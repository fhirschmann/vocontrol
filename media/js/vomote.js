/**
 * Vendetta Online controlled remotely
 *
 * Copyright 2013 Fabian Hirschmann <fabian@hirschm.net>
 * Released under the MIT license
 */


// Basic setup
$.jsonRPC.setup({
    endPoint: "/push/",
    namespace: "vo"
});

/**
 * Sends an RPC request to VO.
 *
 * @param {String} method the method to call
 * @param {Object} the arguments to the method
 * @param {function} cb function to call back on success
 */
function vo(method, args, cb) {
    $.jsonRPC.request(method, {params: args, success: cb});
}

/**
 * Reloads Vendetta Online's Interface and the Page after 3 seconds.
 */
function vo_reload() {
    window.setInterval(function() {location.reload(true)}, 3000);
    vo("reload");
}

/**
 * Target the player identified by `pid`.
 *
 * @param {Number} pid the player id
 */
function vo_target(pid) {
    vo("target", [pid]);
    $("#sector-player-" + pid).effect(
        "highlight", {color: "#303030"}, 700);
}

/**
 * Returns the CSS class corresponding to the current health [0-100] status.
 *
 * @param {Number} health indicator
 * @return {String} the CSS class
 */
function health2color(health) {
    if (health > 80) {
        return "health-10";
    } else if (health > 50) {
        return "health-9";
    } else if (health > 20) {
        return "health-8";
    } else {
        return "health-7";
    }
}

/**
 * Activates the given tab
 *
 * @param {String} tab the tab to activate.
 */
function activate_tab(tab) {
    $(".tabs").hide();
    $("#tab-" + tab).show();

    $(".nav-event-item").parent().removeClass("active");
    $("#nav-event-" + tab).parent().addClass("active");
}

/**
 * Formats a player using the array returned by the server.
 *
 * @param {Array} array with player information
 * @return {String} the player representation
 */
function format_player(p) {
    return '<font class="nation' + p[3] + '">' +
        (p[5] ? "[" + p[5] + "] " : "") + p[0] + "</font>";
}


/**
 * Formats a sector row for a given player.
 *
 * @param {Number} pid the player id
 * @param {Array} info the player info sent by the server
 * @return {String} an html table entry (td)
 */
function sector_format_row(pid, info) {
    return $.format(
            '<tr id="sector-player-' + pid + '" class="nation{3}">' +
            '<td>' + format_player(info) + '</td>' +
            '<td>{1}</td>' +
            '<td>{6}</td>' +
            '<td class="' + health2color(info[2]) + '">{2}</td>' +
            '<td>{4}</td>' +
            '</tr>', info);
}

/**
 * Adds or updates an existing player in the sector table.
 *
 * @param {Number} pid the player id
 * @param {Array} info the player info sent by the server
 * @return {String} an html table entry (td)
 */
function sector_add_or_update(pid, info) {
    var row = sector_format_row(pid, info);

    if ($("#sector-player-" + pid).length != 0) {
        // Player exists
        var last_health = parseInt($("#sector-player-" + pid).
            find("td:nth-child(3)").text());
        $("#sector-player-" + pid).replaceWith(row);
        if ((info[2] < last_health - 10) && (info[2] != -1)) {
            $("#sector-player-" + pid).effect(
                "highlight", {color: "#5C000C"}, 2000);
        }
    } else {
        // New player
        $("#sector-table tr:last").after(row);
        $("#sector-player-" + pid).hide();
        $("#sector-player-" + pid).fadeIn(fade_delay);
    }
}

/**
 * Keeps only the specified players in the sector list.
 *
 * @param {Array} player_ids the player ids of the players to keep.
 */
function sector_keep_only(player_ids) {
    $("#sector-table").find("tr:gt(0)").each(function() {
        // Remove players that left
        var pid2 = $(this).attr("id").substring(14);
        if (!_.contains(player_ids, pid2)) {
            $(this).fadeOut(fade_delay, function() {
                $(this).remove();
            });
        }
    });
}

/**
 * Adds the msg to the chat box.
 *
 * @param {Array} msg a message sent by the server
 */
