-- ============================================
-- GUILD GAMES MODULE
-- Multiplayer mini-games for guild events
-- ============================================

NWT.GuildGames = {
    isOpen = false,
    sceneInitialized = false,
    
    -- Navigation state
    selectedGameIndex = 1,
    focusPanel = "games", -- "games", "center"
    
    -- Game state
    currentGame = nil,      -- Currently selected game type
    gameState = "idle",     -- "idle", "lobby", "playing", "results"
    isHost = false,         -- Is this player the host (group leader)?
    lobbyHostName = nil,    -- Display name of lobby host
    joinedPlayers = {},     -- Players who have joined the lobby
    
    -- Settings dialog state
    settingsOpen = false,
    settingsRowIndex = 1,
    gameSettings = {},      -- Per-game settings overrides
    
    -- Network state
    authKey = nil,
    lastBroadcast = 0,
    BROADCAST_COOLDOWN = 500, -- ms
    
    -- Player tracking
    players = {},           -- { unitTag, name, displayName, status, score }
    localPlayerIndex = 0,
    
    -- Game-specific state
    tagState = {
        itPlayerIndex = 0,
        tagCounts = {},
        roundTimeRemaining = 0,
    },
    
    raceState = {
        checkpoints = {},
        playerProgress = {},
    },
    
    -- Update timer
    updateInterval = nil,
}

-- Game definitions
NWT.GuildGames.GAMES = {
    {
        id = "tag",
        name = "Tag",
        icon = "/esoui/art/icons/ability_buff_major_expedition.dds",
        description = "One player is IT and must tag others by getting close to them!",
        minPlayers = 2,
        maxPlayers = 12,
        instructions = {
            "One player starts as 'IT' (marked with skull)",
            "IT must get close to other players to tag them",
            "When tagged, you become the new IT",
            "Player with fewest tags at the end wins!",
        },
        settings = {
            tagDistance = 300,      -- ~3 meters
            roundDuration = 180,    -- 3 minutes
        },
    },
    {
        id = "freezeTag",
        name = "Freeze Tag",
        icon = "/esoui/art/icons/ability_debuff_snare.dds",
        description = "IT freezes players! Teammates can unfreeze by standing near frozen players.",
        minPlayers = 3,
        maxPlayers = 12,
        instructions = {
            "IT player tags others to FREEZE them",
            "Frozen players must stop moving",
            "Non-frozen players unfreeze teammates by standing near them for 3 seconds",
            "IT wins if everyone is frozen, Runners win if time expires!",
        },
        settings = {
            tagDistance = 300,
            unfreezeDistance = 400,
            unfreezeTime = 3,
            roundDuration = 180,
        },
    },
    {
        id = "hideSeek",
        name = "Hide & Seek",
        icon = "/esoui/art/icons/ability_rogue_yourewelcome.dds",
        description = "One seeker hunts for hiding players. Last one found wins!",
        minPlayers = 3,
        maxPlayers = 12,
        instructions = {
            "30 seconds to hide while seeker waits",
            "Seeker looks at players to 'find' them",
            "Found players join the seekers",
            "Last unfound player wins!",
        },
        settings = {
            hideTime = 30,
            roundDuration = 300,
        },
    },
    {
        id = "race",
        name = "Checkpoint Race",
        icon = "/esoui/art/icons/ability_buff_major_gallop.dds",
        description = "Race through checkpoints set by the host. First to finish wins!",
        minPlayers = 2,
        maxPlayers = 12,
        instructions = {
            "Host sets checkpoint locations before starting",
            "Race to each checkpoint in order",
            "Reach within 5m of checkpoint to register",
            "First to complete all checkpoints wins!",
        },
        settings = {
            checkpointRadius = 500,
            maxCheckpoints = 10,
        },
    },
    {
        id = "hotPotato",
        name = "Hot Potato",
        icon = "/esoui/art/icons/crafting_provisioner_seasoning_pepper_coldharbour.dds",
        description = "Pass the potato before it explodes! Don't be holding it when time runs out.",
        minPlayers = 3,
        maxPlayers = 12,
        instructions = {
            "One player starts with the 'potato' (marked)",
            "Look at another player and press A to pass",
            "Timer counts down randomly (5-15 sec)",
            "Player holding potato when timer hits 0 is OUT!",
        },
        settings = {
            minTime = 5,
            maxTime = 15,
        },
    },
    {
        id = "simonSays",
        name = "Simon Says",
        icon = "/esoui/art/icons/ability_warrior_yourewelcome.dds",
        description = "Follow the host's commands - but only when they say 'Simon Says'!",
        minPlayers = 2,
        maxPlayers = 12,
        instructions = {
            "Host calls out emote commands",
            "If 'Simon Says...' do the emote!",
            "If NO 'Simon Says', DON'T do it!",
            "Last player standing wins!",
        },
        settings = {
            commandTime = 5,
        },
    },
    {
        id = "trivia",
        name = "ESO Trivia",
        icon = "/esoui/art/icons/ability_companion_rapport_positive.dds",
        description = "Test your ESO knowledge! Answer questions to earn points.",
        minPlayers = 2,
        maxPlayers = 12,
        instructions = {
            "Questions appear on screen",
            "Press A to buzz in",
            "Answer correctly to earn points",
            "Most points after all rounds wins!",
        },
        settings = {
            questionTime = 30,
            totalRounds = 10,
        },
    },
    {
        id = "kingHill",
        name = "King of the Hill",
        icon = "/esoui/art/icons/ability_warrior_yourewelcome.dds",
        description = "Control the designated area to earn points. Most time in the zone wins!",
        minPlayers = 2,
        maxPlayers = 12,
        instructions = {
            "Host marks the 'hill' area",
            "Stand in the zone to earn points",
            "Multiple players split the points",
            "Most points when time expires wins!",
        },
        settings = {
            hillRadius = 1000,
            roundDuration = 180,
        },
    },
    {
        id = "dice",
        name = "Dice Roll",
        icon = "/esoui/art/icons/crafting_jewelry_base_ruby_r1.dds",
        description = "Simple dice rolling for raffles and gold giveaways!",
        minPlayers = 2,
        maxPlayers = 12,
        instructions = {
            "Each player rolls a virtual die",
            "Results shown to everyone",
            "Highest (or lowest) roll wins!",
            "Great for gold giveaways!",
        },
        settings = {
            minRoll = 1,
            maxRoll = 100,
            highestWins = true,
        },
    },
}

