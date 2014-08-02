-- Poco Common Library V2.1 --
if not deep_clone then return end
function _req(name)
  local f=io.open(name,"r")
  if f~=nil then
		io.close(f)
		require(name)
	end
end
_req ('poco/3rdPartyLibrary.lua')
_req ('poco/3rdPartyLibrary.luac')
local inGame = CopDamage ~= nil
function _pairs(t, f) -- pairs but sorted
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
end
local clr = function(bgr)
	return Color(bgr%0x100 /255,math.floor(bgr/0x100) % 0x100 /255,math.floor(bgr/0x10000) /255)
end
cl = {
	AliceBlue=clr(0xFFF8F0),
	AntiqueWhite=clr(0xD7EBFA),
	Aqua=clr(0xFFFF00),
	Aquamarine=clr(0xD4FF7F),
	Azure=clr(0xFFFFF0),
	Beige=clr(0xDCF5F5),
	Bisque=clr(0xC4E4FF),
	Black=clr(0x000000),
	BlanchedAlmond=clr(0xCDEBFF),
	Blue=clr(0xFF0000),
	BlueViolet=clr(0xE22B8A),
	Brown=clr(0x2A2AA5),
	Burlywood=clr(0x87B8DE),
	CadetBlue=clr(0xA09E5F),
	Chartreuse=clr(0x00FF7F),
	Chocolate=clr(0x1E69D2),
	Coral=clr(0x507FFF),
	CornFlowerBlue=clr(0xED9564),
	CornSilk=clr(0xDCF8FF),
	Cream=clr(0xF0FBFF),
	Crimson=clr(0x3C14DC),
	Cyan=clr(0xFFFF00),
	DarkBlue=clr(0x8B0000),
	DarkCyan=clr(0x8B8B00),
	DarkGoldenRod=clr(0x0B86B8),
	DarkGray=clr(0xA9A9A9),
	Darkgreen=clr(0x006400),
	DarkKhaki=clr(0x6BB7BD),
	DarkMagenta=clr(0x8B008B),
	DarkOliveGreen=clr(0x2F6B55),
	DarkOrange=clr(0x008CFF),
	DarkOrchid=clr(0xCC3299),
	DarkRed=clr(0x00008B),
	DarkSalmon=clr(0x7A96E9),
	DarkSeaGreen=clr(0x8FBC8F),
	DarkSlateBlue=clr(0x8B3D48),
	DarkSlategray=clr(0x4F4F2F),
	DarkTurquoise=clr(0xD1CE00),
	DarkViolet=clr(0xD30094),
	DeepPink=clr(0x9314FF),
	DeepskyBlue=clr(0xFFBF00),
	DimGray=clr(0x696969),
	DkGray=clr(0x808080),
	DodgerBlue=clr(0xFF901E),
	Firebrick=clr(0x2222B2),
	FloralWhite=clr(0xF0FAFF),
	ForestGreen=clr(0x228B22),
	Fuchsia=clr(0xFF00FF),
	Gainsboro=clr(0xDCDCDC),
	GhostWhite=clr(0xFFF8F8),
	Gold=clr(0x00D7FF),
	GoldenRod=clr(0x20A5DA),
	Gray=clr(0x808080),
	Green=clr(0x008000),
	GreenYellow=clr(0x2FFFAD),
	Honeydew=clr(0xF0FFF0),
	HotPink=clr(0xB469FF),
	IndianRed=clr(0x5C5CCD),
	Indigo=clr(0x82004B),
	Ivory=clr(0xF0FFFF),
	Khaki=clr(0x8CE6F0),
	Lavender=clr(0xFAE6E6),
	LavenderBlush=clr(0xF5F0FF),
	LawnGreen=clr(0x00FC7C),
	LemonChiffon=clr(0xCDFAFF),
	LightBlue=clr(0xE6D8AD),
	LightCoral=clr(0x8080F0),
	LightCyan=clr(0xFFFFE0),
	LightGoldenrodYellow=clr(0xD2FAFA),
	LightGreen=clr(0x90EE90),
	Lightgrey=clr(0xD3D3D3),
	LightPink=clr(0xC1B6FF),
	LightSalmon=clr(0x7AA0FF),
	LightSeaGreen=clr(0xAAB220),
	LightSkyBlue=clr(0xFACE87),
	LightSlateGray=clr(0x998877),
	LightSteelBlue=clr(0xDEC4B0),
	LightYellow=clr(0xE0FFFF),
	Lime=clr(0x00FF00),
	LimeGreen=clr(0x32CD32),
	Linen=clr(0xE6F0FA),
	LtGray=clr(0xC0C0C0),
	Magenta=clr(0xFF00FF),
	Maroon=clr(0x000080),
	MedGray=clr(0xA4A0A0),
	MediumAquamarine=clr(0xAACD66),
	MediumBlue=clr(0xCD0000),
	MediumOrchid=clr(0xD355BA),
	MediumPurple=clr(0xDB7093),
	MediumSeaGreen=clr(0x71B33C),
	MediumSlateBlue=clr(0xEE687B),
	MediumSpringGreen=clr(0x9AFA00),
	MediumTurquoise=clr(0xCCD148),
	MediumVioletRed=clr(0x8515C7),
	MidnightBlue=clr(0x701919),
	Mintcream=clr(0xFAFFF5),
	MistyRose=clr(0xE1E4FF),
	Moccasin=clr(0xB5E4FF),
	MoneyGreen=clr(0xC0DCC0),
	NavajoWhite=clr(0xADDEFF),
	Navy=clr(0x800000),
	OldLace=clr(0xE6F5FD),
	Olive=clr(0x008080),
	OliveDrab=clr(0x238E6B),
	Orange=clr(0x00A5FF),
	OrangeRed=clr(0x0045FF),
	Orchid=clr(0xD670DA),
	PaleGoldenrod=clr(0xAAE8EE),
	PaleGreen=clr(0x98FB98),
	PaleTurquoise=clr(0xEEEEAF),
	PaleVioletRed=clr(0x9370DB),
	PapayaWhip=clr(0xD5EFFF),
	PeachPuff=clr(0xB9DAFF),
	Peru=clr(0x3F85CD),
	Pink=clr(0xCBC0FF),
	Plum=clr(0xDDA0DD),
	PowderBlue=clr(0xE6E0B0),
	Purple=clr(0x800080),
	Red=clr(0x0000FF),
	RosyBrown=clr(0x8F8FBC),
	RoyalBlue=clr(0xE16941),
	SaddleBrown=clr(0x13458B),
	Salmon=clr(0x7280FA),
	SandyBrown=clr(0x60A4F4),
	SeaGreen=clr(0x578B2E),
	Seashell=clr(0xEEF5FF),
	Sienna=clr(0x2D52A0),
	Silver=clr(0xC0C0C0),
	SkyBlue=clr(0xEBCE87),
	SkyBlue=clr(0xF0CAA6),
	SlateBlue=clr(0xCD5A6A),
	SlateGray=clr(0x908070),
	Snow=clr(0xFAFAFF),
	SpringGreen=clr(0x7FFF00),
	SteelBlue=clr(0xB48246),
	Tan=clr(0x8CB4D2),
	Teal=clr(0x808000),
	Thistle=clr(0xD8BFD8),
	Tomato=clr(0x4763FF),
	Turquoise=clr(0xD0E040),
	Violet=clr(0xEE82EE),
	Wheat=clr(0xB3DEF5),
	White=clr(0xFFFFFF),
	WhiteSmoke=clr(0xF5F5F5),
	Yellow=clr(0x00FFFF),
	YellowGreen=clr(0x32CD9A),
}

