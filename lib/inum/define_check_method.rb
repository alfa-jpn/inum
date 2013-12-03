module Inum
  # DefinedCheckMethod module should be extend.
  #
  # @example
  #   class Fruit
  #     extend Inum::DefineCheckMethod
  #     define_check_method :type, FruitType
  #
  #     attr_accessor :type
  #   end
  #
  module DefineCheckMethod
    require 'inum/utils'

    # Define compare method in class.
    #
    # @param variable_name [String]     name of variable.
    # @param enum_class    [Inum::Base] class of extended Enum::EnumBase.
    def define_check_method(variable_name, enum_class)
      self.class_eval do
        enum_class::each do |enum|
          define_method("#{enum.to_u}?") do
            enum.eql?(send(variable_name))
          end
        end
      end
    end
  end
end
