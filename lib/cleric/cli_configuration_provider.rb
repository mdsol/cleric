module Cleric
  class CLIConfigurationProvider
    # Returns GitHub credentials.
    # @return [Hash] Hash of credentials, e.g. `{ login: 'me', password: 'secret'}`
    def github_credentials
      $stdout.print "GitHub login: "
      login = $stdin.readline.chomp
      $stdout.print "GitHub password: "
      password = $stdin.readline.chomp
      { login: login, password: password }
    end
  end
end
