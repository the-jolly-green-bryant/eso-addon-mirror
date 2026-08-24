local U = Ultivite
U.Sound = U.Sound or {}
local SS = U.Sound

SS.name = "UltiviteSound"
SS.version = "1.0.41 / Ultivite 1.0.200"
SS.savedVersion = 1
SS.captureUpdateName = "SoundSuppressorCaptureTimer"
SS.auditionUpdateName = "SoundSuppressorPlayAllTimer"
SS.recentLimit = 60
SS.captureUniqueLimit = 40
SS.captureSerial = 0
SS.captureActive = false
SS.captureList = {}
SS.captureByName = {}
SS.recent = {}
SS.soundAliases = {}
SS.hookInstalled = false
SS.hookMode = "none"
SS.originalPlaySound = nil
SS.wrapper = nil
SS.playAllActive = false
SS.playAllIndex = 0

local defaults = {
    enabled = true,
    liveLogging = false,
    captureSeconds = 8,
    playAllDelaySeconds = 2,
    blocked = {},
}

SS.defaults = defaults

local function chat(message)
    d(string.format("|c7FD4FF[Ultivite: Sound]|r %s", tostring(message)))
end

function SS.RequestSettingsSave()
    if Ultivite and U.RequestSettingsSave then
        U.RequestSettingsSave(true)
    elseif RequestAddOnSavedVariablesPrioritySave then
        RequestAddOnSavedVariablesPrioritySave("Ultivite")
    end
end

local function trim(value)
    if value == nil then return "" end
    local text = tostring(value)
    return text:match("^%s*(.-)%s*$") or ""
end

local function splitFirst(text)
    text = trim(text)
    if text == "" then return "", "" end
    local command, rest = text:match("^(%S+)%s*(.-)$")
    return zo_strlower(command or ""), trim(rest or "")
end

local function boolWord(value)
    return value and "ON" or "OFF"
end

