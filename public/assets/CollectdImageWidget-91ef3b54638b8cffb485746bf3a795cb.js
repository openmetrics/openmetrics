var CollectdImageWidget = CollectdImageWidget || {};
$.extend(CollectdImageWidget, {
    openWidgetForm : function (id) {
        var widget = Widgets[id];
        var dialog_title;
        if (!widget || !widget.id) {
            if (!widget) widget = new Object();
            widget.id = "new";
            if (!widget.preferences) widget.preferences = new Object();
            dialog_title = "Create new CollectdImageWidget"
        }
        else {
            dialog_title = "Edit CollectdImageWidget";
        }
        // dialog div-container is being intialized and appended to content;
        var dialogContainerId = 'collectd_widget_form_' + widget.id;
        var dialogContainer = $( "#"+dialogContainerId );
        if (dialogContainer.length == 0 ) {
            dialogContainer = $('<div class="ui-helper-clearfix"></div>').attr('id', dialogContainerId);
            $('#content').append(dialogContainer);
            // transforming dialog div-container to the jquery-ui dialog
            var dialog = dialogContainer.dialog({
                width: 950,
                height: 500,
                autoOpen: false,
                modal:false,
                resizable: false,
                zIndex: 50000,
                title: dialog_title,
                close: function(event, ui){
                    $(this).dialog('destroy').empty().remove();
                //                    $('#addWidgetButton').button('enable').trigger('enable');
                }
            });
            dialogContainer.dialog('disable');
            dialogContainer.dialog('open');
        }
        else {
            dialogContainer.dialog('moveToTop');
        }
 
        var url = '/collectd_image_widgets/form_step1';

        if (widget.preferences.system_id && typeof(widget.preferences.system_id) == "string")
            widget.preferences.system_id = JSON.parse(widget.preferences.system_id);
        if (widget.preferences.metrics && typeof(widget.preferences.metrics) == "string")
            widget.preferences.metrics = JSON.parse(widget.preferences.metrics);
        
        // fires ajax request to load systems for the systems selection input
        $.ajax({
            url: url,
            type: "POST",
            complete: function(data, textStatus){
                //                $('#collectdImageWidgetForm_ajax-loader').remove();
                if(textStatus=="success") {
                    // callback for systems loading; create systems selection input
                    result = data.responseText;
                    dialogContainer.prepend(result);
                    dialogContainer.dialog('enable');
                    widget.dialogContainer = dialogContainer;
                    initCollectdWidgetSystemSelection(widget);
                    openCollectdWidgetSystemSelection(widget);
                }
            },
            error: function(data, textStatus) {
                notify('error', 'CollectdImageWidget#'+widget.id, textStatus + data);
                dialog.dialog({
                    buttons: null
                });
            }
        });
    },
    getWidgetContent: function (id) {
        var widget = Widgets[id];
        $.ajax({
            url: '/collectd_image_widgets/collectd_data/'+widget.id,
            type: "GET",
            complete: function(data, textStatus){
                if(textStatus=="success") {
                    // callback for systems loading; create systems selection input
                    var result = JSON.parse(data.responseText);
                    // refresh event definition and trigger to redraw flot graph on resize/init
                    // use functions object as container to better handle custom widget functions;
                    widget.functions = {};
                    widget.functions.refresh = function(){
                        flot_onDataReceived(widget, result);
                    };
                    Widgets[widget.id] = widget;
                    widget.functions.refresh();
                }
            },
            error: function(data, textStatus) {
                notify('error', 'CollectdImageWidget#'+widget.id, textStatus + data);
            }
        });
        widget.preferences.title = (widget.preferences.title) ? widget.preferences.title : "";
        var html = "";
        html += "<div class='title ui-widget ui-state-default'><b>"+widget.preferences.title+"</b></div>";
        html += "<div>";
        html += $('#ajaxload').html();
        html += "</div>";
        $('#'+widget.id+" div.content-wrapper").fadeOut(100, function () {$(this).html(html).fadeIn()});
    }
});

