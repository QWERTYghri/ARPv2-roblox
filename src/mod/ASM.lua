--[[
*	ARP Assembler
*
*	Auth : Mrgameybean17
*
*	This is an assembler to map out keywords and characters to a table to be written into memory by tableWrite ()
*	
*	The line assembler is broken up into the parse () and tConv () func
*
*	These functions are wrapped in ASM which returns the output table to be written by tableWrite
*
*	lex () creates a table out of the string in this format
*
*	{
*		{ "0x0f", "LDA", "0x04" }
*	}
*
*	This is then inputed to asm which turns the strings into it's numeric identities
*
*
*	This is an extremely limited "assembler" it doesn't support comments and objects such as macro definitions
*	It doesn't really abstract some commands.
]]


local self = {}

local keyWords =
	{
		LDA = 1,
		STA = 2,
		GTA = 3,
		LDX = 4,
		STX = 5,
		GTX = 6,
		TAX = 7,
		TXA = 8,
		TSX = 9,
		TXS = 10,
		PHA = 11,
		POA = 12,
		ADD = 13,
		SUB = 14,
		SBA = 15,
		ADA = 16,
		INX = 17,
		CPX = 18,
		CPA = 19,
		CXA = 20,
		CAA = 21,
		CLC = 22,
		JMP = 23,
		JLC = 24,
		JMS = 25,
		RET = 26,
		HLT = 27
	}


function self:parse ( str )
	local plc = 0
	local retTab = {}
	local tmpTab = {}

	-- Section tokenizes three parts from a string into a single table
	-- Then adds table to a retTab
	-- String parts are denoted by a variable val
	for i, v in string.gmatch ( str, "%S+" ) do
		table.insert ( tmpTab, i )

		plc += 1

		if plc == 3 then
			plc = 0
			table.insert ( retTab, tmpTab )
			tmpTab = {}
		end
	end
	return retTab
end


--Returns a table containing the numerical values to be interpreted by tabWrt
function self:asm ( str )
	local parseRes = self:parse ( str )
	local retTab = {}
	local tmpTab = {}


	for _, v in pairs ( parseRes ) do
		for _, k in pairs ( v ) do
			if string.find ( k, "0x" ) ~= nil then		-- Convert str hex into a number and add to tmpTab
				table.insert ( tmpTab, tonumber ( k ) )
			else
				for str, val in pairs ( keyWords ) do	--Decode the opcode str to keyword val
					if str == string.upper ( k ) then
						table.insert ( tmpTab, val )
					end
				end
			end
		end
		table.insert ( retTab, tmpTab ) --Insert tmpTab into retTab and then clear tmpTab
		tmpTab = {}
	end

	return retTab
end

return self --END