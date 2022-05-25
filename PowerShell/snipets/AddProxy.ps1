function Set-Proxy ( $server,$port)
{
    $server = Read-Host "Добавьте IP"
    $port = Read-Host "Введите PORT"
    Write-Host "$($server):$($port)"
    Start-Sleep -S 2
    If ((Test-NetConnection -ComputerName $server -Port $port).TcpTestSucceeded) {
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value "$($server):$($port)"
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 1
    } Else {
          Write-Error -Message "Неверные настройки прокси-сервера:  $($server):$($port)"
    }
}



# -------------------------------
function Get-MENU()
{
$MENU = @(
Clear-Host
Write-Host "
********  MENU  ********
1.  Добавить прокси
2.  Включить прокси    [ ON  ]
3.  Выключить прокси   [ OFF ]
************************
0. Next"
Start-Sleep -S 2
)

$Again = "Неправильный выбор, попробуйте еще раз!";
$input = Read-Host ${MENU} "Введите";
switch ($input) {
"1" {
    while( -not ( ($choice= (Read-Host "Установить прокси [Y/N] ..?")) -match "y|n")){ "Yes or No"} 
    if ($choice -eq "y") {
        Set-Proxy "$($server) $($port)"
    }
Start-Sleep -S 3
[System.Net.WebProxy]::GetDefaultProxy()
pause
    Get-MENU
}
"2" {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' ProxyEnable -value 1
    Get-MENU
}
"3" {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' ProxyEnable -value 0
    Get-MENU
}
"0" {Write-Host "Выходим"; Start-Sleep -S 2 | break}
default {Clear-Host;Write-Host "${Again}" |Start-Sleep -S 2;Get-MENU}
}
}; 
Get-MENU
Write-Host "Выходим"|Start-Sleep -S 2
exit
# -------------------------------
