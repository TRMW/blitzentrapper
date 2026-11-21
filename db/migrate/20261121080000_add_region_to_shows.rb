# Production has had shows.region since before the repo's history starts
# (Show.update_location_info writes it, ShowsHelper reads it), but no
# migration ever created it, so schema.rb and the test database lacked it.
# The guard makes this a no-op in production.
class AddRegionToShows < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :region, :string unless column_exists?(:shows, :region)
  end
end
