VestigeMirror = VestigeMirror or {}

local ADDON_NAME = "VestigeMirror"
local SHARE_LINK_TYPE = "vestigemirror"

ZO_CreateStringId("SI_BINDING_NAME_VESTIGE_MIRROR_TOGGLE", "Toggle Vestige Mirror")

function VestigeMirror:Initialize()
    if self.initialized then
        return
    end

    self.Data:Initialize()
    self.Preview:Initialize()
    self.UI:Initialize(VestigeMirrorWindow)
    self.Scene:Initialize()

    SLASH_COMMANDS["/vestigemirror"] = function(arguments) self:HandleCommand(arguments) end
    SLASH_COMMANDS["/vm"] = function(arguments) self:HandleCommand(arguments) end
    SLASH_COMMANDS["/vmshare"] = function() self:ShareCurrentAppearance() end
    self:RegisterLinkHandler()

    self.initialized = true
end

function VestigeMirror:RegisterLinkHandler()
    if self.linkHandlerRegistered then
        return
    end

    if LibChatMessage then
        LibChatMessage:RegisterCustomChatLink(SHARE_LINK_TYPE, function(linkStyle, linkType, data, displayText)
            return "|cFFFF00" .. ZO_LinkHandler_CreateLinkWithoutBrackets(displayText, nil, SHARE_LINK_TYPE, data) .. "|r"
        end)
    end

    if LINK_HANDLER then
        local function OnLinkClicked(link, button, text, color, linkType, payload)
            if linkType == SHARE_LINK_TYPE and button == MOUSE_BUTTON_INDEX_LEFT then
                self:ShowSharedPayload(payload, text)
                return true
            end
        end

        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, OnLinkClicked)
        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnLinkClicked)
    end

    self.linkHandlerRegistered = true
end

function VestigeMirror:HandleCommand(arguments)
    if arguments and arguments ~= "" then
        local shared = self.Data:DecodeShareString(arguments)
        if shared then
            local outfitName = arguments:match("%[(.-)%].-VM1:")
            if outfitName and outfitName ~= "" then
                shared.outfitName = outfitName
            end
            self:ShowSharedAppearance(shared)
            return
        end

        if CHAT_SYSTEM then
            CHAT_SYSTEM:AddMessage("|cFFFF00Vestige Mirror:|r Invalid share string.")
        end
        return
    end

    self:Toggle()
end

function VestigeMirror:ShowSharedAppearance(shared)
    if not self.initialized then
        return
    end

    local appearance = self.Data:BuildSharedAppearance(shared)
    self.Scene:ShowAppearance(appearance)
end

function VestigeMirror:ShowSharedPayload(payload, outfitName)
    local shared = self.Data:DecodeShareString("VM1:" .. (payload or ""))
    if shared then
        if outfitName and outfitName ~= "" then
            shared.outfitName = outfitName:gsub("^%[", ""):gsub("%]$", ""):gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
        end
        self:ShowSharedAppearance(shared)
    elseif CHAT_SYSTEM then
        CHAT_SYSTEM:AddMessage("|cFFFF00Vestige Mirror:|r Invalid outfit link.")
    end
end

function VestigeMirror:ShareCurrentAppearance()
    if not self.initialized then
        return
    end

    local appearance = self.Data:BuildAppearance()
    local shareString = self.Data:EncodeAppearance(appearance)
    if shareString == "VM1:" then
        if CHAT_SYSTEM then
            CHAT_SYSTEM:AddMessage("|cFFFF00Vestige Mirror:|r No outfit style slots found to share.")
        end
        return
    end

    local outfitName = tostring(appearance.outfitName or "Shared Outfit"):gsub("[%[%]\r\n]", "")
    if outfitName == "" then
        outfitName = "Shared Outfit"
    end

    local shareMessage = string.format("Vestige Mirror [%s]: %s", outfitName, shareString)
    local payload = shareString:match("^VM1:(.*)$")
    local link = nil
    if payload and LibChatMessage and ZO_LinkHandler_CreateLink then
        link = ZO_LinkHandler_CreateLink(outfitName, nil, SHARE_LINK_TYPE, payload)
    end

    if link and CHAT_SYSTEM and CHAT_SYSTEM.textEntry then
        CHAT_SYSTEM.textEntry:InsertLink(link)
    elseif StartChatInput then
        StartChatInput(shareMessage)
    elseif CHAT_SYSTEM then
        CHAT_SYSTEM:AddMessage(shareMessage)
    end

    if CHAT_SYSTEM then
        if link then
            CHAT_SYSTEM:AddMessage("|cFFFF00Vestige Mirror:|r Share link inserted in chat input.")
        else
            CHAT_SYSTEM:AddMessage("|cFFFF00Vestige Mirror:|r LibChatMessage not found. Share text prepared instead.")
        end
    end
end

function VestigeMirror:Toggle()
    if not self.initialized then
        return
    end

    if self.Scene:IsShowing() then
        self:Hide()
    else
        self:Show()
    end
end

function VestigeMirror:Show()
    if not self.initialized then
        return
    end

    self.Scene:Show()
end

function VestigeMirror:Hide()
    if not self.initialized then
        return
    end

    self.Scene:Hide()
end

function VestigeMirror_OnInitialized(control)
    VestigeMirror.window = control
end

function VestigeMirror_Toggle()
    VestigeMirror:Toggle()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    VestigeMirror:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