function flot_onDataReceived(widget, result) {
    var width;
    var dataVoids;

    var html = "";
    html += "<div class='title ui-state-default'><b>"+widget.preferences.title+"</b></div>";
    html += "<div class='graph'></div>";
    html += "<div class='overview'></div>";
    //    html += "<div class='graph_legend'><div class ='graph_legend_header'><b>Legend:</b></div><div class ='graph_legend_content'></div></div>";
    $('#'+widget.id+" div.content-wrapper").fadeOut(100).html(html).fadeIn();

    $('#'+widget.id+" div.content-wrapper").css({
        'overflow-x':'hidden'
    });

    $('#'+widget.id+" div.content-wrapper div.graph").width("100%");
    width = $('#'+widget.id+" div.content-wrapper div.graph").width() - 20;
    $('#'+widget.id+" div.content-wrapper div.graph").width(width);
    $('#'+widget.id+" div.content-wrapper div.graph").height($('#'+widget.id+" div.content-wrapper").height() - 25);

    if (widget.preferences.show_legend == true) {
//        showLegendAsSidebar(widget.id);
        showLegendAsSidebar(widget);
    }

    var content_wrapper = $('#'+widget.id+" div.content-wrapper");
    var graph = content_wrapper.children("div.graph");
    //    var graphOptions = getGraphOptions(content_wrapper);
    var graphOptions = getGraphOptions(widget.id);
    var current_ranges = null;

    processOptions(result['options']);
    //    graphOptions.grid.markings = result['events'];
    graphOptions.grid.events = result['events'];
    
    if (widget.preferences.show_overview == true) {
        $('#'+widget.id+" div.content-wrapper div.graph").height($('#'+widget.id+" div.content-wrapper div.graph").height() - 75);
        $('#'+widget.id+" div.content-wrapper div.overview").width(width+4);
        $('#'+widget.id+" div.content-wrapper div.overview").height(75);
        var overview = content_wrapper.children("div.overview");
        var overviewOptions = getOverviewOptions();

        // Draw the overview
        var overview_plot = $.plot(overview, result['series'], $.extend(true, {}, overviewOptions, result['options']));

        if(current_ranges != null) {
            overview_plot.setSelection(current_ranges, true);
        }
        
        overview.bind("plotselected", function (event, ranges) {
            current_ranges = ranges;
            // do the zooming
            $.extend(true, graphOptions, {
                xaxis: {
                    min: ranges.xaxis.from,
                    max: ranges.xaxis.to
                },
                yaxis: {
                    min: null,
                    max: null
                }
            });
            graph_plot = $.plot(graph, result['series'], $.extend(true, {}, graphOptions, result['options']));
            customizeGraphCanvas(graph_plot, graph);
            //dataVoids = highlightDataVoids(graph_plot, graph);
//            if (widget.preferences.show_events) highlightEvents(graph_plot, graph);
        });

        overview.bind("plotunselected", function(event) {
            current_ranges = null;
            $.extend(true, graphOptions, {
                xaxis: {
                    min: null,
                    max: null
                },
                yaxis: {
                    min: null,
                    max: null
                }
            });
            graph_plot = $.plot(graph, result['series'], $.extend(true, {}, graphOptions, result['options']));
            customizeGraphCanvas(graph_plot, graph);
//            dataVoids = highlightDataVoids(graph_plot, graph);
//            if (widget.preferences.show_events) highlightEvents(graph_plot, graph);
        });
    } else {
        $('#'+widget.id+" div.content-wrapper div.overview").remove();
    }
    

    //    if (widget.preferences.show_legend == true) {
    //        $('#'+widget.id+" div.content-wrapper div.graph").height($('#'+widget.id+" div.content-wrapper div.graph").height() - 25);
    //        $('#'+widget.id+" div.content-wrapper div.graph_legend").width(width);
    //        $('#'+widget.id+" div.content-wrapper div.graph_legend").height(25);
    //        showLegendAsPortlet(content_wrapper);
    //    } else {
    //        $('#'+widget.id+" div.content-wrapper div.graph_legend").remove();
    //    }

    // Draw the main graph
    var graph_plot = $.plot(graph, result['series'], $.extend(true, {}, graphOptions, result['options']));
    customizeGraphCanvas(graph_plot, graph);
//    dataVoids = highlightDataVoids(graph_plot, graph);
//    if (widget.preferences.show_events) highlightEvents(graph_plot, graph);
    
    if(current_ranges != null) {
        graph_plot.setSelection(current_ranges, true);
    }

    graph.bind("plotselected", function (event, ranges) {
        current_ranges = ranges;
        // do the zooming
        $.extend(true, graphOptions, {
            xaxis: {
                min: ranges.xaxis.from,
                max: ranges.xaxis.to
            },
            yaxis: {
                min: ranges.yaxis.from,
                max: ranges.yaxis.to
            }
        });
        graph_plot = $.plot(graph, result['series'], $.extend(true, {}, graphOptions, result['options']));
        if (overview_plot) overview_plot.setSelection(current_ranges, true);
        customizeGraphCanvas(graph_plot, graph);
        dataVoids = highlightDataVoids(graph_plot, graph);
        if (widget.preferences.show_events) highlightEvents(graph_plot, graph);
    });

    graph.bind("plotunselected", function(event) {
        current_ranges = null;
        $.extend(true, graphOptions, {
            xaxis: {
                min: null,
                max: null
            },
            yaxis: {
                min: null,
                max: null
            }
        });
        graph_plot = $.plot(graph, result['series'], $.extend(true, {}, graphOptions, result['options']));
        if (overview_plot) overview_plot = $.plot(overview, result['series'], $.extend(true, {}, overviewOptions, result['options']));
        customizeGraphCanvas(graph_plot, graph);
        dataVoids = highlightDataVoids(graph_plot, graph);
        if (widget.preferences.show_events) highlightEvents(graph_plot, graph);
    });
    //    console.log(graph_plot.getAxes().yaxis.max);

    graph.first("canvas").bind("mouseleave", function () {
        $('#collectd_graph_tooltip').fadeOut(200);
    });
    graph.bind("plothover", function (event, pos, item) {
        showDatapointTooltip(pos, item);
    });
    graph.bind("plothover", function (event, pos, item) {
        showDatavoidsTooltip(dataVoids, pos, item);
    });
//    graph.bind("plothover", function (event, pos, item) {
//        showEventsTooltip(result['events'], pos, item);
//    });
}

