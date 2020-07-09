# Futurism
Lazy-load Rails partials via CableReady

## Usage
with a helper in your template

```erb
<%= futurize @posts %>
```

custom `<futurism-elements>` (in the form of a `<div>` or a `<tr is="futurism-table-row">` are rendered. Those custom elements have an `IntersectionObserver` attached that will send a signed global id to an ActionCable channel (`FuturismChannel`) which will then replace the placeholders with the actual resource partial.

With that method, you could lazy load every class that has to_partial_path defined (ActiveModel has by default).

You can pass the placeholder as a block:

```erb
<%= futurize @posts do %>
  <td class="placeholder"></td>
<% end %>
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'futurism'
```

And then execute:
```bash
$ bundle
```

To copy over the javascript files to your application, run

```bash
$ bin/rails futurism:install
```


## Contributing

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
