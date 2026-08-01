CCSME = {
  name = "CarosCraftStoreMarkerExtension",
  iconString = "|cff0000|t20:20:esoui/art/buttons/decline_up.dds:inheritcolor|t|r",
}
local CS = CraftStoreFixedAndImprovedLongClassName
local GS = GetString
local ttCustomColor = ZO_ColorDef:New(1,1,1)
local ccsmeDebug = false

local function buildCCSMEIconString()
	if CCSME.sV.iconColor then
		CCSME.iconString = string.format("|c%s|t20:20:%s:inheritcolor|t|r", CCSME.sV.iconColor, CCSME.sV.iconTexture)
	else
		CCSME.iconString = string.format("|t20:20:%s|t",  CCSME.sV.iconTexture)
	end
end

function CCSME.debug()
	ccsmeDebug = not ccsmeDebug
	d("CCSME debug: "..(ccsmeDebug and "on" or "off"))
end

function CCSME.ShouldShowIcon(itemLink)
	local itemType, specializedItemType = GetItemLinkItemType(itemLink)
	local need, unneed = '', ''
	
	if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then 
		need, unneed = CS.IsStyleNeeded(itemLink)
	elseif itemType == ITEMTYPE_RECIPE then
		if specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING then
		  need, unneed = CS.IsBlueprintNeeded(itemLink)
		else
		  need, unneed = CS.IsRecipeNeeded(itemLink)
		end
	elseif specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then
		need = IsCollectibleUnlocked(GetItemLinkContainerCollectibleId(itemLink)) and '' or 'need'
	end
	if need ~= '' then return true else return false end
end

-- This code is mostly copied from Kyzeragon's Set Collection Marker
function CCSME.ParseItemLinks(message, location)
    if (not message) then
        return
    end

    -- Use a table to make sure the links are unique, for gsub later
    local found = {}
    local count = 0

    for itemLink in string.gmatch(message, "(|H%d:item:.-|h|h)") do
        if (CCSME.ShouldShowIcon(itemLink)) then
            -- things to be subbed for
            found[itemLink] = CCSME.iconString .. itemLink
            count = count + 1
        end
    end

    -- No item links
    if (count == 0) then
        return message
    end

    for link, withIcon in pairs(found) do
        message = string.gsub(message, link, withIcon)
    end
    return message
end

local function SetupChatHooks()
    if CS == nil then d('[CCSME] Your current version of CraftStore is not supported at the moment.') end
    local function AddIconToSystem(origMessage)
        return CCSME.ParseItemLinks(origMessage)
    end
    local previousFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()["AddSystemMessage"]
    if (previousFormatter) then
        CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", function(...)
            return AddIconToSystem(previousFormatter(...))
        end)
    else
        CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", AddIconToSystem)
    end

    --------------------------
    -- Set up normal chat hook
    local function AddIconToMessage(messageType, fromName, text, isFromCustomerService, fromDisplayName)
        local formattedText = text
        formattedText = CCSME.ParseItemLinks(text)


        local channelInfo = ZO_ChatSystem_GetChannelInfo()[messageType]
        if (not channelInfo or not channelInfo.format) then
            return
        end

        return formattedText, channelInfo.saveTarget
    end
    local oldFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
    if (oldFormatter) then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
            local oldText = oldFormatter(messageType, fromName, text, isFromCustomerService, fromDisplayName)
            return AddIconToMessage(messageType, fromName, oldText, isFromCustomerService, fromDisplayName)
        end)
    else
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, AddIconToMessage)
    end

    -- No longer need this
    EVENT_MANAGER:UnregisterForEvent(CCSME.name.."Activated", EVENT_PLAYER_ACTIVATED)
end

