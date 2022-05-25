## #############################
MENU_func() {
  # ----------------------
  #    Меню Установки
  # ----------------------
function menu {
  clear && echo
  echo -en "# ---------------------- #\n\tМеню Установки\n# ---------------------- #"
  echo -en "\t1. Select 1"
  echo -en "\t2. Select 2"
  echo -en "\t3. Select 3"

  echo -e "\t0. Выход"
  echo -en "\t\tВведите номер раздела: "
  read -n 1 option
}

# ----------------------
# меню
while [ $? -ne 1 ]
do
  menu
  case $option in
    0) break
;;
    1) echo $option
;;
    2) echo $option
;;
    3) echo $option
;;
    *) clear && echo "Сделайте выбор "
;;
  esac
  echo -en "\n Продолжить..? \n";
  read -n 1 line
done
clear
}

MENU_func
