// click on a ruleset name to see its source here
ruleset sensor_profile {
  
  meta {
    
    provides temp_threshold, sms_notify_num, sensor_info
    shares temp_threshold, sms_notify_num, sensor_info
  }
  
  
  global {
    temp_threshold = function() {
      ent:violation_threshold.defaultsTo(80)
    }
    sms_notify_num = function() {
      ent:sms_num
    }
    sensor_info = function() {
      {
        "sensorName": ent:sensor_name,
        "sensorLocation": ent:sensor_loc
      }
    }  
  
  }
  
  rule update_profile {
    select when sensor profile_updated
    pre {
      vals = event:attrs.klog("temp attrs")
    }
    fired {
      ent:violation_threshold := event:attr("tempThreshold").defaultsTo(ent:violation_threshold);
      ent:sms_num := event:attr("smsNum").defaultsTo(ent:sms_num);
      ent:sensor_name := event:attr("sensorName").defaultsTo(ent:sensor_name);
      ent:sensor_loc := event:attr("sensorLocation").defaultsTo(ent:sensor_loc);
    }
  }
}
