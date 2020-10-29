from PIL import Image

clara = Image.open("clara.jpg")
ella = Image.open("ella.jpg")
#area = (200, 200, 1040, 1240)
#cropped_ella = ella.crop(area)

#ella.show()
#cropped_ella.show()
clara_area = (234, 589, 741, 1105)
cropped_clara = clara.crop(clara_area)
#cropped_clara.show()

paste_area = (234+200, 589, 741+200, 1105)
ella.paste(cropped_clara, paste_area)
ella.show()