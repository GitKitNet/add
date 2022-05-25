
#Если вам нужен секундомер, вы можете сделать это:

while true; do echo -ne "`date`\r"; done

#Это покажет вам секунды, проходящие в реальном времени, и вы можете остановить это с помощью Ctrl+ C. Если вам нужна более высокая точность, вы можете использовать это, чтобы дать вам наносекунды:
while true; do echo -ne "`date +%H:%M:%S:%N`\r"; done
#Наконец, если вам действительно нужен "формат секундомера", где все начинается с 0 и начинает расти, вы можете сделать что-то вроде этого:

date1=`date +%s`; while true; do 
   echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
done
#Для таймера обратного отсчета (а это не то, о чем спрашивал ваш исходный вопрос) вы можете сделать это (соответственно измените секунды):

seconds=20; date1=$((`date +%s` + $seconds)); 
while [ "$date1" -ge `date +%s` ]; do 
    echo -ne "$(date -u --date @$(($date1 - `date +%s` )) +%H:%M:%S)\r"; 
done
#Вы можете объединить их в простые команды, используя функции bash (или любую другую оболочку, которую вы предпочитаете). В bash добавьте эти строки в ваш ~/.bashrc(это sleep 0.1заставит систему ждать 1/10 секунды между каждым запуском, чтобы вы не спамили свой процессор):

function countdown(){
   date1=$((`date +%s` + $1)); 
   while [ "$date1" -ge `date +%s` ]; do 
     echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
     sleep 0.1
   done
}
function stopwatch(){
  date1=`date +%s`; 
   while true; do 
    echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r"; 
    sleep 0.1
   done
}
#Затем вы можете запустить таймер обратного отсчета на одну минуту, выполнив:

countdown 60
#Вы можете отсчитывать два часа с помощью:

countdown $((2*60*60))
#или целый день с использованием:

countdown $((24*60*60))
#И запустите секундомер, запустив:

stopwatch

# Если вам нужно иметь дело с днями, а также часами, минутами и секундами, вы можете сделать что-то вроде этого:

countdown(){
    if [[ "$1" =~ ^[[:digit:]]+$ ]]; then T="$1"; else T="5"; fi && date1=$((`date +%s` + $T));
    while [ "$date1" -ge `date +%s` ]; do 
    ## Is this more than 24h away?
    days=$(($(($(( $date1 - $(date +%s))) * 1 ))/86400))
    echo -ne "$days day(s) and $(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r"; 
    sleep 0.1
    done
}
stopwatch(){
    date1=`date +%s`; 
    while true; do 
    days=$(( $(($(date +%s) - date1)) / 86400 ))
    echo -ne "$days day(s) and $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
    sleep 0.1
    done
}
