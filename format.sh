#!/usr/bin/env bash

initANSI() {

#make special characters useable
esc="$(echo -en '\e')"

#foreground colors
defaultf="${esc}[39m"
blackf="${esc}[30m"
redf="${esc}[31m"
greenf="${esc}[32m"
yellowf="${esc}[33m"
bluef="${esc}[34m"
magentaf="${esc}[35m"
cyanf="${esc}[36m"
lightgrayf="${esc}[37m"
darkgrayf="${esc}[90"
lightredf="${esc}[91"
lightgreenf="${esc}[92"
lightyellowf="${esc}[93"
lightbluef="${esc}[94"
lightmagentaf="${esc}[95"
lightcyanf="${esc}[96"
whitef="${esc}[97"

#background colors
defaultb="${esc}[49m"
blackb="${esc}[40m"
redb="${esc}[41m"
greenb="${esc}[42m"
yellowb="${esc}[43m"
blueb="${esc}[44m"
magentab="${esc}[45m"
cyanb="${esc}[46m"
lightgrayb="${esc}[47"
darkgrayb="${esc}[100"
lightredb="${esc}[101"
lightgreenb="${esc}[102"
lightyellowb="${esc}[103"
lightblueb="${esc}[104"
lightmagentab="${esc}[105"
lightcyanb="${esc}[106"
whiteb="${esc}[107m"

#formatting
boldon="${esc}[1m"
boldoff="${esc}[21m"

dimon="${esc}[2m"
dimoff="${esc}[22"

italicson="${esc}[3m"
italicsoff="${esc}[23m"

ulon="${esc}[4m"
uloff="${esc}[24m"

blinkon="${esc}[5m"
blinkoff="${esc}[25m"

invon="${esc}[7m"
invoff="${esc}[27m"

hiddenon="${esc}[8m"
hiddenoff="${esc}[28m"

reset="${esc}[0m"
}
