#--
# Copyright (c) 2009, Gonzalo Suarez, Nando Sola.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Spain.
#++

require 'base64'
require 'sha1'
require 'md5'


module RuoteRest
module Password

  SALT_SIZE = 8

  def self.generate_salt (length=SALT_SIZE)

    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + %w{ . / }

    #salt = ''
    #1.upto(length) { |i| salt << chars[rand(chars.size-1)] }
    #salt
    (1..length).inject('') { |salt, i| salt << chars[rand(chars.size - 1)] }
  end

  def self.generate_ssha (password, salt=generate_salt())

    '{SSHA}' +
    Base64.encode64(Digest::SHA1.digest(password + salt) + salt).chomp!
  end

  def self.generate_smd5 (password, salt=generate_salt())

    '{SMD5}' +
    Base64.encode64(Digest::MD5.digest(password + salt) + salt).chomp!
  end

  def self.check_password (challenge, password)

    raise Exception.new('Crypt pattern not found') \
      unless challenge.match(/^\{([A-Z][A-Z\d]+)\}/)

    data = Regexp.last_match
    type = data[1].downcase

    raise Exception.new('Unknown crypt mode') \
      unless respond_to?("generate_#{type}")

    salt = (Base64.decode64 data.post_match)[-SALT_SIZE, SALT_SIZE]
    crypted = send("generate_#{type}", password, salt)

    challenge == crypted
  end

end
end

