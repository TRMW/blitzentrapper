# Daily page view counters for the traffic dashboard (/admin/traffic). One row
# per day, dimension (e.g. "source", "referrer", "country", "agent") and value,
# so the table stays small and holds no IPs or per-visitor data.
class CreateTrafficCounts < ActiveRecord::Migration[8.1]
  def change
    create_table :traffic_counts do |t|
      t.date :day, null: false
      t.string :dimension, null: false
      t.string :value, null: false
      t.integer :count, null: false, default: 0
    end
    add_index :traffic_counts, [ :day, :dimension, :value ], unique: true
  end
end
