<#
# приостановить или возобновить
# защиту BitLocker
#>

# приостановить защиту BitLocker:
Suspend-BitLocker -MountPoint "C:"

# возобновить защиту BitLocker (приостановленного диска):
Resume-BitLocker -MountPoint "C:"

##===========================##
<#

echo "     резервное копирование        "
echo " ключей восстановления BitLocker  "
echo "        для всех дисков           "

<#
 Этот метод работает путем создания сценария
 PowerShell, поэтому вы можете создавать
 резервные копии ключей восстановления
 BitLocker для всех дисков сразу. 
#>

# Export the BitLocker recovery keys for all drives
# and display them at the Command Prompt.
$BitlockerVolumers = Get-BitLockerVolume
$BitlockerVolumers |
ForEach-Object {
  $MountPoint = $_.MountPoint
  $RecoveryKey = [string]($_.KeyProtector).RecoveryPassword
  if ($RecoveryKey.Length -gt 5) {
    Write-Output ("The drive $MountPoint has a BitLocker recovery key $RecoveryKey.")
  }
}

pause

#exit 1

#>


##===========================##
<#
#>
