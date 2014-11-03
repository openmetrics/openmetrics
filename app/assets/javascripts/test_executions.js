$(".test_executions").ready(function () {
    console.log("Test Execution JS Ready");

    // poll test execution status on test_executions show
    if (jQuery(".test_executions.show").length) {
        console.log("Test Execution polling status");
        var timeOutId = 0;
        var ajaxFn = function () {
            $.ajax({
                url: document.URL + '/poll',
                success: function (response) {
                    if (response.status == 40) {
                        console.log("Test Execution finished - no need to poll anymore.", response);
                        clearTimeout(timeOutId);
                        testExecutionFinished();
                    } else {
                        timeOutId = setTimeout(ajaxFn, 2000);
                        if (response.status < 40) {
                            testExecutionUpdate(response);
                        }
                        console.log("Test Execution running: ", response);
                    }
                }
            });
        };
        // wait 0.5 secs before first call
        // window hash shouldn't contain #finished
        if(!window.location.hash) {
            timeOutId = setTimeout(ajaxFn, 2000);
        };
    }

    // checkbox hide/show all actions
    //set initial state.
    $('#checkbox_stdin').val($(this).is(':checked'));
    $('#checkbox_stdin').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .stdin').fadeIn('fast')
        else
            $('.test_plan .items .stdin').hide();
    });
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
    $('#checkbox_quality').val($(this).is(':checked'));
    $('#checkbox_quality').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .quality').fadeIn('fast')
        else
            $('.test_plan .items .quality').hide();
    });
    $('#checkbox_quality_criteria').val($(this).is(':checked'));
    $('#checkbox_quality_criteria').change(function() {
        if ( $(this).is(':checked') )
            $('.test_plan .items .quality_criteria').fadeIn('fast')
        else
            $('.test_plan .items .quality_criteria').hide();
    });

    $('#checkbox_showall').val($(this).is(':checked'));
    $('#checkbox_showall').change(function() {
        if ( $(this).is(':checked') ) {
            $('.test_plan ul.items li').fadeIn('fast');
            $('#checkbox_quality, #checkbox_quality_criteria, #checkbox_markup_raw, #checkbox_markup, #checkbox_stderr, #checkbox_stdout, #checkbox_stdin').attr('checked', true);
        } else {
            $('.test_plan ul.items li').hide();
            $('#checkbox_quality, #checkbox_quality_criteria, #checkbox_markup_raw, #checkbox_markup, #checkbox_stderr, #checkbox_stdout, #checkbox_stdin').attr('checked', false);

        }
    });

    // specific status_toggle (input, output, error)
    $('.toggle_status i').on('click', function(e) {
        var toggle = $(this).data('toggle');
        var element = $(this).closest('li').children('ul.items').children('li.'+toggle);
        if ( $(element).is(':visible') ) {
            $(element).hide();
        } else {
            $(element).fadeIn('fast');
        }

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

// TODO update processing status based on response
function testExecutionUpdate(response) {
    //window.location.reload();
    //console.log(response);
}
function testExecutionFinished() {
    if(!window.location.hash) {
        window.location = window.location + '#finshed';
        window.location.reload();
    }
}



//// poll status from sse stream
//var stream = new EventSource(document.URL+'/poll');
//stream.onmessage = function(event) {
//    console.log(event.data);
//};