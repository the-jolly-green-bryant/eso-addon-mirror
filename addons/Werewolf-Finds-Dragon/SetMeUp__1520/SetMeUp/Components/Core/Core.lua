setMeUpAddon   = {}
setMeUpAddonDB = setMeUpAddonDB or {}

local obj, db, lom, msg = setMeUpAddon

function obj.onLoad(_, addon)
  if addon ~= "SetMeUp" or not LibStub then return end

  db = setMeUpAddonDB

  if LibStub then
    obj.lom = LibStub:GetLibrary("LibOmniMessage-4.0")
  end

  if obj.lom then
    obj.doMessage = function(textMessage, formatTable)
      obj.lom:Send(lom:Title("SetMeUp")..textMessage, formatTable)
    end
  end

  lom = obj.lom       or {}
  msg = obj.doMessage or function() end

  SLASH_COMMANDS["/smu"] = obj.slashHandler

  EVENT_MANAGER:UnregisterForEvent("SetMeUp_OnLoad")
end

function obj.slashHandler(textMessage)
  textMessage = type(textMessage) == "string" and textMessage:lower() or ""

  local varType, varText

  if textMessage:find(" ") then
    varType, varText = textMessage:match("(%w+) (.*)")
  end

  if obj[(varType or textMessage)] then
    obj[(varType or textMessage)](varText)

  else
    obj.showHelp()
  end
end

