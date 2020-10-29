# Dictionary of stocks & their prices
# key is stock name, value is price
stocks = {
    'GOOG' : 520.54,
    'FB' : 76.45,
    'YHOO' : 39.28,
    'AMZN' : 306.21,
    'AAPL' : 99.76
    }

# Create a list (instead of dict) by using zip 
# zip will create one list from two lists with each entry being two values together
# Note - output of zip isn't really a list, but can kinda be treated like a list.
stocks_list = zip(stocks.values(), stocks.keys())

#min
price,stock = min(stocks_list)
print("Min: " + str(price) + " - " + stock + "\n")

# sort
print(sorted(zip(stocks.values(), stocks.keys())))

# Why does this not work?
sorted_list = sorted(stocks_list)
print(sorted_list)

