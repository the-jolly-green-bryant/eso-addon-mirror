ZO_CreateStringId("SI_BINDING_NAME_RPN_CHECK_NEEDS", "Check Needs")
ZO_CreateStringId("SI_BINDING_NAME_RPN_TAKE_NAP", "Take Nap")
local meters = {
    hunger = {
        iconPaths = {
            "RolePlayNeeds/ui/icon_food_meat_chunk_01.dds",
            "RolePlayNeeds/ui/icon_food_meat_chunk_02.dds",
            "RolePlayNeeds/ui/icon_food_meat_chunk_02.dds",
            "RolePlayNeeds/ui/icon_food_meat_chunk_02.dds",
            "RolePlayNeeds/ui/icon_food_meat_chunk_03.dds",
            "RolePlayNeeds/ui/icon_food_meat_chunk_03.dds",
            "RolePlayNeeds/ui/icon_food_meat_chunk_03.dds",
            "RolePlayNeeds/ui/wheel/eatW.dds",
            "RolePlayNeeds/ui/wheel/eatW.dds",
            "RolePlayNeeds/ui/wheel/eatW.dds",
        }
    },
    water = {
        iconPaths = {
            "RolePlayNeeds/ui/icon_water_01.dds",
            "RolePlayNeeds/ui/icon_water_02.dds",
            "RolePlayNeeds/ui/icon_water_02.dds",
            "RolePlayNeeds/ui/icon_water_02.dds",
            "RolePlayNeeds/ui/icon_water_03.dds",
            "RolePlayNeeds/ui/icon_water_03.dds",
            "RolePlayNeeds/ui/icon_water_03.dds",
            "RolePlayNeeds/ui/wheel/drinkW.dds",
            "RolePlayNeeds/ui/wheel/drinkW.dds",
            "RolePlayNeeds/ui/wheel/drinkW.dds",
        }
    },

    alcohol = {
        iconPaths = {
            "RolePlayNeeds/ui/icon_alcohols.dds",
            "RolePlayNeeds/ui/icon_alcohol.dds",
            "RolePlayNeeds/ui/icon_alcohol.dds",
            "RolePlayNeeds/ui/icon_alcohol.dds",
            "RolePlayNeeds/ui/icon_alcohol.dds",
            "RolePlayNeeds/ui/icon_alcohol.dds",
            "RolePlayNeeds/ui/icon_alcohol.dds",
            "RolePlayNeeds/ui/icon_alcohol.dds",
            "RolePlayNeeds/ui/icon_alcohol.dds",
            "RolePlayNeeds/ui/icon_alcohol.dds",
            "RolePlayNeeds/ui/icon_alcohol.dds",
        }
    },
    fatigue = {
        iconPaths = {
            "RolePlayNeeds/ui/fatigue1.dds",
            "RolePlayNeeds/ui/fatigue2.dds",
            "RolePlayNeeds/ui/fatigue3.dds",
            "RolePlayNeeds/ui/wheel/restW.dds",
        }
    },



}

local function containsString(str, substr)
    return string.find(str, substr) ~= nil
end
local function CATCHER(needle)
    for i = 1, GetNumEmotes() do

    local slashName, category, command, isHidden, isEmote = GetEmoteInfo(i)          -- BY NAME METHOD
    if containsString(slashName, needle) or containsString(command, needle) then
        d(string.format("%d: %s", i, slashName, command))
    end

    end
end

local wm = GetWindowManager()
local em = GetEventManager()
local lastInventoryState = {}
local IconTimer = 500
local MAX_STAMINA = 12000
local MAX_MAGICKA = 12000
local messageCD = 0
local messageTimer = 0
local isWheelOpen = false
RolePlayNeeds = RolePlayNeeds or {}
RolePlayNeeds.name = "RolePlayNeeds"
RolePlayNeeds.version = "0.7"

local estimatedSpeed = 1
local function IsAnyMainUIOpen()
    return not SCENE_MANAGER:IsShowing("hud")
end
RolePlayNeeds.settings = {
    survivalModeOn = true,
    alpha = 50,
    diseaseChance = 1,
    hungerTickSeconds = 750,
    waterTickSeconds = 750,
    diseaseTickSeconds = 300,
    alcoholTickSeconds = 180,
    diseasesMechanicEnabled = true,
    MAX_FATIGUE = 2500,
    fatigueLv = 0,
    fatigueMultiplier = 5,
    recoverFatigueMultiplier = 5,
    restingEmoteIndex = 119,
    eatEmoteIndex = 168,
    drinkEmoteIndex = 8,
    emptyIconsOpacity = 50,
    hasDisease = false,
    diseaseLv= -1,
    diseaseOverlayalpha1= 0.75,
    diseaseOverlayalpha2= 0.75,
    diseaseOverlayalpha3= 0.75,
    canEatRaw = false,
    canDrinkRaw = true,
    hunger = {
        opacity_max = 100,
        opacity_empty = 50,
        x = GuiRoot:GetWidth() * 0.65,
        y = GuiRoot:GetHeight() * 0.93,
        shown = true,
        currentStage = 4,
    },
    water = {
        opacity_max = 100,
        opacity_empty = 100,
        x = GuiRoot:GetWidth() * 0.65 + 30,
        y = GuiRoot:GetHeight() * 0.93,
        shown = true,
        currentStage = 4,
    },
    alcohol = {
        opacity_max = 100,
        opacity_empty = 100,
        x = GuiRoot:GetWidth() * 0.65 + 90,
        y = GuiRoot:GetHeight() * 0.93,
        shown = true,
        currentStage = 1,
    },
    fatigue = {
        opacity_max = 100,
        opacity_empty = 100,
        x = GuiRoot:GetWidth() * 0.65 + 60,
        y = GuiRoot:GetHeight() * 0.93,
        shown = true,
        currentStage = 4,
    },

}
local isMount = false
EVENT_MANAGER:RegisterForEvent("MountTracker", EVENT_MOUNTED_STATE_CHANGED, function(_, isMounted)
    isMount = isMounted
end)

local prevX, prevY
local isMoving = false
local isFighting = false
local isCatchingBreath = false
local lastStamina = GetUnitPower("player", 3) or 12000
local lastMagicka = GetUnitPower("player", 2) or 12000
local RESTING_EMOTE = 119

GlobalclockTicker = 0
RolePlayNeeds.hunger = {}
RolePlayNeeds.water = {}
RolePlayNeeds.alcohol = {}
RolePlayNeeds.fatigue = {}
RolePlayNeeds.isEmoting = false


local function UpdateStage(meterName, stage)
    local meter = RolePlayNeeds[meterName]
    local settings = RolePlayNeeds.settings



    if meterName == "fatigue" then

        if stage < 1 then stage = 1 end
        if stage > #meters[meterName].iconPaths then stage = #meters[meterName].iconPaths end
        stage = RolePlayNeeds.settings.fatigueLv
        --d(meter.currentStage .. tostring(RolePlayNeeds.settings.fatigueLv))
        local FSTG4 = RolePlayNeeds.settings.MAX_FATIGUE - ((RolePlayNeeds.settings.MAX_FATIGUE/100)*95)
        local FSTG3 = RolePlayNeeds.settings.MAX_FATIGUE - ((RolePlayNeeds.settings.MAX_FATIGUE/100)*80)
        local FSTG2 = RolePlayNeeds.settings.MAX_FATIGUE - ((RolePlayNeeds.settings.MAX_FATIGUE/100)*60)
        local FSTG1 = RolePlayNeeds.settings.MAX_FATIGUE - ((RolePlayNeeds.settings.MAX_FATIGUE/100)*35)
        local FSTG0 = RolePlayNeeds.settings.MAX_FATIGUE - ((RolePlayNeeds.settings.MAX_FATIGUE/100)*15)

        if stage <= FSTG4  then      -- 85%
            --d(FSTG4)
            meter.currentStage = 4
        elseif stage <= FSTG3 then
--            d(FSTG3)
            meter.currentStage = 3
        elseif stage <= FSTG2 then
--            d(FSTG2)
            meter.currentStage = 3
        elseif stage <= FSTG1 then
--            d(FSTG1)
            meter.currentStage = 2
        elseif stage <= FSTG0 then
--            d(FSTG0)
            meter.currentStage = 2
        elseif stage <= RolePlayNeeds.settings.MAX_FATIGUE then
            --d("MAX!")
            meter.currentStage = 1
        end
        if meter.texture then
            meter.texture:SetTexture(meters[meterName].iconPaths[meter.currentStage])
        end
    else
        local meter = RolePlayNeeds[meterName]
        local settings = RolePlayNeeds.settings
        if stage < 1 then stage = 1 end
        if stage > #meters[meterName].iconPaths then stage = #meters[meterName].iconPaths end
        meter.currentStage = stage
        local fs = stage or 1
        settings[meterName].currentStage = fs
        if meter.texture then
            meter.texture:SetTexture(meters[meterName].iconPaths[stage])
        end


    end


