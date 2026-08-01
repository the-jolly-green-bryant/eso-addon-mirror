GankProbability = {
    name = "GankProbability",
    version = "1.0.0",
    author = "@Drako-Ei",
    command = "/gankprobability",
    description = "A simple neural network based gank probability calculator",
    internal = {},
    storageName = "GankProbabilityStorage",
    menuName = "GankProbability Settings",
    savedVars = {},
    defaultVars = {
        version = "1.0.0",
        reticleX = 0,
        reticleY = 50,
        reticleSize = 2,
        active = true,
        dataCollection = true,
        maxStoragePerClass = 300,
        activeModel = "Imperial City",
        predictionModels = {
            ["Imperial City"] = {
                structure = {20, 6, 2},
                activation = "sigmoid",
                weights = {
                    3,20,6,2,3.1414119480,-1.0631079106,1.2715804062,-1.1040337353,-0.7057912254,2.2340474146,-3.5273307985,2.2415568465,1.2274594935,-2.6948605420,
                    1.6613008516,0.6834426371,-1.4590651967,-1.1310569143,0.4476080330,0.1669865426,-1.5575526614,0.4496928887,1.3871826239,-5.9546800060,-0.2187426426,
                    -0.8907748255,0.0879412409,0.3789418098,-1.4785843925,-0.3749490056,-0.4042422167,0.3267909366,0.6356567849,1.3351773766,-0.3485756454,-0.1574136716,
                    1.0135834428,-1.6644530389,-0.3515257769,-1.0107148151,-0.6730568866,-0.3516705138,0.2710997859,-1.0469667968,0.8598945999,0.9814179444,0.0828429947,
                    -0.4682481086,0.6284661758,-0.1308790125,0.6945093428,1.1311673136,-1.6677432854,-0.0338345725,2.3582979636,-1.2154978115,0.5258693238,-0.2579556656,
                    -0.0755130109,1.2959924616,1.6177091752,-0.2097664164,0.3220549404,-0.0645279668,1.1481909748,-2.7978854910,-1.2129087333,-0.1923018148,-0.1792557986,
                    -1.0746416019,-0.4718810764,0.1555872178,1.4425245706,0.8180332697,-1.5126784290,0.8094572709,-0.0877756621,2.2491420067,0.0884357260,-3.0973716000,
                    -1.1463033571,-0.6295710397,9.1057588988,-5.9474441721,-2.6160576765,0.7404269552,0.6375210778,-0.2418314932,0.4040740750,2.7044604070,0.4077589799,
                    -1.3076571507,-1.0692615849,-0.6800665750,0.0610326521,-0.1917052628,-0.4075773822,-1.0476117142,-0.0356041065,0.6722242706,0.6073614679,2.6530347594,
                    -3.2131010170,-12.7247148441,3.2935870038,-0.9412583009,-0.0938955500,-1.7186458223,0.2367035935,1.1202079594,-2.9142192283,0.1857507361,0.8949277831,
                    -2.2737426356,2.2017220437,0.9180435755,-0.2718641736,-0.5680807251,1.6688731257,-0.1746568587,-1.0001358087,2.1687720636,-1.1355940626,-5.8876774604,
                    3.7751918138,-0.4466142607,-3.7733912248,7.2538785929,9.4531364951,3.3989511812,-3.9373208245,-0.9383608174,3.9152553405,-7.2714375579,-9.4421812461,
                    -3.2679193112,2.7487657521,-2.6880719334,2.1459877455,-1.1379511543,2.3055277867,1.2809790020,-6.4428920508,6.3762036168
                }

            }
        },
        gankAttempts = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
            [5] = {},
            [6] = {},
            [117] = {}
        }
    }
}

local GP = GankProbability
local internal = GP.internal
local cachedProbabilities = {}

function internal.configureReticleDisplay()

    if internal.reticleDisplay == nil then return end
    internal.reticleDisplay:SetFont("ZoFontGame")
    internal.reticleDisplay:SetScale(GP.savedVars.reticleSize)
    internal.reticleDisplay:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, GP.savedVars.reticleX, GP.savedVars.reticleY)
    internal.reticleDisplay:SetHidden(true)

end

function internal.initializeGankProbability()

    GP.savedVars = ZO_SavedVars:New(GP.storageName, 1, nil, GP.defaultVars)

    internal.reticleDisplay = WINDOW_MANAGER:CreateControl(nil, ZO_ReticleContainer, CT_LABEL)
    internal.configureReticleDisplay()
    internal.targettedPlayers = {}

end

function internal.clearReticle()

    internal.reticleDisplay:SetHidden(true)

end

-- Handle reticle change
function internal.onReticleTargetChanged(eventCode)

    internal.clearReticle()
    if not GP.savedVars.active then return end
    if not IsUnitPlayer("reticleover") then return nil end
    if not IsUnitAttackable("reticleover") then return nil end

    local targettedPlayer = internal.getTargettedPlayer("reticleover")
    internal.targettedPlayers[targettedPlayer.name] = targettedPlayer
    local probability = cachedProbabilities[targettedPlayer.name]
    if probability == nil then
        probability = internal.getGankProbability(targettedPlayer)
        cachedProbabilities[targettedPlayer.name] = probability
    end

    if probability <= 33 then
        internal.reticleDisplay:SetColor(1, 0.5, 0.5, 1)
    elseif probability >= 66 then
        internal.reticleDisplay:SetColor(0.5, 1, 0.5, 1)
    else
        internal.reticleDisplay:SetColor(1, 1, 0.5, 1)
    end

    internal.reticleDisplay:SetText(string.format("%d%%", probability))
    internal.reticleDisplay:SetHidden(false)

end



