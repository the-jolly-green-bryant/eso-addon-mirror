-- Beltalowda Client Ultimate Selector
-- Draggable selector box where player chooses which ultimate to report to group
-- Inspired by RdK's clientUltimateTLW design

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.ClientUltimateSelector = Beltalowda.UI.ClientUltimateSelector or {}

local CUS = Beltalowda.UI.ClientUltimateSelector
local wm = WINDOW_MANAGER

-- Constants
CUS.ICON_SIZE = 64
CUS.OFFSET = 12  -- Matches RdK exactly
-- Controls
CUS.controls = {
    window = nil,
    icon = nil,
    backdrop = nil,
    originalOverlay = nil,  -- Overlay showing original ult when upgrade is active
}

-- Settings
CUS.settings = {
    enabled = true,
    locked = false,
    scale = 1.0,
    opacity = 1.0,
    positionX = 900,
    positionY = 350,
    selectedUltimateId = 0,
    selectedIndex = 1,
}

-- Menu visibility state (set by centralized layer handler)
CUS.menuHidden = false

-- PvP visibility state (set by centralized PvP zone handler)
CUS.pvpHidden = false

--[[
    Set menu-hidden state (called by centralized layer handler)
]]--
function CUS.SetMenuHidden(hidden)
    CUS.menuHidden = hidden
    CUS.ApplySettings()
end

--[[
    Set PvP-hidden state (called by centralized PvP zone handler)
]]--
function CUS.SetPvPHidden(hidden)
    CUS.pvpHidden = hidden
    CUS.ApplySettings()
end

