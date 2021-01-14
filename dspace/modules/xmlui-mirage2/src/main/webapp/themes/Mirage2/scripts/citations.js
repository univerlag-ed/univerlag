function setDeeplink(from, to) {
		var deeplURL = 'https://www.deepl.com/translator#';
		var transl = "";
		var text = "";		

		var node = $("#aspect_submission_StepTransformer_field_dc_description_abstract" + from);
		transl = from + "/" + to + "/";	
		var text = $(node).val();
		return deeplURL + transl + text;			

}


function citestyle(cs, link){
                        $.ajax({
                                headers: {
                                        "Accept": "text/x-bibliography; style=" + cs
                                 },
                                  url: link,
                                  dataType : "text",
                                  //data: "data",
                                  success : function(response) {
                                    //$("#citationstyle").text($("#citationstyle").text() + response);
						$('.'+cs).toggle();
                                                $('#'+cs).text(response);
                                  },
                                  error: function(jqxhr, status, exception) {
                                        /*alert('Exception:', exception);*/
                                }
                        });
   }
 

   $( document ).ready(function() {
	$("#cs").click( function(){		
		doi=$('#pid').text();
		citestyle("apa", doi);
		citestyle("chicago-author-date-de", doi);
                citestyle("harvard1", doi);
          //      citestyle("mla", doi);
	});

	$("#aspect_submission_StepTransformer_field_dc_description_abstracteng").bind('keyup', function(e){
		if ($("#aspect_submission_StepTransformer_field_dc_description_abstracteng").val().length > 10)
		{
		   if ($("#toger").length > 0) {
			$("#toger").attr("href", setDeeplink("eng", "ger"));
		   }
		   else {
		   	var deeplink = $("<a>", {"id":"toger", "class": "alert alert-success", "href": setDeeplink("eng", "ger"), "target": "_blank","text": "Send to Deepl"});
		
			    $("label[for='aspect_submission_StepTransformer_field_dc_description_abstracteng']").after($(deeplink));	
			}
		}
	
	});

     $("#aspect_submission_StepTransformer_field_dc_description_abstractger").bind('keyup', function(e){
                if ($("#aspect_submission_StepTransformer_field_dc_description_abstractger").val().length > 10)
                {
		    if ($("#toeng").length > 0) { 
			$("#toeng").attr("href", setDeeplink("ger", "eng"));
		    }
		    else {
        	                var deeplink = $("<a>", {"id":"toeng" , "class": "alert alert-success", "href": setDeeplink("ger", "eng"), "target": "_blank","text": "Send to Deepl"});
	                    $("label[for='aspect_submission_StepTransformer_field_dc_description_abstractger']").after($(deeplink));
		    }
                }

        });
    
   });

