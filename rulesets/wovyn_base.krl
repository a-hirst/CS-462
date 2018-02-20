ruleset wovyn_base {
  
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

      send_directive("heartbeat", {"attrs": wovyn_data});
    }
  }
  
}
