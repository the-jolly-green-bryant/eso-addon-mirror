INSTACELEAVER = {}
INSTACELEAVER.version = 0.2
INSTACELEAVER.author = "Vaalhazac"

function INSTACELEAVER.LeaveInstance()
    if CanExitInstanceImmediately() then
        ExitInstanceImmediately()
    else
        d("Instance Leaver: Cannot leave the current instance right now.")
    end
end

