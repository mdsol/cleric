require 'spec_helper'

module Cleric
  describe RepoAuditor do
    subject(:auditor) { RepoAuditor.new(config, listener) }
    let(:config) { double('Config', repo_agent: agent).as_null_object }
    let(:listener) { double('Listener').as_null_object }
    let(:agent) { double('Agent', repo_pull_request_ranges: ranges).as_null_object }
    let(:ranges) { [{ base: 'b', head: 'd' }, { base: 'f', head: 'h' }] }
    let(:client) { double('Client', log: log).as_null_object }
    let(:log) { ('a'..'i').map {|sha| double('LogEntry', sha: sha, parents: ['z']) } }

    describe '#audit_repo' do
      before(:each) do
        Git.stub(:open) { client }
        log.stub(:between) do |from, to|
          (from..to).map {|sha| double('LogEntry', sha: sha) }
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
      it 'notifies the listener that latest changes are being fetched' do
        listener.should_receive(:repo_fetching_latest_changes)
      end
      it 'fetches the latest changes for the local repo' do
        client.should_receive(:fetch)
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

      context 'when a given range no longer exists in the local repo' do
        let(:ranges) { [{ base: 'p', head: 'q', pr_number: '123' }, { base: 'a', head: 'i' }] }

        before(:each) do
          log.stub(:between).with('p', 'q') { raise 'git log error' }
        end

        it 'notifies the listener of an obsolete range' do
          listener.should_receive(:repo_obsolete_pull_request).with('123', 'p', 'q')
        end
        it 'continues execution normally' do
          listener.should_receive(:repo_audit_passed).with('my/repo')
        end
      end
    end
  end
end
