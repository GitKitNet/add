
echo "     резервное копирование        "
echo " ключей восстановления BitLocker  "
echo "        для всех дисков           "

<#
# Резервные копии ключей восстановления BitLocker для всех дисков.
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
#>


# Export the BitLocker recovery keys for all drives
$BitlockerVolumers = Get-BitLockerVolume
$BitlockerVolumers |
ForEach-Object {
  $MountPoint = $_.MountPoint
  $RecoveryKey = [string]($_.KeyProtector).RecoveryPassword
  if ($RecoveryKey.Length -gt 5) {
    $BITLOCKER_key = "$env:SYSTEMDRIVE\PS\BitLocker\$RecoveryKey.txt"
    New-Item -Path $BITLOCKER_key -Force -ItemType File
    Write-Output ("
======== BitLocker recovery key ========
PC:     $env:COMPUTERNAME
Drive:  $MountPoint
Key: $RecoveryKey.
") >> $BITLOCKER_key
  }
}


#exit 1
