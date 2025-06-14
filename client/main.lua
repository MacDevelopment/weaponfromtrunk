local lastWeapon = nil
local trunkOpenVeh = nil
local blockedWeapon = nil
local grantedWeapon = nil

local function isNearAnyVehicle()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = GetClosestVehicle(pos, 5.0, 0, 70)
    if veh == 0 or not DoesEntityExist(veh) then return false, nil end
    return #(pos - GetEntityCoords(veh)) < 3.0, veh
end

local function isRestrictedWeapon(hash)
    for _, weapon in ipairs(Config.Weapons) do
        if hash == GetHashKey(weapon) then return true end
    end
    return false
end

CreateThread(function()
    while true do
        Wait(300)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then goto continue end

        local current = GetSelectedPedWeapon(ped)

        if current ~= lastWeapon then
            if grantedWeapon and isRestrictedWeapon(lastWeapon) and not isNearAnyVehicle() then
                SetCurrentPedWeapon(ped, lastWeapon, true)
                TriggerEvent('chat:addMessage', {
                    args = { 'You must be near a vehicle to store that weapon.' }
                })
                goto continue
            end

            blockedWeapon = nil
            grantedWeapon = nil
            lastWeapon = current
        end

        if isRestrictedWeapon(current) then
            if grantedWeapon == current then goto continue end

            local near, veh = isNearAnyVehicle()
            if near and veh then
                SetVehicleDoorOpen(veh, 5, false, false)
                trunkOpenVeh = veh
                grantedWeapon = current
            else
                if blockedWeapon ~= current then
                    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                    TriggerEvent('chat:addMessage', {
                        args = { 'You must be near a vehicle to equip that weapon.' }
                    })
                    blockedWeapon = current
                end
            end
        else
            grantedWeapon = nil
        end

        ::continue::
    end
end)
