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
    it 'has an audit command' do
      cli_help.should include('cleric repo audit <name>')
    end
    it 'has a create command' do
      cli_help.should include('cleric repo create <name>')
    end
    it 'has an update command' do
      cli_help.should include('cleric repo update <name>')
    end
  end

  context 'under the "user" command' do
    let(:cli_command) { 'user' }
    it 'has a welcome command' do
      cli_help.should include('cleric user welcome <github-username>')
    end
    it 'has a remove command' do
      cli_help.should include('cleric user remove <email>')
    end
  end
end

module Cleric
  describe CLI do
    let(:config) { double('Config') }
    let(:agent) { double('GitHub').as_null_object }
    let(:console) { double(ConsoleAnnouncer) }
    let(:hipchat) { double(HipChatAnnouncer) }

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
        HipChatAnnouncer.should_receive(:new).with(config, console, agent.login)
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
        let(:manager) { double(RepoManager).as_null_object }

        before(:each) do
          RepoManager.stub(:new) { manager }
          repo.options = { team: '1234', chatroom: 'my_room' }
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

      describe '#audit' do
        let(:auditor) { double(RepoAuditor).as_null_object }

        before(:each) { RepoAuditor.stub(:new) { auditor } }
        after(:each) { repo.audit('my/repo') }

        it 'creates a console announcer' do
          ConsoleAnnouncer.should_receive(:new).with($stdout)
        end
        it 'creates a configured repo auditor' do
          RepoAuditor.should_receive(:new).with(config, console)
        end
        it 'delegates to the auditor' do
          auditor.should_receive(:audit_repo).with('my/repo')
        end
      end

      describe '#update' do
        let(:name) { 'example_name' }
        let(:manager) { double(RepoManager).as_null_object }
        let(:options) { { chatroom: 'my_room' } }

        before(:each) do
          RepoManager.stub(:new) { manager }
          repo.options = options
        end

        after(:each) { repo.update(name) }

        include_examples :github_agent_user
        include_examples :announcers
        it 'creates a repo manager configured with the agent' do
          RepoManager.should_receive(:new).with(agent, hipchat)
        end
        it 'delegates creation to the manager' do
          manager.should_receive(:update).with(name, hash_including(chatroom: 'my_room'))
        end

        context 'when given a team option' do
          let(:options) { { chatroom: 'my_room', team: '1234' } }

          it 'delegates creation to the manager' do
            manager.should_receive(:update).with(name, hash_including(team: '1234'))
          end
        end
      end
    end

    describe User do
      subject(:user) { Cleric::User.new }
      let(:manager) { double(UserManager).as_null_object }

      before(:each) do
        UserManager.stub(:new) { manager }
      end

      shared_examples :creates_user_manager do
        it 'creates a user manager configured with the agent' do
          UserManager.should_receive(:new).with(config, hipchat)
        end
      end

      describe '#create' do
        before(:each) { user.options = { team: '1234', email: 'me@example.com' } }
        after(:each) { user.welcome('a_username') }

        include_examples :announcers
        include_examples :creates_user_manager
        it 'delegates welcome to the manager' do
          manager.should_receive(:welcome).with('a_username', 'me@example.com', '1234')
        end
      end

      describe '#remove' do
        after(:each) { user.remove('a_user@example.com', 'an_org') }

        include_examples :announcers
        include_examples :creates_user_manager
        it 'delegates removal to the manager' do
          manager.should_receive(:remove).with('a_user@example.com', 'an_org')
        end
      end
    end
  end
end
