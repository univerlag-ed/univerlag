$(function(){
  var annosText = $("#annotation-details-text").text();
  var noAnnosText = $("#annotation-details-none").text();
  var annosLink = $("#annotation-details-link").text();
  var pdfUrl = $("#pdfurl").text();
  pdfUrl = fixUrlForHypothesisSearch(pdfUrl);

  var annotations = [];
  var replies = [];
  var offset = 0;
  search(pdfUrl, offset, annotations, replies);

  function fixUrlForHypothesisSearch(url) {
    var fixedUrl = url.replace(/^.+\/pdfview\//, 'https://www.univerlag.uni-goettingen.de/bitstream/handle/3/');
    fixedUrl = fixedUrl.split('?')[0]; //replace('?sequence=1&', '');
    return fixedUrl;
  }

  function search(pdfUrl, offset, annotations, replies) {
    var max = 2000;
    var limit = 200;
    if (max <= limit) {
        limit = max;
    }
    $.ajax({
      type: "GET",
      url: "https://hypothes.is/api/search?_separate_replies=true&limit=" + limit + "&offset=" + offset + "&url=" + encodeURIComponent(pdfUrl),
      contentType: false,
      error: function(){
        updateDOM();
      },
      success: function(response){
        annotations = annotations.concat(response.rows);
        replies = replies.concat(response.replies);
        if (response.rows.length === 0 || annotations.length >= max) {
          updateDOM();
        }
        else {
          search(pdfUrl, offset + limit, annotations, replies);
        }

      },
      timeout: 3000 // sets timeout to 3 seconds
    });

    function updateDOM() {
      var tag = "<p><strong>" + annosText + " </strong>: "
      if (annotations.length === 0) {
        tag += "<em>" + noAnnosText + "</em>";
      } else {
	$(".icon-download-5.pdf").remove();
        $("#hp").toggle();
        tag += "<a id='downloadAnnotations' href='#'>" + annosLink + "</a>";
      }
      tag += "</p>";
      $("#details").append(tag);
      $("#downloadAnnotations").click(function(){
        parseAnnotationsAndPrepareForDownload(annotations, replies);
        return false;
      });
    }

    function parseAnnotationsAndPrepareForDownload(annotations, replies) {
      var parsedData = parseAnnotations(annotations);
      parsedData = parsedData.concat(parseAnnotations(replies));

      parsedData.sort(function(a, b){
          return a.updated - b.updated;
      });

      var csvOutput = '"level","updated","url","user","id","group","tags","quote","text","direct link"\n';
      for (var i = 0; i < parsedData.length; i++) {
        row = parsedData[i];
        csvOutput += convertToCSV(row) + "\n";
      }
      download(csvOutput, 'csv');
    }

    function parseAnnotations(rows) {
      var parsed = [];
      for (var i = 0; i < rows.length; i++) {
        var row = rows[i];
        parsedRow = parseAnnotation(row);
        parsed.push(parsedRow);
      }
      return parsed;
    }

    function parseAnnotation(row) {
      var id = row.id;
      var url = row.uri;
      var updated = row.updated.slice(0, 19);
      var group = row.group;
      var title = url;
      var refs = row.references ? row.references : [];
      var user = row.user.replace('acct:', '').replace('@hypothes.is', '');
      var quote = '';
      var level = 0;
      if (row.target && row.target.length) {
        var selectors = row.target[0].selector;
        if (selectors) {
          for (var i = 0; i < selectors.length; i++) {
            var selector = selectors[i];
            if (selector.type === 'TextQuoteSelector') {
              quote = selector.exact;
            }
          }
        }
      }
      var text = row.text ? row.text : '';
      var tags = row.tags;
      try {
        title = row.document.title;
        if (typeof title === 'object') {
          title = title[0];
        }
        else {
          title = url;
        }
      }
      catch (e) {
        title = url;
      }
      var isReply = refs.length > 0;
      var isPagenote = row.target && !row.target[0].hasOwnProperty('selector');
      if (refs) {
        level = refs.length;
      }
      var r = {
        id: id,
        url: url,
        updated: updated,
        title: title,
        refs: refs,
        isReply: isReply,
        isPagenote: isPagenote,
        user: user,
        text: text,
        quote: quote,
        tags: tags,
        group: group,
        target: row.target,
        level: level
      };
      return r;
    }

    function convertToCSV(row) {
      var fields = [
          row.level.toString(),
          row.updated,
          row.url,
          row.user,
          row.id,
          row.group,
          row.tags.join(', '),
          row.quote,
          row.text
      ];
      fields.push("https://hyp.is/" + row.id); // add direct link
      fields = fields.map(function (field) {
          if (field) {
              field = field.replace(/\s+/g, ' '); // normalize whitespace
              field = field.replace(/"/g, '""'); // escape double quotes
              field = field.replace(/\r?\n|\r/g, ' '); // remove cr lf
              field = "\"" + field + "\""; // quote the field
          }
          return field;
      });
      return fields.join(',');
    }

    function download(text, type) {
      var blob = new Blob([text], {
          type: 'application/octet-stream'
      });
      var url = URL.createObjectURL(blob);
      var a = document.createElement('a');
      a.href = url;
      a.target = '_blank';
      a.download = 'hypothesis.' + type;
      document.body.appendChild(a);
      a.click();
    }
  }
});