local function csTTHook(control, itemLink)
	if not CCSME.sV.showKnownByAll then return end
	local itemType = GetItemLinkItemType(itemLink)
	local db = false
	if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
		db = CS.Data.style
	elseif itemType == ITEMTYPE_RECIPE then
		if IsItemLinkFurnitureRecipe(itemLink) then
			db = CS.Data.furnisher
		else
			db = CS.Data.cook
		end
	else
		return
	end
	local idInQuestion = GetItemLinkItemId(itemLink)
	local unknownBySome = false
	local actualChars = {}
	for i=1, GetNumCharacters() do
		actualChars[zo_strformat("<<C:1>>", GetCharacterInfo(i))] = true
	end
	for charName, knowledge in pairs(db.knowledge) do
		if actualChars[charName] then
			if not knowledge[idInQuestion] or type(knowledge[idInQuestion]) == "table" and not knowledge[idInQuestion][value] then 
				if ccsmeDebug then d("Unknown: "..charName) end
				unknownBySome = true 
				break
			end
			if unknownBySome and not ccsmeDebug then break end
		end
	end
	
	if unknownBySome then return end
	
	if CCSME.sV.autoMarkKnownByAllAsJunk and PersonalAssistant and PersonalAssistant.Junk then
		PersonalAssistant.Junk.Custom.addItemLinkToPermanentJunk(itemLink)
	end
	
	control:AddLine(string.format("|t20:20:esoui/art/buttons/accept_up.dds|t |c%s%s|r", CCSME.sV.showKnownByAllUseCC and ttCustomColor:ToHex() or "00FF00", GS(SI_ADDON_MANAGER_CHARACTER_SELECT_ALL),'CraftStoreFixedFont'))
end
	
function CCSME.OnPlayerActivated()
	if ShissuFramework and not (_lchat and _lchat.formatEnabled == 1) then
	    zo_callLater(function() SetupChatHooks() end, 6000) 
	elseif (pChat or rChat) then
        EVENT_MANAGER:RegisterForUpdate(CCSME.name .. "DelayedActivated", 500,
            function()
                EVENT_MANAGER:UnregisterForUpdate(CCSME.name.."DelayedActivated")
                SetupChatHooks()
				SecurePostHook(CS, "TooltipShow", csTTHook)
            end)
    else
        SetupChatHooks()
		SecurePostHook(CS, "TooltipShow", csTTHook)
    end
end


