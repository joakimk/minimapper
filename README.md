# WIP

This is work in progress. It's being extracted from https://github.com/joakimk/deployer.

# Minimapper

A minimalistic way of separating your models from ORMs like ActiveRecord. This separation allows you to swap out your persistance layer for an in-memory implementation in tests, or use different persistance for different models, etc.

If you're following good style, you're probably already pushing all knowledge of ActiveRecord down into your models or model-layer classes and away from controllers and mailers, etc. This takes it a step further and let's you work with your models without loading rails or needing a database.

## Keeping it small

I intend to keep this library small. It should be possible to learn all it does in a short time, so that you can feel secure about depending on it. The most important thing is that the code is stable, well-tested and bug-free.

Any significant addons will be made into separate gems (with names like "minimapper-FOO").

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

# Persisting
user = User.new(name: "Joe")
mapper = UserMapper.new
mapper.add(user)

# Finding
user = mapper.find(1)

# Updating
user.name = "Joey"
mapper.update(user)

# Removing
mapper.delete(user)

# Removing all
mapper.delete_all
```

Or though a repository:

``` ruby
MemoryRepo = Minimapper::Repository.build({
  users: UserMapper.new
})

repository = MemoryRepo
MemoryRepo.users.find(1)
```

Using the ActiveRecord mapper:

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
mapper.add(user)
```

## Inspiration

Jason Roelofs:
* [Designing a Rails App](http://jasonroelofs.com/2012/05/29/designing-a-rails-app-part-1/) (find the whole series of posts)

Robert "Uncle Bob" Martin:
* [Architecture: The Lost Years](http://www.confreaks.com/videos/759-rubymidwest2011-keynote-architecture-the-lost-years)
* [The Clean Architecture](http://blog.8thlight.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Implementing another mapper

# todo: shared examples, possibly move AR into a minimapper-ar gem and recommend the same for other mappers.

## Contributing

0. Read "Keeping it small" above
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
