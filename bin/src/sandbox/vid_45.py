from PIL import Image

ella = Image.open("ella.jpg")

# this returns tuple
ella_r,ella_g,ella_b = ella.split()

#new_img = Image.merge("RGB", (r,g,b))
#new_img.show()

clara = Image.open("clara.jpg")
clara_r,clara_g,clara_b = clara.split()

new_img = Image.merge("RGB", (ella_r, clara_g, ella_b))
new_img.show()
