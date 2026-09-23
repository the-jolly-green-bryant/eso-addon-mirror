	EVENT_MANAGER:RegisterForEvent("ERUI_SimpleImage", EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= "EldenRingUI" then return end
    
    local Master = WINDOW_MANAGER:CreateControl("ERUI_SimpleImgMaster", GuiRoot, CT_TOPLEVELCONTROL)
    Master:SetAnchorFill(GuiRoot)
    Master:SetDrawLayer(DL_BACKGROUND)
    Master:SetDrawTier(DT_LOW)
    Master:SetDrawLevel(0)
    
    local function AddImg(name, file, relToEdge, x, y, w, h)
        local c = WINDOW_MANAGER:CreateControl(name, Master, CT_CONTROL)
        c:SetDimensions(w, h)
        c:SetAnchor(CENTER, Master, relToEdge, x, y)
        
        c:SetDrawLayer(DL_BACKGROUND)
        c:SetDrawTier(DT_LOW)
        c:SetDrawLevel(0)

        local t = WINDOW_MANAGER:CreateControl(nil, c, CT_TEXTURE)
        t:SetAnchorFill()
        t:SetTexture("EldenRingUI/Textures/" .. file)
        return c 
    end
    
    local function GetPlayerClassIcon()
        local classId = GetUnitClassId("player")
        local classMap = {
            [1]   = "Icons/dragonknight.dds",
            [2]   = "Icons/sorcerer.dds",
            [3]   = "Icons/nightblade.dds",
            [4]   = "Icons/warden.dds",
            [5]   = "Icons/necromancer.dds",
            [6]   = "Icons/templar.dds",  
            [117] = "Icons/arcanist.dds", 
        }
        return classMap[classId] or "empty.dds" 
    end
    
    AddImg("ERUI_Img1", "ClassHolder.dds", TOPLEFT, 91, 70, 128, 128)
    AddImg("ERUI_Img0", GetPlayerClassIcon(), TOPLEFT, 91, 70, 80, 80)

    AddImg("ERUI_Img2", "Slot.dds", BOTTOMLEFT, 92, -171, 128, 128)   -- Left Slot
    AddImg("ERUI_Img3", "Slot.dds", BOTTOMLEFT, 187, -225, 128, 128)  -- Top Slot
    AddImg("ERUI_Img4", "Slot.dds", BOTTOMLEFT, 187, -115, 128, 128)  -- Bottom Slot
    AddImg("ERUI_Img5", "Slot.dds", BOTTOMLEFT, 281, -171, 128, 128)  -- Right Slot

    AddImg("ERUI_Img6", "Souls.dds", BOTTOMRIGHT, -150, -45, 512, 256) 
    AddImg("ERUI_Img7", "Mastery.dds", BOTTOMLEFT, 236, -391, 512, 64)
	
	AddImg("ERUI_Img8", "ERCompass.dds", TOP, 0, 135, 500, 12)
	
    local compassMarks = {
    AddImg("ERUI_Img9", "CompassMark.dds", TOP, -128, 135, 4, 24),
    AddImg("ERUI_Img10", "CompassMark.dds", TOP, -77, 135, 4, 24),
    AddImg("ERUI_Img11", "CompassMark.dds", TOP, -26, 135, 4, 24),
    AddImg("ERUI_Img12", "CompassMark.dds", TOP, 26, 135, 4, 24),
    AddImg("ERUI_Img13", "CompassMark.dds", TOP, 77, 135, 4, 24),
    AddImg("ERUI_Img14", "CompassMark.dds", TOP, 128, 135, 4, 24)
    }

    
    local deathImg = WINDOW_MANAGER:CreateControl("ERUI_DeathImageDisplay", Master, CT_TEXTURE)
    local screenWidth = GuiRoot:GetWidth()
    local scaleFactor = screenWidth / 1920
    deathImg:SetDimensions(screenWidth, 240 * scaleFactor)
    deathImg:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    deathImg:SetTexture("EldenRingUI/Textures/died.dds")
    deathImg:SetHidden(true)
    deathImg:SetDrawLayer(DL_OVERLAY)
    deathImg:SetDrawTier(DT_HIGH)

    local deathImg2 = WINDOW_MANAGER:CreateControl("ERUI_DeathImageDisplay2", Master, CT_TEXTURE)
    deathImg2:SetDimensions(1024, 128)
    deathImg2:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -28)
    deathImg2:SetTexture("EldenRingUI/Textures/DeadBG.dds")
    deathImg2:SetHidden(true)
    deathImg2:SetDrawLayer(DL_OVERLAY)
    deathImg2:SetDrawTier(DT_MEDIUM) 

    EVENT_MANAGER:RegisterForEvent("ERUI_SimpleImage_Death", EVENT_PLAYER_DEAD, function()
        for i = 1, 3 do
            PlaySound(SOUNDS.BATTLEGROUND_MATCH_LOST)
        end
        PlaySound(SOUNDS.BATTLEGROUND_ROUND_RECAP_FLAG_SCORE_COUNT)
        deathImg:SetHidden(false)
        
        for _, mark in ipairs(compassMarks) do
            mark:SetHidden(true)
        end

        zo_callLater(function() 
            deathImg:SetHidden(true) 
        end, 2500)
        
        zo_callLater(function()
            if IsUnitDead("player") then
                deathImg2:SetHidden(false)
            end
        end, 2000)
    end)
    
    EVENT_MANAGER:RegisterForEvent("ERUI_SimpleImage_Alive", EVENT_PLAYER_ALIVE, function()
        deathImg:SetHidden(true)
        deathImg2:SetHidden(true) 
        
        for _, mark in ipairs(compassMarks) do
            mark:SetHidden(false)
        end
    end)

    COMPASS_FRAME:SetBossBarHiddenForReason('modded', true)

    local function UpdateVisibility()
        local isHudVisible = SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
        Master:SetHidden(not isHudVisible)
    end

    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", UpdateVisibility)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", UpdateVisibility)
    UpdateVisibility()
end)