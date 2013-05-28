require File.expand_path('../lib/cleric/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'cleric'
  s.version = Cleric::VERSION
  s.platform = Gem::Platform::RUBY

  s.authors = ['Andrew Smith']
  s.email = ['asmith@mdsol.com']
  s.summary = 'Administration tools for the lazy software development manager.'
  s.homepage = 'https://github.com/mdsol/cleric'

  s.files = Dir['lib/**/*']
  s.test_files = Dir['spec/**/*']
  s.executables = Dir['bin/*'].map {|f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'ansi', '~> 1.4'
  s.add_dependency 'hipchat-api', '~> 1.0'
  s.add_dependency 'octokit', '~> 1.24'
  s.add_dependency 'thor', '~> 0.18'
end
