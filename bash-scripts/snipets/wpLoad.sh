#/bin/bash

function WORDPRESS_LOAD()
{
  #creating user
  echo -e "${YELLOW}Adding separate user & creating website home folder for secure running of your website...${NC}"

  echo -e "${YELLOW}Please enter website name: ${NC}"
  read websitename
  mkdir -p /var/www/$websitename
  chown -R www-data:www-data /var/www/$websitename





# ------------------
read -r -p "Do you want to install WordPress automatically? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])

# ------------------
# меню.
function menu()
{
  clear
  echo
  echo -e "${GREEN}Please, choose WordPress language you need (set RUS or ENG): "
  echo -e "\t1. Russion lang (RUS)"
  echo -e "\t2. English lang (ENG)"
  echo -e "\t3. Default (ENG)"
  echo -en "\t\tВведите: "
  read -n 1 option
}

while [ $? -ne 1 ]
do
  menu
  case $option in
    0) echo "Cancel and Quit..." && break ;;
    1) wordpress_lang="RUS" && break ;;
    2) wordpress_lang="ENG" && break ;;
    3) wordpress_lang="ENG" && break ;;
    *) clear && echo "Нужно выбрать раздел"
    ;;
  esac
  echo -en "\n\n\t\t\tНажмите любую клавишу для продолжения";
  read -n 1 line
done

# read wordpress_lang
if [ "$wordpress_lang" == 'RUS' ]; then
  wget https://ru.wordpress.org/latest-ru_RU.zip -O /tmp/$wordpress_lang.zip
else
  wget https://wordpress.org/latest.zip -O /tmp/$wordpress_lang.zip
fi

echo -e "Unpacking WordPress into website home directory..."
sleep 5
unzip /tmp/$wordpress_lang.zip -d /var/www/$websitename
mv /var/www/$websitename/wordpress/* /var/www/$websitename
rm -rf /var/www/$websitename/wordpress
rm /tmp/$wordpress_lang.zip
mkdir -p /var/www/$websitename/wp-content/uploads
chmod -R 777 /var/www/$websitename/wp-content/uploads
chown -R www-data:www-data /var/www/$websitename



;;
*) echo -e "${RED}WordPress  were not downloaded & installed.${NC}"

;;
esac
}
