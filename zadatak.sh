#!/bin/bash
#


db=""
first_menu() {
	echo "1. Create new database"
	echo "2. Log in existing database"
	echo "3. Quit"
}
menu() {
	echo "1. Select data from tables"
	echo "2. Delete data from tables"
	echo "3. Insert data into tables"
	echo "4. Edit data"
	echo "5. Show table"
	echo "6. Back"
}
insert() {

	echo "Enter table data."
	#Counting numbers for ID and echo in file
	ID=$(awk '/^\*\* [0-9]+/ {print $2}' "$db_name" | sort -n | tail -n 1)
	ID=$(($ID + 1))
	echo -n "** $ID      " >> "$db_name"
	#Insert values for table with one row lenght - 8 characters
	read podatak1
        if [ -z "podatak1" ];then
                podatak1="        "
        fi
        read podatak2
        if [ -z "podatak2" ];then
                podatak2="        "
        fi
        read podatak3
        if [ -z "podatak3" ];then
                podatak3="        "
        fi
        for podatak_1 in "$podatak1"; do
                printf "*""%-8.8s" " $podatak1 "  >> "$db_name"
        done
        for podatak_2 in "$podatak2"; do
                printf "*""%-8.8s" " $podatak2 "  >> "$db_name"
        done
        for podatak_3 in "$podatak3"; do
                printf "*""%-8.8s" " $podatak3 "  >> "$db_name"
        done

	echo "**" >> "$db_name"

}
delete(){
	echo "Enter ID of row you want to delete."
	read ID
	#Finding ID we want to delete
	if [[ "$ID" =~ ^[0-9]+$ ]]; then
		sed -i "/^\\*\\* $ID /d" "$db_name"
	fi
		
}
create_db() {
	echo "Name database?"
	read name
	db="$name.database"
	if [ -f "$db" ]; then
		echo "Database "$db" already existed."
		
	else 	
	       	echo "Database "$db" created."
		touch "$db"
		echo "$name" > "$db"
			echo "***************************************" >> "$db"
		create_table
	fi
}
create_table(){
	#Read what are column names and put in table with - 8 characters max
	echo "What are names of fields?"
	read unos1
	if [ -z "unos1" ];then
		unos1="        "
	fi
	read unos2
	if [ -z "unos2" ];then
                unos2="        "
	fi
	read unos3
	if [ -z "unos3" ];then
                unos3="        "
	fi
	echo -n "** ID     " >> "$db"
	for unos in "$unos1"; do                
	      	printf "*""%-8.8s" " $unos1 "  >> "$db"
	done
	for unos in "$unos2"; do
                printf "*""%-8.8s" " $unos2 "  >> "$db"
        done
	for unos in "$unos3"; do                       
                printf "*""%-8.8s" " $unos3 "  >> "$db"
        done
	echo "**" >> "$db"
}
login_db() {
	echo "Name database?"
	read nameex
	db_name="$nameex.database"
	#Checking if already have database with same name
	if [ -f "$db_name" ]; then
                echo "Database "$db_name" is found."
		tail +2 "$db_name"	
	else 
		echo "Database doesn't exist."
		pocetni_meni
	fi
	meni

}
select_data() {
	echo "Do you want to search by ID or by name of field?"
	read id_or_field
	if [ "$id_or_field" == "id" ]; then
		echo "Which ID you want to select?"
		read id_select
		#Check if ID is number and print us row with ID we input
		if [[ "$id_select" =~ ^[0-9]+$ ]]; then
			result_id=$(awk -F'\*\*\ ' -v  id="$id_select" '$2 ~ "^"id {print $0}' "$db_name")
			if [ -n "$result_id" ]; then
				echo "$result_id"
			else
				echo "ID doesn't exist."

			fi
		fi
	#Check for name of header if match continue next function search_by_field
	elif [ "$id_or_field" == "name" ]; then
		echo "Enter a name of the field."
		read ime_field
		#This script prompts the user to input an ID, checks if it's a valid number, and then searches for the corresponding record in the database
		search_by_field
	else
		echo "Enter "id" or "name"."
		select_data
	fi
}
search_by_field() {
	#Find third line of database and removes whitespaces and split into array using "*" to separate
	naslov_field=$(sed -n '3p' "$db_name" | xargs)
	IFS='*' read -ra columns <<< "$naslov_field"
	
	#Loop throw columns and finding where is the field we looking for and save that position in "column_position"
	column_position=-1
	for i in "${!columns[@]}"; do
   	column="${columns[$i]}"
    	column=$(echo "$column" | xargs)
    		if [ "$column" == "$ime_field" ]; then
        	column_position=$((i + 1))
        	break
    		fi
	done

	if [ "$column_position" -eq -1 ]; then
    	echo "Column '$ime_field' not found!"
    	return
	fi
	awk -F ' *\\* *' -v column="$column_position" 'NR > 3 { print $column }' "$db_name"
}

edit_data() {
	echo "Which ID want to edit?"
	read id_edit
	#This script prompts the user to input an ID, checks if it's a valid number, and then searches for the corresponding record in the database
        	if [[ "$id_edit" =~ ^[0-9]+$ ]]; then
        	result_edit=$(awk -F'\*\*\ ' -v  id="$id_edit" '$2 ~ "^"id {print $0}' "$db_name")
                	if [ -n "$result_edit" ]; then
                                echo "$result_edit"
                        else
                                echo "ID doesn't exist."

                        fi
                fi

	echo "Which column you want to edit?"
	read which_data
	
	naslov_edit=$(sed -n '3p' "$db_name" | xargs)
	IFS=' * ' read -ra columns <<< "$naslov_edit"
	
        #Loop throw columns and finding where is the field we looking for and save that position in "column_position"
	column_position=-1
        for i in "${!columns[@]}"; do
        column="${columns[$i]}"
	column=$(echo "$column" | xargs)
                if [ "$column" == "$which_data" ]; then
                column_position=$((i + 1))
                break
                fi
        done


	if [ "$column_position" -eq -1 ]; then
	echo "Column not found!"
	return
	fi
	
	echo "Enter new value for column '$which_data':" #### ovde treba namestiti zvezzdice i to
	read new_value
	line_number=$(grep -n "^** $id_edit" "$db_name" | cut -d: -f1)
	if [ -z "$line_number" ]; then
   		 echo "ID not found."
    		return
	fi ####
	# Update the table ### KAD EDITUJEM TREBA NAMESTITI DA BUDE MAX 8 karaktera i da razmakne posle broj ID jos razmake da napravi da se poravna
	# TREBA NAMESTITI
	awk -v row="$line_number" -v col="$column_position" -v val="$new_value" -F' \\ *' '
NR == row {$col = val}1' OFS=" " "$db_name" > temp.txt && mv temp.txt "$db_name"
}

pocetni_meni() {
	while true; do
		first_menu
		read -p "Choose an action: " action1
		case $action1 in
			1)	create_db 	
				;;
			2)	login_db
				;;
			3)	sleep 1s
				exit
				;;	
		esac
	done
}
#meni petlja
meni() {
	while true; do
		menu
		read -p "Choose an action: " action
		case $action in
			1) 	select_data
				;;
			2)	delete
				;;
			3)	insert
				;;
			4)	edit_data
				;;
			5)	cat "$db_name"
				;;
			6)
				sleep 1s
				pocetni_meni
				;;
			*)
				echo "Invalid option. Try something else."
				;;
		esac
	done
}
pocetni_meni
