#! /usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'erb'
enable :method_override

hash_array = []
json_file_path = 'memo.json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/memos' do
  @memo_parse = File.open(json_file_path) do |file|
    JSON.parse(file.read)
  end

  @title = 'トップページ'
  erb :index, locals: { md: markdown(:md_template) }
end

get '/memos/new' do
  @title = '新規作成'
  erb :new, locals: { md: markdown(:md_template) }
end

post '/memos' do
  title = params[:title]
  description = params[:description]

  memo_parse = File.open(json_file_path) do |file|
    JSON.parse(file.read)
  end

  File.open(json_file_path, 'w') do |file|
    hash_array = memo_parse.to_a

    hash = { id: SecureRandom.uuid, title: title, description: description }
    hash_array << hash
    JSON.dump(hash_array, file)
  end

  redirect '/memos'
end

get '/memos/:id' do
  memo_parse = File.open(json_file_path) do |file|
    JSON.parse(file.read)
  end
  @memo_hash = memo_parse.find { |hash| hash['id'] == params[:id] }

  @title = '詳細'
  erb :show, locals: { md: markdown(:md_template) }
end

get '/memos/:id/edit' do
  buffer = File.open(json_file_path, 'r') do |file|
    JSON.parse(file.read)
  end
  @memo_hash = buffer.find { |hash| hash['id'] == params[:id] }

  @title = '編集'
  erb :edit, locals: { md: markdown(:md_template) }
end

patch '/memos/:id' do
  edited_title = params[:edited_title]
  edited_description = params[:edited_description]

  memo_data = File.open(json_file_path) do |file|
    JSON.parse(file.read)
  end

  memo_hash = memo_data.find { |hash| hash['id'] == params[:id] }
  memo_hash['title'] = edited_title
  memo_hash['description'] = edited_description

  File.open(json_file_path, 'w') do |file|
    JSON.dump(memo_data, file)
  end

  redirect redirect '/memos'
end

delete '/memos/:id' do
  memo_data = File.open(json_file_path) do |file|
    JSON.parse(file.read)
  end

  memo_data.delete_if { |hash| hash['id'] == params[:id] }

  File.open(json_file_path, 'w') do |file|
    JSON.dump(memo_data, file)
  end

  redirect '/memos'
end
