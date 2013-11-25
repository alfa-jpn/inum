module Inum
  class Base
    attr_accessor :value
    private_class_method :new

    def initialize(value)
      unless self.class.defined_enums.has_value?(value)
        raise ArgumentError, "unknown value #{value}!"
      end
      @value = value
    end

    def to_i
      @value
    end

    def to_s
      self.class.defined_enums.key(@value).to_s
    end

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
    def self.define_enum(name, value)
      if name == :DEFINED_ENUMS
        raise ArgumentError, "#{name} is keyword."
      end

      if defined_enums.has_value?(value)
        raise ArgumentError, "#{name}'s value(#{value}!) already exists!!"
      end

      defined_enums[name] = value
      self.const_set(name, new(value))
    end

    def self.defined_enums
      self.const_get(:DEFINED_ENUMS)
    end

    def self.inherited(child)
      child.const_set(:DEFINED_ENUMS, Hash.new)
    end
  end
end
