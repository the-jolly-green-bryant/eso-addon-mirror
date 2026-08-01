-- Beltalowda Group Equipment Display
-- UI component for displaying group members' equipped sets and roles

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.GroupEquipmentDisplay = {}

local GroupEquipmentDisplay = Beltalowda.UI.GroupEquipmentDisplay

-- Constants
local WINDOW_WIDTH = 400
local WINDOW_HEIGHT = 300
local ROW_HEIGHT = 30
local PADDING = 5

-- UI Controls
local mainWindow = nil
local contentControl = nil
local playerRows = {}

-- Settings (will be saved to SavedVariables)
local settings = {
    enabled = true,
    locked = false,
    scale = 1.0,
    opacity = 1.0,
    positionX = 150,
    positionY = 150,
}

-- Role detection uses SetDatabase.DetectRole() — no duplicate logic here

--[[
    Initialize the equipment display
]]--
function GroupEquipmentDisplay.Initialize()
    -- Load settings from SavedVariables
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupEquipmentDisplay = BeltalowdaVars.ui.groupEquipmentDisplay or {}
    
    local savedSettings = BeltalowdaVars.ui.groupEquipmentDisplay
    settings.enabled = savedSettings.enabled ~= false  -- default true
    settings.locked = savedSettings.locked or false
    settings.scale = savedSettings.scale or 1.0
    settings.opacity = savedSettings.opacity or 1.0
    settings.positionX = savedSettings.positionX or 150
    settings.positionY = savedSettings.positionY or 150
    
    -- Create the UI
    GroupEquipmentDisplay.CreateMainWindow()
    
    -- Subscribe to equipment data updates
    if Beltalowda.network and Beltalowda.network.OnDataChanged then
        local originalCallback = Beltalowda.network.OnDataChanged
        Beltalowda.network.OnDataChanged = function(dataType, unitTag)
            originalCallback(dataType, unitTag)
            if dataType == "equipment" then
                GroupEquipmentDisplay.OnEquipmentDataChanged(unitTag)
            end
        end
    end
    
    -- Start periodic refresh
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaEquipmentDisplay_Refresh", 2000, function()
        if settings.enabled then
            GroupEquipmentDisplay.RefreshDisplay()
        end
    end)
    
    -- Apply initial visibility
    if mainWindow then
        mainWindow:SetHidden(not settings.enabled)
    end
    
end

--[[
    Create the main window
]]--
function GroupEquipmentDisplay.CreateMainWindow()
    -- Create main window control
    mainWindow = WINDOW_MANAGER:CreateTopLevelWindow("BeltalowdaGroupEquipmentDisplay")
    mainWindow:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    mainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.positionX, settings.positionY)
    mainWindow:SetMovable(not settings.locked)
    mainWindow:SetMouseEnabled(true)
    mainWindow:SetClampedToScreen(true)
    mainWindow:SetHidden(not settings.enabled)
    mainWindow:SetAlpha(settings.opacity)
    mainWindow:SetScale(settings.scale)
    
    -- Backdrop
    local backdrop = WINDOW_MANAGER:CreateControl(nil, mainWindow, CT_BACKDROP)
    backdrop:SetAnchorFill(mainWindow)
    backdrop:SetCenterColor(0, 0, 0, 0.8)
    backdrop:SetEdgeColor(0.5, 0.5, 0.5, 1)
    backdrop:SetEdgeTexture("", 8, 1, 1)
    
    -- Title
    local title = WINDOW_MANAGER:CreateControl(nil, mainWindow, CT_LABEL)
    title:SetFont("ZoFontWinH4")
    title:SetText("Group Equipment")
    title:SetAnchor(TOP, mainWindow, TOP, 0, PADDING)
    title:SetColor(1, 1, 1, 1)
    
    -- Content area (scrollable)
    contentControl = WINDOW_MANAGER:CreateControl(nil, mainWindow, CT_CONTROL)
    contentControl:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, PADDING, 30)
    contentControl:SetAnchor(BOTTOMRIGHT, mainWindow, BOTTOMRIGHT, -PADDING, -PADDING)
    
    -- Handle window movement
    mainWindow:SetHandler("OnMoveStop", function(control)
        local _, _, _, offsetX, offsetY = control:GetAnchor(0)
        settings.positionX = offsetX
        settings.positionY = offsetY
        GroupEquipmentDisplay.SaveSettings()
    end)
end

