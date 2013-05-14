require 'spec_helper'

describe 'Command line' do
  let(:cli_command) { '' }
  let(:cli_help) { `./bin/cleric #{cli_command}` }

  context 'when invoked without arguments' do
    it 'shows the available commands' do
      cli_help.should include('cleric help [COMMAND]')
    end
  end

  it 'has a "repo [COMMAND]" command' do
    cli_help.should include('cleric repo [COMMAND]')
  end

  context 'under the "repo" command' do
    let(:cli_command) { 'repo' }
    it 'has a "create <name>" command' do
      cli_help.should include('cleric repo create <name>')
    end
  end
end

module Cleric
  describe Repo do
    describe '#create' do
      let(:name) { 'example_name' }
      let(:config) { mock(CLIConfigurationProvider) }
      let(:agent) { mock(GitHubAgent) }
      let(:manager) { mock(RepoManager).as_null_object }

      before(:each) do
        CLIConfigurationProvider.stub(:new) { config }
        GitHubAgent.stub(:new) { agent }
        RepoManager.stub(:new) { manager }
        subject.stub_chain(:options, :[]) { '1234' }
      end
      after(:each) { subject.create(name) }

      it 'creates a configured GitHub agent' do
        GitHubAgent.should_receive(:new).with(config)
      end
      it 'creates a repo manager configured with the agent' do
        RepoManager.should_receive(:new).with(agent)
      end
      it 'delegates creation to the manager' do
        manager.should_receive(:create).with(name, '1234')
      end
    end
  end
end
