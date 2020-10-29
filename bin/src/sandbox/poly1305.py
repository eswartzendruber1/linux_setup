def byte_swizzle(data, size):
    w = 0
    for i in range(size):
        w = w | ((data%(2**8)) * (2**((size-1-i)*8)))
        data = data/(2**8)
    return w

def byte_swizzle_flit(flit):
    w = 0
    for i in range(16):
        w = w | ((flit%(2**8)) * (2**((15-i)*8)))
        flit = flit/(2**8)
    return w


def flit_to_32bit(flit):
    r = []
    for i in range(4):
        r.append(flit%(2**32))
        flit = flit/(2**32)
    return r

def simple_poly_mul_col(m0_0, m0_1, m1_0, m1_1, m2_0, m2_1, m3_0, m3_1, m4_0, m4_1):
    print "x = 0x{0:x} + 0x{1:x} + 0x{2:x} + 0x{3:x} + 0x{4:x}".format((m0_0*m0_1), (m1_0*m1_1), (m2_0*m2_1), (m3_0*m3_1), (m4_0*m4_1))
    print "x = 0x{0:x}\n".format(m0_0*m0_1 + m1_0*m1_1 + m2_0*m2_1 + m3_0*m3_1 + m4_0*m4_1)
    x = m0_0*m0_1 + m1_0*m1_1 + m2_0*m2_1 + m3_0*m3_1 + m4_0*m4_1
    print "x = 0x{0:x}\n".format(x)
    return x
    

def simple_poly_mul(h, r):
    rr = []
    for ri in r:
        rr.append((ri/4)*5)

    x = []
        
    print "x0 = h[0]*r[0] + h[1]*rr[3] + h[2]*rr[2] + h[3]*rr[1] + h[4]*rr[0];"
    x.append(simple_poly_mul_col(h[0], r[0], h[1], rr[3], h[2], rr[2], h[3], rr[1], h[4], rr[0]))
    #print "x0 = 0x{0:x} + 0x{1:x} + 0x{2:x} + 0x{3:x} + 0x{4:x}".format((h[0]*r[0]), (h[1]*rr[3]), (h[2]*rr[2]), (h[3]*rr[1]), (h[4]*rr[0])); 
    #print "x0 = 0x{0:x}".format(h[0]*r[0] + h[1]*rr[3] + h[2]*rr[2] + h[3]*rr[1] + h[4]*rr[0]);
        
    print "x1 = h[0]*r[1] + h[1]*r[0]  + h[2]*rr[3] + h[3]*rr[2] + h[4]*rr[1];"
    x.append(simple_poly_mul_col(h[0], r[1],  h[1], r[0] ,  h[2], rr[3],  h[3], rr[2],  h[4], rr[1]))

    print "x2 = h[0]*r[2] + h[1]*r[1]  + h[2]*r[0]  + h[3]*rr[3] + h[4]*rr[2];"
    x.append(simple_poly_mul_col(h[0], r[2],  h[1], r[1] ,  h[2], r[0] ,  h[3], rr[3],  h[4], rr[2]))
    
    print "x3 = h[0]*r[3] + h[1]*r[2]  + h[2]*r[1]  + h[3]*r[0]  + h[4]*rr[3];"
    x.append(simple_poly_mul_col(h[0], r[3],  h[1], r[2] ,  h[2], r[1] ,  h[3], r[0] ,  h[4], rr[3]))
    
    print "x4 = h[4] * (r[0] & 3); // ...recover those 2 bits"
    print "x4 = 0x{0:x} * 0x{1:x}".format(h[4], (r[0]%(2**2)))
    print "x4 = 0x{0:x}\n".format(h[4] * (r[0]%(2**2)))
    x.append(h[4] * (r[0]%(2**2)))

    for xi in x:
        print "{0:x}".format(xi)

    msb = x[4] + (x[3]/(2**32))
    while msb > 3:
        u = (msb/(2**2))*5
        print "msb = 0x{0:x}, u = 0x{1:x}, x[0] = {2:x}".format(msb, u, x[0])
        u = u+(x[0]%(2**32))
        h[0] = u%(2**32);
        u = u/(2**32)
        #print "u0.2 = {0:x}".format(u)
        for i in range(1,4):
            u = u+(x[i]%(2**32)) + (x[i-1]/(2**32))
            x[i-1] = h[i-1]
            h[i] = u%(2**32);
            u = u/(2**32)
            #print "u{0}.2 = {1:x}".format(i, u)
        x[3] = h[3]
        u = u+(msb%(2**2))
        msb = u
        x[4] = u
        for xi in x:
            print "{0:x}".format(xi)
        print "\n"

    acc = 0
    for i,xi in enumerate(x):
        acc = acc | (xi * (2**(32*i)))
    return acc
        

#def simple_poly(r_key, s_key, data):
#    r = flit_to_32bit(r_key)
#
#    for d in data:
#        h = []
#        h = flit_to_32bit(d)
#        for i,hi in enumerate(h):
#            h[i] = byte_swizzle(hi)
#            print "h[{0}] = {1:x} -> {2:x}".format(i,hi,h[i])
#        h.append(0x1)
#        simple_poly_mul(h, r)
        
