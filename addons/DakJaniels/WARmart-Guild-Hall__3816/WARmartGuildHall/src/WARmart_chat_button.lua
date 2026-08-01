local LCMB = LibChatMenuButton;

WARmartGuildHall = {
  name = "|cFF0000WARmart|r GuildHall";
  version = "1.0";
  description = "Chat window icon for WARmart Guild";
  buttonName = "?WGHButton";
  iconPath = "/WARmartGuildHall/icon/WARmart.dds";
  tooltipText = "Teleport to WARmartGuildHall";
  WARmartGuildHallButton = function ()
    local owner = "@Artmetis";
    local house_id = 66; -- Elinhir Private Arena
    if GetWorldName() == "NA Megaserver" then
      if owner == GetDisplayName() then
        RequestJumpToHouse(house_id, false);
      else
        JumpToSpecificHouse(owner, house_id);
      end;
    end;
  end;
  savedVariables = ZO_SavedVars:NewCharacterIdSettings("WARmartSavedVars", 1, nil, {});
  enableHooks = function ()
    return true;
  end;
  Startup = function ()
    WARmartGuildHall.enableHooks();
  end;

  PlayerActivated = function (eventCode)
    EVENT_MANAGER:UnregisterForEvent(WARmartGuildHall.name, eventCode);
    WARmartGuildHall.Startup();
  end;

  OnAddOnLoaded = function (eventCode, addOnName)
    if (addOnName ~= WARmartGuildHall.name) then return; end;
    EVENT_MANAGER:RegisterForEvent(WARmartGuildHall.name, EVENT_PLAYER_ACTIVATED, WARmartGuildHall.PlayerActivated);
  end;
};

SLASH_COMMANDS["/wmgh"] = WARmartGuildHall.WARmartGuildHallButton;

local button = LCMB.addChatButton(WARmartGuildHall.buttonName, WARmartGuildHall.iconPath, WARmartGuildHall.tooltipText, WARmartGuildHall.WARmartGuildHallButton);
button:enable();

EVENT_MANAGER:RegisterForEvent(WARmartGuildHall.name, EVENT_ADD_ON_LOADED, WARmartGuildHall.OnAddOnLoaded);
