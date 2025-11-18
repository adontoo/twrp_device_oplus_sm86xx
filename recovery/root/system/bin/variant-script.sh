#!/sbin/sh

variant="$(getprop ro.boot.prjname)"

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

set_oneplus_common() {
    local usb_name="$1"
    local product_name="$2"
    local device_code="$3"
    local region="$4"
    local spr_value="$5"

    echo "$usb_name" > /config/usb_gadget/g1/strings/0x409/product

    resetprop ro.product.brand "OnePlus"
    resetprop ro.product.manufacturer "OnePlus"
    resetprop vendor.display.enable_spr "$spr_value"
    resetprop ro.product.name "$product_name"
    resetprop ro.product.device "$device_code"
    resetprop ro.product.system.device "$product_name"
    resetprop ro.product.vendor.device "$device_code"
    resetprop ro.product.odm.device "$device_code"
    resetprop ro.product.product.device "$device_code"
    resetprop ro.product.system_ext.device "$device_code"
    resetprop ro.product.product.model "$product_name"
    resetprop ro.product.model "$product_name"
    resetprop ro.product.system.model "$product_name"
    resetprop ro.product.system_ext.model "$product_name"
    resetprop ro.product.vendor.model "$product_name"
    resetprop ro.product.odm.model "$product_name"
    resetprop ro.boot.hardware.revision "$region"
    log "Variant $usb_name ($product_name) properties all set."
}

case "$variant" in
    "23851")
        # OnePlus ACE 5 (giulia)
        set_oneplus_common "Oneplus ACE 5" "PKG110" "OP5D2BL1" "CN" "0"
        ;;

    "23868")
        # OnePlus 13R (giulia)
        set_oneplus_common "Oneplus 13 R" "CPH2645" "OP5D3BL1" "GL" "0"
        ;;

    "23869")
        # OnePlus 13R (giulia)
        set_oneplus_common "Oneplus 13 R" "CPH2647" "OP5D3BL1" "NA" "0"
        ;;

    "23867")
        # OnePlus 13R (giulia)
        set_oneplus_common "Oneplus 13 R" "CPH2691" "OP5D3BL1" "IN" "0"
        ;;

    "23803")
        # OnePlus ACE 3 V (audi)
        set_oneplus_common "Oneplus ACE 3 V" "PJF110" "OP5CFBL1" "CN" "0"
        ;;

    "24211")
        # OnePlus NORD 4 (audi)
        set_oneplus_common "Oneplus NORD 4" "CPH2661" "OP5E93L1" "IN" "0"
        ;;

    "23814")
        # OnePlus ACE 3 PRO (corvette)
        set_oneplus_common "Oneplus ACE 3 Pro" "PJX110" "OP5D06L1" "CN" "0"
        ;;

    "23631")
        # Realme GT 6 (divo)
        set_oneplus_common "Realme GT 6" "RMX3800" "RE5C4FL1" "CN" "0"
        ;;

    *)
        # Unknown variant
        log "Unknown variant: $variant"
        ;;
esac

device="$(getprop ro.product.device)"

case "$device" in
    "OP5CFBL1")
        # OnePlus ACE 3v (audi)
        cp -rf /vendor/variant/audi/vendor/* /vendor
        ;;

    "OP5E93L1")
        # OnePlus NORD 4 (audi)
        cp -rf /vendor/variant/audi/vendor/* /vendor
        ;;

    *)
        # No need to copy files device
        device="$(cat /config/usb_gadget/g1/strings/0x409/product)"
        log "No need to copy files for variant: $device"
        ;;
esac

log "twrp.variant.files_copied"

resetprop twrp.variant.files_copied "1"

exit 0
