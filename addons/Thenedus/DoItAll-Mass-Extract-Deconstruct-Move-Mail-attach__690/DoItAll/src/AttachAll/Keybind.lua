DoItAll = DoItAll or {}

local keystripDef = {
    name = "Attach All",
    keybind = "SC_BANK_ALL",
    callback = function() DoItAll.AttachAll() end,
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    visible = function() return true end,
}
table.insert(MAIL_SEND.staticKeybindStripDescriptor, keystripDef)

local function MailSendSceneStateChanged(oldState, newState)
  if newState == SCENE_SHOWING then
    --KEYBIND_STRIP:AddKeybindButtonGroup(keystripDef)
    --Remove the old keybind if there is still one activated
    if DoItAll.currentKeyStripDef ~= nil then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(DoItAll.currentKeyStripDef)
    end
    --Add the keystrip def to the global vars so we can reach it from everywhere
    DoItAll.currentKeyStripDef = keystripDef

  elseif newState == SCENE_HIDING then
    --KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDef)
    --Add the keystrip def to the global vars so we can reach it from everywhere
    DoItAll.currentKeyStripDef = nil
  end
end
MAIL_SEND_SCENE:RegisterCallback("StateChange", MailSendSceneStateChanged)