function showEventsTooltip(event, pos) {
    if (event) {
        var date = new Date();
        //            date.setTime(event.xaxis.from-3600000);
        date.setTime(event.xaxis.from);
        date = date.toString().split(" ");
        var time = date[4]
        date = date[0] + ", " + date[2] +". "+ date[1] +" "+ date[3];
        var date1 = new Date();
        //            date1.setTime(event.xaxis.to-3600000);
        date1.setTime(event.xaxis.to);
        date1 = date1.toString().split(" ");
        var time1 = date1[4]
        date1 = date1[0] + ", " + date1[2] +". "+ date1[1] +" "+ date1[3];
        string = '<div style="margin:5px;"><img height="16" src="/images/noun_icons/red3/16x16/calendar.png" style="vertical-align:middle;" />';
        string += '<b style="vertical-align:middle;margin-left:5px;">';
        string += event.prefs.title || ("Event: #"+event.id);
        string += "</b></div>";
        string += '<div style="margin:5px;">';
        string += date+" "+time+" - "+date1+" "+time1;
        string += "<hr />";
        string += event.prefs.description || "-";
        string += "</div>";
        $('#collectd_graph_tooltip').html(string).show();
        var width = $(window).width();
        if (pos.pageX < (width/2)) {
            $('#collectd_graph_tooltip').css({
                top: (pos.pageY-75),
                left: (pos.pageX+25),
                'border-color': '#fff'
            });
        }
        else {
            width = $('#collectd_graph_tooltip').width();
            $('#collectd_graph_tooltip').css({
                top: (pos.pageY-75),
                left: (pos.pageX-35-width),
                'border-color': '#fff'
            });
        }
    }
    else {
        $('<div id="collectd_graph_tooltip" class="collectd_graph_tooltip"><div>').appendTo('#content').hide();
    }
}

