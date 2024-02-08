#!/bin/bash

# database directory path
db_path="$(pwd)"

# Read database name 
db_name=$1


while true; do
     read -p "Select a table: " table_name
    table_path="$db_path/$table_name"

    if [ ! -f "$table_path" ]; then
        echo "Table $table_name does not exist!"
    else
        break
    fi
done

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
    # Display the selected row and delete it
    awk -v col_index="$col_index" -v filter_value="$filter_value" -F: '$col_index == filter_value { print }' "$table_path"
    # Create a temporary file to store updated data
    awk -v col_index="$col_index" -v filter_value="$filter_value" -F: '$col_index != filter_value { print }' "$table_path" > "$table_path.temp"
    # Replace the original file with the temporary file
    mv "$table_path.temp" "$table_path"
    echo "Row deleted successfully."
fi

echo "============================"