end

local function GetActivityFatigueRate(SPEED)
    local POWERTYPE_STAMINA = POWERTYPE_STAMINA or 3
    local POWERTYPE_MAGICKA = POWERTYPE_MAGICKA or 2

    local currentStamina = GetUnitPower("player", POWERTYPE_STAMINA)  or 12000
    local currentMagicka =  GetUnitPower("player", POWERTYPE_MAGICKA)  or 12000

    local staminaDelta = MAX_STAMINA - currentStamina
    local magickaDelta = MAX_MAGICKA - currentMagicka

    lastStamina = currentStamina  -- Update for next check
    lastMagicka = currentMagicka  -- Update for next check

    local rate = 0

    if RolePlayNeeds.isResting then
        rate = -5
    else
        if (staminaDelta > 35 or magickaDelta > 35) then
            rate = 5  -- light fatigue (Sprinting, occasional skills)

        elseif SPEED > 1 then
            rate = 1  -- light fatigue (Walking)
        elseif SPEED > 250 then
            rate = 3    -- light fatigue (Sprinting, occasional skills)
        elseif staminaDelta <= 0 then
            rate = -1  -- resting or idle
        else
            rate = 7  -- heavy fatigue (spamming dodge roll, full sprint, combat panic)
        end

        if IsUnitInCombat("player") then
            rate = rate + 5  -- extra burn for being in combat
        end


        -- INTESIFIER
        if staminaDelta > MAX_STAMINA/2 then
            rate = rate*2
            isCatchingBreath = true

        elseif magickaDelta > MAX_MAGICKA/2 then
            rate = rate*2
            isCatchingBreath = true

        else
            if isCatchingBreath == true then
                PlayEmoteByIndex(91) -- Stretch
                UpdateStage("fatigue", RolePlayNeeds.settings.fatigueLv)
            end
            isCatchingBreath = false
        end
    end
    if not RolePlayNeeds.settings.survivalModeOn then
        rate = 0
        isCatchingBreath = false
    end
    return rate
end


EVENT_MANAGER:RegisterForEvent("CombatTracker", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
    if inCombat then
        isFighting = true
    else
        isFighting = false

    end
end)
local function ClampFatigue(value)
    local clamped = math.min(math.max(value, 1), RolePlayNeeds.settings.MAX_FATIGUE)

    return clamped
end


function GetRandomCraftMessage()
    return CRAFT_MESSAGES[math.random(1, #CRAFT_MESSAGES)]
end
function GetRandomCollectMessage()
    return COLLECT_MESSAGES[math.random(1, #COLLECT_MESSAGES)]
end

EVENT_MANAGER:RegisterForEvent("RolePlayNeeds_Gathering", EVENT_LOOT_RECEIVED, function(_, receivedBy, itemName, itemName2, itemName3, itemName4, source)


    if RolePlayNeeds.settings.survivalModeOn and (itemName3 == 19 and RolePlayNeeds.settings.canDrinkRaw and not containsString(tostring(itemName),"Ichor") and not containsString(tostring(itemName),"Grease") ) then
        RolePlayNeeds.IncreaseWaterNeutral()
    end
    if RolePlayNeeds.settings.survivalModeOn and (itemName3 == 25 and RolePlayNeeds.settings.canEatRaw) then
        RolePlayNeeds.IncreaseHungerNeutral()
    end
    if RolePlayNeeds.settings.survivalModeOn and (itemName3 == 40 or itemName3 == 23 or itemName3==19 or itemName3 == 22 or itemName3 == 26 or itemName3 == 15 or itemName3 == 30 or itemName3 == 37  or itemName3 == 39) and(messageTimer <= 0) then
        RolePlayNeeds.settings.fatigueLv = ClampFatigue(RolePlayNeeds.settings.fatigueLv + 15)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetRandomCollectMessage())
        messageTimer = 30
    end
end)
EVENT_MANAGER:RegisterForEvent("RolePlayNeeds_Crafting", EVENT_CRAFT_COMPLETED, function()
    if RolePlayNeeds.settings.survivalModeOn then
        RolePlayNeeds.settings.fatigueLv = ClampFatigue(RolePlayNeeds.settings.fatigueLv + 18)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetRandomCraftMessage())
    end
end)



EVENT_MANAGER:RegisterForUpdate("MovementTracker", 100, function()
    local xa, worldX, worldY, xb = GetUnitWorldPosition("player")


    isMounted = IsMounted()
    messageTimer = messageTimer - 1
    if prevX and prevY then
    local dx = worldX - prevX
    local dy = worldY - prevY
    local distSquared = dx * dx + dy * dy
    local dist = math.sqrt(distSquared)
    local rawSpeed = dist / 0.1  -- 0.1 is your delta timelocal
    local angle = math.deg(math.atan2(dy, dx))
    local nsFactor = 1.0
    if (angle > 45 and angle < 150) or (angle > 180 and angle < 350) then
        nsFactor = 5  -- Adjust this experimentally
    end
    estimatedSpeed = rawSpeed * nsFactor

        if distSquared > 0.0001 then
            if not isMoving then
                isMoving = true
                if RolePlayNeeds.isResting then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,"You are no longer resting.")
                    d("You are no longer resting.")
                end
                RolePlayNeeds.isResting = false
                if isWheelOpen then
                  isWheelOpen = False
                  SLASH_COMMANDS["/mywheel"]()
                  SetGameCameraUIMode(false)
                end
                --d("[V] Started moving")
            end
        else
            if isMoving then
                isMoving = false
                --d("[X] Stopped moving")
            end
        end


        local rate = GetActivityFatigueRate(estimatedSpeed)/10
        local FM = RolePlayNeeds.settings.fatigueMultiplier or 10
        local RM = RolePlayNeeds.settings.recoverFatigueMultiplier or 10
        if rate > 0 then -- EXERCISE
             RolePlayNeeds.settings.fatigueLv = ClampFatigue(RolePlayNeeds.settings.fatigueLv + (rate*(FM/10)))
        else
             RolePlayNeeds.settings.fatigueLv = ClampFatigue(RolePlayNeeds.settings.fatigueLv + (rate*(RM/10)))
        end
        if RolePlayNeeds.settings.survivalModeOn then
            UpdateStage("fatigue", RolePlayNeeds.settings.fatigueLv)
        end

    end

    prevX, prevY = worldX, worldY

end)
local diseaseOverlay1 = WINDOW_MANAGER:CreateTopLevelWindow("DiseaseOverlay1")
local diseaseOverlay2 = WINDOW_MANAGER:CreateTopLevelWindow("DiseaseOverlay2")
local diseaseOverlay3 = WINDOW_MANAGER:CreateTopLevelWindow("DiseaseOverlay3")

local function InitDiseaseOverlay()
    diseaseOverlay1:SetAnchorFill()
    diseaseOverlay1:SetMouseEnabled(false)
    local x = RolePlayNeeds.settings.diseaseOverlayalpha1
    diseaseOverlay1:SetAlpha(x)
    diseaseOverlay1:SetHidden(true)
    local bg1 = WINDOW_MANAGER:CreateControl(nil, diseaseOverlay1, CT_TEXTURE)
    bg1:SetAnchorFill()
    bg1:SetTexture("RolePlayNeeds/ui/GREEN_OVERLAY.dds")

    diseaseOverlay2:SetAnchorFill()
    diseaseOverlay2:SetMouseEnabled(false)
    local y = RolePlayNeeds.settings.diseaseOverlayalpha2
    diseaseOverlay2:SetAlpha(y)
    diseaseOverlay2:SetHidden(true)
    local bg2 = WINDOW_MANAGER:CreateControl(nil, diseaseOverlay2, CT_TEXTURE)
    bg2:SetAnchorFill()
    bg2:SetTexture("RolePlayNeeds/ui/RED_OVERLAY.dds")


    diseaseOverlay3:SetAnchorFill()
    diseaseOverlay3:SetMouseEnabled(false)
    local z = RolePlayNeeds.settings.diseaseOverlayalpha3
    diseaseOverlay3:SetAlpha(z)
    diseaseOverlay3:SetHidden(true)
    local bg3 = WINDOW_MANAGER:CreateControl(nil, diseaseOverlay3, CT_TEXTURE)
    bg3:SetAnchorFill()
    bg3:SetTexture("RolePlayNeeds/ui/BLUE_OVERLAY.dds")


end

function RolePlayNeeds.OnCombatEvent(eventCode, result, isError, abilityName,
                                     abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName,
                                     targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if RolePlayNeeds.settings.survivalModeOn then
        if targetType == COMBAT_UNIT_TYPE_PLAYER and sourceName then
        local lowerName = string.lower(sourceName)
        if RolePlayNeeds.settings.diseasesMechanicEnabled then
            local val =  math.random()
            if math.random() < (RolePlayNeeds.settings.diseaseChance/100) then
                local diseaseLV = 1
                local message = "I feel weird... I might be sick."
                if val > 0.6 then
                    diseaseLV = 2
                    message = "Argh... That wound hurts..."
                end
                if val > 0.9 then
                    diseaseLV = 3
                    message = "Huh.. What... My head... Argh!"
                end
                RolePlayNeeds.ApplyDisease(message, diseaseLV)
            end

        end

    end
    end

end



EVENT_MANAGER:RegisterForEvent("RolePlayNeeds_DiseaseSystem", EVENT_COMBAT_EVENT, RolePlayNeeds.OnCombatEvent)
EVENT_MANAGER:AddFilterForEvent("RolePlayNeeds_DiseaseSystem", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE)

local function OpenGoldDonationMail()
    SCENE_MANAGER:Show("mailSend")

    zo_callLater(function()
        ZO_MailSendToField:SetText("@matheusbk2")
        ZO_MailSendSubjectField:SetText("Thanks for the Addon!")

    end, 100) -- Delay to ensure the mail UI is visible
end


local function contains(str, needle)
    return string.find(string.lower(str), needle, 1, true) ~= nil
end


function RolePlayNeeds.OnInventoryChange(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason, stackCountChange)
    local prevLink = lastInventoryState[bagId .. ":" .. slotId]
    local currentLink = GetItemLink(bagId, slotId)


    local itemLink = currentLink ~= "" and currentLink or prevLink

    if stackCountChange < 0 and itemLink and itemLink ~= "" then

        local itemName = GetItemLinkName(itemLink)
        local itemType, specializedItemType = GetItemLinkItemType(itemLink)
        --d(tostring(itemName) .."//".. tostring(itemType) .."//".. tostring(specializedItemType) .. "//" .. tostring(eventCode).. "//" .. tostring(isNewItem))
        if (RolePlayNeeds.diseaseLv == 1 and (specializedItemType == 150 or specializedItemType == 151 or specializedItemType == 152)) or ((specializedItemType == 150 or specializedItemType == 152) and RolePlayNeeds.diseaseLv == 2) or (specializedItemType == 151 and RolePlayNeeds.diseaseLv == 3) then
           RolePlayNeeds.CureDisease()
        end


        if specializedItemType == 20 then
            RolePlayNeeds.IncreaseAlcohol()
            RolePlayNeeds.IncreaseWater()

        elseif itemType == 7 then
            if contains(itemName, 'stamina') and RolePlayNeeds.diseaseLv == 1 then
                RolePlayNeeds.CureDisease()
            elseif contains(itemName, 'health') and RolePlayNeeds.diseaseLv == 2 then
                RolePlayNeeds.CureDisease()
            elseif contains(itemName, 'magicka') and RolePlayNeeds.diseaseLv == 3 then
                RolePlayNeeds.CureDisease()
            end

        elseif itemType == ITEMTYPE_DRINK then
            RolePlayNeeds.IncreaseWater()
        elseif itemType == ITEMTYPE_FOOD then
            RolePlayNeeds.IncreaseHunger()
        end
    end


    lastInventoryState[bagId .. ":" .. slotId] = currentLink
end


function RPN_CheckNeeds()
    if RolePlayNeeds and RolePlayNeeds.CheckNeeds then
        RolePlayNeeds.CheckNeeds()
    else
        d("CheckNeeds() not ready.")
    end
end

local function StartTimers()

    local function tickHunger()
        local survivalModeOn = RolePlayNeeds.settings.survivalModeOn or false
        if survivalModeOn then
            local current = RolePlayNeeds.hunger.currentStage

            if current > 1 then
                UpdateStage("hunger", current - 1)
            end
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, need5)
        end
        zo_callLater(tickHunger, RolePlayNeeds.settings.hungerTickSeconds * 1000)
    end

    local function tickWater()
        local survivalModeOn = RolePlayNeeds.settings.survivalModeOn or false
        if survivalModeOn then
            local current = RolePlayNeeds.water.currentStage
            if current > 1
                then UpdateStage("water", current - 1)
            end
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, need5)
        end
        zo_callLater(tickWater, RolePlayNeeds.settings.waterTickSeconds * 1000)
    end

    local function tickDisease()
        local current = RolePlayNeeds.diseaseLv
            if current == 1 then
                RolePlayNeeds.CureDisease()
            end
        zo_callLater(tickDisease, RolePlayNeeds.settings.diseaseTickSeconds * 1000)
    end
    zo_callLater(tickDisease, RolePlayNeeds.settings.diseaseTickSeconds * 1000)
    tickHunger()
    tickWater()

