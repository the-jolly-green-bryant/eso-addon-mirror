-- globals
deaglTT = {}
deaglTT.Name = "TeleportTool"
deaglTT.AppName = "Teleport Tool"
deaglTT.Author = "deagl0r´s"
deaglTT.Version= "1.23.0619.0"
deaglTT.Loaded = true
-- std color
deaglTT.Color = { 
  "|c77ff7a", -- 1, Grün    - Friend-Member
  "|cf1ff77", -- 2, Gelb    - Target teleport, important info
  "|cff7d77", -- 3, Rot     - Group-Member
  "|cd5d1d1", -- 4. Grau    - [Offline]
  "|ceeeeee", -- 5, Weiß    - Guild/Zone-Member
  "|c779cff", -- 6, Blau    - App-Name | Title
  "|cff3300", -- 7
  "|c2f2f2f", -- 8
  "|c6f6f6f", -- 9
}
deaglTT.ColordInitMsg = deaglTT.Color[6].. deaglTT.Author.. " ".. deaglTT.Color[5].. deaglTT.AppName.. " v.".. deaglTT.Version
deaglTT.ColoredName = deaglTT.Color[6] .. deaglTT.AppName
deaglTT.ChatLineHeader = deaglTT.Color[6].. deaglTT.AppName.. deaglTT.Color[5].. ": "
deaglTT.ColoredVersion = deaglTT.Color[6] .. deaglTT.Version
deaglTT.Settings = {}
deaglTT.Lib = {}
deaglTT.Teleport = {}                            