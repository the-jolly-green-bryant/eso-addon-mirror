-- DDPositions_Data.lua
DDPositions = DDPositions or {}
local DDP = DDPositions

DDP.version = "3.1.4"
DDP.autor = "@Zaan's"

DDP.positions = {
	[636] = { mechOrder = {"2Groups"}, mechanics = {["2Groups"] = {"Upstairs","Upstairs","Upstairs","Upstairs","Downstairs","Downstairs","Downstairs","Downstairs"}} },
	[725] = {
        mechOrder = {"2Groups", "Runner"},
        mechanics = {
            ["2Groups"] = {"Exit","Exit","Exit","Exit","Entrance","Entrance","Entrance","Entrance"},
            ["Runner"] = {"R.Left", "R.Middle", "R.Right"},
        },
    },
	[975] = {
        mechOrder = {"Portals", "2Groups"},
        mechanics = {
            ["Portals"] = {"N","S","W","E"},
            ["2Groups"] = {"Left","Left","Left","Left","Right","Right","Right","Right",},
        },
    },
    [1000] = { mechOrder = {"Positions"}, mechanics = {["Positions"] = {"1","2","3","4","5","6","7","8"}} },
    [1051] = { mechOrder = {"Portals", "Orbs"}, mechanics = {["Portals"] = {"P1","P1","P2","P2"}, ["Orbs"] = {"Orbs"}} },
    [1121] = {
        mechOrder = {"Tombs", "Head&Wing", "Portals", "Positions(HM)", "Tombs(HM)"},
        mechanics = {
            ["Tombs"] = {"T1","T2","T3"},
            ["Head&Wing"] = {"Head","Head","Head","Head","Wing","Wing","Wing","Wing"},
            ["Portals"] = {"P.Left","P.Middle","P.Right"},
            ["Positions(HM)"] = {"1","2","3","4","5","6","7","8"},
            ["Tombs(HM)"] = {"T1A","T1B","T2A","T2B","T3A","T3B"},
        },
    },
    [1196] = {
        mechOrder = {"Positions", "Boat", "Line", "Stack(HM)"},
        mechanics = {
            ["Positions"] = {"1","2","3","4","5","6","7","8"},
            ["Boat"] = {"Boat"},
            ["Line"] = {"Line1","Line2","Line3","Line4","Line5"},
            ["Stack(HM)"] = {"1","1","2","2","3","3","4","4"},
        },
    },
    [1263] = { mechOrder = {"Kite"}, mechanics = {["Kite"] = {"Kite"}} },
    [1344] = {
        mechOrder = {"Interrupts", "Reefs", "Bridges", "Interrupts(HM)"},
        mechanics = {
            ["Interrupts"] = {"Exit.R & Swap","Exit.L & Swap","Entrance.R","Entrance.L"},
            ["Reefs"] = {"12-5-8","3-6-9","4-7-10"},
            ["Bridges"] = {"B1","B1","B2","B2","B3","B3"},
            ["Interrupts(HM)"] = {"Exit.R","Exit.L","Entrance.R","Entrance.L","Exit.R","Exit.L","Entrance.R","Entrance.L"},
        },
    },
    [1427] = {
        mechOrder = {"Portals", "2Groups", "Ansuul Portal"},
        mechanics = {
            ["Portals"] = {"P1","P1","P1","P1","P2","P2","P2","P2"},
            ["2Groups"] = {"Left","Left","Left","Left","Right","Right","Right","Right"},
            ["Ansuul Portal"] = {"+Portal","+Portal","+Portal"},
        },
    },
    [1478] = {
        mechOrder = {"2Groups", "Mirrors"},
        mechanics = {
            ["2Groups"] = {"Dark","Dark","Dark","Dark","Light","Light","Light","Light"},
            ["Mirrors"] = {"N","S","E","W","NE","SE","SW","NW"},
        },
    },
	[1548] = {
        mechOrder = {"Portal", "2Groups"},
        mechanics = {
            ["Portal"] = {"+P","+P","+P","+P"},
            ["2Groups"] = {"Left","Left","Left","Left","Right","Right","Right","Right"},
        },
    },
}
