# vomote
Vomote is an add-on for the video game [Vendetta Online](http://vendetta-online.com) that lets
you use additional devices (e.g. a second monitor, a tablet, a phone)
in order to control certain aspects of the game.

It is currently capable of displaying the entire ingame **chat interface**
and the **targeting computer** ("sector list") on any webbrowser.

This is possible because vomote utilizes [vohttp](http://github.com/fhirschmann/vohttp), a webserver
that is written in Vendetta Online's subset of the Lua programming
language.

## User Setup
You can download a vomote relase from TODO and
extract it to your `~/.vendetta/plugins` directory. After you have done so,
type `/vomote help` ingame and follow the instructions.

## Developer Setup
If you wish to contribute to vomote, the following instructions will
get you started:

    cd ~/.vendetta/plugins
    git clone --recursive git://github.com/fhirschmann/vomote.git

    cd vomote
    make
