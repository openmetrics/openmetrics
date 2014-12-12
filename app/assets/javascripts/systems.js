//button to run test plan
$(document).on('click', '.profile_system', function(e) {
    var system_id = $(this).data('system_id');
    var paramsString = $.param({system_lookup: {system_id: system_id}});
    $.ajax({
        type: "POST",
        url: '/systems/profile',
        data: paramsString,
        success: function(data, textStatus) {
            console.log('Run baby, run!');
        }
    });
});

$(".systems").ready(function () {

    console.log('Systems JS Ready');

    if ( $('body.systems.show').length ) {

        // system relation graph
        var nodes = null;
        var edges = null;
        var network = null;
        var services = $('#system-graph').data('services'); // json
        var running_services = $('#system-graph').data('running_services'); // json
        var system = $('#system-graph').data('system'); //json

        if (system) {
            // create nodes
            nodes = [];
            nodes.push({id: system.id, label: system.name, group: 'system'});
            running_services.forEach(function (rs) {
                var service = $.grep(services, function (e) {
                    return e.id == rs.service_id;
                })[0];
                nodes.push({id: rs.id, label: service.name, group: 'running_service'});
            });

            // create edges
            edges = [];
            running_services.forEach(function (rs) {
                edges.push({from: system.id, to: rs.id, style: 'dash-line'});
            });
            // create a network
            var container = document.getElementById('system-graph');
            var data = {
                nodes: nodes,
                edges: edges
            };
            var options = {
                height: '450px',
                navigation: true,
                keyboard: false,
                groups: {
                    system: {
                        shape: 'box',
                        color: {
                            background: "#428bca"
                        },
                        fontColor: 'white',
                        fontSize: 12
                    },
                    running_service: {
                        shape: 'dot',
                        color: {
                            color: 'white',
                            border: "#428bca"
                        },
                        fontSize: 10

                    }
                }
            };
            if (container) {
                var network = new vis.Network(container, data, options);
            }
        }

        // system events timeline
        var items = null;
        var events = $('#system-timeline').data('events'); // json
        var container = document.getElementById('system-timeline');

        items = [];
        events.forEach(function(event) {
            items.push({id: event.id, content: event.key, start: event.created_at, type: 'point'});
        });

        // Configuration for the Timeline
        var options = {};

        // Create a Timeline
        if (container) {
            var timeline = new vis.Timeline(container, items, options);
        }

    }

    // system label (tagging) input
    // uses 'name' attribute instead of defaults 'text'
    function select2_format(item) { return item.name; }
    if ( $('#label_input').length ) {
        var labels = $('#label_input').data('labels'); // json
        var json_labels = $('#label_input').data('preselected-labels'); // json
        // preselection
        var preselected_labels;
        if (typeof json_labels != 'undefined') {
            preselected_labels = json_labels.map(function (label) {
                return label.id;
            });
        } else {
            preselected_labels = [];
        }
        $('#label_input').select2({
            data: labels,
            formatSelection: select2_format,
            formatResult: select2_format,
            multiple: true,
            width: '100%',
            allowClear: true,
            dropdownAutoWidth: true
        }).select2("val", preselected_labels);
    }


    // init running_services multiselect
    jQuery("select.running_services").multiselect();
    jQuery("select.running_services").bind('change', function(event, ui) {
        setAlertForSaveButton();
        jQuery(this).unbind(event);
    });

    // highlight save button if form changes
    jQuery('form input:text, form textarea').on('input propertychange paste', function() {
        setAlertForSaveButton();
    });

    // save button shall serialize and submit form data
    var save_button = jQuery('.systems.edit a.save');
    var form = jQuery('form[name="system"]');
    save_button.click(function () {
        var paramsString = form.serialize();
        var running_services_params = jQuery("select.running_services").children('option[role="service"]').map(function () {
            if (this.selected) {
                return {service_id: jQuery(this).data('service_id')};
            }
        }).get();
        var destroy_running_services = jQuery("select.running_services").children('option[role="running_service"]').map(function () {
            if (!this.selected)
                return {_destroy: 1, id: jQuery(this).data('id')};
        }).get();

        var running_collectd_plugins_params = $('div#enabled_collectd_plugins_lists_container ul').children('li:not(.placeholder)').map(function () {
            var add = {};
            add.collectd_plugin_id = $(this).data('collectd_plugin_id');
            add.running_service_id = $(this).parent('ul').data('running_service_id')
            add.id = $(this).data('id');
            if (typeof $(this).data('remove') != 'undefined') {
                add._destroy = 1;
            }
            return add;
        }).get();

        // get selected labels
        var selected_labels = $("#label_input").select2('data');
        var current_labels = $('#label_input').data('current-labels'); // json
        var all_labels = $('#label_input').data('labels'); // json
        //console.log("current labels", current_labels);
        //console.log("selected labels", selected_labels );
        var label_params = selected_labels.map(function(label) {
            var obj = {};
            obj.tag_id = label.id;
            obj.name = label.name;
            var in_current_labels = $.grep(current_labels, function(e){ return e.tag_id == label.id; });
            if (in_current_labels.length > 0) {
                //console.log("already in label", in_current_labels);
                obj.id = in_current_labels[0].id;
            }
            //return obj;
            return obj.name;
        });

        // remove label
        //var remove_labels = [];
        //current_labels.forEach(function(label) {
        //    // any current labels missing in selection?
        //    var to_be_removed = $.grep(label_params, function(e){ return e.tag_id == label.tag_id; });
        //    if (to_be_removed.length == 0) {
        //        console.log("remove", label, "from", current_labels);
        //        remove_labels.push(label.id);
        //    }
        //});
        //if (remove_labels.length > 0) {
        //    remove_labels.forEach(function(id) {
        //        var obj = {};
        //        obj.id = id;
        //        obj._destroy = 1;
        //        label_params.push(obj);
        //    });
        //}

        // extend params string
        paramsString = paramsString + '&' +
            jQuery.param({system: {running_services_attributes: running_services_params}}) + '&' +
            jQuery.param({system: {running_services_attributes: destroy_running_services}}) +'&'+
            jQuery.param({system: {label_list: label_params}}) + '&' +
            jQuery.param({system: {running_collectd_plugins_attributes: running_collectd_plugins_params}})
        ;

        jQuery.ajax({
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
        jQuery(this).blur();
        return false;
    });


    // new test plan item browser filter
    $('#collectd_plugins_searchlist').btsListFilter('#searchinput', {initial: false, resetOnBlur: false});

    // replace buttons and placeholder for existing list items (e.g. when editing test plan with some test items)
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
                //if (actions.children('i.fa-cog').length == 0) {
                //    configure_icon.prependTo(actions);
                //}
                if (actions.children('i.glyphicon-remove').length == 0) {
                    remove_icon.prependTo(actions);
                }
                if (actions.children('i.drag').length > 0) {
                    actions.children('i.drag').remove();
                    if (actions.hasClass('ui-sortable')) {
                        sort_icon.prependTo(actions);
                    }
                }
            });
        }

    };

    // replace buttons and remove placeholder for existing list items
    $('.dropzone ul.collectd_plugins').each(function (index, element) {

        if ($(element).children('li:not(.placeholder)').length > 0) {
            console.log("found plugin");
            $(element).children('li.placeholder').hide();
        }
        $(element).children('li:not(.placeholder)').map(function () {
            var item = $(this);
            var list = item.parent('.dropzone ul.collectd_plugins');
            replaceButtons(null, item, list);
        })
    });

    // collectd plugin edit drag n drop
    // based on http://jsfiddle.net/KyleMit/Geupm/2/
    $(".collectd_plugins_list li").draggable({
        appendTo: "body",
        helper: "clone"
    });

    jQuery(".dropzone ul.collectd_plugins").droppable({
        tolerance: "pointer",
//        activeClass: "ui-state-default",
//        hoverClass: "ui-state-hover",
        accept: 'li:not(.placeholder)',
        placeholder: jQuery(this).find("li.placeholder"),
        over: function () {
            //hides the placeholder when the item is over the droppable
            if ($(this).children(":not(.placeholder)").length > 0) {
                $("li.placeholder").hide();
            }
        },
        drop: function (event, ui) {
            var draggable = ui.draggable;
            var droppable = $(this);
            var clone = $(draggable).clone();
            var target = event.target;
            $(this).append(clone);
            //jQuery(this).find("li.placeholder").hide();
            //var li = jQuery('<li class="ui-state-active ui-helper-clearfix collectd-plugin"></li>');
            //li.data('collectd_plugin', draggable.data('collectd_plugin'));
            //jQuery('<span class="left-floating"></span>').text(ui.draggable.text()).appendTo(li);
            //jQuery('<span class="ui-icon ui-icon-close right-floating" title="Remove"></span>').appendTo(li);
            //li.appendTo(this);
            setAlertForSaveButton();
            replaceButtons(event, clone, target);
        },
        out: function () {
            //shows the placeholder again if there are no items in the list
            //if ($(this).children(":not(.placeholder)").length == 0) {
            //    $("li.placeholder").show();
            //}
        }
    });


    //make tabs clickable and store location
    $('ul#system_tabs').find('a').not('.disabled').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });

    // on load of the page: switch to the currently selected tab
    var anchor = window.location.hash;
    if (anchor == '') {
        $('#system_tabs a:first').tab('show')
    } else {
        $('#system_tabs a[href="' + anchor + '"]').tab('show');
    }

    // store the currently selected tab in the window location hash
    $("ul#system_tabs > li > a").on("shown.bs.tab", function (e) {
        var tab_name = $(e.target).attr("href").substr(1); // strip '#' from anchors
        window.location.hash = tab_name;
    });

