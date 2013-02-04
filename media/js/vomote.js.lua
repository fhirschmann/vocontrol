-- vim: set ft=javascript:
return [[

$.jsonRPC.setup({
    endPoint: "/push/",
    namespace: "vo"
});

function vo(method, args) {
    $.jsonRPC.request(method, {params: [args]});
}

function vo_reload() {
    window.setInterval(function() {location.reload(true)}, 2500);
    vo("reload");
}

function update() {
    $.getJSON("/pull/", function(data) {
        $.each(data, function(key, value) {
            if (key == "sector") {
                $("#sector").find("tr:gt(0)").remove();
                $.each(data[key], function(_, p) {
                    $("#sector tr:last").after(
                      $.format(
                      "<tr id=\"targ_{0}\" class=\"nation{4}\"><td>{1} [{3}%]</td><td>{2}m</tr>",
                      p));
                    $("#targ_" + p[0]).on("click", function() { vo('target', p[0]) });
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
                });
            }
        });
    });

}
]]
