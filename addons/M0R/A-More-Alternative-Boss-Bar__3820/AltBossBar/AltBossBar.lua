
local NAME = 'AltBossBar'
local SV_VER = 2

local SETTINGS

local ICONSIZE = ZO_COMPASS_FRAME_HEIGHT_KEYBOARD-8

local OVERSHIELD_COLOR_START = ZO_ColorDef:New("392952")
local OVERSHIELD_COLOR_END = ZO_ColorDef:New("968498")
local UNWAVERING_COLOR_START = ZO_ColorDef:New("7D7750")
local UNWAVERING_COLOR_END = ZO_ColorDef:New("DDDDCB")
local HP_COLOR_START = ZO_ColorDef:New("722323")
local HP_COLOR_END = ZO_ColorDef:New("DA3030")

local OVERSHIELD_GRADIENT = { OVERSHIELD_COLOR_START, OVERSHIELD_COLOR_END }
local UNWAVERING_GRADIENT = { UNWAVERING_COLOR_START, UNWAVERING_COLOR_END }
local HP_GRADIENT = { HP_COLOR_START, HP_COLOR_END } -- equal to ZO_POWER_BAR_GRADIENT_COLORS[COMBAT_MECHANIC_FLAGS_HEALTH]

AlternativeBossBars = {}



-- Modifying health thresholds to personal preference
local localData = {}



-- Assume +3 until something or another can be found to tell the differences
localData["Z'Maja"] = {
    [75] = "Siroria Spawn",
    [50] = "Relequen Spawn",
    [40] = "Creepers",
    [25] = "Galenwe Spawn",
    [5] = "Execute"
}

-- Crutch didnt show atro spawn points, also add blank bar at 20% for telling when to swap
localData["Lylanar"] = {
    normHealth = 10906420,
    vetHealth = 27943440,
    hmHealth = 55886880,
    ["Normal"] = {
            [90] = "Atronach",
            [80] = "Atronach",
            [70] = "2nd Boss Teleports",
            [65] = "1st Boss Teleports"
    },
    ["Veteran"] = {
            [90] = "Atronach",
            [80] = "Atronach",
            [70] = "2nd Boss Teleports",
            [65] = "1st Boss Teleports"
    },
    ["Hardmode"] = {
            [90] = "Same Colour Atronach",
            [85] = "Wrong Colour Atronach",
            [80] = "Same Colour Atronach",
            [75] = "Wrong Colour Atronach",
            [70] = "2nd Boss Teleports",
            [65] = "1st Boss Teleports",
            [20] = ""
    }
}

-- u46 Boss with 6 health bars, use total health instead of individual health
localData["Shaper of Flesh"] = {
    [84] = "Portal Activated",
    [67] = "Portal Activated",
    [50] = "Portal Activated",
    [34] = "Portal Activated",
    [17] = "Portal Activated",
    combinedHealthbar = true,
}



-- Crutch only uses boss1 names, ABB uses both bosses names, so add aliases

-- Thank you notnear for quickly mentioning this fix
local aliases = {}
aliases["Turlassil"] = "Lylanar"
aliases["Reducer"] = "Reactor"
aliases["Reclaimer"] = "Reactor"
aliases["Hunter-Killer Positrox"] = "Hunter-Killer Negatrix"



-- need to add language aliases for turli, reducer, reclaimer, positrox, shaper of flesh, lyl, zmaja
AlternativeBossBars.aliases = aliases




