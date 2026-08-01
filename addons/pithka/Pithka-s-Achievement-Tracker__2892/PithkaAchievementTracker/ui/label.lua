-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.ui = PITHKA.ui or {}
PITHKA.ui.label = {}

-- convenient namespacing
local api = PITHKA.common.api
local constants = PITHKA.common.constants
local utils = PITHKA.common.utils
local ui = PITHKA.ui
local data = PITHKA.data

-- debug printing
local debugEnabled = false
local function debug(msg)
    if debugEnabled then
        d('|c00FFFF[ui.label]|r ' .. msg )
    end
end

---------------------------------------------------------------------------------------------------------
-- Basic Label
---------------------------------------------------------------------------------------------------------

function ui.label.basic(settings)
    local settings = settings or {}

    -- extract settings and defaults
    local text    = settings.text          or '' 
	local width   = settings.width         or constants.icon.size
	local height  = settings.height        or constants.icon.size
	local font    = settings.font          or constants.font.smallFont
	local color   = settings.color         or constants.color.rgbWhite
	local align   = settings.align         or TEXT_ALIGN_LEFT
	local vAlign  = settings.vAlign        or TEXT_ALIGN_CENTER
    local ttt     = settings.tooltipText   -- no default, existance is used to conditionally add
    local tta     = settings.tooltipAnchor or BOTTOM
    local ttc     = settings.tooltipColor  or constants.color.hexGold
    local ttf     = settings.tooltipFont   or constants.font.defaultFont 
    local clickFn = settings.clickFn       -- no default, existance is used to conditionally add
    local parent  = settings.parent        or PITHKA_GUI
    local hidden  = settings.hidden        or false


    -- create UI control
    local control = api.control.newLabel()
    control:SetDimensions(width, height)
	control:SetColor(unpack(color))
	control:SetHorizontalAlignment(align)
	control:SetVerticalAlignment(vAlign)
	control:SetText(text)
	control:SetFont(font)
    control:SetParent(parent)
    control:SetHidden(hidden)
    -- set tooltip if defined
    if ttt then
        local ttOpenFn  = api.control.tooltipOpenFn(control, ttt, tta, ttc, ttf)
        local ttCloseFn = api.control.tooltipCloseFn(control)
        control:SetMouseEnabled(true)            
        control:SetHandler("OnMouseEnter", ttOpenFn)
        control:SetHandler( "OnMouseExit", ttCloseFn)
    end

    -- set click action if defined
    if clickFn then
        control:SetMouseEnabled(true)            
        control:SetHandler("OnMouseUp", clickFn)
    end

    return control
end

---------------------------------------------------------------------------------------------------------
-- Achievement Label
---------------------------------------------------------------------------------------------------------

function ui.label.achievement(settings)
    local settings = settings or {}
    
    -- Check if AID (Achievement ID) is provided
    if not settings.AID then
        debug("[ui.label.achievement] Warning: No AID provided, falling back to basic label")
        settings.font = settings.font or constants.font.defaultFont
        return ui.label.basic(settings)
    end
    
    -- Check achievement completion status
    local isComplete = api.achievement.IsComplete(settings.AID)
    
    -- Set color based on completion status: green if complete, gray if not (consistent with icon.lua)
    settings.color = isComplete and constants.color.rgbWhite or constants.color.rgbGray
    
    -- Update default styling
    settings.font = settings.font or constants.font.defaultFont
    
    -- Create the basic label with our enhanced settings
    local control = ui.label.basic(settings)
    
    -- Store AID for potential future reference
    control.achievementId = settings.AID
    control.isComplete = isComplete
    
    -- Add an update function to refresh the label when achievement status might change
    local updateFn = function()
        local currentComplete = api.achievement.IsComplete(settings.AID)
        if currentComplete ~= control.isComplete then
            control.isComplete = currentComplete
            local newColor = currentComplete and constants.color.rgbWhite or constants.color.rgbGray
            control:SetColor(unpack(newColor))
            debug(string.format("[ui.label.achievement] Updated AID %d completion status: %s", settings.AID, tostring(currentComplete)))
        end
    end
    
    -- Set up event handler to update when achievements change
    control:SetHandler("OnEffectivelyShown", updateFn)
    
    debug(string.format("[ui.label.achievement] Created achievement label for AID %d, complete: %s", settings.AID, tostring(isComplete)))
    
    return control