// tooltip used to display missing data within graph
function showDatavoidsTooltip(dataVoids, pos, item) {
    if (item)
        return;

    var labels = [];
    $.each(dataVoids, function (label, ranges) {
        $.each(ranges, function(index, range){
            if (pos.x >= range[0] && pos.x <= range[1]) {
                labels.push(label);
                return false;
            }
        });
    });

    if (labels.length > 0) {
        var date = new Date();
        //            date.setTime(pos.x-3600000);
        date.setTime(pos.x);
        date = date.toString().split(" ");
        var time = date[4]
        date = date[0] + ", " + date[2] +". "+ date[1] +" "+ date[3];
        string = '<span style="vertical-align: middle" class="ui-icon ui-icon-alert inline-ui-icon"></span>';
        string += "<strong>Missing metric data at ";
        string += time + " on " + date + "</strong><br />";
        string += labels.join("<br />");
        //        console.log(string);
        $('#collectd_graph_tooltip').html(string).show();
        var width = $(window).width();
        if (pos.pageX < (width/2)) {
            $('#collectd_graph_tooltip').css({
                top: (pos.pageY-75),
                left: (pos.pageX+25),
                'border-color': '#f00'
            });
        }
        else {
            width = $('#collectd_graph_tooltip').width();
            $('#collectd_graph_tooltip').css({
                top: (pos.pageY-75),
                left: (pos.pageX-35-width),
                'border-color': '#f00'
            });
        }
    }
    else {
        $('<div id="collectd_graph_tooltip" class="collectd_graph_tooltip"><div>').appendTo('#content').hide();
    }
}

function showDatapointTooltip(pos, item) {
    if (item) {
        if ($('#collectd_graph_tooltip').length != 0) {
            var timestamp = item.datapoint[0];
            var date = new Date();
            //            date.setTime(timestamp-3600000);
            date.setTime(timestamp);
            date = date.toString();
            date = date.split(" ");
            //console.log(date)
            var time = date[4]
            date = date[0] + ", " + date[2] +". "+ date[1] +" "+ date[3];
            var val2 = item.datapoint[1];
            var val1 = item.series.data[item.dataIndex][1];
            //            var val1 = item.datapoint[1];
            var formatter = item.series.yaxis.tickFormatter;
            val1 = formatter(val1, item.series.yaxis);
            val2 = formatter(val2, item.series.yaxis);
            string = "<b>" + val1;
            if (item.series.stack)
                string += " (stacked: " + val2 + ")";
            string += " at " + time + " on " + date + "</b>";
            string += "<br />";
            string += "System: "+item.series.label.replace(/:/, "<br />Metric: ");
            $('#collectd_graph_tooltip').html(string).show();
            var width = $(window).width();
            if (pos.pageX < (width/2)) {
                $('#collectd_graph_tooltip').css({
                    top: (pos.pageY-75),
                    left: (pos.pageX+25),
                    'border-color': item.series.color
                });
            }
            else {
                width = $('#collectd_graph_tooltip').width();
                $('#collectd_graph_tooltip').css({
                    top: (pos.pageY-75),
                    left: (pos.pageX-35-width),
                    'border-color': item.series.color
                });
            }
        }
        else {
            $('<div id="collectd_graph_tooltip" class="collectd_graph_tooltip"><div>').appendTo('#content').hide();
        }
    }
    else {
        $('#collectd_graph_tooltip').hide();
    }
}

