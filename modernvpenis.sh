#/bin/bash
# terrible version of Meyers of epenis.sh script, trying to get it updated for modern hardware. Help needed :)
# written by gerry.larsson@gmail.com
# Version 0.01 (25/6/2022)

# colors
BGreen='\033[1;32m' # Green
NC='\033[0m'    # No Color

# commands
check_mountpoint(){
if  mountpoint -q $1
  then
                #printf "%s\n" "$1 is mounted"
                return 0
            else
                #printf "%s\n" "$1 is not mounted"
                return 1
fi
}

check_mountpoint /media/sd 
if [ $? -gt 0 ]
  then
    #printf "%s\n" "aborting"
    exit 0
fi


# get processor model name
cpuModelName=$(cat /proc/cpuinfo | grep "model name" | sed -n '1{p;q}')

# get processor logical core count
cpuCountArray=($(cat /proc/cpuinfo | grep "model name" | wc -l ))
cpuCoreCount="$((${cpuCountArray[@]/%/+}0))"
echo "Total cores: $cpuCoreCount"

# get individal core speed
cpuCountMHzArray=($(cat /proc/cpuinfo | grep "cpu MHz" | sed 's/\..*$//' | awk '{ print $4 }' ))

# sum up all the individual cores clock speed
sumCPUMHz="$(( ${cpuCountMHzArray[@]/%/ +} 0))"

# use bc to get the average clock speed across the whole CPU
averageCPUMHz=$(expr $sumCPUMHz / $cpuCoreCount)

# cpu details
echo "CPU INFO (simple)"

echo -e "${NC}CPU model name:                                   ${BGreen} $cpuModelName"
echo -e "${NC}CPU logical core count:                           ${BGreen} $cpuCoreCount"
echo -e "${NC}CPU average clock speed across all cores:         ${BGreen} $averageCPUMHz"
echo -e "\033[0m"

### simple memory details

echo -e "${NC}MEMORY INFO (simple)"
echo -e "\033[0m"

ramTotal=($(sudo free -h | awk 'FNR == 2 {print $2}' ))
ramUsed=($(sudo free -h | awk 'FNR == 2 {print $3}' ))
ramFree=($(sudo free -h | awk 'FNR == 2 {print $4}' ))
ramSwap=($(sudo free -h | awk 'FNR == 3 {print $2}' ))

echo -e "${NC}Total amount of RAM:                              ${BGreen} $ramTotal"
echo -e "${NC}Total amount of used RAM:                         ${BGreen} $ramUsed"
echo -e "${NC}Total amount of free RAM:                         ${BGreen} $ramFree"
echo -e "${NC}Total amount of swap (if existing)                ${BGreen} $ramSwap"
echo -e ""
echo -e "\033[0m"

# detailed memory details

echo -e "${NC}MEMORY INFO (more detailed)"
echo -e "\033[0m"

ramConfiguredMemorySpeed=($(sudo dmidecode --type 17 | grep 'Configured Memory Speed' | sed '/None/d' | sed '/No Module Installed/d' | sed '/Unknown/d' | sed '/Module Manufacturer ID/d' | sed '/Volatile/d' | sed -n '1{p;q}' | awk '{print $4}' ))
ramTotalAmountDIMMS=($(sudo dmidecode --type 17 | grep 'DDR' | sed '/None/d' | sed '/No Module Installed/d' | sed '/Unknown/d' | sed '/Module Manufacturer ID/d' | sed '/Volatile/d' | wc -l ))
ramPartNumber=($(sudo dmidecode --type 17 | grep 'Part Number' | sed '/None/d' | sed '/No Module Installed/d' | sed '/Unknown/d' | sed '/Module Manufacturer ID/d' | sed '/Volatile/d' | sed -n '1{p;q}' | awk '{print $3}' ))
ramConfiguredVoltage=($(sudo dmidecode --type 17 | grep 'Configured Voltage' | sed '/None/d' | sed '/No Module Installed/d' | sed '/Unknown/d' | sed '/Module Manufacturer ID/d' | sed '/Volatile/d' | sed -n '1{p;q}' | awk '{print $3}' ))

echo -e "${NC}Total amount of RAM sticks:                       ${BGreen} $ramTotalAmountDIMMS"
echo -e "${NC}Configured RAM speed:                             ${BGreen} $ramConfiguredMemorySpeed"
echo -e "${NC}RAM Part Number (where available):                ${BGreen} $ramPartNumber"
echo -e "${NC}Configured Voltage:                               ${BGreen} $ramConfiguredVoltage"
echo -e "\033[0m"

# simple disk details

echo -e "${NC}DISK INFO (simple)"

rootSize=$(df -h | awk 'FNR == 2 '{print $2}')
rootUsed=$(df -h | awk 'FNR == 2 '{print $3}')
rootFree=$(df -h | awk 'FNR == 2 '{print $4}')
rootUsedProcent=$(df -h | awk 'FNR == 2 '{print $5}')

echo -e "${NC}Root mount size:                                  ${BGreen} $rootSize"
echo -e "${NC}Root mount used:                                  ${BGreen} $rootUsed"
echo -e "${NC}Root mount free in GB:                            ${BGreen} $rootFree"
echo -e "${NC}Root volume used in procent:                      ${BGreen} $rootUsedProcent"
echo -e "\033[0m"

if (check_mountpoint /home == true)
  then
    homeSize=$(df -h | awk 'FNR == 3 '{print $2}')
    homeUsed=$(df -h | awk 'FNR == 3 '{print $3}')
    homeFree=$(df -h | awk 'FNR == 3 '{print $4}')
    homeUsedProcent=$(df -h | awk 'FNR == 3 '{print $5}')
    echo -e "${NC}Home mount size:                                 ${BGreen} $homeSize"
    echo -e "${NC}Home mount used:                                 ${BGreen} $homeUsed"
    echo -e "${NC}Home mount free in GB:                           ${BGreen} $homeFree"
    echo -e "${NC}Home volume used in procent:                     ${BGreen} $homeUsedProcent"
    echo -e "\033[0m"
fi
else echo -e "${NC}No home folder specially mounted"
fi

# GPU details
