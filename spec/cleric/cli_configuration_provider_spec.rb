require 'spec_helper'

module Cleric
  describe CLIConfigurationProvider do
    describe '#github_credentials' do
      it 'prompts for username and password' do
        $stdin.stub(:readline).and_return("me\n", "secret\n")
        subject.github_credentials.should == { login: 'me', password: 'secret' }
      end
    end
  end
end
