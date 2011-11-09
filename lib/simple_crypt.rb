require 'base64'
require 'openssl'
require 'digest/sha1'

# A simple set of class methods for encrypting/decrypting strings.
class SimpleCrypt

  @@algorithm = "des-ecb"
  @@key       = "SuperSecret_key"  # ok - so this is really not "secure"
  @@iv        = "SuperSecret_iv"

  # Encrypts a string.
  #
  # ====Parameters
  #
  # +str+::
  #   The string to encrypt.
  #
  # ====Returns
  #
  # An encrypted String.
  #
  # ====Examples
  #
  #     encrypted = SimpleCrypt.encrypt("MyPassword")
  #
  def SimpleCrypt.encrypt(str)
    cipher = OpenSSL::Cipher::Cipher.new(@@algorithm)
    cipher.encrypt
    cipher.key = Digest::SHA1.hexdigest(@@key)
    cipher.iv  = Digest::SHA1.hexdigest(@@iv)
    output = cipher.update(str)
    output << cipher.final
    return Base64.encode64(output)
  end

  # Decrypts a string that was encrypted with SimpleCrypt.encrypt().
  #
  # ====Parameters
  #
  # +str+::
  #   The string to decrypt.
  #
  # ====Returns
  #
  # The decrypted String.
  #
  #
  # ====Raises Exceptions
  #
  # +ErrorInvalidEncryptedString+::
  #   if the +str+ parameter is not a valid encrypted string
  #
  # ====Examples
  #
  #     decrypted = SimpleCrypt.decrypt(encrypted)
  #
  def SimpleCrypt.decrypt(str)
    cipher = OpenSSL::Cipher::Cipher.new(@@algorithm)
    cipher.decrypt
    cipher.key = Digest::SHA1.hexdigest(@@key)
    cipher.iv  = Digest::SHA1.hexdigest(@@iv)
    begin
      output = cipher.update(Base64.decode64(str))
      output << cipher.final
    rescue
      raise "ErrorInvalidEncryptedString"
    end
    return output
  end

  # Encrypts a file.
  #
  # ====Parameters
  #
  # +filepath+::
  #   The path to the file to encrypt.
  #
  # ====Returns
  #
  # None
  #
  # ====Examples
  #
  #     SimpleCrypt.encrypt_file("test.txt")
  #
  def SimpleCrypt.encrypt_file(filepath)
    in_file = File.open(filepath, "rb")
    clear_data = in_file.read
    crypt_data = SimpleCrypt.encrypt(clear_data)
    in_file.close

    out_file = File.open(filepath, "wb")
    out_file.write(crypt_data)
    out_file.close
  end

  # Decrypts a file that was encrypted with SimpleCrypt.encrypt_file().
  #
  # ====Parameters
  #
  # +filepath+::
  #   The path to the file to decrypt.
  #
  # ====Returns
  #
  # None.
  #
  # ====Raises Exceptions
  #
  # +ErrorInvalidEncryptedString+::
  #   if the contents of the file are not a valid encrypted file
  #
  # ====Examples
  #
  #   SimpleCrypt.decrypt_file("test.txt")
  #
  def SimpleCrypt.decrypt_file(filepath)
    in_file = File.open(filepath, "rb")
    crypt_data = in_file.read
    clear_data = SimpleCrypt.decrypt(crypt_data)
    in_file.close

    out_file = File.open(filepath, "wb")
    out_file.write(clear_data)
    out_file.close
  end

  # Encrypts the contents of a file to a string without modifying
  # the input file.
  #
  # +filepath+::
  #   The path to the file to encrypt.
  #
  # ====Returns
  #
  # The encrypted contents of the file as a String.
  #
  # ====Examples
  #
  #     encrypted = SimpleCrypt.encrypt_file_to_string("test.txt")
  #
  def SimpleCrypt.encrypt_file_to_string(filepath)
    in_file = File.open(filepath, "rb")
    clear_data = in_file.read
    crypt_data = SimpleCrypt.encrypt(clear_data)
    in_file.close
    return crypt_data
  end

  # Decrypts a file that was encrypted with SimpleCrypt.encrypt_file()
  # and returns the clear data without modifying the input file.
  #
  # ====Parameters
  #
  # +filepath+::
  #   The path to the file to decrypt.
  #
  # ====Returns
  #
  # The clear data contents of the encrypted input file.
  #
  # ====Raises Exceptions
  #
  # +ErrorInvalidEncryptedString+::
  #   if the contents of the file are not a valid encrypted file
  #
  # ====Examples
  #
  #     decrypted = SimpleCrypt.decrypt_file_to_string("test.txt")
  #
  def SimpleCrypt.decrypt_file_to_string(filepath)
    in_file = File.open(filepath, "rb")
    crypt_data = in_file.read
    clear_data = SimpleCrypt.decrypt(crypt_data)
    in_file.close
    return clear_data
  end
end
