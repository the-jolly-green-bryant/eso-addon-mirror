-- Alkosh Synergy Tracker — move mode (keybind strip only, no settings panel)

AST_UI = AST_UI or {}
local UI = AST_UI
local AST = AlkoshSynergyTracker

UI.sceneName = "AlkoshSynergyTrackerSettingsScene"
UI.visible = false
UI.initialized = false
UI.sceneSetup = false
UI.hubRetryScheduled = false
UI.NUDGE_STEP = 20
UI.SCALE_STEP = 0.05

local function SafeNum(v, fallback)
    local n = tonumber(v)
    if n == nil then
        return fallback or 0
    end
    return n
end

local function ClampScale(scale)
    if type(zo_clamp) == "function" then
        return zo_clamp(scale, 0.5, 2.5)
    end
    return math.max(0.5, math.min(2.5, scale))
end

local function RefreshHudSafe()
    if AST and type(AST.RefreshHud) == "function" then
        AST:RefreshHud()
    end
end

local function ApplyTransformSafe()
    if AST and type(AST.ApplyHudTransform) == "function" then
        AST:ApplyHudTransform()
    elseif AST and type(AST.ApplyHudPosition) == "function" then
        AST:ApplyHudPosition()
    end
end

function UI:EnsureSceneRoot()
    if self.sceneRoot then
        return self.sceneRoot
    end
    if not GuiRoot then
        return nil
    end
    local root = WINDOW_MANAGER:CreateControl("AST_MoveModeRoot", GuiRoot, CT_CONTROL)
    root:SetDimensions(1, 1)
    root:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    root:SetHidden(true)
    root:SetMouseEnabled(false)
    self.sceneRoot = root
    return root
end

function UI:Nudge(dx, dy)
    if not AST or not AST.sv then
        return
    end
    AST.sv.offsetX = math.floor(SafeNum(AST.sv.offsetX, 0) + dx)
    AST.sv.offsetY = math.floor(SafeNum(AST.sv.offsetY, 0) + dy)
    AST.lastTransformKey = nil
    AST.lastRenderKey = nil
    ApplyTransformSafe()
    RefreshHudSafe()
end

function UI:AdjustScale(delta)
    if not AST or not AST.sv then
        return
    end
    local oldScale = SafeNum(AST.sv.scale, 1.0)
    local newScale = ClampScale(oldScale + (delta or 0))
    newScale = math.floor((newScale * 100) + 0.5) / 100
    if math.abs(newScale - oldScale) <= 0.0001 then
        return
    end
    AST.sv.scale = newScale
    AST.lastTransformKey = nil
    AST.lastRenderKey = nil
    ApplyTransformSafe()
    RefreshHudSafe()
end

function UI:ResetAll()
    if not AST or not AST.sv then
        return
    end
    AST.sv.offsetX = 0
    AST.sv.offsetY = 0
    AST.sv.scale = 1.0
    AST.lastTransformKey = nil
    AST.lastRenderKey = nil
    ApplyTransformSafe()
    RefreshHudSafe()
    d("[AST] HUD position and scale reset.")
end

function UI:BuildKeybindStrip()
    local backName = "Back"
    if type(GetString) == "function" and SI_GAMEPAD_BACK_OPTION then
        backName = GetString(SI_GAMEPAD_BACK_OPTION)
    end

    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind = "UI_SHORTCUT_NEGATIVE",
            name = backName,
            callback = function()
                SCENE_MANAGER:HideCurrentScene()
            end,
            sound = SOUNDS and SOUNDS.GAMEPAD_MENU_BACK,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            name = "Left",
            callback = function()
                UI:Nudge(-UI.NUDGE_STEP, 0)
            end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            name = "Right",
            callback = function()
                UI:Nudge(UI.NUDGE_STEP, 0)
            end,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            name = "Up",
            callback = function()
                UI:Nudge(0, -UI.NUDGE_STEP)
            end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            name = "Down",
            callback = function()
                UI:Nudge(0, UI.NUDGE_STEP)
            end,
        },
        {
            keybind = "UI_SHORTCUT_SECONDARY",
            name = "Scale -",
            callback = function()
                UI:AdjustScale(-UI.SCALE_STEP)
            end,
        },
        {
            keybind = "UI_SHORTCUT_TERTIARY",
            name = "Scale +",
            callback = function()
                UI:AdjustScale(UI.SCALE_STEP)
            end,
        },
        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = "Reset",
            callback = function()
                UI:ResetAll()
            end,
        },
    }
end

function UI:SetupScene()
    if self.sceneSetup then
        return
    end
    local root = self:EnsureSceneRoot()
    if not root or not ZO_Scene or not SCENE_MANAGER or not FRAGMENT_GROUP then
        return
    end

    local scene = ZO_Scene:New(self.sceneName, SCENE_MANAGER)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    if GAMEPAD_MENU_SOUND_FRAGMENT then
        scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    end
    scene:AddFragment(ZO_SimpleSceneFragment:New(root))
    self:BuildKeybindStrip()

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            UI.visible = true
            KEYBIND_STRIP:AddKeybindButtonGroup(UI.keybindStripDescriptor)
            UI:RegisterInTrackingToolsHub()
            RefreshHudSafe()
        elseif newState == SCENE_HIDDEN then
            UI.visible = false
            KEYBIND_STRIP:RemoveKeybindButtonGroup(UI.keybindStripDescriptor)
            RefreshHudSafe()
        end
    end)

    self.sceneSetup = true
end

function UI:RegisterInTrackingToolsHub()
    if type(AST_EnsureTrackingToolsHub) == "function" then
        AST_EnsureTrackingToolsHub()
    end

    if ELDIBABALO_TRACKING_TOOLS and ELDIBABALO_TRACKING_TOOLS.Register then
        ELDIBABALO_TRACKING_TOOLS:Register(
            "Alkosh Synergy Tracker",
            "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_combat.dds",
            self.sceneName
        )
        if ELDIBABALO_TRACKING_TOOLS.RefreshList then
            ELDIBABALO_TRACKING_TOOLS:RefreshList()
        end
        self.hubRetryScheduled = false
        return true
    end

    if not self.hubRetryScheduled and type(zo_callLater) == "function" then
        self.hubRetryScheduled = true
        zo_callLater(function()
            self.hubRetryScheduled = false
            UI:RegisterInTrackingToolsHub()
        end, 1500)
    end
    return false
end

function UI:Initialize()
    if self.initialized then
        return
    end
    self:SetupScene()
    self.initialized = true
end

function UI:ToggleSettings()
    self:Initialize()
    if not self.sceneName or not SCENE_MANAGER then
        return
    end
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        SCENE_MANAGER:HideCurrentScene()
    else
        SCENE_MANAGER:Show(self.sceneName)
    end
end

function UI:LateInit()
    self:RegisterInTrackingToolsHub()
end

function AlkoshSynergyTracker_Settings()
    if AST_UI then
        AST_UI:ToggleSettings()
    end
end
