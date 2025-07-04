/*
 * Copyright (c) 2024 Seeed Studio
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef OV2640_ESP32S3_H
#define OV2640_ESP32S3_H

#include <zephyr/device.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initialize OV2640 hardware components
 * 
 * @param dev Video device instance
 * @return 0 on success, negative errno on failure
 */
int ov2640_init_hardware(const struct device *dev);

/**
 * @brief Initialize OV2640 GPIO pins
 * 
 * @param dev Video device instance
 * @return 0 on success, negative errno on failure
 */
int ov2640_init_gpio(const struct device *dev);

/**
 * @brief Initialize OV2640 components (I2C, LCD_CAM, sensor)
 * 
 * @param dev Video device instance
 * @return 0 on success, negative errno on failure
 */
int ov2640_init_components(const struct device *dev);

/**
 * @brief Initialize OV2640 I2C communication
 * 
 * @param dev Video device instance
 * @return 0 on success, negative errno on failure
 */
int ov2640_init_i2c(const struct device *dev);

#ifdef __cplusplus
}
#endif

#endif /* OV2640_ESP32S3_H */ 