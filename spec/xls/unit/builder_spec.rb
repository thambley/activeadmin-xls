require 'spec_helper'

module ActiveAdmin
  # tests for builder
  module Xls
    describe Builder do
      let(:builder) { Builder.new(Post) }
      let(:content_columns) { Post.content_columns }

      context 'the default builder' do
        it 'has no header style' do
          expect(builder.header_style).to eq({})
        end
        it 'has no i18n scope' do
          expect(builder.i18n_scope).to be_nil
        end
        it 'has default columns' do
          expect(builder.columns.size).to eq(content_columns.size + 1)
        end
      end

      context 'customizing a builder' do
        it 'deletes columns we tell it we dont want' do
          builder.delete_columns :id, :body
          expect(builder.columns.size).to eq(content_columns.size - 1)
        end

        it 'lets us use specific columns in a list' do
          builder.only_columns :title, :author
          expect(builder.columns.size).to eq(2)
        end

        it 'lets us say we dont want the header' do
          builder.skip_header
          expect(builder.instance_values['skip_header']).to be_truthy
        end

        it 'lets us add custom columns' do
          builder.column(:hoge)
          expect(builder.columns.size).to eq(content_columns.size + 2)
        end

        it 'lets us clear all columns' do
          builder.clear_columns
          expect(builder.columns.size).to eq(0)
        end

        context 'Using Procs for delayed content generation' do
          let(:post) { Post.new(title: 'Hot Dawg') }

          before do
            builder.column(:hoge) do |resource|
              "#{resource.title} - with cheese"
            end
          end

          it 'stores the block when defining a column for later execution.' do
            expect(builder.columns.last.data).to be_a(Proc)
          end

          it 'evaluates custom column blocks' do
            expect(builder.columns.last.data.call(post)).to eq(
              'Hot Dawg - with cheese'
            )
          end
        end
      end

      context 'sheet generation without headers' do
        let!(:users) { [User.new(first_name: 'bob', last_name: 'nancy')] }

        let!(:posts) do
          [Post.new(title: 'bob', body: 'is a swell guy', author: users.first)]
        end

        let!(:builder) do
          options = {
            header_format: { weight: :bold },
            i18n_scope: %i[xls post]
          }
          Builder.new(Post, options) do
            skip_header
          end
        end

        before do
          # disable clean up so we can get the book.
          allow(builder).to receive(:clean_up) { false }
          # @book = Spreadsheet.open(builder.serialize(posts))
          builder.serialize(posts)
          @book = builder.send(:book)
          @collection = builder.collection
        end

        it 'does not serialize the header' do
          expect(@book.worksheets.first[0, 0]).not_to eq('Title')
        end
      end

      context 'whitelisted sheet generation' do
        let!(:users) { [User.new(first_name: 'bob', last_name: 'nancy')] }

        let!(:posts) do
          [Post.new(title: 'bob', body: 'is a swell guy', author: users.first)]
        end

        let!(:builder) do
          Builder.new(Post, header_style: {}, i18n_scope: %i[xls post]) do
            skip_header
            whitelist
            column :title
          end
        end

        before do
          allow(User).to receive(:all) { users }
          allow(Post).to receive(:all) { posts }
          # disable clean up so we can get the book.
          allow(builder).to receive(:clean_up) { false }
          builder.serialize(Post.all)
          @book = builder.send(:book)
          @collection = builder.collection
        end

        it 'does not serialize the header' do
          sheet = @book.worksheets.first
          expect(sheet.column_count).to eq(1)
          expect(sheet[0, 0]).to eq(@collection.first.title)
        end
      end

      context 'Sheet generation with a highly customized configuration.' do
        let!(:builder) do
          options = {
            header_style: { size: 10, color: 'red' },
            i18n_scope: %i[xls post]
          }
          Builder.new(Post, options) do
            delete_columns :id, :created_at, :updated_at
            column(:author) do |resource|
              "#{resource.author.first_name} #{resource.author.last_name}"
            end
            after_filter do |sheet|
              row_number = sheet.dimensions[1]
              sheet.update_row(row_number)
              row_number += 1
              sheet.update_row(row_number, 'Author Name', 'Number of Posts')
              users = collection.map(&:author).uniq(&:id)
              users.each do |user|
                row_number += 1
                sheet.update_row(row_number,
                                 "#{user.first_name} #{user.last_name}",
                                 user.posts.size)
              end
            end
            before_filter do |sheet|
              users = collection.map(&:author)
              users.each do |user|
                user.first_name = 'Set In Proc' if user.first_name == 'bob'
              end
              row_number = sheet.dimensions[1]
              sheet.update_row(row_number, 'Created', Time.zone.now)
              row_number += 1
              sheet.update_row(row_number, '')
            end
          end
        end

        before do
          Post.all.each(&:destroy)
          User.all.each(&:destroy)
          @user = User.create!(first_name: 'bob', last_name: 'nancy')
          @post = Post.create!(title: 'bob',
                               body: 'is a swell guy',
                               author: @user)
          # disable clean up so we can get the book.
          allow(builder).to receive(:clean_up) { false }
          builder.serialize(Post.all)
          @book = builder.send(:book)
          @collection = builder.collection
        end

        it 'provides the collection object' do
          expect(@collection.count).to eq(Post.all.count)
        end

        it 'merges our customizations with the default header style' do
          expect(builder.header_style[:size]).to eq(10)
          expect(builder.header_style[:color]).to eq('red')
          # expect(builder.header_style[:pattern_bg_color]).to eq('00')
        end

        it 'uses the specified i18n_scope' do
          expect(builder.i18n_scope).to eq(%i[xls post])
        end

        it 'translates the header row based on our i18n scope' do
          header_row = @book.worksheets.first.row(2)
          expect(header_row).to eq(
            ['Title', 'Content', 'Published On', 'Publisher']
          )
        end

        it 'processes the before filter' do
          expect(@book.worksheets.first.cell(0, 0)).to eq('Created')
        end

        it 'lets us work against the collection in the before filter' do
          expect(@book.worksheets.first.last_row[0]).to eq('Set In Proc nancy')
        end
      end
    end
  end
end
