ZO_CreateStringId("SI_BINDING_NAME_IHR_ASK_FOR_INFORMATION", "Ask for Information")
IHeardARumor = IHeardARumor or {}
IHeardARumor.RumorsWindow = nil
IHeardARumor.RumorsButton = nil
TamrielServiceMap = TamrielServiceMap or {}

local available_services = {}
local isServiceWindowOpen = false
--=======================--
local MINIMUM_DISTANCE = 0.04
local MID_DISTANCE = 0.2
 local playerPinVar = false




local originalShowPin
local function HidePlayerPin()
    local pin = ZO_MapPin0
    if pin then
        pin:SetHidden(true)
        originalShowPin = pin.SetHidden
        pin.SetHidden = function()  end -- Prevent re-showing
    end
end

local function ShowPlayerPin()
    local pin = ZO_MapPin0
    pin.SetHidden = originalShowPin
    pin:SetHidden(false)

end


local function TogglePlayerPin(value)
    --ModifyPlayerPinLayout(value)
    if value then
        HidePlayerPin()
    else
        ShowPlayerPin()

    end
    IHeardARumor.savedVars.hidePlayerPin = value
    playerPinVar = value
end

local prevX = 0
local prevY = 0
local services_window = WINDOW_MANAGER:CreateTopLevelWindow("IHeardARumor_ServicesWindow")

local function ShowSimpleDialog(title, text, buttonText)
    ZO_Dialogs_RegisterCustomDialog("RPN_TEMP_DIALOG", {
        title = { text = title },
        mainText = { text = text },
        buttons = {
            {
                text = buttonText or "Close",
                callback = function() end,
            },
        },
    })
    zo_callLater(function()
        ZO_Dialogs_ShowDialog("RPN_TEMP_DIALOG")
    end, 200)
end

local DIRECTION_NAMES = {
    [1] = "east", "southeast", "south", "southwest",
    "west", "northwest", "north", "northeast","east"
}

local directionThresholds = {
    [1] = 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5, 360
}


local function CloseServicesWindow()
    --d('Close Signal Received')

    services_window:SetHidden(true)
    if IHeardARumor.RumorsWindow then
        isServiceWindowOpen = false
        IHeardARumor.RumorsWindow:SetHidden(true)
    end


end

--=======================--


local function clampDegrees(deg)
    return deg % 360
end

local function getDirectionFromDegrees(deg)
    deg = clampDegrees(deg)
    --d("DEG:" .. tostring(deg))
    for i, threshold in ipairs(directionThresholds) do
        if deg < threshold then return DIRECTION_NAMES[i] end
    end
    return DIRECTION_NAMES[1]  -- Wraps to "east"
end

local function getZoneName()
    return GetZoneName(GetUnitZoneIndex("player"))
end

local function getSubZoneName()
    local mapName = GetMapName()
    return mapName ~= "" and mapName or getZoneName()
end

local function getPlayerPosition()
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    end
    return GetMapPlayerPosition("player")
end


--===========================--


