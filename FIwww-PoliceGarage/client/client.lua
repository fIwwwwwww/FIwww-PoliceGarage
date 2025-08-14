local QBCore = exports['qb-core']:GetCoreObject()
local pedHandle = nil
local nuiOpen = false

local function playerHasJob(job)
    local pd = LocalPlayer.state
    if pd and pd.job and pd.job.name then
        return pd.job.name == job, pd.job.grade or 0, pd.job.label or '', pd.job.grade_label or ''
    end
    local data = QBCore.Functions.GetPlayerData()
    if data and data.job then
        return data.job.name == job, data.job.grade.level or data.job.grade or 0, data.job.label or '', (data.job.grade and data.job.grade.name) or ''
    end
    return false, 0, '', ''
end

local function ensureAreaClear(coords, radius)
    local vehicles = lib.getNearbyVehicles(vec3(coords.x, coords.y, coords.z), radius or 3.5, true)
    for _, v in ipairs(vehicles) do
        SetEntityAsMissionEntity(v, true, true)
        DeleteVehicle(v)
    end
end

CreateThread(function()
    local p = Config.Ped
    RequestModel(p.model)
    while not HasModelLoaded(p.model) do Wait(50) end
    pedHandle = CreatePed(0, p.model, p.coords.x, p.coords.y, p.coords.z - 1.0, p.coords.w, false, true)
    SetEntityInvincible(pedHandle, true)
    SetBlockingOfNonTemporaryEvents(pedHandle, true)
    FreezeEntityPosition(pedHandle, true)
    if p.scenario and p.scenario ~= '' then
        TaskStartScenarioInPlace(pedHandle, p.scenario, 0, true)
    end

    exports.ox_target:addLocalEntity(pedHandle, {
        {
            name = 'qbx_pd_garage:open',
            icon = p.icon or 'fa-solid fa-car',
            label = p.label or 'Open PD Garage',
            distance = p.distance or 2.0,
            canInteract = function(entity, distance, coords, name)
                local ok = playerHasJob(Config.JobName)
                return ok
            end,
            onSelect = function(data)
                local isPolice, grade = playerHasJob(Config.JobName)
                if not isPolice then
                    QBCore.Functions.Notify('Police only.', 'error')
                    return
                end
                SetNuiFocus(true, true)
                nuiOpen = true
                local payload = {
                    action = 'open',
                    categories = Config.Categories,
                    leaders = Config.Leaders,
                    locationLabel = 'Mission Row',
                    grade = grade,
                    ranks = Config.Ranks
                }
                SendNUIMessage(payload)
            end
        }
    })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    nuiOpen = false
    SendNUIMessage({ action = 'close' })
    cb(1)
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local isPolice, grade = playerHasJob(Config.JobName)
    if not isPolice then
        QBCore.Functions.Notify('Police only.', 'error')
        cb({ ok = false, msg = 'Not police' })
        return
    end

    local required = Config.Ranks[data.requiredRank] or 0
    if grade < required then
        QBCore.Functions.Notify(('Requires rank: %s'):format(data.requiredRank), 'error')
        cb({ ok = false, msg = 'Insufficient rank' })
        return
    end

    local spawn = Config.Spawn.coords
    ensureAreaClear(spawn, Config.Spawn.clearRadius or 3.5)

    local model = joaat(data.model)
    RequestModel(model)
    local tries = 0
    while not HasModelLoaded(model) and tries < 200 do
        Wait(20); tries = tries + 1
    end
    if not HasModelLoaded(model) then
        QBCore.Functions.Notify('Model failed to load.', 'error')
        cb({ ok = false })
        return
    end

    local veh = CreateVehicle(model, spawn.x, spawn.y, spawn.z, spawn.w, true, true)
    SetVehicleOnGroundProperly(veh)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleNumberPlateText(veh, ('PD %03d'):format(math.random(1, 999)))
    TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh) or GetVehicleNumberPlateText(veh))

    local fuel = tonumber(data.fuel or 100) or 100
    local ok, err = pcall(function()
        if GetResourceState(Config.FuelResourceName) == 'started' then
            exports[Config.FuelResourceName]:SetFuel(veh, fuel)
        elseif GetResourceState('LegacyFuel') == 'started' then
            exports['LegacyFuel']:SetFuel(veh, fuel)
        else
            Entity(veh).state.fuelLevel = fuel
        end
    end)
    if not ok then
        Entity(veh).state.fuelLevel = fuel
    end

    SetPedIntoVehicle(PlayerPedId(), veh, -1)

    SetNuiFocus(false, false)
    nuiOpen = false
    SendNUIMessage({ action = 'close' })

    cb({ ok = true })
end)

RegisterCommand('pdextras', function()
    local isPolice, grade = playerHasJob(Config.JobName)
    if not isPolice then
        QBCore.Functions.Notify('Police only.', 'error')
        return
    end
    
    SetNuiFocus(true, true)
    nuiOpen = true
    SendNUIMessage({
        action = 'openExtras',
        grade = grade
    })
end)

RegisterNUICallback('getVehicleExtras', function(_, cb)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then
        cb({ ok = false })
        return
    end

    local extras = {}
    for i = 0, 20 do
        if DoesExtraExist(veh, i) then
            extras[#extras+1] = { id = i, state = IsVehicleExtraTurnedOn(veh, i) }
        end
    end

    cb({ ok = true, extras = extras })
end)

RegisterNUICallback('toggleExtra', function(data, cb)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then
        cb({ ok = false })
        return
    end
    local id = tonumber(data.id)
    if id and DoesExtraExist(veh, id) then
        local newState = not IsVehicleExtraTurnedOn(veh, id)
        SetVehicleExtra(veh, id, newState and 0 or 1)
        cb({ ok = true, state = newState })
    else
        cb({ ok = false })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if nuiOpen and IsControlJustPressed(0, 322) then
            SetNuiFocus(false, false)
            nuiOpen = false
            SendNUIMessage({ action = 'close' })
        end
    end
end)
