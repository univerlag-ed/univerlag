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
        });

    }

})(jQuery);
