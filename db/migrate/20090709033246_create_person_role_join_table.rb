class CreatePersonRoleJoinTable < ActiveRecord::Migration
  def self.up
    create_table :phin_people_phin_roles do |t|
      t.integer :phin_role_id
      t.integer :phin_person_id
    end
  end

  def self.down
    drop_table :phin_people_phin_roles
  end
end
