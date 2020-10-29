while True:
    try:
        number = int(input("What's your fav number?\n"))
        print(18/number)
        break
    except NameError:
        print("NameError: Invalid input.  Try again.")
    except ZeroDivisionError:
        print("ZeroDivisionError: Try again.")
    # Try not to use except because you basically don't know what happened.
    except:
        print("Something went wrong.")
        break
    # This gets executed no matter what (exception or not)
    finally:
        print("Loop Iteration Complete.")


