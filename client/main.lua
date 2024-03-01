---@type table<string, Job>
local Jobs = exports.qbx_core:GetJobs()

RegisterNetEvent("qbx_core:client:onJobUpdate", function (jobName, job)
    Jobs[jobName] = job
end)

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
    local jobs = {}

    for jobName, jobGrade in pairs(QBX.PlayerData.jobs) do
        local jobData = Jobs[jobName]
        if jobData then
            jobs[#jobs+1] = {
                name = jobName,
                label = jobData.label,
                gradeLabel = jobData.grades[jobGrade]?.name or "Invalid Grade",
                isCurrentlyJob = QBX.PlayerData.job.name == jobName
            }
        else
            jobs[#jobs+1] = {
                name = jobName,
                label = ("Invalid Job (%s)"):format(jobName),
                gradeLabel = "Invalid Grade",
                isCurrentlyJob = QBX.PlayerData.job.name == jobName
            }
        end
    end

    table.sort(jobs, function (a, b)
        return a.label < b.label
    end)

    for _, job in pairs(jobs) do
        opts[#opts+1] = {
            title = job.label,
            description = job.gradeLabel,
            disabled = job.isCurrentlyJob,
            onSelect = function ()
                local success, result = lib.callback.await("gmn_qboxmultijob:server:workAt", false, job.name)
                if success then
                    exports.qbx_core:Notify(locale("success.employed", job.label), "success", 5000)
                else
                    exports.qbx_core:Notify(locale("error." .. tostring(result)), "error", 5000)
                end
            end
        }
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