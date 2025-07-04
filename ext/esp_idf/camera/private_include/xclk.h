#pragma once

// #include "esp_system.h" // TODO: Replace with Zephyr system APIs if needed
// #include "esp_camera.h" // TODO: Ensure Zephyr compatibility for camera types/APIs

// TODO: Ensure all types and macros are defined for Zephyr compatibility
// TODO: Patch/replace any ESP-IDF-specific APIs

esp_err_t xclk_timer_conf(int ledc_timer, int xclk_freq_hz);

esp_err_t camera_enable_out_clock(const camera_config_t *config);

void camera_disable_out_clock(void); 