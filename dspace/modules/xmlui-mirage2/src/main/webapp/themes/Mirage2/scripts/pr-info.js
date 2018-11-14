$(function(){
  var isbn = $("#isbn").text();
  var detailsElement = $("#details");
  var prText = $("#pr-details-text").text();
  var prLinkTitle = $("#pr-link-title").text();

  var doabUrl = 'https://www.doabooks.org/api/peerReviews';
  var doabQuery = doabUrl + '?isbn=' + isbn;

  $.ajax({
    type: "GET",
    url: doabQuery,
    contentType: false,
    error: function(){
      // nothing to do
    },
    success: function(response){
      addPrDescription(response);
    },
    timeout: 3000 // sets timeout to 3 seconds
  });

  function addPrDescription(data) {
    var prIcon = data.PeerReviews[0].prIconUrl;
    var doabBookUrl = createDescriptiveDoabUrl(data.book.bUrl);
    var prIconTag = "<p><strong>" + prText + "</strong>: " +
        "<a href=" + doabBookUrl + " title='" + prLinkTitle + "' target='_blank'>" +
          "<img src=" + prIcon + " alt='Certified by DOAB'>" +
        "</a>" +
      "</p>"
    detailsElement.append(prIconTag);
  }

  function createDescriptiveDoabUrl(bookUrl) {
    var doabBase = 'https://www.doabooks.org/doab';
    var id = RegExp('rid[=:]([^&]*)').exec(decodeURIComponent(bookUrl));

    if (id && id[1]) {
      return doabBase + '?func=prInfo&rid=' + id[1] + '&sat=1';
    }
    // use bookUrl as fallback
    return bookUrl;
  }
});