-- language aliases
-- de
aliases["Abfänger Positrox"] = "Hunter-Killer Negatrix"
aliases["Lylanar"] = "Lylanar"
aliases["Minderer"] = "Reactor"
aliases["Rückforderer"] = "Reactor"
aliases["Turlassil"] = "Lylanar"
aliases["Z'Maja"] = "Z'Maja"
-- es
aliases["Lylanar"] = "Lylanar"
aliases["Reinvindicador"] = "Reactor"
aliases["Turlassil"] = "Lylanar"
aliases["Z'Maja"] = "Z'Maja"
aliases["cazador asesino Positrox"] = "Hunter-Killer Negatrix"
aliases["reductor"] = "Reactor"
-- fr
aliases["Lylanar"] = "Lylanar"
aliases["Turlassil"] = "Lylanar"
aliases["Z'Maja"] = "Z'Maja"
aliases["chasseur-tueur positrox"] = "Hunter-Killer Negatrix"
aliases["récupérateur"] = "Reactor"
aliases["réducteur"] = "Reactor"
-- jp
aliases["ズマジャ"] = "Z'Maja"
aliases["トゥルラシル"] = "Lylanar"
aliases["ハンターキラー・ポジトロクス"] = "Hunter-Killer Negatrix"
aliases["リクライマー"] = "Reactor"
aliases["リデューサー"] = "Reactor"
aliases["リラナー"] = "Lylanar"
-- ru
aliases["З'Маджа"] = "Z'Maja"
aliases["Лиланар"] = "Lylanar"
aliases["Охотник-убийца Позитрокс"] = "Hunter-Killer Negatrix"
aliases["Регенератор"] = "Reactor"
aliases["Редуктор"] = "Reactor"
aliases["Турлассил"] = "Lylanar"
-- zh
aliases["减速器人"] = "Reactor"
aliases["图拉塞尔"] = "Lylanar"
aliases["泽玛亚"] = "Z'Maja"
aliases["猎杀者博西特洛克斯"] = "Hunter-Killer Negatrix"
aliases["莱拉纳尔"] = "Lylanar"
aliases["采集器人"] = "Reactor"






local combinedBossNames = {}
combinedBossNames["Shaper of Flesh"] = "Hall of Fleshcraft"
-- de
combinedBossNames["Former des Fleisches"] = "Halle des Fleischwerks^f"
-- es
combinedBossNames["moldeador de carne"] = "Salón de Manipulación de la Carne^m"
-- fr
combinedBossNames["façonneur de chair"] = "Salle des sculptechairs"
-- jp
combinedBossNames["肉の加工者"] = "肉細工の間"
-- ru
combinedBossNames["Формирователь плоти"] = "Зал Преображения Плоти"
-- zh
combinedBossNames["血肉塑形者"] = "血肉大厅"







AlternativeBossBars.combinedBossNames = combinedBossNames




local function getBossPercentagesByName(name, isTotalBar)


    -- Following code was taken from Crutch. Prob better way of doing it, but not a priority rn


    local data


    local localPotential = localData[name] or localData[aliases[name]]
    if localPotential then
        data = ZO_DeepTableCopy(localPotential)
    elseif (GetZoneId(GetUnitZoneIndex("player")) == 1436) then
        data = CrutchAlerts.BossHealthBar.eaThresholds[name] or CrutchAlerts.BossHealthBar.eaThresholds[aliases[name]]
    else
        data = CrutchAlerts.BossHealthBar.thresholds[name] or CrutchAlerts.BossHealthBar.thresholds[aliases[name]]
    end

    --a = data
    if data and data.combinedHealthbar and (isTotalBar ~= true) then
    	--d("Was not a thing")
    	--d(data.combinedHealthbar)
        return nil
    end

    -- Detect HM or vet or normal first based on boss health
    -- If not found, prioritize HM, then vet, and finally whatever data there is
    -- If there's no stages, do a default 75, 50, 25
    local _, powerMax, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
    if (not data) then
        data = {
            [75] = "",
            [50] = "",
            [25] = "",
        }
    elseif (powerMax == data.hmHealth and data.Hardmode) then
        data = data.Hardmode
    elseif (powerMax == data.vetHealth and data.Veteran) then
        data = data.Veteran
    elseif (powerMax == data.normHealth and data.Normal) then
        data = data.Normal
    elseif (data.Hardmode) then
        data = data.Hardmode
    elseif (data.Veteran) then
        data = data.Veteran
    elseif (data.Normal) then
        data = data.Normal
    else
        -- how did we get here
    end


    for i,v in pairs(data) do -- prob a better way of doing this, idk
        if type(i) ~= "number" then
            data[i] = nil
        end
    end

    return data
    
