# dictionary
stocks = {
    'AAPL' : 201,
    'GOOG' : 800,
    'F' : 54,
    'MSFT' : 313,
    'TUNA' : 68,
    'AMZN' : 623,
    }

min_price = min(zip(stocks.values(), stocks.keys()))
print(min_price)