function customizeGraphCanvas(graph_plot, graph) {
    var ctx = graph_plot.getCanvas().getContext("2d");
    var o = graph_plot.getPlotOffset();

    // draw x- and y-axes
    ctx.beginPath();
    ctx.lineWidth = 1;
    ctx.globalAlpha= 1.0;
    ctx.moveTo(o.left - 2, o.top);
    ctx.lineTo(o.left - 2, graph_plot.height()+o.top + 2);
    ctx.lineTo(graph_plot.width()+o.left, graph_plot.height()+o.top + 2);
    ctx.stroke();
    ctx.closePath();

    // draw trianle at x-axes end
    ctx.beginPath();
    ctx.moveTo(o.left - 2, o.top - 2);
    ctx.lineTo(o.left - 5, o.top + 5);
    ctx.lineTo(o.left + 1, o.top + 5);
    ctx.lineTo(o.left - 2, o.top - 2);
    ctx.fillStyle = "#000000";
    ctx.fill();
    ctx.closePath();
    // draw trianle at y-axes end
    ctx.beginPath();
    ctx.moveTo(graph_plot.width()+o.left + 5, graph_plot.height()+o.top + 2);
    ctx.lineTo(graph_plot.width()+o.left-2, graph_plot.height()+o.top - 1);
    ctx.lineTo(graph_plot.width()+o.left-2, graph_plot.height()+o.top + 5);
    ctx.lineTo(graph_plot.width()+o.left + 5, graph_plot.height()+o.top + 2);
    ctx.fillStyle = "#000000";
    ctx.fill();
    ctx.closePath();
}

function highlightDataVoids(graph_plot, graph) {
    var dataVoids = {};
    var series = graph_plot.getData();
    var graph_canvas = graph_plot.getCanvas();
    var canvas = $(graph_canvas).prev('.canvas.custom');

    if (canvas.length == 0) {
        graph_canvas = $(graph_canvas);
        var width = $(graph_canvas).width();
        var height = $(graph_canvas).height();
        canvas = graph_canvas.parent().append('<canvas class="custom" width="'+width+'" height="'+height+'" style="position: absolute; left: 0px; top: 0px;"></canvas>');
    }

    // FIXME this errors with next is not a function
    canvas = graph_plot.getCanvas().next('canvas').next("canvas.custom");
    var ctx = canvas.getContext("2d");

    var offset = graph_plot.getPlotOffset();
    var height = graph_plot.height() + 4;

    $.each(series, function(x, serie) {
        var start, finish;
        $.each(serie.data, function (s, datapoint) {
            if (!start && datapoint[1] === null) {
                start = datapoint[0];
            }
            if (start && (datapoint[1] !== null || s == (serie.data.length-1))) {
                finish = (serie.data[s]) ? serie.data[s][0] : serie.data[s-1][0];
                dataVoids[serie.label] = (dataVoids[serie.label]) ? dataVoids[serie.label] : [];
                dataVoids[serie.label].push([start, finish]);
                var a, b;
                a = graph_plot.pointOffset({
                    x: start,
                    y: 0
                });
                b = graph_plot.pointOffset({
                    x: finish,
                    y: 0
                });
                if (a.left < offset.left) a.left = offset.left;
                if ((b.left-a.left) > 0) {
                    ctx.beginPath();
                    ctx.moveTo(a.left, a.top);
                    ctx.lineTo(a.left, 4);
                    ctx.lineTo(b.left, 4);
                    ctx.lineTo(b.left, height);
                    ctx.lineTo(a.left, height);
                    ctx.fillStyle = "#ff0000";
                    ctx.globalAlpha= .05;
                    ctx.fill();
                }
                start = finish = null;
            }
        });
    });
    $(canvas).prependTo(graph_canvas.parent());
    return dataVoids;
}

