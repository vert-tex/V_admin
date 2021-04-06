ESX = nil

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
	end
end)

PlayerData = {}

godmode, visible, gamerTags, freeze = false, false, false, {}, false
resultl = false
local open = false
local alreadyOpen = false
local doorActionIndex = 1
local engineActionIndex = 1
local engineCoolDown = false
local extraCooldown = false
local doorCoolDown = false
local extraIndex = 1
local extraList = {"n°1","n°2","n°3","n°4","n°5","n°6","n°7","n°8","n°9","n°10","n°11","n°12","n°13","n°14","n°15"}
local extraStateIndex = 1
local convertibleCooldown = false
staffmodactive = false
local outfitcolorByRank = {
    ["superadmin"] = {color = 2, name = "~r~Superadmin"}
}
local beforeStaffOutfit = {}
local affichername = false
local afficherblips = false
local GetBlips = false
local pBlips = {}
local godmode = true
local ShowName = false
local gamerTags = {}
local NoClip = false
local NoClipSpeed = 2.0
local staffModeBol = false
local staffModeI = {
    [true] = "~s~",
    [false] = "~r~"
}
local colorVar = nil
local IdSelected = 0
staffRank = rank
colorVar = "~r~"

local money = {
	index = 1,
	list = {'~g~Liquide~s~', '~b~ En Banque~s~', '~r~Sale~s~'},
}

Citizen.CreateThread(function()
    while true do 
       Citizen.Wait(800)
       if colorVar == "~r~" then colorVar = "~o~" else colorVar = "~r~"  end 
   end 
end)

local ServersIdSession = {}

Citizen.CreateThread(function()
    while true do
        Wait(500)
        for k,v in pairs(GetActivePlayers()) do
            local found = false
            for _,j in pairs(ServersIdSession) do
                if GetPlayerServerId(v) == j then
                    found = true
                end
            end
            if not found then
                table.insert(ServersIdSession, GetPlayerServerId(v))
            end
        end
    end
end)

function DrawPlayerInfo(target)
	drawTarget = target
	drawInfo = true
end

function StopDrawPlayerInfo()
	drawInfo = false
	drawTarget = 0
end


function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function GiveCash()
    local amount = KeyboardInput("Somme", "", 8)

    if amount ~= nil then
        amount = tonumber(amount)
        
        if type(amount) == 'number' then
            TriggerServerEvent('vtx:GiveCash', amount)
        end
    end
end

function GiveBanque()
    local amount = KeyboardInput("Somme", "", 8)

    if amount ~= nil then
        amount = tonumber(amount)
        
        if type(amount) == 'number' then
            TriggerServerEvent('vtx:GiveBanque', amount)
        end
    end
end

function GiveND()
    local amount = KeyboardInput("Somme", "", 8)

    if amount ~= nil then
        amount = tonumber(amount)
        
        if type(amount) == 'number' then
            TriggerServerEvent('vtx:GiveND', amount)
        end
    end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if InStaff then

            if NoClip then
                HideHudComponentThisFrame(19)
                local pCoords = GetEntityCoords(GetPlayerPed(-1), false)
                local camCoords = getCamDirection()
                SetEntityVelocity(GetPlayerPed(-1), 0.01, 0.01, 0.01)
                SetEntityCollision(GetPlayerPed(-1), 0, 1)
            
                if IsControlPressed(0, 32) then
                    pCoords = pCoords + (NoClipSpeed * camCoords)
                end
            
                if IsControlPressed(0, 269) then
                    pCoords = pCoords - (NoClipSpeed * camCoords)
                end

                if IsControlPressed(1, 15) then
                    NoClipSpeed = NoClipSpeed + 0.5
                end
                if IsControlPressed(1, 16) then
                    NoClipSpeed = NoClipSpeed - 0.5
                    if NoClipSpeed < 0 then
                        NoClipSpeed = 0
                    end
                end
                SetEntityCoordsNoOffset(GetPlayerPed(-1), pCoords, true, true, true)
            end
            if invisible then
                SetEntityVisible(GetPlayerPed(-1), 0, 0)
                NetworkSetEntityInvisibleToNetwork(pPed, 1)
            else
                SetEntityVisible(GetPlayerPed(-1), 1, 0)
                NetworkSetEntityInvisibleToNetwork(pPed, 0)
			end
            if ShowName then
                local pCoords = GetEntityCoords(GetPlayerPed(-1), false)
                for _, v in pairs(GetActivePlayers()) do
                    local otherPed = GetPlayerPed(v)
                
                    if otherPed ~= pPed then
                        if #(pCoords - GetEntityCoords(otherPed, false)) < 250.0 then
                            gamerTags[v] = CreateFakeMpGamerTag(otherPed, ('[%s] %s'):format(GetPlayerServerId(v), GetPlayerName(v)), false, false, '', 0)
                            SetMpGamerTagVisibility(gamerTags[v], 4, 1)
                        else
                            RemoveMpGamerTag(gamerTags[v])
                            gamerTags[v] = nil
                        end
                    end
                end
            else
                for _, v in pairs(GetActivePlayers()) do
                    RemoveMpGamerTag(gamerTags[v])
                end
            end
        end
    end
