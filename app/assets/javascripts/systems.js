$(".systems").ready(function () {

    console.log('Systems JS Ready');

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

        var add_running_collectd_plugins = jQuery('div#enabled_collectd_plugins_lists_container ul').children('li.collectd-plugin').map(function(){
            var add = {};
            var running_service = jQuery(this).parent('ul').data('running_service');
            var collectd_plugin = jQuery(this).data('collectd_plugin');
            add.running_service_id = running_service;
            add.collectd_plugin_id = collectd_plugin;

            return add;
        }).get();

        var remove_running_collectd_plugins = jQuery('div#enabled_collectd_plugins_lists_container ul').children('li.disabled').map(function(){
            return jQuery(this).attr("running_collectd_plugin");
        }).get();

        // extend params string
        paramsString = paramsString + '&' +
            jQuery.param({system: {running_services_attributes: running_services_params}}) + '&' +
            jQuery.param({system: {running_services_attributes: destroy_running_services}}) +'&'+
            jQuery.param({system: {running_collectd_plugins_attributes: add_running_collectd_plugins}})+'&'+
            jQuery.param({remove_running_collectd_plugins: remove_running_collectd_plugins})
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


    // collectd plugin edit
    jQuery("#collectd_plugins_list li").draggable({
        helper: "clone",
        appendTo: "body",
        revert: "invalid"
    });

    jQuery("#enabled_collectd_plugins_lists_container ul").droppable({
        tolerance: "pointer",
        activeClass: "ui-state-default",
        hoverClass: "ui-state-hover",
        accept: 'li.collectd-plugin',
        placeholder: jQuery(this).find("li.placeholder"),
        drop: function (event, ui) {
            jQuery(this).find("li.placeholder").hide();
            var li = jQuery('<li class="ui-state-active ui-helper-clearfix collectd-plugin"></li>');
            li.data('collectd_plugin', ui.draggable.data('collectd_plugin'));
            jQuery('<span class="left-floating"></span>').text(ui.draggable.text()).appendTo(li);
            jQuery('<span class="ui-icon ui-icon-close right-floating" title="Remove"></span>').appendTo(li);
            li.appendTo(this);

                setAlertForSaveButton();
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