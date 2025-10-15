# Number of clients to run
n=2

# Build the docker images
build:
	docker-compose build

# Create the network and start the webserver
up:
	docker-compose up -d webserver

# Stop and remove containers, networks
down:
	docker-compose down -v

# Run the server
run_server:
	docker-compose up server

# Run n clients in parallel
run_clients:
	@for /l %i in (1, 1, $(n)) do @start /b docker-compose run client python client.py http://webserver:80 page_%i.html

# Run n clients in parallel (for bash/zsh)
run_clients_bash:
	@for i in $$(seq 1 ${n}); do \
		docker-compose run client python client.py http://webserver:80 page_$$i.html & \
	done

# Open the webserver index page in the browser
surf:
	@echo "Please open http://localhost:8080 in your browser"

# Install python dependencies locally (optional, for local testing)
install:
	pip3 install -r requirements.txt

	