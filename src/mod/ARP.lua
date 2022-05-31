--[[
 *	ARP - A luau based psuedo emulator
 *
 *	Auth : Mrgameybean17
 *
 *	This was primarily made for fun and along with providing a kind of backend to creating a pseudo RISC computer
 *
 *	This is not meant to be an actual CPU as it doesn't follow any standard ISAs and the implementation of Lua is
 *	restrictive to creating things such as bitfields, types, actual bitwise operations, and more. For example, Lua
 *	utilizes double 64 bit floating point values and it is impossible to make integers in Luau.
]]

local self = {}

self.cpu =
	{
		reg =
		{
			-- Accumulator, X reg, Stack register, Program counter
			AC	= 0,
			X	= 0,
			SR	= 0,

			-- proper FDE cycle isn't here because im lazy
			PC	= 0,
			CIR	= 0,
			MBR	= 0

		},

		flags =
		{
			ST	= 0,
			CM	= 0,
		},

		mBus	= {},
		isaList	= {}
	}

local reg	= self.cpu.reg
local mBus	= self.cpu.mBus
local isaList	= self.cpu.isaList
local flg	= self.cpu.flags

-- FUNCTIONS

--REG LOAD
isaList[1] = -- LDA
	function ()
		reg.AC = reg.MBR
	end
isaList[2] = -- STA
	function ()
		mBus[reg.MBR] = reg.AC
	end
isaList[3] = -- GTA
	function ()
		reg.AC = mBus[reg.MBR]
	end
isaList[4] = -- LDX
	function ()
		reg.X = reg.MBR
	end
isaList[5] = -- STX
	function ()
		mBus[reg.MBR] = reg.X
	end
isaList[6] = -- GTX
	function ()
		reg.X = mBus[reg.MBR]
	end

--REG TRANSFER
isaList[7] = -- TAX
	function ()
		reg.X = reg.AC
	end
isaList[8] = -- TXA
	function ()
		reg.AC = reg.X
	end

--STACK OPERATIONS
isaList[9] = -- TSX
	function ()
		reg.X = reg.SR
	end
isaList[10] = -- TXS
	function ()
		reg.SR = reg.X
	end
isaList[11] = -- PHA
	function ()
		mBus[reg.SR] = reg.AC
		reg.SR += 1
	end
isaList[12] = -- POA
	function ()
		reg.AC = mBus[reg.SR]
		reg.SR -= 1
	end

--ARITHEMETIC
isaList[13] = -- ADD
	function ()
		reg.AC += reg.MBR
	end
isaList[14] = -- SUB
	function ()
		reg.AC -= reg.MBR
	end
isaList[15] = -- SBA
	function ()
		reg.AC -= mBus[reg.MBR]
	end
isaList[16] = -- ADA
	function ()
		reg.AC -= mBus[reg.MBR]
	end
isaList[17] = -- INX
	function ()
		reg.X += 1
	end

--COMPARISON
isaList[18] = -- CPX
	function ()
		if reg.X == reg.MBR then
			flg.CM = 1
		else
			flg.CM = 0
		end
	end	
isaList[19] = -- CPA
	function ()
		if reg.AC == reg.MBR then
			flg.CM = 1
		else
			flg.CM = 0
		end
	end	
isaList[20] = -- CXA
	function ()
		if reg.X == mBus[reg.MBR] then
			flg.CM = 1
		else
			flg.CM = 0
		end
	end
isaList[21] = -- CAA
	function ()
		if reg.AC == mBus[reg.MBR] then
			flg.CM = 1
		else
			flg.CM = 0
		end
	end
isaList[22] = -- CLC
	function ()
		flg.CM = 0
	end

-- JUMP/CALL
isaList[23] = -- JMP
	function ()
		reg.PC = reg.MBR
		flg.CM = 0
	end
isaList[24] = -- JLC
	function ()
		if flg.CM == 1 then
			reg.PC = reg.MBR
		end
		flg.CM = 0
	end
isaList[25] = -- JMS
	function ()
		mBus[reg.SR] = reg.PC
		reg.SR += 1

		reg.PC = reg.MBR
	end
isaList[26] = -- RET
	function ()
		reg.SR -= 1
		reg.PC = mBus[ ( reg.SR ) ]
	end
isaList[27] = -- HLT
	function ()
		flg.ST = 1
	end


-- List of number literals
local literal =
	{
		maxAdr	= 65535,	-- Max mBus list
		maxIsa	= #isaList,	-- maxIsa instructions
		maxHdd	= 625000	-- maxHdd addressable / ngl I did this to address 5mb for data welp, since each val uses double float
	}



--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--[[
 *
 *	mBusFunc ()
 *	
 *	This is a function to provide sort of a peripheral data to put data onto mBus
 *
 *	This is a default template
 *
 *
]]


self.hdd = {}

-- mBus conf function
function self:mBusFunc ()
	mBus[0xff] = self.hdd[mBus[0xfe]]	-- 0xfe in mBus is the 
end


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------


-- EXEC FUNCTIONS
function self:init ()
	reg.AC, reg.X, reg.SR, reg.PC = 0, 0, 0, 0xff
	
	for i = 1, literal.maxAdr do
		mBus[i] = 0
	end
	
	for i = 1, literal.maxHdd do
		self.hdd[i] = 0
	end
end

-- MEMORY WRITING

function self:write ( adr, opcode, operand )
	mBus[adr] = opcode
	mBus[ ( adr + 1 ) ] = operand
end

-- Too lazy to optimize and also I just want to make this simple
function self:tabWrite ( table )
	local plcVal, adr, opcode, operand = 0, 0, 0, 0

	for _, v in pairs ( table ) do			-- Iterate through table to write the contents into memory
		for _, k in pairs ( v ) do
			if plcVal == 0 then
				adr = k
			elseif plcVal == 1 then
				opcode = k
			elseif plcVal == 2 then
				operand = k
			end
			plcVal += 1
		end

		self:write ( adr, opcode, operand )
		adr, opcode, operand, plcVal = 0, 0, 0, 0
	end
end


-- EXECUTION
function self:fetch ()
	reg.CIR	= mBus[reg.PC]
	reg.PC += 1
	reg.MBR = mBus[reg.PC]
end

function self:step ()
	self:fetch ()
	
	if reg.CIR < literal.maxIsa and reg.CIR > 0 then
		isaList[reg.CIR] ()
	end
	
	reg.PC += 1
	self:mBusFunc ()
end

function self:exec ( cyc, adr )
	reg.PC = adr
	
	while cyc > 0 and flg.ST == 0 do
		self:step ()
		cyc -= 1
	end
end

function self:dbExec ( cyc, adr )
	reg.PC = adr
	
	while cyc > 0 and flg.ST == 0 do
		print ( string.format ( "\n***********\n\nAddr : %d\nOpcode : %d\nOperand : %d\n\nAC : %d\nX : %d\nSR : %d\nCM : %d\n\n***********",
			reg.PC, reg.CIR, reg.MBR, reg.AC, reg.X, reg.SR, flg.CM ) )
		
		self:step ()
		cyc -= 1
	end
end

return self -- END