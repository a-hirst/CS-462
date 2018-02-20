ruleset wovyn_base {
  
  rule process_heartbeat {
    select when wovyn heartbeat where genericThing.match(re#[^\0]#)
    pre {
      wovyn_data = event:attrs.klog("attrs");
    }
    send_directive("heartbeat", {"attrs": wovyn_data});
  }
  
  rule process_heartbeat2 {
    select when wovyn heartbeat genericThing re#[^\0]#
    pre {
      wovyn_data = event:attrs.klog("attrs");
    }
    send_directive("heartbeat", {"attrs": wovyn_data});
  }
  
  rule process_heartbeat3 {
    select when wovyn heartbeat
    pre {
      wovyn_data = event:attrs.klog("attrs");
      generic = event:attr("genericThing").klog("generic");
      
    }
    if event:attr("genericThing").isnull() == false then
    send_directive("heartbeat", {"attrs": wovyn_data});
  }
}
