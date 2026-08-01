local MC = MagicCarpet

local pi = math.pi
local abs = math.abs
local cos = math.cos
local sin = math.sin
local rad = math.rad
local random = math.random

local ACTION = { }
ACTION.NONE = 0
ACTION.ROLL_DODGE = 1
ACTION.INTERRUPT = 2
ACTION.BLOCK = 3
ACTION.SPRINT = 4
ACTION.HIDE = 5

local USE_DEFAULT = math.huge

local function GetPlayerRace()
	local race = GetUnitRace( "player" ) or "person"
	local raceMap = { ["Dark Elf"] = "Dunmer", ["High Elf"] = "Altmer", ["Wood Elf"] = "Bosmer" }
	return raceMap[race] or race
end

------[ BUILT-IN MODES ]------

--[ Entry-level Modes ]--

MC.Mode:New( {

	SortOrder = 10,
	Name = "Plank-tato",
	Description = "A basic, no frills ride for the budget conscious traveler.",
	Quality = ITEM_QUALITY_NORMAL,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, MC.Mode.ATTRIBUTE.LOW_COST, },
	Components = {
		{ "|H0:item:117989:2:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local item, x, y, z, pitch, yaw, roll = items[1], state.Position.X, state.StableY + state.OffsetY, state.Position.Z, 0, state.Heading + 0.5 * math.pi, 0
		y = y - 22

		if state.Descending then
			roll = roll - math.rad( 35 )
			y = y - 100
		elseif state.Ascending then
			roll = roll + math.rad( 35 )
			y = y - 11
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

MC.Mode:New( {
	SortOrder = 10,
	Author = "@Erorah, PC NA",
	Name = "Erorah's Lid Flipper",
	Description = "No pupil of flight mastery can be contained with a lid this magical.",
	Quality = ITEM_QUALITY_NORMAL,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, MC.Mode.ATTRIBUTE.LOW_COST, },
	Components = {
		{ "|H0:item:117931:2:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )
		local item, x, y, z, pitch, yaw, roll = items[1], state.Position.X, state.Position.Y, state.Position.Z, 0, state.Heading, 0
		if state.StableY > y and (state.StableY - y) < 10 then
			y = state.StableY
		end

		if state.Descending then
			pitch = math.rad(-25)
			x = x + math.sin(yaw) * -30
			y = y - 30
			z = z + math.cos(yaw) * -30
		elseif state.Ascending then
			pitch = math.rad(25)
			x = x + math.sin(yaw) * -65
			y = y + 17
			z = z + math.cos(yaw) * -65
		else
			pitch = math.rad(1)
			x = x + math.sin(yaw) * -65
			y = y - 9
			z = z + math.cos(yaw) * -65
		end
--[[
		if state.Descending then
			-- /script OPD, OXD, OZD, OYD = -25, -30, -30, 30
			pitch = math.rad(OPD or -25)
			x = x + math.sin(yaw) * (OXD or -30)
			y = y - (OYD or 30)
			z = z + math.cos(yaw) * (OZD or -30)
		elseif state.Ascending then
			-- /script OPA, OXA, OZA, OYA = 25, -65, -65, 17
			pitch = math.rad(OPA or 25)
			x = x + math.sin(yaw) * (OXA or -65)
			y = y + (OYA or 17)
			z = z + math.cos(yaw) * (OZA or -65)
		else
			-- /script OP,OX,OZ,OY = 1, -65, -65, 9
			pitch = math.rad(OP or 1)
			x = x + math.sin(yaw) * (OX or -65)
			y = y - (OY or 9)
			z = z + math.cos(yaw) * (OZ or -65)
		end
]]
		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
	end,
} )

MC.Mode:New( {

	SortOrder = 10,
	Name = "On Top of the World",
	Description = "You've got people to see and places to be...",
	Quality = ITEM_QUALITY_NORMAL,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:collectible:4664|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local item, x, y, z, pitch, yaw, roll = items[1], state.Position.X, state.StableY + state.OffsetY - 3, state.Position.Z, math.pi, state.Heading + 0.5 * math.pi, 0
		x, z = x - 28 * math.sin( state.Heading ), z - 28 * math.cos( state.Heading )

		if state.Descending then
			roll = roll + math.rad( 16 )
			
		elseif state.Ascending then
			roll = roll - math.rad( 16 )
			y = y + 5
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

MC.Mode:New({
	Name = "Dwemer Discus",
	Description = "Not to be confused with Dwemer 'AOL' Disks, although those can still be used as drink coasters.",
	Quality = ITEM_QUALITY_ARCANE,
	Attributes = {MC.Mode.ATTRIBUTE.FLIGHT,},
	Components = {{"|H0:item:171755:4:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 1}},
	SetupFunction = nil,
	UpdateFunction = function( state, items, data )
		local x, y, z, pitch, yaw, roll = state.Position.X, state.Position.Y + state.OffsetY - 12, state.Position.Z, 0, state.Heading + math.rad( 90 ), math.pi
		if state.IdleAnimations then
			yaw = 2 * math.pi * ( state.FrameMS % 60000 ) / 60000
		end
		if state.Descending then
			local angle = ( zo_forwardArcSize( state.Heading, yaw ) + math.rad( 90 ) ) % math.rad( 360 )
			roll = roll + math.rad( -15 ) * -math.cos( angle % math.rad( 360 ) )
			pitch = pitch + math.rad( -15 ) * math.sin( angle % math.rad( 360 ) )
		elseif state.Ascending then
			local angle = ( zo_forwardArcSize( state.Heading, yaw ) + math.rad( 90 ) ) % math.rad( 360 )
			roll = roll + math.rad( 15 ) * -math.cos( angle % math.rad( 360 ) )
			pitch = pitch + math.rad( 15 ) * math.sin( angle % math.rad( 360 ) )
		end
		items[ 1 ]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
	end,
})

do

	local carpets = {
		{
			Name = "Rustic",
			Link = "|H0:item:114338:3:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h",
			OffsetY = -4,
			OffsetHeading = math.rad( 90 ),
			DescendOffsetY = -40,
			DescendOffsetRoll = math.rad( -20 ),
			AscendOffsetY = -6,
			AscendOffsetRoll = math.rad( 20 ),
			IdleOffsetY = 46,
			IdleOffsetXZ = 200,
			IdleOffsetRoll = math.rad( -15 ),
		},
		{
			Name = "Fresh Rain",
			Link = "|H0:item:114361:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
			OffsetY = -10,
			OffsetHeading = 0,
			DescendOffsetY = -14,
			DescendOffsetPitch = math.rad( -20 ),
			AscendOffsetY = -24,
			AscendOffsetPitch = math.rad( 20 ),
			IdleOffsetY = 43,
			IdleOffsetXZ = 200,
			IdleOffsetPitch = math.rad( -15 ),
		},
		{
			Name = "Pine Scented",
			Link = "|H0:item:114362:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
			OffsetY = -1,
			OffsetHeading = 0,
			DescendOffsetY = -8,
			DescendOffsetPitch = math.rad( -20 ),
			AscendOffsetY = -10,
			AscendOffsetPitch = math.rad( 20 ),
			IdleOffsetY = 40,
			IdleOffsetXZ = 200,
			IdleOffsetPitch = math.rad( -15 ),
		},
	}

	for index = 1, #carpets do

		local carpet = carpets[ index ]

		MC.Mode:New( {

			SortOrder = 20,
			Name = string.format( "Magic Carpet (%s)", carpet.Name ),
			Description = "The signature mode of transportation and a true classic.",
			Quality = ITEM_QUALITY_MAGIC,
			Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, MC.Mode.ATTRIBUTE.PANORAMA_VIEW, MC.Mode.ATTRIBUTE.LOW_COST, },
			Components = { { carpet.Link, 1 } },
			SetupFunction = nil,
			UpdateFunction = function( state, items, data )

				local item, x, y, z, pitch, yaw, roll = items[1], state.Position.X, state.StableY + state.OffsetY, state.Position.Z, 0, state.Heading + ( carpet.OffsetHeading or 0 ), 0

				if state.Descending then
					pitch = pitch + ( carpet.DescendOffsetPitch or 0 )
					roll = roll + ( carpet.DescendOffsetRoll or 0 )
					y = y + ( carpet.DescendOffsetY or 0 )
				elseif state.Idling and state.PanoramaView then
					pitch = pitch + ( carpet.IdleOffsetPitch or 0 )
					roll = roll + ( carpet.IdleOffsetRoll or 0 )
					x, z = x + carpet.IdleOffsetXZ * math.sin( state.Heading ), z + carpet.IdleOffsetXZ * math.cos( state.Heading )
					y = y + ( carpet.IdleOffsetY or 0 )
				elseif state.Ascending then
					pitch = pitch + ( carpet.AscendOffsetPitch or 0 )
					roll = roll + ( carpet.AscendOffsetRoll or 0 )
					y = y + ( carpet.AscendOffsetY or 0 )
				else
					y = y + carpet.OffsetY
				end

				item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

			end,

		} )

	end

end

--[ Moderate to Advanced Modes ]--

do
	local offsets =
	{
		ascending =
		{
			pitch = math.rad(-135),
			yaw = math.rad(-120),
			roll = math.rad(145),
			x = 50,
			y = -690,
			z = 50,
		},
		descending =
		{
			pitch = math.rad(-145),
			yaw = math.rad(-60),
			roll = math.rad(75),
			x = 520,
			y = -398,
			z = 520,
		},
		neutral =
		{
			pitch = math.rad(-125),
			yaw = math.rad(-95),
			roll = math.rad(115),
			x = 320,
			y = -615,
			z = 320,
		},
	}

	MC.Mode:New( {
		SortOrder = 10,
		Name = "Helping Hand",
		Description = "If you liked it then you shoulda put a ring on it.",
		Quality = ITEM_QUALITY_NORMAL,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = {
			{ "|H1:item:192411:4:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h", 1 }
		},
		SetupFunction = nil,
		UpdateFunction = function(state, items, data)
	-- /script MCP, MCY, MCR, MCOY, MCOX, MCOZ = math.rad( -145 ), math.rad( -60 ), math.rad( 75 ), -398, 520, 520
			local o
			if state.Ascending then
				o = offsets.ascending
			elseif state.Descending then
				o = offsets.descending
			else
				o = offsets.neutral
			end

			local x = state.Position.X + sin(state.Heading) * (MCOX or o.x)
			local y = state.StableY + state.OffsetY + (MCOY or o.y)
			local z = state.Position.Z + cos(state.Heading) * (MCOZ or o.z)
			local pitch = MCP or o.pitch
			local yaw = state.Heading + (MCY or o.yaw)
			local roll = MCR or o.roll
			items[1]:SetPositionAndOrientation(x, y, z, pitch, yaw, roll)
		end,
	} )
end

MC.Mode:New( {
	Name = "Schema Surfer",
	Description = "\"Do you have a plan?\" they asked.\nNot only do you have a plan... it's a |c55ffffflight plan|r.",
	Quality = ITEM_QUALITY_ARCANE,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:126559:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 }
	},
	SetupFunction = nil,
	UpdateFunction = function( state, items, data )
		local item = items[1]
		local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY+state.OffsetY-9, state.Position.Z, 0, state.Heading+0.5*math.pi, 0.5*math.pi
		x, z = x - 90 * math.sin( state.Heading ), z - 90 * math.cos( state.Heading )

		if state.Ascending then
			roll = roll + math.rad( 25 )
			y = y + 38
		elseif state.Descending then
			roll = roll - math.rad( 40 )
			y = y - 82
		else
			roll = roll - math.rad( 4 )
			y = y - 7
		end

		if state.IdleAnimations then
			if state.Idling then
				local interval = math.sin( ( state.IdlingTimer % 4000 ) / 4000 * 2 * math.pi )
				local coeff = 0 == ( state.IdlingStart % 2 ) and 1 or -1

				if 8000 > state.IdlingTimer then
					pitch = pitch + coeff * math.rad( interval * ( 8 - math.floor( state.IdlingTimer / 2000 ) ) )
				else
					pitch = pitch + coeff * math.rad( interval * 4 )
				end
			end
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
	end,
} )

MC.Mode:New( {
	Name = "Replicarpet",
	Description = "So what if it fell off the back of the truck?\nKnock-offs are \"in\" this season...",
	Quality = ITEM_QUALITY_ARCANE,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:collectible:5930|h|h", 1 }
	},
	SetupFunction = nil,
	UpdateFunction = function( state, items, data )
		local item = items[1]
		local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY+state.OffsetY-111, state.Position.Z, 0, state.Heading+0.5*math.pi, 0

		x, z = x - 90 * math.sin( state.Heading ), z - 90 * math.cos( state.Heading )

		if state.Ascending then
			roll = roll + math.rad( 35 )
			y = y + 32
		elseif state.Descending then
			roll = roll - math.rad( 35 )
			y = y - 107
		end

		if state.IdleAnimations then
			if state.Idling then
				local interval = math.sin( ( state.IdlingTimer % 4000 ) / 4000 * 2 * math.pi )
				local coeff = 0 == ( state.IdlingStart % 2 ) and 1 or -1

				if 8000 > state.IdlingTimer then
					pitch = pitch + coeff * math.rad( interval * ( 8 - math.floor( state.IdlingTimer / 2000 ) ) )
				else
					pitch = pitch + coeff * math.rad( interval * 4 )
				end
			end
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
	end,
} )

MC.Mode:New( {
	Name = "Glinda the Transmuted",
	Description = "Graceful, elegant and, much like the original bubble, best suited for a grand entrance at a glacial pace.",
	Quality = ITEM_QUALITY_MAGIC,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:133576:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 }
	},
	SetupFunction = nil,
	UpdateFunction = function( state, items, data )
		local item, x, y, z, pitch, yaw, roll = items[1], state.Position.X, state.StableY + state.OffsetY - 125, state.Position.Z, 0, 0, 0
		yaw = -2 * math.pi * ( ( state.FrameMS % 18000 ) / 18000 )

		if state.Ascending then
			data.AscendOffset = math.min( 30, ( ( data.AscendOffset or 0 ) + 5 ) )
			y = y + data.AscendOffset
		else
			data.AscendOffset = math.max( 0, ( ( data.AscendOffset or 0 ) - 5 ) )
			y = y + data.AscendOffset

			if state.Descending then
				y = y - 20
			end
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
	end,
} )

MC.Mode:New( {

	Name = "Sheo's Cheese Grater",
	Description = "\"Marvelous time! Butterflies, blood, a Fox, a severed head...\nOh, and the cheese! To die for.\"",
	Quality = ITEM_QUALITY_MAGIC,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, MC.Mode.ATTRIBUTE.PANORAMA_VIEW, MC.Mode.ATTRIBUTE.LOW_COST, },
	Components = {
		{ "|H0:item:134298:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local item, x, y, z, pitch, yaw, roll = items[ 1 ], state.Position.X, state.StableY + state.OffsetY - 30, state.Position.Z, 0, state.Heading + 0.5 * math.pi, math.rad( 4 )

		if state.Descending then
			roll = roll + math.rad( -12 )
			y = y + 0
		elseif state.Idling and state.PanoramaView then
			roll = math.rad( -15 )
			x, z = x + 250 * math.sin( state.Heading ), z + 250 * math.cos( state.Heading )
			y = y + 65
		elseif state.Ascending then
			roll = roll + math.rad( 12 )
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

MC.Mode:New( {

	Name = "Vvardenfloaten",
	Description = "Boasting an outstanding flight safety record, not a single passenger\nhas ever Vvardenfallen off this floating island.",
	Quality = ITEM_QUALITY_MAGIC,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:collectible:1171|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local x, y, z, pitch, yaw, roll = state.Position.X, state.Position.Y + state.OffsetY + 0, state.Position.Z, 0, state.Heading + math.rad( 90 ), math.pi

		if state.IdleAnimations then
			yaw = 2 * math.pi * ( state.FrameMS % 20000 ) / 20000
		end

		if state.Descending then
			local angle = ( zo_forwardArcSize( state.Heading, yaw ) + math.rad( 90 ) ) % math.rad( 360 )
			roll = roll + math.rad( -15 ) * -math.cos( angle % math.rad( 360 ) )
			pitch = pitch + math.rad( -15 ) * math.sin( angle % math.rad( 360 ) )
		elseif state.Ascending then
			local angle = ( zo_forwardArcSize( state.Heading, yaw ) + math.rad( 90 ) ) % math.rad( 360 )
			roll = roll + math.rad( 15 ) * -math.cos( angle % math.rad( 360 ) )
			pitch = pitch + math.rad( 15 ) * math.sin( angle % math.rad( 360 ) )
		end

		items[ 1 ]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

MC.Mode:New( {

	Name = "Personal Hovercraft",
	Description = "This single passenger aircraft is nimble enough to outmaneuver\neven the fastest malfunctioning factotums.",
	Quality = ITEM_QUALITY_MAGIC,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:134328:4:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 1 },
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local item = items[ 1 ]
		local x, y, z, pitch, yaw, roll = state.Position.X, state.Position.Y + state.OffsetY - 74, state.Position.Z, 0, state.Heading, 0

		if state.Ascending then
			pitch = pitch + math.rad( 20 )
			y = y - 5
		end

		if state.Descending then y = y - 100 end

		if state.IdleAnimations then
			if state.Idling then
				if state.IdlingTimer <= 16000 then
					local interval = math.sin( ( state.IdlingTimer % 4000 ) / 4000 * 2 * math.pi )
					pitch = pitch + math.rad( interval * ( 5 - math.floor( state.IdlingTimer / 4000 ) ) )
				end

				if state.IdlingTimer >= 3000 then
					local interval = math.sin( ( ( state.IdlingTimer - 3000 ) % 5000 ) / 5000 * 2 * math.pi )
					if 1 == state.IdlingStart % 2 then
						roll = roll + math.rad( interval * math.min( state.IdlingTimer / 3000, 3 ) )
					else
						roll = roll - math.rad( interval * math.min( state.IdlingTimer / 3000, 3 ) )
					end
				end

				if state.IdlingTimer >= 18000 then
					local interval = math.sin( ( ( state.IdlingTimer - 18000 ) % 8000 ) / 8000 * 2 * math.pi )
					if 1 == state.IdlingStart % 3 then
						pitch = pitch + math.rad( interval )
					else
						pitch = pitch - math.rad( interval )
					end
				end
			end
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

MC.Mode:New( {

	Name = "Bedknobs and Broomsticks",
	Description = "Insert movie reference that will likely be lost on many.",
	Quality = ITEM_QUALITY_MAGIC,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, MC.Mode.ATTRIBUTE.PANORAMA_VIEW, },
	Components = { { "|H0:item:141826:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 } },

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY + state.OffsetY, state.Position.Z, 0, state.Heading, 0

		if state.Descending then
			pitch = pitch + math.rad( -30 )
			x, y, z = x - 100 * math.sin( yaw ), y - 130, z - 100 * math.cos( yaw )
		elseif state.Ascending then
			pitch = pitch + math.rad( 30 )
			x, y, z = x - 130 * math.sin( yaw ), y + 14, z - 130 * math.cos( yaw )
		elseif state.Idling and state.PanoramaView then
			pitch = pitch + math.rad( -20 )
			x, y, z = x + 120 * math.sin( yaw ), y - 19, z + 120 * math.cos( yaw )
		else
			x, y, z = x - 100 * math.sin( yaw ), y - 58, z - 100 * math.cos( yaw )
		end

		items[1]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

MC.Mode:New( {
	Name = "The S. S. Ess Ess",
	Description = "Display your fishing prowess with a flying boat that also floats.",
	Quality = ITEM_QUALITY_ARCANE,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:120043:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 },
	},
	SetupFunction = nil,
	UpdateFunction = function( state, items, data )
		local item = items[ 1 ]
		local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY + state.OffsetY, state.Position.Z, 0, state.Heading + math.rad( OH or 90 ), 0
		local offsetYaw = state.Heading
		local ft = GetFrameTimeMilliseconds()

		if state.Descending then
			-- roll = roll + math.rad( OR or -20 )
			-- x, y, z = x + (OX or -70) * math.sin( offsetYaw ), y + (OY or -116), z + (OX or -70) * math.cos( offsetYaw )
			roll = roll - 0.34906585 -- math.rad( -20 )
			x, y, z = x - 70 * math.sin( offsetYaw ), y - 116, z - 70 * math.cos( offsetYaw )
		elseif state.Ascending then
			--roll = roll + math.rad( OR or 35 )
			--x, y, z = x + (OX or -200) * math.sin( offsetYaw ), y + (OY or 30), z + (OX or -200) * math.cos( offsetYaw )
			roll = roll + math.rad( 35 )
			x, y, z = x - 200 * math.sin( offsetYaw ), y + 30, z - 200 * math.cos( offsetYaw )
		else
			-- x, y, z = x + (OX or -160) * math.sin( offsetYaw ), y + (OY or -78), z + (OX or -160) * math.cos( offsetYaw )
			x, y, z = x - 100 * math.sin( offsetYaw ), y - 80, z - 100 * math.cos( offsetYaw )
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
	end,
} )

MC.Mode:New( {

	Name = "Drodda's Slip 'n Slide",
	Description = "Frost magic - not just an Icereach thing anymore...",
	Quality = ITEM_QUALITY_ARCANE,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:134577:3:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 4 },
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local itemIndex, prevX, prevY, prevZ = data.ItemIndex or 1, data.PreviousX or 1, data.PreviousY or 1, data.PreviousZ or 1
		local item, x, y, z, pitch, yaw, roll = items[ itemIndex ], state.Position.X, state.StableY + state.OffsetY - 44, state.Position.Z, math.pi + math.rad( 1 ), state.Heading - math.rad( 30 ), math.rad( 0.5 )

		if state.Ascending then
			pitch = pitch + math.rad( 14 )
			roll = roll + math.rad( 7 )
			y = y + 36
		end

		if state.Descending then y = y - 200 end

		if math.rad( 2 ) < state.DistanceHeading then y = y - zo_clamp( 4 * math.deg( state.DistanceHeading ), 0, 52 ) end

		x, z = x - 150 * math.sin( state.Heading ), z - 150 * math.cos( state.Heading )
		if -20 > state.DistanceVect.Y then y = y + itemIndex * state.DistanceVect.Y end
		y = y - 2 * ( itemIndex - 1 )

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		itemIndex = itemIndex + 1
		if itemIndex > #items then itemIndex = 1 end
		data.ItemIndex = itemIndex

	end,

} )

do

	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!hl\".u7\"(gZ\"/nO\"(](\"(43\"&@V!hm\".u-\"(gZ\"/n$\"%\"':D\"&@W!hj\".uN\"(gZ\"/mi\"(\"&@T\"&@T!hk\".uk\"(gX\"/ms\"%\"%Fc\"&@P!hn\".ub\"(gZ\"/nS\"(](\"Lt\"&@Q!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Name = "Statuejette",
		Description = "The sum of this mini-jet is greater than its statuette parts.",
		Quality = ITEM_QUALITY_ARCANE,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local item = items[ 1 ]
			local x, y, z, pitch, yaw, roll = state.Position.X, 0, state.Position.Z, 0, state.Heading, math.pi

			if state.Descending then
				pitch = math.rad( -14 )
				y = state.StableY + state.OffsetY - 7
			elseif state.Ascending then
				pitch = math.rad( 14 )
				y = state.StableY + state.OffsetY - 5
			else
				y = state.StableY + state.OffsetY
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

do

	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!5CX\"&G\"$\"&o\"%0$\"&@T\"&@T!5CX\"&G\"$\"$\"%0$\"&@T\"&@T!5CX\"&G\"$\")b\"%0$\"&@T\"&@T!5CY\"$\"$\"&o\"%0$\"&@T\"&@T!5CY\"$\"$\"$\"%0$\"&@T\"&@T!5CY\"$\"$\")b\"%0$\"&@T\"&@T!5CZ\"(j\"$\"&o\"%0$\"&@T\"&@T!5CZ\"(j\"$\")b\"%0$\"&@T\"&@T!5CZ\"(j\"$\"$\"%0$\"&@T\"&@T!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Name = "It's A Sign!",
		Description = "Technically it's 9 divine signs. But who's counting?",
		Quality = ITEM_QUALITY_ARCANE,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local item = items[ 1 ]
			local x, y, z, pitch, yaw, roll = state.Position.X, state.Position.Y + state.OffsetY - 23, state.Position.Z, math.rad( 90 ), state.Heading + math.rad( 180 ), 0

			x, z = x - 200 * math.sin( state.Heading ), z - 200 * math.cos( state.Heading )

			if state.Descending then
				pitch = pitch + math.rad( 20 )
				y = y - 74
			elseif state.Ascending then
				pitch = pitch - math.rad( 20 )
				y = y + 69
			end

			if state.IdleAnimations then
				if state.Idling then
					if state.IdlingTimer <= 16000 then
						local interval = math.sin( ( state.IdlingTimer % 4000 ) / 4000 * 2 * math.pi )
						pitch = pitch + math.rad( interval * ( 4 - math.floor( state.IdlingTimer / 3000 ) ) )
					end

					if state.IdlingTimer >= 3000 then
						local interval = math.sin( ( ( state.IdlingTimer - 3000 ) % 5000 ) / 5000 * 2 * math.pi )
						if 1 == state.IdlingStart % 2 then
							roll = roll + math.rad( interval * math.min( state.IdlingTimer / 2000, 2 ) )
						else
							roll = roll - math.rad( interval * math.min( state.IdlingTimer / 2000, 2 ) )
						end
					end

					if state.IdlingTimer >= 18000 then
						local interval = math.sin( ( ( state.IdlingTimer - 18000 ) % 8000 ) / 8000 * 2 * math.pi )
						if 1 == state.IdlingStart % 3 then
							pitch = pitch + math.rad( interval )
						else
							pitch = pitch - math.rad( interval )
						end
					end
				end
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

MC.Mode:New( {

	Name = "Walking on Broken Glass",
	Description = "\"This sweet dream of a ride just won't bring you down.\"\n- Annie L.",
	Quality = ITEM_QUALITY_ARCANE,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:126633:4:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h", 3 },
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local itemIndex, prevX, prevY, prevZ, prevYaw = data.ItemIndex or 1, data.PreviousX or 1, data.PreviousY or 1, data.PreviousZ or 1, data.PreviousYaw or 1
		local item, x, y, z, pitch, yaw, roll = items[ itemIndex ], state.Position.X, state.StableY + state.OffsetY - 37, state.Position.Z, 0, state.Heading, math.rad( 0.5 )

		if state.Descending then
			pitch = pitch + math.rad( -15 )
			y = y - 70
			x, z = x - 80 * math.sin( state.Heading ), z - 80 * math.cos( state.Heading )
		elseif state.Ascending then
			pitch = pitch + math.rad( 20 )
			y = y + 10
			x, z = x - 80 * math.sin( state.Heading ), z - 80 * math.cos( state.Heading )
		else
			x, z = x - 120 * math.sin( state.Heading ), z - 120 * math.cos( state.Heading )
		end

		if math.rad( 5 ) > math.abs( yaw - prevYaw ) and 25 > zo_distance3D( x, y, z, prevX, prevY, prevZ ) then return end
		data.PreviousX, data.PreviousY, data.PreviousZ, data.PreviousYaw = x, y, z, yaw

		yaw = yaw + math.rad( -5 ) + math.rad( 10 ) * math.random()
		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		itemIndex = itemIndex + 1
		if itemIndex > #items then itemIndex = 1 end
		data.ItemIndex = itemIndex

	end,

} )

MC.Mode:New( {

	Name = "Brass Billiard Balls",
	Description = "Really just one, though it's easily large enough to reenact\n" ..
		"that scene from \"Raiders of the Lost Ark.\"",
	Quality = ITEM_QUALITY_ARCANE,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:134284:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local x, y, z = state.Position.X, state.StableY + state.OffsetY - 564, state.Position.Z
		local pitch, yaw, roll = 0, state.Heading, 0
		local distanceOffset = 0

		if state.Descending then
			distanceOffset = -270
			y = y + 55
		elseif state.Ascending then
			distanceOffset = 300
			y = y + 76
		end

		local travel = ( ( data.Travel or 0 ) + state.DistanceXZ ) % 3600
		data.Travel = travel
		pitch = -2 * math.pi * ( 1 - ( travel / 3600 ) )

		local dist = distanceOffset + math.abs( state.DistanceXZ )
		x, z = x - dist * math.sin( state.Heading ), z - dist * math.cos( state.Heading )

		offsetX, offsetY, offsetZ = MC.Engine:GetOrientationOffsets( 0, -562, 0, pitch, yaw, roll )
		x, y, z = x + offsetX, y + offsetY, z + offsetZ
		items[1]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

MC.Mode:New( {

	Name = "Dragon Priest",
	Description = "Does dragon-riding need an explanation...?",
	Quality = ITEM_QUALITY_ARCANE,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:134856:6:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY + state.OffsetY - 300, state.Position.Z, math.rad( 27 ), state.Heading + math.pi, 0

		if state.Descending then
			x, z = x + 225 * math.sin( state.Heading ), z + 225 * math.cos( state.Heading )
			y = y + 60
			pitch = pitch + math.rad( 20 )
		elseif state.Ascending then
			x, z = x - 0 * math.sin( state.Heading ), z - 0 * math.cos( state.Heading )
			pitch = pitch + math.rad( -45 )
			y = y - 61
		else
			x, z = x + 40 * math.sin( state.Heading ), z + 40 * math.cos( state.Heading )
		end

		items[ 1 ]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

do

	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!6gK\"$\"$\"$\"$\"$\"$!6gK\"'4\"$\"$\"$\"$\"$!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Name = "Murccasins",
		Description = "These designer shoes are the very sole of Murkmire.",
		Quality = ITEM_QUALITY_MAGIC,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, completeFunc )
		end,

		UpdateFunction = function( state, items, data )

			local index, x, y, z, pitch, yaw, roll, offset, hOffset = ( data.Index or 1 ) + 1, state.Position.X, 0, state.Position.Z, 0, state.Heading, 0, -230, 0
			if index > 2 then index = 1 end

			if 1 == index then
				hOffset = -135
			else
				hOffset = 135
			end

			if state.Descending then
				offset = -220
				pitch = pitch + math.rad( -20 )
				y = -145
			elseif state.Ascending then
				offset = -220
				pitch = pitch + math.rad( 20 )
				y = 20
			else
				y = -65
			end

			y = y + state.StableY + state.OffsetY
			x, z = x + offset * math.sin( state.Heading ), z + offset * math.cos( state.Heading )
			x, z = x + hOffset * math.sin( state.Heading + math.rad( 90 ) ), z + hOffset * math.cos( state.Heading + math.rad( 90 ) )

			local prevX, prevY, prevZ, prevYaw, prevPitch = data.PrevX or 0, data.PrevY or 0, data.PrevZ or 0, data.PrevYaw or 0, data.PrevPitch or 0
			if 14 <= math.abs( prevX - state.Position.X ) or 14 <= math.abs( prevY - state.Position.Y ) or 14 <= math.abs( prevZ - state.Position.Z ) or math.rad( 10 ) <= math.abs( prevYaw - state.Heading ) or prevPitch ~= pitch then
				data.Index, data.PrevX, data.PrevY, data.PrevZ, data.PrevYaw, data.PrevPitch = index, state.Position.X, state.Position.Y, state.Position.Z, state.Heading, pitch

				data.CycleIndex = ( ( data.CycleIndex or 0 ) + 1 ) % 3
				if 2 == data.CycleIndex then y = y - 20 end

				items[ index ]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
			end

		end,

	} )

end

do

	local modelData = "\"\"\"\"\"\"\"\"\"\"V3!883\"(Q\\\"&kO\"&q$\"$\"(L(\"%/!883\"(QD\"&kO\"&r$\"$\"(L(\"%/!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Name = "These Boots Are Made For Flying",
		Description = "...and that's just what they'll do.",
		Quality = ITEM_QUALITY_MAGIC,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, completeFunc )
		end,

		UpdateFunction = function( state, items, data )
			local index, x, y, z, pitch, yaw, roll, offset, hOffset = ( data.Index or 1 ) + 1, state.Position.X, 0, state.Position.Z, 0, state.Heading + math.rad( 90 ), 0, -50, 0
			if index > 2 then index = 1 end

			if 1 == index then
				hOffset = OX or 30
			else
				hOffset = -(OX or 30)
			end

			if state.Descending then
				y = -180
				offset = -10
				roll = roll + math.rad( -10 )
			elseif state.Ascending then
				y = -144
				offset = -100
				roll = roll + math.rad( 20 )
			else
				y = -152
			end

			y = y + state.StableY + state.OffsetY
			x, z = x + offset * math.sin( state.Heading ), z + offset * math.cos( state.Heading )
			x, z = x + hOffset * math.sin( state.Heading + math.rad( 90 ) ), z + hOffset * math.cos( state.Heading + math.rad( 90 ) )

			local prevX, prevY, prevZ, prevYaw, prevPitch = data.PrevX or 0, data.PrevY or 0, data.PrevZ or 0, data.PrevYaw or 0, data.PrevPitch or 0
			if 14 <= math.abs( prevX - state.Position.X ) or 14 <= math.abs( prevY - state.Position.Y ) or 14 <= math.abs( prevZ - state.Position.Z ) or math.rad( 10 ) <= math.abs( prevYaw - state.Heading ) or prevPitch ~= pitch then
				data.Index, data.PrevX, data.PrevY, data.PrevZ, data.PrevYaw, data.PrevPitch = index, state.Position.X, state.Position.Y, state.Position.Z, state.Heading, pitch

				local cycleIndex = items[ index ].CycleIndex
				if not cycleIndex then
					cycleIndex = 2 * index
				end

				cycleIndex = ( cycleIndex + 1 ) % 4
				items[ index ].CycleIndex = cycleIndex

				if cycleIndex < 3 then
					roll = roll + math.rad( -10 + 10 * cycleIndex )
				else
					roll = roll + math.rad( 10 - 10 * ( cycleIndex - 2 ) )
				end

				items[ index ]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
			end
		end,

	} )

end

do

	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!6jO\"A\"$\"p\"W/\"$\"$!6jO\"u\"$\"1\"W/\"%TD\"$!6jO\"$\"$\"$\"W/\"',c\"$!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Name = "ScuttleVroom",
		Description = "Similar to a traditional palanquin but with a Murkmire twist.",
		Quality = ITEM_QUALITY_ARCANE,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local x, y, z, pitch, yaw, roll, offset = state.Position.X, 0, state.Position.Z, 0, state.Heading + math.pi, 0, -40

			if state.Descending then
				pitch = math.rad( 95 )
				y = -30
				offset = 40
			elseif state.Ascending then
				pitch = math.rad( 25 )
				y = -40
			else
				if state.IdleAnimations then
					if state.Idling then
						if state.IdlingTimer > ( ( data.PreviousIdleTimer or 0 ) + 5000 ) then
							data.PreviousIdleTimer = state.IdlingTimer

							for index = 1, #items do
								HousingEditorRequestChangeState( items[ index ]:GetFurnitureId() )
							end

							return
						end
					else
						data.PreviousIdleTimer = 0
					end
				end

				pitch = math.rad( 60 )
				y = -56
			end

			y = y + state.StableY + state.OffsetY
			x, z = x + offset * math.sin( state.Heading ), z + offset * math.cos( state.Heading )

			items[1]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

MC.Mode:New( {

	Name = "Sorcerer's Aura",
	Description = "A nerf-resistant Daedric aura conjured by Sorcerers.",
	Quality = ITEM_QUALITY_ARCANE,
	Attributes = { MC.Mode.ATTRIBUTE.COSMETIC, },
	Components = {
		{ "|H0:item:119841:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h", 8 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local index = data.Index or 0
		index = index + 1
		if index > #items then index = 1 end
		data.Index = index

		local currentX, currentY, currentZ = data.CurrentX or state.Position.X, data.CurrentY or state.StableY, data.CurrentZ or state.Position.Z
		currentX = currentX + zo_clamp( state.Position.X - currentX, -60, 60 )
		currentY = currentY + zo_clamp( state.StableY - currentY, -100, 2.5 )
		currentZ = currentZ + zo_clamp( state.Position.Z - currentZ, -60, 60 )
		data.CurrentX, data.CurrentY, data.CurrentZ = currentX, currentY, currentZ

		local item, x, y, z, pitch, yaw, roll = items[index], currentX, currentY + state.OffsetY, currentZ, 0, 0, 0

		y = y - 25 - math.random() * 60

		pitch = math.rad( 20 + math.random() * 20 )
		yaw = 2 * math.pi * ( state.FrameMS % 2000 ) / 2000
		local offsetX, offsetZ = 0 * math.sin( yaw ), 0 * math.cos( yaw )
		x, z = x + offsetX, z + offsetZ

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

do
	MC.Mode:New( {
		Name = "Warden's Aura (Ice)",
		Description = "Flaunting one's command over all manner of flora seems so pedestrian.\nBesides... your horticultural talent speaks for itself.",
		Quality = ITEM_QUALITY_ARCANE,
		Attributes = { MC.Mode.ATTRIBUTE.COSMETIC, },
		Components = {
			{ "|H1:item:120798:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 5 }
		},
		SetupFunction = function( completeFunc, state, items, data )
			data.Index, data.NextShift, data.LastPlayerPosition = 1, 0, {0, 0, 0}
			completeFunc()
		end,
		UpdateFunction = function( state, items, data )
			local lastPlayerPosition = data.LastPlayerPosition
			local shiftPosition = data.NextShift <= 0
			if not shiftPosition then
				shiftPosition = abs(lastPlayerPosition[1] - state.Position.X) > 50 or
								abs(lastPlayerPosition[2] - state.Position.Y) > 50 or
								abs(lastPlayerPosition[3] - state.Position.Z) > 50
			end
			lastPlayerPosition[1], lastPlayerPosition[2], lastPlayerPosition[3] = state.Position.X, state.Position.Y, state.Position.Z
			
			if shiftPosition then
				data.NextShift = 4
				data.Index = 1 + ( ( data.Index + 1 ) % #items )

				local a, r = random() * 2 * pi, random() * 200 + 60
				data.NextPosition = {state.Position.X + r * sin( a ), state.Position.Y - 24, state.Position.Z + r * cos( a )}
				data.NextOrientation = {rad( random( -3, 3 ) ), rad( random( 0, 359 ) ), rad( random( -3, 3 ) )}
			end

			local x, y, z = unpack(data.NextPosition)
			local pitch, yaw, roll = unpack(data.NextOrientation)
			items[data.Index]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

			data.NextShift = data.NextShift - 1
			data.NextPosition[2] = data.NextPosition[2] + 6
		end,
	} )
end

do
	local minBound, maxBound = 2000, 3000

	MC.Mode:New( {
		Name = "Warden's Aura (Fire)",
		Description = "Flaunting one's command over all manner of flora seems so pedestrian.\nBesides... your horticultural talent speaks for itself.",
		Quality = ITEM_QUALITY_ARCANE,
		Attributes = { MC.Mode.ATTRIBUTE.COSMETIC, },
		Components = {
			{ "|H1:item:120799:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 5 }
		},
		SetupFunction = function( completeFunc, state, items, data )
			data.CosInterval, data.SinInterval = math.random( minBound, maxBound ), math.random( minBound, maxBound )
			data.CosOffset, data.SinOffset = -state.FrameMS, -state.FrameMS
			data.CosIntervalOffset, data.SinIntervalOffset = 0, 0
			data.CosDistance, data.SinDistance = 100, 200
			data.Index, data.NextShift = 1, 0
			completeFunc()
		end,
		UpdateFunction = function( state, items, data )
			if data.NextShift <= state.FrameMS then
				data.CosIntervalOffset = data.CosIntervalOffset + ( ( ( data.CosOffset + state.FrameMS ) % data.CosInterval ) / data.CosInterval )
				data.SinIntervalOffset = data.SinIntervalOffset + ( ( ( data.SinOffset + state.FrameMS ) % data.SinInterval ) / data.SinInterval )
				data.CosOffset, data.SinOffset = -state.FrameMS, -state.FrameMS
				data.CosInterval, data.SinInterval = zo_clamp( data.CosInterval + math.random( -150, 150 ), minBound, maxBound ), zo_clamp( data.SinInterval + math.random( -150, 150 ), minBound, maxBound )
				data.CosDistance, data.SinDistance = zo_clamp( data.CosDistance + math.random( -50, 50 ), 50, 250 ), zo_clamp( data.SinDistance + math.random( -50, 50 ), 50, 250 )
				data.NextShift = state.FrameMS + math.random( 500, 1000 )
			end

			local x = state.Position.X + data.SinDistance * math.sin( 2 * math.pi * ( data.SinIntervalOffset + ( ( ( data.SinOffset + state.FrameMS ) % data.SinInterval ) / data.SinInterval ) ) )
			local z = state.Position.Z + data.CosDistance * math.cos( 2 * math.pi * ( data.CosIntervalOffset + ( ( ( data.CosOffset + state.FrameMS ) % data.CosInterval ) / data.CosInterval ) ) )
			local y = state.Position.Y - 12 * math.sin( math.pi * ( ( state.FrameMS % 5000 ) / 5000 ) )
			local pitch, yaw, roll = math.rad( math.random( -3, 3 ) ), math.rad( math.random( 0, 359 ) ), math.rad( math.random( -3, 3 ) )

			items[data.Index]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
			data.Index = 1 + ( ( data.Index + 1 ) % #items )
		end,
	} )
end

do
	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!5yP\"*4/\"&.w\"*bU\"$\"$\"$!5yP\"*4.\"&.y\"*c0\"&\"$\"&@T!5yP\"*53\"&.y\"*bT\"$\"%2<\"&@V!5yP\"*4p\"&.y\"*c=\"%\"W0\"&@U!5yP\"*4.\"&.y\"*cW\"&\"$\"&@T!5yP\"*3F\"&.y\"*c<\"%\"()w\"&@R!5yP\"*3+\"&.y\"*bR\"$\"'Nk\"&@Q!5yP\"*3G\"&.z\"*aj\"(]*\"&s_\"&@R!5yP\"*40\"&.z\"*av\"(])\"&@T\"&@T!5yP\"*4q\"&.z\"*ak\"(]*\"%eH\"&@U!5yP\"*4^\"&.z\"*b:\"(]*\"%TD\"&@V!5yP\"*4]\"&.y\"*bo\"%\"h3\"&@V!5yP\"*3Y\"&.y\"*bm\"%\"'pt\"&@Q!5yP\"*40\"&.z\"*aO\"(])\"&@T\"&@T!5yP\"*3Z\"&.z\"*b8\"(]*\"',c\"&@Q!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {
		Name = "Meditation Cloud",
		Quality = ITEM_QUALITY_ARTIFACT,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Description = "Borrowed ...indefinitely... from the Psijic Vault of Moawita.\nWith so many artifacts it's unlikely anyone will notice.",
		Components = {
			{ "|H1:item:139172:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h", 15 },
		},
		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,
		UpdateFunction = function( state, items, data )
			local item = items[ 1 ]
			local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY + state.OffsetY - 13, state.Position.Z, 0, 0, 0
			local ch = GetPlayerCameraHeading()

			if state.IdleAnimations then
				yaw = 2 * math.pi * ( ( state.FrameMS % 16000 ) / 16000 )
			end

			if state.Ascending then
				local angle = -1 * ( yaw - state.Heading )
				roll = roll - math.rad( 10 ) * math.sin( angle )
				pitch = pitch - math.rad( -10 ) * math.cos( angle )
				y = y - 2
			elseif state.Descending then
				local angle = -1 * ( yaw - state.Heading )
				roll = roll + math.rad( 10 ) * math.sin( angle )
				pitch = pitch + math.rad( -10 ) * math.cos( angle )
				y = y - 4
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
		end,
	} )
end

do
	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!5D%\"/-<\"(h.\"/Zd\"$\"$\"$!7)k\"/-.\"(hD\"/[_\"(WH\"&J\"W0!7)k\"/,?\"(hD\"/Zi\"(WH\"'_o\"W0!7)k\"/,J\"(hD\"/[5\"(WH\"(%+\"W0!7)k\"/,c\"(hD\"/[Q\"(WH\"(B>\"W0!7)k\"/-t\"(hD\"/[J\"(WH\"`p\"W0!7)k\"/-T\"(hD\"/[]\"(WH\"C^\"W0!7)k\"/.2\"(hD\"/[+\"(WH\"%&,\"W0!7)k\"/.8\"(hD\"/Z^\"(WH\"%C?\"W0!7)k\"/.-\"(hD\"/Z:\"(WH\"%`S\"W0!7)k\"/-l\"(hD\"/Yv\"(WH\"&%f\"W0!7)k\"/-I\"(hD\"/Yh\"(WH\"&Bz\"W0!7)k\"/,{\"(hD\"/Yj\"(WH\"&`6\"W0!7)k\"/,[\"(hD\"/Z%\"(WH\"'%H\"W0!7)k\"/,E\"(hD\"/ZD\"(WH\"'B\\\"W0!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {
		Name = "Bladerunner",
		Quality = ITEM_QUALITY_ARTIFACT,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Description = "A symphony of blades that is ideal for light yardwork, hedge trimming and can double as a Cuisinart(R) in a pinch.",
		Components = {
			{ "|H1:item:134465:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 },
			{ "|H1:item:147647:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 14 }
		},
		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,
		UpdateFunction = function( state, items, data )
			local item = items[ 1 ]
			local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY + state.OffsetY - 42, state.Position.Z, 0, 0, 0
			local ch = GetPlayerCameraHeading()

			if state.IdleAnimations then
				yaw = 2 * math.pi * ( ( state.FrameMS % 2000 ) / 2000 )
			end

			if state.Ascending then
				local angle = -1 * ( yaw - state.Heading )
				roll = roll - math.rad( 10 ) * math.sin( angle )
				pitch = pitch - math.rad( -10 ) * math.cos( angle )
				y = y - 2
			elseif state.Descending then
				local angle = -1 * ( yaw - state.Heading )
				roll = roll + math.rad( 10 ) * math.sin( angle )
				pitch = pitch + math.rad( -10 ) * math.cos( angle )
				y = y - 4
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
		end,
	} )
end

do
	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!4lX\".sP\"(fm\".x=\"'ps\"'Nk\"%2<!4lX\".sV\"(g)\".sk\"'da\"%*Q\"%Ao!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {
		Name = "Flyin' Flume",
		Quality = ITEM_QUALITY_MAGIC,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, MC.Mode.ATTRIBUTE.LOW_COST, },
		Author = "@Chryseia, PC NA",
		Description = "Darien Gautier, once an experienced lumberjack, would undoubtedly approve of this mode of transporation.",
		Components = model:GetRequirements(),
		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,
		UpdateFunction = function( state, items, data )
			local item = items[ 1 ]
			local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY + state.OffsetY + (OY or 52), state.Position.Z, (P or math.rad(-60)), state.Heading + (Y or math.rad(-100)), R or math.rad(105)
			x, z = x + math.sin( state.Heading ) * (O or 145), z + math.cos( state.Heading ) * (O or 145)

			if state.Descending then
				yaw, roll = state.Heading + math.rad( -155 ), math.rad( 160 )
				y = state.StableY + state.OffsetY + (OY or 130)
			elseif state.Ascending then
				yaw, roll = state.Heading + math.rad( -70 ), math.rad( 70 )
				y = state.StableY + state.OffsetY + (OY or 15)
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
		end,
	} )
end

MC.Mode:New( {

	Name = "Leki's Blades",
	Quality = ITEM_QUALITY_ARTIFACT,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Description = "No veil can conceal this whirlwind of blades.",
	Components = {
		{ "|H0:item:139192:4:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 10 }
	},

	SetupFunction = function( completeFunc, state, items, data )

		local updateFunc = function( data, index, item, items )
			local yaw = 2 * math.pi * ( index / #items )
			item:SetPositionAndOrientation( data.X, data.Y, data.Z, 0, yaw, math.rad( 92 ) )
		end

		MC.Engine:LinkItemsToPrimary( updateFunc, completeFunc, state, items, data )

	end,

	UpdateFunction = function( state, items, data )

		local item = items[ 1 ]
		local x, y, z, pitch, yaw, roll = state.Position.X, state.Position.Y + state.OffsetY - 63, state.Position.Z, 0, state.Heading, math.rad( 92 )

		if state.IdleAnimations then
			yaw = 2 * math.pi * ( state.FrameMS % 6000 ) / 6000
		end

		if state.Ascending then
			local angle = yaw - state.Heading
			roll = roll + math.rad( 15 ) * math.sin( angle )
			pitch = pitch + math.rad( 15 ) * math.cos( angle )
			y = y + -4
		elseif state.Descending then
			local angle = -1 * ( yaw - state.Heading )
			roll = roll + math.rad( 15 ) * math.sin( angle )
			pitch = pitch + math.rad( -15 ) * math.cos( angle )
			y = y + -4
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

MC.Mode:New( {

	Name = "Clockwork Orbiter",
	Quality = ITEM_QUALITY_ARTIFACT,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Description = "A saucer of the flying variety and a menace to all crops.",
	Components = {
		{ "|H0:item:134338:4:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 10 }
	},

	SetupFunction = function( completeFunc, state, items, data )

		local updateFunc = function( data, index, item, items )
			local yaw = 2 * math.pi * ( ( index - 1 ) / #items )
			item:SetPositionAndOrientation( data.X, data.Y, data.Z, math.rad( -90.2 ), yaw, 0 )
		end

		MC.Engine:LinkItemsToPrimary( updateFunc, completeFunc, state, items, data )

	end,

	UpdateFunction = function( state, items, data )

		local x, y, z, pitch, yaw, roll = state.Position.X, state.Position.Y + state.OffsetY - 47, state.Position.Z, math.rad( 90.2 ), state.Heading, 0

		if state.Descending then
			pitch = pitch + math.rad( -25 )
			y = y + -8
		elseif state.Ascending then
			pitch = pitch + math.rad( 15 )
			y = y + -3
		elseif state.IdleAnimations then
			yaw = 2 * math.pi * ( state.FrameMS % 20000 ) / 20000
		end

		items[1]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end

} )
--[[
MC.Mode:New( {

	Name = "Balls of Fire",
	Quality = ITEM_QUALITY_ARTIFACT,
	Attributes = {MC.Mode.ATTRIBUTE.FLIGHT,},
	Description = "Goodness, gracious...",
	Components =
	{
		{"|H1:item:181643:6:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 3}
	},

	SetupFunction = function(completeFunc, state, items, data)
		local updateFunc = function(data, index, item, items)
			local numItems = #items
			local itemPercent = (index - 1) / numItems
			local theta = 2 * math.pi * itemPercent
			item:SetPositionAndOrientation(data.X + math.sin(theta) * 60, data.Y, data.Z + math.cos(theta) * 60, 0, theta, 0)
		end
		MC.Engine:LinkItemsToPrimary(updateFunc, completeFunc, state, items, data)
	end,

	UpdateFunction = function(state, items, data)
		local offsetX, offsetZ = math.sin(state.Heading) * 60, math.cos(state.Heading) * 60
		local x, y, z, pitch, yaw, roll = state.Position.X + offsetX, state.Position.Y + state.OffsetY - (OY or 32), state.Position.Z + offsetZ, 0, state.Heading, 0

		if state.Descending then
			pitch = pitch + math.rad(OP1 or -25)
			y = y + (OY1 or -10)
		elseif state.Ascending then
			pitch = pitch + math.rad(OP2 or 25)
			y = y + (OY2 or 10)
		elseif state.IdleAnimations then
			--yaw = 2 * math.pi * (state.FrameMS % 20000) / 20000
		end

		items[1]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
	end

} )
]]
do

	local offsetY
	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!4B9\"(7\"$\"&)\"$\"$\"(])!4B9\"(-\"$\"&'\"-\"%2<\"-!5I'\")k\"\\\"&&\"%1w\"(Lj\"'<a!5I'\"$\"V\"&,\"'Op\"'_n\"(J9!5x[\"(4\"%I\"$\"N\"'Q+\"%2W!5x[\")s\"y\"r\"R\"&i2\"%2'!5x[\")@\"x\"D\"V\"'*d\"%2:!5x[\"(V\"x\")\"S\"'D=\"%2N!5x[\"'j\"w\"(\"H\"']p\"%2_!5x[\"')\"w\"D\"8\"'wI\"%2j!5x[\"&P\"v\"v\"%\"(8{\"%2n!5x[\"*+\"%K\"%8\"M\"&\\E\"%1w!5x[\")[\"%J\"Z\"U\"&uv\"%21!5x[\"(w\"%J\"1\"U\"'7Q\"%2D!5x[\"'H\"%I\"3\"@\"'j\\\"%2e!5x[\"&f\"%I\"Z\".\"(,6\"%2m!5x[\"&?\"%H\"%?\"(\\{\"(Eh\"%2m!5x[\"&B\"%H\"&o\"(\\Z\"?l\"%2X!5x[\"&i\"%J\"'Q\"(\\R\"YG\"%2F!5x[\"'L\"%J\"'x\"(\\R\"ry\"%23!5x[\"(9\"%K\"(,\"(\\Y\"%4S\"%1x!5x[\")$\"%K\"'u\"(\\g\"%N-\"%1j!5x[\")^\"%L\"'M\"(\\y\"%g_\"%1b!5x[\"*-\"%L\"&k\",\"&)9\"%1b!5x[\"*6\"%v\"&H\"6\"&6&\"%1d!5x[\"*5\"%u\"%Y\"G\"&OW\"%1o!5x[\")r\"%u\"q\"R\"&i2\"%2'!5x[\")?\"%t\"A\"V\"'*d\"%2:!5x[\"(W\"%t\"'\"S\"'D=\"%2N!5x[\"'g\"%s\"(\"H\"']p\"%2_!5x[\"''\"%s\"C\"8\"'wI\"%2j!5x[\"&O\"%q\"v\"%\"(8{\"%2n!5x[\"&5\"%r\"%^\"(\\q\"(RV\"%2k!5x[\"&6\"%r\"&N\"(\\`\"3'\"%2`!5x[\"&R\"%s\"'6\"(\\U\"LY\"%2P!5x[\"',\"%t\"'g\"(\\Q\"f4\"%2=!5x[\"'l\"%u\"(*\"(\\T\"%'f\"%2)!5x[\")E\"%u\"'c\"(\\o\"%Zq\"%1e!5x[\")u\"%v\"'1\"(]*\"%tK\"%1a!5x[\"(\\\"%u\"((\"(\\_\"%A@\"%1p!5x[\"&S\"v\"'6\"(\\U\"LY\"%2P!5x[\"',\"x\"'h\"(\\Q\"f4\"%2=!5x[\"'m\"y\"(*\"(\\T\"%'f\"%2)!5x[\"(\\\"y\"(*\"(\\_\"%A@\"%1p!5x[\")D\"y\"'d\"(\\o\"%Zq\"%1e!5x[\")v\"z\"'3\"(]*\"%tK\"%1a!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Name = "Daedric Cruiser",
		Description = "Designed with the modern Xivkyn in mind, this chic little cruiser\n" ..
			"is ideal for the active lifestyle of today's trendy Taskmaster.",
		Model = model,
		Quality = ITEM_QUALITY_LEGENDARY,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local item, ft = items[1], GetFrameTimeMilliseconds()
			local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY + state.OffsetY - 46, state.Position.Z, 0, state.Heading, 0

			if state.Descending then
				x, y, z = x - 80 * math.sin( state.Heading ), y - 54, z - 80 * math.cos( state.Heading )
				pitch = pitch + math.rad( -25 )
			elseif state.Ascending then
				x, y, z = x - 80 * math.sin( state.Heading ), y + 22, z - 80 * math.cos( state.Heading )
				pitch = pitch + math.rad( 25 )
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

do

	local offsetY
	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!4B9\"'h\"$\"&)\"$\"$\"(])!4B9\"'^\"$\"&'\"-\"%2<\"-!5I'\"(u\"p\"&&\"%&l\"'PZ\"&@O!5I'\"$\"K\"&9\"'Uc\"'f9\"(O9!5x[\"'e\"%I\"$\"N\"'Q+\"%2W!5x[\"(q\"x\"D\"V\"'*d\"%2:!5x[\"(/\"x\")\"S\"'D=\"%2N!5x[\"'C\"w\"(\"H\"']p\"%2_!5x[\"&Z\"w\"D\"8\"'wI\"%2j!5x[\"(P\"%J\"1\"U\"'7Q\"%2D!5x[\"&y\"%I\"3\"@\"'j\\\"%2e!5x[\"(0\"%t\"'\"S\"'D=\"%2N!5x[\"'@\"%s\"(\"H\"']p\"%2_!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Name = "Daedric Chariot",
		Description = "A sporty, 2-door version of the Daedric Cruiser.",
		Model = model,
		Quality = ITEM_QUALITY_LEGENDARY,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local item = items[1]
			local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY + state.OffsetY - 46, state.Position.Z, 0, state.Heading, 0

			if state.Descending then
				x, y, z = x - 80 * math.sin( state.Heading ), y - 54, z - 80 * math.cos( state.Heading )
				pitch = pitch + math.rad( -25 )
			elseif state.Ascending then
				x, y, z = x - 80 * math.sin( state.Heading ), y + 22, z - 80 * math.cos( state.Heading )
				pitch = pitch + math.rad( 25 )
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

do

	local offsetY, ascendOffsetY, pitchInterval, yawInterval = -275, 0, 6000, 15000
	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!5B@\"0o\".a\"/A\"(('\"'(W\"%2<!5B@\"1'\".b\"/)\"Y(\"d'\"%2<!5B/\"/[\"1*\".A\"GW\"'(X\"%!5B/\"0E\"1M\".m\"0o\"'(X\"(]+!5B/\"15\"1S\"/E\"(S7\"'(X\"(]+!5B/\"2$\"19\"/t\"(<O\"'(X\"(]+!5B/\"2_\"0]\"0C\"(%g\"'(W\"$!5B/\"3.\"/m\"0]\"'g(\"'(W\"$!5B/\"3?\".p\"0h\"'P=\"'(_\"(]$!5B/\"37\"-q\"0c\"'d&\"d(\"&@T!5B/\"2n\"-$\"0N\"'zf\"d(\"&@S!5B/\"1O\"+t\"/V\"(P8\"d(\"&@T!5B/\"0_\"+o\"/&\"-p\"d(\"&@T!5B/\"/p\",/\".O\"DX\"d(\"&@T!5B/\"/6\",d\".)\"[@\"d'\"&@S!5B/\".g\"-U\"-e\"r'\"d'\"&@S!5B/\".U\".R\"-Z\"%0j\"d/\"&@[!5B/\".]\"/P\"-`\"u(\"'(W\"(]*!5B/\"/&\"0F\"-u\"^?\"'(X\"$!5B/\"2:\",?\"0*\"(9R\"d'\"&@T!5B@\"5I\"7S\"&a\"E@\"&gn\"Qo!5B@\"-'\"&3\"8B\"EC\"&gq\"&nI!5B/\"-5\"&O\"7v\"T'\"(?%\"($V!5B/\"05\"n\"6{\"`r\"(S9\"(3F!5B/\"*Q\"(l\"86\"E,\"(1>\"'tm!5B/\"(C\"+]\"7f\"5:\"(&e\"'q0!5B/\"&v\".c\"6]\"%,\"'uK\"'p0!5B/\"&A\"1j\"4x\"(N'\"'l0\"'qN!5B/\"&[\"4\\\"2k\"(>=\"'aX\"'uN!5B/\"%$\"5h\"0R\"RR\"(?%\"[*!5B/\"&{\"7e\"3G\"R?\"(?B\"H`!5B/\"0F\"&B\":M\"[]\"%pn\"&%s!5B/\",l\"%]\"8v\"[d\"%qA\"&8o!5B/\")X\"%d\"6\\\"[d\"%qm\"&Km!5B/\"'$\"&R\"3e\"[[\"%r>\"&^h!5B/\"%9\"(&\"0U\"[J\"%rd\"&q`!5B/\"L\"**\"-<\"[4\"%s&\"',O!5B/\"b\",O\"*2\"Zp\"%s6\"'?8!5B/\"'h\"7$\"0H\"(/L\"'T%\"(%E!5B/\")`\"8c\"-u\"'ze\"'@I\"(3p!5B/\",6\"9Z\"+U\"'rU\"&{(\"(LI!5B/\"//\"9]\")R\"'r<\"&Vy\"2a!5B/\"28\"8k\"'y\"'z'\"&8t\"Kv!5B/\"58\"71\"'&\"(.S\"&$g\"Zz!5B/\"7u\"4l\"&f\"(=:\"%nt\"c8!5B/\":*\"1{\"'6\"(Lz\"%d7\"gJ!5B/\";P\".u\"(@\"%\"%Zq\"hu!5B/\"<,\"+n\"*%\"45\"%QZ\"h,!5B/\";j\")$\",1\"D)\"%G4\"dY!5B/\":^\"&\\\".T\"S,\"%9g\"]5!5B/\"8f\"u\"1(\"`1\"%&-\"Nz!5B/\"68\"%\"3G\"hb\"_^\"5_!5B/\"3?\"$\"5I\"i&\"9F\"(MP!5B/\")k\"8{\"5z\"R3\"(?f\"6D!5B/\"-8\"9I\"8&\"R/\"(@3\")!5B/\"0z\"8{\"9F\"R3\"(@Y\"(Jm!5B/\"4h\"7e\"9x\"R?\"(A$\"(8P!5B/\"89\"5i\"9a\"RR\"(AA\"(&.!5B/\";4\"3=\"8W\"Rj\"(AV\"'k_!5B/\"=@\"0D\"6h\"S.\"(Aa\"'Y3!5B/\">K\"-E\"4D\"SK\"(Ac\"'FW!5B/\">U\"*N\"1U\"Sg\"(AY\"'3u!5B/\"=T\"'z\".X\"T(\"(AC\"&y3!5B/\";T\"&%\"+e\"T;\"(A&\"&fB!5B/\"8e\"f\")2\"TG\"(@Y\"&SN!5B/\"5@\"C\"'+\"TL\"(@3\"&@X!5B/\"1U\"e\"%e\"TG\"(?d\"&-a!5B/\"-h\"&$\"%3\"T;\"(?@\"%rm!5B/\"*=\"'y\"%K\"T(\"(>{\"%`%!5B/\"'E\"*M\"&R\"Sg\"(>f\"%M;!5B/\"%9\"-C\"(C\"SK\"(>\\\"%:X!5B/\",\"0D\"*h\"S.\"(>\\\"%'{!5B/\"$\"3:\"-U\"Rk\"(>g\"mO!5B/\"%z\"/.\"'L\"ZT\"%s:\"'Qo!5B/\"(2\"1d\"%O\"Z6\"%s2\"'dF!5B/\"++\"4-\">\"Yu\"%rx\"'vl!5B/\".R\"6(\"$\"Y`\"%rY\"(12!5B/\"21\"7I\"^\"YQ\"%r5\"(CK!5B/\"5e\"8+\"&4\"YJ\"%qd\"(Ub!5B/\"8w\"8&\"(O\"YK\"%q:\".n!5B/\";T\"76\"+C\"YS\"%pi\"A-!5B/\"=?\"5e\".T\"Yc\"%pE\"SF!5B/\">*\"3_\"1k\"Yz\"%p*\"ef!5B/\"=n\"1:\"4x\"Z<\"%oq\"x6!5B/\"<V\".[\"7Z\"ZY\"%ok\"%2f!5B/\":F\",%\"9\\\"Zv\"%oq\"%EG!5B/\"7L\")]\":l\"[9\"%p+\"%X1!5B/\"4(\"'a\";.\"[N\"%pH\"%jz!5Bx\"1F\".r\"/N\"'dz\"'(T\"(!5Bx\"0P\".Q\".r\"t.\"d$\"&@O!5Bx\"0Q\".w\".s\"m>\"'([\"&!5Bx\"0i\"/9\"/+\":2\"'(Y\"&!5Bx\"11\"/7\"/@\"(@.\"'(Y\"%!5Bx\"1D\".L\"/M\"'ki\"d+\"&@Q!5Bx\"1-\".3\"/=\"(Fu\"d)\"&@Q!5Bx\"0e\".5\"/(\"@y\"d)\"&@R!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Name = "Inertial Gyrometer",
		Description = "Three axes of freedom, all Eulered up and ready to defy\n" ..
			"both the laws of physics and the dreaded Gimbal Lock.",
		Model = model,
		Quality = ITEM_QUALITY_LEGENDARY,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local item = items[1]
			local x, y, z, pitch, yaw, roll = state.Position.X, state.Position.Y + state.OffsetY + offsetY, state.Position.Z, 0, 0, math.rad( 90 )

			pitch = 2 * math.pi * ( state.FrameMS % pitchInterval ) / pitchInterval
			yaw = 2 * math.pi * ( state.FrameMS % yawInterval ) / yawInterval
			local offsetX, offsetZ = -40 * math.sin( yaw ), -40 * math.cos( yaw )
			x, z = x + offsetX, z + offsetZ

			if state.Ascending then
				-- No Op
			elseif state.Descending then
				y = y - 100
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

do

	local function AegisSetup( completeFunc, state, items, data )

		local x, y, z = GetPlayerWorldPositionInHouse()

		MC.Transaction:New(

			"Configure Components",

			{ Index = 1, Placed = false, Linked = false, State = state, Items = items, Data = data, X = x, Y = y + 1000, Z = z },

			function( tran )

				local data = tran:GetData()
				local index, placed, linked = data.Index, data.Placed, data.Linked

				if placed and linked then
					if index == #data.Items then
						completeFunc( state, items, data )
						return true
					end

					index, placed, linked = index + 1, false, false
					data.Index, data.Placed, data.Linked = index, placed, linked
				end

				local item = data.Items[index]
				local x, y, z = data.X, data.Y, data.Z
				local pitch, roll, yaw, offsetX, offsetY, offsetZ = 0, 0, 0, 0, 0, 0

				if not placed then

					if 1 == index then
						item:SetPositionAndOrientation( x, y, z, 0, 0, 0 )
					elseif 2 == index then
						item:SetPositionAndOrientation( x, y, z + 20, 0, 0, 0 )
					else
						item:SetPositionAndOrientation( x, y, z + 40, 0, 0, 0 )
					end

					data.Placed = true
					return false, 300

				elseif not linked then

					if 1 == index then
						HousingEditorRequestClearFurnitureParent( item:GetFurnitureId() )
					else
						HousingEditorRequestSetFurnitureParent( item:GetFurnitureId(), data.Items[index - 1]:GetFurnitureId() )
					end

					data.Linked = true
					return false, 500

				end

			end,

			nil,

			completeFunc

		)

	end

	local function AegisUpdate( state, items, data )

		local actionRequested, action, actionState, cooldown, frameTime = ACTION.NONE, data.Action or ACTION.NONE, data.ActionState or 0, data.Cooldown or 0, GetFrameTimeMilliseconds()
		local x, y, z, pitch, yaw, roll

		if 0 < cooldown then
			if frameTime < cooldown then return end
			cooldown, data.Cooldown = 0, 0
		end

		if state.RollDodging then
			actionRequested = ACTION.ROLL_DODGE
		elseif state.Hidden or state.Cloaking then
			actionRequested = ACTION.HIDE
		elseif state.LastInterrupt then
			actionRequested = ACTION.INTERRUPT
		elseif state.Blocking then
			actionRequested = ACTION.BLOCK
		elseif state.Sprinting then
			actionRequested = ACTION.SPRINT
		end

		if actionRequested ~= action then
			action = actionRequested
			actionState = 0
		end

		x, y, z = state.Position.X - 0 * math.sin( state.Heading ), state.StableY + state.OffsetY - 10, state.Position.Z - 0 * math.cos( state.Heading )
		pitch, yaw, roll = math.rad( 91 ), state.Heading + math.pi, 0

		if state.Descending or action == ACTION.ROLL_DODGE then
			pitch = pitch + math.rad( 30 )
			y = y - 65
		elseif state.Ascending or action == ACTION.SPRINT then
			pitch = pitch - math.rad( 30 )
			y = y - 5
		end

		if action == ACTION.NONE or nil == data.CurrentX then

			if 0 == actionState then

				data.CurrentX, data.CurrentY, data.CurrentZ, data.CurrentYaw = x, y, z, yaw
				items[1]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
				items[2]:SetPositionAndOrientation( x, y - 20, z, pitch, yaw, roll )
				cooldown = 200
				actionState = 1

			else

				data.CurrentX, data.CurrentY, data.CurrentZ, data.CurrentYaw = x, y, z, yaw
				items[1]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

			end

		else

			if actionRequested == ACTION.BLOCK then

				if actionState == 0 then

					x, y, z = x - 160 * math.sin( data.CurrentYaw - math.pi ), y + 80, z - 160 * math.cos( data.CurrentYaw - math.pi )
					if state.Ascending or state.Descending then y = y + 50 end
					items[2]:SetPositionAndOrientation( x, y, z, pitch - math.rad( 89 ), data.CurrentYaw, roll )
					actionState = 1
					cooldown = 200

				end

			elseif actionRequested == ACTION.ROLL_DODGE then

				if actionState == 0 then

					x, y, z = x + 300 * math.sin( data.CurrentYaw - math.pi ), y + 120, z + 300 * math.cos( data.CurrentYaw - math.pi )
					items[2]:SetPositionAndOrientation( x, y, z, pitch + math.rad( 60 ), data.CurrentYaw, roll )
					actionState = 1
					cooldown = 200

				end

			elseif actionRequested == ACTION.INTERRUPT then

				if actionState == 0 then

					x, y, z = x - 200 * math.sin( data.CurrentYaw - math.pi ), y + 80, z - 200 * math.cos( data.CurrentYaw - math.pi )
					if state.Ascending or state.Descending then y = y + 50 end
					items[2]:SetPositionAndOrientation( x, y, z, pitch - math.rad( 70 ), data.CurrentYaw, roll )
					actionState = 1
					cooldown = 200

				elseif actionState == 1 then

					x, y, z = x - 175 * math.sin( data.CurrentYaw - math.pi ), y + 80, z - 175 * math.cos( data.CurrentYaw - math.pi )
					if state.Ascending or state.Descending then y = y + 50 end
					items[2]:SetPositionAndOrientation( x, y, z, pitch - math.rad( 90 ), data.CurrentYaw, roll )
					actionState = 2
					cooldown = 100

				elseif actionState == 2 then

					x, y, z = x - 150 * math.sin( data.CurrentYaw - math.pi ), y + 80, z - 150 * math.cos( data.CurrentYaw - math.pi )
					if state.Ascending or state.Descending then y = y + 50 end
					items[2]:SetPositionAndOrientation( x, y, z, pitch - math.rad( 110 ), data.CurrentYaw, roll )
					state.LastInterrupt = nil
					actionState = 0
					cooldown = 200

				end

			elseif actionRequested == ACTION.HIDE then

				if actionState == 0 then

					y = y - 150
					data.CurrentX, data.CurrentY, data.CurrentZ, data.CurrentYaw = x, y, z, yaw
					items[1]:SetPositionAndOrientation( x, y, z, pitch + math.pi, yaw, roll )
					cooldown = 100

				end

			end

			if 0 == cooldown then
				items[1]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
				data.CurrentX, data.CurrentY, data.CurrentZ, data.CurrentYaw = x, y, z, yaw
			end

		end

		data.Action, data.ActionState, data.Cooldown = action, actionState, frameTime + cooldown

	end

	MC.Mode:New( {

		Name = "Aegis of the Covenant",
		Description = "A protective enchantment employed by Covenant battlemages\n" ..
			"for use in tactical combat.",
		Quality = ITEM_QUALITY_ARCANE,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, MC.Mode.ATTRIBUTE.COMBAT_ENHANCED },
		Components = { { "|H0:item:120064:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 3 }, },
		SetupFunction = AegisSetup,
		UpdateFunction = AegisUpdate,

	} )

	MC.Mode:New( {

		Name = "Aegis of the Dominion",
		Description = "A protective enchantment employed by Dominion battlemages\n" ..
			"for use in tactical combat.",
		Quality = ITEM_QUALITY_ARCANE,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, MC.Mode.ATTRIBUTE.COMBAT_ENHANCED },
		Components = { { "|H0:item:120063:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 3 }, },
		SetupFunction = AegisSetup,
		UpdateFunction = AegisUpdate,

	} )

	MC.Mode:New( {

		Name = "Aegis of the Pact",
		Description = "A protective enchantment employed by Pact battlemages\n" ..
			"for use in tactical combat.",
		Quality = ITEM_QUALITY_ARCANE,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, MC.Mode.ATTRIBUTE.COMBAT_ENHANCED },
		Components = { { "|H0:item:120065:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 3 }, },
		SetupFunction = AegisSetup,
		UpdateFunction = AegisUpdate,

	} )

end

MC.Mode:New( {

	Name = "Designer Head Scarf",
	Description = "You would take form over function any day and this delicate wrap from Alinor's preeminent designer won't let anyone forget that.\n|c00bbbbOwn it... |c44ccccWork it... |c88ffffLive it.",
	Quality = ITEM_QUALITY_LEGENDARY,
	Attributes = { MC.Mode.ATTRIBUTE.COSMETIC, },
	CameraDistance = 0,
	CameraVerticalOffset = -0.3,
	Components = {
		{ "|H0:item:139367:6:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local item, x, y, z, pitch, yaw, roll = items[ 1 ], state.Position.X, state.Position.Y + state.OffsetY + 205, state.Position.Z, math.rad( 2 ), state.Heading + math.pi, 0
		x, z = x + 100 * math.sin( state.Heading ), z + 100 * math.cos( state.Heading )
		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

MC.Mode:New( {

	Name = "Pippi Longcurtain",
	Description = "Yes, it's pigtails...\nBut some argue that it's also a state of mind.",
	Quality = ITEM_QUALITY_MAGIC,
	Attributes = { MC.Mode.ATTRIBUTE.COSMETIC, },
	CameraDistance = 0,
	CameraVerticalOffset = -0.3,
	Components = {
		{ "|H0:item:151678:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 }
	},
	SetupFunction = nil,
	UpdateFunction = function( state, items, data )
		local item, x, y, z, pitch, yaw, roll = items[ 1 ], state.Position.X, state.Position.Y + state.OffsetY + 220, state.Position.Z, math.rad( 340 ), state.Heading + math.pi, 0
		pitch = pitch + math.rad( math.min( state.Distance, 40 ) )
		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
	end,

} )

MC.Mode:New( {

	Name = "RoboCopter",
	Description = "Clever dwemer pun or movie reference?\nYou decide...",
	Quality = ITEM_QUALITY_MAGIC,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:147577:5:1:0:0:0:0:0:0:0:0:0:0:0:65:0:0:1:0:0:0|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local item = items[ 1 ]
		local x, y, z, pitch, yaw, roll = state.Position.X, state.Position.Y + state.OffsetY, state.Position.Z, 0, state.Heading, 0
		local xOffset, yOffset, zOffset = 0, 0, 0
		local hOffset, vOffset = 0, 0

		if state.Ascending then
			pitch = math.rad( 20 )
			hOffset, vOffset = 250, -163
		elseif state.Descending then
			pitch = math.rad( -20 )
			hOffset, vOffset = 250, -165
		else
			pitch = 0
			hOffset, vOffset = 250, -162
		end

		if state.IdleAnimations then
			if state.Idling then
				if state.IdlingTimer <= 16000 then
					local interval = math.sin( ( state.IdlingTimer % 4000 ) / 4000 * 2 * math.pi )
					pitch = pitch + math.rad( interval * ( 5 - math.floor( state.IdlingTimer / 4000 ) ) )
				end

				if state.IdlingTimer >= 3000 then
					local interval = math.sin( ( ( state.IdlingTimer - 3000 ) % 5000 ) / 5000 * 2 * math.pi )
					if 1 == state.IdlingStart % 2 then
						roll = roll + math.rad( interval * math.min( state.IdlingTimer / 3000, 3 ) )
					else
						roll = roll - math.rad( interval * math.min( state.IdlingTimer / 3000, 3 ) )
					end
				end

				if state.IdlingTimer >= 18000 then
					local interval = math.sin( ( ( state.IdlingTimer - 18000 ) % 8000 ) / 8000 * 2 * math.pi )
					if 1 == state.IdlingStart % 3 then
						pitch = pitch + math.rad( interval )
					else
						pitch = pitch - math.rad( interval )
					end
				end
			end
		end

		xOffset, yOffset, zOffset = MC.Engine:Rotate( 0, vOffset, hOffset, pitch, yaw, roll )
		x, y, z = x + xOffset, y + yOffset, z + zOffset

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

------[[ PLAYER SUBMITTED MODES ]]------

do

	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!5BL\"o\"&J\"'x\"$\"$\"$!3NE\"D\"%Z\"&e\"([G\"(X{\"&C;!3NE\"%o\"%U\"''\"%N\"&HW\"&@z!3NE\"2\"%R\"(y\"%L\":%\"&@F!3NE\".\"%]\"'o\"(\\B\"Q\"&GU!3NE\"%s\"%O\"((\").\"&E/\"&Bx!39F\"$\"&/\"A\"%-r\"(Ai\"qa!5BL\"o\"&=\"'v\"$\"$\"&@T!3NE\"%X\"%W\"(U\"`\"%xd\"&@C!39F\"%j\"&.\"E\"%&w\"(V;\"'I'!5BH\"l\").\"*S\"()$\"'Ms\"'O\\!5B]\"v\"'r\"%z\"&+\"'Sx\"%Y2!5BP\"r\"$\")n\"w\"&?]\"(\\R!5C&\"s\"%{\"$\"'R6\"&?X\"(])!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Name = "City City Bang Bang",
		Author = "@Callaleo, PC NA",
		Description = "A truly scrumptious ride with a Sotha Sil of Approval(tm).",
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local x, y, z, pitch, yaw, roll, offset = state.Position.X, 0, state.Position.Z, 0, state.Heading, 0, 0

			if state.Descending then
				offset = 0
				pitch = pitch + math.rad( 340 )
				y = y - 85
			elseif state.Ascending then
				offset = -100
				pitch = pitch + math.rad( 20 )
				y = y - 44
			else
				pitch = pitch + math.rad( 1 )
				y = y - 76
			end

			if not state.Idling or ( state.Idling and state.IdleAnimations ) then
				local timeline = ( state.FrameMS % 5000 ) / 5000
				local timelineF = 2 * math.pi * timeline
				roll = roll + math.rad( 3 ) * math.sin( timelineF )
			end

			y = y + state.StableY + state.OffsetY
			x, z = x + offset * math.sin( state.Heading ), z + offset * math.cos( state.Heading )

			items[1]:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

do

	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!4kK\"'i3\"%dh\"'&_\"(]*\"'EM\"(]$!4kK\"'ib\"%di\"''G\"*\"JC\"(!4kK\"'iw\"%dj\"''2\"(\"ct\"*!4kK\"'j+\"%dk\"'&n\"%\"%%N\"+!4kK\"'j+\"%dl\"'&O\"(]*\"%?)\"+!4kK\"'iw\"%dk\"'&3\"(]'\"%XZ\"*!4kK\"'iF\"%dh\"''S\"+\"0i\"%!4kK\"'ib\"%dj\"'%v\"(]%\"%r5\"(!4kK\"'iF\"%di\"'%j\"(]$\"&3g\"%!4kK\"'hT\"%dm\"'&8\"*\"D2\"'!4kK\"'hW\"%dm\"''4\"(]%\"&m5\"(]'!4kK\"'iE\"%di\"'&^\"$\"'Mx\"(]$!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Author = "@Xerodom, PC NA",
		Name = "Siofra's Magic School Bus",
		Description = "Guaranteed to make you grin a most maniacal grin.\n**Cheese not included",
		Quality = ITEM_QUALITY_LEGENDARY,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local item = items[ 1 ]
			local x, y, z, pitch, yaw, roll = state.Position.X, 0, state.Position.Z, 0, state.Heading, math.pi

			if state.Descending then
				pitch = math.rad( -14 )
				y = state.StableY + state.OffsetY - 7
			elseif state.Ascending then
				pitch = math.rad( 14 )
				y = state.StableY + state.OffsetY - 5
			else
				y = state.StableY + state.OffsetY
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

do

	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!6>s\")l\"$\")`\"$\"U+\"$!3<\\\")>\"]\"/_\"$\"(Y3\"$!3M1\"%c\"]\"-t\"$\"%`p\"$!3L?\"$\"]\")S\"$\"%1i\"$!3<^\")x\"]\"$\"$\"&:s\"$!3Ld\"/@\"]\")K\"$\"'Lk\"$!3&q\")n\")8\")_\"$\"&o,\"$!3&r\"'>\"'7\"/<\"$\"&*l\"$!3&r\"/W\"'3\"'M\"$\"'_{\"$!3&r\",D\"'9\"2\"$\"(H2\"$!3&r\")\"'6\"+t\"$\"%IX\"$!3<[\"-c\"]\"%h\"$\"%k3\"$!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Author = "@Agrivar, PC NA",
		Name = "Crafting Rotunda",
		Description = "The fusion of Orcish design with mobile productivity.\nSuspend whenever you feel the urge to take a craft.",
		Quality = ITEM_QUALITY_LEGENDARY,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local item = items[ 1 ]
			local x, y, z, pitch, yaw, roll = state.Position.X, 0, state.Position.Z, 0, state.Heading, 0

			if state.Descending then
				pitch = math.rad( -20 )
				y = state.StableY + state.OffsetY - 100
			elseif state.Ascending then
				pitch = math.rad( 20 )
				y = state.StableY + state.OffsetY - 65
			else
				y = state.StableY + state.OffsetY - 55
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

do

	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!3Mt\"9\"$\"$\"%2:\"$\"&@T!3Mt\"O\"$\"I\"%2:\"',c\"&@T!3Mt\"O\"$\"0\"%2:\"'pt\"&@T!3Mt\"$\"$\"0\"%2:\"h3\"&@T!3Mt\"9\"$\"U\"%2:\"&@T\"&@T!3Mt\"$\"$\"I\"%2:\"%TD\"&@T!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Author = "@mayasunrising",
		Name = "Maya's Crystalline Sunrise",
		Description = "Practice your Warrior Pose in the sky while atop\nMaya's stellar disc of flight.",
		Quality = ITEM_QUALITY_LEGENDARY,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local item = items[ 1 ]
			local x, y, z, pitch, yaw, roll = state.Position.X, 0, state.Position.Z, math.rad( 90 ), state.Heading, 0

			if state.Descending then
				pitch = math.rad( 70 )
				y = -23
				x, z = x - 20 * math.sin( yaw ), z - 20 * math.cos( yaw )
			elseif state.Ascending then
				pitch = math.rad( 110 )
				y = -11
				x, z = x - 20 * math.sin( yaw ), z - 20 * math.cos( yaw )
			elseif state.IdleAnimations then
				y = -12
				yaw = state.Heading + ( 2 * math.pi * ( state.FrameMS % 6000 ) / 6000 )
				x, z = x + 20 * math.sin( yaw ), z + 20 * math.cos( yaw )
			end

			y = y + state.Position.Y + state.OffsetY
			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

MC.Mode:New( {

	Author = "@Callaleo, PC NA",
	Name = "Rudolph's Radishing Nose",
	Description = "It's simply radishing.\n(Recommended with no active Personality - Adjust height as necessary)",
	Quality = ITEM_QUALITY_LEGENDARY,
	Attributes = { MC.Mode.ATTRIBUTE.COSMETIC, },
	Components = {
		{ "|H0:item:118031:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local item, x, y, z, pitch, yaw, roll = items[ 1 ], state.Position.X, state.Position.Y + state.OffsetY + 212, state.Position.Z, math.rad( 105 ), state.Heading - math.rad( 13 ), 0
		x, z = x - 26 * math.sin( state.Heading ), z - 26 * math.cos( state.Heading )
		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

do
	local modelData = "\"\"\"\"\"\"\"\"\"\"V3!4kd\"/ws\"&va\"/=Z\"$\"$\"&@T!3Mk\"/wc\"&vH\"/=]\"(]'\"%Ol\"&@T!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {
		Name = "Ion Thruster",
		Description = "Fast, silent technology that also coordinates well with formal attire.",
		Quality = ITEM_QUALITY_ARTIFACT,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			state.StabilizationThresholdY = 15
			data.tiltAngle = 0
			data.pitchAngle = 0
			data.verticalOffset = 0

			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )
			local item, x, y, z, pitch, yaw, roll = items[ 1 ], state.Position.X, state.StableY + state.OffsetY - 28, state.Position.Z, math.pi, state.Heading, 0

			local tiltPitch = 0
			local tiltRoll = 0

			if state.IdlingTimer then
				if data.tiltAngle < 1.6 then
					data.tiltAngle = data.tiltAngle + 0.2
				end
			else
				if data.tiltAngle > 0 then
					data.tiltAngle = data.tiltAngle - 0.2
				end
			end

			local tiltAngle1 = 2 * math.pi * ( ( state.FrameMS % 6700 ) / 6700 )
			local tiltAngle2 = 2 * math.pi * ( ( state.FrameMS % 9000 ) / 9000 )
			local tiltPitch = math.rad( math.sin( tiltAngle1 ) * data.tiltAngle )
			local tiltRoll = math.rad( math.cos( tiltAngle2 ) * data.tiltAngle )

			local targetAngle = 0
			local targetOffset = 0

			if state.Descending then
				targetAngle = math.rad( -30 )
				targetOffset = -3
			elseif state.Ascending then
				targetAngle = math.rad( 30 )
				targetOffset = -9
			end

			if data.pitchAngle ~= targetAngle then
				data.pitchAngle = data.pitchAngle + ( targetAngle - data.pitchAngle ) * 0.65
			end

			if data.verticalOffset ~= targetOffset then
				data.verticalOffset = data.verticalOffset + ( targetOffset - data.verticalOffset ) * 0.65
			end

			pitch = pitch + tiltPitch + data.pitchAngle
			roll = roll + tiltRoll
			y = y + data.verticalOffset

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
		end,
	} )
end

MC.Mode:New( {

	Author = "@DragonJrill, PC NA",
	Name = "Jrill's Booster Seat",
	Description = "Sponsored by the fabulous ESO Housing Magazine YouTube channel \"Juni Sulli\".",
	Quality = ITEM_QUALITY_LEGENDARY,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:116463:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local item, x, y, z, pitch, yaw, roll = items[ 1 ], state.Position.X, state.Position.Y + state.OffsetY - 80, state.Position.Z, math.rad( 180 ), state.Heading, 0

		if state.Descending then
			y = y - 20
			pitch = math.rad( 150 )
			x, z = x - 26 * math.sin( state.Heading ), z - 26 * math.cos( state.Heading )
		elseif state.Ascending then
			y = y + 10
			pitch = math.rad( 200 )
			x, z = x - 50 * math.sin( state.Heading ), z - 50 * math.cos( state.Heading )
		elseif state.Idling and state.IdleAnimations then
			yaw = state.Heading + ( 2 * math.pi * ( state.IdlingTimer % 4000 ) / 4000 )
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

MC.Mode:New( {

	Author = "@Swankery, PC NA",
	Name = "Swanky Seahorse",
	Description = "Giddy-up!",
	Quality = ITEM_QUALITY_LEGENDARY,
	Attributes = { MC.Mode.ATTRIBUTE.FLIGHT, },
	Components = {
		{ "|H0:item:119986:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h", 1 }
	},

	SetupFunction = nil,

	UpdateFunction = function( state, items, data )

		local item, x, y, z, pitch, yaw, roll = items[ 1 ], state.Position.X, state.StableY + state.OffsetY - 45, state.Position.Z, 0, state.Heading - math.rad( 90 ), math.rad( 90 )
		x, z = x + 100 * math.sin( state.Heading ), z + 100 * math.cos( state.Heading )

		if state.Descending then
			y = state.StableY + state.OffsetY + 28
			roll = math.rad( 135 )
		elseif state.Ascending then
			y = state.StableY + state.OffsetY - 75
			roll = math.rad( 45 )
			x, z = x - 100 * math.sin( state.Heading ), z - 100 * math.cos( state.Heading )
		end

		item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	end,

} )

do

	local offsetY
	local modelData = "\"\"\"\"\"\"\"\"\"\"V2!5{t\"$\"$\"$\"'Nn\"$\"$!5{t\"$\"$\"%f\"'Nn\"$\"$!"
	local model = MC.Model:New( modelData )

	MC.Mode:New( {

		Author = "@Agrivar, PC NA",
		Name = "Water in the Sky",
		Description = "\"Phish is life.\"\n- Agrivar the Wise",
		Model = model,
		Quality = ITEM_QUALITY_LEGENDARY,
		Attributes = { MC.Mode.ATTRIBUTE.FLIGHT },
		Components = model:GetRequirements(),

		SetupFunction = function( completeFunc, state, items, data )
			model:Construct( items, function() MC.Engine:LinkItemsToPrimary( nil, completeFunc, state, items, data ) end )
		end,

		UpdateFunction = function( state, items, data )

			local item, ft = items[1], GetFrameTimeMilliseconds()
			local x, y, z, pitch, yaw, roll = state.Position.X, 0, state.Position.Z, 0, state.Heading, 0
			x, z = x - 120 * math.sin( state.Heading ), z - 120 * math.cos( state.Heading )

			if state.Descending then
				pitch = pitch + math.rad( 260 )
				y = state.StableY + state.OffsetY - 240
				x, z = x - 20 * math.sin( state.Heading ), z - 20 * math.cos( state.Heading )
			elseif state.Ascending then
				pitch = pitch + math.rad( 280 )
				y = state.StableY + state.OffsetY - 200
			else
				pitch = math.rad( 270 )
				y = state.StableY + state.OffsetY - 211
				x, z = x - 120 * math.sin( state.Heading ), z - 120 * math.cos( state.Heading )
			end

			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

		end,

	} )

end

MC.Mode:New( {

	Author = "@Callaleo, PC NA",
	Name = "May The Farce Be With You",
	Description = "Not sponsored by Cinnabon(tm)",
	Quality = ITEM_QUALITY_LEGENDARY,
	Attributes = { MC.Mode.ATTRIBUTE.COSMETIC },
	Components = {
		{ "|H0:item:118355:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", 2 }
	},

	SetupFunction = function( completeFunc, state, items, data )

		local updateFunc = function( data, index, item, items )
			local yaw = 2 * math.pi * ( ( index - 1 ) / #items )
			local oX, oZ = math.sin( yaw ) * -2, math.cos( yaw ) * -2
			item:SetPositionAndOrientation( data.X + oX, data.Y, data.Z + oZ, 0.5 * math.pi, yaw, 0 )
		end

		MC.Engine:LinkItemsToPrimary( updateFunc, completeFunc, state, items, data )

	end,

	UpdateFunction = function( state, items, data )

		local x, y, z, pitch, yaw, roll = state.Position.X, state.StableY + state.OffsetY + 212, state.Position.Z, 0.5 * math.pi, state.Heading, 0
		items[1]:SetPositionAndOrientation( x, y, z, pitch, yaw + 0.5 * math.pi, roll )

	end,

} )

do

	local numItemFrames = 5
	local nextItemTime, itemIndex, itemFrame, itemAngle, itemOffset, itemOffsetY = 0, 2, 1, 0, 0, -100
	local itemX, itemY, itemZ

	MC.Mode:New( {

		Name = "Magnetic Personality",
		Description = string.format( "It's not your fault for being such an attractive %s -\nyou were just drawn this way.", GetPlayerRace() ),
		Quality = ITEM_QUALITY_MAGIC,
		Attributes = { MC.Mode.ATTRIBUTE.COSMETIC },
		Components = {
			{ "|H1:item:117943:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", 1 },
			{ "|H1:item:118028:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", 1 },
			{ "|H1:item:118034:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 },
			{ "|H1:item:118035:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1 },
			{ "|H1:item:118029:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", 1 },
			{ "|H1:item:118025:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", 1 },
		},

		SetupFunction = function( completeFunc, state, items, data )

			local updateFunc = function( data, index, item, items )
				item:SetPositionAndOrientation( data.X, data.Y, data.Z, 0, 0, 0 )
			end

			MC.Engine:LinkItemsToPrimary( updateFunc, completeFunc, state, items, data )

		end,

		UpdateFunction = function( state, items, data )

			local x, y, z, yaw = state.Position.X, state.Position.Y, state.Position.Z, state.Heading

			if not state.Idling then
				nextItemTime = 0
				items[1]:SetPositionAndOrientation( x, y - 900, z, 0, yaw, 0 )
			else
				if state.IdlingTimer >= nextItemTime then
					local item = items[itemIndex]

					if 1 == itemFrame then
						local approach = math.random( 1, 10 )

						if 1 >= approach then
							itemAngle = math.rad( math.random( 88, 92 ) )
							itemOffsetY = math.random( 30, 70 )
							itemOffset = 30
						elseif 2 >= approach then
							itemAngle = math.rad( math.random( 268, 272 ) )
							itemOffsetY = math.random( 30, 70 )
							itemOffset = 30
						elseif 6 >= approach then
							itemAngle = math.rad( math.random( -2, 2 ) )
							itemOffsetY = math.random( 80, 170 )
							itemOffset = (O or 32) - 6 * ( ( 170 - itemOffsetY ) / 170 )
						else
							itemAngle = math.rad( math.random( 178, 182 ) )
							itemOffsetY = math.random( 80, 170 )
							itemOffset = (O2 or 19) - 6 * ( ( 170 - itemOffsetY ) / 170 )
						end
					end

					itemX, itemZ = ( ( numItemFrames + 1 ) - itemFrame ) * itemOffset * math.sin( itemAngle ), ( ( numItemFrames + 1 ) - itemFrame ) * itemOffset * math.cos( itemAngle )
					itemY = ( itemFrame / numItemFrames ) * itemOffsetY

					item:SetPositionAndOrientation(
						x + itemX, y + itemY, z + itemZ,
						itemFrame >= numItemFrames and math.rad( 80 ) or math.rad( math.random( 0, 89 ) ),
						itemAngle,
						itemFrame >= numItemFrames and 0 or math.rad( math.random( 0, 89 ) ) )

					itemFrame = itemFrame + 1

					if itemFrame > numItemFrames then
						itemFrame = 1
						itemIndex = itemIndex + 1

						if itemIndex > #items then
							itemIndex = 2
						end

						nextItemTime = state.IdlingTimer + math.random( 0, 1200 )
					end
				end
			end

		end,

	} )

end