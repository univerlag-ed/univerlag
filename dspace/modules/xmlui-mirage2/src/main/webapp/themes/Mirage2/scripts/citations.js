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
    
   });

