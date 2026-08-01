local AddonName="NecroCat"
local lang=GetCVar("language.2")
local Settings={
    Guilds={
        [839248]=true,	--Castle of Necro-Cat
    },
    Logo=true,
    Label={en="Guildhalls",ru="|c66f2ffГильд Холлы|r"},
    LabelFont="ZoFontWinH4",
    Position={TOPLEFT,ZO_GuildHome,TOPLEFT,30,500},	
    Vertical=true, 
    ButtonSize=150,
    Space=10,
    Message=true,
    MessageText={en="Jump to ",ru="Перемещаемся в "},
}

local ButtonData={
    [1]={
        tooltip={en="Main guildhall", ru="|c66f2ffNecroCat|r"},
        house={"@NecroCat_Crimson", 124},
        icon = "NecroCat/imgs/GuildHall.dds",
        layout = "vertical",
        size = 150 -- Размер иконки 1
    },
    [2]={
        tooltip={en="Crafting house", ru="Крафт Холл"},
        house={"@NecroCat_Crimson", 13},
        icon="NecroCat/imgs/CastleofNecroCat.dds",
        layout = "horizontal",
        size = 50 -- Размер иконки 2
    },
}

local function ScreenMessage(message,delay)
	if BUI and BUI.OnScreen then
		BUI.OnScreen.Message[11]=nil
		BUI.OnScreen.Notification(11,message,(not delay and SOUNDS.BOOK_ACQUIRED or nil),delay)
	else
		local messageParams=CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.BOOK_ACQUIRED)
		messageParams:SetText("|t42:42:/esoui/art/icons/mapkey/mapkey_wayshrine.dds|t "..message)
		CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
	end
end

local function MakeButton(control, num, index, isVertical)
    local data = ButtonData[num]
    local w = data.size or Settings.ButtonSize
    local space = Settings.Space
    
    local name = "ZO_GuildHome_NecroCat_ButtonContainer"..num
    local container = _G[name] or WINDOW_MANAGER:CreateControl(name, control, CT_CONTROL)
    container:SetDimensions(w + 20, w + 40) 
    
    container:ClearAnchors()
    if isVertical then
        container:SetAnchor(TOPLEFT, control, TOPLEFT, 0, (w + space + 20) * index)
    else
        container:SetAnchor(TOPLEFT, control, TOPLEFT, (w + space) * index, 0)
    end
    
    -- Сама иконка
    local buttonName = name.."_Icon"
    local button = _G[buttonName] or WINDOW_MANAGER:CreateControl(buttonName, container, CT_TEXTURE)
    button:SetDimensions(w, w)
    button:SetAnchor(TOP, container, TOP, 0, 0)
    button:SetTexture(data.icon)
    button:SetColor(.6,.57,.46,1)
    button:SetMouseEnabled(true)

    -- Текст под иконкой
    local labelName = name.."_Label"
    local label = _G[labelName] or WINDOW_MANAGER:CreateControl(labelName, container, CT_LABEL)
    label:SetDimensions(w + 20, 20)
    label:SetAnchor(TOP, button, BOTTOM, 0, 2)
    label:SetFont("ZoFontGameSmall")
    label:SetText(data.tooltip[lang] or data.tooltip.en)
    label:SetHorizontalAlignment(1)
    label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

    -- Обработчики
    button:SetHandler("OnMouseEnter", function(self) self:SetColor(.9,.9,.8,1) end)
    button:SetHandler("OnMouseExit", function(self) self:SetColor(.6,.57,.46,1) end)
    button:SetHandler("OnMouseDown", function(self)
        if Settings.Message and data.house then
            SCENE_MANAGER:SetInUIMode()
            local tooltip=data.tooltip[lang] or data.tooltip.en
            ScreenMessage((Settings.MessageText[lang] or Settings.MessageText.en)..tooltip,8000)
            if data.house[2] then
                if data.house[1] == GetDisplayName() then RequestJumpToHouse(data.house[2]) 
                else JumpToSpecificHouse(data.house[1], data.house[2]) end
            else JumpToHouse(data.house[1]) end
        end
    end)
