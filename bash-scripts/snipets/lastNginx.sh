##########   Установите последнюю версию Nginx на Ubuntu #

# Установите необходимые компоненты:
sudo apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring

# Импортируйте официальный ключ подписи nginx, чтобы apt мог проверить подлинность пакета. Получите ключ.
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# Убедитесь, что загруженный файл содержит правильный ключ:
gpg --dry-run --quiet --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

# Импорт стабильного репозитория Nginx
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list

# Как и в случае с Debian, прикрепите репозиторий к последней версии.
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx

# Чтобы установить nginx в Ubuntu, выполните следующие команды:
sudo apt update
sudo apt install nginx

# Чтобы убедиться, что установка прошла успешно, выполните следующую команду:
sudo nginx -v
