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
//= require jquery_ujs
//= require turbolinks
//= require bootstrap.min
//= require bootstrap-tabdrop
//= require bootstrap-multiselect
//= require i18n/i18n
//= require i18n/translations


$( document ).ready(function() {
    // toggle bootstrap dropdowns
    $('.dropdown-toggle').dropdown();
    // if tab-nav does not fit into space, show mobile icon nav
    $('.nav-pills, .nav-tabs').tabdrop();
    // bootstrap multiselect
//    $('.multiselect').multiselect({
//        buttonClass: 'btn btn-link' // make dropdown appear as inline link, not like a regular button
//    });
});