-- Message types for network protocol
local MSG_TYPE = {
    GAME_STATE = 1,     -- Game state update
    PLAYER_ACTION = 2,  -- Player did something
    SCORE_UPDATE = 3,   -- Score changed
    GAME_CONFIG = 4,    -- Settings changed
    PLAYER_JOIN = 5,    -- Player joined game
    PLAYER_LEAVE = 6,   -- Player left game
}

-- ============================================
-- HIDDEN LIST SCREEN (for D-pad navigation)
-- ============================================

local ATK_HiddenGuildGamesListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenGuildGamesListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenGuildGamesListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, GUILD_GAMES_SCENE) end
function ATK_HiddenGuildGamesListScreen:PerformUpdate() end

function ATK_HiddenGuildGamesListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        -- A Button: Select/Increase
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Select", keybind = "UI_SHORTCUT_PRIMARY", callback = function() 
            if NWT.GuildGames.settingsOpen then
                NWT.GuildGames_SettingsChangeValue(1)
            else
                NWT.GuildGames_PrimaryAction() 
            end
        end },
        -- Y Button: Settings
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Settings", keybind = "UI_SHORTCUT_SECONDARY", callback = function() 
            if not NWT.GuildGames.settingsOpen then
                NWT.GuildGames_OpenSettings() 
            end
        end },
        -- X Button: Leave/Decrease
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Leave/End", keybind = "UI_SHORTCUT_TERTIARY", callback = function() 
            if NWT.GuildGames.settingsOpen then
                NWT.GuildGames_SettingsChangeValue(-1)
            else
                NWT.GuildGames_TertiaryAction() 
            end
        end },
        -- LB: Prev tab/panel
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "◄", keybind = "UI_SHORTCUT_LEFT_SHOULDER", callback = function() 
            if NWT.GuildGames.settingsOpen then
                NWT.GuildGames_SettingsChangeTab(-1)
            else
                NWT.GuildGames_SwitchPanel("games") 
            end
        end },
        -- RB: Next tab/panel
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "►", keybind = "UI_SHORTCUT_RIGHT_SHOULDER", callback = function() 
            if NWT.GuildGames.settingsOpen then
                NWT.GuildGames_SettingsChangeTab(1)
            else
                NWT.GuildGames_SwitchPanel("center") 
            end
        end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() 
        if NWT.GuildGames.settingsOpen then
            NWT.GuildGames_CloseSettings()
        else
            NWT.CloseGuildGames() 
        end
    end)
end

-- ============================================
-- INITIALIZATION
-- ============================================

function NWT.InitGuildGames()
    if NWT.GuildGames.sceneInitialized then return end
    local ui = ATK_GuildGames_UI
    if not ui then return end
    
    local gg = NWT.GuildGames
    gg.ui = ui
    
    -- Create hidden control for parametric list navigation
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenGuildGamesList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true)
    hc:SetAlpha(0)
    
    -- Create scene
    GUILD_GAMES_SCENE = ZO_Scene:New("guildGamesScene", SCENE_MANAGER)
    GUILD_GAMES_SCENE:AddFragment(ZO_SimpleSceneFragment:New(ui))
    GUILD_GAMES_SCENE:AddFragment(ZO_SimpleSceneFragment:New(hc))
    GUILD_GAMES_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    GUILD_GAMES_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    
    -- Initialize hidden list screen (handles keybinds and D-pad)
    NWT.HiddenGuildGamesListScreen = ATK_HiddenGuildGamesListScreen:New(hc)
    NWT.HiddenGuildGamesList = NWT.HiddenGuildGamesListScreen:GetMainList()
    NWT.HiddenGuildGamesList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d)
        local l = c:GetNamedChild("Label")
        if l then l:SetText(d.name or "") end
    end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    -- Handle selection changes from D-pad navigation
    NWT.HiddenGuildGamesList:SetOnSelectedDataChangedCallback(function(list, selectedData)
        if gg.skipCallback then return end
        
        -- If settings dialog is open, intercept D-pad and navigate settings instead
        if gg.settingsOpen then
            -- Calculate direction from index change
            if selectedData and selectedData.index then
                local direction = selectedData.index > gg.selectedGameIndex and 1 or -1
                -- Reset hidden list to current game (don't actually change it)
                gg.skipCallback = true
                pcall(function() list:SetSelectedIndexWithoutAnimation(gg.selectedGameIndex) end)
                gg.skipCallback = false
                -- Navigate settings rows instead
                NWT.GuildGames_SettingsNavigate(direction)
            end
            return
        end
        
        if selectedData and selectedData.index then
            gg.selectedGameIndex = selectedData.index
            NWT.UpdateGuildGamesUI()
        end
    end)
    
    -- Scene state changes
    GUILD_GAMES_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_HIDDEN then
            gg.isOpen = false
            NWT.GuildGames_OnHide()
        end
    end)
    
    -- Register for network events
    EVENT_MANAGER:RegisterForEvent("ATK_GuildGames", EVENT_GROUP_ADD_ON_DATA_RECEIVED, NWT.GuildGames_OnDataReceived)
    
    gg.sceneInitialized = true
end

-- Sync the hidden list with game data
function NWT.SyncHiddenGuildGamesList()
    if not NWT.HiddenGuildGamesList then return end
    local gg = NWT.GuildGames
    
    NWT.HiddenGuildGamesList:Clear()
    for i, game in ipairs(gg.GAMES) do
        local entryData = ZO_GamepadEntryData:New(game.name)
        entryData.index = i
        entryData.game = game
        NWT.HiddenGuildGamesList:AddEntry("ZO_GamepadItemEntryTemplate", entryData)
    end
    NWT.HiddenGuildGamesList:Commit()
    
    -- Set selection
    if gg.selectedGameIndex and gg.selectedGameIndex <= #gg.GAMES then
        local success, err = pcall(function()
            NWT.HiddenGuildGamesList:SetSelectedIndexWithoutAnimation(gg.selectedGameIndex)
        end)
    end
