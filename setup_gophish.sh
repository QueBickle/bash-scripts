#!/bin/bash

# This script sets up Gophish using Docker and configures Nginx for HTTPS redirection.

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed. Please install Docker first."
        exit 1
    fi
}

# Start and enable Docker service
start_docker() {
    echo "Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
}

# Run Gophish container
run_gophish() {
    # Remove existing container if it exists
    if [ "$(sudo docker ps -aq -f name=gophish)" ]; then
        echo "Removing existing Gophish container..."
        sudo docker rm -f gophish
    fi

    echo "Running Gophish container..."
    sudo docker run --name gophish -p 3333:3333 -d gophish/gophish
}

# Configure Nginx for HTTPS redirection
configure_nginx() {
    local domain="example.com"  # Change this to your actual domain

    echo "Configuring Nginx for HTTPS redirection..."
    echo "server {
        listen 80;
        server_name $domain;
        return 301 https://\$server_name\$request_uri;
    }" | sudo tee /etc/nginx/sites-available/$domain

    # Enable the site (optional)
    sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
    
    # Restart Nginx (make sure Nginx is installed and running)
    sudo systemctl restart nginx
}

# Open Gophish in Firefox
open_gophish() {
    echo "Opening Gophish in Firefox..."
    firefox localhost:3333 &
}

# Main function to orchestrate the setup
main() {
    check_docker
    start_docker
    run_gophish
    configure_nginx
    open_gophish

    echo "Gophish setup completed successfully!"
}

# Execute the main function
main
