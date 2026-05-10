local cooldowns = {}
local acms = {}

local function g()
    return tostring(math.random(100000, 999999)) .. tostring(os.time())
end

lib.callback.register('dnj_illegaldiving:getlore', function(source)
    local lore = exports.esx_identity:getlore(source)
    return lore
end)

lib.callback.register('dnj_illegaldiving:check', function(source)
    local xpl = ESX.GetPlayerFromId(source)
    local identifier = xpl.identifier
    
    if cooldowns[identifier] and os.time() < cooldowns[identifier] then
        return false, (cooldowns[identifier] - os.time())
    end
    
    return true
end)

lib.callback.register('dnj_illegaldiving:set', function(source)
    local xpl = ESX.GetPlayerFromId(source)
    local identifier = xpl.identifier
    
    cooldowns[identifier] = os.time() + dnj.cldown
    acms[source] = nil
end)

lib.callback.register('dnj_illegaldiving:rent', function(source, price)
    local money = exports.ox_inventory:GetItemCount(source, 'money')
    
    if money >= price then
        exports.ox_inventory:RemoveItem(source, 'money', price)
        
        local token = g()
        acms[source] = token
        
        return true, token
    end
    
    return false, nil
end)

lib.callback.register('dnj_illegaldiving:rw', function(source, token, missionIndex)
    if not acms[source] or acms[source] ~= token then
        return false
    end

    local mission = dnj.msn[missionIndex]
    if not mission then return false end

    local item = mission.rwr.items[math.random(#mission.rwr.items)]
    local count = math.random(mission.rwr.min, mission.rwr.max)
    local playername = GetPlayerName(source)
    if exports.ox_inventory:CanCarryItem(source, item, count) then
        --[[exports['dnj_logs']:sendlog(
        'diving', 
        'Vzal item - dnj illegal diving', 
        'Hráč **' .. playername .. '** vzal **' .. item .. '** **'.. count .. '**x.', 
        'info' 
        )]]
        exports.ox_inventory:AddItem(source, item, count)
        return true
    end
    
    return false
end)

AddEventHandler('playerDropped', function()
    local src = source
    if acms[src] then
        acms[src] = nil
    end
end)
