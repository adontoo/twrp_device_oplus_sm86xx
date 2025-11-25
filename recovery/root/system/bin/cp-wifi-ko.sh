#!/system/bin/sh

# Do not copy in fastbootd mode
FASTBOOTD_PROP=$(getprop ro.twrp.fastbootd)
if [ "$FASTBOOTD_PROP" = "1" ]; then
    echo "I:cp-wifi-ko.sh: Detected fastbootd (ro.twrp.fastbootd=1), exit script." >> /tmp/recovery.log
    exit 0
fi

mount /vendor_dlkm
mount /system_dlkm

LOG_TAG="I:cp-wifi-ko.sh"
TARGET_DIR="/odm/wifi/modules"
SEARCH_DIRS="/vendor_dlkm /system_dlkm"
KO_FILES="cnss_prealloc.ko cnss_nl.ko wlan_firmware_service.ko cnss_plat_ipc_qmi_svc.ko cnss_utils.ko cnss2.ko gsim.ko rmnet_mem.ko ipam.ko rfkill.ko cfg80211.ko qca_cld3_kiwi_v2.ko"

log_print() {
    echo "$LOG_TAG: $1" >> /tmp/recovery.log
}

if [ ! -d "$TARGET_DIR" ]; then
    log_print "Creating target dir: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
    if [ $? -ne 0 ]; then
        log_print "Error: unable to create $TARGET_DIR"
        exit 1
    fi
fi

chmod 0755 "$TARGET_DIR"

log_print "Search and copy wifi ko files..."

found_count=0
copied_count=0

for ko_file in $KO_FILES; do
    file_found=0
    for search_dir in $SEARCH_DIRS; do
        if [ -d "$search_dir" ]; then
            file_path=$(find "$search_dir" -type f -name "$ko_file" 2>/dev/null | head -1)
            if [ -n "$file_path" ] && [ -f "$file_path" ]; then
                file_found=1
                target_file="$TARGET_DIR/$ko_file"
                if [ ! -f "$target_file" ]; then
                    log_print "Copy: $file_path -> $target_file"
                    cp "$file_path" "$target_file"
                    if [ $? -eq 0 ]; then
                        chmod 0644 "$target_file"
                        copied_count=$((copied_count + 1))
                        log_print "Copy successfully: $ko_file"
                    else
                        log_print "Error: Copy failed:  $ko_file"
                    fi
                else
                    log_print "Skip existing file: $ko_file"
                fi
                break
            fi
        else
            log_print "Warning: The search directory does not exist: $search_dir"
        fi
    done
    
    if [ $file_found -eq 1 ]; then
        found_count=$((found_count + 1))
    else
        log_print "Unable to found: $ko_file"
    fi
done

log_print "Copy done: $found_count files found, $copied_count files copied."
log_print "Target dir files:"
ls -la "$TARGET_DIR" 2>/dev/null | while read line; do
    log_print "$line"
done

resetprop twrp.cpko "true"

exit 0