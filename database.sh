#!/bin/bash

# Check if the "database" directory exit

if [ -d "database" ];
then
   echo "the main database already exist, write database word to get menu"
else
	echo " there is no main database , creating....... done :),now write database name to get menu"
    mkdir database
    
fi

 database(){
	if [ -d "database" ]
	then
		cd database
		source menu.sh
		Menu

	fi

       


}



