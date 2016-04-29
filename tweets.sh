
#!/bin/bash

# Twitter script
# Author: Ben Kohl
# Created: 3/13/16

#avoids "illegal byte sequence" error
LANG=C
LC_CTYPE=C

#get main menu options
echo "What would you like to do?"
echo "1. Append to excludingWords.txt"
echo "2. Append to positiveWords.txt"
echo "3. Append to negativeWords.txt"
echo "4. Search for a word in existing tweets"
echo "5. See the top 10 used words"
echo "6. See the top 10 negative words"
echo "7. See the top 10 positive words"
echo "8. Get new tweets"
echo "9. View the logfile"
echo "or press 0 to exit"
read option

case $option in
    0 )
        echo "Exiting..."
        exit
        ;;
    1 )
        echo "Enter word to add to add to excludingWords.txt"
        read exclude
        echo $exclude >> excludingWords.txt
        echo "$exclude succesfully added."
        exit
        ;;
    2 )
        echo "Enter word to add to add to positiveWords.txt"
        read positive
        echo $positive >> positiveWords.txt
        echo "$positive succesfully added."
        exit
        ;;
    3 )
        echo "Enter word to add to add to negativeWords.txt"
        read negative
        echo $negative >> negativeWords.txt
        echo "$negative succesfully added."
        exit
        ;;
    4 )
        #TODO
        echo "Functionality not implemented yet."
        echo "Exiting..."
        exit
        ;;
    5 )
        #TODO
        echo "Functionality not implemented yet."
        echo "Exiting..."
        exit
        ;;
    6 )
        #TODO
        echo "Functionality not implemented yet."
        echo "Exiting..."
        exit
        ;;
    7 )
        #TODO
        echo "Functionality not implemented yet."
        echo "Exiting..."
        exit
        ;;
    8 )
        #get user input
        echo "Please select a category below:"
        echo "1.  News"
        echo "2.  Sports"
        echo "3.  Celebrities"
        echo "4.  Technology"
        echo "5.  Hobbies"
        echo "or press 0 to exit"
        read category
        ;;
    9 )
        cat logfile.txt
        exit
        ;;
    * )
        echo "Invalid input, exiting."
        exit
        ;;

esac

case $category in
    0 )
        echo "Exiting..."
        exit
        ;;
    1 )
        echo "Please select a News option below:"
        echo "1.  US & World News"
        echo "2.  Business & Finance News"
        echo "3.  Journalist & Pundit News"
        echo "5.  Weather News"
        echo "23. Industry News"
        echo "25. Tech News"
        ;;
    2 )
        echo "Please select a Sports option below:"
        echo "7.  NFL"
        echo "8.  NBA"
        echo "9.  College Basketball"
        echo "10. MLB"
        echo "11. Soccer"
        echo "12. NHL"
        echo "13. NASCAR"
        echo "14. WWE"
        echo "15. MMA"
        echo "16. Golf"
        echo "17. College Football"
        ;;
    3 )
        echo "Please select a Celebrities option below:"
        echo "18. Celebrity News"
        echo "19. TV Stars"
        echo "20. Actors & Actresses"
        echo "21. Reality TV"
        echo "23. Industry News"
        echo "24. Celebrity Gamers"
        ;;
    4 )
        echo "Please select a Tech option below:"
        echo "25. Tech News"
        echo "26. Tech Influencers"
        echo "27. Space"
        echo "28. Science"
        ;;
    5 )
        echo "Please select a Hobbies option below:"
        echo "29. Food & Drink"
        echo "30. Parenting"
        echo "31. DIY & Home"
        echo "33. Travel"
        echo "34. Fitness & Wellness"
        echo "35. Car Culture"
        ;;
    * )
        echo "Invalid category, exiting."
        exit
        ;;
esac

read cmd
url="https://twitter.com/i/streams/stream/$cmd"

currently=`date +"%m-%d-%Y %T"`
echo "Current date is $currently"

#get html from twitter page
wget -O twitter.html ${url}

#dump basic outline and text to file
lynx --dump twitter.html > twitter.txt

#get lines after 'seconds ago'
grep -i -A 4 'seconds ago' twitter.txt > output.txt
grep -i -A 4 'minutes ago' twitter.txt >> output.txt
grep -i -A 4 'hours ago' twitter.txt >> output.txt

#remove unnecessary text
sed -i.txt '/seconds ago/d' output.txt
sed -i.txt '/minutes ago/d' output.txt
sed -i.txt '/hours ago/d' output.txt

#replace symbols
sed -i.txt 's/\[.*\]\[DEL: @ :DEL\] /@/g' output.txt
sed -i.txt 's/\[.*\]\[DEL: # :DEL\] /#/g' output.txt
sed -i.txt 's/\[.*\]\[DEL: @ :DEL\]/@/g' output.txt
sed -i.txt 's/\[.*\]\[DEL: # :DEL\]/#/g' output.txt
sed -i.txt 's/.\:.*Details//g' output.txt
sed -i.txt 's/\[.*\]http.*//g' output.txt
sed -i.txt 's/\[.*\]pic.*//g' output.txt
sed -i.txt 's/\.//g' output.txt
sed -i.txt 's/\://g' output.txt
sed -i.txt 's/\!//g' output.txt
sed -i.txt 's/\?//g' output.txt
sed -i.txt 's/\"//g' output.txt
sed -i.txt 's/\--//g' output.txt
sed -i.txt 's/\,//g' output.txt
sed -i.txt 's/[()]//g' output.txt
sed -i.txt 's/\-/ /g' output.txt
sed -i.txt 's/\// /g' output.txt

#get one word per line
tr ' ' '\n' < output.txt > outputTemp1.txt

#remove empty lines
sed '/^$/d' outputTemp1.txt > outputTemp2.txt

#remove any remnants
sed -i.txt 's/\[.*//g' outputTemp2.txt
sed -i.txt 's/\].*//g' outputTemp2.txt

#remove empty lines
sed '/^$/d' outputTemp2.txt > outputTemp3.txt

#convert to lower case
tr '[:upper:]' '[:lower:]' < outputTemp3.txt > outputTemp4.txt

#get the number of words in file
numWords=$(wc -w < outputTemp4.txt)

#clear outputTemp5.txt
echo > outputTemp5.txt

while [ $numWords -gt 0 ]
do
    #get the first word in a file
    word=$(head -n 1 outputTemp4.txt)

    #count instances of that word
    wordCount=$(grep -o -w "$word" outputTemp4.txt | wc -l)
    echo $wordCount $word >> outputTemp5.txt

    #delete instances of that word
    sed -i.txt "s/^$word$//g" outputTemp4.txt

    #remove empty lines
    sed -i.txt '/^$/d' outputTemp4.txt

    numWords=$(wc -w < outputTemp4.txt)
done

#numerically sort output
sort -nr outputTemp5.txt > outputTemp6.txt


#sort outputTemp6.txt excludingWords.txt|uniq -u

#get file size
size=$(stat -f%z output.txt)

#append to logfile.txt
printf "%20s %20s %10s %10s" "$currently" "$url" "output.txt" "$size" >> logfile.txt

#remove temporary files
rm output.txt.txt
rm outputTemp1.txt
rm outputTemp2.txt
rm outputTemp2.txt.txt
rm outputTemp3.txt
rm outputTemp4.txt
rm outputTemp4.txt.txt
rm outputTemp5.txt
rm twitter.html
rm twitter.txt



