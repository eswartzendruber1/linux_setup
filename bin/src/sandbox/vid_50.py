income = [10,30,75]

def double_money(dollars):
    return dollars * 2

# Could make for loop to go through all items.
# Instead, use map
new_income = list(map(double_money, income))
print(new_income)
