// add content timerbased to element, useful if refresh_interval is set as widget preference
function refreshWidgetContent(id) {
    var widget = Widgets[id];
    // refresh_ms refresh every xxxx milliseconds
    if (!widget.preferences.refresh_interval || widget.preferences.refresh_interval == 0)
        return;
    if (widget.preferences.refresh_interval_id)
        clearTimeout(widget.preferences.refresh_interval_id);
    var refresh_ms = widget.preferences.refresh_interval * 1000;
    var refresh_interval_id = setTimeout(
        function () {
            getWidgetContent(id);
            refreshWidgetContent(id);
        }, refresh_ms);
    widget.preferences.refresh_interval_id = refresh_interval_id;
    placePauseRefreshButton(id);
// END widget refresh recursion
}

// create widget's outer containers (drag-and-drop, resize etc.)
// place widget's content in returned from WIDGET.getWidgetContent function;
function renderWidget(id){
    var widget = Widgets[id];
    if (!widget.type) return;

    // zIndexes for containers' layering
    maxZindex = (maxZindex > widget.zindex) ? maxZindex : parseInt(widget.zindex);
    var zIndex1 = maxZindex;
    var zIndex2 = (maxZindex+1);
    var zIndex3 = (maxZindex+2);

    // contentCointainer fix the content overflow if the widget size doesn't fit it
    var widgetContentContainer = $('<div></div>');
    widgetContentContainer.addClass('content-wrapper');
    //    widgetContentContainer.html(content);
    // drag-and-drop container
    var widgetDnDContainer = $('<div></div>');
    widgetDnDContainer.addClass('dnd-wrapper');
    widgetDnDContainer.attr('id', id);
    widgetDnDContainer.css({
        top: (widget.top+'px'),
        left: (widget.left+'px'),
        'z-index': zIndex1
    });
    // handle for drag-and-drop as overlay for content; prevents click events on the content in edit mode;
    var handleDnD = $('<div></div>');
    handleDnD.addClass('handleDnD');
    handleDnD.css({
        'z-index': zIndex2
    });
    // resize container
    var widgetResizeContainer = $('<div></div>');
    widgetResizeContainer.addClass('resize-wrapper');
    widgetResizeContainer.css({
        'z-index' : zIndex3
    });

    if (widget.preferences.bubble) {
        widgetDnDContainer.css("-moz-box-shadow", "none");
        widgetDnDContainer.css("-webkit-box-shadow", "none");
        widgetDnDContainer.css("box-shadow", "none");
        widgetResizeContainer.addClass(widget.preferences.bubble);
    }
    else
    {
        widgetResizeContainer.css({
            "border": "2px dotted #ccc"
        });
        widgetResizeContainer.css({
            'background-color': '#fff'
        });
        if (widget.preferences.border)
            widgetResizeContainer.css({
                border: widget.preferences.border
            });
        if (widget.preferences.background)
            widgetResizeContainer.css({
                'background-color': '#'+widget.preferences.background
            });
    }
    // edit bar container for each widget with 'edit' and 'delete' buttons;
    var editBar = $('<div class="widget-toolbar"></div>').hide();
    var moveButton = $('<img src="/images/noun_icons/'+iconColor+'/24x24/eject.png" />').addClass('widget-toolbar-icon').attr('title', 'Reassign to another dashboard').click(function () {
        getMoveWidgetForm(id);
    });
    var editButton = $('<img src="/images/noun_icons/'+iconColor+'/24x24/edit.png" />').addClass('widget-toolbar-icon').attr('title', 'Edit').click(function () {
        getEditWidgetForm(id);
    });
    var copyButton = $('<img src="/images/noun_icons/'+iconColor+'/24x24/paper.png" />').addClass('widget-toolbar-icon').attr('title', 'Copy').click(function () {
        var new_widget = $.extend(true, {}, widget);
        new_widget.id = 0;
        Widgets[0] = new_widget;
        //            getEditWidgetForm(new_widget);
        getEditWidgetForm(0);
    });
    var deleteButton = $('<img src="/images/noun_icons/'+iconColor+'/24x24/litter.png" />').addClass('widget-toolbar-icon').attr('title', 'Delete').click(function () {
        deleteWidgets([id]);
    });
    editBar.append(editButton);
    editBar.append(copyButton);
    editBar.append(moveButton);
    editBar.append(deleteButton);

    // containers are being nested and placed to content
    handleDnD.append(editBar);
    handleDnD.mouseover(function () {
        editBar.show();
    });
    handleDnD.mouseleave(function () {
        editBar.hide();
    });
    editBar.mouseover(function () {
        editBar.show();
    });
    editBar.mouseleave(function () {
        editBar.hide();
    });

    widgetResizeContainer.append(widgetContentContainer);
    widgetDnDContainer.append(handleDnD);
    widgetDnDContainer.append(widgetResizeContainer);
    widgetDnDContainer.css('display', 'none');
    $('#content').append(widgetDnDContainer);
    widgetDnDContainer.fadeIn();

    // if widget size has not been set, the load-event for content is used: widget size is being set to fit all content;
    if (!widget.sizex || !widget.sizey) {
        widget.sizex = widgetContentContainer.width();
        widget.sizey = widgetContentContainer.height();
        widgetContentContainer.children(':first-child').load(function(){
            widget.sizex = $(this).width();
            widget.sizey = $(this).height();

            widgetContentContainer.width(widget.sizex).height(widget.sizey);
            handleDnD.width(widget.sizex).height(widget.sizey);
            widgetResizeContainer.width(widget.sizex).height(widget.sizey);
        });
    }
    widgetContentContainer.width(widget.sizex).height(widget.sizey);
    handleDnD.width(widget.sizex).height(widget.sizey);
    widgetResizeContainer.width(widget.sizex).height(widget.sizey);

    // initialize jquery-ui resizable for resize container
    widgetDnDContainer.children('div.resize-wrapper').resizable({
        start: function(event, ui) {
            widgetDnDContainer.children('div.resize-wrapper').find('div.collectd_graph_legend').remove();
        },
        stop: function(event, ui) {
            //                    var postdata = 'sizex='+ui.size.width+'&sizey='+ui.size.height +'&zindex='+maxZindex;
            var postdata = 'sizex='+$(this).width()+'&sizey='+$(this).height() +'&zindex='+maxZindex;
            saveWidget(id, "widgets", postdata);
            if (widget.functions && widget.functions.refresh) widget.functions.refresh();
        },
        //                resize event callback was preffered insteed alsoResize option because of needed ability to trigger resize event in guidline plugin;
        //                alsoResize: '#'+id+' div.handleDnD, #'+id+' div.content-wrapper',
        opacity: 0.35,
        disabled: true,
        //guideline plugin settings
        guides: true,
        guidepadding: 10,
        guidecenter: false
    });
    widgetDnDContainer.children('div.resize-wrapper').bind("resize", function (event, ui) {
        $('#'+id+' div.content-wrapper').width($(this).width());
        $('#'+id+' div.handleDnD').width($(this).width());

        $('#'+id+' div.content-wrapper').height($(this).height());
        $('#'+id+' div.handleDnD').height($(this).height());
    });
    // initialize jquery-ui draggable for drag-and-drop container
    widgetDnDContainer.draggable({
        drag: function(event, ui) {
            var dt = ui.position.top - offset.top, dl = ui.position.left - offset.left;

            // take all the elements that are selected expect $(”this”), which is the element being dragged and loop through each.

            selected.not(this).each(function() {
                // create the variable for we don’t need to keep calling $(”this”)
                // el = current element we are on
                // off = what position was this element at when it was selected, before drag
                var el = $(this), off = el.data("offset");
                el.css({
                    top: off.top + dt,
                    left: off.left + dl
                });
            });
        },
        start: function(event, ui) {
            $(this).addClass('noclick');
            if( !$(this).hasClass("ui-selected")) {
                $(".ui-selected").each(function() {
                    el = $(this);
                    el.removeClass("ui-selected");
                });
                selected = $([]);
                offset = {
                    top:0,
                    left:0
                };
                $(this).addClass("ui-selected");
            }
            else {
                selected = $(".ui-selected").each(function() {
                    var el = $(this);
                    el.data("offset", el.offset());
                });
                offset = $(this).offset();
            }
        },
        stop: function(event, ui) {
            var warning = false;
            var top = ui.position.top;
            var left = ui.position.left;
            if (left < 0 || top <= 27) {
                warning = true;
                if (widget.preferences.refresh_interval_id) {
                    var refresh_interval_id = widget.preferences.refresh_interval_id;
                    clearTimeout(refresh_interval_id);
                    widget.preferences.refresh_interval_id = null;
                }
                $('#'+id).remove();
                renderWidget(id);
            }
            else {
                var postdata = 'top='+top+'&left='+left +'&zindex='+maxZindex;
                saveWidget(id, "widgets", postdata);
            }

            var dt = ui.position.top - offset.top, dl = ui.position.left - offset.left;
            selected.not(this).each(function() {
                // create the variable for we don’t need to keep calling $(”this”)
                // el = current element we are on
                // off = what position was this element at when it was selected, before drag
                var el = $(this), off = el.data("offset");
                var top = off.top + dt;
                var left = off.left + dl;
                var id = $(this).attr("id");
                el.css({
                    top: top,
                    left: left
                });

                if (left < 0 || top <= 27) {
                    warning = true;
                    if (widget.preferences.refresh_interval_id) {
                        var refresh_interval_id = widget.preferences.refresh_interval_id;
                        clearTimeout(refresh_interval_id);
                        widget.preferences.refresh_interval_id = null;
                    }
                    $('#'+id).remove();
                    renderWidget(id);
                }
                else {
                    var postdata = 'top='+top+'&left='+left +'&zindex='+maxZindex;
                    saveWidget(id, "widgets", postdata);
                }
            });
            if (warning) notify('warning', undefined, "One (or more) widget(s) couldn't be positioned outside the dashboard area!");
        },
        handle: '#'+id+' div.handleDnD',
        disabled: true,
        iframeFix: true,
        opacity: 0.35,
        snap: true,
        snapMode: "outer",
        snapTolerance: 20,
        //guideline plugin settings
        guides: true,
        guidepadding: 20,
        guidecenter: false

    });
    // set click action for widgets to handle z-indexes
    widgetDnDContainer.children('div.resize-wrapper')
    .click(function(){
        widgetDnDContainer.css('z-index', maxZindex);
        widgetDnDContainer.children('div.handleDnD').css('z-index', (maxZindex+1));
        widgetDnDContainer.children('div.resize-wrapper').css('z-index', (maxZindex+2));
        var postdata = 'zindex='+maxZindex;
        saveWidget(id, "widgets", postdata);
        maxZindex = maxZindex + 3;
    })
    .dblclick(function(){
        $('#editDashboardInput').attr('checked', "checked");
        $('#editDashboardInput').button("refresh");
        forceDashboardEditMode(true);
        //                getEditWidgetForm(widget);
        getEditWidgetForm(id);
    });
    widgetDnDContainer.children('div.handleDnD')
    .click(function(){
        if (widgetDnDContainer.hasClass('noclick')) {
            widgetDnDContainer.removeClass('noclick');
            return;
        }
        widgetDnDContainer.css('z-index', maxZindex);
        widgetDnDContainer.children('div.handleDnD').css('z-index', (maxZindex+2));
        widgetDnDContainer.children('div.resize-wrapper').css('z-index', (maxZindex+1));
        var postdata = 'zindex='+maxZindex;
        saveWidget(id, "widgets", postdata);
        maxZindex = maxZindex + 3;
        if( !widgetDnDContainer.hasClass("ui-selected")) {
            if (!ctrlKeyPressed) {
                $(".ui-selected").each(function() {
                    el = $(this);
                    el.removeClass("ui-selected");
                });
                selected = $([]);
            }
            widgetDnDContainer.addClass("ui-selected");
        }
        else {
            widgetDnDContainer.removeClass("ui-selected");
            selected = $(".ui-selected").each(function() {
                var el = $(this);
                el.data("offset", el.offset());
            });
        }
    })
    .dblclick(function(){
        //                getEditWidgetForm(Widgets[id]);
        getEditWidgetForm(id);
    });
    if ($('#editDashboardInput').attr('checked'))
        setEditMode(id);
    else
        $('div.ui-resizable-handle').hide();
    maxZindex = maxZindex + 3;

    // call getWidgetContent function -> invokes widget.getWidgetContent
    //
    if (widget.preferences.refresh_interval) {
        refreshWidgetContent(id);
    }
    getWidgetContent(id);
}

