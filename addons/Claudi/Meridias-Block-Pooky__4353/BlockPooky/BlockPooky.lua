--[[
    BlockPooky - Main Module
    
    The core BlockPooky addon provides PvP awareness through block warnings and combat notifications.
    This is the main initialization and event handling module that coordinates all other components.
    
    Key Features:
    - Detects incoming pull abilities and warns the player to block
    - Provides multiple notification channels (UI, sound, chat, CSA)
    - Group integration with cross-addon compatibility (Agony Warning)
    - Customizable trigger abilities and notification settings
    
    Event Flow:
    1. Monitors EVENT_COMBAT_EVENT for ACTION_RESULT_EFFECT_GAINED
    2. Checks if ability matches configured triggers
    3. Validates source is not player/companion/group member
    4. Applies cooldown to prevent spam
    5. Triggers multi-channel warning system
--]]

--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
-- Addon version information
BlockPooky.version = 2.15
BlockPooky.svVersion = 1.8  -- SavedVariables version for config migration
BlockPooky.name = "BlockPooky"
BlockPooky.msgText = "BLOCK Pooky!"
-- Runtime state tracking
BlockPooky.isActive = false
BlockPooky.blockingregistered = false
-- Message templates for customization
BlockPooky.defaultMessages = {
    blockWarning = "BLOCK Pooky!",
    blockingHint = "Pooky BLOCKING!",
    vigorHint = "VIGOR!",
    dcReady = "DC Ready!",
    roaReady = "ROA Ready!",
    mountReady = "Pooky you can MOUNT!",
    ccImmunity = "CC Immunity",
    negateWarning = "MOVE Pooky! You're in a Negate!"
}
-- Map coordinate step size for ping encoding (from libgroupsocket)
BlockPooky.MapStepSize = 1.4285034012573e-005
local BlockPooky = BlockPooky

--[[
    Predefined Trigger Abilities
    
    These arrays contain ability IDs that should trigger block warnings.
    Uses one representative ID per ability to get the localized name via GetAbilityName().
    ESO abilities often have multiple IDs for the same ability, so we pick one reliable ID.
--]]
BlockPooky.predefinedTriggerAbilities = {
    -- effects
    159279, -- Agonie
    159385, -- Konvergenz
    -- skills
    20492, -- feuriger Griff (Fiery Grip)
    20496, -- unerbittlicher Griff (Unreleting Grip)
    20499, -- Ketten der Verwüstung (Chains of Devastation)
    40336, -- Silberne Leine (silver leash)
    18346, -- Teleportationsschlag (Teleport Strike)
    25494, -- Lotusfächer (Lotus Fan)
    25485, -- Hinterhalt (Ambush)
    21061, -- krit. Toben (Stampede)
    28448, -- krit. Stürmen (Critical Charge)
    38782 -- krit. Preschen (Critical Rush)
}
BlockPooky.predefinedPullAbilities = {
    -- effects
    159279, -- Agonie
    159385, -- Konvergenz
}

local BlockPooky_lastPookyWarning = 0
local BlockPooky_lastGroupMessage = 0
local BlockPooky_grpMsgActive = false

local BlockPooky_chat = LibChatMessage(BlockPooky.name, "BP") -- long and short tag to identify who is printing the message
--[[ GROUP MESSAGING WARNING: LibMapPing is used for cross-group communication.
     ZOS has flagged MapPing as a backdoor API and discouraged its use for data sharing (2024-12).
     A new official group communication API may be available in the future.
     Users should be aware this feature may violate ESOUI rules. --]]
local BlockPooky_LGPS = LibGPS2
local BlockPooky_LMP = LibMapPing


--[[ helper functions ------------------------------------------------------------------------------------------------]]

---Removes ESO's color code suffixes from ability/unit names
---ESO sometimes appends color codes like "^n" or "^p" to names, this strips them
---@param name string|nil the name to clean
---@return string cleaned name without color codes
function BlockPooky.CleanupName(name)
    if name then return name:gsub("%^%a%a?$", "") end
    return name or ""
end

---Checks if a given name is in the current group
---@param name string the name to check
---@return boolean true if the name is a group member
function BlockPooky.IsInGroup(name)
    return BlockPooky.group[name]
