Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Impound.RetrieveLocation.x, Config.Impound.RetrieveLocation.y, Config.Impound.RetrieveLocation.z)
	SetBlipScale(blip, 0.7)
	SetBlipDisplay(blip, 4)
	SetBlipSprite(blip, 357)
	SetBlipColour(blip, 5)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("In beslagname opslag")
	EndTextCommandSetBlipName(blip)
	while true do
		Citizen.Wait(5)
		local pedcoords = GetEntityCoords(GetPlayerPed(-1))
		if(GetDistanceBetweenCoords(pedcoords, Config.Impound.RetrieveLocation.x, Config.Impound.RetrieveLocation.y, Config.Impound.RetrieveLocation.z, true) < 40.0) then
			DrawMarker(23, Config.Impound.RetrieveLocation.x, Config.Impound.RetrieveLocation.y, Config.Impound.RetrieveLocation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, Config.ColorR, Config.ColorG, Config.ColorB, 255, false, true, 2, false, false, false)
			Draw3DText(Config.Impound.RetrieveLocation.x, Config.Impound.RetrieveLocation.y, Config.Impound.RetrieveLocation.z -1.000, "Druk E voor jouw in beslag genomen voertuigen", 4, 0.1, 0.1)
			if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
				DrawMarker(23, Config.Impound.StoreLocation.x, Config.Impound.StoreLocation.y, Config.Impound.StoreLocation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, Config.ColorR, Config.ColorG, Config.ColorB, 255, false, true, 2, true, false, false, false)
				Draw3DText(Config.Impound.StoreLocation.x, Config.Impound.StoreLocation.y, Config.Impound.StoreLocation.z -1.000, "Druk E om het voertuig in beslag te nemen", 4, 0.1, 0.1)
				if(GetDistanceBetweenCoords(pedcoords, Config.Impound.StoreLocation.x, Config.Impound.StoreLocation.y, Config.Impound.StoreLocation.z, true) < 7.0) then
					if IsControlJustPressed(0, 38) then
						ImpoundVoertuig()
					end
				end
			end	
			if(GetDistanceBetweenCoords(pedcoords, Config.Impound.RetrieveLocation.x, Config.Impound.RetrieveLocation.y, Config.Impound.RetrieveLocation.z, true) < 2.0) then
				if IsControlJustPressed(0, 38) then				
					ImpoundedVoertuigenMenu()
				end
			end
			if IsControlJustPressed(1, 177) and not Menu.hidden then
				CloseMenu()
				PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
			end
		end
	end
	Menu.renderGUI()
	Citizen.Wait(100)
end)

function ImpoundVoertuig()
	local coords = GetEntityCoords(GetPlayerPed(-1))
	local vehicle = GetClosestVehicle(Config.Impound.StoreLocation.x, Config.Impound.StoreLocation.y, Config.Impound.StoreLocation.z,  7.0,  0,  71)
	if DoesEntityExist(vehicle) then
		if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
			exports['mythic_notify']:SendAlert('inform', 'Stap uit het voertuig', 5000, { ['background-color'] = Config.ColorHex, ['color'] = '#ffffff' })
		else
			local vehicleProps = GetVehicleProperties(vehicle)
			local plate = vehicleProps.plate
			ESX.TriggerServerCallback('AS_SimpleGarage:isOwned', function(isPlateTaken)
				if isPlateTaken == false then
					StartImpoundAnimatie()
					Citizen.Wait(9400)
					Citizen.Wait(500)	
					NetworkFadeOutEntity(vehicle, true, true)	
					Citizen.Wait(100)	
					ESX.Game.DeleteVehicle(vehicle)
					exports['mythic_notify']:SendAlert('inform', 'Voertuig in beslag genomen', 5000, { ['background-color'] = Config.ColorHex, ['color'] = '#ffffff' })
				elseif isPlateTaken == true then -- Vehicle has owner
					KeyboardInput("Voer het boetebedrag in tussen €250 en €2500", "", 4)
					local price = tonumber(GetOnscreenKeyboardResult())
					if price ~= nil then
						if price < 2501 and price > 249 then
							StartImpoundAnimatie()
							Citizen.Wait(9400)
							Citizen.Wait(500)	
							NetworkFadeOutEntity(vehicle, true, true)
							TriggerServerEvent('AS_SimpleGarage:ImpoundVoertuig', plate, vehicleProps, price)
							Citizen.Wait(100)	
							ESX.Game.DeleteVehicle(vehicle)
							exports['mythic_notify']:SendAlert('inform', 'Voertuig in beslag genomen met een boetebedrag van: €'..price, 5000, { ['background-color'] = Config.ColorHex, ['color'] = '#ffffff' })
						else
							exports['mythic_notify']:SendAlert('inform', 'Boetebedrag is onjuist, probeer opnieuw', 5000, { ['background-color'] = Config.ColorHex, ['color'] = '#ffffff' })
						end
					else
						exports['mythic_notify']:SendAlert('inform', 'Boetebedrag niet ingevuld', 5000, { ['background-color'] = Config.ColorHex, ['color'] = '#ffffff' })
					end
				end
			end, plate)
		end
	else
		exports['mythic_notify']:SendAlert('inform', 'Geen voertuig gevonden', 5000, { ['background-color'] = Config.ColorHex, ['color'] = '#ffffff' })
	end
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

	-- TextEntry		-->	The Text above the typing field in the black square
	-- ExampleText		-->	An Example Text, what it should say in the typing field
	-- MaxStringLenght	-->	Maximum String Lenght

	AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
	blockinput = true --Blocks new input while typing if **blockinput** is used

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() --Gets the result of the typing
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return result --Returns the result
	else
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return nil --Returns nil if the typing got aborted
	end
