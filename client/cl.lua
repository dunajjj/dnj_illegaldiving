local acm = false
local ix = nil
local spwprops = {} 
local rprops = 0
local scuba = false
local pedboat = nil
local active = nil
local tE = nil


function dispatch()

    --[[local ped = PlayerPedId() -- exports.dnj_dispatch:GetPlayerInfo(source)
    local coords = GetEntityCoords(ped)

    TriggerServerEvent('dnj_dispatch:server:AddNotification', {
        jobs = {'police', 'sheriff', 'sahp'}, 
        coords = coords, -- data.coords
        code = '10-18',
        title = 'Nelegálni potápění',
        info = 'Rybář nahlásil nelegální potápění.', -- data.street , data.sex
        priority = 1, 
        isPanic = false,
        blip = {
            sprite = 207, 
            scale = 0.9, 
            colour = 24,
            text = '911 - Potápění',
            time = 4 
        }
    })]]

end


--[[local function dealerblip()
    local lore = lib.callback.await('dnj_illegaldiving:getlore', false)
    
    if lore == "dealer" then 
    local blip5 = exports['dnj_base']:blip({
        coords = vector3(dnj.snpc.coords.x, dnj.snpc.coords.y, dnj.snpc.coords.z),
        sprite = 108,
        scale = 0.6, 
        color = 0,
        category = 14,
        label = 'Dealer'
    })
    end
end]]


local function npc(coords, model, scenario)
    local hash = joaat(model)
    lib.requestModel(hash)
    local npc = CreatePed(4, hash, coords.x, coords.y, coords.z, coords.w, false, true)
    
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    local foundg, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 50.0, 0)
    if foundg then
        SetEntityCoords(npc, coords.x, coords.y, z, false, false, false, true)
    else
        PlaceObjectOnGroundProperly(npc)
    end
    
    SetEntityHeading(npc, coords.w)
    FreezeEntityPosition(npc, true)
    
    if scenario then
        TaskStartScenarioInPlace(npc, scenario, 0, true)
    end
    
    return npc
end

local function clean()
    for _, data in pairs(spwprops) do
        if DoesEntityExist(data.object) then DeleteEntity(data.object) end
        if data.blip then RemoveBlip(data.blip) end
    end
    spwprops = {}
    
    if DoesEntityExist(pedboat) then DeleteEntity(pedboat) end
    pedboat = nil
    
    if active then RemoveBlip(active) end
    active = nil
    
    acm = false
    ix = nil
    tE = nil
end

local function finish()
    lib.notify({
        description = 'Všechno jsi vzal. Jdi rychle pryč!',
        type = 'success'
    })
    clean()
    lib.callback.await('dnj_illegaldiving:set', false) -- cl set false
end

local function loot(entity)
    local success = lib.skillCheck({'easy', 'easy', 'medium'}, {'w', 'a', 's', 'd'})
    if success then
        if DoesEntityExist(entity) then
            for k, v in pairs(spwprops) do
                if v.object == entity then
                    if v.blip then RemoveBlip(v.blip) end
                    DeleteEntity(v.object)
                    table.remove(spwprops, k)
                    break
                end
            end
            
            local rewarded = lib.callback.await('dnj_illegaldiving:rw', false, tE, ix)
            
            if rewarded then
                rprops = rprops - 1
                if rprops <= 0 then
                    finish()
                else
                    lib.notify({
                        description = 'Ještě ' .. rprops .. ' předmětů.', 
                        type = 'info'
                    })
                --[[else -- TODO : idk ci to nepise error
                    if rprops <= 1 then
                    lib.notify({
                        description = "Chybí poslední předmět! Vezmi ho!"
                        type = 'warning'
                    })
                    end]]
                end
            else
                lib.notify({
                    description = 'Chyba při získávání odměny.',
                    type = 'error'
                })
            end
        end
    else
        lib.notify({
            description = 'Nepodařilo se ti to vzít.',
            type = 'error'
        })
    end
end

local function loop()
    CreateThread(function()
        while acm do
            local pedcoords = GetEntityCoords(cache.ped)
            
            for _, data in pairs(spwprops) do
                if DoesEntityExist(data.object) then
                    local propcoords = GetEntityCoords(data.object)
                    local dist = #(pedcoords - propcoords)
                    
                    if dist <= 45.0 then
                       -- if not IsEntityFocus(data.object) then -- useless
                             SetEntityDrawOutline(data.object, true)
                             SetEntityDrawOutlineColor(148, 0, 211, 255)
                        end
                    else
                        SetEntityDrawOutline(data.object, false)
                    end
                end
            end
            Wait(500) 
        end
    end)
end

