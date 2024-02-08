#!/bin/bash

# Define the database directory path
db_path="$(pwd)"

# Read database name from the command line argument
db_name=$1

# Prompt the user to select a table
read -p "Select a table: " table_name
table_path="$db_path/$table_name"

if [ ! -f "$table_path" ]; then
    echo "Table does not exist!!!!!!"
    exit 1
else
    echo "1. Show all rows"
    echo "2. Select a specific row"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            # Show Table Content
            echo "============================"
            echo "$table_name table contains: "
            echo "============================"
            while IFS=: read -r -a columns; do
                for col in "${columns[@]}"; do
                    echo -n "$col "
                done
                echo
            done < "$table_path"
            echo "============================"
            ;;
        2)
            read -p "Enter column name to filter: " column_name
            read -p "Enter value for $column_name: " filter_value

            # Show specific row based on condition
            echo "============================"
            echo "Selected row from $table_name where $column_name = $filter_value: "
            echo "============================"

            # Find the column index
            col_index=$(awk -F: -v col="$column_name" 'NR==1 { for (i=1; i<=NF; i++) { if ($i == col) { print i; exit } } }' "$table_path")

            if [ -z "$col_index" ]; then
                echo "Column $column_name not found in the table."
            else
                awk -v col_index="$col_index" -v filter_value="$filter_value" -F: '$col_index == filter_value { print }' "$table_path"
            fi

            echo "============================"
            ;;
        *)
            echo "Invalid choice!"
            exit 1
            ;;
    esac
fi
