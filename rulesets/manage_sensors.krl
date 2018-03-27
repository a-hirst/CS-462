ruleset manage_sensors {
  
  meta {
    use module io.picolabs.wrangler alias Wrangler
    
    provides sensors, aggregated_temperatures
    shares sensors, aggregated_temperatures
  }
  
  global {
    temperature_threshold = 80
    sensors = function() {
      ent:sensors.defaultsTo({}) 
    }
    
    aggregated_temperatures = function() {
      ent:sensors.map(function(v, k) {
        Wrangler:skyQuery(v,"temperature_store","temperatures",{}).klog("value" + k);
      })
    }
  }

  rule handle_new_sensor {
    select when sensor new_sensor
    pre {
      name = event:attr("name")
      exists = ent:sensors.defaultsTo({}) >< name
      // eci = meta:eci
    } 
    if not exists then
      noop();
    fired {
      raise wrangler event "child_creation"
      attributes { "name": name,
                   "smsNum": event:attr("smsNum"),
                    "rids": ["temperature_store", "wovyn_base", "sensor_profile"]
      }
    }
  }
  
  rule initialize_new_sensor {
    select when wrangler child_initialized
    pre {
      sensor_eci = event:attr("eci").klog("eci")
      sensor_id = event:attr("id")
      // the_section = {"id": event:attr("id"), "eci": event:attr("eci")}
      name = event:attr("rs_attrs"){"name"}
      smsNum = event:attr("rs_attrs"){"smsNum"}
      sensor_attrs = {
        "tempThreshold": temperature_threshold,
        "sensorName": name,
        "smsNum": smsNum
      }
    }
    if name.klog("found name")
    then
      event:send({"eci":sensor_eci, "domain":"sensor", 
          "type":"profile_updated", "attrs":sensor_attrs});
    fired {
      ent:sensors := ent:sensors.defaultsTo({}).klog("sensors");
      ent:sensors{[name]} := sensor_eci
      
    }
  }
  
  rule remove_sensor {
    select when sensor unneeded_sensor
    pre {
      name = event:attr("name")
      exists = ent:sensors.defaultsTo({}) >< name
    }
    if exists then
      send_directive("deleting_sensor", {"name":name})
    fired {
      raise wrangler event "child_deletion"
        attributes {"name": name};
      clear ent:sensors{[name]}
    }
  }
  
  /*rule pico_ruleset_added {
    select when pico ruleset_added where rid == meta:rid
    pre {
      name = event:attr("name").klog("new pico name")
    }
    always {
      ent:section_id := section_id
    }
  }*/
}
