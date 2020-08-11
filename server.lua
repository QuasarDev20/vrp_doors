local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

local cfg = module("vrp_doors", "config")

local Doors = class("Doors",vRP.Extension)

Doors.event = {}

function Doors.event:playerSpawn(user, first_spawn)
  if first_spawn then
    TriggerClientEvent('vrpdoorsystem:load', user.source, cfg.list)
  end
end


Citizen.CreateThread(function()
  Citizen.Wait(500)
  TriggerClientEvent('vrpdoorsystem:load', -1, cfg.list)
end)


RegisterServerEvent('vrpdoorsystem:open')
AddEventHandler('vrpdoorsystem:open', function(id)
  local user = vRP.users_by_source[source]
  if user:hasPermission("!item."..cfg.list[id].key..".>0") or user:hasPermission(cfg.list[id].permission) then
    vRP.EXT.Base.remote.playAnim(user.source,false, {{"misscommon@locked_door", "lockeddoor_tryopen", 1}}, false)
    SetTimeout(4000, function()
      cfg.list[id].locked = not cfg.list[id].locked
      TriggerClientEvent('vrpdoorsystem:statusSend', (-1), id,cfg.list[id].locked)
      if cfg.list[id].pair ~= nil then
        local idsecond = cfg.list[id].pair
        cfg.list[idsecond].locked = cfg.list[id].locked
        TriggerClientEvent('vrpdoorsystem:statusSend', (-1), idsecond,cfg.list[id].locked)
      end
      if cfg.list[id].locked then
        vRP.EXT.Base.remote._notify(user.source,"~o~Дверь закрыта ~w~с помощью Ключа ~g~"..cfg.list[id].name)
      else
        vRP.EXT.Base.remote._notify(user.source,"~g~Дверь открыта ~w~с помощью Ключа ~g~"..cfg.list[id].name)
      end
    end)
  else
    vRP.EXT.Base.remote._notify(user.source,"~r~Отсутствует Ключ от дверей ~g~"..cfg.list[id].name)
  end
end)

vRP:registerExtension(Doors)