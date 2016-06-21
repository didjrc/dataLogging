#include <pebble_worker.h>
#include "Eczemama.h"
#include "common.h"

static EczemamaLogger *s_eczemamaLogger = NULL;

static void eczemama_update_handler(Data *eczemama_data) {
  Data *data = eczemama_data;
  AppWorkerMessage msg = {
    .data0 = data->packet_id,
  };
  app_worker_send_message(WORKER_KEY_ECZEMAMALOGGER_UPDATE, &msg);
}

static void worker_message_handler(uint16_t type, AppWorkerMessage *data) {
  AppWorkerMessage msg;
  switch (type) {
    case WORKER_KEY_ECZEMAMALOGGER_START:
      eczemamaLogger_start_logging(s_eczemamaLogger);
      persist_write_bool(PERSIST_KEY_IS_LOGGING, true);
      APP_LOG(APP_LOG_LEVEL_DEBUG, "ECZEMAMALOGGER_START"); //Pebble log output
      break;

    case WORKER_KEY_ECZEMAMALOGGER_STOP:
      eczemamaLogger_stop_logging(s_eczemamaLogger);
      persist_write_bool(PERSIST_KEY_IS_LOGGING, false);
      APP_LOG(APP_LOG_LEVEL_DEBUG, "ECZEMAMALOGGER_STOP"); //Pebble log output
      break;

    case WORKER_KEY_ECZEMAMALOGGER_TOGGLE:
      if (eczemamaLogger_is_logging(s_eczemamaLogger)) {
        app_worker_send_message(WORKER_KEY_ECZEMAMALOGGER_STOP, &msg);
      } else {
        app_worker_send_message(WORKER_KEY_ECZEMAMALOGGER_START, &msg);
      }
      APP_LOG(APP_LOG_LEVEL_DEBUG, "ECZEMAMALOGGER_TOGGLE"); //Pebble log output
      break;

    case WORKER_KEY_ECZEMAMALOGGER_RESET:
      eczemamaLogger_reset_data(s_eczemamaLogger);
      break;
  }
}

static void init() {
  app_worker_message_subscribe(worker_message_handler);

  s_eczemamaLogger = eczemamaLogger_create();
  eczemamaLogger_set_update_handler(s_eczemamaLogger, eczemama_update_handler);
}

static void deinit() {
  eczemamaLogger_destroy(s_eczemamaLogger);
  app_worker_message_unsubscribe();
  persist_write_bool(PERSIST_KEY_IS_LOGGING, false);
}

int main(void) {
  init();
  worker_event_loop();
  deinit();
//  return 0;
}