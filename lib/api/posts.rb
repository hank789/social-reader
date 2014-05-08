module API
  # Posts API
  class Posts < Grape::API
    before { authenticate! }

    resource :posts do
      # Get currently authenticated user's posts
      #
      # Example Request:
      #   GET /posts
      get do
        present paginate(current_user.posts), with: Entities::Post
      end
    end

    resource :projects do
      # Get a list of project posts
      #
      # Parameters:
      #   id (required) - The ID of a project
      # Example Request:
      #   GET /projects/:id/posts
      get ":id/posts" do
        present paginate(user_project.posts), with: Entities::Post
      end

      # Get a single project post
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   post_id (required) - The ID of a project post
      # Example Request:
      #   GET /projects/:id/posts/:post_id
      get ":id/posts/:post_id" do
        @post = user_project.posts.find(params[:post_id])
        present @post, with: Entities::Post
      end

      # Create a new project post
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   title (required) - The title of an post
      #   description (optional) - The description of an post
      #   assignee_id (optional) - The ID of a user to assign post
      #   milestone_id (optional) - The ID of a milestone to assign post
      #   labels (optional) - The labels of an post
      # Example Request:
      #   POST /projects/:id/posts
      post ":id/posts" do
        required_attributes! [:title]
        attrs = attributes_for_keys [:title, :description, :assignee_id, :milestone_id]
        attrs[:label_list] = params[:labels] if params[:labels].present?
        post = ::Posts::CreateService.new(user_project, current_user, attrs).execute

        if post.valid?
          present post, with: Entities::Post
        else
          not_found!
        end
      end

      # Update an existing post
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   post_id (required) - The ID of a project post
      #   title (optional) - The title of an post
      #   description (optional) - The description of an post
      #   assignee_id (optional) - The ID of a user to assign post
      #   milestone_id (optional) - The ID of a milestone to assign post
      #   labels (optional) - The labels of an post
      #   state_event (optional) - The state event of an post (close|reopen)
      # Example Request:
      #   PUT /projects/:id/posts/:post_id
      put ":id/posts/:post_id" do
        post = user_project.posts.find(params[:post_id])
        authorize! :modify_post, post

        attrs = attributes_for_keys [:title, :description, :assignee_id, :milestone_id, :state_event]
        attrs[:label_list] = params[:labels] if params[:labels].present?

        post = ::Posts::UpdateService.new(user_project, current_user, attrs).execute(post)

        if post.valid?
          present post, with: Entities::Post
        else
          not_found!
        end
      end

      # Delete a project post (deprecated)
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   post_id (required) - The ID of a project post
      # Example Request:
      #   DELETE /projects/:id/posts/:post_id
      delete ":id/posts/:post_id" do
        not_allowed!
      end
    end
  end
end
