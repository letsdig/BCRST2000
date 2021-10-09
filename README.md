# BCRST2000

This is a setup for use the BCR2000 + Supercollider + Tidal Cycles as a mixer/sampler/slicer/fast-navigation tool, the scripts can be also improved.

It also contains a very raw bash script to get random patterns of 8 chars using 9 digits (0, 1, 2, 3, 4, 5, 6, 7, ~)

There is no channel subdivision at the moment, so its made basically for a single BRC2000 preset.

{optional}
- Linux is the default system used in this project
- Kxstudio repos are involved for the base audio environment of this project - https://kx.studio/Repositories
- Claudia/Ladish is the default patchbay - "sudo apt install claudia" 
- Atom is the default text editor so install it: https://atom.io/ because we're going to use the default udp atom ports to translate midi to osc in order to be able to move the cursors by midi.

- It Implements the haskell "Capply" function and supercollider edits made by: https://club.tidalcycles.org/t/trigger-tidal-code-with-midi/2168

8 tracks, by default: 
- 6 sliced loop tracks and  
- 2 single sample tracks
- mute
- solo
- speed
- fast change control/notes patterns by knob - 128 patterns per track
- fast change sample/loop by knob - 128 loops/samples per track - 8 bar loops slice as default but it can be changed in the code for long loops bar folders
- evaluate atom block code or single row and move in the editor by midi

- Supercollider script contains MIDI code for: mute, solo, editor evaluate and move, these controls refers to the basic Tidal Cycle Patterns: (d1, d2... and so on), and Atom osc control (evaluate, move) 
 
- Tidal Cycles scripts contains MIDI code for: speed, change sample/loop, change midi/note pattern   

Its easy peasy to route the supercollider/sclang output channels into any sequencer (i mostly use reaper or ableton) and record the stream.

Easy peasy change the cc number of the controls as you need

Other cc controls can be added to the BCR2000 as at this state of the script we're not going to use all the BCR2000 potential 
