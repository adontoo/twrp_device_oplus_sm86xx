# TWRP device tree for OPLUS sm86xx sreies

## Supported devices
- OnePlus Ace 5 / 13R(CN, GL, IN)
- OnePlus Ace 3 Pro(CN)
- OnePlus Ace 3 V / Nord 4(CN, GL, IN)
- Realme GT 6(CN)
## Build it yourself?

```shell
mkdir twrp && cd twrp
repo init --depth=1 -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git -b twrp-16.0
repo sync
git clone --depth=1 https://github.com/adontoo/twrp_device_oplus_sm86xx device/oplus/sm86xx
```

```shell
source build/envsetup.sh
lunch twrp_sm86xx
m recoveryimage
```

If there is no error, recovery.img will be found in `out/target/product/sm86xx/recovery.img`

## Features

Works:

- [X] ADB
- [X] Display
- [X] Decryption
- [X] Fasbootd
- [X] Flashing
- [X] MTP
- [X] Sideload
- [X] Touch
- [X] USB OTG
- [X] Vibrator

## To use it:

```shell
fastboot flash recovery recovery.img
```

or

```shell
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img
```
