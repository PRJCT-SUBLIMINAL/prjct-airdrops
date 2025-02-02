local playersInZone = 0
local isAirdropActive = false
local airdropTimer = nil

local function Debug(message)
    if Config.Debug then
        print('[Airdrops Server Debug] ' .. message)
    end
end

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
        TriggerEvent('prjct-airdrops:startTimer')
        --StartAirdropTimer()
    end,
    onExit = function()
        TriggerEvent('prjct-airdrops:stopTimer')
        --StopAirdropTimer()
    end
})

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

local function StartAirdropTimer()
    
    local randomWait = math.random(Config.AirDropTimer.min, Config.AirDropTimer.max) * 60000
    Debug('Next airdrop in: ' .. (randomWait/60000) .. ' minutes')
    isAirdropActive = true
    
    airdropTimer = SetTimeout(randomWait, function()
        airdropTimer = nil
        
        if isAirdropActive == true then
            local dropCoords = GetRandomDropCoords()
            TriggerClientEvent('airdrops:client:crateDrop', -1, dropCoords)
        
            if Config.Debug then
                Debug('Airdrop started at coordinates: ' .. vec3(dropCoords.x, dropCoords.y, dropCoords.z))
            end
        end
    end)
end

local function StopAirdropTimer()
    if airdropTimer then
        ClearTimeout(airdropTimer)
        airdropTimer = nil
    end
    isAirdropActive = false
    Debug('Airdrop timer stopped successfully')
end

RegisterNetEvent('prjct-airdrops:startTimer', function()
    playersInZone = playersInZone + 1
    
    if playersInZone == 1 then
        StartAirdropTimer()
    end
end)

RegisterNetEvent('prjct-airdrops:stopTimer', function()
    playersInZone = playersInZone - 1
    
    if playersInZone <= 0 then
        playersInZone = 0
        StopAirdropTimer()
    end
end)

local function CreateAirdropStash(coords)
    Debug('Creating stash at coordinates: ' .. vec3(coords.x, coords.y, coords.z))
    local stashId = 'airdrop_' .. math.random(1000, 9999)
    Debug('Generated stashId: ' .. stashId)

    local inventoryId = exports.ox_inventory:CreateTemporaryStash({
        label = 'Airdrop Crate',
        slots = Config.StashSlots,
        maxWeight = Config.StashWeight,
    })

    local reward = Config.Rewards[math.random(#Config.Rewards)]
    local rewardAmount = math.ceil(math.random(reward.amount.min, reward.amount.max))
    Debug('Selected reward: ' .. reward.item .. ' x' .. rewardAmount)
    exports.ox_inventory:AddItem(inventoryId, reward.item, rewardAmount)

    return inventoryId
end

RegisterNetEvent('airdrops:server:spawnCrate', function(coords)
    Debug('Spawn crate event received from client')
    TriggerClientEvent('airdrops:client:crateDrop', -1, coords)
end)

RegisterNetEvent('airdrops:server:createCrateStash', function(coords)
    local stashId = CreateAirdropStash(coords)
    Debug('Creating stash for crash site crate')
    TriggerClientEvent('airdrops:client:spawnSingleCrate', -1, coords, stashId)
end)

RegisterNetEvent('airdrops:server:airdropComplete', function()
    isAirdropActive = false
    
    if playersInZone >= 1 then
        StartAirdropTimer()
    end
end)