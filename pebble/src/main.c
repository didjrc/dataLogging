/*
Count Logger
Allows user to log the time that the SELECT button is pressed

Should output [time, count]
where time ==> formatted time output 
count ==> # times SELECT is pressed

Once the log is finished logging, the data shall be pushed to the companion iOS app.
Each log will be represented in a list in the companion app;
Tapping each list item will go to a DETAILS view where detailed log data will be listed

Data shall persist on the iOS companion app.
*/

#include <pebble.h>
#include "common.h"

static Window *window;
static TextLayer *text_layer;

//testing
static uint32_t s_packet_id;
//endtesting

//counter variable for # times SELECT is pressed
int select_count = 0;

//datalogging
#define TIMESTAMP_LOG 1
//end

/*
//datalogging
//create session reference variable
static DataLoggingSessionRef logging_session;
//end

static void datalogging_start(void) {
  //datalogging
  //begin datalogging session
  logging_session = data_logging_create(TIMESTAMP_LOG, DATA_LOGGING_INT, sizeof(int), true);
  //end
}

static void datalogging_end(void) {
  //datalogging
  //I think it logs the value of 16 to log session "logging_session"
  //   const int value = 16;
  const uint32_t num_values = 1;
  
  DataLoggingResult result = data_logging_log(logging_session, &select_count, num_values);
  
  if (result != DATA_LOGGING_SUCCESS) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "Woah! Error logging data: %d", (int)result);
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Error!");
  }
  data_logging_finish(logging_session);
}
*/

//method for handling "select" button press
static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
  select_count++;
  text_layer_set_text(text_layer, "Counting...");
  APP_LOG(APP_LOG_LEVEL_DEBUG, "%d counts", select_count); //Pebble log output
  
  //testing
  AppWorkerMessage msg;
  app_worker_send_message(WORKER_KEY_ECZEMAMALOGGER_TOGGLE, &msg);
  //endtesting
}

//method for handling "up" button press
static void up_click_handler(ClickRecognizerRef recognizer, void *context) {
  text_layer_set_text(text_layer, "Logging Started");
//   datalogging_start();
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Logging started"); //Pebble log output
  
  //testing
  AppWorkerMessage msg;
  app_worker_send_message(WORKER_KEY_ECZEMAMALOGGER_START, &msg);
  //endtesting
}

//method for handling "down" button press
static void down_click_handler(ClickRecognizerRef recognizer, void *context) {
  text_layer_set_text(text_layer, "Logging Ended");
//   datalogging_end();
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Logging ended"); //Pebble log output
  
   //testing
  AppWorkerMessage msg;
  app_worker_send_message(WORKER_KEY_ECZEMAMALOGGER_STOP, &msg);
  //endtesting
}

static void click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
  window_single_click_subscribe(BUTTON_ID_UP, up_click_handler);
  window_single_click_subscribe(BUTTON_ID_DOWN, down_click_handler);
}

//creates window upon watchApp load
static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  text_layer = text_layer_create((GRect) { .origin = { 0, 72 }, .size = { bounds.size.w, 20 } });
  text_layer_set_text(text_layer, "Press a button");
  text_layer_set_text_alignment(text_layer, GTextAlignmentCenter);
  layer_add_child(window_layer, text_layer_get_layer(text_layer));
}

static void window_unload(Window *window) {
  text_layer_destroy(text_layer);
}

//testing
static void worker_message_handler(uint16_t type, AppWorkerMessage *data) {
  switch (type) {
    case WORKER_KEY_ECZEMAMALOGGER_UPDATE:
      s_packet_id = data->data0;
      break;
    
      case WORKER_KEY_ECZEMAMALOGGER_START:
        window_set_background_color(window, GColorGreen);
        break;

      case WORKER_KEY_ECZEMAMALOGGER_STOP:
        window_set_background_color(window, GColorChromeYellow);
        break;
  }
   layer_mark_dirty(text_layer_get_layer(text_layer)); 
}
//endtesting

static void init(void) {
  //testing
  app_worker_launch();
  app_worker_message_subscribe(worker_message_handler);
  //endtesting
  
  window = window_create();
  window_set_click_config_provider(window, click_config_provider);
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload,
  });
  const bool animated = true;
  window_stack_push(window, animated);
  
  //testing
  if (persist_read_bool(PERSIST_KEY_IS_LOGGING)) {
    window_set_background_color(window, GColorGreen);
  }

  if (!app_worker_is_running()) {
    window_set_background_color(window, GColorRed);
  }
  //endtesting
}

static void deinit(void) {
  window_destroy(window);
}

int main(void) {
  init();
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);
  app_event_loop();
  deinit();
//  return 0;
}

