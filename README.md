Active Admin Xls: Excel Spreadsheet Export for Active Admin
====================================

**Git**:[http://github.com/thambley/activeadmin-xls](http://github.com/thambley/activeadmin-xls)

**Author**:  Todd Hambley

**Copyright**:    2014 ~ 2016

**License**: MIT License

**Latest Version**: 1.0.3

**Release Date**: 2014.09.21

Synopsis
--------

This gem provides xls downloads for Active Admin resources.

This gem borrows heavily from [https://github.com/randym/activeadmin-axlsx](https://github.com/randym/activeadmin-axlsx) and [https://github.com/splendeo/to_xls](https://github.com/splendeo/to_xls).


Usage example:

Add the following to your Gemfile and you are good to go.
All resource index views will now include a link for download directly
to xls.

```
gem 'activeadmin-xls'
```

Cool Toys
---------

Here are a few quick examples of things you can easily tweak.

## localize column headers

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  config.xls_builder.i18n_scope = [:active_record, :models, :posts]
end
```

## Use blocks for adding computed fields

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  config.xls_builder.column('author_name') do |resource|
    resource.author.name
  end
end
```

## Change the column header format

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  config.xls_builder.header_format = { :weight => :bold,
                                       :color => :blue }
end
```

## Remove columns

```ruby
# app/admin/posts.rb
ActiveAdmin.register Post do
  config.xls_builder.delete_columns :id, :created_at, :updated_at
end
```

# Using the DSL

Everything that you do with the config's default builder can be done via
the resource DSL.

Below is an example of the DSL

```ruby
ActiveAdmin.register Post do

  # i18n_scope and header style are set via options
  xlsx(:i18n_scope => [:active_admin, :xls, :post],
       :header_style => {:weight => :bold, :color => :blue }) do

    # Specify that you want to white list column output.
    # whitelist

    # Do not serialize the header, only output data.
    # skip_header

    # deleting columns from the report
    delete_columns :id, :created_at, :updated_at

    # adding a column to the report
    column(:author) { |resource| "#{resource.author.first_name} #{resource.author.last_name}" }

    # creating a chart and inserting additional data with after_filter
    after_filter { |sheet|
      # todo
    }

    # iserting data with before_filter
    before_filter do |sheet|
      # todo
    end
  end
end
```

# Specs
------
Running specs for this gem requires that you construct a rails application.
To execute the specs, navigate to the gem directory,
run bundle install and run these to rake tasks:

```
bundle exec rake setup
```

```
bundle exec rake
```

# Copyright and License
----------

activeadmin-xls &copy; 2014 by [Todd Hambley](mailto:thambley@travelleaders.com).

activeadmin-xls is licensed under the MIT license. Please see the LICENSE document for more information.