end

local function getWidth()
    return zo_clamp(GuiRoot:GetWidth() * .35, 400, 800)
end

local PercentLineManager = ZO_ControlPool:Subclass()
function PercentLineManager:New(parent, ...)
    local obj = ZO_ControlPool.New(self, "ABB_HP_Line_Template", parent, "ABB_HP_Line")
    --obj:Initialize( ... )
    return obj
end

local ABB_BossBar = ZO_Object:Subclass()
function ABB_BossBar:New(...)
    local bar = ZO_Object.New(self)
    bar:Initialize(...)
    return bar
end

function ABB_BossBar:Initialize(bossTag, topLevelCtrl, previousBar, combinedHealthbar)
    self.unitTag = bossTag
    self.parent = topLevelCtrl
    self.control = CreateControlFromVirtual("ABB_Frame"..bossTag, topLevelCtrl, "ABB_BossBar")
    self.control:SetHidden(true)
    local healthControl = GetControl(self.control, "Health")
    self.nameText = GetControl(healthControl, "Name")
    self.mechText = GetControl(healthControl, "Mech")
    self.healthText = GetControl(healthControl, "Text")
    self.healthBar = GetControl(healthControl, "Bar")
    self.healthLeftBgBar = GetControl(healthControl, "LeftBgBar")
    self.previousBar = previousBar
    self.nextBar = nil
    self.percentLinePool = PercentLineManager:New(self.healthBar)
    self.bossPercentages = nil
    self.hasShield = false
    self.hasImmunity = false
    self.oldMax = 0
    self.lines = {}

    self:ResetColors()

    local function PowerUpdateHandlerFunction(unitTag, powerPoolIndex, powerType, powerPool, powerPoolMax)
        self:OnPowerUpdate(powerPool, powerPoolMax, false)
    end
    
    self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function() self:UpdateWidth() end)
    self.control:RegisterForEvent(EVENT_SCREEN_RESIZED, function() self:UpdateWidth() end)

    if combinedHealthbar == nil then
        local powerUpdateEventHandler = ZO_MostRecentPowerUpdateHandler:New("BossBar"..bossTag, PowerUpdateHandlerFunction)
        powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
        powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, bossTag)
        self.control:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(eventCode, unitTag, ...) self:OnUavUpdate(...) end)
        self.control:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, self.unitTag)
        self.control:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(eventCode, unitTag, ...) self:OnUavUpdate(...) end)
        self.control:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, self.unitTag)
        self.control:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(eventCode, unitTag, ...) self:OnUavRemoval(...) end)
        self.control:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, self.unitTag)
    end

    self:ApplyStyle()
    self:ApplyAnchors()
end

function ABB_BossBar:CreateLine(percent)
    local line = self.percentLinePool:AcquireObject()
    local x = (self.healthBar:GetWidth() / 100) * percent
    x = x - 9 -- mod for better simmetry cause of healthLeftBgBar
    line:SetAnchor(TOPLEFT, self.healthBar, TOPLEFT, x, 0)
    line:SetAnchor(BOTTOMRIGHT, self.healthBar, TOPLEFT,  x, -0 + self.healthBar:GetHeight())
    self.lines[percent] = line
end

function ABB_BossBar:Refresh(force)
    if force then
        self:ApplyStyle()
    end
    local bossName = GetUnitName(self.unitTag)
    self.bossPercentages = getBossPercentagesByName(bossName)
    --d(bossName)
    --d(self.bossPercentages)
    --d("")
    self.percentLinePool:ReleaseAllObjects()
    if self.bossPercentages ~= nil then
    	AlternativeBossBars.setCombinedBarVisible(self.unitTag, false)
        self.lines = {}
        for i,v in pairs(self.bossPercentages) do
            self:CreateLine(i)
        end
    else
    	AlternativeBossBars.setCombinedBarVisible(self.unitTag, true)
    	self:Hide()
    	return true
    end
    self.nameText:SetText(bossName)
    local health, maxHealth = GetUnitPower(self.unitTag, POWERTYPE_HEALTH)
    --d("Refreshing: "..maxHealth.." from "..self.oldMax)
    self.oldMax = maxHealth
    self:OnPowerUpdate(health, maxHealth, force)
