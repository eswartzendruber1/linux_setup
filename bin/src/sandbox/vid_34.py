import threading

class BuckysMessenger(threading.Thread):

    # 'run' is a special thread function
    def run(self):
        # use the '_' if you just want to loop 10 times and don't care about variable
        for _ in range (10):
            print(threading.currentThread().getName())

x = BuckysMessenger(name='Send out messages')
y = BuckysMessenger(name='Receive messages')

# The start function basically goes to class and looks for 'run' function
x.start()
y.start()
