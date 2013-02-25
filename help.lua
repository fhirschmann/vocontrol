local help = [[
This is the vocontrol help dialog.

If you wish to use vocontrol, type `/vocontrol start` now, or set autostart
to true by typing `/vocontrol config set autostart 1`.

After you've done so, direct your browser to http://IP:PORT. Vocontrol
defaults to using port 9001. Remember to use vocontrol in trusted networks
only.

available commands:
vocontrol    start        start the server
vocontrol    stop         stop the server
vocontrol    restart     restart the server
vocontrol    reload      reload the server (from disk)

commands which impact the current browser view:
vocontrol    ctrl tab sector          swtiches to the "sector" tab
vocontrol    ctrl tab chat             switches to the "chat" tab
vocontrol    ctrl togglebots          shows/hides bots in the sector tab

commands concerned with configuration options:
vocontrol    config set url URL                     sets the url for static content to URL
vocontrol    config set autostart {0,1}           turns autostart on/off
vocontrol    config set interval N, N>0           sets the polling interval to N ms
vocontrol    config set port N, N>1024           sets the port to listen to to N
vocontrol    config set debug {0,1}                turns debug mode on/off

vocontrol    config get OPTION                    gets the value of any of the options mentioned above
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
