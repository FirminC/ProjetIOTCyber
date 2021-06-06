module ActionCable
    module Connection
        class Base
            def started_request_message
                'Started %s "%s"%s for %s at %s' % [
                    request.request_method,
                    request.filtered_path,
                    websocket.possible? ? " [WebSocket]" : "[non-WebSocket]",
                    request.ip.gsub!(/\w/,"x"),
                    Time.now.to_s 
                ]
            end

            def finished_request_message
                'Finished "%s"%s for %s at %s' % [
                    request.filtered_path,
                    websocket.possible? ? " [WebSocket]" : "[non-WebSocket]",
                    request.ip.gsub!(/\w/,"x"),
                    Time.now.to_s
                ]
            end
        end
    end
end