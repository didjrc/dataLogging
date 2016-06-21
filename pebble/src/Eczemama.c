#include <pebble.h>
#include "Eczemama.h"

#define DEFAULT_TAG 42
#define DEFAULT_DELAY_INTERVAL 500

static void prv_delay_timer_callback(void *data);

typedef struct EczemamaLogger {
  Data *data;
  DataLoggingSessionRef logging_session;
  uint32_t tag;
  AppTimer *delay_timer;
  uint32_t delay_interval;
  EczemamaUpdateHandler update_handler;
} EczemamaLogger;

EczemamaLogger* eczemamaLogger_create(void) {
  EczemamaLogger *eczemamaLogger = malloc(sizeof(EczemamaLogger));
  if (!eczemamaLogger) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "failed to allocate memory for tricorder");
    return NULL;
  }

  *eczemamaLogger = (EczemamaLogger) {
    .tag = DEFAULT_TAG,
    .delay_interval = DEFAULT_DELAY_INTERVAL,
  };

  eczemamaLogger->data = malloc(sizeof(Data));
  if (!eczemamaLogger->data) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "failed to allocate memory for tricorder data");
    free(eczemamaLogger);
    return NULL;
  }

  *eczemamaLogger->data = (Data) {0};

  return eczemamaLogger;
}

void eczemamaLogger_destroy(EczemamaLogger *eczemamaLogger) {
  if (!eczemamaLogger) return;

  app_timer_cancel(eczemamaLogger->delay_timer);
  if (eczemamaLogger->logging_session) {
    data_logging_finish(eczemamaLogger->logging_session);
  }
  free(eczemamaLogger->data);
  free(eczemamaLogger);
}

void eczemamaLogger_start_logging(EczemamaLogger *eczemamaLogger) {
  if (!eczemamaLogger) return;
  if (eczemamaLogger->logging_session) return;

  eczemamaLogger_reset_data(eczemamaLogger);

  eczemamaLogger->logging_session = data_logging_create(eczemamaLogger->tag,
                                                   DATA_LOGGING_BYTE_ARRAY,
                                                   sizeof(Data), true);
  if (!eczemamaLogger->logging_session) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "failed to create data logging session");
    return;
  }

  eczemamaLogger->delay_timer = app_timer_register(0, prv_delay_timer_callback, eczemamaLogger);
}

void eczemamaLogger_stop_logging(EczemamaLogger *eczemamaLogger) {
  if (!eczemamaLogger) return;
  if (!eczemamaLogger->logging_session) return;

  app_timer_cancel(eczemamaLogger->delay_timer);
  data_logging_finish(eczemamaLogger->logging_session);
  eczemamaLogger->logging_session = NULL;
}

bool eczemamaLogger_is_logging(EczemamaLogger *eczemamaLogger) {
  if (!eczemamaLogger) return false;

  return eczemamaLogger->logging_session != NULL;
}

void eczemamaLogger_reset_data(EczemamaLogger *eczemamaLogger) {
  if (!eczemamaLogger) return;

  *eczemamaLogger->data = (Data) {0};

  if (eczemamaLogger->update_handler != NULL) {
    eczemamaLogger->update_handler(eczemamaLogger->data);
  }
}

void eczemamaLogger_set_update_handler(EczemamaLogger *eczemamaLogger, EczemamaUpdateHandler handler) {
  if (!eczemamaLogger) return;

  eczemamaLogger->update_handler = handler;
}

static void prv_update_data(EczemamaLogger *eczemamaLogger) {
  if (!eczemamaLogger) {
    APP_LOG(APP_LOG_LEVEL_DEBUG, "prv_update_data"); //Pebble log output
    return;
  }

  eczemamaLogger->data->packet_id++;
  time_ms(&eczemamaLogger->data->timestamp, &eczemamaLogger->data->timestamp_ms);

  //test
  time_t temp = time(NULL);
  struct tm *time_ms = localtime(&temp);
  //endTest

#if defined(PBL_SDK_2)
  eczemamaLogger->data->connection_status = bluetooth_connection_service_peek();
#elif defined(PBL_SDK_3)
  eczemamaLogger->data->connection_status = connection_service_peek_pebble_app_connection();
#endif
//   eczemamaLogger->data->charge_percent = battery_state_service_peek().charge_percent;
//   accel_service_peek(&eczemamaLogger->data->accel_data);
//   eczemamaLogger->data->crc32 = 0;
//   eczemamaLogger->data->crc32 = crc32(tricorder->data, sizeof(TricorderData));

  if (eczemamaLogger->update_handler != NULL) {
    eczemamaLogger->update_handler(eczemamaLogger->data);
  }
}

static void prv_log_data(EczemamaLogger *eczemamaLogger) {
  if (!eczemamaLogger) return;

  printf("==================================================");
  printf("packet_id:\t\t%d", (int) eczemamaLogger->data->packet_id);
  printf("timestamp:\t\t%d.%d", (int) eczemamaLogger->data->timestamp,
                                (int) eczemamaLogger->data->timestamp_ms);
  printf("connection_status:\t%d", (int) eczemamaLogger->data->connection_status);
//   printf("charge_percent:\t%d", (int) eczemamaLogger->data->charge_percent);
//   printf("accel:\t\t%05d\t%05d\t%05d\t%d", (int) eczemamaLogger->data->accel_data.x,
//                                            (int) eczemamaLogger->data->accel_data.y,
//                                            (int) eczemamaLogger->data->accel_data.z,
//                                            (int) eczemamaLogger->data->accel_data.did_vibrate);
//   printf("crc32:\t\t%d", (int) tricorder->data->crc32);
}

static void prv_add_data(EczemamaLogger *eczemamaLogger) {
  if (!eczemamaLogger) return;

  DataLoggingResult res = data_logging_log(eczemamaLogger->logging_session, eczemamaLogger->data, 1);
  if (res != DATA_LOGGING_SUCCESS) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "failed to add data to the logging session: %d", (int) res);
  }

  //test
  //Insert if-statement for DATA_LOGGING_FULL
  //End DATALOG -- before or after push?
  //Println 
  //Push DATALOG to phone
  else if (res == DATA_LOGGING_FULL) {
    APP_LOG(APP_LOG_LEVEL_DEBUG, "DATA_LOGGING_FULL");
    eczemamaLogger_stop_logging(eczemamaLogger);
  }
  //endTest
}

static void prv_delay_timer_callback(void *data) {
  if (!data) return;

  EczemamaLogger *eczemamaLogger = data;

  prv_update_data(eczemamaLogger);
  prv_log_data(eczemamaLogger);
  prv_add_data(eczemamaLogger);

  eczemamaLogger->delay_timer = app_timer_register(eczemamaLogger->delay_interval,
                                              prv_delay_timer_callback, data);
}
