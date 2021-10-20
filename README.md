# メモアプリ

メモを作成できるアプリケーションです。

# How to use

1. 任意のディレクトリにて git clone してください。

```
$ git clone https://github.com/fuwa-syugyo/memo_app_fuwa.git
```

2. Bundlerを使って必要なGemをインストールしてください。
```
$ bundle install   
```

3. `memo`DBを作成し、接続してください。
```
$ createdb memo -O {user_name};    
```

```
$ psql -d memo   
```

4. `memos`テーブルを作成してください。
```
$ CREATE TABLE memos
(id serial,
title text not null,
description text,
PRIMARY KEY(id));
```

5. cloneしたディレクトリでアプリケーションを起動してください。
```
$ bundle exec ruby app.rb    
```
6. ローカルホストで以下のURLにアクセスしてください。
```
http://localhost:4567/memos
```
