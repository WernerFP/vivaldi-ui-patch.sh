#!/bin/bash
#
# Author: WernerFP
# License: GPL
# Source: https://github.com/WernerFP/vivaldi-ui-patch.sh
#
# Script to patch the browser.html and copy custom.css and custom.js 
# in a selected Vivaldi installation. 
# The files custom.css and/or custom.js must be in the same directory
# where the script is executed. 
# The script offers to create a backup of browser.html.

ITSME=$( basename $( readlink -f $0) )

if [[ -z $PWD ]]; then
	echo  "Sorry, \$PWD is not set in $0."
	exit
elif [ $UID != 0 ]; then
	echo  "Please run '$ITSME' as root"
	exit
fi

V=$( dirname $( find /opt -name "vivaldi-bin" ) 2>/dev/null )
CC=$PWD/custom.css
CJ=$PWD/custom.js
DL="/resources/vivaldi"
DONE=" browser.html has already been patched"
N=1

if [[ ! -f $CC ]] && [[ ! -f $CJ ]]; then
	echo "► Neither 'custom.css' nor 'custom.js' was found in $PWD";
	exit
elif [[ -z $V ]]; then
	echo "► No Vivaldi installation was found.";
	exit
else
	echo "Vivaldi installations found to patch:"
fi

for i in $V; do
	echo $i": "$N; ((N++));
done

read -p "► Please enter a selection number (or any key to cancel): " OP;
if [[ -z $OP ]] || [[ $OP != ${OP//[^0-9]/} ]] || [[ $OP++ > $N ]]; then
	echo "The script '$ITSME' was canceled, goodbye."
	exit
else 
	VD=$( echo $V | cut -d\  -f$OP 2>/dev/null ); OP=""
fi

read -p "► Should we backup browser.html first? [y/n]: " OP;
if  [[ -z $OP ]] || [[ $OP == [yYjJ] ]]; then
	BU="$PWD/browser.html-$( date +"%Y%m%d_%H%M" ).bak"
	cp "$VD$DL/browser.html" "$BU"
	chown -c $USER "$BU" 2>&1> /dev/null; chmod -f 644 "$BU"; chgrp -f users "$BU"
fi

QCC=$(grep "style/custom.css" "$VD$DL/browser.html" )
QCJ=$(grep "custom.js" "$VD$DL/browser.html" )
if [[ -z $QCC ]]; then
	sed -i 's/  <\/head>/    <link rel=\"stylesheet\" href=\"style\/custom.css\" \/>\n&/'\
	"$VD$DL/browser.html"
	DONE=" browser.html is patched"
fi
if [[ -z $QCJ ]]; then
	sed -i 's/  <\/body>/    <script src=\"custom.js\"><\/script>\n&/'\
	"$VD$DL/browser.html"
	DONE=" browser.html is patched"
fi

if [[ -f $CC ]]; then
	cp -f "$PWD/custom.css" "$VD$DL/style/custom.css" 2>/dev/null
	DONE=$(echo -e "$DONE\n custom.css is updated")
fi
if [[ -f $CJ ]]; then
	cp -f "$PWD/custom.js" "$VD$DL/custom.js" 2>/dev/null
	DONE=$(echo -e "$DONE\n custom.js is updated")
fi
echo -e "-----------------------------------------------------------\nCompleted for $VD:\n$DONE"
