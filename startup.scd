/*
This is a custom Super Collider startup file. You can load it from your startup file
(to be found in Platform.userAppSupportDir +/+ "startup.scd")
*/

(

var on, off, cc;
var mutes, solos, muteAll, unmuteAll, unsoloAll, hush;
var playbackControl, playbackState, playbackControl2;
var osc;
var osc1;
var cc1 = 40;

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
		    ~dirt.loadSoundFiles("/yoursamplesfolderpath/*"); // specify sample folder to load

        // for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
        // s.sync; // optionally: wait for samples to be read
        ~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12, 14]);   // 8 stereo outputs

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

// In this case, F4, G4 & A4 solo patterns d1, d2 & d3
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

// This MIDI note triggers "muteAll"
// In this case, it's set to C5
muteAll = 105;

// This MIDI note triggers "unmuteAll"
// In this case, it's set to D5
unmuteAll = 106;

// This MIDI note triggers "unsoloAll"
// In this case, it's unused
unsoloAll = 107;

// This MIDI note triggers "hush"
// In this case, it's unused
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
    osc.sendMsg("/ctrl", num.asString, val);
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

	if (104 == num, {
					osc1.sendMsg("/atom/eval", "type", "line", "row", val, "column", 1, );

				});

});

if (~stopMidiMuteControl != nil, {
    ~stopMidiMuteControl.value;
});

~stopMidiMuteControl = {
    playbackControl.free;
};





		);

	};









    s.latency = 0.5; // increase this if you get "late" messages
};
)




