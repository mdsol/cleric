module Cleric
  class ConsoleAnnouncer
    include ANSI::Code

    def initialize(io)
      @io = io
    end

    # Announces the successful completion of an action to the configured
    # IO object.
    #
    # @param description [String] Description of the action completed.
    def successful_action(description)
      @io.puts(green { description })
    end
  end
end
