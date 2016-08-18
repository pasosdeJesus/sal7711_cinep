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
//= require_tree .

$(document).on('turbolinks:load ready page:change', function() {
	var root;
	root = typeof exports !== "undefined" && exports !== null ? 
		exports : window;
	sip_prepara_eventos_comunes(root);
	sal7711_gen_prepara_eventos_comunes(root);

	$('[data-behaviour~=datepicker]').datepicker({
		format: root.formato_fecha,
		autoclose: true,
		todayHighlight: true,
		language: 'es'	
	});

});

