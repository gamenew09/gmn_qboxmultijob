if not lib.checkDependency("qbx_core", "1.7.1", true) then error("checkDependency error") return end

---@type table<string, Job>
local Jobs = exports.qbx_core:GetJobs()

AddEventHandler("qbx_core:server:onJobUpdate", function (jobName, job)
    Jobs[jobName] = job
end)

lib.callback.register("gmn_qboxmultijob:server:becomeUnemployed", function (source)
    ---@type Player|nil
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return false, "not_logged_in"
    end

    local s, r = pcall(function ()
    exports.qbx_core:SetPlayerPrimaryJob(player.PlayerData.citizenid, "unemployed")
    end)

    if not s then
        lib.print.error("Failed to set player's primary job to unemployed: ", r)
    end

    player = exports.qbx_core:GetPlayer(source)--[[ @type Player|nil ]]
    if player and player.PlayerData.job.name == "unemployed" then
        return true
    else
        return false, "unknown_error"
    end
end)

lib.callback.register("gmn_qboxmultijob:server:workAt", function (source, jobName)
    ---@type Player|nil
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return false, "not_logged_in"
    end

    if not Jobs[jobName] then
        return false, "job_not_exist"
    end

    local s, r = pcall(function ()
    exports.qbx_core:SetPlayerPrimaryJob(player.PlayerData.citizenid, jobName)
    end)

    if not s then
        lib.print.error(("Failed to set player's primary job to %s: "):format(jobName), r)
    end

    player = exports.qbx_core:GetPlayer(source)--[[ @type Player|nil ]]
    if player and player.PlayerData.job.name == jobName then
        return true
    else
        return false, "unknown_error"
    end
end)