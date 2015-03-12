--[[
	PocoHud EntryPoint
--]]

--RegisterScript("poco/common.luac", 1, "UNDERSCORE")
--RegisterScript("poco/common.luac", 1, "PocoHud3")

if io and not PocoDir then
	PocoDir = string.gsub(string.gsub(debug.getinfo(1).short_src,'\\','/'), "^(.+/)[^/]+$", "%1")..'../../poco/'
	local getEither = function (name)
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
		local filename = getEither("./poco/common.lua")
		if filename then AddPersistScript("UNDERSCORE", filename) end
		--if filename then RegisterScript(filename, 1, "UNDERSCORE") end
	end
	if not GetPersistScript("PocoHud3") then
		local filename = getEither("./poco/Hud3.lua")
		if filename then AddPersistScript("PocoHud3", filename) end
		--if filename then RegisterScript(filename, 1, "PocoHud3") end
	end
end