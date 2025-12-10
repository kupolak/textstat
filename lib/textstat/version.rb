# TextStat version information
#
# This module defines the current version of the TextStat gem.
# The version follows Semantic Versioning (semver.org).
#
# @author Jakub Polak
# @since 0.1.0
module TextStat
  # Current version of the TextStat gem
  #
  # Version 1.0.1 includes performance optimizations and bug fixes
  # - Optimized dictionary caching with lazy loading
  # - Improved text_standard performance
  # - Reduced memory allocations
  # - Code quality improvements (Rubocop compliance)
  #
  # @return [String] current version string
  # @example
  #   TextStat::VERSION  # => "1.0.1"
  VERSION = '1.0.1'.freeze
end