local function startafterspawn(data)
    lib.notify({
        description = 'Ponoř se a hledej šrot. Lokace jsou označené na mapě.',
        type = 'info',
        duration = 8500
    })

    for _, coords in pairs(data.lootlocs) do
        local model = dnj.props[math.random(#dnj.props)]
        lib.requestModel(model)
        
        local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
        
        SetEntityCollision(obj, true, true)
        
        local attempts = 0
        while attempts < 10 do
            PlaceObjectOnGroundProperly(obj)
            Wait(50) 
            attempts = attempts + 1
        end
        
        FreezeEntityPosition(obj, true)
        
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 1)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('<FONT FACE="Lexend">Šrot</FONT>')
        EndTextCommandSetBlipName(blip)
        
        table.insert(spwprops, {object = obj, blip = blip})
        
        exports.ox_target:addLocalEntity(obj, {
            {
                name = 's2',
                icon = 'fa-solid fa-hand',
                label = 'Vzít šrot',
                onSelect = function(data)
                    local chance = math.random(1,100)
                    if chance < 35 then -- 100 = 100% chance na dispatch
                        dispatch()
                    end
                --    dispatch() 
                    loot(data.entity)
                end
            }
        })
    end
    
    loop()
end

local function diving()
    acm = true
    ix = math.random(#dnj.msn)
    local data = dnj.msn[ix]
    rprops = #data.lootlocs
    
    lib.notify({
        description = 'Jdi na GPS a vezmi si loď.',
        type = 'info'
    })

    active = AddBlipForCoord(data.boatnpc.coords.x, data.boatnpc.coords.y, data.boatnpc.coords.z)
    SetBlipSprite(active, 404)
    SetBlipColour(active, 3)
    SetBlipRoute(active, true)

    pedboat = npc(data.boatnpc.coords, data.boatnpc.model, data.boatnpc.scenario)
    
    exports.ox_target:addLocalEntity(pedboat, {
        {
            name = 'sd',
            icon = 'fa-solid fa-anchor',
            label = 'Pronajmout loď ($'..data.boatst.price..')',
            onSelect = function()
                local paid, token = lib.callback.await('dnj_illegaldiving:rent', false, data.boatst.price)
                if paid and token then
                    tE = token
                    
                    lib.requestModel(data.boatst.model)
                    local vehicle = CreateVehicle(data.boatst.model, data.boatst.spawn.x, data.boatst.spawn.y, data.boatst.spawn.z, data.boatst.spawn.w, true, false)
                    SetPedIntoVehicle(cache.ped, vehicle, -1)
                    
                    if active then RemoveBlip(active) end
                    active = nil
                    
                    startafterspawn(data)
                else
                    lib.notify({type = 'error', description = 'Nemáš dosť peňazí!'})
                end
            end
        }
    })
end

CreateThread(function()
    local pedstart = npc(dnj.snpc.coords, dnj.snpc.model, dnj.snpc.scenario)
    
    exports.ox_target:addLocalEntity(pedstart, {
        {
            name = 's',
            icon = 'fa-solid fa-lungs',
            label = 'Promluvit o práci',
            onSelect = function()
                if acm then --- @param acm string
                    lib.notify({type = 'error', description = 'Už něco děláš.'})
                    return
                end

                local hs = exports.ox_inventory:Search('count', dnj.rq)
                if hs > 0 then
                    local candive, time = lib.callback.await('dnj_illegaldiving:check', false) -- cl check
                    if candive then
                        diving()
                    else
                        lib.notify({type = 'error', description = 'Už to někdo udělal...'})
                    end
                else
                    lib.notify({type = 'error', description = 'Chybí ti maska. Sežeň si ji a pak přijď.'})
                end
            end
        }
    })
end)

RegisterNetEvent('dnj_diving:scb', function()
    if scuba then return end
    scuba = true
    
    local ped = cache.ped
    lib.requestAnimDict('clothingshirt')
    TaskPlayAnim(ped, 'clothingshirt', 'try_shirt_positive_d', 8.0, -8.0, 2500, 49, 0, false, false, false)
    Wait(2500)
    
    local gender = GetEntityModel(ped)
    if gender == `mp_m_freemode_01` then
        SetPedComponentVariation(ped, 1, dnj.scubamask.male.drawable, dnj.scubamask.male.texture, 0)
    elseif gender == `mp_f_freemode_01` then
        SetPedComponentVariation(ped, 1, dnj.scubamask.female.drawable, dnj.scubamask.female.texture, 0)
    end
    
    SetPedDiesInWater(ped, false)
    SetPedMaxTimeUnderwater(ped, 1000.00)
    
    local time = dnj.scuba
    
    --[[local textUI = lib.showTextUI('Kyslík: ' .. time .. 's', {
        position = "right-center",
        icon = 'lungs',
    })]]
    
    CreateThread(function()
        while time > 0 do
            Wait(1000)
            time = time - 1
            if scuba then
                lib.showTextUI('Kyslík: ' .. time .. 's')
            else
                break
            end
        end
        
        scuba = false
        SetPedDiesInWater(ped, true)
        SetPedMaxTimeUnderwater(ped, 10.0)
        
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        
        lib.hideTextUI()
        lib.notify({type = 'warning', description = 'Došel ti kyslík!'})
    end)
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    Wait(1000)
  --  dealerblip()
end)

CreateThread(function()
    Wait(2000)
  --  dealerblip()
end)
