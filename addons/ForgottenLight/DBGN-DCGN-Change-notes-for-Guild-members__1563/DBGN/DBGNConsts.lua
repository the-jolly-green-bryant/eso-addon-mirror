DBGN = {
  Name = "DBGN",
  Version = "1.1.9",
  IsDebugMode = false,
  CraftTraitDef = 4,
  ArrayYY = {"2025","2026","2027"," "},
  YY_Shift = 24, -- 2025 saved as 25 shifted to 1 position in ComboBox
  UI_FilterButton = {},
  UI_GHButton = {},
  GS_Desc = {},
  GS_MotD = {},
  DefXY = {
    BttN = {X = 10, Y = -80, DX = 340, DY = 200,},
    BttS = {X = 40, Y = -80, DX = 340, DY = 200,},
    BttP = {X =-415,Y = 0,   DX = 340, DY = 200,},
    WinFN = {X = -230, Y = -80, DX = 200, DY = 200,},
    WinFS = {X = -200, Y = -80, DX = 200, DY = 200,},
    WinFP = {X = -230, Y =  48, DX = 200, DY = 200,},
  },
}
local AGT = {
  [0] = {Code="MYGN",Name="For developers",},
  [1] = {Code="DBGN",Name="Bandits Clan",},
  [2] = {Code="SBMI",Name="Solstheim bards",},
  [3] = {Code="DCGN",Name="Domain Community",},
}
AGT.MaxNumber = 3
DBGN.AvlGuildType = setmetatable(AGT,
  { __index = function(self, key)
      if type(key) == "string" then
        for i=0,self.MaxNumber do
          if self[i].Code == key then return i end
        end
      end
      return nil
    end
  }
)
--
DBGN.WorldName = GetWorldName()
if     DBGN.WorldName == "NA Megaserver"
  then DBGN.WorldName =  "NA"
elseif DBGN.WorldName == "EU Megaserver"
  then DBGN.WorldName =  "EU"
