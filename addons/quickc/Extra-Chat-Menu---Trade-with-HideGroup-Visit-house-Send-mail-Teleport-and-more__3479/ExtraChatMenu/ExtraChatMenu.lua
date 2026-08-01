-- ECM

ECM = {}
ECM.name = "ExtraChatMenu"
ECM.version = 0.3
ECM.author = "quickc (esoui)"

local const CPA = "Copy Name" -- need localization

-- Settings
local savedVars
local ECMSV = {
	ECMTrade = true,
	ECMVisitHouse = true,
	ECMCopyName = true,
	ECMSendMail = true,
	ECMJumpTo = true,
}

function ECM.settings()
      -- LAM
      local LAM = LibAddonMenu2
      local panelName = "Extra Chat Menu"

      local panelData = {
            type = "panel",
            name = panelName,
            author = ECM.author,
      }
      local panel = LAM:RegisterAddonPanel(panelName, panelData)
      local optionsData = {
            {
                  type = "checkbox",
                  name = GetString(SI_PLAYER_TO_PLAYER_INVITE_TRADE),
                  getFunc = function() return savedVars.ECMTrade end,
                  setFunc = function(value) savedVars.ECMTrade = value end,
                  requiresReload = true,
            },
            {
                  type = "checkbox",
                  name = GetString(SI_SOCIAL_MENU_VISIT_HOUSE),
                  getFunc = function() return savedVars.ECMVisitHouse end,
                  setFunc = function(value) savedVars.ECMVisitHouse = value end,
                  requiresReload = true,
            },
            {
                  type = "checkbox",
                  name = CPA,
                  getFunc = function() return savedVars.ECMCopyName end,
                  setFunc = function(value) savedVars.ECMCopyName = value end,
                  requiresReload = true,
            },
            {
                  type = "checkbox",
                  name = GetString(SI_SOCIAL_MENU_SEND_MAIL),
                  getFunc = function() return savedVars.ECMSendMail end,
                  setFunc = function(value) savedVars.ECMSendMail = value end,
                  requiresReload = true,
            },
            {
                  type = "checkbox",
                  name = GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER),
                  getFunc = function() return savedVars.ECMJumpTo end,
                  setFunc = function(value) savedVars.ECMJumpTo = value end,
                  requiresReload = true,
            }
      }
      LAM:RegisterOptionControls(panelName, optionsData)

end

-- Menu
function ECM.PlayerContextMenu(playerName, rawName)

      if savedVars.ECMTrade then
            AddCustomMenuItem(GetString(SI_PLAYER_TO_PLAYER_INVITE_TRADE), function()  TradeInviteByName(playerName)  end)
      end

      if savedVars.ECMVisitHouse then
            AddCustomMenuItem(GetString(SI_SOCIAL_MENU_VISIT_HOUSE), function()  JumpToHouse(playerName)  end)
      end

      if savedVars.ECMCopyName then
            AddCustomMenuItem(CPA, function()  CHAT_SYSTEM:StartTextEntry(playerName, CHAT_CHANNEL_PARTY) end)
      end

      if savedVars.ECMSendMail then
            AddCustomMenuItem(GetString(SI_SOCIAL_MENU_SEND_MAIL), function()
                  if MAIL_SEND:IsHidden() then
                        MAIL_SEND:ComposeMailTo(playerName)
                  else
                        MAIL_SEND:SetReply(playerName)
                  end
            end)
      end

      if savedVars.ECMJumpTo then
            if IsPlayerInGroup(playerName) then
                  AddCustomMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function() JumpToGroupMember(playerName) end)
            elseif IsFriend(playerName) then
                  AddCustomMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function() JumpToFriend(playerName) end)
            end
      end
end

-- Load
function ECM.OnAddOnLoaded(event, addonName)
      if addonName == ECM.name then
            EVENT_MANAGER:UnregisterForEvent(ECM.name, EVENT_ADD_ON_LOADED)
      if LibCustomMenu == nil or LibAddonMenu2 == nil then
            return
      end
      savedVars = ZO_SavedVars:NewAccountWide(ECM.name, ECM.version, nil, ECMSV, profile)
      LibCustomMenu:RegisterPlayerContextMenu(ECM.PlayerContextMenu, LibCustomMenu.CATEGORY_LATE)
      ECM.settings()
      end
end

EVENT_MANAGER:RegisterForEvent(ECM.name, EVENT_ADD_ON_LOADED, ECM.OnAddOnLoaded)


