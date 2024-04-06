#!/bin/bash

################################################################################################
# Brought to you by TheMojoMan <themojoman@gmx.net> (TheMagicMojoMan on xdaforums.com & Steam) #
################################################################################################

# exit on errors
set -e

install_box86 () {
	sudo dpkg --add-architecture armhf
	sudo wget https://itai-nelken.github.io/weekly-box86-debs/debian/box86.list -O /etc/apt/sources.list.d/box86.list
	wget -qO- https://itai-nelken.github.io/weekly-box86-debs/debian/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg
	sudo apt update && sudo apt install box86:armhf -y
}

install_box64 () {
	sudo wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
	wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
	sudo apt update && sudo apt install box64 -y
}

install_steam () {
	echo -e "\nInstalling: Steam ...\n"
	# install essential drivers
	sudo apt install -y libgdm1:armhf libudev1:armhf libgl1-mesa-dri:armhf libglapi-mesa:armhf libglu1-mesa:armhf libglx-mesa0:armhf mesa-va-drivers:armhf mesa-vdpau-drivers:armhf mesa-vulkan-drivers:armhf libsdl1.2debian:armhf libegl-mesa0:armhf
	sudo apt install -y libc6:armhf
	sudo apt install -y mesa-vulkan-drivers
	
	#
	# the following script is taken from https://github.com/ptitSeb/box86/blob/master/install_steam.sh
	# (slight modifications by me)
	#
	
	# create necessary directories
	mkdir -p ~/steam
	mkdir -p ~/steam/tmp
	cd ~/steam/tmp

	# download latest deb and unpack
	#wget https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb
	wget https://repo.steampowered.com/steam/archive/stable/steam_latest.deb -O steam.deb
	ar x steam.deb
	tar xf data.tar.xz

	# remove deb archives, not needed anymore
	rm ./*.tar.xz ./steam.deb

	# move deb contents to steam folder
	mv ./usr/* ../
	cd ../ && rm -rf ./tmp/

	# create run script
	echo "#!/bin/bash
	export STEAMOS=1
	export STEAM_RUNTIME=1
	export DBUS_FATAL_WARNINGS=0
	~/steam/bin/steam -no-browser +open steam://open/minigameslist $@" > steam

	# make script executable and move
	chmod +x steam
	sudo mv steam /usr/local/bin/

	# detect if we're running on 64 bit Debian (maybe this can be moved in another script then mentioned in documentation for the people that don't use steam but don't want a headache)
	MACHINE_TYPE=`uname -m`
	if [ ${MACHINE_TYPE} == 'aarch64' ] && [ -f '/etc/debian_version' ]; then
	 echo "Detected 64 bit ARM Debian. Installing 32 bit libraries"
	 sudo dpkg --add-architecture armhf # enable installation of armhf libraries
	 sudo apt update # update package lists with the newly added arch
	 # install the libraries that Steam requires
	 sudo apt install -y libc6:armhf libsdl2-2.0-0:armhf libsdl2-image-2.0-0:armhf libsdl2-mixer-2.0-0:armhf libsdl2-ttf-2.0-0:armhf libopenal1:armhf libpng16-16:armhf libfontconfig1:armhf libxcomposite1:armhf libbz2-1.0:armhf libxtst6:armhf libsm6:armhf libice6:armhf libgl1:armhf libxinerama1:armhf libxdamage1:armhf
	 # this one is not there all the time, so just try it...
	 sudo apt install -y libncurses6:armhf 

	 # install mesa for armhf if already installed
	 if dpkg-query -W libgl1-mesa-dri 2>/dev/null; then
	  echo "Detected mesa driver for 64 bit ARM. Installing complementary 32 bit one"
	  sudo apt install -y libgl1-mesa-dri:armhf
	 fi

	 echo "Don't forget to compile/install Box64!"
	fi
	#
	# end of script by ptitSeb
	#
	
	# move .desktop file to Desktop folder, modify Exec command & fix Icon
	mv ~/steam/share/applications/steam.desktop ~/Desktop/
	sed -i "s|Exec=/usr/bin/steam|Exec=steam|" ~/Desktop/steam.desktop
	sed -i "s|Icon=steam|Icon=$HOME/steam/share/pixmaps/steam.png|" ~/Desktop/steam.desktop
	
	# run steam: it will download additional files; please cancel at login page
	steam
	
	# after installation of Steam there are some system components missing (e.g. gdm3)
	# reinstalling ubuntu-desktop fixes this problem
	#sudo apt install -y ubuntu-desktop
	echo -e "\nInstalled: Steam ...\n\n"
}

install_wine_depedencies () {
	# box86 dependencies
	sudo apt install -y libasound2:armhf \
	libc6:armhf \
	libglib2.0-0:armhf \
	libgphoto2-6:armhf \
	libgphoto2-port12:armhf \
	libgstreamer-plugins-base1.0-0:armhf \
	libgstreamer1.0-0:armhf \
	libpcap0.8:armhf \
	libpcsclite1:armhf \
	libpulse0:armhf \
	libsane1:armhf \
	libudev1:armhf \
	libusb-1.0-0:armhf \
	libwayland-client0:armhf \
	libwayland-egl1:armhf \
	libx11-6:armhf \
	libxext6:armhf \
	libxkbcommon0:armhf \
	libxkbregistry0:armhf \
	ocl-icd-libopencl1:armhf \
	libasound2-plugins:armhf \
	libncurses6:armhf \
	debconf:armhf \
	libc6:armhf \
	libgl1:armhf \
#	libappindicator:armhf \
#	libxtst6:armhf \
#	libpipewire-0.3-0:armhf
	
	# box64 dependencies
	sudo apt install -y libasound2 \
	libc6 \
	libglib2.0-0 \
	libgphoto2-6 \
	libgphoto2-port12 \
	libgstreamer-plugins-base1.0-0 \
	libgstreamer1.0-0 \
	libpcap0.8 \
	libpcsclite1 \
	libpulse0 \
	libsane1 \
	libudev1 \
	libusb-1.0-0 \
	libwayland-client0 \
	libwayland-egl1 \
	libx11-6 \
	libxext6 \
	libxkbcommon0 \
	libxkbregistry0 \
	ocl-icd-libopencl1 \
	libasound2-plugins \
	libncurses6 \
	debconf \
	libgl1 \
	libunwind8 \
	libopencl-1.2-1 \
	#libappindicator -> conflicts with libappindicator:armhf
}

# The following functions are based on the work of 

install_wine () {
	# Download Wine binaries from Kron4ek’s Wine-Builds. This archive contains Wine and Wine64
	cd ~/Downloads
	wget https://github.com/Kron4ek/Wine-Builds/releases/download/${wine_version}/wine-${wine_version}-amd64.tar.xz
	wget https://github.com/Kron4ek/Wine-Builds/releases/download/${wine_version}/wine-${wine_version}-x86.tar.xz

	# Extract the archive.
	tar xvf wine-${wine_version}-amd64.tar.xz
	tar xvf wine-${wine_version}-x86.tar.xz
	rm wine-${wine_version}-amd64.tar.xz wine-${wine_version}-x86.tar.xz
	# !!! check if dirs already exist !!!
	mv wine-${wine_version}-amd64 ~/wine64
	mv wine-${wine_version}-x86 ~/wine
	cd ~
}

create_wine_bin_shortcuts () {
	echo '#!/bin/bash
export WINEPREFIX='$wine32_prefix'
box86 '"$HOME/wine/bin/wine "'"$@"' | sudo tee /usr/local/bin/wine  > /dev/null
	sudo chmod +x /usr/local/bin/wine
	echo '#!/bin/bash
export WINEPREFIX='$wine64_prefix'
box64 '"$HOME/wine64/bin/wine64 "'"$@"' | sudo tee /usr/local/bin/wine64  > /dev/null
	sudo chmod +x /usr/local/bin/wine64
}

create_wine_desktop_shortcuts () {
	# Create a shortcut of Wine’s file explorer on Desktop so you could start exe in it.
	cd ~/Desktop
	echo '[Desktop Entry]
	Name=Wine32 Explorer
	Exec=bash -c "wine explorer"
	Icon=wine
	Type=Application' > ~/Desktop/Wine32_Explorer.desktop
	chmod +x ~/Desktop/Wine32_Explorer.desktop
	sudo cp ~/Desktop/Wine32_Explorer.desktop /usr/share/applications/

	cd ~/Desktop
	echo '[Desktop Entry]
	Name=Wine64 Explorer
	Exec=bash -c "wine64 explorer"
	Icon=wine
	Type=Application' > ~/Desktop/Wine64_Explorer.desktop
	chmod +x ~/Desktop/Wine64_Explorer.desktop
	sudo cp ~/Desktop/Wine64_Explorer.desktop /usr/share/applications/
}

add_wine_paths_to_bashrc () {
	echo 'export DISPLAY=:0
export BOX86_PATH=~/wine/bin/
export BOX86_LD_LIBRARY_PATH=~/wine/lib/wine/i386-unix/:/lib/i386-linux-gnu/:/lib/aarch64-linux-gnu/:/lib/arm-linux-gnueabihf/:/usr/lib/aarch64-linux-gnu/:/usr/lib/arm-linux-gnueabihf/:/usr/lib/i386-linux-gnu/
export BOX64_PATH=~/wine64/bin/
export BOX64_LD_LIBRARY_PATH=~/wine64/lib/i386-unix/:~/wine64/lib/wine/x86_64-unix/:/lib/i386-linux-gnu/:/lib/x86_64-linux-gnu:/lib/aarch64-linux-gnu/:/lib/arm-linux-gnueabihf/:/usr/lib/aarch64-linux-gnu/:/usr/lib/arm-linux-gnueabihf/:/usr/lib/i386-linux-gnu/:/usr/lib/x86_64-linux-gnu' >> ~/.bashrc
	source ~/.bashrc
}

install_winetricks () {
	cd ~/Downloads
	wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
	chmod +x winetricks
	sudo mv winetricks /usr/local/bin/
	cd ~
}

create_winetricks_bin_shortcuts () {
	echo '#!/bin/bash
export BOX86_NOBANNER=1 WINE=wine WINEPREFIX='$wine32_prefix' WINESERVER=~/wine/bin/wineserver
'"/usr/local/bin/winetricks "'"$@"' | sudo tee /usr/local/bin/winetricks32 > /dev/null
	sudo chmod +x /usr/local/bin/winetricks32
	echo '#!/bin/bash
export BOX64_NOBANNER=1 WINE=wine64 WINEPREFIX='$wine64_prefix' WINESERVER=~/wine64/bin/wineserver
'"/usr/local/bin/winetricks "'"$@"' | sudo tee /usr/local/bin/winetricks64 > /dev/null
	sudo chmod +x /usr/local/bin/winetricks64
}

make_wine32_prefix () {
	# Open winecfg and manually add DLL overrides for d3d11, d3d10core, dxgi, and d3d9.
	export WINEPREFIX=$1
	export WINEARCH=win32
	box86 ~/wine/bin/wine winecfg
}

make_wine64_prefix () {
	# Open winecfg and manually add DLL overrides for d3d11, d3d10core, dxgi, and d3d9.
	export WINEPREFIX=$1
	export WINEARCH=win64
	box64 ~/wine/bin/wine64 winecfg
}

install_dxvk () {
	sudo apt install mesa-vulkan-drivers mesa-vulkan-drivers:armhf libvulkan1 libvulkan1:armhf
	cd ~/Downloads
	wget https://github.com/doitsujin/dxvk/releases/download/v${dxvk_version}/dxvk-${dxvk_version}.tar.gz
	tar xvf dxvk-${dxvk_version}.tar.gz
	rm dxvk-${dxvk_version}.tar.gz
	cd dxvk-${dxvk_version}
	cp -f x32/* ${wine32_prefix}/drive_c/windows/system32
	cp -f x32/* ${wine64_prefix}/drive_c/windows/system32
	cp -f x64/* ${wine64_prefix}/drive_c/windows/syswow64
	cd ~
}

change_default_wineprefixes () {
	create_wine_bin_shortcuts
	create_winetricks_bin_shortcuts
	echo "Changed default wine32 prefix path to: $wine32_prefix"
	echo "Changed default wine64 prefix path to: $wine64_prefix"
}

install_box86_and_box64 () {
	echo -e "\nInstalling: box86 & box64 ...\n"
	install_box86
	install_box64
	echo -e "\nInstalled: box86 & box64 \n\n"
}

install_wine_and_dxvk () {
	echo -e "\nInstalling: Wine & DXVK ...\n"
	install_wine_depedencies
	install_wine
	create_wine_bin_shortcuts
	create_wine_desktop_shortcuts
	add_wine_paths_to_bashrc
	install_winetricks
	create_winetricks_bin_shortcuts
	make_wine32_prefix $wine32_prefix
	make_wine64_prefix $wine64_prefix
	install_dxvk
	echo -e "\nInstalled: Wine & DXVK ...\n\n"
}

install_everything () {
	echo -e "\nInstalling: Everything ...\n"
	install_box86_and_box64
	install_steam
	install_wine_and_dxvk
	echo -e "\nInstallation completed\n"
}

#
# Menus
#

menu_main () {
	while true
	do
		clear
		# print values
		echo "Wine version: $wine_version"
		echo "DXVK version: $dxvk_version"
		echo "Path to wine32 prefix: $wine32_prefix"
		echo "Path to wine64 prefix: $wine64_prefix"
		echo

		# menu
		local options=(
		"Install everything"
		"Install box86 & box64"
		"Install Steam"
		"Install Wine & DXVK"
		"-> Change variables"
		"-> Wine administration"
		)
		local PS3=$'\n'"Choose a number: "
		local opt
		select opt in "${options[@]}" "Quit"
		do 
		    case "$REPLY" in
		    1) install_everything;;
		    2) install_box86_and_box64;;
		    3) install_steam;;
		    4) install_wine_and_dxvk;;
		    5) menu_change_variables; break;;
		    6) menu_administrate_wine; break;;
		    $((${#options[@]}+1))) echo "Goodbye!"; break 2;;
		    *) echo "Invalid option. Try another one.";continue;;
		    esac
		done
	done
}

menu_change_variables () {
	clear
	local options=(
	"Set Wine version number"
	"Set DXVK version number"
	"Set wine32 prefix path"
	"Set wine64 prefix path"
	"Change default wine prefix paths"
	)
	local PS3=$'\n'"Choose a number: "
	local opt
	select opt in "${options[@]}" "Return to main menu"
	do 
	    case "$REPLY" in
	    1) read -p "Enter new Wine version number: " wine_version;;
	    2) read -p "Enter new DXVK version number: " dxvk_version;;
	    3) read -p "Enter new wine32 prefix path: " wine32_prefix;;
	    4) read -p "Enter new wine64 prefix path: " wine64_prefix;;
	    5) change_default_wineprefixes;;
	    $((${#options[@]}+1))) return;;
	    *) echo "Invalid option. Try another one.";continue;;
	    esac
	done
}

menu_administrate_wine () {
	while true
	do
		clear
		local options=(
		"Configure wine32 prefix"
		"Configure wine64 prefix"
		"Show wine32 winetricks"
		"Show wine64 winetricks"
		"Make a new Wine32 prefix"
		"Make a new Wine64 prefix"
		"Change default wine prefix paths"	
		)
		local PS3=$'\n'"Choose a number: "
		local opt
		select opt in "${options[@]}" "Return to main menu"
		do 
		    case "$REPLY" in
		    1) wine winecfg; break;;
		    2) wine64 winecfg; break;;
		    3) winetricks32; break;;
		    4) winetricks64; break;;
		    5) read -p "Enter path of new wine32 prefix: " new_wine32_path; make_wine32_prefix $new_wine32_path; break;;
		    6) read -p "Enter path of new wine64 prefix: " new_wine64_path; make_wine64_prefix $new_wine64_path; break;;
		    7) change_default_wineprefixes; read -p "hit ENTER to continue"; break;;
		    $((${#options[@]}+1))) return;;
		    *) echo "Invalid option. Try another one.";continue;;
		    esac
		done
	done
}

################
# main program #
################

# set variable to first parameter or use default value
wine32_prefix=$1
wine32_prefix=${wine32_prefix:="~/.wine32"}
# set variable to second parameter or use default value
wine64_prefix=$2
wine64_prefix=${wine64_prefix:="~/.wine64"}
# set variable to third parameter or use default value
wine_version=$3
wine_version=${wine_version:="9.4"}
# set variable to third parameter or use default value
dxvk_version=$4
dxvk_version=${dxvk_version:="2.3.1"}

# print help
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	echo "Usage: $0 [path to wine32 prefix] [path to wine64 prefix] [wine version] [DXVK version]"
	echo "Default: $0 ~/.wine32 ~/.wine64 9.4 2.3.1"
	exit 0
fi

menu_main