end


---------------------------------------------------------------------------------------------------------
-- Teleport Label
---------------------------------------------------------------------------------------------------------

-- helper function to handle port to normal
local function createNormalPortFn(portId, t)
    local portFn = api.travel.portFn(portId, t)

    local fn = function ()
        -- if set to normal, just port
        if not IsUnitUsingVeteranDifficulty("player") then
            portFn()
        else
            -- if set to vet, check if changable, if so change and port
            if CanPlayerChangeGroupDifficulty() then
                SetVeteranDifficulty(false)
                portFn()
            -- if cannot change, error
            else
                d("Teleport Error: Difficulty set to Vet and cannot change")
            end
        end
    end
    return fn
end

-- helper function to handle port to vet
local function createVetPortFn(portId, t)
    local portFn = api.travel.portFn(portId, t)

    local fn = function ()
        -- if set to vet, just port
        if IsUnitUsingVeteranDifficulty("player") then
            portFn()
        else
           -- if set to normal, check if changable, if so change and port
            if CanPlayerChangeGroupDifficulty() then    
                SetVeteranDifficulty(true)
                portFn()
            else
                d("Teleport Error: Difficulty set to Normal and cannot change")
            end 
        end
    end
    return fn
end


function ui.label.teleport(settings)
    local vQueue = settings.vQueue
    local nQueue = settings.nQueue
    local portId = settings.portId
    local t      = settings.text

    -- start from basic label, overriding some styling defaults
    settings.color = settings.color or constants.color.rgbBlue
    settings.font  = settings.font or constants.font.defaultFont
    local control  = ui.label.basic(settings)

    -- update the hover functionality
    control:SetMouseEnabled(true)  
    control:SetHandler("OnMouseEnter", function(control) control:SetColor(unpack(constants.color.rgbWhite)) end )
	control:SetHandler("OnMouseExit",  function(control) control:SetColor(unpack(constants.color.rgbBlue)) end )

    -- create click menu
    control:SetHandler("OnMouseUp", function(control, button)
        -- right click close menu
        if button == 2 then
            ClearMenu()
        
        -- left click create menu
        elseif button == 1 then            
            ClearMenu()
            
            -- add menu item for vet queue
            if vQueue then
                local queueFn = api.travel.queueFn(vQueue, t)
                local menuText = "Queue Vet"
                AddMenuItem(menuText, queueFn)
            end
        
            -- add menu item for normal queue
            if nQueue then
                local queueFn = api.travel.queueFn(nQueue, t)
                local menuText = "Queue Normal"
                AddMenuItem(menuText, queueFn)
            end

            -- add menu item to teleport
            if portId then
                local VetPortFn = createVetPortFn(portId, t)
                local NormalPortFn = createNormalPortFn(portId, t)
                AddMenuItem('Port to Vet', VetPortFn)
                AddMenuItem('Port to Normal', NormalPortFn)
            end

            ShowMenu(control)
        end
    end)
    
    return control
end


---------------------------------------------------------------------------------------------------------
-- Score Label
---------------------------------------------------------------------------------------------------------

