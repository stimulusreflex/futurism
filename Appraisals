if RUBY_VERSION >= "2.7"
  appraise "rails-7-0" do
    gem "rails", "7.0.0.alpha2"
    gem "sqlite3", "~> 1.4"
  end
end

appraise "rails-6-1" do
  gem "rails", "~> 6.1"
  gem "sqlite3", "~> 1.4"
end

appraise "rails-6-0" do
  gem "rails", "~> 6.0"
  gem "sqlite3", "~> 1.4"
end

if RUBY_VERSION < "3.0"
  appraise "rails-5-2" do
    gem "rails", "~> 5.2"
    gem "sqlite3", "~> 1.3", "< 1.4"
    gem "action-cable-testing"
  end
end
