$(document).ready(function () {
		$("ul.subnav").parent().hover(
			function () {
			  $(this).children().slideDown('fast').show();
			},
			function () {
			  $(this).chidren().slideUp('slow');
			})
		});