end

local function UI_Init()
    -- 1. СТАРЫЙ ФОН (оставляем его на месте как декорацию)
    local bgControl = ZO_GuildHome_NecroCat or WINDOW_MANAGER:CreateControl("ZO_GuildHome_NecroCat", ZO_GuildHome, CT_CONTROL)
    local pos = Settings.Position
    bgControl:SetDimensions(128, 64)
    bgControl:ClearAnchors()
    bgControl:SetAnchor(pos[1], ZO_GuildHome, pos[3], pos[4], pos[5])
    bgControl:SetHidden(false)

    -- Логотип (если есть)
    if Settings.Logo then
        local texture = ZO_GuildHome_Castle or WINDOW_MANAGER:CreateControl("ZO_GuildHome_Castle", bgControl, CT_TEXTURE)
        texture:SetDimensions(700, 700)
        texture:ClearAnchors()
        texture:SetAnchor(TOP, bgControl, TOP, 475, -420)
        texture:SetTexture("/NecroCat/imgs/GuildHall.dds")
        texture:SetAlpha(.5)
        texture:SetHidden(false)
    end

    -- 2. ВЕРТИКАЛЬНЫЙ КОНТЕЙНЕР (под Торговцем)
    local vControl = ZO_GuildHome_NecroCat_V or WINDOW_MANAGER:CreateControl("ZO_GuildHome_NecroCat_V", ZO_GuildHome, CT_CONTROL)
    vControl:SetDimensions(200, 200)
    vControl:ClearAnchors()
    vControl:SetAnchor(TOPLEFT, ZO_GuildHome, TOPLEFT, 30, 535) 
    vControl:SetHidden(false)

    -- 3. ГОРИЗОНТАЛЬНЫЙ КОНТЕЙНЕР (для Крафт Холлов)
    local hControl = ZO_GuildHome_NecroCat_H or WINDOW_MANAGER:CreateControl("ZO_GuildHome_NecroCat_H", ZO_GuildHome, CT_CONTROL)
    hControl:SetDimensions(500, 200)
    hControl:ClearAnchors()
    hControl:SetAnchor(TOPLEFT, bgControl, TOPLEFT, 300, -490)
    hControl:SetHidden(false)

    -- 4. РАСКИДЫВАЕМ КНОПКИ
    local vIndex = 0
    local hIndex = 0
    
    for num, data in pairs(ButtonData) do
        if data.layout == "vertical" then
            MakeButton(vControl, num, vIndex, true)
            vIndex = vIndex + 1
        else
            MakeButton(hControl, num, hIndex, false)
            hIndex = hIndex + 1
        end
    end
end

local function OnAddOnLoaded(_,addonName)
	if addonName~=AddonName then return end
	EVENT_MANAGER:UnregisterForEvent("NGH_Event", EVENT_ADD_ON_LOADED)
--	NGH_Vars=ZO_SavedVars:NewAccountWide("NGH_Settings", 3, nil, Defaults)
	ZO_PreHookHandler(ZO_GuildHome,"OnEffectivelyShown",function()
		ZO_GuildHome_NecroCat:SetHidden(not Settings.Guilds[GUILD_SELECTOR.guildId])
	end)
--	ZO_PreHookHandler(ZO_GuildHome,'OnEffectivelyHidden',function() end)
	CALLBACK_MANAGER:RegisterCallback("OnGuildSelected",function()
		ZO_GuildHome_NecroCat:SetHidden(not Settings.Guilds[GUILD_SELECTOR.guildId])
	end)
	UI_Init()
end

EVENT_MANAGER:RegisterForEvent("NGH_Event", EVENT_ADD_ON_LOADED, OnAddOnLoaded)