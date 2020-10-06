# Futurism
[![Twitter follow](https://img.shields.io/twitter/follow/julian_rubisch?style=social)](https://twitter.com/julian_rubisch)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-13-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
Lazy-load Rails partials via CableReady

:rotating_light: *Futurism is still in pre-1.0 state. As much as I hope to keep the API backwards-compatible, I cannot guarantee it* :rotating_light:

<img src="https://user-images.githubusercontent.com/4352208/88374198-9e6f3500-cd99-11ea-804b-0216ed320eff.jpg" alt="birmingham-museums-trust-GrvC6MI-z4w-unsplash" width="50%" align="center"/>
<span>Photo by <a href="https://unsplash.com/@birminghammuseumstrust?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Birmingham Museums Trust</a> on <a href="https://unsplash.com/s/photos/futurism?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Facts](#facts)
  - [Browser Support](#browser-support)
- [Usage](#usage)
- [API](#api)
  - [Resource](#resource)
  - [Explicit Partial](#explicit-partial)
  - [HTML Options](#html-options)
  - [Eager Loading](#eager-loading)
- [Events](#events)
- [Installation](#installation)
  - [Manual Installation](#manual-installation)
- [Authentication](#authentication)
- [Gotchas](#gotchas)
- [Contributing](#contributing)
- [License](#license)
- [Contributors](#contributors)

## Facts
- only one dependency: CableReady
- bundle size (without CableReady) is around [~1.04kB](https://bundlephobia.com/result?p=@minthesize/futurism@0.1.3)

### Browser Support

- Chrome v67+ (v54+ via Polyfill)
- Firefox v63+
- Edge v79+
- Safari v10.1+ via Polyfill
- iOS Safari & Chrome v10.3+ via Polyfill

[Caniuse](https://www.caniuse.com/#search=custom%20elements)

## Usage
with a helper in your template

```erb
<%= futurize @posts, extends: :div do %>
  <!-- placeholder -->
<% end %>
```

custom `<futurism-element>`s (in the form of a `<div>` or a `<tr is="futurism-table-row">` are rendered. Those custom elements have an `IntersectionObserver` attached that will send a signed global id to an ActionCable channel (`FuturismChannel`) which will then replace the placeholders with the actual resource partial.

With that method, you could lazy load every class that has to_partial_path defined (ActiveModel has by default).

You can pass the placeholder as a block:

```erb
<%= futurize @posts, extends: :tr do %>
  <td class="placeholder"></td>
<% end %>
```

![aa601dec1930151f71dbf0d6b02b61c9](https://user-images.githubusercontent.com/4352208/87131629-f768a480-c294-11ea-89a9-ea0a76ee06ef.gif)

## API

Currently there are two ways to call `futurize`, designed to wrap `render`'s behavior:

### Resource

You can pass a single `ActiveRecord` or an `ActiveRecord::Relation` to `futurize`, just as you would call `render`:

```erb
<%= futurize @posts, extends: :tr do %>
  <td class="placeholder"></td>
<% end %>
```

#### Partial Path

Remember that you can override the partial path in you models, like so:

```rb
class Post < ApplicationRecord
  def to_partial_path
    "home/post"
  end
end
```

That way you get maximal flexibility when just specifying a single resource.

### Explicit Partial

Call `futurize` with a `partial` keyword:

```erb
<%= futurize partial: "items/card", locals: {card: @card}, extends: :div do %>
  <div class="spinner"></div>
<% end %>
```

You can also use the shorthand syntax:

```erb
<%= futurize "items/card", card: @card, extends: :div do %>
  <div class="spinner"></div>
<% end %>
```

#### Collections

Collection rendering is also possible:

```erb
<%= futurize partial: "items/card", collection: @cards, extends: :div do %>
  <div class="spinner"></div>
<% end %>
```

### HTML Options

You can pass a hash of attribute/value pairs which will be mixed into the HTML markup for the placeholder element. This is important for layouts that require elements to have dimensionality. For example, many scripts calculate size based on element height and width. This option ensures that your elements have integrity, even if they are gone before you see them.

```erb
<%= futurize @posts, extends: :tr, html_options: {style: "width: 50px; height: 50px;"} do %>
  <td class="placeholder"></td>
<% end %>
```

This will output the following:

```html
<tr style="width: 50px; height: 50px;">
  <td class="placeholder"></td>
</tr>
```

### Eager Loading
It may sound surprising to support eager loading in a lazy loading library :joy:, but there's a quite simple use case:

Suppose you have some hidden interactive portion of your page, like a tab or dropdown. You don't want its content to block the initial page load, but once that is done, you occasionally don't want to wait for the element to become visible and trigger the `IntersectionObserver`, you want to lazy load its contents right after it's added to the DOM.

Futurism makes that dead simple:

```erb
<%= futurize 'some_tab', eager: true, extends: :tr do %>
  <div class="placeholder"</td>
<% end %>
```

## Events

Once your futurize element has been rendered, the `futurize:appeared` custom event will be called.

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

**! Note that the installer will run `yarn add @minthesize/futurism` for you !**

### Manual Installation
After `bundle`, install the Javascript library:

```bash
$ bin/yarn add @minthesize/futurism
```

In your `app/javascript/channels/index.js`, add the following

```js
import * as Futurism from '@minthesize/futurism'

import consumer from './consumer'

Futurism.initializeElements()
Futurism.createSubscription(consumer)
```

## Authentication
For authentication, you can rely on ActionCable identifiers, for example, if you use Devise:

```ruby
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = env["warden"].user || reject_unauthorized_connection
    end
  end
end
```

The [Stimulus Reflex Docs](https://docs.stimulusreflex.com/authentication) have an excellent section about all sorts of authentication.

## Gotchas

### ActiveStorage URLs aren't correct in development

Out of the box, Rails will prefix generated urls with `http://example.org` rather than `http://localhost`, much like ActionMailer. To amend this, add

```ruby
  # config/environments/development.rb
  config.action_controller.default_url_options = {host: "localhost", port: 3000}

  # config/environments/production.rb
  config.action_controller.default_url_options = {host: "mysite.com"}
```

to your environments.

## Contributing

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://www.julianrubisch.at"><img src="https://avatars0.githubusercontent.com/u/4352208?v=4" width="100px;" alt=""/><br /><sub><b>Julian Rubisch</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/commits?author=julianrubisch" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/darkrubyist"><img src="https://avatars2.githubusercontent.com/u/11207292?v=4" width="100px;" alt=""/><br /><sub><b>darkrubyist</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/commits?author=darkrubyist" title="Code">💻</a> <a href="https://github.com/julianrubisch/futurism/commits?author=darkrubyist" title="Documentation">📖</a></td>
    <td align="center"><a href="https://ParamagicDev.github.io/portfolio"><img src="https://avatars2.githubusercontent.com/u/26425882?v=4" width="100px;" alt=""/><br /><sub><b>Konnor Rogers</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/commits?author=ParamagicDev" title="Code">💻</a></td>
    <td align="center"><a href="https://www.andrewm.codes"><img src="https://avatars1.githubusercontent.com/u/18423853?v=4" width="100px;" alt=""/><br /><sub><b>Andrew Mason</b></sub></a><br /><a href="#maintenance-andrewmcodes" title="Maintenance">🚧</a></td>
    <td align="center"><a href="http://gorails.com"><img src="https://avatars1.githubusercontent.com/u/67093?v=4" width="100px;" alt=""/><br /><sub><b>Chris Oliver</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/commits?author=excid3" title="Code">💻</a> <a href="https://github.com/julianrubisch/futurism/pulls?q=is%3Apr+reviewed-by%3Aexcid3" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/leastbad"><img src="https://avatars2.githubusercontent.com/u/38150464?v=4" width="100px;" alt=""/><br /><sub><b>leastbad</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/commits?author=leastbad" title="Code">💻</a> <a href="https://github.com/julianrubisch/futurism/pulls?q=is%3Apr+reviewed-by%3Aleastbad" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="http://code.digimonkey.com"><img src="https://avatars0.githubusercontent.com/u/74207?v=4" width="100px;" alt=""/><br /><sub><b>M. E. Patterson</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/issues?q=author%3Amepatterson" title="Bug reports">🐛</a></td>
  </tr>
  <tr>
    <td align="center"><a href="http://fractaledmind.com"><img src="https://avatars3.githubusercontent.com/u/5077225?v=4" width="100px;" alt=""/><br /><sub><b>Stephen Margheim</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/commits?author=fractaledmind" title="Code">💻</a></td>
    <td align="center"><a href="http://hass.codes"><img src="https://avatars2.githubusercontent.com/u/1064205?v=4" width="100px;" alt=""/><br /><sub><b>Hassanin Ahmed</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/commits?author=sas1ni69" title="Code">💻</a></td>
    <td align="center"><a href="https://marcoroth.dev"><img src="https://avatars2.githubusercontent.com/u/6411752?v=4" width="100px;" alt=""/><br /><sub><b>Marco Roth</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/commits?author=marcoroth" title="Code">💻</a></td>
    <td align="center"><a href="https://viedit.com"><img src="https://avatars1.githubusercontent.com/u/49990587?v=4" width="100px;" alt=""/><br /><sub><b>Viedit com</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/commits?author=vieditcom" title="Documentation">📖</a></td>
    <td align="center"><a href="http://scottbarrow.ca"><img src="https://avatars2.githubusercontent.com/u/5571736?v=4" width="100px;" alt=""/><br /><sub><b>Scott Barrow</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/commits?author=scottbarrow" title="Code">💻</a></td>
    <td align="center"><a href="http://domchristie.co.uk"><img src="https://avatars0.githubusercontent.com/u/111734?v=4" width="100px;" alt=""/><br /><sub><b>Dom Christie</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/pulls?q=is%3Apr+reviewed-by%3Adomchristie" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="http://www.rickychilcott.com"><img src="https://avatars1.githubusercontent.com/u/445759?v=4" width="100px;" alt=""/><br /><sub><b>Ricky Chilcott</b></sub></a><br /><a href="https://github.com/julianrubisch/futurism/pulls?q=is%3Apr+reviewed-by%3Arickychilcott" title="Reviewed Pull Requests">👀</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
