# Open a file with write permissions
fw = open('sample.txt', 'w')

fw.write('Writing some stuff in my text file\n')
fw.write('I like bacon')
fw.close()

fr = open('sample.txt', 'r')

# Read all of file and put into string
text = fr.read()  
print(text)
fr.close()