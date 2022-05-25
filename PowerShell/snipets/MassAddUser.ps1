Write-host -ForegroundColor DarkYellow "

# Скрипт для создания локальных учетных
# записей пользователей и добавления их в группы.#
 # Файл с пользователями должен содержать поля: 
 # username - имя(логин) пользователя # 
 # fullname - полное имя пользователя # 
 # description - описание пользователя # 
 # groups - группа(ы), в которые нужно добавить пользователя(через запятую, без кавычек) #" 
 $Path_to_csv = Read-Host "Введите путь до файла-списка пользователей" 
 $users = Import-Csv $Path_to_csv -Encoding Default -Delimiter ";" 
    foreach ($user in $users) 
        { 
            $username = $user.username 
            $password = $user.password | ConvertTo-SecureString -AsPlainText -Force 
            $groups = @($user.groups) 
            $grs = $user.groups.split(",") 
            $description =$user.description 
            $fullname = $user.fullname New-LocalUser -Name $username -Password $password -FullName "$fullname" -Description "$description" 
    foreach($group in @($grs))
          { 
            Add-LocalGroupMember -Group $group -Member $username 
          } 
        }
