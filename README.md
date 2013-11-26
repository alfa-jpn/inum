# Inum

Inum(enumerated type of Integer) provide a Java-enum-like Enum.

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
p AnimeType::EVANGELION       # => EVANGELION
p AnimeType::EVANGELION.to_i  # => 0

# parse object to instance of AnimeType.
# object can use class of Symbol or String or Integer or Self.
type = AnimeType::parse(0)
p type.equal?(AnimeType::EVANGELION) # => true (member of Enum is singleton.)

p AnimeType::HARUHI.eql?('HARUHI')   # => true (eql? can compare all parsable object.)

p AnimeType::HARUHI + 1   # => NYARUKO
p AnimeType::NYARUKO - 1  # => HARUHI

```

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


## API DOCUMENT

- [Documentation for alfa-jpn/Inum(master)](http://rubydoc.info/github/alfa-jpn/inum/frames)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
