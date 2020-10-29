from struct import *

# STore as bytes data
# "iif" - store 2 integers and a float
packed_data = pack('iif', 6, 19, 4.73)
print(packed_data)

print(calcsize('i'))
print(calcsize('f'))
print(calcsize('iif'))

# To get bytes data back to normal
original_data = unpack('iif', packed_data)
print(original_data)

print(unpack('iif', b'\x06\x00\x00\x00\x13\x00\x00\x00)\\\x97@'))