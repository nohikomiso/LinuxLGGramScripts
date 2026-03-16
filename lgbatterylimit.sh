#!/bin/bash
DRIVER="/sys/class/power_supply/CMB0/charge_control_end_threshold"
OLD_DRIVER="/sys/devices/platform/lg-laptop/battery_care_limit"
ACPI_CALL="/proc/acpi/call"

# For older models (e.g. 2016 15Z960)
BATT_LIMIT_ADDR="0xBC"

# Lets check the kernel version
function driver_path_check() {
  CURRENT_KERNEL_VERSION=$(uname --kernel-release | cut --delimiter="." --fields=1-2)
  CURRENT_KERNEL_MAJOR_VERSION=$(echo "${CURRENT_KERNEL_VERSION}" | cut --delimiter="." --fields=1)
  CURRENT_KERNEL_MINOR_VERSION=$(echo "${CURRENT_KERNEL_VERSION}" | cut --delimiter="." --fields=2)
  if [ "${CURRENT_KERNEL_MAJOR_VERSION}" -lt "5" ]; then
    DRIVER=$OLD_DRIVER
  fi

  if [ "${CURRENT_KERNEL_MAJOR_VERSION}" == "5" ]; then
    if [ "${CURRENT_KERNEL_MINOR_VERSION}" -lt "18" ]; then
      DRIVER=$OLD_DRIVER
    fi
  fi
}

driver_path_check

# Check for acpi_call if sysfs is missing
USE_ACPI_CALL=0
if [ ! -f "$DRIVER" ]; then
    if [ -f "$ACPI_CALL" ]; then
        USE_ACPI_CALL=1
    else
        echo "LG driver file and acpi_call not found"
        exit -1
    fi
fi

if [ $# -eq 0 ]; then
    if [ $USE_ACPI_CALL -eq 1 ]; then
        VAL_HEX=$(echo "\_SB.PCI0.LPCB.H_EC.ECRX $BATT_LIMIT_ADDR" | sudo tee $ACPI_CALL > /dev/null && sudo cat $ACPI_CALL | tr -d '\0')
        VAL=$((VAL_HEX))
        if [[ $VAL == 80 ]] || [[ $VAL == 0x50 ]]; then
            TURN_ON=0
        else
            TURN_ON=1
        fi
    else
        PREV_VAL=`cat $DRIVER`
        if [[ $PREV_VAL == 80 ]]; then
            TURN_ON=0
        else
            TURN_ON=1
        fi
    fi
else
    if [ "$1" == "off" ]; then
        TURN_ON=0
    else
        TURN_ON=1
    fi
fi

if [[ $TURN_ON == 1 ]]; then
    echo "Changing battery limit to 80%"
    if [ $USE_ACPI_CALL -eq 1 ]; then
        echo "\_SB.PCI0.LPCB.H_EC.ECWX $BATT_LIMIT_ADDR 0x50" | sudo tee $ACPI_CALL > /dev/null
    else
        sudo bash -c "echo 80 > $DRIVER"
    fi
else
    echo "Changing battery limit to 100%"
    if [ $USE_ACPI_CALL -eq 1 ]; then
        echo "\_SB.PCI0.LPCB.H_EC.ECWX $BATT_LIMIT_ADDR 0x64" | sudo tee $ACPI_CALL > /dev/null
    else
        sudo bash -c "echo 100 > $DRIVER"
    fi
fi
