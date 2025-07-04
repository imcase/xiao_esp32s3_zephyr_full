#!/bin/bash

# Color constants
BLUE='\e[0;34m'
GREEN='\e[0;32m'
ORANGE='\e[0;33m'
RED='\e[0;31m'
RESET='\e[0m'
PRINT_ERROR="---:[${RED}ERROR]:${RESET}"
PRINT_INFO="---:[${BLUE}INFO]:${RESET}"
PRINT_SUCCESS="---:[${GREEN}SUCCESS]:${RESET}"
PRINT_WARNING="---:[${ORANGE}WARNING]:${RESET}"

# Get script directory and calculate paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
PROJECTS_DIR="$(dirname "${REPO_DIR}")"
ZEPHYR_PROJECT_DIR="$(dirname "${PROJECTS_DIR}")"
ZEPHYR_DIR="${ZEPHYR_PROJECT_DIR}/zephyr"
VENV_DIR="${ZEPHYR_PROJECT_DIR}/.venv"

# Function to copy files/folders without overwriting Zephyr originals
safe_copy() {
    SRC="$1"
    DEST="$2"
    if [ -d "$SRC" ]; then
        mkdir -p "$DEST"
        for file in $(find "$SRC" -type f); do
            relpath="${file#$SRC/}"
            target="$DEST/$relpath"
            if [ -e "$target" ]; then
                echo -e "${PRINT_WARNING} Not overwriting existing: $target"
            else
                mkdir -p "$(dirname "$target")"
                cp "$file" "$target"
                echo -e "${PRINT_SUCCESS} Copied: $file -> $target"
            fi
        done
    elif [ -f "$SRC" ]; then
        if [ -e "$DEST" ]; then
            echo -e "${PRINT_WARNING} Not overwriting existing: $DEST"
        else
            mkdir -p "$(dirname "$DEST")"
            cp "$SRC" "$DEST"
            echo -e "${PRINT_SUCCESS} Copied: $SRC -> $DEST"
        fi
    fi
}

# 1. Copy ESP-IDF hybrid sources to Zephyr tree (without overwriting originals)
ESP_IDF_LOCAL_DIR="${REPO_DIR}/ext/esp_idf"
ESP_IDF_TARGET_DIR="${ZEPHYR_DIR}/ext/esp_idf"

if [ -d "$ESP_IDF_LOCAL_DIR" ]; then
    echo -e "${PRINT_INFO} Copying ESP-IDF hybrid sources to Zephyr tree..."
    safe_copy "$ESP_IDF_LOCAL_DIR" "$ESP_IDF_TARGET_DIR"
else
    echo -e "${PRINT_WARNING} No ESP-IDF sources found at $ESP_IDF_LOCAL_DIR"
fi

# 1a. Copy Zephyr video driver files to Zephyr tree
DRIVER_LOCAL_DIR="${REPO_DIR}/drivers/video"
DRIVER_TARGET_DIR="${ZEPHYR_DIR}/drivers/video"

if [ -d "$DRIVER_LOCAL_DIR" ]; then
    echo -e "${PRINT_INFO} Copying Zephyr video driver files to Zephyr tree..."
    safe_copy "$DRIVER_LOCAL_DIR" "$DRIVER_TARGET_DIR"
else
    echo -e "${PRINT_WARNING} No driver files found at $DRIVER_LOCAL_DIR"
fi

# 1b. Copy device tree bindings to Zephyr tree
DTS_LOCAL_DIR="${REPO_DIR}/dts/bindings"
DTS_TARGET_DIR="${ZEPHYR_DIR}/dts/bindings"

if [ -d "$DTS_LOCAL_DIR" ]; then
    echo -e "${PRINT_INFO} Copying device tree bindings to Zephyr tree..."
    safe_copy "$DTS_LOCAL_DIR" "$DTS_TARGET_DIR"
else
    echo -e "${PRINT_WARNING} No device tree bindings found at $DTS_LOCAL_DIR"
fi

