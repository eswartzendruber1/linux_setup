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
            #print(title + " -> " + href)
            get_single_item_data(href)
        page += 1

def get_single_item_data(item_url):
        source_code = requests.get(item_url)
        plain_text = source_code.text  # gets rid of all the headers and crap

        # Need to create a beautiful soup object
        soup = BeautifulSoup(plain_text, "html.parser")
        print(soup.title)

        # find all links on item page and add to set (this will automatically only keep uniq entries)
        #links = set()
        #for link in soup.findAll('a'):  
            #href = link.get('href')
            #links.add(href)
        
        #for l in links:
            #print(l)


trade_spider(1)
