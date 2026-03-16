#!/bin/bash
DRIVER="/sys/devices/platform/lg-laptop/fan_mode"
ACPI_CALL="/proc/acpi/call"

# For older models (e.g. 2016 15Z960)
EC_FAN_ADDR="0xC2"

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

TURN_ON=1
if [ $# -eq 0 ]; then
    if [ $USE_ACPI_CALL -eq 1 ]; then
        VAL_HEX=$(echo "\_SB.PCI0.LPCB.H_EC.ECRX $EC_FAN_ADDR" | sudo tee $ACPI_CALL > /dev/null && sudo cat $ACPI_CALL | tr -d '\0')
        VAL=$((VAL_HEX))
        if [[ $VAL == 1 ]]; then
            TURN_ON=0
        fi
    else
        PREV_VAL=`cat $DRIVER`
        if [[ $PREV_VAL == 1 ]]; then
            TURN_ON=0
        fi
    fi
else
    if [ "$1" == "off" ]; then
        TURN_ON=0
    fi
fi

if [[ $TURN_ON == 1 ]]; then
    echo "Disabling silent fan mode"
    if [ $USE_ACPI_CALL -eq 1 ]; then
        echo "\_SB.PCI0.LPCB.H_EC.ECWX $EC_FAN_ADDR 0x01" | sudo tee $ACPI_CALL > /dev/null
    else
        sudo bash -c "echo 1 > $DRIVER"
    fi
else
    echo "Enabling silent fan mode"
    if [ $USE_ACPI_CALL -eq 1 ]; then
        echo "\_SB.PCI0.LPCB.H_EC.ECWX $EC_FAN_ADDR 0x00" | sudo tee $ACPI_CALL > /dev/null
    else
        sudo bash -c "echo 0 > $DRIVER"
    fi
fi
