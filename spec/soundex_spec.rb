require 'spec_helper'

context "Soundex" do
  it "should convert numbers to words" do
    "ONE".should eql(Soundex.encode_num("1"))
    "NINETEEN".should eql(Soundex.encode_num("19"))
    "TWENTY-FIVE".should eql(Soundex.encode_num("25"))
    "SIXTY-NINE".should eql(Soundex.encode_num("69"))
    "ONE HUNDRED".should eql(Soundex.encode_num("100"))
    "ONE HUNDRED SIXTY-NINE".should eql(Soundex.encode_num("169"))
    "ONE THOUSAND NINE HUNDRED".should eql(Soundex.encode_num("1900"))
    "ONE THOUSAND NINE HUNDRED SEVENTY-FIVE".should eql(Soundex.encode_num("1975"))
    "TWO THOUSAND SIX".should eql(Soundex.encode_num("2006"))
    "ONE BILLION TWO HUNDRED THIRTY-FOUR MILLION FIVE HUNDRED SIXTY-SEVEN THOUSAND EIGHT HUNDRED NINTEY".should eql(Soundex.encode_num("1234567890"))
  end
  
  it "should match words that sound alike" do
    Soundex.compare("Grate", "great").should eql(true)
    Soundex.compare("Robert", "Rupert").should eql(true)
    Soundex.compare("bob", "bawb").should eql(true)
    Soundex.compare("Steel", "Steal").should eql(true)
    Soundex.compare("affluent", "avlooent").should eql(true)
    Soundex.compare("facad", "fasahd").should eql(true)
    Soundex.compare("Led Zeppelin", "led zeplin").should eql(true)
    Soundex.compare("USA", "U.S.A.").should eql(true)
    Soundex.compare("AC/DC", "AC-DC").should eql(true)
    Soundex.compare("Guns & Roses", "Guns and Roses").should eql(true)
    Soundex.compare("Guns && Roses", "Guns and Roses").should eql(true)
    Soundex.compare("Guns + Roses", "Guns and Roses").should eql(true)
    Soundex.compare("Guns & Roses", "Guns and Roses").should eql(true)
    Soundex.compare("Guns n Roses", "Guns and Roses").should eql(true)
    Soundex.compare("Guns 'n Roses", "Guns and Roses").should eql(true)
    Soundex.compare("Guns n' Roses", "Guns and Roses").should eql(true)
    Soundex.compare("Guns 'n' Roses", "Guns and Roses").should eql(true)
    Soundex.compare("2pac", "tupac").should eql(true)
    Soundex.compare("Summer of 69", "Summer of Sixty Nine").should eql(true)
    Soundex.compare("46 & 2", "forty six and two").should eql(true)
    Soundex.compare("Don't Cry", "Dont Cry").should eql(true)
  end
  
  it "shouldn't match words that don't sound alike" do
    Soundex.compare("Great", "Bob").should eql(false)
    Soundex.compare("roger", "finger").should eql(false)
    Soundex.compare("Exclamation", "Expansion").should eql(false)
    Soundex.compare("Metallica", "AC/DC").should eql(false)
    Soundex.compare("joy", "pain").should eql(false)
    Soundex.compare("sunshine", "rain").should eql(false)
  end
  
  it "should be able to match numbers" do
    Soundex.compare('1', '1').should eql(true)
    Soundex.compare("1", "1").should eql(true)
    Soundex.compare("11", "11").should eql(true)
    Soundex.compare("Volume 1", "Voloom 1").should eql(true)
    Soundex.compare("Episode 2", "Eposode 2").should eql(true)
    Soundex.compare("Vol. 1", "Vol. One").should eql(true)
  end
  
  it "should not match different numbers" do
    Soundex.compare('1', '4').should eql(false)
    Soundex.compare("1", "2").should eql(false)
    Soundex.compare("11", "16").should eql(false)
    Soundex.compare("Volume 1", "Voloom 2").should eql(false)
    Soundex.compare("Episode 2", "Eposode 5").should eql(false)
    Soundex.compare("Vol. 1", "Vol. Five").should eql(false)  
  end
end
