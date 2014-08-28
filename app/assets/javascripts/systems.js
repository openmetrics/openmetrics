$(document).ready(function ($) {

    console.log('Systems Ready');

    // init running_services multiselect
    $("select.running_services").multiselect();
    $("select.running_services").bind('change', function(event, ui) {
        setAlertForSaveButton();
        $(this).unbind(event);
    });

    // highlight save button if form changes
    $('form input:text').bind('change', function (event) {
        setAlertForSaveButton();
        $(this).unbind(event);
    });

    // save button shall serialize and submit form data
    var save_button = $('.save');
    var form = $('form[name="system"]');
    save_button.click(function () {
        var paramsString = form.serialize();
        console.log(paramsString);

        var create_running_services = $("select.running_services").children('option[role="service"]').map(function () {
            if (this.selected)
                return $(this).val();
        }).get();
        var destroy_running_services = $("select.running_services").children('option[role="running_service"]').map(function () {
            if (!this.selected)
                return $(this).val();
        }).get();
        var add_system_group_maps = $("select.system_group_maps").children('option[role="system_group"]').map(function () {
            if (this.selected)
                return $(this).val();
        }).get();
        var destroy_system_group_maps = $("select.system_group_maps").children('option[role="system_group_map"]').map(function () {
            if (!this.selected)
                return $(this).val();
        }).get();

        var add_running_collectd_plugins = $("div#enabled_collectd_plugins_lists_container ul").children('li.collectd-plugin').map(function () {
            var add = {};
            var running_service = $(this).parent("ul").attr("running_service");
            var collectd_plugin = $(this).attr("collectd_plugin");
            add.running_service = running_service;
            add.collectd_plugin = collectd_plugin;

            return add;
        }).get();

        var remove_running_collectd_plugins = $("div#enabled_collectd_plugins_lists_container ul").children('li.disabled').map(function () {
            return $(this).attr("running_collectd_plugin");
        }).get();

        $.ajax({
            type: 'POST',
            url: form.attr("action"),
            data: paramsString + '&' +
                $.param({create_running_services: create_running_services}) + '&' +
                $.param({destroy_running_services: destroy_running_services}) + '&' +
                $.param({add_system_group_maps: add_system_group_maps}) + '&' +
                $.param({destroy_system_group_maps: destroy_system_group_maps}) + '&' +
                $.param({add_running_collectd_plugins: add_running_collectd_plugins}) + '&' +
                $.param({remove_running_collectd_plugins: remove_running_collectd_plugins}),
            success: function (data, textStatus) {
                if (textStatus == "success") {
//                    var url = $("form.niceforms").attr("action") + "/edit";
//                    $(location).attr('href', url);
                }
            },
            error: function (data, textStatus) {
                notify('error', 'error', textStatus + data);
            }
        });
        $(this).blur();
        return false;
    });


    // collectd plugin edit
    $("#collectd_plugins_list li").draggable({
        helper: "clone",
        appendTo: "body",
        revert: "invalid"
    });

    $("#enabled_collectd_plugins_lists_container ul").droppable({
        tolerance: "pointer",
        activeClass: "ui-state-default",
        hoverClass: "ui-state-hover",
        accept: 'li.collectd-plugin',
        placeholder: $(this).find("li.placeholder"),
        drop: function (event, ui) {
            $(this).find("li.placeholder").hide();
            var li = $('<li class="ui-state-active ui-helper-clearfix collectd-plugin"></li>');
            li.data("collectd_plugin", ui.draggable.attr("collectd_plugin"));
            $('<span class="left-floating"></span>').text(ui.draggable.text()).appendTo(li);
            $('<span class="ui-icon ui-icon-close right-floating" title="Remove"></span>').appendTo(li);
            li.appendTo(this);

//                setAlertForSaveButton();
        }
    });

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