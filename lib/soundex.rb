# Implements class methods for performing the "Soundex" phoenetic string
# matching algorithm similar to the one described here:
#
#   http://en.wikipedia.org/wiki/Soundex
#
class Soundex < ActiveRecord::Base

  # Generates a soundex encoding for the specified word.
  #
  # ====Parameters
  #
  # +word+::
  #   The word to be soundex-encoded.
  #
  # ====Returns
  #
  # A String containing the soundex encoding of the given word.
  #
  # ====Examples
  #
  #     encoding = Soundex.encode("Steel")
  #
  def Soundex.encode(word)
    word = word.upcase()

    # replace special strings with phoenetic replacements
    word = word.gsub(/&+/, 'AND')
    word = word.gsub(/\++/, 'AND')
    word = word.gsub(/\s+N\s+/, ' AND ')
    word = word.gsub(/\s+'N'\s+/, ' AND ')
    word = word.gsub(/\s+'N\s+/, ' AND ')
    word = word.gsub(/\s+N'\s+/, ' AND ')

    # replace numbers with phoenetic replacements
    nums = word.scan(/\d+/)
    nums.each do |num|
      word = word.gsub(num, Soundex.encode_num(num))
    end

    # remove all remaining non-alpha characters
    temp = ""
    word.each_byte do |curr_byte|
      if (curr_byte >= 65) && (curr_byte <= 90)
        temp << curr_byte
      end
    end
    word = temp

    if word.length > 0
      first_character = word[0]
      word = word.gsub(/[AEIOUHWY]/, '0')
      word = word.gsub(/[BFPV]/,     '1')
      word = word.gsub(/[CGJKQSXZ]/, '2')
      word = word.gsub(/[DT]/,       '3')
      word = word.gsub(/[L]/,        '4')
      word = word.gsub(/[MN]/,       '5')
      word = word.gsub(/[R]/,        '6')
      word[0] = first_character
    end

    # remove duplicates
    temp = ""
    last_byte = 0
    word.each_byte do |curr_byte|
      temp << curr_byte if curr_byte != last_byte
      last_byte = curr_byte
    end
    word = temp

    # remove zeros
    word = word.gsub(/0/, '')

    # pad if necessary
    while (word.length() < 4)
      word << '0'
    end

    return word
  end

  # Compares two words to see if they "sound alike" using the
  # Soundex encoding to compare them
  #
  # ====Parameters
  #
  # +word1+::
  #   The first word to compare.
  #
  # +word2+::
  #   The second word to compare.
  #
  # ====Returns
  #
  # A Boolean +true+ if the words match with the soundex algorithm, +false+
  # if they do not.
  #
  # ====Examples
  #
  #     Soundex.compare("steel", "steal")  # => true
  #     Soundex.compare("fool", "gold")    # => false
  #
  def Soundex.compare(word1, word2)
    if word1.empty? || word2.empty?
      return false
    end
    if Soundex.encode(word1) == Soundex.encode(word2)
      return true
    else
      return false
    end
  end

  # Converts a string representation of a number to its fully-written-out
  # English spelling.
  #
  # ====Parameters
  #
  # +num+::
  #   The number String to convert.
  #
  # ====Returns
  #
  # A String containing the English words for this number.
  #
  # ====Examples
  #
  #     Soundex.encode_num("169") # => "ONE HUNDRED SIXTY-NINE"
  #
  def Soundex.encode_num(num)
    denom = [
      '',
      'THOUSAND',
      'MILLION',
      'BILLION',
      'TRILLION',
      'QUADRILLION',
      'QUINTILLION',
      'SEXTILLION',
      'SEPTILLION',
      'OCTILLION',
      'NONILLION',
      'DECILLION',
      'UNDECILLION',
      'DUODECILLION',
      'TREDECILLION',
      'QUATTUORDECILLION',
      'SEXDECILLION',
      'SEPTENDECILLION',
      'OCTODECILLION',
      'NOVEMDECILLION',
      'VIGINTILLION'
    ]
    
    val = num.to_i
    if val < 100
      return Soundex.encode_nn(val)
    end
    if val < 1000
      return Soundex.encode_nnn(val)
    end

    0.upto(denom.size-1) do |v|
      didx = v - 1
      dval = 1000 ** v
      if dval > val
        mod = 1000 ** didx
        l   = val / mod
        r   = val - (l * mod)
        ret = Soundex.encode_nnn(l) + ' ' + denom[didx]
        if r > 0
          ret = ret + ' ' + Soundex.encode_num(r)
        end
        return ret
      end
    end
  end

  # Helper function for encode_num. Handles three-digit numbers.
  #
  # ====Parameters
  #
  # +val+::
  #   The integer value to convert to English words.
  #
  # ====Returns
  #
  # A String containing the English words for this number.
  #
  # ====Examples
  #
  #     Sounex.encode_nnn(169) # => "ONE HUNDRED SIXTY-NINE"
  #
  def Soundex.encode_nnn(val)
    word = ''
    mod = val % 100
    rem = val / 100
    if rem > 0
      word = Soundex.encode_19(rem) + ' HUNDRED'
      if mod > 0
        word = word + ' '
      end
    end
    if mod > 0
      word = word + Soundex.encode_nn(mod)
    end
    return word
  end

  # Helper function for encode_num. Handles two-digit numbers.
  #
  # ====Parameters
  #
  # +val+::
  #   The integer value to convert to English words.
  #
  # ====Returns
  #
  # A String containing the English words for this number.
  #
  # ====Examples
  #
  #     Soundex.encode_nn(69) # => "SIXTY-NINE"
  #
  def Soundex.encode_nn(val)
    tens = [
      'TWENTY',
      'THIRTY',
      'FOURTY',
      'FIFTY',
      'SIXTY',
      'SEVENTY',
      'EIGHTY',
      'NINTEY'
    ]
    
    if val < 20
      return Soundex.encode_19(val)
    end
    0.upto(tens.size-1) do |v|
      dcap = tens[v]
      dval = 20 + (10 * v)
      if dval + 10 > val
        if val % 10 != 0
          return dcap + '-' + Soundex.encode_19(val % 10)
        end
        return dcap
      end
    end
  end

  # Helper function for encode_num. Handles numbers <= 19.
  #
  # ====Parameters
  #
  # +val+::
  #   The integer valud to convert to English words.
  #
  # ====Returns
  #
  # A String containing the English words for this number.
  #
  # ====Examples
  #
  #     Soundex.encode_19(14) # => "FOURTEEN"
  #
  def Soundex.encode_19(val)
    words = [
      'ZERO',
      'ONE',
      'TWO',
      'THREE',
      'FOUR',
      'FIVE',
      'SIX',
      'SEVEN',
      'EIGHT',
      'NINE',
      'TEN',
      'ELEVEN',
      'TWELVE',
      'THIRTEEN',
      'FOURTEEN',
      'FIFTEEN',
      'SIXTEEN',
      'SEVENTEEN',
      'EIGHTEEN',
      'NINETEEN'
    ]
    return words[val]
  end
  
  # Generates an SQL WHERE clause expression to test a given column against
  # the given value, to match it as a possible candidate that might match
  # with Soundex.compare.
  #
  # This is necessary because MySQL's SOUNDEX does not handle phenetic
  # comparisons for special symbols and numbers like our custom Ruby
  # Soundex.compare method does. Using strictly SOUNDEX() in SQL will not
  # match values that would match with Soundex.compare. To get around this,
  # this method can be used to select a wider set of candidates by replacing
  # special substrings with wildcards. The results of this query will include
  # more results than will match with Soundex.compare. These results should
  # then be post-processed in Ruby with Soundex.compare to weed out the
  # results that don't actually match.
  #
  # ====Parameters
  #
  # +column+::
  #   The name of the column to test as should be used in an SQL WHERE
  #   clause expression.
  #
  # +value+::
  #   A String containing the value to test the column against using a
  #   wider-than-SOUNDEX comparison.
  #
  # ====Returns
  #
  # A String containing an SQL WHERE clause expression (enclosed in
  # parenthesis) that can be used to filter to possible matching candidates
  # where the specified column sorta-sounds-like the specified value.
  #
  def Soundex.generate_candidate_where_clause(column, value)
    # REVISIT: The current implementation has a number of shortcomings:
    #
    #   1. Numeric words in a value will not be caught. This is because we
    #      are not replacing numbers with wildcards, as doing so turned out
    #      to be performance-prohibitive. This means that
    #      "Summer of Sixty-Nine" will not be returned from SQL as a
    #      potential match for "Summery of 69", and vice-versa, even though
    #      Soundex.compare would compare them as matching.
    #
    #   2. We lose some sounds-like comparison ability because SQL does
    #      not support a single expression that combines SOUNDEX and LIKE
    #      at the same time. So, "Slow and Low" will not be returned as a
    #      candidate for "Slo & Lo" (but "Slo and Lo" and "Slow & Low" will).
    #
    #   3. The use of wildcards will cause more candidates to be returned than
    #      are really necessary -- a necessary side-effect of casting a
    #      wider net. For example, "Jack Killed Jill" will be returned as a
    #      candidate for "Jack and Jill". Applying Ruby post-processing of the
    #      results using Soundex.compare will weed these out. It may be
    #      a performance hit to return too many candidates, but we are trying
    #      to be more correct by returning a wider set of candidates.
    #
    #   4. It is possible that the wild-card-converted value is left with
    #      nothing by wildcards. E.g.: "and" would be converted to
    #      "LIKE '%'". We protect explicitly against cases where there is
    #      nothing other than whitespace and wildcards.
    #

    # Always start with the standard SQL SOUNDEX equality expression.
    clauses = [
      "SOUNDEX(#{column})=SOUNDEX('#{Mysql::escape_string(value)}')"
    ]
    
    # Define the regex that we use to check to see if the value has any
    # special characters that need to be replaced with wildcards.
    regex = /&+|\s+and\s+|\s+n\s+|\s+'n'\s+|\s+'n\s+|\s+n'\s+/i

    # Check if the value has any special substrings in it.
    if value =~ regex
      # Create the wildcard name string we'll use in the LIKE statement,
      # by replacing all special substrings with the wildcard character '%'
      # then mysql-escaping it.
      quote_regex = /\s+n\s+|\s+'n'\s+|\s+'n\s+|\s+n'\s+/i
      other_regex = /&+|\s+and\s+/i
      wild_val = Mysql::escape_string(
        value.gsub(quote_regex, '%').gsub(other_regex, '%')
      )

      # Only if the wild_val has more characters in it that just whitespace
      # and wildcards do we add an additional clause to do the wildcard
      # comparison on the column.
      if wild_val.gsub(/%|\s+/, '') != ''
        clauses << "#{column} LIKE '#{wild_val}'"
      end
    end

    return "(#{clauses.join(' OR ')})"
  end
  
end
