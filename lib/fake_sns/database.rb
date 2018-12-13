require 'etc'
require 'aws-sdk'
require 'pp'

module FakeSNS
  # YAML DB
  class Database
    attr_reader :database_filename

    def initialize(database_filename)
      @database_filename = database_filename || File.join(Dir.home, '.fake_sns.yml')
    end

    def perform(action, params)
      action_instance = action_provider(action).new(self, params)
      action_instance.call
      Response.new(action_instance)
    end

    def topics
      @topics ||= TopicCollection.new(store)
    end

    def subscriptions
      @subscriptions ||= SubscriptionCollection.new(store)
    end

    def messages
      @messages ||= MessageCollection.new(store)
    end

    def reset
      topics.reset
      subscriptions.reset
      messages.reset
    end

    def transaction
      store.transaction do
        yield
      end
    end

    def abort
      store.abort
    end

    def replace(data)
      store.replace(data)
    end

    def to_yaml
      store.to_yaml
    end

    def each_deliverable_message
      topics.each do |topic|
        subscriptions.each do |subscription|
          messages.each do |message|
            next unless message.for?(subscription, topic)
            yield subscription, message
          end
        end
      end
    end

    private

    def store
      @store ||= Storage.for(database_filename)
    end

    def action_provider(action)
      Actions.const_get(action)
    rescue NameError
      raise InvalidAction, "not implemented: #{action}"
    end
  end
end
