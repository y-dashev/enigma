# frozen_string_literal: true

require_relative "enigma/version"
require_relative "enigma/verifier"

# Enigma module provides functionality for encrypting and verifying passwords from scrypt to bcrypt.
module Enigma
  class << self
    attr_accessor :base64_signer_key, :base64_salt_separator, :rounds, :mem_cost, :logger

    def configure
      yield self if block_given?
    end
  end

  self.rounds = 8
  self.mem_cost = 14
  self.logger = Logger.new(STDERR)

  class EnigmaError < ArgumentError; end
end
