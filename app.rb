#! /usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'erb'
enable :method_override

json_file_path = 'memo.json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class Memo
  def self.uuid
    SecureRandom.uuid
  end

  def self.find_all
    File.open('memo.json') do |file|
      JSON.parse(file.read)
    end
  end
end

get '/memos' do
  @memos = Memo.find_all

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
  memos = Memo.find_all

  File.open(json_file_path, 'w') do |file|
    memo = { id: Memo.uuid, title: title, description: description }
    memos << memo
    JSON.dump(memos, file)
  end

  redirect '/memos'
end

get '/memos/:id' do
  memos = Memo.find_all
  @memo = memos.find { |file| file['id'] == params[:id] }

  @title = '詳細'
  erb :show, locals: { md: markdown(:md_template) }
end

get '/memos/:id/edit' do
  memos = Memo.find_all
  @memo = memos.find { |file| file['id'] == params[:id] }

  @title = '編集'
  erb :edit, locals: { md: markdown(:md_template) }
end

patch '/memos/:id' do
  memos = Memo.find_all

  edited_title = params[:edited_title]
  edited_description = params[:edited_description]

  memo = memos.find { |file| file['id'] == params[:id] }
  memo['title'] = edited_title
  memo['description'] = edited_description

  File.open(json_file_path, 'w') do |file|
    JSON.dump(memos, file)
  end

  redirect redirect '/memos'
end

delete '/memos/:id' do
  memos = Memo.find_all

  memos.delete_if { |file| file['id'] == params[:id] }

  File.open(json_file_path, 'w') do |file|
    JSON.dump(memos, file)
  end

  redirect '/memos'
end
