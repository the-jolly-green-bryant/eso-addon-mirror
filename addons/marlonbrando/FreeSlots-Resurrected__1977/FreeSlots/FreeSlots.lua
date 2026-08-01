-- Name: FreeSlots
-- Author: Valandil, Specko
-- Description: Displays free inventory slots without opening the bag screen.

local saved

local ui

local name = "FreeSlots"
local version = "2.24"
local savedVersion = 1
local wm

local gr, gg, gb = (0xcf / 0xff),  (0xdc / 0xff), (0xbd / 255)

local function num(n)
    return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(n))
end

local moving = false
function onmovestart()
    moving = true
end

function onmovestop()
    saved.wm.x = ui:GetLeft()
    saved.wm.y = ui:GetTop()
    moving = false
end

local BufferTable = {}

local function bag(c)
    local red = 0
    local green = 0
    local blue = 0
    local alpha = 255

    --red
    local NoSpace = {}
    for i=-1, 5 do
	NoSpace[#NoSpace+1] = i + 1
    end

    for k = 1, #NoSpace do
	if CheckInventorySpaceSilently(NoSpace[k]) == true then
	    red = 255
	    green = 0
	    blue = 0
	    alpha = 255
	end
    end

    --orange
    local SomeSpace = {}
    for i=6, 10 do
	SomeSpace[#SomeSpace+1] = i + 1
    end

    for k = 1, #SomeSpace do
	if CheckInventorySpaceSilently(SomeSpace[k]) == true then
	    red = 128
	    green = 0
	    blue = 0
	    alpha = 255
	end
    end

    --yellow
    local DecentSpace = {}
    for i=11, 20 do
	DecentSpace[#DecentSpace+1] = i + 1
    end

    for k = 1, #DecentSpace do
	if CheckInventorySpaceSilently(DecentSpace[k]) == true then
	    red = 255
	    green = 255
	    blue = 0
	    alpha = 255
	end
    end

    --blue
    local MediumSpace = {}
    for i=21, 30 do
	MediumSpace[#MediumSpace+1] = i + 1
    end

    for k = 1, #MediumSpace do
	if CheckInventorySpaceSilently(MediumSpace[k]) == true then
	    red = 0
	    green = 255
	    blue = 255
	    alpha = 255
	end
    end

    --green
    local PlentyOfSpace = {}
    for i=31, 1000 do
	PlentyOfSpace[#PlentyOfSpace+1] = i + 1
    end

    for k = 1, #PlentyOfSpace do
	if CheckInventorySpaceSilently(PlentyOfSpace[k]) == true then
	    red = 0
	    green = 255
	    blue = 0
	    alpha = 255
	end
    end


    --getBagSpace
    local slots = {}
    for i=0, 1000 do
	slots[i] = i + 1
    end

    for j = 0, #slots do
	if CheckInventorySpaceSilently(j) == true then
	    bagSpace = j
	end
    end

    totalSlots = GetBagSize(BAG_BACKPACK)

    c:SetColor(red, green, blue, alpha)

    c:SetText(string.format("%d/%d", bagSpace, totalSlots))
end

local function bank(c)
    bankSpace = GetNumBagFreeSlots(BAG_BANK) + GetNumBagFreeSlots(BAG_SUBSCRIBER_BANK)
    totBankSpace = GetBagSize(BAG_BANK) + GetBagSize(BAG_SUBSCRIBER_BANK)

    c:SetText(string.format("%d/%d", bankSpace, totBankSpace))
end

local function alliancepoints(c)
    c:SetText(num(GetAlliancePoints()))
end

local function gold(c)
    c:SetText(num(GetCurrentMoney()))
end

local function telvar(c)
    c:SetText(num(GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)))
end

local function telvarbank(c)
    c:SetText(num(GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_BANK)))
end

local function transmute(c)
    local max = GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
    local have = GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
    c:SetText(string.format("%s/%s", num(have), num(max)))
end

local function BufferReached(key, buffer)
    if key == nil then return end
    if BufferTable[key] == nil then
	BufferTable[key] = {}
    end
    BufferTable[key].buffer = buffer or 3
    BufferTable[key].now = GetFrameTimeSeconds()
    if BufferTable[key].last == nil then
	BufferTable[key].last = BufferTable[key].now
    end
    BufferTable[key].diff = BufferTable[key].now - BufferTable[key].last
    BufferTable[key].eval = BufferTable[key].diff >= BufferTable[key].buffer
    if BufferTable[key].eval then
	BufferTable[key].last = BufferTable[key].now
    end
    return BufferTable[key].eval
end

local currencies = {
    {func = bag, field = 'bag', text = 'Inventory Slots'},
    {func = bank, field = 'bank', text = 'Bank Slots'},
    {func = alliancepoints, field = 'ap', text = 'Alliance Points'},
    {func = gold, field = 'gold', text = 'Gold', rgb = {1, 1, 0}},
    {func = telvar, field = 'telvar', text = 'Tel Var', rgb = {0.30, 0.65, 1}},
    {func = telvarbank, field = 'telvarbank', text = 'Tel Var in Bank', rgb = {0.30, 0.65, 1}},
    {func = transmute, field = 'transmute', text = 'Transmute Crystals'}
}

local maxx
local maxx1 = 0
local maxy
local function onupdate()
    if moving or not BufferReached("myaddonupdatebuffer", 1) then
	return
    end
    local maxxnow = 0
    for _, x in ipairs(currencies) do
	local func, control = x.func, x.controlstatus
	func(control)
	local width = control:GetWidth()
	if width > maxxnow then
	    maxxnow = width
	end
    end
    if maxxnow ~= maxx1 then
	maxx1 = maxxnow + 12
	for _, x in ipairs(currencies) do
	    x.controlstatus:SetWidth(maxx1)
	end
	ui:SetDimensions(maxx + maxx1 + 22, maxy + 4)
	ui:SetHidden(false)
    end
end

local function update_control(ui, create)
    local controls = {}
    ui:SetHidden(true)
    maxx = 0 maxy = 0 maxx1 = 0
    for i, x in ipairs(currencies) do
	local func, field, text = x.func, x.field, x.text
	local r, g, b
	if x.rgb then
	    r, g, b = unpack(x.rgb)
	end
	local ct = (create and wm:CreateControl(nil, ui, CT_LABEL)) or x.controltag
	x.controltag = ct
	local cs = (create and wm:CreateControl(nil, ui, CT_LABEL)) or x.controlstatus
	x.controlstatus = cs
	if not saved.currencies[field].show then
	    ct:SetText("") ct:SetHidden(true)
	    cs:SetText("") cs:SetHidden(true)
	else
	    ct:ClearAnchors()
	    cs:ClearAnchors()
	    ct:SetFont("ZoFontGame")
	    ct:SetAnchor(TOPLEFT, ui, TOPLEFT, 6, maxy)
	    ct:SetHorizontalAlignment(RIGHT)
	    ct:SetText(text)
	    ct:SetColor(gr, gg, gb, 1)
	    local width = ct:GetWidth()
	    if width > maxx then
		maxx = width
	    end

	    cs:SetFont("ZoFontGame")
	    cs:SetColor(r or gr, g or gg, b or gb, 1)
	    cs:SetAnchor(TOPLEFT, ct, TOPRIGHT, 10, 0)
	    cs:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	    controls[#controls + 1] = ct
	    maxy = maxy + 20
	    ct:SetHidden(false)
	    cs:SetHidden(false)
	end
    end
    for _, ct in ipairs(controls) do
	ct:SetWidth(maxx)
    end
end

local function lam(ui)
    local o = {
	{
	    type = "header",
	    name = GetString("Display Options"),
	}
    }
    for _, x in ipairs(currencies) do
	local field, text = x.field, x.text
	o[#o + 1] = {
	    type = "checkbox",
	    name = text,
	    tooltip = "Control whether to always display " .. text,
	    getFunc = function()
		return saved.currencies[field].show
	    end,
	    setFunc = function(setit)
		saved.currencies[field].show = setit
		update_control(ui)
	    end
	}
    end
    local paneldata = {
	    type = "panel",
	    name = "FreeSlots",
	    displayName = "|c00B50F" .. "FreeSlots" .. "|r",
	    author = "Valandil",
	    description = "Show Inventory, Bank, and Currency Info",
	    version = version,
	    registerForDefaults = true,
	    registerForRefresh = true
    }
    local LAM = LibAddonMenu2
    local panel = LAM:RegisterAddonPanel("FreeSlotsSettingsMenu", paneldata)
    LAM:RegisterOptionControls("FreeSlotsSettingsMenu", o)
    SLASH_COMMANDS["/freeslots"] = function () LAM:OpenToPanel(panel) end
end

local function initialize(eventCode, addOnName)
    if addOnName ~= name then
	return
    end
    EVENT_MANAGER:UnregisterForEvent("FreeSlots")

    local defaults = {currencies = {}, wm = {}}
    for _, x in ipairs(currencies) do
	local field = x.field
	defaults.currencies[field] = {}
	defaults.currencies[field].show = true
    end

    saved = ZO_SavedVars:New("FreeSlotsSettings" , savedVersion, nil, defaults, nil)

    ui = CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
    if saved.wm.x then
	ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, saved.wm.x, saved.wm.y)
    else
	ui:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    ui:SetClampedToScreen(true)
    ui:SetMovable(true)
    ui:SetMouseEnabled(true)
    ui:SetHandler("OnMoveStart", onmovestart)
    ui:SetHandler("OnMoveStop", onmovestop)
    ui:SetHidden(false)
    ui:SetDrawLayer(1)

    wm = GetWindowManager()
    local bg = wm:CreateControlFromVirtual(nil, ui, 'ZO_DefaultBackdrop')
    bg:SetAnchor(TOPLEFT, scrollContainer, TOPLEFT, 0, -3)
    bg:SetAnchor(BOTTOMRIGHT, scrollContainer, BOTTOMRIGHT, 2, 5)
    -- bg:SetEdgeTexture("EsoUI\\Art\\Tooltips\\UI-Border.dds", 128, 16)
    -- bg:SetCenterTexture("EsoUI\\Art\\Tooltips\\UI-TooltipCenter.dds")
    bg:SetAlpha(.8)
    -- bg:SetInsets(16, 16, -16, -16)
    lam(ui)
    update_control(ui, true)
    bg:SetHandler("OnUpdate", onupdate)
    local fragment = ZO_SimpleSceneFragment:New(ui)
    local sceneHud = SCENE_MANAGER:GetScene("hud")
    local sceneHudUI = SCENE_MANAGER:GetScene("hudui")
    sceneHud:AddFragment(fragment)
    sceneHudUI:AddFragment(fragment)
    SLASH_COMMANDS["fsreset"] = function () saved.wm = {} ReloadUI() end
end

EVENT_MANAGER:RegisterForEvent("FreeSlots" , EVENT_ADD_ON_LOADED , initialize)
