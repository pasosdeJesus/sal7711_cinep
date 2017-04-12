class OcrarticulosJob < ApplicationJob
  queue_as :default

  def perform(articulo_id)
    # Do something later
    puts "Aqui 1,2,3, articulo_id=#{articulo_id}"
    a=Sal7711Gen::Articulo.find_by(id: articulo_id.to_i)
    if a
      res=`/usr/local/bin/tesseract #{a.ruta_articulo} stdout -l spa`
      puts "Resultado OCR para artículo #{a.id}: #{res.strip!}"
      a.update_attribute(:textoocr, res)
      if (a.texto.nil? || a.texto == 'Procesando') 
        a.update_attribute(:texto, res)
      end
    else
      puts "Articulo eliminado #{articulo_id} no pudo procesarse"
    end
  end
end
