module Inum
  module DefineCheckMethod

    # define compare method.
    #
    # @param variable_name [String]     name of variable.
    # @param enum_class    [Inum::Base] class of extended Enum::EnumBase.
    def define_check_method(variable_name, enum_class)
      self.class_eval do
        enum_class::DEFINED_ENUMS.each_key do |enum_name|
          define_method("#{enum_name.downcase}?") do
            enum_class::parse(send(variable_name)) == enum_class::parse(enum_name)
          end
        end
      end
    end

  end
end
