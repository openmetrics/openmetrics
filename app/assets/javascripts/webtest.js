//button to run test plan
$(document).on('click', '.run_test_plan', function(e) {
    var test_plan_id = $(this).data('id');
    $.ajax({
        type: "POST",
        url: '/test_plans/run',
        data: 'id='+test_plan_id,
        success: function(data, textStatus) {
            console.log('Run baby, run!');
        }
    });
});


$(document).ready(function() {

    console.log("JavaScript Ready Webtest");

    // new test plan droppable + selectable
    // from http://jsfiddle.net/KyleMit/Geupm/2/
    $(".test_cases_list li, .test_scripts_list li").draggable({
        appendTo: "body",
        helper: "clone",
        connectToSortable: ".dropzone ol.test_items"
    });
    $(".dropzone ol.test_items").sortable({
        items: "li:not(.placeholder)",
        connectWith: "li",
        sort: function () {
            $(this).removeClass("ui-state-default");
        },
        over: function () {
            //hides the placeholder when the item is over the sortable
            $("li.placeholder").hide();
        },
        update: function() {
            setAlertForSaveButton();
            // replace move icon with sortable icon
            var list_items = $(this).children('li:not(.placeholder)');
            if (list_items.length > 0) {
                var sort_icon = $('<i class="fa fa-arrows-v"></i>');
                var remove_icon = $('<i class="glyphicon glyphicon-remove"></i>');
                var configure_icon = $('<i class="fa fa-cog"></i>');
                list_items.each(function(index,value){
                    var item = $(this);
                    var actions = $(this).children('.actions');
                    if (actions.children('i.fa-arrows').length > 0) {
                        actions.children('i.fa-arrows').remove();
                        sort_icon.prependTo(actions);
                    }
                    if (actions.children('i.glyphicon-remove').length == 0) {
                        remove_icon.prependTo(actions);
                    }
                    if (actions.children('i.fa-cog').length == 0) {
                        configure_icon.prependTo(actions);
                    }
                });
            }

        },
        out: function () {
            if ($(this).children(":not(.placeholder)").length == 0) {
                //shows the placeholder again if there are no items in the list
                $("li.placeholder").show();
            }
        }
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


    // code editor
    if ( $('#test_case_markup').length ) {
        var editor = ace.edit("test_case_markup");
        editor.setTheme("ace/theme/github");
        editor.getSession().setMode("ace/mode/html");
        console.log(editor);
    }

    // jstree within _test_item_browser
    $('#jstree_demo_div').jstree({
        "plugins" : [ "wholerow" ]
    });

});