end


local function CreateMeterUI(meterName)
    local meter = RolePlayNeeds[meterName]
    local settings = RolePlayNeeds.settings[meterName]


    if meter.control and meter.control:IsControlHidden() == false then
        meter.control:SetHidden(true)
    end


    local control = wm:CreateTopLevelWindow("RolePlayNeeds_" .. meterName .. "_Control")
    control:SetDimensions(32, 32)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.x, settings.y)
    control:SetMovable(true)
    control:SetMouseEnabled(true)
    control:SetClampedToScreen(true)



    control:SetHandler("OnMouseUp", function(self)
        self:StopMovingOrResizing()
        local left, top = self:GetLeft(), self:GetTop()
        settings.x = left
        settings.y = top
    end)



    local tex = wm:CreateControl("$(parent)_Texture", control, CT_TEXTURE)
    tex:SetAnchorFill()

    meter.control = control
    meter.texture = tex

    if not meterName == "fatigue" then
        UpdateStage(meterName, settings.currentStage)
    end


    d("[RPN] (meter) created: " .. meterName)
    return meter

end



function RolePlayNeeds.ApplyDisease(diseaseMessage, lv )
    lv = lv or 1
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,  diseaseMessage )
    --d("[RPN]: " .. diseaseMessage )
    RolePlayNeeds.hasDisease = true
    RolePlayNeeds.diseaseLv = lv or 1
    RolePlayNeeds.settings.hasDisease = true
    RolePlayNeeds.settings.diseaseLv = lv or 1
    RolePlayNeeds.ShowDiseaseOverlay(true, lv)
end

function RolePlayNeeds.CureDisease()

    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "I have been cured! I feel much better.")
    --d("[RPN] I have been cured! I feel much better.")
    RolePlayNeeds.hasDisease = false
    RolePlayNeeds.diseaseLv = -1
    RolePlayNeeds.settings.hasDisease = false
    RolePlayNeeds.settings.diseaseLv = -1

    RolePlayNeeds.ShowDiseaseOverlay(false, -1)
    if not isMoving and not IsAnyMainUIOpen() then
        PlayEmoteByIndex(25)

    end
end

function RolePlayNeeds.ShowDiseaseOverlay(state, lv)

    if lv == -1 then
        diseaseOverlay1:SetHidden(not state)
        diseaseOverlay2:SetHidden(not state)
        diseaseOverlay3:SetHidden(not state)
    end

    if diseaseOverlay1 then
        if lv == 1 then diseaseOverlay1:SetHidden(not state) end
    end
    if diseaseOverlay2 then
        if lv == 2 then diseaseOverlay2:SetHidden(not state) end
    end
    if diseaseOverlay3 then
        if lv == 3 then diseaseOverlay3:SetHidden(not state) end
    end

end

function RolePlayNeeds.tickSober()
    local current = RolePlayNeeds.alcohol.currentStage
    if current > 1 then UpdateStage("alcohol", current - 1) end
    zo_callLater(RolePlayNeeds.tickSober, RolePlayNeeds.settings.alcoholTickSeconds * 1000)
end

function RolePlayNeeds.IncreaseHungerNeutral()
     if isWheelOpen then
        SetGameCameraUIMode(false)
        SLASH_COMMANDS["/mywheel"]()
        isWheelOpen = false
     end
    local current = RolePlayNeeds.hunger.currentStage or 1
    IconTimer = 500
    if current >= #meters.hunger.iconPaths then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "I'm full...")
    return
    end
    UpdateStage("hunger", current + 5)
        if not isMoving and not IsAnyMainUIOpen() then
            PlayEmoteByIndex(9)

        end
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,"I ate some food.")

end

function RolePlayNeeds.IncreaseHunger()
     if isWheelOpen then
        SetGameCameraUIMode(false)
        SLASH_COMMANDS["/mywheel"]()
        isWheelOpen = false
     end
    local current = RolePlayNeeds.hunger.currentStage or 1
    IconTimer = 500
    if current >= #meters.hunger.iconPaths then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "I'm full...")
        return
    end

    UpdateStage("hunger", current + 5)
        if not isMoving and not IsAnyMainUIOpen() then
            PlayEmoteByIndex(168)
        end
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,"I ate some food.")

end

