-- vim: set ft=javascript:
return [[
function update() {
    $.getJSON("/pull/", function(data) {
        $("#debug").text(JSON.stringify(data));
        $.each(data, function(i, value) {
        });
    });
}
]]
