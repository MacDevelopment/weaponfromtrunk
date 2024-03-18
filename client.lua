-- Define the configuration for weapons and ammo
local weaponConfig = {
    "weapon_pistol",
    "weapon_carbinerifle",
    -- Add more weapons as needed
}

-- Function to check if the player has the specified weapon in their inventory
function HasWeaponInInventory(weaponHash)
    return HasPedGotWeapon(PlayerPedId(), GetHashKey(weaponHash), false)
end

-- Function to force player to take out weapon from trunk
RegisterNetEvent('takeOutWeaponFromTrunk')
AddEventHandler('takeOutWeaponFromTrunk', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    -- Check if the player is close to any vehicle trunk
    local trunkCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.0)
    local trunkObject = GetClosestObjectOfType(trunkCoords, 1.0, GetHashKey("prop_ld_binbag_01"), false, false, false)
    
    if trunkObject ~= 0 then
        -- Check if the player has any weapons from the configuration
        local hasConfigWeapon = false
        for _, weaponHash in ipairs(weaponConfig) do
            if HasWeaponInInventory(weaponHash) then
                hasConfigWeapon = true
                break
            end
        end
        
        if hasConfigWeapon then
            -- Allow the player to take out the weapon
            TriggerEvent("chatMessage", "^*^2You are allowed to take out the weapon from the trunk.")
        else
            -- Inform the player that they don't have any valid weapons in their inventory
            TriggerEvent("chatMessage", "^*^1You don't have any valid weapon to take out from the trunk.")
        end
    else
        -- Notify the player if the trunk is not found
        TriggerEvent("chatMessage", "^*^1Trunk not found.")
    end
end)

-- Command to trigger taking out weapon from trunk
RegisterCommand("takeoutweapon", function(source, args)
    TriggerEvent("takeOutWeaponFromTrunk")
end, false)
