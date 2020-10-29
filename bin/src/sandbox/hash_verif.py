hashes = set()
for i in range(0,255):
    hash_7 = ((i>>5) & 1) ^ ((i>>4) & 1) ^ ((i>>3) & 1)
    hash_6 = ((i>>4) & 1) ^ ((i>>3) & 1) ^ ((i>>2) & 1)
    hash_5 = ((i>>7) & 1) ^ ((i>>3) & 1) ^ ((i>>2) & 1) ^ ((i>>1) & 1)
    hash_4 = ((i>>6) & 1) ^ ((i>>2) & 1) ^ ((i>>1) & 1) ^ ((i>>0) & 1)
    hash_3 = ((i>>4) & 1) ^ ((i>>3) & 1) ^ ((i>>1) & 1) ^ ((i>>0) & 1)
    hash_2 = ((i>>7) & 1) ^ ((i>>5) & 1) ^ ((i>>4) & 1) ^ ((i>>2) & 1) ^ ((i>>0) & 1)
    hash_1 = ((i>>7) & 1) ^ ((i>>6) & 1) ^ ((i>>5) & 1) ^ ((i>>1) & 1)
    hash_0 = ((i>>6) & 1) ^ ((i>>5) & 1) ^ ((i>>4) & 1) ^ ((i>>0) & 1)

    hash = (hash_7 << 7) | (hash_6 << 6) | (hash_5 << 5) | (hash_4 << 4) | (hash_3 << 3) | (hash_2 << 2) | (hash_1 << 1) | hash_0
    #print(hash)
    if hash in hashes:
        print("FAIL on hash = {0}".format(hash))
    else:
        hashes.add(hash)