def simple_poly(r_key, s_key, data):
    r = flit_to_32bit(r_key)

    for d in data:
        h = []
        d_rev = byte_swizzle(d,16)
        h = flit_to_32bit(d_rev)
        #for i,hi in enumerate(h):
        #    h[i] = byte_swizzle(hi,4)
        h.append(0x1)
        acc = simple_poly_mul(h, r)
    print "acc = 0x{0:x}".format(acc)
    acc = acc + s_key
    print "acc + s_key = 0x{0:x}".format(acc)
    for i in range(4):
        print "0x{0:x}".format(byte_swizzle(acc%(2**32),4))
        acc = acc/(2**32)
        
    #rr = []
    #for ri in r:
    #    print "{0:x}".format(ri)
    #    rr.append((ri/4)*5)
    #
    #for rri in rr:
    #    print "{0:x}".format(rri)


def rtl_poly_mul(h, r):
    rh = []

    for ri in r:
        rih = []
        for hi in h:
            rih.append(ri*hi)
            print "{0:x} * {1:x} -> 0x{2:x}".format(ri,hi,(ri*hi))
        rh.append(rih)

    x = [0, 0, 0, 0, 0]
    for i in range(4):
        for j in range(5):
            #print "rh[{0}][{1}] = 0x{2:x}".format(i, j, rh[i][j])
            idx = i + j
            val = rh[i][j] % (2**32)
            if idx == 4:
                x[idx] =  x[idx] + (rh[i][j]%4)
                div4 = (rh[i][j]/4) % (2**32)
                div4x4 = (rh[i][j] % (2**32)) & 0xfffffffc
                val = div4 + div4x4 
                if (idx%4) == 1:
                    print "Adding: 0x{0:x} + 0x{1:x} = 0x{2:x}".format(div4, div4x4, val)
            elif idx > 4:
                div4 = (rh[i][j]/4) % (2**32)
                #div4x4 = ((rh[i][j]/4)*4) % (2**32)
                div4x4 = (rh[i][j] % (2**32)) & 0xfffffffc
                val = div4 + div4x4 
                if (idx%4) == 1:
                    print "Adding: 0x{0:x} + 0x{1:x} = 0x{2:x}".format(div4, div4x4, val)
            else:
                if (idx%4) == 1:
                    print "Adding: 0x{0:x}".format(val)
                
            x[idx%4] = x[idx%4] + val
            idx = i + j + 1
            val = rh[i][j] / (2**32)
            if idx == 4:
                x[idx] =  x[idx] + ((rh[i][j] / (2**32))%4)
                div4 = (rh[i][j]/4) / (2**32)
                #div4x4 = ((rh[i][j]/4)*4) / (2**32)
                div4x4 = (rh[i][j] / (2**32)) & 0xfffffffc
                val = div4 + div4x4 
                if (idx%4) == 1:
                    print "Adding: 0x{0:x} + 0x{1:x} = 0x{2:x}".format(div4, div4x4, val)
            elif idx > 4:
                div4 = (rh[i][j]/4) / (2**32)
                #div4x4 = ((rh[i][j]/4)*4) / (2**32)
                div4x4 = (rh[i][j] / (2**32)) & 0xfffffffc
                val = div4 + div4x4 
                if (idx%4) == 1:
                    print "Adding: 0x{0:x} + 0x{1:x} = 0x{2:x}".format(div4, div4x4, val)
            else:
                if (idx%4) == 1:
                    print "Adding: 0x{0:x}".format(val)
            x[idx%4] = x[idx%4] + val

    for xi in x:
        print "{0:x}".format(xi)

    msb = x[4] + (x[3]/(2**32))
    u = (msb/(2**2))*5
    u = u+(x[0]%(2**32))
    h[0] = u%(2**32);
    u = u/(2**32)
    #print "u0.2 = {0:x}".format(u)
    for i in range(1,4):
        u = u+(x[i]%(2**32)) + (x[i-1]/(2**32))
        x[i-1] = h[i-1]
        h[i] = u%(2**32);
        u = u/(2**32)
        #print "u{0}.2 = {1:x}".format(i, u)
    x[3] = h[3]
    u = u+(msb%(2**2))
    msb = u
    x[4] = u
    for xi in x:
        print "{0:x}".format(xi)
    print "\n"
    acc = 0
    for i,xi in enumerate(x):
        acc = acc | (xi * (2**(32*i)))
    return acc

    
        
def rtl_poly(r_key, s_key, data):
    r = flit_to_32bit(r_key)

    for d in data:
        h = []
        d_rev = byte_swizzle(d,16)
        h = flit_to_32bit(d_rev)
        #h = []
        #h = flit_to_32bit(d)
        #for i,hi in enumerate(h):
        #    h[i] = byte_swizzle(hi,4)
        h.append(0x1)
        acc = rtl_poly_mul(h, r)
    print "acc = 0x{0:x}".format(acc)
    acc = acc + s_key
    print "acc + s_key = 0x{0:x}".format(acc)
    for i in range(4):
        print "0x{0:x}".format(byte_swizzle(acc%(2**32),4))
        acc = acc/(2**32)
        

r_key = 0x0194b248074050800c815f900ba0d58a
s_key = 0x46a6d1fde2b8db08a50dfde337b633a8
data = [0x57a229af57a229af57a229af57a229af]#, 0x57a229af57a229af57a229af57a229af]
simple_poly(r_key, s_key, data)
rtl_poly(r_key, s_key, data)
    
#print "r_key = 0x{0:x}".format(r_key)
#print "r_key0 = 0x{0:x}".format(r[0])
#print "r_key1 = 0x{0:x}".format(r[1])
#print "r_key0 = " + '\xr_key0' + "\n")

