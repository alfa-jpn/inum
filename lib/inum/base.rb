module Inum
  require 'i18n'
  require 'inum/utils'

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
    extend Enumerable
    include Comparable

    private_class_method :new

    # initialize Inum::Base with value.
    # @note The instance of Enum Member is singleton.
    #
    # @param label [Symbol]  label of Enum.
    # @param value [Integer] value of Enum.
    def initialize(label, value)
      @label = label
      @value = value

      @underscore_label = Inum::Utils::underscore(label)
    end

    # Compare object.
    #
    # @param object [Object] parsable object.
    # @return [Integer] same normal <=>.
    def <=> (object)
      @value <=> self.class.parse(object).to_i
    end

    # plus object.
    #
    # @param value [Integer] plus value.(call to_i in this method.)
    # @return [Inum::Base] object after plus value.
    def + (value)
      self.class.parse(@value + value.to_i)
    end

    # minus object.
    #
    # @param value [Integer] plus value.(call to_i in this method.)
    # @return [Inum::Base] object after plus value.
    def - (value)
      self.class.parse(@value - value.to_i)
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
    # @return [String] string value(label) of Enum.
    def to_s
      @label.to_s
    end

    # Translate Enum to localized string.(use i18n)
    # @note find default `Namespace.Classname.EnumMember`
    #
    # @return [String] localized string of Enum.
    def to_t
      I18n.t(self.class.i18n_key(@label))
    end

    # Enum label to underscore string.
    #
    # @return [String] under_score string value(label) of Enum.
    def to_u
      @underscore_label
    end

    # Execute the yield(block) with each member of enum.
    #
    # @yield [enum] instance of enum.
    def self.each
      defined_enums.each_key {|key| yield parse(key.to_s)}
    end

    # get all labels of Enum.
    #
    # @return [Array<Symbol>] all labels of Enum.
    def self.labels
      defined_enums.keys
    end

    # get Enum length.
    #
    # @return [Integer] count of Enums.
    def self.length
      defined_enums.length
    end

    # return array of Enums.
    #
    # @return [Array<Array<Symbol, Integer>>] sorted array of Enums.
    def self.to_a
      defined_enums.flatten(0).sort{|a,b| a[1] <=> b[1] }
    end

    # return hash of Enums.
    #
    # @return [Hash<Symbol, Integer>] hash of Enums.
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

    # get all values of Enum.
    #
    # @return [Array<Integer>] all values of Enum.
    def self.values
      defined_enums.values
    end

    private
    # Define Enum in called class.
    #
    # @param label [Symbol]  label of Enum.
    # @param value [Integer] value of Enum.(default:autoincrement for 0.)
    def self.define_enum(label, value = defined_enums.size)
      value = value.to_i

      validate_enum_args!(label, value)

      defined_enums[label] = value
      self.const_set(label, new(label, value))
    end

    # get hash of @defined_enums.
    #
    # @return [Hash] hash of defined enums.
    def self.defined_enums
      @defined_enums
    end

    # get key for I18n.t method.
    # @note default: Namespace.Classname.Label(label of enum member.)
    #
    # @param label [Symbol] label of enum member.
    # @return [String] key for I18n.t method.
    # @abstract If change key from the default.
    def self.i18n_key(label)
      Inum::Utils::underscore("inum::#{self.name}::#{label}")
    end

    # call after inherited.
    # @note Define hash of :DEFINED_ENUMS in child.
    def self.inherited(child)
      child.instance_variable_set(:@defined_enums, Hash.new)
    end

    # Validate enum args, and raise exception.
    #
    # @param label [Object]  label of Enum.
    # @param value [Integer] value of Enum.
    def self.validate_enum_args!(label, value)
      unless label.instance_of?(Symbol)
        raise ArgumentError, "The label(#{label}!) isn't instance of Symbol."
      end

      if defined_enums.has_key?(label)
        raise ArgumentError, "The label(#{label}!) already exists!!"
      end

      if defined_enums.has_value?(value)
        raise ArgumentError, "The value(#{value}!) already exists!!"
      end
    end
  end
end
