ruleset use_twilio {
  meta {
    use module keys
    use module twilio
        with account_sid = keys:twilio{"account_sid"}
             auth_token =  keys:twilio{"auth_token"}
  }
 
  rule test_send_sms {
    select when test new_message
    
    pre {
      name = event:attr("to").klog("our passed in to: ") ;
      thing = event:attr("from").klog("our passed in from: ") ;
      that = event:attr("message").klog("our passed in message: ") ;
      message = (name) => ("Hello " + name) | "Hello Monkey"
    }
    twilio:send_sms(event:attr("to"),
                    event:attr("from"),
                    event:attr("message")
                   )
  }
}
