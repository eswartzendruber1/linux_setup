# Dictionary - Key:value
classmates = {'Tony':'cool but smells', 'Emma':'sits behind me', 'Lucy':'asks too many questions'}

print(classmates)

# prints value for Key = Emma
print(classmates['Emma'])

# loop through all
for k, v in classmates.items():
    print("{0} -> {1}".format(k, v))