function RolePlayNeeds.IncreaseWater()
     PlayEmoteByIndex(8)
     if isWheelOpen then
        SetGameCameraUIMode(false)
        SLASH_COMMANDS["/mywheel"]()
        isWheelOpen = false
     end
    IconTimer = 500
    local current = RolePlayNeeds.water.currentStage or 1
    if current >= #meters.water.iconPaths then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "I feel Hydrated")
        RolePlayNeeds.water.currentStage = #meters.water.iconPaths
        return
    end
    UpdateStage("water", current + 3)
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,"I've drank some water")
end
function RolePlayNeeds.IncreaseWaterNeutral()

     if isWheelOpen then
        SetGameCameraUIMode(false)
        SLASH_COMMANDS["/mywheel"]()
        isWheelOpen = false
     end
    IconTimer = 500
    local current = RolePlayNeeds.water.currentStage or 1
    if current >= #meters.water.iconPaths then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "I feel Hydrated")
        RolePlayNeeds.water.currentStage = #meters.water.iconPaths
        return
    end
    UpdateStage("water", current + 3)

        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,"I've drank some water")
end
function RolePlayNeeds.IncreaseWater2()
     if isWheelOpen then
        SetGameCameraUIMode(false)
        SLASH_COMMANDS["/mywheel"]()
        isWheelOpen = false
     end
    IconTimer = 500
    local current = RolePlayNeeds.water.currentStage or 1
    if current >= #meters.water.iconPaths then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "I feel Hydrated")
        RolePlayNeeds.water.currentStage = #meters.water.iconPaths
        return
    end
    UpdateStage("water", current + 3)
        if not isMoving and not IsAnyMainUIOpen() then
            PlayEmoteByIndex(173)
        end
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,"I've drank some water")


end

function RolePlayNeeds.IncreaseWater3()
     if isWheelOpen then
        SetGameCameraUIMode(false)
        SLASH_COMMANDS["/mywheel"]()
        isWheelOpen = false
     end
    IconTimer = 500
    local current = RolePlayNeeds.water.currentStage or 1
    if current >= #meters.water.iconPaths then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "I feel Hydrated")
        RolePlayNeeds.water.currentStage = #meters.water.iconPaths
        return
    end
    UpdateStage("water", current + 3)
        if not isMoving and not IsAnyMainUIOpen() then
            PlayEmoteByIndex(200)
        end
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,"I've drank some water")


end

function RolePlayNeeds.IncreaseWaterSit()
     if isWheelOpen then
        SetGameCameraUIMode(false)
        SLASH_COMMANDS["/mywheel"]()
        isWheelOpen = false
     end
    IconTimer = 500
    local current = RolePlayNeeds.water.currentStage or 1
    if current >= #meters.water.iconPaths then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "I feel Hydrated")
        RolePlayNeeds.water.currentStage = #meters.water.iconPaths
        return
    end
    UpdateStage("water", current + 3)
        if not isMoving and not IsAnyMainUIOpen() then
            PlayEmoteByIndex(417)
        end
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,"I've drank some water")


end

function RolePlayNeeds.IncreaseAlcohol()
     if isWheelOpen then
        SetGameCameraUIMode(false)
        SLASH_COMMANDS["/mywheel"]()
        isWheelOpen = false
     end
IconTimer = 500
local current = RolePlayNeeds.alcohol.currentStage or 1
    if not isMoving and not IsAnyMainUIOpen() then
        PlayEmoteByIndex(8)

    end
UpdateStage("alcohol", current + 2)
d("[RPN] You drank Alcohol.")
end


function RolePlayNeeds.ResetHunger()
UpdateStage("hunger", 1)
d("[RPN] Hunger reset to starving.")
--RolePlayNeeds.HungerLoop()
end

function RolePlayNeeds.ResetWater()
UpdateStage("water", 1)
d("[RPN] Water reset to thirsty.")

end

function RolePlayNeeds.ResetAlcohol()
UpdateStage("alcohol", 1)
d("[RPN] Alcohol reset to sober.")
    if not isMoving and not IsAnyMainUIOpen() then
        PlayEmoteByIndex(8)

    end

end

function RolePlayNeeds.GetNeedDescription(value, needType)
    local desc = ""
    if needType == "Food" then
        if value <= 1 then
            desc = "starving to death!!! "
        elseif value <= 3 then
            desc = "very hungry..."
        elseif value <= 5 then
            desc = "could use a bite"
        elseif value <= 7 then
            desc = "almost full"
        elseif value <= 9 then
            desc = "stuffed"
        elseif value == 10 then
            desc = "completely full!"
        elseif value > 10 then
            desc = "ate too much!"
        end

    end

    if needType == "Disease" then
        if value == -1 then
            desc = "feeling healthy."
        end
        if value == 1 then
            desc = "feeling a bit ill. I should go see an alchemist."
        end
        if value == 2 then
            desc = "feeling sick. I should go see an alchemist."
        end
        if value == 3 then
            desc = " feeling really sick! contracted a rare disease...I should go see an alchemist."
        end

    end

    if needType == "Water" then
        if value <= 1 then
            desc = "dehydrated!!"
        elseif value <= 3 then
            desc = "'m very thirsty"
        elseif value <= 5 then
            desc = "could have another drink"
        elseif value <= 7 then
            desc = "could use a drink"
        elseif value <= 9 then
            desc = "'m feeling hydrated"
        elseif value == 10 then
            desc = "'m fully hydrated!"
        elseif value > 10 then
            desc = "'m overhydrated and feeling bloated"
        end
    elseif needType == "Alcohol" then
        if value <= 1 then
            desc = "totally sober!"
        elseif value <= 2 then
            desc = "feeling giggly"
        elseif value <= 5 then
            desc = "feeling dizzy"
        elseif value <= 7 then
            desc = "drunk"
        elseif value <= 9 then
            desc = "very drunk"
        elseif value == 10 then
            desc = "hammered!"
        elseif value > 10 then
            desc = "blackout drunk!"
        end
    elseif needType == "Fatigue" then
        if value <= RolePlayNeeds.settings.MAX_FATIGUE - ((RolePlayNeeds.settings.MAX_FATIGUE/100)*95) then
            desc = "completely rested!"
        elseif value <= RolePlayNeeds.settings.MAX_FATIGUE-((RolePlayNeeds.settings.MAX_FATIGUE/100)*85) then
            desc = "I'm feeling good."
        elseif value <= RolePlayNeeds.settings.MAX_FATIGUE-((RolePlayNeeds.settings.MAX_FATIGUE/100)*75) then
            desc = "I'm ok"
        elseif value <= RolePlayNeeds.settings.MAX_FATIGUE-((RolePlayNeeds.settings.MAX_FATIGUE/100)*50) then
            desc = "I just need to catch my breath a little bit."
        elseif value <= RolePlayNeeds.settings.MAX_FATIGUE-((RolePlayNeeds.settings.MAX_FATIGUE/100)*35) then
            desc = "I feel tired, I could take a break."
        elseif value <= RolePlayNeeds.settings.MAX_FATIGUE-((RolePlayNeeds.settings.MAX_FATIGUE/100)*15) then
            desc = "I feel really tired, I need to rest."
        elseif value <= RolePlayNeeds.settings.MAX_FATIGUE then
            desc = "I'm Wrecked!! I'm desperate for need a nap."
        end
    end


    return desc
end


ZO_Dialogs_RegisterCustomDialog("RPN_FAKE_NOCURE_DIALOG", {
    title = { text = "Cure Disease" },
    mainText = { text = "Hum... You look alright to me. Just drink more water, dear." },
    buttons = {
        {
            text = SI_YES,
            callback = function()
                RolePlayNeeds.settings.hasDisease = false
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "I have been cured from my condition.")
                RolePlayNeeds.CureDisease()

            end
        },
        {
            text = SI_NO,
        }
    }
})
ZO_Dialogs_RegisterCustomDialog("RPN_FAKE_CURE_DIALOG", {
    title = { text = "Cure Disease" },
    mainText = { text = "Here, this could finally cure you from your disease.\n \n (The Alchemist offers me a solution for my ill condition. Should I take it?)" },
    buttons = {
        {
            text = SI_YES,
            callback = function()
                RolePlayNeeds.settings.hasDisease = false
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "I have been cured from my condition.")
                RolePlayNeeds.CureDisease()

            end
        },
        {
            text = SI_NO,
        }
    }
})



local function IsAlchemistVendor()

    for i = 1, GetNumStoreItems() do
        local itemTypeA, itemName, itemTypeD, itemTypeC, itemTypeX, itemTypeZ, itemType = GetStoreEntryInfo(i)
        local nameCheck = tostring(itemName)
        if contains(nameCheck, "poison") then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, 'Its an Alchemist! I can try to cure my disease here.')

            return true
        end
    end
    return false
end


function RolePlayNeeds.CureDialogOpen()
    zo_callLater(function()
        ZO_Dialogs_ShowDialog("RPN_FAKE_CURE_DIALOG")
    end, 500)
end

