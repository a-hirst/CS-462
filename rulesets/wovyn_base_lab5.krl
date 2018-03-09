ruleset wovyn_base {
  
  meta {
    use module sensor_profile
    use module keys
    use module twilio
        with account_sid = keys:twilio{"account_sid"}
             auth_token =  keys:twilio{"auth_token"}
  }
  
  
  rule process_heartbeat {
    select when wovyn heartbeat genericThing re#[^\0]#
    pre {
      wovyn_data = event:attrs.klog("attrs");
      genericThing = event:attr("genericThing").klog("generic");
      temperature = wovyn_data{["genericThing", "data", "temperature"]}[0]{["temperatureF"]}.klog("temp2");
      timestamp = time:now().klog("timestamp");

    }
    every {
      event:send({
        "eci":"TM3Ui4g4winMhjLxMKrWuN", 
        "domain":"wovyn", 
        "type":"new_temperature_reading", 
        "attrs":{
          "temperature": temperature,
          "timestamp": timestamp
        }})

      send_directive("heartbeat", {"body": {"attrs": wovyn_data}});
    }
  }
  
  rule find_high_temps {
    select when wovyn new_temperature_reading
    pre {
      temperature = event:attr("temperature")
    }
    send_directive("find high temps", {"body": {"violation": (temperature > sensor_profile:temp_threshold())}}) 
    
    always {
      raise wovyn event "threshold_violation" attributes event:attrs if (temperature > sensor_profile:temp_threshold() );
    } 
  }
  
  rule threshold_violation {
    select when wovyn threshold_violation
    pre {
      temperature = event:attrs.klog("attrs")
      message = "Temperature Violation: temperature is " + event:attr("temperature") 
      + ", timestamp: " + event:attr("timestamp")
    }
    twilio:send_sms(sensor_profile:sms_notify_num(),
                    "+19513098481",
                    message
                   )
    // send_directive("temperature violation", {"attrs": temperature})
  }
  
}
