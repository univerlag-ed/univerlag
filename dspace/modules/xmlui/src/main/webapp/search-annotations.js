$(function(){

  var crowdlayersapi = "https://hypothes.is/api";
  searchHypotesis();

  function searchHypotesis() {
    $.ajax({
      type: "GET",
      url: crowdlayersapi + "/search?_separate_replies=true&limit=200&offset=0&sort=created&search_after=2017-01-01T00:00:09.334539+00:00&wildcard_uri=https://www.univerlag.uni-goettingen.de%2F/*",
      contentType: false,
      error: function(){
        errorMessage();
      },
      success: function(response){
        for (var i = 0; i < response.rows.length; i++) {
        var row = response.rows[i];
        var uri = 'http://crowdlaaers.org?url=' + row.uri;
        var title = row.document.title[0];
        $('#annotations').append('<li><a href="'+ uri + '" target="_blank">' +  title + '</a></li>');
      }

      },
      timeout: 3000 // sets timeout to 3 seconds
    });
   }
});
