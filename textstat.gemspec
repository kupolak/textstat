
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "textstat/version"

Gem::Specification.new do |spec|
  spec.name          = "textstat"
  spec.version       = TextStat::VERSION
  spec.authors       = ["Jakub Polak"]
  spec.email         = ["jakub.polak.vz@gmail.com"]

  spec.summary       = %q{Ruby gem to calculate readability statistics of a text object - paragraphs, sentences, articles}
  spec.homepage      = "https://github.com/kupolak/textstat"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/kupolak/textstat"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.files         = Dir['lib/**/*.rb', 'lib/dictionaries/*.txt']
  spec.test_files    = ["spec/textstat_spec.rb", "lib/dictionaries/en_us.txt"]

  spec.add_runtime_dependency     "text-hyphen", "~> 1.4", ">= 1.4.1"
  spec.add_development_dependency "bundler", "~> 2.0.a"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
