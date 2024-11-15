#!/bin/bash

enable_usbguard() {
    ACTIVE_USERNAME=$(whoami)
    pkexec sh -c '
        mkdir -p /var/log/usbguard
        mkdir -p /etc/usbguard
        chmod 755 /etc/usbguard
        usbguard generate-policy > /etc/usbguard/rules.conf
        systemctl enable --now usbguard.service
        usbguard add-user $1
    ' -- $ACTIVE_USERNAME
    systemctl enable --user --now usbguard-notifier.service
}

message-completed() {
notify-send -t 0 -a "USBGuard Setup" "USB Protection Completed" "All currently connected USB devices will be permanetly allowed. Others will need to be allowed manually. Read on how to use usbguard here:\n\nhttps://ogy.de/sa4n"
}

message-aborted() {
notify-send -t 0 -a "USBGuard Setup" "USB Protection Cancelled" "This will keep your system unchanged and allow any USB device. If you want to protect your system, read on it here:\n\nhttps://ogy.de/sa4n"
}


# main kdialog dialog

kdialog --title "USBGuard Setup" --yesno "Do you want to protect your PC from malicious USB devices?" "By proceeding, you can protect yourself from malicious USB devices that are plugged into your PC. An example are RubberDuckies and many other tools also used by law enforcement and others interested in your data."

if [[ $? -eq 0 ]]; then
    # user chose "okay"
    enable_usbguard
    message_completed
    exit
else
    # user chose "cancel"
    message_aborted
    exit
fi
