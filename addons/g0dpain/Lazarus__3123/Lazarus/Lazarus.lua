-- events: https://wiki.esoui.com/Constant_Values#RESURRECT_RESULT_DECLINED
local namespace = "Lazarus"
local filterUnitTagPrefix = "group"
local key_you = "YOU"
local key_others = "OTHERS"
local isDebugging = false

Lazarus = {}

Lazarus.DisplayName = "Lazarus"
Lazarus.Author = "@G0dPain"
Lazarus.Resurrections = {}
Lazarus.Resurrections[key_you] = {}
Lazarus.Resurrections[key_others] = {} 



Lazarus.DefaultVal = {    
    OffsetX = 20,
    OffsetY = 75,
    IsUiHidden = true,
    Resurrections = Lazarus.Resurrections
}
Lazarus.IsInitialized = false


function Lazarus.HideUi()

end

function Lazarus.ToggleWindow()

    if Lazarus.savedVars.IsUiHidden then
        Lazarus.savedVars.IsUiHidden = false
    else        
        Lazarus.savedVars.IsUiHidden = true
    end

    LazarusTLC:SetHidden(Lazarus.savedVars.IsUiHidden)

end

function Lazarus.Reset()

end

-- wird zweimal getriggert, einmal mit player und einmal mit group1
-- evtl. wird unitTag über einen einfachen String abgeglichen
-- wird getriggert, wenn IRGENDETWAS stirbt oder wiederbelebt wird
function DeathStateChanged(eventCode, unitTag, isDead)
        --d("GROUPED")
		
		--local deathInfo = GetDeathInfo()		
		
		if isDead then
			--d("Dieded")
		else
			--d("Revived")
		end    
end

function ResurrectionRequest(eventCode, requesterCharacterName, timeLeftToAccept, requesterDisplayName)
    if requesterCharacterName ~= nil then
        --d("requesterCharacterName: " .. requesterCharacterName)
    else
        --d("requesterCharacterName is null")
    end

    if timeLeftToAccept ~= nil then
        --d("timeLeftToAccept: " .. timeLeftToAccept)
    else
        --d("timeLeftToAccept is null")
    end


    if requesterDisplayName ~= nil then
        --d("requesterDisplayName: " .. requesterDisplayName)
    else
        --d("requesterDisplayName is null")
    end

    Lazarus.increaseResurrections(key_others, requesterDisplayName, -1)
end

-- gets called when resurrection is finished
function ResurrectionRequestRemoved(eventCode)
    --d("Resurrection request has been removed")
end


function SoulGemResurrectionStart(eventCode, durationMs)
    if durationMs ~= nil then
        --d("Duration: " .. durationMs)        
    end
end

-- result = ResurrectResult
-- https://wiki.esoui.com/Globals#ResurrectResult
function ResurrectionResult(eventCode, targetCharacterName, result, targetDisplayName)
	-- targetCharacterName = Charaktername (z.B. GodPain)
	-- targetDisplayName = Anzeigename (z.B. @G0dPain)

	-- ResurrectResult int-Codes
	--RESURRECT_RESULT_ALREADY_CONSIDERING 1?
	--RESURRECT_RESULT_DECLINED 0
	--RESURRECT_RESULT_IN_KILLZONE 2
	--RESURRECT_RESULT_NO_SOUL_GEM 3
	--RESURRECT_RESULT_SOUL_GEM_IN_USE 4
	--RESURRECT_RESULT_SUCCESS 5
	
	if result ~= nil then
		if result == 0 then
		-- Spieler hat abgelehnt
			--d(targetDisplayName.." hat abgelehnt")
		elseif result == 5 then
			--d(targetDisplayName .. " hat Wiederbelebung angenommen")
		else
			--d("ResultCode: "..result)
		end

        Lazarus.increaseResurrections(key_you, targetDisplayName, result)            
	end
end

function Lazarus.increaseResurrections(key, displayName, status)
    --d(Lazarus.savedVars.Resurrections)

    tblTarget = Lazarus.savedVars.Resurrections[key][displayName]

    
            if tblTarget == nil or tblTarget == 0 then
                --d("True")
                Lazarus.savedVars.Resurrections[key][displayName] = 1
                --d("Resurrections".. key .. "->"..displayName..": 1")
            else
               -- d("False")
                Lazarus.savedVars.Resurrections[key][displayName] = Lazarus.savedVars.Resurrections[key][displayName] + 1
                --d("Resurrections".. key .. "->".. Lazarus.savedVars.Resurrections[key][displayName])
            end
    
            local text1, height1, width1, text2, height2, width2 = Lazarus.ResurrectionsToText("")

            Lazarus.DisplayStats(text1, height1, width1, text2, height2, width2)
end

function Lazarus.TryLoadExistingData()
    local  text1, height1, width1, text2, height2, width2 = Lazarus.ResurrectionsToText("")
    Lazarus.DisplayStats(text1, height1, width1, text2, height2, width2)
end

