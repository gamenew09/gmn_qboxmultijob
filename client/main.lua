---@type table<string, Job>
local Jobs = exports.qbx_core:GetJobs()
local sharedConfig = require 'configs.shared'

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
    
    ---@class JobListData
    ---@field name string
    ---@field jobData Job
    ---@field jobGrade JobGradeData
    ---@field isCurrentlyJob boolean

    ---@type JobListData[]
    local jobs = {}

    for jobName, jobGrade in pairs(QBX.PlayerData.jobs) do
        local jobData = Jobs[jobName] or ({
            defaultDuty = false,
            grades = {},
            label = "Invalid Job (" .. jobName .. ")",
            offDutyPay = false,
            type = "invalid"
        } --[[@as Job]])
        local currentJobGrade = jobData.grades[jobGrade] or ({
            name = "Invalid",
            payment = 0,
            bankAuth = false,
            isboss = false,
        } --[[@as JobGradeData]])
        jobs[#jobs+1] = {
            name = jobName,
            jobData = jobData,
            jobGrade = currentJobGrade,
            isCurrentlyJob = QBX.PlayerData.job.name == jobName
        }
    end

    table.sort(jobs, function (a, b)
        if a.isCurrentlyJob then
            return true
        elseif b.isCurrentlyJob then
            return false
        end
        return a.jobData.label < b.jobData.label
    end)

    ---@type ContextMenuProps[]
    local menus = {}

    for _, job in pairs(jobs) do
        opts[#opts+1] = {
            title = job.isCurrentlyJob and ("%s (Active Job)"):format(job.jobData.label) or job.jobData.label,
            description = job.jobGrade.name,
            menu = "gamenew09-multijob:job:" .. job.name,
            metadata = {
                ["Is Boss"] = job.jobGrade.isboss and "Yes" or "No",
                ["Has Bank Access"] = job.jobGrade.bankAuth and "Yes" or "No",
                ["Payment"] = job.jobGrade.payment,
            }
        }
        menus[#menus+1] = {
            id = "gamenew09-multijob:job:" .. job.name,
            title = job.jobData.label,
            menu = "gamenew09-multijob",
            options = {
                {
                    title = "Become Job",
                    disabled = job.isCurrentlyJob,
                    onSelect = function ()
                        local success, result = lib.callback.await("gmn_qboxmultijob:server:workAt", false, job.name)
                        if success then
                            exports.qbx_core:Notify(locale("success.employed", job.jobData.label), "success", 5000)
                        else
                            exports.qbx_core:Notify(locale("error." .. tostring(result)), "error", 5000)
                        end
                    end
                },
                sharedConfig.leaveJobFromMenu and ({
                    title = "Leave Job",
                    onSelect = function ()
                        if lib.alertDialog({
                            header = locale("leavejobalert.title"),
                            content = locale("leavejobalert.content", job.jobData.label),
                            cancel = true,
                            labels = {
                                cancel = "No",
                                confirm = "Yes",
                            },
                            centered = true,
                            size = 'lg',
                        }) == 'confirm' then
                            local success, result = lib.callback.await("gmn_qboxmultijob:server:leaveJob", false, job.name)
                            if success then
                                exports.qbx_core:Notify(locale("success.leftjob", job.jobData.label), "success", 5000)
                            else
                                exports.qbx_core:Notify(locale("error." .. tostring(result)), "error", 5000)
                            end
                        end
                    end
                } --[[@as ContextMenuArrayItem]]) or nil
            }
        }
    end

    lib.registerContext({
        id = "gamenew09-multijob",
        title = "Choose a Job to Work For",
        canClose = true,
        options = opts
    })
    lib.registerContext(menus)
    lib.showContext("gamenew09-multijob")
end)

TriggerEvent('chat:addSuggestions', {
    {
        name = "/multijob",
        help = "Opens the multijob menu."
    }
})