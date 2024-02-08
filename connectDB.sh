#!/bin/bash

while true; do
    echo -e "Enter Database Name: \c"
    read -r db_name

    # Check if the input starts with a space
    if [[ $db_name =~ ^[[:space:]] ]]; then
        echo "Invalid database name! Database name cannot start with a space."
        continue
    fi

    # Check if the database name contains at least two characters
    if [ ${#db_name} -lt 2 ]; then
        echo "Invalid database name! Database name must contain at least two characters."
        continue
    fi

    # Check if the database name contains only letters, numbers, or underscores
    if [[ ! $db_name =~ ^[[:alpha:]][[:alnum:]]*$ ]]; then
        echo "Invalid database name!"
        continue
    fi

    path=$(pwd)
    cd "$path/$db_name" 2> /dev/null

    if [ $? -eq 0 ]; then
        echo "========================================="
        echo "Connected to $db_name Successfully!!!!!!"
        echo "========================================="
        source submenu.sh
        submenu "$db_name"
        break
    else
        echo "================================"
        echo "Database $db_name wasn't found!!"
        echo "================================"
        source menu.sh
        Menu
    fi
done
