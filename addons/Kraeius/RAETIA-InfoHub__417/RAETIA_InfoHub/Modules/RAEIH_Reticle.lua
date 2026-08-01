local LMP = RAEIH.LMP
local uTag = "reticleover"
local meTag = "player"

-- zo_iconFormat(RAEIH.Icons.Reticle, RAEIH.SavedVars.ReticleIconW, RAEIH.SavedVars.ReticleIconH) .. " " ..

function RAEIH.ReticleMode()
	if RAEIH.SavedVars.ReticleFirstTime == true then
		RAEIH_Reticle:ClearAnchors()
		RAEIH_Reticle:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, 0, -150)
		RAEIH.SavedVars.ReticleX = RAEIH_Reticle:GetLeft()
		RAEIH.SavedVars.ReticleY = RAEIH_Reticle:GetTop()
		RAEIH_Reticle:ClearAnchors()
		RAEIH_Reticle:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ReticleX, RAEIH.SavedVars.ReticleY)
		RAEIH.SavedVars.ReticleFirstTime = false
	end
end

function RAEIH.ChangeReticleTexture()
	if RAEIH_Reticle_Texture == nil then
		local WM = GetWindowManager()
		if RAEIH.SavedVars.ChangeReticleTexture then
			local txPath = nil
			local txSize = nil
			if RAEIH.SavedVars.ReticleTexture == "Cross" then
				txPath = RAEIH.Reticles.Cross.Path
				txSize = RAEIH.Reticles.Cross.Size
			elseif RAEIH.SavedVars.ReticleTexture == "Dot" then
				txPath = RAEIH.Reticles.Dot.Path
				txSize = RAEIH.Reticles.Dot.Size
			end
				RAEIH_Reticle_Texture = WM:CreateControl("RAEIH_Reticle_Texture", ZO_ReticleContainer, CT_TEXTURE)
				RAEIH_Reticle_Texture:SetTexture(txPath)
				RAEIH_Reticle_Texture:SetDimensions(txSize, txSize)
				RAEIH_Reticle_Texture:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, 0, 0)
				RAEIH_Reticle_Texture:SetColor(1, 1, 1, 1)
				RAEIH_Reticle_Texture:SetMouseEnabled(false)
				RAEIH_Reticle_Texture:SetMovable(false)
				RAEIH_Reticle_Texture:SetScale(RAEIH.SavedVars.ReticleTextureScale)
				ZO_ReticleContainerReticle:SetHidden(true)
		else
			ZO_ReticleContainerReticle:SetHidden(false)
		end
	else
		RAEIH.OrganizeReticleTexture()		
	end
end

function RAEIH.OrganizeReticleTexture()
	if RAEIH.SavedVars.ChangeReticleTexture == true and RAEIH_Reticle_Texture ~= nil then
		local txPath = nil
		local txSize = nil
		if RAEIH.SavedVars.ReticleTexture == "Cross" then
			txPath = RAEIH.Reticles.Cross.Path
			txSize = RAEIH.Reticles.Cross.Size
		elseif RAEIH.SavedVars.ReticleTexture == "Dot" then
			txPath = RAEIH.Reticles.Dot.Path
			txSize = RAEIH.Reticles.Dot.Size
		end
		RAEIH_Reticle_Texture:SetTexture(txPath)
		RAEIH_Reticle_Texture:SetDimensions(txSize, txSize)
		ZO_ReticleContainerReticle:SetHidden(true)
		RAEIH_Reticle_Texture:SetHidden(false)
	end
end

function RAEIH.CreateReticle()
	if RAEIH_Reticle == nil then
		local WM = GetWindowManager()
		-- Shorten Variables
		local mX = RAEIH.SavedVars.ReticleX
		local mY = RAEIH.SavedVars.ReticleY
		-- Main Placeholder
		RAEIH_Reticle = WM:CreateTopLevelWindow("RAEIH_Reticle")
		RAEIH_Reticle:SetDimensions(500, 100)
		RAEIH_Reticle:SetClampedToScreen(true)
		RAEIH_Reticle:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Reticle:SetMouseEnabled(false)
		RAEIH_Reticle:SetHidden(not RAEIH.SavedVars.ShowReticle)
		-- String
		RAEIH_Reticle_String = WM:CreateControl("RAEIH_Reticle_String", RAEIH_Reticle, CT_LABEL)
		RAEIH_Reticle_String:SetAnchorFill(RAEIH_Reticle)
		RAEIH_Reticle_String:SetHorizontalAlignment(1)
		RAEIH_Reticle_String:SetVerticalAlignment(1)
		RAEIH.ReticleMode()
	end
end

