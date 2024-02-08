#!/bin/bash
deleteTable(){
	path=$(pwd)
read  -p  "Enter Table you want to delete: " table_name
table_path=$path/$table_name
table_metapath=$path/.$table_name.metadata
if [ ! -f "$table_path" ]; then

    echo "==========================="	
    echo "Table does not exist!!!!!!"
    echo "==========================="

    source submenu.sh 
   submenu $1

else
    	echo -e "Are you Sure You Want To delete $table_name Table? y/n \c"
	read choice;
	case $choice in
		 [Yy]* ) 
			rm -r "$table_path" "$table_metapath"
                	echo "============================================"
         		echo "Table $table_name deleted successfully!!!!!!"
         		echo "============================================"
			;;
		 [Nn]* ) 
      			echo "======================"
			echo "Deleting Canceled!!!"
      			echo "======================"
			;;
		 * ) 
		 	echo "===================="
			echo "Please choice y/n"
			echo "===================="
			;;
	esac
  
    source submenu.sh
   submenu $1

fi
}
export deleteTable
