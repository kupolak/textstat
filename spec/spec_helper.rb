# SimpleCov configuration - must be loaded before any application code
require 'simplecov'
require 'simplecov-lcov'

# Configure SimpleCov for comprehensive code coverage analysis
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
]

SimpleCov.start do
  # Coverage tracking configuration
  add_filter '/spec/'          # Exclude test files
  add_filter '/vendor/'        # Exclude vendor dependencies
  add_filter 'lib/textstat/version.rb' # Exclude version file (constants only)

  # Group coverage by modules for better reporting
  add_group 'Core Library' do |src_file|
    src_file.filename.include?('lib/textstat.rb') ||
      src_file.filename.include?('lib/textstat/main.rb')
  end

  add_group 'Basic Statistics', 'lib/textstat/basic_stats.rb'
  add_group 'Dictionary Manager', 'lib/textstat/dictionary_manager.rb'
  add_group 'Readability Formulas', 'lib/textstat/readability_formulas.rb'

  # Coverage thresholds
  minimum_coverage 85
  # Don't enforce per-file minimum to avoid issues with utility files

  # Enable branch coverage for more detailed analysis
  enable_coverage :branch

  # Output configuration
  coverage_dir 'coverage'

  # Track files even if not loaded during tests (exclude filtered files)
  track_files '{lib/textstat.rb,lib/textstat/main.rb,' \
              'lib/textstat/basic_stats.rb,' \
              'lib/textstat/dictionary_manager.rb,' \
              'lib/textstat/readability_formulas.rb}'
end

# Standard RSpec configuration
RSpec.configure do |config|
  # Use more verbose output for CI
  config.formatter = :documentation if ENV['CI']

  # Run specs in random order to surface order dependencies
  config.order = :random

  # Seed global randomization for reproducible test runs
  Kernel.srand config.seed

  # Configure expectations
  config.expect_with :rspec do |expectations|
    # Disable monkey patching of should/should_not into Kernel
    expectations.syntax = :expect
    # Enable more detailed output for failures
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Configure mocks
  config.mock_with :rspec do |mocks|
    # Prevent accidental monkey patching of Kernel
    mocks.syntax = :expect
    # Verify partial doubles
    mocks.verify_partial_doubles = true
  end

  # Filter out specific warnings
  config.warnings = false

  # Print the 10 slowest examples and example groups
  config.profile_examples = 10 if ENV['PROFILE']

  # Shared examples configuration
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