_ = {
	F = function (n,k) -- ff
		k = k or 2
		if type(n) == 'number' then
			local r = string.format('%.'..k..'g', n):sub(1,k+2)
			return r:find('e') and tostring(math.floor(n)) or r
		elseif type(n) == 'table' then
			return zinspect(n):gsub('\n','')
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
			return '_.s Err: '..zinspect(b):gsub('\n','')
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
					if type(txtObj)=='table' then
						txtObj[1] = tostring(txtObj[1])
					else
						_('_.L Err:txtObj is not a table',txtObj)
					end
					result = result..txtObj[1]
					local __, count = txtObj[1]:gsub('[^\128-\193]', '')
					if count > 0 then
						posEnd = pos + count
						table.insert(ranges,{pos,posEnd,txtObj[2] or cl.White})
						pos = posEnd
					end
				end
				lbl:set_text(result)
				for _,range in ipairs(ranges) do
					lbl:set_range_color( range[1], range[2], range[3] or cl.Green)
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
	W = function(...)io.stderr:write(_.S(...)..'\n')end
}
setmetatable(_,{__call = function(__,...) return _.W(...) end})
UNDERSCORE = _
if clone then
	for k,v in pairs(clone(_)) do
		_[k:lower()] = v
	end
end
_assert = _assert or assert
assert = function()	end
function string:usub(start,num)
	local r = ''
	for i,t in ipairs(utf8.characters(self) or {}) do
		if (num and (i>=start and i<num+start)) or not num and (i<=start) then
			r = r .. t
		end
	end
	return r
