#!/usr/local/bin/ruby

require 'pg'
require 'yaml'
require 'byebug'

if ENV['RAILS_ENV'].nil?
  puts "RAILS_ENV deberia definir tipo de ambiente, e.g ensayo o production"
end

e = ENV['RAILS_ENV']
puts "Ambiente: #{e}"

if ENV['MINID'].nil?
  minid=1
else
  minid=ENV['MINID'].to_i
end
if ENV['MAXID'].nil?
  maxid = 0
else
  maxid=ENV['MAXID'].to_i
end
puts "minid: #{minid}"
puts "maxid: #{maxid}"

def ruta_articulo(id, creacion, adjunto_file_name)
  created_at=Date.parse(creacion)
  File.join('/var/www/resremoto/archivoprensa/', created_at.year.to_s,
            created_at.month.to_s.rjust(2, '0'),
            created_at.day.to_s.rjust(2, '0'),
            "/#{id}_#{adjunto_file_name}")
end


config = YAML.load_file('config/database.yml')
# Output a table of current connections to the DB
conf = config[e]
conf.delete('adapter')
conf.delete('encoding')
conf.delete('pool')
puts "dbname: #{conf['database']}"
conn = PG.connect( host: conf['host'], dbname: conf['database'], user: conf['username'], password: conf['password'])

cuenta = 0
cons = "SELECT id, adjunto_file_name, created_at, texto 
  FROM public.sal7711_gen_articulo WHERE texto=''
  AND "
if maxid > 0
  cons += "id>='#{minid.to_s}' AND id<='#{maxid.to_s}'"
else
  cons += "id>='#{minid.to_s}'"
end
cons += " ORDER BY id"

#cons += " LIMIT 2"
#deco = PG::TextDecoder::CopyRow.new
#conn.copy_data "COPY (#{cons}) TO STDOUT", deco do
#    while row=conn.get_copy_data
#      puts "row=#{row}"
#    end
#end
#puts "termino"
#exit 1
puts "cons='#{cons}'"
conn.exec(cons ) do |sinocr|
  puts sinocr.inspect
  puts "sinocr.count=#{sinocr.count}"
  sinocr.each do |fila|
    r=ruta_articulo(fila['id'], fila['created_at'], fila['adjunto_file_name'])
    cuenta += 1
    puts cuenta.to_s + ": " + fila['id'].to_s +  '. ' + r
    cmd ="/usr/local/bin/tesseract #{r} stdout -l spa"
    puts cmd
    res=`#{cmd}`
    res.strip!
    l = res.nil? ? 0 : res.length
    puts "Resultado OCR para artículo #{fila['id']}: #{l}"
    conn.exec( "UPDATE sal7711_gen_articulo SET textoocr=TRIM('#{conn.escape_string(res)}'), texto=TRIM('#{conn.escape_string(res)}') WHERE id=#{fila["id"].to_i};")
  end
end
puts "cuenta=#{cuenta}"
if cuenta > 0
  act="REFRESH MATERIALIZED VIEW md_articulo"
  puts act
  conn.exec(act)
end
conn.finish
