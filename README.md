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
class AnimeTypes < Inum::Base
  define :EVANGELION, 0
  define :HARUHI,     1
  define :NYARUKO,    2
end
```

If the value(integer) is omitted, It is auto-incremented.(deprecated.)

### Use Enum(Inum)
How to use Enum(Inum).

``` ruby
p AnimeTypes::EVANGELION.label      # => :EVANGELION
p AnimeTypes::EVANGELION.to_s       # => "EVANGELION"
p AnimeTypes::EVANGELION.value      # => 0 (can use to_i.)
p AnimeTypes::EVANGELION.translate  # => エヴァンゲリオン (I18n.t will be called with `anime_types.evangelion`.)

# Parse object.
# This method is parsable Symbol and String and Integer and Self.
p AnimeTypes.parse(1) # => AnimeTypes::HARUHI

# Compare object.
p AnimeTypes::HARUHI.eql?('HARUHI')   # => true (This method can compare all parsable object.)

# each method.
AnimeTypes.each {|enum| p enum}

# Get length
AnimeTypes.length # => 3

# Get labels and values
AnimeTypes.labels # => [:EVANGELION, :HARUHI, :NYARUKO]
AnimeTypes.values # => [0, 1, 2]

# Get collection array.
AnimeTypes.collection # => [["EVANGELION", 0], ["HARUHI", 1], ....]

# collection usually use with some rails view helpers.
# f.select :name, Enum.collection
# f.select :name, Enum.collection(except:[:EVANGELION])
# f.select :name, Enum.collection(only:[:EVANGELION])
```

can use Enumerable and Comparable.

- more detail is [Class::Base](http://rubydoc.info/github/alfa-jpn/inum/Inum/Base)

### If use ActiveRecord, can use bind\_inum

``` ruby
class Favorite < ActiveRecord::Base
  bind_inum :anime, AnimeTypes
end
```

bind\_enum wrap accessor of column.

``` ruby
fav = Favorite.new(anime: AnimeTypes::NYARUKO)

# #getter will return instance of AnimeTypes.
p fav.anime.t # => '這いよれ！ニャル子さん' t is aliased translate.

# #setter can set parsable object.
anime.type = 1
anime.type = '1'
anime.type = 'NYARUKO'

# check methods.
p fav.anime_evangelion? # => false
```

### Localize(i18n)
translate methods localize enum by i18n.
default i18n key is `#{name_space}.#{class_name}.#{label}`.

``` yaml
ja:
  anime_types:
    evangelion: 'エヴァンゲリオン'
    haruhi:     'ハルヒ'
    nyaruko:    '這いよれ！ニャル子さん'
```

If you want to change key of i18n, Override i18n_key class method.

``` ruby
class AnimeTypes < Inum::Base
  def self.i18n_key(underscore_class_path, underscore_label)
    "inums.#{underscore_class_path}.#{label}"
  end
end
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
