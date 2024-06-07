#!/bin/bash

# User-configurable variables
GPU=0000:07:00.0                    # GPU PCI address
GPU_ID="1003 79bf"                  # GPU ID for re-binding
VRAM_SIZE="16GB"                    # Set VRAM size based on your GPU

# Define a function to determine the bit size for rebar based on VRAM size
function get_rebar_size {
    local vram_size=$1
    case $vram_size in
        "2MB") echo 1 ;;
        "4MB") echo 2 ;;
        "8MB") echo 3 ;;
        "16MB") echo 4 ;;
        "32MB") echo 5 ;;
        "64MB") echo 6 ;;
        "128MB") echo 7 ;;
        "256MB") echo 8 ;;
        "512MB") echo 9 ;;
        "1GB") echo 10 ;;
        "2GB") echo 11 ;;
        "4GB") echo 12 ;;
        "8GB") echo 13 ;;
        "16GB") echo 14 ;;
        "32GB") echo 15 ;;
        *) echo "Unsupported VRAM size: $vram_size"; exit 1 ;;
    esac
}

# Use lspci to check the GPU manufacturer
MANUFACTURER=$(lspci -v -s ${GPU} | grep 'VGA compatible controller')

# Unbind GPU from vfio-pci driver
echo "Unbinding GPU from vfio-pci driver..."
echo ${GPU} > /sys/bus/pci/drivers/vfio-pci/unbind
sleep 1

# Get the correct rebar size bit value
REBAR_SIZE=$(get_rebar_size $VRAM_SIZE)

# Check if the GPU is from AMD or NVIDIA and apply settings accordingly
if echo "${MANUFACTURER}" | grep -q "NVIDIA"; then
    echo "Detected NVIDIA GPU. Applying NVIDIA-specific settings..."
    echo "Setting the rebar size to $VRAM_SIZE"
    if ! echo $REBAR_SIZE > /sys/bus/pci/devices/${GPU}/resource1_resize; then
        echo "Failed to set rebar size. Please check if the VRAM size variable ($VRAM_SIZE) is correct for your GPU."
        exit 1
    fi
elif echo "${MANUFACTURER}" | grep -q "AMD"; then
    echo "Detected AMD GPU. Applying AMD-specific settings..."
    echo "Setting the rebar 0 size to $VRAM_SIZE"
    if ! echo $REBAR_SIZE > /sys/bus/pci/devices/${GPU}/resource0_resize; then
        echo "Failed to set rebar 0 size. Please check if the VRAM size variable ($VRAM_SIZE) is correct for your GPU."
        exit 1
    fi
    echo "Setting the rebar 2 size to 8MB"
    if ! echo 3 > /sys/bus/pci/devices/${GPU}/resource2_resize; then
        echo "Failed to set rebar 2 size to 8MB."
        exit 1
    fi
else
    echo "GPU manufacturer not recognized. Exiting script."
    exit 1
fi

# Wait for settings to apply
sleep 2

# Re-bind GPU
echo ${GPU_ID} > /sys/bus/pci/drivers/vfio-pci/new_id || echo -n "${GPU}" > /sys/bus/pci/drivers/vfio-pci/bind
echo "Configuration complete."
sleep 1
