module Cleric
  class CLIConfigurationProvider
    def initialize(filename = File.expand_path('~/.clericrc'))
      @filename = filename
    end

    # Returns GitHub credentials.
    # @return [Hash] Hash of credentials, e.g. `{ login: 'me', password: 'secret'}`
    def github_credentials
      $stdout.print "GitHub login: "
      login = $stdin.readline.chomp
      $stdout.print "GitHub password: "
      password = $stdin.readline.chomp
      { login: login, password: password }
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

    private

    def config
      @config ||= YAML::load(File.open(@filename))
    end
  end
end
