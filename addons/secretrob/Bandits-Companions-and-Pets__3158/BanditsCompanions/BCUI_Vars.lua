BCUI.Defaults = {
  ShowCompanionWhenSolo      = true,
  ShowCompanionWhenInGroup   = true,
  UseCompanionWeaponForIcon  = true,
  BCUI_CompanionFrame        = {TOPLEFT,TOPLEFT,50,160}, --Anchored to Raid Frame for now
  CompanionWidth             =220,
  CompanionHeight            =32,
  CompanionFontSize          =17,
  CompanionSplit             =0,
  CompanionLevels            =true,
  CompanionSort              =1,
  CompanionNameColor         =true,
  FrameCompanionColor        ={102/255,255/255,102/255},
  CompanionIcon              ="/esoui/art/companion/keyboard/category_u30_companions_up.dds",
  PetIcon                    ="/esoui/art/treeicons/store_indexicon_vanitypets_up.dds",
  CompanionCompact           =false,
  AddPetsToCompanionList     =false,
  ShowAllPetsAbilites        =false,
  CompanionNameFormat        =1,
  DetachFrameGroup           =false,
  DetachFrameSolo            =false,  
  AutoHide                   =false,
  SidebarCompanion           =2,
  CompanionAutoDismiss       =false,
}

function BCUI.Vars.Initialize()
  BCUI.Vars = ZO_SavedVars:NewAccountWide('BanditsCompanions_SavedVars', 1, nil, BCUI.Defaults)
  if BUI.Vars.BCUI_CompanionFrame then BCUI.Vars.BCUI_CompanionFrame = BUI.Vars.BCUI_CompanionFrame end
  BUI.DefaultFrames["BCUI_CompanionFrame"] = "Companion Frame"
end
