class AddWikiTables < ActiveRecord::Migration
  def self.up
 create_table "concepts", :options => 'default charset=utf8', :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.boolean  "pending",         :default => true
    t.integer  "added_by"
    t.integer  "subject_area_id"
    t.integer  "country_id"
    t.boolean  "goout_intern",    :default => false
  end

  create_table "revisions", :options => 'default charset=utf8', :force => true do |t|
    t.text     "content"
    t.integer  "author_id"
    t.integer  "concept_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

 create_table "wiki_references", :options => 'default charset=utf8', :force => true do |t|
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "concept_id",                    :default => 0,  :null => false
    t.string   "referenced_name", :limit => 60, :default => "", :null => false
    t.string   "link_type",       :limit => 1,  :default => "", :null => false
  end



  end

  def self.down
    drop_table "concepts"
    drop_table "revisions"
    drop_table "wiki_references"
  end
end
