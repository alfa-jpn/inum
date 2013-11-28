require 'rspec'
require 'spec_helper'

describe Inum::Utils do

  it 'underscore can convert CamelCasedWord to underscore_word.' do
    expect(Inum::Utils::underscore('camelcase')).to     eq('camelcase')
    expect(Inum::Utils::underscore('CamelCase')).to     eq('camel_case')
    expect(Inum::Utils::underscore('CamelCaseWord')).to eq('camel_case_word')
    
    expect(Inum::Utils::underscore('Came1Case')).to eq('came1_case')

    expect(Inum::Utils::underscore('UNDER_SCORE')).to eq('under_score')
    expect(Inum::Utils::underscore('under_score')).to eq('under_score')

    expect(Inum::Utils::underscore('name::space')).to eq('name.space')
    expect(Inum::Utils::underscore('Name::Space')).to  eq('name.space')
  end
  
  it 'underscore can convert Symbol to underscore_word.' do
    expect(Inum::Utils::underscore(:CamelCase)).to eq('camel_case')
  end
end
