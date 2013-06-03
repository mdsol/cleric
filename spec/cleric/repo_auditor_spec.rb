require 'spec_helper'

module Cleric
  describe RepoAuditor do
    subject(:auditor) { RepoAuditor.new(config, listener) }
    let(:config) { mock('Config', repo_agent: agent).as_null_object }
    let(:listener) { mock('Listener').as_null_object }
    let(:agent) { mock('Agent', repo_pull_request_ranges: ranges).as_null_object }
    let(:ranges) { [{ base: 'b', head: 'd' }, { base: 'f', head: 'h' }] }
    let(:client) { mock('Client', log: log).as_null_object }
    let(:log) { ('a'..'i').map {|sha| mock('LogEntry', sha: sha, parents: ['z']) } }

    describe '#audit_repo' do
      before(:each) do
        Git.stub(:open) { client }
        log.stub(:between) do |from, to|
          (from..to).map {|sha| mock('LogEntry', sha: sha) }
        end

        # Commits with multiple parents (i.e. merge commits) should be ignored.
        log.first.stub(:parents) { ['x', 'y'] }
      end
      after(:each) { auditor.audit_repo('my/repo') }

      it 'gets the range of commits for all pull requests in the repo via the agent' do
        agent.should_receive(:repo_pull_request_ranges).with('my/repo')
      end
      it 'opens a client for the local repo' do
        Git.should_receive(:open).with('.')
      end
      it 'gets the list of commits in each range from the local repo via the client' do
        # Expecting three log accesses, one for each range and one for all commits.
        client.should_receive(:log).with(nil).at_least(3).times
        log.should_receive(:between).with('b', 'd')
        log.should_receive(:between).with('f', 'h')
      end

      context 'when there are commits outside the given ranges' do
        it 'notifies the listener of non-merge commits not covered by a pull request' do
          listener.should_receive(:commits_without_pull_requests).with('my/repo', ['e', 'i'])
          listener.should_not_receive(:repo_audit_passed)
        end
      end

      context 'when there are no commits outside the given ranges' do
        let(:ranges) { [{ base: 'a', head: 'i' }] }

        it 'notifies the listener that the audit has passed' do
          listener.should_receive(:repo_audit_passed).with('my/repo')
          listener.should_not_receive(:commits_without_pull_requests)
        end
      end
    end
  end
end
