ruleset use_twilio {
  meta {
    use module keys
    use module twilio
        with account_sid = keys:twilio{"account_sid"}
             auth_token =  keys:twilio{"auth_token"}
  }
 
  rule test_send_sms {
    select when test new_message

    twilio:send_sms(event:attr("to"),
                    event:attr("from"),
                    event:attr("message")
                   )
  }
  
  rule get_sms_logs {
    select when test message_logs
    
    pre {
    logs = twilio:messages(event:attr("to"),
                    event:attr("from"))
    }
    send_directive("logs", {"sms": logs})
  }
}

