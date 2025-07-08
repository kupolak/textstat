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
  # Version 1.0.0 represents the first stable release with:
  # - 36x performance improvement through dictionary caching
  # - Modular architecture with separate modules for different functionality
  # - Comprehensive test coverage (199 tests)
  # - Support for 22 languages
  # - Full backward compatibility with 0.1.x series
  #
  # @return [String] current version string
  # @example
  #   TextStat::VERSION  # => \"1.0.0\"
  VERSION = '1.0.0'.freeze
end
