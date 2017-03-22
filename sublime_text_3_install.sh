#!/bin/bash
set -eu

# This script will install sublime text editor on Fedora 25 OS
# I have not tested on previous versions, but it should work with little on no changes.
# At the time of writing latest build of sublime text 3 available was '3126'.
# For other build version change 'SUBLIME_TEXT_VERSION' value and run the script

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
RESET_COLOR=$(tput sgr0)

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "$BLUE"    "[INFO]    $*" "$RESET_COLOR"; echo "[INFO]    $(date +"%Y/%m/%d_%H:%M:%S")||$*" >> "$LOG_FILE" 2>&1; }
warning() { echo "$YELLOW"  "[WARNING] $*" "$RESET_COLOR"; echo "[WARNING] $(date +"%Y/%m/%d_%H:%M:%S")||$*" >> "$LOG_FILE" 2>&1; }
error()   { echo "$RED"     "[ERROR]   $*" "$RESET_COLOR"; echo "[ERROR]   $(date +"%Y/%m/%d_%H:%M:%S")||$*" >> "$LOG_FILE" 2>&1; }
fatal()   { echo "$RED"     "[FATAL]   $*" "$RESET_COLOR"; echo "[FATAL]   $(date +"%Y/%m/%d_%H:%M:%S")||$*" >> "$LOG_FILE" 2>&1; exit 1 ; }

if [ "$(id -u)" != "0" ]; then
   error "This script must be run with root privileges."
   exit 1
fi

if [ -d "/opt/sublime_text_3/" ]; then
	warning "/opt/sublime_text_3 already exists."
	warning "Do you want to fitst remove it and continue installation?"

	echo  -n " Enter your choice [Y/N] (default: N):"
	read -r choice

	if [ "$choice" == "Y" ] || [ "$choice" == 'y' ]; then
		info "You entered: $choice"
		info "Removing old /opt/sublime_text_3/"
		rm -rvf /opt/sublime_text_3/
		rm -vf /usr/share/applications/sublime-text-3.desktop
		unlink /usr/bin/sublime
	else
		info "You entered: N"
		info "Nothing to do. Logs are present in $LOG_FILE"
		exit
	fi
fi

SUBLIME_TEXT_VERSION=3126
SUBLIME_TEXT_TARBALL_URL="https://download.sublimetext.com/sublime_text_3_build_${SUBLIME_TEXT_VERSION}_x64.tar.bz2"

if [ -f "/tmp/sublime_text_3_build_${SUBLIME_TEXT_VERSION}_x64.tar.bz2" ]; then
	warning "/tmp/sublime_text_3_build_${SUBLIME_TEXT_VERSION}_x64.tar.bz2 already exists."
	warning "Continuing installation without downloading tarball."
else
	info "Downloading sublime text 3 to /tmp/"
	curl -o /tmp/sublime_text_3_build_${SUBLIME_TEXT_VERSION}_x64.tar.bz2 $SUBLIME_TEXT_TARBALL_URL
	info "Download completed."
fi

info "Extracting to /tmp/"
cd /tmp/
tar -xvf sublime_text_3_build_${SUBLIME_TEXT_VERSION}_x64.tar.bz2
info "Completed extracting."

info "Moving to /opt/ dir."
mv sublime_text_3 /opt/

info "Creating application shortcut (/usr/share/applications/sublime-text-3.desktop)"
cat > "/usr/share/applications/sublime-text-3.desktop" <<EOF
[Desktop Entry]
Name=Sublime Text 3
Comment=Edit text files
Exec=/opt/sublime_text_3/sublime_text
Icon=/opt/sublime_text_3/Icon/128x128/sublime-text.png
Terminal=false
Type=Application
Encoding=UTF-8
Categories=Utility;TextEditor;
EOF

info "Creating symlink for sublime text in /usr/bin (/usr/bin/sublime)"
ln -s /opt/sublime_text_3/sublime_text /usr/bin/sublime
info "Done."

info "Do you want to delete downloaded tarball (/tmp/sublime_text_3_build_${SUBLIME_TEXT_VERSION}_x64.tar.bz2)?"

echo  -n " Enter your choice [Y/N] (default: N):"
read -r choice

if [ "$choice" == "Y" ]; then
	info "You entered: $choice"
	info "Removing tarball /tmp/sublime_text_3_build_${SUBLIME_TEXT_VERSION}_x64.tar.bz2"
	rm -vf /tmp/sublime_text_3_build_${SUBLIME_TEXT_VERSION}_x64.tar.bz2
else
	info "You chosed to keep downloded tarball /tmp/sublime_text_3_build_${SUBLIME_TEXT_VERSION}_x64.tar.bz2"
	warning "Contents from /tmp/ are not preserved on system restart. Move downloaded tarball to some other location if you want to reuse it again."
fi

info "Finished installing. Logs are present in $LOG_FILE"
