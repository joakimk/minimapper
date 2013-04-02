[![Build Status](https://secure.travis-ci.org/joakimk/minimapper.png)](http://travis-ci.org/joakimk/minimapper)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/joakimk/minimapper)

# Minimapper

## About

### Introduction

Minimapper is a minimalistic way of separating models from ORMs like ActiveRecord. It enables you to test your models (and code using your models) within a [sub-second unit test suite](https://github.com/joakimk/fast_unit_tests_example) and makes it simpler to have a modular design as described in [Matt Wynne's Hexagonal Rails posts](http://blog.mattwynne.net/2012/04/09/hexagonal-rails-introduction/).

Minimapper comes with an in-memory implementation of common CRUD operations. You can use this in tests to not hit the database where it isn't nessesary to do so. You can also develop new features without having to think about migrations until you need to persist data.

Minimapper is not an ORM, instead it's a tool to make it simpler to handle persistence in existing applications using ORMs like ActiveRecord. It may also be an attractive alternative to using DataMapper 2 (when it's done) for new apps if you already know ActiveRecord well (most of the rails developers I know have many years of experience with ActiveRecord).

### Early days

The API may not be entirely stable yet and there are probably edge cases that aren't covered. However... it's most likely better to use this than to roll your own project specific solution. We need good tools for this kind of thing in the rails community, but to make that possible we need to gather around a few of them and make them good.

### Compatibility

This gem is tested against all major rubies in 1.8, 1.9 and 2.0, see [.travis.yml](https://github.com/joakimk/minimapper/blob/master/.travis.yml). For each ruby version, the SQL mappers are tested against SQLite3, PostgreSQL and MySQL.

### Only the most basic API

This library only implements the most basic persistence API (mostly just CRUD). Any significant additions will be made into separate gems. The reasons for this are:

* It should have a stable API
* It should be possible to learn all it does in a short time
* It should be simple to add an adapter for a new database
* It should be simple to maintain minimapper

## Installation

Add this line to your application's Gemfile:

    gem 'minimapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minimapper

You also need the `activemodel` gem if you use Minimapper::Entity and not only Minimapper::Entity::Core.

Please avoid installing directly from the github repository. Code will be pushed there that might fail in [CI](https://travis-ci.org/#!/joakimk/minimapper/builds) (because testing all permutations of ruby versions and databases locally isn't practical). Gem releases are only done when CI is green.

## Usage

### Basics

You can use the mappers like this (<strong>it's runnable, try copy and pasting it into a ruby file</strong> or [use this gist](https://gist.github.com/3904952)):

``` ruby
# minimapper_example.rb
require "rubygems"
require "minimapper"
require "minimapper/entity"
require "minimapper/mapper/memory"

class User
  include Minimapper::Entity

  attributes :name, :email
  validates :name, :presence => true
end

class UserMapper < Minimapper::Mapper::Memory
end

## Creating
user = User.new(:name => "Joe")
user_mapper = UserMapper.new
user_mapper.create(user)

## Finding
user = user_mapper.find(user.id)
p user.name              # => Joe
p user_mapper.first.name # => Joe

## Updating
user.name = "Joey"
user_mapper.update(user)
p user_mapper.first.name # => Joey

## Deleting
old_id = user.id
user_mapper.delete(user)
p user.id                        # => nil
p user_mapper.find_by_id(old_id) # => nil
# user_mapper.find(old_id)       # raises Minimapper::EntityNotFound
# user_mapper.delete_all
# user_mapper.delete_by_id(1)

## Using a repository
require "minimapper/repository"

repository = Minimapper::Repository.build({
  :users    => UserMapper.new
  # :projects => ProjectMapper.new
})

user = User.new(:name => "Joe")
repository.users.create(user)
p repository.users.find(user.id).name # => Joe
repository.users.delete_all

## Using ActiveModel validations
user = User.new
repository.users.create(user)
p repository.users.count    # => 0
p user.errors.full_messages # Name can't be blank
```

### ActiveRecord

This is not directly runnable like the previous example, it requires ActiveRecord, a database and a users table. Isn't it interesting how much you could do without those things in the previous example? :)

When you do need to use an ORM like ActiveRecord however, it now has the same API as your in-memory persistence (thanks to the [shared tests](https://github.com/joakimk/minimapper/blob/master/spec/support/shared_examples/mapper.rb) which define how a mapper is supposed to behave).

``` ruby
require "minimapper/mapper/ar"

module AR
  class UserMapper < Minimapper::AR
  end

  class User < ActiveRecord::Base
    attr_accessible :name, :email
  end
end

user = User.new(name: "Joe")
mapper = AR::UserMapper.new
mapper.create(user)
```

### Uniqueness validations and other DB validations

Validations on uniqueness can't be implemented on the entity, because they need to access the database.

Therefore, the ActiveRecord mapper will copy over any record errors to the entity when attempting to create or update.

Add these validations to the record itself, like:

``` ruby
class User < ActiveRecord::Base
  validates :email, :uniqueness => true
end
```

Note that just calling `valid?` on the entity will not access the database. Errors copied over from the record will remain until the next attempt to create or update.

So an entity that wouldn't be unique in the database will be `valid?` before you attempt to create it. And after you attempt to create it, the entity will not be `valid?` even after assigning a new value, until you attempt to create it again.

### Custom queries

You can write custom queries like this:

``` ruby
# Memory implementation
module Memory
  class ProjectMapper < Minimapper::Mapper::Memory
    def waiting_for_review
      all.find_all { |p| p.waiting_for_review }.sort_by(&:id).reverse
    end
  end
end

# ActiveRecord implementation
module AR
  class ProjectMapper < Minimapper::AR
    def waiting_for_review
      record_class.where(waiting_for_review: true).order("id DESC").map do |record|
        entity_for(record)
      end
    end
  end
end
```

And then use it like this:

``` ruby
# repository = Minimapper::Repository.build(...)
repository.projects.waiting_for_review.each do |project|
  p project.name
end
```

It gets simpler to maintain if you use shared tests to test both implementations. For inspiration, see the [shared tests](https://github.com/joakimk/minimapper/blob/master/spec/support/shared_examples/mapper.rb) used to test minimapper.

`entity_for` returns nil for nil.

It takes an optional second argument if you want a different entity class than the mapper's:

```
class ProjectMapper < Minimapper::AR
  def owner_of(project)
    owner_record = find(project).owner
    entity_for(owner_record, User)
  end
end
```

### Typed attributes

If you specify type, minimapper will attempt to convert into that type. Supported types: Integer and DateTime (:integer and :date_time).

``` ruby
class User
  include Minimapper::Entity
  attributes [ :profile_id, :integer ]

  # Or for single attributes:
  # attribute :profile_id, :integer
end

User.new(:profile_id => "10").profile_id      # => 10
User.new(:profile_id => " 10 ").profile_id    # => 10
User.new(:profile_id => " ").profile_id       # => nil
User.new(:profile_id => "foobar").profile_id  # => nil
```

You can add your own type conversions like this:

``` ruby
require "date"

class ToDate
  def convert(value)
    Date.parse(value) rescue nil
  end
end

Minimapper::Entity::Convert.register_converter(:date, ToDate.new)

class User
  include Minimapper::Entity
  attributes [ :reminder_on, :date ]
end

User.new(:reminder_on => "2012-01-01").reminder # => #<Date: 2012-01-01 ...>
```

Minimapper only calls #convert on non-empty strings. When the value is blank or nil, the attribute is set to nil.

### Associations

There is no built in support for associations yet, but you can handle them manually (see https://github.com/joakimk/minimapper/issues/3).

### Custom entity class

[Minimapper::Entity](https://github.com/joakimk/minimapper/blob/master/lib/minimapper/entity.rb) adds some convenience methods for when a model is used within a rails application. If you don't need that you can just include the core API from the [Minimapper::Entity::Core](https://github.com/joakimk/minimapper/blob/master/lib/minimapper/entity/core.rb) module (or implement your own version that behaves like [Minimapper::Entity::Core](https://github.com/joakimk/minimapper/blob/master/lib/minimapper/entity/core.rb)).

### Adding a new mapper

If you where to add a [Mongoid](http://mongoid.org/en/mongoid/index.html) mapper:

1. Start by copying *spec/ar_spec.rb* to *spec/mongoid_spec.rb* and adapt it for Mongoid.
2. Add any setup code needed in *spec/support/database_setup.rb*.
3. Get the [shared tests](https://github.com/joakimk/minimapper/blob/master/spec/support/shared_examples/mapper.rb) to pass for *spec/mongoid_spec.rb*.
4. Ensure all other tests pass.
5. Send a pull request.
6. As soon as it can be made to work in travis in all ruby versions that apply (in Mongoid's case that is only the 1.9 rubies), I'll merge it in.

## Inspiration

### People

Jason Roelofs:

* [Designing a Rails App](http://jasonroelofs.com/2012/05/29/designing-a-rails-app-part-1/) (find the whole series of posts)

Robert "Uncle Bob" Martin:

* [Architecture: The Lost Years](http://www.confreaks.com/videos/759-rubymidwest2011-keynote-architecture-the-lost-years)
* [The Clean Architecture](http://blog.8thlight.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Apps

* About 4 people at [Barsoom](http://barsoom.se/) are currently working full time on building a rails app that uses minimapper. We'll be extending minimapper as we go.
* The deploy status app that minimapper was extracted from: [https://github.com/joakimk/deployer](https://github.com/joakimk/deployer)

## Contributing

### Running the tests

You need mysql and postgres installed (but they do not have to be running) to be able to run bundle. The sql-mapper tests use sqlite3 by default.

    bundle
    rake

### Steps

0. Read "Only the most basic API" above
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Don't forget to write tests
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## Todo

### Next

* Make it possible to override minimapper attributes with super (like it's done in https://github.com/barsoom/traco)
* Support default values for attributes (probably only using lambdas to avoid bugs).
* Built in way to set induvidual attributes in a way that bypasses protected attributes like you can do with an AR model.
  - user.is_admin = true; user_mapper.update(user) should probably set is_admin to true, mass-assignment should not.
* Extract entity and model class lookup code from the ar-mapper and reuse it in the memory mapper.
* Change the memory mapper to store entity attributes, not entity instances.
  - Unless this makes it difficult to handle associated data.

### Ideas

I won't implement anything that isn't actually used. But here are some ideas for things that might make it into minimapper someday if there is a need for it.

* Provide a hook to convert attributes between entities and the backing models (when your entity attributes and db-schema isn't a one-to-one match).

## Credits and license

By [Joakim Kolsjö](https://twitter.com/joakimk) under the MIT license:

>  Copyright (c) 2012 Joakim Kolsjö
>
>  Permission is hereby granted, free of charge, to any person obtaining a copy
>  of this software and associated documentation files (the "Software"), to deal
>  in the Software without restriction, including without limitation the rights
>  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>  copies of the Software, and to permit persons to whom the Software is
>  furnished to do so, subject to the following conditions:
>
>  The above copyright notice and this permission notice shall be included in
>  all copies or substantial portions of the Software.
>
>  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>  THE SOFTWARE.
