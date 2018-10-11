require_relative 'db_helper'

DB.create_table(:classes) do
  primary_key :id
  index [:name, :flavour], unique: true
  String :name, null: false
  String :flavour, size: 50, null: false # class or module
  String :url, size: 50, null: false
end

DB.create_table(:methods) do
  primary_key :id
  foreign_key :class_id, :classes, null: false
  index [:name, :flavour, :class_id], unique: true
  String :name, null: false
  String :flavour, size: 50, null: false # class or instance
  String :url, size: 50, null: false
end
