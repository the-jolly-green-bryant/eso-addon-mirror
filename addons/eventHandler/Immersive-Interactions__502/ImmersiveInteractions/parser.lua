-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --

-- this feature was heavily inspired by UX Dialog

do
	local ns	= "ImmersiveInteractions"
	local wm	= WINDOW_MANAGER

	function ImmersiveFunctions.DuplicateControl(ctrl, name)
		local d = wm:CreateControl(ImmersiveFunctions.CreateName(ctrl:GetName(), name), ctrl:GetParent(), ctrl:GetType())

		d:SetHidden(ctrl:IsHidden())
		d:SetDimensions(ctrl:GetDimensions())
		d:SetAnchor(select(2, ctrl:GetAnchor()))
		d:SetScale(ctrl:GetScale())
		d:SetAlpha(ctrl:GetAlpha())
		d:SetColor(ctrl:GetColor())

		d:SetDrawLayer(ctrl:GetDrawLayer())
		d:SetDrawLevel(ctrl:GetDrawLevel())
		d:SetDrawTier(ctrl:GetDrawTier())

		if ctrl:GetType() == CT_TEXTURE then
			local texture = ctrl:GetTextureFileName()
			if #texture ~= 0 then
				d:SetTexture(texture)
			end

			d:SetResizeToFitFile(ctrl:GetResizeToFitFile())
		end

		return d
	end

	function ImmersiveFunctions.CreateName(...)
		--[[
			1. accept any number of arbitrary-typed parameters (var_n, for n number of parameters),
			2. given parameters var_n are tables where all elemenets are strings or numbers,
			3. merge elements var_n[1] to var_n[#var_n] for all n parameters, separating tables by '_' (underscore)
			-- seems excessive, since we are only calling this with strings
		--]]
		local str = table.concat({...}, '_')
		-- replace anything other than alphanumeric or underscores with underscores
		str = string.gsub(str, '[^%w_]', '_')

		-- check if (our namespace) ns..'_' is already part of str already, else add it as prefix (avoids adding the prefix multiple times)
		if not string.find(str, ns..'_') then
			str = ns..'_'..str
		end
		return str
	end

	-- ==================== --

	-- ==================== --

	function ImmersiveFunctions.SetupReplay()
		local MOUSE_BUTTON_LEFT = 1

		--local ds = ImmersiveData
		local icar = ImmersiveData.ctrls["audioReplay"]
		local dtau = ImmersiveData.icons["audioUp"].texture
		local dtad = ImmersiveData.icons["audioDown"].texture

		icar:SetHidden(false)

		icar:SetAnchor(LEFT, nil, LEFT, -.5, 0)
		icar:SetResizeToFitFile(true)

		icar:SetTexture(dtad)
		icar:SetTexture(dtau)

		icar:SetAlpha(.5)
		icar:SetMouseEnabled(true)

		icar:SetHandler('OnMouseEnter', function(self)
			if self.isMouseDown then
				self:SetTexture(dtad)
			else
				self:SetTexture(dtau)
			end
			self:SetAlpha(1)
		end)

		icar:SetHandler('OnMouseExit', function(self)
			self:SetTexture(dtau)
			self:SetAlpha(.5)
		end)

		icar:SetHandler('OnMouseDown', function(self, button)
			if wm:GetMouseOverControl() == self and button == MOUSE_BUTTON_LEFT then
				self.isMouseDown = true
				self:SetTexture(dtad)
			end
		end)

		icar:SetHandler('OnMouseUp', function(self, button)
			self.isMouseDown = false
			self:SetTexture(dtau)
			-- replay audio icon clicked
			if wm:GetMouseOverControl() == self and button == MOUSE_BUTTON_LEFT then
				ImmersiveFunctions.ReplayAudio()
			end
		end)
	end

	-- ==================== --

	-- ==================== --

	function ImmersiveFunctions.SetupIcon(op)
		-- lg prefix for local copies of global (_G) variables
		local lgIcon		= _G[op:GetName()..'Icon']
		local lgTexture		= _G[op:GetName()..'IconImage']

		-- make sure any previous changes to this icon do not stick
		if op.isTainted then
			lgIcon:SetScale(1)
			
			lgIcon:ClearAnchors()
			lgIcon:SetAnchor(RIGHT, op, LEFT, -5, 0)

			lgTexture:SetColor(1,1,1,1)
			lgTexture:SetDesaturation(0)

			if op.secondary then
				op.secondary:SetHidden(true)
				op.secondary:SetAlpha(1)
				op.secondary:SetColor(1,1,1,1)
				op.secondary:SetDesaturation(0)
			end

			op.isTainted = false
		end

		local custom = ImmersiveData.iconsByType[op.optionType]

		if custom then
			lgIcon:SetHidden(false)

			if custom.secondary then
				if not op.secondary then
					op.secondary = ImmersiveFunctions.DuplicateControl(lgTexture, "Secondary")
				end

				local secondary = op.secondary
				secondary:SetTexture(custom.secondary.texture)
				secondary:ClearAnchors()

				local point, relativeTo, relativePoint, offsetX, offsetY = select(2, lgTexture:GetAnchor())
				if custom.secondary.offset then
					local offsets = custom.secondary.offset
					offsetX = offsetX + offsets[1]
					offsetY = offsetY + offsets[2]
				end
				secondary:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
				secondary:SetScale(custom.secondary.scale or lgTexture:GetScale())

				if custom.secondary.color then
					secondary:SetColor(unpack(custom.secondary.color))
				end
				secondary:SetAlpha(custom.secondary.alpha or 1)

				if custom.secondary.placeBehind then
					secondary:SetDrawLevel(lgTexture:GetDrawLevel() - 1)
				else
					secondary:SetDrawLevel(lgTexture:GetDrawLevel() + 1)
				end

				secondary:SetHidden(false)
			end

			lgTexture:SetTexture(custom.texture)

			if custom.scale then
				lgIcon:SetScale(custom.scale)
			end

			if custom.anchor then
				local point, relativePoint, offsetX, offsetY = unpack(custom.anchor)
				lgIcon:ClearAnchors()
				lgIcon:SetAnchor(point, op, relativePoint, offsetX, offsetY)
			end

			local icons = ImmersiveData.icons
			if op.chosenBefore or not op.enabled then
				lgTexture:SetDesaturation(1)
				lgTexture:SetColor(unpack(icons["disabledIcon"]))

				if op.secondary then
					op.secondary:SetDesaturation(1)
					op.secondary:SetColor(unpack(icons["disabledIcon"]))
				end
			elseif op.isImportant and not custom.colorOverride then
				lgTexture:SetColor(1,0,0,1)

				if op.secondary then
					op.secondary:SetColor(1,0,0,1)
				end
			elseif custom.color then
				lgTexture:SetColor(unpack(custom.color))
			end

			-- if guild bank or tradehouse and not part of any guild, dim label and icon
			if (op.optionType == CHATTER_START_GUILDBANK or op.optionType == CHATTER_START_TRADINGHOUSE) and GetNumGuilds() == 0 then
				op:SetColor(unpack(icons["disabledColor"]))
				lgTexture:SetDesaturation(1)
				lgTexture:SetColor(unpack(icons["disabledIcon"]))
			end

			op.isTainted = true
			lgTexture:SetHidden(false)

		-- flag to avoid resetting unnecessarily
		else
			op.isTainted = false
			lgIcon:SetHidden(true)
		end

		table.insert(ImmersiveData.controls, lgIcon)
	end
end
