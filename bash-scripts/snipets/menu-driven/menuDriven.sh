#!/usr/bin/ksh

# Helps to change values using this menu driven script
cvsprops=FileA.props  

# Executing include file, to simulate variable declaration.
# This is a must,, since its a parameter driven script.
. FileA.props

user_prompt='To Change Above Defaults Make A Selection:[n] '
PS3="${user_prompt}"

REDISPLAY=true  # Helps to exit from Menu.

while [ "$REDISPLAY" == "true" ]; do
select line in $(egrep -v "#" $cvsprops ) REVIEW DONE
do
        [ "$line" == "DONE" ] && REDISPLAY=false && break
        [ "$line" == "REVIEW" ] && break

        [ ! -n "$line" ] && echo " Invalid choice:[$REPLY]. Please make correct choice." && continue

        user_var="$(echo $line | cut -d= -f1)"
        user_value="$(echo $line | cut -d= -f2)"

        #echo "Length of $user_value --> ${#user_value}"

        # if required variable is not set. Prompt user to set it.
        if [ ! -n "$user_value" ]; then
                echo "Set --> ${user_var} ?: \c"
        else
                echo "Change --> ${user_var}:[${user_value}] ?: \c"
        fi
        read user_value
        if [ -n $user_value ]; then
            echo "new value for ${user_var} --> $user_value" 
           
            # *** This is failing.. How can I change say 
            # myvar1 value to 'mytest4' !!?
            
            # $((user_var))=$user_value
            eval "$user_var=$user_value"
        fi

done # End of - select

done # End of while
# EOF