end)

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(GetPlayerPed(-1))
	local pitch = GetGameplayCamRelativePitch()
	local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
	local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

	if len ~= 0 then
		coords = coords / len
	end

	return coords
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if GetBlips then
            local players = GetActivePlayers()
            for k,v in pairs(players) do
                local ped = GetPlayerPed(v)
                local blip = AddBlipForEntity(ped)
                table.insert(pBlips, blip)
                SetBlipScale(blip, 0.85)
                if IsPedOnAnyBike(ped) then
                    SetBlipSprite(blip, 226)
                elseif IsPedInAnyHeli(ped) then
                    SetBlipSprite(blip, 422)
                elseif IsPedInAnyPlane(ped) then
                    SetBlipSprite(blip, 307)
                elseif IsPedInAnyVehicle(ped, false) then
                    SetBlipSprite(blip, 523)
                else
                    SetBlipSprite(blip, 1)
                end

                if IsPedInAnyPoliceVehicle(ped) then
                    SetBlipSprite(blip, 56)
                    SetBlipColour(blip, 3)
                end
                SetBlipRotation(blip, math.ceil(GetEntityHeading(ped)))
			end
		else
			for k,v in pairs(pBlips) do
                RemoveBlip(v)
            end
        end
    end
end)

function generateStaffOutfit(model)
    clothesSkin = {}

    local couleur = outfitcolorByRank[playergroup].color        
   --ESX.ShowNotification("~o~[Staff] ~s~Tenue changée en: "..outfitcolorByRank[playergroup].name)
    TriggerEvent("FeedM:showAdvancedNotification", "~b~Statut du mode staff", "~r~Info Administration", "~o~[Staff] ~s~Tenue changée en : "..outfitcolorByRank[playergroup].name, "CHAR_STRETCH", Interval, Type)
    if model == GetHashKey("mp_m_freemode_01") then
        clothesSkin = {
            ['bags_1'] = 0, ['bags_2'] = 0,
            ['tshirt_1'] = 15, ['tshirt_2'] = 2,
            ['torso_1'] = 178, ['torso_2'] = 4,
            ['arms'] = 31,
            ['pants_1'] = 77, ['pants_2'] = 4,
            ['shoes_1'] = 55, ['shoes_2'] = 4,
            ['mask_1'] = 0, ['mask_2'] = 0,
            ['bproof_1'] = 0,
            ['chain_1'] = 0,
            ['helmet_1'] = 91, ['helmet_2'] = 4,
        }
    else
        clothesSkin = {
            ['bags_1'] = 0, ['bags_2'] = 0,
            ['tshirt_1'] = 31, ['tshirt_2'] = 0,
            ['torso_1'] = 180, ['torso_2'] = couleur,
            ['arms'] = 36, ['arms_2'] = 0,
            ['pants_1'] = 79, ['pants_2'] = couleur,
            ['shoes_1'] = 58, ['shoes_2'] = couleur,
            ['mask_1'] = 0, ['mask_2'] = 0,
            ['bproof_1'] = 0,
            ['chain_1'] = 0,
            ['helmet_1'] = 90, ['helmet_2'] = couleur,
        }
    end

    for k,v in pairs(clothesSkin) do
        TriggerEvent("skinchanger:change", k, v)
    end

    Citizen.Wait(1000)
        Citizen.CreateThread(function()
        while staffmodactive do
            
            if GetPedTextureVariation(PlayerPedId(), 11) ~= couleur then
                for k,v in pairs(clothesSkin) do
                    TriggerEvent("skinchanger:change", k, v)
                end
           end
            
            
            Citizen.Wait(2500)
        end
    end)
