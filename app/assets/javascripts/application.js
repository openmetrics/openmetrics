// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery-2.1.0.min.js
// require jquery.turbolinks
//= require jquery_ujs
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require bootstrap.min
//= require bootstrap-multiselect
// tabdrop doesnt work well for left handed tabs
// require bootstrap-tabdrop
//= require i18n/i18n
//= require i18n/translations
//= require unobtrusive_flash
//= require jstree.min
//= require search
//= require jqCron
//= require uploads
//= require ace/ace
//= require ace/mode-html
//= require ace/theme-github
////= require turbolinks

/* flash handler */
flashHandler = function(e, params) {
    console.log('Received flash message "'+params.message+'" of type '+params.type);
};

$(window).bind('rails:flash', flashHandler);

/* loading indicator (turbolinks fetch/change event and jquery ajax) */
$(document).on('page:fetch', function() {
    $("#loading-indicator").fadeIn(300);
});

$(document).on('page:change', function() {
    $("#loading-indicator").fadeOut(450);
});
$(document).ajaxSend(function () {
    $('#loading-indicator').fadeIn(300);
});
$(document).ajaxComplete(function () {
    //alert("ajax complete");
    $('#loading-indicator').fadeOut(450);
});


/* misc */

$(document).on('page:change', function() {
    // toggle bootstrap dropdowns
    $('.dropdown-toggle').dropdown();
    // if tab-nav does not fit into space, show mobile icon nav
//    $('.nav-pills, .nav-tabs').tabdrop();
    // bootstrap multiselect
//    $('.multiselect').multiselect({
//        buttonClass: 'btn btn-link' // make dropdown appear as inline link, not like a regular button
//    });

    // fancy file uploads
    $('#test_case_upload').fileupload({
        dataType: 'json',
        done: function (e, data) {
            $.each(data.result.files, function (index, file) {
                $('<p/>').text(file.name).appendTo(document.body);
            });
        }
    });
});