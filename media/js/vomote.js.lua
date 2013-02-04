-- vim: set ft=javascript:
return [[

$.jsonRPC.setup({
    endPoint: "/push/",
    namespace: "vo"
});

function vo(method, args) {
    $.jsonRPC.request(method, {params: [args]});
}

function update() {
    $.getJSON("/pull/", function(data) {
        $.each(data, function(key, value) {
            if (key == "sector") {
                $("#sector").find("tr:gt(0)").remove();
                $.each(data[key], function(_, p) {
                    $("#sector tr:last").after(
                      $.format(
                      "<tr id=\"targ_{0}\"><td>{1} [{3}%]</td><td>{2}m</tr>",
                      p));
                    $("#targ_" + p[0]).on("click", function() { vo('target', p[0]) });
                });
            }
        });
    });

}
]]
