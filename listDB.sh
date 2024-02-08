#!/bin/bash
dir=$(pwd)
if [ "$(ls -A $dir)" ]; 
    
    then
    echo "======================="
    echo "AVAILABLE DATABASES IS:"
    echo "======================="
    ls $dir 
    echo "======================="
    source menu.sh
    Menu

else 
    echo "========================="
    echo "NO AVAILABLE DATABASES!"
    echo "=========================="
    source menu.sh
    Menu
    
fi

