import requests
from bs4 import BeautifulSoup

def trade_spider(max_pages):
    page = 0
    while page < max_pages:
        idx = page * 120
        if page is 0:
            url = 'https://austin.craigslist.org/search/bia'
        else:
            url = 'https://austin.craigslist.org/search/bia?s=' + str(idx)
        source_code = requests.get(url)
        plain_text = source_code.text  # gets rid of all the headers and crap

        # Need to create a beautiful soup object
        soup = BeautifulSoup(plain_text, "html.parser")

        # 'a' means 'anchor' which is html tag for links
        # This will loop through all links with class=='result-title hdrlnk'
        for link in soup.findAll('a', {'class':'result-title hdrlnk'}):
            href = link.get('href')  # this will return href for the link
            title = link.string
            print(title + " -> " + href)
        page += 1

trade_spider(2)
