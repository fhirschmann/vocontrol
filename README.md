# vocontrol
Vocontrol is an add-on for the video game [Vendetta Online](http://vendetta-online.com) that lets
you use additional devices (e.g. a second monitor, a tablet, a phone)
in order to control certain aspects of the game.

It is currently capable of displaying the entire ingame **chat interface**
and the **targeting computer** ("sector list") on any webbrowser.

This is possible because vocontrol utilizes [vohttp](http://github.com/fhirschmann/vohttp), a webserver
that is written in Vendetta Online's subset of the Lua programming
language.

## Security Note
Vocontrol currently has __no security mechanisms__ in place! If you are in an untrusted network,
use your operating systems mechanism to block access to Vocontrol for everybody
except the IP of the device you wish to pair Vendetta Online with.

## User Setup
You can download a vocontrol relase from [this site](http://dl.0x0b.de/vocontrol) and
extract it to your `~/.vendetta/plugins` directory. After you have done so,
type `/vocontrol help` ingame and follow the instructions.

## Developer Setup
If you wish to contribute to vocontrol, the following instructions will
get you started:

    cd ~/.vendetta/plugins
    git clone --recursive git://github.com/fhirschmann/vocontrol.git
    export PATH=$PATH:`pwd`/vocontrol/lib/vohttp/tools

    cd vocontrol
    make

I recommend running a local webserver when messing with the Javascript code.
You can instruct vocontrol to load JS from a different location by executing
`/vocontrol config set url http://localhost/vocontrol`. The HTML
code will still be served by [vohttp](http://github.com/fhirschmann/vohttp),
and thus needs to be refreshed by calling `/lua ReloadInterface()`.
