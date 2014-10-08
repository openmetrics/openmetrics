$(".test_executions").ready(function () {
    console.log("Test Execution JS Ready");

    // poll test execution status on test_executions show
    if (jQuery(".test_executions.show").length) {
        var timeOutId = 0;
        var ajaxFn = function () {
            $.ajax({
                url: document.URL + '/poll',
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
    }

    // checkbox actions
    //set initial state.
    $('#checkbox_stdout').val($(this).is(':checked'));
    $('#checkbox_stdout').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .stdout').fadeIn('fast')
        else
            $('.test_plan .items .stdout').hide();
    });
    $('#checkbox_stderr').val($(this).is(':checked'));
    $('#checkbox_stderr').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .stderr').fadeIn('fast')
        else
            $('.test_plan .items .stderr').hide();
    });
    $('#checkbox_markup').val($(this).is(':checked'));
    $('#checkbox_markup').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .markup').fadeIn('fast')
        else
            $('.test_plan .items .markup').hide();
    });
    $('#checkbox_markup_raw').val($(this).is(':checked'));
    $('#checkbox_markup_raw').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .markup_raw').fadeIn('fast')
        else
            $('.test_plan .items .markup_raw').hide();
    });
    $('#checkbox_quality').attr('checked', false);;
    $('#checkbox_quality').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .quality').fadeIn('fast')
        else
            $('.test_plan .items .quality').hide();
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

});



//// poll status from sse stream
//var stream = new EventSource(document.URL+'/poll');
//stream.onmessage = function(event) {
//    console.log(event.data);
//};