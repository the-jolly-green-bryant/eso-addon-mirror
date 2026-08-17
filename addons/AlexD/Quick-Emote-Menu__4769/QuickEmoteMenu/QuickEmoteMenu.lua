local ADDON_TITLE   = "Quick Emote Menu"
local ADDON_NAME    = "QuickEmoteMenu"
local ADDON_AUTHOR  = "@AlexD"
local ADDON_VERSION = "1.2.0"
local ADDON_WEBSITE = "https://www.esoui.com/downloads/info4769-QuickEmoteMenu.html"
local SV_VERSION    = 1

local SLASH_COMMAND_PANEL  = "/qempanel"
local SLASH_COMMAND_DETACH = "/qemdetach"

QuickEmoteMenu = QuickEmoteMenu or {}
local QEM = QuickEmoteMenu

-- Cached ESO globals
local SM  = SCENE_MANAGER
local EM  = EVENT_MANAGER
local WM  = WINDOW_MANAGER
local WMS = WORLD_MAP_SCENE
local PEM = PLAYER_EMOTE_MANAGER
local MIO = MouseIsOver

local SOUND_OPEN  = SOUNDS.TREE_HEADER_CLICK
local SOUND_CLICK = SOUNDS.DEFAULT_CLICK
local BTN_LEFT    = MOUSE_BUTTON_INDEX_LEFT
local BTN_RIGHT   = MOUSE_BUTTON_INDEX_RIGHT
local CURSOR_TYPE = {
                        DEFAULT = MOUSE_CURSOR_DEFAULT_CURSOR,
                        DRAG    = MOUSE_CURSOR_PAN,
                    }

-- Cached locals
local CreateControl              = CreateControl
local CreateControlFromVirtual   = CreateControlFromVirtual
local CreateTopLevelWindow       = CreateTopLevelWindow
local IsGameCameraUIModeActive   = IsGameCameraUIModeActive
local PlaySound                  = PlaySound
local PlayEmoteByIndex           = PlayEmoteByIndex
local GetInterfaceColor          = GetInterfaceColor
local GetString                  = GetString
local GetUIMousePosition         = GetUIMousePosition
local GuiRoot                    = GuiRoot
local ZO_ClearTable              = ZO_ClearTable
local ZO_ChatWindow              = ZO_ChatWindow
local ZO_ChatWindowOptions       = ZO_ChatWindowOptions
local ZO_ObjectPool              = ZO_ObjectPool
local ZO_SavedVars               = ZO_SavedVars
local ZO_SimpleSceneFragment     = ZO_SimpleSceneFragment
local ZO_CreateStringId          = ZO_CreateStringId
local ZO_Scroll_Initialize       = ZO_Scroll_Initialize
local ZO_Scroll_UpdateScrollBar  = ZO_Scroll_UpdateScrollBar
local ZO_Scroll_ResetToTop       = ZO_Scroll_ResetToTop
local strformat                  = string.format
local mmax                       = math.max
local mmin                       = math.min
local tinsert                    = table.insert
local tremove                    = table.remove
local tsort                      = table.sort

-- Layout constants
local ROW_W                 = 50
local ROW_H                 = 24
local ALPHA_ON, ALPHA_OFF   = 1, 0.35
local BG_ALPHA              = 0.85
local BORDER_ALPHA          = 0      -- TODO: testing hidden border
local MAX_VISIBLE_ROWS      = 20     -- TODO: max rows before scrollbar
local TLW_BUTTON_SIZE       = 36
local CHAT_BUTTON_SIZE      = 32
local CHAT_BUTTON_GAP       = 5  -- gap between the button and the chat window options button
local TEXTURE_ARROW_SCALE   = 0.8
local SUBMENU_GAP           = 13
local DRAW_LEVEL_TLW        = 200
local DRAW_LEVEL_FAV        = 202

-- TODO: when true, the in-menu Settings entry is not shown on the main emote menu.
local hideSettingsMenu      = false

-- Emote-row layout
local ROW_LEFT_PAD          = 4
local ROW_RIGHT_PAD         = 4
local ROW_RIGHT_PAD_EMOTES  = 20     -- TODO: extra padding because of scrollbar

-- Emote menu colors
local COLORS = {
    favorite = {
        normal = { 1.0, 0.55, 0.10, 1.0 },
        hover  = { 1.0, 0.75, 0.25, 1.0 },
    },
    label = {
        normal = { GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL) },
        hover  = { GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTEXT_HIGHLIGHT) },
    },
}

-- Font & text style
local FONT_ROW      = "$(MEDIUM_FONT)|18|shadow"
local FONT_HEADER   = "$(BOLD_FONT)|18|soft-shadow-thick"

-- Textures
local TEX = {
    ARROW       = "EsoUI/Art/Buttons/tree_closed_up.dds",
    EMOTES      = "EsoUI/Art/Help/help_tabIcon_emotes_up.dds",
    EMOTES_DOWN = "EsoUI/Art/Help/help_tabIcon_emotes_down.dds",
    EMOTES_OVER = "EsoUI/Art/Help/help_tabIcon_emotes_over.dds"
}

----------------------------------------------------------------------
-- Localization
-- https://wiki.esoui.com/How_to_add_localization_support
-- dynamically change the language ingame via a slash command in the chat editbox:
-- /script SetCVar("language.2", "de")
--[[
Languages:
de	German
en	English
es	Spanish
fr	French
ru	Russian
jp	Japanese
zh	Chinese Simplified
br	Portugese
it	Italian
kr	Korean
pl	Polish
th	Thai
tr	Turkish
ua	Ukrainian
--]]
----------------------------------------------------------------------
local STRINGS = {}

local function CacheLocalizedStrings()
    STRINGS.UNKNOWN_NAME           = GetString(SI_QUICKEMOTEMENU_UNKNOWN_NAME)
    STRINGS.CATEGORIES             = GetString(SI_QUICKEMOTEMENU_CATEGORIES)
    STRINGS.FAVORITES              = GetString(SI_QUICKEMOTEMENU_FAVORITES)
    STRINGS.NO_FAVORITES           = GetString(SI_QUICKEMOTEMENU_NO_FAVORITES)
    STRINGS.BINDING_TOGGLE         = GetString(SI_QUICKEMOTEMENU_BINDING_TOGGLE)
    STRINGS.OPTION_HOVER           = GetString(SI_QUICKEMOTEMENU_OPTION_HOVER)
    STRINGS.OPTION_HOVER_TOOLTIP   = GetString(SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP)
    STRINGS.OPTION_UIMODE          = GetString(SI_QUICKEMOTEMENU_OPTION_UIMODE)
    STRINGS.OPTION_UIMODE_TOOLTIP  = GetString(SI_QUICKEMOTEMENU_OPTION_UIMODE_TOOLTIP)
    STRINGS.OPTION_DETACH          = GetString(SI_QUICKEMOTEMENU_OPTION_DETACH)
    STRINGS.OPTION_DETACH_TOOLTIP  = GetString(SI_QUICKEMOTEMENU_OPTION_DETACH_TOOLTIP)
    STRINGS.OPTION_CLOSE           = GetString(SI_QUICKEMOTEMENU_OPTION_CLOSE)
    STRINGS.OPTION_RESET           = GetString(SI_QUICKEMOTEMENU_OPTION_RESET)
    STRINGS.OPTION_DESCRIPTION     = GetString(SI_QUICKEMOTEMENU_OPTION_DESCRIPTION)
    STRINGS.SETTINGS               = GetString(SI_QUICKEMOTEMENU_OPTION_SETTINGS)
    STRINGS.ATTACH_BUTTON          = GetString(SI_QUICKEMOTEMENU_OPTION_ATTACH_BUTTON)
    STRINGS.DETACH_BUTTON          = GetString(SI_QUICKEMOTEMENU_OPTION_DETACH_BUTTON)
    STRINGS.SHOW_SETTINGS_PANEL    = GetString(SI_QUICKEMOTEMENU_OPTION_SHOW_PANEL)
end

