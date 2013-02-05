-- vim: set ft=html:
return function(context)
    printtable(context)
    return string.gsub([[
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
    <script src="https://github.com/jch/jquery.inputHistory/raw/master/jquery.inputHistory.min.js"></script>
    <script src="https://github.com/jeresig/jquery.hotkeys/raw/master/jquery.hotkeys.js"></script>
    <script src="$URL/js/vomote.js"></script>
    <link rel="stylesheet" href="$URL/css/style.css" />
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
            <form id="chat_form">
            <table>
                <tr>
                    <td colspan="3">
                        <div id="chat_box"></div>
                    </td>
                </tr>
                <tr>
                    <td width="100%">
                        <input type="text" id="chat_msg" autocomplete="off" />
                    </td>
                    <td>
                        <select name="chat_dest" id="chat_dest">
                            <option value="SECTOR">Sector</option>
                            <option value="CHANNEL" selected>Channel</option>
                            <option value="GROUP">Group</option>
                            <option value="GUILD">Guild</option>
                            <option value="SYSTEM">System</option>
                        </select>
                    </td>
                    <td>
                        <input type="submit" />
                    </td>
                </tr>
            </table>
            </form>
        </div>
        <div id="tabs-3">
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
]], "%$(%w+)", function(k) return context[k] end)
end
