# -*- encoding: utf-8 -*-
# stub: text-hyphen 1.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "text-hyphen".freeze
  s.version = "1.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze]
  s.date = "2012-08-27"
  s.description = "Text::Hyphen is a Ruby library to hyphenate words in various languages using\nRuby-fied versions of TeX hyphenation patterns. It will properly hyphenate\nvarious words according to the rules of the language the word is written in.\nThe algorithm is based on that of the TeX typesetting system by Donald E.\nKnuth.\n\nThis is originally based on the Perl implementation of\n{TeX::Hyphen}[http://search.cpan.org/author/JANPAZ/TeX-Hyphen-0.140/lib/TeX/Hyphen.pm]\nand the {Ruby port}[http://rubyforge.org/projects/text-format]. The language\nhyphenation pattern files are based on the sources available from\n{CTAN}[http://www.ctan.org] as of 2004.12.19 and have been manually translated\nby Austin Ziegler.\n\nThis is a small feature release adding Russian language support and fixing a\nbug in the custom hyphen support introduced last version. This release provides\nboth Ruby 1.8.7 and Ruby 1.9.2 support (but please read below). In short, Ruby\n1.8 support is deprecated and I will not be providing any bug fixes related to\nRuby 1.8. New features will be developed and tested against Ruby 1.9 only.".freeze
  s.email = ["austin@rubyforge.org".freeze]
  s.executables = ["ruby-hyphen".freeze]
  s.extra_rdoc_files = ["History.rdoc".freeze, "License.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.files = ["History.rdoc".freeze, "License.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "bin/ruby-hyphen".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Text::Hyphen is a Ruby library to hyphenate words in various languages using Ruby-fied versions of TeX hyphenation patterns".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 3

  s.add_development_dependency(%q<rdoc>.freeze, ["~> 3.10"])
  s.add_development_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<hoe-gemspec>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<hoe-git>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<hoe-seattlerb>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<hoe>.freeze, ["~> 3.0"])
end