--[[
    Create a player equipment row
]]--
function GroupEquipmentDisplay.CreatePlayerRow(parentControl, index)
    local row = WINDOW_MANAGER:CreateControl(nil, parentControl, CT_CONTROL)
    row:SetDimensions(WINDOW_WIDTH - (PADDING * 2), ROW_HEIGHT)
    row:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 0, (index - 1) * ROW_HEIGHT)
    
    -- Player name label
    local nameLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    nameLabel:SetFont("ZoFontGame")
    nameLabel:SetAnchor(LEFT, row, LEFT, 5, 0)
    nameLabel:SetText("Player " .. index)
    nameLabel:SetColor(1, 1, 1, 1)
    row.nameLabel = nameLabel
    
    -- Role indicator
    local roleLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    roleLabel:SetFont("ZoFontGame")
    roleLabel:SetAnchor(LEFT, nameLabel, RIGHT, 10, 0)
    roleLabel:SetText("[Role]")
    roleLabel:SetColor(0.7, 0.7, 1, 1)
    row.roleLabel = roleLabel
    
    -- Equipment info label
    local equipLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    equipLabel:SetFont("ZoFontGame")
    equipLabel:SetAnchor(LEFT, roleLabel, RIGHT, 10, 0)
    equipLabel:SetText("Sets: -")
    equipLabel:SetColor(0.8, 0.8, 0.8, 1)
    row.equipLabel = equipLabel
    
    return row
end

--[[
    Detect player role from equipped sets
    Delegates to SetDatabase.DetectRole() for unified PvP role taxonomy
]]--
function GroupEquipmentDisplay.DetectRole(setData)
    if not setData or type(setData) ~= "table" then
        return "Unknown"
    end
    
    local SetDB = Beltalowda.SetDatabase
    if SetDB and SetDB.DetectRole then
        local role = SetDB.DetectRole(setData)
        return SetDB.GetRoleDisplayName(role)
    end
    
    return "Damage"  -- Default
end

--[[
    Helper: Calculate total piece count for a set
]]--
local function GetSetPieceCount(setInfo)
    if not setInfo or not setInfo.numEquip then
        return 0
    end
    return (setInfo.numEquip.body or 0) + 
           (setInfo.numEquip.front or 0) + 
           (setInfo.numEquip.back or 0)
end

--[[
    Format equipment info for display.
    Uses pre-sorted usefulBits.sets from SetDatabase.ExtractUsefulBits() for
    consistent ordering: Monster (2/2) → Mythic → Arena (2/2) → Normal (5/5) → Incomplete.
    Falls back to raw setData if usefulBits is not available.
]]--
function GroupEquipmentDisplay.FormatEquipmentInfo(equipData, unitTag)
    local usefulBits = equipData and equipData.usefulBits
    local setData = equipData and equipData.rawData

    -- Prefer pre-sorted usefulBits.sets
    if usefulBits and usefulBits.sets and #usefulBits.sets > 0 then
        local setNames = {}
        for _, set in ipairs(usefulBits.sets) do
            local setDisplay = set.name .. " (" .. set.pieces .. "/" .. set.maxPieces .. ")"

            -- Add cooldown info for monster sets
            if Beltalowda.MonsterSets and Beltalowda.MonsterSets.IsMonsterSet(set.id) then
                local cooldown = Beltalowda.MonsterSets.GetCooldown(set.id)
                if cooldown and cooldown > 0 then
                    local remaining = Beltalowda.MonsterSets.GetRemainingCooldown(unitTag, set.id)
                    if remaining > 0 then
                        setDisplay = setDisplay .. string.format(" [CD: %.1fs]", remaining)
                    else
                        setDisplay = setDisplay .. " [Ready]"
                    end
                end
            end

            table.insert(setNames, setDisplay)
        end

        -- Append buffs/synergies after all sets
        if usefulBits.buffsProvided and #usefulBits.buffsProvided > 0 then
            table.insert(setNames, "Provides: " .. table.concat(usefulBits.buffsProvided, ", "))
        end

        return table.concat(setNames, ", ")
    end

    -- Fallback: raw setData (unordered)
    if not setData or type(setData) ~= "table" then
        return "No data"
    end
    
    local setNames = {}
    for setId, setInfo in pairs(setData) do
        if type(setId) == "number" and setInfo and setInfo.setName then
            local pieceCount = GetSetPieceCount(setInfo)
            
            if pieceCount >= 1 then  -- Show all active sets (including 1-piece mythics)
                local setDisplay = setInfo.setName .. " (" .. pieceCount .. ")"
                
                -- Add cooldown info for monster sets
                if Beltalowda.MonsterSets and Beltalowda.MonsterSets.IsMonsterSet(setId) then
                    local cooldown = Beltalowda.MonsterSets.GetCooldown(setId)
                    if cooldown and cooldown > 0 then
                        local remaining = Beltalowda.MonsterSets.GetRemainingCooldown(unitTag, setId)
                        if remaining > 0 then
                            setDisplay = setDisplay .. string.format(" [CD: %.1fs]", remaining)
                        else
                            setDisplay = setDisplay .. " [Ready]"
                        end
                    end
                end
                
                table.insert(setNames, setDisplay)
            end
        end
    end
    
    if #setNames == 0 then
        return "No sets"
    end
    
    return table.concat(setNames, ", ")
