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

                app = access_token.user_application

                if (message[:type] == 'request')
                  name  = message.delete(:name)
                  request_id  = message.delete(:request_id)
                  actions = message.delete(:actions)
                  Rails.logger.info "Adding request: #{name} #{request_id} #{actions.to_yaml}"
                  app.add_request(name, request_id, actions)
                  Rails.logger.info "Added request: #{name}"
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
