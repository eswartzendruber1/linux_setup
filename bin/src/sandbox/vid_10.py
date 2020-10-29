magicNumber = 12


'''
This is a multi-line
comment
'''

# This is a single line comment
for n in range(101):
    if n is magicNumber:
        print(n, " is the magic number!")
        break
    else:
        print(n)

#Homework - print all numbers between 0-100 that are a multiple of 4
# solution 1:
for n in range(101):
    if (n%4) == 0:
        print(n)

# solution 2:
for n in range (0,100/4+1):
    print(n*4);