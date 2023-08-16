while IFS= read -r line
do
  echo "$line"
  sleep 0.05
done < "cat_ansi"

sleep 5
echo ""
echo -n "Rebooting in 3"
sleep 1
echo -n "...2"
sleep 1
echo -e "...1\n"
sleep 1
