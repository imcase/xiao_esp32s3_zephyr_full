# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.20.0)

# Set the board root to find our custom board files
set(BOARD_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/../..)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(video_capture_sample)

# Include source files
target_sources(app PRIVATE src/main.c)

# Prepare for ESP-IDF integration
set(ESP_IDF_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ext/esp_idf)
set(ESP_IDF_CAMERA_DIR ${ESP_IDF_SRC_DIR}/camera)
if(EXISTS ${ESP_IDF_CAMERA_DIR})
  file(GLOB ESP_IDF_CAMERA_SOURCES
    ${ESP_IDF_CAMERA_DIR}/*.c
  )
  target_sources(app PRIVATE ${ESP_IDF_CAMERA_SOURCES})
  target_include_directories(app PRIVATE
    ${ESP_IDF_CAMERA_DIR}/include
    ${ESP_IDF_CAMERA_DIR}/private_include
    ${ESP_IDF_CAMERA_DIR}
  )
endif() 