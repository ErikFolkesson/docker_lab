basename=$(shell docker inspect --format='{{.NetworkSettings.Networks.crawlernet.Gateway}}' webserver)
n=2

# to run the application you need to prepare the environment (make create_web) \
  (now you should be also able to access the index.html page from your browser, e.g., make surf if you use google-chrome) \
  then you need to install the Pythion packeges to run the Python scripts (make install) \
  finally you can run the application: \
  - open a new terminal in this folder and launch the server (make run_server) \
  - open a new terminal in this folder and launch n clients (make run_clients) \

surf:
	google-chrome --incognito http://$(basename):8080 2> /dev/null

install:
# if this does not work, you could need to install the packages through the apt-get command
	pip3 install -q requests --upgrade
	pip3 install -q bs4 --upgrade

run_server:
	python3 server.py

run_clients:
	for i in $$(seq ${n}); do python3 client.py http://$(basename):8080 page_$$i.html & done

create_web:
	docker rm -v -f $$(docker ps -qa) 2> /dev/null || true
	docker system prune -a --volumes
	docker network create --driver bridge crawlernet || true
	docker run --name webserver -v ./html:/usr/share/nginx/html:ro --network crawlernet -p 8080:80 -d nginx:stable-alpine
	docker inspect --format='{{.NetworkSettings.Networks.crawlernet.Gateway}}' webserver
	