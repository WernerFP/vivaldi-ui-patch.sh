#!/bin/bash
#
# Author: WernerFP
# License: GPL3
# Source: https://github.com/WernerFP/vivaldi-ui-patch.sh
#
# Script to patch the browser.html and copy custom.css and custom.js in a selected Vivaldi installation.
#
# Your files custom.css and/or custom.js must be in the same directory where the script is executed.
# The script offers to backup the original browser.html.

# Filename of this script
itsme=$( basename $( readlink -f $0) )

# check if environment variable $PWD and root privileges are present
if [[ -z $PWD ]]; then
	echo  "Sorry, \$PWD is not set in $0."
	exit
elif [ $UID != 0 ]; then
	echo  "Please run '$itsme' as root"
	exit
fi

# Declaring variables
vivaldi=$( dirname $( find /opt -name "vivaldi-bin" ) 2>/dev/null )
css=$PWD/custom.css
js=$PWD/custom.js
href="href=\"style/custom.css\""
scr="src=\"custom.js\""
common_path="/resources/vivaldi"
done=" browser.html has already been patched"
n=1

# Are the necessary files available?
if [[ ! -f $css ]] && [[ ! -f $js ]]; then
	echo "► Neither 'custom.css' nor 'custom.js' was found in $PWD"
elif [[ -z $vivaldi ]]; then
	echo "► No Vivaldi installation was found."
else
	echo "Vivaldi installation(s) found to patch:"
fi

# Number existing Vivaldi installations
for i in $vivaldi; do
	echo "  $(( n++ ))  $i"
	count=$(echo "$(( n++ ))")
done

# If there are multiple installations of Vivaldi you will be asked which version to patch
if [[ $count > 2 ]]; then
	read -p "► Please enter a selection number (or any key to cancel): " selected
	if [[ -z $selected ]] || [[ $selected != ${selected//[^0-9]/} ]] || [[ $selected++ > $n ]]; then
		echo "The script '$itsme' was canceled, goodbye."
	else
		selected_vivaldi=$( echo $vivaldi | cut -d\  -f$selected 2>/dev/null ); selected=""
	fi
else
	selected_vivaldi=$( echo $vivaldi | cut -d\  -f1 2>/dev/null ); selected=""
fi

# If you want to backup the file browser.html,
# the existing file will be saved in the current script directory
entry_href=$( grep "$href" "$selected_vivaldi$common_path/browser.html" 2>/dev/null)
entry_scr=$( grep "$scr" "$selected_vivaldi$common_path/browser.html" 2>/dev/null)
if [[ -z $entry_href ]] || [[ -z $entry_scr ]]; then
	read -p "► Do you want to backup browser.html first? [y/n]: " selected
	if  [[ -z $selected ]] || [[ $selected == [yYjJ] ]]; then
		backup="$PWD/browser.html-$( date +"%Y%m%d_%H%M" ).bak"
		cp "$selected_vivaldi$common_path/browser.html" "$backup"
		chown -c $USER "$backup" 2>&1> /dev/null; chmod -f 644 "$backup"; chgrp -f users "$backup"
	fi
fi

# Execute patch
if [[ -z $entry_href ]]; then
	sed -i 's/^[\t\ \n]*<\/head>/    <link rel=\"stylesheet\" href=\"style\/custom.css\" \/>\n&/'\
	"$selected_vivaldi$common_path/browser.html"
	done=" browser.html is patched"
fi
if [[ -z $entry_scr ]]; then
	sed -i 's/^[\t\ \n]*<\/body>/    <script src=\"custom.js\"><\/script>\n&/'\
	"$selected_vivaldi$common_path/browser.html"
	done=" browser.html is patched"
fi

# Check that the operation was successful
entry_href=$( grep "$href" "$selected_vivaldi$common_path/browser.html" )
entry_scr=$( grep "$scr" "$selected_vivaldi$common_path/browser.html" )
if [[ -z $entry_href ]] || [[ -z $entry_scr ]]; then
	echo -e "► Sorry, the patch could not be executed (missing permissions or unexpected HTML formatting?):\n  $selected_vivaldi$common_path/browser.html"
	exit
fi

# Notification of which changes have been made
if [[ -f $css ]]; then
	cp -f "$PWD/custom.css" "$selected_vivaldi$common_path/style/custom.css" 2>/dev/null
	done=$( echo -e "$done \n custom.css is updated" )
fi
if [[ -f $js ]]; then
	cp -f "$PWD/custom.js" "$selected_vivaldi$common_path/custom.js" 2>/dev/null
	done=$( echo -e "$done \n custom.js is updated" )
fi
if [[ -n $backup ]]; then
	backup=$( echo "$backup" | sed -e 's/.*\///' ) 2>/dev/null
	done=$( echo -e "$done \n Backup: $backup" )
fi
echo -e "-----------------------------------------------------------\n$selected_vivaldi:\n$done "
