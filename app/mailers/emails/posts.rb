module Emails
  module Posts
    def new_post_email(recipient_id, post_id)
      @post = Post.find(post_id)
      @project = @post.project
      @target_url = project_post_url(@project, @post)
      mail(from: sender(@post.author_id),
           to: recipient(recipient_id),
           subject: subject("#{@post.title} (##{@post.iid})"))
    end

    def reassigned_post_email(recipient_id, post_id, previous_assignee_id, updated_by_user_id)
      @post = Post.find(post_id)
      @previous_assignee = User.find_by(id: previous_assignee_id) if previous_assignee_id
      @project = @post.project
      @target_url = project_post_url(@project, @post)
      mail(from: sender(updated_by_user_id),
           to: recipient(recipient_id),
           subject: subject("#{@post.title} (##{@post.iid})"))
    end

    def closed_post_email(recipient_id, post_id, updated_by_user_id)
      @post = Post.find post_id
      @project = @post.project
      @updated_by = User.find updated_by_user_id
      @target_url = project_post_url(@project, @post)
      mail(from: sender(updated_by_user_id),
           to: recipient(recipient_id),
           subject: subject("#{@post.title} (##{@post.iid})"))
    end

    def post_status_changed_email(recipient_id, post_id, status, updated_by_user_id)
      @post = Post.find post_id
      @post_status = status
      @project = @post.project
      @updated_by = User.find updated_by_user_id
      @target_url = project_post_url(@project, @post)
      mail(from: sender(updated_by_user_id),
           to: recipient(recipient_id),
           subject: subject("#{@post.title} (##{@post.iid})"))
    end
  end
end
