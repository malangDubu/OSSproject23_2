echo "--------------------------"
echo "User Name: 이원정"
echo "Student Number: 12220637"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie.id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie.id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as programmer'"
echo "9. Exit"
echo "--------------------------"

while true; do
	read -p "Enter your choice [ 1-9 ] " selectedNum
	echo "" 

	if [ "$selectedNum" -eq 9 ]; then
		echo "Bye!"
		break
	fi

	if [ "$selectedNum" -eq 1 ]; then
		read -p "Please enter 'movie id' (1~1682) : " inputNum1
		movie_info=$(grep "^$inputNum1|" /C/OSSproject/u.item)
		echo ""
		echo "$movie_info"
		echo ""
	fi

	if [ "$selectedNum" -eq 2 ]; then
		read -p "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n) : " y
		echo ""
		if [ "$y" == "y" ]; then
			awk -F'|' '$7 == "1" { print $1 " " $2 }' /C/OSSproject/u.item | sort -k1,1n | head -n 10
		fi
		echo ""
	fi

	if [ "$selectedNum" -eq 3 ]; then
		read -p "Please enter 'movie id' (1~1682) : " inputNum3
		average_rating=$(awk -F'[[:space:]]+' -v movie_id="$inputNum3" '
		$2 == movie_id {
			total += $3;
			count++
		}
		END {
			printf "average rating of %d : %.5f\n", movie_id, total/count;
		}' /C/OSSproject/u.data)
		echo ""
		echo "$average_rating"
		echo ""
	fi

	if [ "$selectedNum" -eq 4 ]; then
		read -p "Do you want to delete the 'IMDb URL' from u.item'? (y/n) : " y
		echo ""
		if [ "$y" == "y" ]; then
			awk -F'|' -v OFS='|' 'NR<=10 { $5=""; print }' /C/OSSproject/u.item
		fi
		echo ""
	fi

	if [ "$selectedNum" -eq 5 ]; then
		read -p "Do you want to get the data about users from 'u.user'? (y/n) : " y
		echo ""
		if [ "$y" == "y" ]; then
			awk -F'|' 'NR<=10 {
			gender = ($3 == "M") ? "male" : (($3 == "F") ? "female" : "" );
			if (gender != "") {
				print "user", $1, "is", $2, "years old", gender, $4;
			}
		}' /C/OSSproject/u.user
		fi
		echo ""
	fi

	if [ "$selectedNum" -eq 6 ]; then
		read -p "Do you want to Modify the format of 'release data' in 'u.item'? (y/n) : " y
		echo ""
		if [ "$y" == "y" ]; then
			awk -F'|' -v OFS='|' 'NR>1 && $1 >= 1673 && $1 <= 1682 {
			split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", monthNames, " ");
			for (i=1; i<=12; i++) monthMap[monthNames[i]] = sprintf("%02d", i);
			split($3, dateParts, "-");
			$3 = dateParts[3] monthMap[dateParts[2]] dateParts[1];
			print;
		}' /C/OSSproject/u.item
		fi
		echo ""
	fi
	
	if [ "$selectedNum" -eq 7 ]; then
                read -p "Please enter the 'user id' (1~943) : " inputNum7
                movie_ids=$(awk -v user_id="$inputNum7" -F'[[:space:]]+' '$1 == user_id { print $2 }' /C/OSSproject/u.data | sort -n)
		top_movie_ids=$(echo "$movie_ids" | head -10)
		movie_ids_joined=$(echo -n $movie_ids | tr ' ' '|')
                echo ""
                echo "$movie_ids_joined"
                echo ""

		for id in $top_movie_ids; do
			mytitle=$(awk -F'|' -v myId="$id" '$1 == myId {print $2}' /C/OSSproject/u.item)
			echo "$id | $mytitle"
		done
		echo ""
        fi

	if [ "$selectedNum" -eq 8 ]; then
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer' (y/n) : " y
		echo ""
		if [ "$y" == "y" ]; then
			user_ids=$(awk -F'|' '$2 >= 20 && $2 <= 29 && $4 == "programmer" {print $1}' /C/OSSproject/u.user)
			awk -v ids="$user_ids" -F'[[:space:]]+' '
			BEGIN {
				split(ids, id_array, " ")
				for (i in id_array) {
					user_map[id_array[i]]
				}
			}
			$1 in user_map {
				rating[$2]+=$3
				count[$2]++
			}
			END {
				for (m in rating) {
					if (count[m] > 0 ) {
						printf "%d %.5f\n", m, rating[m]/count[m]
					}
				}
			}' /C/OSSproject/u.data | sort -k1,1n
		fi
		echo ""
	fi
done


