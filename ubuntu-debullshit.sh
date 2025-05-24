#!/usr/bin/env bash

disable_ubuntu_report() {
    ubuntu-report send no
    apt remove ubuntu-report -y
}

remove_appcrash_popup() {
    apt remove apport apport-gtk -y
}

remove_snaps() {
    while [ "$(snap list | wc -l)" -gt 0 ]; do
        for snap in $(snap list | tail -n +2 | cut -d ' ' -f 1); do
            snap remove --purge "$snap" 2> /dev/null
        done
    done

    systemctl stop snapd
    systemctl disable snapd
    systemctl mask snapd
    apt purge snapd -y
    rm -rf /snap /var/lib/snapd
    for userpath in /home/*; do
        rm -rf $userpath/snap
    done
    cat <<-EOF | tee /etc/apt/preferences.d/nosnap.pref
	Package: snapd
	Pin: release a=*
	Pin-Priority: -10
	EOF
}

disable_terminal_ads() {
    sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news 2>/dev/null
    pro config set apt_news=false
}

update_system() {
    apt update && apt upgrade -y
}

cleanup() {
    apt autoremove -y
}

setup_flathub() {
    apt install flatpak -y
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    apt install --install-suggests gnome-software -y
}

gsettings_wrapper() {
    if ! command -v dbus-launch; then
        sudo apt install dbus-x11 -y
    fi
    sudo -Hu $(logname) dbus-launch gsettings "$@"
}

adjust_settings() {
    # Binds
    gsettings_wrapper set org.gnome.shell.keybindings switch-to-application-1 []
    gsettings_wrapper set org.gnome.shell.keybindings switch-to-application-2 []
    gsettings_wrapper set org.gnome.shell.keybindings switch-to-application-3 []
    gsettings_wrapper set org.gnome.shell.keybindings switch-to-application-4 []
    gsettings_wrapper set org.gnome.shell.keybindings toggle-message-tray []
    gsettings_wrapper set org.gnome.desktop.wm.keybindings switch-input-source "[]"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"

    gsettings_wrapper set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"

    gsettings_wrapper set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Shift><Super>1']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Shift><Super>2']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Shift><Super>3']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Shift><Super>4']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<Shift><Super>5']"

    gsettings_wrapper set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings close "['<Super>q']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings maximize "['<Super>f']"
    gsettings_wrapper set org.gnome.desktop.wm.keybindings unmaximize "['<Super>t']"

    gsettings_wrapper set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>Return'
    gsettings_wrapper set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'alacritty'
    gsettings_wrapper set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'open terminal'

    gsettings_wrapper set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>e'
    gsettings_wrapper set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'nautilus -w /hdd'
    gsettings_wrapper set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'open file manager'

    # Preferences
    gsettings_wrapper set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    gsettings_wrapper set org.gnome.desktop.wm.preferences focus-mode 'sloppy'
    gsettings_wrapper set org.gnome.desktop.wm.preferences num-workspaces 5

    gsettings_wrapper set org.gnome.desktop.interface clock-show-weekday true
    gsettings_wrapper set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings_wrapper set org.gnome.desktop.interface enable-hot-corners false
    gsettings_wrapper set org.gnome.desktop.interface gtk-enable-primary-paste false

    gsettings_wrapper set org.gnome.desktop.sound event-sounds false
    gsettings_wrapper set org.gnome.desktop.sound theme-name '__custom'

    gsettings_wrapper set org.gnome.shell enabled-extensions "['ubuntu-appindicators@ubuntu.com']"
}

personal_things() {
    # Mount points
    mkdir /hdd
    mkdir /sata

    apt remove gnome-clocks -y
    apt remove gnome-characters -y
    apt remove gnome-calendar -y
    apt remove gnome-font-viewer -y
    apt remove gnome-system-monitor -y
    apt remove gnome-snapshot -y
    apt remove totem -y
    apt remove simple-scan -y
    apt remove gnome-logs -y

    apt install curl -y
    apt install fastfetch -y
    apt install alacritty -y
    apt install gh -y
    apt install vlc -y
    apt install obs-studio -y
    apt install dconf-editor -y
    apt install htop -y
    apt install gnome-tweaks -y

    flatpak install flathub com.belmoussaoui.Authenticator --noninteractive
    flatpak install flathub com.bitwarden.desktop --noninteractive
    flatpak install flathub it.mijorus.gearlever --noninteractive
    flatpak install flathub com.discordapp.Discord --noninteractive
    flatpak install flathub com.rtosta.zapzap --noninteractive
    flatpak install flathub org.gnome.Todo --noninteractive
    flatpak install flathub de.haeckerfelix.Fragments --noninteractive
    flatpak install flathub io.missioncenter.MissionCenter --noninteractive
    flatpak install flathub com.mattjakeman.ExtensionManager --noninteractive

    curl -fsS https://dl.brave.com/install.sh | sh
    curl -f https://zed.dev/install.sh | sh

    bash <(curl -sSL https://spotx-official.github.io/run.sh) --installdeb

    echo 'fastfetch' >> ~/.bashrc
    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
}

main() {
    if [ "$(id -u)" != 0 ]; then
        echo 'Please run the script as root!'
        echo 'We need to do administrative tasks'
        exit
    fi

    update_system
    disable_ubuntu_report
    remove_appcrash_popup
    disable_terminal_ads
    remove_snaps
    setup_flathub
    personal_things
    adjust_settings
    cleanup

    reboot
    exit 0
}

main
