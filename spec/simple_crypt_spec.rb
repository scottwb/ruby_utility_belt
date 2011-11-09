require 'spec_helper'

describe SimpleCrypt do
  it "should encypt a simple string" do
    original = 'Test String'

    encrypted = SimpleCrypt.encrypt(original)
    encrypted.should_not == original

    decrypted = SimpleCrypt.decrypt(encrypted)
    decrypted.should == original
  end
  
  it "should raise error when trying to decrpyt a non encypted string" do
    expect{SimpleCrypt.decrypt('invalid')}.to raise_exception "ErrorInvalidEncryptedString"
  end
end
