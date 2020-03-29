require_relative 'db_helper'

origin = ARGV[0]
origin_file, origin_dir = origin.split('/').reverse
basedir = File.join(* ['db', 'seeds', origin_dir].compact)
klasses_path = File.join(basedir, "#{origin_file}_class_index.txt")
methods_path = File.join(basedir, "#{origin_file}_method_index.txt")

# :reek:UtilityFunction
def report_io(fn, io)
  warn "error occured at [#{fn}:#{io.lineno}] "
end

# rubocop:disable Metrics/BlockLength
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
      case name
      when /(\S*) *\((.*)\)/
        name = Regexp.last_match(1)
        klass_name = Regexp.last_match(2)

        klass_id = DB[:klasses]
                   .where(name: klass_name, origin_id: origin_id)
                   .get(:id)

        begin
          DB[:methods].insert(name: name,
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
# rubocop:enable Metrics/BlockLength
