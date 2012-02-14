require 'pp'
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
        Rails.logger.info "Starting collector..."
        EventMachine.run do
          at_exit do
            Rails.logger.info "Shutting down collector..."
            Rails.logger.info "Shutting down active record connection."
          end
          Rails.logger.info "Starting collector on #{@url.host} #{@url.port}"
          EventMachine::WebSocket.start(:protocols=>PROTOCOLS.keys, :host => @url.host, :port => @url.port) do |ws|
            ws.onopen     {
              Rails.logger.info "Connection requested..."
              @collector_record.connection_count += 1

              begin
                validate_request!(ws)
                Rails.logger.info "Connection accepted."
              rescue ValidationException => e
                Rails.logger.error "Closed connection, validation error: #{e}"
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
        Rails.logger.info "Heartbeat."
        @collector_record.updated_at = Time.now
        @collector_record.save!
      end

      private

      def validate_request!(ws)
        req_key   = ws.request['truestack-access-key'];
        req_nonce = ws.request['truestack-access-nonce'];
        req_token = ws.request['truestack-access-token'];

        # Nonce must be 32+ chars and a-f0-9
        if req_nonce =~ /^[0-9a-f]{31}[0-9a-f]+$/
          Rails.logger.info "Looking up access token for key: #{req_key}"
          access_token = AccessToken.where(key: req_key).limit(1).first

          if access_token
            if access_token.valid_signature?(req_nonce, req_token)
              true
            else
              raise ValidationException.new "Invalid signature"
            end
          else
            raise ValidationException.new "Invalid token"
          end
        else
          raise ValidationException.new "Invalid Nonce - /[0-9a-f]{32+}/"
        end
      end
      PROTOCOLS = {
        '01282012.client.truestack.com' => lambda {|ws, msg|
          Rails.logger.info "Received #{msg}"

        }
      }
    end
  end
end
