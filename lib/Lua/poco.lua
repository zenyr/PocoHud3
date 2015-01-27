--RegisterScript("poco/common.luac", 1, "UNDERSCORE")
--RegisterScript("poco/common.luac", 1, "PocoHud3")
if not GetPersistScript("UNDERSCORE") then AddPersistScript("UNDERSCORE", "poco/common.luac") end
if not GetPersistScript("PocoHud3") then AddPersistScript("PocoHud3", "poco/Hud3.luac") end

--[[
Commented lines are how it is supposed to work as documented, however both keybind and persist modes seem to
not currently function when using RegisterScript, while post-requires do work. As a workaround the two
uncommented lines are in use, which provide identical functionality for minimal (possibly no) additional
overhead.
--]]