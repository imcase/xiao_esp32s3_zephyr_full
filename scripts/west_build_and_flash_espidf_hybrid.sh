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

# 1b2. Force overwrite updated files that have been modified
echo -e "${PRINT_INFO} Force overwriting updated driver files..."
cp "${REPO_DIR}/drivers/video/Kconfig.ov2640_esp32s3" "${ZEPHYR_DIR}/drivers/video/Kconfig.ov2640_esp32s3"
cp "${REPO_DIR}/drivers/video/ov2640_esp32s3.c" "${ZEPHYR_DIR}/drivers/video/ov2640_esp32s3.c"
echo -e "${PRINT_SUCCESS} Updated driver files copied."

# 1b3. Force overwrite overlay files
echo -e "${PRINT_INFO} Force overwriting updated overlay files..."
cp "${REPO_DIR}/boards/seeed/xiao_esp32s3/xiao_esp32s3.overlay" "${ZEPHYR_DIR}/boards/seeed/xiao_esp32s3/xiao_esp32s3.overlay"
cp "${REPO_DIR}/boards/seeed/xiao_esp32s3/xiao_esp32s3.overlay" "${ZEPHYR_DIR}/boards/seeed/xiao_esp32s3/xiao_esp32s3_procpu.overlay"
cp "${REPO_DIR}/boards/seeed/xiao_esp32s3/xiao_esp32s3.overlay" "${ZEPHYR_DIR}/boards/seeed/xiao_esp32s3/xiao_esp32s3_procpu_sense.overlay"
echo -e "${PRINT_SUCCESS} Updated overlay files copied."

# 1c. Copy local overlay to Zephyr board directory (for all relevant board variants, without overwriting originals)
LOCAL_OVERLAY="${REPO_DIR}/boards/seeed/xiao_esp32s3/xiao_esp32s3.overlay"
ZEPHYR_OVERLAY_DIR="${ZEPHYR_DIR}/boards/seeed/xiao_esp32s3"
for variant in xiao_esp32s3 xiao_esp32s3_procpu xiao_esp32s3_procpu_sense; do
    ZEPHYR_OVERLAY_TARGET="${ZEPHYR_OVERLAY_DIR}/${variant}.overlay"
    if [ -f "$LOCAL_OVERLAY" ]; then
        echo -e "${PRINT_INFO} Copying local overlay to Zephyr board directory as $variant.overlay..."
        if [ -e "$ZEPHYR_OVERLAY_TARGET" ]; then
            echo -e "${PRINT_WARNING} Not overwriting existing Zephyr overlay: $ZEPHYR_OVERLAY_TARGET"
        else
            mkdir -p "$ZEPHYR_OVERLAY_DIR"
            cp "$LOCAL_OVERLAY" "$ZEPHYR_OVERLAY_TARGET"
            echo -e "${PRINT_SUCCESS} Copied overlay: $LOCAL_OVERLAY -> $ZEPHYR_OVERLAY_TARGET"
        fi
    else
        echo -e "${PRINT_WARNING} Local overlay not found: $LOCAL_OVERLAY"
    fi
done

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