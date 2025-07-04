# SPDX-License-Identifier: Apache-2.0

# OV2640 ESP32S3 Video Driver
zephyr_library_sources_ifdef(CONFIG_VIDEO_OV2640_ESP32S3 ov2640_esp32s3.c) 