
function MYMENU()
{

function MENU()
{
echo -en "
****   -MENU-   *****
\t1) SELECT 1
\t2) SELECT 2
\t3) SELECT 3
\t\n0) Exit
*********************
";
}


MENU
read -e -p n
case $n in
  1) echo "Selected 1" ;;
  2) echo "Selected 1" ;;
  3) echo "Selected 1" ;;
  0) echo "Cancel"; break ;;
  *) echo "$n-ERROR. EXIT" ;;
esac

}

MYMENU
