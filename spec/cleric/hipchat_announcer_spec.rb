require 'spec_helper'

module Cleric
  describe HipChatAnnouncer do
    subject(:announcer) { HipChatAnnouncer.new(config, listener) }
    let(:config) { mock('Config', hipchat_api_token: 'api_token', hipchat_announcement_room_id: 'room_id') }
    let(:listener) { mock('Listener').as_null_object }
    let(:hipchat) { mock('HipChat').as_null_object }

    before(:each) { HipChat::API.stub(:new) { hipchat } }

    describe '#initialize' do
      it 'takes a config and a listener' do
        announcer.should be_a(HipChatAnnouncer)
      end
    end

    describe '#successful_action' do
      after(:each) { announcer.successful_action('hello') }

      it 'sends the message to upstream listener' do
        listener.should_receive(:successful_action).with('hello')
      end
      it 'creates a HipChat client' do
        HipChat::API.should_receive(:new).with('api_token')
      end
      it 'sends the message to the configured HipChat room' do
        hipchat.should_receive(:rooms_message)
          .with('room_id', 'Cleric', 'hello', 0, 'green', 'text')
      end
    end
  end
end
