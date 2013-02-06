$.jsonRPC.setup({
    endPoint: "/push/",
    namespace: "vo"
});

function vo(method, args, cb) {
    $.jsonRPC.request(method, {params: args, success: cb});
}

function vo_reload() {
    window.setInterval(function() {location.reload(true)}, 2500);
    vo("reload");
}

function vo_target(pid) {
    vo("target", [pid]);
    $("#targ_" + pid).effect("highlight", {color: "#424242"}, 1500);
}

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

$(function() {
    $("#chat_msg").keypress(function(event) {
        var sel = null;
        if ((event.which == 103 && event.ctrlKey)) {
            event.preventDefault();
            sel = "GUILD";
        } else if ((event.which == 71 && event.ctrlKey)) {
            event.preventDefault();
            sel = "GROUP";
        } else if ((event.which == 99 && event.ctrlKey)) {
            event.preventDefault();
            sel = "CHANNEL";
        } else if ((event.which == 115 && event.ctrlKey)) {
            event.preventDefault();
            sel = "SECTOR";
        }

        if (sel != null) {
            $("#chat_dest").val(sel);
        }
    });
    /*
    $("#map_systems").on("click", "area", function(e) {
        alert($(this).attr("alt"));
    });
    */

    $("#vo_reload").live("click", vo_reload);
    $("#chat_msg").inputHistory({size: 30});
    $("#channel-options").click(function() {
        $(this).toggleClass("active");
    });
    $("#chat_form").live("keydown", function(e) {
        var keyCode = e.keyCode || e.which;

        if (keyCode == 9) {
            e.preventDefault();
            var match = $("#chat_msg").val().match(/(\S+)$/);
            vo("tabcomplete", [match ? match[0] : ""], function(c) {
                if (c["result"] != null) {
                    var res = c["result"][0];

                    // Enclose names with spaces in ""
                    res = res.indexOf(" ") ? '"' + res + '"' : res;
                    $("#chat_msg").val($("#chat_msg").val().replace(/\w*$/, res));
                }
            });
        } else if (keyCode == 13) {
            event.preventDefault();
            event.stopPropagation();
            $("#chat_form").submit();
        }
    });

    update();

    $("#chat_form").submit(function(e) {
        e.stopImmediatePropagation();
        e.preventDefault();
        if ($("#chat_msg").val() != "") {
            if ($("#chat_msg").val().charAt(0) == "/") {
                vo("processcmd", [$("#chat_msg").val().slice(1)]);
            } else {
                vo("chat", [$("#chat_msg").val(), $("#chat_dest").val()]);
            }
            $("#chat_msg").val("");
        }

        return false;
    });

    setInterval(function() {
        update();
    }, 2000);

});

var last_query = null;

function update() {
    $.getJSON("/pull/?last_query=" + last_query, function(queries) {
        last_query = queries[queries.length - 1]["timestamp"];
        $.each(queries, function(_, data) {
            $.each(data, function(key, value) {
                if (key == "sector") {
                    $("#sector").find("tr:gt(0)").remove();
                    $.each(data[key], function(_, p) {
                        $("#sector tr:last").after(
                          $.format(
                          '<tr id="targ_{0}" class="nation{4}">' +
                          '<td>{1}</td>' +
                          '<td>' + ((p[2] == '-1') ? '' : '{2}m') + '</td>' +
                          '<td class="' + health2color(p[3]) + '">' + 
                              ((p[3] == '-1') ? '' : '{3}') + '</td>' +
                          '<td>{5}</td>' +
                          '</tr>',
                          p));
                        $("#targ_" + p[0]).on("click", function() { vo_target(p[0]); } );
                    });
                } else if (key == "chat") {
                    $.each(data[key], function(_, m) {
                        var line = m["formatstring"].replace(/\<(\w+?)\>/g,
                            function(match, contents, offset, s) {
                                if (contents == "cname") {
                                    return "COL" + m["faction_color"] + m["name"] + "LOC";
                                } else {
                                    return m[contents];
                                }
                            });
                        line = line.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
                        line = "COL" + m["color"] + line + "LOC";
                        line = line.replace(/COL#(.{6})/g, "<span style=\"color: #$1\">");
                        line = line.replace(/LOC/g, "</span>");
                        $("#chat_box").append(line);
                        $("#chat_box").append("<br />");
                        $("#chat_box").scrollTop($("#chat_box")[0].scrollHeight);
                    });
                }
            });
        });
    });
}
