#! /project/tools/python3.6/bin/python3

def permute(left, llist):
    #if len(llist) > 0:
    #    print("left = {0}; list = {1}".format(left, llist))
    #else:
    #    print("left = {0}; list = <empty>".format(left))
    if left < 0:
        #print("Final level: {0}".format(llist))
        plist.append(llist)
    else:
        for i in range(0, len(llist)+1):
            nlist = llist.copy()
            nlist.insert(i, left)
            #print("Insert {0} into location {1}".format(left, i))
            #print("Call permute with left = {0} and nlist = {1}".format(left-1, nlist))
            permute(left-1, nlist)
            #print("Return from permute with left = {0} and nlist = {1}".format(left-1, nlist))
            
    return

#def permute(left, llist):
#    if left < 0:
#        print("Final level: {0}".format(llist))
#    else:
#        llist.append(left)
#        left=left-1
#        permute(left, llist)
#    return

# Main
llist = []
plist = []
r = [ [ [0,0], [1,1], [2,2], [3,3], [4,0] ],
      [ [0,1], [1,2], [2,3], [3,0], [4,1] ],
      [ [0,2], [1,3], [2,0], [3,1], [4,2] ],
      [ [0,3], [1,0], [2,1], [3,2], [4,3] ],
      ]
#r = [ [ [0,0], [1,1], [2,2] ],
#      [ [0,1], [1,2], [2,3] ],
#      ]
rorder = [ [], [], [], [] ]
r0 = 0
r1 = 0
r2 = 0
r3 = 0

num_levels = len(r[0])
permute(num_levels-1, llist)
for r0 in range(len(plist)):
    print("R0: permutation(r0,r1,r2,r3) = {0},{1},{2},{3}".format(r0,r1,r2,r3))
    rorder[0] = plist[r0].copy();
    
    for r1 in range(len(plist)):
        #print("R1: permutation(r0,r1,r2,r3) = {0},{1},{2},{3}".format(r0,r1,r2,r3))
        rorder[1] = plist[r1].copy();
        h_conflict = 0
        x_conflict = 0
        for i in range(0, num_levels):
            if r[0][rorder[0][i]][0] == r[1][rorder[1][i]][0]:
                h_conflict = h_conflict+1
                if h_conflict > 0:
                    break;
                break;
            if r[0][rorder[0][i]][1] == r[1][rorder[1][i]][1]:
                x_conflict = x_conflict+1
                if x_conflict > 4:
                    break;
        if h_conflict > 0 or x_conflict > 4:
            continue;
        
        for r2 in range(len(plist)):
            #print("R2: permutation(r0,r1,r2,r3) = {0},{1},{2},{3}".format(r0,r1,r2,r3))
            rorder[2] = plist[r2].copy();
            h_conflict2 = h_conflict
            x_conflict2 = x_conflict
            for i in range(0, num_levels):
                for rs in range(0, 2):
                    if r[rs][rorder[rs][i]][0] == r[2][rorder[2][i]][0]:
                        h_conflict2 = h_conflict2+1
                        if h_conflict2 > 0:
                            break;
                    if r[rs][rorder[rs][i]][1] == r[2][rorder[2][i]][1]:
                        x_conflict2 = x_conflict2+1
                        if x_conflict2 > 4:
                            break;
                if h_conflict2 > 0 or x_conflict2 > 4:
                    break;
            if h_conflict2 > 0 or x_conflict2 > 4:
                continue;
            
            for r3 in range(len(plist)):
                #print("R3: permutation(r0,r1,r2,r3) = {0},{1},{2},{3}".format(r0,r1,r2,r3))
                rorder[3] = plist[r3].copy();
                h_conflict3 = h_conflict2
                x_conflict3 = x_conflict2

                for i in range(0, num_levels):
                    for rs in range(0, 3):
                        if r[rs][rorder[rs][i]][0] == r[3][rorder[3][i]][0]:
                            h_conflict3 = h_conflict3+1
                            if h_conflict3 > 0:
                                break;
                        if r[rs][rorder[rs][i]][1] == r[3][rorder[3][i]][1]:
                            x_conflict3 = x_conflict3+1
                            if x_conflict3 > 4:
                                break;
                    if h_conflict3 > 0 or x_conflict3 > 4:
                        break;
                if h_conflict3 > 0 or x_conflict3 > 4:
                    continue;
                else:
                    r_pplist = []
                    for rs in range(0, len(r)):
                        #print("r{0} = {1}, {2}, {3}, {4}, {5}".format(rs, r[rs][rorder[rs][0]], r[rs][rorder[rs][1]], r[rs][rorder[rs][2]], r[rs][rorder[rs][3]], r[rs][rorder[rs][4]]))
                        pplist = []
                        for y in range(1,5):
                            prev_pos = 4
                            for x in range(0, len(r)):
                                if r[rs][rorder[rs][y]][0] == r[x][rorder[x][y-1]][0]:
                                    prev_pos = x
                            pplist.append(prev_pos)
                        r_pplist.append(pplist)

                    diff_prev = 0
                    for pp in r_pplist:
                        for x in range(1,len(pp)):
                            if pp[x] != pp[x-1]:
                                diff_prev = 1;
                                break
                        if diff_prev == 1:
                            break
                    if diff_prev == 0:
                        print("Awesome vvvvv")
                        print("H_Conflict = {0}, X_Conflict = {1}".format(h_conflict3, x_conflict3))
                        for rs in range(0, len(r)):
                            print("r{0} = {1}, {2}, {3}, {4}, {5}".format(rs, r[rs][rorder[rs][0]], r[rs][rorder[rs][1]], r[rs][rorder[rs][2]], r[rs][rorder[rs][3]], r[rs][rorder[rs][4]]))
                        for pp in r_pplist:
                            print(pp)
                        
                            
