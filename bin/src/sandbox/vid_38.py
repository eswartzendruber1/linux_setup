
def drop_first_last(grades):
    # This must be python 3 syntax
    first, *middle, last = grades  # puts all items in the middle into middle list
    avg = sum(middle) / len(middle)
    print(avg)

drop_first_last([65, 76, 98, 54, 21])
