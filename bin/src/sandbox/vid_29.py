# common to name class using capital
class Enemy:
    life = 3

    # "self" - it means use parameters from its own class
    def attack(self):
        print('ouch!')
        self.life -= 1  # need to tell which life to decrement

    def checkLife(self):
        if self.life <= 0:
            print('I am dead')
        else:
            print('Life = {0}'.format(self.life))

# Need to create object to access stuff inside your class
enemy1 = Enemy()
enemy2 = Enemy()

enemy1.attack()
enemy1.attack()
enemy1.checkLife()
enemy2.checkLife()


