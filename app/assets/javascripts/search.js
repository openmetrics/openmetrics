$(document).ready(function () {

    console.log("Search JS Ready");
    var search_delay = undefined;
    var selectedItem = 0; // used to highlight searchresult by keyboard
    var searchInput = jQuery('#main-search');
    var searchForm = searchInput.closest('form');
    var defaultFormAction = searchForm.attr('action');

    searchInput.keydown(function (event) {

        if (typeof search_delay != 'undefined') {
            clearTimeout(search_delay);
        }

        // keybindings
        switch (event.which) {
            case 38: // up arrow, hightlight previous item of resultset
                //console.log("keypress up");
                var allItems = jQuery('#ajax_search_result').find('a');
                if (allItems.size() > 0) {
                    if (selectedItem > 0 && selectedItem <= allItems.size()) {
                        selectedItem = selectedItem - 1;

                        jQuery.each(allItems, function (index, value) {
                            jQuery(this).removeClass('active'); // clean active highlights
                            //alert(index + ': ' + value);
                            if (index == selectedItem - 1) {
                                jQuery(this).addClass('active');
                                var linkattr = jQuery(this).attr('href');
                                // searchInput.val(linkattr);
                                searchForm.attr('action', linkattr); // set form target to active items href
                            }
                        });
                    }
                    if (selectedItem == 0) {
                        // here we are if someone pressed up key to have no item selected anymore
                        // reset form action to search again
                        searchForm.attr('action', defaultFormAction);
                    }
                }
                return false;
                break;

            case 40: // down arrow, hightlight next item of resultset
                //console.log("keypress down");
                var allItems = jQuery('#ajax_search_result').find('a');
                if (allItems.size() > 0) {
                    if (selectedItem <= allItems.size() - 1) {
                        selectedItem = selectedItem + 1;
                        jQuery.each(allItems, function (index, value) {
                            jQuery(this).removeClass('active'); // clean active highlights
                            if (index == selectedItem - 1) {
                                jQuery(this).addClass('active');
                                var linkattr = jQuery(this).attr('href');
                                // searchInput.val(linkattr);
                                searchForm.attr('action', linkattr); // set form target to active item
                            }
                        });
                    }
                }
                return false;
                break;
            case 27: // esc pressed
                hideAjaxSearchResults();
                break;
            case 8: //backspace,
                // hide ajax search results if input is empty
                if ( searchInput.val().length == 1) {
                    hideAjaxSearchResults();
                    selectedItem = 0; // reset search result selection
                }
            default:
                search_delay = setTimeout(function () {
                    if (searchInput.val()) {
                        jQuery('#ajax_search_result').fadeOut("fast");
                        jQuery.ajax({
                            url: '/searches/search?q=' + encodeURIComponent(searchInput.val().trim()),
                            type: "GET",
                            complete: function (data, textStatus) {
                                if (textStatus == 'success') {
                                    // callback for systems loading; create systems selection input
                                    var result = data.responseText;
//                                    console.log(result);
                                    if (result != 'false') {
                                        showAjaxSearchResults(result);
                                    }
                                    else {
                                        // do something?
                                    }
                                }
                            },
                            error: function (data, textStatus) {
                            }
                        });
                    }
                }, 250);
        } // end switch
    }); // end keydown

    // hide result if focus left searchbox
    searchInput.bind('focusout', function () {
        hideAjaxSearchResults();
        selectedItem = 0; // reset search result selection
    });

});

function hideAjaxSearchResults() {
    setTimeout(function () { jQuery('#ajax_search_result').hide("fast"); }, 400);
}

function showAjaxSearchResults(result) {
    var pos = jQuery('#main-search').offset();
    jQuery('#ajax_search_result')
        .css({position: "absolute", top: pos.top + 25, left: pos.left})
        .empty()
        .append(result)
        .fadeIn("fast");
}