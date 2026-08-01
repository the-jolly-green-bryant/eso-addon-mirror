------------------------------------------
--          Merlin the Enchanter        --
--               by Khrill              --
--                                      --
--                v 1.8.2              --
------------------------------------------
local KMTE = {}
KMTE.name  = "KhrillMerlinTheEnchanter"
KMTE.version = "1.8.2"
KMTE.isDebug = false

KMTE.BGTexturesLabel = {"Paper book", "Skin book", "Rubbing book"}
KMTE.BGTextures = {
	[1] = "/esoui/art/lorelibrary/lorelibrary_paperbook.dds", 
	[2] = "/esoui/art/lorelibrary/lorelibrary_skinbook.dds",
	[3] = "/esoui/art/lorelibrary/lorelibrary_rubbingbook.dds",
}
KMTE.defaults = {
	Enable = true,
	EnableButton = true,
	SavePosition = false,
	OffsetX = 0,
	OffsetY = 0,
	InfoMode = false,
	LabelMode = false,
	PotencyFirst = false,
	KeepQualityMode = false,
	BracketMode = true,
	XPMode = true,
	NewItem = true,
	LinkChat = false,
	EsoUiFade = true,
	MsgWindow = false,
	ItemSaver = true,
	FCOItemSaver = true,
	BG = 1,
	AllRunesMode = false,
}
KMTE.accountDefaults = {
	knownGlyph = {}, --[potencyId,essenceId,aspectId] = link glyph,
}
KMTE.settings = KMTE.defaults
KMTE.accountSettings = KMTE.accountDefaults

KMTE.Tooltip = nil
KMTE.langString = nil
KMTE.isStation = false
KMTE.mode = nil
KMTE.InfoMode = false
KMTE.LabelMode = false
KMTE.BagMode = true
KMTE.BankMode = true
KMTE.autoCraftRefreshNeeded = false
KMTE.autoCraftMode = 0
KMTE.autoCraftAll = false
KMTE.cancelCraft = false

local RUNE_MAIN = {}
local RUNE_OUTLINE = {}
local RUNE_ICON = {}
local RUNE_NUMBER = {}
local RUNE_TEXT = {}
-- Rune = { id, name, order, info, label, quality, icon, stack, glyph, known, bagId[], slotIndex[] }
-- typeRune = ("Essence", "PotencyAdditive", "PotencySubstrative", "Aspect")
-- typeGlyph = ("#Armor#", "#Weapon#", "#Jewel#")

-- ** New rune => add it into KMTE:CheckBag + KMTE:GetAllRunes

local TEXTURE_CLOSE = "/esoui/art/buttons/cancel_up.dds"
local TEXTURE_BAG = "/esoui/art/mainmenu/menubar_inventory_down.dds" --down.dds"
local TEXTURE_BANK = KMTE.name .. "/art/chest.dds" --"/esoui/art/mappins/minimap_bank.dds" --"/esoui/art/guild/guild_bankaccess.dds"
local TEXTURE_RELOAD = "/esoui/art/miscellaneous/rateicon.dds"
local TEXTURE_OUTLINE = KMTE.name .. "/art/gridItem_outline.dds"
local TEXTURE_RUNEUNKNOWN = "/esoui/art/icons/rune_a.dds" --"/esoui/art/crafting/enchantment_tabicon_potency_down.dds" --KMTE.name .. "/art/rune.dds"
local TEXTURE_RUNEPOTENCY = "/esoui/art/crafting/enchantment_tabicon_potency_down.dds"
local TEXTURE_RUNEESSENCE = "/esoui/art/crafting/enchantment_tabicon_essence_down.dds"
local TEXTURE_RUNEASPECT = "/esoui/art/crafting/enchantment_tabicon_aspect_down.dds"
local TEXTURE_GLYPH_ARMOR = "/esoui/art/icons/enchantment_armor_staminaboost.dds"
local TEXTURE_GLYPH_WEAPON = "/esoui/art/icons/enchantment_weapon_shockessence.dds"
local TEXTURE_GLYPH_JEWEL = "/esoui/art/icons/enchantment_jewelry_magickaregen.dds"
local COLOR_QUALITY = {}
COLOR_QUALITY[0] = "0A0A0A00" -- black
COLOR_QUALITY[1] = "0A0A0A00"
COLOR_QUALITY[2] = "267F00FF" -- green
COLOR_QUALITY[3] = "2655FFFF" -- blue
COLOR_QUALITY[4] = "8244FF00" -- purple
COLOR_QUALITY[5] = "FFD800FF" -- yellow
local COLOR_KHRILLSELECT = "FF6A00" -- orange ^^
local COLOR_DISABLED = "A0A0A0" -- gray
local COLOR_TITLE = "FF0000" --red
local COLOR_RUNEUNKNOWN = "FFFACDFF" --white
local COLOR_RUNENUMBER = "FFFACDFF"
KMTE.default_filter = {}
KMTE.default_filter["Armor"] = {value="#Armor"}
KMTE.default_filter["Weapon"] = {value="#Weapon"}
KMTE.default_filter["Jewel"] = {value="#Jewel"}
KMTE.default_rune = {}
KMTE.default_rune["Armor"] = {name = "Armor", icon = TEXTURE_GLYPH_ARMOR, stack = "", glyph = KMTE.default_filter["Armor"].value, quality=0, known=true}
KMTE.default_rune["Weapon"] = {name = "Weapon", icon = TEXTURE_GLYPH_WEAPON, stack = "", glyph = KMTE.default_filter["Weapon"].value, quality=0, known=true}
KMTE.default_rune["Jewel"] = {name = "Jewel", icon = TEXTURE_GLYPH_JEWEL, stack = "", glyph = KMTE.default_filter["Jewel"].value, quality=0, known=true}
KMTE_DB = KMTE_DB_Default

KMTE.activeAddon = { -- addons compatibility; is active
	itemSaver = false,
	FCOitemSaver = false,
	WeaponChargeAlert = false,
	GearSwap = false,
}
KMTE.itemSaverFilter    = false
KMTE.FCOitemSaverFilter = false

local LIBMW = LibStub:GetLibrary("LibMsgWin-1.0")
KMTE.MsgWindow = nil

-- // **********
-- // Functions
-- // **********
local function HexToRGBA( hex )
 	if string.len(hex) == 6 then hex = hex.."FF" end
	local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end
local function getKeyByValue(t, value)
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end
local function GetItemLinkID(link)
	if type(link) == "string" then
		local itemId = link:match("|H.-:.-:(.-):")
		if itemId ~= nil then
			return tonumber(itemId)
		end
	end
	return nil
end
local function msg(m)
	if KMTE.isDebug then d(m) end
end
function KMTE:addMsg(message)
	if KMTE.settings.MsgWindow then
		if KMTE.MsgWindow == nil then KMTE:CreateMsgWnd() end	
		KMTE.MsgWindow:SetHidden(false)
		KMTE.MsgWindow:AddText(message)
	else
		CHAT_SYSTEM:AddMessage(message)
	end
end

local function addButton(parent, name, callbackFunction, text, font, tooltipText, tooltipAlign, textureNormal, textureMouseOver, textureClicked, width, height, left, top, alignValue, alignControl, hideButton)
	--Add a button to an existing parent control
	--Abort needed?
	if  (parent == nil or name == nil or callbackFunction == nil
		or width <= 0 or height <= 0 )
		and (textureNormal == nil or text == nil) then
			return nil
	end
	local button
    --Does the button already exist?
    button = WINDOW_MANAGER:GetControlByName(name, "")
    if button == nil then
        --Button does not exist yet and it should be hidden? Abort here!
        if hideButton == true then return nil end
        --Create the button control at the parent
        button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    end
    --Button was created?
    if button ~= nil then
        --Button should be hidden?
        if hideButton == false then
            --Set the button's size
            button:SetDimensions(width, height)
            --Align the button
            if alignControl == nil then
                alignControl = parent
            end
            --SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
			if alignValue == nil then alignValue = TOPLEFT end
            button:SetAnchor(alignValue, alignControl, alignValue, left, top)
            --Texture or text?
            if (text ~= nil) then
                --Text
                --Set the button's font
                if font == nil then
                    button:SetFont("ZoFontGameSmall")
                else
                    button:SetFont(font)
                end
                --Set the button's text
                button:SetText(text)
            else
                --Texture
                local texture
 
                --Check if texture exists
                texture = WINDOW_MANAGER:GetControlByName(name .. "Texture", "")
                if texture == nil then
                    --Create the texture for the button to hold the image
                    texture = WINDOW_MANAGER:CreateControl(name .. "Texture", button, CT_TEXTURE)
                end
                texture:SetAnchorFill()
                --Set the texture for normale state now
                texture:SetTexture(textureNormal)
                --Do we have seperate textures for the button states?
                button.upTexture      = textureNormal
                button.downTexture    = textureMouseOver or textureNormal
                button.clickedTexture = textureClicked or textureNormal
            end
            if tooltipAlign == nil then tooltipAlign = TOP end
            --Set a tooltip?
            if tooltipText ~= nil then
                if button:GetHandler("OnMouseEnter") == nil then button:SetHandler("OnMouseEnter", function(self)
                    self:GetChild(1):SetTexture(self.downTexture)
                    ZO_Tooltips_ShowTextTooltip(button, tooltipAlign, tooltipText)
					end)
				end
                if button:GetHandler("OnMouseExit") == nil then button:SetHandler("OnMouseExit", function(self)
                    self:GetChild(1):SetTexture(self.upTexture)
                    ZO_Tooltips_HideTextTooltip()
					end)
				end
            else
                if button:GetHandler("OnMouseEnter") == nil then button:SetHandler("OnMouseEnter", function(self)
                    self:GetChild(1):SetTexture(self.downTexture)
					end)
				end
                if button:GetHandler("OnMouseExit") == nil then button:SetHandler("OnMouseExit", function(self)
                    self:GetChild(1):SetTexture(self.upTexture)
					end)
				end
            end
            --Set the callback function of the button
            if button:GetHandler("OnClicked") == nil then button:SetHandler("OnClicked", function(butn)
                callbackFunction()
				end)
			end
			if button:GetHandler("OnMouseDown") == nil then button:SetHandler("OnMouseDown", function(butn, ctrl, alt, shift, command)
				butn:GetChild(1):SetTexture(butn.clickedTexture)
				end)
			end
			--Show the button and make it react on mouse input
			button:SetHidden(false)
			button:SetMouseEnabled(true)
			--Return the button control
			return button
		else
			--Hide the button and make it not reacting on mouse input
			button:SetHidden(true)
			button:SetMouseEnabled(false)
		end
	else
		return nil
	end
end

local function getColorForBG(quality)
	-- return adequate color in function of BG texture
	-- rubbingbook (-> invert white with black)
	if quality == nil then quality = 0 end
	if KMTE.settings.BG == 3 and quality < 2 then 
		return COLOR_RUNEUNKNOWN
	else
		return COLOR_QUALITY[quality]
	end
end

local function getControl(control, namepart)
--	local maxChild = control:GetNumChildren()
--	d("--getControl=" ..control:GetName()..":"..maxChild.." search="..tostring(namepart))
	if control == nil or namepart == nil then return control end
	return control:GetNamedChild("_"..namepart)
end
local function getTextControl(control)
	-- // return the appropriate text in function of Info & Label modes
	local typeRune = control:GetParent().typeRune
	if (typeRune == "Essence" or typeRune == "PotencyAdditive" or typeRune == "PotencySubstrative" or typeRune == "Aspect") then
		if typeRune == "Essence" then
			local numText = 0
			if KMTE.selAdditive then
				numText = 1
			elseif KMTE.selSubstrative then
				numText = 2
			end
			if KMTE.InfoMode then
				return control.Info[numText]
			elseif KMTE.LabelMode then
				return control.Label[numText]
			else
				return control.RuneName
			end
		else
			if KMTE.InfoMode then
				return control.Info
			elseif KMTE.LabelMode then
				return control.Label
			else
				return control.RuneName
			end
		end
	else
		return control.RuneName
	end	
end
local function activeControl(control, state)
--	d("--ActiveControl="..control:GetName()..", "..tostring(state))
	if state then
		if control.Color ~= nil then
			if string.find(control:GetName(), "_Text") ~= nil and KMTE.settings.KeepQualityMode then
				if control.Quality ~= nil then
					control:SetColor(HexToRGBA(getColorForBG(control.Quality)))
					-- if KMTE.settings.BG == 3 and control.Quality < 2 then --rubbingbook (-> invert white with black)
						-- control:SetColor(HexToRGBA(COLOR_RUNEUNKNOWN))
					-- else
						-- control:SetColor(HexToRGBA(COLOR_QUALITY[control.Quality]))
					-- end
				end
				if control.RuneName ~= nil and KMTE.settings.BracketMode then control:SetText("|c"..COLOR_KHRILLSELECT.."[|r"..getTextControl(control).."|c"..COLOR_KHRILLSELECT.."]|r") end
			else
				control:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
			end
		end
		control:SetHidden(false)
	else
--		d("color="..control.Color)
		if control.Color ~= nil then control:SetColor(HexToRGBA(control.Color)) end
		if string.find(control:GetName(), "_Text") ~= nil and KMTE.settings.KeepQualityMode and control.RuneName ~= nil then control:SetText(getTextControl(control)) end
		control:SetHidden(control.Hidden)
	end
end
local function activeControlNumber(typeRune, state)
	local maxChild = KMTE.MainWindow:GetNumChildren()
	local i
	for i=1,maxChild do
		--d(KMTE.MainWindow:GetChild(i):GetName(), typeRune)
		if string.find(KMTE.MainWindow:GetChild(i):GetName(), "_"..typeRune) ~= nil then
--			d("--> active "..KMTE.MainWindow:GetChild(i):GetName())
			activeControl(getControl(KMTE.MainWindow:GetChild(i), "Number"), state) --nb
		end
	end
end
local function showControl(control, namepart, state)
		local selButton = getControl(control, namepart)
		if selButton ~= nil then selButton:SetHidden(not state) end		
end
local function selectControl(control, namepart, state)
	local selButton = getControl(control, namepart)
--d("--select "..selButton:GetName()..", "..tostring(state))
	if selButton ~= nil then activeControl(selButton, state) end
	local outline = getControl(selButton, "Outline")
	if outline ~= nil then activeControl(outline, state) end
	local text = getControl(selButton, "Text")
	if text ~= nil then activeControl(text, state) end
	local nb = getControl(selButton, "Number")
	if nb ~= nil then activeControl(nb, state) end
end
local function setTextControl(control, namepart, newContent)
	local selButton = getControl(control, namepart)
	local text = getControl(selButton, "Text")
	if text ~= nil then
		text:SetText(newContent)
		selButton:SetHidden(false)
	end
end
local function swapTextControl(button)
--	if button:IsHidden() then return end
	local text = getControl(button, "Text")
	if text ~= nil then
		if KMTE.InfoMode and button.typeRune == "Essence" then
			text:SetScale(0.7)
		elseif button.typeRune ~= "Aspect" and KMTE.LabelMode then
			text:SetScale(0.7)
		else
			text:SetScale(1)
		end
		-- check selected
		if getControl(button, "Outline"):IsControlHidden() or not KMTE.settings.BracketMode or not KMTE.settings.KeepQualityMode then
			text:SetText(getTextControl(text))
		else
			text:SetText("|c"..COLOR_KHRILLSELECT.."[|r"..getTextControl(text).."|c"..COLOR_KHRILLSELECT.."]|r")
		end
	end
end
local function swapAll()
--	d("--swapAll KMTE.InfoMode="..tostring(KMTE.InfoMode))
	local control = KMTE.MainWindow
	local namepart = ""
	local maxChild = control:GetNumChildren()

	selectControl(KMTE.MainWindow, "SwapRune", not KMTE.InfoMode and not KMTE.LabelMode)
	selectControl(KMTE.MainWindow, "SwapInfo", KMTE.InfoMode)
	selectControl(KMTE.MainWindow, "SwapLabel", KMTE.LabelMode)
	getControl(KMTE.MainWindow, "SwapRune_Text"):SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
	getControl(KMTE.MainWindow, "SwapInfo_Text"):SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
	getControl(KMTE.MainWindow, "SwapLabel_Text"):SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
	-- apply different style color for selected one (in function of BG texture)
	if KMTE.InfoMode then
		getControl(KMTE.MainWindow, "SwapInfo_Text"):SetStyleColor(HexToRGBA(getColorForBG())) --COLOR_QUALITY[0]))
	elseif KMTE.LabelMode then
		getControl(KMTE.MainWindow, "SwapLabel_Text"):SetStyleColor(HexToRGBA(getColorForBG()))
	else
		getControl(KMTE.MainWindow, "SwapRune_Text"):SetStyleColor(HexToRGBA(getColorForBG()))
	end
		
--	d("--getControl=" ..control:GetName()..":"..maxChild.." search="..tostring(namepart))
	for i=1,maxChild do
--		d(control:GetChild(i):GetName())
--		d(control:GetChild(i).typeRune)
		if control:GetChild(i).typeRune ~= nil then
			if control:GetChild(i).typeRune ~= "Glyph" and control:GetChild(i).typeRune ~= "Weapon" and control:GetChild(i).typeRune ~= "Armor" and control:GetChild(i).typeRune ~= "Jewel" then
--			d("-> change "..control:GetChild(i):GetName())
			swapTextControl(control:GetChild(i))
			end
		end
	end	
end
local function majNumberButton(button, newContent)
--	if not button:IsControlHidden() then
		local text = getControl(button, "Number")
		if text ~= nil then
			text:SetText(newContent)
		end
--	end
end
local function checkCreateGlyph()
	-- // check if create button & tooltip show or hide
	msg("--checkCreateGlyph ")
	if	KMTE_DB["count"]["Essence"].Selected ~= nil and KMTE_DB["count"]["Aspect"].Selected ~= nil then
		if KMTE_DB["count"]["PotencyAdditive"].Selected ~= nil or KMTE_DB["count"]["PotencySubstrative"].Selected ~= nil then
			--Check selected runes
			KMTE:checkObject("Essence", KMTE_DB["count"]["Essence"].Selected)
			if KMTE_DB["count"]["PotencyAdditive"].Selected ~= nil then KMTE:checkObject("PotencyAdditive", KMTE_DB["count"]["PotencyAdditive"].Selected) end
			if KMTE_DB["count"]["PotencySubstrative"].Selected ~= nil then KMTE:checkObject("PotencySubstrative", KMTE_DB["count"]["PotencySubstrative"].Selected) end
			KMTE:checkObject("Aspect", KMTE_DB["count"]["Aspect"].Selected)
			
			local msg = "|cFF6A00[" .. KMTE.name .. "]|r : "..KMTE.langString.KMTEMessage_error
			if KMTE_DB["count"]["Essence"].Selected.bagId[1] == nil or GetItemInstanceId(KMTE_DB["count"]["Essence"].Selected.bagId[1], KMTE_DB["count"]["Essence"].Selected.slotIndex[1]) == nil then
				msg = msg.."Essence. "
				if not KMTE.settings.AllRunesMode then msg = msg..KMTE.langString.KMTEMessage_retry end
				KMTE:addMsg(msg)
			elseif KMTE_DB["count"]["Aspect"].Selected.bagId[1] == nil or GetItemInstanceId(KMTE_DB["count"]["Aspect"].Selected.bagId[1], KMTE_DB["count"]["Aspect"].Selected.slotIndex[1]) == nil then
				msg = msg.."Aspect. "
				if not KMTE.settings.AllRunesMode then msg = msg..KMTE.langString.KMTEMessage_retry end
				KMTE:addMsg(msg)
			elseif KMTE_DB["count"]["PotencyAdditive"].Selected ~= nil and (KMTE_DB["count"]["PotencyAdditive"].Selected.bagId[1] == nil or GetItemInstanceId(KMTE_DB["count"]["PotencyAdditive"].Selected.bagId[1], KMTE_DB["count"]["PotencyAdditive"].Selected.slotIndex[1]) == nil) then
				msg = msg.."PotencyAdditive. "
				if not KMTE.settings.AllRunesMode then msg = msg..KMTE.langString.KMTEMessage_retry end
				KMTE:addMsg(msg)
			elseif KMTE_DB["count"]["PotencySubstrative"].Selected ~= nil and (KMTE_DB["count"]["PotencySubstrative"].Selected.bagId[1] == nil or GetItemInstanceId(KMTE_DB["count"]["PotencySubstrative"].Selected.bagId[1], KMTE_DB["count"]["PotencySubstrative"].Selected.slotIndex[1]) == nil) then
				msg = msg.."PotencySubstrative. "
				if not KMTE.settings.AllRunesMode then msg = msg..KMTE.langString.KMTEMessage_retry end
				KMTE:addMsg(msg)
			else
				-- rune selected -> add it to ESO UI
				if ENCHANTING.enchantingMode == ENCHANTING_MODE_CREATION then
					ENCHANTING:AddItemToCraft(KMTE_DB["count"]["Essence"].Selected.bagId[1], KMTE_DB["count"]["Essence"].Selected.slotIndex[1])
					local nbItem = KMTE_DB["count"]["Essence"].Selected.stack
					ENCHANTING:AddItemToCraft(KMTE_DB["count"]["Aspect"].Selected.bagId[1], KMTE_DB["count"]["Aspect"].Selected.slotIndex[1])
					if KMTE_DB["count"]["Aspect"].Selected.stack < nbItem then nbItem = KMTE_DB["count"]["Aspect"].Selected.stack end
					if KMTE_DB["count"]["PotencyAdditive"].Selected ~= nil then			
						ENCHANTING:AddItemToCraft(KMTE_DB["count"]["PotencyAdditive"].Selected.bagId[1], KMTE_DB["count"]["PotencyAdditive"].Selected.slotIndex[1])
						if KMTE_DB["count"]["PotencyAdditive"].Selected.stack < nbItem then nbItem = KMTE_DB["count"]["PotencyAdditive"].Selected.stack end
					else
						ENCHANTING:AddItemToCraft(KMTE_DB["count"]["PotencySubstrative"].Selected.bagId[1], KMTE_DB["count"]["PotencySubstrative"].Selected.slotIndex[1])
						if KMTE_DB["count"]["PotencySubstrative"].Selected.stack < nbItem then nbItem = KMTE_DB["count"]["PotencySubstrative"].Selected.stack end
					end

					local control = GetControl("KMTE_MainWindow_CreateSlider")
					control:SetMinMax(1, nbItem)
					control:SetValue(1)
					control:SetHidden(false)
					control.selText:SetText(1)
					control.maxText:SetText(nbItem)
					
					_G["ZO_EnchantingTopLevelRuneSlotContainer"]:SetAlpha(0.7)
				end
				--show button & slider & tooltip
				selectControl(KMTE.MainWindow, "CreateGlyph", true)
				KMTE:showTooltip(true)
				return -- exit
			end
		end
	end
	if ENCHANTING.enchantingMode == ENCHANTING_MODE_CREATION then ENCHANTING:ClearSelections() end
	_G["ZO_EnchantingTopLevelRuneSlotContainer"]:SetAlpha(0)
	selectControl(KMTE.MainWindow, "CreateGlyph", false)
	selectControl(KMTE.MainWindow, "CreateSlider", false)
	KMTE:showTooltip(false)
