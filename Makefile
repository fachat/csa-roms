
all: romimg romimg64k romcheck rompatch

PATCHES=initmmu reset crtctab40 crtctab80 
TOOLS=rompatch romcheck
PRGS=

# Steve Gray's editor ROM project
EDITROMS=edit80gx.bin edit40gx.bin edit40gc.bin edit80gc.bin edit40gxc.bin edit80gxc.bin 

romimg64k: romimg zero
	cat zero zero zero zero zero zero zero zero 	> romimg64k
	cat zero zero zero zero zero zero zero zero 	>> romimg64k
	cat romimg 					>> romimg64k

romimg: zero edit40gp edit80gp apmonax basic4 kernal4p apmona 
	cat edit40gp zero				> romimg	# $8xxx: 4k 40 column editor ROM
	cat zero zero					>> romimg	# $9xxx: empty
	cat apmona					>> romimg	# $axxx: 4-8k   : @MON monitor (sys40960)
	cat basic4 					>> romimg	# $b-$dxxx: 48-60k : BASIC4 ROMS (12k $b000-$dfff)
	cat edit80gp zero				>> romimg	# $exxx: (original) BASIC 4 80 column editor ROM (graph keybd)
	cat kernal4p					>> romimg	# $fxxx: 60-64k : BASIC4 kernel (4k)

zero: 
	dd if=/dev/zero of=zero bs=2048 count=1

charPet2Invers: charPet2Invers.c
	gcc -o charPet2Invers charPet2Invers.c
	
# PET ROMs

ARCHIVE=http://www.zimmers.net/anonftp/pub/cbm

chargen_pet:
	curl -o chargen_pet $(ARCHIVE)/firmware/computers/pet/characters-2.901447-10.bin

basic4:
	curl -o basic4b $(ARCHIVE)/firmware/computers/pet/basic-4-b000.901465-23.bin 
	curl -o basic4c $(ARCHIVE)/firmware/computers/pet/basic-4-c000.901465-20.bin 
	curl -o basic4d $(ARCHIVE)/firmware/computers/pet/basic-4-d000.901465-21.bin 
	cat basic4b basic4c basic4d > basic4
	rm basic4b basic4c basic4d

kernal4:
	curl -o kernal4 $(ARCHIVE)/firmware/computers/pet/kernal-4.901465-22.bin

edit40g:
	curl -o edit40g $(ARCHIVE)/firmware/computers/pet/edit-4-40-n-50Hz.901498-01.bin
	
edit80g:
	curl -o edit80g $(ARCHIVE)/firmware/computers/pet/edit-4-80-n-50Hz.4016_to_8016.bin

${EDITROMS}: %.bin: %.asm
	test -e cbm-edit-rom || git clone https://github.com/sjgray/cbm-edit-rom.git
	cp $< cbm-edit-rom/edit.asm
	cd cbm-edit-rom && acme -r editrom.txt editrom.asm
	cp cbm-edit-rom/editrom.bin $@

# load other PET Editor ROM and reboot

${PRGS}: % : %.lst
	petcat -w40 -o $@ $<

loadrom.bin: loadrom.a65
	xa -o $@ $<

# patches for KERNAL

${PATCHES}: % : %.a65
	xa -o $@ $<

${TOOLS}: % : %.c
	cc -Wall -pedantic -o $@ $<

kernal4p: kernal4 initmmu reset rompatch romcheck
	./rompatch -p 0xe00 initmmu -p 0xffc reset -o kernal-tmp kernal4
	./romcheck -s 0xf0 -i 0xdff -o kernal4p kernal-tmp
	rm kernal-tmp

edit40gp: edit40g rompatch romcheck crtctab40
	./rompatch -p 0x7b1 crtctab40 -o edit-tmp edit40g
	./romcheck -s 0xe0 -i 0x7ff -o edit40gp edit-tmp
	rm edit-tmp

edit80gp: edit80g rompatch romcheck crtctab80
	./rompatch -p 0x72a crtctab80 -o edit-tmp edit80g
	./romcheck -s 0xe0 -i 0x7ff -o edit80gp edit-tmp
	rm edit-tmp
	

# Clean

clean:
	rm -f zero charPet2Invers
	rm -f basic2 edit2g kernal2 chargen_pet basic4 kernal4 edit40g edit80g basic1 edit1 kernal1 chargen_pet1 chargen_pet1_16
	rm -f $(EDITROMS)
	rm -f $(TOOLS)
	rm -f $(PATCHES)
	rm -f romimg romimg64k

