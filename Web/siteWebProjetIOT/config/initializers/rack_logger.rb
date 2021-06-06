module Rails
    module Rack
        class Logger < ActiveSupport::LogSubscriber
            def started_request_message(request)
                'Started %s "%s" for %s at %s' % [
                    request.request_method,
                    request.filtered_path,
                    request.ip.gsub!(/\w/,"x"),
                    Time.now.to_default_s
                ]
            end
        end
    end
end