function obj.checkProfile(profileName, save)
  if IsUnitInCombat("player") or IsUnitDeadOrReincarnating("player") then
    msg("You can't do that right now. Try again when you're safe.")

  elseif not profileName then
    msg("You must provide a profile name.")

    return false

  elseif not save and not db[profileName] then
    msg("You don't have a profile named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(profileName or "?")})

    return false

  elseif save and db[profileName] then
    msg("You already have a profile named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>>, please delete it if you want to remake it.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(profileName or "?")})

    return false
  end

  return true
end

function obj.save(profileName)
  if not obj.checkProfile(profileName, true) then return end

  local zosDB, panelName, settingType, settingData, chatIndex, windowIndex, tabIndex, windows, tabs = ZO_SharedOptions_SettingsData

  db[profileName] = db[profileName] or {}

  for panelName, _ in pairs(zosDB) do
    for settingType, _ in pairs(zosDB[panelName]) do
      for settingData, _ in pairs(zosDB[panelName][settingType]) do
        if zosDB[panelName][settingType][settingData].settingId then
          db[profileName][settingType.." "..zosDB[panelName][settingType][settingData].settingId] = GetSetting(settingType, zosDB[panelName][settingType][settingData].settingId)
        end
      end
    end
  end

  for chatIndex = 1, GetNumChatCategories() do
    local redColor, greenColor, blueColor = GetChatCategoryColor(chatIndex)

    db[profileName]["bubble "..tostring(chatIndex)] = IsChatBubbleCategoryEnabled(chatIndex)

    if redColor and greenColor and blueColor then
      db[profileName]["chat "..tostring(chatIndex)] = tostring(redColor).." "..tostring(greenColor).." "..tostring(blueColor)
    end
  end

  db[profileName].windows = {}
  windows                 = db[profileName].windows

  for windowIndex = 1, #CHAT_SYSTEM.containers do
    windows[windowIndex] = { tabs = {} }
    tabs                 = windows[windowIndex].tabs

    windows[windowIndex].relPoint = CHAT_SYSTEM.containers[windowIndex].settings.relPoint
    windows[windowIndex].x        = CHAT_SYSTEM.containers[windowIndex].settings.x
    windows[windowIndex].y        = CHAT_SYSTEM.containers[windowIndex].settings.y
    windows[windowIndex].height   = CHAT_SYSTEM.containers[windowIndex].settings.height
    windows[windowIndex].width    = CHAT_SYSTEM.containers[windowIndex].settings.width
    windows[windowIndex].point    = CHAT_SYSTEM.containers[windowIndex].settings.point

    for tabIndex  = 1, #CHAT_SYSTEM.containers[windowIndex].windows do
      tabs[tabIndex] = {}

      tabs[tabIndex].name, tabs[tabIndex].locked, tabs[tabIndex].interactive, _, tabs[tabIndex].timestamps = GetChatContainerTabInfo(windowIndex, tabIndex)

      tabs[tabIndex].categories  = {}

      for chatIndex = 1, GetNumChatCategories() do
        tabs[tabIndex].categories[chatIndex] = IsChatContainerTabCategoryEnabled(1, tabIndex, chatIndex)
      end
    end
  end

  db[profileName].fontsize  = GetChatFontSize()
  db[profileName].chatalpha = CHAT_SYSTEM:GetMinAlpha()

  if Binder then
    Binder.SaveBindings("setmeup_"..profileName, true)
  end

  msg("Profile named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>> saved.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(profileName or "?")})
end

function obj.delete(profileName)
  if not obj.checkProfile(profileName) then return end

  db[profileName] = nil

  if Binder then
    Binder.savedVariables.bindings["setmeup_"..profileName] = nil
  end

  msg("Profile named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>> removed.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(profileName or "?")})
end

function obj.load(profileName)
  if not obj.checkProfile(profileName) then return end

  local settingType, settingID, redColor, greenColor, blueColor, chatIndex, windows, tabs

  for settingData, settingValue in pairs(db[profileName]) do
    settingType, settingID = settingData:match("(.*) (.*)")

    if settingData == "fontsize" then
      SetChatFontSize(db[profileName].fontsize)

    elseif settingData == "chatalpha" then
      CHAT_SYSTEM:SetMinAlpha(db[profileName].chatalpha)

    elseif settingData == "windows" then
      for windowIndex = 1, #CHAT_SYSTEM.containers do
        windows = db[profileName].windows

        CHAT_SYSTEM.containers[windowIndex].settings.relPoint = windows[windowIndex].relPoint
        CHAT_SYSTEM.containers[windowIndex].settings.x        = windows[windowIndex].x
        CHAT_SYSTEM.containers[windowIndex].settings.y        = windows[windowIndex].y
        CHAT_SYSTEM.containers[windowIndex].settings.height   = windows[windowIndex].height
        CHAT_SYSTEM.containers[windowIndex].settings.width    = windows[windowIndex].width
        CHAT_SYSTEM.containers[windowIndex].settings.point    = windows[windowIndex].point

        for tabIndex = 1, #CHAT_SYSTEM.containers[windowIndex].windows do
          tabs = windows and windows[windowIndex].tabs or nil

          if windows and windows[windowIndex] and tabs and tabs[tabIndex] then
            if GetNumChatContainerTabs(windowIndex) < tabIndex then
              CHAT_SYSTEM.containers[windowIndex]:AddWindow(tabs[tabIndex].name)
            end

            SetChatContainerTabInfo(windowIndex, tabIndex, tabs[tabIndex].name, tabs[tabIndex].locked, tabs[tabIndex].interactive, tabs[tabIndex].timestamps)

            for chatIndex = 1, GetNumChatCategories() do
              SetChatContainerTabCategoryEnabled(windowIndex, tabIndex, chatIndex, tabs[tabIndex].categories[chatIndex])
            end
          end
        end
      end

    elseif settingType == "bubble" then
      SetChatBubbleCategoryEnabled(tonumber(settingID), settingValue)

    elseif settingType == "chat" then
      redColor, greenColor, blueColor = settingValue:match("(.*) (.*) (.*)")

      CHAT_SYSTEM:SetChannelCategoryColor(tonumber(settingID), tonumber(redColor), tonumber(greenColor), tonumber(blueColor))
      SetChatCategoryColor(               tonumber(settingID), tonumber(redColor), tonumber(greenColor), tonumber(blueColor))

    elseif tonumber(settingType) and tonumber(settingID) and settingValue then
      if settingValue == 1 or settingValue == 0 then
        settingValue = 1 - settingValue
      end

      SetSetting(tonumber(settingType), tonumber(settingID), settingValue)
    end
  end

  if Binder then
    Binder.LoadBindings("setmeup_"..profileName, true)
  end

  msg("Profile named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>> loaded, UI will reload in ten seconds.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(profileName or "?")})

  zo_callLater(function() ReloadUI() end, 10000)
end

function obj.list()
  local profileName

  msg("You have the following profiles saved...")

  for profileName, _ in pairs(db) do
    msg("<<LOM-YELLOW>>*<<LOM-CLEAR>> <<LOM-GREEN>><<LOM-NAME>><<LOM-CLEAR>>", {GREEN=lom.greenColor, YELLOW=lom.yellowColor, CLEAR=lom.clearColor, NAME=string.gsub(" "..(profileName or "?"), "%W%l", string.upper):sub(2)})
  end

  if not next(db) then msg("<<LOM-RED>>None!<<LOM-CLEAR>>", {RED=lom.redColor, CLEAR=lom.clearColor}) end
end

function obj.showHelp()
  msg("Here are the commands you can use...")
  msg("<<LOM-GREEN>>/smu save profile name<<LOM-WHITE>> Stores your per-character settings profile as 'profile name.'",  {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/smu load profile name<<LOM-WHITE>> Loads your per-character settings profile from 'profile name.'", {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/smu delete profile name<<LOM-WHITE>> Deletes the profile named 'profile name.'",                    {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/smu list<<LOM-WHITE>> Lists all stored profiles.",                                                  {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
end

EVENT_MANAGER:RegisterForEvent("SetMeUp_OnLoad", EVENT_ADD_ON_LOADED, obj.onLoad)