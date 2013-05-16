require 'spec_helper'

describe 'Command line' do
  let(:cli_command) { '' }
  let(:cli_help) { `./bin/cleric #{cli_command}` }

  context 'when invoked without arguments' do
    it 'shows the available commands' do
      cli_help.should include('cleric help [COMMAND]')
    end
  end

  it 'has a "auth" command' do
    cli_help.should include('cleric auth')
  end
  it 'has a "repo [COMMAND]" command' do
    cli_help.should include('cleric repo [COMMAND]')
  end
  it 'has a "user [COMMAND]" command' do
    cli_help.should include('cleric user [COMMAND]')
  end

  context 'under the "repo" command' do
    let(:cli_command) { 'repo' }
    it 'has a "create <name>" command' do
      cli_help.should include('cleric repo create <name>')
    end
  end

  context 'under the "user" command' do
    let(:cli_command) { 'user' }
    it 'has a "welcome <github-username>" command' do
      cli_help.should include('cleric user welcome <github-username>')
    end
  end
end

module Cleric
  describe CLI do
    def stub_options_for(obj, options)
      # Thor classes access their options through the `option` method so the
      # only option (pun intended) is to mock as follows.
      obj.stub_chain(:options, :[]) { |opt| options[opt] }
    end

    let(:config) { mock('Config') }
    let(:agent) { mock('GitHub').as_null_object }
    let(:console) { mock(ConsoleAnnouncer) }
    let(:hipchat) { mock(HipChatAnnouncer) }

    before(:each) do
      CLIConfigurationProvider.stub(:new) { config }
      GitHubAgent.stub(:new) { agent }
      ConsoleAnnouncer.stub(:new) { console }
      HipChatAnnouncer.stub(:new) { hipchat }
    end

    shared_examples :github_agent_user do
      it 'creates a configured GitHub agent' do
        GitHubAgent.should_receive(:new).with(config)
      end
    end

    shared_examples :announcers do
      it 'creates a console announcer' do
        ConsoleAnnouncer.should_receive(:new).with($stdout)
      end
      it 'creates a HipChat console decorating the console announcer' do
        HipChatAnnouncer.should_receive(:new).with(config, console)
      end
    end

    describe '#auth' do
      after(:each) { subject.auth }

      include_examples :github_agent_user
      it 'tells the agent to create an authorization token' do
        agent.should_receive(:create_authorization)
      end
    end

    describe Repo do
      subject(:repo) { Cleric::Repo.new }

      describe '#create' do
        let(:name) { 'example_name' }
        let(:manager) { mock(RepoManager).as_null_object }

        before(:each) do
          RepoManager.stub(:new) { manager }
          stub_options_for(repo, team: '1234', chatroom: 'my_room')
        end

        after(:each) { repo.create(name) }

        include_examples :github_agent_user
        include_examples :announcers
        it 'creates a repo manager configured with the agent' do
          RepoManager.should_receive(:new).with(agent, hipchat)
        end
        it 'delegates creation to the manager' do
          manager.should_receive(:create).with(name, '1234', hash_including(chatroom: 'my_room'))
        end
      end
    end

    describe User do
      subject(:user) { Cleric::User.new }

      describe '#create' do
        let(:username) { 'my_github_username' }
        let(:manager) { mock(UserManager).as_null_object }

        before(:each) do
          UserManager.stub(:new) { manager }
          stub_options_for(user, team: '1234', email: 'me@example.com')
        end

        after(:each) { user.welcome(username) }

        include_examples :announcers
        it 'creates a user manager configured with the agent' do
          UserManager.should_receive(:new).with(config, hipchat)
        end
        it 'delegates creation to the manager' do
          manager.should_receive(:welcome).with(username, 'me@example.com', '1234')
        end
      end
    end
  end
end
