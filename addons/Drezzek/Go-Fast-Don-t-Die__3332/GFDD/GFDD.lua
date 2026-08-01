GFDD = {}
GFDD.name = "GFDD"
 
function GFDD:Initialize()
  SLASH_COMMANDS["/gfdd"] = ShowScore
end

function GFDD.OnAddOnLoaded(event, addonName)
  if addonName == GFDD.name then
    GFDD:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(GFDD.name, EVENT_ADD_ON_LOADED, GFDD.OnAddOnLoaded)

-- Scores and rank tables

BaseScores = {}
DLCScores = {}
GFDDRanks = {}

BaseScores = {VET = 5, HM = 15, SR = 10, ND = 15, CHA = 10}
DLCScores = {VET = 10, HM = 30, SR = 20, ND = 30, CHA = 20, TRI = 50}
GFDDRanks = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110} 

-- Calculate scores and max points

function ShowScore()

  -- Set up variables

  local t
  BaseCounter = 0 --Counts number of base dungeons for calculating max score
  DLCCounter = 0  --Counts number of DLC dungeons for calculating max score
  BaseDungeonCounter = 0 --Base dungeon running score
  DLCDungeonCounter = 0 --DLC dungeon running score
  DLCCHACounter = 0 -- Counts number of DLCs with challenger achievements
  DLCTRICounter = 0 -- Counts number of DLCs with trifecta achievements
  BaseDungeonMax = 0  --Base dungeon maximum possible score
  DLCDungeonMax = 0  --DLC dungeon maximum possible score
  GFDDMax = 0 -- Total maximum possible score
  MaxScore = 0 --total maximum score
  TotalScore = 0 -- Player's current GFDD score
 
  for t = 1,#DB,1 do

     -- Check all DLC dungeons
     if (DB[t].TYPE == "dungeon") then
        -- Count total DLC dungeons for Max Score calculation
        DLCDungeonCounter = DLCDungeonCounter + 1
        if(DB[t].CHA) then  -- needed because some dungeons do not have Challenger Achievements
          DLCCHACounter = DLCCHACounter + 1
        end
        if(DB[t].TRI) then  -- needed because some dungeons do not have Trifecta Achievements
          DLCTRICounter = DLCTRICounter + 1
        end
        -- Check Vet Completion
        local name, description, points, icon, completed, date, time = GetAchievementInfo(DB[t].VET)
        if completed then
           DLCCounter = DLCCounter + DLCScores.VET
        end 
        -- Check Hard Mode Completion
        local name, description, points, icon, completed, date, time = GetAchievementInfo(DB[t].HM)
        if completed then
           DLCCounter = DLCCounter + DLCScores.HM
        end
        -- Check Speed Run Completion
        local name, description, points, icon, completed, date, time = GetAchievementInfo(DB[t].SR)
        if completed then
           DLCCounter = DLCCounter + DLCScores.SR
        end
        -- Check No Death Completion
        local name, description, points, icon, completed, date, time = GetAchievementInfo(DB[t].ND)
        if completed then
           DLCCounter = DLCCounter + DLCScores.ND
        end
        -- Check Challenger Completion
        local name, description, points, icon, completed, date, time = GetAchievementInfo(DB[t].CHA)
        if completed then
           DLCCounter = DLCCounter + DLCScores.CHA
        end
        -- Check Trifecta Completion
        local name, description, points, icon, completed, date, time = GetAchievementInfo(DB[t].TRI)
        if completed then
           DLCCounter = DLCCounter + DLCScores.TRI
        end   
     end

    -- Check all Base Game dungeons
     if (DB[t].TYPE == "baseDungeon") then
        -- Count total Base dungeons for Max Score calculation
        BaseDungeonCounter = BaseDungeonCounter + 1
        -- Check Vet Completion
        local name, description, points, icon, completed, date, time = GetAchievementInfo(DB[t].VET)
        if completed then
           BaseCounter = BaseCounter + BaseScores.VET
        end 
        -- Check Hard Mode Completion
        local name, description, points, icon, completed, date, time = GetAchievementInfo(DB[t].HM)
        if completed then
           BaseCounter = BaseCounter + BaseScores.HM
        end
        -- Check Speed Run Completion
        local name, description, points, icon, completed, date, time = GetAchievementInfo(DB[t].SR)
        if completed then
           BaseCounter  = BaseCounter + BaseScores.SR
        end
        -- Check No Death Completion
        local name, description, points, icon, completed, date, time = GetAchievementInfo(DB[t].ND)
        if completed then
           BaseCounter = BaseCounter + BaseScores.ND
        end
     end


  end -- end of loop through entire DB table

-- Calculate Total Score
TotalScore = BaseCounter + DLCCounter

-- Calculate Max Score

BaseDungeonMax = BaseDungeonCounter * (BaseScores.VET + BaseScores.HM + BaseScores.SR + BaseScores.ND)
DLCDungeonMax = DLCDungeonCounter * (DLCScores.VET + DLCScores.HM + DLCScores.SR + DLCScores.ND) + (DLCCHACounter * DLCScores.CHA) + (DLCTRICounter * DLCScores.TRI)
GFDDMax = BaseDungeonMax + DLCDungeonMax

--Calculate Rank

PlayerRank = 0

-- TotalScore = 0 -- TESTING ONLY.  

for a = 1,(#GFDDRanks - 1),1 do

  if(TotalScore < (GFDDMax * (GFDDRanks[a+1]/100)) and TotalScore >= (GFDDMax * (GFDDRanks[a]/100))) then
     if(PlayerRank) then
       PlayerRank = a
     end
  end

end

-- Calculate points needed for next rank

PointGap = (GFDDMax * (GFDDRanks[PlayerRank + 1]/100)) - TotalScore

-- Print Player's score and max score in chat window.

d("|c00FFFFYour GFDD Score is |cFFFFFF" .. tostring(TotalScore) .. "|c00FFFF of |cFFFFFF" .. tostring(GFDDMax) .. "|c00ffff (Rank " .. tostring(PlayerRank) .. ").")

-- Print Player's points needed for next rank in chat window

if(PlayerRank == (#GFDDRanks - 1)) then
  d("|c00FFFFYou are at the highest rank! Way to go fast and not die!")
else
  d("|c00FFFFYou need |cFFFFFF" .. tostring(PointGap) .. "|c00FFFF points to reach Rank " .. tostring(PlayerRank +1) .. ".")
end

end