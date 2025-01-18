#!/bin/bash

# This script sets up a Tomcat-like honeypot for capturing exploits and malicious activity.
# It installs necessary dependencies, creates a vulnerable interface, and starts the service.

# Function to prompt for user input
get_input() {
    read -p "$1" input
    echo "$input"
}

# Prompt for the desired URL for the honeypot
HONEYPOT_URL=$(get_input "Enter the URL for the honeypot (e.g., http://your-server-ip/tomcat-manager/): ")

# Update package lists to ensure we have the latest information
echo "Updating package lists..."
sudo apt update

# Install required packages for running Apache and PHP
echo "Installing required packages..."
sudo apt install -y apache2 php libapache2-mod-php

# Create the honeypot directory
HONEYPOT_DIR="/var/www/html/honeypot"
sudo mkdir -p $HONEYPOT_DIR

# Create the vulnerable interface (index.html)
echo "Creating honeypot interface..."
cat <<EOL | sudo tee $HONEYPOT_DIR/index.html > /dev/null
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tomcat Manager - Honeypot</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0; /* Light Gray */
            color: #333;
            text-align: center;
            padding: 50px;
        }
        h1 {
            color: #ff5733; /* Eye-catching color */
        }
        .vulnerable-form {
            margin-top: 20px;
            padding: 20px;
            border: 1px solid #ff5733; /* Border color */
            border-radius: 8px;
            background-color: white;
        }
        input[type="text"], input[type="password"] {
            width: 80%;
            padding: 10px;
            margin: 10px 0;
            border-radius: 4px;
            border: 1px solid #ccc;
        }
        input[type="submit"] {
            background-color: #28a745; /* Green */
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 4px;
            cursor: pointer;
        }
    </style>
    <script>
        // Function to log user actions
        function logAction(action) {
            const xhr = new XMLHttpRequest();
            xhr.open("POST", "log.php", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.send("action=" + encodeURIComponent(action));
        }

        // Log when input fields are focused
        function logInputFocus(field) {
            logAction("Focused on " + field);
        }

        // Log when form is submitted (without processing input)
        function handleSubmit() {
            logAction("Attempted to submit login form.");
            alert("Warning! You've been caught in a honeypot!");
            return false; // Prevent actual submission
        }
    </script>
</head>
<body>

    <h1>Tomcat Manager - Honeypot</h1>
    <p>This interface simulates the Tomcat manager.</p>

    <!-- Simulated vulnerable login form -->
    <div class="vulnerable-form">
        <h2>Login Form</h2>
        <form onsubmit="return handleSubmit();"> <!-- Prevent actual submission -->
            <input type="text" name="username" placeholder="Username" required onfocus="logInputFocus('username')"><br>
            <input type="password" name="password" placeholder="Password" required onfocus="logInputFocus('password')"><br>
            <input type="submit" value="Login">
        </form>
    </div>

</body>
</html>
EOL

# Create the logging script (log.php)
echo "Creating logging script..."
cat <<EOL | sudo tee $HONEYPOT_DIR/log.php > /dev/null
<?php
// log.php - Logs user actions to a file along with their IP address and other details

// Specify the log file location
\$logFile = '/var/log/honeypot_actions.log';

// Get the action from POST request
\$action = \$_POST['action'] ?? 'No action specified';

// Get the user's IP address
\$user_ip = \$_SERVER['REMOTE_ADDR'];

// Get additional information about the user agent and headers
\$user_agent = \$_SERVER['HTTP_USER_AGENT'];
\$accept_language = \$_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? 'Not specified';
\$referer = \$_SERVER['HTTP_REFERER'] ?? 'Not specified';

// Log the action with a timestamp, IP address, and additional info
\$logEntry = date('Y-m-d H:i:s') . " - IP: \$user_ip - Action: \$action - User Agent: \$user_agent - Accept-Language: \$accept_language - Referer: \$referer" . PHP_EOL;

file_put_contents(\$logFile, \$logEntry, FILE_APPEND);
?>
EOL

# Set permissions for logging
echo "Setting permissions for logging..."
sudo touch /var/log/honeypot_actions.log
sudo chown www-data:www-data /var/log/honeypot_actions.log

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart apache2

# Provide feedback on setup completion and link to access it
echo "Honeypot setup is complete!"
echo "You can access your honeypot at ${HONEYPOT_URL}"
