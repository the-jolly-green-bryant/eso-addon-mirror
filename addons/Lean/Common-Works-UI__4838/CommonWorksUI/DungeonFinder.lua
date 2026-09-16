-- Common Works -- Dungeon Finder bulk-select buttons
--
-- All three buttons only ADD: a second click is a no-op, manual picks survive.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local WM = WINDOW_MANAGER

-- Not listed here = DLC. The base-game set closed at Update 6, so it needs no upkeep.
-- Verify an id:  /script d(GetZoneNameById(688))
local EXCLUDED_ZONES = {
    -- Base game, the original 16
    [283] = true,   -- Fungal Grotto I
    [144] = true,   -- Spindleclutch I
    [380] = true,   -- The Banished Cells I
    [63]  = true,   -- Darkshade Caverns I
    [126] = true,   -- Elden Hollow I
    [146] = true,   -- Wayrest Sewers I
    [148] = true,   -- Arx Corinium
    [176] = true,   -- City of Ash I
    [130] = true,   -- Crypt of Hearts I
    [22]  = true,   -- Volenfell
    [131] = true,   -- Tempest Island
    [31]  = true,   -- Selene's Web
    [38]  = true,   -- Blackheart Haven
    [64]  = true,   -- Blessed Crucible
    [449] = true,   -- Direfrost Keep
    [11]  = true,   -- Vaults of Madness
    -- Base game, the "II" dungeons (Update 6)
    [934] = true,   -- Fungal Grotto II
    [936] = true,   -- Spindleclutch II
    [935] = true,   -- The Banished Cells II
    [930] = true,   -- Darkshade Caverns II
    [931] = true,   -- Elden Hollow II
    [933] = true,   -- Wayrest Sewers II
    [681] = true,   -- City of Ash II
    [932] = true,   -- Crypt of Hearts II
    -- DLC, but excluded by request
    [678] = true,   -- Imperial City Prison
    [688] = true,   -- White-Gold Tower
}

-- Both walked, so a button acts the same whichever section is expanded.
local NORMAL_CONTAINER, VET_CONTAINER = 2, 3
local CONTAINERS = { NORMAL_CONTAINER, VET_CONTAINER }

-- 200 is ZOS's QueueButton width; the quest pair splits it, 2 x 98 plus a 4px gutter.
local BTN_W, BTN_H = 200, 28
local HALF_W, ROW_GAP = 98, 4
-- Leave Queue centres on the category column, not the panel, so anchor to the column too.
-- Panel bottom is 90 below the column, button 200 above it.
local COLUMN_OFFSET_Y = -110

local function CheckFunDLC()
    local manager = ZO_ACTIVITY_FINDER_ROOT_MANAGER

    local ticked = 0
    for _, c in ipairs(CONTAINERS) do
        local container = _G["ZO_DungeonFinder_KeyboardListSectionScrollChildContainer" .. c]
        if container then
            for i = 1, container:GetNumChildren() do
                local row = container:GetChild(i)
                local data = row and row.node and row.node.data
                local zoneId = data and data.zoneId
                -- isLocked == false is the ownership gate; state 0 keeps this additive.
                if zoneId and zoneId > 0 and not EXCLUDED_ZONES[zoneId]
                    and data.isLocked == false
                    and row.check and row.check:GetState() == 0 then
                    -- The first paints the box, the second registers the location.
                    row.check:SetState(BSTATE_PRESSED, true)
                    manager:ToggleLocationSelected(data)
                    ticked = ticked + 1
                end
            end
        end
    end
    return ticked
end