function RAEIH.SetReticle()

	if RAEIH.SavedVars.ShowTargetInfo == true or
		RAEIH.SavedVars.ChangeReticleTexture == true or
		RAEIH.SavedVars.ReticleReactionColouring == true or
		RAEIH.SavedVars.ReticlePartialColouring == true then

		-- Target First Check
		local tName = GetUnitName(uTag)

		-- No Valid Target
		if tName == "" or tName == nil then

			-- Hide Reticle Text
			RAEIH.ReticleText = ""
			RAEIH_Reticle_String:SetText(RAEIH.ReticleText)
			RAEIH_Reticle:SetHidden(true)

			-- Make RT Default Coloured
			if RAEIH.SavedVars.ReticleReactionColouring == true and RAEIH.SavedVars.ReticleUseRCforRT == true then
				local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNoTarget)
				ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
				end
			elseif RAEIH.SavedVars.ReticleReactionColouring == true and RAEIH.SavedVars.ReticleUsePCforRT == true then
				local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleTextureColour)
				ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
				end
			elseif RAEIH.SavedVars.ReticlePartialColouring == true and RAEIH.SavedVars.ReticleUseRCforRT == true then
				local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNoTarget)
				ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
				end
			elseif RAEIH.SavedVars.ReticlePartialColouring == true and RAEIH.SavedVars.ReticleUsePCforRT == true then
				local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleTextureColour)
				ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
				end
			end

		-- Critter Check
		elseif RAEIH.SavedVars.ReticleIgnoreCritter and
			(tName == "Rat" or
			tName == "Chicken" or
			tName == "Beetle" or
			tName == "Sheep" or
			tName == "Pig" or
			tName == "Snake" or
			tName == "Frog" or
			tName == "Monkey" or
			tName == "Bantam Guar" or
			tName == "Fox" or
			tName == "Deer" or
			tName == "Spider" or
			tName == "Rabbit") then

			-- Hide Reticle Text
			RAEIH.ReticleText = ""
			RAEIH_Reticle_String:SetText(RAEIH.ReticleText)
			RAEIH_Reticle:SetHidden(true)

			-- Make RT Default Coloured
			if RAEIH.SavedVars.ReticleReactionColouring == true and RAEIH.SavedVars.ReticleUseRCforRT == true then
				local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNoTarget)
				ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
				end
			elseif RAEIH.SavedVars.ReticleReactionColouring == true and RAEIH.SavedVars.ReticleUsePCforRT == true then
				local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleTextureColour)
				ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
				end
			elseif RAEIH.SavedVars.ReticlePartialColouring == true and RAEIH.SavedVars.ReticleUseRCforRT == true then
				local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNoTarget)
				ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
				end
			elseif RAEIH.SavedVars.ReticlePartialColouring == true and RAEIH.SavedVars.ReticleUsePCforRT == true then
				local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleTextureColour)
				ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
				end
			end

		-- Target is Valid
		else

			-- Prepare Default Colours
			local clrDft = "|c" .. RAEIH.SavedVars.ReticleDefaultColour
			local clrName = "|c" .. RAEIH.SavedVars.ReticleNameColour
			local clrLVR = "|c" .. RAEIH.SavedVars.ReticleLVRColour
			local clrCHealth = "|c" .. RAEIH.SavedVars.ReticleCHealthColour
			local clrMHealth = "|c" .. RAEIH.SavedVars.ReticleMHealthColour
			local clrHPerc = "|c" .. RAEIH.SavedVars.ReticleHPercColour
			local clrGender = "|c" .. RAEIH.SavedVars.ReticleGenderColour
			local clrRace = "|c" .. RAEIH.SavedVars.ReticleRaceColour
			local clrClass = "|c" .. RAEIH.SavedVars.ReticleClassColour
			local clrTiCa = "|c" .. RAEIH.SavedVars.ReticleTiCaColour
			local clrAvA = "|c" .. RAEIH.SavedVars.ReticleAvAColour
			local clrAlliance = "|c" .. RAEIH.SavedVars.ReticleAllianceColour

			-- Check If Target is Alive
			local tCH, tMH = GetUnitPower(uTag, -2)
			local tReaction = GetUnitReaction(uTag)

			-- Define Reaction
			if tReaction == 0 then tReaction = "Unidentified"
			elseif tReaction == 1 then tReaction = "Hostile"
			elseif tReaction == 2 then tReaction = "Neutral"
			elseif tReaction == 3 then tReaction = "Friendly"
			elseif tReaction == 4 then tReaction = "Player Ally"
			elseif tReaction == 5 then tReaction = "NPC Ally" end

			-- Set Complete Reaction Colours
			if RAEIH.SavedVars.ReticleReactionColouring then
				if tCH == 0 then
					clrDft = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrName = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrGender = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrRace = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrClass = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCDead
					clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCDead
				elseif tReaction == "Unidentified" then
					clrDft = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrName = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrGender = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrRace = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrClass = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
				elseif tReaction == "Hostile" then
					clrDft = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrName = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrGender = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrRace = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrClass = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCHostile
				elseif tReaction == "Neutral" then
					clrDft = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrName = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrGender = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrRace = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrClass = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
				elseif tReaction == "Friendly" then
					clrDft = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrName = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrGender = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrRace = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrClass = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
				elseif tReaction == "Player Ally" then
					clrDft = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrName = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrGender = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrRace = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrClass = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
				elseif tReaction == "NPC Ally" then
					clrDft = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrName = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrGender = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrRace = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrClass = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
				end
			end

			-- Set Reticle Texture Reaction Colours
			if RAEIH.SavedVars.ReticleReactionColouring == true and RAEIH.SavedVars.ReticleUseRCforRT == true then
				if tCH == 0 then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCDead)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "Unidentified" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCUnidentified)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "Hostile" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCHostile)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "Neutral" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNeutral)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "Friendly" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCFriendly)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "Player Ally" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCPlayerAlly)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "NPC Ally" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNPCAlly)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				end
			elseif RAEIH.SavedVars.ReticleReactionColouring == true and RAEIH.SavedVars.ReticleUsePCforRT == true then
				local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleTextureColour)
				ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
				end
			elseif RAEIH.SavedVars.ReticlePartialColouring == true and RAEIH.SavedVars.ReticleUsePCforRT == true then
				local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleTextureColour)
				ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
				end
			elseif RAEIH.SavedVars.ReticlePartialColouring == true and RAEIH.SavedVars.ReticleUseRCforRT == true then
				if tCH == 0 then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCDead)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "Unidentified" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCUnidentified)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "Hostile" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCHostile)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "Neutral" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNeutral)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "Friendly" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCFriendly)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "Player Ally" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCPlayerAlly)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				elseif tReaction == "NPC Ally" then
					local r, g, b = RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNPCAlly)
					ZO_ReticleContainerReticle:SetColor(r, g, b, 1)
					if RAEIH_Reticle_Texture ~= nil then
						RAEIH_Reticle_Texture:SetColor(r, g, b, 1)
					end
				end
			elseif RAEIH.SavedVars.ReticleUseRCforRT == false and RAEIH.SavedVars.ReticleUsePCforRT == false then
				ZO_ReticleContainerReticle:SetColor(1, 1, 1, 1)
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetColor(1, 1, 1, 1)
				end
			end

			-- Set Partial Reaction Colours
			if RAEIH.SavedVars.ReticlePartialColouring then
				-- LVR Colouring
				if RAEIH.SavedVars.ReticleLVRMode == "Difficulty Mode" then
					local isTargetVeteran = IsUnitVeteran(uTag)
					local amIVeteran = IsUnitVeteran(meTag)

					if amIVeteran == true and isTargetVeteran == false then clrLVR = "|c" .. RAEIH.SavedVars.ReticleLowLVR

					elseif amIVeteran == false and isTargetVeteran == true then clrLVR = "|c" .. RAEIH.SavedVars.ReticleHighLVR

					elseif amIVeteran == false and isTargetVeteran == false then
						local targetLvl = GetUnitLevel(uTag)
						local myLvl = GetUnitLevel(meTag)

						if myLvl <= (targetLvl - 5) then clrLVR = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myLvl >= (targetLvl - 2) and myLvl <= (targetLvl + 2) then clrLVR = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myLvl >= (targetLvl + 5) then clrLVR = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end

					elseif amIVeteran == true and isTargetVeteran == true then
						local targetRank = GetUnitVeteranRank(uTag)
						local myRank = GetUnitVeteranRank(meTag)

						if myRank <= (targetRank - 5) then clrLVR = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myRank >= (targetRank - 2) and myRank <= (targetRank + 2) then clrLVR = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myRank >= (targetRank + 5) then clrLVR = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end
					end
				elseif RAEIH.SavedVars.ReticleLVRMode == "Reaction Mode" then
					if tCH == 0 then
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCDead
					elseif tReaction == "Unidentified" then
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					elseif tReaction == "Hostile" then
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					elseif tReaction == "Neutral" then
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					elseif tReaction == "Friendly" then
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					elseif tReaction == "Player Ally" then
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					elseif tReaction == "NPC Ally" then
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					end
				elseif RAEIH.SavedVars.ReticleLVRMode == "Alliance Mode" then
					local tAlliance = GetUnitAlliance(uTag)
					if tAlliance == 3 then
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleDC
					elseif tAlliance == 2 then
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleEP
					elseif tAlliance == 1 then
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleAD
					else
						clrLVR = "|c" .. RAEIH.SavedVars.ReticleNoAlliance
					end
				end
				-- Name Colouring
				if RAEIH.SavedVars.ReticleNameMode == "Difficulty Mode" then
					local isTargetVeteran = IsUnitVeteran(uTag)
					local amIVeteran = IsUnitVeteran(meTag)

					if amIVeteran == true and isTargetVeteran == false then clrName = "|c" .. RAEIH.SavedVars.ReticleLowLVR

					elseif amIVeteran == false and isTargetVeteran == true then clrName = "|c" .. RAEIH.SavedVars.ReticleHighLVR

					elseif amIVeteran == false and isTargetVeteran == false then
						local targetLvl = GetUnitLevel(uTag)
						local myLvl = GetUnitLevel(meTag)

						if myLvl <= (targetLvl - 5) then clrName = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myLvl >= (targetLvl - 2) and myLvl <= (targetLvl + 2) then clrName = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myLvl >= (targetLvl + 5) then clrName = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end

					elseif amIVeteran == true and isTargetVeteran == true then
						local targetRank = GetUnitVeteranRank(uTag)
						local myRank = GetUnitVeteranRank(meTag)

						if myRank <= (targetRank - 5) then clrName = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myRank >= (targetRank - 2) and myRank <= (targetRank + 2) then clrName = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myRank >= (targetRank + 5) then clrName = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end
					end
				elseif RAEIH.SavedVars.ReticleNameMode == "Reaction Mode" then
					if tCH == 0 then
						clrName = "|c" .. RAEIH.SavedVars.ReticleRCDead
					elseif tReaction == "Unidentified" then
						clrName = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					elseif tReaction == "Hostile" then
						clrName = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					elseif tReaction == "Neutral" then
						clrName = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					elseif tReaction == "Friendly" then
						clrName = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					elseif tReaction == "Player Ally" then
						clrName = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					elseif tReaction == "NPC Ally" then
						clrName = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					end
				elseif RAEIH.SavedVars.ReticleNameMode == "Alliance Mode" then
					local tAlliance = GetUnitAlliance(uTag)
					if tAlliance == 3 then
						clrName = "|c" .. RAEIH.SavedVars.ReticleDC
					elseif tAlliance == 2 then
						clrName = "|c" .. RAEIH.SavedVars.ReticleEP
					elseif tAlliance == 1 then
						clrName = "|c" .. RAEIH.SavedVars.ReticleAD
					else
						clrName = "|c" .. RAEIH.SavedVars.ReticleNoAlliance
					end
				end
				-- Health Colouring
				if RAEIH.SavedVars.ReticleHealthMode == "Difficulty Mode" then
					local isTargetVeteran = IsUnitVeteran(uTag)
					local amIVeteran = IsUnitVeteran(meTag)

					if amIVeteran == true and isTargetVeteran == false then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleLowLVR

					elseif amIVeteran == false and isTargetVeteran == true then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleHighLVR

					elseif amIVeteran == false and isTargetVeteran == false then
						local targetLvl = GetUnitLevel(uTag)
						local myLvl = GetUnitLevel(meTag)

						if myLvl <= (targetLvl - 5) then
							clrCHealth = "|c" .. RAEIH.SavedVars.ReticleHighLVR
							clrMHealth = "|c" .. RAEIH.SavedVars.ReticleHighLVR
							clrHPerc = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myLvl >= (targetLvl - 2) and myLvl <= (targetLvl + 2) then
							clrCHealth = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
							clrMHealth = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
							clrHPerc = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myLvl >= (targetLvl + 5) then
							clrCHealth = "|c" .. RAEIH.SavedVars.ReticleLowLVR
							clrMHealth = "|c" .. RAEIH.SavedVars.ReticleLowLVR
							clrHPerc = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end

					elseif amIVeteran == true and isTargetVeteran == true then
						local targetRank = GetUnitVeteranRank(uTag)
						local myRank = GetUnitVeteranRank(meTag)

						if myRank <= (targetRank - 5) then
							clrCHealth = "|c" .. RAEIH.SavedVars.ReticleHighLVR
							clrMHealth = "|c" .. RAEIH.SavedVars.ReticleHighLVR
							clrHPerc = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myRank >= (targetRank - 2) and myRank <= (targetRank + 2) then
							clrCHealth = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
							clrMHealth = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
							clrHPerc = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myRank >= (targetRank + 5) then
							clrCHealth = "|c" .. RAEIH.SavedVars.ReticleLowLVR
							clrCHealth = "|c" .. RAEIH.SavedVars.ReticleLowLVR
							clrMHealth = "|c" .. RAEIH.SavedVars.ReticleLowLVR
							clrHPerc = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end
					end
				elseif RAEIH.SavedVars.ReticleHealthMode == "Reaction Mode" then
					if tCH == 0 then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCDead
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCDead
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCDead
					elseif tReaction == "Unidentified" then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					elseif tReaction == "Hostile" then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCHostile
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCHostile
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					elseif tReaction == "Neutral" then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					elseif tReaction == "Friendly" then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					elseif tReaction == "Player Ally" then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					elseif tReaction == "NPC Ally" then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					end
				elseif RAEIH.SavedVars.ReticleHealthMode == "Alliance Mode" then
					local tAlliance = GetUnitAlliance(uTag)
					if tAlliance == 3 then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleDC
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleDC
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleDC
					elseif tAlliance == 2 then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleEP
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleEP
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleEP
					elseif tAlliance == 1 then
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleAD
						clrMHealth = "|c" .. RAEIH.SavedVars.ReticleAD
						clrHPerc = "|c" .. RAEIH.SavedVars.ReticleAD
					else
						clrCHealth = "|c" .. RAEIH.SavedVars.ReticleNoAlliance
					end
				end
				-- Gender Colouring
				if RAEIH.SavedVars.ReticleGenderMode == "Difficulty Mode" then
					local isTargetVeteran = IsUnitVeteran(uTag)
					local amIVeteran = IsUnitVeteran(meTag)

					if amIVeteran == true and isTargetVeteran == false then clrGender = "|c" .. RAEIH.SavedVars.ReticleLowLVR

					elseif amIVeteran == false and isTargetVeteran == true then clrGender = "|c" .. RAEIH.SavedVars.ReticleHighLVR

					elseif amIVeteran == false and isTargetVeteran == false then
						local targetLvl = GetUnitLevel(uTag)
						local myLvl = GetUnitLevel(meTag)

						if myLvl <= (targetLvl - 5) then clrGender = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myLvl >= (targetLvl - 2) and myLvl <= (targetLvl + 2) then clrGender = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myLvl >= (targetLvl + 5) then clrGender = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end

					elseif amIVeteran == true and isTargetVeteran == true then
						local targetRank = GetUnitVeteranRank(uTag)
						local myRank = GetUnitVeteranRank(meTag)

						if myRank <= (targetRank - 5) then clrGender = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myRank >= (targetRank - 2) and myRank <= (targetRank + 2) then clrGender = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myRank >= (targetRank + 5) then clrGender = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end
					end
				elseif RAEIH.SavedVars.ReticleGenderMode == "Reaction Mode" then
					if tCH == 0 then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleRCDead
					elseif tReaction == "Unidentified" then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					elseif tReaction == "Hostile" then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					elseif tReaction == "Neutral" then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					elseif tReaction == "Friendly" then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					elseif tReaction == "Player Ally" then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					elseif tReaction == "NPC Ally" then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					end
				elseif RAEIH.SavedVars.ReticleGenderMode == "Alliance Mode" then
					local tAlliance = GetUnitAlliance(uTag)
					if tAlliance == 3 then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleDC
					elseif tAlliance == 2 then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleEP
					elseif tAlliance == 1 then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleAD
					else
						clrGender = "|c" .. RAEIH.SavedVars.ReticleNoAlliance
					end
				elseif RAEIH.SavedVars.ReticleGenderMode == "Split Gender Mode" then
					local tGender = GetUnitGender(uTag)
					if tGender == 1 then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleFemale
					elseif tGender == 2 then
						clrGender = "|c" .. RAEIH.SavedVars.ReticleMale
					else
						clrGender = "|c" .. RAEIH.SavedVars.ReticleGenderColour
					end
				end
				-- Race Colouring
				if RAEIH.SavedVars.ReticleRaceMode == "Difficulty Mode" then
					local isTargetVeteran = IsUnitVeteran(uTag)
					local amIVeteran = IsUnitVeteran(meTag)

					if amIVeteran == true and isTargetVeteran == false then clrRace = "|c" .. RAEIH.SavedVars.ReticleLowLVR

					elseif amIVeteran == false and isTargetVeteran == true then clrRace = "|c" .. RAEIH.SavedVars.ReticleHighLVR

					elseif amIVeteran == false and isTargetVeteran == false then
						local targetLvl = GetUnitLevel(uTag)
						local myLvl = GetUnitLevel(meTag)

						if myLvl <= (targetLvl - 5) then clrRace = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myLvl >= (targetLvl - 2) and myLvl <= (targetLvl + 2) then clrRace = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myLvl >= (targetLvl + 5) then clrRace = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end

					elseif amIVeteran == true and isTargetVeteran == true then
						local targetRank = GetUnitVeteranRank(uTag)
						local myRank = GetUnitVeteranRank(meTag)

						if myRank <= (targetRank - 5) then clrRace = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myRank >= (targetRank - 2) and myRank <= (targetRank + 2) then clrRace = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myRank >= (targetRank + 5) then clrRace = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end
					end
				elseif RAEIH.SavedVars.ReticleRaceMode == "Reaction Mode" then
					if tCH == 0 then
						clrRace = "|c" .. RAEIH.SavedVars.ReticleRCDead
					elseif tReaction == "Unidentified" then
						clrRace = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					elseif tReaction == "Hostile" then
						clrRace = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					elseif tReaction == "Neutral" then
						clrRace = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					elseif tReaction == "Friendly" then
						clrRace = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					elseif tReaction == "Player Ally" then
						clrRace = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					elseif tReaction == "NPC Ally" then
						clrRace = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					end
				elseif RAEIH.SavedVars.ReticleRaceMode == "Ext. Alliance Mode" then
					local tRace = GetUnitRace(uTag)
					if tRace == "Imperial" then clrRace = "|c" .. RAEIH.SavedVars.ReticleIMP
					elseif tRace == "Breton" or tRace == "Redguard" or tRace == "Orc" then clrRace = "|c" .. RAEIH.SavedVars.ReticleDC
					elseif tRace == "High Elf" or tRace == "Wood Elf" or tRace == "Khajiit" then clrRace = "|c" .. RAEIH.SavedVars.ReticleAD
					elseif tRace == "Nord" or tRace == "Dark Elf" or tRace == "Argonian" then clrRace = "|c" .. RAEIH.SavedVars.ReticleEP
					else clrRace = "|c" .. RAEIH.SavedVars.ReticleNoAlliance
					end
				end
				-- Class Colouring
				if RAEIH.SavedVars.ReticleClassMode == "Difficulty Mode" then
					local isTargetVeteran = IsUnitVeteran(uTag)
					local amIVeteran = IsUnitVeteran(meTag)

					if amIVeteran == true and isTargetVeteran == false then clrClass = "|c" .. RAEIH.SavedVars.ReticleLowLVR

					elseif amIVeteran == false and isTargetVeteran == true then clrClass = "|c" .. RAEIH.SavedVars.ReticleHighLVR

					elseif amIVeteran == false and isTargetVeteran == false then
						local targetLvl = GetUnitLevel(uTag)
						local myLvl = GetUnitLevel(meTag)

						if myLvl <= (targetLvl - 5) then clrClass = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myLvl >= (targetLvl - 2) and myLvl <= (targetLvl + 2) then clrClass = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myLvl >= (targetLvl + 5) then clrClass = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end

					elseif amIVeteran == true and isTargetVeteran == true then
						local targetRank = GetUnitVeteranRank(uTag)
						local myRank = GetUnitVeteranRank(meTag)

						if myRank <= (targetRank - 5) then clrClass = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myRank >= (targetRank - 2) and myRank <= (targetRank + 2) then clrClass = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myRank >= (targetRank + 5) then clrClass = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end
					end
				elseif RAEIH.SavedVars.ReticleClassMode == "Reaction Mode" then
					if tCH == 0 then
						clrClass = "|c" .. RAEIH.SavedVars.ReticleRCDead
					elseif tReaction == "Unidentified" then
						clrClass = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					elseif tReaction == "Hostile" then
						clrClass = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					elseif tReaction == "Neutral" then
						clrClass = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					elseif tReaction == "Friendly" then
						clrClass = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					elseif tReaction == "Player Ally" then
						clrClass = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					elseif tReaction == "NPC Ally" then
						clrClass = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					end
				elseif RAEIH.SavedVars.ReticleAvAMode == "Alliance Mode" then
					local tAlliance = GetUnitAlliance(uTag)
					if tAlliance == 3 then
						clrClass = "|c" .. RAEIH.SavedVars.ReticleDC
					elseif tAlliance == 2 then
						clrClass = "|c" .. RAEIH.SavedVars.ReticleEP
					elseif tAlliance == 1 then
						clrClass = "|c" .. RAEIH.SavedVars.ReticleAD
					else
						clrClass = "|c" .. RAEIH.SavedVars.ReticleNoAlliance
					end
				end
				-- TiCa Colouring
				if RAEIH.SavedVars.ReticleTiCaMode == "Difficulty Mode" then
					local isTargetVeteran = IsUnitVeteran(uTag)
					local amIVeteran = IsUnitVeteran(meTag)

					if amIVeteran == true and isTargetVeteran == false then clrTiCa = "|c" .. RAEIH.SavedVars.ReticleLowLVR

					elseif amIVeteran == false and isTargetVeteran == true then clrTiCa = "|c" .. RAEIH.SavedVars.ReticleHighLVR

					elseif amIVeteran == false and isTargetVeteran == false then
						local targetLvl = GetUnitLevel(uTag)
						local myLvl = GetUnitLevel(meTag)

						if myLvl <= (targetLvl - 5) then clrTiCa = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myLvl >= (targetLvl - 2) and myLvl <= (targetLvl + 2) then clrTiCa = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myLvl >= (targetLvl + 5) then clrTiCa = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end

					elseif amIVeteran == true and isTargetVeteran == true then
						local targetRank = GetUnitVeteranRank(uTag)
						local myRank = GetUnitVeteranRank(meTag)

						if myRank <= (targetRank - 5) then clrTiCa = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myRank >= (targetRank - 2) and myRank <= (targetRank + 2) then clrTiCa = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myRank >= (targetRank + 5) then clrTiCa = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end
					end
				elseif RAEIH.SavedVars.ReticleTiCaMode == "Reaction Mode" then
					if tCH == 0 then
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCDead
					elseif tReaction == "Unidentified" then
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					elseif tReaction == "Hostile" then
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					elseif tReaction == "Neutral" then
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					elseif tReaction == "Friendly" then
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					elseif tReaction == "Player Ally" then
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					elseif tReaction == "NPC Ally" then
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					end
				elseif RAEIH.SavedVars.ReticleTiCaMode == "Alliance Mode" then
					local tAlliance = GetUnitAlliance(uTag)
					if tAlliance == 3 then
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleDC
					elseif tAlliance == 2 then
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleEP
					elseif tAlliance == 1 then
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleAD
					else
						clrTiCa = "|c" .. RAEIH.SavedVars.ReticleNoAlliance
					end
				end
				-- AvA Colouring
				if RAEIH.SavedVars.ReticleAvAMode == "Difficulty Mode" then
					local isTargetVeteran = IsUnitVeteran(uTag)
					local amIVeteran = IsUnitVeteran(meTag)

					if amIVeteran == true and isTargetVeteran == false then clrAvA = "|c" .. RAEIH.SavedVars.ReticleLowLVR

					elseif amIVeteran == false and isTargetVeteran == true then clrAvA = "|c" .. RAEIH.SavedVars.ReticleHighLVR

					elseif amIVeteran == false and isTargetVeteran == false then
						local targetLvl = GetUnitLevel(uTag)
						local myLvl = GetUnitLevel(meTag)

						if myLvl <= (targetLvl - 5) then clrAvA = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myLvl >= (targetLvl - 2) and myLvl <= (targetLvl + 2) then clrAvA = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myLvl >= (targetLvl + 5) then clrAvA = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end

					elseif amIVeteran == true and isTargetVeteran == true then
						local targetRank = GetUnitVeteranRank(uTag)
						local myRank = GetUnitVeteranRank(meTag)

						if myRank <= (targetRank - 5) then clrAvA = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myRank >= (targetRank - 2) and myRank <= (targetRank + 2) then clrAvA = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myRank >= (targetRank + 5) then clrAvA = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end
					end
				elseif RAEIH.SavedVars.ReticleAvAMode == "Reaction Mode" then
					if tCH == 0 then
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCDead
					elseif tReaction == "Unidentified" then
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					elseif tReaction == "Hostile" then
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					elseif tReaction == "Neutral" then
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					elseif tReaction == "Friendly" then
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					elseif tReaction == "Player Ally" then
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					elseif tReaction == "NPC Ally" then
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					end
				elseif RAEIH.SavedVars.ReticleAvAMode == "Alliance Mode" then
					local tAlliance = GetUnitAlliance(uTag)
					if tAlliance == 3 then
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleDC
					elseif tAlliance == 2 then
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleEP
					elseif tAlliance == 1 then
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleAD
					else
						clrAvA = "|c" .. RAEIH.SavedVars.ReticleNoAlliance
					end
				end
				-- Alliance Colouring
				if RAEIH.SavedVars.ReticleAllianceMode == "Difficulty Mode" then
					local isTargetVeteran = IsUnitVeteran(uTag)
					local amIVeteran = IsUnitVeteran(meTag)

					if amIVeteran == true and isTargetVeteran == false then clrAlliance = "|c" .. RAEIH.SavedVars.ReticleLowLVR

					elseif amIVeteran == false and isTargetVeteran == true then clrAlliance = "|c" .. RAEIH.SavedVars.ReticleHighLVR

					elseif amIVeteran == false and isTargetVeteran == false then
						local targetLvl = GetUnitLevel(uTag)
						local myLvl = GetUnitLevel(meTag)

						if myLvl <= (targetLvl - 5) then clrAlliance = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myLvl >= (targetLvl - 2) and myLvl <= (targetLvl + 2) then clrAlliance = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myLvl >= (targetLvl + 5) then clrAlliance = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end

					elseif amIVeteran == true and isTargetVeteran == true then
						local targetRank = GetUnitVeteranRank(uTag)
						local myRank = GetUnitVeteranRank(meTag)

						if myRank <= (targetRank - 5) then clrAlliance = "|c" .. RAEIH.SavedVars.ReticleHighLVR
						elseif myRank >= (targetRank - 2) and myRank <= (targetRank + 2) then clrAlliance = "|c" .. RAEIH.SavedVars.ReticleNormalLVR
						elseif myRank >= (targetRank + 5) then clrAlliance = "|c" .. RAEIH.SavedVars.ReticleLowLVR
						end
					end
				elseif RAEIH.SavedVars.ReticleAllianceMode == "Reaction Mode" then
					if tCH == 0 then
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCDead
					elseif tReaction == "Unidentified" then
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCUnidentified
					elseif tReaction == "Hostile" then
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCHostile
					elseif tReaction == "Neutral" then
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCNeutral
					elseif tReaction == "Friendly" then
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCFriendly
					elseif tReaction == "Player Ally" then
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCPlayerAlly
					elseif tReaction == "NPC Ally" then
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleRCNPCAlly
					end
				elseif RAEIH.SavedVars.ReticleAllianceMode == "Alliance Mode" then
					local tAlliance = GetUnitAlliance(uTag)
					if tAlliance == 3 then
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleDC
					elseif tAlliance == 2 then
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleEP
					elseif tAlliance == 1 then
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleAD
					else
						clrAlliance = "|c" .. RAEIH.SavedVars.ReticleNoAlliance
					end
				end
			end

			-- Get Basics
			tName = clrName .. GetUnitName(uTag)
			local tGender = GetUnitGender(uTag)
			local tRace = clrRace .. GetUnitRace(uTag)
			local tClass = clrClass .. GetUnitClass(uTag)

			local tCaption = GetUnitCaption(uTag)
			local tTitle = GetUnitTitle(uTag)

			local tAlliance = GetUnitAlliance(uTag)

			local tAvaRank = GetUnitAvARank(uTag)
			local tAvaRankName = GetAvARankName(tGender, tAvaRank)

			-- Get Attributes
			--tCH, tMH = GetUnitPower(uTag, -2) --P5ych3 - Does not work. Removed.
			tCH, tMH = GetUnitPower(uTag, POWERTYPE_HEALTH) --P5ych3 - Replacement current and max health variables.
			local tHPerc = RAEIH.Round(tCH / tMH * 100)
			local tCM, tMM = GetUnitPower(uTag, 0)
			local tMPerc = RAEIH.Round(tCM / tMM * 100)
			local tCS, tMS = GetUnitPower(uTag, 6)
			local tSPerc = RAEIH.Round(tCS / tMS * 100)

			if RAEIH.SavedVars.TSFormat == "Point (.)" then
				tCH = RAEIH.ThousandsSeparatorPoint(tCH)
				tMH = RAEIH.ThousandsSeparatorPoint(tMH)
				tHPerc = string.gsub(tostring(tHPerc), "%.", ",") .. "%"

				tCM = RAEIH.ThousandsSeparatorPoint(tCM)
				tMM = RAEIH.ThousandsSeparatorPoint(tMM)
				tMPerc = string.gsub(tostring(tMPerc), "%.", ",") .. "%"

				tCS = RAEIH.ThousandsSeparatorPoint(tCS)
				tMS = RAEIH.ThousandsSeparatorPoint(tMS)
				tSPerc = string.gsub(tostring(tSPerc), "%.", ",") .. "%"
			else
				tCH = RAEIH.ThousandsSeparatorComma(tCH)
				tMH = RAEIH.ThousandsSeparatorComma(tMH)
				tHPerc = tostring(tHPerc) .. "%"

				tCM = RAEIH.ThousandsSeparatorComma(tCM)
				tMM = RAEIH.ThousandsSeparatorComma(tMM)
				tMPerc = tostring(tMPerc) .. "%"

				tCS = RAEIH.ThousandsSeparatorComma(tCS)
				tMS = RAEIH.ThousandsSeparatorComma(tMS)
				tSPerc = tostring(tSPerc) .. "%"
			end

			-- Normalize Attributes
			local tHInfoExtended = clrDft .. "[" .. clrCHealth .. tCH .. clrDft .. "/" .. clrMHealth .. tMH .. clrDft .."] [" .. clrHPerc .. tHPerc .. clrDft .. "]"
			local tHInfoCurPerc = clrDft .. "[" .. clrCHealth .. tCH .. clrDft .. "] [" .. clrHPerc .. tHPerc .. clrDft .. "]"
			local tHInfoMaxPerc = clrDft .. "[" .. clrMHealth .. tMH .. clrDft .. "] [" .. clrHPerc .. tHPerc .. clrDft .. "]"
			local tHInfoPerc = clrDft .. "[" .. clrHPerc .. tHPerc .. clrDft .. "]"

			local tMInfoExtended = clrDft .. "[" .. tCM .. "/" .. tMM .. "] [" .. tMPerc .. "]"
			local tSInfoExtended = clrDft .. "[" .. tCS .. "/" .. tMS .. "] [" .. tSPerc .. "]"

			local thInfo = nil

			if RAEIH.SavedVars.ReticleHealthFormat == "[Current/Max] [%]" then
				thInfo = tHInfoExtended
			elseif RAEIH.SavedVars.ReticleHealthFormat == "[Current] [%]" then
				thInfo = tHInfoCurPerc
			elseif RAEIH.SavedVars.ReticleHealthFormat == "[Max] [%]" then
				thInfo = tHInfoMaxPerc
			elseif RAEIH.SavedVars.ReticleHealthFormat == "[%]" then
				thInfo = tHInfoPerc
			end

			-- Normalize Alliance
			if tAlliance == 3 then
				tAlliance = clrAlliance .. "Daggerfall Covenant"
			elseif tAlliance == 2 then
				tAlliance = clrAlliance .. "Ebonheart Pact"
			elseif tAlliance == 1 then
				tAlliance = clrAlliance .. "Aldmeri Dominion"
			else
				tAlliance = ""
			end

			-- Normalize Gender
			if tGender == 1 then
				tGender = clrGender .. "Female"
			elseif tGender == 2 then
				tGender = clrGender .. "Male"
			else
				tGender = ""
			end

			-- Normalize Title/Caption
			local tTICA = nil

			if tTitle ~= "" then
				tTICA = clrDft .. "«" .. clrTiCa .. tTitle .. clrDft .. "»"
			elseif tCaption ~= nil then
				tTICA = clrDft .. "«" .. clrTiCa .. tCaption .. clrDft .. "»"
			else
				tTICA = ""
			end

			-- Normalize AvA Rank Name
			if tAvaRankName == "" or tAvaRankName == nil then tAvaRankName = ""
			else
				tAvaRankName = clrDft .. "«" .. clrAvA .. tAvaRankName .. clrDft .. "» "
			end

			-- Get LVR
			local tLVR = nil

			if IsUnitVeteran(uTag) then
				tLVR = clrDft .. "[" .. clrLVR .. "CP" .. GetUnitVeteranRank(uTag) .. clrDft .. "]"
			else
				tLVR = clrDft .. "[" .. clrLVR .. "L" .. GetUnitLevel(uTag) .. clrDft .. "]"
			end

			-- Manage Label
			if RAEIH.SavedVars.ReticleFormat == "Extended" then
				if IsUnitPlayer(uTag) then
					RAEIH.ReticleText = tLVR .. " " .. tName .. " " .. thInfo .. "\n" .. tGender .. " " .. tRace .. " " .. tClass .. " " .. tTICA .. "\n" .. tAvaRankName .. tAlliance
				else
					RAEIH.ReticleText = tLVR .. " " .. tName .. " " .. thInfo .. "\n" .. tAlliance .. " " .. tTICA
				end
			elseif RAEIH.SavedVars.ReticleFormat == "Semi-Extended" then
				if IsUnitPlayer(uTag) then
					RAEIH.ReticleText = tLVR .. " " .. tName .. " " .. thInfo .. "\n" .. tRace .. " " .. tClass .. " " .. tTICA .. "\n" .. tAlliance
				else
					RAEIH.ReticleText = tLVR .. " " .. tName .. " " .. thInfo .. "\n" .. tAlliance .. " " .. tTICA
				end
			elseif RAEIH.SavedVars.ReticleFormat == "Normal" then
				if IsUnitPlayer(uTag) then
					RAEIH.ReticleText = tLVR .. " " .. tName .. " " .. thInfo .. "\n" .. tAlliance .. " " .. tTICA
				else
					RAEIH.ReticleText = tLVR .. " " .. tName .. " " .. thInfo .. "\n" .. tAlliance .. " " .. tTICA
				end
			elseif RAEIH.SavedVars.ReticleFormat == "Basics" then
				if IsUnitPlayer(uTag) then
					RAEIH.ReticleText = tLVR .. " " .. tName .. " " .. thInfo
				else
					RAEIH.ReticleText = tLVR .. " " .. tName .. " " .. thInfo .. "\n" .. tAlliance .. " " .. tTICA
				end
			end

			if RAEIH.SavedVars.ShowTargetInfo == false then RAEIH.ReticleText = "" end
			RAEIH_Reticle_String:SetText(RAEIH.ReticleText)
			RAEIH_Reticle:SetHidden(false)
		end
	end
end

function RAEIH.FormatReticle()

	local font = LMP:Fetch('font', RAEIH.SavedVars.ReticleFont)
	local size = RAEIH.SavedVars.ReticleFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.ReticleFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Reticle_String:SetFont(fontFormat)

end