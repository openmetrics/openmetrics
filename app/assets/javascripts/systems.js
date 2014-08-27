$(document).ready(function($) {

    console.log('Systems Ready');

    // collectd plugin edit
    $("#collectd_plugins_list li").draggable( {
        helper: "clone",
        appendTo: "body",
        revert: "invalid"
    });

    $( "#enabled_collectd_plugins_lists_container ul" ).droppable({
        tolerance: "pointer",
        activeClass: "ui-state-default",
        hoverClass: "ui-state-hover",
        accept: 'li.collectd-plugin',
        placeholder: $( this ).find( "li.placeholder" ),
        drop: function( event, ui ) {
            $( this ).find( "li.placeholder" ).hide();
            var li = $( '<li class="ui-state-active ui-helper-clearfix collectd-plugin"></li>' );
            li.data("collectd_plugin", ui.draggable.attr("collectd_plugin"));
            $( '<span class="left-floating"></span>' ).text( ui.draggable.text()).appendTo( li );
            $( '<span class="ui-icon ui-icon-close right-floating" title="Remove"></span>' ).appendTo( li );
            li.appendTo( this );

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