end
function Popup(txt)
	ClearPrints()
	SetNotificationBackgroundColor(140)
	SetNotificationTextEntry("STRING")
	AddTextComponentSubstringPlayerName(txt)
	DrawNotification(false, true)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if StaffMod then

            if ShowName then
                local pCoords = GetEntityCoords(GetPlayerPed(-1), false)
                for _, v in pairs(GetActivePlayers()) do
                    local otherPed = GetPlayerPed(v)
                
                    if otherPed ~= pPed then
                        if #(pCoords - GetEntityCoords(otherPed, false)) < 250.0 then
                            gamerTags[v] = CreateFakeMpGamerTag(otherPed, ('[%s] %s'):format(GetPlayerServerId(v), GetPlayerName(v)), false, false, '', 0)
                            SetMpGamerTagVisibility(gamerTags[v], 4, 1)
                        else
                            RemoveMpGamerTag(gamerTags[v])
                            gamerTags[v] = nil
                        end
                    end
                end
            else
                for _, v in pairs(GetActivePlayers()) do
                    RemoveMpGamerTag(gamerTags[v])
                end
            end

            for k,v in pairs(GetActivePlayers()) do
                if NetworkIsPlayerTalking(v) then
                    local pPed = GetPlayerPed(v)
                    local pCoords = GetEntityCoords(pPed)
                    DrawMarker(32, pCoords.x, pCoords.y, pCoords.z+1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 255, 0, 170, 0, 1, 2, 0, nil, nil, 0)
                end
			end
        end
    end
end)

function CustomString()
    local txt = nil
    AddTextEntry("CREATOR_TXT", "Entrez votre texte.")
    DisplayOnscreenKeyboard(1, "CREATOR_TXT", '', "", '', '', '', 15)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        txt = GetOnscreenKeyboardResult()
        Citizen.Wait(1)
    else
        Citizen.Wait(1)
    end
    return txt
end

function Notify(text)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(text)
	DrawNotification(false, true)
end

function CustomStringStaff()
    local txt = nil
    AddTextEntry("CREATOR_TXT", "Entrez votre texte.")
    DisplayOnscreenKeyboard(1, "CREATOR_TXT", '', "", '', '', '', 255)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        txt = GetOnscreenKeyboardResult()
        Citizen.Wait(1)
    else
        Citizen.Wait(1)
    end
    return txt
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLength)

	AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

function startStaff()
    Citizen.CreateThread(function()
        while staffmodactive do
            Citizen.Wait(1000)
            staffModeBol = not staffModeBol
        end
    end)
    Citizen.CreateThread(function()
        while staffmodactive do
            RageUI.Text({message = staffModeI[staffModeBol].."Mode administration~n~~s~Rang: "..outfitcolorByRank[playergroup].name.."~s~",time_display = 1})
            Citizen.Wait(1)
        end
    end)
end

local staffColor = {
    [0] = {color = "0", tag = ""},
    [1] = {color = "50", tag = ""},
    [2] = {color = "200", tag = ""},
    [3] = {color = "255", tag = ""},
    [4] = {color = "170", tag = "🛠️"},
}

