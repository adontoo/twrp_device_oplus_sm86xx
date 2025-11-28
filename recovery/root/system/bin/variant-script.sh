#!/sbin/sh

log_file="/dev/kmsg"

log() {
    echo "variant-script.sh: $1" | tee -a "$log_file"
    echo "variant-script.sh: $1" | tee -a /tmp/recovery.log
}

umount -f -l /system
log "/system unmounted"
umount -f -l /vendor
log "/vendor unmounted"
umount -f -l /odm
log "/odm unmounted"

usb_name="$(getprop ro.twrp.device_version)"
echo "$usb_name" > /config/usb_gadget/g1/strings/0x409/product

copy_variant_vendor() {
    local variant_name="$1"
    cp -rf /vendor/variant/$variant_name/vendor/* /vendor
    log "Copied vendor files for variant: $variant_name"
}

device="$(getprop ro.product.device)"

case "$device" in
    "OP5CFBL1" | "OP5E93L1")
        # OnePlus ACE 3v / NORD 4 (audi)
        copy_variant_vendor "audi"
        ;;

    "OP5929L1" | "OP595DL1")
        # OnePlus 12 CN/IN/GL/NA (waffle)
        copy_variant_vendor "waffle"
        ;;

    *)
        # No need to copy files device
        device="$(getprop ro.twrp.device_version)"
        log "No need to copy files for variant: $device"
        ;;
esac

log "twrp.variant.files_copied"

resetprop twrp.variant.files_copied "1"

exit 0
