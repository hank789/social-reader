module Search
  class GlobalService
    attr_accessor :current_user, :params

    def initialize(user, params)
      @current_user, @params = user, params.dup
    end

    def execute
      query = params[:search]
      query = Shellwords.shellescape(query) if query.present?
      return result unless query.present?

      result[:posts] = Post.publicish(current_user).search(query).order('updated_at DESC').limit(20)
      result[:total_results] = %w(posts).sum { |items| result[items.to_sym].size }
      result
    end

    def result
      @result ||= {
        posts: [],
        total_results: 0,
      }
    end
  end
end
