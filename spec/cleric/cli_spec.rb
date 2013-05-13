require 'spec_helper'

describe 'Command line' do
  context 'when invoked without arguments' do
    it 'shows the available commands' do
      `./bin/cleric`.should include('cleric help [COMMAND]')
    end
  end
end
