-- vim: set ft=html:
return function(context)
    return [[
<!doctype html>
<html>
<head>
    <meta charset="utf-8" />
    <title>vomote</title>
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.0/themes/vader/jquery-ui.css" />
    <script src="http://code.jquery.com/jquery-1.8.3.js"></script>
    <script src="http://code.jquery.com/ui/1.10.0/jquery-ui.js"></script>
    <script src="http://vomote.0x0b.de/js/jquery.utils.min.js"></script>
    <script src="http://vomote.0x0b.de/js/jquery.jsonrpc.js"></script>
    <script src="/media/js/vomote.js"></script>
    <link rel="stylesheet" href="/media/css/style.css" />
    <script>
        $(function() {
            $( "#tabs" ).tabs();
        });
        setInterval(function() {
            update();
        }, 2500);
        update();

        $("#vo_reload").live("click", vo_reload);
    </script>
</head>
<body>
    <div id="tabs">
        <ul>
            <li><a href="#tabs-1">Sector</a></li>
            <li><a href="#tabs-2">Chat</a></li>
            <li><a href="#tabs-3">Map</a></li>
            <li><a href="#tabs-4">Debug</a></li>
        </ul>
        <div id="tabs-1">
            <table id="sector">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Distance</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
        <div id="tabs-2">
            <p>
            <div id="chat_box">
            </div>
            <form>
            <input type="text" name="chat_msg" id="chat_send" />
            </form>
            </p>
        </div>
        <div id="tabs-3">
            <p>
            </p>
        </div>
        <div id="tabs-4">
            <p>
            <button id="vo_reload">Reload Interface</button>
            </p>
        </div>
    </div>
    <pre id="debug"></pre>
</body>
</html>
]]
end