-- Available ultimates for selection (player's slotted ultimates)
CUS.availableUltimates = {
    -- Will be populated from player's actual slotted ultimates
    -- For now, just track what's selected
}

-- Hardcoded comprehensive ultimate list for manual override dropdown
-- This provides a full list of selectable ultimates for manual override
-- Kept separate from dynamic detection which is used for tracking
CUS.KNOWN_ULTIMATES = {
    -- Special: Auto-detect (0 = use dynamic detection)
    {id = 0, name = "Auto-Detect (Dynamic)"},
    
    -- Special Artifact Ultimates
    {id = 116096, name = "Ruinous Cyclone (Volendrung)"},
    {id = 195031, name = "Crypt Transfer (Cryptcannon)"},
    
    -- Class Ultimates
    {id = 16536, name = "Meteor"},  -- Sorcerer
    {id = 16538, name = "Ice Comet"},
    {id = 16540, name = "Shooting Star"},
    {id = 83619, name = "Elemental Storm"},  -- Destruction Staff
    {id = 83625, name = "Fire Storm"},
    {id = 83628, name = "Ice Storm"},
    {id = 83630, name = "Thunder Storm"},
    {id = 84434, name = "Elemental Rage"},
    {id = 85126, name = "Fiery Rage"},
    {id = 85128, name = "Icy Rage"},
    {id = 85130, name = "Thunderous Rage"},
    {id = 83642, name = "Eye of the Storm"},
    {id = 83682, name = "Eye of Flame"},
    {id = 83684, name = "Eye of Frost"},
    {id = 83686, name = "Eye of Lightning"},
    
    -- Templar
    {id = 40159, name = "Solar Prison"},
    {id = 40161, name = "Solar Disturbance"},
    {id = 40163, name = "Gravity Crush"},
    
    -- Necromancer  
    {id = 16491, name = "Frozen Colossus"},
    {id = 118308, name = "Frozen Colossus (Pesti)"},
    {id = 118222, name = "Glacial Colossus"},
    
    -- Nightblade
    {id = 25091, name = "Death Stroke"},
    {id = 25484, name = "Incapacitating Strike"},
    {id = 25493, name = "Soul Harvest"},
    
    -- Dragonknight
    {id = 28967, name = "Standard of Might"},
    {id = 32958, name = "Shifting Standard"},
    {id = 32944, name = "Corrosive Armor"},
    
    -- Warden
    {id = 85982, name = "Sleet Storm"},
    {id = 86050, name = "Northern Storm"},
    {id = 86109, name = "Permafrost"},
    
    -- Arcanist
    {id = 86117, name = "Gibbering Shelter"},
    {id = 192380, name = "Gibbering Shelter (Alt)"},
    
    -- Weapon Skill Lines
    {id = 35713, name = "Dawnbreaker"},  -- Fighters Guild
    {id = 40158, name = "Flawless Dawnbreaker"},
    {id = 40156, name = "Dawnbreaker of Smiting"},
    
    -- Alliance War
    {id = 38563, name = "War Horn"},  -- Assault
    {id = 40223, name = "Aggressive Horn"},
    {id = 40220, name = "Sturdy Horn"},
    
    {id = 38573, name = "Barrier"},  -- Support
    {id = 40237, name = "Reviving Barrier"},
    {id = 40239, name = "Replenishing Barrier"},
    
    -- Restoration Staff
    {id = 83552, name = "Panacea"},
    {id = 83557, name = "Life Giver"},
    {id = 83559, name = "Light's Champion"},
    
    -- Two-Handed
    {id = 28283, name = "Onslaught"},
    {id = 38788, name = "Berserker Strike"},
    {id = 38807, name = "Onslaught (Ravage)"},
    
    -- Dual Wield
    {id = 28279, name = "Lacerate"},
    {id = 38901, name = "Thrive in Chaos"},
    {id = 38910, name = "Rend"},
    
    -- Bow
    {id = 28858, name = "Ballista"},
    {id = 40385, name = "Ballista (Scattershot)"},
    {id = 40382, name = "Ballista (Snipe)"},
    
    -- Soul Magic
    {id = 24165, name = "Soul Strike"},
    {id = 24195, name = "Soul Assault"},
    {id = 24198, name = "Shatter Soul"},
    
    -- Vampire
    {id = 32624, name = "Bat Swarm"},
    {id = 38963, name = "Clouding Swarm"},
    {id = 38956, name = "Devouring Swarm"},
    
    -- Werewolf
    {id = 32455, name = "Werewolf Transformation"},
    {id = 39075, name = "Pack Leader"},
    {id = 39076, name = "Werewolf Berserker"},
}

--[[
    Initialize the Client Ultimate Selector
]]--
function CUS.Initialize()
    if CUS.initialized then return end
    -- Load settings
    CUS.LoadSettings()
    
    -- Create selector window
    CUS.CreateWindow()
    
    -- Apply settings
    CUS.ApplySettings()
    
    -- Detect player's slotted ultimates
    CUS.DetectPlayerUltimates()
    
    -- Register for events
    CUS.RegisterForEvents()
    
    CUS.initialized = true
    return true
end

--[[
    Load settings from SavedVariables
]]--
function CUS.LoadSettings()
    -- Initialize BeltalowdaVars if it doesn't exist yet
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.clientUltimateSelector = BeltalowdaVars.ui.clientUltimateSelector or {}
    
    local saved = BeltalowdaVars.ui.clientUltimateSelector
    
    CUS.settings.enabled = (saved.enabled ~= nil) and saved.enabled or true
    CUS.settings.locked = (saved.locked ~= nil) and saved.locked or false
    CUS.settings.scale = saved.scale or 1.0
    CUS.settings.opacity = saved.opacity or 1.0
    CUS.settings.positionX = saved.positionX or 900
    CUS.settings.positionY = saved.positionY or 350
    CUS.settings.selectedUltimateId = saved.selectedUltimateId or 0
    CUS.settings.selectedIndex = saved.selectedIndex or 1
end

--[[
    Save settings to SavedVariables
]]--
function CUS.SaveSettings()
    -- Ensure BeltalowdaVars exists
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    
    BeltalowdaVars.ui.clientUltimateSelector = {
        enabled = CUS.settings.enabled,
        locked = CUS.settings.locked,
        scale = CUS.settings.scale,
        opacity = CUS.settings.opacity,
        positionX = CUS.settings.positionX,
        positionY = CUS.settings.positionY,
        selectedUltimateId = CUS.settings.selectedUltimateId,
        selectedIndex = CUS.settings.selectedIndex,
    }
end

--[[
    Create the selector window
]]--
function CUS.CreateWindow()
    -- Check if window already exists to prevent duplicate name errors
    local window = wm:GetControlByName("BeltalowdaClientUltimateSelector")
    if window then
        CUS.controls.window = window
        return
    end
    
    window = wm:CreateTopLevelWindow("BeltalowdaClientUltimateSelector")
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_BACKGROUND)
    window:SetDrawLevel(1)
    window:SetMovable(not CUS.settings.locked)
    window:SetMouseEnabled(not CUS.settings.locked)  -- Matches RdK: both toggle together
    window:SetHidden(not CUS.settings.enabled)
    -- Note: NOT setting window alpha to 0 - that would make children invisible too!
    
    local width = CUS.ICON_SIZE + (CUS.OFFSET * 2)
    local height = CUS.ICON_SIZE + (CUS.OFFSET * 2)
    window:SetDimensions(width, height)
    
    -- Position
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CUS.settings.positionX, CUS.settings.positionY)
    
    -- Save position when moved
    window:SetHandler("OnMoveStop", function()
        CUS.OnWindowMoved()
    end)
    
    -- Create backdrop for dragging (matching RdK)
    local backdrop = wm:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    backdrop:SetDimensions(width, height)  -- Same size as window, not extending beyond
    -- Initial colors based on lock state (matches RdK exactly)
    if CUS.settings.locked then
        backdrop:SetCenterColor(1, 0, 0, 0.0)  -- Transparent when locked
        backdrop:SetEdgeColor(1, 0, 0, 0.0)
    else
        backdrop:SetCenterColor(1, 0, 0, 0.5)  -- Red semi-transparent fill when unlocked
        backdrop:SetEdgeColor(1, 0, 0, 0.0)
    end
    backdrop:SetMouseEnabled(not CUS.settings.locked)  -- Make backdrop draggable when unlocked
    
    -- Make backdrop draggable by forwarding drag events to parent window
    backdrop:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not CUS.settings.locked then
            window:StartMoving()
        end
    end)
    backdrop:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not CUS.settings.locked then
            window:StopMovingOrResizing()
        end
    end)
    
    window.backdrop = backdrop  -- Store reference for lock/unlock
    
    -- Create button (matches RdK: CT_BUTTON works even when parent has SetMouseEnabled(false))
    local button = wm:CreateControl(nil, window, CT_BUTTON)
    button:SetAnchor(CENTER, window, CENTER, 0, 0)
    button:SetDimensions(CUS.ICON_SIZE, CUS.ICON_SIZE)
    button:SetNormalTexture("/esoui/art/actionbar/abilityframe64_up.dds")
    button:SetPressedTexture("/esoui/art/actionbar/abilityframe64_down.dds")
    button:SetMouseOverTexture("EsoUI/Art/ActionBar/actionBar_mouseOver.dds")
    button:SetHidden(false)  -- Ensure button is visible
    button:SetHandler("OnClicked", function(control)
        CUS.ShowUltimateSelectionDialog(control)
    end)
    
    -- Create icon texture on top of button
    local icon = wm:CreateControl(nil, window, CT_TEXTURE)
    icon:SetAnchor(CENTER, button, CENTER, 0, 0)
    icon:SetDimensions(CUS.ICON_SIZE - 4, CUS.ICON_SIZE - 4)
    icon:SetTexture("/esoui/art/icons/ability_default.dds")
    icon:SetHidden(false)  -- Ensure icon is visible
    
    -- Tooltip on button
    button:SetHandler("OnMouseEnter", function(control)
        CUS.ShowTooltip(control)
    end)
    
    button:SetHandler("OnMouseExit", function(control)
        ClearTooltip(InformationTooltip)
    end)
    
    -- Create original-ult overlay (bottom-right quadrant of main icon)
    -- When a smart upgrade is active, the MAIN icon shows the upgraded ult
    -- and this small overlay shows the original detected ult for reference.
    local overlaySize = math.floor((CUS.ICON_SIZE - 4) / 2)
    
    local originalOverlay = wm:CreateControl(nil, window, CT_TEXTURE)
    originalOverlay:SetAnchor(BOTTOMRIGHT, icon, BOTTOMRIGHT, 0, 0)
    originalOverlay:SetDimensions(overlaySize, overlaySize)
    originalOverlay:SetTexture("/esoui/art/icons/ability_default.dds")
    originalOverlay:SetDrawLevel(3)
    originalOverlay:SetHidden(true)
    
    -- Orange glow layers for Volendrung ready state (#125)
    -- 3 nested backdrops: outer (faint, wide) → inner (bright, tight)
    -- Same technique as GroupUltimateDisplayByRoles glow layers
    local GUD = Beltalowda.UI.GroupUltimateDisplay
    local glowColor = GUD and GUD.COLORS and GUD.COLORS.MAX_ULT_WASTED or {1, 0.6, 0}
    local glowLayers = {}
    local glowSpecs = {
        {expand = 8, edgeWidth = 8, alpha = 0.15},  -- Outermost: faint wide glow
        {expand = 4, edgeWidth = 4, alpha = 0.35},  -- Middle layer
        {expand = 2, edgeWidth = 2, alpha = 0.65},  -- Innermost: bright tight glow
    }
    for i, spec in ipairs(glowSpecs) do
        local glow = wm:CreateControl(nil, window, CT_BACKDROP)
        glow:SetAnchor(TOPLEFT, button, TOPLEFT, -spec.expand, -spec.expand)
        glow:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, spec.expand, spec.expand)
        glow:SetCenterColor(0, 0, 0, 0)
        glow:SetEdgeColor(glowColor[1], glowColor[2], glowColor[3], spec.alpha)
        glow:SetEdgeTexture(nil, spec.edgeWidth, spec.edgeWidth, spec.edgeWidth, 0)
        glow:SetDrawLevel(11)
        glow:SetHidden(true)
        glowLayers[i] = glow
    end
    
    CUS.controls.window = window
    CUS.controls.backdrop = backdrop
    CUS.controls.button = button
    CUS.controls.icon = icon
    CUS.controls.originalOverlay = originalOverlay
    CUS.controls.glowLayers = glowLayers