end
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
	self._lastError = _.s(msg,di and di.short_src..':'..di.currentline or '@?')
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
----------
TPoco = class()
function TPoco:init()
	self.addOns = {}
	self.funcs = {}
	self.save = {}
	self.binds = {down={},up={}}
	if inGame then
		self.pnl = managers.hud._workspace:panel():panel({ name = "poco_sheet" , layer = 50000})
	end
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
function TPoco:Bind(sender,key,downCbk,upCbk)
	local name = sender:name(1)
	if type(key) == 'number' then
		if key == 0 then
			key = 11
		elseif key < 10 then -- Number key
			key = key + 1
		end
	elseif type(key) == 'string' then
		key = string.lower(key)
		key = Input:keyboard():has_button( Idstring( key ) ) and Input:keyboard():button_index( Idstring( key ) )
	end
	if type(key) ~= 'number' then
		return _('Poco:Bind err;invalid key:',key)
	end
	self.binds.down[key] = downCbk and {name,downCbk} or nil
	self.binds.up[key] = upCbk and {name,upCbk} or nil
end
function TPoco:LoadOptions(key,obj)
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
function TPoco:UnBind(sender)
	local name = sender:name(1)
	for key,cbk in pairs(clone(self.binds.down)) do
		if cbk[1]==name then
			self.binds.down[key] = nil
		end
	end
	for key,cbk in pairs(clone(self.binds.up)) do
		if cbk[1]==name then
			self.binds.up[key] = nil
		end
	end
end
function TPoco:AddOn(ancestor)
	local name = ancestor.className
	local addOn = self.addOns[name]
	if addOn then
		self:UnBind(addOn)
		addOn:export()
		addOn:destroy()
		self.addOns[name] = nil
		return
	else
		local addon = ancestor:new()
		self.addOns[name] = addon
		return addon
	end
end
function TPoco:Update(t,dt)
--	if not managers.menu_component:input_focus() then
	if not (managers.menu_component._game_chat_gui and managers.menu_component._game_chat_gui:input_focus()) then
		for key,cbks in pairs(self.binds.down) do
			if cbks and self._kbd:pressed(key) then
				cbks[2](t,dt)
			end
		end
		for key,cbks in pairs(self.binds.up) do
			if cbks and self._kbd:released(key) then
				cbks[2](t,dt)
			end
		end
	end

	for __,func in pairs(self.funcs) do
		func(t,dt)
	end
end
function TPoco:register(key,func)
	if not self.funcs[key] then
		self.funcs[key] = func
	end
end
function TPoco:unregister(key)
	self.funcs[key] = nil
end
function TPoco:destroy()
	for k,v in pairs(self.addOns) do
		v:destroy()
	end
	self.dead = true
	managers.hud._workspace:panel():remove(self.pnl)
	setup.update = setup._update
	setup._update = nil
	_('Poco:destroy')
end



if Poco and not Poco.dead then
	Poco:destroy()
else
	Poco = TPoco:new()
end

