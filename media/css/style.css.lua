-- vim: set ft=css:
css = [[
body {
	font-family: "Trebuchet MS", "Helvetica", "Arial",  "Verdana", "sans-serif";
	font-size: 62.5%;
    background-color: #1f1f1f;
}

table {
    border-spacing: 5px;
}

thead th {
    text-align: left;
}

tr.even td {
    background-color: yellow;
    background-color: orange;
}

table tbody {
    padding: 5px;
}

.itani, .nation1 {
    color: #8080ff;
}

.serco, .nation2 {
    color: #ff0000;
}

.uit, .nation3 {
    color: #ffff00;
}

.unaligned, .nation4 {
    color: #909090;
}

#chat_box {
    overflow: auto;
    height: 400px;
}

#chat_send {
}

#chat_box, #chat_msg {
    border: 1px solid #000;
    background-color: #1e1e1e;
    color: #efefef;
    width: 100%;
}

]]
return css
