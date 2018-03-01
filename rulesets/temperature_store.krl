ruleset temperature_store {
  
  meta {
    
    provides temperatures, threshold_violations, inrange_temperatures
    shares temperatures, threshold_violations, inrange_temperatures
  }
  
  
  global {
    temperatures = function() {
      ent:temperatures
    }
    threshold_violations = function() {
      ent:threshold_violations
    }
    inrange_temperatures = function() {
      ent:temperatures.filter(function(x) {
        not (ent:threshold_violations >< x)
      })
    }  
  
  }
  
    rule intialization {
      select when wrangler ruleset_added where rids >< meta:rid
      fired {
        ent:temperatures := [];
        ent:threshold_violations := [];
      }
    }
  
  rule collect_temperatures {
    select when wovyn new_temperature_reading
    pre {
      val = event:attrs.klog("temp attrs")
      thing = ent:temperatures.klog("entity var")
    }
    fired {
      ent:temperatures := ent:temperatures.append([event:attrs])
    }
  }
  
  rule collect_threshold_violations {
    select when wovyn threshold_violation
    fired {
      ent:threshold_violations := ent:threshold_violations.append([event:attrs])
    }
  }
  
  rule clear_tempeartures {
    select when sensor reading_reset
    fired {
      ent:temperatures := [];
      ent:threshold_violations := [];
    }
  }
}
