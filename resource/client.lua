if not lib.checkDependency('stevo_lib', '1.6.0') then
    error('uk_policebadge requires stevo_lib 1.6.0 or newer.')
end

lib.locale()

local config = lib.require('config')
local stevo_lib = exports['stevo_lib']:import()
local CURRENTLY_USING_BADGE = false

local function isAuthorisedJob()
    local job = stevo_lib.GetPlayerGroups()
    if type(job) == 'table' then
        job = job[1]
    end

    for i = 1, #(config.job_names or {}) do
        if config.job_names[i] == job then
            return true
        end
    end

    return false
end

local function getNearbyServerIds()
    local radius = tonumber(config.badge_show_radius) or 3.0
    local players = lib.getNearbyPlayers(GetEntityCoords(PlayerPedId()), radius, false)
    local nearby = {}

    for i = 1, #players do
        nearby[#nearby + 1] = GetPlayerServerId(players[i].id)
    end

    return nearby
end

local function showBadge()
    CURRENTLY_USING_BADGE = true

    local badgeData = lib.callback.await('uk_policebadge:retrieveInfo', false)
    SendNUIMessage({
        type = 'displayBadge',
        data = badgeData,
        hideAfter = config.badge_show_time
    })

    local nearby = getNearbyServerIds()
    if #nearby > 0 then
        TriggerServerEvent('uk_policebadge:showbadge', badgeData, nearby)
    end

    local progress = config.progress or {}
    lib.progressBar({
        duration = config.badge_show_time,
        label = progress.label or locale('progress_label'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = progress.anim,
        prop = progress.prop,
    })

    CURRENTLY_USING_BADGE = false
end

RegisterNetEvent('uk_policebadge:use', function()
    local swimming = IsPedSwimmingUnderWater(cache.ped)
    local inVehicle = IsPedInAnyVehicle(cache.ped, true)

    if not isAuthorisedJob() then
        return stevo_lib.Notify(locale('not_police'), 'error', 3000)
    end

    if swimming or inVehicle then
        return stevo_lib.Notify(locale('not_now'), 'error', 3000)
    end

    if CURRENTLY_USING_BADGE then
        return
    end

    showBadge()
end)

RegisterNetEvent('uk_policebadge:displaybadge', function(data)
    SendNUIMessage({
        type = 'displayBadge',
        data = data,
        hideAfter = config.badge_show_time
    })
end)

RegisterCommand(config.set_image_command, function()
    if not isAuthorisedJob() then
        stevo_lib.Notify(locale('not_police'), 'error', 3000)
        return
    end

    local input = lib.inputDialog(locale('input_title'), { locale('input_text') })
    if not input or not input[1] then
        stevo_lib.Notify(locale('no_photo'), 'error', 3000)
        return
    end

    local ok = lib.callback.await('uk_policebadge:setBadgePhoto', false, input[1])
    if ok then
        lib.alertDialog({
            header = config.department_name or 'Police',
            content = locale('update_badge_photo_success'),
            centered = true,
            cancel = false
        })
    else
        lib.alertDialog({
            header = config.department_name or 'Police',
            content = locale('update_badge_photo_fail'),
            centered = true,
            cancel = false
        })
    end
end, false)
