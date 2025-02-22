This is a "emulator" for the CHIP-8 virtual platform using PETSCII graphics on the Commander X16.

Controls: Uses the standardized CHIP-8 controls on a keyboard (seen below, original -> keyboard). Backspace key exits the program, 0 toggles sound, -/= decrease and increase the speed of the game respectively, and enter resets the game.

123C \ 1234
456D ------\ QWER
789E ------/ ASDF
A0BF / ZXCV

How to use: CHIP8.PRG can just be loaded and ran like any other program. However, as there is no real loader yet, games should be loaded in with "BLOAD "YOURGAME.CH8",8,0,$3200".

Note: CHIP-8 has a memory range of 4 kilobytes that are mapped to $3000-$3FFF on the X16. Execution is intended to begin at $200 ($3200 on X16) as the first 512 bytes were originally used for the interpreter on 4K systems. The first 512 bytes of memory are technically available for use (With the first 80 always being overwritten for the standard font in this implementation), but are generally ignored due to this old limitation.

Compatibility/Issues: CHIP-8 does have some ambiguous instructions that can vary depending on the implementation. This implementation has the shift instructions affect use only Vx (rather than putting the shifted version of Vy into Vx), and does not have the load/save instructions affect the I register. I also opted to use the beeper sound from BSOUT for sound effects for the time being, which might cause slow gameplay on games that feature large amounts of sound effects. Games that do not utilize sound or use it occasionally should not be heavily affected.
