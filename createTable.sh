#!/bin/bash

#database directory path
db_path="$(pwd)"


createTable() {
    
    source validation.sh

    tablecreated=false
    while true; do
        read -p "Enter table name: " tbname
        if [ ${#tbname} -lt 2 ]; then
            echo "Table name must consist of at least two characters ❌"
            continue
        elif [[ ! $tbname =~ ^[a-zA-Z_]+$ ]]; then
            echo "Invalid table name!❌"
            continue
        fi
        validateDBobjectName "$tbname"
        if [ $? -ne 0 ]; then
            continue
        fi

        if [ ! -f "$db_path/$tbname" ]; then
            touch "$db_path/$tbname"
            touch "$db_path/.$tbname.metadata"
            echo "Table created successfully ✅"
            tablecreated=true
            break
        else
            echo "Table already exists ❌"
        fi
    done

    if [ $tablecreated = true ]; then
        while true; do
            read -p "Enter number of columns (must be greater than zero): " col_num
            if ! [[ "$col_num" =~ ^[0-9]+$ ]]; then
                echo "Invalid input. Please enter a valid integer."
                continue
            fi
            if [ $col_num -le 0 ]; then
                echo "Number of columns must be greater than zero ❌"
                continue
            else
                break
            fi
        done

        not_null_exists=false
        for (( i=0; i < $col_num ; i++ )); do
            while true; do
                read -p "Enter the name of column $(($i+1)): " col_name
                if [ ${#col_name} -lt 2 ]; then
                    echo "Column name must consist of at least two characters ❌"
                    continue
                elif [[ ! $col_name =~ ^[a-zA-Z_]+$ ]]; then
                    echo "Invalid column name!❌"
                    continue
                fi
                validateDBobjectName "$col_name"
                if [ $? -ne 0 ]; then
                    continue
                fi
                col_exist=$(head -1 "$db_path/$tbname" | awk -F ':' -v name="$col_name" '{ for (i = 1; i <= NF; i++) { if ($i==name) { print i;exit; } } }')
                if [ ! -z "$col_exist" ]; then
                    echo "Column name already exists ❌"
                    continue
                else
                    break
                fi
            done

            if [ "$col_name" == "id" ]; then
                col_null=not_null
                echo "id column is set to 'not null' automatically ✅"
                not_null_exists=true
            elif [ $i -eq $(($col_num-1)) ]; then
                if [ "$not_null_exists" = false ]; then
                    echo "You reached the last column. At least one column must be 'not null'."
                    echo "Setting column '$col_name' to 'not null' automatically ✅"
                    col_null=not_null
                else
                    while true; do
                        read -p "Do your column allow null? (Enter '1' for 'null' or '2' for 'not null'): " col_null_choice
                        case $col_null_choice in
                            1) col_null=null ;;
                            2) col_null=not_null ;;
                            *)
                                echo "Enter valid choice '1' for 'null' or '2' for 'not null' ❌"
                                continue
                                ;;
                        esac
                        break
                    done
                fi
            else
                while true; do
                    read -p "Do your column allow null? (Enter '1' for 'null' or '2' for 'not null'): " col_null_choice
                    case $col_null_choice in
                        1) col_null=null ;;
                        2) col_null=not_null; not_null_exists=true ;;
                        *)
                            echo "Enter valid choice '1' for 'null' or '2' for 'not null' ❌"
                            continue
                            ;;
                    esac
                    break
                done
            fi

            echo "What is your data type?"
            echo "1) string"
            echo "2) int"
            while true; do
                read -p "Enter your choice (1 or 2): " choice
                case $choice in
                    1) col_type=string; break ;;
                    2) col_type=int; break ;;
                    *)
                        echo "Enter valid choice 1 or 2 ❌"
                        continue
                        ;;
                esac
            done

            echo "${col_name}:${col_type}:${col_null}" >> "$db_path/.$tbname.metadata"

            if [ $i -eq $(($col_num-1)) ]; then
                echo "${col_name}" >> "$db_path/$tbname"
            else
                echo -n "${col_name}:" >> "$db_path/$tbname"
            fi
        done

        if [ "$not_null_exists" = true ]; then
            # List options for primary key from columns that are not null
            options=""
            while IFS= read -r line; do
                col=$(echo "$line" | cut -d':' -f1)
                null=$(echo "$line" | cut -d':' -f3)
                if [ "$null" == "not_null" ]; then
                    options+="$col "
                fi
            done < "$db_path/.$tbname.metadata"

            if [ -n "$options" ]; then
                # Prompt user to choose primary key column from the list of options
                while true; do
                    echo "Choose a column to be the primary key (Enter the number):"
                    select option in $options; do
                        if [ -n "$option" ]; then
                            # Get the data type and null/not value of the selected column
                            column_info=$(grep "^$option:" "$db_path/.$tbname.metadata")
                            data_type=$(echo "$column_info" | cut -d':' -f2)
                            null_status=$(echo "$column_info" | cut -d':' -f3)
                            # Replace the null/not value with "not null" if it is null
                            if [ "$null_status" == "null" ]; then
                                null_status="not null"
                            fi
                            # Store the primary key
                            primary_key="${option}:${data_type}:${null_status}:PK"
                            # Replace the existing line with the new line including the primary key
                            sed -i "s|^$option:$data_type:$null_status|$primary_key|" "$db_path/.$tbname.metadata"
                            echo "Primary key column set successfully ✅"
                            break 2
                        else
                            echo "Invalid selection ❌"
                        fi
                    done
                done
            else
                echo "Since there are no 'not null' columns, the primary key cannot be set."
            fi
        else
            echo "Since there are no 'not null' columns, the primary key cannot be set."
        fi
    fi
}

# Export the createTable function
export createTable
