ruleset wovyn_base {
  
  rule process_heartbeat {
    select when wovyn heartbeat genericThing re#[^\0]#
    pre {
      wovyn_data = event:attrs.klog("attrs");
      genericThing = event:attr("genericThing").klog("generic");
    }
    send_directive("heartbeat", {"attrs": wovyn_data});
  }
  
}
