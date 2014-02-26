class FixPgForTagsAndTagLinks < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE "tag_links" ALTER COLUMN "tag_id" TYPE integer USING 
        CAST(CASE "tag_id" WHEN '' THEN NULL ELSE "tag_id" END AS INTEGER);
    SQL
  end

  def down
    change_column :tag_links, :tag_id, :string
  end
end
