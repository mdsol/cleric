module Cleric
  class ConsoleAnnouncer
    def initialize(io)
      @io = io
    end

    # Announces the successful completion of an action to the configured
    # IO object.
    #
    # @param description [String] Description of the action completed.
    def successful_action(description)
      @io.puts(description)
    end
  end
end
