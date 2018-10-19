require_relative 'db_helper'

DB.create_table(:origins) do
  primary_key :id
  String :name, size: 50, null: false
end

DB.create_table(:classes) do
  primary_key :id
  foreign_key :origin_id, :origins, null: false
  index [:name, :flavour, :origin_id], unique: true

  String :name, null: false
  String :flavour, size: 50, null: false # class or module
  String :url, size: 50, null: false
end

DB.create_table(:methods) do
  primary_key :id
  foreign_key :class_id, :classes, null: false
  foreign_key :origin_id, :origins, null: false
  index [:name, :flavour, :class_id], unique: true

  String :name, null: false
  String :flavour, size: 50, null: false # class or instance
  String :url, size: 50, null: false
end
