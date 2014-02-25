module Inum
  require 'i18n'
  require 'inum/utils'

  # InumBase class.
  #
  # @abstract Inum class should be a inheritance of Inum::Base.
  # @example
  #   class FruitType < Inum::Base
  #     define :APPLE,  0
  #     define :BANANA, 1
  #     define :ORANGE, 2
  #   end
  class Base
    extend Enumerable
    include Comparable

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
      other = self.class.parse(object)
      if other.nil?
        nil
      else
        @value <=> other.to_i
      end
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

    # Label of Enum.
    #
    # @return [Symbol] Label of Enum.
    def label
      @label
    end

    # Enum to String.
    #
    # @return [String] Label(String).
    def to_s
      @label.to_s
    end

    # Translate Enum to localized string.(use i18n)
    # @note find default `Namespace.Classname.EnumMember`
    #
    # @return [String] localized string of Enum.
    def translate
      I18n.t(self.class.i18n_key(@label))
    end
    alias_method :t, :translate

    # Enum label to underscore string.
    #
    # @return [String] under_score string value(label) of Enum.
    def underscore
      @underscore_label
    end

    # Value of Enum.
    #
    # @return [Integer] Value of Enum.
    def value
      @value
    end
    alias_method :to_i, :value

    # Execute the yield(block) with each member of enum.
    #
    # @param &block [proc{|enum| .. }] execute the block.
    def self.each(&block)
      enums.each(&block)
    end

    # get all labels of Enum.
    #
    # @return [Array<Symbol>] all labels of Enum.
    def self.labels
      enum_format.keys
    end

    # get Enum length.
    #
    # @return [Integer] count of Enums.
    def self.length
      enum_format.length
    end

    # return array of Enums.
    #
    # @return [Array<Inum>] sorted array of Enums.
    def self.to_a
      enums.dup
    end

    # return hash of Enums.
    #
    # @return [Hash<Symbol, Integer>] hash of Enums.
    def self.to_h
      enum_format.dup
    end

    # Parse Object to Enum.(unsafe:An exception may occur.)
    #
    # @param object [Object] string or symbol or integer or Inum::Base.
    # @return [Inum::Base] instance of Inum::Base. or raise Exception.
    def self.parse!(object)
      case object
        when String
          self.const_get(object)
        when Symbol
          parse object.to_s
        when Integer
          parse self.enum_format.key(object).to_s
        when self
          object
        else
          raise ArgumentError, "#{object} is nani?"
      end
    end

    # Parse Object to Enum.
    #
    # @param object [Object] string or symbol or integer or Inum::Base.
    # @return [Inum::Base] instance of Inum::Base. or nil.
    def self.parse(object)
      case object
        when String
          return nil unless labels.include?(object.to_sym)
        when Symbol
          return nil unless labels.include?(object)
        when Integer
          return nil unless values.include?(object)
        when self
          # do nothing.
        else
          return nil
      end
      parse!(object)
    end

    # get all values of Enum.
    #
    # @return [Array<Integer>] all values of Enum.
    def self.values
      enum_format.values
    end


    # Define Enum in called class.
    #
    # @param label [Symbol]  label of Enum.
    # @param value [Integer] value of Enum.(default:autoincrement for 0.)
    def self.define(label, value = enum_format.size)
      value = value.to_i
      validate_enum_args!(label, value)

      enum = new(label, value)
      enum_format[label] = value

      enums.push(enum)
      self.const_set(label, enum)
    end

    # get hash of @enum_format.
    # @private
    #
    # @return [Hash] format(hash) of enum.
    def self.enum_format
      @enum_format
    end

    # get array of @enums.
    # @private
    #
    # @return [Array] array of defined enums.
    def self.enums
      @enums
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
    #
    # @note Define hash of :enum_format in child.
    def self.inherited(child)
      child.instance_variable_set(:@enum_format, Hash.new)
      child.instance_variable_set(:@enums, Array.new)
    end

    # Validate enum args, and raise exception.
    #
    # @param label [Object]  label of Enum.
    # @param value [Integer] value of Enum.
    def self.validate_enum_args!(label, value)
      unless label.instance_of?(Symbol)
        raise ArgumentError, "The label(#{label}!) isn't instance of Symbol."
      end

      if labels.include?(label)
        raise ArgumentError, "The label(#{label}!) already exists!!"
      end

      if values.include?(value)
        raise ArgumentError, "The value(#{value}!) already exists!!"
      end
    end

    private_class_method :new, :define, :validate_enum_args!
  end
end
