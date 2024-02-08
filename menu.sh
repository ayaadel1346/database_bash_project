#!/bin/bash

# Main Menu
Menu() {
	while true
	do
    echo "Main Menu:"
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect To Database"
    echo "4. Drop Database"
    read -p "Enter your choice: " choice
    case $choice in
        1) source createDB.sh ;;
        2) source listDB.sh ;;
        3) source connectDB.sh ;;
        4) source dropDB.sh ;;
        *) echo "Invalid choice" ;;
    esac
done
}
export Menu
