local help = [[
usage: vomote command

available commands:
vomote    start        start the server
vomote    stop         stop the server
vomote    restart     restart the server
vomote    reload      reload the server (from disk)

vomote    ctrl tab sector          swtiches to the "sector" tab in the browser
vomote    ctrl tab chat             switches to the "chat" tab in the browser

vomote    set url URL                     sets the url for static content to URL
vomote    set autostart {0,1}           turns autostart on/off
vomote    set interval N, N>0           sets the polling interval to N ms
vomote    set port N, N>1024           sets the port to listen to to N
vomote    set evqueuesize N, N>0     sets the size of the event queue to N
vomote    set debug {0,1}                turns debug mode on/off
]]

return function()
    local ok = iup.stationbutton{title="OK", expand="HORIZONTAL"}
    local dlg = iup.dialog {
        iup.vbox{
            iup.stationnameframe{
                iup.vbox{
                    iup.stationsubmultiline{
                        value=help,
                        expand="YES",
                        readonly="YES"
                    },
                    iup.pdasubsubsubframefull2{
                        iup.hbox{
                            ok,
                            gap = 5
                        }, gap = 5, margin="10x10"
                    }, gap = 5,
                }
            }, margin="QUARTERxQUARTER"
        }
    }
    local function ret(s)
        dlg:destroy()
    end

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
