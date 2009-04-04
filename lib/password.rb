#--
# Copyright (c) 2009, Gonzalo Suarez, Nando Sola.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# . Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# . Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# . Neither the name of the "OpenWFE" nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
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

