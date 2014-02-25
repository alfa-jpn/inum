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
    # @param options [Hash] option
    # @option options [Symbol]    :column     Binding column.          (require)
    # @option options [Inum:Base] :class      Binding enum.            (require)
    # @option options [Symbol]    :prefix     Prefix.                  (default: "{option[:column]}_")
    # @option options [Bool]      :validation Enable validation        (default: true)
    # @option options [Bool]      :allow_nil  Allow nil when validate. (default: false)
    def bind_inum(options)
      opts = {
        allow_nil:  false,
        prefix:     options[:column],
        validation: true,
      }.merge(options)
      opts[:prefix] = (opts[:prefix].nil?)? '' : "#{opts[:prefix]}_"

      self.class_eval do
        if opts[:validation]
          validates opts[:column], {
            allow_nil: opts[:allow_nil],
            inclusion: {in: opts[:class].to_a},
          }
        end

        define_method("#{opts[:column]}") do
          opts[:class].parse(read_attribute(opts[:column]))
        end

        define_method("#{opts[:column]}=") do |value|
          enum  = opts[:class].parse(value)
          if enum
            write_attribute(opts[:column], enum.to_i)
          else
            write_attribute(opts[:column], nil)
          end
        end

        opts[:class].each do |enum|
          define_method("#{opts[:prefix]}#{enum.underscore}?") do
            enum.eql?(send(opts[:column]))
          end
        end
      end
    end
  end
end