----------------------------------------------------------------------
-- Saved Variables + Settings
----------------------------------------------------------------------
local function InitSettings()
    local defaults = {
        buttonX              = nil,
        buttonY              = nil,
        favWindowX           = nil,
        favWindowY           = nil,
        submenuDelay         = 100,   -- 0 = only on click
        closeOnPlay          = true,  -- leave UI mode after LMB play
        showOnlyInUIMode     = false, -- only show the main button while the cursor is visible
        detachButtonFromChat = false, -- false = dock button next to the chat window options button; true = free-floating (draggable) button
        favorites            = {},    -- list of emoteId
    }

    local SV = ZO_SavedVars:NewAccountWide(ADDON_NAME .. "_SV", SV_VERSION, "Settings", defaults)
    QEM.SV = SV

    if not LibAddonMenu2 then return end

    local panelData = {
        type              = "panel",
        name              = ADDON_TITLE,
        displayName       = ADDON_TITLE,
        author            = ADDON_AUTHOR,
        version           = ADDON_VERSION,
        website           = ADDON_WEBSITE,
        slashCommand      = SLASH_COMMAND_PANEL,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {
        {
            type    = "slider",
            name    = STRINGS.OPTION_HOVER,
            tooltip = STRINGS.OPTION_HOVER_TOOLTIP,
            warning = STRINGS.OPTION_HOVER_TOOLTIP,
            min = 0, max = 200, step = 50,
            getFunc = function() return SV.submenuDelay end,
            setFunc = function(v) SV.submenuDelay = v end,
            default = defaults.submenuDelay,
        },
        {
            type    = "checkbox",
            name    = STRINGS.OPTION_CLOSE,
            getFunc = function() return SV.closeOnPlay end,
            setFunc = function(v) SV.closeOnPlay = v end,
            default = defaults.closeOnPlay,
        },
        {
            type    = "checkbox",
            name    = STRINGS.OPTION_UIMODE,
            tooltip = STRINGS.OPTION_UIMODE_TOOLTIP,
            getFunc = function() return SV.showOnlyInUIMode end,
            setFunc = function(v)
                SV.showOnlyInUIMode = v
                if QEM.UpdateButtonCursorVisibility then QEM.UpdateButtonCursorVisibility() end
            end,
            default = defaults.showOnlyInUIMode,
        },
        {
            type    = "checkbox",
            name    = STRINGS.OPTION_DETACH,
            tooltip = STRINGS.OPTION_DETACH_TOOLTIP,
            getFunc = function() return SV.detachButtonFromChat end,
            setFunc = function(v)
                SV.detachButtonFromChat = v
                if QEM.UpdateButtonAttachment then QEM.UpdateButtonAttachment() end
            end,
            default = defaults.detachButtonFromChat,
        }, -- toggle also available via /qemdetach and the in-menu Settings entry
        {
            type    = "button",
            name    = STRINGS.OPTION_RESET,
            func    = function()
                SV.buttonX, SV.buttonY = nil, nil
                if SV.detachButtonFromChat and QEM.button then
                    QEM.button:ClearAnchors()
                    QEM.button:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
                end
            end,
        },
        {
            type    = "description",
            text    = STRINGS.OPTION_DESCRIPTION,
            width   = "full",
        },
    }

    LibAddonMenu2:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)
    LibAddonMenu2:RegisterOptionControls(ADDON_NAME .. "Panel", options)
end

----------------------------------------------------------------------
-- Favorites helpers
----------------------------------------------------------------------
local function IsFavorite(emoteId)
    local favs = QEM.SV.favorites
    for i = 1, #favs do
        if favs[i] == emoteId then return true, i end
    end
    return false, nil
end

local function ToggleFavorite(emoteId)
    local isFav, idx = IsFavorite(emoteId)
    if isFav then
        tremove(QEM.SV.favorites, idx)
        return false
    else
        tinsert(QEM.SV.favorites, emoteId)
        return true
    end
end

