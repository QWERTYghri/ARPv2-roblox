local ARP = require ( game.ReplicatedStorage.ARPv2.src.ARP_m)
local ASM = require ( game.ReplicatedStorage.ARPv2.src.ASM_m)



local function main ()
	ARP:init ()
	
	ARP:tabWrite ( ASM:asm (
		[[
			0x200	LDA 0x01
			0x202	LDX 0x19
			
			0x204	STA 0xfb
			0x206	STX 0xfc
			
			0x208	GTA 0xfe
			0x20A	HLT 0x00
		]]))
	
	ARP:dbExec ( 6, 0x1FE)
end
main ()