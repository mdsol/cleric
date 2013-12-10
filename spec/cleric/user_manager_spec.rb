require 'spec_helper'

module Cleric
  describe UserManager do
    subject(:manager) { UserManager.new(config, listener) }
    let(:config) { double('Config', repo_agent: repo_agent).as_null_object }
    let(:listener) { double('Listener') }
    let(:repo_agent) { double('RepoAgent').as_null_object }

    describe '#remove' do
      after(:each) { manager.remove('user@example.com', 'an_org') }

      it 'tells the repo agent to remove the user from the org' do
        repo_agent.should_receive(:remove_user_from_org).with('user@example.com', 'an_org', listener)
      end
    end

    describe '#welcome' do
      after(:each) { manager.welcome('a_user', 'user@example.com', 'a_team') }

      it 'tells the repo agent to verify the user public email address' do
        repo_agent.should_receive(:verify_user_public_email)
          .with('a_user', 'user@example.com', manager)
      end
      it 'tells the repo agent to add the user to the team' do
        repo_agent.should_receive(:add_user_to_team).with('a_user', 'a_team', listener)
      end

      context 'when the email verification fails' do
        before(:each) { repo_agent.stub(:verify_user_public_email) { throw :verification_failed } }

        it 'does not tell the repo agent to add the user to the team' do
          repo_agent.should_not_receive(:add_user_to_team)
        end
      end
    end

    describe '#verify_user_public_email_failure' do
      it 'raises an throws a verification failure' do
        expect { manager.verify_user_public_email_failure }.to throw_symbol(:verification_failed)
      end
    end
  end
end
