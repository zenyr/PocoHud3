if not TPocoBase then return end
local inGame = CopDamage ~= nil
--- Options ---
local O = {

}
--- Class Start ---
TPocoHud3 = class(TPocoBase)
TPocoHud3.className = 'Hud'
TPocoHud3.classVersion = 3
--- Inherited ---
function TPocoHud3:OnInit()
	Poco:LoadOptions(self:name(1),O)
	self._ws = inGame and managers.gui_data:create_fullscreen_workspace() or managers.gui_data:create_fullscreen_16_9_workspace()
	self.pnl = {
		dmg = self._ws:panel():panel({ name = "dmg_sheet" , layer = 50000})
	}
	self.stats = {}
	self.dbgLbl = self.pnl.dmg:text{text='HUD '..(inGame and 'Ingame' or 'Outgame'), font=tweak_data.hud_present.title_font, font_size = 20, color = Color.purple, x=0,y=0, layer=0}
	Poco:Bind(16,callback(self,self,'err'),callback(self,self,'err'))
end
function TPocoHud3:onResolutionChanged()
	if alive(self._ws) then
		if inGame then
			managers.gui_data:layout_fullscreen_workspace( self._ws )
		else
			managers.gui_data:layout_fullscreen_16_9_workspace( self._ws )
		end
	else
		self:err('No WS to reschange')
	end
end
function TPocoHud3:import(data)
	for k,v in pairs(data or {}) do
		self[k] = v
	end
end
function TPocoHud3:export()
	Poco.save[self.className] = {
		stats = self.stats
	}
end
function TPocoHud3:Update(t,dt)
	pcall(self._update,self,t,dt)
end
function TPocoHud3:onDestroy()
		managers.gui_data:destroy_workspace(self._ws)
end
--- Internal functions ---
function TPocoHud3:_update(t,dt)
	-- Populate DbgLbl
	self._keyList = _.s(#(Poco._kbd:down_list() or {})>0 and Poco._kbd:down_list() or '')
	self._dbgTxt = _.s(self._keyList,self:lastError())
	if t-(self._lastSlowUpdate or 0) > 0.5 or self._dbgTxt ~= self.__dbgTxt  then
		self.__dbgTxt = self._dbgTxt
		self:_slowUpdate(t,dt)
		self._lastSlowUpdate = t
	end
	-- DbgLbl end
	if inGame then

	else

	end
end
function TPocoHud3:_slowUpdate(t,dt)
	self.dbgLbl:set_text( _.s( math.floor(1/dt), os.date('%X'),self._dbgTxt))
end
function TPocoHud3:Stat(pid,key,data,add)
	if pid then
		local stat = self.stats[pid] or {}
		if not self.stats[pid] then
			self.stats[pid] = stat
		end
		if not stat[key] then
			stat[key] = 0
		end
		if data ~= nil then
			if add then
				stat[key] = stat[key] + data
			else
				stat[key] = data
			end
		end
		return stat[key]
	end
end

--- Utility functions ---
function TPocoHud3:_vectorToScreen(v3pos)
	if not self._ws then return end
	local cam = managers.viewport:get_current_camera()
	return (cam and v3pos) and self._ws:world_to_screen( cam, v3pos )
end
function TPocoHud3:_lbl(lbl,txts)
	local result = ''
	if type(txts)=='table' then
		local pos = 0
		local posEnd = 0
		local ranges = {}
		for _,txtObj in ipairs(txts or {}) do
			result = result..tostring(txtObj[1])
			local __, count = string.gsub(txtObj[1], "[^\128-\193]", "")
			posEnd = pos + count
			table.insert(ranges,{pos,posEnd,txtObj[2] or Color.blue})
			pos = posEnd
		end
		lbl:set_text(result)
		for _,range in ipairs(ranges) do
			lbl:set_range_color( range[1], range[2], range[3] or Color.green)
		end
	elseif type(txts)=='string' then
		result = txts
		lbl:set_text(txts)
	end
	return result
end
--- Class end ---
if Poco and not Poco.dead then
	local me = Poco:AddOn(TPocoHud3)
	if me and not me.dead then
		PocoHud3 = me
	else
		managers.menu_component:post_event( "zoom_out")
	end
else
	managers.menu_component:post_event( "zoom_out")
end