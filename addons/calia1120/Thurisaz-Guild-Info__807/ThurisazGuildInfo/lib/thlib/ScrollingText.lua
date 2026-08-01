--[[
  [ Copyright (c) 2014 User Froali from ESOUI.com
  [ All Rights Reserved. If you want to use arts of my AddOns for your own work, please contact me first!
  ]]

--Scrolling Text Functions
TI.SCT = {}
TI.SCT.maxMessages = 5
TI.SCT.lifeTime = 7.5
TI.SCT.activeMessages = 0
local pool
local parentFrame
local lastControl
local usedLines = {}
local queuedMessages = {}

--[[
--Count unfinished (active) Lines
 ]]
local function CountUsedLines()
    local count = 0
    for key,value in pairs(usedLines) do
        if(not value.finished) then
            count = count + 1
        end
    end
    return count
end

--[[
-- Pull next Message from Queue
 ]]
local function getNextMessage()
    if(#queuedMessages < 1) then return false end
    return table.remove(queuedMessages, 1)
end

--[[
-- Update Message Display and display next message if limit is not reached
 ]]


--[[
--Create new line/control in ZO_ObjectPool
 ]]
local function NewLine(pool)
	local control = ZO_ObjectPool_CreateControl("TGI_SCT_Line", pool, parentFrame)
	control:SetHidden(true)
	control:SetAlpha(0)
	return control
end

--[[
--RemoveLine/Control from used List in ZO_ObjectPool
 ]]
local function  RemoveLine(control)

    control:SetHidden(true)
    control:SetAlpha(0)
    control:ClearAnchors()
end

--[[
--Release Control by Id of ObjectPool
 ]]
local function FreeControlById(controlid)
    if(not controlid) then return end
    pool:ReleaseObject(controlid)
end

--[[
--tries to Clean Up the used Controls by Scrolling Text
 ]]
local function tryCleanUpLines()
    --test if there are unfinished lines in table. if so return and do not clean up
    for key,value in pairs(usedLines) do
        if(not value.finished) then
            return false
        end
    end
    --there are no unfinished lines. so start cleaning up
    for key,value in pairs(usedLines) do
       FreeControlById(value.controlId)
       usedLines[key] = nil
    end
    lastControl = parentFrame
end



--[[
-- Add a Line to the Scrolling Announcement Text
 ]]
local function CreateAnnouncementLine(text)
    tryCleanUpLines()

    local line, controlId = pool:AcquireObject()
    line:SetAlpha(0)
    line:SetHidden(true)
    local label = line:GetNamedChild("Text")

    label:SetHorizontalAlignment(TI.GetDisplayAlign())
    TI.SCT.activeMessages =  TI.SCT.activeMessages + 1

    line:ClearAnchors()
    local parent = nil
    if(lastControl == nil or lastControl == line) then
        parent = parentFrame
    else
        parent = lastControl
    end


    line:SetWidth(TI.GetDisplayWidth())


    label:SetWidth(TI.GetDisplayWidth())
    label:SetText(text)
    label:SetFont(TI.GetDisplayFont())

    local fontHeight = label:GetFontHeight()
    local labelHeight = label:GetTextHeight()
    line:SetHeight(labelHeight)
    label:SetHeight(labelHeight)
    if(parent == parentFrame) then
	    line:SetAnchor( BOTTOM, parent, nil, 0, 0)
    else
        line:SetAnchor( TOP, parent, nil, 0, -labelHeight)
    end

    lastControl = line
    usedLines[line:GetName()] = {}
    usedLines[line:GetName()].finished = false
    usedLines[line:GetName()].controlId = controlId



    TI.SCT.ScrollAnimation(line, TI.SCT.lifeTime * 1000, controlId)
end

---Pulls next message from messageQueue and displays this line
local function UpdateMessages()
    if(CountUsedLines() >= TI.SCT.maxMessages) then return end
    local message = getNextMessage()
    if(not message) then return end
    CreateAnnouncementLine(message)
end


---Add a Line to the Scrolling Text Queue
function TI.SCT:AddLine(text)
    table.insert(queuedMessages, text)
    UpdateMessages()
end


---Initialize the Scrolling Text Module
function TI.SCT:Initialize(parentControl)
	TI.SCT.control = parentControl
    parentFrame = parentControl

    pool = ZO_ObjectPool:New( NewLine,  RemoveLine)
end

function TI.SCT:IsInitialized()
	return TI.SCT.control ~= nil
end

function TI.SCT:SetTime(secs)
	if(isnumeric(secs)) then
		TI.SCT.lifeTime = secs
	end
end


---Applies Scroll Animation to a control. Animation is defined as fadeout und translate downwards in the last 1.2 seconds of lifetime
function TI.SCT.ScrollAnimation(control, duration, controlId)
    local fadeinTime = 1000
    local fadeoutTime = 1200
    local timeline = ANIMATION_MANAGER:CreateTimeline()

    local fadeIn = timeline:InsertAnimation(ANIMATION_ALPHA, control)
    fadeIn:SetAlphaValues(0,1)
    fadeIn:SetDuration(fadeinTime or 500)

    local fadeOut = timeline:InsertAnimation(ANIMATION_ALPHA, control, duration - fadeoutTime)
    fadeOut:SetAlphaValues(1, 0)
    fadeOut:SetDuration(fadeoutTime)

    local translateOut = timeline:InsertAnimation(ANIMATION_TRANSLATE, control,duration - fadeoutTime)
    translateOut:SetTranslateDeltas(0, control:GetHeight())
    translateOut:SetDuration(fadeoutTime or 1200)

    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    timeline:SetHandler('OnStop', function()
        TI.SCT.activeMessages =  TI.SCT.activeMessages - 1
        usedLines[control:GetName()].finished = true
        control:ClearAnchors()
        control:SetHidden(true)
        UpdateMessages()
    end)
    timeline:PlayFromStart()
	control:SetHidden(false)
end