//    $(".dropzone ol.test_items").sortable({
//        items: "li:not(.placeholder)",
//        connectWith: "li",
//        sort: function () {
//            $(this).removeClass("ui-state-default");
//        },
//        over: function () {
//            //hides the placeholder when the item is over the sortable
//            $("li.placeholder").hide();
//        },
//        update: function(event, ui) {
//            setAlertForSaveButton();
//            replaceButtons(event, ui.item, $(this))
//        },
//        out: function () {
//            if ($(this).children(":not(.placeholder)").length == 0) {
//                //shows the placeholder again if there are no items in the list
//                $("li.placeholder").show();
//            }
//        }
//    }).bind('sortupdate', function (event, ui) {
//        replaceButtons(event, ui.item, $(this));
//        event.stopImmediatePropagation();
//    });

//    jQuery("#collectd_plugins_list li").draggable({
//        helper: "clone",
//        appendTo: "body",
//        revert: "invalid"
//    });
//
//    jQuery("#enabled_collectd_plugins_lists_container ul").droppable({
//        tolerance: "pointer",
//        activeClass: "ui-state-default",
//        hoverClass: "ui-state-hover",
//        accept: 'li.collectd-plugin',
//        placeholder: jQuery(this).find("li.placeholder"),
//        drop: function (event, ui) {
//            jQuery(this).find("li.placeholder").hide();
//            var li = jQuery('<li class="ui-state-active ui-helper-clearfix collectd-plugin"></li>');
//            li.data('collectd_plugin', ui.draggable.data('collectd_plugin'));
//            jQuery('<span class="left-floating"></span>').text(ui.draggable.text()).appendTo(li);
//            jQuery('<span class="ui-icon ui-icon-close right-floating" title="Remove"></span>').appendTo(li);
//            li.appendTo(this);
//
//                setAlertForSaveButton();
//        }
//    });

//    $( '#enabled_collectd_plugins_lists_container ul li span.ui-icon-close' ).live("click", function() {
//        var ul = $(this).parent("li").parent("ul");
//        if ($(this).parent("li").is(".enabled"))
//            $(this).parent("li").addClass("disabled").hide();
//        else
//            $(this).parent("li").remove();
//        if (ul.find("li:not(.disabled)").size() < 2)
//            ul.find( "li.placeholder" ).show();
//
////        setAlertForSaveButton();
//    });
});