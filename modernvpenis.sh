#/bin/bash
# terrible version of Meyers of epenis.sh script, trying to get it updated for modern hardware. Help needed :)
# written by gerry.larsson@gmail.com
# Version 0.04 (26/6/2022)

# disclamer: this script requires the following:
# root access
# packages: speedtest-cli

# DEFINE HERE PLEASE!!! IF YOU HAVE A LOW INTERNET CONNECTIONN THIS TAKES AGES
# RUN INTERNET SPEED TEST OR NOT: TRUE or FALSE

ENABLE_INTERNET_SPEED_TEST=$true

# install required packages
sudo apt -qq update && apt -qq install -y speedtest-cli

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

# get the average clock speed across the whole CPU
averageCPUMHz=$(expr $sumCPUMHz / $cpuCoreCount)

# simple cpu details
echo "CPU INFO (simple)"

# print the details
echo -e "${NC}CPU model name:                                   ${BGreen} $cpuModelName"
echo -e "${NC}CPU logical core count:                           ${BGreen} $cpuCoreCount"
echo -e "${NC}CPU average clock speed across all cores:         ${BGreen} $averageCPUMHz"
echo -e "\033[0m"

# simple memory details
echo -e "${NC}MEMORY INFO (simple)"
echo -e "\033[0m"

# populate the memory array
ramTotal=($(sudo free -h | awk 'FNR == 2 {print $2}' ))
ramUsed=($(sudo free -h | awk 'FNR == 2 {print $3}' ))
ramFree=($(sudo free -h | awk 'FNR == 2 {print $4}' ))
ramSwap=($(sudo free -h | awk 'FNR == 3 {print $2}' ))

# print results
echo -e "${NC}Total amount of RAM:                              ${BGreen} $ramTotal"
echo -e "${NC}Total amount of used RAM:                         ${BGreen} $ramUsed"
echo -e "${NC}Total amount of free RAM:                         ${BGreen} $ramFree"
echo -e "${NC}Total amount of swap (if existing)                ${BGreen} $ramSwap"
echo -e ""
echo -e "\033[0m"

# detailed memory details
echo -e "${NC}MEMORY INFO (more detailed)"
echo -e "\033[0m"

# gather detailed memory details from dmidecode *this requires sudo/root access
ramConfiguredMemorySpeed=($(sudo dmidecode --type 17 | grep 'Configured Memory Speed' | sed '/None/d' | sed '/No Module Installed/d' | sed '/Unknown/d' | sed '/Module Manufacturer ID/d' | sed '/Volatile/d' | sed -n '1{p;q}' | awk '{print $4}' ))
ramTotalAmountDIMMS=($(sudo dmidecode --type 17 | grep 'DDR' | sed '/None/d' | sed '/No Module Installed/d' | sed '/Unknown/d' | sed '/Module Manufacturer ID/d' | sed '/Volatile/d' | wc -l ))
ramPartNumber=($(sudo dmidecode --type 17 | grep 'Part Number' | sed '/None/d' | sed '/No Module Installed/d' | sed '/Unknown/d' | sed '/Module Manufacturer ID/d' | sed '/Volatile/d' | sed -n '1{p;q}' | awk '{print $3}' ))
ramConfiguredVoltage=($(sudo dmidecode --type 17 | grep 'Configured Voltage' | sed '/None/d' | sed '/No Module Installed/d' | sed '/Unknown/d' | sed '/Module Manufacturer ID/d' | sed '/Volatile/d' | sed -n '1{p;q}' | awk '{print $3}' ))

# print the results
echo -e "${NC}Total amount of RAM sticks:                       ${BGreen} $ramTotalAmountDIMMS"
echo -e "${NC}Configured RAM speed:                             ${BGreen} $ramConfiguredMemorySpeed"
echo -e "${NC}RAM Part Number (where available):                ${BGreen} $ramPartNumber"
echo -e "${NC}Configured Voltage:                               ${BGreen} $ramConfiguredVoltage"
echo -e "\033[0m"

# simple disk details
echo -e "${NC}DISK INFO (simple)"

