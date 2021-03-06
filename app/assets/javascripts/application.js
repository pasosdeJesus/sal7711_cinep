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
//= require chosen.order.jquery
//= require cocoon
//= require_tree .

document.addEventListener('turbolinks:load', function() {
	var root;
	root = typeof exports !== "undefined" && exports !== null ? 
		exports : window;
	sip_prepara_eventos_comunes(root, true);
	sal7711_gen_prepara_eventos_comunes(root);
	sal7711_cinep_prepara_eventos_comunes(root);


	// ========== FORMULARIO ARTÍCULO ===========
	// Al editar artículo establece categorias de prensa que se muestra en el orden
	// que se guardaron
	var l = $($('#categoriaprensa_sinorden').get(0))
	if (l.length > 0) {
		l.setSelectionOrder($('#articulo_categoriaprensa_ids').val(), 
			true);
	}

	// Al ediar articuo foco comienza en departamento
	if ($('#articulo_departamento_id').length == 1)  {
		$('#articulo_departamento_id')[0].focus();
	}

	// Pone orden a categoria por guardar de acuerdo al orden dado
	// por el usuario
	$(document).on('change', '#categoriaprensa_sinorden', function(e, params) {
		l=$($('#categoriaprensa_sinorden').get(0)).getSelectionOrder()
		$('#articulo_categoriaprensa_ids').html('')
		for(i = 0; i < l.length; i++) {
			if (typeof params.deselected == "undefined" || 
					params.deselected.indexOf(l[i]) === -1) {
				$('#articulo_categoriaprensa_ids').append(
						'<option val="' + l[i] + '" selected>' +
						l[i] + '</option>')
			}
		}
	})


	// Candado en fecha
	$(document).on('change', '#articulo_fecha_localizada', function(e) {
		if ($(this).val() != "")
			$("#articulo_icfecha").removeAttr("disabled");
		else {
			$("#articulo_icfecha").attr("disabled", true);
			$("#articulo_icfecha").removeAttr("checked");
		}
		$('#articulo_departamento_id')[0].focus();
	})

	// Candado en departamento
	$(document).on('change', '#articulo_departamento_id', function(e) {
		if ($(this).val() != "")
			$("#articulo_icdepartamento").removeAttr(
					"disabled");
		else {
			$("#articulo_icdepartamento").removeAttr("checked");
			$("#articulo_icdepartamento").attr(
					"disabled", true);
		}
	})

	// Candado en municipio
	$(document).on('change', '#articulo_municipio_id', function(e) {
		if ($(this).val() != "")
			$("#articulo_icmunicipio").removeAttr("disabled");
		else {
			$("#articulo_icmunicipio").removeAttr("checked");
			$("#articulo_icmunicipio").attr("disabled", true);
		}
	})

	// Candado en categoria
	$(document).on('change', '#categoriaprensa_sinorden', function(e) {
		if ($(this).val() != "")
			$("#articulo_iccategoriaprensa").removeAttr("disabled");
		else {
			$("#articulo_iccategoriaprensa").removeAttr("checked");
			$("#articulo_iccategoriaprensa").attr("disabled", true);
		}
	})

	$(document).on('change', '#articulo_iccategoriaprensa', function (e) {
		if ($(e.target).prop('checked')) {
			$('#categoriaprensa_sinorden').prop('disabled', true).trigger('chosen:updated')
		} else {
			$('#categoriaprensa_sinorden').prop('disabled', false).trigger('chosen:updated')
		}
	})
	// Candado en fuente de prensa
	$(document).on('change', '#articulo_fuenteprensa_id', function(e) {
		if ($(this).val() != "")
			$("#articulo_icfuenteprensa").removeAttr(
					"disabled");
		else {
			$("#articulo_icfuenteprensa").attr(
					"disabled", true);
			$("#articulo_icfuenteprensa").removeAttr(
					"checked");
		}
	})

	// Al editar artículos TAB en el campo categoria es diferente, si hay 
	// selección la elige, si no hay pasa al siguiente
	$(document).on('keydown', '#categoriaprensa_sinorden_chosen input', function(e) {
		if (e.keyCode == 9) {
		       var d = $('select#categoriaprensa_sinorden').chosen().data('chosen')
		       if (d.results_showing) {
			       d.result_select(e);
			       d.mouse_on_container = false;
			       //e.preventDefault();
			       return;
		       }
		}
	})


	// ========== FORMULARIO LOTE ===========
	
	$(document).on('change', 'select[id$=canddepartamento_id]', function(e) {
		llena_municipio($(this), root, true)
	})

	$(document).on('change', '#lote_candfecha_localizada', function(e) {
		$("#lote_nombre").val($(this).val());
	})

	// ========== LISTADO DE LOTES ===========

	// Si se presenta un cierto lote, elegirlo en cuadro de selección
	if ($('#lotes_lote').length == 1)  {
		var l = $('#lotes_lote')
		if (typeof l.attr('value') != 'undefined') {
			l.val(l.attr('value'))
			l.trigger('chosen:updated')
		}
		// Si por error de chosen se presenta segundo cuadro chosen eliminarlo
		while ($('.chosen-container[id=lotes_lote_chosen]').length > 1) {
			$('.chosen-container[id=lotes_lote_chosen]')[1].remove()
		}
	}

	$(document).on('change', '#lotes_lote', function(e) {
		root = window;
		sip_enviarautomatico_formulario($(this).closest('form'));
	})

	// ========== FORMULARIO ORGANIZACIÓN ===========
        $('#organizacion_autoregistro').trigger('change')

});

