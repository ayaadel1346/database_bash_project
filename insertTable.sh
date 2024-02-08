#!/bin/bash

source validation.sh

insert() {
	
    check_var=1
    while [ $check_var -eq 1 ]; do
        read -p "Enter table name : " tab_name
        if [ -f "$PWD/$tab_name" ]; then
            check_var=0
        else
            echo "Table name does not exist❌"
            continue
        fi
    done

    num_col=$(awk -F ':' '{print NF}' "$PWD/$tab_name")

    echo "${tab_name}:${num_col}:$1" >> ../.logs

    kContinue=yes
    while [ "$kContinue" = "yes" ]; do
        r=0
        while [ $r -lt $num_col ]; do
            in_col_name=$(head -1 "$PWD/$tab_name" | awk -v var=$((r+1)) -F ':' '{print $var}')
            read -p "Enter the value for column ${in_col_name} : " col_value

            ValidateDatatype "$1" "$tab_name" "$r" "$col_value"
            dataType=$?
            if [ $dataType -eq 1 ]; then
                continue
            fi

            checkNull "$1" "$tab_name" "$r" "$col_value"
            is_null=$?
            if [ $is_null -eq 1 ]; then
                continue
            fi

            if [ "${col_value,,}" = "null" ]; then
                is_null=2
            fi

            pk_exist=$(head -$((r+1)) "$PWD/.${tab_name}.metadata" | tail -1 | awk -F ':' '{print $4}')

            if [ "$pk_exist" = "PK" ]; then
                check_uniqueness "$1" "$tab_name" "$col_value" "$((r+1))"
                unique_val=$?
                if [ $unique_val -eq 1 ]; then
                    echo "You must enter a unique value❌"
                    continue
                fi
            
 fi

            if [ $is_null -eq 2 ]; then
                col_value=null
            fi

            if (( r == 0 )); then
                echo -n "${col_value}:" >> "$PWD/$tab_name"
            elif (( r == (num_col-1) )); then
                echo "${col_value}" >> "$PWD/$tab_name"
            else
                echo -n "${col_value}:" >> "$PWD/$tab_name"
            fi

            ((r++))
        done

        row_prompt=yes
        while [ "$row_prompt" = "yes" ]; do
            echo "Do you want to insert another row?"
            echo "1) Yes"
            echo "2) No"
            read  var
            if [ "$var" = "Yes" ] || [ "$var" = "1" ]; then
                kContinue=yes
                row_prompt=no
                continue
            elif [ "$var" = "No" ] || [ "$var" = "2" ]; then
                kContinue=no
                row_prompt=no
                break
            else
                echo "Enter valid input❌"
                row_prompt=yes
            fi
        done
    done
    orderRowsByPK "$1" "$tab_name"
    
}

export insert