----------------------------------------------------------------------
-- Create UI
----------------------------------------------------------------------
local function CreateUI()
    -- local saved variables
    local sv = QEM.SV

    -- Permanent measure label
    local measure = CreateControl(ADDON_NAME .. "_Measure", GuiRoot, CT_LABEL)
    measure:SetFont(FONT_ROW)
    measure:SetHidden(true)
    measure:SetWidth(3000)

    local function LeaveUIMode()
        if SM:GetScene("hud"):IsShowing() or SM:GetScene("hudui"):IsShowing() then
            SM:SetInUIMode(false)
        end
    end

    local function AcquirePopup(name, parent)
        local menu = CreateControl(name, parent or GuiRoot, CT_CONTROL)
        menu:SetInheritAlpha(false)
        menu:SetMouseEnabled(true)
        menu:SetHidden(true)
        menu:SetClampedToScreen(true)
        -- NOTE: deliberately NOT using SetResizeToFitDescendents(true) here.
        -- mainMenu/catMenu/emoteMenu all compute and set their own exact
        -- width/height manually. Combining manual
        -- SetWidth/SetHeight with resize-to-fit-descendents on the same
        -- control causes the engine's auto-fit to fight our explicit sizing
        -- (ESO itself warns about this combination), which showed up as
        -- menus not resizing correctly when favorites were added/removed.

        local bg = CreateControl("$(parent)Bg", menu, CT_BACKDROP)
        bg:SetAnchor(TOPLEFT, menu, TOPLEFT, -5, -5)
        bg:SetAnchor(BOTTOMRIGHT, menu, BOTTOMRIGHT, 5, 5)
        bg:SetCenterColor(12/255, 12/255, 12/255, BG_ALPHA)
        bg:SetEdgeTexture(nil, 1, 1, 1, 0)
        bg:SetEdgeColor(70/255, 70/255, 70/255, 1)
        bg:SetInsets(-1, -1, 1, 1)
        bg:SetExcludeFromResizeToFitExtents(true)
        menu.bg = bg
        return menu
    end

    local function StyleLabel(label, highlight)
        if highlight then
            local c = COLORS.label.hover
            label:SetColor(c[1], c[2], c[3], c[4])
        else
            local c = COLORS.label.normal
            label:SetColor(c[1], c[2], c[3], c[4])
        end
    end

    -- Floating movable button (TopLevelWindow) -- only used in DETACHED mode.
    -- In ATTACHED mode the single clickable button is reparented under the
    -- chat window host so it fades/hides with chat.
    local tlw = CreateTopLevelWindow(ADDON_NAME .. "_ButtonTLW")
    tlw:SetHidden(true)

    -- Thin host under the chat window so the button inherits chat
    -- alpha/fade/hide like a native chat icon.
    local chatHost
    local function SetChatHostAnchorAndDimensions(isVisible)
        if not chatHost then return end
        if isVisible then
            chatHost:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, -CHAT_BUTTON_GAP, 0)
            chatHost:SetDimensions(CHAT_BUTTON_SIZE, CHAT_BUTTON_SIZE)
        else
            chatHost:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, 0, 0)
            chatHost:SetDimensions(0, 0)
        end
    end
    QEM.SetChatHostAnchorAndDimensions = SetChatHostAnchorAndDimensions
    if ZO_ChatWindow then
        chatHost = CreateControl(ADDON_NAME .. "_ChatHost", ZO_ChatWindow, CT_CONTROL)
        QEM.SetChatHostAnchorAndDimensions(false);
        chatHost:SetMouseEnabled(false)
        chatHost:SetHidden(false)
    end
    QEM.chatHost = chatHost

    -- One clickable button for both modes -- only parent/anchor/dimensions change.
    local button = CreateControl(ADDON_NAME .. "_Btn", GuiRoot, CT_BUTTON)
    button:SetMouseEnabled(true)
    button:EnableMouseButton(BTN_RIGHT, true)
    button:SetNormalTexture(TEX.EMOTES)
    button:SetPressedTexture(TEX.EMOTES_DOWN)
    button:SetMouseOverTexture(TEX.EMOTES_OVER)
    button:SetClickSound(SOUND_CLICK)
    button:SetDimensions(0, 0)
    button:SetHidden(true)

    -- Background frame -- lazily created the first time the button is detached.
    local tlwChromeInitialized = false
    local function InitTLWChrome()
        if tlwChromeInitialized then return end
        tlwChromeInitialized = true

        tlw:SetDimensions(TLW_BUTTON_SIZE, TLW_BUTTON_SIZE)
        tlw:SetMouseEnabled(true)
        tlw:SetMovable(false)           -- engine auto-drag is hardwired to LMB, so we
                                        -- drive dragging manually (right mouse only) below
        tlw:SetClampedToScreen(true)
        tlw:SetDrawTier(DT_HIGH)
        tlw:SetDrawLayer(DL_OVERLAY)
        tlw:SetDrawLevel(DRAW_LEVEL_TLW)

        local bg = CreateControl("$(parent)Bg", tlw, CT_BACKDROP)
        bg:SetAnchorFill(tlw)
        bg:SetCenterColor(0.12, 0.12, 0.15, 0.92)
        bg:SetEdgeColor(0.40, 0.55, 0.70, 1)
        bg:SetEdgeTexture(nil, 1, 1, 1.5, 0)
        bg:SetMouseEnabled(false)            -- must be false so TLW receives drag
        bg:SetHidden(false)
    end

    -- Auto-hide free-floating TLW with HUD (map, inventory, etc.).
    -- Only active in DETACHED mode. In ATTACHED mode the fragment must not
    -- be registered or it will re-show the empty TLW when the HUD returns
    -- (e.g. after closing the map).
    local buttonFragment = ZO_SimpleSceneFragment:New(tlw)
    local buttonFragmentAdded = false

    local function SetButtonFragmentEnabled(enabled)
        if enabled and not buttonFragmentAdded then
            SM:GetScene("hud"):AddFragment(buttonFragment)
            SM:GetScene("hudui"):AddFragment(buttonFragment)
            buttonFragmentAdded = true
        elseif not enabled and buttonFragmentAdded then
            SM:GetScene("hud"):RemoveFragment(buttonFragment)
            SM:GetScene("hudui"):RemoveFragment(buttonFragment)
            buttonFragmentAdded = false
            -- Fragment removal can leave the control shown; force hide when attached.
            tlw:SetHidden(true)
        end
    end

    local function ApplyButtonAttachment()
        tlw:ClearAnchors()
        button:ClearAnchors()
        button:SetHidden(false)

        if not QEM.SV.detachButtonFromChat and ZO_ChatWindowOptions and chatHost then

            -- Attached: reparent under chat host. Drop HUD fragment so it
            -- cannot re-show the empty TLW after map/inventory closes.
            SetButtonFragmentEnabled(false)
            tlw:SetHidden(true)

            if ZO_ChatWindowOptions and chatHost then
                QEM.SetChatHostAnchorAndDimensions(true)
                button:SetDimensions(CHAT_BUTTON_SIZE, CHAT_BUTTON_SIZE)
                button:SetParent(chatHost)
                button:SetAnchorFill(chatHost)
            end
        else
            QEM.SetChatHostAnchorAndDimensions(false)
            button:SetDimensions(TLW_BUTTON_SIZE, TLW_BUTTON_SIZE)

            -- Detached: free-floating, draggable button with its own frame.
            InitTLWChrome()
            SetButtonFragmentEnabled(true)
            tlw:SetHidden(false)

            button:SetParent(tlw)
            button:SetAnchorFill(tlw)

            if sv.buttonX and sv.buttonY
                and sv.buttonX > 0 and sv.buttonY > 0
                and sv.buttonX < GuiRoot:GetWidth() - TLW_BUTTON_SIZE
                and sv.buttonY < GuiRoot:GetHeight() - TLW_BUTTON_SIZE then
                tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.buttonX, sv.buttonY)
            else
                tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
                sv.buttonX, sv.buttonY = nil, nil
            end
        end
    end
    QEM.ApplyButtonAttachment = ApplyButtonAttachment
    ApplyButtonAttachment()

    -- Manual right-mouse-button dragging (engine's built-in SetMovable drag
    -- only responds to the left button, so we can't use it for this).
    -- Only ever active in detached mode -- see StartDragging below.
    local DRAG_UPDATE_NAME = ADDON_NAME .. "_ButtonDrag"
    local isDragging = false
    local dragStartMouseX, dragStartMouseY, dragStartLeft, dragStartTop

    local function OnDragUpdate()
        local mx, my = GetUIMousePosition()
        local newLeft = dragStartLeft + (mx - dragStartMouseX)
        local newTop  = dragStartTop  + (my - dragStartMouseY)
        tlw:ClearAnchors()
        tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, newLeft, newTop)
    end

    local function StartDragging()
        if not QEM.SV.detachButtonFromChat then return end -- docked to chat, not movable
        if isDragging then return end -- already dragging?
        isDragging = true
        WM:SetMouseCursor(CURSOR_TYPE.DRAG)
        if QEM.CloseAll then QEM:CloseAll() end
        dragStartMouseX, dragStartMouseY = GetUIMousePosition()
        dragStartLeft, dragStartTop = tlw:GetLeft(), tlw:GetTop()
        EM:RegisterForUpdate(DRAG_UPDATE_NAME, 10, OnDragUpdate)
    end

    local function StopDragging()
        if not isDragging then return end
        isDragging = false
        WM:SetMouseCursor(CURSOR_TYPE.DEFAULT)
        EM:UnregisterForUpdate(DRAG_UPDATE_NAME)
        QEM.SV.buttonX = tlw:GetLeft()
        QEM.SV.buttonY = tlw:GetTop()
    end

    -- Left click = toggle menu, Right mouse drag = move button
    -- (textures are handled automatically by the CT_BUTTON states)
    button:SetHandler("OnMouseDown", function(self, button)
        if button == BTN_RIGHT then
            StartDragging()
        end
    end)

    button:SetHandler("OnMouseUp", function(self, button, upInside)
        if button == BTN_LEFT then
            if upInside then
                QEM:ToggleMainMenu(false)
            end
        elseif button == BTN_RIGHT then
            StopDragging()
        end
    end)

    QEM.button = tlw          -- store the TLW (for show/hide & position when detached)
    QEM.buttonClick = button  -- the actual visible/clickable control in either mode
    QEM.UpdateButtonAttachment = function()
        if QEM.ApplyButtonAttachment then QEM.ApplyButtonAttachment() end
        if QEM.UpdateButtonCursorVisibility then QEM.UpdateButtonCursorVisibility() end
    end

    -- Anchor submenu to button depending on button position. Uses `button`
    -- (not `tlw`) since that's the control that's actually visible and
    -- correctly positioned in both attached and detached mode.
    local function ShouldOpenSubmenusLeft()
        local buttonCenterX = button:GetLeft() + button:GetWidth() / 2
        return buttonCenterX > (GuiRoot:GetWidth() / 2)
    end

    local function AnchorSubmenu(menu, anchorRow)
        menu:ClearAnchors()
        if ShouldOpenSubmenusLeft() then
            -- open to the left of the row
            menu:SetAnchor(RIGHT, anchorRow, LEFT, -SUBMENU_GAP, 0)
        else
            -- open to the right (current behavior)
            menu:SetAnchor(LEFT, anchorRow, RIGHT, SUBMENU_GAP, 0)
        end
    end

    -- Only show the button while the mouse cursor (UI mode) is active,
    -- i.e. hide it again once back in normal gameplay/interaction mode.
    -- Uses alpha/mouse-enable instead of SetHidden so it doesn't fight with the
    -- HUD scene fragment (detached) or the chat window's own fade (attached).
    local function UpdateButtonCursorVisibility()
        local showButton = (not QEM.SV.showOnlyInUIMode) or IsGameCameraUIModeActive()
        if QEM.SV.detachButtonFromChat then
            tlw:SetAlpha(showButton and 1 or 0)
            tlw:SetMouseEnabled(showButton)
        else
            -- button:SetAlpha(showButton and 1 or 0) -- TODO: any use?
        end
        button:SetMouseEnabled(showButton)
    end
    QEM.UpdateButtonCursorVisibility = UpdateButtonCursorVisibility

    EM:RegisterForEvent(ADDON_NAME .. "_CursorVisibility", EVENT_GAME_CAMERA_UI_MODE_CHANGED, UpdateButtonCursorVisibility)
    UpdateButtonCursorVisibility()

    -- Main menu -------------------------------------------------------
    local mainMenu = AcquirePopup(ADDON_NAME .. "_Main", button)
    mainMenu:SetAnchor(BOTTOM, button, TOP, 0, -4)
    QEM.mainMenu = mainMenu

    -- Category submenu ------------------------------------------------
    local catMenu = AcquirePopup(ADDON_NAME .. "_CatMenu", mainMenu.bg)
    QEM.catMenu = catMenu

    -- Emote submenu ---------------------------------------------------
    local emoteMenu = AcquirePopup(ADDON_NAME .. "_EmoteMenu", catMenu.bg)
    QEM.emoteMenu = emoteMenu

    local emoteScroll = CreateControlFromVirtual("$(parent)Scroll", emoteMenu, "ZO_ScrollContainer")
    emoteScroll:SetAnchor(TOPLEFT, emoteMenu, TOPLEFT, 0, 0)
    emoteScroll:SetAnchor(BOTTOMRIGHT, emoteMenu, BOTTOMRIGHT, 0, 0)
    ZO_Scroll_Initialize(emoteScroll)
    emoteMenu.scroll = emoteScroll
    local emoteChild = emoteScroll:GetNamedChild("ScrollChild")
    emoteChild:SetResizeToFitDescendents(false)
    emoteMenu.scrollChild = emoteChild

    -- Favorites submenu ------------------------------------------------
    local favMenu = AcquirePopup(ADDON_NAME .. "_FavMenu", mainMenu.bg)
    QEM.favMenu = favMenu

    local favScroll = CreateControlFromVirtual("$(parent)Scroll", favMenu, "ZO_ScrollContainer")
    favScroll:SetAnchor(TOPLEFT, favMenu, TOPLEFT, 0, 0)
    favScroll:SetAnchor(BOTTOMRIGHT, favMenu, BOTTOMRIGHT, 0, 0)
    ZO_Scroll_Initialize(favScroll)
    favMenu.scroll = favScroll
    local favChild = favScroll:GetNamedChild("ScrollChild")
    favChild:SetResizeToFitDescendents(false)
    favMenu.scrollChild = favChild

    -- Settings submenu (Attach/Detach + open LAM panel) ----------------
    local settingsMenu = AcquirePopup(ADDON_NAME .. "_SettingsMenu", mainMenu.bg)
    QEM.settingsMenu = settingsMenu

    local settingsRows = {}
    local activeEmoteRows = {}
    local activeFavRows = {}
    local seenSlash = {}
    local selectedCategoryRow -- tracks which catMenu row's arrow is currently highlighted

    -- Favorite emote rows now use text color only
    local function SetRowFavState(row, isFav)
        if isFav then
            local c = COLORS.favorite.normal
            row.label:SetColor(c[1], c[2], c[3], c[4])
        else
            StyleLabel(row.label, false)
        end

        row.label:ClearAnchors()
        row.label:SetAnchor(LEFT, row, LEFT, ROW_LEFT_PAD, 0)
        row.label:SetAnchor(RIGHT, row, RIGHT, -ROW_RIGHT_PAD, 0)
    end

    -- Row pool for emotes
    local function AcquireEmoteRow(pool)
        local id = pool:GetNextControlId()
        local row = CreateControl("$(parent)ERow" .. id, emoteChild, CT_BUTTON)
        row:SetMouseEnabled(true)
        row:SetDimensions(ROW_W, ROW_H)
        row:SetHidden(true)

        local label = CreateControl("$(parent)Label", row, CT_LABEL)
        label:SetAnchor(LEFT, row, LEFT, 4, 0)
        label:SetAnchor(RIGHT, row, RIGHT, -4, 0)
        label:SetMaxLineCount(1)
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        label:SetFont(FONT_ROW)
        StyleLabel(label, false)
        row.label = label

        row:SetHandler("OnMouseEnter", function(self)
            if self.data and IsFavorite(self.data.emoteId) then
                local c = COLORS.favorite.hover
                self.label:SetColor(c[1], c[2], c[3], c[4])
            else
                StyleLabel(self.label, true)
            end
        end)

        row:SetHandler("OnMouseExit", function(self)
            if self.data and IsFavorite(self.data.emoteId) then
                local c = COLORS.favorite.normal
                self.label:SetColor(c[1], c[2], c[3], c[4])
            else
                StyleLabel(self.label, false)
            end
        end)

        row:SetHandler("OnMouseUp", function(self, btn, upInside)
            if not upInside or not self.data or not self.data.emoteIndex then return end
            if btn == BTN_LEFT then
                PlayEmoteByIndex(self.data.emoteIndex)
                if QEM.SV.closeOnPlay then
                    QEM:CloseAll()
                    LeaveUIMode()
                end
            elseif btn == BTN_RIGHT then
                ToggleFavorite(self.data.emoteId)
                local isFav = IsFavorite(self.data.emoteId)
                local slash = self.data.emoteSlashName or ""
                local name  = self.data.displayName or STRINGS.UNKNOWN_NAME
                self.label:SetText(strformat("%s :: %s", name, slash))
                SetRowFavState(self, isFav)
                QEM:RefreshMainMenu(true)
                if not favMenu:IsHidden() and mainMenu.selectedFavRow then
                    QEM.ShowFavorites(mainMenu.selectedFavRow)
                end
            end
        end)
        return row
    end

    local function ResetEmoteRow(c)
        c:SetHidden(true)
        c:ClearAnchors()
        c.data = nil
    end

    emoteMenu.rowPool = ZO_ObjectPool:New(AcquireEmoteRow, ResetEmoteRow)

    -- Row pool for favorites submenu (play / unfavorite)
    local function AcquireFavListRow(pool)
        local id = pool:GetNextControlId()
        local row = CreateControl("$(parent)FRow" .. id, favChild, CT_BUTTON)
        row:SetMouseEnabled(true)
        row:SetDimensions(ROW_W, ROW_H)
        row:SetHidden(true)

        local label = CreateControl("$(parent)Label", row, CT_LABEL)
        label:SetAnchor(LEFT, row, LEFT, ROW_LEFT_PAD, 0)
        label:SetAnchor(RIGHT, row, RIGHT, -ROW_RIGHT_PAD, 0)
        label:SetMaxLineCount(1)
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        label:SetFont(FONT_ROW)
        StyleLabel(label, false)
        row.label = label

        row:SetHandler("OnMouseEnter", function(self) StyleLabel(self.label, true) end)

        row:SetHandler("OnMouseExit",  function(self) StyleLabel(self.label, false) end)

        row:SetHandler("OnMouseUp", function(self, btn, upInside)
            if not upInside or not self.data then return end
            if btn == BTN_LEFT and self.data.emoteIndex then
                PlayEmoteByIndex(self.data.emoteIndex)
                if QEM.SV.closeOnPlay then
                    QEM:CloseAll()
                    LeaveUIMode()
                end
            elseif btn == BTN_RIGHT and self.data.emoteId then
                ToggleFavorite(self.data.emoteId)
                if mainMenu.selectedFavRow then
                    QEM.ShowFavorites(mainMenu.selectedFavRow)
                end
            end
        end)
        return row
    end

    local function ResetFavListRow(c)
        c:SetHidden(true)
        c:ClearAnchors()
        c.data = nil
    end

    favMenu.rowPool = ZO_ObjectPool:New(AcquireFavListRow, ResetFavListRow)

    -- Helpers to show/hide submenus -----------------------------------
    local function HideEmoteMenu()
        emoteMenu:SetHidden(true)
        emoteMenu.rowPool:ReleaseAllObjects()
        ZO_ClearTable(activeEmoteRows)
        if selectedCategoryRow and selectedCategoryRow.arrow then
            selectedCategoryRow.arrow:SetAlpha(ALPHA_OFF)
        end
        selectedCategoryRow = nil
    end

    local function HideFavMenu()
        favMenu:SetHidden(true)
        favMenu.rowPool:ReleaseAllObjects()
        ZO_ClearTable(activeFavRows)
        if mainMenu.selectedFavRow and mainMenu.selectedFavRow.arrow then
            mainMenu.selectedFavRow.arrow:SetAlpha(ALPHA_OFF)
        end
        mainMenu.selectedFavRow = nil
    end

    local function HideSettingsMenu()
        settingsMenu:SetHidden(true)
        if mainMenu.selectedSettingsRow and mainMenu.selectedSettingsRow.arrow then
            mainMenu.selectedSettingsRow.arrow:SetAlpha(ALPHA_OFF)
        end
        mainMenu.selectedSettingsRow = nil
    end

    local function HideCatMenu()
        catMenu:SetHidden(true)
        HideEmoteMenu()
        if mainMenu.selectedCatRow and mainMenu.selectedCatRow.arrow then
            mainMenu.selectedCatRow.arrow:SetAlpha(ALPHA_OFF)
        end
        mainMenu.selectedCatRow = nil
    end

    function QEM.ShowFavorites(anchorRow)
        HideCatMenu()
        HideSettingsMenu()
        AnchorSubmenu(favMenu, anchorRow)
        favMenu.rowPool:ReleaseAllObjects()
        ZO_ClearTable(activeFavRows)

        local favs = QEM.SV.favorites
        local favTemp = {}
        for i = #favs, 1, -1 do
            local emoteId = favs[i]
            local info = PEM:GetEmoteItemInfo(emoteId)
            if info and info.emoteIndex then
                tinsert(favTemp, info)
            else
                tremove(favs, i)
            end
        end
        tsort(favTemp, function(a, b)
            local na = a.displayName or a.emoteSlashName or ""
            local nb = b.displayName or b.emoteSlashName or ""
            return na < nb
        end)

        local maxW = 0
        local count = 0

        if #favTemp == 0 then
            local row = favMenu.rowPool:AcquireObject()
            row.data = nil
            row.label:SetText(STRINGS.NO_FAVORITES)
            row:SetHandler("OnMouseUp", function() end)
            measure:SetText(STRINGS.NO_FAVORITES)
            maxW = mmax(maxW, measure:GetTextWidth() + ROW_LEFT_PAD + ROW_RIGHT_PAD_EMOTES)
            count = 1
            activeFavRows[1] = row
        else
            for _, info in ipairs(favTemp) do
                local row = favMenu.rowPool:AcquireObject()
                row.data = info
                local slash = info.emoteSlashName or ""
                local name  = info.displayName or STRINGS.UNKNOWN_NAME
                local text  = strformat("%s :: %s", name, slash)
                row.label:SetText(text)

                row:SetHandler("OnMouseUp", function(self, btn, upInside)
                    if not upInside or not self.data then return end
                    if btn == BTN_LEFT and self.data.emoteIndex then
                        PlayEmoteByIndex(self.data.emoteIndex)
                        if QEM.SV.closeOnPlay then
                            QEM:CloseAll()
                            LeaveUIMode()
                        end
                    elseif btn == BTN_RIGHT and self.data.emoteId then
                        ToggleFavorite(self.data.emoteId)
                        if mainMenu.selectedFavRow then
                            QEM.ShowFavorites(mainMenu.selectedFavRow)
                        end
                    end
                end)
                measure:SetText(text)
                maxW = mmax(maxW, measure:GetTextWidth() + ROW_LEFT_PAD + ROW_RIGHT_PAD_EMOTES)
                count = count + 1
                activeFavRows[count] = row
            end
        end

        local finalW = mmax(maxW, ROW_W)
        favMenu:SetWidth(finalW)
        favScroll:SetWidth(finalW)
        favChild:SetWidth(finalW)

        for i = 1, count do
            local row = activeFavRows[i]
            row:ClearAnchors()
            row:SetDimensions(finalW, ROW_H)
            row:SetHidden(false)
            if i == 1 then
                row:SetAnchor(TOPLEFT, favChild, TOPLEFT, 0, 0)
            else
                row:SetAnchor(TOPLEFT, activeFavRows[i - 1], BOTTOMLEFT, 0, 0)
            end
        end

        local contentH = mmax(count * ROW_H, 1)
        local visH     = mmin(mmax(count, 1), MAX_VISIBLE_ROWS) * ROW_H
        favChild:SetHeight(contentH)
        favScroll:SetHeight(visH)
        favMenu:SetHeight(visH)

        if ZO_Scroll_UpdateScrollBar then ZO_Scroll_UpdateScrollBar(favScroll) end
        if ZO_Scroll_ResetToTop then ZO_Scroll_ResetToTop(favScroll) end

        favMenu:SetHidden(false)
        PlaySound(SOUND_OPEN)
    end

    local function ShowEmotesForCategory(category, anchorRow)
        HideFavMenu()
        HideSettingsMenu()
        HideEmoteMenu()
        selectedCategoryRow = anchorRow
        if anchorRow.arrow then anchorRow.arrow:SetAlpha(ALPHA_ON) end
        AnchorSubmenu(emoteMenu, anchorRow)

        local emoteIds = PEM:GetEmoteListForType(category)
        ZO_ClearTable(seenSlash)
        local temp = {}
        local maxW = 0

        if emoteIds then
            for _, emoteId in ipairs(emoteIds) do
                local info = PEM:GetEmoteItemInfo(emoteId) 
                if info and info.emoteIndex then
                    local slash = info.emoteSlashName or ""
                    if slash ~= "" and not seenSlash[slash] then
                        seenSlash[slash] = true
                        tinsert(temp, info)
                    end
                end
            end
            tsort(temp, function(a, b)
                local na = a.displayName or a.emoteSlashName or ""
                local nb = b.displayName or b.emoteSlashName or ""
                return na < nb
            end)
        end

        local count = 0
        for _, info in ipairs(temp) do
            local row = emoteMenu.rowPool:AcquireObject()
            row.data = info
            local slash = info.emoteSlashName or ""
            local name  = info.displayName or STRINGS.UNKNOWN_NAME
            local isFav = IsFavorite(info.emoteId)
            local text  = strformat("%s :: %s", name, slash)
            row.label:SetText(text)
            SetRowFavState(row, isFav)
            measure:SetText(text)
            -- Favorite state is visual only; it never changes row/menu width.
            maxW = mmax(maxW, measure:GetTextWidth() + ROW_LEFT_PAD + ROW_RIGHT_PAD_EMOTES)
            count = count + 1
            activeEmoteRows[count] = row
        end

        local finalW = mmax(maxW, ROW_W)
        emoteMenu:SetWidth(finalW)
        emoteScroll:SetWidth(finalW)
        emoteChild:SetWidth(finalW)

        for i = 1, count do
            local row = activeEmoteRows[i]
            row:ClearAnchors()
            row:SetDimensions(finalW, ROW_H)
            row:SetHidden(false)
            if i == 1 then
                row:SetAnchor(TOPLEFT, emoteChild, TOPLEFT, 0, 0)
            else
                row:SetAnchor(TOPLEFT, activeEmoteRows[i-1], BOTTOMLEFT, 0, 0)
            end
        end

        local contentH = mmax(count * ROW_H, 1)
        local visH     = mmin(mmax(count, 1), MAX_VISIBLE_ROWS) * ROW_H
        emoteChild:SetHeight(contentH)
        emoteScroll:SetHeight(visH)
        emoteMenu:SetHeight(visH)

        if ZO_Scroll_UpdateScrollBar then ZO_Scroll_UpdateScrollBar(emoteScroll) end
        if ZO_Scroll_ResetToTop then ZO_Scroll_ResetToTop(emoteScroll) end

        emoteMenu:SetHidden(false)
        PlaySound(SOUND_OPEN)
    end

    -- Build category list once ----------------------------------------
    local catRows = {}
    local categories = PEM:GetEmoteCategories()
    local lastCat

    for _, category in ipairs(categories) do
        if category and category ~= EMOTE_CATEGORY_INVALID and category ~= EMOTE_CATEGORY_DEPRECATED then
            local row = CreateControl("$(parent)Cat" .. tostring(category), catMenu, CT_BUTTON)
            row:SetMouseEnabled(true)
            row:SetDimensions(ROW_W, ROW_H)

            local arrow = CreateControl("$(parent)Arrow", row, CT_TEXTURE)
            arrow:SetTexture(TEX.ARROW)
            arrow:SetAnchor(RIGHT, row, RIGHT, 0, 0)
            arrow:SetDimensions(ROW_H * TEXTURE_ARROW_SCALE, ROW_H)
            arrow:SetTextureCoords(0, TEXTURE_ARROW_SCALE, 0, 1)
            arrow:SetAlpha(ALPHA_OFF)
            row.arrow = arrow

            local label = CreateControl("$(parent)Label", row, CT_LABEL)
            label:SetAnchor(LEFT, row, LEFT, 4, 0)
            label:SetAnchor(RIGHT, arrow, LEFT, -2, 0)
            label:SetMaxLineCount(1)
            label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
            label:SetFont(FONT_ROW)
            StyleLabel(label, false)
            label:SetText(GetString("SI_EMOTECATEGORY", category))
            row.label = label
            row.category = category

            row:SetHandler("OnMouseEnter", function(self)
                StyleLabel(self.label, true)
                if QEM.SV.submenuDelay > 0 then
                    local name = "qem_cat_" .. category
                    EM:RegisterForUpdate(name, QEM.SV.submenuDelay, function()
                        EM:UnregisterForUpdate(name)
                        if MIO(self) then
                            ShowEmotesForCategory(self.category, self)
                        end
                    end)
                end
            end)
            row:SetHandler("OnMouseExit", function(self)
                StyleLabel(self.label, false)
                EM:UnregisterForUpdate("qem_cat_" .. category)
            end)
            row:SetHandler("OnMouseUp", function(self, btn, upInside)
                if btn == BTN_LEFT and upInside then
                    ShowEmotesForCategory(self.category, self)
                end
            end)

            if not lastCat then
                row:SetAnchor(TOPLEFT, catMenu, TOPLEFT, 0, 0)
            else
                row:SetAnchor(TOPLEFT, lastCat, BOTTOMLEFT, 0, 0)
            end
            lastCat = row
            tinsert(catRows, row)
        end
    end

    -- size category menu
    do
        local maxW = ROW_W
        for _, r in ipairs(catRows) do
            measure:SetText(r.label:GetText())
            maxW = mmax(maxW, measure:GetTextWidth() + ROW_H * TEXTURE_ARROW_SCALE + 16)
        end
        for _, r in ipairs(catRows) do r:SetWidth(maxW) end
        catMenu:SetWidth(maxW)
        catMenu:SetHeight(#catRows * ROW_H)
    end

    -- Main menu content (Categories header + Favorites) ---------------
    local mainRows = {}  -- reusable

    local function ClearMainRows()
        for _, r in ipairs(mainRows) do
            r:SetHidden(true)
            r:ClearAnchors()
        end
        ZO_ClearTable(mainRows)
    end

    local function AcquireMainRow()
        local idx = #mainRows + 1
        local row = mainMenu["row" .. idx]
        if not row then
            row = CreateControl("$(parent)MRow" .. idx, mainMenu, CT_BUTTON)
            row:SetMouseEnabled(true)
            row:SetDimensions(ROW_W, ROW_H)

            local arrow = CreateControl("$(parent)Arrow", row, CT_TEXTURE)
            arrow:SetTexture(TEX.ARROW)
            arrow:SetAnchor(RIGHT, row, RIGHT, 0, 0)
            arrow:SetDimensions(ROW_H * TEXTURE_ARROW_SCALE, ROW_H)
            arrow:SetTextureCoords(0, TEXTURE_ARROW_SCALE, 0, 1)
            arrow:SetAlpha(ALPHA_OFF)
            row.arrow = arrow

            local label = CreateControl("$(parent)Label", row, CT_LABEL)
            label:SetAnchor(LEFT, row, LEFT, 4, 0)
            label:SetAnchor(RIGHT, arrow, LEFT, -2, 0)
            label:SetMaxLineCount(1)
            label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
            label:SetFont(FONT_ROW)
            StyleLabel(label, false)
            row.label = label

            row:SetHandler("OnMouseEnter", function(self) StyleLabel(self.label, true) end)
            row:SetHandler("OnMouseExit",  function(self) StyleLabel(self.label, false) end)
            mainMenu["row" .. idx] = row
        end
        mainRows[idx] = row
        return row
    end

    local function OpenCategoriesMenu(row)
        HideFavMenu()
        HideSettingsMenu()
        AnchorSubmenu(catMenu, row)
        catMenu:SetHidden(false)
        row.arrow:SetAlpha(ALPHA_ON)
        mainMenu.selectedCatRow = row
        PlaySound(SOUND_OPEN)
    end

    local function OpenFavoritesMenu(row)
        HideCatMenu()
        HideSettingsMenu()
        mainMenu.selectedFavRow = row
        row.arrow:SetAlpha(ALPHA_ON)
        QEM.ShowFavorites(row)
    end

    local function BuildSettingsMenu()
        -- Rebuild fixed rows so Attach/Detach label matches current state
        for _, r in ipairs(settingsRows) do
            r:SetHidden(true)
            r:ClearAnchors()
        end
        ZO_ClearTable(settingsRows)

        local function AcquireSettingsRow()
            local idx = #settingsRows + 1
            local row = settingsMenu["srow" .. idx]
            if not row then
                row = CreateControl("$(parent)SRow" .. idx, settingsMenu, CT_BUTTON)
                row:SetMouseEnabled(true)
                row:SetDimensions(ROW_W, ROW_H)
                local label = CreateControl("$(parent)Label", row, CT_LABEL)
                label:SetAnchor(LEFT, row, LEFT, ROW_LEFT_PAD, 0)
                label:SetAnchor(RIGHT, row, RIGHT, -ROW_RIGHT_PAD, 0)
                label:SetMaxLineCount(1)
                label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                label:SetFont(FONT_ROW)
                StyleLabel(label, false)
                row.label = label
                row:SetHandler("OnMouseEnter", function(self) StyleLabel(self.label, true) end)
                row:SetHandler("OnMouseExit",  function(self) StyleLabel(self.label, false) end)
                settingsMenu["srow" .. idx] = row
            end
            settingsRows[idx] = row
            return row
        end

        local maxW = ROW_W
        local count = 0

        -- 1. Show Settings Panel (only if LibAddonMenu2 is available)
        if LibAddonMenu2 then
            local row = AcquireSettingsRow()
            count = count + 1
            row.label:SetText(STRINGS.SHOW_SETTINGS_PANEL)
            row:SetHandler("OnMouseUp", function(self, btn, upInside)
                if btn == BTN_LEFT and upInside then
                    QEM:CloseAll()
                    -- QEM.OpenSettingsPanel() -- This doesn't work! use the slash command
                    SLASH_COMMANDS[SLASH_COMMAND_PANEL]()
                end
            end)
            measure:SetText(STRINGS.SHOW_SETTINGS_PANEL)
            maxW = mmax(maxW, measure:GetTextWidth() + ROW_LEFT_PAD + ROW_RIGHT_PAD + 8)
        end

        -- 2. Attach / Detach Button
        do
            local row = AcquireSettingsRow()
            count = count + 1
            local text = QEM.SV.detachButtonFromChat and STRINGS.ATTACH_BUTTON or STRINGS.DETACH_BUTTON
            row.label:SetText(text)
            row:SetHandler("OnMouseUp", function(self, btn, upInside)
                if btn == BTN_LEFT and upInside then
                    QEM.ToggleDetachFromChat()
                    -- Rebuild so the Attach/Detach label reflects the new state
                    if mainMenu.selectedSettingsRow then
                        BuildSettingsMenu()
                    end
                end
            end)
            measure:SetText(text)
            maxW = mmax(maxW, measure:GetTextWidth() + ROW_LEFT_PAD + ROW_RIGHT_PAD + 8)
        end

        local finalW = mmax(maxW, ROW_W)
        for i = 1, count do
            local row = settingsRows[i]
            row:ClearAnchors()
            row:SetDimensions(finalW, ROW_H)
            row:SetHidden(false)
            if i == 1 then
                row:SetAnchor(TOPLEFT, settingsMenu, TOPLEFT, 0, 0)
            else
                row:SetAnchor(TOPLEFT, settingsRows[i - 1], BOTTOMLEFT, 0, 0)
            end
        end
        settingsMenu:SetWidth(finalW)
        settingsMenu:SetHeight(mmax(count, 1) * ROW_H)
    end

    local function OpenSettingsMenu(row)
        HideCatMenu()
        HideFavMenu()
        BuildSettingsMenu()
        AnchorSubmenu(settingsMenu, row)
        settingsMenu:SetHidden(false)
        row.arrow:SetAlpha(ALPHA_ON)
        mainMenu.selectedSettingsRow = row
        PlaySound(SOUND_OPEN)
    end

    function QEM:RefreshMainMenu(keepSubmenuOpen)
        local keepCatSelected = keepSubmenuOpen and mainMenu.selectedCatRow ~= nil
        local keepFavSelected = keepSubmenuOpen and mainMenu.selectedFavRow ~= nil
        local keepSettingsSelected = keepSubmenuOpen and mainMenu.selectedSettingsRow ~= nil

        ClearMainRows()
        if not keepSubmenuOpen then
            HideCatMenu()
            HideFavMenu()
            HideSettingsMenu()
        end

        local maxW = ROW_W
        local count = 0

        -- Categories (same look as category list rows)
        do
            local row = AcquireMainRow()
            count = count + 1
            row.label:SetText(STRINGS.CATEGORIES)
            -- row.arrow:SetHidden(false)
            row.arrow:SetAlpha(keepCatSelected and ALPHA_ON or ALPHA_OFF)
            row.data = nil
            if keepCatSelected then
                mainMenu.selectedCatRow = row
            end

            row:SetHandler("OnMouseUp", function(self, btn, upInside)
                if btn == BTN_LEFT and upInside then
                    OpenCategoriesMenu(self)
                end
            end)
            row:SetHandler("OnMouseEnter", function(self)
                StyleLabel(self.label, true)
                if QEM.SV.submenuDelay > 0 then
                    EM:RegisterForUpdate("qem_main_cat", QEM.SV.submenuDelay, function()
                        EM:UnregisterForUpdate("qem_main_cat")
                        if MIO(self) then
                            OpenCategoriesMenu(self)
                        end
                    end)
                end
            end)
            row:SetHandler("OnMouseExit", function(self)
                StyleLabel(self.label, false)
                EM:UnregisterForUpdate("qem_main_cat")
            end)

            measure:SetText(STRINGS.CATEGORIES)
            maxW = mmax(maxW, measure:GetTextWidth() + ROW_H * TEXTURE_ARROW_SCALE + 16)
        end

        -- Favorites (same look as category list rows)
        do
            local row = AcquireMainRow()
            count = count + 1
            row.label:SetText(STRINGS.FAVORITES)
            -- row.arrow:SetHidden(false)
            row.arrow:SetAlpha(keepFavSelected and ALPHA_ON or ALPHA_OFF)
            row.data = nil
            if keepFavSelected then
                mainMenu.selectedFavRow = row
            end

            row:SetHandler("OnMouseUp", function(self, btn, upInside)
                if btn == BTN_LEFT and upInside then
                    OpenFavoritesMenu(self)
                end
            end)
            row:SetHandler("OnMouseEnter", function(self)
                StyleLabel(self.label, true)
                if QEM.SV.submenuDelay > 0 then
                    EM:RegisterForUpdate("qem_main_fav", QEM.SV.submenuDelay, function()
                        EM:UnregisterForUpdate("qem_main_fav")
                        if MIO(self) then
                            OpenFavoritesMenu(self)
                        end
                    end)
                end
            end)
            row:SetHandler("OnMouseExit", function(self)
                StyleLabel(self.label, false)
                EM:UnregisterForUpdate("qem_main_fav")
            end)

            measure:SetText(STRINGS.FAVORITES)
            maxW = mmax(maxW, measure:GetTextWidth() + ROW_H * TEXTURE_ARROW_SCALE + 16)
        end

        -- Settings (same look; optional via hideSettingsMenu)
        if not hideSettingsMenu then
            local row = AcquireMainRow()
            count = count + 1
            row.label:SetText(STRINGS.SETTINGS)
            row.arrow:SetAlpha(keepSettingsSelected and ALPHA_ON or ALPHA_OFF)
            row.data = nil
            if keepSettingsSelected then
                mainMenu.selectedSettingsRow = row
            end

            row:SetHandler("OnMouseUp", function(self, btn, upInside)
                if btn == BTN_LEFT and upInside then
                    OpenSettingsMenu(self)
                end
            end)
            row:SetHandler("OnMouseEnter", function(self)
                StyleLabel(self.label, true)
                if QEM.SV.submenuDelay > 0 then
                    EM:RegisterForUpdate("qem_main_settings", QEM.SV.submenuDelay, function()
                        EM:UnregisterForUpdate("qem_main_settings")
                        if MIO(self) then
                            OpenSettingsMenu(self)
                        end
                    end)
                end
            end)
            row:SetHandler("OnMouseExit", function(self)
                StyleLabel(self.label, false)
                EM:UnregisterForUpdate("qem_main_settings")
            end)

            measure:SetText(STRINGS.SETTINGS)
            maxW = mmax(maxW, measure:GetTextWidth() + ROW_H * TEXTURE_ARROW_SCALE + 16)
        end

        local finalW = mmax(maxW, ROW_W)

        for i = 1, count do
            local row = mainRows[i]
            row:ClearAnchors()
            row:SetDimensions(finalW, ROW_H)
            row:SetHidden(false)
            if i == 1 then
                row:SetAnchor(TOPLEFT, mainMenu, TOPLEFT, 0, 0)
            else
                row:SetAnchor(TOPLEFT, mainRows[i - 1], BOTTOMLEFT, 0, 0)
            end
        end

        mainMenu:SetWidth(finalW)
        mainMenu:SetHeight(count * ROW_H)
    end

    function QEM:CloseAll()
        mainMenu:SetHidden(true)
        HideCatMenu()
        HideFavMenu()
        HideSettingsMenu()
    end

    -- Anchor main menu to button depending on button position. Uses `button`
    -- (not `tlw`) since that's the control that's actually visible and
    -- correctly positioned in both attached and detached mode.
    local function AnchorMainMenuToButton()
        mainMenu:ClearAnchors()
        local buttonCenterY = button:GetTop() + button:GetHeight() / 2
        local screenCenterY = GuiRoot:GetHeight() / 2

        if buttonCenterY < screenCenterY then
            -- Button in upper half → open menu below it
            mainMenu:SetAnchor(TOP, button, BOTTOM, 0, 4)
        else
            -- Button in lower half → open menu above it
            mainMenu:SetAnchor(BOTTOM, button, TOP, 0, -4)
        end
    end

    function QEM:ToggleMainMenu(leaveUIModeOnClose)
        if mainMenu:IsHidden() then
            if self.HideFavoritesWindow then self:HideFavoritesWindow(false) end
            self:RefreshMainMenu()
            AnchorMainMenuToButton()
            mainMenu:SetHidden(false)
            SM:SetInUIMode(true)
            PlaySound(SOUND_OPEN)
        else
            self:CloseAll()
            if leaveUIModeOnClose then
                LeaveUIMode()
            end
        end
    end

    -- Close when clicking outside
    mainMenu:SetHandler("OnShow", function(self)
        self:RegisterForEvent(EVENT_GLOBAL_MOUSE_UP, function()
            if MIO(self) or MIO(button) or MIO(catMenu) or MIO(emoteMenu) or MIO(favMenu) or MIO(settingsMenu) then return end
            QEM:CloseAll()
        end)
        self:RegisterForEvent(EVENT_ACTION_LAYER_POPPED, function()
            if not self:IsHidden() then QEM:CloseAll() end
        end)
        -- More reliable than EVENT_ACTION_LAYER_POPPED: fires directly off the
        -- camera's UI-mode/cursor state, so it closes the menu consistently
        -- whether it was opened by clicking the button or via the keybind.
        self:RegisterForEvent(EVENT_GAME_CAMERA_UI_MODE_CHANGED, function()
            if not self:IsHidden() and not IsGameCameraUIModeActive() then
                QEM:CloseAll()
                LeaveUIMode()
            end
        end)
    end)
    mainMenu:SetHandler("OnHide", function(self)
        self:UnregisterForEvent(EVENT_GLOBAL_MOUSE_UP)
        self:UnregisterForEvent(EVENT_ACTION_LAYER_POPPED)
        self:UnregisterForEvent(EVENT_GAME_CAMERA_UI_MODE_CHANGED)
        HideCatMenu()
        HideFavMenu()
        HideSettingsMenu()
    end)

    ----------------------------------------------------------------------
    -- Standalone Favorites Window
    -- Opened only via its own keybind (QEM_ToggleFavoritesWindow). Shows the
    -- current favorites list, is scrollable, movable by its header, and is
    -- read-only (no right-click removal here — manage favorites from the
    -- main button's menu instead).
    --
    -- Layout matches the fav submenu: explicit width/height, no padding
    -- inset that fights scroll anchors, same backdrop style as AcquirePopup.
    ----------------------------------------------------------------------
    local FAV_WIN_HEADER_MARGIN = 5 -- extra space between header and content
    local FAV_WIN_HEADER_H = ROW_H + FAV_WIN_HEADER_MARGIN

    local favWindow = CreateTopLevelWindow(ADDON_NAME .. "_FavWindow")
    favWindow:SetMouseEnabled(true)
    favWindow:SetMovable(true) -- required for StartMoving()/StopMovingOrResizing()
    favWindow:SetClampedToScreen(true)
    favWindow:SetDrawTier(DT_HIGH)
    favWindow:SetDrawLayer(DL_OVERLAY)
    favWindow:SetDrawLevel(DRAW_LEVEL_FAV)
    favWindow:SetHidden(true)
    favWindow:SetInheritAlpha(false)
    favWindow:SetDimensions(ROW_W, FAV_WIN_HEADER_H + ROW_H)

    -- Same backdrop style as AcquirePopup / fav submenu
    local favWinBg = CreateControl("$(parent)Bg", favWindow, CT_BACKDROP)
    favWinBg:SetAnchor(TOPLEFT, favWindow, TOPLEFT, -5, -5)
    favWinBg:SetAnchor(BOTTOMRIGHT, favWindow, BOTTOMRIGHT, 5, 5)
    favWinBg:SetCenterColor(12/255, 12/255, 12/255, BG_ALPHA)
    favWinBg:SetEdgeTexture(nil, 1, 1, 1, 0)
    favWinBg:SetEdgeColor(70/255, 70/255, 70/255, BORDER_ALPHA) -- TODO: transparent
    favWinBg:SetInsets(-1, -1, 1, 1)
    favWinBg:SetExcludeFromResizeToFitExtents(true)
    favWinBg:SetMouseEnabled(false)

    -- Header: full-width drag handle + centered title
    local favWinHeader = CreateControl("$(parent)Header", favWindow, CT_CONTROL)
    favWinHeader:SetAnchor(TOPLEFT, favWindow, TOPLEFT, 0, 0)
    favWinHeader:SetAnchor(TOPRIGHT, favWindow, TOPRIGHT, 0, 0)
    favWinHeader:SetHeight(FAV_WIN_HEADER_H - FAV_WIN_HEADER_MARGIN)
    favWinHeader:SetMouseEnabled(true)

    local favWinHeaderBg = CreateControl("$(parent)Bg", favWinHeader, CT_BACKDROP)
    favWinHeaderBg:SetAnchorFill(favWinHeader)
    favWinHeaderBg:SetCenterColor(12/255, 12/255, 12/255, 0.35)
    favWinHeaderBg:SetEdgeTexture(nil, 1, 1, 0, 0)
    favWinHeaderBg:SetEdgeColor(70 / 255, 70 / 255, 70 / 255, BORDER_ALPHA) -- TODO: transparent
    favWinHeaderBg:SetMouseEnabled(false)

    local favWinTitle = CreateControl("$(parent)Title", favWinHeader, CT_LABEL)
    favWinTitle:SetAnchor(LEFT, favWinHeader, LEFT, ROW_LEFT_PAD, 0)
    favWinTitle:SetAnchor(RIGHT, favWinHeader, RIGHT, -ROW_LEFT_PAD, 0)
    favWinTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    favWinTitle:SetMaxLineCount(1)
    favWinTitle:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    favWinTitle:SetFont(FONT_HEADER)
    favWinTitle:SetText(STRINGS.FAVORITES)
    StyleLabel(favWinTitle, false)
    favWinTitle:SetMouseEnabled(false)

    -- Drag only via the header so row clicks never move the window
    favWinHeader:SetHandler("OnMouseEnter", function()
        WM:SetMouseCursor(CURSOR_TYPE.DRAG)
    end)
    favWinHeader:SetHandler("OnMouseExit", function()
        WM:SetMouseCursor(CURSOR_TYPE.DEFAULT)
    end)
    favWinHeader:SetHandler("OnMouseDown", function(_, btn)
        if btn == BTN_LEFT or btn == BTN_RIGHT then
            favWindow:StartMoving()
        end
    end)
    favWinHeader:SetHandler("OnMouseUp", function(_, btn)
        if btn == BTN_LEFT or btn == BTN_RIGHT then
            favWindow:StopMovingOrResizing()
            QEM.SV.favWindowX = favWindow:GetLeft()
            QEM.SV.favWindowY = favWindow:GetTop()
        end
    end)

    -- Scrollable body — same pattern as favMenu / emoteMenu
    local favWinScroll = CreateControlFromVirtual("$(parent)Scroll", favWindow, "ZO_ScrollContainer")
    favWinScroll:SetAnchor(TOPLEFT, favWindow, TOPLEFT, 0, FAV_WIN_HEADER_H)
    favWinScroll:SetAnchor(BOTTOMRIGHT, favWindow, BOTTOMRIGHT, 0, 0)
    ZO_Scroll_Initialize(favWinScroll)
    local favWinChild = favWinScroll:GetNamedChild("ScrollChild")
    favWinChild:SetResizeToFitDescendents(false)

    local activeFavWinRows = {}

    local function AcquireFavWindowRow(pool)
        local id = pool:GetNextControlId()
        local row = CreateControl("$(parent)WRow" .. id, favWinChild, CT_BUTTON)
        row:SetMouseEnabled(true)
        row:SetDimensions(ROW_W, ROW_H)
        row:SetHidden(true)

        local label = CreateControl("$(parent)Label", row, CT_LABEL)
        label:SetAnchor(LEFT, row, LEFT, ROW_LEFT_PAD, 0)
        label:SetAnchor(RIGHT, row, RIGHT, -ROW_RIGHT_PAD, 0)
        label:SetMaxLineCount(1)
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        label:SetFont(FONT_ROW)
        StyleLabel(label, false)
        row.label = label

        row:SetHandler("OnMouseEnter", function(self) StyleLabel(self.label, true) end)
        row:SetHandler("OnMouseExit",  function(self) StyleLabel(self.label, false) end)

        -- Play only; no right-click unfavorite (manage favorites from main menu)
        row:SetHandler("OnMouseUp", function(self, btn, upInside)
            if not upInside or not self.data or not self.data.emoteIndex then return end
            if btn == BTN_LEFT then
                PlayEmoteByIndex(self.data.emoteIndex)
                if QEM.SV.closeOnPlay then
                    QEM:HideFavoritesWindow(true)
                end
            end
        end)
        return row
    end

    local function ResetFavWindowRow(c)
        c:SetHidden(true)
        c:ClearAnchors()
        c.data = nil
    end

    favWindow.rowPool = ZO_ObjectPool:New(AcquireFavWindowRow, ResetFavWindowRow)

    function QEM:RefreshFavoritesWindow()
        favWindow.rowPool:ReleaseAllObjects()
        ZO_ClearTable(activeFavWinRows)

        local favs = QEM.SV.favorites
        local favTemp = {}
        for i = #favs, 1, -1 do
            local emoteId = favs[i]
            local info = PEM:GetEmoteItemInfo(emoteId)
            if info and info.emoteIndex then
                tinsert(favTemp, info)
            else
                tremove(favs, i)
            end
        end
        tsort(favTemp, function(a, b)
            local na = a.displayName or a.emoteSlashName or ""
            local nb = b.displayName or b.emoteSlashName or ""
            return na < nb
        end)

        local maxW = 0
        local count = 0

        if #favTemp == 0 then
            local row = favWindow.rowPool:AcquireObject()
            row.data = nil
            row.label:SetText(STRINGS.NO_FAVORITES)
            measure:SetText(STRINGS.NO_FAVORITES)
            maxW = mmax(maxW, measure:GetTextWidth() + ROW_LEFT_PAD + ROW_RIGHT_PAD_EMOTES)
            count = 1
            activeFavWinRows[1] = row
        else
            for _, info in ipairs(favTemp) do
                local row = favWindow.rowPool:AcquireObject()
                row.data = info
                local slash = info.emoteSlashName or ""
                local name  = info.displayName or STRINGS.UNKNOWN_NAME
                local text  = strformat("%s :: %s", name, slash)
                row.label:SetText(text)
                measure:SetText(text)
                maxW = mmax(maxW, measure:GetTextWidth() + ROW_LEFT_PAD + ROW_RIGHT_PAD_EMOTES)
                count = count + 1
                activeFavWinRows[count] = row
            end
        end

        -- Never shrink below the centered title width
        measure:SetText(STRINGS.FAVORITES)
        local headerMinW = measure:GetTextWidth() + ROW_LEFT_PAD * 2
        local finalW = mmax(maxW, headerMinW, ROW_W)

        local contentH = mmax(count * ROW_H, 1)
        local visH     = mmin(mmax(count, 1), MAX_VISIBLE_ROWS) * ROW_H

        -- Size window first, then children (same order as fav/emote submenus)
        favWindow:SetDimensions(finalW, visH + FAV_WIN_HEADER_H)
        favWinScroll:SetWidth(finalW)
        favWinScroll:SetHeight(visH)
        favWinChild:SetWidth(finalW)
        favWinChild:SetHeight(contentH)

        for i = 1, count do
            local row = activeFavWinRows[i]
            row:ClearAnchors()
            row:SetDimensions(finalW, ROW_H)
            row:SetHidden(false)
            if i == 1 then
                row:SetAnchor(TOPLEFT, favWinChild, TOPLEFT, 0, 0)
            else
                row:SetAnchor(TOPLEFT, activeFavWinRows[i - 1], BOTTOMLEFT, 0, 0)
            end
        end

        if ZO_Scroll_UpdateScrollBar then ZO_Scroll_UpdateScrollBar(favWinScroll) end
        if ZO_Scroll_ResetToTop then ZO_Scroll_ResetToTop(favWinScroll) end
    end

    function QEM:ShowFavoritesWindow()
        if self.CloseAll then self:CloseAll() end
        self:RefreshFavoritesWindow()
        favWindow:SetHidden(false)
        SM:SetInUIMode(true)
        PlaySound(SOUND_OPEN)
    end

    function QEM:HideFavoritesWindow(leaveUIMode)
        if favWindow:IsHidden() then return end
        favWindow:SetHidden(true)
        if leaveUIMode then
            LeaveUIMode()
        end
    end

    function QEM:ToggleFavoritesWindow()
        if favWindow:IsHidden() then
            self:ShowFavoritesWindow()
        else
            self:HideFavoritesWindow(true)
        end
    end

    -- Force-close popup menus/windows as soon as the HUD scenes start hiding
    -- (map, inventory, dialogues, etc.). The main menu is only a child of the
    -- button control — it is NOT a scene fragment — so when the detached TLW
    -- is re-shown after the map closes the menu would still be open unless we
    -- explicitly CloseAll here. Same for the standalone favorites window.
    local function ForceHidePopupsOnHudHide(oldState, newState)
        if newState == SCENE_HIDING or newState == SCENE_HIDDEN then
            if not mainMenu:IsHidden() then
                QEM:CloseAll()
            end
            if not favWindow:IsHidden() then
                QEM:HideFavoritesWindow(false)
            end
        end
    end
    SM:GetScene("hud"):RegisterCallback("StateChange", ForceHidePopupsOnHudHide)
    SM:GetScene("hudui"):RegisterCallback("StateChange", ForceHidePopupsOnHudHide)

    -- Extra safety for the world map specifically
    if WMS then -- WORLD_MAP_SCENE
        WMS:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                if not mainMenu:IsHidden() then
                    QEM:CloseAll()
                end
                if not favWindow:IsHidden() then
                    QEM:HideFavoritesWindow(false)
                end
            end
        end)
    end

    -- Also close when leaving UI mode / cursor (movement, etc.)
    favWindow:SetHandler("OnShow", function(self)
        self:RegisterForEvent(EVENT_GAME_CAMERA_UI_MODE_CHANGED, function()
            if not self:IsHidden() and not IsGameCameraUIModeActive() then
                QEM:HideFavoritesWindow(false)
            end
        end)
    end)
    favWindow:SetHandler("OnHide", function(self)
        self:UnregisterForEvent(EVENT_GAME_CAMERA_UI_MODE_CHANGED)
    end)

    -- Position (independent of the main button)
    favWindow:ClearAnchors()
    if sv.favWindowX and sv.favWindowY
        and sv.favWindowX > 0 and sv.favWindowY > 0
        and sv.favWindowX < GuiRoot:GetWidth()
        and sv.favWindowY < GuiRoot:GetHeight() then
        favWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.favWindowX, sv.favWindowY)
    else
        favWindow:SetAnchor(TOPLEFT, GuiRoot, CENTER, 50, 0) -- default position
    end

    QEM.favWindow = favWindow
