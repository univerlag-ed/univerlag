$( document ).ready(function() {
		if ($("#tabmenu").length > 0) {
		
			var acttab = $("li.active");
			
			$("#tabmenu > li > a").each( function() {
				$(this).click( function(e) {
										
					var content = $(this).attr("href");
					
					if (content.charAt(0)=="#") {
						e.preventDefault();
					
						acttab.removeClass("active");
						$(this).parent().addClass("active");
						acttab = $(this).parent();
				
						$(content).show().addClass('active').siblings().hide().removeClass('active');
					}
				
				});	
	
			});
		}			
 });
