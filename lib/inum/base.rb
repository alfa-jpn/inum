module Inum
  # InumBase class.
  #
  # @abstract Inum class should be a inheritance of Inum::Base.
  # @example
  #   class FruitType < Inum::Base
  #     define_enum :APPLE,  0
  #     define_enum :BANANA, 1  
  #     define_enum :ORANGE, 2
  #   end
  class Base
   
    attr_accessor :value
    private_class_method :new

    # initialize Inum::Base with value.
    # @note Inum::Base can't call new method.
    #
    # @param value [Integer] value of Enum.
    def initialize(value)
      unless self.class.defined_enums.has_value?(value)
        raise ArgumentError, "unknown value #{value}!"
      end
      @value = value
    end

    # Compare object.
    #
    # @param [Object] parsable object.
    # @return [Boolean] result.
    def eql?(object)
      self.equal?(self.class.parse(object))
    end
    
    # Enum to Integer.
    # 
    # @return [Integer] integer value of Enum.
    def to_i
      @value
    end

    # Enum to String.
    #
    # @return [String] string value of Enum.
    def to_s
      self.class.defined_enums.key(@value).to_s
    end

    # return array of Enums.
    #
    # @return [Array<Array<String, Integer>>] sorted array of Enums.
    def self.to_a
      defined_enums.map{|k,v| [k.to_s,v] }.sort{|a,b| a[1] <=> b[1] }
    end
    
    # return hash of Enums.
    #
    # @return [Hash] hash of Enums.
    def self.to_h
      defined_enums.dup
    end
    
    # Parse Object to Enum.
    #
    # @param object [Object] string or symbol or integer or Inum::Base.
    # @return [Inum::Base] instance of Inum::Base.
    def self.parse(object)
      case object
        when String
          self.const_get(object)
        when Symbol
          parse object.to_s
        when Integer
          parse self.defined_enums.key(object).to_s
        when self
          object
        else
          raise ArgumentError, "#{object} is nani?"
      end
    end

    private
    # Define Enum in called class.
    #
    # @param name  [String, Symbol] name of Enum.
    # @param value [Integer,Fixnum] value of Enum.
    def self.define_enum(name, value)

      validate_enum_args!(name, value)

      defined_enums[name] = value
      self.const_set(name, new(value))
    end
    
    # get hash of :DEFINED_ENUMS.
    def self.defined_enums
      self.const_get(:DEFINED_ENUMS)
    end

    # call after inherited.
    # @note Define hash of :DEFINED_ENUMS in child.
    def self.inherited(child)
      child.const_set(:DEFINED_ENUMS, Hash.new)
    end
    
    # Validate enum args, and raise exception.
    # 
    # @param name  [Object]  name of Enum.
    # @param value [Object] value of Enum.
    def self.validate_enum_args!(name, value)
      unless name.instance_of?(String) or name.instance_of?(Symbol)
        raise ArgumentError, "#{name}<#{name.class}> isn't String or Symbol."
      end
      
      unless value.instance_of?(Integer) or value.instance_of?(Fixnum)
        raise ArgumentError, "#{value}<#{value.class}> isn't Integer or Fixnum."
      end
      
      if name == :DEFINED_ENUMS
        raise ArgumentError, "#{name} is keyword."
      end

      if defined_enums.has_key?(name)
        raise ArgumentError, "name(#{name}!) already exists!!"
      end
      
      if defined_enums.has_value?(value)
        raise ArgumentError, "value(#{value}!) already exists!!"
      end
    end
  end
end
