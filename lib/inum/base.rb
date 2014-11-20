module Inum
  require 'active_support/inflector'
  require 'i18n'

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
      @label        = label
      @label_string = label.to_s
      @value        = value

      @underscore_class_path = self.class.name ? ActiveSupport::Inflector.underscore(self.class.name).gsub('/', '.') : ''
      @underscore_label      = ActiveSupport::Inflector.underscore(label).gsub('/', '.')
    end

    # Compare object.
    #
    # @param object [Object] parsable object.
    # @return [Integer] same normal <=>.
    def <=> (object)
      if other = self.class.parse(object)
        @value <=> other.to_i
      else
        nil
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
      @label_string
    end

    # Translate Enum to localized string.(use i18n)
    # @note find default `Namespace.Classname.EnumMember`
    #
    # @return [String] localized string of Enum.
    def translate
      I18n.t(self.class.i18n_key(@underscore_class_path, @underscore_label))
    end
    alias_method :t, :translate

    # Value of Enum.
    #
    # @return [Integer] Value of Enum.
    def value
      @value
    end
    alias_method :to_i, :value

    # Get collection.
    # @note Type of usable with a Rails form helper.
    # @exapmle
    #  f.select :name, Enum.collection
    #  f.select :name, Enum.collection(except:[:HOGE])      # Except Enum::HOGE
    #  f.select :name, Enum.collection(only:[:HOGE, :FUGA]) # Only Enum::HOGE and Enum::FUGA
    #
    # @param option [Hash] Options.
    # @option option [Array<Symbol>] except Except enum.
    # @option option [Array<Symbol>] only   Limit enum.
    # @return [Array<Array>] collection. ex `[["HOGE", 0], ["FUGA", 1]]`
    def self.collection(option = {})
      map { |e|
        next if option[:except] and option[:except].include?(e.label)
        next if option[:only]   and !option[:only].include?(e.label)
        [e.translate, e.value]
      }.compact
    end

    # Execute the yield(block) with each member of enum.
    #
    # @yield [enum] execute the block with enums.
    # @yieldparam [Inum::Base] enum enum.
    def self.each(&block)
      @enums.each(&block)
    end

    # Override the rule of i18n keys.
    # @abstract if change the rule of i18n keys.
    #
    # @param underscore_class_path [String] underscore class name.
    # @param underscore_label      [String] underscore label.
    # @return [String] i18n key.
    def self.i18n_key(underscore_class_path, underscore_label)
      "#{underscore_class_path}.#{underscore_label}"
    end

    # get all labels of Enum.
    #
    # @return [Array<Symbol>] all labels of Enum.
    def self.labels
      @enums.map(&:label)
    end

    # get Enum length.
    #
    # @return [Integer] count of Enums.
    def self.length
      @enums.length
    end

    # Parse object to Enum.
    #
    # @param object [Object] string or symbol or integer or Inum::Base.
    # @return [Inum::Base, Nil] enum or nil.
    def self.parse(object)
      case object
      when String
        if /^\d+$/.match(object)
          parse(object.to_i)
        else
          upcase = object.upcase
          find {|e| e.to_s == upcase}
        end
      when Symbol
        upcase = object.upcase
        find {|e| e.label == upcase}
      when Integer
        find {|e| e.value == object}
      when self
        object
      else
        nil
      end
    end

    # Parse object to Enum.
    # @raise [Inum::NotDefined] raise if not found.
    #
    # @param object [Object] string or symbol or integer or Inum::Base.
    # @return [Inum::Base] enum.
    def self.parse!(object)
      parse(object) || raise(Inum::NotDefined)
    end

    # return array of Enums.
    #
    # @return [Array<Inum>] sorted array of Enums.
    def self.to_a
      @enums.dup
    end

    # get all values of Enum.
    #
    # @return [Array<Integer>] all values of Enum.
    def self.values
      @enums.map(&:value)
    end

    # Define Enum.
    #
    # @param label [Symbol]  label of Enum.
    # @param value [Integer] value of Enum.(default:autoincrement for 0.)
    def self.define(label, value = @enums.size)
      validate_enum_args!(label, value)

      new(label, value).tap do |enum|
        const_set(label, enum)
        @enums.push(enum)
      end
    end

    # Initialize inherited class.
    def self.inherited(child)
      child.instance_variable_set(:@enums, Array.new)
    end

    # Validate enum args.
    # @raise [ArgumentError] If argument is wrong.
    #
    # @param label [Object]  label of Enum.
    # @param value [Integer] value of Enum.
    def self.validate_enum_args!(label, value)
      unless label.instance_of?(Symbol)
        raise ArgumentError, "#{label} isn't instance of Symbol."
      end

      if labels =~ /[^A-Z\d_]/
        raise ArgumentError, "#{label} is wrong constant name. Label allow uppercase and digits and underscore."
      end

      if labels.include?(label)
        raise ArgumentError, "#{label} already exists label."
      end

      if values.include?(value)
        raise ArgumentError, "#{value} already exists value."
      end
    end

    private_class_method :new, :define, :validate_enum_args!
  end
end