function SS.BuildSoundAliasIndex()
    SS.soundAliases = {}
    if type(SOUNDS) ~= "table" then return end

    for key, value in pairs(SOUNDS) do
        if type(key) == "string" and type(value) == "string" and value ~= "" then
            local bucket = SS.soundAliases[value]
            if not bucket then
                bucket = {}
                SS.soundAliases[value] = bucket
            end
            bucket[#bucket + 1] = key
        end
    end

    for _, bucket in pairs(SS.soundAliases) do
        table.sort(bucket)
    end
end

function SS.GetAliasText(soundName)
    local bucket = SS.soundAliases and SS.soundAliases[soundName]
    if not bucket or #bucket == 0 then return "" end
    if #bucket == 1 then return "SOUNDS." .. bucket[1] end

    local visible = {}
    local maxVisible = math.min(#bucket, 3)
    for i = 1, maxVisible do
        visible[#visible + 1] = "SOUNDS." .. bucket[i]
    end
    if #bucket > maxVisible then
        visible[#visible + 1] = string.format("+%d aliases", #bucket - maxVisible)
    end
    return table.concat(visible, ", ")
end

function SS.DescribeSound(soundName)
    local raw = tostring(soundName or "")
    local aliases = SS.GetAliasText(raw)
    if aliases ~= "" then
        return string.format("%s | raw=%s", aliases, raw)
    end
    return string.format("raw=%s", raw)
end

function SS.IsBlocked(soundName)
    if not SS.sv or SS.sv.enabled ~= true then return false end
    if type(SS.sv.blocked) ~= "table" then return false end
    return SS.sv.blocked[tostring(soundName or "")] == true
end

function SS.RecordRecent(soundName, blocked)
    local record = {
        time = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0,
        name = tostring(soundName or ""),
        blocked = blocked and true or false,
    }
    SS.recent[#SS.recent + 1] = record
    while #SS.recent > SS.recentLimit do
        table.remove(SS.recent, 1)
    end
end

function SS.RecordCapture(soundName, blocked)
    if not SS.captureActive then return end
    local raw = tostring(soundName or "")
    if raw == "" then return end

    local entry = SS.captureByName[raw]
    if entry then
        entry.count = entry.count + 1
        entry.lastTime = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
        if blocked then entry.blocked = true end
        return
    end

    if #SS.captureList >= SS.captureUniqueLimit then return end

    entry = {
        name = raw,
        count = 1,
        blocked = blocked and true or false,
        firstTime = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0,
        lastTime = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0,
    }
    SS.captureByName[raw] = entry
    SS.captureList[#SS.captureList + 1] = entry
end

function SS.InterceptPlaySound(soundName)
    local raw = tostring(soundName or "")
    local blocked = SS.IsBlocked(raw)

    SS.RecordRecent(raw, blocked)
    SS.RecordCapture(raw, blocked)

    if SS.sv and SS.sv.liveLogging == true then
        chat(string.format("%s %s", blocked and "BLOCKED" or "PLAY", SS.DescribeSound(raw)))
    end

    return blocked
end

function SS.InstallHook()
    if SS.hookInstalled then return true end

    if type(PlaySound) ~= "function" then
        chat("PlaySound is unavailable. Suppression hook was not installed.")
        return false
    end

    SS.originalPlaySound = PlaySound

    if type(ZO_PreHook) == "function" then
        local ok, result = pcall(function()
            return ZO_PreHook("PlaySound", function(soundName)
                return SS.InterceptPlaySound(soundName)
            end)
        end)
        if ok and result ~= false then
            SS.hookInstalled = true
            SS.hookMode = "ZO_PreHook"
            return true
        end
    end

    SS.wrapper = function(soundName)
        if SS.InterceptPlaySound(soundName) then return end
        return SS.originalPlaySound(soundName)
    end

    local ok = pcall(function()
        _G.PlaySound = SS.wrapper
    end)
    if ok and _G.PlaySound == SS.wrapper then
        SS.hookInstalled = true
        SS.hookMode = "wrapper"
        return true
    end

    chat("PlaySound could not be intercepted on this client.")
    return false
end

function SS.StartCapture(seconds)
    SS.StopPlayAll(true)
    seconds = tonumber(seconds) or tonumber(SS.sv and SS.sv.captureSeconds) or defaults.captureSeconds
    seconds = math.max(2, math.min(30, math.floor(seconds + 0.5)))

    SS.captureSerial = SS.captureSerial + 1
    SS.captureActive = true
    SS.captureList = {}
    SS.captureByName = {}
    SS.captureEndMs = (GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0) + (seconds * 1000)

    EVENT_MANAGER:UnregisterForUpdate(SS.captureUpdateName)
    EVENT_MANAGER:RegisterForUpdate(SS.captureUpdateName, 100, function()
        local now = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
        if SS.captureActive and now >= (SS.captureEndMs or 0) then
            SS.StopCapture(true)
        end
    end)

    chat(string.format("Capture started for %d seconds. Trigger the unwanted sound now.", seconds))
end

function SS.StopCapture(printResults)
    EVENT_MANAGER:UnregisterForUpdate(SS.captureUpdateName)
    local wasActive = SS.captureActive
    SS.captureActive = false
    if wasActive then
        chat(string.format("Capture stopped. %d unique PlaySound calls recorded.", #SS.captureList))
    end
    if printResults then SS.PrintCapture() end
end

function SS.PrintCapture()
    if #SS.captureList == 0 then
        chat("Capture is empty. If the unwanted sound definitely played, it may be engine-side 3D audio rather than a Lua PlaySound call.")
        return
    end

    chat(string.format("Capture results: %d unique sounds. Use /ss play NUMBER to audition and /ss block NUMBER to suppress.", #SS.captureList))
    for index, entry in ipairs(SS.captureList) do
        chat(string.format("[%d] x%d %s%s", index, entry.count or 1, entry.blocked and "BLOCKED " or "", SS.DescribeSound(entry.name)))
    end
end

function SS.PrintRecent()
    if #SS.recent == 0 then
        chat("No intercepted PlaySound calls recorded yet.")
        return
    end

    local first = math.max(1, #SS.recent - 19)
    chat(string.format("Most recent %d PlaySound calls:", #SS.recent - first + 1))
    local displayIndex = 1
    for i = first, #SS.recent do
        local entry = SS.recent[i]
        chat(string.format("[%d] %s%s", displayIndex, entry.blocked and "BLOCKED " or "", SS.DescribeSound(entry.name)))
        displayIndex = displayIndex + 1
    end
end

function SS.GetCaptureEntry(reference)
    local number = tonumber(reference)
    if not number then return nil end
    number = math.floor(number)
    if number < 1 or number > #SS.captureList then return nil end
    return SS.captureList[number]
end

function SS.ResolveSoundReference(reference)
    reference = trim(reference)
    if reference == "" then return nil end

    local entry = SS.GetCaptureEntry(reference)
    if entry then return entry.name end

    return reference
end

function SS.Block(reference)
    local soundName = SS.ResolveSoundReference(reference)
    if not soundName or soundName == "" then
        chat("Usage: /ss block NUMBER from the current capture, or /ss block EXACT_SOUND_NAME")
        return
    end

    SS.sv.blocked = SS.sv.blocked or {}
    SS.sv.blocked[soundName] = true
    SS.RequestSettingsSave()
    chat("Blocked: " .. SS.DescribeSound(soundName))
end

function SS.Unblock(reference)
    local soundName = SS.ResolveSoundReference(reference)
    if not soundName or soundName == "" then
        chat("Usage: /ss unblock NUMBER or /ss unblock EXACT_SOUND_NAME")
        return
    end

    SS.sv.blocked = SS.sv.blocked or {}
    SS.sv.blocked[soundName] = nil
    SS.RequestSettingsSave()
    chat("Unblocked: " .. SS.DescribeSound(soundName))
end

function SS.BlockLast()
    local entry = SS.recent[#SS.recent]
    if not entry then
        chat("No recent PlaySound call to block.")
        return
    end
    SS.Block(entry.name)
end

function SS.PlayReference(reference)
    local soundName = SS.ResolveSoundReference(reference)
    if not soundName or soundName == "" then
        chat("Usage: /ss play NUMBER from the current capture, or /ss play EXACT_SOUND_NAME")
        return
    end

    if type(SS.originalPlaySound) ~= "function" then
        chat("Original PlaySound function is unavailable.")
        return
    end

    chat("Auditioning: " .. SS.DescribeSound(soundName))
    local ok = pcall(SS.originalPlaySound, soundName)
    if not ok then
        chat("ESO rejected that sound name for playback.")
    end
end

function SS.StopPlayAll(silent)
    EVENT_MANAGER:UnregisterForUpdate(SS.auditionUpdateName)
    local wasActive = SS.playAllActive == true
    SS.playAllActive = false
    SS.playAllIndex = 0
    if wasActive and not silent then
        chat("Play-all audition stopped.")
    end
end

function SS.PlayAllNext()
    if SS.playAllActive ~= true then return end

    SS.playAllIndex = (tonumber(SS.playAllIndex) or 0) + 1
    local index = SS.playAllIndex
    local entry = SS.captureList[index]
    if not entry then
        SS.StopPlayAll(true)
        chat("Play-all audition finished.")
        return
    end

    local total = #SS.captureList
    local blockedText = entry.blocked and " BLOCKED" or ""
    chat(string.format("Playing [%d/%d] capture #%d x%d%s: %s", index, total, index, entry.count or 1, blockedText, SS.DescribeSound(entry.name)))

    local ok = pcall(SS.originalPlaySound, entry.name)
    if not ok then
        chat(string.format("Capture #%d was rejected by ESO for playback.", index))
    end
end

function SS.PlayAllCaptured()
    if #SS.captureList == 0 then
        chat("Capture is empty. Run /ss capture first.")
        return
    end
    if type(SS.originalPlaySound) ~= "function" then
        chat("Original PlaySound function is unavailable.")
        return
    end

    if SS.captureActive then
        SS.StopCapture(false)
    end
    SS.StopPlayAll(true)

    local seconds = tonumber(SS.sv and SS.sv.playAllDelaySeconds) or defaults.playAllDelaySeconds
    seconds = math.max(1, math.min(5, seconds))
    local delayMs = math.floor(seconds * 1000 + 0.5)

    SS.playAllActive = true
    SS.playAllIndex = 0
    chat(string.format("Playing all %d captured sounds with %.1f seconds between each. Watch chat for the number currently playing.", #SS.captureList, seconds))

    SS.PlayAllNext()
    if SS.playAllActive then
        EVENT_MANAGER:RegisterForUpdate(SS.auditionUpdateName, delayMs, function()
            SS.PlayAllNext()
        end)
    end
end

function SS.PrintBlocked()
    SS.sv.blocked = SS.sv.blocked or {}
    local names = {}
    for soundName, blocked in pairs(SS.sv.blocked) do
        if blocked == true then names[#names + 1] = soundName end
    end
    table.sort(names)

    if #names == 0 then
        chat("Blocklist is empty.")
        return
    end

    chat(string.format("Blocked sounds: %d", #names))
    for index, soundName in ipairs(names) do
        chat(string.format("[%d] %s", index, SS.DescribeSound(soundName)))
    end
end

function SS.ClearBlocked()
    SS.sv.blocked = {}
    SS.RequestSettingsSave()
    chat("Blocklist cleared.")
end

function SS.ClearCapture()
    SS.captureList = {}
    SS.captureByName = {}
    SS.recent = {}
    chat("Capture and recent diagnostic history cleared. Blocklist unchanged.")
end

function SS.SetEnabled(value)
    SS.sv.enabled = value and true or false
    SS.RequestSettingsSave()
    chat("Suppression " .. boolWord(SS.sv.enabled) .. ". Diagnostics still capture PlaySound calls.")
end

function SS.SetLiveLogging(value)
    SS.sv.liveLogging = value and true or false
    SS.RequestSettingsSave()
    chat("Live PlaySound logging " .. boolWord(SS.sv.liveLogging) .. ".")
end

function SS.PrintStatus()
    local blockedCount = 0
    for _, blocked in pairs(SS.sv.blocked or {}) do
        if blocked == true then blockedCount = blockedCount + 1 end
    end
    chat(string.format("v%s | hook=%s | suppression=%s | live=%s | capture=%s | blocked=%d", SS.version, SS.hookMode, boolWord(SS.sv.enabled), boolWord(SS.sv.liveLogging), SS.captureActive and "ACTIVE" or "idle", blockedCount))
end

function SS.PrintHelp()
    chat("Commands:")
    chat("/ss capture 8   Start a timed PlaySound capture. Default is 8 seconds.")
    chat("/ss stop        Stop capture and print results.")
    chat("/ss dump        Print the current capture results.")
    chat("/ss play 3      Audition captured sound number 3 using ESO's original PlaySound.")
    chat("/ss playall     Play every captured sound in order and announce each number in chat.")
    chat("/ss stopplay    Stop a running play-all audition.")
    chat("/ss block 3     Suppress captured sound number 3.")
    chat("/ss unblock 3   Remove captured sound number 3 from the blocklist.")
    chat("/ss blocklast   Block the most recent intercepted PlaySound call.")
    chat("/ss blocked     Print the persistent account-wide blocklist.")
    chat("/ss recent      Print the most recent intercepted calls.")
    chat("/ss live on     Print every intercepted PlaySound call to chat. Use only briefly.")
    chat("/ss on | off    Enable or disable suppression without deleting the blocklist.")
    chat("/ss clear       Clear capture/recent diagnostics only.")
    chat("/ss clearblocked Clear every blocked sound.")
    chat("/ss status      Show hook and suppression state.")
end

function SS.HandleSlash(text)
    local command, rest = splitFirst(text)

    if command == "" or command == "help" then
        SS.PrintHelp()
    elseif command == "capture" then
        SS.StartCapture(rest ~= "" and tonumber(rest) or nil)
    elseif command == "stop" then
        SS.StopCapture(true)
    elseif command == "dump" then
        SS.PrintCapture()
    elseif command == "recent" then
        SS.PrintRecent()
    elseif command == "play" then
        SS.PlayReference(rest)
    elseif command == "playall" then
        SS.PlayAllCaptured()
    elseif command == "stopplay" then
        SS.StopPlayAll(false)
    elseif command == "block" then
        SS.Block(rest)
    elseif command == "unblock" then
        SS.Unblock(rest)
    elseif command == "blocklast" then
        SS.BlockLast()
    elseif command == "blocked" then
        SS.PrintBlocked()
    elseif command == "clear" then
        SS.ClearCapture()
    elseif command == "clearblocked" then
        SS.ClearBlocked()
    elseif command == "on" then
        SS.SetEnabled(true)
    elseif command == "off" then
        SS.SetEnabled(false)
    elseif command == "live" then
        local choice = zo_strlower(rest)
        if choice == "on" or choice == "1" or choice == "true" then
            SS.SetLiveLogging(true)
        elseif choice == "off" or choice == "0" or choice == "false" then
            SS.SetLiveLogging(false)
        else
            chat("Usage: /ss live on or /ss live off")
        end
    elseif command == "status" then
        SS.PrintStatus()
    else
        chat("Unknown command. Use /ss help")
    end
end

function SS.GetMenuOptions()
    local options = {
        {
            type = "description",
            text = "Captures Lua PlaySound calls and suppresses only exact sounds you block. Use a capture while triggering the unwanted effect, then audition numbered results before blocking them.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable sound suppression",
            getFunc = function() return SS.sv.enabled == true end,
            setFunc = function(value) SS.SetEnabled(value) end,
            default = defaults.enabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Live diagnostic logging",
            tooltip = "Print every Lua PlaySound call to chat. This can be noisy, so leave it off except while diagnosing.",
            getFunc = function() return SS.sv.liveLogging == true end,
            setFunc = function(value) SS.SetLiveLogging(value) end,
            default = defaults.liveLogging,
            width = "full",
        },
        {
            type = "slider",
            name = "Capture duration",
            min = 2,
            max = 30,
            step = 1,
            getFunc = function() return tonumber(SS.sv.captureSeconds) or defaults.captureSeconds end,
            setFunc = function(value)
                SS.sv.captureSeconds = math.floor(tonumber(value) or defaults.captureSeconds)
                SS.RequestSettingsSave()
            end,
            default = defaults.captureSeconds,
            width = "full",
        },
        {
            type = "slider",
            name = "Play-all delay",
            tooltip = "Seconds between each captured sound when using Play all captured sounds.",
            min = 1,
            max = 5,
            step = 0.5,
            getFunc = function() return tonumber(SS.sv.playAllDelaySeconds) or defaults.playAllDelaySeconds end,
            setFunc = function(value)
                SS.sv.playAllDelaySeconds = tonumber(value) or defaults.playAllDelaySeconds
                SS.RequestSettingsSave()
            end,
            default = defaults.playAllDelaySeconds,
            width = "full",
        },
        {
            type = "button",
            name = "Start sound capture",
            func = function() SS.StartCapture(SS.sv.captureSeconds) end,
            width = "half",
        },
        {
            type = "button",
            name = "Print capture",
            func = function() SS.PrintCapture() end,
            width = "half",
        },
        {
            type = "button",
            name = "Play all captured sounds",
            tooltip = "Plays every captured sound in sequence. Chat announces the exact capture number before each sound.",
            func = function() SS.PlayAllCaptured() end,
            width = "half",
        },
        {
            type = "button",
            name = "Stop play all",
            func = function() SS.StopPlayAll(false) end,
            width = "half",
        },
        {
            type = "button",
            name = "Print blocked sounds",
            func = function() SS.PrintBlocked() end,
            width = "half",
        },
        {
            type = "button",
            name = "Clear diagnostics",
            func = function() SS.ClearCapture() end,
            width = "half",
        },
        {
            type = "description",
            text = "Useful chat commands: /ss capture 8, /ss dump, /ss playall, /ss stopplay, /ss play 1, /ss block 1, /ss blocked, /ss status",
            width = "full",
        },
    }
    return options
end

function SS.BuildMenu()
    return SS.GetMenuOptions()
end

function SS.Initialize(externalSV)
    SS.sv = externalSV or ZO_SavedVars:NewAccountWide("SoundSuppressorSavedVariables", SS.savedVersion, nil, defaults)
    SS.sv.blocked = SS.sv.blocked or {}
    if SS.sv.enabled == nil then SS.sv.enabled = defaults.enabled end
    if SS.sv.liveLogging == nil then SS.sv.liveLogging = defaults.liveLogging end
    if SS.sv.captureSeconds == nil then SS.sv.captureSeconds = defaults.captureSeconds end
    if SS.sv.playAllDelaySeconds == nil then SS.sv.playAllDelaySeconds = defaults.playAllDelaySeconds end

    SS.BuildSoundAliasIndex()
    SS.InstallHook()
    -- Ultivite owns the single consolidated LibAddonMenu panel.

    SLASH_COMMANDS["/ss"] = function(text) SS.HandleSlash(text) end
    SLASH_COMMANDS["/soundsuppressor"] = function(text) SS.HandleSlash(text) end

    chat(string.format("v%s loaded. Hook=%s. Use /ss capture 8 before triggering an unwanted sound.", SS.version, SS.hookMode))
end
