class AddStoryToProject < ActiveRecord::Migration
  def change
    add_reference :stories, :project, index: true
  end
end
