require 'spec_helper'

module Cleric

  describe ConsoleAnnouncer do
    subject(:announcer) { ConsoleAnnouncer.new(io) }
    let(:io) { mock('IO') }

    describe '#initialize' do
      it 'takes an IO object' do
        ConsoleAnnouncer.new($stdout)
      end
    end

    describe '#successful_action' do
      it 'sends the message to the configured IO object' do
        io.should_receive(:puts).with(ANSI::Code.green { 'hello' })
        announcer.successful_action('hello')
      end
    end
  end
end
