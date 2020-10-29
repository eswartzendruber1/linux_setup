class Girl:
    gender = 'female' # Object Variable: The gender will all be female for all objects

    def __init__(self, name):
        self.name = name  # Instance Variable: The name will be unique to each object

r = Girl('Rachel')
s = Girl('Stacey')

print(r.gender)
print(s.gender)

print(r.name)
print(s.name)