end

function NWT.GuildGames_OnShow()
    -- Register auth key for broadcasting
    if not NWT.GuildGames.authKey then
        NWT.GuildGames.authKey = RegisterForGroupAddOnDataBroadcastAuthKey("AdventurersToolkit")
    end
    
    -- Check if we're the group leader (host)
    NWT.GuildGames.isHost = IsUnitGroupLeader("player") or not IsUnitGrouped("player")
    NWT.GuildGames.isOpen = true
    
    -- Sync hidden list for navigation
    NWT.SyncHiddenGuildGamesList()
    
    -- Refresh player list
    NWT.GuildGames_RefreshPlayers()
    
    -- Update UI
    NWT.UpdateGuildGamesUI()
    
    -- Start update loop for active games
    if NWT.GuildGames.gameState == "playing" then
        NWT.GuildGames_StartUpdateLoop()
    end
end

function NWT.GuildGames_OnHide()
    -- Stop update loop
    NWT.GuildGames_StopUpdateLoop()
end

-- ============================================
-- NETWORK COMMUNICATION
-- ============================================

function NWT.GuildGames_Broadcast(msgType, data1, data2, data3, data4, data5, data6, data7)
    if not NWT.GuildGames.authKey then return false end
    
    local now = GetGameTimeMilliseconds()
    local cooldown = GetGroupAddOnDataBroadcastCooldownRemainingMS()
    if cooldown > 0 then
        -- Queue for later
        zo_callLater(function()
            NWT.GuildGames_Broadcast(msgType, data1, data2, data3, data4, data5, data6, data7)
        end, cooldown + 50)
        return false
    end
    
    local result = BroadcastAddOnDataToGroup(
        NWT.GuildGames.authKey,
        msgType or 0,
        data1 or 0,
        data2 or 0,
        data3 or 0,
        data4 or 0,
        data5 or 0,
        data6 or 0,
        data7 or 0
    )
    
    NWT.GuildGames.lastBroadcast = now
    return result == GROUP_ADD_ON_DATA_BROADCAST_RESULT_SUCCESS
end

function NWT.GuildGames_OnDataReceived(eventCode, senderUnitTag, data1, data2, data3, data4, data5, data6, data7, data8)
    local msgType = data1
    
    if msgType == MSG_TYPE.GAME_STATE then
        NWT.GuildGames_HandleGameState(senderUnitTag, data2, data3, data4, data5, data6, data7, data8)
    elseif msgType == MSG_TYPE.PLAYER_ACTION then
        NWT.GuildGames_HandlePlayerAction(senderUnitTag, data2, data3, data4, data5, data6, data7, data8)
    elseif msgType == MSG_TYPE.SCORE_UPDATE then
        NWT.GuildGames_HandleScoreUpdate(senderUnitTag, data2, data3, data4, data5, data6, data7, data8)
    end
    
    -- Update UI if open
    if NWT.GuildGames.isOpen then
        NWT.UpdateGuildGamesUI()
    end
end

function NWT.GuildGames_HandleGameState(senderTag, gameId, state, itPlayer, timeRemaining, d5, d6, d7)
    -- Only accept game state from host
    if not IsUnitGroupLeader(senderTag) then return end
    
    -- Update game state
    for i, game in ipairs(NWT.GuildGames.GAMES) do
        if i == gameId then
            NWT.GuildGames.currentGame = game
            NWT.GuildGames.selectedGameIndex = i
            break
        end
    end
    
    if state == 0 then
        NWT.GuildGames.gameState = "lobby"
    elseif state == 1 then
        NWT.GuildGames.gameState = "playing"
        NWT.GuildGames_StartUpdateLoop()
    elseif state == 2 then
        NWT.GuildGames.gameState = "results"
        NWT.GuildGames_StopUpdateLoop()
    end
    
    -- Game-specific state
    NWT.GuildGames.tagState.itPlayerIndex = itPlayer
    NWT.GuildGames.tagState.roundTimeRemaining = timeRemaining
end

function NWT.GuildGames_HandlePlayerAction(senderTag, actionType, targetIndex, d3, d4, d5, d6, d7)
    -- Handle tag action
    if actionType == 1 then -- Tag
        NWT.GuildGames.tagState.itPlayerIndex = targetIndex
        -- Increment tag count for tagged player
        local counts = NWT.GuildGames.tagState.tagCounts
        counts[targetIndex] = (counts[targetIndex] or 0) + 1
        
        -- Play sound
        if NWT.GuildGames.isOpen then
            PlaySound(SOUNDS.DUEL_START)
        end
    end
end

function NWT.GuildGames_HandleScoreUpdate(senderTag, p1, p2, p3, p4, p5, p6, p7)
    -- Unpack scores
    NWT.GuildGames.tagState.tagCounts = {
        [1] = p1 % 256, [2] = math.floor(p1/256) % 256,
        [3] = p2 % 256, [4] = math.floor(p2/256) % 256,
        [5] = p3 % 256, [6] = math.floor(p3/256) % 256,
        [7] = p4 % 256, [8] = math.floor(p4/256) % 256,
        [9] = p5 % 256, [10] = math.floor(p5/256) % 256,
        [11] = p6 % 256, [12] = math.floor(p6/256) % 256,
    }
end

-- ============================================
-- PLAYER MANAGEMENT
-- ============================================

