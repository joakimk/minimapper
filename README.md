[![Build Status](https://secure.travis-ci.org/joakimk/minimapper.png)](http://travis-ci.org/joakimk/minimapper)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/joakimk/minimapper)

# Minimapper

## About

### Introduction

Minimapper is a minimalistic way of [separating models](http://martinfowler.com/eaaCatalog/dataMapper.html) from ActiveRecord. It enables you to test your models (and code using your models) within a [sub-second unit test suite](https://github.com/joakimk/fast_unit_tests_example) and makes it simpler to have a modular design as described in [Matt Wynne's Hexagonal Rails posts](http://blog.mattwynne.net/2012/04/09/hexagonal-rails-introduction/).

Minimapper follows many Rails conventions but it does not require Rails.

### Early days

The API may not be entirely stable yet and there are probably edge cases that aren't covered. However... it's most likely better to use this than to roll your own project specific solution. We need good tools for this kind of thing in the rails community, but to make that possible we need to gather around a few of them and make them good.

### Important resources

- [minimapper-extras](https://github.com/barsoom/minimapper-extras) (useful tools for projects using minimapper)
- [Gist of yet to be extracted mapper code](https://gist.github.com/joakimk/5656945) from a project using minimapper.

### Compatibility

This gem is tested against all major rubies in 1.8, 1.9 and 2.0, see [.travis.yml](https://github.com/joakimk/minimapper/blob/master/.travis.yml). For each ruby version, the mapper is tested against SQLite3, PostgreSQL and MySQL.

### Only the most basic API

This library only implements the most basic persistence API (mostly just CRUD). Any significant additions will be made into separate gems (like [minimapper-extras](https://github.com/barsoom/minimapper-extras)). The reasons for this are:

* It should be simple to maintain minimapper
* It should be possible to learn all it does in a short time
* It should have a stable API

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

Basics and how we use minimapper in practice.

``` ruby
require "rubygems"
require "minimapper"
require "minimapper/entity"
require "minimapper/mapper"

# app/models/user.rb
class User
  include Minimapper::Entity

  attributes :name, :email
  validates :name, :presence => true
end

# app/mappers/user_mapper.rb
class UserMapper < Minimapper::Mapper
  class Record < ActiveRecord::Base
    self.table_name = "users"
  end
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
# user.attributes = params[:user]
user_mapper.update(user)
p user_mapper.first.name # => Joey

## Deleting
old_id = user.id
user_mapper.delete(user)
p user.id                        # => nil
p user_mapper.find_by_id(old_id) # => nil
# user_mapper.find(old_id)       # raises ActiveRecord::RecordNotFound
# user_mapper.delete_all
# user_mapper.delete_by_id(1)

## Using a repository
require "minimapper/repository"

# config/initializers/repository.rb
Repository = Minimapper::Repository.build({
  :users    => UserMapper.new
  # :projects => ProjectMapper.new
})

user = User.new(:name => "Joe")
Repository.users.create(user)
p Repository.users.find(user.id).name # => Joe
Repository.users.delete_all

## Using ActiveModel validations
user = User.new
Repository.users.create(user)
p Repository.users.count    # => 0
p user.errors.full_messages # Name can't be blank
```

### Eager loading

When using minimapper you don't have lazy loading. We haven't gotten around to adding the association-inclusion syntax yet, but [it's quite simple to implement](https://gist.github.com/joakimk/5656945).

### Uniqueness validations and other DB validations

Validations on uniqueness can't be implemented on the entity, because they need to access the database.

Therefore, the mapper will copy over any record errors to the entity when attempting to create or update.

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
class ProjectMapper < Minimapper::AR
  def waiting_for_review
    entities_for record_class.where(waiting_for_review: true).order("id DESC")
  end
end
```

And then use it like this:

``` ruby
# Repository = Minimapper::Repository.build(...)
Repository.projects.waiting_for_review.each do |project|
  p project.name
end
```

`entity_for` returns nil for nil.

`entity_for` and `entities_for` take an optional second argument if you want a different entity class than the mapper's:

```
class ProjectMapper < Minimapper::AR
  def owner_of(project)
    owner_record = find(project).owner
    entity_for(owner_record, User)
  end
end
```

### Typed attributes and type coercion

If you specify type, Minimapper will only allow values of that type, or strings that can be coerced into that type.

The latter means that it can accept e.g. string integers directly from a form.
Minimapper aims to be much less of a form value parser than ActiveRecord, but we'll allow ourselves conveniences like this.

Supported types: Integer and DateTime.

``` ruby
class User
  include Minimapper::Entity
  attributes [ :profile_id, Integer ]

  # Or for single attributes:
  # attribute :profile_id, Integer
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

(FIXME? We're considering changing this so Minimapper core can only enforce type, and there's some `Minimapper::FormObject` mixin to parse string values.)

### Overriding attribute accessors

Attribute readers and writers are implemented so that you can override them with inheritance:

``` ruby
class User
  include Minimapper::Entity
  attribute :name

  def name
    super.upcase
  end

  def name=(value)
    super(value.strip)
  end
end
```

### Protected attributes

We recommend using [strong_parameters](https://github.com/rails/strong_parameters) for attribute security, without including `ActiveModel::ForbiddenAttributesProtection`.

Use of `attr_accessible` or `attr_protected` may obstruct the mapper.

If you use Minimapper as intended, you only assign attributes on the entity. Once they're on the entity, the mapper will assume they're permitted to be persisted; and once they're in the record, the mapper will assume they are permitted for populating an entity.

(FIXME?: There's a ongoing discussion about whether Minimapper should actively bypass attribute protection, or encourage you not to use it, or what.)

### Associations

There is no core support for associations, but we're implementing them in [minimapper-extras](https://github.com/barsoom/minimapper-extras) as we need them.

For some discussion, [see this issue](https://github.com/joakimk/minimapper/issues/3).

### Lifecycle hooks

#### after_find

This is called after any kind of find and can be used for things like loading associated data.

``` ruby
class ProjectMapper < Minimapper::AR
  private

  def after_find(entity, record)
    entity.owner = User.new(record.owner.attributes)
  end
end
```

### Deletion

When you do `mapper.delete(entity)`, it will use [ActiveRecord's `delete`](http://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy), which means that no destroy callbacks or `:dependent` association options are honored.

(FIXME?: Should we support `destroy` instead or as well?)

### Custom entity class

[Minimapper::Entity](https://github.com/joakimk/minimapper/blob/master/lib/minimapper/entity.rb) adds some convenience methods for when a model is used within a Rails application. If you don't need that you can just include the core API from the [Minimapper::Entity::Core](https://github.com/joakimk/minimapper/blob/master/lib/minimapper/entity/core.rb) module (or implement your own version that behaves like [Minimapper::Entity::Core](https://github.com/joakimk/minimapper/blob/master/lib/minimapper/entity/core.rb)).

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

You need mysql and postgres installed (but they do not have to be running) to be able to run bundle. The mapper tests use sqlite3 by default.

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
