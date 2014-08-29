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
        var running_services_params = $("select.running_services").children('option[role="service"]').map(function () {
            if (this.selected) {
                return {service_id: $(this).data('service_id')};
            }
        }).get();
        var destroy_running_services = $("select.running_services").children('option[role="running_service"]').map(function () {
            if (!this.selected)
                return {_destroy: 1, id: $(this).data('id')};
        }).get();

        // extend params string
        paramsString = paramsString + '&' +
            $.param({system: {running_services_attributes: running_services_params}}) + '&' +
            $.param({system: {running_services_attributes: destroy_running_services}})
        ;

        $.ajax({
            type: 'POST',
            url: form.attr('action'),
            data: paramsString,
            success: function (data, textStatus) {
                if (textStatus == "success") {
//                    var url = $("form.niceforms").attr("action") + "/edit";
//                    $(location).attr('href', url);
                }
            },
            error: function (data, textStatus) {
                //notify('error', 'error');
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