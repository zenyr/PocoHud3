-- Poco Common Library V3.1 --
if type(Poco) == 'table' and Poco.destroy and not Poco.dead then
	Poco:destroy()
end
Poco = {}
Poco._req = function (name)
	local __req = function(name)
		local f=io.open(name,"r")
		if f~=nil then
			io.close(f)
			return dofile(name)
		end
	end
	return __req(name) or __req(name..'c')
end
Poco._req ('poco/3rdPartyLibrary.lua')
local inGame = CopDamage ~= nil
local now = function (type) return type and TimerManager:game():time() or managers.player:player_timer():time() end
if not deep_clone then return end
-- GLOBALS --
-- * cl
cl = {
	AliceBlue = Color(16/17,248/255,1), AntiqueWhite = Color(50/51,47/51,43/51), Aqua = Color(0,1,1), Aquamarine = Color(127/255,1,212/255), Azure = Color(16/17,1,1), Beige = Color(49/51,49/51,44/51), Bisque = Color(1,76/85,196/255), Black = Color(0,0,0), BlanchedAlmond = Color(1,47/51,41/51), Blue = Color(0,0,1), BlueViolet = Color(46/85,43/255,226/255), Brown = Color(11/17,14/85,14/85), Burlywood = Color(74/85,184/255,9/17), CadetBlue = Color(19/51,158/255,32/51), Chartreuse = Color(127/255,1,0), Chocolate = Color(14/17,7/17,2/17), Coral = Color(1,127/255,16/51), CornFlowerBlue = Color(20/51,149/255,79/85), CornSilk = Color(1,248/255,44/51), Crimson = Color(44/51,4/51,4/17), Cyan = Color(0,1,1), DarkBlue = Color(0,0,139/255), DarkCyan = Color(0,139/255,139/255), DarkGoldenRod = Color(184/255,134/255,11/255), DarkGray = Color(169/255,169/255,169/255), Darkgreen = Color(0,20/51,0), DarkKhaki = Color(63/85,61/85,107/255), DarkMagenta = Color(139/255,0,139/255), DarkOliveGreen = Color(1/3,107/255,47/255), DarkOrange = Color(1,28/51,0), DarkOrchid = Color(3/5,10/51,4/5), DarkRed = Color(139/255,0,0), DarkSalmon = Color(233/255,10/17,122/255), DarkSeaGreen = Color(143/255,188/255,139/255), DarkSlateBlue = Color(24/85,61/255,139/255), DarkSlategray = Color(47/255,79/255,79/255), DarkTurquoise = Color(0,206/255,209/255), DarkViolet = Color(148/255,0,211/255), DeepPink = Color(1,4/51,49/85), DeepSkyBlue = Color(0,191/255,1), DimGray = Color(7/17,7/17,7/17), DodgerBlue = Color(2/17,48/85,1), Firebrick = Color(178/255,2/15,2/15), FloralWhite = Color(1,50/51,16/17), ForestGreen = Color(2/15,139/255,2/15), Fuchsia = Color(1,0,1), Gainsboro = Color(44/51,44/51,44/51), GhostWhite = Color(248/255,248/255,1), Gold = Color(1,43/51,0), GoldenRod = Color(218/255,11/17,32/255), Gray = Color(128/255,128/255,128/255), Green = Color(0,128/255,0), GreenYellow = Color(173/255,1,47/255), Honeydew = Color(16/17,1,16/17), HotPink = Color(1,7/17,12/17), IndianRed = Color(41/51,92/255,92/255), Indigo = Color(5/17,0,26/51), Ivory = Color(1,1,16/17), Khaki = Color(16/17,46/51,28/51), Lavender = Color(46/51,46/51,50/51), LavenderBlush = Color(1,16/17,49/51), LawnGreen = Color(124/255,84/85,0), LemonChiffon = Color(1,50/51,41/51), LightBlue = Color(173/255,72/85,46/51), LightCoral = Color(16/17,128/255,128/255), LightCyan = Color(224/255,1,1), LightGoldenrodYellow = Color(50/51,50/51,14/17), LightGray = Color(211/255,211/255,211/255), LightGreen = Color(48/85,14/15,48/85), LightPink = Color(1,182/255,193/255), LightSalmon = Color(1,32/51,122/255), LightSeaGreen = Color(32/255,178/255,2/3), LightSkyBlue = Color(9/17,206/255,50/51), LightSlateGray = Color(7/15,8/15,3/5), LightSteelBlue = Color(176/255,196/255,74/85), LightYellow = Color(1,1,224/255), Lime = Color(0,1,0), LimeGreen = Color(10/51,41/51,10/51), Linen = Color(50/51,16/17,46/51), Magenta = Color(1,0,1), Maroon = Color(128/255,0,0), MediumAquamarine = Color(2/5,41/51,2/3), MediumBlue = Color(0,0,41/51), MediumOrchid = Color(62/85,1/3,211/255), MediumPurple = Color(49/85,112/255,73/85), MediumSeaGreen = Color(4/17,179/255,113/255), MediumSlateBlue = Color(41/85,104/255,14/15), MediumSpringGreen = Color(0,50/51,154/255), MediumTurquoise = Color(24/85,209/255,4/5), MediumVioletRed = Color(199/255,7/85,133/255), MidnightBlue = Color(5/51,5/51,112/255), Mintcream = Color(49/51,1,50/51), MistyRose = Color(1,76/85,15/17), Moccasin = Color(1,76/85,181/255), NavajoWhite = Color(1,74/85,173/255), Navy = Color(0,0,128/255), OldLace = Color(253/255,49/51,46/51), Olive = Color(128/255,128/255,0), OliveDrab = Color(107/255,142/255,7/51), Orange = Color(1,11/17,0), OrangeRed = Color(1,23/85,0), Orchid = Color(218/255,112/255,214/255), PaleGoldenrod = Color(14/15,232/255,2/3), PaleGreen = Color(152/255,251/255,152/255), PaleTurquoise = Color(35/51,14/15,14/15), PaleVioletRed = Color(73/85,112/255,49/85), PapayaWhip = Color(1,239/255,71/85), PeachPuff = Color(1,218/255,37/51), Peru = Color(41/51,133/255,21/85), Pink = Color(1,64/85,203/255), Plum = Color(13/15,32/51,13/15), PowderBlue = Color(176/255,224/255,46/51), Purple = Color(128/255,0,128/255), Red = Color(1,0,0), RosyBrown = Color(188/255,143/255,143/255), RoyalBlue = Color(13/51,7/17,15/17), SaddleBrown = Color(139/255,23/85,19/255), Salmon = Color(50/51,128/255,38/85), SandyBrown = Color(244/255,164/255,32/85), SeaGreen = Color(46/255,139/255,29/85), Seashell = Color(1,49/51,14/15), Sienna = Color(32/51,82/255,3/17), Silver = Color(64/85,64/85,64/85), SkyBlue = Color(9/17,206/255,47/51), SlateBlue = Color(106/255,6/17,41/51), SlateGray = Color(112/255,128/255,48/85), Snow = Color(1,50/51,50/51), SpringGreen = Color(0,1,127/255), SteelBlue = Color(14/51,26/51,12/17), Tan = Color(14/17,12/17,28/51), Teal = Color(0,128/255,128/255), Thistle = Color(72/85,191/255,72/85), Tomato = Color(1,33/85,71/255), Turquoise = Color(64/255,224/255,208/255), Violet = Color(14/15,26/51,14/15), Wheat = Color(49/51,74/85,179/255), White = Color(1,1,1), WhiteSmoke = Color(49/51,49/51,49/51), Yellow = Color(1,1,0), YellowGreen = Color(154/255,41/51,10/51)
}
-- *_, UNDERSCORE
_ = {
	F = function (n,k) -- ff
		k = k or 2
		if type(n) == 'number' then
			local r = string.format('%.'..k..'g', n):sub(1,k+2)
			return r:find('e') and tostring(math.floor(n)) or r
		elseif type(n) == 'table' then
			return _.i(n):gsub('\n','')
		else
			return tostring(n)
		end
	end,
	S = function (...) -- toStr
		local a,b = clone({...}) , {}
		for k,v in pairs(a) do
			b[#b+1] = _.F(v)
		end
		local r,err = pcall(table.concat,b,' ')
		if r then
			return err
		else
			return '_.s Err: '.._.i(b):gsub('\n','')
		end
	end,
	C = function (name,message,color) -- Chat
		if not message then
			message = name
			name = nil
		end
		if not tostring(color):find('Color') then
			color = nil
		end
		message = _.S(message)
		if managers and managers.chat and managers.chat._receivers and managers.chat._receivers[1] then
			for __,rcv in pairs( managers.chat._receivers[1] ) do
				rcv:receive_message( name or "*", message, color or tweak_data.chat_colors[5] )
			end
		else
			_('_.C',message)
		end
	end,
	D = function (...) -- Debug
		if managers and managers.mission then
			managers.mission._show_debug_subtitle(managers.mission,_.S(...)..'  ')
			return true
		else
			_('_.D',...)
		end
	end,
	O = function (...) -- File
		local f = io.open("poco\\output.txt", "a")
		f:write(_.S(...).."\n")
		f:close()
	end,
	R = function (mask) -- RayTest
		-- local _maskDefault = World:make_slot_mask( 2, 8, 11, 12, 14, 16, 18, 21, 22, 25, 26, 33, 34, 35 )
		local from = alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()
		if not from then return end
		local to = from + managers.player:player_unit():movement():m_head_rot():y() * 30000
		local masks = type(mask)=='string' and managers.slot:get_mask( mask ) or mask or managers.slot:get_mask( 'bullet_impact_targets' )
		return World:raycast( "ray", from, to, "slot_mask", masks)
	end,
	G = function (path,fallback,origin) -- SafeGet
		local from = origin or _G
		local lPath = ''
		for curr,delim in string.gmatch (path, "([%a_]+)([^%a_]*)") do
			local isFunc = string.find(delim,'%(')
			if isFunc then
				from = from[curr](from)
			else
				from = from[curr]
			end
			lPath = lPath..curr..delim
			if not from then
				break
			elseif type(from) ~= 'table' and type(from) ~= 'userdata' then
				if lPath ~= path then
					from = nil
					break
				end
			end
		end
		if not from and fallback ~= nil then
			return fallback
		else
			return from
		end
	end,
	L = function(lbl, txts, autoSize) -- New FillLbl
		local result = ''
		local isTable = type(txts)=='table'
		if not isTable then
			return _.L(lbl,{{txts}},autoSize)
		end
		if isTable and type(txts[2]) == 'userdata' then
			return _.L(lbl,{txts},autoSize)
		end
		if lbl then
			if type(lbl) ~= 'userdata' then
				local obj = lbl
				lbl = obj.pnl:text(obj)
			end
			if alive(lbl) then
				local pos = 0
				local posEnd = 0
				local ranges = {}
				for _k,txtObj in ipairs(txts or {}) do
					if txtObj then
						if type(txtObj)=='table' then
							txtObj[1] = tostring(txtObj[1])
						else
							txtObj = {txtObj}
						end
						result = result..txtObj[1]
						local __, count = txtObj[1]:gsub('[^\128-\193]', '')
						if count > 0 then
							posEnd = pos + count
							table.insert(ranges,{pos,posEnd,txtObj[2] or false})
							pos = posEnd
						end
					end
				end
				lbl:set_text(result)
				for __,range in ipairs(ranges) do
					if range[3] then
						lbl:set_range_color( range[1], range[2], range[3])
					end
				end
				if autoSize then
					local x,y,w,h = lbl:text_rect()
					lbl:set_size(w,h)
				end
			end
		else -- simple merge
			for __, t in pairs(txts) do
				result = result .. tostring(t[1])
			end
		end
		return result, lbl
	end,
	M = function(orig,new,copy)
		if copy then
			orig = table.deepcopy(orig)
		end
		local merge_task = {}
		 merge_task[orig] = new

		 local left = orig
		 while left ~= nil do
				local right = merge_task[left]
				for new_key, new_val in pairs(right) do
					 local old_val = left[new_key]
					 if old_val == nil then
							left[new_key] = new_val
					 else
							local old_type = type(old_val)
							local new_type = type(new_val)
							if (old_type == "table" and new_type == "table") then
								 merge_task[old_val] = new_val
							else
								 left[new_key] = new_val
							end
					 end
				end
				merge_task[left] = nil
				left = next(merge_task)
		 end
		 return orig
	end,
	T = function(utc, compare)
		-- HORRIBLY inaccurate due to game's lua engine
		local t = os.time( os.date((utc and '!' or '') ..'*t') )
		if not compare then
			return t
		else
			return compare - t
		end
	end,
	W = function(...)io.stdout:write(_.S(...)..'\n')end,
	P = function (t, f) -- pairs but sorted
		local a = {}
		for n in pairs(t or {}) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0
		return function ()
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
	end,
	I = Poco.inspect,
	J = Poco.JSON,
}
UNDERSCORE = _
setmetatable(_,{__call = function(__,...) return UNDERSCORE.W(...) end})
for k,v in pairs(table.deepcopy(_)) do
	_[k:lower()] = v
end
-- Utils --
table.sorted_keys = function(map)
	local r = {}
	for key,val in pairs(map) do
		r[#r+1] = key
	end
	return r
end
-- PocoBase
-----------
TPocoBase = class()
TPocoBase.className = 'Base'
TPocoBase.classVersion = 0

function TPocoBase:init()
	self.inherited = self
	local data = Poco.save[self.className]
	if data then
		self:import(data)
	end
	if self.onInit and self:onInit() then
		Poco:register(self.className..'_update',callback(self,self,'Update'))
		self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func( callback( self, self, "onResolutionChanged" ) )
	else
		self:destroy()
	end
end
function TPocoBase:onResolutionChanged()
end
function TPocoBase:import(data)
end
function TPocoBase:export()
end
function TPocoBase:name(inner)
	return (inner and '' or 'Poco')..self.className..self.classVersion
end
function TPocoBase:Update(t,dt)
end
function TPocoBase:err(msg,deeper)
	local di = debug.getinfo(3+(deeper or 0))
	managers.menu_component:post_event( "zoom_in")
	self._lastError = _.s(msg,di and (di.short_src..':'..di.currentline) or '@?')
end
function TPocoBase:lastError()
	return self._lastError or ''
end

function TPocoBase:destroy(...)
	managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)
	if self.onDestroy then self:onDestroy(...) end
	self.dead = true
	Poco:unregister(self.className..'_update',callback(self,self,'Update'))
end

-- Poco --
function Poco:init()
	self.addOns = {}
	self.birthdays = {}
	self.funcs = {}
	self.save = {}
	self.binds = {}
	self._kbd = Input:keyboard()
	if not setup._update then
		setup._update = setup.update
	end
	setup.update = function(setup_self,t,dt)
		setup_self:_update(t,dt)
		if not self.dead then
			self:Update(t,dt)
		end
	end
	_('Poco:Init')
end
function Poco:sanitizeKey(key)
	local keyT = type(key)
	if keyT == 'number' then
		if key == 0 then
			key = 11
		elseif key < 10 then -- Number key
			--key = key + 1
		end
	elseif keyT == 'string' then
		key = string.lower(key)
		key = self._kbd:has_button( Idstring( key ) ) and self._kbd:button_index( Idstring( key ) )
		keyT = type(key)
	end
	if keyT ~= 'number' then
		return _('Poco:Bind err;invalid key:',key)
	else
		return key
	end
end
function Poco:addBind(event,name,key,cbk)
	-- event > {name,key,cbk}
	key = self:sanitizeKey(key)
	if key then
		self.binds[event] = self.binds[event] or {}
		local events = self.binds[event]
		table.insert(events,{name,key,cbk})
	end
end

function Poco:ignoreBind(t)
	self._ignoreT = TimerManager:game():time() + (t or 0.2)
end

function Poco:_runBinds(t,dt)
	if not (
		(managers.menu_component._blackmarket_gui and managers.menu_component._blackmarket_gui._renaming_item) or
		(managers.menu_component._skilltree_gui and managers.menu_component._skilltree_gui._renaming_skill_switch) or
		(managers.hud and managers.hud._chat_focus) or
		(managers.menu_component._game_chat_gui and managers.menu_component._game_chat_gui:input_focus()) or
		(self._ignoreT and self._ignoreT > TimerManager:game():time())
		) then
		for event,events in pairs(self.binds) do
			for __,obj in pairs(events) do
				local name, key, cbk = unpack(obj)
				local eventPass = false
				if event == 'down' then
					eventPass = self._kbd:pressed(key)
				elseif event == 'up' then
					eventPass = self._kbd:released(key)
				end
				if eventPass then
					cbk(t,dt,key)
				end
			end
		end
	end
end

function Poco:removeBind(event,name,key)
	if event and self.binds[event] then
		if name then
			local events = self.binds[event]
			for ind,obj in pairs(events) do
				if obj[1] == name then
					if not key or obj[2] == key then
						events[ind] = nil
					end
				end
			end
		else
			self.binds[event] = {}
		end
	end
end

function Poco:Bind(sender,key,downCbk,upCbk)
	local name = sender:name(1)
	if downCbk then
		self:addBind('down',name,key,downCbk)
	end
	if upCbk then
		self:addBind('up',name,key,upCbk)
	end
end

function Poco:LoadOptions(key,obj)
	local extOpt = io.open('poco\\'..key..'_config.lua','r')
	local merge
	merge = function (t1, t2)
		for k, v in pairs(t2) do
			if (type(v) == "table") and (type(t1[k] or false) == "table") then
				merge(t1[k], t2[k])
			else
				t1[k] = v
			end
		end
		return t1
	end
	if extOpt then
		extOpt = loadstring(extOpt:read('*all'))()
		obj = merge(obj,extOpt or {})
	else
		_('No config file found. (poco\\'..key..'_config.lua)')
	end
end

function Poco:UnBind(sender)
	local name = sender:name(1)
	for event in pairs(self.binds) do
		self:removeBind(event,name)
	end
end

function Poco:Kill(name)
	local addOn = self.addOns[name]
	self:UnBind(addOn)
	addOn:export()
	addOn:destroy()
	self.addOns[name] = nil
	return
end

function Poco:AddOn(ancestor)
	local name = ancestor.className
	local addOn = self.addOns[name]
	if addOn then
		return self:Kill(name)
	else
		local addon = ancestor:new()
		self.addOns[name] = addon
		return addon
	end
end
function Poco:Update(t,dt)
--	if not managers.menu_component:input_focus() then
	for __,func in pairs(self.funcs) do
		if self.birthdays[__] and (now() - self.birthdays[__] > 1) then
			func(t,dt)
		end
	end
	self:_runBinds(t,dt)
end
function Poco:register(key,func)
	if not self.funcs[key] then
		self.funcs[key] = func
		self.birthdays[key] = now()
	end
end
function Poco:unregister(key)
	self.funcs[key] = nil
end
function Poco:destroy()
	for k,v in pairs(self.addOns) do
		v:destroy()
	end
	self.dead = true
	setup.update = setup._update
	setup._update = nil
	_('Poco:destroy')
end

Poco:init()
Poco._req ('poco/Hud3.lua')
PocoCommon = true