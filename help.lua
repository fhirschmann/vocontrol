local help = [[
This is the vomote help dialog.

If you wish to use vomote, type `/vomote start` now, or set autostart
to true by typing `/vomote config set autostart 1`.

After you've done so, direct your browser to http://IP:PORT. Vomote
defaults to using port 9001. Remember to use vomote in trusted networks
only.

available commands:
vomote    start        start the server
vomote    stop         stop the server
vomote    restart     restart the server
vomote    reload      reload the server (from disk)

commands which impact the current browser view:
vomote    ctrl tab sector          swtiches to the "sector" tab
vomote    ctrl tab chat             switches to the "chat" tab
vomote    ctrl togglebots          shows/hides bots in the sector tab

commands concerned with configuration options:
vomote    config set url URL                     sets the url for static content to URL
vomote    config set autostart {0,1}           turns autostart on/off
vomote    config set interval N, N>0           sets the polling interval to N ms
vomote    config set port N, N>1024           sets the port to listen to to N
vomote    config set debug {0,1}                turns debug mode on/off

vomote    config get OPTION                    gets the value of any of the options mentioned above
]]

return function()
    local ok = iup.stationbutton{title="OK", expand="HORIZONTAL"}
    local dlg = iup.dialog {
        iup.vbox{
            iup.stationnameframe{
                iup.vbox{
                    iup.pdasubframebg{
                        iup.stationsubmultiline{
                            value=help,
                            expand="YES",
                            readonly="YES"
                        },
                    },
                    iup.pdasubsubsubframefull2{
                        iup.hbox{
                            ok,
                            gap = 5
                        }, gap = 5, margin="10x10"
                    }, gap = 5,
                }
            }, margin="10x10"
        }
    }

    iup.SetAttributes(dlg,'\
        RESIZE=NO,\
        MENUBOX=NO,\
        BORDER=NO,\
        EXPAND=NO,\
        MODAL=YES,\
        SIZE=FULLxFULL,\
        ACTIVE=YES,\
        TOPMOST=YES,\
        BRINGFRONT=YES,\
        VISIBLE=YES,\
        BGCOLOR="255 0 0 0 *",\
    ')
    function ok:action() dlg:destroy() end
    dlg:showxy(iup.CENTER, iup.CENTER)
end
