repeat task.wait() until game:IsLoaded()
if shared.spectre then shared.spectre:Uninject() end

local spectre
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and spectre then
		spectre:CreateNotification('Spectre', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/kinfeadiguess/SpectreCompiled/'..readfile('spectre/profiles/commit.txt')..'/'..select(1, path:gsub('spectre/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--[spectre:cached]\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	spectre.Init = nil
	spectre:Load()
	task.spawn(function()
		repeat
			spectre:Save()
			task.wait(10)
		until not spectre.Loaded
	end)

	local teleportedServers
	spectre:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.SpectreIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.spectreload = true
				if shared.SpectreDeveloper then
					loadstring(readfile('spectre/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/kinfeadiguess/SpectreCompiled/'..readfile('spectre/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]

			if shared.SpectreDeveloper then
				teleportScript = 'shared.SpectreDeveloper = true\n'..teleportScript
			end

			if shared.SpectreCustomProfile then
				teleportScript = 'shared.SpectreCustomProfile = "'..shared.SpectreCustomProfile..'"\n'..teleportScript
			end

			spectre:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.spectreload then
		if not spectre.Categories then return end
		if spectre.Settings.GUI.Options['GUI bind indicator'].Enabled then
			spectre:CreateNotification('Finished Loading', spectre.SpectreButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(spectre.GUIBind.Keys, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('spectre/profiles/gui.txt') then
	writefile('spectre/profiles/gui.txt', 'new')
end
local gui = 'new'--readfile('spectre/profiles/gui.txt')

if not isfolder('spectre/assets/'..gui) then
	makefolder('spectre/assets/'..gui)
end
spectre = loadstring(downloadFile('spectre/guis/'..gui..'.lua'), 'gui')()
shared.spectre = spectre

if not shared.SpectreIndependent then
	loadstring(downloadFile('spectre/games/universal.lua'), 'universal')()
	if isfile('spectre/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('spectre/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.SpectreDeveloper then
			local success, data = pcall(downloadFile, 'spectre/games/'..game.PlaceId..'.lua')
			if success then
				loadstring(data, tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	spectre.Init = finishLoading
	return spectre
end
