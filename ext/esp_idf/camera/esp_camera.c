// Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "time.h"
#include "sys/time.h"
// #include "freertos/FreeRTOS.h" // REMOVED: Use Zephyr kernel
// #include "freertos/task.h"     // REMOVED: Use Zephyr kernel
// #include "driver/gpio.h"       // TODO: Replace with Zephyr GPIO
// #include "esp_system.h"        // TODO: Replace with Zephyr system APIs if needed
// #include "nvs_flash.h"         // TODO: Replace with Zephyr settings if needed
// #include "nvs.h"               // TODO: Replace with Zephyr settings if needed
#include "sensor.h"
#include "sccb.h"
#include "cam_hal.h"
#include "esp_camera.h"
#include "xclk.h"
// #if CONFIG_OV2640_SUPPORT
// #include "ov2640.h"
// #endif
#if CONFIG_OV7725_SUPPORT
#include "ov7725.h"
#endif
#if CONFIG_OV3660_SUPPORT
#include "ov3660.h"
#endif
#if CONFIG_OV5640_SUPPORT
#include "ov5640.h"
#endif
#if CONFIG_NT99141_SUPPORT
#include "nt99141.h"
#endif
#if CONFIG_OV7670_SUPPORT
#include "ov7670.h"
#endif
#if CONFIG_GC2145_SUPPORT
#include "gc2145.h"
#endif
#if CONFIG_GC032A_SUPPORT
#include "gc032a.h"
#endif
#if CONFIG_GC0308_SUPPORT
#include "gc0308.h"
#endif
#if CONFIG_BF3005_SUPPORT
#include "bf3005.h"
#endif
#if CONFIG_BF20A6_SUPPORT
#include "bf20a6.h"
#endif
#if CONFIG_SC101IOT_SUPPORT
#include "sc101iot.h"
#endif
#if CONFIG_SC030IOT_SUPPORT
#include "sc030iot.h"
#endif
#if CONFIG_SC031GS_SUPPORT
#include "sc031gs.h"
#endif
#if CONFIG_MEGA_CCM_SUPPORT
#include "mega_ccm.h"
#endif

// Logging: Replace ESP-IDF logging with Zephyr logging
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(esp_camera, CONFIG_VIDEO_LOG_LEVEL);
#define ESP_LOGI(tag, fmt, ...) LOG_INF(fmt, ##__VA_ARGS__)
#define ESP_LOGE(tag, fmt, ...) LOG_ERR(fmt, ##__VA_ARGS__)
#define ESP_LOGD(tag, fmt, ...) LOG_DBG(fmt, ##__VA_ARGS__)

// TODO: Replace memory allocation (calloc, malloc) with Zephyr k_malloc/k_calloc if needed
// TODO: Replace I2C/SCCB routines with Zephyr I2C API or wrapper
// TODO: Replace GPIO and timer APIs with Zephyr equivalents
// TODO: Replace NVS with Zephyr settings subsystem if persistent storage is needed

// ... existing code ... 