# Active Admin Xls

Excel Spreadsheet Export for [Active Admin]

[![Version][rubygems_badge]][rubygems]
[![Quality][codeclimate_badge]][codeclimate]

## Synopsis

This gem provides xls downloads for Active Admin resources.

This gem borrows heavily from [activeadmin-axlsx] and [to_xls].

Usage example:

Add the following to your Gemfile and you are good to go.
All resource index views will now include a link for download directly
to xls.

```ruby
gem 'activeadmin-xls', '~>1.1.0'
```

For Active Admin 1.0, you will also have to update config/initializers/active_admin.rb.  Update the download\_links setting to include xls:

```ruby
config.download_links = %i[csv xml json xls]
```

## Dependencies

This gem depends on [spreadsheet] to generate xls files.

## Examples

Here are a few quick examples of things you can easily tweak.

### Localize column headers

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  config.xls_builder.i18n_scope = [:active_record, :models, :posts]
end
```

### Use blocks for adding computed fields

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  config.xls_builder.column('author_name') do |resource|
    resource.author.name
  end
end
```

### Change the column header format

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  config.xls_builder.header_format = { weight: :bold,
                                       color: :blue }
end
```

### Remove columns

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  config.xls_builder.delete_columns :id, :created_at, :updated_at
end
```

### Restrict columns to a list

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  config.xls_builder.only_columns :title, :author
end
```

## Using the DSL

Everything that you do with the config's default builder can be done via
the resource DSL.

Below is an example of the DSL

```ruby
ActiveAdmin.register Post do

  # i18n_scope and header style are set via options
  xls(i18n_scope: [:active_admin, :xls, :post],
      header_format: { weight: :bold, color: :blue }) do

    # Specify that you want to white list column output.
    # whitelist

    # Do not serialize the header, only output data.
    # skip_header

    # restrict columns to a list without customization
    # only_columns :title, :author

    # deleting columns from the report
    delete_columns :id, :created_at, :updated_at

    # adding a column to the report with customization
    column(:author) { |post| "#{post.author.first_name} #{post.author.last_name}" }

    # inserting additional data with after_filter
    after_filter do |sheet|
      # todo
    end

    # inserting data with before_filter
    before_filter do |sheet|
      # todo
    end
  end
end
```

## Testing

Running specs for this gem requires that you construct a rails application.

To execute the specs, navigate to the gem directory, run bundle install and run these to rake tasks:

### Rails 3.2

```text
bundle install --gemfile=gemfiles/rails_32.gemfile
```

```text
BUNDLE_GEMFILE=gemfiles/rails_32.gemfile bundle exec rake setup
```

```text
BUNDLE_GEMFILE=gemfiles/rails_32.gemfile bundle exec rake
```

### Rails 4.2

```text
bundle install --gemfile=gemfiles/rails_42.gemfile
```

```text
BUNDLE_GEMFILE=gemfiles/rails_42.gemfile bundle exec rake setup
```

```text
BUNDLE_GEMFILE=gemfiles/rails_42.gemfile bundle exec rake
```

[Active Admin]:https://www.activeadmin.info/
[activeadmin-axlsx]:https://github.com/randym/activeadmin-axlsx
[to_xls]:https://github.com/splendeo/to_xls
[spreadsheet]:https://github.com/zdavatz/spreadsheet

[rubygems_badge]: https://badge.fury.io/rb/activeadmin-xls.svg
[rubygems]: https://badge.fury.io/rb/activeadmin-xls
[codeclimate_badge]: https://api.codeclimate.com/v1/badges/e294712bac54d4520182/maintainability
[codeclimate]: https://codeclimate.com/github/thambley/activeadmin-xls/maintainability