# gather the simple disk details from df
rootSize=$(df -h | awk 'FNR == 2 {print $2}')
rootUsed=$(df -h | awk 'FNR == 2 {print $3}')
rootFree=$(df -h | awk 'FNR == 2 {print $4}')
rootUsedProcent=$(df -h | awk 'FNR == 2 {print $5}')

# print the results
echo -e "${NC}Root mount size:                                  ${BGreen} $rootSize"
echo -e "${NC}Root mount used:                                  ${BGreen} $rootUsed"
echo -e "${NC}Root mount free                                   ${BGreen} $rootFree"
echo -e "${NC}Root volume used in procent:                      ${BGreen} $rootUsedProcent"
echo -e "\033[0m"

# if user may have his /home mounted on another disk or something, display those details
echo -e "${NC}HOME FOLDER DISK INFO (simple, if exists)"

# run check to see if /home is mounted separately from /
if (check_mountpoint /home == true)
  then
    homeSize=$(df -h | awk 'FNR == 4 {print $2}')
    homeUsed=$(df -h | awk 'FNR == 4 {print $3}')
    homeFree=$(df -h | awk 'FNR == 4 {print $4}')
    homeUsedProcent=$(df -h | awk 'FNR == 4 {print $5}')
    echo -e "${NC}Home mount size:                              ${BGreen} $homeSize"
    echo -e "${NC}Home mount used:                              ${BGreen} $homeUsed"
    echo -e "${NC}Home mount free:                              ${BGreen} $homeFree"
    echo -e "${NC}Home volume used in procent:                  ${BGreen} $homeUsedProcent"
    echo -e "\033[0m"
else echo -e "${NC}No home folder specifically mounted"
fi
echo -e "\033[0m"

# Internet speed details
# check if defined
if $ENABLE_INTERNET_SPEED_TEST == true
  then
echo -e "${NC}INTERNET DETAILS (if INTERNET_TESTS specifically defined, speed needs separate package)"

# run speedtest (external package) to gather internet speeds based on its defaults
# but save float result and metric value separately if needed if client has GB's or god forbid Kb's)
internetDownloadSpeedValue=$(speedtest | grep Download | awk '{print $2}')
internetDownloadSpeedMetric=$(speedtest | grep Download | awk '{print $3}')
internetUploadSpeedValue=$(speedtest | grep Upload | awk '{print $2}')
internetUploadSpeedMetric=$(speedtest | grep Upload | awk '{print $3}')

# print the results
echo -e "${NC}Internet download speed:                          ${BGreen} $internetDownloadSpeedValue $internetDownloadSpeedMetric"
echo -e "${NC}Internet upload speed:                            ${BGreen} $internetUploadSpeedValue $internetUploadSpeedMetric"
echo -e "\033[0m"

# Network latency details / should change this to ping local resources and skip internet if INTERNET_TESTS not defined
echo -e "${NC}NETWORK LATENCY DETAILS (if INTERNET_TESTS specifically defined, no package neededed)"

  else
    networkGateway=$(ip r | grep default | awk {'print $3'})
    echo -e "${NC}INTERNET SPEED TEST (disabled)"
    echo -e "\033[0m"
    echo -e "${NC}INTERNET SPEED TEST (disabled)"
    echo -e "${NC}Average ping result to your local LAN GW:     ${BGreen} $pingNetworkGateway"
    echo -e "\033[0m"

# ping hosts and average out their 4 replies
pingNetworkGateway=$(ping -c 4 1.1.1.1 | tail -1 | awk -F '/' '{print $5}')
pingGoogleCom=$(ping -c 4 www.google.com | tail -1 | awk -F '/' '{print $5}')
pingOneOneOneOne=$(ping -c 4 1.1.1.1 | tail -1 | awk -F '/' '{print $5}')
pingEightEightEightEIght=$(ping -c 4 1.1.1.1 | tail -1 | awk -F '/' '{print $5}')

# display the results

else
  echo -e "${NC}Average ping result to www.google.com:            ${BGreen} $pingGoogleCom"
  echo -e "${NC}Average ping result to DNS server 1.1.1.1:        ${BGreen} $pingOneOneOneOne"
  echo -e "${NC}Average ping result to DNS server 8.8.8.8:        ${BGreen} $pingEightEightEightEIght"
  echo -e "\033[0m"
fi