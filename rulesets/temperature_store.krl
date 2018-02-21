ruleset temperature_store {
   
  rule collect_temperatures {
    select when wovyn new_temperature_reading
    fired {
      ent:temperatures.defaultsTo([]).append(event:attrs)
    }
  }
  
  rule collect_threshold_violations {
    select when wovyn threshold_violation
    fired {
      ent:threshold_violations.defaultsTo([]).append(event:attrs)
    }
  }
  
  rule clear_tempeartures {
    select when sensor reading_reset
    fired {
      clear ent:temperatures;
      clear ent:threshold_violations;
    }
  }
}
