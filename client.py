import os
import sys
import time
import socket
import requests
import configparser
from bs4 import BeautifulSoup

#process id
pid = os.getpid()

#set of urls to visit
tovisit = set()

#set url prefix for all urls to visit
basename = sys.argv[-2] + "/"

#retrieve the server hostname and the port number to use
config = configparser.ConfigParser()
config.read('crawler.cfg')
HOST = config['server']['host']
PORT = int(config['server']['port'])

#create a single session to reuse TCP connections
session = requests.Session()

#ask server if the input url has been visited already: if yes return immediately otherwise download the related webpage and add all the links to the set
def visit(page):
    url = basename + page
    soc = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    soc.connect((HOST, PORT))
    soc.sendall(url.encode())
    visited = soc.recv(64)
    soc.close()
    if visited.decode() == "Y":
        print("[Process #%s] %s skipped" % (pid, url))
        return
    else:
        print("[Process #%s] parsing %s" % (pid, url))
        try:
            resp = session.get(url)
            resp.raise_for_status()
        except requests.exceptions.RequestException as e:
            # transient errors retry
            print(f"[Process #{pid}] network error, {url} added again")
            tovisit.add(page)
            return
        soup = BeautifulSoup(resp.text, 'html.parser')
        for link in soup.find_all('a'):
            tovisit.add(link.get('href'))
        return

#add the first link to the set and continue to consume the urls until the set is empty
tovisit.add(sys.argv[-1])
while tovisit:
    url = tovisit.pop()
    visit(url)

print("Process #%s completed, bye!" % pid)
time.sleep(1)
