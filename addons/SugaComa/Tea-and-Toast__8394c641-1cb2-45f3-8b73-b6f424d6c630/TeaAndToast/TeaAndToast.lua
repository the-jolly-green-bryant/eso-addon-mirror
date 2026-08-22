--------------------------------------------------------------
-- Tea & Toast — v2.2.3 "Restored Fish-On Cue"
-- Author: SugaComa (Rik Sprint)
--
-- Nan watches for AFK, grows steadily more concerned,
-- and welcomes you back when you return.
-- Adds PvP detection (Cyrodiil/BGs = Drill-Sergeant Nan),
-- and robust fishing detection (no IsUnitFishing).
--
-- Tea & Toast runs fully standalone.
-- A future module (TollBooth.lua) may hook here to relay
-- messages through LibVcapBridge → VCAP, but this version
-- is self-contained and independent.
--------------------------------------------------------------

local ADDON = "TeaAndToast"
TeaAndToast = TeaAndToast or {}
local TT = TeaAndToast
local EM = EVENT_MANAGER
local CHAT_TAG = "[Nan Says]"


--------------------------------------------------------------

--------------------------------------------------------------
-- Saved Vars (defaults)
--------------------------------------------------------------
local SV_DEFAULTS = {
    nanEnabled    = true,
    afkTalk       = true,      -- Nan's AFK comments can be disabled independently
    subtleSounds  = true,
    afkThreshold  = 120,     -- seconds idle → AFK
    pulseInterval = 60,      -- seconds between Nan lines
    checkInterval = 10,      -- seconds between activity checks
    debug         = false,
    fishingBanter = true,      -- Nan comments while fishing
    fishingReactionDelay = 650, -- milliseconds before Nan reacts
    crabSlaughterCraneSeen = false, -- one-time account-wide special reaction
}
TT.SV = TT.SV or nil

--------------------------------------------------------------
-- Helpers
--------------------------------------------------------------
local COL_TEA, COL_NAN, COL_WARN = "C3B091", "92B0D9", "FFCC66"
local COL_GREEN, COL_BLUE, COL_PURPLE = "2DC50E", "3A92FF", "A02EF7"
local function c(hex, txt) return ("|c%s%s|r"):format(hex, txt) end
local function fmtTime(sec) return string.format("%dm %02ds", math.floor(sec/60), sec%60) end

