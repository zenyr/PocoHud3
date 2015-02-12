-- PocoHud EntryPoint v1

if io and not PocoEntryRun then
	PocoEntryRun = true
	local getEither = function (name) -- get either .lua or .luac
		local __req = function(name)
			local f= io.open(name,"r")
			if f~=nil then
				io.close(f)
				io.stdout:write('Found:'..name..'\n');
				return name
			end
			last = name
		end
		return __req(name) or __req(name..'c');
	end
	if not GetPersistScript("UNDERSCORE") then
		local filename = getEither("lib/lua/poco/common.lua")
		if filename then AddPersistScript("UNDERSCORE", filename) end
		--if filename then RegisterScript(filename, 1, "UNDERSCORE") end -- LE glitch
	end
	if not GetPersistScript("PocoHud3") then
		local filename = getEither("lib/lua/poco/Hud3.lua")
		if filename then AddPersistScript("PocoHud3", filename) end
		--if filename then RegisterScript(filename, 1, "PocoHud3") end -- LE glitch
	end
end