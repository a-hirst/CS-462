ruleset wovyn_base {
  
  rule process_heartbeat {
    select when wovyn heartbeat where genericThing.match(re#/.+#)
    pre {
      wovyn_data = event:attrs.klog("attrs");
    }
    send_directive("heartbeat", {"attrs": wovyn_data});
  }
}
