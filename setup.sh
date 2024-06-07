#!/bin/bash

# Function to create the banner
create_banner() {
    echo "############################################################################"
    echo "#                                                                          #"
    echo "#                           S3 Enumeration Tool                            #"
    echo "#                      :-  Developed by Raman & Vasiya                     #"
    echo "#                                                                          #"
    echo "############################################################################"
    echo ""
}

# Display the banner
create_banner

# Prompt the user for the target
read -p "Please enter the target: " TARGET

# Path to the Ruby script
RUBY_SCRIPT="path/to/your/script.rb"

# Check if the Ruby script exists
if [ -f "$RUBY_SCRIPT" ]; then
    # Execute the Ruby script with the target as an argument
    ruby "$RUBY_SCRIPT" "$TARGET"
else
    echo "Error: Ruby script '$RUBY_SCRIPT' not found."
    exit 1
fi

