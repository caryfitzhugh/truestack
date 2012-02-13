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
        ActiveRecord::Base.connection_pool.with_connection do
          @collector_record = CollectorWorker.find_or_create_by_url(@url.to_s)
          @collector_record.save!
        end
      end

      def start
        Rails.logger.info "Starting collector..."
        EventMachine.run do
          at_exit do
            Rails.logger.info "Shutting down collector..."
            ActiveRecord::Base.connection_pool.disconnect!
            Rails.logger.info "Shutting down active record connection."
          end
          Rails.logger.info "Starting collector on #{@url.host} #{@url.port}"
          EventMachine::WebSocket.start(:protocols=>PROTOCOLS.keys, :host => @url.host, :port => @url.port) do |ws|
            ws.onopen     { self.onopen(ws) }
            ws.onclose    { self.onclose(ws) }
            ws.onmessage  {|msg| self.onmessage(ws, msg) }
            ws.onerror    {|e|   self.onerror(ws, e) }
          end

          EventMachine.add_periodic_timer(30) { self.heartbeat }
        end
      end

      def onopen(ws)
        Rails.logger.info "Connection requested..."
        @collector_record.connection_count += 1
        ActiveRecord::Base.connection_pool.with_connection do
        end
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
      end
      def onclose(ws)
        @collector_record.connection_count -= 1
        Rails.logger.info "Connection closed"
      end
      def onerror(ws, e)
        Rails.logger.error "Error: #{e}"
        pp e
        pp e.backtrace.first

      end
      def onmessage(ws, msg)
        Rails.logger.info "Recieved message: #{msg} - push into Cassandra storage"

      end

      def heartbeat
        Rails.logger.info "Heartbeat."
        ActiveRecord::Base.connection_pool.with_connection do
          @collector_record.updated_at = Time.now
          @collector_record.save!
        end
      end

      private

      def validate_request!(ws)
        req_key   = ws.request['truestack-access-key'];
        req_nonce = ws.request['truestack-access-nonce'];
        req_token = ws.request['truestack-access-token'];

        # Nonce must be 32+ chars and a-f0-9
        if req_nonce =~ /^[0-9a-f]{31}[0-9a-f]+$/
          access_token = nil
          ActiveRecord::Base.connection_pool.with_connection do
            access_token = AccessToken.where(key: req_key).first
          end

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
          ActiveRecord::Base.connection_pool.with_connection do

          end
        }
      }
    end
  end
end
