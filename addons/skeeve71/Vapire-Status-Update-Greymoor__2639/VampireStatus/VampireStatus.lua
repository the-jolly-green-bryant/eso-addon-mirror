-- Vampire Status Addon for Elder Scrolls Online, originally made by Stormknight/LCAmethyst
-- Author: CrazyDutchGuy, Stormknight/LCAmethyst
-- Skeeve71: Patch for Greymoor
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

local Addon = 
{
    name = "VampireStatus",
    nameSpaced = "Vampire Status",
    author = "CrazyDutchGuy, Stormknight, Engel",
    version = "2.4.3",    
    -- Set-up the defaults options for saved variables.
    defaults = 
    {
        locx        = 400,
        locy        = 400,
        locked      = false,
    },        
}

local VampireStatus = nil

local function VampStatus_OnUpdate()
    -- Now look for the Vampirism buff
    local i, numBuffs, buffName, timeStarted, timeEnding, iconFilename, matchResult, buffName2
    numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        buffName, timeStarted, timeEnding, _, _, iconFilename, _, _, _, _ = GetUnitBuffInfo("player",i)
        matchResult = PlainStringFind(iconFilename,"ability_u26_vampire_infection")
        if (matchResult) then
            local timeRemaining = math.ceil(( timeEnding - ( GetGameTimeMilliseconds() / 1000 ) ) / 60 )
            if (timeRemaining > 0) then
                timeRemaining = timeRemaining .. " mins"
            else
                timeRemaining = ""
            end
			buffName = buffName:sub(1, -3) --remove whitspace from name
            VampireStatus.LabelStage:SetText(buffName)
            VampireStatus.LabelTime:SetText(timeRemaining)
			VampireStatus.btnVamp:SetTexture(iconFilename)
            return  -- don't need to cycle through remaining buffs if we've found the one we want
        end
    end
end 

local function VampStatus_OnMoveStop()
    Addon.vars.locx = math.floor(VampireStatus:GetLeft())
    Addon.vars.locy = math.floor(VampireStatus:GetTop())
end 

local function createLAM2Panel()
    local panelData = 
    {
        type = "panel",
        name = Addon.nameSpaced,
        displayName = "|cFFFFB0" .. Addon.nameSpaced .. "|r",
        author = Addon.author,
        version = Addon.version,
    }

    local optionsData = 
    {
        [1] = 
        {
            type = "checkbox",
            name = "Lock Vampire Status",
            tooltip = "Locks the Vampire Status button in place.",
            getFunc = function() return Addon.vars.locked end,
            setFunc = function(value) 
                Addon.vars.locked = value 
                VampireStatus:SetMovable(not Addon.vars.locked)                
            end,
        },
        [2] =
        {
            type = "description",
            text = "AI Vampire Status is an addon that shows the various stages of Vampirism on your screen.",
        }
    }   

    LAM2:RegisterAddonPanel(Addon.name.."LAM2Options", panelData)
    LAM2:RegisterOptionControls(Addon.name.."LAM2Options", optionsData)
end

local function VampStatus_OnAddOnLoad(eventCode, addOnName)
    -- Only initialize our own addon
    if (Addon.name ~= addOnName) then return end

    Addon.vars = ZO_SavedVars:NewAccountWide("AIVampStatus_SavedVariables", 1, nil, Addon.defaults)

    VampireStatus = WINDOW_MANAGER:CreateTopLevelWindow( nil )
    VampireStatus:SetMouseEnabled(true)         
    VampireStatus:SetMovable( not Addon.vars.locked )
    VampireStatus:SetClampedToScreen( true )
    VampireStatus:SetDimensions( 200 , 40 )
    VampireStatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Addon.vars.locx, Addon.vars.locy)

    VampireStatus:SetHandler("OnMoveStop", function(...) VampStatus_OnMoveStop(...) end )    

    VampireStatus.LabelStage = WINDOW_MANAGER:CreateControl(nil, VampireStatus, CT_LABEL)
    VampireStatus.LabelStage:SetAnchor(TOP, VampireStatus, TOP, 24, 0)
    VampireStatus.LabelStage:SetDimensions( 160, 20 )    
    VampireStatus.LabelStage:SetFont("ZoFontWinH5")


    VampireStatus.LabelTime = WINDOW_MANAGER:CreateControl(nil, VampireStatus, CT_LABEL)
    VampireStatus.LabelTime:SetAnchor(TOP, VampireStatus, TOP, 24, 20)
    VampireStatus.LabelTime:SetDimensions( 160, 20 )
    VampireStatus.LabelTime:SetFont("ZoFontWinH5")

    VampireStatus.btnVamp = WINDOW_MANAGER:CreateControl("VampireStatusButtonVampire", VampireStatus, CT_TEXTURE)
    VampireStatus.btnVamp:SetDimensions(36, 36)
    VampireStatus.btnVamp:SetAnchor(TOPLEFT, VampireStatus, TOPLEFT, 2 , 2)
    VampireStatus.btnVamp:SetHidden(false)
--    VampireStatus.btnVamp:SetTexture("/esoui/art/icons/ability_u26_vampire_infection_stage1.dds")
    
    local fragment = ZO_SimpleSceneFragment:New( VampireStatus )        
    SCENE_MANAGER:GetScene('hud'):AddFragment( fragment )   
    SCENE_MANAGER:GetScene('hudui'):AddFragment( fragment )    

    EVENT_MANAGER:UnregisterForEvent( Addon.name, EVENT_ADD_ON_LOADED )

    createLAM2Panel()

    VampStatus_OnUpdate()
    -- Every minute is more then enough
    EVENT_MANAGER:RegisterForUpdate(Addon.name.."Update", 60*1000, function(...) VampStatus_OnUpdate() end ) 
    -- For fase changes and stuff, additional accuracy in case the once a minute is not enough
    EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_EFFECT_CHANGED, function(...) VampStatus_OnUpdate() end ) 

end

function VampStatus_OnInitialized()
    EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, function(...) VampStatus_OnAddOnLoad(...) end)
end
