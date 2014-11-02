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
    var list_size = test_item.parent('ol').children('li:not(.placeholder):visible').length;
    if (test_item.length > 0) {
        // if there is already an id set (edit), hide element and add attribute to mark item for deletion
        if (typeof test_item.data('id') != 'undefined') {
            test_item.attr('data-remove', 1);
            test_item.hide();
            setAlertForSaveButton();
        // otherwise (new) just remove item
        } else {
            test_item.remove();
        }
    }

    // show placeholder if it's the only remaining element in list
    if (list_size == 1) {
        $('li.placeholder').show();
    }
});

$(document).on('i.add', 'click', function(e) {
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

// test projects select input change shall highlight save button
$(document).on('change', '#test_projects', function(e) {
    setAlertForSaveButton()
});

$(document).ready(function() {

    console.log("Webtest JS Ready");

    // new test plan droppable + selectable
    // based on http://jsfiddle.net/KyleMit/Geupm/2/
    var replaceButtons;
    replaceButtons = function (event, list_item, list) {
        var $this = list;
        // replace move icon with sortable icon and add/remove configure icon
        var list_items = $($this).children('li:not(.placeholder)');
        if (list_items.length > 0) {
            var sort_icon = $('<i class="sort fa fa-arrows-v" title="Sort"></i>');
            var remove_icon = $('<i class="remove glyphicon glyphicon-remove" title="Remove"></i>');
            var configure_icon = $('<i class="configure fa fa-cog" title="Configure"></i>');
            list_items.each(function (index, value) {
                var actions = list_item.children('.actions');
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

    // replace buttons and placeholder for existing list items (e.g. when editing test plan with some test items)
    if ($('.dropzone ol.test_items').children('li:not(.placeholder)').length > 0) {
        $('li.placeholder').hide();
        $('.dropzone ol.test_items').children('li:not(.placeholder)').map(function () {
            var item = $(this);
            var list = $('.dropzone ol.test_items');
            replaceButtons(null, item, list);
        })
    }

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
            replaceButtons(event, ui.item, $(this))
        },
        out: function () {
            if ($(this).children(":not(.placeholder)").length == 0) {
                //shows the placeholder again if there are no items in the list
                $("li.placeholder").show();
            }
        }
    }).bind('sortupdate', function (event, ui) {
        replaceButtons(event, ui.item, $(this));
        event.stopImmediatePropagation();
    });

    // new test plan item browser filter
    $('#test_scripts_searchlist').btsListFilter('#searchinput', {initial: false, resetOnBlur: false});
    $('#test_cases_searchlist').btsListFilter('#searchinput', {initial: false, resetOnBlur: false});


    // highlight save button if form changes
    $('form input:text, form textarea, form .select2-container').on('input propertychange paste', function() {
        setAlertForSaveButton();
    });

    // test plans save button shall serialize and submit form data (new & edit)
    var save_button = $('.test_plans a.save');
    var form = $('form[name="test_plan"]');
    save_button.click(function () {
        var paramsString = form.serialize();
        var i = 0; // to count position of test plan items
        var test_items_params = $('.dropzone ol.test_items').children('li:not(.placeholder)').map(function () {
            var add = {};
            var type;
            var id;
            if (typeof $(this).data('test_case_id') != 'undefined') {
                type = 'TestCase';
                add.test_item_id = $(this).data('test_case_id');
            }
            if (typeof $(this).data('test_script_id') != 'undefined') {
                type = 'TestScript';
                add.test_item_id = $(this).data('test_script_id');

            }
            add.id = $(this).data('id');
            i++;
            add.position = i;
            if (typeof $(this).data('remove') != 'undefined') {
                add._destroy = 1;
            }
            return add;
        }).get();

        // get quality criteria
        var quality_criteria_params = $('.conditional').children('.rule').map(function () {
            var tmp = serializeForm($(this));
            var add = {};
            add.attr = tmp['quality_criteria_attributes[attr]'];
            add.operator = tmp['quality_criteria_attributes[operator]'];
            add.value = tmp['quality_criteria_attributes[value]'];
            add.id = tmp['quality_criteria_attributes[id]'];
            return add;
        }).get();

        // get selected projects
        var selected_projects = $("#test_projects").select2('data');
        var current_projects = $('#test_projects').data('current-projects'); // json
        var all_projects = $('#test_projects').data('projects'); // json
        //console.log("current projects", current_projects);
        //console.log("selected projects", selected_projects );
        var project_params = selected_projects.map(function(project) {
            var obj = {};
            obj.project_id = project.id;
            var in_current_projects = $.grep(current_projects, function(e){ return e.project_id == project.id; });
            if (in_current_projects.length > 0) {
                //console.log("already in project", in_current_projects);
                obj.id = in_current_projects[0].id;
            }
            return obj;
        });

        // remove projects
        var remove_projects = [];
        current_projects.forEach(function(project) {
           // any current projects missing in selection?
           var to_be_removed = $.grep(project_params, function(e){ return e.project_id == project.project_id; });
           if (to_be_removed.length == 0) {
               //console.log("remove", project, "from", current_projects);
               remove_projects.push(project.id);
           }
        });
        if (remove_projects.length > 0) {
            remove_projects.forEach(function(id) {
                var obj = {};
                obj.id = id;
                obj._destroy = 1;
                project_params.push(obj);
            });
        }



        // extend params string
        paramsString = paramsString + '&' +
            $.param({test_plan: {test_plan_items_attributes: test_items_params}}) + '&' +
            $.param({test_plan: {test_projects_attributes: project_params}}) + '&' +
            $.param({test_plan: {quality_criteria_attributes: quality_criteria_params}})
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

    // test plan test projects select2 multiselect for projects
    // use 'name' attribute instead of defaults 'text'
    function select2_format(item) { return item.name; }
    if ( $('#test_projects').length ) {
        var projects = $('#test_projects').data('projects'); // json
        var json_projects = $('#test_projects').data('preselected-projects'); // json
        // preselection
        var preselected_projects;
        if (typeof json_projects != 'undefined') {
            preselected_projects = json_projects.map(function (project) {
                return project.id;
            });
        } else {
            preselected_projects = [];
        }
        $('#test_projects').select2({
            data: projects,
            formatSelection: select2_format,
            formatResult: select2_format,
            multiple: true,
            width: '100%',
            allowClear: true,
            dropdownAutoWidth: true
        }).select2("val", preselected_projects);
    }

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


    // ace code editor
    // Hook up ACE editor to all textareas with data-editor attribute
    // as seen in https://gist.github.com/duncansmart/5267653

    $('textarea[data-format]').each(function () {
        var textarea = $(this);

        var format = textarea.data('format');

        var editDiv = $('<div>', {
            position: 'absolute',
            width: textarea.width(),
            height: textarea.height(),
            'class': textarea.attr('class')
        }).insertBefore(textarea);

        textarea.css('visibility', 'hidden');



        var editor = ace.edit(editDiv[0]);
        editor.renderer.setShowGutter(false);
        editor.getSession().setValue(textarea.val());
        editor.getSession().setUseWorker(false);
        editor.getSession().setTabSize(4);
        editor.setOptions({
            minLines: 5,
            maxLines: Infinity
        });
        editor.setTheme("ace/theme/tomorrow");
        switch(format) {
            case 'selenese':
                editor.getSession().setMode("ace/mode/html");
                break;
            case 'ruby':
                editor.getSession().setMode("ace/mode/ruby");
                break;
            case 'bash':
                editor.getSession().setMode("ace/mode/sh");
                break;
            default:
                editor.getSession().setMode("ace/mode/text");
        }
//
//        var heightUpdateFunction = function() {
//
//            // http://stackoverflow.com/questions/11584061/
//            var newHeight =
//                editor.getSession().getScreenLength()
//                * editor.renderer.lineHeight
//                + editor.renderer.scrollBar.getWidth();
//
//            editDiv.height(newHeight.toString() + "px");
//            $('#editor-section').height(newHeight.toString() + "px");
//
//            // This call is required for the editor to fix all of
//            // its inner structure for adapting to a change in size
//            editor.resize();
//        };
//
//        // Set initial size to match initial content
//        heightUpdateFunction();
//
//        // Whenever a change happens inside the ACE editor, update
//        // the size again
////        editor.getSession().on('change', heightUpdateFunction);

        console.log('Ace editor loaded for format:', format);

        // copy back to textarea on form submit...
        textarea.closest('form').submit(function () {
            textarea.val(editor.getSession().getValue());
        })

    });

    // jstree within _test_item_browser
    $('#jstree_demo_div').jstree({
        "plugins" : [ "wholerow" ]
    });

});