// switches widget's edit mode ON;
function setEditMode (id) {
    var widgetContainer = $('#'+id);
    var zIndex = parseInt(widgetContainer.css('z-index'));
    widgetContainer.children('div.handleDnD')
    .css('z-index', (zIndex+2));
    widgetContainer.children('div.resize-wrapper').css('z-index', (zIndex+1));
    widgetContainer.draggable("option", {
        disabled: false,
        iframeFix: true
    }).addClass('ui-draggable-disabled ui-state-disabled')
    .css("opacity", "0.7")
    ;
    widgetContainer.children('div.resize-wrapper')
    .resizable("option", {
        disabled: false
    })
    .removeClass('ui-resizable-disabled ui-state-disabled');
}

// switches widget's edit mode OFF;
function unsetEditMode (id) {
    var widgetContainer = $('#'+id);
    var zIndex = parseInt(widgetContainer.css('z-index'));
    widgetContainer
    .removeClass("ui-selected")
    .children('div.handleDnD')
    .css('z-index', (zIndex+1));
    widgetContainer.children('div.resize-wrapper').css('z-index', (zIndex+2));
    widgetContainer.draggable("option", {
        disabled: true
    })
    .removeClass('ui-draggable-disabled ui-state-disabled')
    .css("opacity", "1.0")
    ;
    widgetContainer.children('div.resize-wrapper').resizable("option", {
        disabled: true
    })
    .removeClass('ui-resizable-disabled ui-state-disabled');
}

