//button to run test plan
$(document).on('click', '.run_test_plan', function(e) {
    var test_plan_id = $(this).data('id');
    $.ajax({
        type: "POST",
        // FIXME hardcoded path
        url: '/test_plans/run',
        data: 'id='+test_plan_id,
        success: function(data, textStatus){
            if(textStatus=="success") {
                //notify('notice', 'Successfully updated widget!');
                //console.log("run baby, run!")
            }
        },
        error: function(data, textStatus) {
            //notify('error','Widget#'+id, textStatus + data  );
        }
    });
    e.preventDefault();
});


$(document).on('page:change', function() {

    // popover for test execution display settings
    $('.display_options').popover({
        trigger: 'click',
        html: true,
        content: function () {
            return $("#display_options_popover");
        }
    }).on('hidden.bs.popover', function () {
        $("#popover_content_container").append($("#display_options_popover"));
    });

    // popover for test plan run options, takes placement and title from data attributes
    // content comes dynamicially from within a div #popover_content_container
    // taken from https://github.com/twbs/bootstrap/issues/3722
    // see http://getbootstrap.com/javascript/#popovers for popover reference
    $('.run_options').popover({
        trigger: 'click',
        html: true,
        content: function () {
            return $("#run_options_popover");
        }
    }).on('hidden.bs.popover', function () {
        $("#popover_content_container").append($("#run_options_popover"));
    });

    // scheduling test plan execution (https://github.com/arnapou/jqCron/tree/master/demo)
    $('.schedule').jqCron();
    $('.schedule2').jqCron({
        enabled_minute: true,
        multiple_dom: true,
        multiple_month: true,
        multiple_mins: true,
        multiple_dow: true,
        multiple_time_hours: true,
        multiple_time_minutes: true,
        default_period: 'week',
        default_value: '15 10-12 * * 1-5',
        no_reset_button: false,
        lang: 'en'
    });
    $('.schedule4').jqCron({
        lang: 'en',
        numeric_zero_pad: true,
        default_value: '30 2 1 * *',
        multiple_dom: true,
        multiple_month: true,
        multiple_mins: true,
        multiple_dow: true,
        multiple_time_hours: true,
        multiple_time_minutes: true,
        bind_to: $('.schedule4-span'),
        bind_method: {
            set: function($element, value) {
                $element.html(value);
            }
        }
    });


    var editor = ace.edit("test_case_markup");
    editor.setTheme("ace/theme/github");
    editor.getSession().setMode("ace/mode/html");
    console.log(editor);

    // jstree within _test_item_browser
    $('#jstree_demo_div').jstree({
        "plugins" : [ "wholerow" ]
    });

    /* dropdowns for testplan testitems */
    var test_suites_select = $('#test_suites');
    var test_cases_select = $('#test_cases');
    var test_scripts_select = $('#test_scripts');
    var test_items = $('#webtest_test_items');

    var multiselectOptions = {
      buttonClass: 'btn btn-default'
    };

    var selectedItems = [];
    test_scripts_select.multiselect({
        buttonClass: 'btn btn-default',
        onChange: function(element, checked) {
            if (checked == true) {
                selectedItems.push(element.val());
                console.log('checked ', selectedItems);
//                $('#test_suites').multiselect('deselect', element.val());
//                $('#test_suites').multiselect('refresh');
            }
            else if (checked == false) {
//                $('#test_suites').multiselect('select', element.val());
//                $('#test_suites').multiselect('refresh');
            }

        }
    });
    test_cases_select.multiselect(multiselectOptions);
    test_suites_select.multiselect(multiselectOptions);

});


