![Build status](https://secure.travis-ci.org/joakimk/minimapper.png) | [builds](https://travis-ci.org/#!/joakimk/minimapper/builds)

# WIP

This is work in progress. It's being extracted from https://github.com/joakimk/deployer.

# Minimapper

A minimalistic way of separating your models from ORMs like ActiveRecord that allows you to swap out your persistance layer for an in-memory implementation in tests or use different persistance for different models and so on.

If you're following good style, you're probably already pushing all knowledge of your ORM down into your models or model-layer classes. This takes it a step further and let's you work with your models without depending on heavy frameworks like rails or needing a database.

Minimapper is a partial [repository-pattern](http://martinfowler.com/eaaCatalog/repository.html) implementation. It implements repositories and data mappers but not critera builders.

## Keeping it small

This library only implements the most basic persistance API (mostly just CRUD). Any significant additions will be made into separate gems (with names like "minimapper-FOO").

The reasons for this are:
* It should be possible to learn all it does in a short time
* You should be able to feel secure about depending on the API
* It should be simple to add an adapter for a new database
* It should be simple to maintain minimapper

## Compatibility

This gem is tested against all major rubies in both 1.8 and 1.9, see [.travis.yml](https://github.com/joakimk/minimapper/blob/master/.travis.yml).

## Installation

Add this line to your application's Gemfile:

    gem 'minimapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minimapper

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

*todo*: shared examples, possibly move AR into a minimapper-ar gem and recommend the same for other mappers.b

## Inspiration

Jason Roelofs:
* [Designing a Rails App](http://jasonroelofs.com/2012/05/29/designing-a-rails-app-part-1/) (find the whole series of posts)

Robert "Uncle Bob" Martin:
* [Architecture: The Lost Years](http://www.confreaks.com/videos/759-rubymidwest2011-keynote-architecture-the-lost-years)
* [The Clean Architecture](http://blog.8thlight.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Contributing

0. Read "Keeping it small" above
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
