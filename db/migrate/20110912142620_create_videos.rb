class CreateVideos < ActiveRecord::Migration[4.2]
  def self.up
    create_table :videos do |t|
      t.string :name
      t.string :hometown
      t.text :description
      t.string :clip_file_name
      t.string :clip_content_type
      t.integer :clip_file_size
      t.datetime :clip_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
