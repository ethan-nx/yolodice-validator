# Copyright (c) 2016 Ethan White (YOLOdice.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'openssl'
require 'csv'

class YolodiceGenerator

  def initialize server_key_hex, client_phrase
    @server_key = [server_key_hex].pack("H*")
    @client_phrase = client_phrase
  end

  def server_key_hex
    @server_key.unpack('H*')[0]
  end

  def server_key_hash_hex
    # OpenSSL::Digest::SHA256.hexdigest server_key_hex
    OpenSSL::Digest::SHA256.hexdigest server_key_hex
  end

  # Runs the algorithm that returns bet result.
  def roll nonce
    hash = OpenSSL::HMAC.hexdigest 'sha512', @server_key, "#{@client_phrase}.#{nonce}"
    out = nil
    while !out || out >= 1_000_000
      out = hash.slice!(0,5).to_i 16
    end
    out
  end

  # When given bet result and bet input parameters the function returns a Hash
  # that include bet profit.
  def generate_bet nonce, amount, target, range
    result = roll nonce
    profit = (amount * (1_000_000.to_f / target * (1 - 0.01) - 1)).floor
    win = case range
          when 'lo'
            result < target
          when 'hi'
            result > 999_999 - target
          end
    profit = -amount unless win
    {
      result: result,
      profit: profit,
      win: win
    }
  end

end

class YolodiceValidator

  def initialize input_file
    @input_file = input_file
    @mismatch_count = 0
  end

  def run
    CSV.open @input_file do |file|
      # parse first line
      seed_id0, secret_hashed_hex0, secret_hex0, client_phrase0, seed_created_at0 = file.shift
      @generator = YolodiceGenerator.new secret_hex0, client_phrase0
      assume 'secret_hashed_hex', secret_hashed_hex0, @generator.server_key_hash_hex
      if @mismatch_count == 0
        puts "Seed seems OK, validating individual bets."
      else
        puts "Seed data is not valid, checking bets anyway."
      end
      print '.'
      @last_dot = true
      # read the rest of lines, verify individual bets
      while bet_data = file.shift do
        bet_id0, nonce0, rolled0, target0, range0, amount0, profit0 = bet_data
        bet_id0 = bet_id0.to_i
        nonce0 = nonce0.to_i
        rolled0 = rolled0.to_i
        target0 = target0.to_i
        amount0 = amount0.to_i
        profit0 = profit0.to_i

        bet = @generator.generate_bet nonce0, amount0, target0, range0
        assume "bet #{bet_id0} result", rolled0.to_i, bet[:result]
        assume "bet #{bet_id0} profit", profit0.to_i, bet[:profit]
        if nonce0 % 1000 == 0
          print '.' 
          @last_dot = true
        end
      end
      print "\n"
      if @mismatch_count == 0
        puts "All bets verified OK"
      else
        puts "#{@mismatch_count} errors found."
      end

    end
  end

  private
  def assume label, v0, v1
    unless v0 == v1
      print "\n" if @last_dot
      puts "MISMATCH: #{label}, in file: #{v0}, calculated: #{v1}"
      @mismatch_count += 1
      @last_dot = false
    end

  end

  class << self
    
    def parse_opts argv
      # There is only one option - pass a file containing a CSV dump
      usage = "Usage: ruby yolodice_validator.rb DUMP_FILE"
      unless argv.length == 1
        puts usage
        exit
      end
      return { input_file: argv[0] }
    end

    def run opts
      yv = YolodiceValidator.new opts[:input_file]
      yv.run
    end

  end
end

if __FILE__ == $0
  options = YolodiceValidator.parse_opts ARGV
  YolodiceValidator.run options
end
