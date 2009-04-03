require 'base64'
require 'sha1'
require 'md5'

module Password

  SALT_SIZE = 8 

  def generate_salt(length)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + '.'.to_a + '/'.to_a
    salt = ""
    1.upto(length) { |i| salt << chars[rand(chars.size-1)] }
    salt
  end 

  def generate_ssha (password, salt=nil)
    salt ||= generate_salt SALT_SIZE
    "{SSHA}" + Base64.encode64(Digest::SHA1.digest(password + salt) + salt).chomp!
  end 

  def generate_smd5 (password, salt=nil)
    salt ||= generate_salt SALT_SIZE
    "{SMD5}" + Base64.encode64(Digest::MD5.digest(password + salt) + salt).chomp!
  end 

  def check_password (challenge, password)
    raise Exception, "Crypt pattern not found" unless /^\{([A-Z][A-Z\d]+)\}/ =~ challenge

    data = Regexp.last_match
    type = data[1].downcase

    raise Exception, "Unknown crypt mode" unless respond_to? "generate_#{type}"

    salt = (Base64.decode64 data.post_match)[-SALT_SIZE, SALT_SIZE]
    crypted = send("generate_#{type}", password, salt)

    challenge == crypted
  end

end