-- Keyed by activity id (data.id); normal and vet share one quest since One Tamriel.
-- Ids from esoitem.uesp.net. Verify:  /script d(GetCompletedQuestInfo(3993))
local QUEST_BY_ACTIVITY = {
    [2]  = 3993,  [299] = 3993,   -- Fungal Grotto I
    [18] = 4303,  [312] = 4303,   -- Fungal Grotto II
    [3]  = 4054,  [315] = 4054,   -- Spindleclutch I
    [316] = 4555, [19]  = 4555,   -- Spindleclutch II
    [4]  = 4107,  [20]  = 4107,   -- The Banished Cells I
    [300] = 4597, [301] = 4597,   -- The Banished Cells II
    [5]  = 4145,  [309] = 4145,   -- Darkshade Caverns I
    [308] = 4641, [21]  = 4641,   -- Darkshade Caverns II
    [7]  = 4336,  [23]  = 4336,   -- Elden Hollow I
    [303] = 4675, [302] = 4675,   -- Elden Hollow II
    [6]  = 4246,  [306] = 4246,   -- Wayrest Sewers I
    [22] = 4813,  [307] = 4813,   -- Wayrest Sewers II
    [8]  = 4202,  [305] = 4202,   -- Arx Corinium
    [10] = 4778,  [310] = 4778,   -- City of Ash I
    [322] = 5120, [267] = 5120,   -- City of Ash II
    [9]  = 4379,  [261] = 4379,   -- Crypt of Hearts I
    [317] = 5113, [318] = 5113,   -- Crypt of Hearts II
    [11] = 4346,  [319] = 4346,   -- Direfrost Keep
    [12] = 4432,  [304] = 4432,   -- Volenfell
    [13] = 4538,  [311] = 4538,   -- Tempest Island
    [14] = 4469,  [320] = 4469,   -- Blessed Crucible
    [15] = 4589,  [321] = 4589,   -- Blackheart Haven
    [16] = 4733,  [313] = 4733,   -- Selene's Web
    [17] = 4822,  [314] = 4822,   -- Vaults of Madness
    [289] = 5136, [268] = 5136,   -- Imperial City Prison
    [288] = 5342, [287] = 5342,   -- White-Gold Tower
    [293] = 5403, [294] = 5403,   -- Ruins of Mazzatun
    [295] = 5702, [296] = 5702,   -- Cradle of Shadows
    [324] = 5889, [325] = 5889,   -- Bloodroot Forge
    [368] = 5891, [369] = 5891,   -- Falkreath Hold
    [420] = 6064, [421] = 6064,   -- Fang Lair
    [418] = 6065, [419] = 6065,   -- Scalecaller Peak
    [426] = 6186, [427] = 6186,   -- Moon Hunter Keep
    [428] = 6188, [429] = 6188,   -- March of Sacrifices
    [433] = 6249, [434] = 6249,   -- Frostvault
    [435] = 6251, [436] = 6251,   -- Depths of Malatar
    [494] = 6349, [495] = 6349,   -- Moongrave Fane
    [496] = 6351, [497] = 6351,   -- Lair of Maarselok
    [503] = 6414, [504] = 6414,   -- Icereach
    [505] = 6416, [506] = 6416,   -- Unhallowed Grave
    [507] = 6505, [508] = 6505,   -- Stone Garden
    [509] = 6507, [510] = 6507,   -- Castle Thorn
    [591] = 6576, [592] = 6576,   -- Black Drake Villa
    [593] = 6578, [594] = 6578,   -- The Cauldron
    [595] = 6683, [596] = 6683,   -- Red Petal Bastion
    [597] = 6685, [598] = 6685,   -- The Dread Cellar
    [599] = 6740, [600] = 6740,   -- Coral Aerie
    [601] = 6742, [602] = 6742,   -- Shipwright's Regret
    [608] = 6835, [609] = 6835,   -- Earthen Root Enclave
    [610] = 6837, [611] = 6837,   -- Graven Deep
    [613] = 6896, [614] = 6896,   -- Bal Sunnar
    [615] = 7027, [616] = 7027,   -- Scrivener's Hall
    [638] = 7105, [639] = 7105,   -- Oathsworn Pit
    [640] = 7155, [641] = 7155,   -- Bedlam Veil
    [855] = 7235, [856] = 7235,   -- Exiled Redoubt
    [857] = 7237, [858] = 7237,   -- Lep Seclusa
    [1037] = 7320, [1038] = 7320, -- Naj Caldeesh
    [1039] = 7323, [1040] = 7323, -- Black Gem Foundry
}

