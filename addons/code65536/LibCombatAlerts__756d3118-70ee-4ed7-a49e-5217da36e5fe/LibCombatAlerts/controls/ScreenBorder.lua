local LCA = LibCombatAlerts


--------------------------------------------------------------------------------
-- LCA_ScreenBorder
--------------------------------------------------------------------------------

local LCA_ScreenBorder = LCA.BaseControlObject:Subclass()
LCA.ScreenBorder = LCA_ScreenBorder

local nextBorderId = 1 -- Global so that border IDs are unique even across border instances
local function Identifier( x )
	return "LCA_ScreenBorder_" .. x
end

-- Preserve GuiRoot to guard against redefinition
local GuiRoot = GuiRoot


--------------------------------------------------------------------------------
-- Public interface
--------------------------------------------------------------------------------

function LCA_ScreenBorder:New( )
	local obj = LCA.BaseControlObject.New(self, "LCA_ScreenBorder")

	obj.control = WINDOW_MANAGER:CreateControlFromVirtual(obj.ID, GuiRoot, "LCA_ScreenBorder")
	obj.control:SetHidden(true)
	obj.overlay = obj.control:GetNamedChild("Overlay")
	obj.overlay:SetCenterColor(0, 0, 0, 0)
	obj.overlay:SetEdgeTexture(LCA.GetTexture("screenborder-edge"), 2048, 256)
	obj.overlay:SetInsets(256, 256, -256, -256)

	obj.borders = { }

	return obj
end

function LCA_ScreenBorder:Enable( color, duration, borderIdOverride )
	if (type(color) ~= "number") then
		color = 0xFFFFFFFF
	end

	-- Identifier for this border
	local borderId = borderIdOverride
	if (type(borderId) ~= "number" and type(borderId) ~= "string") then
		borderId = nextBorderId
		nextBorderId = nextBorderId + 1
	end

	-- If there is an existing update callback for this border, disable it
	if (self.borders[borderId] and self.borders[borderId][5]) then
		EVENT_MANAGER:UnregisterForUpdate(Identifier(borderId))
	end

	-- Register the border
	self.borders[borderId] = { LCA.UnpackRGBA(color) }

	-- Set update callback for timed disablement
	if (type(duration) == "number") then
		self.borders[borderId][5] = true
		EVENT_MANAGER:RegisterForUpdate(Identifier(borderId), duration, function() self:Disable(borderId) end, true)
	end

	self:Redraw()
	return borderId
end

function LCA_ScreenBorder:Disable( borderId )
	if ((type(borderId) == "number" or type(borderId) == "string") and self.borders[borderId]) then
		if (self.borders[borderId][5]) then
			EVENT_MANAGER:UnregisterForUpdate(Identifier(borderId))
		end
		self.borders[borderId] = nil
	elseif (borderId == nil) then
		for id, border in pairs(self.borders) do
			if (border[5]) then
				EVENT_MANAGER:UnregisterForUpdate(Identifier(id))
			end
		end
		self.borders = { }
	end

	self:Redraw()
end


--------------------------------------------------------------------------------
-- Private functions; do not call these externally
--------------------------------------------------------------------------------

function LCA_ScreenBorder:Redraw( )
	local first = next(self.borders)

	if (not first) then
		-- No active borders
		self.control:SetHidden(true)
	elseif (not next(self.borders, first)) then
		-- Single active border
		self.overlay:SetEdgeColor(unpack(self.borders[first]))
		self.control:SetHidden(false)
	else
		-- Multiple active borders: Mix the colors together
		local sumX, sumY, sumS, sumL, sumA, maxA = 0, 0, 0, 0, 0, 0

		-- Convert to HSL and calculate circular mean weighted by alpha and saturation
		for _, border in pairs(self.borders) do
			local r, g, b, a = unpack(border)

			if (a > 0) then
				local h, s, l = ConvertRGBToHSL(r, g, b)
				local as = a * s
				sumX = math.cos(h * ZO_TWO_PI) * as + sumX
				sumY = math.sin(h * ZO_TWO_PI) * as + sumY
				sumS = as + sumS
				sumL = l * a + sumL
				sumA = a + sumA
				if (maxA < a) then
					maxA = a
				end
			end
		end

		-- The numerator will always be zero if the denominator is zero, so any
		-- number can be used to avoid division by zero
		if (sumA == 0) then sumA = 1 end

		local r, g, b = LCA.HSLToRGB(math.atan2(sumY, sumX) / ZO_TWO_PI, sumS / sumA, sumL / sumA)
		self.overlay:SetEdgeColor(r, g, b, maxA)
		self.control:SetHidden(false)
	end
end
