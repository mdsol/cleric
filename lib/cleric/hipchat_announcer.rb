module Cleric
  class HipChatAnnouncer
    def initialize(config, listener)
      @config = config
      @listener = listener
    end

    # Announces the successful completion of an action to the configured
    # HipChat room.
    #
    # @param description [String] Description of the action completed.
    def successful_action(description)
      @listener.successful_action(description)
      hipchat.rooms_message(
        @config.hipchat_announcement_room_id, 'Cleric', description, 0, 'green', 'text'
      )
    end

    private

    def hipchat
      @hipchat ||= HipChat::API.new(@config.hipchat_api_token)
    end
  end
end
