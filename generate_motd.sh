#!/bin/bash
# Generates MOTD output for the motd file

# Colour CONSTANTS
W="\033[0m"
B="\033[01;36m"
R="\033[01;31m"
G="\033[01;32m"
N="\033[0m"

# Define output file
motd="/etc/motd"

# Collect information
HOSTNAME=`uname -n`
KERNEL=`uname -r`
CPU=`lscpu | grep 'Model name:' | awk '{for (i=3; i<=NF; i++) printf("%s ",$i)} END {print""}'`
CPU_VENDOR=`lscpu | grep "Vendor ID:" | awk '{print $3}'`
CORES=`lscpu | grep 'Core(s) per socket:' | awk '{print $4}'`
ARCH=`uname -m`
MEMORY1=`free -t -m | grep "Mem" | awk '{print $6" MB";}'`
MEMORY2=`free -t -m | grep "Mem" | awk '{print $2" MB";}'`
MEMPERCENT=`free | awk '/Mem/{printf("%.2f% (Used) "), $3/$2*100}'`
BOOT_TYPE=""
CPU_TEMP="N/A"
MAX_OK_TEMP="85.0'C"
SYSTEM_STATUS=`systemctl status | grep State | head -n1 |awk {'print $2'}`
SERVICES_RUNNING=`systemctl | grep running | wc -l`
FAILED_SERVICES=`systemctl status | grep Failed | head -n1 | awk {'print $2'}`
NET_INTERFACE=`ip -o link show | grep "state UP" | sed "s|:||g" | awk {'print $2'}`
IP_ADDRESS=`ip -4 -o address show $NET_INTERFACE | grep inet | sed "s|:||g" | awk {'print $4'}`


if [ "$CPU_VENDOR" == "ARM" ]; then
  BOOT_TYPE="PI"
elif [ -d /sys/firmware/efi ]; then
  BOOT_TYPE="UEFI"
else
  BOOT_TYPE="BIOS"
fi

#System uptime
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))


#System load
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`

#Clear screen before motd
cat /dev/null > $motd

if [ "$CPU_VENDOR" == "ARM" ]; then
CPU_TEMP=`/opt/vc/bin/vcgencmd measure_temp | sed "s/=/ /" | awk {'print $2'}`

  echo -e "
       $B. $W 
      $B/#\ $W                     _     $B _ _                   $W _ 
     $B/###\ $W      __ _ _ __ ___| |__  $B| (_)_ __  _   ___  __ $W| |  _   ___ __  __ 
    $B/#####\ $W    / _' | '__/ __| '_ \ $B| | | '_ \| | | \ \/ / $W| | / \ | _ \  \/  |
   $B/##.-.##\ $W  | (_| | | | (__| | | |$B| | | | | | |_| |>  <  $W| |/ ^ \|   / |\/| |
  $B/##(   )##\ $W  \__,_|_|  \___|_| |_|$B|_|_|_| |_|\__._/_/\_\ $W| /_/ \_\_|_\_|  |_|
 $B/#.--   --.#\ $W                                             $W|_|   $G>$R Raspberry Pi$W
$B/'           '\ $W> $G$HOSTNAME" > $motd
else
  echo -e "
       $B. $W
      $B/#\ $W                     _     $B _ _
     $B/###\ $W      __ _ _ __ ___| |__  $B| (_)_ __  _   ___  __ 
    $B/#####\ $W    / _' | '__/ __| '_ \ $B| | | '_ \| | | \ \/ /
   $B/##.-.##\ $W  | (_| | | | (__| | | |$B| | | | | | |_| |>  <  
  $B/##(   )##\ $W  \__,_|_|  \___|_| |_|$B|_|_|_| |_|\__._/_/\_\\
 $B/#.--   --.#\ $W  
$B/'           '\ $W> $G$HOSTNAME " > $motd
fi

echo -e "$G--------------------------------------------------------------------" >> $motd
echo -e "$B        KERNEL $G:$W $KERNEL $ARCH                                 " >> $motd
echo -e "$B    CPU VENDOR $G:$W $CPU_VENDOR                                   " >> $motd
echo -e "$B           CPU $G:$W $CPU                                          " >> $motd
echo -e "$B         CORES $G:$W $CORES                                        " >> $motd
echo -e "$B     BOOT TYPE $G:$W $BOOT_TYPE                                    " >> $motd
echo -e "$B    IP ADDRESS $G:$W $IP_ADDRESS ($NET_INTERFACE)               " >> $motd
echo -e "$N" >> $motd
echo -e "$B        MEMORY $G:$W $MEMORY1 / $MEMORY2 - $MEMPERCENT             " >> $motd
if [ "$CPU_VENDOR" == "ARM" ]; then
echo -e "$B      CPU TEMP $G:$W $CPU_TEMP (max allowed: $MAX_OK_TEMP)         " >> $motd
fi
echo -e "$B SYSTEM STATUS $G:$W $SYSTEM_STATUS         " >> $motd
echo -e "$B      SERVICES $G:$W $SERVICES_RUNNING running / $FAILED_SERVICES failed " >> $motd
echo -e "$B        UPTIME $G:$W $upDays days $upHours hours $upMins minutes $upSecs seconds " >> $motd
echo -e "$B      LOAD AVG $G:$W $LOAD1 | $LOAD5 | $LOAD15              " >> $motd
echo -e "$B  USERS ACTIVE $G:$W `users | wc -w` users logged in             " >> $motd
echo -e "$G--------------------------------------------------------------------" >> $motd
echo -e "$N" >> $motd
