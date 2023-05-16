# typed: false
# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "guard/sorbet/version"

Gem::Specification.new do |spec|
  spec.name = "guard-sorbet"
  spec.version = Guard::SorbetVersion::VERSION
  spec.authors = ["Dmitry Zuev"]
  spec.email = ["mail@dmitryzuev.com"]

  spec.summary = "Guard plugin for Sorbet"
  spec.description = "Guard::Sorbet automatically checks Ruby typing with Sorbet when files are modified."
  spec.homepage = "https://github.com/dmitryzuev/guard-sorbet"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dmitryzuev/guard-sorbet"
  spec.metadata["changelog_uri"] = "https://github.com/dmitryzuev/guard-sorbet/blob/main/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = true

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "guard", ">= 2.16.0", "< 3.0.0"
  spec.add_dependency "sorbet"
  spec.add_dependency "sorbet-runtime"
end
