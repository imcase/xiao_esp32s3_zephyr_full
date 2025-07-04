/*
 * Copyright (c) 2024 Seeed Studio
 * SPDX-License-Identifier: Apache-2.0
 */

#define DT_DRV_COMPAT ovti_ov2640_esp32s3

#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/video.h>
#include <zephyr/drivers/i2c.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/logging/log.h>
#include <zephyr/sys/util.h>

LOG_MODULE_REGISTER(ov2640_esp32s3, CONFIG_VIDEO_LOG_LEVEL);

/* Forward declarations for ESP-IDF camera functions */
extern int esp_camera_init_wrapper(void);
extern int esp_camera_deinit_wrapper(void);
extern void* esp_camera_fb_get_wrapper(void);
extern void esp_camera_fb_return_wrapper(void *fb);

struct ov2640_config {
	struct i2c_dt_spec i2c;
	uint32_t xclk_freq;
};

struct ov2640_data {
	struct video_format fmt;
	bool streaming;
	uint32_t frame_count;
};

/* Video format capabilities */
static const struct video_format_cap fmts[] = {
	{
		.pixelformat = VIDEO_PIX_FMT_JPEG,
		.width_min = 96,
		.width_max = 1600,
		.height_min = 96, 
		.height_max = 1200,
		.width_step = 2,
		.height_step = 2,
	},
	{0}
};

/* Video capabilities */
static const struct video_caps caps = {
	.format_caps = fmts,
	.min_vbuf_count = 1,
	.min_line_count = 96,
	.max_line_count = 1200,
};

static int ov2640_set_fmt(const struct device *dev, struct video_format *fmt)
{
	struct ov2640_data *data = dev->data;
	
	LOG_INF("Setting format: %s %ux%u", 
		VIDEO_FOURCC_TO_STR(fmt->pixelformat), fmt->width, fmt->height);
	
	/* Validate format */
	if (fmt->pixelformat != VIDEO_PIX_FMT_JPEG) {
		LOG_ERR("Unsupported pixel format");
		return -ENOTSUP;
	}
	
	/* Store format */
	data->fmt = *fmt;
	
	return 0;
}

static int ov2640_get_fmt(const struct device *dev, struct video_format *fmt)
{
	struct ov2640_data *data = dev->data;
	
	*fmt = data->fmt;
	return 0;
}

static int ov2640_get_caps(const struct device *dev, struct video_caps *caps_ptr)
{
	*caps_ptr = caps;
	return 0;
}

static int ov2640_stream_start(const struct device *dev, enum video_buf_type type)
{
	struct ov2640_data *data = dev->data;
	
	if (data->streaming) {
		LOG_WRN("Already streaming");
		return -EALREADY;
	}
	
	LOG_INF("Starting video stream");
	
	/* Initialize ESP-IDF camera */
	int ret = esp_camera_init_wrapper();
	if (ret) {
		LOG_ERR("Failed to initialize ESP camera: %d", ret);
		return ret;
	}
	
	data->streaming = true;
	data->frame_count = 0;
	
	return 0;
}

static int ov2640_stream_stop(const struct device *dev, enum video_buf_type type)
{
	struct ov2640_data *data = dev->data;
	
	if (!data->streaming) {
		LOG_WRN("Not streaming");
		return -EALREADY;
	}
	
	LOG_INF("Stopping video stream");
	
	/* Deinitialize ESP-IDF camera */
	esp_camera_deinit_wrapper();
	
	data->streaming = false;
	
	LOG_INF("Video stream stopped (captured %u frames)", data->frame_count);
	
	return 0;
}

static int ov2640_enqueue(const struct device *dev, struct video_buffer *vbuf)
{
	/* For now, just mark as successful - ESP-IDF handles buffering internally */
	LOG_DBG("Buffer enqueued: %p", vbuf);
	return 0;
}

static int ov2640_dequeue(const struct device *dev, struct video_buffer **vbuf, k_timeout_t timeout)
{
	struct ov2640_data *data = dev->data;
	
	if (!data->streaming) {
		return -EPIPE;
	}
	
	/* Get frame from ESP-IDF camera */
	void *fb = esp_camera_fb_get_wrapper();
	if (!fb) {
		LOG_ERR("Failed to get frame buffer");
		return -EIO;
	}
	
	/* For now, we need to adapt this to work with Zephyr's video buffer system */
	/* This is a simplified implementation - real implementation would need proper buffer management */
	
	data->frame_count++;
	LOG_DBG("Frame %u captured", data->frame_count);
	
	/* Return the frame buffer to ESP-IDF (temporary) */
	esp_camera_fb_return_wrapper(fb);
	
	return -EAGAIN; /* Indicate no buffer available for now */
}

/* Video driver API */
static const struct video_driver_api ov2640_driver_api = {
	.set_format = ov2640_set_fmt,
	.get_format = ov2640_get_fmt,
	.get_caps = ov2640_get_caps,
	.stream_start = ov2640_stream_start,
	.stream_stop = ov2640_stream_stop,
	.enqueue = ov2640_enqueue,
	.dequeue = ov2640_dequeue,
};

/* Hardware initialization functions - called from application */
int ov2640_init_hardware(const struct device *dev)
{
	LOG_INF("OV2640 hardware initialization");
	
	/* This will be implemented to initialize ESP-IDF camera hardware */
	/* For now, return success */
	
	return 0;
}

int ov2640_init_gpio(const struct device *dev)
{
	LOG_INF("OV2640 GPIO initialization");
	
	/* This will be implemented to initialize camera GPIO pins */
	/* For now, return success */
	
	return 0;
}

int ov2640_init_components(const struct device *dev)
{
	LOG_INF("OV2640 components initialization");
	
	/* This will be implemented to initialize I2C, LCD_CAM, sensor */
	/* For now, return success */
	
	return 0;
}

int ov2640_init_i2c(const struct device *dev)
{
	const struct ov2640_config *config = dev->config;
	
	LOG_INF("OV2640 I2C initialization");
	
	if (!device_is_ready(config->i2c.bus)) {
		LOG_ERR("I2C device not ready");
		return -ENODEV;
	}
	
	LOG_INF("I2C device ready at 0x%02x", config->i2c.addr);
	
	return 0;
}

static int ov2640_init(const struct device *dev)
{
	const struct ov2640_config *config = dev->config;
	struct ov2640_data *data = dev->data;
	
	LOG_INF("Initializing OV2640 video device");
	
	/* Initialize default format */
	data->fmt.type = VIDEO_BUF_TYPE_OUTPUT;
	data->fmt.pixelformat = VIDEO_PIX_FMT_JPEG;
	data->fmt.width = 320;
	data->fmt.height = 240;
	data->fmt.pitch = 320;
	data->streaming = false;
	data->frame_count = 0;
	
	LOG_INF("OV2640 initialized successfully");
	LOG_INF("XCLK frequency: %u Hz", config->xclk_freq);
	
	return 0;
}

#define OV2640_INIT(n)							\
	static const struct ov2640_config ov2640_config_##n = {	\
		.i2c = I2C_DT_SPEC_INST_GET(n),			\
		.xclk_freq = DT_INST_PROP(n, xclk_frequency),		\
	};								\
									\
	static struct ov2640_data ov2640_data_##n;			\
									\
	DEVICE_DT_INST_DEFINE(n, ov2640_init, NULL,			\
			      &ov2640_data_##n, &ov2640_config_##n,	\
			      POST_KERNEL, CONFIG_VIDEO_INIT_PRIORITY,	\
			      &ov2640_driver_api);

DT_INST_FOREACH_STATUS_OKAY(OV2640_INIT) 