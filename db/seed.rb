require_relative 'db_helper'

classes_path = File.join(DB.db_dir, 'fixtures', 'stdlib_class_index.txt')
methods_path = File.join(DB.db_dir, 'fixtures', 'stdlib_method_index.txt')

DB.transaction do
  DB[:classes].delete
  DB[:methods].delete

  File.open(classes_path) do |io|
    io.each_line do |line|
      flavour, url, name = line.chomp.split('%%')

      DB[:classes].insert(name: name, url: url, flavour: flavour)
    end
  end

  File.open(methods_path) do |io|
    io.each_line do |line|
      url, name = line.chomp.split('%%')
      flavour = case url
                when /-c-/ then 'class'
                when /-i-/ then 'instance'
                end
      if /(\S*) *\((.*)\)/ === name
        name = $1
        class_name = $2

        class_id = DB[:classes].where(name: class_name).get(:id)

        begin
          DB[:methods].insert(
            name: name,
            url: url,
            flavour: flavour,
            class_id: class_id)
        rescue Sequel::UniqueConstraintViolation => e
          p error: e, line: line
          exit 1
        end
      else
        puts "`#{name}' does not contain `()'"
      end
    end
  end
end