end

---Checks if the player is currently in Cyrodiil (AvA zone)
---@return boolean true if in a PvP zone
function BlockPooky.IsInCyro()
    return GetMapContentType() == MAP_CONTENT_AVA
end

---Gets the cleaned ability name for a given ability ID
---@param id number the ability ID
---@return string the cleaned ability name
function BlockPooky.CleanAbilityName(id)
    return BlockPooky.CleanupName(GetAbilityName(id))
end

---Sends a encoded warning message to group members via map ping
---Uses coordinate encoding to send a "pull warning" signal compatible with Agony Warning addon
---Original code concept comes from rdkgrouptool
function BlockPooky.SendWarning()
        BlockPooky_LGPS:PushCurrentMap()
        SetMapToMapListIndex(23)  -- Use specific map index for consistent coordinates
        BlockPooky_LMP:SetMapPing(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, BlockPooky.EncodeMessage(10, 10, 10, 10))
        BlockPooky_LGPS:PopCurrentMap()
end

function BlockPooky.OnBeforePingAdded(pingType, pingTag, x, y, isPingOwner)
    if (pingType == MAP_PIN_TYPE_PING) then
        BlockPooky_LGPS:PushCurrentMap()
        SetMapToMapListIndex(23)
        x, y = BlockPooky_LMP:GetMapPing(pingType, pingTag)
        local b0, b1, b2, b3 = BlockPooky.DecodeMessage(x,y)
        BlockPooky_LGPS:PopCurrentMap()
        BlockPooky_LMP:SuppressPing(pingType, pingTag)

        if b0 == 10 and b1 == 10 and b2 == 10 and b3 == 10 then
            if GetGameTimeMilliseconds() - BlockPooky_lastPookyWarning > BlockPooky.config.cooldown then
                BlockPooky_lastPookyWarning = GetGameTimeMilliseconds()
                BlockPooky.WarnThePooky('pull','group')
            end
        end
    end
end

function BlockPooky.OnAfterPingRemoved(pingType, pingTag, x, y, isPingOwner)
	if (pingType == MAP_PIN_TYPE_PING) then
		BlockPooky_LMP:UnsuppressPing(pingType, pingTag)
	end
end

--Original code comes from libgroupsocket
function BlockPooky.DecodeMessage(x, y)
	x = math.floor(x / BlockPooky.MapStepSize + 0.5)
	y = math.floor(y / BlockPooky.MapStepSize + 0.5)

	local b0 = math.floor(x / 0x100)
	local b1 = x % 0x100
	local b2 = math.floor(y / 0x100)
	local b3 = y % 0x100

	return b0, b1, b2, b3
end

function BlockPooky.EncodeMessage(b0, b1, b2, b3)
	b0 = b0 or 0
	b1 = b1 or 0
	b2 = b2 or 0
	b3 = b3 or 0
	return (b0 * 0x100 + b1) * BlockPooky.MapStepSize, (b2 * 0x100 + b3) * BlockPooky.MapStepSize
end


--[[ ui -------------------------------------------------------------------------------------------------------------]]


function BlockPooky.SetColor()
    if BlockPooky.config.color~=nil then
        BlockPookyIndicatorLabel:SetColor(unpack(BlockPooky.config.color))
    end
end

function BlockPooky.SetBlockingColor()
    if BlockPooky.config.blocking.color~=nil then
        BlockingPookyIndicatorLabel:SetColor(unpack(BlockPooky.config.blocking.color))
    end
end

---Update all UI frame text labels to match current config
function BlockPooky.UpdateUILabels()
    BlockPookyIndicatorLabel:SetText(BlockPooky.config.messages.blockWarning)
    BlockingPookyIndicatorLabel:SetText(BlockPooky.config.messages.blockingHint)
    VigorIndicatorLabel:SetText(BlockPooky.config.messages.vigorHint)
end

