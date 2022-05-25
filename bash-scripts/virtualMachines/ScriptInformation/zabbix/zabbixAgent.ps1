Invoke-WebRequest -Uri "https://cdn.zabbix.com/zabbix/binaries/stable/5.4/5.4.10/zabbix_agent2-5.4.10-windows-amd64-openssl.msi" -OutFile "C:\zabbix.msi"
msiexec /l*v log.txt /i C:\zabbix.msi /qn SERVER=($ZABBIX_SERVER)
