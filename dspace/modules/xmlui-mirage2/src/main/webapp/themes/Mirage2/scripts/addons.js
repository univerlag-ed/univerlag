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

    $('#deliveryDatePicker').datetimepicker(
        {format: 'YYYY-MM-DD'}
    );

    if ($("#ds-language-selection > a").text() == '[de]')
    {
        $("a, a > span").each(function ()
        {
            if ($(this).text() == "Alle Produkte") {
                $(this).text("All Products");
            }
            if ($(this).text() == "Publikationen aus der Universit\u00e4t") {
                $(this).text("Publications from the University");
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
        if ($("#ds-trail > li.last-link").text() == "Publikationen aus der UniversitÃ¤t")
        {
            $("#ds-trail > li.last-link").text("Publications at the University");
        }

    }

})(jQuery);