# 1b2. Copy custom driver files (only if they don't exist)
echo -e "${PRINT_INFO} Copying custom driver files..."
safe_copy "${REPO_DIR}/drivers/video/Kconfig.ov2640_esp32s3" "${ZEPHYR_DIR}/drivers/video/Kconfig.ov2640_esp32s3"
safe_copy "${REPO_DIR}/drivers/video/ov2640_esp32s3.c" "${ZEPHYR_DIR}/drivers/video/ov2640_esp32s3.c"
safe_copy "${REPO_DIR}/drivers/video/ov2640_esp32s3.h" "${ZEPHYR_DIR}/drivers/video/ov2640_esp32s3.h"

# 1b3. Copy custom overlay files (only if they don't exist)
echo -e "${PRINT_INFO} Copying custom overlay files..."
safe_copy "${REPO_DIR}/boards/seeed/xiao_esp32s3/xiao_esp32s3_ov2640.overlay" "${ZEPHYR_DIR}/boards/seeed/xiao_esp32s3/xiao_esp32s3_ov2640.overlay"

# 1c. Copy custom overlay to Zephyr board directory (only if it doesn't exist)
LOCAL_OVERLAY="${REPO_DIR}/boards/seeed/xiao_esp32s3/xiao_esp32s3_ov2640.overlay"
ZEPHYR_OVERLAY_DIR="${ZEPHYR_DIR}/boards/seeed/xiao_esp32s3"
ZEPHYR_OVERLAY_TARGET="${ZEPHYR_OVERLAY_DIR}/xiao_esp32s3_ov2640.overlay"

if [ -f "$LOCAL_OVERLAY" ]; then
    echo -e "${PRINT_INFO} Copying custom overlay to Zephyr board directory..."
    safe_copy "$LOCAL_OVERLAY" "$ZEPHYR_OVERLAY_TARGET"
else
    echo -e "${PRINT_WARNING} Custom overlay not found: $LOCAL_OVERLAY"
fi

# 1d. Remove the build directory for a clean build
SAMPLE_DIR="${ZEPHYR_DIR}/samples/drivers/video/test_ov2640_esp32s3"
BUILD_DIR="$SAMPLE_DIR/build"
if [ -d "$BUILD_DIR" ]; then
    echo -e "${PRINT_INFO} Removing previous build directory: $BUILD_DIR"
    rm -rf "$BUILD_DIR"
fi

# 2. Activate .venv environment
if [ -d "$VENV_DIR" ]; then
    echo -e "${PRINT_INFO} Activating Python virtual environment: $VENV_DIR"
    source "$VENV_DIR/bin/activate"
else
    echo -e "${PRINT_ERROR} Python virtual environment not found: $VENV_DIR"
    exit 1
fi

# 3. Build the firmware using west
SAMPLE_DIR="${ZEPHYR_DIR}/samples/drivers/video/test_ov2640_esp32s3"
if [ ! -d "$SAMPLE_DIR" ]; then
    echo -e "${PRINT_ERROR} Zephyr sample directory not found: $SAMPLE_DIR"
    exit 1
fi
cd "$SAMPLE_DIR"
echo -e "${PRINT_INFO} Building firmware with west..."
west build -p always -b xiao_esp32s3/esp32s3/procpu . -- -DSHIELD_ESP32S3_OV2640=n
BUILD_RESULT=$?
if [ $BUILD_RESULT -ne 0 ]; then
    echo -e "${PRINT_ERROR} Build failed."
    exit $BUILD_RESULT
fi

# 4. Flash the firmware
echo -e "${PRINT_INFO} Flashing firmware..."
west flash
FLASH_RESULT=$?
if [ $FLASH_RESULT -ne 0 ]; then
    echo -e "${PRINT_ERROR} Flash failed."
    exit $FLASH_RESULT
fi

echo -e "${PRINT_SUCCESS} Build and flash completed successfully!"
echo -e "${PRINT_INFO} To connect to serial:"
echo -e "${PRINT_INFO}   picocom -b 115200 /dev/ttyACM0" 