---intialize the UI frame thingy
function BlockPooky.InitUI()
    BlockPooky.RestorePosition()
    BlockPooky.setBlockPookyFont()
    BlockPooky.SetColor()
    BlockPooky.UpdateUILabels()
    EVENT_MANAGER:RegisterForUpdate(BlockPooky.name.."TickUpdate", 1000, function(gameTimeMs)
            BlockPooky.UpdateBlock(gameTimeMs)
            BlockPooky.DcReadyHint(gameTimeMs)
            BlockPooky.RoaReadyHint(gameTimeMs)
            BlockPooky.UpdateCastVigorHint(gameTimeMs)
        end)
    BlockPooky.SetUseBlocking()
    BlockPooky.CallbackManager = ZO_CallbackObject:New()
    BlockPookyIndicator:SetHidden(not BlockPooky.config.lockedUI)
    BlockingPookyIndicator:SetHidden(not BlockPooky.config.lockedUI)
    VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
    BlockPooky.SetBlockingColor()
    BlockPooky.SetVigorHintColor()
    BlockPooky.initCCBarUI()
    BlockPooky.InitCooldownBarUIs()
end

---lock or unlock the UI frame
---@param locked boolean
function BlockPooky.SetUiLock(locked)
    BlockPooky.config.lockedUI = locked
    BlockPookyIndicator:SetHidden(not locked)
    BlockingPookyIndicator:SetHidden(not locked)
    VigorIndicator:SetHidden(not locked)
    if BlockPooky.ccBar then
        BlockPooky.ccBar:SetHidden(not locked)
    end
    BlockPooky.CooldownBarsSetHidden(not locked)
    if BlockPooky.negateWarning then
        BlockPooky.negateWarning:SetHidden(not locked)
    end
end


--[[ Implementations ------------------------------------------------------------------------------------------------]]

---update the blook pooky ui frame eith the block hint
---@param gameTimeMs number
function BlockPooky.UpdateBlock(gameTimeMs)
    local hideMessage = gameTimeMs - BlockPooky_lastPookyWarning > BlockPooky.config.cooldown
    if hideMessage then
        if BlockPooky.isActive then
            BlockPookyIndicator:SetHidden(true)
            BlockPooky.isActive = false
        end
    else
        if not BlockPooky.isActive then
            BlockPookyIndicator:SetHidden(false)
            BlockPooky.isActive = true
        end
    end
end

function BlockPooky.StopBlockPooky(gameTimeMs)
    if BlockPooky.isActive then
        BlockPookyIndicator:SetHidden(true)
        BlockPooky.isActive = false
        -- BlockPooky_lastPookyWarning = gameTimeMs
    end
end

function BlockPooky.OnIndicatorMoveStop()
    BlockPooky.config.left = BlockPookyIndicator:GetLeft()
    BlockPooky.config.top = BlockPookyIndicator:GetTop()
    --d("move saved " .. BlockPooky.config.left .. " : " ..  BlockPooky.config.top)
end

function BlockPooky.ResetBlockPosition()
    if BlockPookyIndicator:GetAnchor() ~= nil then
        BlockPookyIndicator:ClearAnchors()
    end
    BlockPookyIndicator:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, -40)
    BlockPooky.OnIndicatorMoveStop()
end

function BlockPooky.ResetBlockingPosition()
    if BlockingPookyIndicator:GetAnchor() ~= nil then
        BlockingPookyIndicator:ClearAnchors()
    end
    BlockingPookyIndicator:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, -80)
    BlockPooky.OnBlockingIndicatorMoveStop()
end

function BlockPooky.ResetPosition()
    BlockPooky.ResetBlockPosition()
    BlockPooky.ResetBlockingPosition()
    BlockPooky.ResetHintsPosition()
    BlockPooky.ResetCCBarPosition()
    BlockPooky.ResetCooldownBarsPosition()
    BlockPooky.ResetNegateWarningPosition()
end

function BlockPooky.RestorePosition()
  local left = BlockPooky.config.left
  local top = BlockPooky.config.top
  if (left ~= nil and top ~= nil and left > 0 and top > 0) then
    if BlockPookyIndicator:GetAnchor() ~= nil then
        BlockPookyIndicator:ClearAnchors()
    end
    BlockPookyIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  else
    BlockPooky.ResetBlockPosition()
  end
  -- blocking
  left = BlockPooky.config.blocking.left
  top = BlockPooky.config.blocking.top
  if (left ~= nil and top ~= nil and left > 0 and top > 0) then
    if BlockingPookyIndicator:GetAnchor() ~= nil then
        BlockingPookyIndicator:ClearAnchors()
    end
    BlockingPookyIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  else
    BlockPooky.ResetBlockingPosition()
  end
  -- others
  BlockPooky.RestoreHintsPosition()
  BlockPooky.RestoreCCBarPosition()
  BlockPooky.RestoreCooldownBarsPosition()
  BlockPooky.RestoreNegateWarningPosition()
