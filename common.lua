require ('poco/3rdPartyLibrary.lua')
-- Poco Common Library V2 --
if not deep_clone then return end
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
_ = {
	F = function (n,k) -- ff
		if type(n) == 'number' then
			return n >= 99.5 and tostring(math.floor(n)) or string.format('%.'..(k or 2)..'g', n)
		elseif type(n) == 'table' then
			return zinspect(n):gsub('\n','')
		else
			return tostring(n)
		end
	end,
	S = function (...) -- toStr
		local a,b = clone({...}) , {}
		for k,v in pairs(a) do
			b[k] = _.F(v)
		end
		return table.concat(b,' ')
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
	end
}
setmetatable(_,{__call = function(__,...)io.stderr:write(_.S(...)..'\n')end})
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
function TPocoBase:err(msg)
	local di = debug.getinfo(2)
	managers.menu_component:post_event( "zoom_in")
	self._lastError = _.s(msg,di and di.short_src..':'..di.currentline or '@?')
end
function TPocoBase:lastError()
	return self._lastError or ''
end

function TPocoBase:destroy()
	managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)
	if self.onDestroy then self:onDestroy() end
	self.dead = true
	self:export()
	Poco:unRegister(self.className..'_update',callback(self,self,'Update'))
end
----------
TPoco = class()
function TPoco:init()
	self.addOns = {}
	self.funcs = {}
	self.save = {}
	self.binds = {down={},up={}}
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
	if self.addOns[name] then
		self:UnBind(self.addOns[name])
		self.addOns[name]:destroy()
		self.addOns[name] = nil
		return
	else
		local addon = ancestor:new()
		if addon.import then
			addon:import()
		end
		self.addOns[name] = addon
		return addon
	end
end
function TPoco:Update(t,dt)
	if not managers.menu_component:input_focus() then
		for key,cbks in pairs(self.binds.down) do
			if cbks and self._kbd:pressed(key) then
				cbks[2](t,dt)
			end
		end
		for key,cbks in pairs(self.binds.up) do
			if cbks and self._kbd:released(key) then
				cbk[2](t,dt)
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
function TPoco:unRegister(key,func)
	if self.funcs[key] then
		self.funcs[key] = nil
	end
end
function TPoco:destroy()
	for k,v in pairs(self.addOns) do
		v:destroy()
	end
	self.dead = true
	setup.update = setup._update
	setup._update = nil
	_('Poco:destroy')
end



if Poco and not Poco.dead then
	Poco:destroy()
else
	Poco = TPoco:new()
end