function Lazarus.ResurrectionsToText(seperator)
    local your_resurrections = Lazarus.savedVars.Resurrections[key_you]
    local other_resurrections = Lazarus.savedVars.Resurrections[key_others]

    local you_text  = ""
    local other_text = ""

    local biggestWidth1 = 0
    local biggestWidth2 = 0

    for k,v in pairs(your_resurrections) do
        if string.len(k) >= 12 then
            k = string.sub(k, 0, 14) .. ".."
        end

        local t1 = k .. "\t(" .. v .. ")"
        you_text = you_text .. t1 .. seperator .. "\r\n"

        local length1 = string.len(t1)
        --d(length1)
        if length1 ~= nil and length1 > biggestWidth1 then
            biggestWidth1 = length1
        end
    end

    for k,v in pairs(other_resurrections) do
        if string.len(k) >= 12 then
            k = string.sub(k, 0, 14) .. ".."
        end

        local t2 = k .. "\t(" .. v .. ")"
        other_text = other_text .. t2 .. seperator .. "\r\n"    
        
        local length2 = string.len(t2)

        --d(length2)
        if length2 ~= nil and length2 > biggestWidth2 then
            biggestWidth2 = length2
        end
    end

    return you_text, GetTableLength(your_resurrections), biggestWidth1,  other_text, GetTableLength(other_resurrections), biggestWidth2

end

function GetTableLength(table)
    local count = 0
    for k in pairs(table) do
        count = count + 1
    end
    return count
end

function Lazarus.DisplayStats(text1, height1, width1, text2, height2, width2)
    --d("W1 " .. width1)
    --d("W2 " .. width2)
    LazarusTLCData:SetText(text1)    
    --LazarusTLCData:SetDimensions(width1 *25, height1 * 100)
    LazarusTLCData2:SetText(text2)
    --LazarusTLCData2:SetDimensions(width2*20 + 100, height2 * 25)

    local biggerLength = height1

    if height2 > biggerLength then
       biggerLength = height2
    end
    
    LazarusTLCContainer:SetDimensions((width1 + width2)*30, biggerLength * 30)
end



-- saves the new position of the ui if longclicked
function Lazarus.SaveUiPosition()
    --d("SavedVars.OffsetX " .. Lazarus.savedVars.OffsetX)
    --d("SavedVars.OffsetY " .. Lazarus.savedVars.OffsetY)
    Lazarus.savedVars.OffsetY = LazarusTLC:GetTop()
    Lazarus.savedVars.OffsetX = LazarusTLC:GetLeft()
end

function Lazarus.ResetStats()

end


-- prints your stats to the Chat
function Lazarus.printStats()
    local text1, width1, text2, width2 = Lazarus.ResurrectionsToText(";")
    chat_text = "You revived: "..text1 .. " | Revived from: "..text2
    CHAT_SYSTEM.textEntry:SetText(chat_text)
    CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:Open()
    CHAT_SYSTEM.textEntry:FadeIn()
end

function Lazarus:Initialize()
    EVENT_MANAGER:RegisterForEvent(namespace .. "_DeathState", EVENT_UNIT_DEATH_STATE_CHANGED, DeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(namespace.. "_DeathState", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, filterUnitTagPrefix)

    EVENT_MANAGER:RegisterForEvent(namespace.. "_ResurrectRequest", EVENT_RESURRECT_REQUEST, ResurrectionRequest)
    EVENT_MANAGER:RegisterForEvent(namespace.. "_ResurrectResult", EVENT_RESURRECT_RESULT, ResurrectionResult)
    EVENT_MANAGER:RegisterForEvent(namespace.. "_ResurrectRequestRemoved", EVENT_RESURRECT_REQUEST_REMOVED, ResurrectionRequestRemoved)
    EVENT_MANAGER:RegisterForEvent(namespace.. "_StartSoulGemResurrection", EVENT_START_SOUL_GEM_RESURRECTION, SoulGemResurrectionStart)

    Lazarus.savedVars = ZO_SavedVars:NewAccountWide("Lazarus_SavedVariables", 1, nil, Lazarus.DefaultVal)
    
    Lazarus.savedVars.IsUiHidden = false
    
    Lazarus.TryLoadExistingData()    
    Lazarus.IsInitialized = true
    Lazarus.ToggleWindow()
end

-- handles the params of the slash_command
function Lazarus.HandleCommand(param)
    if param == "deletelog" then
        if Lazarus.savedVars == nil then
            Lazarus.savedVars = ZO_SavedVars:NewAccountWide("Lazarus_SavedVariables", 1, nil, Lazarus.DefaultVal)
        end

        Lazarus.savedVars.Resurrections = Lazarus.Resurrections

        return
    end


    if Lazarus.IsInitialized == false and param ~= "start" then
        d("==========================")
        d("Please initialize with \"/lazarus start\" first!")
        d("==========================")
        return
    end

    if param == "start" then
        Lazarus:Initialize()
    elseif param == "reset" then
        Lazarus.ResetStats()
    elseif param == "print" then
        Lazarus.printStats()
    elseif param == "toggleui" then
        Lazarus.ToggleWindow()
    else
        printCommandParameters()
    end
end

-- prints existing command parameters
function printCommandParameters()
    d("Existing parameters:")
    d("start\tStarts the addon")
    d("print\tPrints your stats")
    d("reset\tResets the stats")
    d("deletelog\tDeletes the log")
    d("toggleui\tToggles the visibility of the ui")
end

SLASH_COMMANDS["/lazarus"] = Lazarus.HandleCommand