end

function KMTE:Reset()
	-- // reset vars & selections
	--d("--reset")
	KMTE_DB["count"]["Glyph"].Selected = nil
	KMTE.selButtonGlyph = nil
	KMTE.selAdditive = false
	KMTE.selSubstrative = false
	KMTE.autoCraftMode = 0
	KMTE.autoCraftRefreshNeeded = false
	-- glyph types
	selectControl(KMTE.MainWindow, "Glyph_Armor0", false)
	selectControl(KMTE.MainWindow, "Glyph_Weapon0", false)
	selectControl(KMTE.MainWindow, "Glyph_Jewel0", false)
	--glyph items
	if KMTE_DB["count"]["Armor"].Selected ~= nil then selectControl(KMTE.MainWindow, "Armor_"..KMTE_DB["count"]["Armor"].Selected.name..KMTE_DB["count"]["Armor"].Selected.quality, false) end
	if KMTE_DB["count"]["Weapon"].Selected ~= nil then selectControl(KMTE.MainWindow, "Weapon_"..KMTE_DB["count"]["Weapon"].Selected.name..KMTE_DB["count"]["Weapon"].Selected.quality, false) end
	if KMTE_DB["count"]["Jewel"].Selected ~= nil then selectControl(KMTE.MainWindow, "Jewel_"..KMTE_DB["count"]["Jewel"].Selected.name..KMTE_DB["count"]["Jewel"].Selected.quality, false) end
	KMTE_DB["count"]["Armor"].Selected = nil
	KMTE_DB["count"]["Weapon"].Selected = nil
	KMTE_DB["count"]["Jewel"].Selected = nil
	-- runes
	if KMTE_DB["count"]["Essence"].Selected ~= nil then selectControl(KMTE.MainWindow, "Essence_"..KMTE_DB["count"]["Essence"].Selected.name..KMTE_DB["count"]["Essence"].Selected.quality, false) end
	if KMTE_DB["count"]["PotencyAdditive"].Selected ~= nil then selectControl(KMTE.MainWindow, "PotencyAdditive_"..KMTE_DB["count"]["PotencyAdditive"].Selected.name..KMTE_DB["count"]["PotencyAdditive"].Selected.quality, false) end
	if KMTE_DB["count"]["PotencySubstrative"].Selected ~= nil then selectControl(KMTE.MainWindow, "PotencySubstrative_"..KMTE_DB["count"]["PotencySubstrative"].Selected.name..KMTE_DB["count"]["PotencySubstrative"].Selected.quality, false) end
	if KMTE_DB["count"]["Aspect"].Selected ~= nil then selectControl(KMTE.MainWindow, "Aspect_"..KMTE_DB["count"]["Aspect"].Selected.name..KMTE_DB["count"]["Aspect"].Selected.quality, false) end
	KMTE_DB["count"]["Essence"].Selected = nil
	KMTE_DB["count"]["PotencyAdditive"].Selected = nil
	KMTE_DB["count"]["PotencySubstrative"].Selected = nil
	KMTE_DB["count"]["Aspect"].Selected = nil
	-- swap button
	showControl(KMTE.MainWindow, "SwapRune", false)
	showControl(KMTE.MainWindow, "SwapInfo", false)
	showControl(KMTE.MainWindow, "SwapLabel", false)
end

function KMTE:showTooltip(state)
--d("--showTooltip "..tostring(state))
	local tooltip = KMTE.Tooltip
	if KMTE.settings.LinkChat then CHAT_SYSTEM:GetEditControl():SetText() end
	if state then
		-- retrieve link with runes info
		local potencyRuneBagId
		local potencyRuneSlotIndex
		local essenceRuneBagId
		local essenceRuneSlotIndex
		local id = nil
		local link = nil
		if KMTE_DB["count"]["PotencyAdditive"].Selected ~= nil then
			potencyRuneBagId = KMTE_DB["count"]["PotencyAdditive"].Selected.bagId[1]
			potencyRuneSlotIndex = KMTE_DB["count"]["PotencyAdditive"].Selected.slotIndex[1]
			id = KMTE_DB["count"]["PotencyAdditive"].Selected.id
		elseif KMTE_DB["count"]["PotencySubstrative"].Selected ~= nil then
			potencyRuneBagId = KMTE_DB["count"]["PotencySubstrative"].Selected.bagId[1]
			potencyRuneSlotIndex = KMTE_DB["count"]["PotencySubstrative"].Selected.slotIndex[1]
			id = KMTE_DB["count"]["PotencySubstrative"].Selected.id
		end
		if id ~= nil and KMTE_DB["count"]["Essence"].Selected ~= nil then
			essenceRuneBagId = KMTE_DB["count"]["Essence"].Selected.bagId[1]
			essenceRuneSlotIndex = KMTE_DB["count"]["Essence"].Selected.slotIndex[1]
			id = id .."," ..KMTE_DB["count"]["Essence"].Selected.id
		else id = nil
		end
		if id ~= nil and KMTE_DB["count"]["Aspect"].Selected ~= nil then
			local aspectRuneBagId = KMTE_DB["count"]["Aspect"].Selected.bagId[1]
			local aspectRuneSlotIndex = KMTE_DB["count"]["Aspect"].Selected.slotIndex[1]
			id = id .."," ..KMTE_DB["count"]["Aspect"].Selected.id
			--		local name, icon, stack, sellPrice, meetsUsageRequirement, quality  = GetEnchantingResultingItemInfo(potencyRuneBagId, potencyRuneSlotIndex, essenceRuneBagId, essenceRuneSlotIndex, aspectRuneBagId, aspectRuneSlotIndex)
			local linkStyle = LINK_STYLE_DEFAULT	--LINK_STYLE_BRACKETS ITEM_LINK_TYPE 
			link = GetEnchantingResultingItemLink(potencyRuneBagId, potencyRuneSlotIndex, essenceRuneBagId, essenceRuneSlotIndex, aspectRuneBagId, aspectRuneSlotIndex, linkStyle)
		else id = nil
		end
		-- Tooltip
		if link ~= nil and GetItemLinkID(link) ~= nil then
			-- save link into savevars
			if KMTE.accountSettings.knownGlyph[id] == nil then KMTE.accountSettings.knownGlyph[id] = link end
			-- tooltip
			InitializeTooltip(tooltip)
			tooltip:SetLink(link)
			-- add link to chat
			if KMTE.settings.LinkChat then CHAT_SYSTEM:GetEditControl():SetText("["..link.."]") end
		elseif id ~= nil and KMTE.accountSettings.knownGlyph[id] ~= nil then
			-- test if tooltip exists in savedvars
			-- tooltip
			InitializeTooltip(tooltip)
			tooltip:SetLink(KMTE.accountSettings.knownGlyph[id])
		else	
			-- exit, not shown because empty (not known)
			KMTE:addMsg("|cFF6A00[" .. KMTE.name .. "]|r : "..KMTE.langString.KMTEMessage_unknownGlyph)
			state = false
		end
	end
	tooltip:SetHidden(not state)
end
function KMTE:showDestroyTooltip(rune, state)
	local tooltip = getControl(KMTE_MainWindow, "DestroyTooltip")
	--d("--showDestroyTooltip "..tostring(state))
	if state then
		-- retrieve link
		local glyphBagId = rune.bagId[1]
		local glyphSlotIndex = rune.slotIndex[1]
		local linkStyle = LINK_STYLE_DEFAULT	--LINK_STYLE_BRACKETS ITEM_LINK_TYPE 
		local link = GetItemLink(glyphBagId, glyphSlotIndex, linkStyle)

		-- Tooltip
		if link ~= nil then
			InitializeTooltip(tooltip)
			tooltip:SetLink(link)
		end
	end
	tooltip:SetHidden(not state)
end

function KMTE:ifExistRune(typeRune, name, quality)
	-- // for rune already known
	if KMTE_DB["count"][typeRune] ~= nil then
		for i=1, KMTE_DB["count"][typeRune].Max do
			if KMTE_DB[typeRune][i] and KMTE_DB[typeRune][i].name == name and KMTE_DB[typeRune][i].quality == quality then return i end
		end
	end
	-- not found
	return 0
end
function KMTE:ifExistRune(typeRune, itemId)
	-- // for rune already known
	if KMTE_DB["count"][typeRune] ~= nil then
		for i=1, KMTE_DB["count"][typeRune].Max do
			if KMTE_DB[typeRune][i] and KMTE_DB[typeRune][i].id == itemId then return i end
		end
	end
	-- not found
	return 0
end
function KMTE:findNext(bagId, itemId, excludeSlotIndex)
	-- // find the next position glyph in the bag, else 0
	--local bagIcon, bagSlots = GetBagInfo(bagId) --v1.2
	local bagSlots = GetBagSize(bagId) --v1.3
--	d("--findNext "..bagId.."="..bagSlots)
	
	local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
	while slotIndex do
--	for slotIndex = 0, bagSlots do
		if slotIndex ~= excludeSlotIndex then
			local itemId2test = GetItemLinkID(GetItemLink(bagId, slotIndex))
			if itemId == itemId2test then
--				d("-> return "..slotIndex)
				return slotIndex
			end
		end
		slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
	end
	return 0
end

function KMTE:KnownRune(typeRune, typeGlyph, order, id, name, info, label, quality, icon, stack, bagId, slotIndex)
	--add rune info to the DB
	local rune = {id = nil, name = nil, order = nil, info = nil, label = nil, quality = 0, icon = nil, stack = 0, glyph = nil, known = nil, bagId = {}, slotIndex = {}}
	if quality == nil then quality = 0 end
	local pos =   KMTE:ifExistRune(typeRune, id)
--	local pos =   KMTE:ifExistRune(typeRune, name, quality)
--	d("--KnownRune: "..typeRune..", "..order..", "..name..","..id..", pos="..pos..", stack="..stack)
	if pos == 0 then
		-- new
		rune.id = id
		rune.name = name
		rune.order = order
		rune.info = info
		rune.label = label
		rune.quality = quality
		rune.icon = icon
		rune.stack = stack
		rune.glyph = typeGlyph
		if bagId ~= nil and slotIndex ~= nil then
			rune.known = (GetRunestoneTranslatedName(bagId, slotIndex) ~= nil or typeRune == "Armor" or typeRune == "Weapon" or typeRune == "Jewel")
			rune.bagId = {bagId}
			rune.slotIndex = {slotIndex}
		end
--		d("add "..tostring(rune.bagId[1])..","..tostring(rune.slotIndex[1]).." "..tostring(rune.bagId[2])..","..tostring(rune.slotIndex[2]))
		KMTE_DB["count"][typeRune].Max = KMTE_DB["count"][typeRune].Max +1
		KMTE_DB[typeRune][KMTE_DB["count"][typeRune].Max] = rune
	else
		-- one exist in other bag, save this slot
		table.insert(KMTE_DB[typeRune][pos].bagId, bagId)
		table.insert(KMTE_DB[typeRune][pos].slotIndex, slotIndex)
--		d("maj "..tostring(KMTE_DB[typeRune][pos].bagId[1])..","..tostring(KMTE_DB[typeRune][pos].slotIndex[1]).." "..tostring(KMTE_DB[typeRune][pos].bagId[2])..","..tostring(KMTE_DB[typeRune][pos].slotIndex[2]))
		KMTE_DB[typeRune][pos].stack = KMTE_DB[typeRune][pos].stack + stack
		if KMTE_DB[typeRune][pos].known == nil and bagId ~= nil and slotIndex ~= nil then
			KMTE_DB[typeRune][pos].known = (GetRunestoneTranslatedName(bagId, slotIndex) ~= nil or typeRune == "Armor" or typeRune == "Weapon" or typeRune == "Jewel")
			KMTE_DB[typeRune][pos].icon = icon
			KMTE_DB[typeRune][pos].quality = quality
		end
	end
end
function KMTE:RemoveRune(typeRune, Rune)
	if KMTE_DB["count"][typeRune].Selected ~= nil and KMTE_DB["count"][typeRune].Selected.name == Rune.name then KMTE_DB["count"][typeRune].Selected = nil end
	local pos = KMTE:ifExistRune(typeRune, Rune.id)
--	local pos = KMTE:ifExistRune(typeRune, Rune.name, Rune.quality)
	if pos > 0 then KMTE_DB[typeRune][pos] = nil end
	KMTE:RemoveButtonUI(typeRune, Rune)	
end

function KMTE:CheckBag(bagId)
	KMTE:CheckBag(bagId, nil)
end
function KMTE:CheckBag(bagId, typeRune)
	-- bagId = BAG_BACKPACK or BAG_BANK or BAG_VIRTUAL
	local bagSlots = GetBagSize(bagId)
--	d("--bag "..bagId.."="..bagSlots)

	-- Check for ItemSaver&FCOItemSaver addons
	KMTE:CheckforOtherAddons()

	local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
	while slotIndex do
--	for slotIndex = 0, bagSlots do
		local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagId, slotIndex))
		local itemId = GetItemLinkID(GetItemLink(bagId, slotIndex))
--		local itemTranslate = GetRunestoneTranslatedName(bagId, slotIndex)  --GetItemCraftingInfo(bagId, slotIndex)
		local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality  = GetItemInfo(bagId, slotIndex) 
		local itemType = GetItemType(bagId, slotIndex)
		local isCheck = true
--		local runeKnonwn = (itemTranslate ~= nil)

		if KMTE.itemSaverFilter and ItemSaver_IsItemSaved(bagId, slotIndex) == true then
			-- itemSaver check
			isCheck = false
		elseif KMTE.FCOitemSaverFilter and FCOIsMarked(GetItemInstanceId(bagId, slotIndex), -1) == true then
--		elseif KMTE.FCOitemSaverFilter and FCOIsFiltered(GetItemInstanceId(bagId, slotIndex), -1) == true then
			-- FCOitemSaver check
			isCheck = false
		elseif typeRune ~= nil then
			-- typeRune filter
			isCheck = (typeRune == "AWJ") --false
			if itemType == ITEMTYPE_GLYPH_ARMOR and typeRune == "Armor" then isCheck = true end
			if itemType == ITEMTYPE_GLYPH_WEAPON and typeRune == "Weapon" then isCheck = true end
			if itemType == ITEMTYPE_GLYPH_JEWELRY and typeRune == "Jewel" then isCheck = true end

			if itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE and typeRune == "Essence" then isCheck = true end
			if itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT and typeRune == "Aspect" then isCheck = true end
			if itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY and (typeRune == "PotencyAdditive" or typeRune == "PotencySubstrative") then isCheck = true end
--			d("--check typeRune "..typeRune..": "..itemType .." "..itemName .." "..quality)
--			d(isCheck)
		end