end

--[[
    Apply settings to window
]]--
function CUS.ApplySettings()
    local window = CUS.controls.window
    if not window then return end
    
    window:SetHidden(not CUS.settings.enabled or CUS.menuHidden or CUS.pvpHidden)
    
    -- Apply lock state (matching RdK approach: both toggle together)
    -- NOTE: Window uses SetMovable/SetMouseEnabled pattern
    -- But CT_BUTTON children remain clickable even when parent has SetMouseEnabled(false)
    window:SetMovable(not CUS.settings.locked)
    window:SetMouseEnabled(not CUS.settings.locked)
    
    -- Update backdrop color (matching RdK exactly)
    if window.backdrop then
        window.backdrop:SetMouseEnabled(not CUS.settings.locked)  -- Toggle backdrop draggability
        if CUS.settings.locked then
            window.backdrop:SetCenterColor(1, 0, 0, 0.0)  -- Transparent when locked
            window.backdrop:SetEdgeColor(1, 0, 0, 0.0)
        else
            window.backdrop:SetCenterColor(1, 0, 0, 0.5)  -- Red semi-transparent fill when unlocked
            window.backdrop:SetEdgeColor(1, 0, 0, 0.0)
        end
    end
    
    -- Apply scale and opacity
    window:SetScale(CUS.settings.scale or 1.0)
    window:SetAlpha(CUS.settings.opacity or 1.0)
    
    -- Update position
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CUS.settings.positionX, CUS.settings.positionY)
    
    -- Update icon
    CUS.UpdateIcon()
end

--[[
    Handle window movement (matching RdK approach)
]]--
function CUS.OnWindowMoved()
    -- Only save position when unlocked (matching RdK)
    if CUS.settings.locked then return end
    
    local window = CUS.controls.window
    if not window then return end
    
    -- Use GetLeft() and GetTop() like RdK does for accurate screen coordinates
    CUS.settings.positionX = window:GetLeft()
    CUS.settings.positionY = window:GetTop()
    
    CUS.SaveSettings()
end

--[[
    Detect player's currently slotted ultimates (front bar and back bar)
    NOTE: This only detects available ultimates, doesn't change manual selection
]]--
function CUS.DetectPlayerUltimates()
    local UT = Beltalowda.Data.UltimateTracker
    
    CUS.availableUltimates = {}
    
    -- Track what we find this time
    local currentFront, currentBack = nil, nil
    
    -- Check both action bars (front bar = 0, back bar = 1)
    -- Slot 8 is always the ultimate slot in ESO
    for hotbarCategory = 0, 1 do
        local slotId = 8 -- Ultimate slot is always slot 8
        local abilityId = GetSlotBoundId(slotId, hotbarCategory)
        
        if abilityId and abilityId > 0 then
            -- GetSlotBoundId returns base morph IDs for the inactive bar.
            -- Resolve Destruction Staff ults to their element-specific variant
            -- (fire/ice/lightning) based on what staff is equipped on that bar.
            local RS = Beltalowda.Util and Beltalowda.Util.RoleScoring
            if RS and RS.ResolveDestroVariant then
                abilityId = RS.ResolveDestroVariant(abilityId, hotbarCategory)
            end
            
            if hotbarCategory == 0 then
                currentFront = abilityId
            else
                currentBack = abilityId
            end
            
            -- Slot 8 is always ultimate, so if there's an ability here, it's an ultimate
            table.insert(CUS.availableUltimates, {
                id = abilityId,
                hotbar = hotbarCategory,
            })
            
            -- Register with ultimate tracker
            UT.RegisterUltimate(abilityId)
        end
    end
    
    -- When in Auto-Detect mode (selectedUltimateId == 0), DON'T persist the
    -- detected ID — just update the icon dynamically. UpdateIcon() and
    -- BroadcastSelection() use RoleScoring to pick the best bar based on
    -- equipped gear. Previously this would save the detected ID, turning
    -- auto-detect into a stale manual selection after one detection.
    if CUS.settings.selectedUltimateId == 0 then
        -- Auto-Detect: use equipment-aware scoring to pick the best ult,
        -- then refresh the icon and broadcast the result.
        CUS.UpdateIcon()
        CUS.BroadcastSelection()
    elseif CUS.settings.selectedUltimateId > 0 then
        -- User has a saved selection - find its index in the new array
        -- This ensures selectedIndex stays in sync with selectedUltimateId
        local foundIndex = nil
        for i, ult in ipairs(CUS.availableUltimates) do
            if ult.id == CUS.settings.selectedUltimateId then
                foundIndex = i
                break
            end
        end
        
        if foundIndex then
            -- Update index to match the saved ultimate ID in the new array order
            CUS.settings.selectedIndex = foundIndex
        end
        -- Always update icon to reflect the saved selection
        CUS.UpdateIcon()
        
        -- Broadcast the saved selection on load so other group members see it
        -- This ensures the selection appears without needing to wait for EVENT_POWER_UPDATE
        CUS.BroadcastSelection()
    end
end

--[[
    Get the best ultimate for auto-detect mode using equipment-aware scoring.
    Falls back to front bar (availableUltimates[1]) if scoring isn't possible.
    
    @return number|nil  Ability ID of the best ultimate, or nil if none available
]]--
function CUS.GetAutoDetectedUltimate()
    if #CUS.availableUltimates == 0 then return nil end
    if #CUS.availableUltimates == 1 then return CUS.availableUltimates[1].id end

    -- We have two ultimates; try equipment-aware scoring
    local RS = Beltalowda.Util and Beltalowda.Util.RoleScoring
    if RS and RS.SelectBestUltimate then
        local frontUltId = nil
        local backUltId = nil
        for _, ult in ipairs(CUS.availableUltimates) do
            if ult.hotbar == 0 then frontUltId = ult.id end
            if ult.hotbar == 1 then backUltId = ult.id end
        end

        if frontUltId and backUltId then
            local equipRole = RS.GetLocalPlayerEquipmentRole()
            return RS.SelectBestUltimate(frontUltId, backUltId, equipRole)
        end
    end

    -- Fallback: front bar
    return CUS.availableUltimates[1].id
