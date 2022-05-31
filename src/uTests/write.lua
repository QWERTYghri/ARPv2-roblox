local ARP = require ( script.Parent.Parent.src.ARP_m )

local function main ()
	ARP:init ()
	
	ARP:write (0xff, 0x01, 0xff )
	ARP:write (0x101, 0x02, 0xff )
	
	ARP:tabWrite (
		{
			{ 0x103, 0x03, 0xff },
			{ 0x105, 0x04, 0xff }
		}
	)
	
	for i = 0xff, 0x106 do
		print ( ARP.cpu.mBus[i] )
	end
end
main ()