// fires ajax request to update widget
function saveWidget(id, path, postdata, dialog) {
    postdata.dashboard_id = dashboardId;
    $.ajax({
        type: "PUT",
        url: '/'+path+'/'+id,
        data: postdata,
        success: function(data, textStatus){
            if(textStatus=="success") {
                //notify('notice', 'Successfully updated widget!');
                var functions = Widgets[id].functions;
                //                    var widget = JSON.parse(data.responseText);
                var widget = data;
                widget.functions = functions;
                Widgets[widget.id] = widget;
                if (dialog) {
                    widget = Widgets[id];
                    if (widget.preferences.refresh_interval_id) {
                        var refresh_interval_id = widget.preferences.refresh_interval_id;
                        clearTimeout(refresh_interval_id);
                        widget.preferences.refresh_interval_id = null;
                    }
                    $('#'+id).remove();
                    renderWidget(id);
                    dialog.dialog("close");
                }
                //                    if (widget.functions.refresh) widget.functions.refresh();
                fitContentDivSizeToContent();
            }
        },
        error: function(data, textStatus) {
            notify('error','Widget#'+id, textStatus + data  );
        }
    });
}

// fires ajax request to delete widget
// TODO if widget has :refresh_interval set, this counter needs to be stopped somehow
function deleteWidgets(ids) {
    var dialogContainer = $('<div></div>').attr('id', 'deleteWidgetsDialog').html('Do you really want to destroy selected widget(s)?');
    $('#content').append(dialogContainer);
    dialogContainer.dialog({
        //position: [(50 + dialogContainersSize*20), (50 + dialogContainersSize*20)],
        width: 300,
        height: 200,
        autoOpen: false,
        modal:true,
        resizable: false,
        zIndex: 50000,
        close: function(event, ui){
            $(this).dialog('destroy').html('').hide().remove();
        },
        buttons: {
            "Delete": function() {
                var dialog = $(this);
                $.ajax({
                    url: '/widgets/destroy',
                    type: "POST",
                    data: {
                        ids: ids,
                        _method: "delete"
                    },
                    complete: function(data, textStatus){
                        if(textStatus=="success") {
                            notify('success', undefined, 'Successfully deleted widget(s).');
                            ids.forEach(function (id) {
                                var widget = Widgets[id];
                                if (widget.preferences.refresh_interval_id) {
                                    var refresh_interval_id = widget.preferences.refresh_interval_id;
                                    clearTimeout(refresh_interval_id);
                                    widget.preferences.refresh_interval_id = null;
                                }
                                $('#'+id).hide().remove();
                                // invalidate widget in DOM
                                Widgets[id] = null;
                            });

                            dialog.dialog("close");
                            fitContentDivSizeToContent();
                        }
                    },
                    error: function(data, textStatus) {
                        notify('error','Widget#'+id, textStatus + data  );
                    }
                });
            },
            "Cancel": function() {
                $(this).dialog("close");
            }
        }
    });
    dialogContainer.dialog('open');
}