function NWT.GuildGames_RefreshPlayers()
    NWT.GuildGames.players = {}
    
    if IsUnitGrouped("player") then
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if DoesUnitExist(unitTag) then
                local name = GetUnitName(unitTag)
                local displayName = GetUnitDisplayName(unitTag)
                local isInSameInstance = IsGroupMemberInSameInstanceAsPlayer(unitTag)
                
                table.insert(NWT.GuildGames.players, {
                    unitTag = unitTag,
                    index = i,
                    name = name,
                    displayName = displayName,
                    inInstance = isInSameInstance,
                    score = 0,
                    status = "ready",
                })
                
                if IsUnitPlayer(unitTag) then
                    NWT.GuildGames.localPlayerIndex = #NWT.GuildGames.players
                end
            end
        end
    else
        -- Solo player
        table.insert(NWT.GuildGames.players, {
            unitTag = "player",
            index = 1,
            name = GetUnitName("player"),
            displayName = GetUnitDisplayName("player"),
            inInstance = true,
            score = 0,
            status = "ready",
        })
        NWT.GuildGames.localPlayerIndex = 1
    end
end

function NWT.GuildGames_GetPlayerByIndex(index)
    return NWT.GuildGames.players[index]
end

function NWT.GuildGames_GetLocalPlayer()
    return NWT.GuildGames.players[NWT.GuildGames.localPlayerIndex]
end

-- ============================================
-- DISTANCE & POSITION UTILITIES
-- ============================================

function NWT.GuildGames_GetDistance(unitTag1, unitTag2)
    local _, x1, y1, z1 = GetUnitWorldPosition(unitTag1)
    local _, x2, y2, z2 = GetUnitWorldPosition(unitTag2)
    if not x1 or not x2 then return 999999 end
    return math.sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
end

function NWT.GuildGames_GetNearestPlayer(fromUnitTag, excludeSelf)
    local nearestDist = 999999
    local nearestPlayer = nil
    
    for i, player in ipairs(NWT.GuildGames.players) do
        if player.unitTag ~= fromUnitTag or not excludeSelf then
            local dist = NWT.GuildGames_GetDistance(fromUnitTag, player.unitTag)
            if dist < nearestDist then
                nearestDist = dist
                nearestPlayer = player
            end
        end
    end
    
    return nearestPlayer, nearestDist
end

-- ============================================
-- GAME LOGIC: TAG
-- ============================================

