local showingInput = false

sendNotify = function(text, type)
    lib.notify({
        title = text,
        position = 'top',
        type = type
    })
end

RegisterNetEvent('ap_givecash:sendNotify')
AddEventHandler('ap_givecash:sendNotify', sendNotify)

createInputMenu = function(data)
    if not data.entity then print('data.entity: nil value') return end
    local totalMoney = lib.callback.await('ap_givecash:getPlayerMoney', false)
    if not (totalMoney > 0) then sendNotify('You don\'t have money!', 'error') return end
    handleInputDialog(true, data)
    local input = lib.inputDialog('Amount', {
        {type = 'number', label = 'How many?', description = 'Your cash $'..lib.math.groupdigits(totalMoney), default = 1, min = 1, max = Config.MaxGive, required = true},
        {type = 'input', label = 'Notes:', placeholder = 'Optional', icon = 'fas fa-pen-alt'}
    })
    if not input then handleInputDialog(false, data) return end
    if input[1] > totalMoney then 
        handleInputDialog(false, data)
        sendNotify('Your money is not enough!', 'error') 
        return 
    end
    local alert = lib.alertDialog({
        header = 'Give?',
        content = 'You give the amount of money $' .. lib.math.groupdigits(input[1]) .. (input[2] ~= '' and '  \nNotes : ' .. input[2] or ''),
        centered = true,
        cancel = true,
        size = 'md'
    })
	if alert == 'confirm' then
		local ap = {
		    target = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)),
		    amount = input[1],
		    note = input[2]
		}
		TriggerServerEvent('ap_givecash:checkPlayer', ap)
	end
	handleInputDialog(false, data)
end

handleInputDialog = function(bool, data)
    showingInput = bool
    CreateThread(function()
        while showingInput do
            if #(GetEntityCoords(data.entity) - GetEntityCoords(cache.ped)) > 2.0 or not data.entity then
                sendNotify('Player not found!', 'error')
                lib.closeInputDialog()
                lib.closeAlertDialog()
                showingInput = false
            end
            Wait(1000)
        end
    end)
end

RegisterNetEvent('ap_givecash:sendAlert')
AddEventHandler('ap_givecash:sendAlert', function(data)
    local alert = lib.alertDialog({
        header = 'Accept?',
        content = 'You receive money amounting to $' .. lib.math.groupdigits(data.amount) .. (data.note ~= '' and '  \nNotes : ' .. data.note or ''),
        centered = true,
        cancel = true,
        size = 'md'
    })
    TriggerServerEvent('ap_givecash:sendMoney', data, alert)
end)

if Config.Target == 'ox' then
    exports.ox_target:addGlobalPlayer({
        {
            name = 'ap_givecash',
            icon = 'fa-solid fa-money-bill-wave',
            label = 'Give Cash',
            distance = 1.5,
            onSelect = function(data)
                createInputMenu(data)
            end,
            canInteract = function()
                return not IsPedInAnyVehicle(cache.ped)
            end
        },
    })
elseif Config.Target == 'qb' then
    exports['qb-target']:AddGlobalPlayer({
        options = {
            {
                name = 'ap_givecash',
                icon = 'fa-solid fa-money-bill-wave',
                label = 'Give Cash',
                action = function(entity)
                    createInputMenu({entity = entity})
                end,
                canInteract = function()
                    return not IsPedInAnyVehicle(cache.ped)
                end
            },
        },
        distance = 1.5
    })
end