--if itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY then
--		d(itemName,itemId)
--		d(GetItemInfo(bagId, slotIndex))
--end

		if meetsUsageRequirement and isCheck then
		-- // Glyphs
			if itemType == ITEMTYPE_GLYPH_ARMOR then
				KMTE:KnownRune("Armor", "#ArmorAdd#ArmorSub#", 0, itemId, itemName, nil, nil, quality, icon, stack, bagId, slotIndex)
			elseif itemType == ITEMTYPE_GLYPH_WEAPON then
				KMTE:KnownRune("Weapon", "#WeaponAdd#WeaponSub#", 0, itemId, itemName, nil, nil, quality, icon, stack, bagId, slotIndex)
			elseif itemType == ITEMTYPE_GLYPH_JEWELRY then
				KMTE:KnownRune("Jewel", "#JewelAdd#JewelSub#", 0, itemId, itemName, nil, nil, quality, icon, stack, bagId, slotIndex)
			end
			
			-- // Runes
			-- ESSENCE Runes
			if itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE then
			-- Armor Glyphs = + Makko + Oko + Deni + Hakeijo
			-- Weapon Glyphs = + Dekeipa + Deteri + Haoko + Kuoko + Meip + Okori + Rakeipa - Makko - Oko - Deni - Okoma - Okori - Deteri - Hakeijo
			-- Jewel Glyphs = + Denima + Kaderi + Makderi + Makkoma + Okoma + Oru + Taderi - Dekeipa - Denima - Haoko - Kuoko - Kaderi - Makderi - Makkoma - Meip - Oru  - Rakeipa - Taderi

				if (itemId == 45839) then --(itemName == "Dekeïpa^F") then
					KMTE:KnownRune("Essence", "#WeaponAdd#JewelSub#", 1, itemId, itemName, KMTE.langString.KMTERune_Essence_Dekeipa_Info, KMTE.langString.KMTERune_Essence_Dekeipa_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45833) then --(itemName == "Deni^F") then
					KMTE:KnownRune("Essence", "#ArmorAdd#WeaponSub#", 2, itemId, itemName, KMTE.langString.KMTERune_Essence_Deni_Info, KMTE.langString.KMTERune_Essence_Deni_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45836) then --(itemName == "Denima^F") then
					KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 3, itemId, itemName, KMTE.langString.KMTERune_Essence_Denima_Info, KMTE.langString.KMTERune_Essence_Denima_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45842) then --(itemName == "Deteri^F") then
					KMTE:KnownRune("Essence", "#WeaponAdd#WeaponSub#", 4, itemId, itemName, KMTE.langString.KMTERune_Essence_Deteri_Info, KMTE.langString.KMTERune_Essence_Deteri_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45841) then --(itemName == "Haoko^F") then
					KMTE:KnownRune("Essence","#WeaponAdd#JewelSub#", 5, itemId, itemName, KMTE.langString.KMTERune_Essence_Haoko_Info, KMTE.langString.KMTERune_Essence_Haoko_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45849) then --(itemName == "Kadéri^F") then
					KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 6, itemId, itemName, KMTE.langString.KMTERune_Essence_Kaderi_Info, KMTE.langString.KMTERune_Essence_Kaderi_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45837) then --(itemName == "Kuoko^F") then
					KMTE:KnownRune("Essence", "#WeaponAdd#JewelSub#", 7, itemId, itemName, KMTE.langString.KMTERune_Essence_Kuoko_Info, KMTE.langString.KMTERune_Essence_Kuoko_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45848) then --(itemName == "Makdéri^F") then
					KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 8, itemId, itemName, KMTE.langString.KMTERune_Essence_Makderi_Info, KMTE.langString.KMTERune_Essence_Makderi_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45832) then --(itemName == "Makko^F") then
					KMTE:KnownRune("Essence", "#ArmorAdd#WeaponSub#", 9, itemId, itemName, KMTE.langString.KMTERune_Essence_Makko_Info, KMTE.langString.KMTERune_Essence_Makko_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45835) then --(itemName == "Makkoma^F") then
					KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 10, itemId, itemName, KMTE.langString.KMTERune_Essence_Makkoma_Info, KMTE.langString.KMTERune_Essence_Makkoma_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45840) then --(itemName == "Méip^F") then
					KMTE:KnownRune("Essence", "#WeaponAdd#JewelSub#", 11, itemId, itemName, KMTE.langString.KMTERune_Essence_Meip_Info, KMTE.langString.KMTERune_Essence_Meip_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45831) then --(itemName == "Oko^F") then
					KMTE:KnownRune("Essence", "#ArmorAdd#WeaponSub#", 12, itemId, itemName, KMTE.langString.KMTERune_Essence_Oko_Info, KMTE.langString.KMTERune_Essence_Oko_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45834) then --(itemName == "Okoma^F") then
					KMTE:KnownRune("Essence", "#WeaponSub#JewelAdd#", 13, itemId, itemName, KMTE.langString.KMTERune_Essence_Okoma_Info, KMTE.langString.KMTERune_Essence_Okoma_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45843) then --(itemName == "Okori^F") then
					KMTE:KnownRune("Essence", "#WeaponAdd#WeaponSub#", 14, itemId, itemName, KMTE.langString.KMTERune_Essence_Okori_Info, KMTE.langString.KMTERune_Essence_Okori_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45846) then --(itemName == "Oru^F") then
					KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 15, itemId, itemName, KMTE.langString.KMTERune_Essence_Oru_Info, KMTE.langString.KMTERune_Essence_Oru_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45838) then --(itemName == "Rakeïpa^F") then
					KMTE:KnownRune("Essence", "#WeaponAdd#JewelSub#", 16, itemId, itemName, KMTE.langString.KMTERune_Essence_Rakeipa_Info, KMTE.langString.KMTERune_Essence_Rakeipa_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45847) then --(itemName == "Taderi^F") then
					KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 17, itemId, itemName, KMTE.langString.KMTERune_Essence_Taderi_Info, KMTE.langString.KMTERune_Essence_Taderi_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 68342) then --(itemName == "Hakeijo^F") then
					KMTE:KnownRune("Essence", "#ArmorAdd#WeaponSub#", 18, itemId, itemName, KMTE.langString.KMTERune_Essence_Hakeijo_Info, KMTE.langString.KMTERune_Essence_Hakeijo_Label, quality, icon, stack, bagId, slotIndex)
				end
			end
			
			-- ASPECT Runes
			if itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT then
				if (itemId == 45850) then --(itemName == "Ta^F") then
					KMTE:KnownRune("Aspect", "#ArmorAdd#WeaponAdd#JewelAdd#ArmorSub#WeaponSub#JewelSub#", 1, itemId, itemName, KMTE.langString.KMTERune_Aspect_Ta_Info, KMTE.langString.KMTERune_Aspect_Ta_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45851) then --(itemName == "Jéjota^F") then
					KMTE:KnownRune("Aspect", "#ArmorAdd#WeaponAdd#JewelAdd#ArmorSub#WeaponSub#JewelSub#", 2, itemId, itemName, KMTE.langString.KMTERune_Aspect_Jejota_Info, KMTE.langString.KMTERune_Aspect_Jejota_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45852) then --(itemName == "Denata^F") then
					KMTE:KnownRune("Aspect", "#ArmorAdd#WeaponAdd#JewelAdd#ArmorSub#WeaponSub#JewelSub#", 3, itemId, itemName, KMTE.langString.KMTERune_Aspect_Denata_Info, KMTE.langString.KMTERune_Aspect_Denata_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45853) then --(itemName == "Rekuta^F") then
					KMTE:KnownRune("Aspect", "#ArmorAdd#WeaponAdd#JewelAdd#ArmorSub#WeaponSub#JewelSub#", 4, itemId, itemName, KMTE.langString.KMTERune_Aspect_Rekuta_Info, KMTE.langString.KMTERune_Aspect_Rekuta_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45854) then --(itemName == "Kuta^F") then
					KMTE:KnownRune("Aspect", "#ArmorAdd#WeaponAdd#JewelAdd#ArmorSub#WeaponSub#JewelSub#", 5, itemId, itemName, KMTE.langString.KMTERune_Aspect_Kuta_Info, KMTE.langString.KMTERune_Aspect_Kuta_Label, quality, icon, stack, bagId, slotIndex)
				end
			end
			
			-- POTENCY Runes
			if itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY then
				--Additive Potency Runes
				if (itemId == 45855) then --(itemName == "Jora^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 1, itemId, itemName, KMTE.langString.KMTERune_Potency_Jora_Info, KMTE.langString.KMTERune_Potency_Jora_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45856) then --(itemName == "Porade^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 2, itemId, itemName, KMTE.langString.KMTERune_Potency_Porade_Info, KMTE.langString.KMTERune_Potency_Porade_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45857) then --(itemName == "Jéra^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 3, itemId, itemName, KMTE.langString.KMTERune_Potency_Jera_Info, KMTE.langString.KMTERune_Potency_Jera_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45806) then --(itemName == "Jéjora^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 4, itemId, itemName, KMTE.langString.KMTERune_Potency_Jejora_Info, KMTE.langString.KMTERune_Potency_Jejora_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45807) then --(itemName == "Odra^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 5, itemId, itemName, KMTE.langString.KMTERune_Potency_Odra_Info, KMTE.langString.KMTERune_Potency_Odra_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45808) then --(itemName == "Pojora^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 6, itemId, itemName, KMTE.langString.KMTERune_Potency_Pojora_Info, KMTE.langString.KMTERune_Potency_Pojora_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45809) then --(itemName == "Edora^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 7, itemId, itemName, KMTE.langString.KMTERune_Potency_Edora_Info, KMTE.langString.KMTERune_Potency_Edora_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45810) then --(itemName == "Jaera^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 8, itemId, itemName, KMTE.langString.KMTERune_Potency_Jaera_Info, KMTE.langString.KMTERune_Potency_Jaera_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45811) then --(itemName == "Pora^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 9, itemId, itemName, KMTE.langString.KMTERune_Potency_Pora_Info, KMTE.langString.KMTERune_Potency_Pora_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45812) then --(itemName == "Dénara^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 10, itemId, itemName, KMTE.langString.KMTERune_Potency_Denara_Info, KMTE.langString.KMTERune_Potency_Denara_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45813) then --(itemName == "Réra^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 11, itemId, itemName, KMTE.langString.KMTERune_Potency_Rera_Info, KMTE.langString.KMTERune_Potency_Rera_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45814) then --(itemName == "Dérado^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 12, itemId, itemName, KMTE.langString.KMTERune_Potency_Derado_Info, KMTE.langString.KMTERune_Potency_Derado_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45815) then --(itemName == "Récura^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 13, itemId, itemName, KMTE.langString.KMTERune_Potency_Recura_Info, KMTE.langString.KMTERune_Potency_Recura_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45816) then --(itemName == "Kura^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 14, itemId, itemName, KMTE.langString.KMTERune_Potency_Cura_Info, KMTE.langString.KMTERune_Potency_Cura_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 64509) then --(itemName == "Rejera^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 15, itemId, itemName, KMTE.langString.KMTERune_Potency_Rejera_Info, KMTE.langString.KMTERune_Potency_Rejera_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 68341) then --(itemName == "Repora^F") then
					KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 16, itemId, itemName, KMTE.langString.KMTERune_Potency_Repora_Info, KMTE.langString.KMTERune_Potency_Repora_Label, quality, icon, stack, bagId, slotIndex)
				end

				--Subtrative Potency Runes
				if (itemId == 45817) then --if(itemName == "Jode^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 1, itemId, itemName, KMTE.langString.KMTERune_Potency_Jode_Info, KMTE.langString.KMTERune_Potency_Jode_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45818) then --if(itemName == "Notade^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 2, itemId, itemName, KMTE.langString.KMTERune_Potency_Notade_Info, KMTE.langString.KMTERune_Potency_Notade_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45819) then --if(itemName == "Ode^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 3, itemId, itemName, KMTE.langString.KMTERune_Potency_Ode_Info, KMTE.langString.KMTERune_Potency_Ode_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45820) then --if(itemName == "Tade^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 4, itemId, itemName, KMTE.langString.KMTERune_Potency_Tade_Info, KMTE.langString.KMTERune_Potency_Tade_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45821) then --if(itemName == "Jayde^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 5, itemId, itemName, KMTE.langString.KMTERune_Potency_Jayde_Info, KMTE.langString.KMTERune_Potency_Jayde_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45822) then --if(itemName == "Edode^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 6, itemId, itemName, KMTE.langString.KMTERune_Potency_Edode_Info, KMTE.langString.KMTERune_Potency_Edode_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45823) then --if(itemName == "Pjode^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 7, itemId, itemName, KMTE.langString.KMTERune_Potency_Pjode_Info, KMTE.langString.KMTERune_Potency_Pjode_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45824) then --if(itemName == "Rekudé^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 8, itemId, itemName, KMTE.langString.KMTERune_Potency_Rekude_Info, KMTE.langString.KMTERune_Potency_Rekude_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45825) then --if(itemName == "Hade^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 9, itemId, itemName, KMTE.langString.KMTERune_Potency_Hade_Info, KMTE.langString.KMTERune_Potency_Hade_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45826) then --if(itemName == "Idode^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 10, itemId, itemName, KMTE.langString.KMTERune_Potency_Idode_Info, KMTE.langString.KMTERune_Potency_Idode_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45827) then --if(itemName == "Pode^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 11, itemId, itemName, KMTE.langString.KMTERune_Potency_Pode_Info, KMTE.langString.KMTERune_Potency_Pode_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45828) then --if(itemName == "Kédéko^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 12, itemId, itemName, KMTE.langString.KMTERune_Potency_Kedeko_Info, KMTE.langString.KMTERune_Potency_Kedeko_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45829) then --if(itemName == "Rede^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 13, itemId, itemName, KMTE.langString.KMTERune_Potency_Rede_Info, KMTE.langString.KMTERune_Potency_Rede_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 45830) then --if(itemName == "Kudé^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 14, itemId, itemName, KMTE.langString.KMTERune_Potency_Kude_Info, KMTE.langString.KMTERune_Potency_Kude_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 64508) then --if(itemName == "Jehade^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 15, itemId, itemName, KMTE.langString.KMTERune_Potency_Jehade_Info, KMTE.langString.KMTERune_Potency_Jehade_Label, quality, icon, stack, bagId, slotIndex)
				elseif (itemId == 68340) then --if(itemName == "Itade^F") then
					KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 16, itemId, itemName, KMTE.langString.KMTERune_Potency_Itade_Info, KMTE.langString.KMTERune_Potency_Itade_Label, quality, icon, stack, bagId, slotIndex)
				end	
			end
		end
		slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
	end
end

function KMTE:ClearBag(typeRune)
	if typeRune == nil then
		--all
		--d("--clearbag all")
--		KMTE_DB = nothing
--		KMTE:Reset()
--		KMTE_DB = KMTE.resetRunes --KMTE_DB_Default
		KMTE.selAdditive = false
		KMTE.selSubstrative = false
		KMTE_DB["count"] = {
			["Glyph"] = {
			Max = 0,
			Selected = nil
			},
			["Armor"] = {
			Max = 0,
	--		Selected = nil
			},
			["Weapon"] = {
			Max = 0,
	--		Selected = nil
			},
			["Jewel"] = {
			Max = 0,
	--		Selected = nil
			},

			["Essence"] = {
			Max = 0,
	--		Selected = nil
			},
			["PotencyAdditive"] = {
			Max = 0,
	--		Selected = nil
			},
			["PotencySubstrative"] = {
			Max = 0,
	--		Selected = nil
			},
			["Aspect"] = {
			Max = 0,
	--		Selected = nil
			}
		}
		KMTE_DB["Glyph"] = {}
		KMTE_DB["Armor"] = {}
		KMTE_DB["Weapon"] = {}
		KMTE_DB["Jewel"] = {}
		KMTE_DB["Essence"] = {}
		KMTE_DB["PotencyAdditive"] = {}
		KMTE_DB["PotencySubstrative"] = {}
		KMTE_DB["Aspect"] = {}		
	else
		-- only 1 typeRune
--		KMTE_DB["count"][typeRune].Selected = nil
		KMTE_DB["count"][typeRune].Max = 0
		KMTE_DB[typeRune] = {}		
	end
end

function KMTE:ScanRunes(typeRune)
	-- // Scan bag&bank and memorize runes
	local selButton = nil
	local Selected = KMTE_DB["count"]["Glyph"].Selected
	--	local typeRune = nil
--	d("--scanrunes "..tostring(Selected)..","..tostring(KMTE.settings.AllRunesMode))
	
	if Selected == nil then
		KMTE:ScanAllGlyph()
		if KMTE.settings.AllRunesMode then KMTE:GetAllRunes() end
	else
--		if KMTE.autoCraftRefreshNeeded then typeRune = KMTE_DB["count"]["Glyph"].Selected.name end
--		d(typeRune)
		if typeRune == nil then
			--all
			KMTE:ClearBag(nil)
			KMTE:CleanRuneUI()
			if KMTE.settings.AllRunesMode then KMTE:GetAllRunes() end
			if KMTE.BagMode then
				KMTE:CheckBag(BAG_BACKPACK)
				if HasCraftBagAccess() then KMTE:CheckBag(BAG_VIRTUAL) end
			end
			if KMTE.BankMode then KMTE:CheckBag(BAG_BANK) end
			if Selected ~= nil then
--				d("selected "..Selected.name)
	--			d(KMTE.selButtonGlyph)
				KMTE_DB["count"]["Glyph"].Selected = nil
				selButton = getControl(KMTE.MainWindow, "Glyph_"..Selected.name..Selected.quality)
				if selButton ~= nil then KMTE:SelectRune(selButton) end
			end
		else
--			d("only "..typeRune)
			KMTE:ClearBag(typeRune)
			KMTE:CleanRuneUI(typeRune)
			if KMTE.settings.AllRunesMode then KMTE:GetAllRunes(typeRune) end
			if KMTE.BagMode then
				KMTE:CheckBag(BAG_BACKPACK, typeRune)
				if HasCraftBagAccess() then KMTE:CheckBag(BAG_VIRTUAL, typeRune) end
			end
			if KMTE.BankMode then KMTE:CheckBag(BAG_BANK, typeRune) end
--			d(KMTE_DB["count"][typeRune].Selected)
			KMTE:printRunes(typeRune, KMTE_DB["count"][typeRune].Max, KMTE_DB["count"]["Glyph"].Selected.glyph)
			if (typeRune=="Armor" or typeRune=="Weapon" or typeRune=="Jewel") and KMTE_DB["count"][typeRune].Selected == nil then
				activeControlNumber(typeRune, true)
				setTextControl(KMTE.MainWindow, "DestroyGlyph", KMTE.langString.KMTESettings_glyph_destroyall)
			else
				if KMTE_DB["count"][typeRune].Selected ~= nil then selectControl(KMTE.MainWindow, typeRune.."_"..KMTE_DB["count"][typeRune].Selected.name..KMTE_DB["count"][typeRune].Selected.quality, true) end
			end
		end
	end
	--d("--end scan")
end
function KMTE:ScanAllGlyph()
	-- for printing all glyphs
	KMTE:Reset()
	KMTE:ClearBag(nil)
	KMTE:CleanRuneUI()
	if KMTE.BagMode then
		KMTE:CheckBag(BAG_BACKPACK, "AWJ")
		if HasCraftBagAccess() then KMTE:CheckBag(BAG_VIRTUAL, "AWJ") end
	end
	if KMTE.BankMode then KMTE:CheckBag(BAG_BANK, "AWJ") end
	KMTE:printRunes("Armor", KMTE_DB["count"]["Armor"].Max, KMTE.default_filter["Armor"].value)
	KMTE:printRunes("Weapon", KMTE_DB["count"]["Weapon"].Max, KMTE.default_filter["Weapon"].value)
	KMTE:printRunes("Jewel", KMTE_DB["count"]["Jewel"].Max, KMTE.default_filter["Jewel"].value)
	activeControlNumber("Armor", true)	
	activeControlNumber("Weapon", true)	
	activeControlNumber("Jewel", true)	
	setTextControl(KMTE.MainWindow, "DestroyGlyph", KMTE.langString.KMTESettings_glyph_destroyall)
	KMTE:showDestroyTooltip(nil, false)
end
function KMTE:GetAllRunes(typeRune)
--d("--GetAllRunes ") --.. tostring(typeRune))
	-- // Runes
	-- Armor Glyphs = + Makko + Oko + Deni + Hakeijo
	-- Weapon Glyphs = + Dekeipa + Deteri + Haoko + Kuoko + Meip + Okori + Rakeipa - Makko - Oko - Deni - Okoma - Okori - Deteri - Hakeijo
	-- Jewel Glyphs = + Denima + Kaderi + Makderi + Makkoma + Okoma + Oru + Taderi - Dekeipa - Denima - Haoko - Kuoko - Kaderi - Makderi - Makkoma - Meip - Oru  - Rakeipa - Taderi

	-- ESSENCE Runes
	local itemType = ITEMTYPE_ENCHANTING_RUNE_ESSENCE
	local icon = TEXTURE_RUNEESSENCE
	local quality = 0
	if typeRune == nil or typeRune == "Essence" then
		KMTE:KnownRune("Essence", "#WeaponAdd#JewelSub#", 1, 45839, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Dekeïpa^F"), KMTE.langString.KMTERune_Essence_Dekeipa_Info, KMTE.langString.KMTERune_Essence_Dekeipa_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#ArmorAdd#WeaponSub#", 2, 45833, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Deni^F"), KMTE.langString.KMTERune_Essence_Deni_Info, KMTE.langString.KMTERune_Essence_Deni_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 3, 45836, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Denima^F"), KMTE.langString.KMTERune_Essence_Denima_Info, KMTE.langString.KMTERune_Essence_Denima_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#WeaponAdd#WeaponSub#", 4, 45842, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Deteri^F"), KMTE.langString.KMTERune_Essence_Deteri_Info, KMTE.langString.KMTERune_Essence_Deteri_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#WeaponAdd#JewelSub#", 5, 45841, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Haoko^F"), KMTE.langString.KMTERune_Essence_Haoko_Info, KMTE.langString.KMTERune_Essence_Haoko_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 6, 45849, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Kadéri^F"), KMTE.langString.KMTERune_Essence_Kaderi_Info, KMTE.langString.KMTERune_Essence_Kaderi_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#WeaponAdd#JewelSub#", 7, 45837, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Kuoko^F"), KMTE.langString.KMTERune_Essence_Kuoko_Info, KMTE.langString.KMTERune_Essence_Kuoko_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 8, 45848, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Makdéri^F"), KMTE.langString.KMTERune_Essence_Makderi_Info, KMTE.langString.KMTERune_Essence_Makderi_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#ArmorAdd#WeaponSub#", 9, 45832, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Makko^F"), KMTE.langString.KMTERune_Essence_Makko_Info, KMTE.langString.KMTERune_Essence_Makko_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 10, 45835, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Makkoma^F"), KMTE.langString.KMTERune_Essence_Makkoma_Info, KMTE.langString.KMTERune_Essence_Makkoma_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#WeaponAdd#JewelSub#", 11, 45840, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Méip^F"), KMTE.langString.KMTERune_Essence_Meip_Info, KMTE.langString.KMTERune_Essence_Meip_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#ArmorAdd#WeaponSub#", 12, 45831, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Oko^F"), KMTE.langString.KMTERune_Essence_Oko_Info, KMTE.langString.KMTERune_Essence_Oko_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#WeaponSub#JewelAdd#", 13, 45834, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Okoma^F"), KMTE.langString.KMTERune_Essence_Okoma_Info, KMTE.langString.KMTERune_Essence_Okoma_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#WeaponAdd#WeaponSub#", 14, 45843, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Okori^F"), KMTE.langString.KMTERune_Essence_Okori_Info, KMTE.langString.KMTERune_Essence_Okori_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 15, 45846, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Oru^F"), KMTE.langString.KMTERune_Essence_Oru_Info, KMTE.langString.KMTERune_Essence_Oru_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#WeaponAdd#JewelSub#", 16, 45838, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Rakeïpa^F"), KMTE.langString.KMTERune_Essence_Rakeipa_Info, KMTE.langString.KMTERune_Essence_Rakeipa_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#JewelAdd#JewelSub#", 17, 45847, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Taderi^F"), KMTE.langString.KMTERune_Essence_Taderi_Info, KMTE.langString.KMTERune_Essence_Taderi_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("Essence", "#ArmorAdd#WeaponSub#", 18, 68342, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Hakeijo^F"), KMTE.langString.KMTERune_Essence_Hakeijo_Info, KMTE.langString.KMTERune_Essence_Hakeijo_Label, quality, icon, 0, nil, nil)
	end
	
	-- ASPECT Runes
	if typeRune == nil or typeRune == "Aspect" then
		itemType = ITEMTYPE_ENCHANTING_RUNE_ASPECT
		icon = TEXTURE_RUNEASPECT
		quality = 0
		KMTE:KnownRune("Aspect", "#ArmorAdd#WeaponAdd#JewelAdd#ArmorSub#WeaponSub#JewelSub#", 1, 45850, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Ta^F"), KMTE.langString.KMTERune_Aspect_Ta_Info, KMTE.langString.KMTERune_Aspect_Ta_Label, quality, icon, 0, nil, nil)
--		quality = 2
		KMTE:KnownRune("Aspect", "#ArmorAdd#WeaponAdd#JewelAdd#ArmorSub#WeaponSub#JewelSub#", 2, 45851, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Jéjota^F"), KMTE.langString.KMTERune_Aspect_Jejota_Info, KMTE.langString.KMTERune_Aspect_Jejota_Label, quality, icon, 0, nil, nil)
--		quality = 3
		KMTE:KnownRune("Aspect", "#ArmorAdd#WeaponAdd#JewelAdd#ArmorSub#WeaponSub#JewelSub#", 3, 45852, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Denata^F"), KMTE.langString.KMTERune_Aspect_Denata_Info, KMTE.langString.KMTERune_Aspect_Denata_Label, quality, icon, 0, nil, nil)
--		quality = 4
		KMTE:KnownRune("Aspect", "#ArmorAdd#WeaponAdd#JewelAdd#ArmorSub#WeaponSub#JewelSub#", 4, 45853, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Rekuta^F"), KMTE.langString.KMTERune_Aspect_Rekuta_Info, KMTE.langString.KMTERune_Aspect_Rekuta_Label, quality, icon, 0, nil, nil)
--		quality = 5
		KMTE:KnownRune("Aspect", "#ArmorAdd#WeaponAdd#JewelAdd#ArmorSub#WeaponSub#JewelSub#", 5, 45854, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Kuta^F"), KMTE.langString.KMTERune_Aspect_Kuta_Info, KMTE.langString.KMTERune_Aspect_Kuta_Label, quality, icon, 0, nil, nil)
	end
	
	-- POTENCY Runes
	itemType = ITEMTYPE_ENCHANTING_RUNE_POTENCY
	icon = TEXTURE_RUNEPOTENCY
	quality = 0
	if typeRune == nil or typeRune == "PotencyAdditive" or typeRune == "Potency" then
		--Additive Potency Runes
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 1, 45855, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Jora^F"), KMTE.langString.KMTERune_Potency_Jora_Info, KMTE.langString.KMTERune_Potency_Jora_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 2, 45856, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Porade^F"), KMTE.langString.KMTERune_Potency_Porade_Info, KMTE.langString.KMTERune_Potency_Porade_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 3, 45857, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Jéra^F"), KMTE.langString.KMTERune_Potency_Jera_Info, KMTE.langString.KMTERune_Potency_Jera_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 4, 45806, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Jéjora^F"), KMTE.langString.KMTERune_Potency_Jejora_Info, KMTE.langString.KMTERune_Potency_Jejora_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 5, 45807, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Odra^F"), KMTE.langString.KMTERune_Potency_Odra_Info, KMTE.langString.KMTERune_Potency_Odra_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 6, 45808, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Pojora^F"), KMTE.langString.KMTERune_Potency_Pojora_Info, KMTE.langString.KMTERune_Potency_Pojora_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 7, 45809, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Edora^F"), KMTE.langString.KMTERune_Potency_Edora_Info, KMTE.langString.KMTERune_Potency_Edora_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 8, 45810, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Jaera^F"), KMTE.langString.KMTERune_Potency_Jaera_Info, KMTE.langString.KMTERune_Potency_Jaera_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 9, 45811, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Pora^F"), KMTE.langString.KMTERune_Potency_Pora_Info, KMTE.langString.KMTERune_Potency_Pora_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 10, 45812, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Dénara^F"), KMTE.langString.KMTERune_Potency_Denara_Info, KMTE.langString.KMTERune_Potency_Denara_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 11, 45813, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Réra^F"), KMTE.langString.KMTERune_Potency_Rera_Info, KMTE.langString.KMTERune_Potency_Rera_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 12, 45814, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Dérado^F"), KMTE.langString.KMTERune_Potency_Derado_Info, KMTE.langString.KMTERune_Potency_Derado_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 13, 45815, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Récura^F"), KMTE.langString.KMTERune_Potency_Recura_Info, KMTE.langString.KMTERune_Potency_Recura_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 14, 45816, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Kura^F"), KMTE.langString.KMTERune_Potency_Cura_Info, KMTE.langString.KMTERune_Potency_Cura_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 15, 64509, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Rejera^F"), KMTE.langString.KMTERune_Potency_Rejera_Info, KMTE.langString.KMTERune_Potency_Rejera_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencyAdditive", "#ArmorAdd#WeaponAdd#JewelAdd#", 16, 68341, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Repora^F"), KMTE.langString.KMTERune_Potency_Repora_Info, KMTE.langString.KMTERune_Potency_Repora_Label, quality, icon, 0, nil, nil)
	end
	if typeRune == nil or typeRune == "PotencySubstrative" or typeRune == "Potency" then
		--Subtrative Potency Runes
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 1, 45817, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Jode^F"), KMTE.langString.KMTERune_Potency_Jode_Info, KMTE.langString.KMTERune_Potency_Jode_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 2, 45818, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Notade^F"), KMTE.langString.KMTERune_Potency_Notade_Info, KMTE.langString.KMTERune_Potency_Notade_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 3, 45819, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Ode^F"), KMTE.langString.KMTERune_Potency_Ode_Info, KMTE.langString.KMTERune_Potency_Ode_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 4, 45820, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Tade^F"), KMTE.langString.KMTERune_Potency_Tade_Info, KMTE.langString.KMTERune_Potency_Tade_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 5, 45821, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Jayde^F"), KMTE.langString.KMTERune_Potency_Jayde_Info, KMTE.langString.KMTERune_Potency_Jayde_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 6, 45822, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Edode^F"), KMTE.langString.KMTERune_Potency_Edode_Info, KMTE.langString.KMTERune_Potency_Edode_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 7, 45823, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Pjode^F"), KMTE.langString.KMTERune_Potency_Pjode_Info, KMTE.langString.KMTERune_Potency_Pjode_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 8, 45824, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Rekudé^F"), KMTE.langString.KMTERune_Potency_Rekude_Info, KMTE.langString.KMTERune_Potency_Rekude_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 9, 45825, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Hade^F"), KMTE.langString.KMTERune_Potency_Hade_Info, KMTE.langString.KMTERune_Potency_Hade_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 10, 45826, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Idode^F"), KMTE.langString.KMTERune_Potency_Idode_Info, KMTE.langString.KMTERune_Potency_Idode_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 11, 45827, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Pode^F"), KMTE.langString.KMTERune_Potency_Pode_Info, KMTE.langString.KMTERune_Potency_Pode_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 12, 45828, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Kédéko^F"), KMTE.langString.KMTERune_Potency_Kedeko_Info, KMTE.langString.KMTERune_Potency_Kedeko_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 13, 45829, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Rede^F"), KMTE.langString.KMTERune_Potency_Rede_Info, KMTE.langString.KMTERune_Potency_Rede_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 14, 45830, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Kudé^F"), KMTE.langString.KMTERune_Potency_Kude_Info, KMTE.langString.KMTERune_Potency_Kude_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 15, 64508, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Jehade^F"), KMTE.langString.KMTERune_Potency_Jehade_Info, KMTE.langString.KMTERune_Potency_Jehade_Label, quality, icon, 0, nil, nil)
		KMTE:KnownRune("PotencySubstrative", "#WeaponSub#JewelSub#", 16, 68340, zo_strformat(SI_TOOLTIP_ITEM_NAME, "Itade^F"), KMTE.langString.KMTERune_Potency_Itade_Info, KMTE.langString.KMTERune_Potency_Itade_Label, quality, icon, 0, nil, nil)
	end