-- helper function to format sorted scores into tooltip string
local function getAllScoresString(abbv)
    local s 
    if data.savedVars.db.scores[abbv] then 
        s = 'SCORES BY CHARACTER\n'
        local sortedScores = utils.sortedByValues(data.savedVars.db.scores[abbv])  -- converts t[key]=value into t[index]={key,value} sorted by value
        for _,r in ipairs(sortedScores) do 
            local toon  = r[1]
            local score =  ZO_LocalizeDecimalNumber(r[2])
            s = s .. '\n' .. string.rep(' ',10-#score) .. score .. '    ' .. toon  
        end
    else
        s = 'NO SCORES RECORDED'
    end
    return s
end

-- to do, will probably need to handle different API calls for trial, arena, endless archive
function ui.label.score(settings)
    -- create label
    settings.color = constants.color.rgbOrange
    settings.font  = constants.font.defaultFont
    settings.align = TEXT_ALIGN_RIGHT
    settings.width = 75
    settings.tooltipText = "Test Tooltip" -- Just used to initialize tooltip, text is updated dynamically
    
    local control = ui.label.basic(settings)    

	if settings.SCORED == false then
		settings.texture = constants.textures.X
        settings.color = constants.color.rgbGray
        settings.tooltipText = 'does not exist'
		local x = ui.icon.basic(settings)--give back a gray X instead of building a score control
		x:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
		x:SetParent(control)
		control:SetMouseEnabled(false)--disable tooltip for the score label
		return control
	end
	
	local score = data.scores.getHighestScore(settings.ABBV)
	score = ZO_LocalizeDecimalNumber(score)
	control:SetText(score)
	

    -- create updateFn to set text and tooltip and load into data.scores on change callback
    local updateFn = function()
        -- update score
        local score = data.scores.getHighestScore(settings.ABBV)
        score = ZO_LocalizeDecimalNumber(score)
        control:SetText(score)

        -- creating a dynamic tooltip text
        control:SetHandler("OnMouseEnter", function() 
            local text = getAllScoresString(settings.ABBV)
            local color = constants.color.hexGold
            local font  = constants.font.fixedWidthFont
            local tooltipString = string.format('|%s%s|r', color, text)
            ZO_Tooltips_ShowTextTooltip(control, TEXT_ALIGN_LEFT, tooltipString)
            end)

        local ttCloseFn = api.control.tooltipCloseFn(control)
        control:SetHandler("OnMouseExit", ttCloseFn)
    end
    updateFn()
    
    -- register callback to update when new scores are saved
    data.scores.registerCallback(updateFn)
    return control
end

---------------------------------------------------------------------------------------------------------
-- Pulse Label
---------------------------------------------------------------------------------------------------------

function ui.label.pulse(settings)

    -- Create a basic label with the provided settings
    local control = ui.label.basic(settings)
    
    -- Create the pulse animation timeline
    local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("LabelPulseAnimation", control)
    control.pulseAnimation = timeline
    
    -- Add methods to control the animation
    function control:StartPulse()
        if self.pulseAnimation then
            self.pulseAnimation:PlayFromStart()
        end
    end
    
    function control:StopPulse()
        if self.pulseAnimation then
            self.pulseAnimation:Stop()
        end
    end
    
    -- to do, this is a bit hacky, the callbacks logic should be handled in the view
    -- set text in an updateFn
    local updateFn = function(text)
        if text then
            control:SetText('SEARCHING: ' .. text)
            control:StartPulse()
        else
            control:StopPulse()
        end
    end
    updateFn()

    function control:SetPulse(shouldPulse)
        if shouldPulse then
            self:StartPulse()
        else
            self:StopPulse()
        end
    end

    return control
end


------------------------------------------------------------------------------------------------------------------
-- Watermark Label  
------------------------------------------------------------------------------------------------------------------

-- wrapped label with watermark defaults, also embeds anchor
function ui.label.watermark(settings)
    settings.color = settings.color or  {197/225, 194/225, 158/225, .15}
    settings.font  = settings.font or 'ZoFontCenterScreenAnnounceLarge'
    settings.align = settings.align or TEXT_ALIGN_CENTER
    settings.width = settings.width or 1000
    settings.scale = settings.scale or 3
    settings.vOffset = settings.vOffset or 0
	-- watermark specific values
	local control = ui.label.basic(settings)
	control:SetScale(settings.scale)
	control:SetAnchor(CENTER, PITHKA_GUI, CENTER, 0, settings.vOffset)
	return control
end