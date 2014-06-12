class CreateRssFeeds < ActiveRecord::Migration
  def self.up
    create_table "rss_feeds", force: true do |t|
      t.string   "name"
      t.string   "url"
      t.datetime "last_fetched"
      t.string   "last_fetched_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "status"
    end

    add_index "rss_feeds", ["name"], name: "index_rss_feeds_on_name", unique: true, using: :btree
    add_index "rss_feeds", ["url"], name: "index_rss_feeds_on_url", unique: true, using: :btree

    create_table "rss_categories", force: true do |t|
      t.string   "name"
      t.integer  "parent_id"
      t.string   "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "status"
      t.integer  "select_type", default: 0
    end
    add_index "rss_categories", ["parent_id"], name: "index_rss_categories_on_parent_id", using: :btree

    create_table "rss_feeds_rss_categories", force: true do |t|
      t.integer  "rss_feed_id"
      t.integer  "rss_category_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "rss_feeds_rss_categories", ["rss_category_id"], name: "index_rss_feeds_rss_categories_on_rss_category_id", using: :btree
    add_index "rss_feeds_rss_categories", ["rss_feed_id"], name: "index_rss_feeds_rss_categories_on_rss_feed_id", using: :btree

    execute "INSERT INTO rss_categories (name, description, status, created_at, updated_at, parent_id, select_type) VALUES ('新闻', '新闻', 1, now(), now(), -1, 1)"
    execute "INSERT INTO rss_categories (name, description, status, created_at, updated_at, parent_id) VALUES ('中文科技', '中文科技', 1, now(), now(), -1)"
    execute "INSERT INTO rss_categories (name, description, status, created_at, updated_at, parent_id) VALUES ('英文新闻', '英文新闻', 1, now(), now(), -1)"
    execute "INSERT INTO rss_categories (name, description, status, created_at, updated_at, parent_id) VALUES ('英文科技', '英文科技', 1, now(), now(), -1)"

    execute "INSERT INTO rss_categories (name, description, status, created_at, updated_at, parent_id) VALUES ('网易新闻', '网易新闻', 1, now(), now(), 1)"
    execute "INSERT INTO rss_categories (name, description, status, created_at, updated_at, parent_id) VALUES ('腾讯新闻', '腾讯新闻', 1, now(), now(), 1)"
    execute "INSERT INTO rss_categories (name, description, status, created_at, updated_at, parent_id) VALUES ('凤凰新闻', '凤凰新闻', 1, now(), now(), 1)"

    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('网易头条新闻', 'http://news.163.com/special/00011K6L/rss_newstop.xml',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('网易国内新闻', 'http://news.163.com/special/00011K6L/rss_gn.xml',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('网易国际新闻', 'http://news.163.com/special/00011K6L/rss_gj.xml',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"

    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (1, 5, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (2, 5, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (3, 5, now(), now())"

    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('新闻国内', 'http://news.qq.com/newsgn/rss_newsgn.xml',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('新闻国际', 'http://news.qq.com/newsgj/rss_newswj.xml',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('社会新闻', 'http://news.qq.com/newssh/rss_newssh.xml',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"

    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (4, 6, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (5, 6, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (6, 6, now(), now())"

    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('资讯频道_凤凰网', 'http://news.ifeng.com/rss/index.xml',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('大陆_资讯频道_凤凰网', 'http://news.ifeng.com/rss/mainland.xml',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('国际_资讯频道_凤凰网', 'http://news.ifeng.com/rss/world.xml',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('社会_资讯频道_凤凰网', 'http://news.ifeng.com/rss/society.xml',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"

    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (7, 7, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (8, 7, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (9, 7, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (10, 7, now(), now())"

    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('36氪 | 关注互联网创业', 'http://www.36kr.com/feed',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('爱范儿 · Beats of Bits', 'http://www.ifanr.com/feed',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('钛媒体网', 'http://www.tmtpost.com/?feed=rss2&cat=-1204',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"

    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (11, 2, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (12, 2, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (13, 2, now(), now())"

    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('CNN.com - Top Stories', 'http://rss.cnn.com/rss/edition.rss',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('CNN.com - World', 'http://rss.cnn.com/rss/edition_world.rss',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"

    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (14, 3, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (15, 3, now(), now())"

    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('Hacker News', 'https://news.ycombinator.com/rss',  now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('Re/code', 'http://recode.net/feed', now(), now(), NOW() - INTERVAL 3 DAY, 1)"
    execute "INSERT INTO rss_feeds (name, url, created_at, updated_at, last_fetched, status) VALUES ('ReadWrite', 'http://readwrite.com/main/feed/articles.xml', now(), now(), NOW() - INTERVAL 3 DAY, 1)"

    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (16, 4, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (17, 4, now(), now())"
    execute "INSERT INTO rss_feeds_rss_categories (rss_feed_id, rss_category_id, created_at, updated_at) VALUES (18, 4, now(), now())"

  end

  def self.down
    drop_table :rss_feeds
    drop_table :rss_categories
  end
end