end

--[[
    Show dialog to select which ultimate to report to group
    Now dynamically builds list from detected ultimates (player's slotted + seen in group)
]]--
function CUS.ShowUltimateSelectionDialog(control)
    -- Two-level menu system organized by role categories
    -- Level 1: Auto-Detect, Volendrung, then role categories
    -- Level 2: Specific ultimates within each category
    
    local GUDBR = Beltalowda.UI.GroupUltimateDisplayByRoles
    if not GUDBR or not GUDBR.ULTIMATE_ROLES then
        -- Fallback to old behavior if role system not loaded
        ClearMenu()
        for _, ult in ipairs(CUS.KNOWN_ULTIMATES) do
            AddMenuItem(ult.name, function()
                CUS.SelectUltimate(ult.id)
            end)
        end
        ShowMenu(control)
        return
    end
    
    -- Morph consolidation: map morph IDs to their representative base ID
    -- Only the representative ID will appear in menus
    local morphGroups = {
        -- 2H ultimates → Berserker Strike
        [83216] = 83216,  -- Berserker Strike (base, representative)
        [83229] = 83216,  -- Onslaught → Berserker Strike
        [83238] = 83216,  -- Berserker Rage → Berserker Strike
        
        -- Templar Aedric Spear → Radial Sweep
        [22138] = 22138,  -- Radial Sweep (base, representative)
        [22144] = 22138,  -- Everlasting Sweep → Radial Sweep
        [22139] = 22138,  -- Crescent Sweep → Radial Sweep
        
        -- Destruction Staff → Elemental Storm (all element-specific variants)
        [83619] = 83619,  -- Elemental Storm (base, representative)
        [83625] = 83619,  -- Fire Storm
        [83628] = 83619,  -- Ice Storm
        [83630] = 83619,  -- Thunder Storm
        [84434] = 83619,  -- Elemental Rage
        [85126] = 83619,  -- Fiery Rage
        [85128] = 83619,  -- Icy Rage
        [85130] = 83619,  -- Thunderous Rage
        [83642] = 83619,  -- Eye of the Storm
        [83682] = 83619,  -- Eye of Flame
        [83684] = 83619,  -- Eye of Frost
        [83686] = 83619,  -- Eye of Lightning
        
        -- Bow → Rapid Fire
        [83465] = 83465,  -- Rapid Fire (base, representative)
        [85257] = 83465,  -- Toxic Barrage → Rapid Fire
        [85451] = 83465,  -- Ballista → Rapid Fire
        
        -- Dual Wield → Lacerate
        [83600] = 83600,  -- Lacerate (base, representative)
        [85179] = 83600,  -- Thrive in Chaos → Lacerate
        [85187] = 83600,  -- Rend → Lacerate
        
        -- Fighter's Guild → Dawnbreaker
        [35713] = 35713,  -- Dawnbreaker (base, representative)
        [40161] = 35713,  -- Flawless Dawnbreaker → Dawnbreaker
        [40158] = 35713,  -- Dawnbreaker of Smiting → Dawnbreaker
        
        -- Mage's Guild → Meteor
        [16536] = 16536,  -- Meteor (base, representative)
        [40489] = 16536,  -- Ice Comet → Meteor
        [40493] = 16536,  -- Shooting Star → Meteor
    }
    
    -- Build categorized lists from ULTIMATE_ROLES mapping
    local damageUlts = {}
    local healUlts = {}
    local shieldUlts = {}
    local utilityUlts = {}
    local seenRepresentatives = {}  -- Track which representatives we've already added
    
    for abilityId, role in pairs(GUDBR.ULTIMATE_ROLES) do
        -- Check if this ability is part of a morph group
        local representativeId = morphGroups[abilityId] or abilityId
        
        -- Skip if we've already added this representative
        if not seenRepresentatives[representativeId] then
            local abilityName = GetAbilityName(representativeId)
            if abilityName and abilityName ~= "" then
                local entry = {id = representativeId, name = abilityName}
                if role == GUDBR.ROLE_DAMAGE then
                    table.insert(damageUlts, entry)
                    seenRepresentatives[representativeId] = true
                elseif role == GUDBR.ROLE_HEALS then
                    table.insert(healUlts, entry)
                    seenRepresentatives[representativeId] = true
                elseif role == GUDBR.ROLE_SHIELDS then
                    table.insert(shieldUlts, entry)
                    seenRepresentatives[representativeId] = true
                elseif role == GUDBR.ROLE_UTILITY then
                    table.insert(utilityUlts, entry)
                    seenRepresentatives[representativeId] = true
                end
            end
        end
    end
    
    -- Sort each category alphabetically by name
    table.sort(damageUlts, function(a, b) return a.name < b.name end)
    table.sort(healUlts, function(a, b) return a.name < b.name end)
    table.sort(shieldUlts, function(a, b) return a.name < b.name end)
    table.sort(utilityUlts, function(a, b) return a.name < b.name end)
    
    -- Show Level 1 menu: categories
    ClearMenu()
    
    -- Top items: Auto-Detect and Volendrung (always available)
    AddMenuItem("Auto-Detect (Dynamic)", function()
        CUS.SelectUltimate(0)
    end)
    
    AddMenuItem("Ruinous Cyclone (Volendrung)", function()
        CUS.SelectUltimate(116096)
    end)
    
    -- Category submenus: Damage, Heals, Shields, Utility (in this order)
    if #damageUlts > 0 then
        AddMenuItem("Damage Ultimates →", function()
            zo_callLater(function()
                CUS.ShowCategoryMenu(control, damageUlts, "Damage Ultimates")
            end, 100)
        end)
    end
    
    if #healUlts > 0 then
        AddMenuItem("Heal Ultimates →", function()
            zo_callLater(function()
                CUS.ShowCategoryMenu(control, healUlts, "Heal Ultimates")
            end, 100)
        end)
    end
    
    if #shieldUlts > 0 then
        AddMenuItem("Shield Ultimates →", function()
            zo_callLater(function()
                CUS.ShowCategoryMenu(control, shieldUlts, "Shield Ultimates")
            end, 100)
        end)
    end
    
    if #utilityUlts > 0 then
        AddMenuItem("Utility Ultimates →", function()
            zo_callLater(function()
                CUS.ShowCategoryMenu(control, utilityUlts, "Utility Ultimates")
            end, 100)
        end)
    end
    
    ShowMenu(control)
end

--[[
    Show Level 2 menu: specific ultimates within a category
]]--
function CUS.ShowCategoryMenu(control, ultimates, categoryName)
    ClearMenu()
    
    -- Add header (back option)
    AddMenuItem("← Back", function()
        CUS.ShowUltimateSelectionDialog(control)
    end)
    
    -- Add all ultimates in this category
    for _, ult in ipairs(ultimates) do
        AddMenuItem(ult.name, function()
            CUS.SelectUltimate(ult.id)
        end)
    end
    
    ShowMenu(control)
end

--[[
    Select a specific ultimate
]]--
function CUS.SelectUltimate(abilityId)
    if abilityId == 0 then
        -- Special case: Auto-Detect selected - revert to dynamic tracking
        -- This triggers the ultimate detection to run again and use the detected ultimate
        CUS.settings.selectedUltimateId = 0
        CUS.DetectPlayerUltimates()  -- Re-detect and use actual slotted ultimate
        return
    end
    
    CUS.settings.selectedUltimateId = abilityId
    CUS.UpdateIcon()
    CUS.SaveSettings()
    
    -- Immediately broadcast the new selection
    CUS.BroadcastSelection()
    
    d(string.format("[Beltalowda] Selected ultimate %s, broadcasting immediately", GetAbilityName(abilityId)))
    
    -- Force an immediate UI refresh to show the player in the new column
    if Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay and Beltalowda.UI.GroupUltimateDisplay.RefreshDisplay then
        zo_callLater(function()
            Beltalowda.UI.GroupUltimateDisplay.RefreshDisplay()
        end, 50)  -- Small delay to ensure data is set
    end
end

--[[
    Cycle to next ultimate
]]--
function CUS.CycleUltimate()
    if #CUS.availableUltimates == 0 then
        -- No ultimates detected
        return
    end
    
    -- Cycle to next index
    local oldIndex = CUS.settings.selectedIndex
    CUS.settings.selectedIndex = CUS.settings.selectedIndex + 1
    if CUS.settings.selectedIndex > #CUS.availableUltimates then
        CUS.settings.selectedIndex = 1
    end
    
    -- Update selected ultimate ID
    CUS.settings.selectedUltimateId = CUS.availableUltimates[CUS.settings.selectedIndex].id
    
    -- Update icon
    CUS.UpdateIcon()
    
    -- Save
    CUS.SaveSettings()
    
    -- Broadcast to group (placeholder - will be implemented with LibGroupBroadcast)
    CUS.BroadcastSelection()
end

--[[
    Update icon texture
]]--
function CUS.UpdateIcon()
    if not CUS.controls.icon then return end
    
    -- Check if player has Volendrung (buff detection OR action bar detection)
    local BM = Beltalowda.BuffMonitor
    local frontUlt = GetSlotBoundId(8, 0) or 0
    local backUlt = GetSlotBoundId(8, 1) or 0
    local hasVolendrung = (BM and BM.HasVolendrung("player") or false)
        or frontUlt == 116096 or backUlt == 116096
    
    -- Determine which ultimate ID to display
    local displayUltimateId
    
    if hasVolendrung then
        -- Volendrung replaces all skills (#125): show full Ruinous Cyclone icon,
        -- no upgrade overlay, with orange glow when castable
        displayUltimateId = BM.RUINOUS_CYCLONE_ID
        local iconPath = GetAbilityIcon(displayUltimateId)
        CUS.controls.icon:SetTexture(iconPath and iconPath ~= "" and iconPath or "/esoui/art/icons/ability_default.dds")
        if CUS.controls.originalOverlay then
            CUS.controls.originalOverlay:SetHidden(true)
        end
        
        -- Show orange glow when Ruinous Cyclone is castable (>= 235 ult)
        local currentUlt = GetUnitPower("player", POWERTYPE_ULTIMATE)
        local volendrungReady = currentUlt >= 235
        if CUS.controls.glowLayers then
            for _, glow in ipairs(CUS.controls.glowLayers) do
                glow:SetHidden(not volendrungReady)
            end
        end
    else
        -- Normal case
        displayUltimateId = CUS.settings.selectedUltimateId
        
        -- If 0 (Auto-Detect) or no selection, use equipment-aware scoring
        if not displayUltimateId or displayUltimateId == 0 then
            displayUltimateId = CUS.GetAutoDetectedUltimate()
        end
        
        -- Hide Volendrung glow in normal mode
        if CUS.controls.glowLayers then
            for _, glow in ipairs(CUS.controls.glowLayers) do
                glow:SetHidden(true)
            end
        end
        
        -- Check for smart upgrade BEFORE setting the main icon
        -- If upgrade is active: main icon = upgraded ult, overlay = original detected ult
        CUS.UpdateUpgradeOverlay(displayUltimateId)
    end
end

--[[
    Update the client ult selector icons for smart upgrade state.
    When a smart upgrade is active, the main icon shows the upgraded ult
    and the small bottom-right overlay shows the original detected ult.
    When no upgrade is active, the main icon shows the detected ult normally
    and the overlay is hidden.
    
    @param detectedUltId  number  The normally-detected ultimate ID
]]--
function CUS.UpdateUpgradeOverlay(detectedUltId)
    local mainIcon = CUS.controls.icon
    local originalOverlay = CUS.controls.originalOverlay
    if not mainIcon then return end
    
    local GUDBR = Beltalowda.UI.GroupUltimateDisplayByRoles
    local upgradeUltId = nil
    
    if GUDBR then
        -- Get local player data
        local playerName = GetUnitName("player")
        local playerData = Beltalowda.UI.GroupUltimateDisplay
            and Beltalowda.UI.GroupUltimateDisplay.playerData
            and Beltalowda.UI.GroupUltimateDisplay.playerData[playerName]
        
        if playerData then
            -- Check for smart upgrade (damage first, then reanimate)
            if GUDBR.settings.smartDamageUpgrade and GUDBR.GetDamageUpgradeInfo then
                local damageId = GUDBR.GetDamageUpgradeInfo(playerData)
                if damageId and damageId ~= playerData.selectedUltimateId then
                    upgradeUltId = damageId
                end
            end
            
            if not upgradeUltId and GUDBR.settings.reanimateTracking and GUDBR.GetReanimateUpgradeInfo then
                local reanimateId = GUDBR.GetReanimateUpgradeInfo(playerData)
                if reanimateId then
                    upgradeUltId = reanimateId
                end
            end
        end
    end
    
    if upgradeUltId and detectedUltId then
        -- Upgrade active: show main/overlay based on user preference
        local showOriginalAsMain = GUDBR and GUDBR.settings and GUDBR.settings.showOriginalUltAsMain
        
        if showOriginalAsMain then
            -- User wants original ult as main, upgrade in overlay
            local originalPath = GetAbilityIcon(detectedUltId)
            mainIcon:SetTexture(originalPath and originalPath ~= "" and originalPath or "/esoui/art/icons/ability_default.dds")
            
            if originalOverlay then
                local upgradePath = GetAbilityIcon(upgradeUltId)
                originalOverlay:SetTexture(upgradePath and upgradePath ~= "" and upgradePath or "/esoui/art/icons/ability_default.dds")
                originalOverlay:SetHidden(false)
            end
        else
            -- Default: upgrade as main icon, original in overlay
            local upgradePath = GetAbilityIcon(upgradeUltId)
            mainIcon:SetTexture(upgradePath and upgradePath ~= "" and upgradePath or "/esoui/art/icons/ability_default.dds")
            
            if originalOverlay then
                local originalPath = GetAbilityIcon(detectedUltId)
                originalOverlay:SetTexture(originalPath and originalPath ~= "" and originalPath or "/esoui/art/icons/ability_default.dds")
                originalOverlay:SetHidden(false)
            end
        end
    else
        -- No upgrade: main icon = detected ult, overlay hidden
        if detectedUltId and detectedUltId > 0 then
            local iconPath = GetAbilityIcon(detectedUltId)
            mainIcon:SetTexture(iconPath and iconPath ~= "" and iconPath or "/esoui/art/icons/ability_default.dds")
        else
            mainIcon:SetTexture("/esoui/art/icons/ability_default.dds")
        end
        
        if originalOverlay then
            originalOverlay:SetHidden(true)
        end
    end
end

--[[
    Show tooltip with ultimate info
]]--
function CUS.ShowTooltip(control)
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)

    -- Determine the base detected ult ID
    local detectedUltId
    if CUS.settings.selectedUltimateId and CUS.settings.selectedUltimateId > 0 then
        detectedUltId = CUS.settings.selectedUltimateId
    else
        detectedUltId = CUS.GetAutoDetectedUltimate()
        InformationTooltip:AddLine("Auto-Detect (Dynamic)", "", 1, 1, 1)
    end

    if detectedUltId and detectedUltId > 0 then
        -- Check if a smart upgrade is currently active (same logic as UpdateUpgradeOverlay)
        local upgradeUltId = nil
        local GUDBR = Beltalowda.UI.GroupUltimateDisplayByRoles
        if GUDBR then
            local playerName = GetUnitName("player")
            local playerData = Beltalowda.UI.GroupUltimateDisplay
                and Beltalowda.UI.GroupUltimateDisplay.playerData
                and Beltalowda.UI.GroupUltimateDisplay.playerData[playerName]
            if playerData then
                if GUDBR.settings.smartDamageUpgrade and GUDBR.GetDamageUpgradeInfo then
                    local damageId = GUDBR.GetDamageUpgradeInfo(playerData)
                    if damageId and damageId ~= playerData.selectedUltimateId then
                        upgradeUltId = damageId
                    end
                end
                if not upgradeUltId and GUDBR.settings.reanimateTracking and GUDBR.GetReanimateUpgradeInfo then
                    local reanimateId = GUDBR.GetReanimateUpgradeInfo(playerData)
                    if reanimateId then
                        upgradeUltId = reanimateId
                    end
                end
            end
        end

        local detectedName = GetAbilityName(detectedUltId) or "Unknown"
        if upgradeUltId then
            local upgradeName = GetAbilityName(upgradeUltId) or "Unknown"
            InformationTooltip:AddLine(string.format("%s / %s", detectedName, upgradeName), "", 1, 1, 1)
        else
            InformationTooltip:AddLine(detectedName, "", 1, 1, 1)
        end
    end

    InformationTooltip:AddLine("", "", 1, 1, 1)
    InformationTooltip:AddLine("Click to override", "", 0.6, 0.6, 0.6)
end

--[[
    Broadcast selected ultimate to group via LibGroupBroadcast
    Now broadcasts dual ultimates (frontbar + backbar) along with resources
    Handles Volendrung special case: replaces ultimate with Ruinous Cyclone
]]--
function CUS.BroadcastSelection()
    -- Store in local player data for immediate UI feedback
    if Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay then
        local playerData = Beltalowda.UI.GroupUltimateDisplay.playerData
        local playerName = GetUnitName("player")
        
        -- Get current ultimate power
        local currentUlt, maxUlt = GetUnitPower("player", POWERTYPE_ULTIMATE)
        
        -- Detect both frontbar and backbar ultimates FIRST (needed for Volendrung check)
        -- Apply ResolveDestroVariant to get element-specific destro ult variants.
        -- Without this, GetSlotBoundId returns the base morph for the inactive bar
        -- (e.g. generic Elemental Storm 83642 instead of Eye of Frost 83684),
        -- causing the tracker icon to flicker on bar swap.
        local frontbarUltId = GetSlotBoundId(8, 0) or 0  -- Slot 8 = ultimate, bar 0 = frontbar
        local backbarUltId = GetSlotBoundId(8, 1) or 0   -- Slot 8 = ultimate, bar 1 = backbar
        
        local RS = Beltalowda.Util and Beltalowda.Util.RoleScoring
        if RS and RS.ResolveDestroVariant then
            frontbarUltId = RS.ResolveDestroVariant(frontbarUltId, 0)
            backbarUltId = RS.ResolveDestroVariant(backbarUltId, 1)
        end
        
        -- Check if player has Volendrung (buff detection OR action bar detection)
        local BM = Beltalowda.BuffMonitor
        local hasVolendrung = (BM and BM.HasVolendrung("player") or false)
            or frontbarUltId == 116096 or backbarUltId == 116096
        
        -- Handle Volendrung special case
        local primaryUltId
        local originalUltId = nil
        local volendrungActive = false
        
        if hasVolendrung then
            -- Store original ultimate if not already stored
            if not CUS.volendrungState or not CUS.volendrungState.originalUltId then
                -- Determine original ult: use manual selection if set,
                -- otherwise use whichever bar does NOT have Volendrung
                local origUlt
                if CUS.settings.selectedUltimateId and CUS.settings.selectedUltimateId > 0 then
                    origUlt = CUS.settings.selectedUltimateId
                elseif frontbarUltId == 116096 then
                    origUlt = backbarUltId   -- frontbar is Volendrung, original is on backbar
                else
                    origUlt = frontbarUltId  -- backbar is Volendrung (or neither), use frontbar
                end
                CUS.volendrungState = {
                    originalUltId = origUlt,
                    -- Determine which bar currently has Volendrung equipped
                    volendrungBar = (frontbarUltId == 116096) and 0 or 1
                }
            end
            
            -- Replace with Ruinous Cyclone
            primaryUltId = 116096
            originalUltId = CUS.volendrungState.originalUltId
            volendrungActive = true
        else
            -- Normal case: use manual selection if set, otherwise equipment-aware auto-detect
            if CUS.settings.selectedUltimateId and CUS.settings.selectedUltimateId > 0 then
                primaryUltId = CUS.settings.selectedUltimateId
            else
                primaryUltId = CUS.GetAutoDetectedUltimate() or frontbarUltId
            end
            
            -- Clear Volendrung state if it was previously active
            if CUS.volendrungState then
                CUS.volendrungState = nil
            end
        end
        
        -- Calculate percentage for primary ultimate
        -- CRITICAL FIX: GetAbilityCost() returns different values based on active weapon bar
        -- When the same ultimate is on both bars, we must track the minimum cost seen
        -- and always use that for consistency across bar swaps
        -- SPECIAL CASE: Ruinous Cyclone (Volendrung) has a fixed cost of 235 but GetAbilityCost
        -- returns 0 when not slotted, so we hardcode it
        local primaryPercent = 0
        
        if primaryUltId > 0 then
            -- Cryptcannon Vestments: Crypt Transfer (#121) can cast at any ult > 0.
            -- Skip all cost machinery — just report currentUlt out of 500 (max pool).
            if primaryUltId == 195031 then
                primaryPercent = math.max(0, math.min(500, (currentUlt / 500) * 100))
            else
            -- Get current cost for this ultimate
            local currentCost = select(1, GetAbilityCost(primaryUltId))
            
            -- Special handling for Ruinous Cyclone (Volendrung artifact)
            if primaryUltId == 116096 and (not currentCost or currentCost == 0) then
                currentCost = 235  -- Ruinous Cyclone always costs 235
            end
            
            -- Initialize cost tracking table if needed
            if not CUS.minCostCache then
                CUS.minCostCache = {}
            end
            
            -- Track minimum cost for this ultimate ID
            local cost = currentCost
            if type(currentCost) == "number" and currentCost > 0 then
                if not CUS.minCostCache[primaryUltId] or currentCost < CUS.minCostCache[primaryUltId] then
                    CUS.minCostCache[primaryUltId] = currentCost
                end
                -- Always use the minimum cost we've seen for this ultimate
                cost = CUS.minCostCache[primaryUltId]
            end
            
            if type(cost) == "number" and cost > 0 then
                primaryPercent = (currentUlt / cost) * 100
                -- Sanity check
                if primaryPercent ~= primaryPercent then  -- NaN check
                    primaryPercent = 0
                elseif primaryPercent == math.huge or primaryPercent == -math.huge then
                    primaryPercent = 0
                else
                    primaryPercent = math.max(0, math.min(500, primaryPercent))
                end
            end
            end -- else (non-Cryptcannon)
        end
        
        -- Store extended data in local playerData
        playerData[playerName] = playerData[playerName] or {}
        playerData[playerName].selectedUltimateId = primaryUltId
        playerData[playerName].ultimatePercent = primaryPercent
        playerData[playerName].currentUlt = currentUlt  -- Store raw ultimate value for display logic
        playerData[playerName].frontbarUltimateId = frontbarUltId
        playerData[playerName].backbarUltimateId = backbarUltId
        
        -- Mark local data as authoritative Beltalowda source with a fresh
        -- timestamp EVERY tick.  Without this, the dirty-flag optimisation
        -- below can skip the network broadcast for many seconds while idle,
        -- which means OnManualUltimateReceived never fires and `lastUpdate`
        -- goes stale.  RdKCompat's freshness check then considers the data
        -- expired and overwrites selectedUltimateId with the RDK_TO_ESO_ULT
        -- base-morph ID (e.g. Dragon Leap instead of Take Flight).
        playerData[playerName].source = "beltalowda"
        playerData[playerName].lastUpdate = GetGameTimeMilliseconds()
        
        -- Store Volendrung state
        playerData[playerName].hasVolendrung = volendrungActive
        playerData[playerName].originalUltId = originalUltId
        if CUS.volendrungState then
            playerData[playerName].volendrungBar = CUS.volendrungState.volendrungBar
        end
        
        -- Get resource data for local storage
        local magickaCurrent, magickaMax = GetUnitPower("player", POWERTYPE_MAGICKA)
        local staminaCurrent, staminaMax = GetUnitPower("player", POWERTYPE_STAMINA)
        playerData[playerName].magickaPercent = magickaMax > 0 and math.floor((magickaCurrent / magickaMax) * 100) or 0
        playerData[playerName].staminaPercent = staminaMax > 0 and math.floor((staminaCurrent / staminaMax) * 100) or 0
        playerData[playerName].inCombat = IsUnitInCombat("player")
        
        -- Dirty-flag optimisation: compare rounded broadcast-resolution values
        -- against the last transmitted snapshot.  When nothing meaningful changed
        -- (common on the 1 s timer while idle), skip the expensive network
        -- broadcast + full GUD UI rebuild.  This avoids ~700 µs per redundant
        -- cycle (broadcast ~350 µs + RefreshDisplay ~350 µs).
        local pd = playerData[playerName]
        local roundedUltPct = math.floor((pd.ultimatePercent or 0) + 0.5)
        local lb = CUS.lastBroadcast
        if lb
            and lb.selectedUltimateId == pd.selectedUltimateId
            and lb.ultimatePercent    == roundedUltPct
            and lb.frontbarUltimateId == pd.frontbarUltimateId
            and lb.backbarUltimateId  == pd.backbarUltimateId
            and lb.magickaPercent     == pd.magickaPercent
            and lb.staminaPercent     == pd.staminaPercent
            and lb.inCombat           == pd.inCombat
            and lb.hasVolendrung      == pd.hasVolendrung
        then
            return  -- nothing changed → skip broadcast + UI refresh
        end
        
        -- Cache current values for next comparison
        CUS.lastBroadcast = {
            selectedUltimateId = pd.selectedUltimateId,
            ultimatePercent    = roundedUltPct,
            frontbarUltimateId = pd.frontbarUltimateId,
            backbarUltimateId  = pd.backbarUltimateId,
            magickaPercent     = pd.magickaPercent,
            staminaPercent     = pd.staminaPercent,
            inCombat           = pd.inCombat,
            hasVolendrung      = pd.hasVolendrung,
        }
        
        -- Broadcast to group using network layer (only if in a group)
        if GetGroupSize() > 0 and Beltalowda.network and Beltalowda.network.BroadcastManualUltimate then
            -- Call enhanced broadcast with dual ultimate IDs and Volendrung state
            Beltalowda.network.BroadcastManualUltimate(primaryUltId, primaryPercent, frontbarUltId, backbarUltId, volendrungActive, originalUltId)
        end
        
        -- Refresh the UI to show the update
        if Beltalowda.UI.GroupUltimateDisplay.RefreshDisplay then
            Beltalowda.UI.GroupUltimateDisplay.RefreshDisplay()
        end
    end
end

--[[
    Register for events
]]--
function CUS.RegisterForEvents()
    -- Re-detect ultimates when abilities change
    EVENT_MANAGER:RegisterForEvent("BeltalowdaClientUltimateSelector", EVENT_ACTION_SLOTS_FULL_UPDATE, function()
        CUS.DetectPlayerUltimates()
    end)
    
    -- Re-detect on bar swap
    EVENT_MANAGER:RegisterForEvent("BeltalowdaClientUltimateSelector", EVENT_ACTION_SLOT_ABILITY_SLOTTED, function()
        CUS.DetectPlayerUltimates()
    end)
    
    -- Register callback for Volendrung state changes
    if Beltalowda.BuffMonitor and Beltalowda.BuffMonitor.RegisterVolendrungCallback then
        Beltalowda.BuffMonitor.RegisterVolendrungCallback("ClientUltimateSelector", function(unitTag, hasVolendrung)
            -- Check if this is the local player (unitTag can be "player" or "group1", "group2", etc.)
            local isLocalPlayer = (unitTag == "player") or (GetUnitName(unitTag) == GetUnitName("player"))
            
            if isLocalPlayer then
                -- Trigger immediate broadcast with new state
                CUS.BroadcastSelection()
                -- Update icon to show Ruinous Cyclone or restore original
                CUS.UpdateIcon()
            end
        end)
    end
    
    -- Force full re-detection on zone change (loading screen)
    -- Clears stale Volendrung state that persists when zoning out of a Volendrung area
    -- because EVENT_EFFECT_CHANGED FADED may not fire during zone transitions
    EVENT_MANAGER:RegisterForEvent("BeltalowdaClientUltimateSelector", EVENT_PLAYER_ACTIVATED, function()
        -- Clear Volendrung state unconditionally — DetectPlayerUltimates will
        -- re-establish it if the hammer is still equipped in the new zone
        CUS.volendrungState = nil
        -- Force BuffMonitor to clear stale data and rescan NOW, before we
        -- query BM.HasVolendrung() inside DetectPlayerUltimates/BroadcastSelection.
        -- Without this, a race condition exists: CUS handler can fire before
        -- BuffMonitor's own PLAYER_ACTIVATED handler, so HasVolendrung returns
        -- true from stale buffStates.
        local BM = Beltalowda.BuffMonitor
        if BM then
            BM.buffStates = {}
            BM.ScanPlayerBuffs()
        end
        CUS.DetectPlayerUltimates()
    end)

    -- Broadcast player state + resources every 1 second.
    -- Protocol 221 (state): selected ult ID, combat, Volendrung
    -- Protocol 227 (resources): ult charge 0-500, magicka %, stamina %
    -- Matches RdK compat heartbeat cadence for consistent group updates.
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaClientUltimateSelector", 1000, function()
        CUS.BroadcastSelection()
    end)

    -- Invalidate broadcast cache when group composition changes so new
    -- members receive our state on the very next 1 s tick.
    EVENT_MANAGER:RegisterForEvent("BeltalowdaClientUltimateSelector", EVENT_GROUP_MEMBER_JOINED, function()
        CUS.lastBroadcast = nil
    end)
end

--[[
    Toggle visibility
]]--
function CUS.Toggle()
    CUS.settings.enabled = not CUS.settings.enabled
    CUS.ApplySettings()
    CUS.SaveSettings()
end

--[[
    Toggle lock
]]--
function CUS.ToggleLock()
    CUS.settings.locked = not CUS.settings.locked
    CUS.ApplySettings()
    CUS.SaveSettings()
end

--[[
    Get currently selected ultimate ID
]]--
function CUS.GetSelectedUltimateId()
    return CUS.settings.selectedUltimateId
end

-- ============================================================================
-- Settings Panel Controls (called from BeltalowdaSettings.lua)
-- ============================================================================

function CUS.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFClient Ultimate Selector|r",
            tooltip = "Configure the client ultimate selector widget",
            controls = {
                {
                    type = "description",
                    text = "Configure the ultimate selector widget. Click the icon on-screen to choose which ultimate to report to your group.",
                    width = "full",
                },
                -- Enable Client Ultimate Selector
                {
                    type = "checkbox",
                    name = "Enable Client Ultimate Selector",
                    tooltip = "Show the client ultimate selector (click to choose which ultimate to report)",
                    getFunc = function() return CUS.settings.enabled end,
                    setFunc = function(value)
                        CUS.settings.enabled = value
                        CUS.ApplySettings()
                        CUS.SaveSettings()
                    end,
                    width = "full",
                    default = false,
                },
                -- Lock UI toggle
                {
                    type = "checkbox",
                    name = "Lock UI",
                    tooltip = "Lock the client ultimate selector in place (prevents accidental movement)",
                    getFunc = function() return CUS.settings.locked end,
                    setFunc = function(value)
                        CUS.settings.locked = value
                        CUS.ApplySettings()
                        CUS.SaveSettings()
                    end,
                    width = "full",
                    default = false,
                },
                -- Scale slider
                {
                    type = "slider",
                    name = "UI Scale",
                    tooltip = "Scale of the client ultimate selector",
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    getFunc = function() return CUS.settings.scale end,
                    setFunc = function(value)
                        CUS.settings.scale = value
                        CUS.ApplySettings()
                        CUS.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
                -- Opacity slider
                {
                    type = "slider",
                    name = "UI Opacity",
                    tooltip = "Transparency of the client ultimate selector (0 = invisible, 1 = opaque)",
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    getFunc = function() return CUS.settings.opacity end,
                    setFunc = function(value)
                        CUS.settings.opacity = value
                        CUS.ApplySettings()
                        CUS.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
            },
        },
    }
end

return CUS
