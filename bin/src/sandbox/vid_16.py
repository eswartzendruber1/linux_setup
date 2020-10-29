def dumb_sentence(name='Bucky', action='ate', item='tuna'):
    print("%s %s %s" % (name, action, item))
    print("{0} {1} {2}".format(name, action, item))

# use defaults
dumb_sentence()

# pass in all arguments
dumb_sentence("Sally", "farts", "gently")

#pass in some arguments and/or out-of-order
dumb_sentence(item='awesome', action='is')