end

----------------------------------------------------------------------
-- Shared helpers (slash commands + in-menu Settings)
----------------------------------------------------------------------
function QEM.OpenSettingsPanel()
    if LibAddonMenu2 then
        LibAddonMenu2:OpenToPanel(ADDON_NAME .. "Panel")
    else
        d("[" .. ADDON_NAME .. "] LibAddonMenu-2.0 not found. Settings unavailable.")
    end
end

function QEM.ToggleDetachFromChat()
    if not QEM.SV then return end
    QEM.SV.detachButtonFromChat = not QEM.SV.detachButtonFromChat
    if QEM.UpdateButtonAttachment then
        QEM.UpdateButtonAttachment()
    end
end

----------------------------------------------------------------------
-- Slash + Keybind
----------------------------------------------------------------------
SLASH_COMMANDS[SLASH_COMMAND_PANEL] = function()
    QEM.OpenSettingsPanel()
end

SLASH_COMMANDS[SLASH_COMMAND_DETACH] = function()
    QEM.ToggleDetachFromChat()
end

-- Keybind handler (bind in Controls → User Interface)
function QEM_Toggle()
    if QEM.ToggleMainMenu then QEM:ToggleMainMenu(true) end
end

-- Keybind handler for the standalone favorites window
function QEM_ToggleFavoritesWindow()
    if QEM.ToggleFavoritesWindow then QEM:ToggleFavoritesWindow() end
end

----------------------------------------------------------------------
-- Load
----------------------------------------------------------------------
local function OnLoaded(_, name)
    if name ~= ADDON_NAME then return end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- Localization
    CacheLocalizedStrings()

    -- Bindings
    ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_MENU", STRINGS.BINDING_TOGGLE .. " " .. ADDON_TITLE)
    ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTE_MENU_FAVORITES", STRINGS.BINDING_TOGGLE .. " " .. STRINGS.FAVORITES .. " " .. ADDON_TITLE)

    -- Init
    InitSettings()
    CreateUI()
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)
