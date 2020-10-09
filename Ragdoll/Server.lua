Citizen.CreateThread(function()
    local vRaw = LoadResourceFile(GetCurrentResourceName(), 'Version.json')

    if vRaw and VersionCheck then
		local Client = json.decode(vRaw)
		PerformHttpRequest(
            "https://raw.githubusercontent.com/AlexR32/FiveM-Ragdoll/master/Ragdoll/Version.json",
            function(Code, Result, Header)
                if Code == 200 then
                    local Github = json.decode(Result)
                    if Github.Version ~= Client.Version then
                        print("^3[FiveM-Ragdoll]^0\nCurrent Version: ^1" .. Client.Version .. "^0\nAvailable Version: ^2" .. Github.Version .. "^0\nChangelog: " .. Github.Changelog)
					end
				else
					print("^1[FiveM-Ragdoll]^0\nUnable to check version\nError Code: " .. Code)
                end
        end, "GET")
	end
end)