end

function BlockPooky.setBlockPookyFont()
    local font = CreateFont("BlockPookyFont")
    font:SetFont("$(BOLD_FONT)|" .. BlockPooky.config.fontSize .. "|soft-shadow-thin")
    local bigfont = CreateFont("BlockPookyBigFont")
    bigfont:SetFont("$(BOLD_FONT)|" .. BlockPooky.config.bigFontSize .. "|soft-shadow-thin")
end

function BlockPooky.Test()
    if GetGameTimeMilliseconds() - BlockPooky_lastPookyWarning > BlockPooky.config.cooldown then
        BlockPooky_lastPookyWarning = GetGameTimeMilliseconds()
	    BlockPooky.WarnThePooky("TEST","ME")
    end
	if BlockPooky.IsInGroup and BlockPooky.config.groupMessaging then
		BlockPooky.SendWarning()
	end
end

--[[ addon initialization -------------------------------------------------------------------------------------------]]

---load the group members if grouped
---the casts of the loaded group member will be ignored then
function BlockPooky.LoadGroupMembers()
    BlockPooky.grouped = IsUnitGrouped("player")
    BlockPooky.group = {}
    if BlockPooky.grouped then
        for i = 1, GROUP_SIZE_MAX do
            local groupMemberTag = GetGroupUnitTagByIndex(i)
            if groupMemberTag then
                local groupMemberName = GetUnitName(groupMemberTag)
                if groupMemberName then
                    BlockPooky.group[groupMemberName] = true
                end
            end
        end
    end
end

function BlockPooky.AddCustomAbilities()
    BlockPooky.CustomTriggerAbilities = {}
    for idx = #BlockPooky.config.customAbilityIds, 1, -1 do
        --d("custom: " .. BlockPooky.CleanAbilityName(BlockPooky.config.customAbilityIds[idx]))
        BlockPooky.CustomTriggerAbilities[BlockPooky.CleanAbilityName(BlockPooky.config.customAbilityIds[idx])] = true
    end
end

function BlockPooky.InitGroupMessaging()
    if BlockPooky_grpMsgActive==false then
        BlockPooky_LMP:RegisterCallback("BeforePingAdded", BlockPooky.OnBeforePingAdded)
	    BlockPooky_LMP:RegisterCallback("AfterPingRemoved", BlockPooky.OnAfterPingRemoved)
    end
end

function BlockPooky.StopGroupMessaging()
    if BlockPooky_grpMsgActive then
        BlockPooky_LMP:UnregisterCallback("BeforePingAdded")
	    BlockPooky_LMP:UnregisterCallback("AfterPingRemoved")
    end
end

