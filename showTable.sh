#!/bin/bash
showTable(){

current_path=$(pwd)
if [ -n "$current_path" ];

    then
        echo "Existing Tables in $1: "
        echo "========================"

        ls $current_path
        echo "========================"
else
        echo "========================"
        echo "NO Tables to Show !!!! "
        echo "========================"

fi

}
export showTable
