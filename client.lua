local activeDrops = {}
--local activePeds = {}
local activeThreads = {}
local airdropThread = nil

local function Debug(message)
    if Config.Debug then
        print('[Airdrops Client Debug] ' .. message)
    end
end

-- You can change polyzone here, currently set to Cayo Perico island!
local polyZone = lib.zones.poly({
    points = {
        vec3(4660.5039, -6238.1138, 0.0),
        vec3(3477.8669, -4178.5137, 0.0),
        vec3(5217.9521, -4284.7275, 0.0),
        vec3(5980.2837, -5774.8008, 0.0)
    },
    thickness = 500.0,
    debug = Config.Debug,
    onEnter = function()
        TriggerServerEvent('prjct-airdrops:startTimer')
        --StartAirdropTimer()
    end,
    onExit = function()
        TriggerServerEvent('prjct-airdrops:stopTimer')
        --StopAirdropTimer()
    end
})
--[[
local function CreateHostilePeds(coords, startPos, aircraftData)
    local pedModel = `g_m_m_armboss_01`
    local weaponHash = GetHashKey("WEAPON_CARBINERIFLE")
    
    -- Ensure model is loaded before creating peds
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(500)
    end
    
    for i = 1, math.random(5, 10) do
        local attempts = 0
        local validSpawn = false
        local spawnCoords
        Wait(100)
        while attempts < 10 and not validSpawn do
            local offsetX = math.random(-50, 50)
            local offsetY = math.random(-50, 50)
            local testCoords = vector3(startPos.x + offsetX, startPos.y + offsetY, startPos.z)
            
            local ground, z = GetGroundZFor_3dCoord(testCoords.x, testCoords.y, testCoords.z, true)
            local _, waterHeight = GetWaterHeight(testCoords.x, testCoords.y, testCoords.z)
            
            if ground and (not waterHeight or z > waterHeight) then
                spawnCoords = vector3(testCoords.x, testCoords.y, z + 1.0)
                validSpawn = true
            end
            
            attempts = attempts + 1
        end
        
        if validSpawn then
            local ped = CreatePed(4, pedModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)
            Wait(100) -- Give the ped time to fully spawn
            
            -- Track the ped
            table.insert(activePeds, ped)
            
            -- Basic setup
            SetEntityVisible(ped, true)
            SetPedRandomComponentVariation(ped)
            SetPedArmour(ped, 100)
            SetPedAccuracy(ped, 100)
            
            -- Combat setup
            SetPedCombatAttributes(ped, 46, true)
            SetPedCombatAttributes(ped, 2, true)
            SetPedCombatAttributes(ped, 3, false)
            SetPedCombatAttributes(ped, 5, true)
            SetPedCombatAttributes(ped, 13, true)
            SetPedCombatAttributes(ped, 14, true)
            SetPedCombatRange(ped, 999999.0)
            SetPedCombatMovement(ped, 3)
            SetPedCombatAbility(ped, 100)
            
            -- Weapon setup with delay
            Wait(100)
            SetPedCanSwitchWeapon(ped, true)
            RemoveAllPedWeapons(ped, true)
            Wait(100)
            GiveWeaponToPed(ped, weaponHash, 999, false, true)
            SetCurrentPedWeapon(ped, weaponHash, true)
            SetPedInfiniteAmmo(ped, true, weaponHash)
            SetPedAmmo(ped, weaponHash, 999)
            
            -- Combat thread
            local threadId = CreateThread(function()
                while DoesEntityExist(ped) and DoesEntityExist(aircraftData.aircraft) do
                    if DoesEntityExist(aircraftData.pilot) then
                        TaskCombatPed(ped, aircraftData.pilot, 0, 16)
                    end
                    if DoesEntityExist(aircraftData.aircraft) then
                        TaskShootAtEntity(ped, aircraftData.aircraft, 1000, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
                    end
                    Wait(100)
                end
            end)
            table.insert(activeThreads, threadId)
            Debug('Created elite fighter with weapon at: ' .. vec3(spawnCoords.x, spawnCoords.y, spawnCoords.z))
        end
    end
end
]]
local function GetRandomDropCoords()
    local points = polyZone.points
    local x = 0
    local y = 0

    for i = 1, #points do
        local j = (i % #points) + 1
        local random = math.random()
        x = x + (points[i].x + random * (points[j].x - points[i].x))
        y = y + (points[i].y + random * (points[j].y - points[i].y))
    end

    x = x / #points
    y = y / #points

    return vector3(x, y, 500.0)
end
--[[
function StartAirdropTimer()
    Debug('Airdrop timer started')
    CreateThread(function()
        while true do
            local randomWait = math.random(Config.AirDropTimer.min, Config.AirDropTimer.max) * 60000
            Debug('Waiting ' .. (randomWait/60000) .. ' minutes until next airdrop')
            Wait(randomWait)

            local dropCoords = GetRandomDropCoords()
            Debug('Drop coordinates selected: ' .. vec3(dropCoords.x, dropCoords.y, dropCoords.z))
            TriggerServerEvent('airdrops:server:spawnCrate', dropCoords)
            if Config.Debug then
                lib.notify({
                    title = 'Airdrop Incoming',
                    description = 'A supply drop has been spotted over Cayo Perico',
                    type = 'inform'
                })
            end
        end
    end)
end
]
function StopAirdropTimer()
    if airdropThread then
        TerminateThread(airdropThread)
    end
end
]]
function CreateAircraft(dropCoords)
    Debug('Starting aircraft creation sequence')

    local models = {
        plane = joaat(Config.PlaneModel),
        pilot = joaat(Config.PilotModel)
    }

    RequestModel(models.plane)
    while not HasModelLoaded(models.plane) do
        Wait(500)
    end
    
    RequestModel(models.pilot)
    while not HasModelLoaded(models.pilot) do
        Wait(500)
    end

    local points = polyZone.points
    local randomEdge = math.random(1, #points)
    local nextPoint = (randomEdge % #points) + 1

    local random = math.random()
    local planeHeight = 100.0
    local startPos = vector3(
        points[randomEdge].x + random * (points[nextPoint].x - points[randomEdge].x),
        points[randomEdge].y + random * (points[nextPoint].y - points[randomEdge].y),
        planeHeight
    )

    local randomTarget = GetRandomDropCoords()
    local targetPos = vector3(randomTarget.x, randomTarget.y, planeHeight)

    Debug('Creating aircraft at random edge: ' .. vec3(startPos.x, startPos.y, startPos.z))
    Debug('Flying towards random target: ' .. vec3(targetPos.x, targetPos.y, targetPos.z))

    local heading = GetHeadingFromVector_2d(targetPos.x - startPos.x, targetPos.y - startPos.y)
    local aircraft = CreateVehicle(models.plane, startPos.x, startPos.y, startPos.z, heading, true, true)
    local pilot = CreatePedInsideVehicle(aircraft, 1, models.pilot, -1, true, true)

    SetEntityDynamic(aircraft, true)
    SetVehicleEngineOn(aircraft, true, true, false)
    SetVehicleForwardSpeed(aircraft, 60.0)

    SetBlockingOfNonTemporaryEvents(pilot, true)
    SetPedKeepTask(pilot, true)

    TaskPlaneMission(pilot, aircraft, 0, 0, targetPos.x, targetPos.y, targetPos.z, 4, 60.0, 0.0, heading, 50.0, 5000.0)

    SetModelAsNoLongerNeeded(models.plane)
    SetModelAsNoLongerNeeded(models.pilot)

    Debug('Aircraft created with ID: ' .. aircraft)
    return {aircraft = aircraft, pilot = pilot, targetPos = targetPos}
end

RegisterNetEvent('airdrops:client:crateDrop', function(dropCoords)
    Debug('Starting flight sequence')
    local aircraftData = CreateAircraft(dropCoords)
    local hasCrashed = false
    local flightStartTime = GetGameTimer()

--    CreateHostilePeds(dropCoords, aircraftData.targetPos, aircraftData)

    CreateThread(function()
        while true do
            Wait(100)
            if not DoesEntityExist(aircraftData.aircraft) then break end

            local currentTime = GetGameTimer()
            local flightTime = currentTime - flightStartTime
            local aircraftCoords = GetEntityCoords(aircraftData.aircraft)

            if not hasCrashed and flightTime > math.random(Config.FlightTime.min, Config.FlightTime.max) * 1000 and polyZone:contains(aircraftCoords) then
                Debug('Flight time reached - initiating crash sequence')

                SetVehicleEngineHealth(aircraftData.aircraft, -4000.0)
                SetEntityHealth(aircraftData.aircraft, 0)
--[[
                -- Handle peds with proper entity checks
                for _, ped in pairs(activePeds) do
                    if DoesEntityExist(ped) then
                        ClearPedTasks(ped)
                        Wait(100)
                        RemoveAllPedWeapons(ped, true)
                        Wait(100)
                        TaskSmartFleePed(ped, PlayerPedId(), 1000.0, -1, true, true)
                        SetPedCombatAttributes(ped, 46, false)
                        SetPedFleeAttributes(ped, 0, true)
                    end
                end
]]
                Wait(10000)

                local crashCoords = GetEntityCoords(aircraftData.aircraft)
                local numCrates = math.ceil(math.random(Config.CrateAmount.min, Config.CrateAmount.max))

                for i = 1, numCrates do
                    Wait(100)
                    local offsetX = math.random(-15, 15)
                    local offsetY = math.random(-15, 15)
                    local crateCoords = vector3(
                        crashCoords.x + offsetX,
                        crashCoords.y + offsetY,
                        crashCoords.z + 0.2
                    )
                    TriggerServerEvent('airdrops:server:createCrateStash', crateCoords)
                end

                hasCrashed = true
                TriggerEvent('airdrops:client:despawnTimer')
                TriggerServerEvent('airdrops:server:airdropComplete')
                break
            end
        end
    end)
end)

RegisterNetEvent('airdrops:client:spawnSingleCrate', function(coords, stashId)
    Debug('Finding ground position for crate spawn')
--[[
    local groundZ = 0.0
    local ground, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    if ground then
        groundZ = z
    end

    local finalCoords = vector3(coords.x, coords.y, groundZ + 0.2)

    Debug('Spawning crate at ground level: ' .. vec3(finalCoords.x, finalCoords.y, finalCoords.z))
    local crate = CreateObject(joaat(Config.CrateModel), finalCoords.x, finalCoords.y, finalCoords.z, true, true, true)
]]

    Debug('Spawning crate at ground level: ' .. vec3(coords.x, coords.y, coords.z))
    local crate = CreateObject(joaat(Config.CrateModel), coords.x, coords.y, coords.z + 2, true, true, true)

    SetEntityHeading(crate, math.random(0, 360))
    PlaceObjectOnGroundProperly(crate)

    Wait(4000)

    FreezeEntityPosition(crate, true)

    RequestWeaponAsset(GetHashKey("weapon_flare"))
    while not HasWeaponAssetLoaded(GetHashKey("weapon_flare")) do
        Wait(0)
    end

    local crateCoords = GetEntityCoords(crate)
    ShootSingleBulletBetweenCoords(
        crateCoords.x, crateCoords.y, crateCoords.z,
        crateCoords.x, crateCoords.y, crateCoords.z - 0.5,
        0,
        false,
        GetHashKey("weapon_flare"),
        0,
        true,
        true,
        -1.0
    )

    Wait(2000)

    local targetZone = exports.ox_target:addSphereZone({
        coords = crateCoords,
        debug = Config.TargetDebug,
        radius = 0.52,
        distance = 1.5,
        options = {
            {
                name = 'airdrop_crate_' .. stashId,
                icon = 'fas fa-box-open',
                label = 'Open Crate',
                onSelect = function()
                    exports.ox_inventory:openInventory('stash', stashId)
                end
            }
        }
    })
    

    table.insert(activeDrops, {crate = crate, zone = targetZone, stashId = stashId})
    Debug('Crate spawned with attached flare at ground level with ID: ' .. crate)
end)

RegisterNetEvent('airdrops:client:despawnTimer', function()
    Wait(60000 * 20)
    for _, drop in pairs(activeDrops) do
        if drop.aircraft then DeleteEntity(drop.aircraft) end
        if drop.pilot then DeleteEntity(drop.pilot) end
        if drop.crate then DeleteEntity(drop.crate) end
        if drop.zone then exports.ox_target:removeZone(drop.zone) end
    end
--[[
    -- Clean up peds
    for _, ped in pairs(activePeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
]]
    -- Clear tables
    activeDrops = {}
--    activePeds = {}
    activeThreads = {}
end)

RegisterCommand('testairdrop', function()
    if Config.TestCommand then
        local dropCoords = GetRandomDropCoords()
        Debug('Starting test airdrop sequence at: ' .. vec3(dropCoords.x, dropCoords.y, dropCoords.z))

        lib.notify({
            title = 'Test Airdrop',
            description = 'Aircraft inbound to Cayo Perico',
            type = 'inform',
            position = Config.NotifPosition,
            duration = 5000
        })

        TriggerEvent('airdrops:client:crateDrop', dropCoords)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        -- Clean up drops
        for _, drop in pairs(activeDrops) do
            if drop.aircraft then DeleteEntity(drop.aircraft) end
            if drop.pilot then DeleteEntity(drop.pilot) end
            if drop.crate then DeleteEntity(drop.crate) end
            if drop.zone then exports.ox_target:removeZone(drop.zone) end
        end
--[[
        -- Clean up peds immediately
        for _, ped in pairs(activePeds) do
            if DoesEntityExist(ped) then 
                SetEntityAsMissionEntity(ped, true, true)
                DeleteEntity(ped) 
            end
        end
]]
        -- Reset tables
        activeDrops = {}
--        activePeds = {}
        activeThreads = {}
    end
end)