ruleset wovyn_base {
  
  rule process_heartbeat {
    select when wovyn heartbeat
    pre {
      wovyn_data = event:attrs().klog("attrs");
    }
    send_directive("heartbeat", {"attrs": wovyn_data});
  }
}
