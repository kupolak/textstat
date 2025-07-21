lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'textstat/version'

Gem::Specification.new do |spec|
  spec.name          = 'textstat'
  spec.version       = TextStat::VERSION
  spec.authors       = ['Jakub Polak']
  spec.email         = ['jakub.polak.vz@gmail.com']

  spec.summary       = 'Ruby gem to calculate readability statistics of a text object - paragraphs, sentences, articles'
  spec.homepage      = 'https://github.com/kupolak/textstat'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/kupolak/textstat'
    spec.metadata['rubygems_mfa_required'] = 'true'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Include all library files and all dictionary files
  spec.files         = Dir['lib/**/*.rb', 'lib/dictionaries/*.txt']

  # Runtime dependencies - required for gem functionality
  spec.add_dependency 'text-hyphen', '~> 1.4.1'

  # Development dependencies - required for development and building
  spec.add_development_dependency 'bundler', '>= 2.0'
  spec.add_development_dependency 'rake', '~> 13.3'

  # Testing dependencies
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'simplecov-lcov', '~> 0.8'

  # Code quality and linting - version specific
  if RUBY_VERSION >= '3.0.0'
    spec.add_development_dependency 'rubocop', '~> 1.69'
    spec.add_development_dependency 'rubocop-performance', '~> 1.23'
    spec.add_development_dependency 'rubocop-rake', '~> 0.6'
    spec.add_development_dependency 'rubocop-rspec', '~> 2.31'
  else
    # Fallback for Ruby 2.7
    spec.add_development_dependency 'rubocop', '~> 1.57'
    spec.add_development_dependency 'rubocop-performance', '~> 1.19'
    spec.add_development_dependency 'rubocop-rake', '~> 0.6'
    spec.add_development_dependency 'rubocop-rspec', '~> 2.20'
  end
  spec.add_development_dependency 'rubocop-thread_safety', '~> 0.6'

  # Documentation generation
  spec.add_development_dependency 'redcarpet', '~> 3.6'
  spec.add_development_dependency 'yard', '~> 0.9'

  # Performance and benchmarking
  spec.add_development_dependency 'benchmark-ips', '~> 2.14'

  # Memory profiler only for Ruby 3.1+
  spec.add_development_dependency 'memory_profiler', '~> 1.1' if RUBY_VERSION >= '3.1.0'

  # Security auditing
  spec.add_development_dependency 'bundler-audit', '~> 0.9'

  # Brakeman only for Ruby 3.0+
  if RUBY_VERSION >= '3.0.0'
    spec.add_development_dependency 'brakeman', '~> 7.1'
  else
    # Fallback for Ruby 2.7
    spec.add_development_dependency 'brakeman', '~> 7.1'
  end
end
