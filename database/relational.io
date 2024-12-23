Table users {
  id int64 [primary key]
  username varchar[256]
  followers_count integer
  following_count integer
}

Table follows {
  id int64
  created_at timestamp
  follower_id int64
  following_id int64
}
Ref: follows.follower_id > users.id
Ref: follows.following_id > users.id

Table posts {
  id int64 [primary key]
  created_at timestamp
  author_id int64
  text text [note: 'max 3000']
  location_id int64
  like_count integer
  dislike_count integer
}
Ref: posts.author_id > users.id
Ref: posts.location_id > locations.id

Table attachments {
  id int64 [primary key]
  post_id int64
  url varchar[256]
}
Ref: attachments.post_id > posts.id

Table locations {
  id int64 [primary key]
  place_name varchar[256]
  latitude int64
  longitude int64
}

Table comments {
  id int64 [primary key]
  created_at timestamp
  post_id int64
  user_id int64
  text text [note: 'max 1000']
}
Ref: comments.post_id > posts.id
Ref: comments.user_id > users.id

Table reactions {
  id int64 [primary key]
  created_at timestamp
  post_id int64
  user_id int64
  is_like bool
}
Ref: reactions.post_id > posts.id
Ref: reactions.user_id > users.id