end

function ABB_BossBar:FormatPercent(health, maxHealth)
    local percentText
    
    local percent = 0
    if maxHealth ~= 0 then
        percent = (health / maxHealth) * 100
    end
    
    -- seperate from base game UI settings as some people had issues.
    percentText = ZO_FormatResourceBarCurrentAndMax(health, maxHealth, SETTINGS.HealthFormat)

    local nextMech = ""
    local nextPercent = 0

    if self.bossPercentages ~= nil then
        for i,v in pairs(self.bossPercentages) do

            if i > nextPercent and percent >= i then
                nextMech = v
                nextPercent = i
            end
        end
    end


    local colouredLine = 0
    if (percent >= nextPercent and percent <= nextPercent + SETTINGS.NOTIFY_BEFORE_PERCENT) then
        self.mechText:SetColor(1,1,0,1)
        colouredLine=nextPercent
    else
        self.mechText:SetColor(1,1,1,1)
    end

    for i,v in pairs(self.lines) do
        if i == colouredLine then
            self.lines[i]:SetColor(1,1,0,1)
        else
            self.lines[i]:SetColor(1,1,1,1)
        end
    end

    ---[[
    if nextMech ~= "" then
        self.mechText:SetText("Next at "..nextPercent.."%: "..nextMech)
    else
        self.mechText:SetText("")
    end
    --]]
    return percentText
end

function ABB_BossBar:OnPowerUpdate(health, maxHealth, force)
    ZO_StatusBar_SmoothTransition(self.healthBar, health, maxHealth, force)
    self.healthLeftBgBar:SetValue((health > 0 and 1 or 0))

    if health > 0 and not IsUnitDead(self.unitTag) then
        self.healthText:SetText(self:FormatPercent(health, maxHealth))
    else
        self.healthText:SetText(zo_iconFormat("esoui/art/icons/mapkey/mapkey_groupboss.dds", ICONSIZE, ICONSIZE))
    end

    if maxHealth ~= self.oldMax then
        --d("Boss Health Changed")
        self:Refresh()
        self.oldMax = maxHealth
    end
end

function ABB_BossBar:OnUavUpdate(unitAttributeVisual, _, _, _, value1)
    if (unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER) then
        if value1 ~= nil and value1 > 0 then
            if not self.hasImmunity then
                self.hasImmunity = true
                ZO_StatusBar_SetGradientColor(self.healthBar, UNWAVERING_GRADIENT)
                self.healthLeftBgBar:SetColor(UNWAVERING_COLOR_START:UnpackRGBA())
            end
        else
            self:OnUavRemoval(unitAttributeVisual)
        end
        return
    end
    if (unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and not self.hasImmunity) then
        if value1 ~= nil and value1 > 0 then
            if not self.hasShield then
                self.hasShield = true
                ZO_StatusBar_SetGradientColor(self.healthBar, OVERSHIELD_GRADIENT)
                self.healthLeftBgBar:SetColor(OVERSHIELD_COLOR_START:UnpackRGBA())
            end
        else
            self:OnUavRemoval(unitAttributeVisual)
        end
    end
end

function ABB_BossBar:OnUavRemoval(unitAttributeVisual)
    if (unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER) then
        if self.hasImmunity then
            self.hasImmunity = false
            self:ResetColors()
        end
        return
    end
    if (unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and not self.hasImmunity) then
        if self.hasShield then
            self.hasShield = false
            self:ResetColors()
        end
    end
end

function ABB_BossBar:ResetColors()
    ZO_StatusBar_SetGradientColor(self.healthBar, HP_GRADIENT)
    self.healthLeftBgBar:SetColor(HP_COLOR_START:UnpackRGBA())
end

