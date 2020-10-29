class Mario():
    def move(self):
        print('I am moving!')


class Shroom():
    def eat_shroom(self):
        print('Now I am big!')

# When we create a BigMario object, it will get everything from both Mario & Shroom
class BigMario(Mario, Shroom):
    pass  # this is basically just an empty line

bm = BigMario()
bm.move()
bm.eat_shroom()