--- main addon initialization
function BlockPooky.Initialize()
    BlockPooky.player = BlockPooky.CleanupName(GetUnitName("player")):lower()
    BlockPooky.dcAbilityName = BlockPooky.CleanupName(GetAbilityName(159385))
    BlockPooky.roaAbilityName = BlockPooky.CleanupName(GetAbilityName(159279))
    BlockPooky.companionName = GetUnitName("companion"):lower()
    BlockPooky.LoadGroupMembers()
    BlockPooky.InitUI()
    BlockPooky.InitAddonMenu()
    BlockPooky.AddCustomAbilities()
    if BlockPooky.config.groupMessaging then
        BlockPooky.InitGroupMessaging()
    end

    -- Apply combat visuals if enabled
    if BlockPooky.config.combatVisualsEnabled then
        BlockPooky.SetMaxAOEBrightness(BlockPooky.config.MaxAOEBrightness or 500)
        BlockPooky.SetMaxOutlineThickness(BlockPooky.config.MaxOutlineThickness or 2000)
        BlockPooky.SetMaxTargetOutlineIntensity(BlockPooky.config.MaxTargetOutlineIntensity or 2000)
    end
    -- Apply AOERGB if enabled
    if BlockPooky.config.AOERGBEnabled then
        if BlockPooky.SetAOERGBState then
            BlockPooky.SetAOERGBState(true, true)
        end
        if BlockPooky.config.AOERGBDefaultColor and SetSetting then
            SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, BlockPooky.config.AOERGBDefaultColor)
        end
        -- Speed and turbo are handled by SetAOERGBState if needed
    end

    -- [[register combat event]]
    EVENT_MANAGER:RegisterForEvent(BlockPooky.name, EVENT_COMBAT_EVENT, function(...) BlockPooky.OnCombat(...) end)
    -- Filter combat events at C level for performance: only ACTION_RESULT_EFFECT_GAINED, exclude errors
    EVENT_MANAGER:AddFilterForEvent(BlockPooky.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(BlockPooky.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
    
    EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "GroupUpdate", EVENT_GROUP_UPDATE, function(...) BlockPooky.OnGroupUpdate(...) end)
    EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "CombatNotification", EVENT_PLAYER_COMBAT_STATE, function(...)  BlockPooky.OnCombatNotification(...) end)
    EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "CompanionActivated", EVENT_COMPANION_ACTIVATED, function() BlockPooky.companionName=GetUnitName("companion") end)
    EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "CompanionDeactivated", EVENT_COMPANION_DEACTIVATED, function() BlockPooky.companionName="" end)
    if BlockPooky.config.CCImmunityHint then
        BlockPooky.CCEventRegisterUpdate()
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "CCWatcher", EVENT_EFFECT_CHANGED, function(...) BlockPooky.OnCCImmunityChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "CCWatcher", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) BlockPooky.OnSlotUpdate(...) end )
    EVENT_MANAGER:AddFilterForEvent(BlockPooky.name.."InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name.."InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_IS_NEW_ITEM, false)
    end
    BlockPooky.InitCooldownBarEvents()
    BlockPooky.InitNegateWarning()
    BlockPooky.InitThreatAlert()
    BlockPooky.SetThreatAlertTexture()
    BlockPooky.InitStaminaLow()
    BlockPooky.SetStaminaLowTexture()
    BlockPooky.InitHoTBarUI()
    BlockPooky.InitHoTTracker()
    --
    SLASH_COMMANDS["/blockpookytest"] = BlockPooky.Test
    SLASH_COMMANDS["/blockpookytestimmo"] = function() BlockPooky.TriggerPotionImmunity() end
end

--[[ ui interaction -------------------------------------------------------------------------------------------------]]

---show a CSA Message to the Pooky
---@param message string
function BlockPooky.MessageThePooky(message)
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
    params:SetCSAType(CSA_CATEGORY_LARGE_TEXT)
    params:SetText(message or BlockPooky.config.messages.blockWarning)
    params:SetLifespanMS(BlockPooky.config.msgLifeSpan)
    params:SetPriority(1)
    params:MarkShowImmediately()
    CENTER_SCREEN_ANNOUNCE:DisplayMessage(params)
end

--[[ user interaction -----------------------------------------------------------------------------------------------]]

---warn the Pooky as configured
---@param abilityName string
function BlockPooky.WarnThePooky(abilityName, sourceName)
    -- ui frame
    if BlockPooky.config.useFrame then
        BlockPooky.UpdateBlock(BlockPooky_lastPookyWarning)
    end
    -- screen warning
    if BlockPooky.config.useCSA then
        BlockPooky.MessageThePooky(BlockPooky.config.messages.blockWarning)
    end
    -- play sound
    if BlockPooky.config.playSound then
        PlaySound(SOUNDS.DUEL_START)
    end
    -- chat warning
    if BlockPooky.config.chatWarn then
        BlockPooky_chat:Print("WARNING: Incoming " .. abilityName .. "! from " .. sourceName)
    end
end

--[[ event handling -------------------------------------------------------------------------------------------------]]