function ABB_BossBar:ApplyAnchors()
    self.control:ClearAnchors()
    if self.previousBar ~= nil then
        self.previousBar.nextBar = self
        self.control:SetAnchor(TOP, self.previousBar.control, BOTTOM)
    else
        self.control:SetAnchor(TOP, self.parent, BOTTOM)
    end
end

function ABB_BossBar:ApplyStyle()
    ApplyTemplateToControl(self.control, ZO_GetPlatformTemplate("ABB_BossBar"))
    self:UpdateWidth()
end

function ABB_BossBar:UpdateWidth()
    self.control:SetWidth(getWidth())
end

function ABB_BossBar:Show()
    self.control:SetHidden(false)
end

function ABB_BossBar:Hide(dueToDespawn)
    if (dueToDespawn) and (not DoesUnitExist(self.unitTag)) then AlternativeBossBars.setCombinedBarVisible(self.unitTag, false) end
    self.control:SetHidden(true)
    self.hasShield = false
    self.hasImmunity = false
    self:ResetColors()
    if self.nextBar ~= nil then
        self.nextBar:Hide(dueToDespawn)
    end
end








local combinedBossBar = ABB_BossBar:Subclass()
function combinedBossBar:New(bossTag, topLevelCtrl, prevBossBar)
    local bar = ZO_Object.New(self)
    ABB_BossBar.Initialize(self, bossTag, topLevelCtrl, prevBossBar, true)
    bar:Initialize()
    return bar
end


function combinedBossBar:Initialize()
    self.unitTags = {}

    self.bossHealthsCurrent = {}
    self.bossHealthsMax = {}


    local function onCombinedPowerUpdate(unitTag, powerPoolIndex, powerType, powerPool, powerPoolMax)
        self:OnPowerUpdate(unitTag, powerPool, powerPoolMax)
    end

    for i = 1, MAX_BOSSES do
        local bossTag = "boss"..i
        self.unitTags[#self.unitTags+1] = bossTag

        local powerUpdateEventHandler = ZO_MostRecentPowerUpdateHandler:New("BossBarCombined"..bossTag, onCombinedPowerUpdate)
        powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
        powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, bossTag)
    end
end

function combinedBossBar:OnPowerUpdate(unitTag, powerPool, powerPoolMax)
    self.bossHealthsCurrent[unitTag] = powerPool
    self.bossHealthsMax[unitTag] = powerPoolMax

    local health = 0
    for i,v in pairs(self.bossHealthsCurrent) do
    	health = health + v
    end

    local maxHealth = 0
    for i,v in pairs(self.bossHealthsMax) do
    	maxHealth = maxHealth + v
    end

    ZO_StatusBar_SmoothTransition(self.healthBar, health, maxHealth, false)
    self.healthLeftBgBar:SetValue((health > 0 and 1 or 0))

    if health > 0 then
        self.healthText:SetText(self:FormatPercent(health, maxHealth))
    else
        self.healthText:SetText(zo_iconFormat("esoui/art/icons/mapkey/mapkey_groupboss.dds", ICONSIZE, ICONSIZE))
    end

    --if maxHealth ~= self.oldMax then
        --d("Boss Health Changed")
    --    self:Refresh()
    --    self.oldMax = maxHealth
    --end
end


function combinedBossBar:Refresh(force)
    if force then
        self:ApplyStyle()
    end

    local bossName = ""
    local displayName = ""
    for i,v in pairs(self.unitTags) do
    	bossName = GetUnitName(v)
    	if (bossName ~= "") then
            displayName = bossName
            local potentialCombinedName = combinedBossNames[bossName] or combinedBossNames[aliases[bossName]]
            if potentialCombinedName then
                displayName = potentialCombinedName
            end
            
    		break
    	end
    end
    
    if (bossName == nil) or (bossName == "") then
    	-- TODO: hide health bar and return
    	--self:Hide()
    	return
    end


    self.bossPercentages = getBossPercentagesByName(bossName, true)
    self.percentLinePool:ReleaseAllObjects()
    if self.bossPercentages ~= nil then
        self.lines = {}
        for i,v in pairs(self.bossPercentages) do
            self:CreateLine(i)
        end
    end
    self.nameText:SetText(displayName)
    --local health, maxHealth = GetUnitPower(self.unitTag, POWERTYPE_HEALTH)
    --d("Refreshing: "..maxHealth.." from "..self.oldMax)
    --self.oldMax = maxHealth
    local lastHealth = 0
    local lastMaxHealth = 0
    local lastUnitTag = 'group1'
    for i,unitTag in pairs(self.unitTags) do
    	local unitHealth, unitMaxHealth = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
	    self.bossHealthsCurrent[unitTag] = unitHealth
	    self.bossHealthsMax[unitTag] = unitMaxHealth
	    lastHealth = unitHealth
	    lastMaxHealth = unitMaxHealth
	    lastUnitTag = unitTag
	end
    self:OnPowerUpdate(lastUnitTag, lastHealth, lastMaxHealth)

