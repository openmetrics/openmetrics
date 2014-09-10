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

/* test_plan test_items actions */
$(document).on('click', 'i.configure', function(e) {
    var test_item = $(this).closest('li');
    if (test_item.length > 0) {
        console.log("configure me");
    }
});
$(document).on('click', 'i.remove', function(e) {
    var test_item = $(this).closest('li');
    if (test_item.length > 0) {
        test_item.remove();
    }
});
$(document).delegate('i.add', 'click', function(e) {
    e.preventDefault();
    var test_item = $(this).closest('li');
    var list = $('.dropzone ol.test_items');

    if (test_item.length > 0 && list.length > 0) {
        $("li.placeholder").hide();
        list.sortable('option','update')(null, {
            item: test_item.appendTo(list)
        });
    }
});

$(document).ready(function() {

    console.log("JavaScript Ready Webtest");

    // new test plan droppable + selectable
    // based on http://jsfiddle.net/KyleMit/Geupm/2/
    var replaceButtons;
    replaceButtons = function (event, ui, that) {
        var $this = that;
        //console.log(ui.item, $this);
        // replace move icon with sortable icon and add/remove configure icon
        var list_items = $($this).children('li:not(.placeholder)');
        if (list_items.length > 0) {
            var sort_icon = $('<i class="sort fa fa-arrows-v" title="Sort"></i>');
            var remove_icon = $('<i class="remove glyphicon glyphicon-remove" title="Remove"></i>');
            var configure_icon = $('<i class="configure fa fa-cog" title="Configure"></i>');
            list_items.each(function (index, value) {
                var actions = ui.item.children('.actions');
                actions.children('i.add').remove();
                if (actions.children('i.fa-cog').length == 0) {
                    configure_icon.prependTo(actions);
                }
                if (actions.children('i.glyphicon-remove').length == 0) {
                    remove_icon.prependTo(actions);
                }
                if (actions.children('i.drag').length > 0) {
                    actions.children('i.drag').remove();
                    sort_icon.prependTo(actions);
                }
            });
        }

    };
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
        update: function(event, ui) {
            setAlertForSaveButton();
            replaceButtons(event,ui,$(this))
        },
        out: function () {
            if ($(this).children(":not(.placeholder)").length == 0) {
                //shows the placeholder again if there are no items in the list
                $("li.placeholder").show();
            }
        }
    }).bind('sortupdate', function (event, ui) {
        replaceButtons(event,ui,this);
        event.stopImmediatePropagation();
    });

    // new test plan item browser filter
    $('#test_scripts_searchlist').btsListFilter('#searchinput', {initial: false, resetOnBlur: false});
    $('#test_cases_searchlist').btsListFilter('#searchinput', {initial: false, resetOnBlur: false});

    // save button shall serialize and submit form data
    var save_button = $('div.test_plans a.save');
    var form = $('form[name="test_plan"]');
    save_button.click(function () {
        var paramsString = form.serialize();

        var test_items_params = $('.dropzone ol.test_items').children('li:not(.placeholder)').map(function () {
            var type;
            var id;
            if (typeof $(this).data('test_case_id') != 'undefined') {
                type = 'TestCase';
                id = $(this).data('test_case_id');
            }
            if (typeof $(this).data('test_script_id') != 'undefined') {
                type = 'TestScript';
                id = $(this).data('test_script_id');
            }
            return id;
        }).get();



        // extend params string
        paramsString = paramsString + '&' +
            $.param({test_plan: {test_item_ids: test_items_params}})
        ;

        $.ajax({
            type: 'POST',
            url: form.attr('action'),
            data: paramsString,
            success: function (data, textStatus) {
                if (textStatus == "success") {
                    removeAlertForSaveButton();
                }
            },
            error: function (data, textStatus) {
                //notify('error', 'error');
            }
        });
        $(this).blur();
        return false;
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


