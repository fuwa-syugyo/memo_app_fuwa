#! /usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'erb'
require 'pg'
enable :method_override

connection = PG.connect(dbname: 'memo')

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class Memo
  def self.find_all(connection)
    connection.exec('SELECT * FROM memos') do |result|
      result.map do |row|
        row
      end
    end
  end

  def self.create_memo(connection, title, description)
    connection.exec('INSERT INTO memos (title, description) values ($1, $2)', [title, description])
  end

  def self.update_memo(connection, id, title, description)
    connection.exec('UPDATE memos SET title = $1, description = $2 WHERE id = $3', [title, description, id])
  end

  def self.delete_memo(connection, id)
    connection.exec('DELETE FROM memos WHERE id = $1', [id])
  end
end

get '/memos' do
  @memos = Memo.find_all(connection)

  @title = 'トップページ'
  erb :index, locals: { md: markdown(:md_template) }
end

get '/memos/new' do
  @title = '新規作成'
  erb :new, locals: { md: markdown(:md_template) }
end

post '/memos' do
  Memo.create_memo(connection, params[:title], params[:description])

  redirect '/memos'
end

get '/memos/:id' do
  memos = Memo.find_all(connection)
  @memo = memos.find { |memo| memo['id'] == params[:id] }

  @title = '詳細'
  erb :show, locals: { md: markdown(:md_template) }
end

get '/memos/:id/edit' do
  memos = Memo.find_all(connection)
  @memo = memos.find { |memo| memo['id'] == params[:id] }

  @title = '編集'
  erb :edit, locals: { md: markdown(:md_template) }
end

patch '/memos/:id' do
  memos = Memo.find_all(connection)
  edited_title = params[:edited_title]
  edited_description = params[:edited_description]
  memo_data = memos.find { |memo| memo['id'] == params[:id] }
  memo_data['title'] = edited_title
  memo_data['description'] = edited_description

  Memo.update_memo(connection, params[:id], edited_title, edited_description)

  redirect redirect '/memos'
end

delete '/memos/:id' do
  Memo.delete_memo(connection, params[:id])

  redirect '/memos'
end
