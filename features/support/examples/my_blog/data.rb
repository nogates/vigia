module Vigia
  module Examples
    class MyBlog
      class Data

        POST_1 = {
          slug:  'my-awesome-first-post',
          title: 'My awesome first post',
          body:  'Here is my post. It is a short one!'
        }
        POSTS  = [ POST_1 ]
        COMMENT_1 = {
          title:     'Lurker',
          body:      'First!',
          post_slug: 'my-awesome-first-post'
        }
        COMMENTS  = [ COMMENT_1 ]

        class << self
         def [] key
            case key
            when '/posts'
              POSTS
            when '/post_create'
              POST_1.merge(slug: 'second-post', title: 'Second post!!', body: 'I am on fire')
            when '/posts/post_1'
              POST_1
            when '/posts/1/comments'
              COMMENTS
            when '/posts/1/comment_create'
              COMMENT_1.merge(title: 'Hey yo!', body: 'Not bad')
            when '/posts/1/comment_update'
              COMMENT_1.merge(title: 'Hey yo!', body: 'Updated!')
            else
              raise('Invalid Fixture')
            end
         end
        end
      end
    end
  end
end

