require 'forwardable'
require 'faraday'
require 'base64'
require 'concurrent'

module FakeSNS
  # Delivers messages to the correct target
  class DeliverMessage
    extend Forwardable

    def self.call(options)
      new(options).call
    end

    attr_reader :subscription, :message, :config, :request, :signing_url

    def_delegators :subscription, :protocol, :endpoint, :arn

    def initialize(options)
      @subscription = options.fetch(:subscription)
      @message = options.fetch(:message)
      @request = options.fetch(:request)
      @config = options.fetch(:config)
      @signing_url = options.fetch(:signing_url, '')
    end

    def call
      method_name = protocol.tr('-', '_')

      unless protected_methods.map(&:to_s).include?(method_name)
        raise InvalidParameterValue, "Protocol #{protocol} not supported"
      end

      send(method_name)
    end

    protected

    def sqs
      queue_name = endpoint.split(':').last
      sqs = Aws::SQS::Client.new(
        region: config.fetch('region'),
        credentials: Aws::Credentials.new(config.fetch('access_key_id'), config.fetch('secret_access_key'))
      ).tap do |client|
        client.config.endpoint = URI(config.fetch('sqs_endpoint'))
      end
      queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url
      sqs.send_message(queue_url: queue_url, message_body: message_contents)
    end

    def http
      http_or_https
    end

    def https
      http_or_https
    end

    def email
      pending
    end

    def email_json
      pending
    end

    def sms
      pending
    end

    def application
      pending
    end

    private

    def message_contents
      message.message_for_protocol protocol
    end

    def pending
      puts "Not sending to subscription #{arn}, because protocol #{protocol} has no fake implementation. Message: #{message.id} - #{message_contents.inspect}"
    end

    def http_or_https
      $log.info(self.to_s) { "Notifying endpoint '#{endpoint}'" }
      $log.debug(self.to_s) { "Sending #{message.attributes}" }

      promise = Concurrent::Promise.execute do
        Faraday.new.post(endpoint) do |f|
          begin
            f.body = {
                'Type'             => message.type,
                'MessageId'        => message.id,
                'TopicArn'         => message.topic_arn,
                'Subject'          => message.subject,
                'Message'          => message_contents,
                'Timestamp'        => message.timestamp,
                'SignatureVersion' => '1',
                'Signature'        => Base64.strict_encode64(message.signature),
                'SigningCertURL'   => signing_url,
                'UnsubscribeURL'   => '', # TODO: url to unsubscribe URL on this server
            }.to_json

            f.headers = {
                'x-amz-sns-message-type'     => 'Notification',
                'x-amz-sns-message-id'       => message.id,
                'x-amz-sns-topic-arn'        => message.topic_arn,
                'x-amz-sns-subscription-arn' => arn,
                'Content-Type'               => 'application/json'
            }
          rescue Faraday::Error => e
            $log.fatal(self.to_s) do
              err = <<-ERR
                Failed to notify endpoint '#{endpoint}'. 
                  Status: #{e.response.status}
                  Reason: #{e.response.reason_phrase}
              ERR
              err.strip
            end
            $log.fatal(self.to_s) { "Not sent: #{message}" }
          end
        end
      end.then do
        $log.info(self.to_s) { "Notified endpoint '#{endpoint}'" }
        $log.debug(self.to_s) { "Sent #{message}" }
      end.rescue do |e|
        $log.fatal(e)
      end

      promise.value unless FakeSNS::ASYNC
    end
  end
end