end

function combinedBossBar:unitCreated(unitTag)
    if self.bossHealthsCurrent[unitTag] == nil then
        local unitHealth, unitMaxHealth = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
        self:OnPowerUpdate(unitTag, unitHealth, unitMaxHealth)
    end
end


function combinedBossBar:allUnitsDestroyed()
    for i,unitTag in pairs(self.unitTags) do
        self.bossHealthsCurrent[unitTag] = nil
        self.bossHealthsMax[unitTag] = nil
    end
end












local function AttachTargetTo(control)
    local targetFrame = UNIT_FRAMES:GetFrame("reticleover")
    local targetControl = targetFrame.frame
    targetControl:ClearAnchors()
    targetControl:SetAnchor(TOP, control, BOTTOM, 0, 5)
end

local bossBars = {}


AlternativeBossBars.totalBossBar = {}
local totalBossBar = AlternativeBossBars.totalBossBar


local function InitBars(topLevelCtrl)
    local prevBossBar
    for i = 1, MAX_BOSSES do
        local bossTag = "boss"..i
        bossBars[bossTag] = ABB_BossBar:New(bossTag, topLevelCtrl, prevBossBar)
        prevBossBar = bossBars[bossTag]
    end
    totalBossBar = combinedBossBar:New('bossCombined', topLevelCtrl)
end




local function RefreshAllBosses(forceReset)
    local lastBossBar
    local totalVisible = false

    for i = 1, MAX_BOSSES do
        local bossTag = "boss"..i

        if DoesUnitExist(bossTag) then
            totalVisible = bossBars[bossTag]:Refresh(forceReset)
            if not totalVisible then
            	bossBars[bossTag]:Show()
            end
        else
            
            bossBars[bossTag]:Hide(true)
            do break end
        end

        lastBossBar = bossBars[bossTag]
    end

    if totalVisible then
        COMPASS_FRAME_FRAGMENT:SetHiddenForReason("ABBar", true)
        AttachTargetTo(totalBossBar.control)
    elseif lastBossBar ~= nil then
        COMPASS_FRAME_FRAGMENT:SetHiddenForReason("ABBar", true)
        AttachTargetTo(lastBossBar.control)
    else
        COMPASS_FRAME_FRAGMENT:SetHiddenForReason("ABBar", false)
        AttachTargetTo(ZO_CompassFrame)
    end
end
AlternativeBossBars.RefreshAllBosses = RefreshAllBosses


local combinedVisibleTags = {}
local hiddenBar = true
local function setCombinedBarVisible(unitTag, visible)
	if visible then
		combinedVisibleTags[unitTag] = true
        totalBossBar:unitCreated(unitTag)
	else
		combinedVisibleTags[unitTag] = nil
	end

    --d("Visible:")
    --for i,v in pairs(combinedVisibleTags) do
    --    d(i)
    --end
	if ZO_IsTableEmpty(combinedVisibleTags) then
		-- set hidden
		if hiddenBar == false then
            hiddenBar = true
			totalBossBar:Hide()
			RefreshAllBosses()
			totalBossBar:Refresh()
            totalBossBar:allUnitsDestroyed()
            --hiddenBar = true
		end
	else
		if hiddenBar == true then
            hiddenBar = false
			totalBossBar:Show()
			--RefreshAllBosses()
			totalBossBar:Refresh()
		end
		-- set visible
	end