end

function KMTE:printRunes(typeRune, maxRune, glyphFilter)
	-- maj ui
	local start
	if KMTE.settings.PotencyFirst then
		-- order = potency + & - , essence, aspect
		if typeRune == "Essence" then
			start = 18*2
		elseif typeRune == "PotencyAdditive" then
			start=1
			if not KMTE.selAdditive then glyphFilter = KMTE.default_filter[KMTE_DB["count"]["Glyph"].Selected.name].value end
		elseif typeRune == "PotencySubstrative" then
			start=18
			if not KMTE.selSubstrative then glyphFilter = KMTE.default_filter[KMTE_DB["count"]["Glyph"].Selected.name].value end
		end
	else
		-- order (original) = essence, potency + & - , aspect
		if typeRune == "Essence" then
			start = 1
		elseif typeRune == "PotencyAdditive" then
			start=18
			if not KMTE.selAdditive then glyphFilter = KMTE.default_filter[KMTE_DB["count"]["Glyph"].Selected.name].value end
		elseif typeRune == "PotencySubstrative" then
			start=18*2
			if not KMTE.selSubstrative then glyphFilter = KMTE.default_filter[KMTE_DB["count"]["Glyph"].Selected.name].value end
		end
	end
	if typeRune == "Aspect" then start=18*3 end
	
	if typeRune == "Armor" then start=1 end
	if typeRune == "Weapon" then start=18 end
	if typeRune == "Jewel" then start=18*2 end
--	d("--printRunes="..typeRune..", "..maxRune..", start="..start)
--	d("glyphFilter="..glyphFilter)
	local calStart = start
	-- order first
	local tempOrder = {}
	local runeOrder = { rune = nil, order = 0, glyph = nil }
	local maxOrder = 0
	local rune2test, runeswap
	for i=start,(maxRune+start-1) do
		tempOrder[maxOrder+1] = {}
		rune2test = {}
		runeswap = {}
--		d(KMTE_DB[typeRune][i-start+1])
--		d(KMTE_DB[typeRune][i-start+1].name..", "..KMTE_DB[typeRune][i-start+1].glyph.." -> " ..tostring(string.find(KMTE_DB[typeRune][i-start+1].glyph, glyphFilter)))
		if KMTE_DB[typeRune][i-start+1] and string.find(KMTE_DB[typeRune][i-start+1].glyph, glyphFilter) ~= nil and (KMTE_DB[typeRune][i-start+1].stack > 0 or KMTE.settings.AllRunesMode) then
			rune2test = {rune=KMTE_DB[typeRune][i-start+1], order=KMTE_DB[typeRune][i-start+1].order, glyph=KMTE_DB[typeRune][i-start+1].glyph}
			for j=1,maxOrder do
				if rune2test.order >= tempOrder[j].order then
					--next
				else
					--swap
					--d("swap "..j.." ="..rune2test.rune.name.." <-> "..tempOrder[j].rune.name)
					runeswap = {rune = tempOrder[j].rune, order = tempOrder[j].order, glyph = tempOrder[j].glyph}
					tempOrder[j] = {rune = rune2test.rune, order = rune2test.order, glyph = rune2test.glyph}
					rune2test = {rune = runeswap.rune, order = runeswap.order, glyph = runeswap.glyph}
					--isDone = true
				end
			end
--			d("--insert "..tostring(maxOrder+1).." : " .. rune2test.rune.name .. ","..rune2test.order.. ","..tostring(rune2test.rune.quality))
			tempOrder[maxOrder+1] = {rune = rune2test.rune, order = rune2test.order, glyph = rune2test.glyph}
			maxOrder = maxOrder +1
		end
	end
	-- create rune in UI
	for i=1,maxOrder do
		KMTE:CreateRuneUI(typeRune, calStart, tempOrder[i].rune)
		calStart = calStart +1
	end
end
function KMTE:checkSelectedRunes()
	KMTE:checkSelectedRune("Essence")
	KMTE:checkSelectedRune("PotencyAdditive")
	KMTE:checkSelectedRune("PotencySubstrative")
	KMTE:checkSelectedRune("Aspect")
	if KMTE_DB["count"]["Glyph"].Selected ~= nil then KMTE:checkSelectedRune(KMTE_DB["count"]["Glyph"].Selected.name) end
end
function KMTE:checkSelectedRune(typeRune)
	-- // check if selected rune already visible with glyph type; if not => deselect it
	local state
	if KMTE_DB["count"][typeRune].Selected ~= nil then
		state = not getControl(KMTE.MainWindow,typeRune.."_"..KMTE_DB["count"][typeRune].Selected.name..KMTE_DB["count"][typeRune].Selected.quality):IsControlHidden()
		selectControl(KMTE.MainWindow,typeRune.."_"..KMTE_DB["count"][typeRune].Selected.name..KMTE_DB["count"][typeRune].Selected.quality,state)
		showControl(KMTE.MainWindow,typeRune.."_"..KMTE_DB["count"][typeRune].Selected.name..KMTE_DB["count"][typeRune].Selected.quality,state)
		if not state then KMTE_DB["count"][typeRune].Selected = nil end
	end
end
function KMTE:checkObject(typeRune, rune)
	-- // Check if object (glyph/rune) is available & refresh; if not switch the index/hide control
	local pos, i, sumStack, stack
	if rune ~= nil then
		msg("--checkObject:"..typeRune .." "..rune.name.." "..rune.quality.." (id"..rune.id..")")
		-- find rune
		pos = KMTE:ifExistRune(typeRune, rune.id)
--		pos = KMTE:ifExistRune(typeRune, rune.name, rune.quality)
		if pos > 0 then
			-- check all slot & recount stack
			i = 1
			sumStack = 0
			while KMTE_DB[typeRune][pos].bagId[i] ~= nil do
				stack = nil
				local itemId = GetItemLinkID(GetItemLink(KMTE_DB[typeRune][pos].bagId[i], KMTE_DB[typeRune][pos].slotIndex[i]))
				msg("Id="..tostring(itemId))
				if itemId == nil or itemId ~= rune.id then
					msg("!remove table pos "..i.." for "..KMTE_DB[typeRune][pos].bagId[i] ..", "..KMTE_DB[typeRune][pos].slotIndex[i])
					table.remove(KMTE_DB[typeRune][pos].bagId, i)
					table.remove(KMTE_DB[typeRune][pos].slotIndex, i)
				else
					msg(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(KMTE_DB[typeRune][pos].bagId[i], KMTE_DB[typeRune][pos].slotIndex[i])))
		--			_, stack, _, _, _, _, _, quality  = GetItemInfo(rune.bagId[i], rune.slotIndex[i])
					stack, _ = GetSlotStackSize(KMTE_DB[typeRune][pos].bagId[i], KMTE_DB[typeRune][pos].slotIndex[i])  
					msg("pos "..i..":"..tostring(KMTE_DB[typeRune][pos].bagId[i])..","..tostring(KMTE_DB[typeRune][pos].slotIndex[i]).." = "..tostring(stack))
					i = i +1
				end
				if stack ~= nil then sumStack = sumStack + stack end
			end
			msg("-> total="..sumStack)
			
			if sumStack == 0 and (typeRune == "Armor" or typeRune == "Weapon" or typeRune == "Jewel") then
				KMTE:RemoveRune(typeRune, rune)
				KMTE:showDestroyTooltip(nil, false)
			elseif sumStack == 0 and not KMTE.settings.AllRunesMode then
				KMTE:RemoveRune(typeRune, rune)
			else
				KMTE_DB[typeRune][pos].stack = sumStack
--				d("majNumber "..typeRune.."_"..rune.name..rune.quality..", stack="..sumStack)
				majNumberButton(getControl(KMTE.MainWindow, typeRune.."_"..rune.name..rune.quality), sumStack)

				-- update Selected if needed
				if KMTE_DB["count"][typeRune].Selected ~= nil and KMTE_DB["count"][typeRune].Selected.name == rune.name and KMTE_DB["count"][typeRune].Selected.quality == rune.quality then
					KMTE_DB["count"][typeRune].Selected = KMTE_DB[typeRune][pos]
				end
			end
		end
	end
end

function KMTE:deselectRune(typeRune)
	-- // deselect selected rune
	local state = false
	if KMTE_DB["count"][typeRune].Selected ~= nil then
		selectControl(KMTE.MainWindow,typeRune.."_"..KMTE_DB["count"][typeRune].Selected.name..KMTE_DB["count"][typeRune].Selected.quality,state)
		KMTE_DB["count"][typeRune].Selected = nil
		if typeRune == "Armor" or typeRune == "Weapon" or typeRune == "Jewel" then
			KMTE:showDestroyTooltip(nil, false)
		else
			KMTE:showTooltip(false)
		end
	end
end

-- // **********
-- //   OnClick
-- // **********
local function SelectRune(button)
	-- onclick function
	KMTE:SelectRune(button)
end
function KMTE:SelectRune(button)
	-- // Click on one rune or glyph
	local selButton
	local outline
	local text
--	d("--SelectRune="..button:GetName())
--	d("--typeRune="..button.typeRune)
--	d("--Rune.name="..button.Rune.name)
	-- rune already selected in the same typeRune => deselect it
	if KMTE_DB["count"][button.typeRune].Selected ~= nil then
--		d("--deselect="..KMTE_DB["count"][button.typeRune].Selected.name)
		selectControl(KMTE.MainWindow, button.typeRune.."_"..KMTE_DB["count"][button.typeRune].Selected.name..KMTE_DB["count"][button.typeRune].Selected.quality, false)
		-- if select is the same => deselect the same
		if KMTE_DB["count"][button.typeRune].Selected.name == button.Rune.name and KMTE_DB["count"][button.typeRune].Selected.quality == button.Rune.quality then
			KMTE_DB["count"][button.typeRune].Selected = nil
			-- if Potency => set glyph filter to default
			if button.typeRune == "PotencyAdditive" or button.typeRune == "PotencySubstrative" then
				if button.typeRune == "PotencyAdditive" then KMTE.selAdditive = false end
				if button.typeRune == "PotencySubstrative" then KMTE.selSubstrative = false end
				--reselect selected glyph for refresh
				local oldname = KMTE_DB["count"]["Glyph"].Selected.name..KMTE_DB["count"]["Glyph"].Selected.quality
				KMTE_DB["count"]["Glyph"].Selected = nil
				KMTE:SelectRune(getControl(KMTE.MainWindow, "Glyph_"..oldname))			
			end
			if button.typeRune == "Glyph" then
				KMTE:Reset()
				KMTE:CleanRuneUI()
				KMTE:ScanAllGlyph()
				if KMTE.settings.AllRunesMode then KMTE:GetAllRunes() end
			end
			-- if glyph item, change destroybutton text & tooltip
			if button.typeRune == "Armor" or button.typeRune == "Weapon" or button.typeRune == "Jewel" then
				activeControlNumber(button.typeRune, true)	
				setTextControl(KMTE.MainWindow, "DestroyGlyph", KMTE.langString.KMTESettings_glyph_destroyall)
				KMTE:showDestroyTooltip(nil, false)
			end
			-- state of createbutton
			checkCreateGlyph()
			-- => exit
			return
		end

		--if select Glyph Type => deselect previous glyphes item
		if button.typeRune == "Glyph" then
			if KMTE_DB["count"][KMTE_DB["count"]["Glyph"].Selected.name].Selected ~=nil then
--				d("->deselect "..KMTE_DB["count"]["Glyph"].Selected.name..", "..KMTE_DB["count"][KMTE_DB["count"]["Glyph"].Selected.name].Selected.name)
				selectControl(KMTE.MainWindow, KMTE_DB["count"]["Glyph"].Selected.name.."_"..KMTE_DB["count"][KMTE_DB["count"]["Glyph"].Selected.name].Selected.name..KMTE_DB["count"][KMTE_DB["count"]["Glyph"].Selected.name].Selected.quality, false)
				KMTE_DB["count"][KMTE_DB["count"]["Glyph"].Selected.name].Selected = nil				
			end
			if button.Rune.name == "Armor" and KMTE_DB["count"]["PotencySubstrative"].Selected ~= nil then
				-- unselected substractive Potency
				selectControl(KMTE.MainWindow, "PotencySubstrative_"..KMTE_DB["count"]["PotencySubstrative"].Selected.name..KMTE_DB["count"]["PotencySubstrative"].Selected.quality, false)
				KMTE_DB["count"]["PotencySubstrative"].Selected = nil	
				KMTE.selSubstrative = false
			end
		end
	else
		if button.typeRune == "Armor" or button.typeRune == "Weapon" or button.typeRune == "Jewel" then
			activeControlNumber(button.typeRune, false)	
		end
	end
	
	-- If glyph item and not glyph type selected => select type
	if KMTE_DB["count"]["Glyph"].Selected == nil and (button.typeRune == "Armor" or button.typeRune == "Weapon" or button.typeRune == "Jewel") then
--		d("-> select glyph "..button.typeRune.."0")
		KMTE:SelectRune(getControl(KMTE.MainWindow, "Glyph_"..button.typeRune.."0"))
	end
	
	-- => select it (change outline and text color)
	selectControl(button, nil, true)
	if button.typeRune == "Glyph" then
		button.Rune.glyph = KMTE.default_filter[button.Rune.name].value
		if KMTE.selAdditive then button.Rune.glyph = KMTE.default_filter[button.Rune.name].value.."Add" end
		if KMTE.selSubstrative then button.Rune.glyph = KMTE.default_filter[button.Rune.name].value.."Sub" end
--		d("--filter="..button.Rune.glyph)
	end
	KMTE_DB["count"][button.typeRune].Selected = button.Rune
	
	-- If glyph type => print Runes & Glyphs items
	if button.typeRune == "Glyph" then
		-- print availables
		KMTE:CleanRuneUI()
		KMTE:printRunes("Essence", KMTE_DB["count"]["Essence"].Max, button.Rune.glyph)
		KMTE:printRunes("PotencyAdditive", KMTE_DB["count"]["PotencyAdditive"].Max, button.Rune.glyph)
		KMTE:printRunes("PotencySubstrative", KMTE_DB["count"]["PotencySubstrative"].Max, button.Rune.glyph)
		KMTE:printRunes("Aspect", KMTE_DB["count"]["Aspect"].Max, button.Rune.glyph)
		KMTE:printRunes(button.Rune.name, KMTE_DB["count"][button.Rune.name].Max, button.Rune.glyph)
		KMTE.selButtonGlyph = button
		--print button and texts
		if	KMTE_DB["count"]["Glyph"].Selected ~= nil then
			if KMTE_DB["count"][KMTE_DB["count"]["Glyph"].Selected.name].Selected ~= nil then
				setTextControl(KMTE.MainWindow, "DestroyGlyph", KMTE.langString.KMTESettings_glyph_destroy)
				KMTE:showDestroyTooltip(KMTE_DB["count"][KMTE_DB["count"]["Glyph"].Selected.name].Selected, true)
			else
				--active all glyph number & text destroy button
				activeControlNumber(button.Rune.name, true)
				setTextControl(KMTE.MainWindow, "DestroyGlyph", KMTE.langString.KMTESettings_glyph_destroyall)
			end
		end
		showControl(KMTE.MainWindow,"RuneEssence",true)
		showControl(KMTE.MainWindow,"RunePotency",true)
		showControl(KMTE.MainWindow,"RuneAspect",true)
		selectControl(KMTE.MainWindow,"RunePotencyAdd",KMTE.selAdditive)
		if not KMTE.selAdditive then showControl(KMTE.MainWindow,"RunePotencyAdd",true) end
		selectControl(KMTE.MainWindow,"RunePotencySub",KMTE.selSubstrative)
		if not KMTE.selSubstrative then showControl(KMTE.MainWindow,"RunePotencySub",true) end
		showControl(KMTE.MainWindow,"SwapRune",true)
		showControl(KMTE.MainWindow,"SwapInfo",true)
		showControl(KMTE.MainWindow,"SwapLabel",true)
		swapAll()
		KMTE:checkSelectedRunes()
	else
		-- If glyph item => change destroyButton text and show tooltip
		if button.typeRune == "Armor" or button.typeRune == "Weapon" or button.typeRune == "Jewel" then
			if KMTE.isStation then
				ZO_MenuBar_SelectDescriptor(ZO_EnchantingTopLevelModeMenuBar, ENCHANTING_MODE_EXTRACTION)
				ENCHANTING:AddItemToCraft(button.Rune.bagId[1], button.Rune.slotIndex[1])
				_G["ZO_EnchantingTopLevelTooltip"]:SetAlpha(0)
			end
			setTextControl(KMTE.MainWindow, "DestroyGlyph", KMTE.langString.KMTESettings_glyph_destroy)
			KMTE:showDestroyTooltip(button.Rune, true)
		else
			-- rune selected
			if KMTE.isStation then
				ZO_MenuBar_SelectDescriptor(ZO_EnchantingTopLevelModeMenuBar, ENCHANTING_MODE_CREATION)
				if KMTE_DB["count"]["Glyph"].Selected ~= nil then
