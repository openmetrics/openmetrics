$(document).ready(function ($) {

    console.log("serach ready");
    var search_delay = undefined;
    var selectedItem = 0; // used to highlight searchresult by keyboard
    var searchInput = $('#main-search');

    searchInput.keydown(function (event) {

        if (search_delay != undefined) {
            clearTimeout(search_delay);
        }

        // keybindings
        var e;
        if (event.which != "") {
            e = event.which;
        }
        else if (event.charCode != "") {
            e = event.charCode;
        }
        else if (event.keyCode != "") {
            e = event.keyCode;
        }

        switch (e) {
            case 38: // up arrow
                //alert("keypress up");
                var allItems = $("#ajax_search_result").find('a');
                if (allItems.size() > 0) {
                    if (selectedItem > 0 && selectedItem <= allItems.size()) {
                        selectedItem = selectedItem - 1;

                        $.each(allItems, function (index, value) {
                            $(this).removeClass("ui-corner-all ui-state-active"); // clean active highlights
                            //alert(index + ': ' + value);
                            if (index == selectedItem - 1) {
                                $(this).addClass("ui-corner-all ui-state-active");
                                var linkattr = $(this).attr('href');
                                //searchInput.val(linkattr);
                                searchInput.parent().attr("action", linkattr); // set form target to active item
                            }
                        });
                    }
                    if (selectedItem == 0) {
                        // here we are if someone pressed up key to have no item selected anymore
                        // reset form action to search again
                        searchInput.parent().attr("action", "search");
                    }
                }
                return false;
                break;

            case 40: // down arrow
                // hightlight next item of resultset
                //alert("keypress down");
                var allItems = $("#ajax_search_result").find('a');
                if (allItems.size() > 0) {
                    if (selectedItem <= allItems.size() - 1) {
                        selectedItem = selectedItem + 1;
                        $.each(allItems, function (index, value) {
                            $(this).removeClass("ui-corner-all ui-state-active"); // clean active highlights
                            //alert(index + ': ' + value);
                            if (index == selectedItem - 1) {
                                $(this).addClass("ui-corner-all ui-state-active");
                                var linkattr = $(this).attr('href');
                                //searchInput.val(linkattr);
                                searchInput.parent().attr("action", linkattr); // set form target to active item
                            }
                        });
                    }
                }
                ;
                return false;
                break;
            default:
                search_delay = setTimeout(function () {
                    if (searchInput.val()) {
                        $('#ajax_search_result').fadeOut("fast");
                        $.ajax({
                            url: '/search/search?q' + encodeURIComponent(searchInput.val().trim()),
                            type: "GET",
                            complete: function (data, textStatus) {
                                if (textStatus == "success") {
                                    // callback for systems loading; create systems selection input
                                    var result = data.responseText;
                                    console.log(data);
                                    if (result != "false") {
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
                }, 350);
        } // end switch
    }); // end keydown

    // hide result if focus left searchbox
    searchInput.bind('focusout', function () {
        setTimeout(function () {
            $('#ajax_search_result').hide("fast");
        }, 400);
        selectedItem = 0; // reset search result selection
    });

});

function showAjaxSearchResults(result) {
    var pos = $('#main-search').position();
    $('#ajax_search_result')
        .css({position: "absolute", top: pos.top + 25, left: pos.left})
        .empty()
        .html(result)
        .fadeIn("fast");
}