local function Print(msg)
    if not msg then return end
    local text = tostring(msg)
    -- Keep a short, stable source tag in chat so VCAP2 can discover and filter
    -- Tea & Toast narration. VCAP2 may strip the tag from speech, but the chat
    -- line itself remains unchanged and visibly attributed to this addon.
    if text:sub(1, #CHAT_TAG) ~= CHAT_TAG then
        text = CHAT_TAG .. " " .. text
    end
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(text)
    else
        d(text)
    end
end

local function softPing()
    if TT.SV and TT.SV.subtleSounds then PlaySound(SOUNDS.NEW_NOTIFICATION) end
end

local function Debug(msg)
    if TT.SV and TT.SV.debug then Print("DEBUG: " .. tostring(msg)) end
end

local function fmtElapsed(startTime)
    local elapsed = GetFrameTimeSeconds() - (startTime or GetFrameTimeSeconds())
    return fmtTime(math.floor(elapsed))
end

--------------------------------------------------------------
-- LIBRARIES — Nan’s voice lines
--------------------------------------------------------------
TT.Libs = {
    cozy = {
        "Have you gone Fishing, or gone for tea and toast?",
        "Tea and toast is grand when you're fishing—lure in those special blue fish with a bit of crust!",
        "Have you fallen in? Oh love! I do hope you can swim…",
        "Rod still in hand? No. Guess the kettle’s on, two sugars please.",
        "Even the fish are wondering where you’ve gone, dear. I’m starting to agree with them.",
        "Sit a spell, but don’t let the toast burn.",
        "Slaughterfish won’t bite themselves, mind.",
        "Nothing like a brew and a bobber, is there?",
        "Reel’s gone quiet. Everything alright?",
        "If you’re napping by the water, at least pretend you’re baiting the hook. Manners.",
        "Reel in or pour out, dear. Pick one.",
        "The water’s calm… just like you, eh?",
        "Cast a line, sip your tea—perfect balance.",
        "Don’t forget the marmalade, dear.",
        "Fish or toast? Can’t have one without the other.",
        "I’m watching the ripples, dear. Are you still with us?",
        "A quiet line and a warm cup—bliss, innit?",
        "The gulls are circling. Hungry for your crumbs?",
        "Even the reeds are swaying more than you.",
    },
    passive = {
        "I don’t think you’re fishing, dear. But I *do* think your tea’s going cold.",
        "That rod’s not going to cast itself, you know. Neither’s the kettle.",
        "I’ve got biscuits if you’re staying a while.",
        "The console must be lonely without you.",
        "At this rate, I could’ve knitted a scarf.",
        "Your tea’s forming a skin, love. Not a good look.",
        "Even the mudcrabs are judging you.",
        "I’ve seen statues move faster.",
        "The kettle’s boiled twice now. Third time’s the charm?",
        "Silence is golden—unless it’s from you.",
        "I’m counting. One… two… still nothing.",
        "The toast popped ten minutes ago. Cold now.",
        "Your guild chat’s quieter than a tomb.",
        "Even the loading screen gave up on you.",
        "I could’ve baked a cake in the time you’ve been still.",
        "The butter’s melted. Shame none of it is on your toast.",
    },
    war = {
        "Plates in the sink! young one, and get back to the job at hand!",
        "Cyrodiil’s not saving its own keeps by magic.",
        "When was the last time you killed a delve boss? Too long, judging by your silence.",
        "MOVE, or I’ll send the mudcrabs after you!",
        "Your guildmates are carrying you, and I raised you better!",
        "STAND DOWN, SOLDIER. REFRESHMENT BREAK EXTENDED TOO LONG!",
        "This is not a tea-party, this is WAR!",
        "Get your backside in gear or I’ll do it for you!",
        "The Emperor doesn’t wait for toast!",
        "Daedra don’t take tea breaks—neither should you!",
        "I didn’t fight through the Planemeld to watch you stand there doing nothing!",
        "Your armor’s gathering dust faster than your kills!",
        "Next one to idle gets latrine duty in the Imperial City!",
        "The Alliance War won’t win itself, dear!",
    },
    angry = {
        "I checked my watch again. It’s been %s since you moved.",
        "I’ve been glaring at you for %s now. Completely unacceptable.",
        "%s idle? I’ve birthed children faster than that.",
        "I’ve been tapping my foot for %s. I’m still waiting.",
        "%s gone. Even the fish left.",
        "Turned into furniture, have we? %s of stillness.",
    },
    pvp = {
        "Right, war mode! Banner’s up, move it!",
        "You call this readiness? I call it *treason by toast!*",
        "You’d better be plotting a siege, not sipping Earl Grey!",
        "For the Pact, the Covenant, or the Dominion — whichever moves first!",
        "I see no keeps on fire. DISGRACEFUL.",
        "Cyrodiil waits for no one — least of all you!",
    },
    fishingCast = {
        "I still hate fishing.",
        "Do we have to?",
        "Fine. One more cast.",
        "Fish, then. I’ll make tea.",
        "Again? Lovely.",
        "More fishing. Wonderful.",
        "Go on, feed the lake.",
        "I’ll put the kettle on.",
    },
    fishingHook = {
        "Hooked!",
        "Reel it in!",
        "You've got one!",
        "Fish on—reel!",
        "Bite—reel!",
        "Now, love—reel!",
        "Quick—reel!",
        "It’s hooked!",
        "Pull it in!",
        "Got one—reel!",
        "Rod up!",
        "Reel, love!",
        "There’s one—pull!",
        "One’s hooked—reel!",
        "Got a bite—reel!",
        "Reel now!",
        "One’s on—reel!",
        "Pull, dear!",
        "Catch it—reel!",
        "Reel now, love!",
    },
    fishingWhite = {
        "Ten white fish. You’re a bad fisherman, aren’t you?",
        "Ten ordinary fish. Not your finest work.",
        "Ten plain fish. The lake’s showing you up.",
        "Ten whites. Call yourself a fisherman?",
        "That’s ten ordinary ones. Bit rubbish, love.",
        "Ten common fish. Do try harder.",
    },
    fishingGreen = {
        "That'll make a decent tea.",
        "Not bad. Still smells, mind.",
    },
    fishingBlue = {
        "That'll make a decent stew.",
        "Oh! That's a lovely one!",
    },
    fishingCrabSlaughterCrane = {
        "I'd throw that back before it throws you back... and eats me!",
    },
}

--------------------------------------------------------------
-- Random 3-Line Block Picker
--------------------------------------------------------------
local function PickRandomBlock(lib)
    if not lib or #lib == 0 then return {} end
    local count = math.min(3, #lib)
    local indices = {}
    for i = 1, #lib do indices[i] = i end
    for i = #indices, 2, -1 do
        local j = math.random(i)
        indices[i], indices[j] = indices[j], indices[i]
    end
    local out = {}
    for i = 1, count do out[i] = lib[indices[i]] end
    return out
end

--------------------------------------------------------------
-- Nan Personalities
--------------------------------------------------------------
TT.Moods = {
    cozy = {
        lines = {},
        watch = function(e) return "I checked my watch, love. You’ve been still for "..e.."." end,
        returnLine = "Back already? Pass the cup, dear—let’s have a proper brew.",
    },
    passive = {
        lines = {},
        watch = function(e) return "I’m tapping my foot now. Still no movement? It’s been "..e.."." end,
        returnLine = "Oh, you decided to return. How lovely—now warm that tea up.",
    },
    war = {
        lines = {},
        watch = function(e) return "I’ve checked the watch again. That’s "..e.." now!" end,
        returnLine = "Good—you live. Now report for dish duty and a fresh pot!",
    },
    angry = {
        lines = {},
        watch = function(e) return "I am absolutely fuming. "..e.." and counting." end,
        returnLine = "Finally. I thought you’d turned into furniture.",
    },
    pvp = {
        lines = {},
        watch = function(e) return "I’ve been waiting "..e.." and the battle has too. No excuses!" end,
        returnLine = "Finally back, warrior? Now *fight* like you mean it!",
    },
}
local moodOrder = { "cozy", "passive", "war", "angry" }

--------------------------------------------------------------
-- PvP detection
--------------------------------------------------------------
local function TT_IsInPvPZone()
    if IsPlayerInAvAWorld and IsPlayerInAvAWorld() then return true end
    if IsActiveWorldBattleground and IsActiveWorldBattleground() then return true end
    if GetMapContentType then
        local ct = GetMapContentType() or MAP_CONTENT_NONE
        if ct == MAP_CONTENT_AVA or ct == MAP_CONTENT_BATTLEGROUND then return true end
    end
    local zn = (GetZoneName and GetZoneName(GetUnitZoneIndex("player")) or ""):lower()
    return zn:find("cyrodiil") or zn:find("imperial") or zn:find("battleground")
end

--------------------------------------------------------------
-- Fishing detection + Nan fishing banter
--------------------------------------------------------------
TT.isFishing = false
TT.fishingAttemptActive = false
TT.fishingReelSeen = false
TT.fishingResolveToken = 0
TT.lastLureIndex = nil
TT.lastLureStack = nil
TT.fishingLeaveToken = 0
TT.fishingSayGeneration = 0
TT.fishingSayTokens = {}
TT.whiteSilentSinceComment = 0
TT.whiteCommentGap = 5
TT.lastFishingLineIndices = {}

local function QueryInteractInfo()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then
        return nil, nil, nil
    end
    local action, name, _, _, info = GetGameCameraInteractableActionInfo()
    return action, name, info
end

function TT:IsFishingNow()
    if type(GetInteractionType) == "function" and _G.INTERACTION_FISH then
        if GetInteractionType() == INTERACTION_FISH then
            return true
        end
    end
    if INTERACTIVE_WHEEL_MANAGER
        and INTERACTIVE_WHEEL_MANAGER.IsInteracting
        and _G.ZO_INTERACTIVE_WHEEL_TYPE_FISHING then
        if INTERACTIVE_WHEEL_MANAGER:IsInteracting(ZO_INTERACTIVE_WHEEL_TYPE_FISHING) then
            return true
        end
    end
    local action, _, info = QueryInteractInfo()
    if action and action ~= "" and info == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
        return true
    end
    return false
end

local function FishingBanterEnabled()
    return TT.SV and TT.SV.nanEnabled and TT.SV.fishingBanter
end

local function FishingSay(lib, colorHex, value)
    if not FishingBanterEnabled() or not lib or #lib == 0 then return end
    local lineIndex = math.random(#lib)
    local lastIndex = TT.lastFishingLineIndices[lib]
    if #lib > 1 and lineIndex == lastIndex then
        lineIndex = (lineIndex % #lib) + 1
    end
    TT.lastFishingLineIndices[lib] = lineIndex
    local line = lib[lineIndex]
    if value ~= nil then
        if line:find("%s", 1, true) then
            line = string.format(line, tostring(value))
        else
            -- Keep the recovered Nan line unchanged while naming only the
            -- green, blue, and purple catch that prompted it.
            line = tostring(value) .. ". " .. line
        end
    end
    Print(c(colorHex or COL_TEA, line))
    softPing()
end

local function QueueFishingSay(lib, colorHex, value, channel, delayOverride)
    if not FishingBanterEnabled() or not lib or #lib == 0 then return end
    channel = channel or "catch"
    TT.fishingSayTokens[channel] = (TT.fishingSayTokens[channel] or 0) + 1
    local token = TT.fishingSayTokens[channel]
    local generation = TT.fishingSayGeneration
    local delay = math.max(0, tonumber(delayOverride) or tonumber(TT.SV.fishingReactionDelay) or 650)
    zo_callLater(function()
        if generation == TT.fishingSayGeneration
            and token == TT.fishingSayTokens[channel]
            and FishingBanterEnabled() then
            FishingSay(lib, colorHex, value)
        end
    end, delay)
end

local function QueueCatchReveal(lib, colorHex, value)
    QueueFishingSay(lib, colorHex, value, "catch", math.random(1000, 3000))
end

local function BuildItemLink(itemId)
    if type(itemId) ~= "number" or itemId <= 0 then return nil end
    return string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
end

local function GetLootDisplayQuality(itemName, itemId)
    if type(GetItemLinkDisplayQuality) ~= "function" then return nil end
    local itemLink = nil
    if type(itemName) == "string" and itemName:find("|H%d*:item:") then
        itemLink = itemName
    else
        itemLink = BuildItemLink(itemId)
    end
    if not itemLink then return nil end
    local ok, quality = pcall(GetItemLinkDisplayQuality, itemLink)
    return ok and quality or nil
end

local function GetCatchTier(quality)
    if quality == nil then return nil end
    if _G.ITEM_DISPLAY_QUALITY_NORMAL and quality == ITEM_DISPLAY_QUALITY_NORMAL then return "white" end
    if _G.ITEM_DISPLAY_QUALITY_MAGIC and quality == ITEM_DISPLAY_QUALITY_MAGIC then return "green" end
    if _G.ITEM_DISPLAY_QUALITY_ARCANE and quality == ITEM_DISPLAY_QUALITY_ARCANE then return "blue" end
    if _G.ITEM_DISPLAY_QUALITY_ARTIFACT and quality == ITEM_DISPLAY_QUALITY_ARTIFACT then return "purple" end
    return nil
end

local function IsCrabSlaughterCrane(caught)
    if type(caught) ~= "string" then return false end
    return caught:lower():find("crab-slaughter-crane", 1, true) ~= nil
end

function TT:ResetFishingAttempt()
    self.fishingAttemptActive = false
    self.fishingReelSeen = false
    self.fishingResolveToken = (self.fishingResolveToken or 0) + 1
end

function TT:ResolveFishingCatch(itemName, itemId)
    if not self.fishingAttemptActive then return end
    local quality = GetLootDisplayQuality(itemName, itemId)
    local tier = GetCatchTier(quality)
    local caught = itemName
    if not caught or caught == "" then caught = "something" end
    if zo_strformat and _G.SI_TOOLTIP_ITEM_NAME then
        caught = zo_strformat(SI_TOOLTIP_ITEM_NAME, caught)
    end
    self:ResetFishingAttempt()
    Debug(string.format("Fishing catch itemId=%s quality=%s tier=%s", tostring(itemId), tostring(quality), tostring(tier)))

    if tier == "green" then
        QueueCatchReveal(TT.Libs.fishingGreen, COL_GREEN, caught)
    elseif tier == "blue" then
        QueueCatchReveal(TT.Libs.fishingBlue, COL_BLUE, caught)
    elseif tier == "purple" or IsCrabSlaughterCrane(caught) then
        -- Crab-Slaughter-Crane is the game's sole purple fishing catch.
        -- Nan's throw-it-back reaction therefore applies every time.
        QueueCatchReveal(TT.Libs.fishingCrabSlaughterCrane, COL_PURPLE)
    elseif tier == "white" then
        self.whiteSilentSinceComment = (self.whiteSilentSinceComment or 0) + 1
        local requiredGap = self.whiteCommentGap or 5
        if self.whiteSilentSinceComment > requiredGap then
            self.whiteSilentSinceComment = 0
            self.whiteCommentGap = math.random(5, 7)
            QueueCatchReveal(TT.Libs.fishingWhite, COL_TEA)
        end
    end
end

function TT:OnFishingCast()
    -- Starting a fresh cast silently clears any unresolved previous attempt.
    self:ResetFishingAttempt()
    if math.random(5) == 1 then
        QueueFishingSay(TT.Libs.fishingCast, COL_TEA, nil, "cast", 350)
    end
end

function TT:OnFishingHooked()
    if not FishingBanterEnabled() or self.fishingReelSeen then return end
    self.fishingAttemptActive = true
    self.fishingReelSeen = true
    self.fishingResolveToken = (self.fishingResolveToken or 0) + 1

    -- The fish-on warning is the accessibility feature. Speak immediately;
    -- do not delay it behind the later catch reveal.
    FishingSay(TT.Libs.fishingHook, COL_WARN)
end

function TT:TrackFishingLureStack()
    if not FishingBanterEnabled() then return end
    if type(GetFishingLure) ~= "function" or type(GetFishingLureInfo) ~= "function" then return end

    local lureIndex = GetFishingLure()
    if not lureIndex or lureIndex == 0 then
        return
    end

    local _, _, stackCount = GetFishingLureInfo(lureIndex)
    if type(stackCount) ~= "number" then return end

    if self.lastLureIndex == lureIndex and type(self.lastLureStack) == "number" and stackCount < self.lastLureStack then
        -- ESO consumes one bait when a fish is properly on the hook. This was
        -- the dependable detector in the working version and is the primary cue.
        self:OnFishingHooked()
    end

    self.lastLureIndex = lureIndex
    self.lastLureStack = stackCount
end

function TT:RefreshFishingState()
    local _, name = QueryInteractInfo()
    local wasFishing = self.isFishing
    local fishing = self:IsFishingNow()
    if fishing ~= wasFishing then
        self.isFishing = fishing
        Debug(string.format("Fishing=%s (%s)", tostring(fishing), tostring(name)))

        if not fishing then
            -- Do not call a walk-away a failed catch. Give transient reel/camera state
            -- changes time to settle, then silently forget an abandoned attempt.
            self.fishingLeaveToken = (self.fishingLeaveToken or 0) + 1
            local leaveToken = self.fishingLeaveToken
            zo_callLater(function()
                if leaveToken == TT.fishingLeaveToken and not TT:IsFishingNow() then
                    TT:ResetFishingAttempt()
                    TT.lastLureIndex = nil
                    TT.lastLureStack = nil
                end
            end, 5000)
        else
            self.fishingLeaveToken = (self.fishingLeaveToken or 0) + 1
        end
    end

    if fishing then
        self:TrackFishingLureStack()
    end
end

local function StartFishingPoll()
    EM:RegisterForUpdate(ADDON.."_FishPoll", 250, function() TT:RefreshFishingState() end)
end

local function StopFishingPoll()
    EM:UnregisterForUpdate(ADDON.."_FishPoll")
    TT.fishingSayGeneration = (TT.fishingSayGeneration or 0) + 1
    TT.fishingSayTokens = {}
    TT.isFishing = false
    TT.lastLureIndex = nil
    TT.lastLureStack = nil
    TT:ResetFishingAttempt()
end

-- Fishing chatter is a backup for the bait-stack detector. A nibble is not a
-- real hook and must remain silent; BITE and REEL_IN both confirm fish-on.
local function OnChatterBegin(_, optionCount)
    if not FishingBanterEnabled() then return end
    local count = tonumber(optionCount) or 0
    if type(GetChatterOptionCount) == "function" then
        count = math.max(count, tonumber(GetChatterOptionCount()) or 0)
    end
    if type(GetChatterOption) ~= "function" then return end
    for i = 1, count do
        local _, optionType = GetChatterOption(i)
        local isBite = _G.CHATTER_FISH_BITE and optionType == CHATTER_FISH_BITE
        local isReelIn = _G.CHATTER_FISH_REEL_IN and optionType == CHATTER_FISH_REEL_IN
        if isBite or isReelIn then
            TT:OnFishingHooked()
            return
        end
    end
end

local function OnChatterEnd()
    if not FishingBanterEnabled() or not TT.fishingAttemptActive or not TT.fishingReelSeen then return end
    local token = TT.fishingResolveToken
    zo_callLater(function()
        if TT.fishingAttemptActive and TT.fishingReelSeen and TT.fishingResolveToken == token then
            -- No loot arrived, so silently forget the missed fish. Misses do
            -- not need another line after the accessibility cue.
            TT:ResetFishingAttempt()
        end
    end, 2500)
end

local function OnLootReceived(_, _, itemName, _, _, _, isSelf, _, _, itemId)
    if not FishingBanterEnabled() or not isSelf or not TT.fishingAttemptActive then return end
    -- Only accept loot as a fishing result while a fishing attempt is active and
    -- either the reel prompt was seen or the player still appears to be fishing.
    if TT.fishingReelSeen or TT:IsFishingNow() then
        TT:ResolveFishingCatch(itemName, itemId)
    end
end

local function OnFishingLureSet(_, lureIndex)
    if type(GetFishingLureInfo) ~= "function" then return end
    TT:OnFishingCast()
    local _, _, stackCount = GetFishingLureInfo(lureIndex)
    TT.lastLureIndex = lureIndex
    TT.lastLureStack = stackCount
end

local function OnFishingLureCleared()
    TT.lastLureIndex = nil
    TT.lastLureStack = nil
end

EM:RegisterForEvent(ADDON.."_Reticle", EVENT_RETICLE_TARGET_CHANGED, function()
    if TT.SV and TT.SV.nanEnabled then TT:RefreshFishingState() end
end)
EM:RegisterForEvent(ADDON.."_FishChatterBegin", EVENT_CHATTER_BEGIN, OnChatterBegin)
EM:RegisterForEvent(ADDON.."_FishChatterEnd", EVENT_CHATTER_END, OnChatterEnd)
EM:RegisterForEvent(ADDON.."_FishLoot", EVENT_LOOT_RECEIVED, OnLootReceived)
EM:RegisterForEvent(ADDON.."_FishLureSet", EVENT_FISHING_LURE_SET, OnFishingLureSet)
EM:RegisterForEvent(ADDON.."_FishLureClear", EVENT_FISHING_LURE_CLEARED, OnFishingLureCleared)

--------------------------------------------------------------
-- Activity Detection
--------------------------------------------------------------
local function AFKTalkEnabled()
    return TT.SV and TT.SV.nanEnabled and TT.SV.afkTalk
end

local function IsUIActivity()
    if type(IsGameCameraUIModeActive) == "function" and IsGameCameraUIModeActive() then
        return true
    end
    if SCENE_MANAGER then
        if SCENE_MANAGER.IsInUIMode and SCENE_MANAGER:IsInUIMode() then
            return true
        end
        -- A non-base scene covers console/gamepad menus that do not reliably
        -- report camera UI mode during every scene transition.
        if SCENE_MANAGER.IsShowingBaseScene and not SCENE_MANAGER:IsShowingBaseScene() then
            return true
        end
    end
    return false
end

local function IsInteractionActive()
    if type(GetInteractionType) ~= "function" or not _G.INTERACTION_NONE then return false end
    return GetInteractionType() ~= INTERACTION_NONE
end

local function IsPlayerActive()
    local fishing = TT:IsFishingNow()
    TT.isFishing = fishing
    local recentAction = TT.lastExplicitActivity
        and (GetFrameTimeSeconds() - TT.lastExplicitActivity) < 15
    return IsPlayerMoving()
        or IsUnitInCombat("player")
        or fishing
        or IsUIActivity()
        or IsInteractionActive()
        or recentAction
end

function TT:MarkActivity()
    self.lastExplicitActivity = GetFrameTimeSeconds()
    self.lastActive = self.lastExplicitActivity
    if AFKTalkEnabled() and self.state == "afk" and self.ExitAFK then
        self:ExitAFK()
    end
end

local ACTIVITY_EVENTS = {
    CameraUI     = _G.EVENT_GAME_CAMERA_UI_MODE_CHANGED,
    CraftStart   = _G.EVENT_CRAFT_STARTED,
    CraftDone    = _G.EVENT_CRAFT_COMPLETED,
    Inventory    = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    Mail         = _G.EVENT_MAIL_OPEN_MAILBOX,
    Bank         = _G.EVENT_OPEN_BANK,
    GuildBank    = _G.EVENT_OPEN_GUILD_BANK,
    Store        = _G.EVENT_OPEN_STORE,
    TradingHouse = _G.EVENT_OPEN_TRADING_HOUSE,
}
for suffix, eventCode in pairs(ACTIVITY_EVENTS) do
    if eventCode then
        EM:RegisterForEvent(ADDON.."_Activity_"..suffix, eventCode, function() TT:MarkActivity() end)
    end
end

--------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------
function TT:EnterAFK()
    if not AFKTalkEnabled() then return end
    if self.state == "afk" then return end
    self.state = "afk"
    self.afkSince = GetFrameTimeSeconds()
    self.currentMoodIndex, self.currentLineIndex = 1, 1
    self.isPvP = TT_IsInPvPZone()

    if self.isPvP then
        TT.Moods.pvp.lines = PickRandomBlock(TT.Libs.pvp)
        Print(c(COL_WARN, "No tea breaks in warzones. Move it!"))
        softPing()
        return
    end

    TT.Moods.cozy.lines    = PickRandomBlock(TT.Libs.cozy)
    TT.Moods.passive.lines = PickRandomBlock(TT.Libs.passive)
    TT.Moods.war.lines     = PickRandomBlock(TT.Libs.war)
    TT.Moods.angry.lines   = { TT.Libs.angry[math.random(#TT.Libs.angry)] }

    Print(c(COL_TEA, "I noticed you’ve stopped moving. Don’t tell me you’ve wandered off again."))
    softPing()
end

function TT:ExitAFK()
    if self.state ~= "afk" then return end
    if not AFKTalkEnabled() then
        self.state, self.afkSince, self.currentMoodIndex, self.currentLineIndex = "active", nil, 1, 1
        self.isPvP = false
        return
    end
    local moodKey = self.isPvP and "pvp" or moodOrder[self.currentMoodIndex]
    local moodData = TT.Moods[moodKey] or TT.Moods.cozy
    Print(c(COL_NAN, moodData.returnLine))
    self.state, self.afkSince, self.currentMoodIndex, self.currentLineIndex = "active", nil, 1, 1
    self.isPvP = false
    Debug("I’ve reset to cozy mode.")
end

function TT:PulseWhileAFK()
    if not AFKTalkEnabled() then return end
    if not self.afkSince or self.state ~= "afk" then return end
    local elapsed = fmtElapsed(self.afkSince)
    if self.isPvP then
        local mood = TT.Moods.pvp
        local line = mood.lines[self.currentLineIndex] or "MOVE, soldier! The war waits for no one!"
        Print(c(COL_WARN, line)) softPing()
        self.currentLineIndex = self.currentLineIndex + 1
        if self.currentLineIndex > #mood.lines then
            Print(c(COL_NAN, mood.watch(elapsed))) softPing()
            self.currentLineIndex = 1
        end
        return
    end
    local moodKey = moodOrder[self.currentMoodIndex]
    local mood = TT.Moods[moodKey]
    if not mood then return end
    if moodKey == "angry" then
        local line = mood.lines[1] or "I checked my watch again. It’s been %s since you moved."
        Print(c(COL_WARN, string.format(line, elapsed))) softPing()
        return
    end
    local line = mood.lines[self.currentLineIndex]
    if line then Print(c(COL_WARN, line)) softPing() end
    self.currentLineIndex = self.currentLineIndex + 1
    if self.currentLineIndex > #mood.lines then
        Print(c(COL_NAN, mood.watch(elapsed))) softPing()
        self.currentLineIndex = 1
        self.currentMoodIndex = math.min(self.currentMoodIndex + 1, #moodOrder)
    end
end

function TT:CheckActivity()
    if not self.SV.nanEnabled then return end
    if not self.SV.afkTalk then
        self.state, self.afkSince, self.currentMoodIndex, self.currentLineIndex = "active", nil, 1, 1
        self.isPvP = false
        self.lastActive = GetFrameTimeSeconds()
        return
    end
    local active = false
    local ok = pcall(function() active = IsPlayerActive() end)
    if not ok then active = true end
    if active then
        if self.state == "afk" then self:ExitAFK() end
        self.lastActive = GetFrameTimeSeconds()
    else
        local idle = GetFrameTimeSeconds() - (self.lastActive or 0)
        if idle > (self.SV.afkThreshold or 120) then
            if self.state ~= "afk" then self:EnterAFK() end
        end
    end
end

--------------------------------------------------------------
-- Start / Stop
--------------------------------------------------------------
function TT:Start()
    local SV = self.SV
    if not SV.nanEnabled then self:Stop() return end
    self.state, self.lastActive, self.afkSince = "active", GetFrameTimeSeconds(), nil
    self.lastExplicitActivity = self.lastActive
    self.whiteSilentSinceComment = 0
    self.whiteCommentGap = math.random(5, 7)
    self.lastFishingLineIndices = {}
    self.currentMoodIndex, self.currentLineIndex = 1, 1
    zo_callLater(function() Print(c(COL_TEA, "I’m here, love. Tea’s on. Try not to do anything too daft.")) end, 4000)
    EM:RegisterForUpdate(ADDON.."_Activity", (SV.checkInterval or 10)*1000, function() self:CheckActivity() end)
    EM:RegisterForUpdate(ADDON.."_Pulse", (SV.pulseInterval or 60)*1000, function() self:PulseWhileAFK() end)
    StartFishingPoll()
end

function TT:Stop()
    EM:UnregisterForUpdate(ADDON.."_Activity")
    EM:UnregisterForUpdate(ADDON.."_Pulse")
    StopFishingPoll()
    self.state, self.afkSince, self.currentMoodIndex, self.currentLineIndex = "inactive", nil, 1, 1
end

--------------------------------------------------------------
-- Harven Menu (console-safe)
--------------------------------------------------------------
local function TryCreateSettings()
    local LHA = LibHarvensAddonSettings
    if not LHA then return end
    local settings = LHA:AddAddon("Tea & Toast", {
        allowDefaults = true,
        allowRefresh  = true,
        defaultsFunction = function() for k,v in pairs(SV_DEFAULTS) do TT.SV[k] = v end end,
    })
    if not settings then return end

    settings:AddSetting({ type = LHA.ST_SECTION, label = "Nan Mode" })
    settings:AddSetting({
        type = LHA.ST_CHECKBOX, label = "Enable Nan’s Watchful Eye",
        tooltip = "Master switch for Nan’s AFK monitoring and fishing commentary.",
        getFunction = function() return TT.SV.nanEnabled end,
        setFunction = function(v) TT.SV.nanEnabled = v if v then TT:Start() else TT:Stop() end end,
    })

    settings:AddSetting({ type = LHA.ST_SECTION, label = "AFK Commentary" })
    settings:AddSetting({
        type = LHA.ST_CHECKBOX, label = "Enable Nan’s AFK Commentary",
        tooltip = "Turn AFK comments on or off without disabling Nan’s fishing commentary.",
        getFunction = function() return TT.SV.afkTalk end,
        setFunction = function(v)
            TT.SV.afkTalk = v
            TT.lastActive = GetFrameTimeSeconds()
            if not v then
                TT.state, TT.afkSince, TT.currentMoodIndex, TT.currentLineIndex = "active", nil, 1, 1
                TT.isPvP = false
            end
        end,
    })

    settings:AddSetting({ type = LHA.ST_SECTION, label = "Timing Options" })
    settings:AddSetting({
        type = LHA.ST_SLIDER, label = "AFK Threshold (seconds)",
        tooltip = "How long you can be idle before Nan wakes up.",
        min = 60, max = 300, step = 10, unit = "s",
        getFunction = function() return TT.SV.afkThreshold or 120 end,
        setFunction = function(v) TT.SV.afkThreshold = v end,
    })
    settings:AddSetting({
        type = LHA.ST_SLIDER, label = "Reminder Interval (seconds)",
        tooltip = "How often Nan speaks while you’re AFK.",
        min = 30, max = 180, step = 10, unit = "s",
        getFunction = function() return TT.SV.pulseInterval or 60 end,
        setFunction = function(v)
            TT.SV.pulseInterval = v
            EM:UnregisterForUpdate(ADDON.."_Pulse")
            if TT.SV.nanEnabled then
                EM:RegisterForUpdate(ADDON.."_Pulse", v*1000, function() TT:PulseWhileAFK() end)
            end
        end,
    })

    settings:AddSetting({ type = LHA.ST_SECTION, label = "Fishing Banter" })
    settings:AddSetting({
        type = LHA.ST_CHECKBOX, label = "Enable Nan’s Fishing Commentary",
        tooltip = "Nan occasionally complains when you cast, always warns when a fish is truly hooked, then reveals notable catches after a short pause. White-fish disappointment is spaced by at least five to seven quiet whites. Fishing still prevents AFK reminders when this is off.",
        getFunction = function() return TT.SV.fishingBanter end,
        setFunction = function(v)
            TT.SV.fishingBanter = v
            if not v then
                TT.fishingSayGeneration = (TT.fishingSayGeneration or 0) + 1
                TT.fishingSayTokens = {}
                TT:ResetFishingAttempt()
            end
        end,
    })
    settings:AddSetting({ type = LHA.ST_SECTION, label = "Sound Options" })
    settings:AddSetting({
        type = LHA.ST_CHECKBOX, label = "Gentle Sound Alerts",
        tooltip = "Play a soft ping when Nan speaks.",
        getFunction = function() return TT.SV.subtleSounds end,
        setFunction = function(v) TT.SV.subtleSounds = v end,
    })
end

local function SafeCreateSettings()
    if LibHarvensAddonSettings then
        TryCreateSettings()
    else
        EM:RegisterForEvent(ADDON.."_WaitForHarven", EVENT_ADD_ON_LOADED, function(_, n)
            if n == "LibHarvensAddonSettings" then
                TryCreateSettings()
                EM:UnregisterForEvent(ADDON.."_WaitForHarven", EVENT_ADD_ON_LOADED)
            end
        end)
    end
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------
local function OnAddOnLoaded(_, name)
    if name ~= ADDON then return end
    EM:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)
    if GetGameTimeMilliseconds then
        math.randomseed(GetGameTimeMilliseconds() % 2147483647)
    else
        math.randomseed(os.time())
    end
    TT.SV = ZO_SavedVars:NewAccountWide("TeaAndToast_SV", 13, nil, SV_DEFAULTS)
    -- Explicit migration guards for existing v13 SavedVariables.
    if TT.SV.afkTalk == nil then TT.SV.afkTalk = true end
    if TT.SV.fishingReactionDelay == nil then TT.SV.fishingReactionDelay = 650 end
    if TT.SV.crabSlaughterCraneSeen == nil then TT.SV.crabSlaughterCraneSeen = false end
    SafeCreateSettings()
    if TT.SV.nanEnabled then TT:Start() end
    Print(c(COL_TEA, "I’m watching. And yes, I still hate fishing."))
end

EM:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
