local myNAME = "merCharacterSheet"
local settext = LibGetText(myNAME).settext

settext("|c<<1>><<C:2>>|r recently upgraded a riding skill. S/he can train again in <<3>>.",
        "|c<<1>><<C:2>>|r recently upgraded a riding skill. <<Cp:2>> can train again in <<3>>.")

settext("|c<<1>><<C:2>>|r is ready to train a riding skill.",
        "|c<<1>><<C:2>>|r is ready to train a riding skill.")