local function GetServiceLocation(serviceName, subZoneName)
    local prefix = serviceName .. "::"
    for key, entry in pairs(TamrielServiceMap or {}) do
        if key:sub(1, #prefix) == prefix and entry.subZoneId == subZoneName then
            return entry
        end
    end
    return nil
end

local function getPoiDirections(indexP)
	if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end

    local playerX, playerY = GetMapPlayerPosition("player")

	if GetMapContentType() == MAP_CONTENT_DUNGEON or GetMapType() == MAPTYPE_SUBZONE then
		MapZoomOut()
		zoneName = GetMapName()
		zoneMapId = GetCurrentMapIndex()
		playerX, playerY = GetMapPlayerPosition("player")
	end

    local zoneIndex = GetUnitZoneIndex("player")
    local poiX, poiY = GetPOIMapInfo(zoneIndex, indexP)
    local name, _, icon, _, _, isHidden, _, poiType, isShownInCurrentMap = GetPOIInfo(zoneIndex, indexP)
    local dx = poiX - playerX
    local dy = poiY - playerY

    --d('POI:'.. tostring(name) .. tostring(poiX) .."|".. tostring(poiX))
    --d("POI: " .. tostring(indexP))
    local distance = math.sqrt(dx * dx + dy * dy)
    --d("POI distance: " .. tostring(distance))
    local angle = math.atan2(dy, dx)
    local deg = math.deg(angle) --

    if deg > 360 then
        deg = deg - 360
    end
    if deg < 0 then
        deg = deg + 360
    end
    local direction = "--"

    if deg >= 337.5 or deg < 22.5 then
        direction = "east of here"
    elseif deg < 67.5 then
        direction = "southeast of here"
    elseif deg < 112.5 then
        direction = "south of here"
    elseif deg < 157.5 then
        direction = "southwest of here"
    elseif deg < 202.5 then
        direction = "west of here"
    elseif deg < 247.5 then
        direction = "northwest of here"
    elseif deg < 292.5 then
        direction = "north of here"
    else
        direction = "northeast of here"
    end


    local distancePhrase = ""
    if distance < MINIMUM_DISTANCE then
        distancePhrase =  "Right here!"

    elseif distance < 0.05 then
        distancePhrase = "It's actually really close!"
    elseif distance < 0.1 then
        distancePhrase = "you're almost there."
    elseif distance < 0.15 then
        distancePhrase = "You can easily walk there."
    elseif distance < MID_DISTANCE then
        distancePhrase = "it's not that far... I think."
    elseif distance < 0.3 then
        distancePhrase = "You could get there by walking, but with a horse is better"
    elseif distance < 0.4 then
        distancePhrase = "It's actually a pretty good walk, remember to take some supplies with you on the road if you're willing to travel there."
    else
        distancePhrase = "And It's a pretty long journey... you better be ready."
    end

    return  direction, distancePhrase, distance
end



local function randomChoiceFromList(list)
    if type(list) ~= "table" or #list == 0 then
        return nil -- empty or not a list
    end
    local index = math.random(1, #list)
    return list[index]
end

    local maxReach = 5
    local reach = 0
    local function SaveZonePOIsToFile(indexPOI)


    local zoneIndex = GetUnitZoneIndex("player")
    local zoneName = GetUnitZone("player")

    local name, _, _, _, isShown = GetPOIInfo(zoneIndex, indexPOI)

    local directions, distancePhrase, distance = getPoiDirections(indexPOI)
    local templates = {}
    --d('Distance:' .. tostring(distance))
    --d('MINIMUM_DISTANCE:' .. tostring(MINIMUM_DISTANCE))
    if not (distance < MINIMUM_DISTANCE) then
        templates = {
            "People say " .. name .. " is " .. directions .." "..  distancePhrase,
            "I overheard something about " .. name .. ". It's " .. directions.." "..  distancePhrase,
            "They say trouble's brewing near " .. name .. " – " .. directions.." "..  distancePhrase,
            "Huh, " .. name .. "? That's " .. directions..". "..  distancePhrase,
            "I overheard there's something weird going on around " .. name .. ". It's " .. directions.." "..  distancePhrase,
            "They say trouble's brewing near " .. name .. " – " .. directions..". "..  distancePhrase,
            "Huh, " .. name .. "? That's " .. directions .." "..  distancePhrase.. ". Heard it's not safe these days.",
            "A traveler mentioned strange lights over " .. name .. ", just " .. directions ..". "..  distancePhrase,
            "Locals have been avoiding " .. name .. ". It's " .. directions .. ", if you're curious.",
            "You didn’t hear it from me, but something’s off about " .. name .. " over " .. directions .. ". "..  distancePhrase,
            "There's talk of strange omens near " .. name .. " – over to the " .. directions .."."..  distancePhrase,
            "I’d stay clear of " .. name .. ". It's " .. directions .. ". People say it’s cursed. "..  distancePhrase,
            "Word is, the guards saw something near " .. name .. ". That’s out " .. directions .. "."..  distancePhrase,
            "If you value your life, avoid " .. name .. ". " .. directions.." "..  distancePhrase,
            "Folk around here whisper about " .. name .. " – just " .. directions .. ". Sounds odd. "..  distancePhrase,
            "Folk around here whisper about " .. name .. "? That’s " .. directions .. ". Might wanna think twice. "..  distancePhrase,
            "They say the wind screams at night near " .. name .. ". It’s just " .. directions .. " from here. "..  distancePhrase,
            "Old timers say " .. name .. " was fine once. Now it's just trouble. It's " .. directions .. ". "..  distancePhrase,
        }
    else
        templates = {
            "I overheard there's something weird going on around " .. name .. ". It's " .. directions.." "..  distancePhrase,
            "They say trouble's brewing on " .. name .. "'s surroundings. – " .. directions.." "..  distancePhrase,
            "Huh, " .. name .. "? That's " .. directions.. " ".. distancePhrase,
            "Old timers say " .. name .. " was fine once. Now it's just trouble. It's " .. directions .. ". "..  distancePhrase,
        }
    end


    local msg = templates[math.random(1, #templates)]
    local msg2  = name .."?. Hm... it's ".. directions.. ". " .. distancePhrase

    if name == "" and reach < maxReach then
        reach = reach + 1
        local choicePOI = randomChoiceFromList({1,2,3,4,5,6,7})
        return SaveZonePOIsToFile(choicePOI)

    else
        reach = 0
        return msg,msg2
    end

end

local function GetDirectionsToService(serviceX, serviceY)
    local px, py = getPlayerPosition()
    local dx, dy = serviceX - px, serviceY - py
    local dist = math.sqrt(dx * dx + dy * dy)
    local angle = math.deg(math.atan2(dy, dx))
    local dir = getDirectionFromDegrees(angle)

    local distTxt = (dist < 0.045 and "Right here!")
        or (dist < 0.07 and "(Gesturing with their chin)")
        or (dist < 0.12 and "It's just over there.")
        or (dist < 0.15 and "It's close, actually.")
        or (dist < 0.2 and "A couple houses that way.")
        or (dist < 0.3 and "On the other side.")
        or (dist < 0.4 and "You going to walk a bit.")
        or "I think it's on the other side of town."

    return dir, distTxt, dist
end


local function GetServicesForSubZone(subZoneName)
    local result = {}
    local found = false
    local b2TXT = "Nevermind"
    for key, entry in pairs(TamrielServiceMap or {}) do
        found = true

        if type(entry) == "table" and entry.subZoneId == subZoneName then
            b2TXT = "Services"
            table.insert(result, entry.service)
        end
    end
    if not found then
        d("[RPN - Rumors]: 'Tamriel_Data.lua' NOT FOUND for this Zone. (yet)")
    end


    return result,b2TXT
end


local bgControl

local function ShowServiceList(npcNAME, servicesAround)
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    end
    isServiceWindowOpen = true
    local services = servicesAround


    local windowHeight = 10+(33*#services)
    --d(#services, windowHeight)
    local topWindow = services_window
    topWindow:ClearAnchors()
    topWindow:SetDimensions(300, windowHeight)
    topWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 10)
    topWindow:SetMovable(true)
    topWindow:SetMouseEnabled(true)
    topWindow:SetClampedToScreen(true)
    topWindow:SetHidden(false)

    SCENE_MANAGER:ShowTopLevel(topWindow, true)
    PushActionLayerByName("UI_SHORTCUT_PRIMARY")
    CHAT_SYSTEM:Minimize()


    if bgControl and not bgControl:IsHidden() then
        bgControl:SetHidden(true)
        bgControl:ClearAnchors()
        bgControl:SetParent(nil)
        bgControl = nil
    end


    bgControl = WINDOW_MANAGER:CreateControl(nil, topWindow, CT_BACKDROP)
    bgControl:SetAnchorFill()
    bgControl:SetCenterColor(0, 0, 0, 0.6)
    bgControl:SetEdgeColor(1, 1, 1, 1)
    bgControl:SetEdgeTexture(nil, 1, 1, 1, 1)
    StartChatInput()
    CHAT_SYSTEM:Minimize()
    --  Build clean new list
    for i, service in ipairs(services) do
        --d('Loading: ' .. service)

        local button = WINDOW_MANAGER:CreateControl(nil, bgControl, CT_BUTTON)
        button:SetFont("ZoFontGame")
        button:SetText(service)
        button:SetDimensions(250, 30)
        button:SetAnchor(CENTER, bgControl, TOP, 0, 30 + (i - 1) * 32)
        button:SetClickSound("Click")
        button:SetMouseEnabled(true)
        button.serviceName = service

        button:SetHandler("OnClicked", function(self)
            local subZone = GetMapName()
            local entry = GetServiceLocation(self.serviceName, subZone)
            local caption = GetUnitCaption("interact")
            if entry then
                local dir, distText, distRaw = GetDirectionsToService(entry.mapX, entry.mapY)
                local response

                if self.serviceName == npcNAME or self.serviceName == caption then
                    response = "You're in the right place. Are you looking for me?"
                elseif distText == "Right here!" then
                    response = "Right here! Take a look around."
                else
                    response = string.format("%s? That way - (%s). %s", self.serviceName, dir, distText)
                end

                services_window:SetHidden(true)

                ShowSimpleDialog("Directions", response, "Thanks.")
            else
                d(string.format("[IHeardARumor] %s not found in %s", self.serviceName, subZone))
                ShowSimpleDialog("Hmm...", "I’m not sure where that is, sorry.", "Okay.")
            end
        end)
    end
end


--=============================--
local function ShowRumorDialogForZone(npcNAME ,new)
    local zoneIndex = GetUnitZoneIndex("player")
    local poiCount = GetNumPOIs(zoneIndex)
    local POI_I = IHeardARumor.lastPOI or math.random(1, poiCount)
    if new then
        POI_I = math.random(1, poiCount)
    end
    local zoneTXT, _ = SaveZonePOIsToFile(POI_I)



    ZO_Dialogs_RegisterCustomDialog("RPN_RUMORS_DIALOG", {
    title = { text = npcNAME },
    mainText = { text = zoneTXT},
    buttons = {
    {
    text = "Really? (Follow Rumor)",
    callback = function()
        IHeardARumor.lastPOI = POI_I
    end
    },
    {
    text = "What else?",
    callback = function()
        ShowRumorDialogForZone(npcNAME,true)
    end
    },

    }
    })

    zo_callLater(function()
        ZO_Dialogs_ShowDialog("RPN_RUMORS_DIALOG")
    end, 500)

end



function IsTargetFriendlyNPC()
    if isServiceWindowOpen then
        services_window:SetHidden(true)
        isServiceWindowOpen = false
    else
        PlayEmoteByIndex(46)
        local unitTag = "reticleover"
        local zoneIndex = GetUnitZoneIndex("player")
        if not DoesUnitExist(unitTag) then
            d("There's nobody there.")
            return false
        end

        local poiCount = GetNumPOIs(zoneIndex) or 7
        local POI_I = IHeardARumor.lastPOI or math.random(1, poiCount)

        local reaction = GetUnitReaction(unitTag)
        if reaction == UNIT_REACTION_FRIENDLY or reaction == 2 or reaction == 5 then
            local npcName = GetUnitName(unitTag)
            local greeting = zo_strformat("<<C:1>> says: 'Hello there.'", npcName)
            local POI_REACT = IHeardARumor.lastPOI or 1
            prevX,prevY = GetUnitWorldPosition("player")

            local _, rumorText = SaveZonePOIsToFile(POI_REACT)
            if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
                CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
            end
            local SZ = getSubZoneName()
            local servicesAround,b2TXT = GetServicesForSubZone(SZ)
            --local b2TXT = "Nevermind"
            ZO_Dialogs_RegisterCustomDialog("RPN_RUMORS_DIALOG_RUMOR", {
                title = { text = "Rumors" },
                mainText = { text = rumorText },
                buttons = {
                    {
                        text = "Thanks!",
                        callback = function()
                            services_window:SetHidden(true)
                        end,
                    },
                    {
                        text = "What else?",
                        callback = function()
                            ShowRumorDialogForZone(npcName, true)
                        end
                    },
                }
            })

            ZO_Dialogs_RegisterCustomDialog("RPN_RUMORS_DIALOG_HELLO", {
                title = { text = "Talk" },
                mainText = { text = greeting },
                buttons = {
                    {
                        text = "Rumor",
                        callback = function()
                            services_window:SetHidden(true)
                            if IHeardARumor.lastPOI then
                                zo_callLater(function()
                                    --ShowRumorDialogForZone(npcName, false)
                                    ZO_Dialogs_ShowDialog("RPN_RUMORS_DIALOG_RUMOR")
                                end, 500)
                            else
                                IHeardARumor.lastPOI = 1
                                zo_callLater(function()
                                    --ShowRumorDialogForZone(npcName, false)
                                    ZO_Dialogs_ShowDialog("RPN_RUMORS_DIALOG_RUMOR")
                                end, 500)
                                d("I haven't heard anything about this place yet.")

                            end
                        end
                    },
                    {
                        text = b2TXT,
                        callback = function()
                            if #servicesAround > 0 then
                                --   local SZ = getSubZoneName()
                                --   local servicesA,b2TXT = GetServicesForSubZone(SZ)

                                ShowServiceList(npcName, servicesAround)
                            end

                        end
                    },
                }
            })

            zo_callLater(function()
                ZO_Dialogs_ShowDialog("RPN_RUMORS_DIALOG_HELLO")
            end, 500)
        else
            d("That's not a friendly NPC.")
        end

    end
end


local NPC_ROLES = {
    ["Innkeeper"] = {
        ["en"] = "Innkeeper",
        ["fr"] = "Aubergiste",
        ["de"] = "Gastwirt",
        ["jp"] = "宿屋",
        ["es"] = "Tabernero",
        ["ptbr"] = "Estalajadeiro",
    },
    ["Brewer"] = {
        ["en"] = "Brewer",
        ["fr"] = "Brasseur",
        ["de"] = "Brauer",
        ["jp"] = "醸造者",
        ["es"] = "Cervecero",
        ["ptbr"] = "Cervejeiro",
    },
    ["Chef"] = {
        ["en"] = "Chef",
        ["fr"] = "Chef",
        ["de"] = "Küchenchef",
        ["jp"] = "シェフ",
        ["es"] = "Chef",
        ["ptbr"] = "Chefe",
    },
}
local function IsRoleCaption(caption)
    local lang = GetCVar("Language.2")
    if lang == "pt" then lang = "ptbr" end

    for _, translations in pairs(NPC_ROLES) do
        if translations[lang] and string.find(caption, translations[lang]) then
            return true
        end
    end
    return false
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= "IHeardARumor" then return end
    IHeardARumor.savedVars = IHeardARumor.savedVars or { hidePlayerPin = false }
    playerPinVar = IHeardARumor.savedVars.hidePlayerPin or false
    TogglePlayerPin(playerPinVar)
    local panelData = {
    type = "panel",
    name = "RolePlayNeeds - I Heard A Rumor",
    displayName = "I Heard A Rumor",
    author = "@matheusbk2 & @nathanbk3",
    version = "0.3.2",
    registerForRefresh = true,
    registerForDefaults = true,
}
local function OpenGoldDonationMail()
    SCENE_MANAGER:Show("mailSend")

    zo_callLater(function()
        ZO_MailSendToField:SetText("@matheusbk2")
        ZO_MailSendSubjectField:SetText("Thanks for the Addon!")

    end, 100) -- Delay to ensure the mail UI is visible
end
local optionsTable = {
    {
        type = "checkbox",
        name = "Hide Player Map Pin",
        tooltip = "Hides the player pin on the map to make self-discovery more immersive.\n TIP: (To hide your companion, you must open your map, on the right side tabs and uncheck 'Companions' in 'Pins')",
        getFunc = function() return IHeardARumor.savedVars.hidePlayerPin or false end,
        setFunc = function(value) TogglePlayerPin(value) end,
        default = false,
    },
    {
        type = "header",
        name = "\n",
    },
    {
        type = "header",
        name = "Support the creator!",
    },

    {
        type = "description",
        text = "If you enjoy this addon, consider supporting the creator for more of the RolePlayNeeds Series: \n \n |cFFFFFFhttps://www.patreon.com/c/RolePlayNeeds|r \n\n https://discord.gg/qgKkdYSs",
        width = "full",
    },
    {
        type = "button",
        name = "Copy Patreon Link",
        tooltip = "Click to copy the support link in your chat.",
        func = function()
            StartChatInput("https://www.patreon.com/c/RolePlayNeeds")
        end,
        width = "half",
    },
        {
        type = "button",
        name = "Copy Discord Invite",
        tooltip = "Click to copy Discord Invite link in your chat.",
        func = function()
            StartChatInput("https://discord.gg/qgKkdYSs")
        end,
        width = "half",
    },
    {
        type = "button",
        name = "Donate Gold",
        tooltip = "Click to Say 'Thanks My Dude!' Any form of appreciation is appreciated. :)",
        func = function()
            OpenGoldDonationMail()
        end,
        width = "half",
    }
}

    local LAM = LibAddonMenu2
    local panelName = "IHeardARumor_OptionsPanel"
    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
    EVENT_MANAGER:UnregisterForEvent("IHeardARumor", EVENT_ADD_ON_LOADED)


end


EVENT_MANAGER:RegisterForEvent("IHeardARumor", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForUpdate("MovementTrackerRumor", 300, function()
        local xa, worldX, worldY, xb = GetUnitWorldPosition("player")

        if prevX and prevY then
            if  worldX ~= prevX and worldY ~= prevY then
              CloseServicesWindow()
              isServiceWindowOpen= false
            end
            prevX = worldX
            prevY = worldY
        end


    end)



SLASH_COMMANDS["/serviceshere"] = function()
    local subzone = getSubZoneName()
    local available_services,_ = GetServicesForSubZone(subzone)
    d("Services in " .. subzone .. ":")
    for _, s in ipairs(available_services) do d(" - " .. s) end
end