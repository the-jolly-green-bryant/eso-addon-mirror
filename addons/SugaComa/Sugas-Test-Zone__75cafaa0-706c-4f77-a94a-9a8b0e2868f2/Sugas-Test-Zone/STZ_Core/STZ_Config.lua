SUGAS_TEST_ZONE = SUGAS_TEST_ZONE or {}
local STZ = SUGAS_TEST_ZONE

function STZ:Log(message)
    if type(d) == "function" then
        d(tostring(message or ""))
    end
end

STZ.Config = {
    addonName = "Sugas-Test-Zone",
    version = "0.3.2-test1",
    access = {
        -- Deployment values are the rules shipped to testers.
        -- Before distributing a guild-test build, place the approved numeric
        -- guild IDs here and set deploymentMode to "guild".
        deploymentMode = "private", -- private | guild | public
        deploymentGuildIds = {
            -- 123456,
            -- 789012,
        },

        -- Runtime values are restored from the deployment values. Only the
        -- owner account may locally change them through LHAS for testing.
        mode = "private",
        approvedGuildIds = {},

        ownerAccounts = {
            ["@SugaComa"] = true,
        },
    },
    notice = {
        authorName = "SugaComa",
        releaseCandidateText = "0.x.x RC",
        stableReleaseText = "1.0.0 or higher",
    },
}
