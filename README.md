![Build status](https://secure.travis-ci.org/joakimk/minimapper.png) | [builds](https://travis-ci.org/#!/joakimk/minimapper/builds)

# Minimapper

A minimalistic way of separating your models from ORMs like ActiveRecord that allows you to swap out your persistance layer for an in-memory implementation in tests or use different persistance for different models.

If you're following good style you're probably already pushing all knowledge of your ORM down into your models or model-layer classes. This takes it a step further and let's you work with your models without depending on heavy frameworks like rails or needing a database.

Minimapper is a partial [repository-pattern](http://martinfowler.com/eaaCatalog/repository.html) implementation (it implements repositories and data mappers but not critera builders).

## Only the most basic API

This library only implements the most basic persistance API (mostly just CRUD). Any significant additions will be made into separate gems (with names like "minimapper-FOO").

The reasons for this are:
* You should be able to feel secure about depending on the API
* It should be possible to learn all it does in a short time
* It should be simple to add an adapter for a new database
* It should be simple to maintain minimapper

## Compatibility

This gem is tested against all major rubies in both 1.8 and 1.9, see [.travis.yml](https://github.com/joakimk/minimapper/blob/master/.travis.yml). For each ruby version, the SQL mappers are tested against SQLite3, PostgreSQL and MySQL.

## Installation

Add this line to your application's Gemfile:

    gem 'minimapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minimapper

Please avoid installing directly from the github repository. Code will be pushed there that might fail in [CI](https://travis-ci.org/#!/joakimk/minimapper/builds), gem releases are only done when CI is green.

## Usage

You can use the mappers directly like this:

``` ruby
class User < Minimapper::Entity
  attributes :name, :email
  validates :name, presence: true
end

class UserMapper < Minimapper::Memory
end

# Creating
user = User.new(name: "Joe")
mapper = UserMapper.new
mapper.create(user)

# Finding
user = mapper.find(1)

# Updating
user.name = "Joey"
mapper.update(user)

# Deleting
mapper.delete(user)

# Deleting all
mapper.delete_all
```

Or though a repository:

``` ruby
repository = Minimapper::Repository.build({
  users:    UserMapper.new,
  projects: ProjectMapper.new
})

repository.users.find(1)
```

## Using the ActiveRecord mapper

``` ruby
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

## Implementing custom queries

*todo* show how, talk about shared examples.

## Implementing another mapper

*todo*: how to use the shared examples

## Inspiration

Jason Roelofs:
* [Designing a Rails App](http://jasonroelofs.com/2012/05/29/designing-a-rails-app-part-1/) (find the whole series of posts)

Robert "Uncle Bob" Martin:
* [Architecture: The Lost Years](http://www.confreaks.com/videos/759-rubymidwest2011-keynote-architecture-the-lost-years)
* [The Clean Architecture](http://blog.8thlight.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Running the tests

You need mysql and postgres installed (but they do not have to be running) to be able to run bundle. The sql-mapper tests use sqlite3 by default.

    bundle
    rake

## Contributing

0. Read "Only the most basic API" above
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Don't forget to write test
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
