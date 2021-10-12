# BCRST2000

This is a basic setup/repository for use the BCR2000 + SuperCollider 3.11.2 + Tidal Cycles as a mixer/looper/sampler/slicer/fast-navigation tool, the scripts can be also improved and it is a work in progress, so expect to find bugs or errors.

It contains basically a tidal cycle script and a supercollider startup file.

It also contains a very raw bash script to get random patterns of 8 chars using 9 digits (0, 1, 2, 3, 4, 5, 6, 7, ~)

There is no midi channel subdivision at the moment, so its made basically for a single midi chan BRC2000 preset.

This setup is also suitable for any other device so its not strictly reserved to a BCR2000 user.

This setup is useful if one have a lot of folders full of loops or samples (128 banks per track and max 128 sounds per bank). If your folder exceed 128 samples/loops just split it in two different folders.

# {optional}
- Linux is the default system used in this project
- Kxstudio repos are involved for the base audio environment of this project - https://kx.studio/Repositories
- Claudia/Ladish is the default patchbay - "sudo apt install claudia" 
- Atom is the default text editor so install it: https://atom.io/ because we're going to use the default udp atom ports to receive the translated midi/osc in order to be able to move the atom text cursor by midi.



# {mandatory}
- wine + brc2000 manager https://mountainutilities.eu/downloads 
- Install Tidal Cycle and Supercollider IDE http://tidalcycles.org/docs/getting-started/linux_install/



# {functionalities}
# 8 tracks, 8 different sound banks by default: 
- 6 ready to go loops tracks
- 2 ready to go samples tracks
- change bank
- change patterns
- change sample/loops
- mute
- solo
- speed
- evaluate atom code blocks or a single row and move in the editor, all by midi - play
- hush - stop

- Supercollider script contains code and midi cc variables for: hush, mute, solo, editor evaluate and move, these controls refers to the basic Tidal Cycle Patterns: (d1, d2... and so on), and Atom osc control (evaluate, move). It also contains the code for a visual clock. 
 
- Tidal Cycles scripts contains code and midi cc variables for: speed, change sample/loop, change midi/note pattern, also here you can add more and more controls easily  

Its easy peasy to route the supercollider/sclang output channels into any sequencer (i mostly use reaper or ableton) and record the stream.

Easy peasy change the cc number of the controls as you need or add new ones

Other cc controls can be added to the BCR2000 as at this state of the script we're not going to use all the BCR2000 potential 
