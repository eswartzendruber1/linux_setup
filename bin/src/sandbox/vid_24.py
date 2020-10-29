#from urllib import request
import urllib

avgo_url = 'https://query1.finance.yahoo.com/v7/finance/download/AVGO?period1=1526670227&period2=1529348627&interval=1d&events=history&crumb=X36q/QtSD/X'
txtfile_url = 'https://web.mit.edu/kerberos/krb5-1.15/README-1.15.3.txt'

def download_stock_data(csv_url):
    #response = request.urlopen(csv_url)
    #csv = response.read()
    # This is different for python2 vs python3
    csv = urllib.urlopen(csv_url).read()
    csv_str = str(csv)
    lines = csv_str.split("\\n")
    dest_url = r'sample_web_file.txt'  # 'r' -> raw - do not need to escape characters - just good practice
    fx = open(dest_url, "w")
    for line in lines:
        fx.write(line + "\n")
    fx.close()

download_stock_data(txtfile_url)