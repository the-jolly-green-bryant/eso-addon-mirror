--Name Space
MAGatherUp = {}

--Basic Info
local GU = MAGatherUp
GU.Name = "GatherUp"
GU.Title = "GatherUp"
GU.Author = "@MelanAster"
GU.Version = "0.10"

--Constant
GU.STATUS_ONLINE    = 0
GU.STATUS_OFFLINE   = 1
GU.STATUS_INGROUP   = 2
GU.STATUS_CHANGING  = 3

GU.ICON_UNKNOWN = "|t24:24:esoui/art/journal/u26_progress_digsite_unknown_complete.dds|t"
GU.ICON_ONLINE  = "|t24:24:esoui/art/tutorial/tutorial_illo_status_online.dds|t"
GU.ICON_OFFLINE = "|t24:24:esoui/art/tutorial/tutorial_illo_status_offline.dds|t"
GU.ICON_CHANGING = "|t24:24:esoui/art/guild/gamepad/gp_guild_options_changeicon.dds|t"
GU.ICON_CLASS = {
  [1] = "|t24:24:esoui/art/icons/class/class_dragonknight.dds|t", --DragonKnight
  [2] = "|t24:24:esoui/art/icons/class/class_sorcerer.dds|t",     --Sorcerer
  [3] = "|t24:24:esoui/art/icons/class/class_nightblade.dds|t",   --NightBlade
  [4] = "|t24:24:esoui/art/icons/class/class_warden.dds|t",       --Warden
  [5] = "|t24:24:esoui/art/icons/class/class_necromancer.dds|t",  --Necromancer
  [6] = "|t24:24:esoui/art/icons/class/class_templar.dds|t",      --Templar
  [117] = "|t24:24:esoui/art/icons/class/class_arcanist.dds|t",   --Arcanist
}

--V
GU.Controls = {}

--Default setting for controls position and lock
GU.Default = {
  WindowPosition = {},
  Slot = {[1] = {}, [2] = {}, [3] = {}},
}

-------------------
----Start point----
-------------------

--Whenloaded
local function OnAddOnLoaded(eventCode, addonName)
  if addonName ~= GU.Name then return end
	EVENT_MANAGER:UnregisterForEvent(GU.Name, EVENT_ADD_ON_LOADED)
  
  --Get Account Setting
  GU.SV = ZO_SavedVars:NewAccountWide("GatherUp_Vars", 1, nil, GU.Default, GetWorldName())
  --Keybind
  ZO_CreateStringId("SI_BINDING_NAME_GATHERUP_OPEN", GU.Lang.KEYBIND)
  --Window Register
  SCENE_MANAGER:RegisterTopLevel(MAGU_TopLevel, locksUIMode)
  --Slash Register
  SLASH_COMMANDS["/gatherup"] = GU.ShowWindow
  --Event Register
  EVENT_MANAGER:RegisterForEvent(GU.Name, EVENT_GROUP_INVITE_RESPONSE, GU.InviteError)
  EVENT_MANAGER:RegisterForEvent(GU.Name, EVENT_RAID_TRIAL_STARTED, GU.TrialStart)

  --Initial
  GU.Initialization()
end

--Initial
function GU.Initialization()
  --Reset Window Position
  if GU.SV.WindowPosition["Offx"] then
    MAGU_TopLevel:ClearAnchors()
      MAGU_TopLevel:SetAnchor(
      GU.SV.WindowPosition.Point,
      GuiRoot,
      GU.SV.WindowPosition.RPoint,
      GU.SV.WindowPosition.Offx,
      GU.SV.WindowPosition.Offy
    )
  end
  
  --Create Controls
  local Left = {10, 10, 10, 10, 270, 270, 270, 270, 530, 530, 530, 530}
  local Top = {60, 110, 160, 210, 60, 110, 160, 210, 60, 110, 160, 210}
  for i = 1, 12 do
    GU.Controls[i] = CreateControlFromVirtual(
      "MAGU_Combo_"..i,
      MAGU_TopLevel,
      "GU_Single"
    )
    GU.Controls[i]:SetHidden(false)
    --Reset Controls Position
    GU.Controls[i]:SetAnchor(TOPLEFT, MAGU_TopLevel, TOPLEFT, Left[i], Top[i])
  end
  
  --Leader Set
  local Leader = GU.Controls[1]:GetNamedChild("_Role")
  Leader:SetNormalTexture("esoui/art/compass/groupleader.dds")
  Leader:SetMouseOverTexture("esoui/art/compass/groupleader.dds")
  Leader:SetPressedTexture("esoui/art/compass/groupleader.dds")
  
end

--Save Windonw Position
function GU.WindowMoved()
  local _, Point, _, RPoint, Offx, Offy = MAGU_TopLevel:GetAnchor()
  GU.SV.WindowPosition = {
    ["Point"] = Point, 
    ["RPoint"] = RPoint,
    ["Offx"] = Offx,
    ["Offy"] = Offy,
  }
end

--Whisper Button
function GU.Whisper(Control)
  local Name = Control:GetParent():GetNamedChild("_Name"):GetText()
  if Name ~= "" then
    StartChatInput("", CHAT_CHANNEL_WHISPER, Name)
  end
end

-- Start Here
EVENT_MANAGER:RegisterForEvent(GU.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)