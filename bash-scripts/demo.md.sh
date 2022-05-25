How to Install and Use Figlet and Toilet Tools in Linux
To use FIGlet and TOIlet tools together, you first need to install them on your Linux system using default package manager as shown.

$ sudo apt install figlet toilet    [On Debian/Ubuntu]
$ sudo yum install figlet toilet    [On CentOS/RHEL]
$ sudo dnf install figlet toilet    [On Fedora 22+]
Once installed, the basic way of using figlet is by providing as an argument, the text that you want to transform as a banner or large text, as shown.

$ figlet TecMint.com

 _____         __  __ _       _                        
|_   _|__  ___|  \/  (_)_ __ | |_   ___ ___  _ __ ___  
  | |/ _ \/ __| |\/| | | '_ \| __| / __/ _ \| '_ ` _ \ 
  | |  __/ (__| |  | | | | | | |_ | (_| (_) | | | | | |
  |_|\___|\___|_|  |_|_|_| |_|\__(_)___\___/|_| |_| |_|
Set Output Justification
If you want the output to be created at the center, use the -c flag as shown.

$ figlet -c TecMint.com

             _____         __  __ _       _                        
            |_   _|__  ___|  \/  (_)_ __ | |_   ___ ___  _ __ ___  
              | |/ _ \/ __| |\/| | | '_ \| __| / __/ _ \| '_ ` _ \ 
              | |  __/ (__| |  | | | | | | |_ | (_| (_) | | | | | |
              |_|\___|\___|_|  |_|_|_| |_|\__(_)___\___/|_| |_| |_|
In addition, also use -l to set the output to the left or -r to print it to the right.

Define Output Width
You can also control the output width with the -w switch, the default width is 80 columns.

$ figlet -w 100 I Love TecMint.com

 ___   _                     _____         __  __ _       _                        
|_ _| | |    _____   _____  |_   _|__  ___|  \/  (_)_ __ | |_   ___ ___  _ __ ___  
 | |  | |   / _ \ \ / / _ \   | |/ _ \/ __| |\/| | | '_ \| __| / __/ _ \| '_ ` _ \ 
 | |  | |__| (_) \ V /  __/   | |  __/ (__| |  | | | | | | |_ | (_| (_) | | | | | |
|___| |_____\___/ \_/ \___|   |_|\___|\___|_|  |_|_|_| |_|\__(_)___\___/|_| |_| |_|
If you have a wider terminal, you can use the full width of your terminal with the -t switch.

$ figlet -t TecMint.com
Add Space Between Output Characters
For a more clear output, you can use the -k flag to add a little space between the printed characters: check out the different between the above and below output as shown.

$ figlet -t -k I Love TecMint.com

 ___   _                        _____            __  __  _         _                            
|_ _| | |     ___ __   __ ___  |_   _|___   ___ |  \/  |(_) _ __  | |_     ___  ___   _ __ ___  
 | |  | |    / _ \\ \ / // _ \   | | / _ \ / __|| |\/| || || '_ \ | __|   / __|/ _ \ | '_ ` _ \ 
 | |  | |___| (_) |\ V /|  __/   | ||  __/| (__ | |  | || || | | || |_  _| (__| (_) || | | | | |
|___| |_____|\___/  \_/  \___|   |_| \___| \___||_|  |_||_||_| |_| \__|(_)\___|\___/ |_| |_| |_|
Read Input From a File
Rather than type your text on the command-line, you can read text from a file, using the -p option as shown.

$ echo "I wish I could chmod 644 my Girlfriend" >girlfriend.txt
$ figlet -kp < girlfriend.txt

 ___             _       _       ___                      _      _ 
|_ _| __      __(_) ___ | |__   |_ _|   ___  ___   _   _ | |  __| |
 | |  \ \ /\ / /| |/ __|| '_ \   | |   / __|/ _ \ | | | || | / _` |
 | |   \ V  V / | |\__ \| | | |  | |  | (__| (_) || |_| || || (_| |
|___|   \_/\_/  |_||___/|_| |_| |___|  \___|\___/  \__,_||_| \__,_|
                                                                   
       _                            _    __    _  _    _  _   
  ___ | |__   _ __ ___    ___    __| |  / /_  | || |  | || |  
 / __|| '_ \ | '_ ` _ \  / _ \  / _` | | '_ \ | || |_ | || |_ 
| (__ | | | || | | | | || (_) || (_| | | (_) ||__   _||__   _|
 \___||_| |_||_| |_| |_| \___/  \__,_|  \___/    |_|     |_|  
                                                              
                     ____  _        _   __        _                   _  
 _ __ ___   _   _   / ___|(_) _ __ | | / _| _ __ (_)  ___  _ __    __| | 
| '_ ` _ \ | | | | | |  _ | || '__|| || |_ | '__|| | / _ \| '_ \  / _` | 
| | | | | || |_| | | |_| || || |   | ||  _|| |   | ||  __/| | | || (_| | 
|_| |_| |_| \__, |  \____||_||_|   |_||_|  |_|   |_| \___||_| |_| \__,_|
Change Output Font
You can specify another font, using the -f flag, font is a .flf or .tlf file stored in /usr/share/figlet. You can check out available fonts like so.

$ ls /usr/share/figlet/

646-ca2.flc  646-es.flc   646-kr.flc   646-yu.flc  8859-9.flc	   
646-ca.flc   646-fr.flc   646-no2.flc  8859-2.flc  ascii12.tlf	   
646-cn.flc   646-gb.flc   646-no.flc   8859-3.flc  ascii9.tlf	  
646-cu.flc   646-hu.flc   646-pt2.flc  8859-4.flc  banner.flf	   
646-de.flc   646-irv.flc  646-pt.flc   8859-5.flc  bigascii12.tlf  
646-dk.flc   646-it.flc   646-se2.flc  8859-7.flc  bigascii9.tlf  
646-es2.flc  646-jp.flc   646-se.flc   8859-8.flc  big.flf	   
Then use a particular font, for example, I use font slant.tlf as shown.

$ figlet -f slant "Sudo I Love You"

   _____           __         ____   __                       __  __           
  / ___/__  ______/ /___     /  _/  / /   ____ _   _____      \ \/ /___  __  __
  \__ \/ / / / __  / __ \    / /   / /   / __ \ | / / _ \      \  / __ \/ / / /
 ___/ / /_/ / /_/ / /_/ /  _/ /   / /___/ /_/ / |/ /  __/      / / /_/ / /_/ / 
/____/\__,_/\__,_/\____/  /___/  /_____/\____/|___/\___/      /_/\____/\__,_/
Use TOIlet to Create Colored ASCII Text Banners
The toilet command is also used to transform text to large ASCII characters. The simplest way of running it is as follows.

$ toilet TecMint.com

mmmmmmm               m    m   "             m                               
   #     mmm    mmm   ##  ## mmm    m mm   mm#mm          mmm    mmm   mmmmm 
   #    #"  #  #"  "  # ## #   #    #"  #    #           #"  "  #" "#  # # # 
   #    #""""  #      # "" #   #    #   #    #           #      #   #  # # # 
   #    "#mm"  "#mm"  #    # mm#mm  #   #    "mm    #    "#mm"  "#m#"  # # #  
To change to a particular font, use the -f option, it also reads fonts from the same source as figlet.

$ toilet -kf script TecMint.com

 ______       ,__ __                                       
(_) |        /|  |  |  o                                   
    | _   __  |  |  |      _  _  _|_   __   __   _  _  _   
  _ ||/  /    |  |  |  |  / |/ |  |   /    /  \_/ |/ |/ |  
 (_/ |__/\___/|  |  |_/|_/  |  |_/|_/o\___/\__/   |  |  |_/
A number of the options for figlet that we have looked at above also apply to toilet. For more information, refer to their man pages.

$ man figlet
$ man toilet
