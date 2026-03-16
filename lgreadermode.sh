DRIVER="/sys/devices/platform/lg-laptop/reader_mode"
ACPI_CALL="/proc/acpi/call"

# For older models (e.g. 2016 15Z960)
EC_READER_ADDR="0x64"
EC_READER_BIT=0x80

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
        VAL_HEX=$(echo "\_SB.PCI0.LPCB.H_EC.ECRX $EC_READER_ADDR" | sudo tee $ACPI_CALL > /dev/null && sudo cat $ACPI_CALL)
        VAL=$((VAL_HEX))
        if [ $((VAL & EC_READER_BIT)) -ne 0 ]; then
            TURN_ON=0
        else
            TURN_ON=1
        fi
    else
        PREV_VAL=`cat $DRIVER`
        if [[ $PREV_VAL == 1 ]]; then
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
    echo "Turning on reader mode"
    if [ $USE_ACPI_CALL -eq 1 ]; then
        VAL_HEX=$(echo "\_SB.PCI0.LPCB.H_EC.ECRX $EC_READER_ADDR" | sudo tee $ACPI_CALL > /dev/null && sudo cat $ACPI_CALL)
        NEW_VAL=$((VAL_HEX | EC_READER_BIT))
        NEW_VAL_HEX=$(printf "0x%x" $NEW_VAL)
        echo "\_SB.PCI0.LPCB.H_EC.ECWX $EC_READER_ADDR $NEW_VAL_HEX" | sudo tee $ACPI_CALL > /dev/null
    else
        sudo bash -c "echo 1 > $DRIVER"
    fi
else
    echo "Turning off reader mode"
    if [ $USE_ACPI_CALL -eq 1 ]; then
        VAL_HEX=$(echo "\_SB.PCI0.LPCB.H_EC.ECRX $EC_READER_ADDR" | sudo tee $ACPI_CALL > /dev/null && sudo cat $ACPI_CALL)
        NEW_VAL=$((VAL_HEX & ~EC_READER_BIT))
        NEW_VAL_HEX=$(printf "0x%x" $NEW_VAL)
        echo "\_SB.PCI0.LPCB.H_EC.ECWX $EC_READER_ADDR $NEW_VAL_HEX" | sudo tee $ACPI_CALL > /dev/null
    else
        sudo bash -c "echo 0 > $DRIVER"
    fi
fi
