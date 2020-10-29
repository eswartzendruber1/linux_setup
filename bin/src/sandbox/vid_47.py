from PIL import Image

clara = Image.open("clara.jpg")
square_clara = clara.resize((250, 250))

square_clara.show()

flip_clara = clara.transpose(Image.FLIP_LEFT_RIGHT)
flip_clara.show()

spin_clara = clara.transpose(Image.ROTATE_90)
spin_clara.show()