--					KMTE:deselectRune(KMTE_DB["count"]["Glyph"].Selected.name)
--					setTextControl(KMTE.MainWindow, "DestroyGlyph", KMTE.langString.KMTESettings_glyph_destroyall)
				end
			end
			if button.typeRune == "PotencyAdditive" or button.typeRune == "PotencySubstrative" then
				--add +/- to filter
				KMTE.selAdditive = (button.typeRune == "PotencyAdditive")
				if not KMTE.selAdditive then KMTE_DB["count"]["PotencyAdditive"].Selected = nil end
				KMTE.selSubstrative = (button.typeRune == "PotencySubstrative")
				if not KMTE.selSubstrative then KMTE_DB["count"]["PotencySubstrative"].Selected = nil end
				--reselect selected glyph for refresh
				local oldname = KMTE_DB["count"]["Glyph"].Selected.name..KMTE_DB["count"]["Glyph"].Selected.quality
--				d(oldname)
				KMTE_DB["count"]["Glyph"].Selected = nil
				KMTE:SelectRune(getControl(KMTE.MainWindow, "Glyph_"..oldname))
			end	
		end
	end

	-- if Essence, Potency and Aspect Runes selected => activate create button
	checkCreateGlyph()
end

local function CreateGlyph(button)
	-- // CreateButton selected
	if KMTE.isStation then
		-- check if extraction tab is selected to avoid bugs with ESO UI (and lost item with destroy glyph!)
		if ENCHANTING.enchantingMode == ENCHANTING_MODE_CREATION then ZO_MenuBar_SelectDescriptor(ZO_EnchantingTopLevelModeMenuBar, ENCHANTING_MODE_EXTRACTION) end
		
		--check bag space
		if CheckInventorySpaceAndWarn(1) then
			-- for all type rune, check known status & stack=0
			local potencyRune
			local potencyControl
			if KMTE_DB["count"]["PotencyAdditive"].Selected ~= nil then
				potencyRune = KMTE_DB["count"]["PotencyAdditive"].Selected
				potencyControl = getControl(KMTE.MainWindow,"PotencyAdditive_"..potencyRune.name..potencyRune.quality)
			else
				potencyRune = KMTE_DB["count"]["PotencySubstrative"].Selected
				potencyControl = getControl(KMTE.MainWindow,"PotencySubstrative_"..potencyRune.name..potencyRune.quality)
			end
			majNumberButton(potencyControl, potencyRune.stack -1)
			potencyRune.stack = potencyRune.stack -1
			potencyRune.known = true
			getControl(potencyControl, "Icon"):SetColor(1,1,1,1)
			getControl(potencyControl, "Icon"):SetTexture(potencyRune.icon)
			getControl(potencyControl, "Text").Color = getColorForBG(potencyRune.Quality)

			local essenceRune = KMTE_DB["count"]["Essence"].Selected
			local essenceControl = getControl(KMTE.MainWindow, "Essence_"..essenceRune.name..essenceRune.quality)
			majNumberButton(essenceControl, KMTE_DB["count"]["Essence"].Selected.stack -1)
			essenceRune.stack = essenceRune.stack -1
			essenceRune.known = true
			getControl(essenceControl, "Icon"):SetColor(1,1,1,1)
			getControl(essenceControl, "Icon"):SetTexture(essenceRune.icon)
			getControl(essenceControl, "Text").Color = getColorForBG(essenceRune.Quality)

			local aspectRune = KMTE_DB["count"]["Aspect"].Selected
			local aspectControl = getControl(KMTE.MainWindow, "Aspect_"..aspectRune.name..aspectRune.quality)
			majNumberButton(aspectControl, aspectRune.stack -1)
			aspectRune.stack = aspectRune.stack -1
			aspectRune.known = true
			getControl(aspectControl, "Icon"):SetColor(1,1,1,1)
			getControl(aspectControl, "Icon"):SetTexture(aspectRune.icon)
			getControl(aspectControl, "Text").Color = getColorForBG(aspectRune.Quality)
			
			--d("--CreateGlyph")
			KMTE.mode = ENCHANTING_MODE_CREATION
			-- multicraft ?
			KMTE.autoCraftMode = GetControl("KMTE_MainWindow_CreateSlider"):GetValue()
			CraftEnchantingItem(potencyRune.bagId[1], potencyRune.slotIndex[1], essenceRune.bagId[1], essenceRune.slotIndex[1], aspectRune.bagId[1], aspectRune.slotIndex[1]) 
		end
	else
		-- not in station
		KMTE:addMsg("|cFF6A00[" .. KMTE.name .. "]|r : "..KMTE.langString.KMTEMessage_stationNeeded)
	end
end
local function DestroyGlyph(button)
	-- // DestroyButton selected
	msg("--DestroyGlyph")
	if not KMTE.isStation then
		-- not in station
		KMTE:addMsg("|cFF6A00[" .. KMTE.name .. "]|r : "..KMTE.langString.KMTEMessage_stationNeeded)
	else
		-- check if extraction tab is selected to avoid bugs with ESO UI (and lost item with destroy glyph!)
		if ENCHANTING.enchantingMode == ENCHANTING_MODE_CREATION then ZO_MenuBar_SelectDescriptor(ZO_EnchantingTopLevelModeMenuBar, ENCHANTING_MODE_EXTRACTION) end

		--check bag space
		if CheckInventorySpaceAndWarn(2) then 		
			KMTE.autoCraftAll = false
			local isRestart = false
			local i
			local bagId, slotIndex
			local selectedTypeGlyph = KMTE_DB["count"]["Glyph"].Selected
		--	if KMTE.autoCraftRefreshNeeded then isRestart = true end --test for 1 loop only
			KMTE.autoCraftRefreshNeeded = false
			KMTE.autoCraftMode = 0

			--Refresh if other addons are active
			KMTE:CheckforOtherAddons()

			if selectedTypeGlyph ~= nil then
--				d(KMTE_DB["count"]["Glyph"].Selected.name)
				-- if glyph item selected => destroy it
				if KMTE_DB["count"][selectedTypeGlyph.name].Selected ~= nil then
--					d("--> Destroy! "..KMTE_DB["count"][KMTE_DB["count"]["Glyph"].Selected.name].Selected.name)
					bagId = KMTE_DB["count"][selectedTypeGlyph.name].Selected.bagId[1]
					slotIndex = KMTE_DB["count"][selectedTypeGlyph.name].Selected.slotIndex[1]
					local quality = KMTE_DB["count"][selectedTypeGlyph.name].Selected.quality
					local colorQuality
					if quality < 2 then colorQuality = "FFFACD" else colorQuality = string.sub(COLOR_QUALITY[quality], 1, 6) end
					KMTE.mode = ENCHANTING_MODE_EXTRACTION
					
					-- check if glyph is locked (by user into ESO UI panel)
					if KMTE.itemSaverFilter and ItemSaver_IsItemSaved(bagId, slotIndex) == true then
						KMTE:addMsg("|c"..COLOR_KHRILLSELECT .. KMTE.name .. "|r : "..KMTE.langString.KMTEMessage_itemLocked.."|cFF0000ItemSaver|r (|c"..colorQuality..zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagId, slotIndex)).."|r)")
					elseif KMTE.FCOitemSaverFilter and FCOIsMarked ~= nil and FCOIsMarked(GetItemInstanceId(bagId, slotIndex), -1) == true then
						KMTE:addMsg("|c"..COLOR_KHRILLSELECT .. KMTE.name .. "|r : "..KMTE.langString.KMTEMessage_itemLocked.."|cFF0000FCOItemSaver|r (|c"..colorQuality..zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagId, slotIndex)).."|r)")
					else
						ExtractEnchantingItem(bagId, slotIndex)
	--					table.remove(KMTE_DB["count"][selectedTypeGlyph.name].Selected.bagId, 1)
	--					table.remove(KMTE_DB["count"][selectedTypeGlyph.name].Selected.slotIndex, 1)
	--		d("extract "..tostring(KMTE_DB["count"][selectedTypeGlyph.name].Selected.bagId[1])..","..tostring(KMTE_DB["count"][selectedTypeGlyph.name].Selected.slotIndex[1]).." "..tostring(KMTE_DB["count"][selectedTypeGlyph.name].Selected.bagId[2])..","..tostring(KMTE_DB["count"][selectedTypeGlyph.name].Selected.slotIndex[2]))
						KMTE_DB["count"][selectedTypeGlyph.name].Selected.stack = KMTE_DB["count"][selectedTypeGlyph.name].Selected.stack -1			
						if KMTE_DB["count"][selectedTypeGlyph.name].Selected.stack == 0 then
							showControl(KMTE.MainWindow,selectedTypeGlyph.name.."_"..KMTE_DB["count"][selectedTypeGlyph.name].Selected.name..KMTE_DB["count"][selectedTypeGlyph.name].Selected.quality, false)
							showControl(KMTE.MainWindow,"DestroyGlyph", false)
							KMTE:showDestroyTooltip(nil, false)
						end
					end
				else
				-- else => destroy all for glyph type
--					CHAT_SYSTEM:AddMessage("|cFF6A00" .. KMTE.name .. "|r : "..KMTE.langString.KMTEMessage_notImplemented)
--					return
					KMTE:DestroyAll()
				end
			else
				-- all types of glyph
--				d("-> destroy all")
				KMTE.autoCraftAll = true
				KMTE:showDestroyTooltip(nil, false)
				KMTE_DB["count"]["Glyph"].Selected = KMTE.default_rune["Armor"]
				KMTE:DestroyAll()
			end
		end
	end
end
function KMTE:DestroyAll()
	KMTE.autoCraftMode = 2
	KMTE.autoCraftRefreshNeeded = true
	showControl(KMTE.MainWindow,"DestroyGlyph", false)
	showControl(KMTE.MainWindow,"Cancel", true)
	local selectedTypeGlyph = KMTE_DB["count"]["Glyph"].Selected
	if selectedTypeGlyph ~= nil and KMTE_DB[selectedTypeGlyph.name][1] ~= nil then
--		d("destroy all glyphs "..KMTE_DB["count"]["Glyph"].Selected.name)
--		d("max="..KMTE_DB["count"][KMTE_DB["count"]["Glyph"].Selected.name].Max)
		local bagId = KMTE_DB[selectedTypeGlyph.name][1].bagId[1]
		local slotIndex = KMTE_DB[selectedTypeGlyph.name][1].slotIndex[1]
		local fakeDestroy = false
		local quality = KMTE_DB[selectedTypeGlyph.name][1].quality
		local colorQuality
		if quality < 2 then colorQuality = "FFFACD" else colorQuality = string.sub(COLOR_QUALITY[quality], 1, 6) end
--		d("ExtractEnchantingItem("..bagId..", "..slotIndex..")")
		KMTE.mode = ENCHANTING_MODE_EXTRACTION
		-- check if glyph is locked (by user into ESO UI panel)
		if KMTE.itemSaverFilter and ItemSaver_IsItemSaved(bagId, slotIndex) == true then
			KMTE:addMsg("|c"..COLOR_KHRILLSELECT .. KMTE.name .. "|r : "..KMTE.langString.KMTEMessage_itemLocked.."|cFF0000ItemSaver|r (|c"..colorQuality..zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagId, slotIndex)).."|r)")
			fakeDestroy = true
		elseif KMTE.FCOitemSaverFilter and FCOIsMarked ~= nil and FCOIsMarked(GetItemInstanceId(bagId, slotIndex), -1) == true then
			KMTE:addMsg("|c"..COLOR_KHRILLSELECT .. KMTE.name .. "|r : "..KMTE.langString.KMTEMessage_itemLocked.."|cFF0000FCOItemSaver|r (|c"..colorQuality..zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagId, slotIndex)).."|r)")
			fakeDestroy = true
		else
			ExtractEnchantingItem(bagId, slotIndex)
		end	
		
		table.remove(KMTE_DB[selectedTypeGlyph.name][1].bagId, 1)
		table.remove(KMTE_DB[selectedTypeGlyph.name][1].slotIndex, 1)
		if KMTE_DB[selectedTypeGlyph.name][1].bagId[1] == nil then
--			d("next")
			table.remove(KMTE_DB[selectedTypeGlyph.name], 1)
		end
		-- if locked glyph, do next (no craft completed event)
		if fakeDestroy then KMTE:DestroyAll() end

		--KMTE:OnCraftCompleted() -- for testing
	else
--		d("end "..tostring(KMTE.autoCraftAll))
		if KMTE.autoCraftAll and not KMTE.cancelCraft then
			-- Destroy all glyph mode => continue with next type
			if selectedTypeGlyph.name == "Armor" then 
				KMTE_DB["count"]["Glyph"].Selected = KMTE.default_rune["Weapon"]
			elseif selectedTypeGlyph.name == "Weapon" then
				KMTE_DB["count"]["Glyph"].Selected = KMTE.default_rune["Jewel"]
			elseif selectedTypeGlyph.name == "Jewel" then
				KMTE.autoCraftAll = false
				KMTE_DB["count"]["Glyph"].Selected = nil
			end
			-- restart
--			d("--restart next ")
			KMTE:DestroyAll()
		else
			KMTE.autoCraftMode = 1
			KMTE.autoCraftRefreshNeeded = false
			KMTE:OnCraftCompleted()
		end
	end
end
local function CancelCraft(button)
	KMTE.cancelCraft = true
--	showControl(KMTE.MainWindow,"Cancel", false)
end

local function SwapRune(button)
	-- // SwapRuneButton selected
	KMTE.InfoMode = false
	KMTE.LabelMode = false
	swapAll()
end
local function SwapInfo(button)
	-- // SwapInfoButton selected
	KMTE.InfoMode = true
	KMTE.LabelMode = false
	swapAll()
end
local function SwapLabel(button)
	-- // SwapLabelButton selected
	KMTE.InfoMode = false
	KMTE.LabelMode = true
	swapAll()
end

local function SelectBag(button)
	-- // BagButton selected
	KMTE.BagMode = not KMTE.BagMode
	if not KMTE.BagMode then
		getControl(button,"Texture"):SetColor(HexToRGBA(COLOR_DISABLED))
	else
		getControl(button,"Texture"):SetColor(HexToRGBA(COLOR_KHRILLSELECT))
	end
	KMTE:ScanRunes()
end
local function SelectBank(button)
	-- // BankButton selected
	KMTE.BankMode = not KMTE.BankMode
	if not KMTE.BankMode then
		getControl(button,"Texture"):SetColor(HexToRGBA(COLOR_DISABLED))
	else
		getControl(button,"Texture"):SetColor(HexToRGBA(COLOR_KHRILLSELECT))
	end
	KMTE:ScanRunes()
end
local function Reload(button)
	KMTE:ScanRunes()
end

local function userClose(button)
	-- // CloseButton selected
	SetGameCameraUIMode(false)
	KMTE:CloseUI()
end

-- // **********
-- //   Events
-- // **********
function KMTE_ToggleEnable()
	KMTE:ToggleEnable(not KMTE.settings.Enable)
	if KMTE.settings.Enable then
		KMTE:addMsg("|c"..COLOR_KHRILLSELECT.."["..KMTE.name.."]|r => |c00FF00"..KMTE.langString.KMTESettings_enable.."|r")
	else
		KMTE:addMsg("|c"..COLOR_KHRILLSELECT.."["..KMTE.name.."]|r => |cFF0000"..KMTE.langString.KMTESettings_disable.."|r")
	end
end
function KMTE_ToggleByKey()
	-- show/hide by keybind
	if KMTE_MainWindow:IsHidden() then
		SetGameCameraUIMode(true)
		KMTE.isStation = (GetInteractionType() == INTERACTION_CRAFT and GetCraftingInteractionType() == CRAFTING_TYPE_ENCHANTING)
		KMTE.MainWindow:SetDrawLayer(0)
		KMTE:OpenUI()
	else
		SetGameCameraUIMode(false)
		KMTE:CloseUI()
	end
end
function KMTE:OnCrafting(sameStation)
	-- // active craft station
	msg("--OnCrafting")
	KMTE.isStation = true
	KMTE.MainWindow:SetDrawLayer(DL_BACKGROUND)
	if IsInGamepadPreferredMode() then return end
	if KMTE.settings.Enable then 
		KMTE:OpenUI()
	end
end
function KMTE:OnCraftCompleted()
	if KMTE.isStation then
		if KMTE.autoCraftMode <= 1 or KMTE.cancelCraft then
			msg("--OnCraftCompleted")
			showControl(KMTE.MainWindow,"Cancel", false)
			if KMTE.cancelCraft then
				KMTE.cancelCraft = false
				KMTE:ScanAllGlyph()
			elseif not KMTE.autoCraftAll then
				KMTE.cancelCraft = false
				-- check if destroy object glyph&runes
				local essenceRune = KMTE_DB["count"]["Essence"].Selected
				local potencyAdditiveRune = KMTE_DB["count"]["PotencyAdditive"].Selected
				local potencySubstrativeRune = KMTE_DB["count"]["PotencySubstrative"].Selected
				local aspectRune = KMTE_DB["count"]["Aspect"].Selected
				KMTE:checkObject("Essence", essenceRune)
				KMTE:checkObject("PotencyAdditive", potencyAdditiveRune)
				KMTE:checkObject("PotencySubstrative", potencySubstrativeRune)
				KMTE:checkObject("Aspect", aspectRune)
				local typeGlyph = KMTE_DB["count"]["Glyph"].Selected
				if typeGlyph ~= nil then
					local selectedGlyph = KMTE_DB["count"][typeGlyph.name].Selected
					KMTE:checkObject(KMTE_DB["count"]["Glyph"].Selected.name, selectedGlyph)
				end

				-- if multiple same glyph, then restart
				if KMTE.autoCraftRefreshNeeded then
--					d("->restart")
					--DestroyGlyph(button)
				else
					-- refresh glyph
					--KMTE:Reset()
					--KMTE:ClearBag(KMTE_DB["count"]["Glyph"].Selected.name)
					if KMTE.mode == ENCHANTING_MODE_CREATION or KMTE.mode == ENCHANTING_MODE_EXTRACTION then
						ZO_MenuBar_SelectDescriptor(ZO_EnchantingTopLevelModeMenuBar, KMTE.mode)
						if KMTE.mode == ENCHANTING_MODE_CREATION then
							--if typeGlyph ~= nil then KMTE:deselectRune(typeGlyph.name) end
						end
					end
					--KMTE.autoCraftRefreshNeeded = (typeGlyph ~= nil) --true
					if typeGlyph ~= nil then
						KMTE:ScanRunes(typeGlyph.name)
						checkCreateGlyph()
					else
						KMTE:ScanRunes(nil)
					end
					KMTE_DB["count"]["Glyph"].Selected = typeGlyph
					KMTE.autoCraftRefreshNeeded = false
				end
			end
		else
			msg("--OnCraftCompleted, cpt="..KMTE.autoCraftMode)
			KMTE.autoCraftMode = KMTE.autoCraftMode -1
			if KMTE.mode == ENCHANTING_MODE_CREATION then
				-- create multi (slider)
				local control = GetControl("KMTE_MainWindow_CreateSlider")
				control:SetValue(KMTE.autoCraftMode)
				control.selText:SetText(KMTE.autoCraftMode)
				local nbItem = tonumber(control.maxText:GetText()) -1
				control:SetMinMax(1, nbItem)
				control.maxText:SetText(nbItem)
				-- check runes
				KMTE:checkObject("Essence", KMTE_DB["count"]["Essence"].Selected)
				KMTE:checkObject("PotencyAdditive", KMTE_DB["count"]["PotencyAdditive"].Selected)
				KMTE:checkObject("PotencySubstrative", KMTE_DB["count"]["PotencySubstrative"].Selected)
				KMTE:checkObject("Aspect", KMTE_DB["count"]["Aspect"].Selected)
				--relaunch create
				CreateGlyph(KMTE_MainWindow_CreateGlyph)
			else --destroy all
				if KMTE.autoCraftMode == 1 and KMTE.autoCraftRefreshNeeded then
--				d("->restart cose 1")
					KMTE:DestroyAll()
					--zo_callLater(DestroyGlyph(button),3000)
				end
			end
		end
		_G["ZO_EnchantingTopLevelTooltip"]:SetAlpha(0)
	end
end
function KMTE:OnCraftEnd()
	-- // quit craft
		msg("--OnCraftEnd")
		KMTE.isStation = false
		if not KMTE_MainWindow:IsHidden() then KMTE:CloseUI() end
end
function KMTE:OnSkillXP(skillType, skillIndex, previousXP, currentXP)
	-- // when gain xp via crafting
	local name,rank = GetSkillLineInfo(skillType, skillIndex)
	local gainXP = currentXP - previousXP
	
	if gainXP > 0 then KMTE:addMsg(KMTE.langString.KMTEMessage_skill .. " |cFF6A00" .. zo_strformat(SI_TOOLTIP_ITEM_NAME, name) .. "|r = |cFF6A00+" .. gainXP .. "xp|r") end