local function CheckIncompleteQuests(containerIndex)
    local manager = ZO_ACTIVITY_FINDER_ROOT_MANAGER

    local container = _G["ZO_DungeonFinder_KeyboardListSectionScrollChildContainer" .. containerIndex]
    if not container then return 0 end

    local ticked = 0
    for i = 1, container:GetNumChildren() do
        local row = container:GetChild(i)
        local data = row and row.node and row.node.data
        if data and data.isLocked == false and row.check and row.check:GetState() == 0 then
            local questId = QUEST_BY_ACTIVITY[data.id]
            -- A dungeon newer than the table has none; unknown counts as unfinished.
            if not questId or GetCompletedQuestInfo(questId) == "" then
                row.check:SetState(BSTATE_PRESSED, true)
                manager:ToggleLocationSelected(data)
                ticked = ticked + 1
            end
        end
    end
    return ticked
end

local function MakeButton(name, parent, width, text, tooltipKey, onClick)
    local btn = WM:CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
    btn:SetDimensions(width, BTN_H)
    btn:SetText(text)
    -- Layer and level clear the finder background; only tier crosses top-levels, which
    -- is what ZO_RightFootPrintBackground beside the panel needs.
    btn:SetDrawLayer(DL_OVERLAY)
    btn:SetDrawLevel(2)
    btn:SetDrawTier(DT_HIGH)
    btn:SetClickSound("Click")
    btn:SetHandler("OnClicked", onClick)
    btn:SetHandler("OnMouseEnter", function(self)
        -- Above, not beside: a side tooltip would cover the list.
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -4, TOP)
        SetTooltipText(InformationTooltip, CW.L[tooltipKey])
    end)
    btn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    return btn
end

-- ZO_DungeonFinder_Keyboard is built lazily, so anchoring at load time no-ops.
local function Install()
    if CW.funDlcButtonInstalled then return end
    local parent = ZO_DungeonFinder_Keyboard

    local btn = MakeButton("CW_FunDLCCheck", parent, BTN_W,
        CW.L.DF_FUN_DLC, "DF_FUN_DLC_TIP", function() CheckFunDLC() end)
    -- Anchoring across top-levels is legal; the parent still governs hiding.
    btn:SetAnchor(BOTTOM, ZO_GroupMenu_KeyboardCategories, BOTTOM, 0, COLUMN_OFFSET_Y)

    -- Anchored to the button above, so the pair moves with it.
    local normalBtn = MakeButton("CW_NormalQuestCheck", parent, HALF_W,
        CW.L.DF_NORMAL_QUESTS, "DF_NORMAL_QUESTS_TIP",
        function() CheckIncompleteQuests(NORMAL_CONTAINER) end)
    normalBtn:SetAnchor(TOPLEFT, btn, BOTTOMLEFT, 0, ROW_GAP)

    local vetBtn = MakeButton("CW_VetQuestCheck", parent, HALF_W,
        CW.L.DF_VET_QUESTS, "DF_VET_QUESTS_TIP",
        function() CheckIncompleteQuests(VET_CONTAINER) end)
    vetBtn:SetAnchor(TOPRIGHT, btn, BOTTOMRIGHT, 0, ROW_GAP)

    CW.funDlcButtonInstalled = true
end

-- Core calls this twice, from OnAddOnLoaded and OnPlayerActivated: the controls may
-- not exist yet at the first.
function CW.InstallFunDLCButton()
    if CW.funDlcButtonRegistered or not CW.SavedVars.dungeonFinderEnhance then return end
    local section = ZO_DungeonFinder_KeyboardListSection
    if not section then return end
    CW.funDlcButtonRegistered = true

    ZO_PreHookHandler(section, "OnEffectivelyShown", function() Install() end)

    -- Already open: the handler will not fire again.
    if not section:IsHidden() then Install() end
end
