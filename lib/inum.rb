require 'i18n'

require 'inum/version'
require 'inum/base'
require 'inum/active_record_mixin.rb'

module Inum
  if Object.const_defined?(:ActiveRecord)
    ActiveRecord::Base.send :extend, Inum::ActiveRecordMixin
  end
end
