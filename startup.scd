/*
This is an example startup file. You can load it from your startup file
(to be found in Platform.userAppSupportDir +/+ "startup.scd")
*/

(
var clockMods, clockBeats, screenW, screenH, clockW, clockH, clockX, clockY, resizable, border;


var on, off, cc;
var mutes, solos, muteAll, unmuteAll, unsoloAll, hush;
var playbackControl, playbackState, playbackControl2;
var osc;
var osc1;
var cc1 = 40; // eval multi MIDI-CC
var cc2 = 104; // eval single + move MIDI-CC

s.reboot { // server options are only updated on reboot
    // configure the sound server: here you could add hardware specific options
    // see http://doc.sccode.org/Classes/ServerOptions.html
    s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
    s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
    s.options.numWireBufs = 64; // increase this if you get "exceeded number of interconnect buffers" messages
    s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
    s.options.numOutputBusChannels = 16; // set this to your hardware output channel size, if necessary
    s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
    // boot the server and start SuperDirt
    s.waitForBoot {
        ~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
        //~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
		~dirt.loadSoundFiles("/home/kp-power/Scrivania/TidalCycle/Dirt-Samples/*"); // specify sample folder to load

        // for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
        // s.sync; // optionally: wait for samples to be read
        ~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12, 14]);   // start listening on port 57120, create two busses each sending audio to channel 0

        // optional, needed for convenient access from sclang:
        (
            ~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
            ~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
            ~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
            ~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
			~d13 = ~dirt.orbits[12]; ~d14 = ~dirt.orbits[13];~d15 = ~dirt.orbits[14];
			MIDIClient.init;


	~midiOut= MIDIOut.newByName("Midi Through", "Midi Through Port-0"); // substitute your own device here



	~dirt.soundLibrary.addMIDI(\midi, ~midiOut);


			~midiOut.latency = 0;

        );

	(

//MIDI CC MUTE

mutes = Dictionary[
    65 -> 1,
    66 -> 2,
    67 -> 3,
    68 -> 4,
    69 -> 5,
    70 -> 6,
    71 -> 7,
    72 -> 8
];

// MIDI CC SOLO
solos = Dictionary[
    73 -> 1,
    74 -> 2,
    75 -> 3,
    76 -> 4,
    77 -> 5,
    78 -> 6,
    79 -> 7,
    80 -> 8
];

// This MIDI CC triggers "muteAll"
muteAll = 105;

// This MIDI CC triggers "unmuteAll"
unmuteAll = 106;

// This MIDI CC triggers "unsoloAll"
unsoloAll = 107;

// This MIDI CC triggers "hush"
hush = 108;

/* ------------------------------------------------------- */

playbackState = Dictionary[];

			osc1 = NetAddr.new("127.0.0.1", 3333);

osc = NetAddr.new("127.0.0.1", 6010);


on = MIDIFunc.noteOn({ |val, num, chan, src|
    osc.sendMsg("/ctrl", num.asString, val/127);
});

off = MIDIFunc.noteOff({ |val, num, chan, src|
    osc.sendMsg("/ctrl", num.asString, 0);
});

cc = MIDIFunc.cc({ |val, num, chan, src|
	["CC-Num: " ++ num, "CC-Value:" ++ val].postln;
    osc.sendMsg("/ctrl", num.asString, val/127);
});

if (~stopMidiToOsc != nil, {
    ~stopMidiToOsc.value;
});

~stopMidiToOsc = {
    on.free;
    off.free;
    cc.free;
	};



/* -- MIDI Controller Mapping ---------------------------- */
// Edit this section to configure your MIDI controller

// "mutes" and "solos" are each a Dictionary of MIDI numbers -> Pattern IDs

// In this case, C4, D4 & E4 mute patterns d1, d2 & d3


union(mutes.values.asSet, solos.values.asSet).do({
    arg item;
    playbackState.put(item, Dictionary[\mute -> false, \solo -> false]);
});


MIDIClient.init;
MIDIIn.connectAll;

playbackControl = MIDIFunc.cc({ |val, num, chan, src|
    var patID, patState;
    if (mutes.at(num) !== nil, {
        patID = mutes.at(num);
        patState = playbackState.at(patID);
        if (patState.trueAt(\mute), {
            osc.sendMsg("/unmute", patID);
            patState.put(\mute, false);
        }, {
            osc.sendMsg("/mute", patID);
            patState.put(\mute, true);
        });
    });

    if (solos.at(num) !== nil, {
        patID = solos.at(num);
        patState = playbackState.at(patID);
        if (patState.trueAt(\solo), {
            osc.sendMsg("/unsolo", patID);
            patState.put(\solo, false);
        }, {
            osc.sendMsg("/solo", patID);
            patState.put(\solo, true);
        });
    });

    if (muteAll == num, {
        osc.sendMsg("/muteAll");
        playbackState.do({
            arg patState;
            patState.put(\mute, true);
        });
    });

    if (unmuteAll == num, {
        osc.sendMsg("/unmuteAll");
        playbackState.do({
            arg patState;
            patState.put(\mute, false);
        });
    });

    if (unsoloAll == num, {
        osc.sendMsg("/unsoloAll");
        playbackState.do({
            arg patState;
            patState.put(\solo, false);
        });
    });

    if (hush == num, {
        osc.sendMsg("/hush");
    });

	if (cc1 == num, {
					osc1.sendMsg("/atom/eval", "type", "multi_line");

				});

	if (cc2 == num, {
					osc1.sendMsg("/atom/eval", "type", "line", "row", val, "column", 1, );

				});

});

if (~stopMidiMuteControl != nil, {
    ~stopMidiMuteControl.value;
});

~stopMidiMuteControl = {
    playbackControl.free;
};


/* clock */

clockMods = [4,6];
clockBeats = 4;
screenW = 1440;
screenH = 900;
clockW = 120;
clockH = 22;
clockX = screenW - clockW;
clockY = screenH - 1;
resizable = false;
border = false;

~clockText = StaticText()
.string_("[clock]")
.font_(Font.defaultMonoFace)
.align_(\center)
.stringColor_(Color(1,1,1))
.minHeight_(20);

~updateClock = { |cycle|
    var text, beat;
    text = clockMods.collect { |m| "" ++ (cycle.floor.asInteger.mod(m) + 1) ++ "/" ++ m; }.join(" ");
    beat = (cycle.mod(1)*clockBeats).round.asInteger + 1;
    text = text ++ " " ++ clockBeats.collect { |i| if(i < beat, ".", " "); }.join;
    ~clockText.string_(text);
};

~clockWindow = Window("clock", Rect(clockX, clockY, clockW, clockH), resizable, border)
.background_(Color(0.3,0.3,0.3))
.layout_(
    HLayout(
        ~clockText
    ).margins_(0!4)
);

~clockWindow.alwaysOnTop_(true);
~clockWindow.visible_(true);

SynthDef(\tick, { |cycle|
    SendReply.kr(Impulse.kr(0), "/tick", [cycle]);
    FreeSelf.kr(Impulse.kr(0));
}).add;

OSCdef(\tick, { |msg|
    var cycle;
    #cycle = msg[3..];
    Routine {
        { ~updateClock.(cycle); }.defer;
    }.play(SystemClock);
}, "/tick");


f = { |msg, time, addr|
    if(msg[0] == '/rms') {
		var o = msg[2];
		var vol = (msg[4] + msg[6]);
		if (o < 8) {
			~midiOut.control(0,o+1,(vol*255).min(127));
		}
    }
};
thisProcess.addOSCRecvFunc(f);


		);	};



    s.latency = 0.5; // increase this if you get "late" messages
};
)

