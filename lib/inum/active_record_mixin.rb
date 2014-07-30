module Inum
  # Mixin module to ActiveRecord.
  #
  # @example
  #   class Fruit < ActiveRecord::Base
  #     bind_enum :type, FruitType
  #   end
  #
  module ActiveRecordMixin
    # Define compare method in class.
    #
    # @param column     [Symbol]      Binding column name.
    # @param enum_class [Inum::Base]  Binding Enum.
    # @param options    [Hash]        option
    # @option options [Symbol]    :prefix     Prefix. (default: column)
    def bind_inum(column, enum_class, options = {})
      options = { prefix: column }.merge(options)
      options[:prefix] = options[:prefix] ? "#{options[:prefix]}_" : ''

      self.class_eval do
        define_method(column) do
          enum_class.parse(read_attribute(column))
        end

        define_method("#{column}=") do |value|
          enum_class.parse(value).tap do |enum|
            if enum
              write_attribute(column, enum.to_i)
            else
              write_attribute(column, nil)
            end
          end
        end

        enum_class.each do |enum|
          define_method("#{options[:prefix]}#{enum.to_s.underscore}?") do
            enum.eql?(read_attribute(column))
          end
        end
      end
    end
  end
end