function CustomAmount()
    local montant = nil
    AddTextEntry("BANK_CUSTOM_AMOUNT", "Entrez le montant")
    DisplayOnscreenKeyboard(1, "BANK_CUSTOM_AMOUNT", '', "", '', '', '', 15)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        montant = GetOnscreenKeyboardResult()
        Citizen.Wait(1)
    else
        Citizen.Wait(1)
    end
    return tonumber(montant)
end

function HelpNotif(msg)
    AddTextEntry('InitialvtxHelpNotification', msg)
	BeginTextCommandDisplayHelp('InitialvtxHelpNotification')
    EndTextCommandDisplayHelp(0, false, true, -1)
end


function KeyboardInput1(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)
	blockinput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(10)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
		blockinput = false
        return result
    else
        Citizen.Wait(500)
		blockinput = false
        return nil
    end
end

RegisterNetEvent("hAdmin:envoyer")
AddEventHandler("hAdmin:envoyer", function(msg)
	PlaySoundFrontend(-1, "CHARACTER_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
	local head = RegisterPedheadshot(PlayerPedId())
	while not IsPedheadshotReady(head) or not IsPedheadshotValid(head) do
		Wait(1)
	end
	headshot = GetPedheadshotTxdString(head)
    TriggerEvent("FeedM:showAdvancedNotification", "~b~Statut du mode staff", "~r~Info Administration", "~g~Message : ~b~"..msg, "CHAR_STRETCH", Interval, Type)
end)

local function initializeThread(rank,license)
    mug("Administration","~b~Statut du mode staff","Votre mode staff est pour le moment désactivé, vous pouvez l'activer au travers du ~o~[F11]")
end

local function mug(title, subject, msg)
    local mugshot, mugshotStr = ESX.Game.GetPedMugshot(PlayerPedId())
    ESX.ShowAdvancedNotification(title, subject, msg, mugshotStr, 1)
    UnregisterPedheadshot(mugshot)
end

function admin_tp_marker()
	local WaypointHandle = GetFirstBlipInfoId(8)

	if DoesBlipExist(WaypointHandle) then
		local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

		for height = 1, 1000 do
			SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

			local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

			if foundGround then
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

				break
			end

			Citizen.Wait(0)
		end

        TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~g~Téléportation Effectuée", "CHAR_STRETCH", Interval, Type)	
	else
        TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~r~Aucun Marqueur...\n~w~Placez un maqueur sur la map", "CHAR_STRETCH", Interval, Type)	
	end
end

RegisterNetEvent("CA")
AddEventHandler("CA", function()
  local pos = GetEntityCoords(GetPlayerPed(-1), true)
  ClearAreaOfObjects(pos.x, pos.y, pos.z, 50.0, 0)
end)


local players = {}
RegisterNetEvent("vtx:list")
AddEventHandler("vtx:list", function(list)
    players = list
    print("Players list loaded")
end)

---------------- FONCTIONS ------------------

RMenu.Add('vtx', 'admin', RageUI.CreateMenu("Administration", "Mode Administrateur"))
RMenu:Get('vtx', 'admin').Closed = function()end
RMenu.Add('vtx', 'remboursement', RageUI.CreateSubMenu(RMenu:Get('vtx', 'admin'), "Administration", nil))
RMenu:Get('vtx', 'remboursement').Closed = function()end

RMenu.Add('vtx', 'item', RageUI.CreateSubMenu(RMenu:Get('vtx', 'remboursement'), "Administration", nil))
RMenu:Get('vtx', 'item').Closed = function()end

RMenu.Add('vtx', 'vehicule', RageUI.CreateSubMenu(RMenu:Get('vtx', 'admin'), "Administration", nil))
RMenu:Get('vtx', 'vehicule').Closed = function()end

RMenu.Add('vtx', 'joueur', RageUI.CreateSubMenu(RMenu:Get('vtx', 'admin'), "Administration", nil))
RMenu:Get('vtx', 'joueur').Closed = function()end

RMenu.Add('vtx', 'divers', RageUI.CreateSubMenu(RMenu:Get('vtx', 'admin'), "Administration", nil))
RMenu:Get('vtx', 'divers').Closed = function()end

RMenu.Add('vtx', 'list', RageUI.CreateSubMenu(RMenu:Get('vtx', 'admin'), "Administration", nil))
RMenu:Get('vtx', 'list').Closed = function()end

RMenu.Add('vtx', 'action', RageUI.CreateSubMenu(RMenu:Get('vtx', 'list'), "Administration", nil))
RMenu:Get('vtx', 'action').Closed = function()end

RMenu.Add('vtx', 'job', RageUI.CreateSubMenu(RMenu:Get('vtx', 'action'), "Administration", nil))
RMenu:Get('vtx', 'job').Closed = function()end

RMenu.Add('vtx', 'group', RageUI.CreateSubMenu(RMenu:Get('vtx', 'action'), "Administration", nil))
RMenu:Get('vtx', 'group').Closed = function()end

RMenu.Add('vtx', 'ban', RageUI.CreateSubMenu(RMenu:Get('vtx', 'joueur'), "Administration", nil))
RMenu:Get('vtx', 'ban').Closed = function()end

Citizen.CreateThread(function()
    while true do
    RageUI.IsVisible(RMenu:Get('vtx', 'admin'), true, true, true, function()
    RageUI.Separator(colorVar.."Mode administration")
    RageUI.Checkbox("Activer le mod staff", "Ouvre ce menu l'orsque que tu veut faire de la modération", InStaff, { Style = RageUI.CheckboxStyle.Tick }, function(Hovered, Selected, Active, Checked)
        InStaff = Checked;
    end, function()
        staffmodactive = true
        --mug("Administration","~b~Statut du mode staff","Vous êtes désormais: ~g~en administration~s~.")
        TriggerEvent("FeedM:showAdvancedNotification", "~b~Statut du mode staff", "~r~Info Administration", "Vous êtes désormais : ~g~en administration~s~.", "CHAR_STRETCH", Interval, Type)
        Citizen.CreateThread(function()
            generateStaffOutfit(GetEntityModel(PlayerPedId()))
            FreezeEntityPosition(GetPlayerPed(-1), false)
            NoClip = false
        end)

        startStaff()
    end, function()
        staffmodactive = false
        --mug("Administration","~b~Statut du mode staff","Vous êtes désormais ~r~hors administration~s~.")
        TriggerEvent("FeedM:showAdvancedNotification", "~b~Statut du mode staff", "~r~Info Administration", "Vous êtes désormais : ~r~hors administration~s~.", "CHAR_STRETCH", Interval, Type)
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
        end)
    end)

    RageUI.ButtonWithStyle("Joueurs", nil, { RightLabel = "→" }, InStaff, function(_,_,s)
    end, RMenu:Get('vtx', 'joueur'))

    RageUI.ButtonWithStyle("Action véhicule", nil, { RightLabel = "→" }, InStaff, function(_,_,s)
    end, RMenu:Get('vtx', 'vehicule'))

    RageUI.ButtonWithStyle("Divers", nil, { RightLabel = "→" }, InStaff, function(_,_,s)
    end, RMenu:Get('vtx', 'divers'))



    end, function()
     end)

     RageUI.IsVisible(RMenu:Get('vtx', 'joueur'), true, true, true, function()
        RageUI.Separator(colorVar.."↓↓Liste des joueurs↓↓")
        RageUI.ButtonWithStyle("Liste des joueurs", "Permet de faire des actions sur les joueurs en lignes.", { RightLabel = "→" }, InStaff, function(_,_,s)
            if s then

            end
        end, RMenu:Get('vtx', 'list'))

    end, function()
    end)

    RageUI.IsVisible(RMenu:Get('vtx', 'vehicule'), true, true, true, function()
        RageUI.Separator(colorVar.."↓↓ Action véhicule ↓↓")
        
        RageUI.ButtonWithStyle("Spawn un véhicule", nil, { RightBadge = RageUI.BadgeStyle.Car }, InStaff, function(Hovered, Active, Selected)
            if Selected then
                local ped = GetPlayerPed(tgt)
                local ModelName = KeyboardInput("Véhicule", "", 100)

                if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
                    RequestModel(ModelName)
                    while not HasModelLoaded(ModelName) do
                        Citizen.Wait(0)
                    end
                        local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(GetPlayerPed(-1)), GetEntityHeading(GetPlayerPed(-1)), true, true)
                        TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
                        Wait(50)
                        TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~g~Votre véhicule a bien spawn", "CHAR_STRETCH", Interval, Type)
                else
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~r~Véhicule invalide", "CHAR_STRETCH", Interval, Type)
                end
            end
            end)

        RageUI.ButtonWithStyle("Réparer le véhicule", "Permet de réparer le véhicule le plus proche.", { RightBadge = RageUI.BadgeStyle.Car }, InStaff, function(Hovered, Active, Selected)
            if Selected then
                if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                    vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                    if DoesEntityExist(vehicle) then
                        SetVehicleFixed(vehicle)
                        SetVehicleDeformationFixed(vehicle)
                        TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~g~Vous avez réparé votre véhicule", "CHAR_STRETCH", Interval, Type)

                    end
                end
            end
        end)

        RageUI.ButtonWithStyle("Supprimer le véhicule", "Permet de supprimer le véhicule le plus proche.", { RightBadge = RageUI.BadgeStyle.Car }, InStaff, function(Hovered, Active, Selected)
            if Selected then
                TriggerEvent("esx:deleteVehicle")
                TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~g~Vous avez supprimé un véhicule", "CHAR_STRETCH", Interval, Type)
            end
        end)

    end, function()
    end)

    
    RageUI.IsVisible(RMenu:Get('vtx', 'divers'), true, true, true, function()
        RageUI.Separator(colorVar.."↓↓ Action divers ↓↓")
        RageUI.Checkbox("Noclip", description, crossthemap,{},function(Hovered,Ative,Selected,Checked)
            if Selected then
                crossthemap = Checked
                if Checked then
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "Molette vers le bas = Vitesse ~g~Lente\n~s~Molette vers le haut = Vitesse ~r~Rapide", "CHAR_STRETCH", Interval, Type)
                    FreezeEntityPosition(GetPlayerPed(-1), true)
                    NoClip = true
                    invisible = true
                else
                    FreezeEntityPosition(GetPlayerPed(-1), false)
                    SetEntityCollision(GetPlayerPed(-1), 1, 1)
                    NoClip = false
                    invisible = false
                end
            end
        end)

        RageUI.Checkbox("Afficher les Noms", description, affichername,{},function(Hovered,Ative,Selected,Checked)
            if Selected then
                affichername = Checked
                if Checked then
                    ShowName = true
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "Les noms sont ~g~affichés", "CHAR_STRETCH", Interval, Type)
                else
                    ShowName = false
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "Les noms ne sont plus ~r~affichés", "CHAR_STRETCH", Interval, Type)
                end
            end
        end)
        
        RageUI.Checkbox("Afficher les Blips", description, afficherblips,{},function(Hovered,Ative,Selected,Checked)
            if Selected then
                afficherblips = Checked
                if Checked then
                    GetBlips = true
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "Les blips sont ~g~affichés", "CHAR_STRETCH", Interval, Type)
                else
                    GetBlips = false
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "Les blips ne sont plus ~r~affichés", "CHAR_STRETCH", Interval, Type)
                end
            end
        end)

        RageUI.Checkbox("Invincible", description, invincible,{},function(Hovered,Ative,Selected,Checked)
            if Selected then
                invincible = Checked
                if Checked then
                    SetEntityInvincible(PlayerPedId(), true)
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "Invincibilité ~g~activé", "CHAR_STRETCH", Interval, Type)	
                else
                    SetEntityInvincible(PlayerPedId(), false)
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "Invincibilité ~r~desactivé", "CHAR_STRETCH", Interval, Type)	
                end
            end
        end)
        RageUI.Checkbox("Invisible", description, invisible,{},function(Hovered,Ative,Selected,Checked)
            if Selected then
                invisible = Checked
                if Checked then
                    SetEntityVisible(PlayerPedId(), false, false)
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "Invicibilité ~g~activé", "CHAR_STRETCH", Interval, Type)	
                    else
                    SetEntityVisible(PlayerPedId(), true, false)
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "Invicibilité ~r~desactivé", "CHAR_STRETCH", Interval, Type)	                    --end
                end
            end
        end)

        RageUI.Button("TP sur le marqueur", nil, InStaff, function(_,_,s)
            if s then
                admin_tp_marker()
            end
        end)

        RageUI.Button("Nettoyer les props", nil, InStaff, function(_,_,s)
            if s then
            TriggerEvent("CA")
            TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~g~Vous avez nettoyé les props avec succés", "CHAR_STRETCH", Interval, Type)	
            end
        end)
        RageUI.Checkbox("Afficher les coordonnées", description, affichagecoords,{},function(Hovered,Ative,Selected,Checked)
            if Selected then
                local affichagecoords = true
                while affichagecoords do
                    Wait(0)
                    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
                    local h = GetEntityHeading(GetPlayerPed(-1)) 
                    local r = GetEntityRotation(GetPlayerPed(-1))
                    print("Coords:  ^1X: "..x.." | ^3Y: " ..y.. " | ^4Z: "..z.. " | ^7H: "..h)
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~r~Appuyez sur E pour enlever les coordonnées.", "CHAR_STRETCH", Interval, Type)	
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~b~Pour voir les coordonnées faite F8.", "CHAR_STRETCH", Interval, Type)	
                    if IsControlJustPressed(0, 51) then
                        affichagecoords = false
                    end
                end
            end
        end)


    end, function()
    end)


     RageUI.IsVisible(RMenu:Get('vtx', 'list'), true, true, true, function()
        RageUI.Separator(colorVar.."↓↓Liste des joueurs↓↓")

        for k,v in ipairs(ServersIdSession) do
            if GetPlayerName(GetPlayerFromServerId(v)) == "**Invalid**" then table.remove(ServersIdSession, k) end
            RageUI.ButtonWithStyle(v.."~w~ - " ..GetPlayerName(GetPlayerFromServerId(v)), nil, {}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    IdSelected = v
                end
            end, RMenu:Get('vtx', 'action'))
        end
    end, function()
    end)

    RageUI.IsVisible(RMenu:Get('vtx', 'action'), true, true, true, function()
        RageUI.Separator(colorVar.."[ " .. GetPlayerName(LastId) .. " ]")
        --RageUI.Separator(colorVar.."↓↓ Action joueur ↓↓")
        RageUI.Button("Envoyer un message", nil, true, function(_,_,s)
            if s then
                local msg = KeyboardInput("Raison", "", 100)

                if msg ~= nil then
                    msg = tostring(msg)
            
                    if type(msg) == 'string' then
                        TriggerServerEvent("hAdmin:Message", IdSelected, msg)
                    end
                end
                TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~g~Message envoyé à :			 ~b~" .. GetPlayerName(GetPlayerFromServerId(IdSelected)), "CHAR_STRETCH", Interval, Type)
            end
        end)
        
        RageUI.ButtonWithStyle("Spectate la personne", "Regarder la personne", {}, true, function(Hovered, Active, Selected)
            if Selected then			
                -- Pas fait
            end
        end)

        RageUI.Button("Téléporter sur le joueur", nil, true, function(_,_,s)
            if s then
                SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected))))
                TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~g~Vous venez de vous téléporter à " .. GetPlayerName(GetPlayerFromServerId(IdSelected)), "CHAR_STRETCH", Interval, Type)
            end
        end)

        RageUI.Button("Téléporter le joueur sur moi", nil, true, function(_,_,s)
            if s then
                ExecuteCommand("bring "..IdSelected)
                TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~g~Vous venez de téléporter " .. GetPlayerName(GetPlayerFromServerId(IdSelected)), "CHAR_STRETCH", Interval, Type)

            end
        end)

        RageUI.Button("Revive", nil, true, function(_,_,s)
            if s then
                ExecuteCommand("revive "..IdSelected)  
                TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~g~Vous venez de revive " .. GetPlayerName(GetPlayerFromServerId(IdSelected)), "CHAR_STRETCH", Interval, Type)
            end
        end)

        RageUI.Button("Changer le job", nil, true, function(_,_,s)
        end, RMenu:Get('vtx', 'job'))

        RageUI.Button("Remboursement", nil, playergroup == "admin" or playergroup == "superadmin" or playergroup == "owner", function()
        end, RMenu:Get('vtx', 'remboursement'))

    end, function()
    end)

    RageUI.IsVisible(RMenu:Get('vtx', 'remboursement'), true, true, true, function()

        RageUI.Button("Donner un item", nil, true, function(_,_,s)
            if s then
                local item = KeyboardInput("Item", "", 10)
                local amount = KeyboardInput("Nombre", "", 10)
                if item and amount then
                    ExecuteCommand("giveitem "..IdSelected.. " " ..item.. " " ..amount)
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration", "~g~Vous venez de donner "..amount.. " " .. item .. " ~b~à " .. GetPlayerName(GetPlayerFromServerId(IdSelected)), "CHAR_STRETCH", Interval, Type)                else
                    ESX.ShowNotification("~r~ERROR 404\nChamp Invalide")
                    RageUI.CloseAll()	
                end			
            end
        end)

        RageUI.List('Donner de l\'argent :', money.list, money.index, nil, {}, true, function(Hovered, Active, Selected, Index)
            if (Selected) then
                if Index == 1 then
                    GiveCash()
                elseif Index == 2 then
                    GiveBanque()
                elseif Index == 3 then
                    GiveND()
                end
            end
            money.index = Index
        end)
    end, function()
    end)

    RageUI.IsVisible(RMenu:Get('vtx', 'job'), true, true, true, function()
        RageUI.ButtonWithStyle("~b~Setjob : ~s~  ".. GetPlayerName(GetPlayerFromServerId(IdSelected)) .." ", nil, {}, true, function(Hovered, Active, Selected)
            if (Selected) then
                local job = KeyboardInput1("N_BOX_AMOUNT", "Nom du Job", "", 20)
                local grade = KeyboardInput1("N_BOX_AMOUNT", "Numero du Grade", "", 20)
                if job and grade then
                    ExecuteCommand("setjob "..IdSelected.. " " ..job.. " " ..grade)
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration","Vous venez de setjob ~g~"..job.. " " .. grade .. " " .. GetPlayerName(GetPlayerFromServerId(IdSelected)), "CHAR_STRETCH", Interval, Type)
                else
                    TriggerEvent("FeedM:showAdvancedNotification", "~b~Status", "~r~Info Administration","~ERROR 404", "CHAR_STRETCH", Interval, Type)
                    RageUI.CloseAll()	
                end	
            end
        end)
    end, function()
    end)

     Citizen.Wait(0)
    end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
				if IsControlJustPressed(0, 289) then
					ESX.TriggerServerCallback('RubyMenu:getUsergroup', function(group)
						playergroup = group
						if playergroup == 'superadmin' or playergroup == 'owner' then
							superadmin = true
							RageUI.Visible(RMenu:Get('vtx', 'admin'), not RageUI.Visible(RMenu:Get('vtx', 'admin'))) 
						end
					end)

				end -- Touche F2
	end
end)