function highlightEvents(graph_plot, graph) {
    var options = graph_plot.getOptions();
    var events = options.grid.events;
    //    console.log(events);
    if (events.length < 1)
        return;

    var offset = graph_plot.getPlotOffset();
    var ctx = graph_plot.getCanvas();
    var ctx_width = $(ctx).width();
    var ctx_height = $(ctx).height() - offset.top - offset.bottom - 3 - 3 - 6;
    
    var event_height = (Math.floor(ctx_height / events.length) > 16) ? 16 : Math.floor(ctx_height / events.length);
    var top = offset.top + 3;
    

    $.each(events, function(i, event) {
        var a, b;
        a = graph_plot.pointOffset({
            x: event.xaxis.from,
            y: 0
        });
        b = graph_plot.pointOffset({
            x: event.xaxis.to,
            y: 0
        });

        if (a.left < offset.left) a.left = offset.left;
        if (b.left > ctx_width) b.left = $(ctx).width() - offset.right - 3;
        var event_width = Math.max((b.left-a.left - 3 - 4), 16);
        var icon = $('<img height="'+event_height+'" style="cursor:pointer;" src="/images/noun_icons/red3/16x16/calendar.png" style="vertical-align:middle;" />')
        .click(function(){
            $(location).attr('href',"/events/"+event.id);
        });
        //            var div = $('<div class="collectd_graph_event"></div>')
        var div = $('<div class="collectd_graph_event ui-widget-header ui-corner-all "></div>')
        .append(icon)
        .css({
            left: (a.left),
            top: top
        })
        .width(event_width)
        .height(event_height)
        .appendTo(graph);
        div.mouseenter(function (e) {
            showEventsTooltip(event, e);
            div.bind('mousemove', function(e) {
                showEventsTooltip(event, e);
            });

        });
        div.mouseleave(function () {
            div.unbind('mousemove', function(e) {
                showEventsTooltip(event, e);
            });
            showEventsTooltip();
        });
        top += event_height + 12;
    });
}

var unitFunctions = {
    bytes: function(val, axis) {
        if (val >= 1099511627776)
            return (val / 1099511627776).toFixed(axis.tickDecimals) + " TB";
        else if (val >= 1073741824)
            return (val / 1073741824).toFixed(axis.tickDecimals) + " GB";
        else if (val >= 1048576)
            return (val / 1048576).toFixed(axis.tickDecimals) + " MB";
        else if (val >= 1024)
            return (val / 1024).toFixed(axis.tickDecimals) + " kB";
        else
            return val.toFixed(axis.tickDecimals) + " B";
    },
    percents: function(val, axis) {
        return val.toFixed(axis.tickDecimals) + " %";
    },
    bits: function(val, axis) {
        return val.toFixed(axis.tickDecimals) + " bits";
    },
    issues: function(val, axis) {
        return val.toFixed(axis.tickDecimals) + " issues";
    },
    ops: function(val, axis) {
        return val.toFixed(axis.tickDecimals) + " ops";
    },
    merged_ops: function(val, axis) {
        return val.toFixed(axis.tickDecimals) + " ops";
    },
    time: function(val, axis) {
        return val.toFixed(axis.tickDecimals) + " seconds";
    },
    jiffies: function(val, axis) {
        return val.toFixed(axis.tickDecimals) + " jiffies";
    },
    value: function(val, axis) {
        return val.toFixed(axis.tickDecimals);
    }
};

function processOptions(metricOptions) {
    if(!$.isFunction(metricOptions['yaxis']['tickFormatter'])) {
        var yaxis = metricOptions['yaxis'];
        if(yaxis['tickFormatter']) {
            metricOptions['yaxis']['tickFormatter'] = unitFunctions[yaxis['tickFormatter']];
        }
    }
}