end

--[[
    Refresh the display with current data
]]--
function GroupEquipmentDisplay.RefreshDisplay()
    if not mainWindow or mainWindow:IsHidden() then
        return
    end
    
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        -- Not in group, hide all rows
        for _, row in ipairs(playerRows) do
            row:SetHidden(true)
        end
        return
    end
    
    -- Update or create rows for each group member
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        local playerName = GetUnitName(unitTag)
        
        -- Ensure row exists
        if not playerRows[i] then
            playerRows[i] = GroupEquipmentDisplay.CreatePlayerRow(contentControl, i)
        end
        
        local row = playerRows[i]
        row:SetHidden(false)
        
        -- Update player name
        row.nameLabel:SetText(string.format("[%d] %s", i, Beltalowda.GetDisplayName(unitTag)))
        
        -- Get equipment data
        local equipData = Beltalowda.network and Beltalowda.network.GetEquipmentData(unitTag)
        
        if equipData and equipData.rawData then
            -- Detect role
            local role = GroupEquipmentDisplay.DetectRole(equipData.rawData)
            row.roleLabel:SetText("[" .. role .. "]")
            
            -- Set role color using SetDatabase
            local SetDB = Beltalowda.SetDatabase
            if SetDB and SetDB.GetRoleColor then
                -- DetectRole returns display name, need raw role for color
                local rawRole = SetDB.DetectRole(equipData.rawData)
                local r, g, b = SetDB.GetRoleColor(rawRole)
                row.roleLabel:SetColor(r, g, b, 1)
            else
                row.roleLabel:SetColor(1, 0.3, 0.3, 1)  -- Default red
            end
            
            -- Format equipment info (uses pre-sorted usefulBits.sets when available)
            local equipInfo = GroupEquipmentDisplay.FormatEquipmentInfo(equipData, unitTag)
            row.equipLabel:SetText(equipInfo)
        else
            row.roleLabel:SetText("[?]")
            row.roleLabel:SetColor(0.5, 0.5, 0.5, 1)
            row.equipLabel:SetText("Waiting for data...")
        end
    end
    
    -- Hide extra rows
    for i = groupSize + 1, #playerRows do
        if playerRows[i] then
            playerRows[i]:SetHidden(true)
        end
    end
end

--[[
    Handle equipment data change for a unit
]]--
function GroupEquipmentDisplay.OnEquipmentDataChanged(unitTag)
    -- Trigger a refresh
    GroupEquipmentDisplay.RefreshDisplay()
end

--[[
    Save settings to SavedVariables
]]--
function GroupEquipmentDisplay.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupEquipmentDisplay = {
        enabled = settings.enabled,
        locked = settings.locked,
        scale = settings.scale,
        opacity = settings.opacity,
        positionX = settings.positionX,
        positionY = settings.positionY,
    }
end

--[[
    Toggle display visibility
]]--
function GroupEquipmentDisplay.Toggle()
    settings.enabled = not settings.enabled
    if mainWindow then
        mainWindow:SetHidden(not settings.enabled)
    end
    GroupEquipmentDisplay.SaveSettings()
end

--[[
    Toggle lock state
]]--
function GroupEquipmentDisplay.ToggleLock()
    settings.locked = not settings.locked
    if mainWindow then
        mainWindow:SetMovable(not settings.locked)
    end
    GroupEquipmentDisplay.SaveSettings()
end

--[[
    Set lock state
]]--
function GroupEquipmentDisplay.SetLock(locked)
    settings.locked = locked
    if mainWindow then
        mainWindow:SetMovable(not settings.locked)
    end
    GroupEquipmentDisplay.SaveSettings()
end

--[[
    Set scale
]]--
function GroupEquipmentDisplay.SetScale(scale)
    settings.scale = scale
    if mainWindow then
        mainWindow:SetScale(scale)
    end
    GroupEquipmentDisplay.SaveSettings()
end

--[[
    Set opacity
]]--
function GroupEquipmentDisplay.SetOpacity(opacity)
    settings.opacity = opacity
    if mainWindow then
        mainWindow:SetAlpha(opacity)
    end
    GroupEquipmentDisplay.SaveSettings()
end

-- Slash command handlers
SLASH_COMMANDS["/btlwequip"] = function(args)
    if args == "toggle" then
        GroupEquipmentDisplay.Toggle()
    elseif args == "lock" then
        GroupEquipmentDisplay.ToggleLock()
    elseif args == "refresh" then
        GroupEquipmentDisplay.RefreshDisplay()
    else
        d("  /btlwequip toggle  - Show/hide equipment display")
        d("  /btlwequip lock    - Lock/unlock for positioning")
        d("  /btlwequip refresh - Force refresh")
    end
end
