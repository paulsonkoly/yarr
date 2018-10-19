require_relative 'db_helper'

origin = ARGV[0]
klasses_path = File.join('db', 'fixtures', "#{origin}_class_index.txt")
methods_path = File.join('db', 'fixtures', "#{origin}_method_index.txt")

def report_io(fn, io)
  STDERR.puts "error occured at [#{fn}:#{io.lineno}] "
end

DB.transaction do
  origin_id = DB[:origins].insert(name: origin)

  File.open(klasses_path) do |io|
    io.each_line do |line|
      flavour, url, name = line.chomp.split('%%')

      begin
        DB[:klasses].insert(name: name,
                            url: url,
                            flavour: flavour,
                            origin_id: origin_id)
      rescue Sequel::Error => e
        report_io(klasses_path, io)
        abort e.to_s
      end
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
        klass_name = $2

        klass_id = DB[:klasses]
          .where(name: klass_name, origin_id: origin_id)
          .get(:id)

        begin
          DB[:methods].insert(
            name: name,
            url: url,
            flavour: flavour,
            klass_id: klass_id,
            origin_id: origin_id)
        rescue Sequel::Error => e
          report_io(methods_path, io)
          abort e.to_s
        end
      else
        report_io(methods_path, io)
        abort "`#{name}' does not contain `()'"
      end
    end
  end
end
