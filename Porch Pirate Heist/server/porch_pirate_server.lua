-- LuaDoc: Server-side logic for the Porch Pirate Heist
local requiredPackages = 5 -- Number of packages required to complete the task
local rewards = {
    cash = { min = 5000, max = 8000 },
    markedBills = { min = 5, max = 150 }
}
local policeAlertChance = 0.3 -- 30% chance to trigger a police alert

-- Register a useable item for the stolen package
exports.ox_inventory:RegisterItem({
    name = "stolen_package",
    label = "Stolen Package",
    weight = 10
})

-- Function to send police alerts when a package is stolen
local function sendPoliceAlert(playerCoords, streetName)
    local policePlayers = exports.qbx_core:GetQBPlayers() -- Get all online players

    for _, player in pairs(policePlayers) do
        local job = player.job
        if job.name == "police" and job.onDuty then -- Only notify on-duty police
            TriggerClientEvent('ox_lib:notify', player.source, {
                type = 'inform',
                description = 'Suspicious activity reported: Possible package theft at ' .. streetName,
                duration = 10000,
                icon = 'fas fa-exclamation-triangle',
                iconColor = 'red'
            })
            TriggerClientEvent('porch_pirate:policeAlert', player.source, playerCoords) -- Send alert with location
        end
    end
end

-- Event to start the heist task
RegisterNetEvent('porch_pirate:startTask', function(playerId)
    TriggerClientEvent('porch_pirate:spawnPackages', playerId) -- Spawn the packages for the player to find
    TriggerClientEvent('ox_lib:notify', playerId, {
        type = 'success',
        description = 'I have to find and steal packages from doorsteps!'
    })
end)

-- Event to check package delivery and reward player
RegisterNetEvent('porch_pirate:deliverPackages', function(playerId)
    local player = Ox.GetPlayer(playerId)
    local stolenPackages = exports.ox_inventory:Search(playerId, 'count', 'stolen_package')
    
    if stolenPackages >= requiredPackages then
        exports.ox_inventory:RemoveItem(playerId, 'stolen_package', requiredPackages)

        -- Give rewards
        local cashReward = math.random(rewards.cash.min, rewards.cash.max)
        local markedBillsReward = math.random(rewards.markedBills.min, rewards.markedBills.max)

        player.addMoney('cash', cashReward)
        exports.ox_inventory:AddItem(playerId, 'marked_bills', markedBillsReward)
        
        TriggerClientEvent('ox_lib:notify', playerId, {
            type = 'success',
            description = 'Thank you for your service!'
        })
    else
        TriggerClientEvent('ox_lib:notify', playerId, {
            type = 'error',
            description = 'Who do you work for, grime?'
        })
    end
end)

-- Event triggered when a player steals a package
RegisterNetEvent('porch_pirate:stealPackage', function(playerId, streetName)
    local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

    -- 30% chance to alert police
    if math.random() < policeAlertChance then
        sendPoliceAlert(playerCoords, streetName)
    end
end)