end

function StartImpoundAnimatie()
	TriggerEvent("mythic_progbar:client:progress", {
        name = "ImpoundVoertuig",
        duration = 10000,
        label = "Voertuig in beslag nemen...",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistdockssetup1clipboard@idle_a",
            anim = "idle_a",
        },
        prop = {
			model = "p_amb_clipboard_01",
			bone = 18905,
			coords = { x = 0.10, y = 0.02, z = 0.08 },
			rotation = { x = -80.0, y = 0.0, z = 0.0 },
		},
		propTwo = {
			model = "prop_pencil_01",
			bone = 58866,
			coords = { x = 0.12, y = 0.0, z = 0.001 },
			rotation = { x = -150.0, y = 0.0, z = 0.0 },
		},
    }, function(status)
		if not status then
			local ped = GetPlayerPed(-1)
			ClearPedTasksImmediately(ped)
        end
    end)
end

function ImpoundedVoertuigenMenu()
	Menu.hidden = not Menu.hidden
	TriggerEvent("inmenu",true)
	ClearMenu()
	Citizen.Wait(5)
	MenuTitle = "Impound"
	Menu.addButton("IN BESLAG GENOMEN VOERTUIGEN","CloseMenu",nil)

	ESX.TriggerServerCallback("AS_SimpleGarage:checkImpounded", function(fetchedVehicles)
		for k, v in ipairs(fetchedVehicles) do
			if v then
				local vehicleProps = v["props"]
				local displaytext = GetDisplayNameFromVehicleModel(vehicleProps["model"])
				local name = GetLabelText(displaytext)
				if (name == "NULL") then
					vehicleLabel = displaytext
				else
					vehicleLabel = name
				end
				local vehicle = vehicleProps
				local impoundprice = v["impoundprice"]
				Menu.addButton("" ..(vehicle["plate"]).." | "..vehicleLabel, "SpawnImpoundedVehicle", v, "", " Openstaande schuld: €" ..impoundprice.. "", "",nil)
			end
		end
	end)
end

function SpawnImpoundedVehicle(v)
	local data = v["props"]
	local vehicleProps = data
    if not vehicleProps.model then
        vehicleProps = data[1]
    end
	local spawnpoint = Config.Impound.SpawnLocation

	WaitForModel(vehicleProps["model"])

	if DoesEntityExist(cachedData["vehicle"]) then
		DeleteEntity(cachedData["vehicle"])
	end
	
	if not ESX.Game.IsSpawnPointClear(spawnpoint, 3.0) then 
		exports['mythic_notify']:SendAlert('inform', 'Er staat iets in de weg', 5000, { ['background-color'] = Config.ColorHex, ['color'] = '#ffffff' })
		return
	end
	CloseMenu()
	local gameVehicles = ESX.Game.GetVehicles()

	for i = 1, #gameVehicles do
		local vehicle = gameVehicles[i]

        if DoesEntityExist(vehicle) then
			if Config.Trim(GetVehicleNumberPlateText(vehicle)) == Config.Trim(vehicleProps["plate"]) then
				exports['mythic_notify']:SendAlert('inform', 'Voertuig is al in de wereld', 5000, { ['background-color'] = Config.ColorHex, ['color'] = '#ffffff' })
			end
		end
	end
	ESX.TriggerServerCallback('AS_SimpleGarage:checkMoney', function(EnoughMoney)
		if EnoughMoney == true then
			ESX.Game.SpawnVehicle(vehicleProps["model"], spawnpoint, 300.00, function(yourVehicle)
				SetVehicleProperties(yourVehicle, vehicleProps)
				NetworkFadeInEntity(yourVehicle, true, true)
				SetModelAsNoLongerNeeded(vehicleProps["model"])
				TaskWarpPedIntoVehicle(PlayerPedId(), yourVehicle, -1)
				SetEntityAsMissionEntity(yourVehicle, true, true)    
				SetVehicleHasBeenOwnedByPlayer(yourVehicle, true)
				TriggerServerEvent('AS_SimpleGarage:VeranderSpawnStatus', vehicleProps.plate, false)
				local plate = vehicleProps.plate
				TriggerServerEvent('AS_SimpleGarage:UitImpound', plate)
				IsVehicleRegistered(plate)
				SetVehicleLockState(plate, yourVehicle)
		
				ClearMenu()
			end)
		elseif EnoughMoney == false then -- Owner has no money
			exports['mythic_notify']:SendAlert('inform', 'Er staat niet genoeg op je bankrekening', 5000, { ['background-color'] = Config.ColorHex, ['color'] = '#ffffff' })
		end
	end, v["impoundprice"])
end