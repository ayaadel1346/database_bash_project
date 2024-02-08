#!/bin/bash

current_dir=$(pwd)

while true; do
    echo -e "Enter the Name of the Database: \c"
    read -r db_name

    # Check if the database name consists of two characters or more
    if [ ${#db_name} -ge 2 ]; then
        # Check if the first character is a letter or underscore
        if [[ $db_name =~ ^[[:alpha:]][[:alnum:]]*$ ]]; then
            # Check if the database name consists of letters, numbers, or underscores only
            if [[ $db_name =~ ^[[:alnum:]_]+$ ]]; then
                # Check if the database directory already exists
                if [ -d "$current_dir/$db_name" ]; then
                    while true; do
                        echo "Database $db_name already exists!"
                        echo "1) Connect"
                        echo "2) Return to Menu"
                        read -p "Enter your choice: " choice
                        case $choice in
                            1)
                                source connectDB.sh
                                ;;
                            2)
                                source menu.sh
				Menu
                                ;;
                            *)
                                echo "Invalid choice! Please enter 1 or 2."
                                ;;
                        esac
                    done
                else
                    # Create the database directory
                    mkdir -p "$current_dir/$db_name"
                    echo "===================================="
                    echo "Database $db_name created successfully!"
                    echo "===================================="
                fi
                break
            else
                echo "Invalid database name! Please use letters, numbers, or underscores only."
            fi
        else
            echo "Invalid database name! The first character must be a letter or underscore."
        fi
    else
        echo "Database name must consist of two characters or more."
    fi
done
