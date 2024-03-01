---@type table<string, Job>
local Jobs = exports.qbx_core:GetJobs()

-- TODO: Handle dynamically changing jobs from qbx_core.


lib.callback.register("gmn_qboxmultijob:server:becomeUnemployed", function (source)
    ---@type Player|nil
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return false, "not_logged_in"
    end

    exports.qbx_core:SetPlayerPrimaryJob(player.PlayerData.citizenid, "unemployed")
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

    exports.qbx_core:SetPlayerPrimaryJob(player.PlayerData.citizenid, jobName)
    player = exports.qbx_core:GetPlayer(source)--[[ @type Player|nil ]]
    if player and player.PlayerData.job.name == jobName then
        return true
    else
        return false, "unknown_error"
    end
end)