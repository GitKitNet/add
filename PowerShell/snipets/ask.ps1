
# ***********************************
#               Menu
# ***********************************

# -----------------------------------
function Get-SomeInput() {
  $MENU = "
  ********  MENU  ********
  1. Select 1
  2. Select 2
  3. Select 3
  ************************
  0. Cancel
  Enter"
  $SEL = "Select new."
  Clear-Host
  $choice = Read-Host "${Menu}"
  while($choice -ne "0") {
    if ($choice -eq "1") { Write-Host "SEL1" }
    if ($choice -eq "2") { Write-Host "SEL2" }
    if ($choice -eq "3") { Write-Host "SEL3" }
    Start-Sleep -S 2 | Clear-Host
    $choice = Read-Host "${SEL} ${MENU}"
  }
}; Get-SomeInput;
Write-Host "NextCommands"|Start-Sleep -S 2



# -----------------------------------
function Get-SomeInput() {
  $MENU = @(
    Clear-Host
    Write-Host "
********  MENU  ********
 1.  Выбор 1
 2.  Выбор 2
 3.  Выбор 3
************************
 0. Next"
    Start-Sleep -S 2
  )
  $Again = "Неправильный выбор, попробуйте еще раз!";
  $input = Read-Host ${MENU} "Введите";
    switch ($input) {
      "1" {Write-Host "Yes 1"; Get-SomeInput}
      "2" {Write-Host "Yes 2"; Get-SomeInput}
      "3" {Write-Host "No 3"; Get-SomeInput}
      "0" {Write-Host "Выходим"; Start-Sleep -S 2 | break}
      default {Clear-Host;Write-Host "${Again}" |Start-Sleep -S 2;Get-SomeInput}
    }
}; Get-SomeInput;
Write-Host "NextCommands"|Start-Sleep -S 2

#######################################################
#######################################################








# ***********************************
#    Popup window всплывающее окно
# ***********************************

# -----------------------------------
#    Popup window [Yes/No]
# -----------------------------------
$title = "TITLE"
$message = "Message"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "This means Yes"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "This means No"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $Options, 0)
Switch ($result) {
0 {"==Yes=="};
1 {"==No=="};
}
Write-Host "=NextCommands="


# -----------------------------------
#  Popup Questions[ДА/НЕТ]
function Get-SomeInput() {
Clear-Host
$shell = new-object -comobject "WScript.Shell"
$choice = $shell.popup("Questions",0,"TITLE",4+32) 
    if ($choice -eq "6") { Write-Host "= YES =";Start-Sleep -S 2 }
    if ($choice -eq "7") { Write-Host "= NO =";Start-Sleep -S 2 }
#Write-Host $shell; Write-Host $choice
};
Get-SomeInput
Write-Host "=NextCommands="


# -----------------------------------
function Get-SomeInput() {
    Clear-Host
    $title    = 'something'
    $question = 'Are you sure you want to proceed?'
    $choices  = '&Yes', '&No'
    Write-Host "$question"
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host "CONFIRMED"
    } else { 
        Write-Host "CANCELLED"
        break
    }
}; Get-SomeInput
Write-Host "=NextCommands="


# -----------------------------------
function Get-SomeInput() {
    Clear-Host
    $choice = (new-object -comobject "WScript.Shell").popup("Question",0,"TITLE",4+32);
    if ($choice -eq "4") {Write-Host "Повтор"}
    if ($choice -eq "2") {Write-Host "Отмена";break}
    if ($choice -eq "6") {Write-Host "= Y ="}
    if ($choice -eq "7") {Write-Host "Отмена";break}
    if ($choice -eq "10") {Write-Host "Повтор";Write-Host $choice}
    if ($choice -eq "11") {Write-Host "Продолжить"}
}; Get-SomeInput
Write-Host "=NextCommands="



# -----------------------------------
#  Popup Questions[OK/CANCEL]
function Get-SomeInput() {
    Clear-Host
    $CHOICE = $Host.UI.PromptForChoice('TITLE', 'Question?', @('&Start'; '&Cancel'), 0)  
    if ($CHOICE -eq "1") { Write-Host "CANCEL"; break}
    if ($CHOICE -eq "0") { Write-Host "=== START ==="}
}; Get-SomeInput
Write-Host "=NextCommands="


# -----------------------------------
function Get-SomeInput() {
Clear-Host

$title    = 'something'
$question = 'Are you sure you want to proceed?'

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'
} else {
    Write-Host 'cancelled'
}
}; Get-SomeInput
Write-Host "=NextCommands="



# -----------------------------------
function Get-SomeInput() {
  Clear-Host
  $a = new-object -comobject wscript.shell
  $b = ${a}.popup("Start test?",0, "POPUP WINDOW",1);
  if ($b -eq "2") { Write-Host "CANCEL"; break}
}; Get-SomeInput
Write-Host "=NextCommands="


# -----------------------------------
# SilentlyContinue;Stop;Continue;Inquire;Ignore;Suspend
Write-Warning "$env:ComputerName" -WarningAction Inquire

#######################################################
#######################################################






# ***********************************
#      Only Yes or No
# ***********************************

# -----------------------------------
function Get-SomeInput() {
  Clear-Host
  $TITLE = "Continue [Y/N] ..?"
  while( -not ( ($choice= (Read-Host ${TITLE})) -match "y|n")){ "Yes or No"} if ($choice -eq "y") {Write-Host "=YES="}

}; Get-SomeInput
Write-Host "=NextCommands="


# -----------------------------------
function Get-SomeInput {
  $TITLE = "Начать установку OpenSSH"
  $choice = Read-Host ${TITLE}
  while($choice -ne "y")
  {
      if ($choice -eq "n") {exit}
      if ($choice -eq "y") {break}
      $choice = Read-Host "Only [y/n]"
  }
  Write-Host "Confirmed"
}; Get-SomeInput
Write-Host "=NextCommands="



# -----------------------------------
function Get-SomeInput {
    $ASK = "Введите [yes/no] и нажмите Enter"
    $Again = "Неправильный выбор, попробуйте еще раз! ${ASK}";
    $input = read-host ${ASK};
    switch ($input) {
        "yes" {write-host "Yes"}
        "no"  {write-host "No "}
    default {write-host "${Again}";Get-SomeInput}
    }
}
Get-SomeInput
Write-Host "Confirmed"

#######################################################
#######################################################





## ****************************************************
## Press any key to continue
## ****************************************************

## *********************** ≠≠≠≠ ***********************
Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
Write-Host "=NEXT="

#######################################################
#######################################################



# ***********************************
#    Press any key to continue
# ***********************************

# -----------------------------------
function Get-SomeInput {
  $reply = Read-Host -Prompt "Continue?[y/n]"
  if ( $reply -match "[YESyesYyНУЫнуыНн]" ) { 
      write-host "*** YES ***"
  } else {
      write-host "*** NO ***"; break
  }
  write-host "*** XX ***"
}; Get-SomeInput
Write-Host "=NextCommands="


# -----------------------------------
function Get-SomeInput {
$confirmation = Read-Host "Are you Sure?[y/n]"
if ($confirmation -eq "Y") {
    write-host "*** YES ***"; break
}
write-host "*** NO ***"; break
}; Get-SomeInput
Write-Host "=NextCommands="


# -----------------------------------
function Get-SomeInput {
  $confirmation = Read-Host "Are you Sure?[y/n]"
  if ($confirmation -eq "Y") {
      Write-Host '*** Yes ***'
  } else {
      Write-Host '*** No ***'
  }
}; Get-SomeInput
Write-Host "=NextCommands="


#######################################################
