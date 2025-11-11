# frozen_string_literal: true

require "scrypt"
require "base64"
require "openssl"
require "logger"

module Enigma
  # Verifies the password by comparing it with the stored hash.
  class Verifier
    # @!attribute [r] password_to_check
    #   @return [String] The password to be checked.
    # @!attribute [r] target_salt_base64
    #   @return [String] The base64-encoded user salt.
    # @!attribute [r] stored_hash_base64
    #   @return [String] The base64-encoded stored hash.
    # @!attribute [r] base64_signer_key
    #   @return [String] The base64-encoded signer key.
    # @!attribute [r] base64_salt_separator
    #   @return [String] The base64-encoded salt separator.
    # @!attribute [r] rounds
    #   @return [Integer] The number of rounds used for password hashing.
    # @!attribute [r] mem_cost
    #   @return [Integer] The memory cost used for password hashing.
    def initialize(password_to_check:, target_salt_base64:, stored_hash_base64:)
      check_args(password_to_check, target_salt_base64, stored_hash_base64, Enigma.base64_signer_key,
                 Enigma.base64_salt_separator,
                 Enigma.rounds, Enigma.mem_cost)

      @password_to_check = password_to_check
      @target_salt_base64 = target_salt_base64
      @stored_hash_base64 = stored_hash_base64
      @base64_signer_key = Enigma.base64_signer_key
      @base64_salt_separator = Enigma.base64_salt_separator
      @rounds = Enigma.rounds
      @mem_cost = Enigma.mem_cost
    end

    def verify
      verify_password
    end

    private

    def check_args(*args)
      args.each do |arg|
        if arg.nil?
          Enigma.logger.error "Argument is nil or missing!"
          raise EnigmaError, "Missing required argument"
        end
      end
    end

    def verify_password
      user_salt = decoded_user_salt
      salt_separator = decoded_salt_separator
      signer_key = decoded_signer_key
      stored_hash = decoded_stored_hash
      scrypt_salt = user_salt + salt_separator
      scrypt_hash = compute_scrypt_hash(scrypt_salt)
      computed_hash = encrypt_signer_key(scrypt_hash, signer_key)

      return false if computed_hash.bytesize != stored_hash.bytesize

      secure_compare(computed_hash, stored_hash)
    end

    def decoded_user_salt
      Base64.decode64(@target_salt_base64)
    end

    def decoded_salt_separator
      Base64.decode64(@base64_salt_separator)
    end

    def decoded_signer_key
      Base64.decode64(@base64_signer_key)
    end

    def decoded_stored_hash
      Base64.decode64(@stored_hash_base64)
    end

    def compute_scrypt_hash(scrypt_salt)
      n = 1 << @mem_cost
      r = @rounds
      p = 1
      dk_len = 32
      SCrypt::Engine.scrypt(@password_to_check, scrypt_salt, n, r, p, dk_len)
    end

    def encrypt_signer_key(scrypt_hash, signer_key)
      iv = "\0" * 16
      cipher = OpenSSL::Cipher.new("aes-256-ctr")
      cipher.encrypt
      cipher.iv = iv
      cipher.key = scrypt_hash
      cipher.update(signer_key) + cipher.final
    end

    def secure_compare(computed_hash, stored_hash)
      return false unless OpenSSL.respond_to?(:fixed_length_secure_compare)

      OpenSSL.fixed_length_secure_compare(computed_hash, stored_hash)
    rescue EnigmaError => e
      Enigma.logger.error "Verification failed: #{e.message}. Returning false."
      false
    end
  end
end
