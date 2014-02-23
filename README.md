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
  define :EVANGELION, 0
  define :HARUHI,     1
  define :NYARUKO,    2
end
```

If value(integer) is omitted, value(integer) is auto-incremented.

``` ruby
define :EVANGELION  # => value will auto-increment.
```

### Use Enum(Inum)
How to use Enum(Inum).

``` ruby
p AnimeType::EVANGELION.label      # => :EVANGELION (if use to_s, return "EVANGELION")
p AnimeType::EVANGELION.value      # => 0 (can use to_i.)
p AnimeType::EVANGELION.translate  # => エヴァンゲリオン (i18n find `inum.anime_type.evangelion`.)

# parse object to instance of AnimeType.
# object can use class of Symbol or String or Integer or Self.
type = AnimeType.parse(0)
p AnimeType::HARUHI.eql?('HARUHI')   # => true (eql? can compare all parsable object.)

p AnimeType::HARUHI + 1   # => NYARUKO
p AnimeType::NYARUKO - 1  # => HARUHI

# each method.
AnimeType::each {|enum| p enum }

```

can use Enumerable and Comparable.

- more detail is [Class::Base](http://rubydoc.info/github/alfa-jpn/inum/Inum/Base)

### if use ActiveRecord, can use bind\_inum

``` ruby
class Anime < ActiveRecord::Base
  bind_inum :column => :type, :class => AnimeType
end

# if set prefix.
class Anime < ActiveRecord::Base
  bind_inum :column => :type, :class => AnimeType, :prefix => nil # remove prefix, when prefix is nil.
end

```

bind\_enum generates useful methods and validation.

``` ruby
anime = Anime.new(type: AnimeType::NYARUKO)
p anime.type.t # => '這いよれ！ニャル子さん' t is aliased translate.

p anime.type_evangelion? # => false
p anime.type_nyaruko?    # => true


# type can use all parsable object.
anime.type = 1
p anime.type_haruhi? # => true

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
