class FixSpellingMistake < ActiveRecord::Migration
  def change
    rename_column(:locations, :delivery_boundries, :delivery_boundaries)
  end
end
