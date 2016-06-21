#pragma once

// TricorderData is the struct we send to mobile apps
// Any changes to this struct would require changes to mobile apps as well
typedef struct __attribute__((__packed__)) {
  uint32_t packet_id;      // 4 bytes
  time_t timestamp;        // 4 bytes
  uint16_t timestamp_ms;   // 2 bytes
  bool connection_status;  // 1 byte
//   uint8_t charge_percent;  // 1 byte
//   AccelData accel_data;    // 15 bytes
//   int32_t crc32;           // 4 bytes
} Data;           // 31 bytes

typedef struct EczemamaLogger EczemamaLogger;

typedef void (*EczemamaUpdateHandler)(Data *data);

EczemamaLogger* eczemamaLogger_create(void);
void eczemamaLogger_destroy(EczemamaLogger *eczemamaLogger);

void eczemamaLogger_start_logging(EczemamaLogger *eczemamaLogger);
void eczemamaLogger_stop_logging(EczemamaLogger *eczemamaLogger);
bool eczemamaLogger_is_logging(EczemamaLogger *eczemamaLogger);

void eczemamaLogger_reset_data(EczemamaLogger *eczemamaLogger);

void eczemamaLogger_set_update_handler(EczemamaLogger *eczemamaLogger, EczemamaUpdateHandler handler);