end
function KMTE:OnNewItem(bagId, slotIndex)
	-- // when rune gain via glyph extraction
	local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagId, slotIndex))
	local link = GetItemLink(bagId, slotIndex)
	local itemId = GetItemLinkID(link)
	local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality  = GetItemInfo(bagId, slotIndex) 
	local itemType = GetItemType(bagId, slotIndex)
	local typeRune = nil, typeRune2Print, index, message2print, name2print, icon2print
	msg("-- NewItem "..itemName)
	name2print = itemName
	if icon == nil then
		icon2print = ""
	else
		icon2print = zo_iconFormat(icon, 16, 16)
	end
	if quality == nil then quality = 0 end
	if itemType == ITEMTYPE_GLYPH_ARMOR then
		typeRune = "Armor"
		if KMTE.settings.LinkChat then name2print = "["..link.."]" end
		typeRune2Print = KMTE.langString.KMTESettings_glyph_Armor
		message2print = KMTE.langString.KMTEMessage_glyphGain
	elseif itemType == ITEMTYPE_GLYPH_WEAPON then
		typeRune = "Weapon"
		if KMTE.settings.LinkChat then name2print = "["..link.."]" end
		typeRune2Print = KMTE.langString.KMTESettings_glyph_Weapon
		message2print = KMTE.langString.KMTEMessage_glyphGain
	elseif itemType == ITEMTYPE_GLYPH_JEWELRY then
		typeRune = "Jewel"
		if KMTE.settings.LinkChat then name2print = "["..link.."]" end
		typeRune2Print = KMTE.langString.KMTESettings_glyph_Jewel
		message2print = KMTE.langString.KMTEMessage_glyphGain
	elseif itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE then
		typeRune = "Essence"
		typeRune2Print = KMTE.langString.KMTESettings_rune_Essence
		message2print = KMTE.langString.KMTEMessage_runeGain
	elseif itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT then
		typeRune = "Aspect"
		typeRune2Print = KMTE.langString.KMTESettings_rune_Aspect
		message2print = KMTE.langString.KMTEMessage_runeGain
	elseif itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY then
		if (itemId == 45855) or (itemId == 45856) or (itemId == 45857) or (itemId == 45806) or (itemId == 45807) or (itemId == 45808) or (itemId == 45809) or (itemId == 45810) or (itemId == 45811) or (itemId == 45812) or (itemId == 45813) or (itemId == 45814) or (itemId == 45815) or (itemId == 45816) then
			typeRune = "PotencyAdditive"
		else
			typeRune = "PotencySubstrative"
		end
		typeRune2Print = KMTE.langString.KMTESettings_rune_Potency
		message2print = KMTE.langString.KMTEMessage_runeGain
	end
	if typeRune ~= nil then
		index = KMTE:ifExistRune(typeRune, itemId)
--		index = KMTE:ifExistRune(typeRune, itemName, quality)
		if KMTE.BagMode and meetsUsageRequirement then
			if index > 0 then
				--update
--				d("update")
				KMTE:checkObject(typeRune, KMTE_DB[typeRune][index])
			else
				--new rune in bag -> check bag
				KMTE:ScanRunes(typeRune)
			end
		end
		local colorQuality = string.sub(COLOR_QUALITY[quality], 1, 6)
		if quality < 2 then colorQuality = "FFFACD" end -- white instead of black
		if KMTE.settings.NewItem then KMTE:addMsg(message2print .." ".. icon2print .." |c".. colorQuality .. name2print .. "|r (|cFF6A00" .. typeRune2Print .. "|r)") end
	end
end

-- // **********
-- //     UI
-- // **********
local function WeaponChargeAlert_Hide(state)
	-- hide WCA when on station
	local addonWindow = GetControl("WeaponChargeAlert_Window")
	if addonWindow ~= nil then addonWindow:SetHidden(state) end
end
local function GearSwap_Hide(state)
	-- hide GearSwap when on station
	local addonWindow = GetControl("ctlGearSwap")
	if addonWindow ~= nil then addonWindow:SetHidden(state) end
end

function KMTE:CreateMainUI()
	local windowSizeX = 1100
	local windowSizeY = 950
	local iconSize = 32
	local iconSpacing = 5
	
	-- Main Window
	KMTE.MainWindow = WINDOW_MANAGER:CreateTopLevelWindow("KMTE_MainWindow")
	KMTE.MainWindow:SetDimensions(windowSizeX, windowSizeY)
	KMTE.MainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, KMTE.GetOffsetX(), KMTE:GetOffsetY())
	KMTE.MainWindow:SetClampedToScreen(true)
	KMTE.MainWindow:SetHidden(true)
	KMTE.MainWindow:SetMovable(true)
	KMTE.MainWindow:SetMouseEnabled(true)
	KMTE.MainWindow:SetAlpha(1)
	KMTE.MainWindow:SetDrawLevel(2)
	KMTE.MainWindow:SetDrawLayer(0)
	KMTE.MainWindow:SetDrawTier(0)
	if KMTE.MainWindow:GetHandler("OnMouseUp") == nil then KMTE.MainWindow:SetHandler("OnMouseUp", function() KMTE:SaveAnchor() end) end
	
	-- Backgroung
	local BG = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_BG", KMTE.MainWindow, CT_TEXTURE)
		BG:SetDimensions(windowSizeX, windowSizeY)
		BG:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, -90, -150)
		BG:SetTexture(KMTE.BGTextures[KMTE.settings.BG]) --TEXTURE_BG)
	-- Close button
	local closeBtn = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Close", KMTE.MainWindow, CT_BUTTON)
		closeBtn:SetDimensions(iconSize, iconSize)
		closeBtn:SetAnchor(TOPRIGHT, KMTE.MainWindow, TOPRIGHT, -110, -32)
		if closeBtn:GetHandler("OnClicked") == nil then closeBtn:SetHandler("OnClicked", userClose) end
		closeBtn:SetMouseEnabled(true)
	local closeBtn_TEXTURE = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Close_Texture", closeBtn, CT_TEXTURE)
		closeBtn_TEXTURE.Color=COLOR_KHRILLSELECT
		closeBtn_TEXTURE:SetDimensions(iconSize, iconSize)
		closeBtn_TEXTURE:SetAnchor(TOPLEFT, closeBtn, TOPLEFT)
		closeBtn_TEXTURE:SetAnchorFill(closeBtn)
		closeBtn_TEXTURE:SetTexture(TEXTURE_CLOSE)
		closeBtn_TEXTURE:SetAlpha(1)
		closeBtn_TEXTURE:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		closeBtn_TEXTURE:SetHidden(false)
	-- Title
	local title = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Title", KMTE.MainWindow, CT_LABEL)
		title:SetDimensions(300, 100)
		title:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 400, -10)
		title:SetHorizontalAlignment(1)
		title:SetScale(2)
		title:SetAlpha(1)
		title:SetFont("EsoUI/Common/Fonts/Handwritten_Bold.otf|18|shadow")--"ZoFontGame")
        title:SetColor(HexToRGBA(COLOR_TITLE))
        title:SetStyleColor(0,0,0,1)
		title:SetDrawLevel(2)
		title:SetHidden(false)
		title:SetText(KMTE.langString.KMTESettings_title)
	-- version by Khrill ;)
	local version = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Version", KMTE.MainWindow, CT_LABEL)
		version:SetDimensions(200, 50)
		version:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 895, 645)
		version:SetScale(0.7)
		version:SetAlpha(1)
		version:SetFont("ZoFontGame")
        version:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
        version:SetStyleColor(0,0,0,1)
		version:SetDrawLevel(2)
		version:SetHidden(false)
		version:SetText("v"..KMTE.version.." "..KMTE.langString.KMTESettings_author)

	-- Bag&Bank button
	local bagBtn = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Bag", KMTE.MainWindow, CT_BUTTON)
		bagBtn:SetDimensions(iconSize, iconSize)
		bagBtn:SetAnchor(TOPRIGHT, KMTE.MainWindow, TOPRIGHT, -148, 0)
		if bagBtn:GetHandler("OnClicked") == nil then bagBtn:SetHandler("OnClicked", SelectBag) end
		bagBtn:SetMouseEnabled(true)
	local bagBtn_TEXTURE = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Bag_Texture", bagBtn, CT_TEXTURE)
		bagBtn_TEXTURE.Color=COLOR_KHRILLSELECT
		bagBtn_TEXTURE:SetDimensions(iconSize, iconSize)
		bagBtn_TEXTURE:SetAnchor(TOPLEFT, bagBtn, TOPLEFT)
		bagBtn_TEXTURE:SetAnchorFill(bagBtn)
		bagBtn_TEXTURE:SetTexture(TEXTURE_BAG)
		bagBtn_TEXTURE:SetAlpha(1)
		bagBtn_TEXTURE:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		bagBtn_TEXTURE:SetHidden(false)
	local bankBtn = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Bank", KMTE.MainWindow, CT_BUTTON)
		bankBtn:SetDimensions(28, 28)
		bankBtn:SetAnchor(TOPRIGHT, KMTE.MainWindow, TOPRIGHT, -150, 30)
		if bankBtn:GetHandler("OnClicked") == nil then bankBtn:SetHandler("OnClicked", SelectBank) end
		bankBtn:SetMouseEnabled(true)
	local bankBtn_TEXTURE = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Bank_Texture", bankBtn, CT_TEXTURE)
		bankBtn_TEXTURE.Color=COLOR_KHRILLSELECT
		bankBtn_TEXTURE:SetDimensions(iconSize, iconSize)
		bankBtn_TEXTURE:SetAnchor(TOPLEFT, bankBtn, TOPLEFT)
		bankBtn_TEXTURE:SetAnchorFill(bankBtn)
		bankBtn_TEXTURE:SetTexture(TEXTURE_BANK)
		bankBtn_TEXTURE:SetAlpha(1)
		bankBtn_TEXTURE:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		bankBtn_TEXTURE:SetHidden(false)
	-- reload button
	local reloadBtn = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Reload", KMTE.MainWindow, CT_BUTTON)
		reloadBtn:SetDimensions(22, 22)
		reloadBtn:SetAnchor(TOPRIGHT, KMTE.MainWindow, TOPRIGHT, -153, 60)
		if reloadBtn:GetHandler("OnClicked") == nil then reloadBtn:SetHandler("OnClicked", Reload) end
		reloadBtn:SetMouseEnabled(true)
	local reloadBtn_TEXTURE = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Reload_Texture", reloadBtn, CT_TEXTURE)
		reloadBtn_TEXTURE.Color=COLOR_RUNEUNKNOWN		reloadBtn_TEXTURE:SetDimensions(iconSize, iconSize)
		reloadBtn_TEXTURE:SetAnchor(TOPLEFT, reloadBtn, TOPLEFT)
		reloadBtn_TEXTURE:SetAnchorFill(reloadBtn)
		reloadBtn_TEXTURE:SetTexture(TEXTURE_RELOAD)
		reloadBtn_TEXTURE:SetAlpha(1)
		reloadBtn_TEXTURE:SetColor(HexToRGBA(reloadBtn_TEXTURE.Color))
		reloadBtn_TEXTURE:SetHidden(false)
	
	-- Swap rune button
	local SwapRune_MAIN = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_SwapRune", KMTE.MainWindow, CT_BUTTON)
		SwapRune_MAIN:SetDimensions(50, 40)
		SwapRune_MAIN:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, -55, 250)
		if SwapRune_MAIN:GetHandler("OnClicked") == nil then SwapRune_MAIN:SetHandler("OnClicked", SwapRune) end
		SwapRune_MAIN:SetMouseEnabled(true)
		SwapRune_MAIN:SetHidden(true)
--		SwapRune_MAIN:SetMovable(false)
		SwapRune_MAIN:SetAlpha(0.8)
		SwapRune_MAIN:SetDrawLevel(2)
		SwapRune_MAIN.Hidden = false
	local SwapRune_OUTLINE = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_SwapRune_Outline", SwapRune_MAIN, CT_TEXTURE)
		SwapRune_OUTLINE.Color = COLOR_DISABLED --COLOR_KHRILLSELECT
		SwapRune_OUTLINE:SetDimensions(iconSize, iconSize)
		SwapRune_OUTLINE:SetAnchor(TOPLEFT, SwapRune_MAIN, TOPLEFT)
		SwapRune_OUTLINE:SetAnchorFill(SwapRune_MAIN)
		SwapRune_OUTLINE:SetTexture(TEXTURE_OUTLINE)
		SwapRune_OUTLINE:SetAlpha(0.8)
		SwapRune_OUTLINE:SetColor(HexToRGBA(SwapRune_OUTLINE.Color))
		SwapRune_OUTLINE:SetHidden(false)
	local SwapRune_TEXT = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_SwapRune_Text", SwapRune_MAIN, CT_LABEL)
		SwapRune_TEXT.Color = COLOR_QUALITY[0] --COLOR_KHRILLSELECT
		SwapRune_TEXT.Hidden = false
		SwapRune_TEXT:SetDimensions(50,50)
		SwapRune_TEXT:SetHorizontalAlignment(1)
		SwapRune_TEXT:SetVerticalAlignment(1)
		SwapRune_TEXT:SetScale(0.7)
		SwapRune_TEXT:SetAnchor(TOPLEFT, SwapRune_MAIN, TOPLEFT, 7, 1)
		SwapRune_TEXT:SetAlpha(0.8)
		SwapRune_TEXT:SetFont("ZoFontGame")
		SwapRune_TEXT:SetColor(HexToRGBA(SwapRune_TEXT.Color))
		SwapRune_TEXT:SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
--		SwapRune_TEXT:SetStyleColor(0,0,0,1)
		SwapRune_TEXT:SetDrawLevel(2)
		SwapRune_TEXT:SetHidden(false)
		SwapRune_TEXT:SetText(KMTE.langString.KMTESettings_swap_rune) --"Rune name")
	-- Swap info rune button
	local SwapInfo_MAIN = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_SwapInfo", KMTE.MainWindow, CT_BUTTON)
		SwapInfo_MAIN:SetDimensions(50, 40)
		SwapInfo_MAIN:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, -55, 290)
		if SwapInfo_MAIN:GetHandler("OnClicked") == nil then SwapInfo_MAIN:SetHandler("OnClicked", SwapInfo) end
		SwapInfo_MAIN:SetMouseEnabled(true)
		SwapInfo_MAIN:SetHidden(true)
--		SwapInfo_MAIN:SetMovable(false)
		SwapInfo_MAIN:SetAlpha(0.8)
		SwapInfo_MAIN:SetDrawLevel(2)
		SwapInfo_MAIN.Hidden = false
	local SwapInfo_OUTLINE = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_SwapInfo_Outline", SwapInfo_MAIN, CT_TEXTURE)
		SwapInfo_OUTLINE.Color = COLOR_DISABLED --COLOR_KHRILLSELECT
		SwapInfo_OUTLINE:SetDimensions(iconSize, iconSize)
		SwapInfo_OUTLINE:SetAnchor(TOPLEFT, SwapInfo_MAIN, TOPLEFT)
		SwapInfo_OUTLINE:SetAnchorFill(SwapInfo_MAIN)
		SwapInfo_OUTLINE:SetTexture(TEXTURE_OUTLINE)
		SwapInfo_OUTLINE:SetAlpha(0.8)
		SwapInfo_OUTLINE:SetColor(HexToRGBA(SwapInfo_OUTLINE.Color))
		SwapInfo_OUTLINE:SetHidden(false)
	local SwapInfo_TEXT = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_SwapInfo_Text", SwapInfo_MAIN, CT_LABEL)
		SwapInfo_TEXT.Color = COLOR_QUALITY[0] --COLOR_KHRILLSELECT
		SwapInfo_TEXT.Hidden = false
		SwapInfo_TEXT:SetDimensions(50,50)
		SwapInfo_TEXT:SetHorizontalAlignment(1)
		SwapInfo_TEXT:SetVerticalAlignment(1)
		SwapInfo_TEXT:SetScale(0.7)
		SwapInfo_TEXT:SetAnchor(TOPLEFT, SwapInfo_MAIN, TOPLEFT, 7, 1)
		SwapInfo_TEXT:SetAlpha(0.8)
		SwapInfo_TEXT:SetFont("ZoFontGame")
		SwapInfo_TEXT:SetColor(HexToRGBA(SwapInfo_TEXT.Color))
		SwapInfo_TEXT:SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
--		SwapInfo_TEXT:SetStyleColor(0,0,0,1)
		SwapInfo_TEXT:SetDrawLevel(2)
		SwapInfo_TEXT:SetHidden(false)
		SwapInfo_TEXT:SetText(KMTE.langString.KMTESettings_swap_info) --"Rune info")
	-- Swap name button
	local SwapLabel_MAIN = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_SwapLabel", KMTE.MainWindow, CT_BUTTON)
		SwapLabel_MAIN:SetDimensions(50, 40)
		SwapLabel_MAIN:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, -55, 330)
		if SwapLabel_MAIN:GetHandler("OnClicked") == nil then SwapLabel_MAIN:SetHandler("OnClicked", SwapLabel) end
		SwapLabel_MAIN:SetMouseEnabled(true)
		SwapLabel_MAIN:SetHidden(true)
--		SwapLabel_MAIN:SetMovable(false)
		SwapLabel_MAIN:SetAlpha(0.8)
		SwapLabel_MAIN:SetDrawLevel(2)
		SwapLabel_MAIN.Hidden = false
	local SwapLabel_OUTLINE = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_SwapLabel_Outline", SwapLabel_MAIN, CT_TEXTURE)
		SwapLabel_OUTLINE.Color = COLOR_DISABLED --COLOR_KHRILLSELECT
		SwapLabel_OUTLINE:SetDimensions(iconSize, iconSize)
		SwapLabel_OUTLINE:SetAnchor(TOPLEFT, SwapLabel_MAIN, TOPLEFT)
		SwapLabel_OUTLINE:SetAnchorFill(SwapLabel_MAIN)
		SwapLabel_OUTLINE:SetTexture(TEXTURE_OUTLINE)
		SwapLabel_OUTLINE:SetAlpha(0.8)
		SwapLabel_OUTLINE:SetColor(HexToRGBA(SwapLabel_OUTLINE.Color))
		SwapLabel_OUTLINE:SetHidden(false)
	local SwapLabel_TEXT = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_SwapLabel_Text", SwapLabel_MAIN, CT_LABEL)
		SwapLabel_TEXT.Color = COLOR_QUALITY[0] --COLOR_KHRILLSELECT
		SwapLabel_TEXT.Hidden = false
		SwapLabel_TEXT:SetDimensions(50,50)
		SwapLabel_TEXT:SetHorizontalAlignment(1)
		SwapLabel_TEXT:SetVerticalAlignment(1)
		SwapLabel_TEXT:SetScale(0.7)
		SwapLabel_TEXT:SetAnchor(TOPLEFT, Swap_MAIN, TOPLEFT, 7, 1)
		SwapLabel_TEXT:SetAlpha(0.8)
		SwapLabel_TEXT:SetFont("ZoFontGame")
		SwapLabel_TEXT:SetColor(HexToRGBA(SwapLabel_TEXT.Color))
		SwapLabel_TEXT:SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
		SwapLabel_TEXT:SetDrawLevel(2)
		SwapLabel_TEXT:SetHidden(false)
		SwapLabel_TEXT:SetText(KMTE.langString.KMTESettings_swap_label) --"Glyph label")

	-- Rune titles
	local rune_essence = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_RuneEssence", KMTE.MainWindow, CT_LABEL)
		rune_essence:SetDimensions((iconSize+iconSpacing)*3, 50)
		if KMTE.settings.PotencyFirst then -- order = potency + & - , essence, aspect
			rune_essence:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, (iconSize+iconSpacing)*6, 0)
		else -- order = essence, potency + & - , aspect
			rune_essence:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 0, 0)
		end
		rune_essence:SetHorizontalAlignment(1)
		rune_essence:SetScale(0.9)
		rune_essence:SetAlpha(1)
		rune_essence:SetFont("ZoFontGame")
        rune_essence:SetColor(HexToRGBA(COLOR_QUALITY[2]))
        rune_essence:SetStyleColor(0,0,0,1)
		rune_essence:SetDrawLevel(2)
		rune_essence:SetHidden(true)
		rune_essence:SetText(KMTE.langString.KMTESettings_rune_Essence)
		rune_essence.Hidden = true
	local rune_potency = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_RunePotency", KMTE.MainWindow, CT_LABEL)
		rune_potency:SetDimensions((iconSize+iconSpacing)*6, 50)
		if KMTE.settings.PotencyFirst then -- order = potency + & - , essence, aspect
			rune_potency:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 0, 0)
		else -- order = essence, potency + & - , aspect
			rune_potency:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, (iconSize+iconSpacing)*3, 0)
		end
		rune_potency:SetHorizontalAlignment(1)
		rune_potency:SetScale(0.9)
		rune_potency:SetAlpha(1)
		rune_potency:SetFont("ZoFontGame")
        rune_potency:SetColor(HexToRGBA(COLOR_QUALITY[3]))
        rune_potency:SetStyleColor(0,0,0,1)
		rune_potency:SetDrawLevel(2)
		rune_potency:SetHidden(true)
		rune_potency:SetText(KMTE.langString.KMTESettings_rune_Potency)
		rune_potency.Hidden = true
	local rune_potencyadd = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_RunePotencyAdd", KMTE.MainWindow, CT_LABEL)
		rune_potencyadd.Color = COLOR_QUALITY[3]
		rune_potencyadd.Hidden = true
		rune_potencyadd:SetDimensions((iconSize+iconSpacing), 50)
		if KMTE.settings.PotencyFirst then -- order = potency + & - , essence, aspect
			rune_potencyadd:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 35, -6)
		else -- order = essence, potency + & - , aspect
			rune_potencyadd:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 150, -6)
		end
--		rune_potencyadd:SetHorizontalAlignment(1)
		rune_potencyadd:SetScale(1.2)
		rune_potencyadd:SetAlpha(1)
		rune_potencyadd:SetFont("ZoFontGame")
        rune_potencyadd:SetColor(HexToRGBA(COLOR_QUALITY[3]))
        rune_potencyadd:SetStyleColor(0,0,0,1)
		rune_potencyadd:SetDrawLevel(2)
		rune_potencyadd:SetHidden(true)
		rune_potencyadd:SetText("+")
	local rune_potencysub = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_RunePotencySub", KMTE.MainWindow, CT_LABEL)
		rune_potencysub.Color = COLOR_QUALITY[3]
		rune_potencysub.Hidden = true
		rune_potencysub:SetDimensions((iconSize+iconSpacing), 50)
		if KMTE.settings.PotencyFirst then -- order = potency + & - , essence, aspect
			rune_potencysub:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 150, -12)
		else -- order = essence, potency + & - , aspect
			rune_potencysub:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 260, -12)
		end
