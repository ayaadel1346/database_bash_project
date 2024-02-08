#!/bin/bash

source validation.sh

update() {
    condition_check=1
    while [[ $condition_check = 1 ]]; do
        read -p "Enter table name to update : " tbname
        tbname=$(echo "$tbname")
        if [[ -f "./$tbname" ]]; then
            condition_check=0
        else
            echo "This name doesn't exist❌"
            continue
        fi
    done

    condition_check=1
    while [[ $condition_check = 1 ]]; do
        read -p "Enter column you want to update: " col_name
        col_exist=$(head -1 "./$tbname" | awk -F ':' -v name="$col_name" '{ for (i = 1; i <= NF; i++) { if ($i==name) { print i;exit; } } }')
        if [[ -z $col_exist ]]; then
            echo "Column name doesn't exist❌"
            continue
        else
            condition_check=0
        fi
    done

    validation_check=1
    while [[ $validation_check = 1 ]]; do
        ((col_num=col_exist-1))
        read -p "Enter your new value : " new_value
        ValidateDatatype "./" "$tbname" "$col_num" "$new_value"
        validation_check=$?
        if [[ $validation_check = 1 ]]; then
            continue
        else
            validation_check=0
        fi
        checkNull "./" "$tbname" "$col_num" "$new_value"
        validation_check=$?
        if [[ $validation_check = 1 ]]; then
            continue
        fi
        if [[ $validation_check = 2 ]]; then
            new_value=null
        fi
    done

    pk_exist=$(head -$col_exist "./.$tbname.metadata" | tail -1 | awk -F ':' '{print $4}')
    if [[ $pk_exist = PK ]]; then
        condition_check=condition_applied
    else
        condition_check=1
        while [[ $condition_check = 1 ]]; do
            echo "Do you want to apply a condition?"
            echo "1) Yes"
            echo "2) No"
            read -p "Enter 1 or 2: " is_condition
            if [[ $is_condition == 1 ]]; then
                condition_check=condition_applied
            elif [[ $is_condition == 2 ]]; then
                condition_check=no_condition_applied
            else
                condition_check=1
                continue
            fi
        done
    fi

    while [[ $condition_check = condition_applied ]]; do
        read -p "Enter column that holds your condition : " col_condition
        where_col_exist=$(head -1 "./$tbname" | awk -F ':' -v name="$col_condition" '{ for (i = 1; i <= NF; i++) { if ($i==name) { print i;exit; } } }')
        if [[ -z $where_col_exist ]]; then
            echo "Column name doesn't exist! ❌"
            condition_check=condition_applied
            continue
        else
            echo "Column exists!✅"
            break
        fi
    done

    validation_check=1
    while [[ $condition_check = condition_applied && $validation_check = 1 ]]; do
        read -p "Enter your value : " value
        if [[ -z $value ]]; then
            value=null
        fi
        no_row_affect=0
        no_row_affect=$(awk -F ':' -v aw_where_col_num="$where_col_exist" -v val="$value" -v aw_new_value="$new_value" -v aw_col_exist="$col_exist" -v aw_no_row_affect=$no_row_affect '{ if ($aw_where_col_num == val && NR != 1) {aw_no_row_affect++; }} END {print aw_no_row_affect;} ' "./$tbname")

        pk_exist=$(head -$col_exist "./.$tbname.metadata" | tail -1 | awk -F ':' '{print $4}')
        if [[ $pk_exist = PK ]]; then
            row_number=$(awk -F ':' -v aw_where_col_num="$where_col_exist" -v val="$value" -v aw_new_value="$new_value" -v aw_col_exist="$col_exist" -v aw_no_row_affect=$no_row_affect '{ if ($aw_where_col_num == val && NR != 1) {print NR}} ' "./$tbname")
            unique_val=0
            check_uniquenessForUpdate "./" "$tbname" "$new_value" "$col_exist" "$row_number"
            unique_val=$?
            if [[ $no_row_affect > 1 ]]; then
                echo "invalid❌"
                validation_check=1
                continue
            elif [[ $unique_val = 1 && $no_row_affect == 1 ]]; then
                echo "You must enter a unique value❌"
                validation_check=1
                continue
            else
                validation_check=0
                echo "Unique✅"
            fi
        else
            validation_check=0
        fi
    done

    if [[ $condition_check = condition_applied ]]; then
        awk -F ':' -v aw_where_col_num="$where_col_exist" -v val="$value" -v aw_new_value="$new_value" -v aw_col_exist="$col_exist" -v aw_no_row_affect=$no_row_affect '{ if ($aw_where_col_num == val && NR != 1) {OFS = FS; $aw_col_exist = aw_new_value;}} 1' "./$tbname" > "./temp"
        mv "./temp" "./$tbname"
        echo "$no_row_affect row(s) affected"
    elif [[ $condition_check = no_condition_applied ]]; then
        awk -F ':' -v aw_where_col_num="$where_col_exist" -v aw_new_value="$new_value" -v aw_col_exist="$col_exist" -v aw_no_row_affect=$no_row_affect '{  if (NR != 1){ OFS = FS; $aw_col_exist = aw_new_value;}} 1' "./$tbname" > "./temp"
        mv "./temp" "./$tbname"
        no_row_affect=$(wc -l < "./$tbname")
        ((no_row_affect=$no_row_affect-1))
        echo "$no_row_affect row(s) affected"
    fi
    orderRowsByPK "./" "$tbname"
}

export update
