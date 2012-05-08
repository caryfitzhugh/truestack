module Truestack
  module Workers
    class Collector
      class ValidationException < Exception; end

      def self.start(url)
        @collector = Truestack::Workers::Collector.new(url)
        @collector.start
      end


      def initialize(url)
        @url = URI.parse(url)
        @collector_record = CollectorWorker.where(url: @url).first
        if (!@collector_record)
          @collector_record = CollectorWorker.new(url: @url)
          @collector_record.save!
        end
      end

      def start
        EventMachine.run do
          at_exit do
            Rails.logger.info "Shutting down collector..."
          end

          Rails.logger.info "Starting collector on #{@url.host} #{@url.port}"
          EventMachine::WebSocket.start(:host => @url.host, :port => @url.port) do |ws|
            access_token = nil

            messages = []
            process_messages = lambda do
              while !messages.empty?
                queued_message = messages.pop
                message = ActiveSupport::JSON.decode(queued_message).symbolize_keys rescue {}


                app = access_token.user_application

                #  request:
                #    name: controller#action
                #    request_id:  (unique token)
                #    actions: [
                #      {    type => controller | model | helper | view | browser | lib
                #           tstart
                #           tend
                #           name: klass#method
                #      }
                #    ]
                if (message[:type] == 'request')
                  name  = message.delete(:name)
                  actions = message.delete(:actions)
                  Rails.logger.info "Adding request: #{name} #{actions.to_yaml}"
                  app.add_request(name, actions)
                  Rails.logger.info "Added request: #{name}"

                # Exception:
                # websocket_or_http.write_data(JSON.generate({
                #                   :type => :exception,
                #                   :request_name=>action_name,
                #                   :exception_name => e.to_s,
                #                   :tstart => start_time,
                #                   :backtrace => e.backtrace,
                #                   :env => request.env
                #                  }))
                elsif (message[:type] == 'exception')
                  req_name = message.delete(:request_name)
                  name     = message.delete(:exception_name)
                  backtrace= message.delete(:backtrace) || []
                  tstart   = Time.parse(params.delete(:tstart))     rescue Time.now
                  env      = message.delete(:env)       || {}
                  Rails.logger.info "Adding exception: #{name} #{req_name}"
                  app.add_exception(req_name, name, tstart, backtrace, env)
                  Rails.logger.info "Added exception!"

                elsif (message[:type] == 'startup')
                  tstart = message.delete(:tstart)
                  host_id   = message.delete(:host_id)
                  commit_id  = message.delete(:commit_id)
                  methods= message.delete(:methods)
                  ::Rails.logger.info "Adding startup"
                  app.add_startup(tstart, host_id, commit_id, methods)
                  ::Rails.logger.info "Added startup"

                elsif (message[:type] == 'metric')
                  tstart = message.delete(:tstart)
                  name   = message.delete(:name)
                  value  = message.delete(:value)
                  meta_data = message.delete(:meta_data)
                  ::Rails.logger.info "Adding metric"
                  app.add_metric(tstart, name, value, meta_data)
                  ::Rails.logger.info "Added metric"
                end
              end
            end

            ws.onopen     {
              @collector_record.connection_count += 1

              begin
                access_token = validate_request!(ws)
                Rails.logger.info "Connection accepted."
                process_messages.call
              rescue ValidationException => e
                Rails.logger.error "Rejected connection, validation error: #{e}"
                ws.close_websocket(4000, "Error: #{e}")
              rescue Exception => e
                Rails.logger.error e
                Rails.logger.error e.backtrace
                raise e
              end
            }

            ws.onclose    {
              @collector_record.connection_count -= 1
              Rails.logger.info "Connection closed"
            }

            ws.onmessage  {|msg|
              Rails.logger.info "Recieved message: [#{msg}]"
              messages << msg
              # If we're still looking up the access token, then queue this
              # until we are connected
              if (access_token)
                process_messages.call
              else
                Rails.logger.info "no access_tokens yet!"
              end
            }

            ws.onerror    {|e|
              Rails.logger.error "Error: #{e}"
              pp e
              pp e.backtrace.first
            }
          end

          EventMachine.add_periodic_timer(30) { self.heartbeat }
        end
      end

      def heartbeat
        @collector_record.updated_at = Time.now
        # Saves connection count
        @collector_record.save!
      end

      private

      def validate_request!(ws)
        req_key   = ws.request['truestack-access-key'];

        access_token = AccessToken.where(key: req_key).limit(1).first

        if access_token
          access_token
        else
          raise ValidationException.new "Invalid access key"
        end
      end
    end
  end
end