--		rune_potencysub:SetHorizontalAlignment(1)
		rune_potencysub:SetScale(1.2)
		rune_potencysub:SetAlpha(1)
		rune_potencysub:SetFont("ZoFontGame")
        rune_potencysub:SetColor(HexToRGBA(COLOR_QUALITY[3]))
        rune_potencysub:SetStyleColor(0,0,0,1)
		rune_potencysub:SetDrawLevel(2)
		rune_potencysub:SetHidden(true)
		rune_potencysub:SetText("_")
	local rune_aspect = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_RuneAspect", KMTE.MainWindow, CT_LABEL)
		rune_aspect:SetDimensions((iconSize+iconSpacing)*3, 50)
		rune_aspect:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, (iconSize+iconSpacing)*9, 0)
		rune_aspect:SetHorizontalAlignment(1)
		rune_aspect:SetScale(0.9)
		rune_aspect:SetAlpha(1)
		rune_aspect:SetFont("ZoFontGame")
        rune_aspect:SetColor(HexToRGBA(COLOR_QUALITY[5]))
        rune_aspect:SetStyleColor(0,0,0,1)
		rune_aspect:SetDrawLevel(2)
		rune_aspect:SetHidden(true)
		rune_aspect:SetText(KMTE.langString.KMTESettings_rune_Aspect)
		rune_aspect.Hidden = true

	-- Create button
	local Create_MAIN = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_CreateGlyph", KMTE.MainWindow, CT_BUTTON)
		Create_MAIN:SetDimensions(150, 40)
		Create_MAIN:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 140, 590)
		if Create_MAIN:GetHandler("OnClicked") == nil then Create_MAIN:SetHandler("OnClicked", CreateGlyph) end
		Create_MAIN:SetMouseEnabled(true)
		Create_MAIN:SetHidden(true)
--		Create_MAIN:SetMovable(false)
		Create_MAIN:SetDrawLevel(2)
		Create_MAIN.Hidden = true
	local Create_OUTLINE = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_CreateGlyph_Outline", Create_MAIN, CT_TEXTURE)
		Create_OUTLINE.Color=COLOR_KHRILLSELECT
		Create_OUTLINE:SetDimensions(iconSize, iconSize)
		Create_OUTLINE:SetAnchor(TOPLEFT, Create_MAIN, TOPLEFT)
		Create_OUTLINE:SetAnchorFill(Create_MAIN)
		Create_OUTLINE:SetTexture(TEXTURE_OUTLINE)
		Create_OUTLINE:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		Create_OUTLINE:SetHidden(false)
	local Create_TEXT = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_CreateGlyph_Text", Create_MAIN, CT_LABEL)
		Create_TEXT.Color=COLOR_KHRILLSELECT
		Create_TEXT.Hidden = false
		Create_TEXT:SetDimensions(140,iconSize)
		Create_TEXT:SetHorizontalAlignment(1)
		Create_TEXT:SetVerticalAlignment(1)
		Create_TEXT:SetScale(1)
		Create_TEXT:SetAnchor(TOPLEFT, Create_MAIN, TOPLEFT, 5, 4)
		Create_TEXT:SetAlpha(1)
		Create_TEXT:SetFont("ZoFontGame")
		Create_TEXT:SetColor(HexToRGBA(Create_TEXT.Color))
		Create_TEXT:SetStyleColor(0,0,0,1)
		Create_TEXT:SetDrawLevel(2)
		Create_TEXT:SetHidden(false)
		Create_TEXT:SetText(KMTE.langString.KMTESettings_rune_create)

	-- Slider for multi-craft
	local CreateSlider = WINDOW_MANAGER:CreateControlFromVirtual("KMTE_MainWindow_CreateSlider", KMTE.MainWindow, "ZO_Slider")
		CreateSlider:SetDimensions(100, 15)
		CreateSlider:SetAnchor(LEFT, Create_MAIN, RIGHT, 40, 0)
		CreateSlider:SetOrientation(ORIENTATION_HORIZONTAL)
		CreateSlider:SetMinMax(1,1)
		CreateSlider:SetValueStep(1) 
		CreateSlider:SetMouseEnabled(true)
--		CreateSlider:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
--		CreateSlider:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		if CreateSlider:GetHandler("OnValueChanged") == nil then CreateSlider:SetHandler("OnValueChanged", function(self, value, eventReason)
			if eventReason == EVENT_REASON_SOFTWARE then return end
--			self:SetValue(value)	--do we actually need this line?
			self.selText:SetText(value)	
			end)
		end
		CreateSlider:SetHidden(true)
--		Create_MAIN:SetMovable(false)
		CreateSlider:SetDrawLevel(2)
		CreateSlider.Hidden = true

	CreateSlider.selText = WINDOW_MANAGER:CreateControl(nil, CreateSlider, CT_LABEL)
	local selText = CreateSlider.selText
	selText.Color=COLOR_KHRILLSELECT
	selText:SetFont("ZoFontGame")
	selText:SetColor(HexToRGBA(selText.Color))
	selText:SetAnchor(TOP, CreateSlider, BOTTOM)
	selText:SetText("1")

	CreateSlider.minText = WINDOW_MANAGER:CreateControl(nil, CreateSlider, CT_LABEL)
	local minText = CreateSlider.minText
	minText.Color=COLOR_DISABLED
	minText:SetFont("ZoFontGameSmall")
	minText:SetColor(HexToRGBA(minText.Color))
	minText:SetAnchor(RIGHT, CreateSlider, LEFT,-10)
	minText:SetText("1")

	CreateSlider.maxText = WINDOW_MANAGER:CreateControl(nil, CreateSlider, CT_LABEL)
	local maxText = CreateSlider.maxText
	maxText.Color=COLOR_DISABLED
	maxText:SetFont("ZoFontGameSmall")
	maxText:SetColor(HexToRGBA(maxText.Color))
	maxText:SetAnchor(LEFT, CreateSlider, RIGHT,10)
	maxText:SetText("1")

	-- ToolTip for create glyph
	local tooltip = WINDOW_MANAGER:CreateControlFromVirtual("KMTE_MainWindow_Tooltip", KMTE.MainWindow, "ZO_ItemIconTooltip")
	    tooltip:ClearAnchors()
	    tooltip:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 5, 660)
	    tooltip:SetHidden(true)
	    tooltip:SetClampedToScreen(true)
	    tooltip:SetMouseEnabled(true)
	    tooltip:SetMovable(true)
		tooltip.Hidden = true
	    --tooltip:SetExcludeFromResizeToFitExtents(true)
	KMTE.Tooltip = tooltip
end

function KMTE:CreateChoiceGlyph()
	local iconSize = 32
	local iconSpacing = 5
	local PaddingX = 520 --550
	local PaddingY = 100 
	local runeArmor = KMTE.default_rune["Armor"]
	local runeWeapon = KMTE.default_rune["Weapon"]
	local runeJewel = KMTE.default_rune["Jewel"]

	-- 3 glyph types
	KMTE:CreateButtonUI("Glyph", 60, runeArmor, PaddingX, PaddingY)
	
	PaddingX = PaddingX + (iconSize+iconSpacing)*3 +30
	KMTE:CreateButtonUI("Glyph", 61, runeWeapon, PaddingX, PaddingY)

	PaddingX = PaddingX + (iconSize+iconSpacing)*3 +30
	KMTE:CreateButtonUI("Glyph", 62, runeJewel, PaddingX, PaddingY)

	-- ToolTip for destroy glyph info
	local tooltip = WINDOW_MANAGER:CreateControlFromVirtual("KMTE_MainWindow_DestroyTooltip", KMTE.MainWindow, "ZO_ItemIconTooltip")
		tooltip.Hidden = true
	    tooltip:ClearAnchors()
	    tooltip:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 510, 660)
	    tooltip:SetHidden(true)
	    tooltip:SetClampedToScreen(true)
	    tooltip:SetMouseEnabled(true)
	    tooltip:SetMovable(true)
	    tooltip:SetExcludeFromResizeToFitExtents(true)

	-- select title
	local title = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Choice", KMTE.MainWindow, CT_LABEL)
		title:SetDimensions(350, 100)
		title:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 500,60)
		title:SetHorizontalAlignment(1)
		title:SetScale(1.2)
		title:SetAlpha(1)
		title:SetFont("ZoFontGame")
		title:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		title:SetStyleColor(0,0,0,1)
		title:SetDrawLevel(DL_CONTROLS)
		title:SetHidden(false)
		title:SetText(KMTE.langString.KMTESettings_choice)
	
	-- destroy glyph button
	local Destroy_MAIN = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_DestroyGlyph", KMTE.MainWindow, CT_BUTTON)
		Destroy_MAIN.Hidden = true
		Destroy_MAIN:SetDimensions(150, 40)
		Destroy_MAIN:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 640, 590)
		if Destroy_MAIN:GetHandler("OnClicked") == nil then Destroy_MAIN:SetHandler("OnClicked", DestroyGlyph) end
		Destroy_MAIN:SetMouseEnabled(true)
		Destroy_MAIN:SetHidden(true)
		Destroy_MAIN:SetMovable(false)
		Destroy_MAIN:SetDrawLevel(2)
	local Destroy_OUTLINE = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_DestroyGlyph_Outline", Destroy_MAIN, CT_TEXTURE)
		Destroy_OUTLINE.Color=COLOR_KHRILLSELECT
		Destroy_OUTLINE:SetDimensions(iconSize, iconSize)
		Destroy_OUTLINE:SetAnchor(TOPLEFT, Destroy_MAIN, TOPLEFT)
		Destroy_OUTLINE:SetAnchorFill(Destroy_MAIN)
		Destroy_OUTLINE:SetTexture(TEXTURE_OUTLINE)
		Destroy_OUTLINE:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		Destroy_OUTLINE:SetHidden(false)
	local Destroy_TEXT = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_DestroyGlyph_Text", Destroy_MAIN, CT_LABEL)
		Destroy_TEXT.Color=COLOR_KHRILLSELECT
		Destroy_TEXT.Hidden = false
		Destroy_TEXT:SetDimensions(140,iconSize)
		Destroy_TEXT:SetHorizontalAlignment(1)
		Destroy_TEXT:SetVerticalAlignment(1)
		Destroy_TEXT:SetScale(1)
		Destroy_TEXT:SetAnchor(TOPLEFT, Destroy_MAIN, TOPLEFT, 5, 4)
		Destroy_TEXT:SetAlpha(1)
		Destroy_TEXT:SetFont("ZoFontGame")
		Destroy_TEXT:SetColor(HexToRGBA(Destroy_TEXT.Color))
		Destroy_TEXT:SetStyleColor(0,0,0,1)
		Destroy_TEXT:SetDrawLevel(2)
		Destroy_TEXT:SetHidden(false)
		Destroy_TEXT:SetText(KMTE.langString.KMTESettings_glyph_destroyall)
	-- cancel button
	local Cancel_MAIN = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Cancel", KMTE.MainWindow, CT_BUTTON)
		Cancel_MAIN.Hidden = true
		Cancel_MAIN:SetDimensions(150, 40)
		Cancel_MAIN:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, 640, 590)
		if Cancel_MAIN:GetHandler("OnClicked") == nil then Cancel_MAIN:SetHandler("OnClicked", CancelCraft) end
		Cancel_MAIN:SetMouseEnabled(true)
		Cancel_MAIN:SetHidden(true)
		Cancel_MAIN:SetMovable(false)
		Cancel_MAIN:SetDrawLevel(2)
	local Cancel_OUTLINE = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Cancel_Outline", Cancel_MAIN, CT_TEXTURE)
		Cancel_OUTLINE.Color=COLOR_KHRILLSELECT
		Cancel_OUTLINE:SetDimensions(iconSize, iconSize)
		Cancel_OUTLINE:SetAnchor(TOPLEFT, Cancel_MAIN, TOPLEFT)
		Cancel_OUTLINE:SetAnchorFill(Cancel_MAIN)
		Cancel_OUTLINE:SetTexture(TEXTURE_OUTLINE)
		Cancel_OUTLINE:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		Cancel_OUTLINE:SetHidden(false)
	local Cancel_TEXT = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_Cancel_Text", Cancel_MAIN, CT_LABEL)
		Cancel_TEXT.Color=COLOR_KHRILLSELECT
		Cancel_TEXT.Hidden = false
		Cancel_TEXT:SetDimensions(140,iconSize)
		Cancel_TEXT:SetHorizontalAlignment(1)
		Cancel_TEXT:SetVerticalAlignment(1)
		Cancel_TEXT:SetScale(1)
		Cancel_TEXT:SetAnchor(TOPLEFT, Cancel_MAIN, TOPLEFT, 5, 4)
		Cancel_TEXT:SetAlpha(1)
		Cancel_TEXT:SetFont("ZoFontGame")
		Cancel_TEXT:SetColor(HexToRGBA(Cancel_TEXT.Color))
		Cancel_TEXT:SetStyleColor(0,0,0,1)
		Cancel_TEXT:SetDrawLevel(2)
		Cancel_TEXT:SetHidden(false)
		Cancel_TEXT:SetText(KMTE.langString.KMTESettings_cancelcraft)
end

function KMTE:CreateRuneUI(typeRune, order, Rune)
	local iconSize = 32
	local iconSpacing = 3
	local PaddingX = math.floor((order-1)/17)*(iconSize+iconSpacing)*3
	local PaddingY = (((order-1)%17)-math.floor(math.abs(math.floor((order-18)/17)+0.5)))*(iconSize+iconSpacing)+20
	local scaleText = nil
	
	if typeRune == "Armor" or typeRune == "Weapon" or typeRune == "Jewel" then
		PaddingX = 520 + PaddingX + 30*math.floor((order-1)/17) --550 + PaddingX
		PaddingY = 120 + PaddingY
		scaleText = 0.7
	end
	KMTE:CreateButtonUI(typeRune, order, Rune, PaddingX, PaddingY, scaleText)
end

function KMTE:CreateButtonUI(typeRune, order, Rune, PaddingX, PaddingY, scaleText)
	local ICON_TEXTURE = Rune.icon
	local iconSize = 32
	local iconSpacing = 3
	local button = getControl(KMTE.MainWindow, typeRune.."_"..Rune.name..Rune.quality)

	if button ~= nil then
		--update
		button.Rune = Rune
		button:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, PaddingX, PaddingY)
		majNumberButton(button, Rune.stack)
		button:SetHidden(false)
	else
		--new
		RUNE_MAIN[order] = nil
		RUNE_OUTLINE[order] = nil
		RUNE_ICON[order] = nil
		RUNE_NUMBER[order] = nil
		RUNE_TEXT[order] = nil
		
--		d("--CreateButtonUI: "..order..", "..typeRune..", "..Rune.name..", "..Rune.quality.." *"..Rune.stack)
		
		RUNE_MAIN[order] = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_"..typeRune.."_"..Rune.name..Rune.quality, KMTE.MainWindow, CT_BUTTON)
			RUNE_MAIN[order].typeRune = typeRune
			RUNE_MAIN[order].Rune = Rune
			RUNE_MAIN[order]:SetDimensions(iconSize*3, iconSize)
			RUNE_MAIN[order]:SetAnchor(TOPLEFT, KMTE.MainWindow, TOPLEFT, PaddingX, PaddingY)
			if RUNE_MAIN[order]:GetHandler("OnClicked") == nil then RUNE_MAIN[order]:SetHandler("OnClicked", SelectRune) end
			RUNE_MAIN[order]:SetMouseEnabled(true)
			RUNE_MAIN[order]:SetHidden(false)
			RUNE_MAIN[order]:SetMovable(false)
			RUNE_MAIN[order]:SetDrawLevel(2)
			
		 RUNE_OUTLINE[order] = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_"..typeRune.."_"..Rune.name..Rune.quality.."_Outline", RUNE_MAIN[order], CT_TEXTURE)
			RUNE_OUTLINE[order].Color="00000000"
			RUNE_OUTLINE[order].Hidden = true
			RUNE_OUTLINE[order]:SetDimensions(iconSize, iconSize)
			RUNE_OUTLINE[order]:SetAnchor(TOPLEFT, RUNE_MAIN[order], TOPLEFT)
			RUNE_OUTLINE[order]:SetTexture(TEXTURE_OUTLINE)
			RUNE_OUTLINE[order]:SetColor(0,0,0,0)
			RUNE_OUTLINE[order]:SetHidden(true)
		
		 RUNE_ICON[order] = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_"..typeRune.."_"..Rune.name..Rune.quality.."_Icon", RUNE_MAIN[order], CT_TEXTURE)
			RUNE_ICON[order]:SetDimensions(iconSize, iconSize)
			RUNE_ICON[order]:SetAnchor(TOPLEFT, RUNE_MAIN[order], TOPLEFT)
			if not Rune.known and not(Rune.stack == 0 and KMTE.settings.AllRunesMode) then
				RUNE_ICON[order]:SetColor(HexToRGBA(COLOR_DISABLED))
				RUNE_ICON[order]:SetTexture(TEXTURE_RUNEUNKNOWN)
			else
				RUNE_ICON[order]:SetTexture(ICON_TEXTURE)
			end
			RUNE_ICON[order]:SetHidden(false)
		
		 RUNE_NUMBER[order] = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_"..typeRune.."_"..Rune.name..Rune.quality.."_Number", RUNE_MAIN[order], CT_LABEL)
			RUNE_NUMBER[order].Color = COLOR_RUNENUMBER
			RUNE_NUMBER[order].Quality = Rune.quality
			RUNE_NUMBER[order]:SetDimensions(iconSize,iconSize)
			RUNE_NUMBER[order]:SetVerticalAlignment(1)
			RUNE_NUMBER[order]:SetHorizontalAlignment(1)
			RUNE_NUMBER[order]:SetScale(1)
			RUNE_NUMBER[order]:SetAnchor(TOPLEFT, RUNE_MAIN[order], TOPLEFT, 2, 5)
			RUNE_NUMBER[order]:SetAlpha(1)
			RUNE_NUMBER[order]:SetFont("ZoFontGame")
			RUNE_NUMBER[order]:SetColor(1,0.98,0.8,1)
			RUNE_NUMBER[order]:SetStyleColor(0,0,0,1)
			RUNE_NUMBER[order]:SetDrawLevel(2)
			RUNE_NUMBER[order]:SetHidden(false)
			RUNE_NUMBER[order]:SetText(Rune.stack)
		
		RUNE_TEXT[order] = WINDOW_MANAGER:CreateControl("KMTE_MainWindow_"..typeRune.."_"..Rune.name..Rune.quality.."_Text", RUNE_MAIN[order], CT_LABEL)
			if Rune.known then
				RUNE_TEXT[order].Color = COLOR_QUALITY[Rune.quality]
			else
				RUNE_TEXT[order].Color = COLOR_RUNEUNKNOWN
			end
--			RUNE_TEXT[order].Hidden = false
			RUNE_TEXT[order].Quality = Rune.quality
			if typeRune == "Armor" or typeRune == "Weapon" or typeRune == "Jewel"  then
				RUNE_TEXT[order]:SetDimensions(140,50)
			else
				RUNE_TEXT[order]:SetDimensions(110,50)
			end
			RUNE_TEXT[order]:SetVerticalAlignment(1)
			if scaleText ~= nil then
				RUNE_TEXT[order]:SetScale(scaleText)
			else
				RUNE_TEXT[order]:SetScale(1)
			end
			RUNE_TEXT[order]:SetAnchor(TOPLEFT, RUNE_MAIN[order], TOPLEFT, iconSize+iconSpacing, -4)
			RUNE_TEXT[order]:SetAlpha(1)
			RUNE_TEXT[order]:SetFont("ZoFontGame")
--			RUNE_TEXT[order]:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
			RUNE_TEXT[order]:SetColor(HexToRGBA(RUNE_TEXT[order].Color))
			RUNE_TEXT[order]:SetStyleColor(0,0,0,1)
			RUNE_TEXT[order]:SetDrawLevel(2)
			RUNE_TEXT[order]:SetHidden(false)
			if typeRune == "Glyph" then
				if Rune.name == "Armor" then RUNE_TEXT[order]:SetText(KMTE.langString.KMTESettings_glyph_Armor) end
				if Rune.name == "Weapon" then RUNE_TEXT[order]:SetText(KMTE.langString.KMTESettings_glyph_Weapon) end
				if Rune.name == "Jewel" then RUNE_TEXT[order]:SetText(KMTE.langString.KMTESettings_glyph_Jewel) end
			else
				RUNE_TEXT[order]:SetText(Rune.name)
			end
			RUNE_TEXT[order].RuneName = RUNE_TEXT[order]:GetText()
			RUNE_TEXT[order].Info = Rune.info
			RUNE_TEXT[order].Label = Rune.label

			-- BG special => text color modified
			if KMTE.settings.BG == 3 then --rubbingbook (-> invert white with black)
				KMTE:ModifyTextColor(RUNE_MAIN[order], COLOR_RUNEUNKNOWN, COLOR_QUALITY[0])
			end
	end
end
function KMTE:RemoveButtonUI(typeRune, Rune)
	--d("--removebuttonui : "..typeRune.."_"..Rune.name)
	local selButton = getControl(KMTE.MainWindow,typeRune.."_"..Rune.name..Rune.quality)
	if selButton ~= nil then
		activeControl(selButton, false)
		showControl(KMTE.MainWindow, typeRune.."_"..Rune.name..Rune.quality, false)
--		KMTE:ClearBag(typeRune)
	end
end

function KMTE:CleanRuneUI()
	KMTE:CleanRuneUI(nil)
end
function KMTE:CleanRuneUI(typeRune)
	-- delete all Runes button and objet with Hidden in MainWindow
--	d("--CleanUI "..tostring(typeRune))
	for i=1,KMTE.MainWindow:GetNumChildren() do
		if (KMTE.MainWindow:GetChild(i).typeRune ~= "Glyph" and KMTE.MainWindow:GetChild(i).typeRune ~= nil) or (KMTE.MainWindow:GetChild(i).Hidden and KMTE.MainWindow:GetChild(i).Hidden ~= nil) then
			if typeRune == nil or KMTE.MainWindow:GetChild(i).typeRune == typeRune then
				selectControl(KMTE.MainWindow:GetChild(i), nil, false)
				KMTE.MainWindow:GetChild(i):SetHidden(true)
			end
		end
	end
end