local NAP_SCREEN = nil

local function CreateNapFade()
    if not NAP_SCREEN then
        NAP_SCREEN = WINDOW_MANAGER:CreateTopLevelWindow("TakeANap_Blackout")
        NAP_SCREEN:SetAnchorFill(GuiRoot)
        NAP_SCREEN:SetDrawLayer(DL_OVERLAY)
        NAP_SCREEN:SetMouseEnabled(false)

        local blackBg = WINDOW_MANAGER:CreateControl("$(parent)_Bg", NAP_SCREEN, CT_BACKDROP)
        blackBg:SetAnchorFill()
        blackBg:SetCenterColor(0, 0, 0, 1)
        blackBg:SetEdgeColor(0, 0, 0, 0)
    end
    NAP_SCREEN:SetHidden(true)
end

local function StartNap(duration)
    SetGameCameraUIMode(false)
    PlayEmoteByIndex(118)
    CreateNapFade()
    NAP_SCREEN:SetAlpha(0)
    NAP_SCREEN:SetHidden(false)

    local timeline = ANIMATION_MANAGER:CreateTimeline()

    -- Fade in
    local fadeIn = timeline:InsertAnimation(ANIMATION_ALPHA, NAP_SCREEN, 0)
    fadeIn:SetAlphaValues(0, 1)
    fadeIn:SetDuration(1000)

    -- Hold
    local hold = timeline:InsertAnimation(ANIMATION_ALPHA, NAP_SCREEN, 1000)
    hold:SetAlphaValues(1, 1)
    hold:SetDuration(duration * 1000)

    -- Fade out
    local fadeOut = timeline:InsertAnimation(ANIMATION_ALPHA, NAP_SCREEN, 1000 + duration * 1000)
    fadeOut:SetAlphaValues(1, 0)
    fadeOut:SetDuration(1000)

    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
    timeline:SetHandler("OnStop", function()
        RolePlayNeeds.settings.fatigueLv = 0
        NAP_SCREEN:SetHidden(true)
        PlayEmoteByIndex(91)
    end)

    timeline:PlayFromStart()
end


function RolePlayNeeds:CreateAlchemistWindow()
    if self.CureWindow then return end  -- Only once

    RolePlayNeeds.topWindow = WINDOW_MANAGER:CreateTopLevelWindow("DialogWindow")
    RolePlayNeeds.topWindow:SetDimensions(200, 50)
    RolePlayNeeds.topWindow:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 50, -150)  -- changed anchor here
    RolePlayNeeds.topWindow:SetMovable(true)
    RolePlayNeeds.topWindow:SetMouseEnabled(true)
    RolePlayNeeds.topWindow:SetClampedToScreen(true)
    RolePlayNeeds.topWindow:SetHidden(true)  -- Start hidden, keep as is


    RolePlayNeeds.bg = WINDOW_MANAGER:CreateControl(nil, RolePlayNeeds.topWindow, CT_BACKDROP)
    RolePlayNeeds.bg:SetAnchorFill()
    RolePlayNeeds.bg:SetCenterColor(0, 0, 0, 0.6)
    RolePlayNeeds.bg:SetEdgeColor(1, 1, 1, 1)
    RolePlayNeeds.bg:SetEdgeTexture(nil, 1, 1, 1, 1)


    RolePlayNeeds.btn_alch = WINDOW_MANAGER:CreateControl("RPN_AlchemistButton", RolePlayNeeds.topWindow, CT_BUTTON)
    RolePlayNeeds.btn_alch:SetDimensions(120, 30)
    RolePlayNeeds.btn_alch:SetAnchor(CENTER, topWindow, CENTER, 0, 0)
    RolePlayNeeds.btn_alch:SetText("Cure Disease")
    RolePlayNeeds.btn_alch:SetFont("ZoFontGame")
    RolePlayNeeds.btn_alch:SetNormalFontColor(1, 1, 1, 1)
    RolePlayNeeds.btn_alch:SetMouseEnabled(true)
    RolePlayNeeds.btn_alch:SetHandler("OnClicked", function()
        if RolePlayNeeds.hasDisease then
            zo_callLater(function()
            ZO_Dialogs_ShowDialog("RPN_FAKE_CURE_DIALOG")
            end, 500)
        else
            zo_callLater(function()
            ZO_Dialogs_ShowDialog("RPN_FAKE_NOCURE_DIALOG")
            end, 500)
        end

    end)
    RolePlayNeeds.CureWindow = RolePlayNeeds.topWindow
    RolePlayNeeds.CureButton = RolePlayNeeds.btn_alch
end

function RolePlayNeeds.ShowCureButton(show)
    RolePlayNeeds.topWindow:SetHidden(not show)
end

function RolePlayNeeds.OnStoreClose()
    if RolePlayNeeds.CureWindow then
        RolePlayNeeds.CureWindow:SetHidden(true)
    end
end


function RolePlayNeeds.OnStoreOpen()
        if IsAlchemistVendor() then
            RolePlayNeeds:CreateAlchemistWindow()
            RolePlayNeeds.CureWindow:SetHidden(false)
        else
            if RolePlayNeeds.CureWindow then
                RolePlayNeeds.CureWindow:SetHidden(true)
            end
        end

end



local function ShowCenterMessage(text)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
    messageParams:SetText(text)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN) -- Optional visual style
    messageParams:SetSound(SOUNDS.DUEL_START) -- Optional
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

local function AnnounceWhiteText(text)
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
    params:SetText(text)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end


SLASH_COMMANDS["/logmarker"] = function()
PingMap(MAP_PIN_TYPE_USER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, 0.5, 0.5)

end
local function UpdateRadialStatus()
    if MyFakeRadialButton5 then
        local status = ""
        if RolePlayNeeds.settings.survivalModeOn then
            status = "Survival Mode: ON"
            MyFakeRadialButton5:SetNormalTexture("RolePlayNeeds/ui/wheel/survivalG.dds")
            MyFakeRadialButton5:SetPressedTexture("RolePlayNeeds/ui/wheel/survivalR.dds")
            MyFakeRadialButton5:SetMouseOverTexture("RolePlayNeeds/ui/wheel/survivalG.dds")

        else
            status = "Survival Mode: OFF"
            MyFakeRadialButton5:SetNormalTexture("RolePlayNeeds/ui/wheel/survivalR.dds")
            MyFakeRadialButton5:SetPressedTexture("RolePlayNeeds/ui/wheel/survivalG.dds")
            MyFakeRadialButton5:SetMouseOverTexture("RolePlayNeeds/ui/wheel/survivalR.dds")

        end
        if status and MyFakeRadialHoverLabel then
            MyFakeRadialHoverLabel:SetText(status)
        end
end
function RolePlayNeeds.CheckNeeds()

    local need1 = "I feel " .. RolePlayNeeds.GetNeedDescription(RolePlayNeeds.hunger.currentStage, "Food")
    local need2 = "I " .. RolePlayNeeds.GetNeedDescription(RolePlayNeeds.water.currentStage, "Water")
    local need3 = " I'm... - *hickup* -..." .. RolePlayNeeds.GetNeedDescription(RolePlayNeeds.alcohol.currentStage, "Alcohol")
    local need4 = "I'm currently " .. RolePlayNeeds.GetNeedDescription(RolePlayNeeds.diseaseLv, "Disease")
    local need5 = "" .. RolePlayNeeds.GetNeedDescription(RolePlayNeeds.settings.fatigueLv, "Fatigue")
    if RolePlayNeeds.settings.survivalModeOn then
        IconTimer = 500
    else
        messageCD = 200
        IconTimer = 0
    end

            --d(RolePlayNeeds.diseaseLv)

    if RolePlayNeeds.diseaseLv > 0 and RolePlayNeeds.settings.survivalModeOn then

        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, need4)
    end
    if RolePlayNeeds.alcohol.currentStage > 1 and RolePlayNeeds.settings.survivalModeOn then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, need3)
    end
    if RolePlayNeeds.isResting == true and RolePlayNeeds.settings.survivalModeOn then
        if messageCD <= 0 then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, need1)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, need2)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, need5)

            messageCD = 120
        else
           if not isWheelOpen then
             SLASH_COMMANDS["/mywheel"]()
             isWheelOpen = true
             UpdateRadialStatus()
           end
        end
    else
        if messageCD <= 0 and RolePlayNeeds.settings.survivalModeOn  then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, need1)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, need2)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, need5)

            messageCD = 120
        else
           if not isWheelOpen then
             SLASH_COMMANDS["/mywheel"]()
             isWheelOpen = true
           elseif isWheelOpen then
             SLASH_COMMANDS["/mywheel"]()
             isWheelOpen = false
           end

        end
    end

end

function RolePlayNeeds:ForceInventoryScan()
    for slotId = 0, GetBagSize(BAG_BACKPACK) - 1 do
        if HasItemInSlot(BAG_BACKPACK, slotId) then
            local itemLink = GetItemLink(BAG_BACKPACK, slotId)
            lastInventoryState[BAG_BACKPACK .. ":" .. slotId] = itemLink
        end
    end
