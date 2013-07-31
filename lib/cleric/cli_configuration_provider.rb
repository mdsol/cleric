module Cleric
  class CLIConfigurationProvider
    def initialize(filename = File.expand_path('~/.clericrc'))
      @filename = filename
    end

    # Returns GitHub credentials.
    # @return [Hash] Hash of credentials, e.g. `{ login: 'me', password: 'secret'}`
    def github_credentials
      if github = config['github']
        { login: github['login'], oauth_token: github['oauth_token'] }
      else
        { login: ask("GitHub login"), password: ask("GitHub password", silent: true) }
      end
    end

    # Saves the GitHub credentials.
    # @param values [Hash] Hash of credentials, e.g. `{ login: 'me', oauth_token: 'abc123'}`
    def github_credentials=(values)
      config['github'] = { 'login' => values[:login], 'oauth_token' => values[:oauth_token] }
      File.open(@filename, 'w') {|file| file.write(YAML::dump(config)) }
    end

    # Returns HipChat announcement room id.
    # @return [String] The room id, either numeric or the room name.
    def hipchat_announcement_room_id
      config['hipchat']['announcement_room_id']
    end

    # Returns HipChat API token.
    # @return [String] The API token.
    def hipchat_api_token
      config['hipchat']['api_token']
    end

    # Returns repo HipChat API token, i.e. for notifications from repos to
    # chatrooms.
    # @return [String] The API token.
    def hipchat_repo_api_token
      config['hipchat']['repo_api_token']
    end

    # Returns a configured repo agent.
    # @return [GitHubAgent] A GitHub repo agent.
    def repo_agent
      @repo_agent ||= GitHubAgent.new(self)
    end

    private

    def ask(prompt, options={})
      $stdout.print "#{prompt}: "
      if options[:silent]
        require 'io/console'
        $stdin.noecho {|io| io.readline}
      else
        $stdin.readline
      end.chomp
    end

    def config
      @config ||= load_config
    end

    def load_config
      File.exists?(@filename) ? YAML::load(File.open(@filename)) : {}
    end
  end
end
