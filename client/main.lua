---@type table<string, Job>
local Jobs = exports.qbx_core:GetJobs()

-- TODO: Handle dynamically changing jobs from qbx_core.

RegisterCommand('multijob', function (source, args, raw)
    ---@type { [string]: ContextMenuItem } | ContextMenuArrayItem[]
    local opts = {}

    opts[#opts+1] = {
        title = "Unemployed",
        description = "Be free from the reigns of a job!",
        disabled = QBX.PlayerData.job.name == "unemployed",
        onSelect = function ()
            local success, result = lib.callback.await("gmn_qboxmultijob:server:becomeUnemployed")
            if success then
                exports.qbx_core:Notify(locale("success.unemployed"), "success", 5000)
            else
                exports.qbx_core:Notify(locale("error." .. tostring(result)), "error", 5000)
            end
        end
    }

    -- TODO: Sort by alphabetical order.
    for jobName, jobGrade in pairs(QBX.PlayerData.jobs) do
        local jobData = Jobs[jobName]
        if jobData then
            opts[#opts+1] = {
                title = jobData.label,
                description = jobData.grades[jobGrade]?.name or "Invalid Grade",
                disabled = QBX.PlayerData.job.name == jobName,
                onSelect = function ()
                    local success, result = lib.callback.await("gmn_qboxmultijob:server:workAt", false, jobName)
                    if success then
                        exports.qbx_core:Notify(locale("success.employed", jobData.label), "success", 5000)
                    else
                        exports.qbx_core:Notify(locale("error." .. tostring(result)), "error", 5000)
                    end
                end
            }
        else
            opts[#opts+1] = {
                title = "Invalid Job ".. jobName .. " (make sure you configured your jobs correctly!)"
            }
        end
    end

    lib.registerContext({
        id = "gamenew09-multijob",
        title = "Choose a Job to Work For",
        canClose = true,
        options = opts
    })
    lib.showContext("gamenew09-multijob")
end)

TriggerEvent('chat:addSuggestions', {
    {
        name = "/multijob",
        help = "Opens the multijob menu."
    }
})