end


function RolePlayNeeds.OnUpdateFunction()

    local houseId = GetCurrentZoneHouseId()
    if houseId ~= 0 then
        RolePlayNeeds.isIndoors = true
    end
    if messageCD > 0 then
       messageCD = messageCD - 1
    end
    if not RolePlayNeeds.settings.survivalModeOn then
        if IconTimer > 0 then
            if RolePlayNeeds['hunger'].texture then
                RolePlayNeeds['hunger'].texture:SetAlpha(0)
            end
            if RolePlayNeeds['water'].texture then
                RolePlayNeeds['water'].texture:SetAlpha(0)
            end
            if RolePlayNeeds['alcohol'].texture then
                RolePlayNeeds['alcohol'].texture:SetAlpha(0)
            end
            if RolePlayNeeds['fatigue'].texture then
                RolePlayNeeds['fatigue'].texture:SetAlpha(0)
            end
        end
    end
    if IconTimer > 0 then
        if RolePlayNeeds.settings.survivalModeOn then

            if RolePlayNeeds['hunger'].texture then
                RolePlayNeeds['hunger'].texture:SetAlpha(IconTimer/200)
            end
            if RolePlayNeeds['water'].texture then
                RolePlayNeeds['water'].texture:SetAlpha(IconTimer/200)
            end
            if RolePlayNeeds['alcohol'].texture then
                RolePlayNeeds['alcohol'].texture:SetAlpha(IconTimer/200)
            end
            if RolePlayNeeds['fatigue'].texture then
                RolePlayNeeds['fatigue'].texture:SetAlpha(IconTimer/200)
            end

        end
        IconTimer = IconTimer - 1



    else --FADE
        local currentStamina = GetUnitPower("player", POWERTYPE_STAMINA) or MAX_STAMINA
        local staminaDelta = MAX_STAMINA - currentStamina

        if RolePlayNeeds.settings.survivalModeOn then

            if RolePlayNeeds.hunger.currentStage == 1  then
                RolePlayNeeds['hunger'].texture:SetAlpha(RolePlayNeeds.settings.emptyIconsOpacity/100)
            end
            if RolePlayNeeds.water.currentStage == 1 then
                RolePlayNeeds['water'].texture:SetAlpha(RolePlayNeeds.settings.emptyIconsOpacity/100)
            end

        end

        local FSTG0 = RolePlayNeeds.settings.MAX_FATIGUE - ((RolePlayNeeds.settings.MAX_FATIGUE/100)*15)

        if RolePlayNeeds.settings.fatigueLv > FSTG0  or staminaDelta > 0 then
            staminaDelta = 0
            RolePlayNeeds['fatigue'].texture:SetAlpha(RolePlayNeeds.settings.emptyIconsOpacity/100)
        else
            RolePlayNeeds['fatigue'].texture:SetAlpha(IconTimer/200)
            --RolePlayNeeds['fatigue'].texture:SetAlpha()
        end
        if RolePlayNeeds.isResting then
           RolePlayNeeds['fatigue'].texture:SetAlpha(RolePlayNeeds.settings.emptyIconsOpacity/100)
        end
        if RolePlayNeeds.water.currentStage == 1 then
            RolePlayNeeds['alcohol'].texture:SetAlpha(RolePlayNeeds.settings.alpha/100)
        end

    end
    if RolePlayNeeds['fatigue'].texture then
        local currentStamina = GetUnitPower("player", POWERTYPE_STAMINA) or 12000
        local currentMagicka = GetUnitPower("player", POWERTYPE_MAGICKA) or 12000
        local staminaDelta = 12000 - currentStamina
        local magickaDelta = 12000 - currentMagicka
        if staminaDelta > 0 or magickaDelta > 0 then

            RolePlayNeeds['fatigue'].texture:SetAlpha(0.7) -- MAXHOLD
        else
            if not RolePlayNeeds.isResting and RolePlayNeeds.settings.survivalModeOn then
               RolePlayNeeds['fatigue'].texture:SetAlpha(IconTimer/200)
            end

        end
    end


    if GlobalclockTicker then
        GlobalclockTicker = GlobalclockTicker + 1
    end

    if GlobalclockTicker > 120 then
        RolePlayNeeds.settings.fatigueLv = RolePlayNeeds.settings.fatigueLv - 1

        local currentFatigue = RolePlayNeeds.settings.fatigueLv or 0
        GlobalclockTicker = 0

        local currentFood = RolePlayNeeds.hunger.currentStage or 1
        local currentWater = RolePlayNeeds.water.currentStage or 1
        local currentAlcohol = RolePlayNeeds.alcohol.currentStage or 1
        local currentDisease = RolePlayNeeds.hasDisease or false


        if not isMoving and not IsAnyMainUIOpen() and not isMount and not RolePlayNeeds.isResting and not isFighting and RolePlayNeeds.settings.survivalModeOn then
            if currentAlcohol > 9 then
                PlayEmoteByIndex(115)
            elseif isBurning then
                PlayEmoteByIndex(27)
            elseif currentDisease == true then
                --d(RolePlayNeeds.settings.diseaseLv)
                local specialAnimationIdle1 = 114
                local specialAnimationIdle2 = 114

                if RolePlayNeeds.settings.diseaseLv == 1 then
                    specialAnimationIdle1 = 90
                    specialAnimationIdle2 = 90
                elseif RolePlayNeeds.settings.diseaseLv == 3 then
                    specialAnimationIdle1 = 141
                    specialAnimationIdle2 = 141
                end
                if currentFatigue > RolePlayNeeds.settings.MAX_FATIGUE-((RolePlayNeeds.settings.MAX_FATIGUE/100)*65) then
                    specialAnimationIdle2 = 96
                end
                local numbers = { specialAnimationIdle1,specialAnimationIdle2,specialAnimationIdle1,specialAnimationIdle2, 114,114}
                local chance = math.random() < 0.12
                local choice = numbers[math.random(#numbers)]
                if chance then
                    PlayEmoteByIndex(choice)
                end

            elseif currentFatigue > RolePlayNeeds.settings.MAX_FATIGUE-((RolePlayNeeds.settings.MAX_FATIGUE/100)*15) or isCatchingBreath then
                PlayEmoteByIndex(114)
            elseif currentFood == 1 or currentWater == 1 then
                if currentAlcohol > 3 then
                    PlayEmoteByIndex(115)
                else
                    PlayEmoteByIndex(114)
                end
            elseif currentAlcohol > 5 then
                PlayEmoteByIndex(79)
            elseif currentAlcohol > 3 then
                PlayEmoteByIndex(139)
            end

        end

    end

end

    EVENT_MANAGER:RegisterForUpdate("RPNAddon_UpdateLoop", 0, RolePlayNeeds.OnUpdateFunction)



function RolePlayNeeds.MakeMenu()
    local menu = LibAddonMenu2
    if not menu then
        d("LibAddonMenu2 is missing! Please install it to use the config menu.")
        return
    end

    local set = RolePlayNeeds.settings

    local panel = {
        type = "panel",
        name = "RolePlayNeeds - Tamriel Survival",
        displayName = "Tamriel Survival",
        author = "Matheus Macedo",
        version = RolePlayNeeds.version,
    }

    local options = {
        {
                type = "header",
                name = "Basic Needs",
        },
        {
            type = "checkbox",
            name = "Survival Mode",
            tooltip = "Enable Hunger, Thirst and Diseases System Altogether",
            getFunc = function() return set.survivalModeOn end,
            setFunc = function(value)
                set.survivalModeOn = value
                d('Survival mode: ' .. tostring(value))
            end,
            default = true,
        },
        {
            type = "slider",
            name = "Hunger Timer",
            tooltip = "Timer for Hunger Effects tick. \n (Higher Values = Longer wait, eating less often needed.)\n(Lower Values = Short wait, eating more often needed.)",
            min = 2,
            max = 1200,
            step = 2,
            getFunc = function() return set.hungerTickSeconds end,
            setFunc = function(value)
                set.hungerTickSeconds = value
                RolePlayNeeds.settings.hungerTickSeconds = value
                d(tostring(RolePlayNeeds.settings.hungerTickSeconds) .. " set for Hunger Timer.")
            end,
            default = 600,
        },
        {
            type = "slider",
            name = "Thirst Timer",
            tooltip = "Timer for Thirst Effects tick. \n(Higher Values = Longer wait, drinking less often needed.)\n(Lower Values = Short wait, drinking more often needed.)",
            min = 1,
            max = 1200,
            step = 1,
            getFunc = function() return set.waterTickSeconds end,
            setFunc = function(value)
                set.waterTickSeconds = value
                d(tostring(RolePlayNeeds.settings.waterTickSeconds) .. " :  set for Thirst Timer.")
            end,
            default = 600,
        },
                {
            type = "slider",
            name = "Fatigue Gain Rate",
            tooltip = "Adjust the severity of Fatigue Gain",
            min = 1,
            max = 20,
            step = 1,
            getFunc = function() return set.fatigueMultiplier end,
            setFunc = function(value)
                set.fatigueMultiplier = value

            end,
            default = 5,
        },
        {
            type = "slider",
            name = "Fatigue Recover Rate",
            tooltip = "Adjust Fatigue Regeneration when using a rest action.",
            min = 1,
            max = 20,
            step = 1,
            getFunc = function() return set.recoverFatigueMultiplier end,
            setFunc = function(value)
                set.recoverFatigueMultiplier = value

            end,
            default = 7,
        },


 {
            type = "dropdown",
            name = "Set Quick Resting Animation",
            tooltip = "Choose the quick resting animation for your character\n for when you enter RESTING state",
            choices = {
                "Sit",
                "Meditate",
                "Relax",
                "Relax B",
                "Relax C",
                "Holding Knee",
                "Sit Chair",
                "Nap",
                "Sleep",
                "Wrecked Sleep",
                "Marshmallow*",
                "Sit Read*",

            },
            choicesValues = {
                99,  -- Sit on ground //sit1
                119,  -- Meditate //sit2
                120,  -- Relax 1 //sit3
                121,  -- Relax 2 // sit4
                123,  -- Relax 3 // sit6
                122, -- Sit down // sit5
                100,   -- Sit Chair // sitchair
                116,   -- Sleep side // sleep2
                118,   -- Sleep Belly Up // sleep
                115,   -- Playdead // sleep
                320,   -- Marshmallow Rest // Extra Emote
                386,   -- Reading  Rest    // Extra Emote
            },


            getFunc = function()

                for i, v in ipairs({
                99,  -- Sit on ground //sit1
                119,  -- Meditate //sit2
                120,  -- Relax 1 //sit3
                121,  -- Relax 2 // sit4
                123,  -- Relax 3 // sit6
                122, -- Sit down // sit5
                100,   -- Sit Chair // sitchair
                116,   -- Sleep side // sleep2
                118,   -- Sleep Belly Up // sleep
                115,   -- Playdead // sleep
                320,   -- Marshmallow Rest // Extra Emote
                386,   -- Reading  Rest    // Extra Emote
            }) do
                    if v == set.restingEmoteIndex then

                        return v
                    end
                end
                return 119
            end,
            setFunc = function(selectedLabel)
                set.restingEmoteIndex = selectedLabel

            end,
            default = 119,
        },
         {
            type = "dropdown",
            name = "Set Quick Eating Animation",
            tooltip = "Choose the Quick Eating Animation for your character\n for when you use the QUICKWHEEL",
            choices = {
                "Eat Meat",
                "Eat Bread Slow",
                "Eat Apple",
                "Eat ",
                "Eat Pie",
                "Eat Soup",
                "Eat Small Bread",
                "Eat Bread Fast",
                "Meal",
                "Shrieking Cheese*",
                "MarshMallow*",
                "Spicy Soup*",
            },
            choicesValues = {
                168,
                9,
                177,
                201,
                207,
                208,
                209,
                176,
                210,
                356,
                320,
                329,
            },

            getFunc = function()

                for i, v in ipairs({
                168,
                9,
                177,
                201,
                207,
                208,
                209,
                176,
                210,
                356,
                320,
                329,
            }) do
                if v == set.eatEmoteIndex then
                    return v
                end
                end
                return 168
            end,
            setFunc = function(selectedLabel)
                set.eatEmoteIndex = selectedLabel

            end,
            default = 168,
        },
       {
            type = "dropdown",
            name = "Set Drinking Animation",
            tooltip = "Choose the Quick Drinking Animation for your character\n for when you use the QUICKWHEEL",
            choices = {
                "Drink Mug",
                "Drink Glass",
                "Drink Bottle",
                "Drink Sit A",
                "Drink Horn*",
                "Drink Skull*",
                "Drink Sit B*",

            },
            choicesValues = {
                8,
                173,
                200,
                284,
                287,
                417,
                350,
            },


            getFunc = function()

                for i, v in ipairs({
                8,
                173,
                200,
                417,
                284,
                287,
                350,
            }) do
                    if v == set.drinkEmoteIndex then

                        return v
                    end
                end
                return 8
            end,
            setFunc = function(selectedLabel)
                set.drinkEmoteIndex = selectedLabel

            end,
            default = 8,
        },
        {
            type = "checkbox",
            name = "Can eat Raw Food",
            tooltip = "Enable decreasing hunger when collecting food from natural sources. (Default OFF)",
            getFunc = function() return set.canEatRaw end,
            setFunc = function(value)
                set.canEatRaw = value
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Can drink From Nature (When collecting Water)",
            tooltip = "Enable decreasing thirst when collecting water from natural sources. (Default ON)",
            getFunc = function() return set.canDrinkRaw end,
            setFunc = function(value)
                set.canDrinkRaw = value
            end,
            default = true,
        },
        {
            type = "slider",
            name = "Empty Icons Opacity",
            tooltip = "Max opacity percentage when the gauge is empty and permanent onscreen.",
            min = 0,
            max = 100,
            step = 2,
            getFunc = function() return set.emptyIconsOpacity end,
            setFunc = function(value)
                set.emptyIconsOpacity = value
            end,
            default = 50,
        },
        {
                type = "header",
                name = "Diseases",
        },
        {
            type = "checkbox",
            name = "Diseases",
            tooltip = "Enable in-Game Diseases.",
            getFunc = function() return set.diseasesMechanicEnabled end,
            setFunc = function(value)
                set.diseasesMechanicEnabled = value
                RolePlayNeeds.CureDisease()
            end,
            default = true,
        },
        {
            type = "slider",
            name = "Disease % Chance Multiplier",
            tooltip = "Adjust the chance of catching diseases;",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return set.diseaseChance end,
            setFunc = function(value)
                set.diseaseChance = value

            end,
            default = 2,
        },
        {
            type = "slider",
            name = "Disease Overlay Opacity",
            tooltip = "Adjust Opacity of  Disease Overlay  (GREEN)",
            min = 0,
            max = 1,
            step = 0.1,
            getFunc = function() return set.diseaseOverlayalpha1 end,
            setFunc = function(value)
                set.diseaseOverlayalpha1 = value
                diseaseOverlay1:SetAlpha(value)
            end,
            default = 0.5,
        },
        {
            type = "slider",
            name = "Wound Overlay Opacity",
            tooltip = "Adjust Opacity of  Wound Overlay  (RED)",
            min = 0,
            max = 1,
            step = 0.1,
            getFunc = function() return set.diseaseOverlayalpha2 end,
            setFunc = function(value)
                set.diseaseOverlayalpha2 = value
                diseaseOverlay2:SetAlpha(value)
            end,
            default = 0.5,
        },
        {
            type = "slider",
            name = "Magickal Affliction Overlay Opacity",
            tooltip = "Adjust Opacity of Magickal Affliction Overlay  (Blue)",
            min = 0,
            max = 1,
            step = 0.1,
            getFunc = function() return set.diseaseOverlayalpha3 end,
            setFunc = function(value)
                set.diseaseOverlayalpha3 = value
                diseaseOverlay3:SetAlpha(value)
            end,
            default = 0.5,
        },

        {
            type = "description",
            text = "\n|cFFFFFF Double-tap CHECK NEEDS Key to open the QUICKWHEEL!|r",
            width = "full",
        },
        {
            type = "header",
            name = "Support the creator!",
        },

        {
            type = "description",
            text = "If you enjoy this addon, consider supporting the creator for more of the RolePlayNeeds Series: \n \n |cFFFFFFhttps://www.patreon.com/c/RolePlayNeeds|r",
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
            name = "Donate Gold",
            tooltip = "Click to Say 'Thanks My Dude!' Any form of appreciation is appreciated. :)",
            func = function()
                OpenGoldDonationMail()
            end,
            width = "half",
        }

    }

    menu:RegisterAddonPanel("RolePlayNeedsPanel", panel)
    menu:RegisterOptionControls("RolePlayNeedsPanel", options)
end



end
function RolePlayNeeds.OnAddOnLoaded(event, addonName)
        if addonName ~= RolePlayNeeds.name then return end
        em:UnregisterForEvent(RolePlayNeeds.name, EVENT_ADD_ON_LOADED)


        RolePlayNeeds.settings = ZO_SavedVars:New("RolePlayNeedsSavedVars", 1, nil, RolePlayNeeds.settings)

        local s = RolePlayNeeds.settings

        RolePlayNeeds.hunger.currentStage = s.hunger.currentStage or 1
        RolePlayNeeds.water.currentStage = s.water.currentStage or 1
        RolePlayNeeds.alcohol.currentStage = s.alcohol.currentStage or 1
        RolePlayNeeds.hasDisease = s.hasDisease or false
        RolePlayNeeds.diseaseLv = s.diseaseLv or -1


        RolePlayNeeds.hunger.currentStage = (RolePlayNeeds.hunger.currentStage + 1)
        RolePlayNeeds.water.currentStage = (RolePlayNeeds.water.currentStage + 1)
        RolePlayNeeds.alcohol.currentStage = (RolePlayNeeds.alcohol.currentStage + 1)

        StartTimers()
        RolePlayNeeds.tickSober()
        CreateMeterUI("fatigue")
        CreateMeterUI("hunger")
        CreateMeterUI("water")
        CreateMeterUI("alcohol")
        UpdateStage("fatigue", RolePlayNeeds.settings.fatigueLv)
        UpdateStage("hunger", RolePlayNeeds.hunger.currentStage)
        UpdateStage("water", RolePlayNeeds.water.currentStage)
        UpdateStage("alcohol", RolePlayNeeds.alcohol.currentStage)

        InitDiseaseOverlay()
        UpdateRadialStatus()
        SLASH_COMMANDS["/sit"] = function()
            RolePlayNeeds.isResting = true
            PlayEmoteByIndex(99)

            d("You are resting.")
        end
        SLASH_COMMANDS["/sitchair"] = function()
            RolePlayNeeds.isResting = true
            PlayEmoteByIndex(100)

            d("You are resting.")
        end

        SLASH_COMMANDS["/sit2"] = function()
            RolePlayNeeds.isResting = true
            PlayEmoteByIndex(119)

            d("You are resting.")
        end
        SLASH_COMMANDS["/sit3"] = function()
            RolePlayNeeds.isResting = true
            PlayEmoteByIndex(120)

            d("You are resting.")
        end
        SLASH_COMMANDS["/sit4"] = function()
            RolePlayNeeds.isResting = true
            PlayEmoteByIndex(121)

            d("You are resting.")
        end
        SLASH_COMMANDS["/sit5"] = function()
            RolePlayNeeds.isResting = true
            PlayEmoteByIndex(122)

            d("You are resting.")
        end
        SLASH_COMMANDS["/sit6"] = function()
            RolePlayNeeds.isResting = true
            PlayEmoteByIndex(123)

            d("You are resting.")
        end

        SLASH_COMMANDS["/sleep"] = function()
            RolePlayNeeds.isResting = true
            PlayEmoteByIndex(116)

            d("You are resting.")
        end
        SLASH_COMMANDS["/sleep2"] = function()
            RolePlayNeeds.isResting = true
            PlayEmoteByIndex(118)

            d(" You are resting.")
        end

        SLASH_COMMANDS["/eat"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(168)
        end
        SLASH_COMMANDS["/eat2"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(9)
        end
        SLASH_COMMANDS["/eat3"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(177)
        end
        SLASH_COMMANDS["/eat4"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(201)
        end

        SLASH_COMMANDS["/pie"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(207)
        end
        SLASH_COMMANDS["/marshmallowtreat"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(320)
        end
        SLASH_COMMANDS["/meal"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(210)
        end
        SLASH_COMMANDS["/soupbowl"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(208)
        end
        SLASH_COMMANDS["/spicysoup"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(329)
        end
        SLASH_COMMANDS["/smallbread"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(209)
        end
        SLASH_COMMANDS["/eatbread"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(176)
        end
        SLASH_COMMANDS["/drink"] = RolePlayNeeds.IncreaseWater
        SLASH_COMMANDS["/drink2"] = RolePlayNeeds.IncreaseWater2
        SLASH_COMMANDS["/drink3"] = RolePlayNeeds.IncreaseWater3
        SLASH_COMMANDS["/drinkhorn"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            PlayEmoteByIndex(284)
        end
        SLASH_COMMANDS["/drinkfromskull"] = function()
            RolePlayNeeds.IncreaseWaterNeutral()
            PlayEmoteByIndex(287)
        end
        SLASH_COMMANDS["/eatbread"] = function()
            RolePlayNeeds.IncreaseWaterNeutral()
            PlayEmoteByIndex(176)
        end
        SLASH_COMMANDS["/beachdrink"] = function()
            RolePlayNeeds.IncreaseWaterNeutral()
            PlayEmoteByIndex(423)
        end
        SLASH_COMMANDS["/sitdrink"] = RolePlayNeeds.IncreaseWaterSit
        SLASH_COMMANDS["/booze"] = RolePlayNeeds.IncreaseAlcohol

        SLASH_COMMANDS["/starve"] = RolePlayNeeds.ResetHunger
        SLASH_COMMANDS["/thirst"] = RolePlayNeeds.ResetWater
        SLASH_COMMANDS["/sober"] = RolePlayNeeds.ResetAlcohol
        SLASH_COMMANDS["/isSurvivalOn"] = function() return RolePlayNeeds.settings.survivalModeOn or false end

        SLASH_COMMANDS["/eatfood"] = function()
            RolePlayNeeds.IncreaseHungerNeutral()
            local X = RolePlayNeeds.settings.eatEmoteIndex or 201
            PlayEmoteByIndex(X)
        end
        SLASH_COMMANDS["/openaskforinfo"] = function()
            if isWheelOpen then
                SLASH_COMMANDS["/mywheel"]()
                isWheelOpen = false
            end
            SetGameCameraUIMode(false)
            zo_callLater(function()

                SLASH_COMMANDS["/askforinfo"]()
            end, 300)

        end
        SLASH_COMMANDS["/rest"] = function()

            SetGameCameraUIMode(false)
            if isWheelOpen then
                SLASH_COMMANDS["/mywheel"]()
                isWheelOpen = false
            end
            PlayEmoteByIndex(RolePlayNeeds.settings.restingEmoteIndex)
            RolePlayNeeds.isResting = true
            d('You are resting.')
        end
        SLASH_COMMANDS["/drinkwater"] = function()
            RolePlayNeeds.IncreaseWaterNeutral()
            PlayEmoteByIndex(RolePlayNeeds.settings.drinkEmoteIndex)
        end
        SLASH_COMMANDS["/togglesurvival"] = function()
            RolePlayNeeds.settings.survivalModeOn = not RolePlayNeeds.settings.survivalModeOn
            if RolePlayNeeds.settings.survivalModeOn then
                ShowCenterMessage("Survival Mode: ON!")
                UpdateRadialStatus()
            else
                UpdateRadialStatus()
                ShowCenterMessage("Survival Mode: OFF!")
            end
        end
        SLASH_COMMANDS["/checkneeds"] = RolePlayNeeds.CheckNeeds

        SLASH_COMMANDS["/openmypets"] = function()
            if isWheelOpen then
                SLASH_COMMANDS["/mywheel"]()
                isWheelOpen = false
            end
            SLASH_COMMANDS["/mypets"]()
        end

        SLASH_COMMANDS["/openmybook"] = function()
            SetGameCameraUIMode(false)
            if isWheelOpen then
                SLASH_COMMANDS["/mywheel"]()
                isWheelOpen = false
            end
            SLASH_COMMANDS["/readlastsaved"]()
        end


        SLASH_COMMANDS["/takeanap"] = function()
            if isWheelOpen then
                SLASH_COMMANDS["/mywheel"]()
                isWheelOpen = false
            end
            local x = 5
            StartNap(x)
        end
        SLASH_COMMANDS["/applydisease"] = function()
            RolePlayNeeds.ApplyDisease("Debug Disease: You feel your joints ache... ", 3)
        end

        SLASH_COMMANDS["/curedisease"] = function()
            RolePlayNeeds.CureDisease()
        end
        RolePlayNeeds.MakeMenu()
        em:RegisterForEvent("RolePlayNeeds_InventoryListener", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, RolePlayNeeds.OnInventoryChange)
        d(string.format("[RPN] Loaded. Hunger: %d, Water: %d", RolePlayNeeds.hunger.currentStage, RolePlayNeeds.water.currentStage))
        RolePlayNeeds.ShowDiseaseOverlay(s['hasDisease'],s['diseaseLv'])
        zo_callLater(function()

            InitializeWheel()
        end, 1500)

    end

em:RegisterForEvent("RolePlayNeeds_Loaded", EVENT_PLAYER_ACTIVATED, function()
    em:UnregisterForEvent("RolePlayNeeds_Loaded", EVENT_PLAYER_ACTIVATED)
    RolePlayNeeds:ForceInventoryScan()
end)


em:RegisterForEvent(RolePlayNeeds.name, EVENT_ADD_ON_LOADED, RolePlayNeeds.OnAddOnLoaded)
em:RegisterForEvent("RPN_StoreHook", EVENT_OPEN_STORE, RolePlayNeeds.OnStoreOpen)
em:RegisterForEvent("RPN_StoreHookClose", EVENT_CLOSE_STORE, RolePlayNeeds.OnStoreClose)