function chat_add(msg) {
    var line = msg["formatstring"].replace(/\<(\w+?)\>/g,
        function(match, contents, offset, s) {
            if (contents == "cname") {
                return "COL" + msg["faction_color"] + msg["name"] + "LOC";
            } else {
                return msg[contents];
            }
        });
    line = line.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    line = "COL" + msg["color"] + line + "LOC";
    line = line.replace(/COL#(.{6})/g, "<span style=\"color: #$1\">");
    line = line.replace(/LOC/g, "</span>");
    $("#chat_box").append(line);
    $("#chat_box").append("<br />");
}

/**
 * Scrolls down the chat box.
 */
function chat_scrolldown() {
    $("#chat_box").scrollTop($("#chat_box")[0].scrollHeight);
}

// Whether or not to show bots in the sector list.
var showbots = true;

/**
 * Executes commands sent by the player in VO.
 *
 * @param {Object} data the data sent by VO.
 */
function exec_cmd(data) {
    _.each(data, function(d) {
        switch (d[0]) {
            case "tab":
                activate_tab(d[1]);
                break;
            case "togglebots":
                showbots = !showbots;
                break;
        }
    });
}

/**
 * Adjust the height of the elements according to the window
 * size.
 *
 * I seriously dislike this, so please tell me how to do it in a
 * better way.
 */
function adjust_dimensions() {
    var height = $(window).height();
    var width = $(window).width();
    $("#chat_box").height(height - 250);
}

// Keep track of the last query we received
var last_query = null;

// fade delay for sector listing.
var fade_delay = 700;

/**
 * Pulls update information from the server and updates the page.
 */
function update() {
    $.getJSON("/pull/?last_query=" + last_query, function(queries) {
        last_query = queries[queries.length - 1]["timestamp"];

        _.each(queries, function(data) {
            $.each(data, function(key, value) {
                if (key == "sector") {
                    // Hide bots if `showbots` is true.
                    value = _.filter(value, function(p) {
                        return ((showbots) || p[0].substring(0, 1) != "*");
                    });

                    $.each(value, sector_add_or_update);
                    sector_keep_only(_.keys(value));
                } else if (key == "chat") {
                    _.each(data[key], chat_add);
                    chat_scrolldown();
                } else if (key == "player") {
                    $("#player-name").addClass("nation" + data[key][4]);
                    $("#player-name").html(format_player(data[key]));
                } else if (key == "cmd") {
                    exec_cmd(data[key]);
                }
            });
        });
    });
}

$(function() {
    /**
     * Tab Navigation.
     */
    $(".nav-event-item").click(function() {
        //alert($(this).attr("href"));
        activate_tab($(this).attr("id").substring(10));
    });
    activate_tab("sector");

    /*
     * Sector section starts.
     */
    $("#sector-table").on("click", "tr", function(event) {
        vo_target(parseInt($(this).attr("id").substring(14)));
    });

    /*
     * Chat section starts.
     */

    // Add history to the text input
    $("#chat_msg").inputHistory({size: 30});

    // Handle the channel selection buttons
    $("#channel-options li").on("click", function(event) {
        $("#channel-options li").removeClass("active");
        $("#channel-current").text($(this).text());
        $(this).toggleClass("active");
    });

    // Handle keypresses in the text input
    $("#chat_form").on("keydown", function(e) {
        var keyCode = e.keyCode || e.which;

        if (keyCode == 9) { // TAB
            // Use VO's autocompletion
            e.preventDefault();
            var match = $("#chat_msg").val().match(/(\S+)$/);
            vo("tabcomplete", [match ? match[0] : ""], function(c) {
                if (c["result"] != null) {
                    var res = c["result"][0];

                    // Enclose names with spaces in ""
                    res = res.indexOf(" ") == -1 ? res : '"' + res + '"';
                    $("#chat_msg").val($("#chat_msg").val().replace(/\w*$/, res));
                }
            });
        } else if (keyCode == 13) { // RET
            // Without this, hitting return opens the channel menu for some reason
            event.preventDefault();
            event.stopPropagation();
            $("#chat_form").submit();
        }
    });

    // Submit the chat message that is currently in the text input
    $("#chat_form").submit(function(e) {
        e.stopImmediatePropagation();
        e.preventDefault();
        if ($("#chat_msg").val() != "") {
            // Don't send empty messages
            if ($("#chat_msg").val().charAt(0) == "/") {
                vo("processcmd", [$("#chat_msg").val().slice(1)]);
            } else {
                var dest = $("#channel-options").find(".active").text().toUpperCase();
                vo("chat", [$("#chat_msg").val(), dest]);
            }
            $("#chat_msg").val("");
        }

        return false;
    });

    /*
     * Miscellaneous effects.
     */
    $("#vo_reload").on("click", vo_reload);
    $("#vo-update").on("click", update);

    /*
     * Start the update loop.
     */
    setInterval(function() {
        update();
    }, 2000);
    update();
    chat_scrolldown();

    /*
     * Adjust the interface dimensions.
     */
    $(window).resize(adjust_dimensions);
    adjust_dimensions();
});
