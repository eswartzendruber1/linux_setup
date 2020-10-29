# the asterix basically means flexible number of arguments
# the name could be anything, but "args" is commonly used 
def add_numbers(*args):
    total = 0
    for a in args:
        total += a
    print(total)

add_numbers(3)

add_numbers(3, 32)

add_numbers(3, 32, 434, 4345, 5234, 5325)