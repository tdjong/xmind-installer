#!/bin/bash
#xmind8Install.sh
# based on: https://askubuntu.com/questions/869848/how-to-install-run-xmind-v-8-in-ubuntu-16-04
# start XMind with JRE 8

# Show commands
set -x

# exit of fail
#set -e

usage=$(cat << EOM

USAGE:
  -This script works with "XMind_amd64" only (not i386, 32-bit)! Tested with Ubuntu 16.04.2
  -Best to just copy this script file into the same directory as the downloaded xmind-8-update1-linux.zip
    file (or whatever you called it).
  -This script will create a final direcoty 'xmind8' to install into but you need to pick where you want that 'xmind8' directory
    if you don't want the default of '$HOME/.local/bin'.


xmind [/path/to/downloaded_xmind_file-name.zip] [/path/to/where/you/want/to/install (DEFAULT: $HOME/.local/bin)]

EXAMPLE:
  sudo bash $0 xmind-8-update1-linux.zip
  sudo bash $0 Downloads/xmind-8.zip
  sudo bash $0 xmind-8-update1-linux.zip $HOME/apps
  sudo bash $0 xmind-8-update1-linux.zip /opt
\n
EOM
)

# input validation
[[ ($# < 1) || ("$1" == "--help") || ("$1" == "-h") || ("$1" == "-H") ]] && {
  echo -e "${usage}" #Displays help/usage info
  exit 1
}

function fCHECKSUDO { # checks to make sure the script is being run as root
    if [ "$(id -u)" != '0' ]
    then
            echo -e "\n   $(tput setaf 1)This script has to be run as root! ($ sudo bash ...)$(tput setaf 9)\n"
            exit 1
    fi
}
fCHECKSUDO


type unzip >/dev/null 2>&1 || { apt-get install -y unzip; } #This installs the package 'unzip' if it is not already installed.
fileZip="${1}"
installDirRoot="${2:-"$HOME/.local/bin"}"
 #echo '$fileZip='$fileZip " " '$installDirRoot='$installDirRoot

function _installXMind8 {
    ##user preferences seemed to be saved into: xmind/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/
    ##http://www.xmind.net/m/PuDC a beta DEB package
    ##To find the icon images: $ find ~/bin/xmind8 -iname xmind.*.png
    #[[ ! -f "$fileZip" ]] && wget -t 4 -O xmind8.zip "https://www.xmind.net/xmind/downloads/xmind-8-update1-linux.zip" 
    ##xmind.net is blocking non-browser downloads
    [[ ! -d "$installDirRoot" ]] && mkdir -pv "$installDirRoot"
    unzip "$fileZip" -d "$installDirRoot/xmind8"
    "$installDirRoot/xmind8/setup.sh"

## patch ini file for absolute paths
## else XMind will only start with the correct working directory
#  xmindini="$installDirRoot/xmind8/XMind_amd64/XMind.ini"
#   cp $xmindini ${xmindini}.BAK
#   cp ${xmindini}.BAK ${xmindini}
#   oneDot="${installDirRoot}/xmind8/XMind_amd64/"
#   twoDot="${installDirRoot}/xmind8/"
## replace path seperator with escaped version
#   sed -i "s/^../${twoDot//\///}/g" $xmindini
#   sed -i "s/^./${oneDot//\///}/g" $xmindini
#cat $xmindini

cat <<EOP > $installDirRoot/xmind
#!/bin/sh
# start XMind8 with JRE8
cd $installDirRoot/xmind8/XMind_amd64 
./XMind -vm /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java $*
EOP
chmod 755 $installDirRoot/xmind

desktopItem=$HOME/.local/share/applications/xmind.desktop
cat <<EOF > $desktopItem
   [Desktop Entry]
   Type=Application
   Name=XMind
   Comment=Create and share mind maps.
   Exec=$installDirRoot/xmind %f
   Categories=Office;
   NoDisplay=false
   MimeType=application/zip
   Terminal=false
   Icon=$installDirRoot/xmind8/XMind_amd64/configuration/org.eclipse.osgi/983/0/.cp/icons/xmind.64.png
EOF
ls -l $desktopItem

chown -R ${HOME//\/home\//}:${HOME//\/home\//} $installDirRoot
chown -R ${HOME//\/home\//}:${HOME//\/home\//} $HOME/.local/share/applications/xmind.desktop
}

_installXMind8
