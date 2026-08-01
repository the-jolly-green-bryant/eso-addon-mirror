local myNAME = "merCharacterSheet"
local settext = LibGetText(myNAME).settext

settext("|c<<1>><<C:2>>|r recently upgraded a riding skill. S/he can train again in <<3>>.",
        "|c<<1>><<C:2>>|r hat kürzlich eine Reitfähigkeit verbessert. In <<3>> kann <<p:2>> sie erneut steigern.")

settext("|c<<1>><<C:2>>|r is ready to train a riding skill.",
        "|c<<1>><<C:2>>|r kann nun eine Reitfähigkeit erlernen.")
