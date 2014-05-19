class SearchController < ApplicationController
  include SearchHelper

  def show
    @search_results = Search::GlobalService.new(current_user, params).execute
  end

  def autocomplete
    term = params[:term]
    @post = Post.find(params[:post_id]) if params[:post_id].present?

    render json: search_autocomplete_opts(term).to_json
  end
end
