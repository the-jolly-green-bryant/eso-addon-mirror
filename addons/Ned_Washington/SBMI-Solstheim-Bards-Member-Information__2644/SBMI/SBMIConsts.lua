SBMI = {
  Name = "SBMI",
  Version = "0.1.2",
  DefXY = {
    WinFN = {X = -250, Y = -80, DX = 200, DY = 200,},
    WinFS = {X = -220, Y = -80, DX = 200, DY = 200,},
    WinFP = {X = -250, Y =  48, DX = 200, DY = 200,},
  },
  DungCount = 30,
}
SBMI.MarkersGr = {
  Ambr = {[1]="50",[2]="100",[3]="150"},
  AmbF = {[1]=" ",[2]="50",[3]="100",[4]="150"},
  DDRT = {[1]=2,[2]=3,[3]=5},
  PvEC = {[1]=4,[2]=3,[3]=5},
}
SBMI.MelodyCosts = {
  DSA = {[2]=4},
  BRP = {[2]=10,[3]=25,},
  Crag= {[1]=1, [2]=4, [3]=10,},
  MoL = {[1]=1, [2]=10,[3]=20,[4]=50,},
  HoF = {[1]=1, [2]=20,[3]=30,[4]=50,},
  AS  = {[1]=1, [2]=2 ,[3]=2 ,[4]=10,[5]=20,[6]=40,[7]=50,},
  CR  = {[1]=1, [2]=1, [3]=3, [4]=20,[5]=30,[6]=40,[7]=50,[8]=60,},
  SS  = {[1]=1, [2]=20,[3]=30,[4]=40,[5]=50,[6]=60,},
  KA  = {[1]=1, [2]=20,[3]=30,[4]=40,[5]=50,[6]=60,},
  RG  = {[1]=1, [2]=20,[3]=30,[4]=40,[5]=50,[6]=60,},
  DSR = {[1]=1, [2]=20,[3]=30,[4]=40,[5]=50,[6]=60,},
  SE  = {[1]=1, [2]=20,[3]=30,[4]=40,[5]=50,[6]=60,},
  LC  = {[1]=1, [2]=20,[3]=30,[4]=40,[5]=50,[6]=60,},
  OC  = {[1]=1, [2]=20,[3]=30,[4]=40,[5]=50,[6]=60,},
  Dng = {[1]=3, [2]=15,},
}
SBMI.DungColor = {[0]=1,[1]=2,[2]=3,[3]=6,}
SBMI.Icons = {
  Melody = {
    On  = "SBMI/icons/Melody.dds",
    Off = "SBMI/icons/Melody1.dds",
  },
  Blk = {
    On  = "SBMI/icons/BlackSmith.dds",
    Off = "SBMI/icons/BlackSmith1.dds",
  },
  WWr = {
    On  = "SBMI/icons/Woodworker.dds",
    Off = "SBMI/icons/Woodworker1.dds",
  },
  Clt = {
    On  = "SBMI/icons/Clothier.dds",
    Off = "SBMI/icons/Clothier1.dds",
  },
  Ench = {
    On  = "SBMI/icons/Ench.dds",
    Off = "SBMI/icons/Ench1.dds",
  },
  Alch = {
    On  = "SBMI/icons/Alchemy.dds",
    Off = "SBMI/icons/Alchemy1.dds",
  },
  Jew = {
    On  = "SBMI/icons/Jewerly.dds",
    Off = "SBMI/icons/Jewerly1.dds",
  },
  Prov = {
    On  = "SBMI/icons/Cook.dds",
    Off = "SBMI/icons/Cook1.dds",
  },
  Ambr = {
    On  = "SBMI/icons/Ambr.dds",
    Off = "SBMI/icons/Ambr1.dds",
  },
  Cross = {
    On  = "SBMI/icons/Cross.dds",
    Off = "SBMI/icons/Cross1.dds",
  },
}
SBMI.RankIcons = {}
for i = 1, 10 do SBMI.RankIcons[i] = "SBMI/icons/Rank_" .. i .. ".dds" end