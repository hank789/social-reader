# == Schema Information
#
# Table name: posts
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  assignee_id  :integer
#  author_id    :integer
#  project_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#  position     :integer          default(0)
#  branch_name  :string(255)
#  description  :text
#  milestone_id :integer
#  state        :string(255)
#  iid          :integer
#

class Post < ActiveRecord::Base

  belongs_to :author
  acts_as_taggable_on :author_post_tag
  acts_as_taggable_on :author_post_mention
  # For Hash only
  serialize :data
  validates :author, presence: true
  validates_uniqueness_of :guid, :scope => :provider

  default_value_for :title, ''

  scope :authored, ->(user) { where(author_id: user) }
  scope :recent, -> { order("created_at DESC") }

  ActsAsTaggableOn.strict_case_match = true

  has_many :events
  has_many :photos
  belongs_to :author

  attr_accessible :title, :author_id, :position, :description, :guid, :provider, :data, :favourite_count, :link, :created_at, :updated_at
                  :label_list

  acts_as_taggable_on :labels

  class << self
    def search query
      where("posts.title LIKE :query OR posts.description LIKE :query", query: "%#{query}%")
    end

    def search_by_description query
      where("LOWER(posts.description) LIKE :query", query: "%#{query.downcase}%")
    end

    def publicish(user)
      joins('LEFT JOIN events ON posts.id = events.post_id').where('events.user_id = ?', user.id)
    end

    def add_rss_feed_post(entry, feed)
      author = Author.new
      author.provider = feed.id
      author.name = feed.name
      author.guid = feed.url
      author.slug = feed.url
      author.remote_avatar_url = "https://plus.google.com/_/favicon?domain=#{feed.url.split('/')[2]}"
      author.profile_url = "http://" + feed.url.split('/')[2]

      if !author.save
        author_exist = Author.where(provider: feed.id, guid: feed.url).first
        author.id = author_exist.id
        author.save
      end
      Post.create(provider: feed.id,
                   title: entry.title,
                   link: entry.url,
                   description: extract_rss_content(entry),
                   position: 0,
                   author_id: author.id,
                   favourite_count: 0,
                   created_at: entry.published || Time.now,
                   updated_at: entry.published || Time.now,
                   guid: entry.id)
    end

    def extract_rss_content(entry)
      sanitized_content = ""

      if entry.content
        sanitized_content = rss_sanitize(entry.content)
      elsif entry.summary
        sanitized_content = rss_sanitize(entry.summary)
      end

      rss_expand_absolute_urls(sanitized_content, entry.url)
    end

    def rss_sanitize(content)
      Loofah.fragment(content.gsub(/<wbr\s*>/i, ""))
      .scrub!(:prune)
      .scrub!(:unprintable)
      .to_s
    end

    def rss_expand_absolute_urls(content, base_url)
      doc = Nokogiri::HTML.fragment(content)
      abs_re = URI::DEFAULT_PARSER.regexp[:ABS_URI]

      [["a", "href"], ["img", "src"], ["video", "src"]].each do |tag, attr|
        doc.css("#{tag}[#{attr}]").each do |node|
          url = node.get_attribute(attr)
          unless url =~ abs_re
            unless base_url =~ abs_re
              node.set_attribute(attr, URI.join(base_url, url).to_s)
            end
          end
        end
      end

      doc.to_html
    end

    def rss_count
      Post.where("provider >= 1").count
    end
  end
  # Reset issue events cache
  #
  # Since we do cache @event we need to reset cache in special cases:
  # * when an issue is updated
  # Events cache stored like  events/23-20130109142513.
  # The cache key includes updated_at timestamp.
  # Thus it will automatically generate a new fragment
  # when the event is updated because the key changes.
  def reset_events_cache
    Event.where(target_id: self.id, target_type: 'Post').
      order('id DESC').limit(100).
      update_all(updated_at: Time.now)
  end

end
