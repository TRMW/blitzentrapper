# Indexes for the slowest lookups seen in production on 2026-11-22: the posts
# feed (ORDER BY created_at), forum topic and user pages (find_by_slug), the
# home page's recent topics (ORDER BY last_post_date), and a topic's or show's
# posts (postable_type + postable_id, ordered by created_at).
class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  # Build the indexes without locking the tables against writes.
  disable_ddl_transaction!

  def change
    add_index :posts, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :posts, [ :postable_type, :postable_id, :created_at ],
      name: "index_posts_on_postable_and_created_at",
      algorithm: :concurrently, if_not_exists: true
    add_index :topics, :slug, algorithm: :concurrently, if_not_exists: true
    add_index :topics, :last_post_date, algorithm: :concurrently, if_not_exists: true
    add_index :users, :slug, algorithm: :concurrently, if_not_exists: true
  end
end
