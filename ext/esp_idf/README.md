# ESP-IDF Integration Staging Area

This directory is used to stage ESP-IDF source and header files (e.g., camera, I2C, memory allocation) for integration with the Zephyr build. 

- Mirror the ESP-IDF folder structure here (e.g., camera/, i2c/, heap/).
- Adapt and patch files as needed for Zephyr compatibility.
- The build system will include sources from this directory.
- A sync script can later copy these files to the appropriate location in the Zephyr or ESP-IDF tree before building/flashing. 