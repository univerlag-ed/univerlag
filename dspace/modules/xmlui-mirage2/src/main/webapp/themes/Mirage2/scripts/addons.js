(function($)
{
    $("#main-container").append('<button id="totop">&uarr;</button>');
    $(window).scroll( function(){
        $(window).scrollTop()>300?($("#totop:hidden").fadeIn(),$("#totop").css("top",$(window).scrollTop()+$(window).height()-100)):$("#totop:visible").fadeOut()
    });
    $("#totop").click(function(){
        $("html, body").animate({scrollTop:0})
    });

    $('#issueDatePicker').datetimepicker(
        {format: 'YYYY-MM-DD'}
    );

    $('#issue_date').focus(function() {
        $('#issueDatePicker').data("DateTimePicker").show();
    });


    $('#deliveryDatePicker').datetimepicker(
        {format: 'YYYY-MM-DD'}
    );

    $('#delivery_date').focus(function() {
        $('#deliveryDatePicker').data("DateTimePicker").show();
    });

    $('[data-toggle="popover"]').popover();

    if ($("#ds-language-selection").text().substring(1,3) == 'En')
    {
        $("a, ul.breadcrumb li, h2").each(function ()
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

   if ($("#aspect_submission_StepTransformer_field_dc_identifier_intern").length > 0)
   {
	document.getElementById("aspect_submission_StepTransformer_field_dc_identifier_intern").defaultValue = "isbn-";
   }

//create queryObject
var queryStr = '{"text": "","shortText": "","termVector": [],"language": {"lang": "en"},"entities": [],"onlyNER": false,"resultLanguages": ["de","en"],"nbest": false,"sentence": false,"customisation": "generic"}';
queryJSON = $.parseJSON(queryStr);
var respStr;
var respJSON;;


function setData() {

    //Do not insert entities of some are already existent.
    if ($("input[value='dc_subject_person_1']").length > 0)
    {
        $('#nerd-message').text("Persons alredy existent! Please delete them before starting with lookup.");
        return;
    }

    if ($("input[value='dc_subject_location_1']").length > 0)
    {
        $('#nerd-message').text("Locations alredy existent! Please delete them before starting with lookup.");
        return;

    }
    if ($("input[value='dc_subject_period_1']").length > 0)
    {
        $('#nerd-message').text("Periods alredy existent! Please delete them before starting with lookup.");
        return;

    };



    // Handle only english or german publications
    //language field is multivalued dropdown
    if ($('#aspect_submission_StepTransformer_field_dc_language_iso option:selected').size() == 0)
    {$('#nerd-message').text("No langaguage selected");
        return;
    }

    var langs = [];
    var fieldlang;

    $('#aspect_submission_StepTransformer_field_dc_language_iso option:selected').each(function(){
        langs.push($(this).attr("value"), langs);
    });

    if ($.inArray('eng',langs) > -1) {
        lang = 'en';
        fieldlang = 'eng';
    }
    else if ($.inArray('ger',langs) > -1){
        lang = 'de';
        fieldlang = 'ger';
    }
    else {
        metadata = '';
        $('#nerd-message').text("The selected langaguage is not supported");
        return true;
    }


    var field = "dc_description_abstract" + fieldlang;
    var fieldid = "aspect_submission_StepTransformer_field_" + field;


    //title field is input, abstract fields are textarea
    metadata = $("#aspect_submission_StepTransformer_field_dc_title").attr("value") + $("#" + fieldid).val();

    $("input[value^=" + field + "]").each(function() {
        metadata = metadata + $(this).next().text();
    });

    metadata.replace(/['"]+/g, '');

    queryJSON.text = metadata;
    queryJSON.language.lang = lang;

}



function insertEntities() {


    var persons = [];
    var locations = [];
    var periods = [];

    for (var i = 0, len = respJSON.entities.length; i < len; ++i) {
        var entity = respJSON.entities[i];
        var value;
        if (entity.wikidataId != null) {
            value = entity.rawName + '::' + entity.wikidataId;
        }
        else {
            vaule =entity.rawName;
        }
        if (entity.type == 'PERSON'){
            if ($.inArray(value,persons) == -1) {

                persons.push(value);

            }
        }
        else if (entity.type == 'LOCATION') {
            if ($.inArray(value,locations) == -1) {

                locations.push(value);

            }
        } else if (entity.type == 'PERIOD') {
            if ($.inArray(value,periods) == -1) {

                periods.push(value);

            }
        } else {

            if ($.inArray(value,persons) == -1) {
                persons.push(value);
            }
            if ($.inArray(value, locations) == -1) {
                locations.push(value);
            }
        }

    }

    var personWrap = $( "<div>");
    var personHide = $( "<div>");
    var personDel = $( "<p>", { html:
        $( "<button>", {"class": "ds-button-field btn btn-default ds-delete-button", "name": "submit", "text": "delete"})
    });
    var personEntries = $( "<div>", { "class": "ds-previous-values" });

    $.each(persons, function(index, value) {

        if( index === 0 )
            return true;
        //create input node with checkbox
        var node =  $( "<div>", { "class": "checkbox", html:
            $( "<label>", { html: [
                $( "<input>", { "name": "dc_subject_person_selected", "type": "checkbox", "value": "dc_subject_person_" + index}),
                $( "<span>", { class: "ds-interpreted-field", "text": value}) ]

            })

        });


        //create hidden input
        var hi = $( "<input>", {"name": "dc_subject_person_" + index, "value": value, "type": "hidden"});

        //insert nodes
        $(personEntries).append(node);
        $(personHide).append(hi);


    });

    $(personWrap).append($(personEntries));
    $(personWrap).append($(personDel));
    $(personWrap).append($(personHide).html());

    $('#aspect_submission_StepTransformer_field_dc_subject_person').after($(personWrap).html());

    var locationWrap = $( "<div>");
    var locationHide = $( "<div>");
    var locationDel = $( "<p>", { html:
        $( "<button>", {"class": "ds-button-field btn btn-default ds-delete-button", "name": "submit", "text": "delete"})
    });
    var locationEntries = $( "<div>", { "class": "ds-previous-values" });

    $.each(locations, function(index, value) {
        if( index === 0 ) {	return true;}
        //create input node with checkbox
        var node =  $( "<div>", { "class": "checkbox", html:
            $( "<label>", { html: [
                $( "<input>", { "name": "dc_subject_location_selected", "type": "checkbox", "value": "dc_subject_location_" + index}),
                $( "<span>", { class: "ds-interpreted-field", "text": value}) ]

            })

        });


        //create hidden input
        var hi = $( "<input>", {"name": "dc_subject_location_" + index, "value": value, "type": "hidden"});

        //insert nodes
        $(locationEntries).append(node);
        $(locationHide).append(hi);


    });


    $(locationWrap).append($(locationEntries));
    $(locationWrap).append($(locationDel));
    $(locationWrap).append($(locationHide).html());
    $('#aspect_submission_StepTransformer_field_dc_subject_location').after($(locationWrap).html());

    var periodWrap = $( "<div>");
    var periodHide = $( "<div>");
    var periodDel = $( "<p>", { html:
        $( "<button>", {"class": "ds-button-field btn btn-default ds-delete-button", "name": "submit", "text": "delete"})
    });
    var periodEntries = $( "<div>", { "class": "ds-previous-values" });

    $.each(periods, function(index, value) {

        if( index === 0 )
            return true;
        //create input node with checkbox
        var node =  $( "<div>", { "class": "checkbox", html:
            $( "<label>", { html: [
                $( "<input>", { "name": "dc_subject_period_selected", "type": "checkbox", "value": "dc_subject_period_" + index}),
                $( "<span>", { class: "ds-interpreted-field", "text": value}) ]

            })

        });


        //create hidden input
        var hi = $( "<input>", {"name": "dc_subject_period_" + index, "value": value, "type": "hidden"});

        //insert nodes
        $(periodEntries).append(node);
        $(periodHide).append(hi);


    });

    $(periodWrap).append($(personEntries));
    $(periodWrap).append($(personDel));
    $(periodWrap).append($(personHide).html());

    $('#aspect_submission_StepTransformer_field_dc_subject_period').after($(periodWrap).html());


}

function askNerd () {

    var formData = new FormData();

    formData.append("query", JSON.stringify(queryJSON));

    $('#nerd-message').text('Loading data from NERD ...');

    $.ajax({
        type: "POST",
        url: 'http://nerd.huma-num.fr/nerd/service/disambiguate',
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            respJSON = response;
            //alert(response.runtime);
            $('#nerd-message').text('');
            insertEntities();

        },
        error: function(req, status, errThrown){
            $('#nerd-message').text("ERROR: Something went wrong. Try it again later..");
            setTimeout(function() { $('#nerd-message').hide(); }, 5000);
        }

    });


}

    var nerdurl = "http://nerd.huma-num.fr/nerd/service/disambiguate";
    var lang;

    console.log($('#aspect_submission_StepTransformer_field_dc_language_iso option:selected').size() + " Languages");

    var nerdButton = $("<span>", {"id": "entityLookup", "text": "Lookup Entities"});
    $("label[for='aspect_submission_StepTransformer_field_dc_subject_person']").after($(nerdButton));
    $( "#entityLookup" ).css("cursor", "pointer");
    $( "#entityLookup" ).on( "click", function() {
        if ($('#nerd-message').length) {
            $('#nerd-message').text("");

        }
        else {
            $(nerdButton).after($("<span>", {"id": "nerd-message"}));
        }
        setData();
        if ((queryJSON.text == null) || (queryJSON.text.length < 10)){
            $('#nerd-message').text("Please fill in all metadata and look up again!");
            return; }

        askNerd();
    });

    $('*[data-wiki]').click(function() {
    			var e = $(this);
			e.off('click');
			$.get('http://nerd.huma-num.fr/nerd/service/kb/concept/' + e.data('wiki') + '?lang=en',function(d) {
	                if (d.definitions.length > 0)
        		  {d = d.definitions[0].definition.replace(/'/g, '');
                          d = d.replace(/\[/g, '');
                          d = d.replace(/\]/g, '');
                        }
		        e.popover({content: d, title : e.title}).popover('show');
			});
		});

})(jQuery);