function KMTE:UpdateTextColorRuneUI(colorQuality01, colorRuneUnknown)
	-- update all Runes + glyphs text button in MainWindow (BG texture changed)
--d("--UpdateTextColorRuneUI "..tostring(colorQuality01))
	for i=1,KMTE.MainWindow:GetNumChildren() do
		if KMTE.MainWindow:GetChild(i) ~= nil then
			if (KMTE.MainWindow:GetChild(i).typeRune ~= nil) then
				KMTE:ModifyTextColor(KMTE.MainWindow:GetChild(i), colorQuality01, colorRuneUnknown)
			end
			for j=1,KMTE.MainWindow:GetChild(i):GetNumChildren() do
				if KMTE.MainWindow:GetChild(i):GetChild(j) ~= nil then
					if (KMTE.MainWindow:GetChild(i):GetChild(j).typeRune ~= nil) then
						KMTE:ModifyTextColor(KMTE.MainWindow:GetChild(i), colorQuality01, colorRuneUnknown)
					end
				end
			end
		end
	end
end		
		
function KMTE:ModifyTextColor(ButtonUI, colorQuality01, colorRuneUnknown)
	--change text color of a buttonUI
	local Rune = ButtonUI.Rune
	local textControl = getControl(ButtonUI, "Text")
	if Rune.known then
		if Rune.quality < 2 then textControl.Color = colorQuality01 end
	else
		textControl.Color = colorRuneUnknown
	end
	textControl:SetColor(HexToRGBA(textControl.Color))
end

function KMTE:OpenUI()
	--other addons
	if KMTE.activeAddon.WeaponChargeAlert then WeaponChargeAlert_Hide(true) end --hide
	if KMTE.activeAddon.GearSwap then GearSwap_Hide(true) end --hide

	EVENT_MANAGER:RegisterForEvent(KMTE.name, EVENT_CRAFT_COMPLETED, function(eventCode, craftSkill) if craftSkill == CRAFTING_TYPE_ENCHANTING then KMTE:OnCraftCompleted() end end)
	EVENT_MANAGER:RegisterForEvent(KMTE.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason) if isNewItem then KMTE:OnNewItem(bagId, slotId) end end)	
	KMTE:CreateMsgWnd()
	KMTE_MainWindow:SetHidden(false)
	PlaySound(SOUNDS.BOOK_OPEN)
	KMTE:ScanRunes()

	if KMTE.settings.EsoUiFade then
		-- masking ESO UI
		_G["ZO_EnchantingTopLevelInventory"]:SetAlpha(0.2)
		_G["ZO_EnchantingTopLevelRuneSlotContainer"]:SetAlpha(0)
		_G["ZO_EnchantingTopLevelExtractionSlotContainer"]:SetAlpha(0)
		_G["ZO_EnchantingTopLevelTooltip"]:SetAlpha(0)	
	end
	
	-- check xp gain
	if KMTE.settings.XPMode then EVENT_MANAGER:RegisterForEvent(KMTE.name, EVENT_SKILL_XP_UPDATE, function(eventCode, skillType, skillIndex, reason, rank, previousXP, currentXP) if reason == PROGRESS_REASON_TRADESKILL then KMTE:OnSkillXP(skillType, skillIndex, previousXP, currentXP) end end) end
end
function KMTE:CloseUI()
--	if KMTE.isStation then
		-- restore ESO UI
		_G["ZO_EnchantingTopLevelInventory"]:SetAlpha(1)
		_G["ZO_EnchantingTopLevelRuneSlotContainer"]:SetAlpha(1)
		_G["ZO_EnchantingTopLevelExtractionSlotContainer"]:SetAlpha(1)
		_G["ZO_EnchantingTopLevelTooltip"]:SetAlpha(1)
		
--		KMTE.isStation = false
		KMTE_MainWindow:SetHidden(true)
		if KMTE.MsgWindow ~= nil then KMTE.MsgWindow:SetHidden(true) end
		PlaySound(SOUNDS.BOOK_CLOSE) --COMBO_CLICK
		EVENT_MANAGER:UnregisterForEvent(KMTE.name, EVENT_CRAFT_COMPLETED)
		EVENT_MANAGER:UnregisterForEvent(KMTE.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		if KMTE.settings.XPMode then EVENT_MANAGER:UnregisterForEvent(KMTE.name, EVENT_SKILL_XP_UPDATE) end

		--other addons
		if KMTE.activeAddon.WeaponChargeAlert then WeaponChargeAlert_Hide(false) end
		if KMTE.activeAddon.GearSwap then GearSwap_Hide(false) end
--	end
end

function KMTE:SaveAnchor()
	-- Save the new position of windows
--d("--SaveAnchor")
	local offsetX = KMTE_MainWindow:GetLeft()
	local offsetY = KMTE_MainWindow:GetTop()
--	d("="..offsetX..","..offsetY)
	KMTE.settings.OffsetX = offsetX
	KMTE.settings.OffsetY = offsetY
end
function KMTE:CreateMsgWnd()
	-- Message Window (LibMsgWin)
	if KMTE.MsgWindow == nil then
		KMTE.MsgWindow = LIBMW:CreateMsgWindow((KMTE.name.."Msg"):gsub(" ",""), "|c"..COLOR_TITLE.."Merlin|r - |c"..COLOR_KHRILLSELECT.."Messages|r", 20000, 2000)
	end
	KMTE.MsgWindow:SetHidden(true)
	KMTE.MsgWindow:SetDimensions(300, 300)
	KMTE.MsgWindow:ClearAnchors()
	KMTE.MsgWindow:SetAnchor(BOTTOM, ZO_ChatWindowBg, TOPLEFT, 0, 0)
	KMTE.MsgWindow:ChangeTextFade(20000, 2000)	
end

-- // **********
-- //    Init
-- // **********
function KMTE:GetLanguage()
	local lang = GetCVar("language.2")

	--check for supported languages
	if (lang == "fr") then return lang end
	if (lang == "de") then return lang end
	if (lang == "es") then return lang end

	--return english if not supported
	return "en"
end
function KMTE:GetOffsetX()
	if KMTE.settings.SavePosition then
		return KMTE.settings.OffsetX
	else
		return GuiRoot:GetWidth() * 0.19
	end
end
function KMTE:GetOffsetY()
	if KMTE.settings.SavePosition then
		return KMTE.settings.OffsetY
	else
		return GuiRoot:GetHeight() * 0.09
	end
end

function KMTE:registerEvents(state)
	if state then
		EVENT_MANAGER:RegisterForEvent(KMTE.name, EVENT_CRAFTING_STATION_INTERACT, function(eventCode, craftSkill, sameStation) if craftSkill == CRAFTING_TYPE_ENCHANTING then KMTE:OnCrafting(sameStation) end end)
		EVENT_MANAGER:RegisterForEvent(KMTE.name, EVENT_END_CRAFTING_STATION_INTERACT, function(eventCode) if KMTE.isStation then KMTE:OnCraftEnd() end end)
--		EVENT_MANAGER:RegisterForEvent(KMTE.name, EVENT_END_CRAFTING_STATION_INTERACT, function(eventCode) d(eventCode, GetCraftingInteractionType(),GetInteractionType(),CRAFTING_TYPE_ENCHANTING) if GetCraftingInteractionType() == CRAFTING_TYPE_ENCHANTING then KMTE:OnCraftEnd() end end)
	else
		EVENT_MANAGER:UnregisterForEvent(KMTE.name, EVENT_CRAFTING_STATION_INTERACT)
		EVENT_MANAGER:UnregisterForEvent(KMTE.name, EVENT_CRAFT_COMPLETED)
		EVENT_MANAGER:UnregisterForEvent(KMTE.name, EVENT_END_CRAFTING_STATION_INTERACT)
	end
	--activate or not button on ESO UI
	KMTE:ToggleEnableBtn(KMTE.settings.EnableButton)
end
function KMTE:OnInit(eventCode, addOnName)
	-- check addons compatibility is active?
	if ( addOnName == "ItemSaver") then KMTE.activeAddon.itemSaver = true end
	if ( addOnName == "FCOItemSaver") then KMTE.activeAddon.FCOitemSaver = true end
	if ( addOnName == "WeaponChargeAlert") then KMTE.activeAddon.WeaponChargeAlert = true end
	if ( addOnName == "GearSwap") then KMTE.activeAddon.GearSwap = true end
	
    if ( addOnName ~= KMTE.name) then return end
	
	KMTE.langString = KMTE_Lang[KMTE:GetLanguage()]
	KMTE.resetRunes = KMTE_DB
	KMTE.settings = ZO_SavedVars:New(KMTE.name .. "_settings", 1, nil, KMTE.defaults)
	KMTE.accountSettings = ZO_SavedVars:NewAccountWide(KMTE.name .. "_settings", 1, nil, KMTE.accountDefaults)
	KMTE.InfoMode = KMTE.settings.InfoMode
	KMTE.LabelMode = KMTE.settings.LabelMode
	--bindings
	ZO_CreateStringId("SI_BINDING_NAME_KMTEENABLE", KMTE.langString.SI_BINDING_NAME_KMTEENABLE)
	ZO_CreateStringId("SI_BINDING_NAME_KMTETOGGLE", KMTE.langString.SI_BINDING_NAME_KMTETOGGLE)
	
	-- init settings panel
	KMTE:CommandOptionPanel()
	-- init UI
	KMTE:CreateMainUI()
	KMTE:CreateChoiceGlyph()
	KMTE.MainWindow:SetDrawLayer(DL_BACKGROUND)

	--if KMTE.settings.Enable then KMTE:registerEvents(true) end
	KMTE:registerEvents(true) --KMTE.settings.Enable)
--	EVENT_MANAGER:UnregisterForEvent(KMTE.name, EVENT_ADD_ON_LOADED)
end

-- // **********
-- //  Settings
-- // **********
function KMTE:ToggleEnable(value)
	KMTE.settings.Enable = value
	KMTE:registerEvents(KMTE.settings.Enable)
end
function KMTE:ToggleEnableBtn(value)
	KMTE.settings.EnableButton = value
	--need to clear anchor of the menu bar so the button won't move the wole bar to the left!
--    ZO_EnchantingTopLevelModeMenuBar:ClearAnchors()
    --Create and add the button with textures, tooltip and callback function
	--parent, name, callbackFunction, text, font, tooltipText, tooltipAlign, textureNormal, textureMouseOver, textureClicked, width, height, left, top, alignValue, alignControl, hideButton
	local oppositeTexture = 3
	if KMTE.settings.BG == 3 then oppositeTexture = 1 end --rubbing book
    addButton(ZO_EnchantingTopLevelModeMenu, "ZO_EnchantingTopLevelModeMenuButtonShowMerlinTheEnchanter", KMTE_ToggleByKey, nil, nil, "|c"..COLOR_KHRILLSELECT..KMTE.langString.SI_BINDING_NAME_KMTETOGGLE.." "..KMTE.langString.KMTESettings_title.."|r", TOP, KMTE.BGTextures[KMTE.settings.BG], KMTE.BGTextures[oppositeTexture], KMTE.BGTextures[oppositeTexture], 48, 48, 50, 0, TOPLEFT, ZO_EnchantingTopLevelModeMenu, not KMTE.settings.EnableButton)
end
function KMTE:CheckforOtherAddons()
--Check if other addons are activated
	-- Check for ItemSaver&FCOItemSaver addons
	if KMTE.activeAddon.itemSaver or ItemSaver_IsItemSaved ~= nil  then
--	if KMTE.activeAddon.itemSaver or ItemSaver_IsDeconstructionFiltered ~= nil  then
		-- addon ItemSaver ok -> check if filter enable
		KMTE.itemSaverFilter = KMTE.settings.ItemSaver
	end
    if KMTE.activeAddon.FCOitemSaver or FCOIsMarked ~= nil then
    	-- addon FCOItemSaver ok -> check if enabled
		KMTE.FCOitemSaverFilter = KMTE.settings.FCOItemSaver
	end
end
function KMTE:SelectBGTexture(value)
	-- change BG texture -> adapt text colors
--	KMTE.settings.BG = value
	KMTE.settings.BG = getKeyByValue(KMTE.BGTexturesLabel, value)

	GetControl("KMTE_BGPreview"):SetTexture(KMTE.BGTextures[KMTE.settings.BG])
	GetControl("KMTE_MainWindow_BG"):SetTexture(KMTE.BGTextures[KMTE.settings.BG])	
	
	if KMTE.settings.BG == 3 then --rubbingbook (-> invert white with black)
		KMTE:UpdateTextColorRuneUI(COLOR_RUNEUNKNOWN, COLOR_QUALITY[0])
	else --default color
		KMTE:UpdateTextColorRuneUI(COLOR_QUALITY[0], COLOR_RUNEUNKNOWN)
	end
end

function KMTE:CommandOptionPanel()
	--// Settings panel LAM2
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if ( not LAM2 ) then return end
	
	local ADDON_NAME="Merlin the Enchanter"
	local ADDON_VERSION="v"..KMTE.version
	local panelData = {
			type = "panel",
			name = ADDON_NAME,
			displayName = "|cFF6A00".. ADDON_NAME .."|r (" .. KMTE.langString.LOCALE .. ")",
			author = "|cFF6A00Khrill|r",
			version = ADDON_VERSION,
			slashCommand = "/merlincfg",
			registerForRefresh = true,
			registerForDefaults = true,
	}
	local settingsPanel = LAM2:RegisterAddonPanel(ADDON_NAME, panelData)

	local optionsTable = {
		------------GENERAL--------------
		{ -- Enable
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.Enable end,
			setFunc = function(value) KMTE:ToggleEnable(value) end,
			width = "full",	
			default = KMTE.defaults.Enable,
		},
		{ -- Enable button
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enableBtn,
			tooltip = KMTE.langString.KMTESettings_enableBtn,
			getFunc = function() return KMTE.settings.EnableButton end,
			setFunc = function(value) KMTE:ToggleEnableBtn(value) end,
			width = "full",	
			default = KMTE.defaults.EnableButton,
		},
		{
			type = "header",
			name = "|c"..COLOR_TITLE..KMTE.langString.KMTESettings_control.."|r",
			width = "full",	
		},
		{	-- All Runes
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title12.."|r",
			text = KMTE.langString.KMTESettings_description12,
			width = "full",	
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.AllRunesMode end,
			setFunc = function(value) KMTE.settings.AllRunesMode = value end,
			width = "full",	
			default = KMTE.defaults.AllRunesMode,
		},
		{	-- display Rune info
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title1_1.."|r",
			text = KMTE.langString.KMTESettings_description1_1,
			width = "full",	
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.InfoMode end,
			setFunc = function(value)
						if value then KMTE.settings.LabelMode = false end
						KMTE.settings.InfoMode = value
			end,
			width = "full",	
			default = KMTE.defaults.InfoMode,
		},
		{	-- display glyph label
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title1_2.."|r",
			text = KMTE.langString.KMTESettings_description1_2,
			width = "full",	
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.LabelMode end,
			setFunc = function(value)
						if value then KMTE.settings.InfoMode = false end
						KMTE.settings.LabelMode = value
			end,
			width = "full",	
			default = KMTE.defaults.LabelMode,
		},
		{	-- Keep quality
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title2.."|r",	
			text = KMTE.langString.KMTESettings_description2_1,
			width = "full",	
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.KeepQualityMode end,
			setFunc = function(value) KMTE.settings.KeepQualityMode = value end,
			width = "full",
			default = KMTE.defaults.KeepQualityMode,
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_description2_2,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.BracketMode end,
			setFunc = function(value) KMTE.settings.BracketMode = value end,
			width = "full",
			default = KMTE.defaults.BracketMode,
			disabled = function() return not KMTE.settings.KeepQualityMode end,
		},
		{	-- Show XP
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title3.."|r",
			text = KMTE.langString.KMTESettings_description3,
			width = "full",	
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.XPMode end,
			setFunc = function(value) KMTE.settings.XPMode = value end,
			width = "full",	
			default = KMTE.defaults.XPMode,
		},
		{	-- Show gain
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title6.."|r",
			text = KMTE.langString.KMTESettings_description6,
			width = "full",	
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.NewItem end,
			setFunc = function(value) KMTE.settings.NewItem = value end,
			width = "full",
			default = KMTE.defaults.NewItem,
		},
		{	-- Link
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title4.."|r",
			text = KMTE.langString.KMTESettings_description4,
			width = "full",
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.LinkChat end,
			setFunc = function(value) KMTE.settings.LinkChat=value end,
			width = "full",
			default = KMTE.defaults.LinkChat,
		},
		{	-- Msg window
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title10.."|r",
			text = KMTE.langString.KMTESettings_description10,
			width = "full",
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.MsgWindow end,
			setFunc = function(value) KMTE.settings.MsgWindow=value end,
			width = "full",
			default = KMTE.defaults.MsgWindow,
		},
		------------INTERFACE--------------
		{
			type = "header",
			name = "|c"..COLOR_TITLE..KMTE.langString.KMTESettings_Interface.."|r",
			width = "full",
		},
		{	-- potency first (instead of essence)
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title8.."|r",
			text = KMTE.langString.KMTESettings_description8,
			width = "full",	
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.PotencyFirst end,
			setFunc = function(value)
						KMTE.settings.PotencyFirst = value
						ReloadUI()
			end,
			width = "full",	
			default = KMTE.defaults.PotencyFirst,
			warning = KMTE.langString.KMTESettings_warning,
		},
		{	-- BG texture (with preview)
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_BGTitle.."|r",
			text = KMTE.langString.KMTESettings_BGTexture.." ==>",
			width = "full",
		},
		{
			type = "dropdown",
			name = KMTE.langString.KMTESettings_choose,
			choices = KMTE.BGTexturesLabel,
			getFunc = function() return KMTE.BGTexturesLabel[KMTE.settings.BG] end,
			setFunc = function(value) KMTE:SelectBGTexture(value) end,
			width = "full",
			default = KMTE.BGTexturesLabel[KMTE.defaults.BG],
			reference = "KMTE_BGPreview_Dropdown"
		},
		{	-- ESO UI fade
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title9.."|r",
			text = KMTE.langString.KMTESettings_description9,
			width = "full",	
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.EsoUiFade end,
			setFunc = function(value) KMTE.settings.EsoUiFade = value end,
			width = "full",	
			default = KMTE.defaults.EsoUiFade,
		},
		{	-- Save position
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title11.."|r",
			text = KMTE.langString.KMTESettings_description11,
			width = "full",	
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.SavePosition end,
			setFunc = function(value) KMTE.settings.SavePosition = value end,
			width = "full",	
			default = KMTE.defaults.SavePosition,
		},
		------------ADDONS COMPATIBILITY--------------
		{
			type = "header",
			name = "|c"..COLOR_TITLE..KMTE.langString.KMTESettings_AddonCompatibility.."|r",
			width = "full",
		},
		{	-- ItemSaver
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title5.."|r",
			text = KMTE.langString.KMTESettings_description5,
			width = "full",
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.ItemSaver end,
			setFunc = function(value) KMTE.settings.ItemSaver = value end,
			width = "full",
			disabled = function() return not KMTE.activeAddon.itemSaver end,
			default = KMTE.defaults.ItemSaver,
		},
		{	-- FCOItemSaver
			type = "description",
			title = "|c"..COLOR_KHRILLSELECT..KMTE.langString.KMTESettings_title7.."|r",
			text = KMTE.langString.KMTESettings_description7,
			width = "full",
		},
		{
			type = "checkbox",
			name = KMTE.langString.KMTESettings_enable,
			tooltip = KMTE.langString.KMTESettings_enable,
			getFunc = function() return KMTE.settings.FCOItemSaver end,
			setFunc = function(value) KMTE.settings.FCOItemSaver = value end,
			width = "full",
			disabled = function() return not KMTE.activeAddon.FCOitemSaver end,
			default = KMTE.defaults.FCOItemSaver,
		},
}

	LAM2:RegisterOptionControls(ADDON_NAME, optionsTable)

	--For preview BG picture
	local preview, previewIcon
    previewIcon = function(panel)
        if panel == settingsPanel then
 			local controlPos = 25 --count control position for BG texture
            preview = WINDOW_MANAGER:CreateControl("KMTE_BGPreview", panel.controlsToRefresh[controlPos], CT_TEXTURE)
			preview:SetParent(KMTE_BGPreview_Dropdown)
			preview:SetHidden(false)
			preview:SetDimensions(100, 90)
            preview:SetAnchor(BOTTOM, panel.controlsToRefresh[controlPos].dropdown:GetControl(), TOP, 0, 12)
			preview:SetMouseEnabled(true)
			if KMTE.BGTextures[KMTE.settings.BG] ~= nil then preview:SetTexture(KMTE.BGTextures[KMTE.settings.BG]) end

            CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", previewIcon)
        end
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", previewIcon)
end

EVENT_MANAGER:RegisterForEvent(KMTE.name, EVENT_ADD_ON_LOADED , function(_event, _name) KMTE:OnInit(_event, _name) end)

SLASH_COMMANDS["/merlin"] = function()
	KMTE_ToggleByKey()
end

SLASH_COMMANDS["/kmtedebug"] = function()
	d("-- KMTE Debug --")
	KMTE.isDebug = not KMTE.isDebug
	d(KMTE.isDebug)
end
-- SLASH_COMMANDS["/kmtelist"] = function()
	-- d(KMTE.MainWindow:GetNumChildren() )
	-- for i=1,KMTE.MainWindow:GetNumChildren() do
		-- d(KMTE.MainWindow:GetChild(i):GetName()) 
		-- d(KMTE.MainWindow:GetChild(i):GetNumChildren()) 
		-- if KMTE.MainWindow:GetChild(i):GetNumChildren() > 0 then
			-- for j=1,KMTE.MainWindow:GetChild(i):GetNumChildren() do
				-- d("->"..KMTE.MainWindow:GetChild(i):GetChild(j):GetName()) 
				-- d("->"..KMTE.MainWindow:GetChild(i):GetChild(j):GetNumChildren()) 
			-- end
		-- end
	-- end
-- end