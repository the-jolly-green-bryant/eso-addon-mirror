local SFT = SamisFishTrackerAddon
local visibility = SFT.constants.visibility

local function setVisibility(mode)
  SFT.savedVariables.visibility = mode

  if mode == visibility.SHOW then
    SamisFishTrackerControl:SetHidden(false)
  elseif mode == visibility.HIDE then
    SamisFishTrackerControl:SetHidden(true)
  end
end

function SFT.RegisterSlashCommands()
  local lsc = LibSlashCommander
  if lsc then
    local cmd = lsc:Register(
      "/sft",
      function()
        SamisFishTrackerControl:SetHidden(not SamisFishTrackerControl:IsHidden())
      end,
      "Temporarily show/hide window"
    )

    local subHide = cmd:RegisterSubCommand()
    subHide:AddAlias("hide")
    subHide:SetCallback(function()
      setVisibility(visibility.HIDE)
    end)
    subHide:SetDescription("Hide window")

    local subShow = cmd:RegisterSubCommand()
    subShow:AddAlias("show")
    subShow:SetCallback(function()
      setVisibility(visibility.SHOW)
    end)
    subShow:SetDescription("Show window")

    local subAuto = cmd:RegisterSubCommand()
    subAuto:AddAlias("auto")
    subAuto:SetCallback(function()
      setVisibility(visibility.AUTO)
    end)
    subAuto:SetDescription("Show only when pointing fishing hole")

    local subReset = cmd:RegisterSubCommand()
    subReset:AddAlias("reset")
    subReset:SetCallback(function()
      SFT.ResetFishAmount()
    end)
    subReset:SetDescription("Reset number of fish to 0")
    return
  end

  SLASH_COMMANDS["/sft"] = function(input)
    local command = input:match("^(%S+)")

    if command == "show" then
      setVisibility(visibility.SHOW)
    elseif command == "hide" then
      setVisibility(visibility.HIDE)
    elseif command == "auto" then
      setVisibility(visibility.AUTO)
    elseif command == "reset" then
      SFT.ResetFishAmount()
    else
      SamisFishTrackerControl:SetHidden(not SamisFishTrackerControl:IsHidden())
    end
  end
end
