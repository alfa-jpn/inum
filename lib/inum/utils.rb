module Inum
  # Utils of Inum.
  class Utils
    
    # convert a camel cased word to a underscore word.
    #
    # @param camel_cased_word [String] camel cased word.
    # @return [String, Symbol] underscore word.
    def self.underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!('-', '_')
      
      word.downcase!
      
      word
    end
    
  end
end
