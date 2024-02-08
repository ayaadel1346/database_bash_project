#!/bin/bash
submenu(){
echo "What you want to do in $1: "
while true
do
    echo "1. Show tables"
    echo "2. Create new table"
    echo "3. Insert into table"
    echo "4. Select table"
    echo "5. Update table"
    echo "6. Drop table"
    echo "7. Delete from table"
    echo "8. Return to main menu"
    echo -n "Enter your choice: "
    read choice

    case $choice in
        1)
        source showTable.sh
	showTable $1
          ;;
        2)
        source createTable.sh 
	createTable $1
      
          ;;
        3)
        source insertTable.sh
	insert
     
          ;;
        4)
        source select.sh $1
       
          ;;
        5)
        source update.sh
       update    	
	 
          ;;
        6)
        source deleteTable.sh
       deleteTable $1
          ;;
        7)source deleteFromTable.sh
		;;
        8)
	cd ..
        source menu.sh
	Menu
          ;;
        *)
        echo "Invalid option. Please choose again."
          ;;
    esac
done
}

export submenu
