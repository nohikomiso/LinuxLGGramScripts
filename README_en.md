# Linux LG Gram Scripts (Fork for 2016 model support)

Language: [日本語](README.md) | **English**

A set of scripts to facilitate the usage of Linux drivers for LG Gram laptops. The driver might be available on kernels 4.20 and above.

This personal fork includes support for the **LG gram 15Z960 (2016 model)** and potentially other legacy models using `acpi_call` as a fallback when the standard kernel driver is unavailable.

## Verified Environment
This fork's modifications (`acpi_call` fallback) have been verified to work on the following environment:

| Item | Details |
| :--- | :--- |
| **Model** | LG gram 15Z960-G.AA12J (2016) |
| **BIOS** | 15ZA1730 X64 (2017/05/29) |
| **KBC** | 38.10.00 |
| **CPU** | Intel Core i5-6200U |
| **OS** | Ubuntu 24.04.4 LTS |
| **Kernel** | 6.11.0-29-generic |

## Prerequisites for Legacy Models (e.g., 2016 model)
If you are using an older LG gram (like the 15Z960) where the standard sysfs paths are not available, you need to install `acpi_call`. On Ubuntu 24.04, it can be easily installed via DKMS:

```bash
# Install kernel headers (required for DKMS)
sudo apt install linux-headers-$(uname -r)

# Install acpi_call (DKMS)
sudo apt install acpi-call-dkms
sudo modprobe acpi_call
```

## Installation
Clone this repository in a directory and add it to your PATH. Alternatively, copy all the .sh files to a directory already in your path. Also make sure the scripts are executable:

```sh
chmod +x *.sh
```

## Usage
These scripts use sudo, so your password might be needed.
All scripts can be used to toggle on and off its respective feature. Alternatively, **on** and **off** can be used as a parameter.

Example:
```sh
./lgbatterylimit.sh on
```

### Available Scripts:
* `lgbatterylimit.sh` - Limits battery charge to 80% (Verified on 2016 model).
* `lgreadermode.sh` - Toggles reader mode / blue light reduction (Verified on 2016 model).
* `lgfanmode.sh` - Toggles silent fan mode (Implemented, untested on 2016 model).
* `lgfnlock.sh` - Toggles FN lock (Not supported on 15Z960).
* `lgtouchpadled.sh` - Turns the touchpad LED on/off.
* `lgusbcharge.sh` - Toggles USB charging while the laptop is off.

## Automation at Boot
Since hardware settings such as the battery limit are reset on power-off, it is recommended to automate the script execution at boot time.

1. **Open the root crontab**
   ```bash
   sudo crontab -e
   ```
   *Choose 1 (nano) if prompted for an editor.*

2. **Add the command to the end of the file**
   Append the following line (make sure to use the absolute path of your script):
   ```bash
   # Set battery limit to 80% at boot
   @reboot /home/ytsubame/src/system_setting/github/LinuxLGGramScripts-2016/lgbatterylimit.sh on
   ```

3. **Save and Exit**
   In nano, press `Ctrl+O` -> `Enter` -> `Ctrl+X`.

---
Japanese documentation is available in [README.md](./README.md).