end
DBGN.PredefinedGuild = {
  ["EU"] = {
    ["Bandits Clan"]		= {Type=1,},
    ["Daggerfall Bandits"]	= {Type=1,},
    ["Bandits Force"]		= {Type=1,},
    ["Bandits Lair"]		= {Type=1,},
    ["Bandits Black Market"]	= {Type=1,},
    ["Solstheim bards"]		= {Type=2,},
    ["My domain"]		= {Type=3,},
    ["Steel Domain"]		= {Type=3,},
    ["Fire Domain"]		= {Type=3,},
  },
}
--
DBGN.Icons = {
  OnLine  = "EsoUI/Art/Contacts/social_status_online.dds",
  OffLine = "EsoUI/Art/Contacts/social_status_offline.dds",
  Note = {
    Alt = {
      normal    = "DBGN/icons/note_up.dds",
      pressed   = "DBGN/icons/note_down.dds",
      mouseOver = "DBGN/icons/note_over.dds",
    },
    Original = {
      normal    = "EsoUI/Art/Contacts/social_note_up.dds",
      pressed   = "EsoUI/Art/Contacts/social_note_down.dds",
      mouseOver = "EsoUI/Art/Contacts/social_note_over.dds",
    },
  },
  Craft = {
    Alch = "DBGN/icons/xAlchemy.dds",
    Prov = "DBGN/icons/xProvision.dds",
    Ench = "DBGN/icons/xRune.dds",
    Shld = "DBGN/icons/xShield.dds",
    WWp  = "DBGN/icons/xStaff.dds",
    WBl  = "DBGN/icons/xSword.dds",
    Jew  = "DBGN/icons/xJewelery.dds",
    Arm  = "DBGN/icons/xArmor.dds",
    Weap = "DBGN/icons/xWeapon.dds",
    Bag  = "DBGN/icons/xBag.dds",
    Arm1 = "DBGN/icons/yArmor.dds",
    Wea1 = "DBGN/icons/yWeapon.dds",
    Bag1 = "DBGN/icons/yBag.dds",
  },
  FltrBt = {
    ShowOn = "DBGN/icons/Hide.dds",
    ShowOff = "DBGN/icons/Hide1.dds",
    EnabledOn = "DBGN/icons/Filter.dds",
    EnabledOff = "DBGN/icons/Filter1.dds",
    WithoutGNOn = "DBGN/icons/List.dds",
    WithoutGNOff = "DBGN/icons/List1.dds",
  },
}
DBGN.IconsDC = {
  Blk = {
    On  = "esoui/art/icons/skilllinexp_blacksmithing.dds",
    Off = "DBGN/icons/dc_blacksmithing.dds",
  },
  WWr = {
    On  = "esoui/art/icons/skilllinexp_woodworking.dds",
    Off = "DBGN/icons/dc_woodworking.dds",
  },
  Clt = {
    On  = "esoui/art/icons/skilllinexp_clothier.dds",
    Off = "DBGN/icons/dc_clothier.dds",
  },
  Ench = {
    On  = "esoui/art/icons/skilllinexp_enchanting.dds",
    Off = "DBGN/icons/dc_enchanting.dds",
  },
  Alch = {
    On  = "esoui/art/icons/skilllinexp_alchemy.dds",
    Off = "DBGN/icons/dc_alchemy.dds",
  },
  Jew = {
    On  = "esoui/art/icons/skilllinexp_jewelrymaking.dds",
    Off = "DBGN/icons/dc_jewelrymaking.dds",
  },
  Prov = {
    On  = "esoui/art/icons/skilllinexp_provisioner.dds",
    Off = "DBGN/icons/dc_provisioner.dds",
  },
}
DBGN.TbColors = {}
DBGN.Colors = {
  Mdl = {
    [1] = "555555", -- Grey
    [2] = "CFDCBD", -- Normal
    [3] = "77FF77", -- Green
    [4] = "779CFF", -- Deep Blue
    [5] = "F1FF77", -- Yellow
    [6] = "FF7D77", -- Red
    [7] = "D0D0FF", -- Blue
    [8] = "D5B526", -- Gold
  },
  none = 1,
  on   = 3,
  off  = 1,
  Error = 6,
  m_beg = "|c",
  m_end = "|r",
  Trials = {
    All={[0]=1,[1]=2,[2]=3,[3]=5,[4]=7},
    SS ={[0]=1,[1]=2,[2]=3,[3]=3,[4]=3,[5]=5,[6]=7},
    KA ={[0]=1,[1]=2,[2]=3,[3]=3,[4]=3,[5]=5,[6]=7},
    RG ={[0]=1,[1]=2,[2]=3,[3]=3,[4]=3,[5]=5,[6]=7},
    DSR={[0]=1,[1]=2,[2]=3,[3]=3,[4]=3,[5]=5,[6]=7},
    AS ={[0]=1,[1]=2,[2]=2,[3]=2,[4]=3,[5]=3,[6]=5,[7]=7},
    CR ={[0]=1,[1]=2,[2]=2,[3]=2,[4]=3,[5]=3,[6]=3,[7]=5,[8]=7},
    SE ={[0]=1,[1]=2,[2]=3,[3]=3,[4]=3,[5]=5,[6]=7},
    LC ={[0]=1,[1]=2,[2]=3,[3]=3,[4]=3,[5]=5,[6]=7},
    OC ={[0]=1,[1]=2,[2]=3,[3]=3,[4]=3,[5]=5,[6]=7},
  },
  PvP_DC = {[0]=1,[1]=2,[2]=3,[3]=3,[4]=5,[5]=5},
}
DBGN.IcoPref24 = "|t24:24:"
DBGN.IcoPref16 = "|t16:16:"
DBGN.IcoSuff = "|t"
DBGN.Markers = {
  WBl  = DBGN.IcoPref16 .. DBGN.Icons.Craft.WBl .. DBGN.IcoSuff,
  WWp  = DBGN.IcoPref16 .. DBGN.Icons.Craft.WWp .. DBGN.IcoSuff,
  Jew  = DBGN.IcoPref16 .. DBGN.Icons.Craft.Jew .. DBGN.IcoSuff,
  Shld = DBGN.IcoPref16 .. DBGN.Icons.Craft.Shld .. DBGN.IcoSuff,
  Ench = DBGN.IcoPref16 .. DBGN.Icons.Craft.Ench .. DBGN.IcoSuff,
  Alch = DBGN.IcoPref16 .. DBGN.Icons.Craft.Alch .. DBGN.IcoSuff,
  Prov = DBGN.IcoPref16 .. DBGN.Icons.Craft.Prov .. DBGN.IcoSuff,
}
DBGN.MarkersGr = {
  Prov = {[0]="none",[1]="norm",[2]="Amb",  [3]="Amb+"},
  AA   = {[0]="-AA", [1]="nAA", [2]="vAA",  [3]="hmAA"},
  SO   = {[0]="-SO", [1]="nSO", [2]="vSO",  [3]="hmSO"},
  HRC  = {[0]="-HRC",[1]="nHRC",[2]="vHRC", [3]="hmHRC"},
  DSA  = {[0]="-DSA",[1]="nDSA",[2]="vDSA", [3]="??DSA"},
  BRP  = {[0]="-BRP",[1]="nBRP",[2]="vBRP", [3]="??BRP"},
  MSA  = {[0]="-MSA",[1]="nMSA",[2]="vMSA", [3]="prMSA"},
  VH   = {[0]="-VH", [1]="nVH", [2]="vVH",  [3]="prVH"},
  MoL  = {[0]="-MoL",[1]="nMoL",[2]="vMoL", [3]="hmMoL",  [4]="MoL DmD"},
  HoF  = {[0]="-HoF",[1]="nHoF",[2]="vHoF", [3]="hmHoF",  [4]="HoF TTT"},
  AS   = {[0]="-AS", [1]="nAS", [2]="nAS+1",[3]="nAS+2",  [4]="vAS",    [5]="vAS+1", [6]="hmAS", [7]="AS IR"},
  CR   = {[0]="-CR", [1]="nCR", [2]="nCR+2",[3]="nCR+3",  [4]="vCR",    [5]="vCR+1", [6]="vCR+2",[7]="hmCR",[8]="CR GH"},
  SS   = {[0]="-SS", [1]="nSS", [2]="vSS",  [3]="vSS 1h", [4]="vSS 2h", [5]="hmSS",  [6]="SS GS"},
  KA   = {[0]="-KA", [1]="nKA", [2]="vKA",  [3]="vKA 1h", [4]="vKA 2h", [5]="hmKA",  [6]="KA DB"},
  RG   = {[0]="-RG", [1]="nRG", [2]="vRG",  [3]="vRG 1h", [4]="vRG 2h", [5]="hmRG",  [6]="RG PB"},
  DSR  = {[0]="-DSR",[1]="nDSR",[2]="vDSR", [3]="vDSR 1h",[4]="vDSR 2h",[5]="hmDSR", [6]="DSR SbS"},
  SE   = {[0]="-SE", [1]="nSE", [2]="vSE",  [3]="vSE 1h", [4]="vSE 2h", [5]="hmSE",  [6]="SE DM"},
  LC   = {[0]="-LC", [1]="nLC", [2]="vLC",  [3]="vLC 1h", [4]="vLC 2h", [5]="hmLC",  [6]="LC AS"},
  OC   = {[0]="-OC", [1]="nOC", [2]="vOC",  [3]="vOC 1h", [4]="vOC 2h", [5]="hmOC",  [6]="OC LS"},
--  PvP  = {[0]="none",[1]="*",[2]="**",[3]="***",[4]="****",[5]="*****"},
  Heal = {[0]="none",[1]="Normal",[2]="Veteran",[3]="Master",[4]="Superior"},
  Tank = {[0]="none",[1]="Normal",[2]="Veteran",[3]="Master",[4]="Superior"},
--
  Cmp  = {[1]=" ",[2]="=",[3]=">=",[4]="<="},
  TrlDung ={[1]="AA",[2]="SO",[3]="HRC",[4]="MoL",[5]="HoF",[6]="AS",[7]="CR",[8]="SS",[9]="KA",[10]="RG",[11]="DSR",[12]="SE",[13]="LC",[14]="OC",[15]="DSA",[16]="BRP",[17]="MSA",[18]="VH"},
  TrlVal = {[1]="none",[2]="Normal",[3]="Veteran",[4]="HM / PR"},
}
DBGN.Trial_Max   = {MoL = 4, HoF = 4, AS = 7, CR = 8, SS = 6, KA = 6, RG = 6, DSR = 6, SE = 6, LC = 6, OC = 6}
DBGN.Trial_v3_to_v4 = {
  AS   = {[0]=0, [1]=1, [2]=4, [3]=6},
  CR   = {[0]=0, [1]=1, [2]=4, [3]=7},
  SS   = {[0]=0, [1]=1, [2]=2, [3]=5},
}
DBGN.Trial_for_filter = {
  MoL  = {[0]=0, [1]=1, [2]=2, [3]=3, [4]=3},
  HoF  = {[0]=0, [1]=1, [2]=2, [3]=3, [4]=3},
  AS   = {[0]=0, [1]=1, [2]=1, [3]=1, [4]=2, [5]=2, [6]=3, [7]=3},
  CR   = {[0]=0, [1]=1, [2]=1, [3]=1, [4]=2, [5]=2, [6]=2, [7]=3, [8]=3},
  SS   = {[0]=0, [1]=1, [2]=2, [3]=2, [4]=2, [5]=3, [6]=3},
  KA   = {[0]=0, [1]=1, [2]=2, [3]=2, [4]=2, [5]=3, [6]=3},
  RG   = {[0]=0, [1]=1, [2]=2, [3]=2, [4]=2, [5]=3, [6]=3},
  DSR  = {[0]=0, [1]=1, [2]=2, [3]=2, [4]=2, [5]=3, [6]=3},
  SE   = {[0]=0, [1]=1, [2]=2, [3]=2, [4]=2, [5]=3, [6]=3},
  LC   = {[0]=0, [1]=1, [2]=2, [3]=2, [4]=2, [5]=3, [6]=3},
  OC   = {[0]=0, [1]=1, [2]=2, [3]=2, [4]=2, [5]=3, [6]=3},
}