# frozen_string_literal: true

require_relative "lib/enigma/version"

Gem::Specification.new do |spec|
  spec.name = "enigma"
  spec.version = Enigma::VERSION
  spec.authors = ["Yavor Dashev"]
  spec.email = ["58559918+y-dashev@users.noreply.github.com"]

  spec.summary = "A Ruby gem for verifying passwords hashed with Firebase's scrypt-based algorithm."
  spec.description = <<~DESC
    Enigma is a lightweight Ruby gem designed to verify passwords hashed using Firebase's custom scrypt-based algorithm, making it ideal for seamless integrations and migrations involving Firebase authentication systems. It provides a secure, efficient way to compare a user-provided password against a stored hash without exposing sensitive details, ensuring constant-time comparisons to mitigate timing attacks.

    Key features include:
    - Full compatibility with Firebase Authentication's password hashing logic, combining scrypt with AES-256-CTR encryption for signing.
    - Configurable parameters for scrypt (rounds, memory cost), signer keys, and salt separators.
    - Secure practices using OpenSSL's fixed-length comparisons.
    - Support for custom logging, with easy integration into Rails or other frameworks.
    - Minimal dependencies, relying on the 'scrypt' gem alongside Ruby's standard library.

    A common use case is migrating users from Firebase to systems like Devise in Ruby on Rails. During migration, extract the user's base64-encoded salt and stored hash from Firebase, then use Enigma to verify the input password. If it matches, set the raw password in Devise to generate a new hash, avoiding forced resets and ensuring a smooth transition.

    Whether for custom auth systems, password audits, or hybrid setups, Enigma simplifies secure verification while prioritizing ease of use.
  DESC
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"
  spec.homepage = "https://github.com/y-dashev/enigma"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/y-dashev/enigma"
  spec.metadata["changelog_uri"] = "https://github.com/y-dashev/enigma/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "scrypt", "~> 3.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