end
AlternativeBossBars.setCombinedBarVisible = setCombinedBarVisible




ABB_FakeGloss = ZO_Object:Subclass()
function ABB_FakeGloss:New()
    return ZO_Object.New(self)
end
function ABB_FakeGloss:SetMinMax() end
function ABB_FakeGloss:SetValue() end

-------------------------------------
--Settings Menu--
-------------------------------------
local function InitializeAddonMenu()
    local LAM2 = LibAddonMenu2

    LAM2:RegisterAddonPanel("ABB_Settings", {
        type = "panel",
        name = "Alternative Boss Bars",
        displayName = "Alternative Boss Bars",
        author = "|c943810BulDeZir|r",
        version = string.format('|c00FF00%s|r', 1),
        registerForRefresh = true,
    })

    local HealthFormatValues = {
        ["Off"] = RESOURCE_NUMBERS_SETTING_OFF,
        ["Number Only"] = RESOURCE_NUMBERS_SETTING_NUMBER_ONLY,
        ["Percent Only"] = RESOURCE_NUMBERS_SETTING_PERCENT_ONLY,
        ["Number and Percent"] = RESOURCE_NUMBERS_SETTING_NUMBER_AND_PERCENT,
    }
    local HealthFormatLookup = {}
    for i,v in pairs(HealthFormatValues) do
        HealthFormatLookup[v] = i
    end

    LAM2:RegisterOptionControls("ABB_Settings", {
        {
            type = "dropdown",
            name = "Health Bar Number Format",
            choices = {"Off", "Number Only", "Percent Only", "Number and Percent"},
            getFunc = function() return HealthFormatLookup[SETTINGS.HealthFormat] end,
            setFunc = function(newValue)
                local formattedValue = HealthFormatValues[newValue]
                if formattedValue == nil then
                    d("Alternative Boss Bar: Some weird thing happened, please contact M0R to let him know you got this message. ID=01")
                end
                SETTINGS.HealthFormat = formattedValue
                RefreshAllBosses()
            end,
        },
        {
            type = "checkbox",
            name = "Show Default Percent Lines (75%, 50%, 25%)",
            getFunc = function() return SETTINGS.SHOW_DEFAULTS end,
            setFunc = function(newValue)
                SETTINGS.SHOW_DEFAULTS = newValue
                RefreshAllBosses()
            end,
        },
        {
            type = "slider",
            name = 'Number of %, BEFORE showing alert icon',
            min = 0,
            max = 5,
            step = 1,
            getFunc = function() return SETTINGS.NOTIFY_BEFORE_PERCENT end,
            setFunc = function(newValue)
                SETTINGS.NOTIFY_BEFORE_PERCENT = zo_round(newValue)
                RefreshAllBosses()
            end,
        },
    })
end

function ABB_Initialize(topLevelCtrl)

    local function OnAddOnLoaded(_, addonName)
        if addonName == NAME then

            SETTINGS = ZO_SavedVars:NewAccountWide("AltBossBarSavedVariables", SV_VER, nil, {
                SHOW_DEFAULTS = false,
                NOTIFY_BEFORE_PERCENT = 2,
                HealthFormat = RESOURCE_NUMBERS_SETTING_NUMBER_AND_PERCENT,
            })

            InitializeAddonMenu()

            COMPASS_FRAME:SetBossBarHiddenForReason('modded', true)
            local fragment = ZO_SimpleSceneFragment:New(topLevelCtrl)
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)

            InitBars(topLevelCtrl)
            topLevelCtrl:RegisterForEvent(EVENT_BOSSES_CHANGED, function(_, forceReset) RefreshAllBosses(forceReset) end)
            topLevelCtrl:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function() RefreshAllBosses() end)
            topLevelCtrl:RegisterForEvent(EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function() RefreshAllBosses(true) end)

            EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        end
    end

    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end


--AlternativeBossBars = bossBars
AlternativeBossBars.bossBars = bossBars