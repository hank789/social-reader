module SearchHelper
  def search_autocomplete_opts(term)
    return unless current_user

    resources_results = [
      posts_autocomplete(term)
    ].flatten

    generic_results = default_autocomplete
    generic_results.select! { |result| result[:label] =~ Regexp.new(term, "i") }

    [
      resources_results,
      generic_results
    ].flatten.uniq do |item|
      item[:label]
    end
  end

  private

  # Autocomplete results for various settings pages
  def default_autocomplete
    [
      { label: "My Profile settings", url: profile_path },
      { label: "My SSH Keys",         url: profile_keys_path },
      { label: "My Dashboard",        url: root_path },
      { label: "Admin Section",       url: admin_root_path },
    ]
  end

  # Autocomplete results for the current user's posts
  def posts_autocomplete(term, limit = 5)
    Post.publicish(current_user).search_by_title(term).limit(limit).map do |p|
      {
        label: "post: #{search_result_sanitize(p.title)}",
        url: p.link
      }
    end
  end

  def search_result_sanitize(str)
    Sanitize.clean(str)
  end
end
