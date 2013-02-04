-- vim: set ft=html:
return function(context)
    return [[
<!doctype html>
<html>
<head>
    <meta charset="utf-8" />
    <title>vomote</title>
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.0/themes/base/jquery-ui.css" />
    <script src="http://code.jquery.com/jquery-1.8.3.js"></script>
    <script src="http://code.jquery.com/ui/1.10.0/jquery-ui.js"></script>
    <script src="/media/js/vomote.js"></script>
    <link rel="stylesheet" href="/media/css/style.css" />
    <script>
        $(function() {
            $( "#tabs" ).tabs();
        });
        setInterval(update, 3000);
    </script>
</head>
<body>
    <div id="tabs">
        <ul>
            <li><a href="#tabs-1">Test</a></li>
            <li><a href="#tabs-2">Console</a></li>
            <li><a href="#tabs-3">Map</a></li>
            <li><a href="#tabs-4">Debug</a></li>
        </ul>
        <div id="tabs-1">
            <p>
            Target: <span id="target"></span>
            </p>
        </div>
        <div id="tabs-2">
            <p>
            asdfasfd
            </p>
        </div>
        <div id="tabs-3">
            <p>
            asjkdf
            </p>
        </div>
        <div id="tabs-4">
            <p>
            <pre id="debug">
            </pre>
            </p>
        </div>
    </div>
</body>
</html>
]]
end
