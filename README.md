# A Ruby gem for [Giftbit](http://www.giftbit.com) API

[![Travis CI](http://img.shields.io/travis/modernmsg/giftbit/master.svg)](https://travis-ci.org/modernmsg/giftbit)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'giftbit'
```

And then execute:

```
bundle
```

Or install it yourself as:

```
gem install giftbit
```

## Usage

```ruby
Giftbit.auth = 'token'

Giftbit.funds
# {"info"=>{"code"=>"INFO_FUNDS", "name"=>"Fund information retrieved", ...}

Giftbit.create_gift subject: 'Subject string',
  message: 'Extended message',
  contacts: [
    firstname: user.first_name,
    lastname:  user.last_name,
    email:     user.email,
  ],
  marketplace_gifts: [{id: 1234, price_in_cents: 500}],
  expiry: (Date.today + 30).to_s,
  delivery_type: 'GIFTBIT_EMAIL'
```

See the [code](https://github.com/modernmsg/giftbit/blob/v1.0.0/lib/giftbit.rb#L28) for more API methods.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