function CCSME:Initialize()
	if CS ~= nil then 
		EVENT_MANAGER:RegisterForEvent(CCSME.name.."Activated", EVENT_PLAYER_ACTIVATED, CCSME.OnPlayerActivated)
	end
	
	local serverName = GetWorldName()

	CCSME.sV = ZO_SavedVars:NewAccountWide("CCSMESavedVariables", 1, nil, {}, serverName) -- account wide
	
	CCSME.sV.showKnownByAllCC = CCSME.sV.showKnownByAllCC or {}
	ttCustomColor:SetRGBA(CCSME.sV.showKnownByAllCC.r or 1, CCSME.sV.showKnownByAllCC.g or 1, CCSME.sV.showKnownByAllCC.b or 1)
	
	local panelData = {
		type = "panel",
		name = "|c9e0911Caro|r's Craft Store Marker Extension",
		author = "|c1d6dadIrniben|r",
		registerForRefresh = true, 
    }
	
	--|cff0000|t20:20:esoui/art/buttons/decline_up.dds:inheritcolor|t|r
	CCSME.sV.iconTexture = CCSME.sV.iconTexture or "esoui/art/buttons/decline_up.dds"
	
	if CCSME.sV.iconColor == nil then CCSME.sV.iconColor = "ff0000"	end
	
	buildCCSMEIconString()
	local theIconColor = ZO_ColorDef:New(CCSME.sV.iconColor or "ffffff")
 	
	local optionsData = {
		{
			type = "iconpicker",
			name = GS(CCSME_IconChoose),
			choices = {	
				"esoui/art/buttons/decline_up.dds", 
				"esoui/art/inventory/inventory_tabicon_recipe_up.dds",
				"esoui/art/interaction/goodbye.dds",
				"esoui/art/interaction/questcompleteavailable.dds",
				"esoui/art/interaction/questnewavailable.dds",
			},
			defaultColor = theIconColor,
			default = "esoui/art/buttons/decline_up.dds",
			iconSize = 20,
			maxColumns = 5, 
			visibleRows = 1, 
			getFunc = function() return CCSME.sV.iconTexture end,
			setFunc = function(value) 
				CCSME.sV.iconTexture = value or CCSME.sV.iconTexture 
				buildCCSMEIconString() 
			end,
			reference = "CCSMELAMIconPicker",
		},
		{
			type = "divider",
		},
		{
			type = "description",
			text = GS(CCSME_IconColorDescr), 
		},
		{
			type = "checkbox",
			name = GS(CCSME_IconColorize),
			width = "full",
			default = 0,
			getFunc = function() return CCSME.sV.iconColor ~= false end,
			setFunc = function(value) 
				if value then 
					CCSME.sV.iconColor = CCSME.sV.iconColor or theIconColor:ToHex()
					CCSMELAMIconPicker:SetColor(theIconColor)
				else 
					CCSME.sV.iconColor = false 
					CCSMELAMIconPicker:SetColor(ZO_ColorDef:New(1,1,1,1))
				end
				buildCCSMEIconString() 
			end,
		},
		
		{
			type = "colorpicker",
			name = GS(CCSME_IconColorChoose), 
			width = "full",
			getFunc = function() return theIconColor:UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				theIconColor:SetRGBA(r,g,b,a)
				CCSMELAMIconPicker:SetColor(theIconColor)
				CCSME.sV.iconColor = theIconColor:ToHex()
				buildCCSMEIconString()
			end,
			disabled  = function() return CCSME.sV.iconColor == false end,
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = GS(CCSME_ShowKnownByAll),
			tooltip = GS(CCSME_ShowKnownByAll),
			width = "full",
			default = 0,
			getFunc = function() return CCSME.sV.showKnownByAll end,
			setFunc = function(value) CCSME.sV.showKnownByAll = value end,
		},
		{
			type = "checkbox",
			name = GS(CCSME_ShowKnownByAllUseCustomColor),
			tooltip = GS(CCSME_ShowKnownByAllUseCustomColor),
			width = "full",
			default = 0,
			getFunc = function() return CCSME.sV.showKnownByAllUseCC end,
			setFunc = function(value) CCSME.sV.showKnownByAllUseCC = value end,
		},
		{
			type = "colorpicker",
			name = GS(CCSME_ShowKnownByAllCustomColor),
			tooltip = GS(CCSME_ShowKnownByAllCustomColor),
			width = "full",
			disabled = function() return not CCSME.sV.showKnownByAllUseCC end,
			default = 0,
			getFunc = function() return CCSME.sV.showKnownByAllCC.r, CCSME.sV.showKnownByAllCC.g, CCSME.sV.showKnownByAllCC.b end,
			setFunc = function(r,g,b,a) 
				CCSME.sV.showKnownByAllCC.r=r
				CCSME.sV.showKnownByAllCC.g=g
				CCSME.sV.showKnownByAllCC.b=b 
				ttCustomColor:SetRGBA(r,g,b)
			end, 
		},
	}
	
	if PersonalAssistant and PersonalAssistant.Junk then
		table.insert(optionsData,
				{
					type = "header",
					name = "PersonalAssistant",
					width = "full",
				})
		table.insert(optionsData,
			{
				type = "checkbox",
				name = GS(CCSME_AutoMarkKnownByAllAsJunk),
				tooltip = GS(CCSME_AutoMarkKnownByAllAsJunk),
				width = "full",
				default = 0,
				getFunc = function() return CCSME.sV.autoMarkKnownByAllAsJunk end,
				setFunc = function(value) CCSME.sV.autoMarkKnownByAllAsJunk = value end,
			})
		table.insert(optionsData,	
			{
				type = "button",
				name = GS(CCSME_UnmarkUnknownJunk),
				tooltip = GS(CCSME_UnmarkUnknownJunk),
				width = "full",
				default = 0,
				func = function() 
					local linksToRemove = {}

					local paJunkItems =  PersonalAssistant.Junk and PersonalAssistant.Junk.SavedVars and PersonalAssistant.Junk.SavedVars.Custom and PersonalAssistant.Junk.SavedVars.Custom.PAItemIds
					if not paJunkItems then d("PA or PA list not found") return end

					for _, itemData in pairs(paJunkItems) do 
						local itemType = GetItemLinkItemType(itemData.itemLink)
						if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF and not IsItemLinkBookKnown(itemData.itemLink) or itemType == ITEMTYPE_RECIPE and not IsItemLinkRecipeKnown(itemData.itemLink) then
							table.insert(linksToRemove, itemData.itemLink)
						end
					end

					for _, itemLink in pairs(linksToRemove) do
					   PersonalAssistant.Junk.Custom.removeItemLinkFromPermanentJunk(itemLink)
					end	
				end
			})
	end
	
	local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel("CCSMEOptions", panelData)
	LAM:RegisterOptionControls("CCSMEOptions", optionsData)
	
	EVENT_MANAGER:UnregisterForEvent(CCSME.name, EVENT_ADD_ON_LOADED)
end

function CCSME.OnAddOnLoaded(event, addonName)
	if addonName == CCSME.name then
		EVENT_MANAGER:UnregisterForEvent(CCSME.name, EVENT_ADD_ON_LOADED)
		CCSME:Initialize()
	end
end


 SLASH_COMMANDS["/caromarker"] = SetupChatHooks
 
 EVENT_MANAGER:RegisterForEvent(CCSME.name, EVENT_ADD_ON_LOADED, CCSME.OnAddOnLoaded)