// fires ajax request to create new widget
function createWidget(dialog, path, formValuesObject, top, left, sizex, sizey) {
    $.ajax({
        url: '/'+path,
        type: "POST",
        data: {
            commit: "create",
            dashboard_id: dashboardId,
            top: top,
            left: left,
            sizex: sizex,
            sizey: sizey,
            zindex: maxZindex,
            preferences: JSON.stringify(formValuesObject)
        },
        complete: function(data, textStatus){
            if(textStatus=="success") {
                notify('success', undefined, 'Widget created.');
                var widget = JSON.parse(data.responseText);
                //                  var widget = data;
                Widgets[widget.id] = widget;
                renderWidget(widget.id);
                maxZindex = maxZindex + 3;
                if (dialog) dialog.dialog("close");
                fitContentDivSizeToContent();
            }
        },
        error: function(data, textStatus) {
            notify('error','Widget#'+id, textStatus + data  );
        }
    });
}

// maps getWidgetContent() to widget's obejcts by widget's type
function getWidgetContent (id) {
    var widget = Widgets[id];
    var widgetClass = window[widget.type];
    if (typeof (widgetClass) === 'object' && typeof (widgetClass.getWidgetContent) === 'function')
        return widgetClass.getWidgetContent(id);
    else
        notify('error', undefined, 'Something went wrong' );
}

