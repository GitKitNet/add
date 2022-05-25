

function F1() {
for j in $( for i in $( echo {k..k}{I..K}{a..z}); do echo $i; done | sort | xargs); do 
v='com';
echo "${j}.${v}"; done;
 }
F1


#   Generate name or aa ab ac
######################
for letter in {a..z} ; do echo $letter; done

######################
echo -e {{a..z}{a..z}{a..z}}"\n" | nl

######################
for j in $(for i in $(echo {a..z}{A..Z}{a..z} ); do echo $i; done| sort | xargs); do echo "$j.com"; done;

######################
for letter in {{a..z},{A..Z}}; do   echo $letter; done

######################
START=a; STOP=z; for letter in $(eval echo {$START..$STOP}); do echo $letter; done

######################
echo -e {{a..c},ch,{d..l},ll,{m,n},ñ,{o..z}}"\n" | nl

#####################
function T1() { 
 C=141;
 list=""; 
  while [[ $C -lt 173 ]]; do 
    printf \\$C; 
    list+=" \\$C"; 
    C=$((C+1)); 
   done; 
  echo; 
     echo $list; 
};
T1
