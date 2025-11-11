# Enigma


Enigma: Firebase-Compatible Password Verifier for Ruby
Enigma is a lightweight Ruby gem designed to verify passwords hashed using Firebase's custom scrypt-based algorithm, making it ideal for seamless integrations and migrations involving Firebase authentication systems. It provides a secure, efficient way to compare a user-provided password against a stored hash without exposing sensitive details, ensuring constant-time comparisons to mitigate timing attacks.
Key Features

Firebase Compatibility: Implements the exact password verification logic used by Firebase Authentication, including scrypt hashing combined with AES-256-CTR encryption for signing.
Configurable Parameters: Easily customize scrypt parameters (rounds, memory cost), signer keys, and salt separators via a simple configuration block or per-instance overrides.
Secure Practices: Utilizes OpenSSL's fixed-length secure comparison (when available) to prevent side-channel vulnerabilities.
Logging Support: Integrates with any Ruby logger (defaults to STDERR) for error tracking, with Rails compatibility out of the box.
Minimal Dependencies: Relies only on the scrypt gem for hashing, with Base64 and OpenSSL from Ruby's standard library.

Use Case: Migrating Firebase Users to Devise
One common application of Enigma is during user migrations from Firebase to other authentication systems, such as Devise in a Ruby on Rails application. For instance, when importing users from Firebase, you often need to verify their existing passwords without rehashing them prematurely. Enigma shines here by allowing you to:

Extract Firebase Data: Pull the user's salt (base64-encoded), stored hash (base64-encoded), and other parameters from Firebase exports.
Verify Input Password: During login or migration, use Enigma to check if the password the user enters matches the Firebase-stored hash.
Seamless Transition to Devise: If the verification succeeds, you can safely set the raw password value in Devise (e.g., via user.update(password: raw_password)) to generate a new, Devise-compatible hash. This avoids forcing password resets and provides a smooth user experience.

In a real-world migration script, this might look like:

## Installation

 Replace `enigma` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add enigma-rb
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install enigma-rb
```

## Usage

# In a Rails app, configure once (e.g., in an initializer)
```
Enigma.configure do |config|
  config.base64_signer_key = Rails.application.credentials.dig(:firebase, :base64_signer_key)
  config.base64_salt_separator = Rails.application.credentials.dig(:firebase, :base64_salt_separator)
  config.logger = Rails.logger  # Optional: use Rails logger
end
```

Then verify
```
verifier = Enigma::Verifier.new(
  password_to_check: "user_password",
  user_salt_base64: "some_base64_salt",
  stored_hash_base64: "stored_base64_hash"
)
verifier.verify  # => true or false
```

# Assuming you have Firebase user data
```
firebase_user = { salt_base64: '...', hash_base64: '...', password_input: user_provided_password }

Enigma.configure do |config|
  config.base64_signer_key = 'your_firebase_signer_key_base64'
  config.base64_salt_separator = 'your_firebase_salt_separator_base64'
end

verifier = Enigma::Verifier.new(
  password_to_check: firebase_user[:password_input],
  target_salt_base64: firebase_user[:salt_base64],
  stored_hash_base64: firebase_user[:hash_base64]
)

if verifier.verify
  # Password matches! Migrate to Devise
  new_user = User.new(email: firebase_user[:email])
  new_user.password = firebase_user[:password_input]  # Set raw password to let Devise hash it
  new_user.save
  puts "User migrated successfully!"
else
  puts "Password verification failed. Prompt for reset."
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Potential Improvements

If this is specifically for Firebase password verification, name the gem something like firebase-scrypt-verifier to make its purpose clear (check rubygems.org for conflicts).
Add error handling for invalid base64 inputs or scrypt failures.
If you want to support hashing (not just verification), extend the class with a hash_password method.
Check for existing gems: A quick search shows gems like firebase-auth-ruby or scrypt, but if this matches Firebase's exact algo (scrypt with AES signing), your custom implementation could fill a niche.

If you run into issues during setup or need help with a specific part (e.g., testing), provide more details!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/y-dashev/enigma. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/y-dashev/enigma/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Enigma project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/y-dashev/enigma/blob/master/CODE_OF_CONDUCT.md).
