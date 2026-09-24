-- PreviewAnywherePreviewActions.lua: Registers an item-link preview type with
-- the gamepad item preview system and owns the pushed preview scene used for
-- links (chat, mail, guild descriptions).
--
-- The base game's ZO_ItemPreview_Shared has no preview type for raw item links
-- even though the C API exposes PreviewItemLink/CanItemLinkBePreviewed, so we
-- subclass ZO_ItemPreviewType and register it under our own key. The scene is
-- assembled from the same fragments as TRADING_HOUSE_PREVIEW_GAMEPAD_SCENE
-- (see gamepadingamescenes.lua): the guild store's preview screen is exactly
-- the experience we want for previewing a linked item.

local PreviewUtils = PreviewAnywhere.PreviewUtils

local PreviewActions = {}

local LINK_PREVIEW_SCENE_NAME = "PreviewAnywhere_LinkPreview"

---Preview type that renders an arbitrary item link.
local ItemLinkPreviewType = ZO_ItemPreviewType:Subclass()

function ItemLinkPreviewType:SetStaticParameters(itemLink)
    self.itemLink = itemLink
end

function ItemLinkPreviewType:ResetStaticParameters()
    self.itemLink = nil
end

function ItemLinkPreviewType:HasStaticParameters(itemLink)
    return self.itemLink == itemLink
end

function ItemLinkPreviewType:Apply(variationIndex)
    PreviewItemLink(self.itemLink, variationIndex)
end

local backKeybindDescriptor =
{
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name = GetString(SI_GAMEPAD_BACK_OPTION),
        keybind = "UI_SHORTCUT_NEGATIVE",
        callback = function()
            SCENE_MANAGER:HideCurrentScene()
        end,
    },
}

local function OnLinkPreviewSceneStateChange(_oldState, newState)
    local state = PreviewAnywhere.state
    if newState == SCENE_SHOWING then
        KEYBIND_STRIP:AddKeybindButtonGroup(backKeybindDescriptor)
    elseif newState == SCENE_SHOWN then
        if state.pendingLinkPreviews and #state.pendingLinkPreviews > 0 then
            -- The list helper drives ITEM_PREVIEW_GAMEPAD and provides the
            -- LT/RT "Preview Previous/Next" keybinds when multiple links exist.
            ITEM_PREVIEW_LIST_HELPER_GAMEPAD:PreviewList(PreviewUtils.ITEM_LINK_PREVIEW_TYPE, state.pendingLinkPreviews, state.pendingLinkPreviewIndex)
        end
    elseif newState == SCENE_HIDDEN then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(backKeybindDescriptor)
        state.pendingLinkPreviews = nil
        state.pendingLinkPreviewIndex = nil
    end
end

---Push the link preview scene for a list of previewable item links.
---@param itemLinks string[]
---@param startIndex integer|nil Index within itemLinks to preview first (default 1)
function PreviewActions.ShowLinkPreview(itemLinks, startIndex)
    local state = PreviewAnywhere.state
    state.pendingLinkPreviews = itemLinks
    state.pendingLinkPreviewIndex = startIndex or 1
    SCENE_MANAGER:Push(LINK_PREVIEW_SCENE_NAME)
end

function PreviewActions.Initialize()
    ITEM_PREVIEW_GAMEPAD.previewTypeObjects[PreviewUtils.ITEM_LINK_PREVIEW_TYPE] = ItemLinkPreviewType:New()

    local scene = ZO_Scene:New(LINK_PREVIEW_SCENE_NAME, SCENE_MANAGER)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_CENTERED_NO_BLUR)
    -- The preview options fragment must be added before the ITEM_PREVIEW_GAMEPAD
    -- fragment, which is part of ZO_ITEM_PREVIEW_LIST_HELPER_GAMEPAD_FRAGMENT_GROUP.
    scene:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_FURNITURE_ITEM_PREVIEW_OPTIONS_FRAGMENT)
    scene:AddFragmentGroup(ZO_ITEM_PREVIEW_LIST_HELPER_GAMEPAD_FRAGMENT_GROUP)
    scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    scene:RegisterCallback("StateChange", OnLinkPreviewSceneStateChange)
end

PreviewAnywhere.PreviewActions = PreviewActions
