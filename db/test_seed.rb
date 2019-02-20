require_relative 'db_helper'

DB.transaction do
  origin_id = DB[:origins].insert(name: 'core')

  klass_id = DB[:klasses].insert(name: 'Array',
                                 url: 'Array.html',
                                 flavour: 'class',
                                 origin_id: origin_id)

  DB[:methods].insert(name: 'new',
                      url: 'Array.html#method-c-new',
                      flavour: 'class',
                      klass_id: klass_id,
                      origin_id: origin_id)

  DB[:methods].insert(name: 'size',
                      url: 'Array.html#method-i-size',
                      flavour: 'instance',
                      klass_id: klass_id,
                      origin_id: origin_id)

  klass_id = DB[:klasses].insert(name: 'String',
                                 url: 'String.html',
                                 flavour: 'class',
                                 origin_id: origin_id)

  DB[:methods].insert(name: 'new',
                      url: 'String.html#method-c-new',
                      flavour: 'class',
                      klass_id: klass_id,
                      origin_id: origin_id)

  origin_id = DB[:origins].insert(name: 'abbrev')

  klass_id = DB[:klasses].insert(name: 'Array',
                                 url: 'Array.html',
                                 flavour: 'class',
                                 origin_id: origin_id)

  DB[:klasses].insert(name: 'Abbrev',
                      url: 'Abbrev.html',
                      flavour: 'module',
                      origin_id: origin_id)

  DB[:methods].insert(name: 'abbrev',
                      url: 'Array.html#method-i-abbrev',
                      flavour: 'instance',
                      klass_id: klass_id,
                      origin_id: origin_id)

  origin_id = DB[:origins].insert(name: 'bad-string')

  klass_id = DB[:klasses].insert(name: 'String',
                                 url: 'String.html',
                                 flavour: 'class',
                                 origin_id: origin_id)

  DB[:methods].insert(name: 'new',
                      url: 'String.html#method-c-new',
                      flavour: 'class',
                      klass_id: klass_id,
                      origin_id: origin_id)

  origin_id = DB[:origins].insert(name: 'bigdecimal')
  DB[:klasses].insert(name: 'BigDecimal',
                      url: 'BigDecimal.html',
                      flavour: 'class',
                      origin_id: origin_id)

  origin_id = DB[:origins].insert(name: 'json')
  DB[:klasses].insert(name: 'BigDecimal',
                      url: 'JSON/BigDecimal.html',
                      flavour: 'class',
                      origin_id: origin_id)

end
