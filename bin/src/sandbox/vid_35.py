import requests
from bs4 import BeautifulSoup
import operator

def start(url):
    word_list = []  #empty list
    source_code = requests.get(url).text # just reads source of webpage as text
    soup = BeautifulSoup(source_code, "html.parser")
    #print(soup.prettify())
    for post_text in soup.findAll('p'):
        content = str(post_text.string)  # Get rid of HTML tags & crap
        words = content.lower().split()  # lower-case everything & split into words
        for each_word in words:
            word_list.append(each_word)
    clean_up_list(word_list)

# There are other ways to do this, but this is for demonstration
def clean_up_list(word_list):
    clean_word_list = []
    for word in word_list:
        symbols = "!@#$%^&*()_+{}:\"<>?|-=[]\;',./1234567890"
        for i in range(0, len(symbols)):
            word = word.replace(symbols[i], "")
        if len(word) > 0:
            clean_word_list.append(word)
    create_dictionary(clean_word_list)

def create_dictionary(clean_word_list):
    word_count = {}
    for word in clean_word_list:
        if word in word_count:
            word_count[word] += 1
        else:
            word_count[word] = 1
    # 'key' in sorted() indicates what you want to sort by
    # operator - allows you to work with data types
    # itemgetter() - gets item in dictionary to sort by
    #  - 0 -> sort by key; 1 -> sort by value
    for k, val in sorted(word_count.items(), key=operator.itemgetter(1)):
        print(k, val)
        



website = 'https://askubuntu.com/questions/423355/how-do-i-check-if-a-package-is-installed-on-my-server'
start(website)
