![Build status](https://secure.travis-ci.org/joakimk/minimapper.png) | [builds](https://travis-ci.org/#!/joakimk/minimapper/builds)

# Minimapper

## About

### Introduction

A minimalistic way of separating your models from ORMs like ActiveRecord that allows you to swap out your persistence layer for an in-memory implementation in tests or use different persistence for different models.

If you're following good style you're probably already pushing all knowledge of your ORM down into your models or model-layer classes. This takes it a step further and let's you work with your models without depending on heavy frameworks like rails or needing a database.

Minimapper is a partial [repository-pattern](http://martinfowler.com/eaaCatalog/repository.html) implementation (it implements repositories and data mappers but not criteria builders).

### Only the most basic API

This library only implements the most basic persistence API (mostly just CRUD). Any significant additions will be made into separate gems (with names like "minimapper-FOO").

The reasons for this are:

* You should be able to depend on the API
* It should be possible to learn all it does in a short time
* It should be simple to add an adapter for a new database
* It should be simple to maintain minimapper

### Compatibility

This gem is tested against all major rubies in both 1.8 and 1.9, see [.travis.yml](https://github.com/joakimk/minimapper/blob/master/.travis.yml). For each ruby version, the SQL mappers are tested against SQLite3, PostgreSQL and MySQL.

## Installation

Add this line to your application's Gemfile:

    gem 'minimapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minimapper

Please avoid installing directly from the github repository. Code will be pushed there that might fail in [CI](https://travis-ci.org/#!/joakimk/minimapper/builds) (because testing all permutations of ruby versions and databases locally isn't practical). Gem releases are only done when CI is green.

## Usage

### Basics

You can use the mappers like this (**it's runnable, try copy and pasting it into a ruby file**):

``` ruby
# minimapper_test.rb
require "rubygems"
require "minimapper"
require "minimapper/entity"
require "minimapper/memory"

class User < Minimapper::Entity
  attributes :name, :email
  validates :name, :presence => true
end

class UserMapper < Minimapper::Memory
end

## Creating
user = User.new(:name => "Joe")
mapper = UserMapper.new
mapper.create(user)

## Finding
user = mapper.find(user.id)
puts user.name             # => Joe
puts mapper.first.name     # => Joe

## Updating
user.name = "Joey"
mapper.update(user)
puts mapper.first.name    # => Joey

## Deleting
old_id = user.id
mapper.delete(user)
puts user.id                   # => nil
puts mapper.find_by_id(old_id) # => nil
# mapper.find(old_id)          # raises Minimapper::Common::CanNotFindEntity
# mapper.delete_all
# mapper.delete_by_id(1)

## Using a repository
require "minimapper/repository"

repository = Minimapper::Repository.build({
  :users    => UserMapper.new
  # :projects => ProjectMapper.new
})

user = User.new(:name => "Joe")
repository.users.create(user)
puts repository.users.find(user.id).name # => Joe

## Using ActiveModel validations
user = User.new
repository.users.create(user)
puts repository.users.count    # => 0
puts user.errors.full_messages # Name can't be blank
```

### ActiveRecord

This is not directly runnable like the previous example, it requires ActiveRecord, a database and a users table. Isn't it interesting how much you could do without those things in the previous example? :)

When you do need to use an ORM like ActiveRecord however, it now has the same API as your in-memory persistence (thanks to the [shared tests](https://github.com/joakimk/minimapper/blob/master/spec/support/shared_examples/mapper.rb) which define how a mapper is supposed to behave).

``` ruby
require "minimapper/ar"

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

### Custom queries

You can write custom queries like this:

``` ruby
# Memory implementation
module Memory
  class ProjectMapper < Minimapper::Memory
    def waiting_for_review
      all.find_all { |p| p.waiting_for_review }.sort_by(&:id).reverse
    end
  end
end

# ActiveRecord implementation
module AR
  class ProjectMapper < Minimapper::AR
    def waiting_for_review
      record_klass.where(waiting_for_review: true).order("id DESC").map do |record|
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
  puts project.name
end
```

It gets simpler to maintain if you use shared tests to test both implementations. For inspiration, see the [shared tests](https://github.com/joakimk/minimapper/blob/master/spec/support/shared_examples/mapper.rb) used to test minimapper.

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

* Extract entity and model class lookup code from the ar-mapper and reuse it in the memory mapper.
* Change the memory mapper to store entity attributes, not entity instances.
  - Unless this makes it difficult to handle associated data, need to find a good way to handle that.
* Make Minimapper::Entity a module so you won't have to inherit from it.
* Make using Minimapper::Entity optional by providing shared examples of the behavior required by the mappers. Test the mappers with an object implementing only this behavior.

### Ideas

I won't implement anything that isn't actually used. But here are some ideas for things that might make it into minimapper someday if there is a need for it.

* Provide a hook to convert attributes between entities and the backing models (when your entity attributes and db-schema isn't a one-to-one match).
* Copy validation errors back from the mapper to the entity (for example if you do uniqueness validation in a backing ActiveRecord-model).

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
