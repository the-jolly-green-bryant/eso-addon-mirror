-- PreviewAnywhereLinkActions.lua: Injects a "Preview" keybind into every
-- ZO_GamepadLinks instance (chat menu, mail inbox, guild hub, ...), the
-- widget that shows the carousel tooltip when a message contains links.
--
-- ZO_GamepadLinks adds its keybind group only while a link tooltip is
-- showing, so we pre-hook AddKeybinds and append our button to the
-- instance's descriptor before the group registers with the keybind strip.
-- This covers existing instances (created before addons load) as well as
-- any created later.
--
-- Keybind choice: UI_SHORTCUT_QUATERNARY matches the inventory's preview
-- keybind and is unclaimed by every base-game host of ZO_GamepadLinks
-- (chat menu: negative/primary/secondary/tertiary; mail inbox:
-- primary/secondary/tertiary/quinary/right stick; guild hub: primary/negative).

local LinkUtils = PreviewAnywhere.LinkUtils

local LinkActions = {}

---Pre-hook body for ZO_GamepadLinks:AddKeybinds. Appends the preview button
---to this instance's keybind group exactly once.
---@param gamepadLinks table The ZO_GamepadLinks instance
local function InjectPreviewKeybind(gamepadLinks)
    if gamepadLinks.previewAnywhereInjected then
        return
    end
    gamepadLinks.previewAnywhereInjected = true
    PreviewAnywhere.diagnostics.linkInjections = PreviewAnywhere.diagnostics.linkInjections + 1

    table.insert(gamepadLinks.keybindStripDescriptor, {
        order = 30,
        keybind = "UI_SHORTCUT_QUATERNARY",
        name = GetString(SI_ITEM_ACTION_PREVIEW),
        callback = function()
            local itemLinks, startIndex = LinkUtils.GetPreviewableLinks(gamepadLinks)
            if #itemLinks > 0 then
                PreviewAnywhere.PreviewActions.ShowLinkPreview(itemLinks, startIndex)
            end
        end,
        visible = function()
            if not PreviewAnywhere.state.savedVars.enabled or not IsCharacterPreviewingAvailable() then
                return false
            end
            return LinkUtils.CanPreviewLinkData(gamepadLinks:GetCurrentLink())
        end,
    })
end

function LinkActions.Initialize()
    ZO_PreHook(ZO_GamepadLinks, "AddKeybinds", InjectPreviewKeybind)
end

PreviewAnywhere.LinkActions = LinkActions