// maps getEditWidgetForm() to widget's obejcts by widget's type
function getEditWidgetForm(id) {
    var widget = Widgets[id];
    var widgetClass = window[widget.type];
    if (typeof (widgetClass) === 'object' && typeof (widgetClass.openWidgetForm) === 'function')
        widgetClass.openWidgetForm(id);
    else
        notify('error', undefined, 'Something went wrong' );
}

// maps getAddWidgetForm() to widget's obejcts by widget's type
function getAddWidgetForm(widgetClass) {
    if (typeof (widgetClass) === 'object' && typeof (widgetClass.openWidgetForm) === 'function') {
        Widgets[0] = {};
        widgetClass.openWidgetForm(0);
    }
    else
         notify('error', undefined, 'Something went wrong' );
    
}

// open dialog to reassign widget to another dashboard
function getMoveWidgetForm(id) {
    var widget = Widgets[id];
    // dialog div-container is being intialized and appended to content;
    var dialogContainer = $('<div class="ui-helper-clearfix"></div>').attr('id', 'moveWidgetDialog');
    dialogContainer.html('<img id="moveWidgetForm_ajax-loader" src="/images/ajax-loader.gif"/>');
    $('#content').append(dialogContainer);

    // transforming dialog div-container to the jquery-ui dialog
    var dialog = dialogContainer.dialog({
        width: 400,
        height: 200,
        autoOpen: false,
        modal:true,
        resizable: false,
        zIndex: 50000,
        close: function(event, ui){
            $(this).dialog('destroy').html('').hide().remove();
        }
    });
    dialogContainer.dialog('open');
    dialogContainer.dialog({
        title: "Move widget"
    });
    // fires ajax request to load dashboards for the dashboard selection input
    $.ajax({
        url: '/dashboards/list_only',
        type: "POST",
        complete: function(data, textStatus){
            if(textStatus=="success") {
                //notify('notice', textStatus + ' list_only');
                var dashboards = JSON.parse(data.responseText).dashboards;
                var result = "<b>Select a dashboard to reassign a widget: </b><br /><br />";
                result += "<select>";
                for (var i= 0; i < dashboards.length; i++) {
                    if (dashboards[i])
                        result += '<option value="' + dashboards[i].id + '">' + dashboards[i].name + '</option>';
                }
                result += "</select>";
                dialogContainer.html(result);
                var select = dialogContainer.children("select");
                select.val(dashboardId);
                select.change(function (){
                    if ($(this).val() != dashboardId) {
                        var new_dashboard_id = $(this).val();
                        var buttons = new Object();
                        buttons['Reassign'] = function(){
                            var postdata = 'dashboard_id='+new_dashboard_id;
                            saveWidget(widget.id, "widgets", postdata);
                            $('#'+widget.id).remove();
                            dialogContainer.dialog('close');
                        };
                        buttons['Cancel'] = function() {
                            dialogContainer.dialog('close');
                        }
                        dialogContainer.dialog({
                            buttons: buttons
                        });
                    }
                });
            }
        },
        error: function(data, textStatus) {
            //notify('error', textStatus + data);
            dialogContainer.dialog('close');
        }
    });
}

