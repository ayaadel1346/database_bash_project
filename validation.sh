#!/bin/bash

CURRENT_DIR=$(pwd)

ValidateNumirecInput() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        return 0
    else
        echo "Please enter numbers only ❌"
        return 1
    fi
}

ValidateDTNumirecInput() {
    if [[ $1 =~ ^[0-9]+$ || $1 == "null" ]]; then
        echo "Data type validated successfully ✅"
        return 0
    else
        echo "Please enter numbers only ❌"
        return 1
    fi
}

orderRowsByPK() {
    PK_fields=0
    PK_fields=$(awk  -F ':' '{ for (i = 1; i <= NF; i++) {if( $i == "PK" ){ print NR; exit;}}}' "$CURRENT_DIR"/"$1"/."$2.metadata")
    PK_type=$(awk  -F ':' '{ for (i = 1; i <= NF; i++) {if( $i == "PK" ){ print $2; exit;}}}' "$CURRENT_DIR"/"$1"/."$2.metadata")
    all_rows=$(wc -l < "$CURRENT_DIR"/"$1"/"$2")
    if [ "$PK_fields" != "" ]; then
        ((all_rows=${all_rows}-1))
        head -1 "$CURRENT_DIR"/"$1"/"$2" >> "$CURRENT_DIR"/temp
        if [ "$PK_type" == "int" ]; then
            tail -"$all_rows" "$CURRENT_DIR"/"$1"/"$2" | sort -t':' -k"$PK_fields","$PK_fields"n  >> "$CURRENT_DIR"/temp
        else
            tail -"$all_rows" "$CURRENT_DIR"/"$1"/"$2" | sort -t':' -k"$PK_fields","$PK_fields"  >> "$CURRENT_DIR"/temp
        fi
        mv "$CURRENT_DIR"/temp "$CURRENT_DIR"/"$1"/"$2"
    fi
}

check_uniqueness() {
    PK_fields=$(awk  -F ':' -v col_num="$4" -v col_val="$3" '{if (col_val == $col_num) {print 1;exit;}}' "$CURRENT_DIR"/"$1"/"$2")
    return $PK_fields
}

check_uniquenessForUpdate() {
    PK_fields=$(awk  -F ':' -v col_num="$4" -v col_val="$3" -v row_num="$5" '{if (col_val == $col_num && NR != row_num) {print 1;exit;}}' "$CURRENT_DIR"/"$1"/"$2")
    return $PK_fields
}

checkNull() {
    ((line_number_in_metadatafile=$3+1))
    is_null=$(head -$line_number_in_metadatafile "$CURRENT_DIR"/"$1"/."$2.metadata" | tail -1 | awk -F ':' '{print $3}') #$3 is the third field (null,not_null)
    if [ "$is_null" = "not_null" ] && ( [ -z "$4" ] || [ "$4" = "null" ] ); then
        echo "Not ok, your column is not_null and you inserted nothing❌"
        return 1
    elif [ "$is_null" = "null" ] && [ -z "$4" ]; then
        echo "Ok, your column is null and you inserted nothing✅"
        return 2
    else
        echo "Okay about null check✅"
        return 0
    fi
}

ValidateDatatype() {
    ((line_num=$3+1))
    dataType=$(head -"$line_num" "$CURRENT_DIR"/"$1"/".$2.metadata" | tail -1 | awk -F ':' '{print $2}')

    if [ "$dataType" = "int" ]; then
        ValidateDTNumirecInput "$4"
        var=$?
        return $var
    else
        inputString="$4"
        if [[ "$inputString" =~ [0-9] ]]; then
            echo "Error: String should not contain numbers❌"
            return 1
        elif [[ "$inputString" =~ [^a-zA-Z0-9_[:space:]] ]]; then
            echo "Error: String should not contain special characters❌"
            return 1
        else
            echo "Data type checked successfully✅"
        fi
    fi
}

validateDBobjectName() {
    if [[ "$1" =~ ^[A-Za-z][A-Za-z0-9]*$ ]]; then
        return 0
    else
        echo "Not a valid name. Do not start with a number or special character, and avoid spaces.❌"
        return 1
    fi
}

# Export all functions
export  ValidateNumirecInput
export  ValidateDTNumirecInput
export  orderRowsByPK
export  check_uniqueness
export  check_uniquenessForUpdate
export  chechNull
export  ValidateDatatype
export  validateDBobjectName
