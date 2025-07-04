# xiao_esp32s3_zephyr_full

## Project Overview

This project is a hybrid embedded system for the XIAO ESP32S3 Sense, combining the reliability and modularity of the Zephyr RTOS with the specialized hardware support of ESP-IDF drivers. The goal is to leverage Zephyr for core OS, configuration, and most peripherals, while integrating ESP-IDF code for critical hardware operations such as the camera, I2C (for the camera sensor), and memory buffer allocation.

## Technical Approach

- **Zephyr as the main OS:** Kernel, build system, device tree, and Kconfig are used for most of the project.
- **ESP-IDF integration:** ESP-IDF drivers/libraries are selectively included for:
  - Camera (esp_camera)
  - I2C routines for camera sensor
  - Memory buffer allocation (e.g., `heap_caps_malloc`)
- **Adaptation:** ESP-IDF code is patched as needed to replace FreeRTOS calls, memory allocation, and hardware register access for Zephyr compatibility.
- **Configuration:** Zephyr's device tree and Kconfig are used for all peripherals, even those using ESP-IDF drivers.
- **Build system:** ESP-IDF sources are integrated into Zephyr's CMake-based build system.

## ESP-IDF Directory References

- ESP-IDF workspace root: `/mnt/sdb_disk/repo/OTHER/esp-idf-workspace`
- ESP32 camera driver/component: `/mnt/sdb_disk/repo/OTHER/esp-idf-workspace/esp32-camera`
- ESP-IDF framework source: `/mnt/sdb_disk/repo/OTHER/esp-idf-workspace/esp-idf`
- Example ESP-IDF project: `/mnt/sdb_disk/repo/OTHER/esp-idf-workspace/projects/xiao_esp32s3_espidf`

## Setup & Build Instructions (High-Level)

1. **Clone this repository and the ESP-IDF sources** (see directory references above).
2. **Set up the Zephyr development environment** as per the [Zephyr Getting Started Guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html).
3. **Integrate ESP-IDF sources** into the Zephyr build (CMakeLists.txt and Kconfig modifications as needed).
4. **Configure the device tree and Kconfig** for your board and peripherals.
5. **Build the project** using Zephyr's build system (e.g., `west build ...`).
6. **Flash and test** on the XIAO ESP32S3 Sense board.

## Reference

For a detailed technical concept and adaptation checklist, see [`docs/CONCEPT.md`](docs/CONCEPT.md).
