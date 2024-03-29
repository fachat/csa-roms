
# ROM contents

This folder contains files and code to build a ROM image that can be burned into the 32k ROM on the BIOS board, so that it actually boots.

## Memory Map


	Boot Image
        
        +----+ $ffff
        |    |         BASIC 4 Kernal ROM image
        +----+ $f000
        |    |         2k 80 col EDITOR ROM (filled w/ zeros)
        +----+ $e000
        |    |         12k PET BASIC4
        |    | 
        +----+ $b000
        |    |         4k @MON in the PET4 variant (without editor extension)
        +----+ $a000
        |    |         - empty
        +----+ $9000
        |    |         40 column EDITOR for BASIC4 (to be remapped using the MMU)
        +----+ $8000

## Build

To build the ROM, just run "make".
This build process for bootimg downloads the necessary ROM images from the internet, builds the boot loader, and combines everything into a single boot image.
Then burn the resulting file "romimg" into a 32k (E)EPROM fitting the CS/A BIOS board. 

If you use larger EPROMs there,
burn it at address range 32-64k (i.e. the second 32k). This is due to the BIOS board mapping the ROM addresses
one-to-one into the lowest 64k address space. A 32k EPROM would be mirrored, but larger EPROMs need correct
addresses.

## Files

The following files are test files, or to build the ROMs:

- charPet2Invers.c: a PET charrom is only 2k and lacks inverted characters, as they are generated by hardware. This small program creates, from the 2k PET image, a full 4k image that contains the inverted characeters
- edit....asm: control files for Steve Gray's editor ROM project, to build the custom editor ROMs
-- edit40gx: 40 column for graphics keyboard with wedge and special keys
-- edit80gx: 80 column for graphics keyboard with wedge and special keys
-- edit40gxc: 40 column for C64 keyboard with wedge and special keys
-- edit80gxc: 80 column for C64 keyboard with wedge and special keys
-- edit40gc: 40 column for C64 keyboard (no further extensions) 
-- edit80gc: 80 column for C64 keyboard (no further extensions)

## ROM features

The editor ROMs are non-standard, and feature some extensions.
Note that they are only available for BASIC 4 variants.

### Graphics keyboard ROMs

These are derived from the standard PET ROMs, but feature some extensions:

1. Shift + '@': switch between text and graphics display.
1. '@' + Left-Shift + Right-Shift + DEL: reset the PET

### C64 keyboard ROMs

The ...gc ROM files enable the use of a C64 keyboard instead of a PET graphics keyboard. 
The initial boot loader, where the model is selected detects the keyboard used using the numbers
pressed to select the model, and automatically loads the correct ROM.

Note that due to code size restrictions, only the normal and shifted keys are supported. CBM and Control
are currently ignored.

The follwing features are present:

1. Shift + Left-Arrow: switch between text and graphics display.
1. Ctrl + Left-Shift + Right-Shift + DEL: reset the PET

### Extended machine language monitor

In the ROM area at $a000 there is the @MON machine language monitor included (with assembler
and disassembler, and versatile search functions). 
The apmona version has scrolling (up and down) enabled, but only works with the original 
editor ROMs - unfortunately not with the editor ROMs from Steve Gray.

Note that the scrolling editor is (for now) disabled due to incompatibilities with the modified
editor ROMs in the apmonax version.

