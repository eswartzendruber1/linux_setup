from PIL import Image
from PIL import ImageFilter

ella = Image.open("clara.jpg")

# Convert to black & white (L = luminense)
bw = ella.convert("L")
#bw.show()

blur = ella.filter(ImageFilter.BLUR)
#blur.show()

detail = ella.filter(ImageFilter.DETAIL)
detail.show()

edges = ella.filter(ImageFilter.FIND_EDGES)
edges.show()