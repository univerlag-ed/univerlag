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

    if ($("#langopt").text().substring(0,2) == 'De')
    {
        $("a, ul.breadcrumb li, h2, span.Z3988").each(function ()
        {
            if ($(this).text() == "Alle Produkte") {
                $(this).text("All Products");
            }
            if ($(this).text() == "Publikationen der G\00f6ttingen Campus") {
                $(this).text("Publications of the G\00f6ttingen Campus");
            }
            if ($(this).text() == "Reihen") {
                $(this).text("Series");
            }
            if ($(this).text() == "Verlagsprogramm") {
                $(this).text("Regular Publications");
            }
            /*if ($(this).text().indexOf('Verlagsprogramm') > -1) {$(this).text($(this).text().replace('Verlagsprogramm','Regular Publications'));}*/
            if ($(this).text() == "Agrar- und Forstwissenschaften") {
                $(this).text("Agricultural and Forestry Science");
            }
            if ($(this).text() == "Alte Kulturen") {
                $(this).text("Ancient cultures");
            }
            if ($(this).text() == "Anglistik") {
                $(this).text("English language and literature");
            }
            if ($(this).text() == "Bibliotheks-, Informations- & Medienwissenschaften") {
                $(this).text("Library, Information- & Media Sciences");
            }
            if ($(this).text() == "Biologie") {
                $(this).text("Biology");
            }
            if ($(this).text() == "Erziehungswissenschaft") {
                $(this).text("Educational Science");
            }
            if ($(this).text() == "Ethnologie") {
                $(this).text("Ethnology");
            }
            if ($(this).text() == "Geowissenschaften und Geographie") {
                $(this).text("Geosciences and Georaphy");
            }
            if ($(this).text() == "Germanistik") {
                $(this).text("German language and literature");
            }
            if ($(this).text() == "Geschichte") {
                $(this).text("History");
            }
            if ($(this).text() == "Kultur und Gesellschaft") {
                $(this).text("Culture and Society");
            }
            if ($(this).text() == "Kulturwissenschaften") {
                $(this).text("Cultural sciences");
            }
            if ($(this).text() == "Kunstgeschichte") {
                $(this).text("History of art");
            }
            if ($(this).text() == "Literaturwissenschaften") {
                $(this).text("Literature studies");
            }
            if ($(this).text() == "Mathematik") {
                $(this).text("Mathematics");
            }
            if ($(this).text() == "Medizin") {
                $(this).text("Medicine");
            }
            if ($(this).text() == "Musikwissenschaften") {
                $(this).text("Music sciences");
            }
            if ($(this).text() == "Medizinrecht") {
                $(this).text("Medical law");
            }
            if ($(this).text() == "Philologie") {
                $(this).text("Philology");
            }
            if ($(this).text() == "Philosophie") {
                $(this).text("Philosophy");
            }
            if ($(this).text() == "Physik & Chemie") {
                $(this).text("Physics & Chemistry");
            }
            if ($(this).text() == "Psychologie") {
                $(this).text("Psychology");
            }
            if ($(this).text() == "Rechtswissenschaften") {
                $(this).text("Law");
            }
            if ($(this).text() == "Religionswissenschaften") {
                $(this).text("Study of religion");
            }
            if ($(this).text() == "Sozialwissenschaften") {
                $(this).text("Social sciences");
            }
            if ($(this).text() == "Soziologie") {
                $(this).text("Sociology");
            }
            if ($(this).text() == "Sportwissenschaften") {
                $(this).text("Sports Sciences");
            }
            if ($(this).text() == "Theologie") {
                $(this).text("Theology");
            }
            if ($(this).text() == "Umweltgeschichte") {
                $(this).text("Environmental history");
            }
            if ($(this).text() == "Wirtschaftswissenschaften") {
                $(this).text("Economics");
            }
            if ($(this).text() == "Wissenschaftsgeschichte") {
                $(this).text("History of science");
            }

        });

    }

