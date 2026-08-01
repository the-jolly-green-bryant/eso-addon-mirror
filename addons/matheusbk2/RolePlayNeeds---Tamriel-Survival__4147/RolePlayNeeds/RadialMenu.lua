local buttonTexts = {"Eat", "Drink", "Rest", "Sleep", "Needs", "Ask", "Books", "Pets"}
local buttonActions = {
    function() SLASH_COMMANDS["/eatfood"]() end,
    function() SLASH_COMMANDS["/drinkwater"]() end,
    function() SLASH_COMMANDS["/rest"]() end,
    function() SLASH_COMMANDS["/takeanap"]() end,
    function() SLASH_COMMANDS["/togglesurvival"]() end,
    function() SLASH_COMMANDS["/openaskforinfo"]() end,
    function() SLASH_COMMANDS["/openmybook"]() end,
    function() SLASH_COMMANDS["/openmypets"]() end,
}

local function IsAddonLoaded(target)
    local t = _G[target]
    return type(t) == "table"
end

local function SetupHoverLabel(button, labelText)
    button:SetHandler("OnMouseEnter", function()
    local state = SLASH_COMMANDS["/isSurvivalOn"]()
    if state then
        state = " ON"
        MyFakeRadialButton5:SetNormalTexture("RolePlayNeeds/ui/wheel/survivalG.dds")
        MyFakeRadialButton5:SetPressedTexture("RolePlayNeeds/ui/wheel/survivalR.dds")
        MyFakeRadialButton5:SetMouseOverTexture("RolePlayNeeds/ui/wheel/survivalG.dds")
    else
        state= " OFF"
        MyFakeRadialButton5:SetNormalTexture("RolePlayNeeds/ui/wheel/survivalR.dds")
        MyFakeRadialButton5:SetPressedTexture("RolePlayNeeds/ui/wheel/survivalG.dds")
        MyFakeRadialButton5:SetMouseOverTexture("RolePlayNeeds/ui/wheel/survivalR.dds")
    end
        MyFakeRadialHoverLabel:SetText(labelText)
        if button == MyFakeRadialButton5 then
        MyFakeRadialHoverLabel:SetText(labelText .. state)
        end

        MyFakeRadialHoverLabel:SetHidden(false)
        button:SetDimensions(64, 64)
        PlaySound(SOUNDS.DEFAULT_CLICK)
    end)
    button:SetHandler("OnMouseExit", function()
        MyFakeRadialHoverLabel:SetText("")
        MyFakeRadialHoverLabel:SetHidden(true)
        button:SetDimensions(50, 50)
    end)
end
function InitializeWheel()
    local base = MyFakeRadial
    base:SetHidden(true)
    base:ClearAnchors()
    base:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    base:SetDrawTier(DT_HIGH)

    local hasAsk = IsAddonLoaded("IHeardARumor")
    local hasBooks = IsAddonLoaded("TamrielBooks")
    local hasPets = IsAddonLoaded("ImmersivePets")

    for i = 1, 8 do
        local btn = base:GetNamedChild("Button" .. i)
        if btn then
            local show = true

            if i == 6 and not hasAsk then
                show = false
                d("Hiding Ask button: IHeardARumor not loaded.")
            elseif i == 7 and not hasBooks then
                show = false
                d("Hiding Books button: TamrielBooks not loaded.")
            elseif i == 8 and not hasPets then
                show = false
                d("Hiding Pets button: ImmersivePets not loaded.")
            end

            btn:SetHidden(not show)

            if show then
                btn:SetHandler("OnClicked", buttonActions[i])
            else
                btn:SetHandler("OnClicked", nil)  -- remove handler just in case
            end
        end
    end
local label = WINDOW_MANAGER:CreateControl("MyFakeRadialHoverLabel", MyFakeRadial, CT_LABEL)
label:SetFont("ZoFontWinH1")
label:SetDimensions(300, 40)
label:SetAnchor(CENTER, MyFakeRadial, CENTER, 0, 0)
label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
label:SetColor(1, 1, 1, 1)
label:SetHidden(true)
SetupHoverLabel(MyFakeRadialButton1, "Eat")
SetupHoverLabel(MyFakeRadialButton2, "Drink")
SetupHoverLabel(MyFakeRadialButton3, "Rest")
SetupHoverLabel(MyFakeRadialButton4, "Sleep")
SetupHoverLabel(MyFakeRadialButton5, "Survival Mode:")
SetupHoverLabel(MyFakeRadialButton6, "Ask")
SetupHoverLabel(MyFakeRadialButton7, "Books")
SetupHoverLabel(MyFakeRadialButton8, "Pets")
    SLASH_COMMANDS["/mywheel"] = function()
        base:SetHidden(not base:IsHidden())
        SetGameCameraUIMode(true)
    end
end
