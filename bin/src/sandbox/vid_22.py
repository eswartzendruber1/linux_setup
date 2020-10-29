import random
import urllib

def download_web_image(url):
    name = random.randrange(1,1000)
    full_name = str(name) + ".jpg"
    image=urllib.URLopener()
    image.retrieve(url,full_name)

download_web_image("https://i.redditmedia.com/NVb2iu62ngLVzlOeER73v_bo2qSXDaDYSdovIOBOAkA.jpg?w=1024&s=cda32136c3bf1178774dbf11480cfc83")


