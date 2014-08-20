
var ready = function() {
    console.log("JavaScript Ready Test Execution");

    // poll test execution status
    var timeOutId = 0;
    var ajaxFn = function () {
        $.ajax({
            url: document.URL+'/poll',
            success: function (response) {
                if (response.status == 40) {
                    console.log("Test Execution finished - no need to refresh anymore.");
                    clearTimeout(timeOutId);
                } else {
                    timeOutId = setTimeout(ajaxFn, 2000);
                    console.log("Test Execution running: ", response);
                }
            }
        });
    }
    ajaxFn();
    // wait 0.5 secs before first call
    //timeOutId = setTimeout(ajaxFn, 500);


    // checkbox actions
    //set initial state.
    $('#checkbox_stdout').val($(this).is(':checked'));
    $('#checkbox_stdout').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .stdout').show()
        else
            $('.test_plan .items .stdout').hide();
    });
    $('#checkbox_stderr').val($(this).is(':checked'));
    $('#checkbox_stderr').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .stderr').show()
        else
            $('.test_plan .items .stderr').hide();
    });
    $('#checkbox_markup').val($(this).is(':checked'));
    $('#checkbox_markup').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .markup').show()
        else
            $('.test_plan .items .markup').hide();
    });
    $('#checkbox_markup_raw').val($(this).is(':checked'));
    $('#checkbox_markup_raw').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .markup_raw').show()
        else
            $('.test_plan .items .markup_raw').hide();
    });




    // popover for test execution display settings
    $('.display_options').popover({
        trigger: 'click',
        html: true,
        // overwrite template to adapt popover width, see http://getbootstrap.com/javascript/#popovers
        template: '<div class="popover popover-small"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>',
        content: function () {
            return $("#display_options_popover");
        }
    }).on('hidden.bs.popover', function () {
        $("#popover_content_container").append($("#display_options_popover"));
    });

};

$(document).ready(ready)
$(window).bind('page:load', ready)

//// poll status from sse stream
//var stream = new EventSource(document.URL+'/poll');
//stream.onmessage = function(event) {
//    console.log(event.data);
//};