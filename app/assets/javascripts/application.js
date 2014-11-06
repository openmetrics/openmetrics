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
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery-ui-1.11.1.min
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require bootstrap.min
//= require bootstrap-multiselect
//= require bootstrap-list-filter.min
// tabdrop doesnt work well for left handed tabs
// require bootstrap-tabdrop
//= require i18n/i18n
//= require i18n/translations
//= require unobtrusive_flash
//= require pnotify.custom.min
//= require vis
//= require flot-0.8.3/jquery.flot
//= require flot-0.8.3/jquery.flot.stackpercent
//= require jstree.min
//= require jqCron
//= require uploads
//= require ace/ace
//= require ace/mode-html
//= require ace/mode-ruby
//= require ace/mode-sh
//= require ace/mode-text
//= require ace/theme-tomorrow
//= require conditions-builder
//= require ui.multiselect
//= require select2.min
//= require search
//= require systems
//= require test_executions
//= require webtest
//= require jquery.readyselector
//= require turbolinks

/* flash handler */
flashHandler = function(e, params) {
    console.log('Received flash message "'+params.message+'" of type '+params.type);
    //notify(params.message, params.type);
};
$(window).bind('rails:flash', flashHandler);

// display visual ui notifications (currently with pnotify)
function notify(message, severity, title) {
    var title = typeof title !== 'undefined' ? title : null;
    var severity = typeof severity !== 'undefined' ? severity : 'notice';

    var opts = {
        text: message,
        hide: false,
        shadow: false,
        buttons: { closer_hover: true, sticker: false},
        confirm: { confirm: false }
    };

    switch (severity) {
    case 'alert':
    case 'error':
        opts.title = "Error";
        opts.type = "error";
        break;
    case 'warn':
    case 'warning':
    case 'notice':
        opts.title = "Notice";
        opts.type = "notice";
        break;
    case 'info':
        opts.title = "Info";
        opts.type = "info";
        break;
    case 'success':
        opts.title = "Success";
        opts.type = "success";
        break;
    }

    new PNotify(opts);

}

function closeEditorWarning(){
    return 'It looks like you have been editing something -- if you leave before submitting your changes will be lost.';
}

// find link/button of class .save and add a alert icon
// also set window exit warning dialog
function setAlertForSaveButton() {
    var button = $('.save');
    var icon = $('<span id="save-alert" class="fa fa-exclamation-triangle text-danger"></span>');

    // only set image if there isn't already one
    if (button.children('#save-alert').length == 0) {
        icon.prependTo(button);
    }

    // window exit warning
    //window.onbeforeunload = closeEditorWarning;

}
function removeAlertForSaveButton() {
    var button = $('.save');
    var icon = button.children('#save-alert');
    icon.remove();
}

// gets a form fields value
var getFieldValue = function(e) {
    var v, c, nn;
    nn = e.get(0).nodeName.toLowerCase();
    // getting value of select-/checkboxes & radios
    if (nn == "select" || e.filter(":radio, :checkbox").length) {
        c = (nn == "select" ? e.find("option:selected") : e.filter(":checked"));
        if (c.length == 1) { v = c.val(); }
        else if (c.length > 1) {
            v = [];
            c.each(function() { v.push($(this).val()); });
        }
        // inputs & textarea
    } else {
        v = e.val();
        // replace comma with dot
        if (e.hasClass("number_decimal_positive")) { v = (v + "").replace(/,/g, "."); }
    }
    return v;
};

var serializeForm = function(e) {
    var n, v, f, i, o, elements, nn;
    elements = ["input", "select", "textarea"];
    o = {};
    nn = e.get(0).nodeName.toLowerCase();
    if ( inArray(nn, elements) ) {
        o[e.attr("name")] = getFieldValue(e);
    } else {
        e.find(elements.join(", ")).each(function() {
            n = $(this).attr("name");
            v = getFieldValue($(this));
            // skip ace editor textarea
            if ( $(this).is('textarea') && $(this).hasClass('ace_text-input')) { return }
            // copy back values from ace editor for textareas
            // editor is expected to be a div right before this element
//            if ( $(this).is('textarea') && $(this).data('format')) {
//                var editor = $(this).prev('.ace_editor');
//                v = ace.edit(editor).getSession().getValue();
//            }
            if (typeof o[n] == 'undefined') { o[n] = v; }
            else if (v) {
                if (!o[n].push) {
                    if (o[n] == "") { o[n] = v; }
                    else {
                        o[n] = [o[n]];
                        o[n].push(v);
                    }
                } else { o[n].push(v); }
            }
        });
    }
    f = [];
    for (i in o) { f.push(i); }
    return o;
};

var inArray = function(needle, haystack) {
    if (haystack == undefined) {
        alert(needle);
        return false;
    }
    var length = haystack.length;
    for (var i = 0; i < length; i++) {
        if (haystack[i] == needle) { return true; }
    }
    return false;
};

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
    console.log("Application Turbo Change");

    // toggle bootstrap dropdowns
    $('.dropdown-toggle').dropdown();
    // if tab-nav does not fit into space, show mobile icon nav
//    $('.nav-pills, .nav-tabs').tabdrop();
    // bootstrap multiselect
//    $('.multiselect').multiselectp({
//        buttonClass: 'btn btn-link' // make dropdown appear as inline link, not like a regular button
//    });

    // set focus to main-search
    //$('#main-search').focus();

    // fancy file uploads
    $('#test_case_upload').fileupload({
        dataType: 'json',
        done: function (e, data) {
            $.each(data.result.files, function (index, file) {
                $('<p/>').text(file.name).appendTo(document.body);
            });
        }
    });

    // back to top
    // hide #back-top first
    $("#back-top").hide();

    // fade in #back-top
    $(window).scroll(function () {
        if ($(this).scrollTop() > 100) {
            $('#scroll-top').fadeIn();
        } else {
            $('#scroll-top').fadeOut();
        }
    });

    // scroll body to 0px on click
    $('#scroll-top a').click(function () {
        $('body,html').animate({
            scrollTop:0
        }, 600);
        return false;
    });


});

$(document).ready(function() {
    console.log("Application JS Ready");

    // generic form serializer
    var save_button = $('a.save.generic');
    save_button.click(function(e) {
        e.preventDefault();
        var closest_form = $('.save').closest('.container').find('form');

        if (typeof closest_form != 'undefined') {
            // console.log("Generic form serializer for ", closest_form.attr('id'));
            var id = closest_form.attr('id');
            var paramsString = serializeForm(closest_form);
            $.ajax({
                type: 'POST',
                url: closest_form.attr('action'),
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
        }
    });
    
});