function placePauseRefreshButton(id){
    var widget = Widgets[id];
    var refresh = widget.preferences.refresh_interval;

    $('#'+id + " div.pause-button").remove();
    var pauseButton = $('<div class="pause-button">Refresh is active (interval of '+ refresh +' seconds). Click here to pause refresh. </div>');
    pauseButton.css("margin-top", "-20px");
    pauseButton.css("cursor", "pointer");
    pauseButton.css("text-align", "center");
    //    pauseButton.css("color", "#555");
    //    pauseButton.css("background-color", "#00ff00");
    pauseButton.removeClass("ui-state-active");
    pauseButton.addClass("ui-state-disabled");
    pauseButton.click(function () {
        var refresh_interval_id = widget.preferences.refresh_interval_id;
        clearTimeout(refresh_interval_id);
        widget.preferences.refresh_interval_id = false;
        pauseButton.remove();
        placeStartRefreshButton(id);
        return false;
    });
    $('#'+id + " div.resize-wrapper").prepend(pauseButton);
}

function placeStartRefreshButton(id){
    var widget = Widgets[id];
    var refresh = widget.preferences.refresh_interval;
    
    $('#'+id + " div.start-button").remove();
    var startButton = $('<div class="start-button">Refresh is inactive (interval of '+ refresh +' seconds is defined). Click here to start refresh. </div>');
    startButton.css("margin-top", "-20px");
    startButton.css("cursor", "pointer");
    startButton.css("text-align", "center");
    //    startButton.css("color", "#111");
    //    startButton.css("background-color", "#bbb");
    startButton.removeClass("ui-state-disabled");
    startButton.addClass("ui-state-active");
    startButton.click(function () {
        refreshWidgetContent(id);
        startButton.remove();
        return false;
    });
    $('#'+id + " div.resize-wrapper").prepend(startButton);
}