function NWT.GuildGames_StartTag()
    if not NWT.GuildGames.isHost then return end
    
    local game = NWT.GuildGames.GAMES[1] -- Tag
    NWT.GuildGames.currentGame = game
    NWT.GuildGames.gameState = "playing"
    
    -- Pick random IT player
    local itIndex = math.random(1, #NWT.GuildGames.players)
    NWT.GuildGames.tagState.itPlayerIndex = itIndex
    NWT.GuildGames.tagState.roundTimeRemaining = game.settings.roundDuration
    NWT.GuildGames.tagState.tagCounts = {}
    
    -- Broadcast game start
    NWT.GuildGames_Broadcast(
        MSG_TYPE.GAME_STATE,
        1,  -- Game ID: Tag
        1,  -- State: Playing
        itIndex,
        game.settings.roundDuration,
        0, 0, 0
    )
    
    -- Start update loop
    NWT.GuildGames_StartUpdateLoop()
    
    PlaySound(SOUNDS.DUEL_START)
    NWT.Debug("|c00FF00[Guild Games]|r Tag started! " .. (NWT.GuildGames.players[itIndex] and NWT.GuildGames.players[itIndex].name or "?") .. " is IT!")
end

function NWT.GuildGames_UpdateTag()
    if NWT.GuildGames.gameState ~= "playing" then return end
    if not NWT.GuildGames.currentGame or NWT.GuildGames.currentGame.id ~= "tag" then return end
    
    local state = NWT.GuildGames.tagState
    local settings = NWT.GuildGames.currentGame.settings
    
    -- Update timer (host only)
    if NWT.GuildGames.isHost then
        state.roundTimeRemaining = state.roundTimeRemaining - 0.5 -- Called every 500ms
        
        if state.roundTimeRemaining <= 0 then
            NWT.GuildGames_EndGame()
            return
        end
    end
    
    -- Check for tags (if we're IT)
    local localPlayer = NWT.GuildGames_GetLocalPlayer()
    if localPlayer and localPlayer.index == state.itPlayerIndex then
        for i, player in ipairs(NWT.GuildGames.players) do
            if i ~= state.itPlayerIndex and player.inInstance then
                local dist = NWT.GuildGames_GetDistance("player", player.unitTag)
                if dist < settings.tagDistance then
                    -- TAG!
                    NWT.GuildGames_TagPlayer(i)
                    break
                end
            end
        end
    end
    
    -- Update UI
    if NWT.GuildGames.isOpen then
        NWT.UpdateGuildGamesUI()
    end
end

function NWT.GuildGames_TagPlayer(targetIndex)
    local state = NWT.GuildGames.tagState
    
    -- Update tag count
    state.tagCounts[targetIndex] = (state.tagCounts[targetIndex] or 0) + 1
    
    -- New IT
    state.itPlayerIndex = targetIndex
    
    -- Broadcast
    NWT.GuildGames_Broadcast(
        MSG_TYPE.PLAYER_ACTION,
        1,  -- Action: Tag
        targetIndex,
        0, 0, 0, 0, 0
    )
    
    PlaySound(SOUNDS.DUEL_START)
    
    local targetPlayer = NWT.GuildGames.players[targetIndex]
    NWT.Debug("|c00FF00[Guild Games]|r " .. (targetPlayer and targetPlayer.name or "?") .. " is now IT!")
end

-- ============================================
-- GAME CONTROL
-- ============================================

function NWT.GuildGames_StartGame()
    if not NWT.GuildGames.isHost then return end
    
    local game = NWT.GuildGames.GAMES[NWT.GuildGames.selectedGameIndex]
    if not game then return end
    
    -- Check minimum players
    if #NWT.GuildGames.players < game.minPlayers then
        NWT.Debug("|cFF0000[Guild Games]|r Need at least " .. game.minPlayers .. " players!")
        return
    end
    
    -- Start appropriate game
    if game.id == "tag" then
        NWT.GuildGames_StartTag()
    elseif game.id == "dice" then
        NWT.GuildGames_StartDice()
    else
        NWT.Debug("|cFFFF00[Guild Games]|r " .. game.name .. " coming soon!")
    end
end

function NWT.GuildGames_EndGame()
    NWT.GuildGames.gameState = "results"
    NWT.GuildGames_StopUpdateLoop()
    
    -- Broadcast end
    if NWT.GuildGames.isHost then
        NWT.GuildGames_Broadcast(
            MSG_TYPE.GAME_STATE,
            NWT.GuildGames.selectedGameIndex,
            2,  -- State: Results
            0, 0, 0, 0, 0
        )
    end
    
    PlaySound(SOUNDS.ACHIEVEMENT_AWARDED)
    NWT.Debug("|c00FF00[Guild Games]|r Game Over!")
    
    if NWT.GuildGames.isOpen then
        NWT.UpdateGuildGamesUI()
    end
end

function NWT.GuildGames_StartUpdateLoop()
    if NWT.GuildGames.updateInterval then return end
    
    NWT.GuildGames.updateInterval = EVENT_MANAGER:RegisterForUpdate(
        "ATK_GuildGames_Update",
        500,
        function()
            local game = NWT.GuildGames.currentGame
            if not game then return end
            
            if game.id == "tag" or game.id == "freezeTag" then
                NWT.GuildGames_UpdateTag()
            end
        end
    )
end

function NWT.GuildGames_StopUpdateLoop()
    if NWT.GuildGames.updateInterval then
        EVENT_MANAGER:UnregisterForUpdate("ATK_GuildGames_Update")
        NWT.GuildGames.updateInterval = nil
    end
end

-- ============================================
-- DICE GAME (Simple)
-- ============================================

function NWT.GuildGames_StartDice()
    if not NWT.GuildGames.isHost then return end
    
    local game = NWT.GuildGames.GAMES[9] -- Dice
    NWT.GuildGames.currentGame = game
    
    -- Each player rolls
    local results = {}
    for i, player in ipairs(NWT.GuildGames.players) do
        local roll = math.random(game.settings.minRoll, game.settings.maxRoll)
        results[i] = roll
        player.score = roll
    end
    
    -- Find winner
    local winnerIndex = 1
    local winnerScore = results[1] or 0
    for i, score in pairs(results) do
        if game.settings.highestWins then
            if score > winnerScore then
                winnerIndex = i
                winnerScore = score
            end
        else
            if score < winnerScore then
                winnerIndex = i
                winnerScore = score
            end
        end
    end
    
    -- Announce results
    for i, player in ipairs(NWT.GuildGames.players) do
        local isWinner = i == winnerIndex and "|c00FF00 WINNER!|r" or ""
        NWT.Debug("|cFFD700[Dice]|r " .. player.name .. " rolled |cFFFFFF" .. (results[i] or 0) .. "|r" .. isWinner)
    end
    
    NWT.GuildGames.gameState = "results"
    PlaySound(SOUNDS.ACHIEVEMENT_AWARDED)
    
    if NWT.GuildGames.isOpen then
        NWT.UpdateGuildGamesUI()
    end
end

-- ============================================
-- UI NAVIGATION
-- ============================================

function NWT.GuildGames_NavigateGames(direction)
    local gg = NWT.GuildGames
    local newIndex = gg.selectedGameIndex + direction
    if newIndex < 1 then newIndex = #gg.GAMES end
    if newIndex > #gg.GAMES then newIndex = 1 end
    
    gg.selectedGameIndex = newIndex
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    
    -- Sync hidden list
    if NWT.HiddenGuildGamesList then
        gg.skipCallback = true
        pcall(function() NWT.HiddenGuildGamesList:SetSelectedIndexWithoutAnimation(newIndex) end)
        gg.skipCallback = false
    end
    
    if gg.isOpen then
        NWT.UpdateGuildGamesUI()
    end
end

function NWT.GuildGames_SwitchPanel(panel)
    local gg = NWT.GuildGames
    if gg.focusPanel == panel then return end
    
    gg.focusPanel = panel
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateGuildGamesUI()
end

function NWT.GuildGames_PrimaryAction()
    local gg = NWT.GuildGames
    local state = gg.gameState
    
    -- If on games panel, just confirm selection and switch to center
    if gg.focusPanel == "games" then
        gg.focusPanel = "center"
        PlaySound(SOUNDS.POSITIVE_CLICK)
        NWT.UpdateGuildGamesUI()
        return
    end
    
    -- Center panel actions
    if state == "idle" then
        -- Create or Join lobby
        if gg.isHost then
            NWT.GuildGames_CreateLobby()
        else
            NWT.GuildGames_JoinLobby()
        end
    elseif state == "lobby" then
        if gg.isHost then
            -- Host starts the game
            NWT.GuildGames_StartGame()
        else
            -- Player toggles ready
            NWT.GuildGames_ToggleReady()
        end
    elseif state == "playing" then
        -- Game-specific action (e.g., pass potato, buzz in)
        NWT.Debug("|cFF00FF[Guild Games]|r Action!")
    elseif state == "results" then
        -- Return to idle
        gg.gameState = "idle"
        gg.joinedPlayers = {}
        NWT.UpdateGuildGamesUI()
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

function NWT.GuildGames_TertiaryAction()
    local gg = NWT.GuildGames
    local state = gg.gameState
    
    if state == "lobby" then
        if gg.isHost then
            -- Host closes lobby
            NWT.GuildGames_CloseLobby()
        else
            -- Player leaves lobby
            NWT.GuildGames_LeaveLobby()
        end
    elseif state == "playing" then
        if gg.isHost then
            -- Host ends game
            NWT.GuildGames_EndGame()
        end
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

-- ============================================
-- LOBBY MANAGEMENT
-- ============================================

function NWT.GuildGames_CreateLobby()
    local gg = NWT.GuildGames
    local game = gg.GAMES[gg.selectedGameIndex]
    if not game then return end
    
    gg.gameState = "lobby"
    gg.currentGame = game
    gg.lobbyHostName = GetUnitDisplayName("player")
    gg.joinedPlayers = {}
    
    -- Add self as first player
    table.insert(gg.joinedPlayers, {
        name = GetUnitName("player"),
        displayName = GetUnitDisplayName("player"),
        ready = true,
        isHost = true,
    })
    
    -- Broadcast lobby creation to group
    NWT.GuildGames_Broadcast(MSG_TYPE.GAME_STATE, gg.selectedGameIndex, 1, 0, 0, 0, 0, 0) -- 1 = lobby state
    
    NWT.Debug("|cFF00FF[Guild Games]|r Created lobby for: " .. game.name)
    NWT.UpdateGuildGamesUI()
end

function NWT.GuildGames_JoinLobby()
    local gg = NWT.GuildGames
    
    -- For now, joining is automatic when lobby exists
    -- In full implementation, would check for broadcast from host
    if gg.gameState == "idle" and gg.lobbyHostName then
        table.insert(gg.joinedPlayers, {
            name = GetUnitName("player"),
            displayName = GetUnitDisplayName("player"),
            ready = false,
            isHost = false,
        })
        gg.gameState = "lobby"
        NWT.Debug("|cFF00FF[Guild Games]|r Joined lobby!")
        NWT.UpdateGuildGamesUI()
    else
        NWT.Debug("|cFFFF00[Guild Games]|r No lobby to join. Wait for host to create one.")
    end
end

function NWT.GuildGames_ToggleReady()
    local gg = NWT.GuildGames
    local myName = GetUnitDisplayName("player")
    
    for _, p in ipairs(gg.joinedPlayers) do
        if p.displayName == myName then
            p.ready = not p.ready
            local status = p.ready and "|c00FF00Ready!|r" or "|cFF0000Not Ready|r"
            NWT.Debug("|cFF00FF[Guild Games]|r " .. status)
            break
        end
    end
    
    NWT.UpdateGuildGamesUI()
end

function NWT.GuildGames_CloseLobby()
    local gg = NWT.GuildGames
    
    gg.gameState = "idle"
    gg.currentGame = nil
    gg.lobbyHostName = nil
    gg.joinedPlayers = {}
    
    -- Broadcast lobby closed
    NWT.GuildGames_Broadcast(MSG_TYPE.GAME_STATE, 0, 0, 0, 0, 0, 0, 0) -- 0 = idle state
    
    NWT.Debug("|cFF00FF[Guild Games]|r Lobby closed.")
    NWT.UpdateGuildGamesUI()
end

function NWT.GuildGames_LeaveLobby()
    local gg = NWT.GuildGames
    
    gg.gameState = "idle"
    
    -- Remove self from joined players (host will see update)
    local myName = GetUnitDisplayName("player")
    for i, p in ipairs(gg.joinedPlayers) do
        if p.displayName == myName then
            table.remove(gg.joinedPlayers, i)
            break
        end
    end
    
    NWT.Debug("|cFF00FF[Guild Games]|r Left lobby.")
    NWT.UpdateGuildGamesUI()
end

-- ============================================
-- SETTINGS DIALOG
-- ============================================

-- Settings definitions per game
local GAME_SETTINGS_DEFS = {
    tag = {
        { key = "tagDistance", label = "Tag Distance", type = "number", min = 100, max = 1000, step = 50, default = 300, suffix = " units (~3m)" },
        { key = "roundDuration", label = "Round Duration", type = "number", min = 60, max = 600, step = 30, default = 180, suffix = " seconds" },
    },
    freezeTag = {
        { key = "tagDistance", label = "Tag Distance", type = "number", min = 100, max = 1000, step = 50, default = 300, suffix = " units" },
        { key = "unfreezeDistance", label = "Unfreeze Distance", type = "number", min = 200, max = 1000, step = 50, default = 400, suffix = " units" },
        { key = "unfreezeTime", label = "Unfreeze Time", type = "number", min = 1, max = 10, step = 1, default = 3, suffix = " seconds" },
        { key = "roundDuration", label = "Round Duration", type = "number", min = 60, max = 600, step = 30, default = 180, suffix = " seconds" },
    },
    hideSeek = {
        { key = "hideTime", label = "Hide Time", type = "number", min = 10, max = 120, step = 10, default = 30, suffix = " seconds" },
        { key = "roundDuration", label = "Round Duration", type = "number", min = 120, max = 900, step = 60, default = 300, suffix = " seconds" },
    },
    race = {
        { key = "checkpointRadius", label = "Checkpoint Radius", type = "number", min = 200, max = 1000, step = 100, default = 500, suffix = " units" },
        { key = "maxCheckpoints", label = "Max Checkpoints", type = "number", min = 3, max = 20, step = 1, default = 10, suffix = "" },
    },
    hotPotato = {
        { key = "minTime", label = "Min Timer", type = "number", min = 2, max = 10, step = 1, default = 5, suffix = " seconds" },
        { key = "maxTime", label = "Max Timer", type = "number", min = 5, max = 30, step = 1, default = 15, suffix = " seconds" },
    },
    dice = {
        { key = "minRoll", label = "Min Roll", type = "number", min = 1, max = 50, step = 1, default = 1, suffix = "" },
        { key = "maxRoll", label = "Max Roll", type = "number", min = 10, max = 1000, step = 10, default = 100, suffix = "" },
        { key = "highestWins", label = "Highest Wins", type = "toggle", default = true },
    },
}

function NWT.GuildGames_OpenSettings()
    local gg = NWT.GuildGames
    local game = gg.GAMES[gg.selectedGameIndex]
    if not game then return end
    
    gg.settingsOpen = true
    gg.settingsRowIndex = 1
    
    -- Initialize settings for this game if not exists
    if not gg.gameSettings[game.id] then
        gg.gameSettings[game.id] = {}
    end
    
    NWT.GuildGames_UpdateSettingsDialog()
    if ATK_GuildGamesSettingsDialog then 
        ATK_GuildGamesSettingsDialog:SetHidden(false) 
    end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.GuildGames_CloseSettings()
    local gg = NWT.GuildGames
    gg.settingsOpen = false
    
    if ATK_GuildGamesSettingsDialog then 
        ATK_GuildGamesSettingsDialog:SetHidden(true) 
    end
    PlaySound(SOUNDS.GAMEPAD_MENU_BACK)
end

function NWT.GuildGames_UpdateSettingsDialog()
    local gg = NWT.GuildGames
    local dialog = ATK_GuildGamesSettingsDialog
    if not dialog then return end
    
    local game = gg.GAMES[gg.selectedGameIndex]
    if not game then return end
    
    -- Update tab bar - show all games with current highlighted
    local tabBar = dialog:GetNamedChild("TabBar")
    if tabBar then
        for i = 1, 9 do
            local tab = tabBar:GetNamedChild("Tab" .. i)
            if tab then
                local g = gg.GAMES[i]
                if g then
                    local isSelected = (i == gg.selectedGameIndex)
                    if isSelected then
                        tab:SetText("|cFFD700" .. g.name .. "|r")
                    else
                        tab:SetText("|c666666" .. g.name .. "|r")
                    end
                else
                    tab:SetText("")
                end
            end
        end
    end
    
    -- Get settings definitions for this game
    local defs = GAME_SETTINGS_DEFS[game.id] or {}
    local content = dialog:GetNamedChild("Content")
    if not content then return end
    
    -- Update selection background position
    local selBG = content:GetNamedChild("SelectionBG")
    if selBG then
        selBG:ClearAnchors()
        selBG:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10 + (gg.settingsRowIndex - 1) * 45)
        selBG:SetHidden(#defs == 0)
    end
    
    -- Populate rows
    for i = 1, 6 do
        local row = content:GetNamedChild("Row" .. i)
        if row then
            local def = defs[i]
            if def then
                local currentValue = gg.gameSettings[game.id] and gg.gameSettings[game.id][def.key]
                if currentValue == nil then
                    currentValue = def.default
                end
                
                local valueText
                if def.type == "toggle" then
                    valueText = currentValue and "|c00FF00ON|r" or "|cFF4444OFF|r"
                else
                    valueText = "|cFFD700" .. tostring(currentValue) .. "|r" .. (def.suffix or "")
                end
                
                local isSelected = (i == gg.settingsRowIndex)
                local labelColor = isSelected and "|cFFFFFF" or "|cAAAAAA"
                row:SetText(labelColor .. def.label .. ":|r  " .. valueText)
            else
                row:SetText("")
            end
        end
    end
    
    -- Show message if no settings for this game
    if #defs == 0 then
        local row1 = content:GetNamedChild("Row1")
        if row1 then
            row1:SetText("|c888888No configurable settings for " .. game.name .. "|r")
        end
    end
end

function NWT.GuildGames_SettingsNavigate(direction)
    local gg = NWT.GuildGames
    local game = gg.GAMES[gg.selectedGameIndex]
    if not game then return end
    
    local defs = GAME_SETTINGS_DEFS[game.id] or {}
    local maxRows = #defs
    if maxRows == 0 then return end
    
    local newIndex = gg.settingsRowIndex + direction
    if newIndex < 1 then newIndex = maxRows end
    if newIndex > maxRows then newIndex = 1 end
    
    gg.settingsRowIndex = newIndex
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.GuildGames_UpdateSettingsDialog()
end

function NWT.GuildGames_SettingsChangeTab(direction)
    local gg = NWT.GuildGames
    local newIndex = gg.selectedGameIndex + direction
    
    if newIndex < 1 then newIndex = #gg.GAMES end
    if newIndex > #gg.GAMES then newIndex = 1 end
    
    gg.selectedGameIndex = newIndex
    gg.settingsRowIndex = 1  -- Reset row selection when switching games
    
    -- Initialize settings for new game if needed
    local game = gg.GAMES[newIndex]
    if game and not gg.gameSettings[game.id] then
        gg.gameSettings[game.id] = {}
    end
    
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.GuildGames_UpdateSettingsDialog()
end

function NWT.GuildGames_SettingsChangeValue(direction)
    local gg = NWT.GuildGames
    local game = gg.GAMES[gg.selectedGameIndex]
    if not game then return end
    
    local defs = GAME_SETTINGS_DEFS[game.id] or {}
    local def = defs[gg.settingsRowIndex]
    if not def then return end
    
    local settings = gg.gameSettings[game.id]
    local currentValue = settings[def.key]
    if currentValue == nil then
        currentValue = def.default
    end
    
    if def.type == "toggle" then
        settings[def.key] = not currentValue
    elseif def.type == "number" then
        local step = (def.step or 1) * (direction or 1)
        local newValue = currentValue + step
        if newValue < def.min then newValue = def.min end
        if newValue > def.max then newValue = def.max end
        settings[def.key] = newValue
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.GuildGames_UpdateSettingsDialog()
end

function NWT.GuildGames_GetSetting(gameId, key)
    local gg = NWT.GuildGames
    local settings = gg.gameSettings[gameId]
    if settings and settings[key] ~= nil then
        return settings[key]
    end
    -- Return default from game definition
    local defs = GAME_SETTINGS_DEFS[gameId] or {}
    for _, def in ipairs(defs) do
        if def.key == key then
            return def.default
        end
    end
    return nil
end

-- ============================================
-- UI UPDATE
-- ============================================

function NWT.UpdateGuildGamesUI()
    local ui = ATK_GuildGames_UI
    if not ui then return end
    
    local gg = NWT.GuildGames
    local game = gg.GAMES[gg.selectedGameIndex]
    if not game then return end
    
    -- Header
    local header = ui:GetNamedChild("Header")
    if header then
        local title = header:GetNamedChild("Title")
        if title then
            title:SetText("|cFF00FFGUILD GAMES|r")
        end
        local subtitle = header:GetNamedChild("Subtitle")
        if subtitle then
            local status = ""
            if gg.gameState == "idle" then
                status = "|c888888Select a Game|r"
            elseif gg.gameState == "lobby" then
                status = "|cFFD700LOBBY|r - " .. #gg.joinedPlayers .. " joined"
            elseif gg.gameState == "playing" then
                status = "|c00FF00PLAYING|r"
            elseif gg.gameState == "results" then
                status = "|cFFD700RESULTS|r"
            end
            local hostText = gg.isHost and " |cFFD700(You are Host)|r" or ""
            subtitle:SetText(status .. hostText)
        end
    end
    
    -- Left Panel: Games List
    local leftCol = ui:GetNamedChild("LeftCol")
    if leftCol then
        -- Show focus glow when this panel is active
        local focusGlow = leftCol:GetNamedChild("FocusGlow")
        if focusGlow then
            focusGlow:SetHidden(gg.focusPanel ~= "games")
        end
        
        local list = leftCol:GetNamedChild("List")
        if list then
            for i = 1, 10 do
                local label = list:GetNamedChild("Game" .. i)
                if label then
                    local g = gg.GAMES[i]
                    if g then
                        local isSelected = i == gg.selectedGameIndex
                        local prefix = isSelected and "|cFF00FF> |r" or "  "
                        local color = isSelected and "|cFFFFFF" or "|c888888"
                        label:SetText(prefix .. color .. g.name .. "|r")
                    else
                        label:SetText("")
                    end
                end
            end
            
            -- Update selection frame - only show when games panel is focused
            local frame = list:GetNamedChild("SelectionFrame")
            if frame then
                frame:ClearAnchors()
                frame:SetAnchor(TOPLEFT, list, TOPLEFT, 0, (gg.selectedGameIndex - 1) * 45)
                frame:SetHidden(gg.focusPanel ~= "games")
            end
        end
    end
    
    -- Center Panel: Game Details
    local centerCol = ui:GetNamedChild("CenterCol")
    if centerCol then
        -- Show focus glow when this panel is active
        local focusGlow = centerCol:GetNamedChild("FocusGlow")
        if focusGlow then
            focusGlow:SetHidden(gg.focusPanel ~= "center")
        end
        
        local gameName = centerCol:GetNamedChild("GameName")
        if gameName then
            gameName:SetText("|cFF00FF" .. game.name .. "|r")
        end
        
        local gameDesc = centerCol:GetNamedChild("GameDesc")
        if gameDesc then
            gameDesc:SetText(game.description)
        end
        
        local playerInfo = centerCol:GetNamedChild("PlayerInfo")
        if playerInfo then
            playerInfo:SetText("|c888888Players:|r " .. #NWT.GuildGames.players .. "/" .. game.maxPlayers .. 
                              "  |c888888Min:|r " .. game.minPlayers)
        end
        
        -- Player list - show joined players in lobby, or game players when playing
        local playersCard = centerCol:GetNamedChild("PlayersCard")
        if playersCard then
            local playerList = playersCard:GetNamedChild("PlayerList")
            if playerList then
                for i = 1, 12 do
                    local row = playerList:GetNamedChild("Player" .. i)
                    if row then
                        if gg.gameState == "lobby" or gg.gameState == "idle" then
                            -- Show joined players in lobby
                            local p = gg.joinedPlayers[i]
                            if p then
                                local readyText = p.ready and " |c00FF00[Ready]|r" or " |cFF4444[Not Ready]|r"
                                local hostText = p.isHost and " |cFFD700(Host)|r" or ""
                                row:SetText("|cFFFFFF" .. p.name .. "|r" .. hostText .. readyText)
                            else
                                row:SetText("")
                            end
                        else
                            -- Show game players when playing
                            local player = gg.players[i]
                            if player then
                                local isIT = gg.tagState.itPlayerIndex == i
                                local itText = isIT and " |cFF0000[IT]|r" or ""
                                local score = gg.tagState.tagCounts[i] or 0
                                local scoreText = gg.gameState == "playing" and " |c888888(" .. score .. " tags)|r" or ""
                                row:SetText("|cFFFFFF" .. player.name .. "|r" .. itText .. scoreText)
                            else
                                row:SetText("")
                            end
                        end
                    end
                end
            end
        end
        
        -- Game status message
        local gameStatus = centerCol:GetNamedChild("GameStatus")
        if gameStatus then
            -- Show different message based on focus
            if gg.focusPanel == "games" then
                gameStatus:SetText("|c888888[LB] Games  |cFFFFFF[RB] Details|r  •  Use D-pad to browse, [A] to select")
            elseif gg.gameState == "idle" then
                if gg.isHost then
                    gameStatus:SetText("|c00FF00[A] Create Lobby|r  |c888888[LB] Back to Games|r")
                else
                    gameStatus:SetText("|c888888[A] Join if lobby exists  [LB] Back to Games|r")
                end
            elseif gg.gameState == "lobby" then
                if gg.isHost then
                    gameStatus:SetText("|c00FF00[A] Start Game|r  |cFF4444[X] Close Lobby|r")
                else
                    gameStatus:SetText("|c00FFFF[A] Toggle Ready|r  |cFF4444[X] Leave Lobby|r")
                end
            elseif gg.gameState == "playing" then
                local timeLeft = gg.tagState.roundTimeRemaining or 0
                local mins = math.floor(timeLeft / 60)
                local secs = math.floor(timeLeft % 60)
                gameStatus:SetText("|cFFD700Time: " .. string.format("%d:%02d", mins, secs) .. "|r")
            elseif gg.gameState == "results" then
                gameStatus:SetText("|c00FF00Game Over!|r [A] Return to menu")
            end
        end
    end
    
    -- Right Panel: How to Play
    local rightCol = ui:GetNamedChild("RightCol")
    if rightCol then
        for i = 1, 5 do
            local step = rightCol:GetNamedChild("Step" .. i)
            if step then
                if game.instructions[i] then
                    step:SetText("|cFFFFFF" .. i .. ".|r " .. game.instructions[i])
                else
                    step:SetText("")
                end
            end
        end
    end
end

-- ============================================
-- OPEN / CLOSE
-- ============================================

function NWT.OpenGuildGames()
    if NWT.GuildGames.isOpen then return end
    NWT.InitGuildGames()
    if not GUILD_GAMES_SCENE then return end
    NWT.GuildGames_OnShow()
    SCENE_MANAGER:Push("guildGamesScene")
end

function NWT.CloseGuildGames()
    if GUILD_GAMES_SCENE then
        SCENE_MANAGER:Hide("guildGamesScene")
    end
end

-- Slash command (backup - main access is through Adventurer's Toolkit menu)
SLASH_COMMANDS["/gg"] = function() NWT.OpenGuildGames() end
