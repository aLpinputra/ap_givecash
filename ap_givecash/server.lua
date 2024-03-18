if Config.Core == 'esx' then
    ESX = exports['es_extended']:getSharedObject() 
elseif Config.Core == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
end

GetPlayerId = function(id)
    return Config.Core == 'esx' and ESX.GetPlayerFromId(id) or Config.Core == 'qb' and QBCore.Functions.GetPlayer(id)
end

GetSource = function(Player)
    return Config.Core == 'esx' and Player.source or Config.Core == 'qb' and Player.PlayerData.source
end

MoneyAction = function(Player, amount, type)
    if type == 'get' then
        return Config.Core == 'esx' and Player.getAccount('money').money or Config.Core == 'qb' and Player.Functions.GetMoney('cash')
    elseif type == 'add' then
        return Config.Core == 'esx' and Player.addAccountMoney('money', amount) or Config.Core == 'qb' and Player.Functions.AddMoney('cash', amount, '')
    elseif type == 'remove' then
        return Config.Core == 'esx' and Player.removeAccountMoney('money', amount) or Config.Core == 'qb' and Player.Functions.RemoveMoney('cash', amount, '')
    end
end

lib.callback.register('ap_givecash:getPlayerMoney', function(source)
    return MoneyAction(GetPlayerId(source), nil, 'get')
end)

RegisterServerEvent('ap_givecash:checkPlayer')
AddEventHandler('ap_givecash:checkPlayer', function(data)
	local Player = GetPlayerId(source)
	local Target = GetPlayerId(data.target)
    if Player == nil or Target == nil then
        TriggerClientEvent('ap_givecash:sendNotify', GetSource(Player), 'ID '..GetSource(Target)..' Offline!', 'error')
        return
    end
    data.senderid = GetSource(Player)
    TriggerClientEvent('ap_givecash:sendAlert', GetSource(Target), data)
end)

RegisterServerEvent('ap_givecash:sendMoney')
AddEventHandler('ap_givecash:sendMoney', function(data, confirm)
	local Player = GetPlayerId(source)
	local Target = GetPlayerId(data.senderid)
    if Player == nil or Target == nil then
        TriggerClientEvent('ap_givecash:sendNotify', GetSource(Player), 'ID '..GetSource(Target)..' Offline!', 'error')
        return
    end
    if confirm == 'confirm' then
        MoneyAction(Target, data.amount, 'remove')
        MoneyAction(Player, data.amount, 'add')
        TriggerClientEvent('ap_givecash:sendNotify', GetSource(Target), 'ID '..GetSource(Player)..' Accept!', 'success')
    elseif confirm == 'cancel' then
        TriggerClientEvent('ap_givecash:sendNotify', GetSource(Target), 'ID '..GetSource(Player)..' Reject!', 'error')
    else
        TriggerClientEvent('ap_givecash:sendNotify', GetSource(Target), 'ID '..GetSource(Player)..' Is busy!!', 'inform')
    end
end)
