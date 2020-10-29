def allowed_dating_age(my_age):
    girls_age = my_age/2 + 7
    return girls_age

erics_limit = allowed_dating_age(42)
joes_limit = allowed_dating_age(49)
print("Eric can date girls %d or older") % erics_limit
print("Joe can date girls %d or older") % joes_limit

# Why don't these prints look the same as the tutorial?
#print("Eric can date girls", erics_limit, "or older")
#print("Joe can date girls", joes_limit, "or older")

