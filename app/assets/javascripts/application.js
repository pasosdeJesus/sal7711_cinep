// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require sip/motor
//= require sal7711_gen/motor
//= require chosen-jquery
//= require chosen.order.jquery
//= require cocoon
//= require_tree .

$(document).on('turbolinks:load', function() {
	var root;
	root = typeof exports !== "undefined" && exports !== null ? 
		exports : window;
	sip_prepara_eventos_comunes(root, true);
	sal7711_gen_prepara_eventos_comunes(root);

	// Establece categorias de prensa que se muestra en el orden
	// que se guardó
	l=$($('#categoriaprensa_sinorden').get(0))
	if (l != []) {
		l.setSelectionOrder(
				$('#articulo_categoriaprensa_ids').val(), 
				true);
	}

	// Pone orden a categoria por guardar de acuerdo al orden dado
	// por el usuario
	$(document).on('change', '#categoriaprensa_sinorden', function(e) {
		l=$($('#categoriaprensa_sinorden').get(0)).getSelectionOrder()
		$('#articulo_categoriaprensa_ids').html('')
		for(i = 0; i < l.length; i++) {
			$('#articulo_categoriaprensa_ids').append(
					'<option val="' + l[i] + '" selected>' +
					l[i] + '</option>')
		}
	})
});

