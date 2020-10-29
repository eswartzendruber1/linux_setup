class Parent():

    def print_last_name(self):
        print('Roberts')

# put name of parent class inside parens to make child class of parent class
class Child(Parent):

    def print_first_name(self):
        print('Bucky')

    #child can override functions
    def print_last_name(self):
        print('Snitzleberg')


bucky = Child()
bucky.print_first_name()
bucky.print_last_name()

dad = Parent()
dad.print_last_name()