---OnAddonLoaded Event Handler
---@param event any
---@param addonName string
function BlockPooky.OnAddOnLoaded(event, addonName)
    if addonName == BlockPooky.name then
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name, EVENT_ADD_ON_LOADED)
        local defaultConfig = {
            lockedUI=false,
            useCSA=true,
            playSound=true,
            useFrame=true,
            chatWarn=true,
            left=0,
            top=0,
            cooldown=5000,
            color={0.627,0.129,0.157,1.0},
            grpmsg_cooldown=2000,
            msgLifeSpan=1000,
            dcHint=false,
            roaHint=false,
            vigorHint=false,
            triggerAbilities={},
            customAbilityIds={},
            fontSize=45,
            bigFontSize =80,
            blocking={
                left=0,
                top=0,
                show=true,
                color={0.980, 0.655, 0.0, 1.0}
            },
            vigorUI={
                left=0,
                top=0,
                cooldown=4000,
                color={0.0,0.533,1.0,1.0}
            },
            groupMessaging=true,
            ccBarPosition = {
                left = 0,
                top = 0
            },
            ccBarColor= {0, 1, 0, 1},
            CCImmunityHint=true,
            msgPullAbilitiesOnly=true,
            pullAbilities={},
            cooldownbar={},
            investigate=false,
            investigateEffects=false,
            negate={
                show=false,
                left=0,
                top=0,
                color={1,0,0,1}
            },
            threatalert={
                show=false,
                pvpOnly=true,
                texture="reddot.dds",
                alpha=0.3,
                color={1,0,0,0.12},
                duration=8000,
                cooldown=5000,
                abilities={159385, 159279},  -- Dark Convergence, Rush of Agony (user can remove these)
                customAbilities={}
            },
            staminalow={
                show=false,
                threshold=5000,
                minAlpha=0.3,
                maxAlpha=0.72,
                texture="staminawarn.dds"
            },
            -- Combat Visuals defaults
            combatVisualsEnabled = false,
            MaxAOEBrightness = 500,
            MaxOutlineThickness = 2000,
            MaxTargetOutlineIntensity = 2000,
            -- RGB AOE Visuals defaults
            AOERGBEnabled = false,
            AOERGBDefaultColor = "ff0000",
            AOERGBSpeed = 50,
            AOERGBTurbo = 1,
            -- Customizable Messages
            messages = {
                blockWarning = "BLOCK Pooky!",
                blockingHint = "Pooky BLOCKING!",
                vigorHint = "VIGOR!",
                dcReady = "DC Ready!",
                roaReady = "ROA Ready!",
                mountReady = "Pooky you can MOUNT!",
                ccImmunity = "CC Immunity",
                negateWarning = "MOVE Pooky! You're in a Negate!"
            },
            -- HoT Tracking defaults
            showHoTCounter = false,
            hotBarPosition = {
                left = 0,
                top = 0
            }
        }
        for idx = #BlockPooky.predefinedTriggerAbilities, 1, -1 do
            -- d(\"this: \" .. BlockPooky.CleanAbilityName(BlockPooky.predefinedTriggerAbilities[idx]))
            defaultConfig.triggerAbilities[BlockPooky.CleanAbilityName(BlockPooky.predefinedTriggerAbilities[idx])] = true
        end
        for idx = #BlockPooky.predefinedPullAbilities, 1, -1 do
            defaultConfig.pullAbilities[BlockPooky.CleanAbilityName(BlockPooky.predefinedPullAbilities[idx])] = true
        end
        local defaultToonConfig = {
            cooldownbar={}
        }

        BlockPooky.toonConfig = ZO_SavedVars:New(BlockPooky.name .. "Config", BlockPooky.svVersion, "config", defaultToonConfig)
        BlockPooky.config = ZO_SavedVars:NewAccountWide(BlockPooky.name .. "Config", BlockPooky.svVersion, "config", defaultConfig)
        BlockPooky.Initialize()
    end
end

---COMBAT EVENT Handler
---@param eventCode any
---@param result any
---@param isError any
---@param abilityName any
---@param abilityGraphic any
---@param abilityActionSlotType any
---@param sourceName any
---@param sourceType any
---@param targetName any
---@param targetType any
---@param hitValue any
---@param powerType any
---@param damageType any
---@param combat_log any
---@param sourceUnitId any
---@param targetUnitId any
---@param abilityId any
function BlockPooky.OnCombat(
    eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType,
    combat_log, sourceUnitId, targetUnitId, abilityId
)
    --[[ Warn the Pooky to block!
        Note: Event is pre-filtered to ACTION_RESULT_EFFECT_GAINED and non-errors at C level via AddFilterForEvent.

        (1) check if it is one of the "pull abilities"
        (2) check source is not the player himself
        (3) check source is not a known group member
        (4) use a message cooldown
        (5) Warn the Pooky to BLOCK!
        (6) Handle DC uptimes
        (7) Handle ROA uptimes

    --]]
    local function isIn(set, element)
        return set[element] == true
    end

    -- (1)
    local cleanAbilityName = BlockPooky.CleanupName(abilityName)
    local cleanSourceName = BlockPooky.CleanupName(sourceName):lower()
    if BlockPooky.config.investigate and cleanSourceName~='' then
        d(string.format("Ability? Name: %s | ID: %d | Source: %s", cleanAbilityName, abilityId, cleanSourceName))
    end
    -- (1)
    if isIn(BlockPooky.config.triggerAbilities, cleanAbilityName) or isIn (BlockPooky.CustomTriggerAbilities, cleanAbilityName) then
        -- (2)
        if (cleanSourceName ~= "" and cleanSourceName ~= BlockPooky.player and cleanSourceName ~= BlockPooky.companionName) then
            -- (3)
            if BlockPooky.grouped == false or BlockPooky.group[cleanSourceName] ~= true then
                -- (4)
                if GetGameTimeMilliseconds() - BlockPooky_lastPookyWarning > BlockPooky.config.cooldown then
                    BlockPooky_lastPookyWarning = GetGameTimeMilliseconds()
                    -- (5)
                    BlockPooky.WarnThePooky(cleanAbilityName, cleanSourceName)
                end
            end
            if BlockPooky.grouped then
                local cleanTargetName = BlockPooky.CleanupName(targetName)
                if BlockPooky.IsInGroup(cleanTargetName) and cleanTargetName~=BlockPooky.player then
                    if GetGameTimeMilliseconds() - BlockPooky_lastGroupMessage > BlockPooky.config.grpmsg_cooldown then
                        BlockPooky_chat:Print("Pooky " .. cleanTargetName .. " hit by (" .. cleanAbilityName .. ")")
                    end
                end
                if BlockPooky.config.groupMessaging and cleanTargetName == BlockPooky.player then
                    if BlockPooky.config.msgPullAbilitiesOnly==false or isIn(BlockPooky.config.pullAbilities, cleanAbilityName) then
                        BlockPooky.SendWarning()
                    end
                end
            end
        end
        if cleanAbilityName == BlockPooky.dcAbilityName then
            if cleanSourceName == BlockPooky.player then
                BlockPooky.lastDcCast = GetGameTimeMilliseconds()
            end
        elseif cleanAbilityName == BlockPooky.roaAbilityName then
            if cleanSourceName == BlockPooky.player then
                BlockPooky.lastRoaCast = GetGameTimeMilliseconds()
            end
        end
    elseif BlockPooky.config.vigorHint and abilityId==61506 and result==2240 then -- echoing vigor
        local cleanSourceName = BlockPooky.CleanupName(sourceName)
        if cleanSourceName == BlockPooky.player then
            if GetGameTimeMilliseconds() - BlockPooky.lastVigorCast > 1000 then
                BlockPooky.lastVigorCast = GetGameTimeMilliseconds();
                vigorHint_active = false
                VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
            end
        end
    end
end

---reload group members when group is updated
function BlockPooky.OnGroupUpdate()
    BlockPooky.LoadGroupMembers()
end

function BlockPooky.OnCombatNotification(eventCode, inCombat)
    if BlockPooky.grouped and not inCombat and not IsMounted() and BlockPooky.IsInCyro() then
        BlockPooky.MessageThePooky(BlockPooky.config.messages.mountReady)
    end
end


--[[ MAIN -----------------------------------------------------------------------------------------------------------]]

EVENT_MANAGER:RegisterForEvent(BlockPooky.name, EVENT_ADD_ON_LOADED, function(...) BlockPooky.OnAddOnLoaded(...) end)
