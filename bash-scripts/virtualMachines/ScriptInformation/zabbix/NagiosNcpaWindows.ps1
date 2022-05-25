
# Installing Nagios Windows monitoring agent
Invoke-WebRequest -Uri "https://assets.nagios.com/downloads/ncpa/ncpa-2.3.1.exe" -OutFile "C:\ncpa.exe"
C:\ncpa.exe /S /TOKEN='($TOKEN)'
