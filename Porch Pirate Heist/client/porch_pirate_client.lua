-- LuaDoc: Client-side logic for Porch Pirate Heist

local npcCoords = vector3(839.44, 2176.74, 52.29) -- Coordinates of the NPC ped
local searchAreaCoords = vector3(1368.28, -1535.46, 55.78) -- Center of the general search area
local searchAreaRadius = 200.0 -- Radius for the search area
local packageCoords = { -- Predefined porch locations for packages
    vector3(1313.9, -1527.53, 50.00),
    vector3(1327.2, -1552.86, 53.00),
    vector3(1337.96, -1525.54, 53.00),
    vector3(1360.33, -1555.86, 55.00),
    vector3(1379.63, -1514.8, 57.00),
    vector3(1382.3, -1544.29, 56.00),
    vector3(1402.03, -1490.14, 58.00),
    vector3(1410.1, -1489.29, 59.00),
    vector3(1404.3, -1496.28, 58.00),
    vector3(1435.98, -1491.74, 62.00)
    -- Add more porch locations here...
}

-- Function to create the search area blip on the map
local function addSearchAreaBlip()
    local blip = AddBlipForRadius(searchAreaCoords.x, searchAreaCoords.y, searchAreaCoords.z, searchAreaRadius)
    SetBlipColour(blip, 2) -- Green color
    SetBlipAlpha(blip, 128) -- Transparent circle
    SetBlipAsShortRange(blip, true) -- Only show on the mini-map and when nearby
end

-- Spawn the black market NPC
CreateThread(function()
    local model = `s_m_m_ups_01` -- Example NPC model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(4, model, npcCoords.x, npcCoords.y, npcCoords.z, 90.0, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Add a target interaction to start the heist
    exports.ox_target:addEntity(ped, {
        {
            label = 'Start Porch Pirate Task',
            icon = 'fas fa-box',
            event = 'porch_pirate:startTask'
        }
    })
end)

-- Function to spawn packages on the porches
RegisterNetEvent('porch_pirate:spawnPackages', function()
    addSearchAreaBlip() -- Show the general search area

    for _, coords in ipairs(packageCoords) do
        local prop = CreateObject(`prop_cs_package_01`, coords.x, coords.y, coords.z, true, true, false)
        
        -- Add target interaction to steal the package
        exports.ox_target:addLocalEntity(prop, {
            {
                label = 'Steal Package',
                icon = 'fas fa-box',
                event = 'porch_pirate:stealPackage',
                distance = 1.5,
                canInteract = function(entity)
                    return not IsPedInAnyVehicle(PlayerPedId(), true) -- Prevent stealing while in a vehicle
                end
            }
        })
    end
end)

-- Handle stealing the package and alerting the police
RegisterNetEvent('porch_pirate:stealPackage', function()
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    local streetName = getStreetName(playerCoords)

    -- Animation for picking up the package
    TaskStartScenarioInPlace(player, 'PROP_HUMAN_BUM_BIN', 0, true)
    Wait(3000)
    ClearPedTasks(player)

    -- Give the player a stolen package
    exports.ox_inventory:AddItem(source, 'stolen_package', 1)

    -- Notify the player
    TriggerEvent('ox_lib:notify', {
        type = 'success',
        description = 'You have stolen a package!'
    })

    -- Notify the server to possibly alert the police
    TriggerServerEvent('porch_pirate:stealPackage', source, streetName)
end)

-- Function to get the street name from coordinates
local function getStreetName(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    return streetName
end