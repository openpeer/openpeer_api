class UpdateListsStatus < ActiveRecord::Migration[7.0]
  def up
    List.where(status: :created).update_all(status: :active)
  end

  def down
    List.where(status: :active).update_all(status: :created)
  end
end
