WorhelloAchievementExporter = WorhelloAchievementExporter or {}
WorhelloAchievementExporter.name = "WorhelloAchievementExporter"
WorhelloAchievementExporter.version = "3.0.1"
WorhelloAchievementExporter.Achievements = WorhelloAchievementExporter.Achievements or {}

local _control

-- Main function ----------------------
function WorhelloAchievementExporter.getValForAchieve(a) 
    if IsAchievementComplete(a) then
        return "1"
    end
    return "0"
end

function WorhelloAchievementExporter.parseAllRows(data)
    local t = { }
    for _, row in pairs(data) do
        for _1, achieveCode in pairs(row.CODES) do
            if (achieveCode == "NIL") then
                t[#t+1] = "0"
            else
                t[#t+1] = WorhelloAchievementExporter.getValForAchieve(achieveCode)
            end
        end
    end
    return t
end

function WorhelloAchievementExporter.getUrlType(query)
    local t = query.TYPE
    if (t == 'dungeon') then
        return 'dlcDungeons'
    elseif (t == 'baseDungeon') then
        return 'baseDungeons'
    elseif (t == 'trial') then
        return 'trials'
    else
        return 'unknown'
    end
end

function WorhelloAchievementExporter.encodeCodeForUrl(code)
    local newCode = string.gsub(code, "@", "%%40")
    newCode = string.gsub(newCode, ":", "%%3A")
    newCode = string.gsub(newCode, "+", "%%2B")

    return newCode
end

function WorhelloAchievementExporter.showUi(code, url)
    _control = WorhelloAchievementExporterContainer

    local outputBox = _control:GetNamedChild("OutputBox")

    local closeButton = _control:GetNamedChild("CancelButton")
    closeButton:SetHandler("OnClicked", function()
        _control:SetHidden(true)
        outputBox:SetText("")
    end)

    local urlButton = _control:GetNamedChild("OpenUrlButton")
    urlButton:SetHandler("OnClicked", function()
        RequestOpenUnsafeURL(url)
    end)

    outputBox:SetText(code)
    _control:SetHidden(false)
end

WorhelloAchievementExporter.GetSummaryCodeForAchievements = function(query)
    local data = WorhelloAchievementExporter.Achievements.DBFilter(query)
    local results = WorhelloAchievementExporter.parseAllRows(data)

    local fullCodeInBinaryString = table.concat(results, "")
    -- TODO add options to print this in new UI using settings flag -- LibCopyWindow:Show(GetDisplayName() ..":" .. fullCodeInBinaryString)

    local code = GetDisplayName() .. ":" .. WorhelloAchievementExporter.Achievements.GetVersion(query) .. ":" .. base64Encode(results)
    -- Same TODO as above -- LibCopyWindow:Show(code)

    local urlEncodedCode = WorhelloAchievementExporter.encodeCodeForUrl(code)
    local urlType = WorhelloAchievementExporter.getUrlType(query)
    local url = "https://worhello.github.io/esoSharedAchievementsViewer/?type=" .. urlType .. "&mode=update&data=" .. urlEncodedCode

    WorhelloAchievementExporter.showUi(code, url)
end

function base64Encode(dataAsTable)
    local base64Lexicon='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+_'
    local paddingNeeded = 6 - (#dataAsTable % 6)
    if paddingNeeded > 0 and paddingNeeded < 6 then
        for i = 1, paddingNeeded, 1 do
            dataAsTable[#dataAsTable+1] = 0
        end
    end

    local result = { }
    local curr = 0
    local numCharsAdded = 0
    for dataPtr = 1, #dataAsTable, 1 do
        local currPtrRemainder = dataPtr % 6
        if currPtrRemainder == 0 then
            currPtrRemainder = 6
        end
        if dataAsTable[dataPtr] == "1" then
            local currPowerOfTwo = 6 - currPtrRemainder
            curr = curr + math.pow(2, currPowerOfTwo)
        end

        if dataPtr % 6 == 0 then
            result[#result + 1] = string.sub(base64Lexicon, curr + 1, curr + 1)
            curr = 0
        end
    end
    return table.concat(result)
end

-- Initialize -------------------------
function WorhelloAchievementExporter.Initialize()
    SLASH_COMMANDS["/wae_dungeon"] = function(keyword, argument) WorhelloAchievementExporter.GetSummaryCodeForAchievements({TYPE='dungeon'}) end
    SLASH_COMMANDS["/wae_basedungeon"] = function(keyword, argument) WorhelloAchievementExporter.GetSummaryCodeForAchievements({TYPE='baseDungeon'}) end
    SLASH_COMMANDS["/wae_trial"] = function(keyword, argument) WorhelloAchievementExporter.GetSummaryCodeForAchievements({TYPE='trial'}) end
end


-- On Addon Load ----------------------
function WorhelloAchievementExporter.OnAddOnLoaded(event, addonName)
    if addonName == WorhelloAchievementExporter.name then
        WorhelloAchievementExporter.Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(WorhelloAchievementExporter.name, EVENT_ADD_ON_LOADED, WorhelloAchievementExporter.OnAddOnLoaded)