//function getGraphOptions(content_wrapper) {
function getGraphOptions(id) {
    var legend_container = $('#'+id + " div.resize-wrapper").find("div.graph_legend_content");
    return {
        shadowSize: 0,
        lines: {
            show: true,
            fill: 1.0,
            lineWidth: 0
        },
        points: {
            show:true,
            fill:true,
            radius: 1.0,
            fillColor: "#000000"
        },
        xaxis: {
            mode: 'time',
            timezone: 'browser'
            // FIXME timezone: 'America/Chicago' should work too, but it doesn't: graph remains empty :(
        },
        yaxis: {
            labelWidth: 53,
            tickDecimals: 2
        },
        legend: {
            //            container: content_wrapper.find("div.graph_legend_content")
            //            container: $('#'+id + " div.resize-wrapper").find("div.graph_legend_content")
            container: legend_container
        },
        grid: {
            autoHighlight: true,
            hoverable:true,
            aboveData: true,
            mouseActiveRadius: 20,
            borderWidth: 0,
            aboveData: true
        }
        ,
        selection: {
            mode: "both"
        }
    };
}

function getOverviewOptions(){
    return {
        shadowSize: 0,
        lines: {
            show: true,
            fill: 1.0,
            lineWidth: 0
        },
        points: {
            show:false
        },
        xaxis: {
            mode: 'time',
            timezone: 'browser'
        },
        yaxis: {
            ticks: [],
            labelWidth: 53
        },
        legend: {
            show: false
        },
        grid: {
            aboveData: true
        }
        ,
        selection: {
            mode: "x"
        }
    };
}

function showLegendAsPortlet(content_wrapper) {
    if (content_wrapper.children(".graph_legend").find("span.ui-icon").size() == 0) {
        content_wrapper.children(".graph_legend")
        .find(".graph_legend_header")
        .prepend('<span class="ui-icon ui-icon-minusthick"></span>')
        .end();

        content_wrapper.find(".graph_legend_header")
        .css("cursor", "pointer")
        .click(function() {
            $(this).children(".ui-icon").toggleClass("ui-icon-minusthick").toggleClass("ui-icon-plusthick").css({
                display: "inline-block"
            });
            $(this).parents(".graph_legend:first").find(".graph_legend_content").toggle();
        }).click();
    }
}

//function showLegendAsSidebar(id){
function showLegendAsSidebar(widget){
    //function showLegendAsSidebar(id, content_wrapper){
    //    var widget = Widgets[id];
    var id = widget.id;
    var width = $('#'+id + " div.resize-wrapper").width();
    var height = $('#'+id + " div.resize-wrapper").height();
    

    var legend = $("<div class='collectd_graph_legend hidden'></div>");
    legend.html("<div class='graph_legend_expandable'><div class ='graph_legend_header ui-widget-header'><b>Legend:</b></div><div class ='graph_legend_content'></div></div>");
    legend.css("margin-left", (width + 2));
    legend.css("height", height - 2);
//    legend.css("margin-left", (widget.sizex + 2));
//    legend.css("height", widget.sizey - 2);
    legend.addClass("ui-widget ui-widget-content ui-corner-right");
    $('#'+id + " div.resize-wrapper div.collectd_graph_legend").remove();
    $('#'+id + " div.resize-wrapper").prepend(legend);
    legend.find("div.graph_legend_content").css("height", height - 20);

    var legend_expander = $("<div class ='graph_legend_expander ui-state-default  ui-corner-right'></div>");
    legend_expander.css("height", height - 4);
    legend.append(legend_expander);
    legend.prepend(legend_expander);
    legend_expander
    .css("cursor", "pointer")
    .click(function() {
        $(this).parent().find('div.graph_legend_expandable').toggle(200);
        $(this).parent('div.expanded').animate({'width': '10px'}, 500);
        $(this).parent('div.hidden').animate({'width': '300px'}, 300);
        $(this).parent().toggleClass('expanded').toggleClass('hidden');
        return false;
    })
    .click();
}
;
