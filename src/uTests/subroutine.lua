local ARP = require ( script.Parent.Parent.src.ARP_m )

local function main ()
	ARP:init ()
	
	ARP:tabWrite (
		{
			{ 0xff, 0x18, 0x2FF },
			{ 0x101, 0x1A, 0x00 },
			
			{ 0x300, 0x01, 0x16 },
			{ 0x302, 0x0d, 0x16 },
			{ 0x304, 0x19, 0xff }
		}
	)
	
	ARP:dbExec ( 5, 253 )
end
main ()