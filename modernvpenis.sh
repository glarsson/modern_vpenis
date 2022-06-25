#/bin/bash
# terrible version of Meyers of epenis.sh script, trying to get it updated for modern hardware. Help needed :)
# written by gerry.larsson@gmail.com
# Version 0.01 (25/6/2022)

# colors
BGreen='\033[1;32m' # Green
NC='\033[0m'    # No Color

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

echo average core clock speed: $averageCPUMHz


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

#ramUsed  = free -h | awk 'FNR == 2 {print $3}'
#ramFree  = free -h | awk 'FNR == 2 {print $4}'
#ramSwap  = free -h | awk 'FNR == 3 {print $2}'

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


# GPU details
