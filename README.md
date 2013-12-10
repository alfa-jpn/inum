# Inum

Inum(enumerated type of Integer) provide a Java-enum-like Enum.
Inum has a function to localize by i18n.

## Installation

Add this line to your application's Gemfile:

    gem 'inum'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install inum

## Usage


### Define Enum(Inum)
For example create enum(inum) of Japanese Anime.

``` ruby
class AnimeType < Inum::Base
  define_enum :EVANGELION, 0
  define_enum :HARUHI,     1
  define_enum :NYARUKO,    2
end
```

If value(integer) is omitted, value(integer) is auto-incremented.

``` ruby
define_enum :EVANGELION  # => value will auto-increment.
```

### Use Enum(Inum)
How to use Enum(Inum).

``` ruby
p AnimeType::EVANGELION            # => EVANGELION
p AnimeType::EVANGELION.to_i       # => 0
p AnimeType::EVANGELION.translate  # => エヴァンゲリオン (i18n find `inum.anime_type.evangelion`.)

# parse object to instance of AnimeType.
# object can use class of Symbol or String or Integer or Self.
type = AnimeType::parse(0)
p type.equal?(AnimeType::EVANGELION) # => true (member of Enum is singleton.)

p AnimeType::HARUHI.eql?('HARUHI')   # => true (eql? can compare all parsable object.)

p AnimeType::HARUHI + 1   # => NYARUKO
p AnimeType::NYARUKO - 1  # => HARUHI

# can use each method.
AnimeType::each {|enum| p enum }

```

can use Enumerable and Comparable.

- more detail is [Class::Base](http://rubydoc.info/github/alfa-jpn/inum/Inum/Base)

### Use define\_check\_method
define\_check\_method can extend your class.

``` ruby
class Anime
  extend Inum::DefineCheckMethod
  
  attr_accessor :type

  define_check_method :type, AnimeType
end

```

define\_check\_method generates methods for type confirmation. 

``` ruby
anime = Anime.new
anime.type = AnimeType::NYARUKO

p anime.evangelion? # => false
p anime.nyaruko?    # => true


# type can use all parsable object.
anime.type = 1
p anime.haruhi? # => true

```

### Localize(i18n)
to_t methods localize enum by i18n.
default i18n key is inum.{name_space}.{class_name}.{enum_member_label}.
If change default, Override i18n_key class method.

``` ruby
# default i18n_key.
def self.i18n_key(label)
  Inum::Utils::underscore("inum::#{self.name}::#{label}")
end
```

example

``` yaml
ja:
  inum:
    anime_type:
      evangelion: 'エヴァンゲリオン'
      haruhi:     'ハルヒ'
      nyaruko:    '這いよれ！ニャル子さん'
```

## API DOCUMENT

- [Documentation for alfa-jpn/Inum(master)](http://rubydoc.info/github/alfa-jpn/inum/frames)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# I have poor English. Please help meeeeeeeee!!!!
