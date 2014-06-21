if not TPocoBase then return end
local _ = UNDERSCORE
local VR = 0.01
local inGame = CopDamage ~= nil
local me
--- Options ---
local YES,NO,yes,no = true,false,true,false
local O = {
	enable = YES,
	buff = {
		show = YES,
		left = 10,
		top  = 22,
		maxFPS = 30,
		size = 70, -- ignored by vanilla style
		gap = 10,
		align = 1, -- 1:left 2:center 3:right
		style = 2, -- 1:PocoHud style 2:Vanilla style
	},
	popup = {
		show = YES,
		size = 20,
		damageDecay = 10,
		myDamage = YES,
		crewDamage = YES,
		AIDamage = YES,
		handsUp = YES,
		dominated = YES,
	},
	float = {
		show = YES,
		size = 15,
		margin = 3,
		maxOpacity = 0.9,
		unit = YES,
		drills = YES,
	},
	clock = {

	},
	minion = {
		show = YES
	},
	chat = {
		readThreshold = 2,
		serverSendThreshold = 3,
		clientSendThreshold = 5,
		midgameAnnounce = 50,
		index = {
			midStat = 3,
			endStat = 4,
			dominated = 4,
			converted = 4,
			minionLost = 4,
			minionShot = 4,
			hostageChanged = 1,
			outofAmmo = 4,
			custody = 5,
			downedWarning = 5,
			replenished = 5,
		}
	},
}
local FONT =  tweak_data.hud_present.title_font or tweak_data.hud_players.name_font or "fonts/font_eroded" or 'core/fonts/system_font'
local clGood =  Color( 255, 146, 208, 80 ) / 255
local clBad =  Color( 255, 255, 192, 0 ) / 255
local iconSkull,iconShadow,iconRight,iconDot,iconChapter,iconDiv,iconBigDot = '', '', '','Ї','ϸ','϶','ϴ'
local iconTimes,iconDivided,iconLC,iconRC,iconDeg,iconPM,iconNo = '×','÷','','','Ѐ','Ё','Љ'
local _BROADCASTHDR, _BROADCASTHDR_HIDDEN = iconDiv,iconShadow
local skillIcon = 'guis/textures/pd2/skilltree/icons_atlas'
local now = function () return managers.player:player_timer():time() --[[TimerManager:game():time()]] end
--- miniClass start ---
local TBuff = class()
function TBuff:init(owner,data)
	self.owner = owner
	self.ppnl = owner.pnl.buff
	self:set(data)
end
function TBuff:set(data)
	self.dead = false
	local st = self.data and self.data.st
	self.data = data
	if st and data.et ~= 1 then
		self.data.st = st
	end
end
function TBuff:_make()
	local style = O.buff.style
	local size = style==2 and 40 or O.buff.size
	local data = self.data
	if style == 2 then
		self.created = true
		local pnl = self.ppnl:panel({x = 0,y=0, w=100,h=100})
		self.pnl = pnl
		self.lbl = pnl:text{text='', font=FONT, font_size = size/2, color = data.color or data.good and clGood or clBad, x=1,y=1, layer=2, blend_mode = 'normal'}
		self.bg = HUDBGBox_create( pnl, { w = size, h = size, x = 0, y = 0 }, { color = cl.White, blend_mode = 'normal' } )
		self.bmp = data.icon and pnl:bitmap( { name='icon', texture=data.icon, texture_rect=data.iconRect, blend_mode = 'add', layer=1, x=0,y=0, color=style==2 and cl.White or data.good and clGood or clBad } ) or nil
		local texture = data.good and "guis/textures/pd2/hud_progress_active" or "guis/textures/pd2/hud_progress_invalid"
		self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = texture, radius = size/2, sides = 64, current = 20, total = 64, blend_mode = "add", layer = 0} )
		self.pie:set_position( -size, 0)
		if self.bmp then
			local mul = style==2 and 1 or 0.7
			if self.bmp:width() > mul*size then
				self.bmp:set_size(mul*size,mul*size)
			end
			self.bmp:set_center(5+size + size/2,size/2)
		end
		pnl:set_shape(0,0,size*2+5,size*1.25)
		pnl:set_position(-100,-100)
	else
		self.created = true
		local pnl = self.ppnl:panel({x = 0,y=0, w=100,h=100})
		self.pnl = pnl
		self.lbl = pnl:text{text='', font=FONT, font_size = size/4, color = data.color or data.good and clGood or clBad, x=1,y=1, layer=2, blend_mode = 'normal'}
		self.bg = pnl:bitmap( { name='bg', texture= 'guis/textures/pd2/hud_tabs',texture_rect=  { 105, 34, 19, 19 }, color= cl.Black:with_alpha(0.2), layer=0, x=0,y=0 } )
		self.bmp = data.icon and pnl:bitmap( { name='icon', texture=data.icon, texture_rect=data.iconRect, blend_mode = 'add', layer=1, x=0,y=0, color=data.good and clGood or clBad } ) or nil
		local texture = data.good and "guis/textures/pd2/hud_progress_active" or "guis/textures/pd2/hud_progress_invalid"
		self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = texture, radius = size/2, sides = 64, current = 20, total = 64, blend_mode = "add", layer = 0} )
		self.pie:set_position( 0, 0)
		if self.bmp then
			if self.bmp:width() > 0.7*size then
				self.bmp:set_size(0.7*size,0.7*size)
			end
			self.bmp:set_center(size/2,size/2)
		end
		pnl:set_shape(0,0,size,size*1.25)
		self.bg:set_size(size,size)
		pnl:set_position(-100,-100)
	end
end
function TBuff:draw(t,x,y)
	if not self.dead then
		if not self.created then
			self:_make()
		end
		local data = self.data
		local st,et = data.st,data.et
		local prog = (now()-st)/(et-st)
		local style = O.buff.style
		local vanilla = style == 2
		if prog >= 1 and et ~= 1 then
			self.dead = true
		elseif alive(self.pnl) then
			if et == 1 then
				prog = st
			end
			x = self.x and self.x + (x-self.x)/5 or x
			y = self.y and self.y + (y-self.y)/5 or y
			self.pnl:set_center(x,y)
			self.x = x
			self.y = y
			local txts
			if vanilla then
					txts = {{_.f(et ~= 1 and et-now() or prog*100,1)..(et == 1 and '%' or 's'),cl.White}}
			else
				if type(data.text)=='table' then
					txts = data.text
				else
					txts = {{data.text or '',data.color}}
					table.insert(txts,{_.f(et ~= 1 and et-now() or prog*100)..(et == 1 and '%' or 's'),data.good and clGood or clBad})
				end
			end
			self.owner:_lbl(self.lbl,txts)
			local _x,_y,w,h = self.lbl:text_rect()
			self.lbl:set_size(w,h)
			if vanilla then
				local ww, hh = self.bg:size()
				self.lbl:set_center(ww/2,hh/2)
			else
				local ww, hh = self.pnl:size()
				self.lbl:set_center(ww/2,hh-h/2)
			end
			self.pie:set_current(1-prog)
			if not self.dying then
				self.pnl:set_alpha(1)
			end
		end
	end
end
function TBuff:_fade(pnl, done_cb, seconds)
	local pnl = self.pnl
	pnl:set_visible( true )
	pnl:set_alpha( 1 )
	local t = seconds
	while t > 0 do
		if not self.dead then
			self.dying = false
			break
		end
		local dt = coroutine.yield()
		t = t - dt
		pnl:set_alpha((self.lastD or 1) * t/seconds )
	end
	if self.dying then
		pnl:set_visible( false )
		if done_cb then done_cb(pnl) end
	end
end
function TBuff:destroy(skipAnim)
	local pnl = self.pnl
	if self.created and alive(self.ppnl) and alive(pnl) then
		if not skipAnim then
			if not self.dying then
				self.dying = true
				pnl:stop()
				pnl:animate( callback( self, self, "_fade" ), callback( self, self, "destroy" , true), 0.25 )
			end
		else
			self.ppnl:remove(self.pnl)
			self.owner.buffs[self.data.key] = nil
		end
	end
end
	-------
local TPop = class()
function TPop:init(owner,data)
	self.owner = owner
	self.data = data
	self.data.st=now()
	self.ppnl = owner.pnl.pop
	self:_make()
end
function TPop:_make()
	local size = O.popup.size
	local pnl = self.ppnl:panel({x = 0, y = 0, w=200, h=100})
		local data = self.data
	self.pnl = pnl
	self.lbl = pnl:text{text='', font=FONT, font_size = size, color = data.color or data.good and clGood or clBad, x=0,y=0, layer=3, blend_mode = 'add'}
	local _txt = self.owner:_lbl(self.lbl,data.text)
	self.lblBg = pnl:text{text=_txt, font=FONT, font_size = size, color = cl.Black, x=1,y=1, layer=2, blend_mode = 'normal'}
	local x,y,w,h = self.lblBg:text_rect()
	pnl:set_shape(-100,-100,w,h)
end
function TPop:draw(t)
	local isADS = self.owner.ADS
	local camPos = self.owner.camPos
	if not self.dead and alive(self.pnl) then
		local data = self.data
		local st,et = data.st,data.et
		local prog = (now()-st)/(et-st)
		local pos = data.pos + Vector3()
		local nl_dir = pos - camPos
		mvector3.normalize( nl_dir )
		local dot = mvector3.dot( self.owner.nl_cam_forward, nl_dir )
		self.pnl:set_visible( dot > 0 )
		if dot > 0 then
			local pPos = self.owner:_v2p(pos)
			if not data.stay then
				mvector3.set_y(pPos,pPos.y - math.lerp(100,0, math.pow((1-prog),7)))
			end

			if prog >= 1 then
				self.dead = true
			else
				local dx,dy,d,ww,hh = 0,0,1,self.owner._ws:size()
				self.pnl:set_center( pPos.x,pPos.y)
				if isADS then
					dx = pPos.x - ww/2
					dy = pPos.y - hh/2
					d = math.clamp((dx*dx+dy*dy)/1000,0,1)
				else
					d = 1-math.pow(prog,5)
				end
				d = math.min(d,self.owner:_visibility(false))
				self.pnl:set_alpha(math.min(1-prog,d))
			end
		end
	end
end
function TPop:destroy(key)
	self.ppnl:remove(self.pnl)
	if key then
		self.owner.pops[key] = nil
	end
end

local TFloat = class()
function TFloat:init(owner,data)
	self.owner = owner
	self.category = data.category
	self.unit = data.unit
	self.key = data.key
	self.tag = data.tag
	self.temp = data.temp
	self.lastT = type(self.temp) == 'number' and self.temp or now()
	self.ppnl = owner.pnl.pop
	self:_make()
end
function TFloat:_make()
	local size = O.float.size
	local m = O.float.margin
	local pnl = self.ppnl:panel({x = 0,y=-size, w=300,h=100})
	local texture = 'guis/textures/pd2/hud_health' or 'guis/textures/pd2/hud_progress_32px'
	self.pnl = pnl
	self.bg = HUDBGBox_create(pnl, {x= 0,y= 0,w= 1,h= 1},{color=cl.White:with_alpha(0.3)})
	self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=m,y=m,image = texture, radius = size/2, sides = 64, current = 20, total = 64, blend_mode = 'normal', layer = 3} )
	self.lbl = pnl:text{text='Float', font=FONT, font_size = size, color = cl.White, x=size+m*2,y=m, layer=3, blend_mode = 'normal'}
end
local _drillNames = {
	lance = 'Thermal Drill', uload_database = 'Upload',
	votingmachine2 = 'Voting Machine', hack_suburbia = 'Hacking',
	digitalgui = 'Timelock', drill = 'Drill'
}
function TFloat:draw(t)
	if not alive(self.unit) or (self.temp and (t-self.lastT>0.5)) and not self.dead then
		self.dead = true
	end
	if self.dead and not self.dying then
		self:destroy()
	end
	if not alive(self.pnl) then
		return
	end
	local size = O.float.size
	local m = O.float.margin
	local isADS = self.owner.ADS
	local camPos = self.owner.camPos

	local category = self.category
	local prog,txts = 0,{}
	local unit = self.unit
	if not alive(unit) then return end
	local pos = self.owner:_pos(unit,true)
	local pPos = self.owner:_v2p(pos)
	local nl_dir = pos - camPos
	mvector3.normalize( nl_dir )
	local dot = mvector3.dot( self.owner.nl_cam_forward, nl_dir )
	local dx,dy,d,pDist,ww,hh= 0,0,1,0,self.owner._ws:size()
	dx = pPos.x - ww/2
	dy = pPos.y - hh/2
	pDist = dx*dx+dy*dy
	self.pnl:set_visible( dot > 0 )
	if dot > 0 then
		if category == 0 then -- Unit
			local cHealth = unit:character_damage() and unit:character_damage()._health and unit:character_damage()._health*10 or 0
			local fHealth = cHealth > 0 and unit:character_damage() and unit:character_damage()._HEALTH_INIT*10 or 1
			prog = cHealth / fHealth
			local cCarry = unit:carry_data()
			local isCiv = unit and managers.enemy:is_civilian( unit )
			local color = isCiv and cl.Lime or math.lerp( cl.Red:with_alpha(0.6), cl.Yellow, prog )
			for i=1,4 do
				if unit == self.owner:Stat(i,'minion') then color = math.lerp( cl.MoneyGreen, cl.Cream, prog ) end
			end
			local distance = unit and mvector3.distance( unit:position(), camPos ) or 0
			if cCarry then
				table.insert(txts,{managers.localization:text(tweak_data.carry[cCarry._carry_id].name_id) or 'Bag',color})
			else
				if pDist > 100000 then
					--table.insert(txts,{''})
				elseif cHealth == 0 then
					table.insert(txts,{iconSkull,color})
				else
					table.insert(txts,{_.f(cHealth)..'/'.._.f(fHealth),color})
				end
			end
			pPos = pPos:with_y(pPos.y-size*2)
		end
		if category == 1 then -- Drill
			local tGUI = unit and unit:timer_gui()
			if not tGUI then
				table.insert(txts,{'Done',cl.Green})
			else
				local name = unit and unit:interaction() and unit:interaction().tweak_data
				name = name and name:gsub('_jammed',''):gsub('_upgrade','') or 'drill'
				name = _drillNames[name] or 'Drill'
				prog = 1-tGUI._current_timer/tGUI._timer
				if pDist < 10000 then
					table.insert(txts,{_.s(name..':',self.owner:_time(tGUI._current_timer),'/',self.owner:_time(tGUI._timer)),tGUI._jammed and cl.Red or cl.White})
				else
					table.insert(txts,{_.s(self.owner:_time(tGUI._current_timer)),tGUI._jammed and cl.Red or cl.White})
				end
			end
		end
		self.pie:set_current(prog)
		self.owner:_lbl(self.lbl,txts)
		local __,__,w,h = self.lbl:text_rect()
		h = math.max(h,size)
		self.pnl:set_size(m*3+w+size,h+2*m)
		self.bg:set_size(self.pnl:size())
		self.pnl:set_center( pPos.x,pPos.y)
		if isADS then
			d = math.clamp((pDist-1000)/2000,0,1)
		else
			d = 1
		end
		if not (unit and unit:contour() and #(unit:contour()._contour_list or {}) > 0) then
			d = math.min(d,self.owner:_visibility(pos))
			self.lastD = d
		end
		if not self.dying then
			self.pnl:set_alpha(d)
		end
	end
end
function TFloat:renew()
	if self.temp then
		self.lastT = math.max(self.lastT,now())
	end
	self.dead = false
end
function TFloat:destroy(skipAnim)
	local pnl = self.pnl
	if alive(self.ppnl) and alive(pnl) then
		if not skipAnim then
			if not self.dying then
				self.dying = true
				pnl:stop()
				pnl:animate( callback( self, TBuff, "_fade" ), callback( self, self, "destroy" , true), 0.2 )
			end
		else
			self.ppnl:remove(self.pnl)
			self.owner.floats[self.key] = nil
		end
	end
end
--- Class Start ---
local TPocoHud3 = class(TPocoBase)
TPocoHud3.className = 'Hud'
TPocoHud3.classVersion = 3
--- Inherited ---
function TPocoHud3:onInit() -- 설정
	Poco:LoadOptions(self:name(1),O)
	if not O.enable then
		return false
	end
	self._ws = inGame and managers.gui_data:create_fullscreen_workspace() or managers.gui_data:create_fullscreen_16_9_workspace()
	--self:_setupWws()
	self.pnl = {
		dbg = self._ws:panel():panel({ name = "dbg_sheet" , layer = 50000}),
		pop = self._ws:panel():panel({ name = "dmg_sheet" , layer = 4}),
		buff = self._ws:panel():panel({ name = "buff_sheet" , layer = 5}),
		stat = self._ws:panel():panel({ name = "stat_sheet" , layer = 9}),
	}
	self.killa = self.killa or 0
	self.stats = self.stats or {}
	self.hooks = {}
	self.pops = {}
	self.buffs = {}
	self.floats = {}
	self.smokes = {}
	self.gadget = self.gadget or {}
--	self.tmp = self.pnl.dbg:bitmap{name='x', blend_mode = 'add', layer=1, x=0,y=40, color=clGood ,texture = "guis/textures/hud_icons"}
	local dbgSize = 20
	self.dbgLbl = self.pnl.dbg:text{text='HUD '..(inGame and 'Ingame' or 'Outgame'), font=FONT, font_size = dbgSize, color = cl.Purple, x=0,y=self.pnl.dbg:height()-dbgSize, layer=0}
	self:_hook()
	Poco:Bind(self,16,callback(self,self,'test'),nil)
	return true
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
	self.stats = data.stats
end
function TPocoHud3:export()
	Poco.save[self.className] = {
		stats = self.stats,
	}
end
function TPocoHud3:Update(t,dt)
	local r,err = pcall(self._update,self,t,dt)
	if not r then _(err) end
end
function TPocoHud3:onDestroy(gameEnd)
	if gameEnd then
		self:AnnounceStat(false)
	end
	if( alive( self._ws ) ) then
		managers.gui_data:destroy_workspace(self._ws)
	end
	if( alive( self._worldws ) ) then
		World:newgui():destroy_workspace( self._worldws )
	end
end
function TPocoHud3:AddDmgPopByUnit(sender,unit,offset,damage,death,head)
	if unit then
		self:AddDmgPop(sender,self:_pos(unit),unit,offset,damage,death,head)
	end
end
local _lastAttk, _lastAttkpid = 0,0
function TPocoHud3:AddDmgPop(sender,hitPos,unit,offset,damage,death,head)
	local Opt = O.popup
	if self.dead or not Opt.show then return end
	local pid = self:_pid(sender)
	if pid == self.pid and not Opt.myDamage then return
	elseif pid == 0 and not Opt.AIDamage then return
	elseif not Opt.crewDamage then return
	end
	local isPercent = damage<0
	local dmgTime = Opt.damageDecay
	local rDamage = damage>=0 and damage or -damage
	if isPercent and unit and unit:character_damage() and unit:character_damage()._HEALTH_INIT then
		rDamage = math.min(unit:character_damage()._HEALTH_INIT * rDamage / 100,unit:character_damage()._health)
	end
	local isSpecial = false
	if unit then
		isSpecial = tweak_data.character[ unit:base()._tweak_table ].priority_shout
		if isSpecial =='f34' then isSpecial = false end
		for pid = 1,4 do
			local minion = self:Stat(pid,'minion')
			if unit == minion then
				local apid = self:_pid(sender)
				if apid and apid > 0 and (apid ~= _lastAttkpid or now()-_lastAttk > 5) then
					_lastAttk = now()
					_lastAttkpid = apid
					self:Chat('minionShot',_.s(self:_name(apid),'attacked',(pid==apid and 'own' or self:_name(pid)..'\'s'),'minion by',_.f(rDamage*10)))
				end
			end
		end
	end
	local color = (self:_color(sender,cl.White)):with_alpha(death and 1 or 0.5)
	local pid = self:_pid(sender)
	local texts = { }
	if rDamage>0 then
		texts[#texts+1] = {_.f(rDamage*10),color}
	end
	if head then
		texts[#texts+1] = {'!',color:with_red(1)}
	end
	if death then
		texts[#texts+1] = {'',isSpecial and cl.Yellow or color}
	end
	local pos = Vector3()
	mvector3.set(pos,hitPos)
	mvector3.set_z(pos,pos.z + offset)
	local r,err = pcall(function()
		self:Popup( {pos=pos, text=texts, stay=false, et=now()+dmgTime })
		if sender then
			if self:Stat(pid,'time') == 0 then
				self:Stat(pid,'time',now())
			end
			self:Stat(pid,'dmg',rDamage*10,true)
			if death then
				self.killa = self.killa +1
				self:Stat(pid,'kill',1,true)
				if isSpecial then
					self:Stat(pid,'killS',1,true)
				end
				if Network:is_server() and (self.killa % O.chat.midgameAnnounce == 0) then
					self:AnnounceStat(true)
				end
			end
		end
	end)
	if not r then _(err) end
end
--- Internal functions ---
function TPocoHud3:AnnounceStat(midgame)
	local txt = {}
	table.insert(txt,iconLC..'PocoHud³ v'.._.f(VR,3)..iconRC..' '..(midgame and 'midgame' or 'endgame')..' total:'..self.killa..iconSkull)
	for pid = 0,4 do
		local kill = self:Stat(pid,'kill')
		local killS = self:Stat(pid,'killS')
		if kill > 0 then
			local dt = now()-self:Stat(pid,'time')
			local dpm = _.f(60*self:Stat(pid,'dmg')/dt or 0)
			local kpm = _.f(60*kill/dt)
			local downs = self:Stat(pid,'down')+self:Stat(pid,'downAll')
			table.insert(txt,
				_.s(iconLC..self:_name(pid)..iconRC,
					kill..iconSkull..(killS>0 and '('..killS..' Sp)' or ''),
					'DPM:'..dpm,
					'KPM:'..kpm,
					(downs>0 and downs..iconShadow or nil)
				)
			)
		end
	end
	self:Chat(midgame and 'midStat' or 'endStat',table.concat(txt,'\n'))
end
local lastSlowT = 0
function TPocoHud3:_slowUpdate(t,dt)
	if inGame then
		local peers = _.g('managers.network:session():peers()',{})
		for pid,peer in pairs( peers ) do
			self:Stat(pid,'ping',math.floor(Network:qos( peer:rpc() ).ping))
		end
		self.pid = _.g('managers.network:session():local_peer():id()')
	end
end
function TPocoHud3:_update(t,dt)
	self:_upd_dbgLbl(t,dt)
	self.cam = alive(self.cam) and self.cam or managers.viewport:get_current_camera()
	if not self.cam then return end
	self.rot = self.cam:rotation()
	self.camPos = self.cam:position()
	self.nl_cam_forward = Rotation()
	mrotation.y( self.rot, self.nl_cam_forward )
	if t - lastSlowT > 5 then -- SlowUpdate
		lastSlowT = t
		self:_slowUpdate(t,dt)
	end

	if inGame then
		self:_updateItems(t,dt)
	else

	end
end
function TPocoHud3:Minion(pid,unit)
	if alive(unit) then
		self:Float(unit,0,false,{minion = self:_name(pid)})
		self:Stat(pid,'minion',unit)
		self:Chat('converted',_.s(self:_name(pid),'converted a police hostage.'))
	else
		self:Stat(pid,'minion',0)
	end
end
function TPocoHud3:Chat(category,text)
	local Opt = O.chat
	if Opt.muted then return _('Muted:',text) end
	local catInd = Opt.index[category] or -1
	local canRead = catInd >= Opt.readThreshold
	local canSend = catInd >= (Network:is_server() and Opt.serverSendThreshold or Opt.clientSendThreshold)
	local tStr = _.g('managers.hud._hud_heist_timer._timer_text:text()')
	if canRead then
		_.c(tStr..(canSend and '' or _BROADCASTHDR_HIDDEN), text )
		if canSend then
			managers.network:session():send_to_peers_ip_verified( "send_chat_message", 1, tStr.._BROADCASTHDR..text )
		end
	else
		_.c('CantRead:',text)
	end
end
function TPocoHud3:Float(unit,category,temp,tag)
	local key = unit:key()
	local float = self.floats[key]
	if float then
		float:renew()
	else
		self.floats[key] = TFloat:new(self,{category=category,key=key,unit=unit,temp=temp})
	end
end
function TPocoHud3:Buff(data) -- {key='',icon=''||{},text={{},{}},st,et}
	local buff = self.buffs[data.key]
	if buff and (buff.data.et ~= data.et or buff.data.good ~= data.good )then
		buff:destroy(1)
		buff = nil
	end
	if not buff then
		buff = TBuff:new(self,data)
		self.buffs[data.key] = buff
	else
		buff:set(data)
	end
end

function TPocoHud3:Popup(data) -- {pos=pos,text={{},{}},stay=true,st,et}
	table.insert(self.pops ,TPop:new(self,data))
end

function TPocoHud3:_checkBuff(t)
	-- Check Another Buffs
	-- Berserker
	if managers.player:upgrade_value( "player", "melee_damage_health_ratio_multiplier", 0 )>0 then
		local health_ratio = _.g('managers.player:player_unit():character_damage():health_ratio()')
		if(health_ratio and health_ratio <= tweak_data.upgrades.player_damage_health_ratio_threshold ) then
			local damage_ratio = 1 - ( health_ratio / math.max( 0.01, tweak_data.upgrades.player_damage_health_ratio_threshold ) )
			local mMul =  1 + managers.player:upgrade_value( "player", "melee_damage_health_ratio_multiplier", 0 ) * damage_ratio
			local rMul =  1 + managers.player:upgrade_value( "player", "damage_health_ratio_multiplier", 0 ) * damage_ratio
			if mMul*rMul > 1 then
				local text = {{(mMul>1 and 'm'..ff(mMul)..'x' or '')..(rMul>1 and ' r'..ff(rMul)..'x' or ''),clBad}}
				self:Buff({
					key= 'berserker', good=true,
					icon=skillIcon,
					iconRect = { 2*64, 2*64,64,64 },
					text=text,
					color=cl.Red,
					st=O.buff.style==2 and damage_ratio or 1-damage_ratio, et=1
				})
			end
		else
			self:RemoveBuff('berserker')
		end
	end
	-- Stamina
	local movement = _.g('managers.player:player_unit():movement()')
	if movement then
		local currSt = movement._stamina
		local maxSt = movement:_max_stamina()
		local thrSt = movement:is_above_stamina_threshold()
		if currSt < maxSt then
			self:Buff({
				key= 'stamina', good=false,
				icon=skillIcon,
				iconRect = { 7*64, 3*64,64,64 },
				text=thrSt and '' or 'Exhausted',
				st=(currSt/maxSt), et=1
			})
		else
			self:RemoveBuff('stamina')
		end
	end
	-- Suppression
	local supp = _.g('managers.player:player_unit():character_damage():effective_suppression_ratio()')
	if false and supp and supp > 0 then
		local supp2 = math.lerp( 1, tweak_data.player.suppression.spread_mul, supp )
		self:AddBuff({
			key= 'supp', good=false,
			icon=skillIcon,
			iconRect = { 7*64, 0*64,64,64 },
			text='Supp'..ff(supp2)..'x',
			st=supp, et=1
		})
	else
		self:RemoveBuff('supp')
	end
end
local _mask = World:make_slot_mask(1, 2, 8, 11, 12, 14, 16, 18, 21, 22, 25, 26, 33, 34, 35 )
function TPocoHud3:_updateItems(t,dt)
	self.state = self.state or _.g('managers.player:player_unit():movement():current_state()')
	self.ADS= self.state and self.state._state_data.in_steelsight
	self:_scanSmoke(t)
	local r = _.r(_mask)
	if r and r.unit then
		local unit = r.unit
		if unit and unit:in_slot( 8 ) and alive( unit:parent() ) then -- shield
			unit = unit:parent()
		end
		unit = (unit:movement() or unit:carry_data()) and unit
		if unit then
			local cHealth = unit:character_damage() and unit:character_damage()._health or false
			if cHealth and cHealth > 0 or unit:carry_data() then
				self:Float(unit,0,true)
			end
		end
	end

	self:_checkBuff(t)
	local style = O.buff.style
	local vanilla = style == 2
	local align = O.buff.align
	local size = (vanilla and 40 or O.buff.size) + O.buff.gap
	local count = 0
	for __,buff in pairs(self.buffs) do
		if not (buff.dead or buff.dying) then
			count = count + 1
		end
	end
	local x,y,move = self._ws:size()
	x = x * O.buff.left/100 - size/2
	y = y * O.buff.top/100 - size/2
	local oX,oY = x,y
	if align == 1 then
		move = size
	elseif align == 2 then
		move = size
		if vanilla then
			y = y - count * size / 2
		else
			x = x - count * size / 2
		end
	else
		move = -size
	end
	for key,buff in _pairs(self.buffs) do
		if not (buff.dead or buff.dying) then
			if vanilla then
				y = y + move
			else
				x = x + move
			end
			if not buff.x then
				buff.x = oX
				buff.y = oY
			end
			buff:draw(t,x,y)
		elseif not buff.dying then
			buff:destroy()
		end
	end
	for key,pop in pairs(self.pops) do
		if pop.dead then
			pop:destroy(key)
		else
			pop:draw(t)
		end
	end
	for key,float in pairs(self.floats) do
		float:draw(t)
	end
end
function TPocoHud3:RemoveBuff(key,skipAnim)
	local buff = self.buffs[key]
	if buff and not buff.dying then
		buff.dead = true
		buff:destroy(skipAnim)
	end
end

function TPocoHud3:_upd_dbgLbl(t,dt)
	self._keyList = _.s(#(Poco._kbd:down_list() or {})>0 and Poco._kbd:down_list() or '')
	self._dbgTxt = _.s(self._keyList,self:lastError())
	if t-(self._last_upd_dbgLbl or 0) > 0.5 or self._dbgTxt ~= self.__dbgTxt  then
		self.__dbgTxt = self._dbgTxt
		self.dbgLbl:set_text( _.s( math.floor(1/dt)..'fps', os.date('%X'),self._dbgTxt))
		self._last_upd_dbgLbl = t
	end
end
function TPocoHud3:_scanSmoke(t)
	local smokeDecay = 3
	local units = World:find_units_quick( "all", World:make_slot_mask( 14 ))
	for i,smoke in pairs(units or {}) do
		if smoke:name():key() == '465d8f5aafa10ce5' then
			self.smokes[tostring(smoke:position())] = {smoke:position(),t}
		end
	end
	for id,smoke in pairs(clone(self.smokes)) do
		if t-smoke[2] > smokeDecay then
			self.smokes[id] = nil
		end
	end
end
function TPocoHud3:Stat(pid,key,data,add)
	if pid then
		local stat = self.stats[pid] or {}
		if not self.stats[pid] then
			self.stats[pid] = stat
		end
		if not stat[key] and data == nil then
			return 0
		end
		if data ~= nil then
			if add then
				stat[key] = (stat[key] or 0) + data
			else
				stat[key] = data
			end
		end
		return stat[key]
	end
end
function TPocoHud3:_pos(unit,head)
	if not alive(unit) then return Vector3() end
	local pos = unit:position()
	if head and unit.movement and unit:movement() and unit:movement():m_head_pos() then
		mvector3.set_z(pos,unit:movement():m_head_pos().z+(type(head)=='number' and head or 0))
	end
	return pos
end
function TPocoHud3:_member(something)
	local t = type(something)
	if t == 'userdata' then
		return something and alive(something) and managers.network:game():member_from_unit( something )
	elseif t == 'number' then
		return self:_member(managers.network:game():unit_from_peer_id( something ))
	end
end
function TPocoHud3:_pid(unit)
	local member = self:_member(unit)
	return member and member:peer():id() or 0
end
function TPocoHud3:_color(something,fbk)
	local fallback = fbk or cl.Purple
	if type(something) == 'number' then
		return tweak_data.chat_colors[something] or fallback
	elseif type(something) == 'userdata' then
		local pid = self:_pid(something)
		return pid ~= 0 and self:_color(pid) or fallback
	else
		return fallback
	end
end
function TPocoHud3:_name(something)
	local str = type_name(something)
	if str == 'Vector3' then
		local members = _.g('managers.network:game()._members',{})
		local pid, closest = nil, 999999999
		for __, member in pairs( members ) do
			local unit = member:unit()
			if unit and alive(unit) then
				local d = mvector3.distance_sq(something,unit:position())
				if d < closest then
					pid = member:peer():id()
					closest = d
				end
			end
		end
		something = pid or self.pid
	end
	local member = self:_member(something)
	member = something==0 and "AI" or (member and member:peer():name() or "Someone")
	return member
end
function TPocoHud3:_time(sec)
	local r = {}
	if type(sec) ~= 'number' then
		sec = tonumber(sec)
	end
	if sec >= 60 then
		table.insert(r,math.floor(sec/60))
	end
	if sec >= 0 then
		table.insert(r,sec<60 and _.f(sec) or ('%02s'):format(math.floor(sec%60)))
	end
	return table.concat(r,':')
end
local pen = Draw:pen( "no_z", "red" )
local pen2 = Draw:pen( "no_z", "green" )
local pen3 = Draw:pen( "no_z", 'blue' )
function TPocoHud3:_visibility(uPos)
	local result = 1-math.min(0.9,managers.environment_controller._current_flashbang)
	if not uPos then
		return result
	end
	local minDis = 9999
	local sRad = 300
	for i,obj in pairs(self.smokes) do
		local sPos = obj[1]
		local cPos = self.camPos
		local disR, dotR = 1,1
		local sDir = sPos - cPos
		local uDir = uPos - cPos
		local xDir = sPos - uPos
		minDis = math.min(sDir:length(),xDir:length())
		if minDis <= sRad then
			disR = math.pow(minDis/sRad,3)
		elseif sDir:length() < uDir:length() then
			mvector3.normalize( sDir )
			mvector3.normalize( uDir )
			local dot = mvector3.dot( sDir,uDir )
			dotR= 1-math.pow(dot,3)
		end
		result = math.min(result,math.min(disR,dotR))
	end

--	_.d(now(),result*100,'%')
		-- 1. Inside smoke
		-- 2. Through smoke
	return result
end
function TPocoHud3:_hook()
	local Run = function(key,...)
		if self.hooks[key] then
			return self.hooks[key][2](...)
		else
		end
	end
	local hook = function(Obj,key,newFunc)
		local realKey = key:gsub('*','')
		if not self.hooks[key] then
			self.hooks[key] = {Obj,Obj[realKey]}
			Obj[realKey] = function(...)
				if me.dead then
					return Run(key,...)
				else
					return newFunc(...)
				end
			end
		else
			_('!!Hook Name Collision:'..key)
		end
	end
	--
	if inGame then
		--PlayerStandards
		hook( PlayerStandard, '_start_action_unequip_weapon', function( self,t ,data)
			Run('_start_action_unequip_weapon', self, t,data)
			local alt = self._ext_inventory:equipped_unit()
			for k,sel in pairs(self._ext_inventory._available_selections) do
				if sel.unit ~= alt then
					alt = sel.unit
					break
				end
			end
			local altTD = alt:base():weapon_tweak_data()
			local multiplier = 1
			multiplier = multiplier * managers.player:upgrade_value( "weapon", "swap_speed_multiplier", 1 )
				* managers.player:upgrade_value( "weapon", "passive_swap_speed_multiplier", 1 )
				* managers.player:upgrade_value( altTD[ "category" ], "swap_speed_multiplier", 1 )

			local altT = (altTD.timers.equip or 0.7 ) / multiplier

			local et = self._unequip_weapon_expire_t + altT
			if et then
				pcall(me.Buff,me,({
					key='transition', good=false,
					icon=skillIcon,
					iconRect = { 0, 9*64,64,64 },
					text='',
					st=t, et=et
				}) )
			end
		end)
		hook( PlayerStandard, '_start_action_equip_weapon', function( self,t )
			Run('_start_action_equip_weapon', self, t)
			local wb = self._equipped_unit:base()
			if me.gadget and me.gadget[wb._name_id] then
				wb:set_gadget_on(me.gadget[wb._name_id] )
				self:_stance_entered()
			end
		end)
		hook( PlayerManager, 'drop_carry', function( self ,...)
			Run('drop_carry', self,... )
			pcall(me.Buff,me,({
				key='drop_carry', good=false,
				icon=skillIcon, iconRect = {6*64, 0*64, 64, 64},
				text='',
				st=now(), et=managers.player._carry_blocked_cooldown_t
			}) )
		end)
		local rectDict = {}
		rectDict.combat_medic_damage_multiplier = {'Dmg+', { 5, 7 }}
		rectDict.no_ammo_cost = {'BS',{ 4, 5 }}
		rectDict.dmg_multiplier_outnumbered = {'Dmg+',{2,1}}
		rectDict.dmg_dampener_outnumbered = ''-- {'Def+',{2,1}} -- Double item
		rectDict.overkill_damage_multiplier = {'Dmg+',{3,2}}
		hook( PlayerManager, 'activate_temporary_upgrade', function( self, category, upgrade )
			Run('activate_temporary_upgrade',  self, category, upgrade )
			local et = _.g('managers.player._temporary_upgrades.'..category ..'.'..upgrade..'.expire_time')
			if not et then return end
			local rect = rectDict[upgrade]
			if rect ~= '' then
				local rect2 = rect and ({64*rect[2][1],64*rect[2][2],64,64})
				pcall(me.Buff,me,({
					key=upgrade, good=true,
					icon=rect2 and skillIcon or 'guis/textures/pd2/lock_incompatible', iconRect = rect2,
					text=rect and rect[1] or upgrade,
					st=now(), et=et
				}) )
			end
		end)
		hook( PlayerStandard, '_do_action_intimidate', function( self, t, interact_type, sound_name, skip_alert )
			local r = Run('_do_action_intimidate',  self, t, interact_type, sound_name, skip_alert )
			local et =_.g('managers.player:player_unit():movement()._current_state._intimidate_t')
			if et and interact_type then
				et = et + tweak_data.player.movement_state.interaction_delay
				pcall(me.Buff,me,({
					key='interact', good=false,
					icon=skillIcon,
					iconRect = { 2*64, 8*64 ,64,64 },
					st=t, et=et
				}) )
				local boost = self._ext_movement:rally_skill_data() and self._ext_movement:rally_skill_data().morale_boost_delay_t
				if boost and boost > t then
					pcall(me.Buff,me,({
						key='inspire', good=false,
						icon=skillIcon,
						iconRect = { 4*64, 9*64 ,64,64 },
						st=t, et=boost
					}) )
				end
			end
			return r
		end)
		hook( PlayerStandard, '_interupt_action_interact', function( self,t, input, complete  )
			Run('_interupt_action_interact', self, t, input, complete )
			local et = self._equip_weapon_expire_t
			if et then
				pcall(me.Buff,me,({
					key='transition', good=false,
					icon=skillIcon,
					iconRect = { 4*64, 3*64,64,64 },
					text='',
					st=now(), et=et
				}) )
			end
		end)
		hook( PlayerStandard, '_end_action_running', function( self,t, input, complete  )
			Run('_end_action_running', self, t, input, complete )
			local et = self._end_running_expire_t
			if et then
				pcall(me.Buff,me,({
					key='transition', good=false,
					icon=skillIcon,
					iconRect = { 0, 9*64,64,64 },
					text='',
					st=now(), et=et
				}) )
			end
		end)

		hook( PlayerStandard, '_interupt_action_use_item', function( self,t, input, complete  )
			Run('_interupt_action_use_item', self, t, input, complete )
			local et = self._equip_weapon_expire_t
			if et then
				pcall(me.Buff,me,({
					key='transition', good=false,
					icon=skillIcon,
					iconRect = { 4*64, 3*64,64,64 },
					text='',
					st=now(), et=et
				}) )
			end
		end)
		hook( PlayerStandard, '_start_action_reload', function( self,t  )
			Run('_start_action_reload', self, t )
			local et = self._state_data.reload_expire_t
			if et then
				pcall(me.Buff,me,({
					key='transition', good=false,
					icon=skillIcon,
					iconRect = { 0, 9*64,64,64 },
					text='',
					st=t, et=et
				}) )
			end
		end)
		hook( PlayerStandard, '_update_interaction_timers', function( self, t,... )
			Run('_update_interaction_timers', self, t,...)
			local et = self._interact_expire_t
			if et then
				pcall(me.Buff,me,({
					key='transition', good=true,
					icon = "guis/textures/pd2/pd2_waypoints",
					iconRect = {224, 32, 32, 32 },
					--icon = "guis/textures/hud_icons",
					--iconRect = { 96, 144, 48, 48 },
					text='',
					st=t, et=et
				}) )
			end
		end)
		hook( PlayerStandard, '_update_reload_timers', function( self, t,... )
			Run('_update_reload_timers', self, t,...)
			local et = self._state_data.reload_exit_expire_t
			if et and et > 0 and me.buffs['transition'] then
				me:RemoveBuff('transition')
			end
		end)

		hook( PlayerStandard, '_check_action_weapon_gadget', function( self,...)
			local  t, input = unpack({...})
			Run('_check_action_weapon_gadget', self, ...)
			if input.btn_weapon_gadget_press then
				local wb = self._equipped_unit:base()
				if not me.gadget then me.gadget = {} end
				me.gadget[wb._name_id] = wb._gadget_on
			end
		end)

		hook( PlayerStandard, '_do_action_melee', function( self,t ,input )
			Run('_do_action_melee', self, t ,input )
			local et = self._state_data.melee_expire_t
			if et then
				pcall(me.Buff,me,({
					key='transition', good=false,
					icon=skillIcon,
					iconRect = { 1*64, 3*64,64,64 },
					text='',
					st=t, et=et
				}) )
			end
		end)
		hook( PlayerStandard, '_interupt_action_reload', function( self,t  )
			if self:_is_reloading() then
				me:RemoveBuff('transition')
			end
			Run('_interupt_action_reload', self, t )
		end)
		--PlayerMovement
		hook( PlayerMovement, 'on_morale_boost', function( self, benefactor_unit )
			local r =Run('on_morale_boost',  self, benefactor_unit )
			if self._morale_boost then
				local et = now() + tweak_data.upgrades.morale_boost_time
				pcall(me.Buff,me,({
					key='boost', good=true,
					icon=skillIcon,
					iconRect = { 4*64, 9*64 ,64,64 },
					st=now(), et=et
				}) )
			end
				return r
		end)
		--[[hook( HuskPlayerMovement, 'play_redirect', function( self, ... )
			local redirect_name, at_time = unpack{...}
			if redirect_name and
				not redirect_name:find('idle') and
				not redirect_name:find('walk') and
				not redirect_name:find('sprint') and
				not redirect_name:find('run') and
				not redirect_name:find('recoil') then
				me:Popup( {pos=me:_pos(self._unit), text={{redirect_name,cl.Yellow}}, stay=false, et=now()+3 })
			end
			return Run('play_redirect',  self, ... )
		end)]]

		--PlayerDamage
		hook( PlayerDamage, 'set_regenerate_timer_to_max', function( self )
			Run('set_regenerate_timer_to_max', self)
			local sd = self._supperssion_data and self._supperssion_data.decay_start_t
			if sd then
				sd = math.max(0,sd-now())
			end
			local et = now()+self._regenerate_timer+(sd or 0)
			if et then
				pcall(me.Buff,me,({
					key='shield', good=false,
					icon=skillIcon,
					iconRect = { 6*64, 4*64,64,64 },
					text='Regen',
					st=now(), et=et
				}) )
			end
		end)
		--UnitNetwork
		hook( UnitNetworkHandler, 'long_dis_interaction', function( ... )
			local self, target_unit, amount, aggressor_unit  = unpack({...})
			local pid = me:_pid(target_unit)
			local pidA = me:_pid(aggressor_unit)
			if amount == 1 and pid and pid>0 then -- 3rd Person to me.
				me:Stat(pid,'boost',now() + tweak_data.upgrades.morale_boost_time)
			end
			return Run('long_dis_interaction',...)
		end)
		hook( BaseNetworkSession, 'send_to_peer', function( ... ) -- To capture boost
			local self, peer, fname, target_unit, amount, aggressor_unit = unpack({...})
			if fname == 'long_dis_interaction' and amount == 1 then
				local pid = me:_pid(target_unit)
				if pid then -- 3rd Person to Someone
					me:Stat(pid,'boost',now() + tweak_data.upgrades.morale_boost_time)
				end
			end
			return Run('send_to_peer',...)
		end)
		hook( UnitNetworkHandler, 'damage_bullet', function( ... )
			local self,subject_unit, attacker_unit, damage, i_body, height_offset, death, sender = unpack({...})
			local head = i_body and alive(subject_unit) and subject_unit:character_damage().is_head and subject_unit:character_damage():is_head(subject_unit:body(i_body))
			me:AddDmgPopByUnit(attacker_unit,subject_unit,height_offset,damage*-0.1953125,death,head)
			return Run('damage_bullet',...)
		end)
		hook( UnitNetworkHandler, 'damage_explosion', function(...)
			local self, subject_unit, attacker_unit, damage, i_attack_variant, death, direction, sender = unpack({...})
			me:AddDmgPopByUnit(attacker_unit,subject_unit,0,damage*-0.1953125,death)
			return Run('damage_explosion', ... )
		end)
		hook( UnitNetworkHandler, 'damage_melee', function(...)
			local self, subject_unit, attacker_unit, damage, damage_effect, i_body, height_offset, variant, death, sender  = unpack({...})
			local head = i_body and alive(subject_unit) and subject_unit:character_damage().is_head and subject_unit:character_damage():is_head(subject_unit:body(i_body))
			me:AddDmgPopByUnit(attacker_unit,subject_unit,height_offset,damage*-0.1953125,death,head)
			return Run('damage_melee',...)
		end)
		--CopDamage
		hook( CopDamage, '_on_damage_received', function(self,info)
			local result = Run('_on_damage_received',self,info)
			local hitPos = Vector3()
			if not info.col_ray then
				if self._unit then
				 -- me:AddDmgPopByUnit(nil,self._unit,0,info.damage,self._dead)
				end
			else
				if info.col_ray.position or info.pos or info.col_ray.hit_position then
					mvector3.set(hitPos,info.col_ray.position or info.pos or info.col_ray.hit_position)
					local head = self._unit:character_damage():is_head(info.col_ray.body)
					me:AddDmgPop(info.attacker_unit,hitPos,self._unit,0,info.damage,self._dead,head)
				end
			end
			return result
		end)
		--CopMovement
		hook( CopMovement, 'action_request', function( ...  )
			local self, action_desc = unpack({...})
			local dmgTime = O.popup.damageDecay
			if action_desc.variant == 'hands_up' and O.popup.handsUp then
				me:Popup({pos=me:_pos(self._unit),text={{'Hands-Up',cl.White}},stay=false,et=now()+dmgTime})
			elseif action_desc.variant == 'tied' and O.popup.dominated then
				if not managers.enemy:is_civilian( self._unit ) then
					me:Popup({pos=me:_pos(self._unit),text={{'Intimidated',cl.White}},stay=false,et=now()+dmgTime})
					me:Chat('dominated','We got a police hostage around '..me:_name(me:_pos(self._unit))..'.'..(me._hostageTxt or ''))
				end
			end
			if action_desc.type=='act' and action_desc.variant then
--				me:Popup({pos=me:_pos(self._unit),text={{action_desc.variant,Color.white}},stay=true,et=now()+dmgTime})
			end
			return Run('action_request', ... )
		end)

		--ETC
		hook( HUDManager, 'show_endscreen_hud', function( self )
			Run('show_endscreen_hud', self )
			me:destroy(true)
		end)

		hook( ECMJammerBase, 'set_active', function( self,active )
			Run('set_active', self, active )
			local et = self:battery_life()
			if et then
				pcall(me.Buff,me,({
					key='ecm', good=true,
					icon=skillIcon,
					iconRect = { 1*64, 4*64,64,64 },
					text='',
					st=now(), et=et+now()
				}) )
			end
		end)
		hook( ECMJammerBase, 'set_feedback_active', function( self )
			Run('set_feedback_active', self )
			local et = self._feedback_duration
			if et then
				pcall(me.Buff,me,({
					key='feedback', good=true,
					icon=skillIcon,
					iconRect = { 6*64, 2*64,64,64 },
					text='',
					st=now(), et=et+now()
				}) )
			end
		end)
		hook( SecurityCamera, '_start_tape_loop', function( self , ...)
			local tape_loop_t = unpack({...})
			Run('_start_tape_loop', self, ... )
			local et = tape_loop_t+6
			if et then
				pcall(me.Buff,me,({
					key='tloop', good=true,
					icon=skillIcon,
					iconRect = { 4*64, 2*64,64,64 },
					text='',
					st=now(), et=et+now()
				}) )
			end
		end)
		-- MinionHooks
		hook( GroupAIStateBase, 'convert_hostage_to_criminal', function( self, ... )
			local unit, peer_unit = unpack{...}
			Run('convert_hostage_to_criminal', self, ...  )
			peer_unit = peer_unit or managers.player:player_unit()
			local peerId = me:_pid(peer_unit)
			me:Minion(peerId,unit)
		end)
		hook( UnitNetworkHandler, 'mark_minion', function( self,  unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender )
			Run('mark_minion', self, unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender )
			me:Minion(minion_owner_peer_id,unit)
		end)
		hook( ChatManager, '_receive_message', function( self, ... )
			local channel_id, name, message, color, icon = unpack({...})
			if not O.chat.muted and (name ~= me:_name(me.pid)) and (name ~= _BROADCASTHDR) and message and not Network:is_server() and message:find(_BROADCASTHDR) then
				_.c(_BROADCASTHDR_HIDDEN,'PocoHud broadcast Muted.')
				O.chat.muted = true
			end
			return Run('_receive_message', self,  ...)
		end)
		-- CriminalDown
		hook( HUDManager, 'remove_teammate_panel', function( self, ... )
			local id = unpack{...}
			-- nothing
			return Run('remove_teammate_panel', self, ... )
		end)

		hook( HUDManager, 'add_teammate_panel', function( self, ... )
			local character_name, player_name, ai, peer_id = unpack({...})
			if peer_id then
				if me:Stat(peer_id,'name') ~= player_name then
					me:Stat(peer_id,'name',player_name)
					me:Stat(peer_id,'time',now())
					me:Stat(peer_id,'health',0)
					me:Stat(peer_id,'kill',0)
					me:Stat(peer_id,'killS',0)
					me:Stat(peer_id,'down',0)
					me:Stat(peer_id,'downAll',0)
					me:Stat(peer_id,'minion',0)
				end
			end
			return Run('add_teammate_panel', self, ... )
		end)

		local OnCriminalHealth = function(pid,data)
			local percent = (pid==self.pid and data.current/data.total or data.current)*100
			local bPercent = self:Stat(pid,'health')
			local down = self:Stat(pid,'down')
			if percent >= 99.8 and bPercent < percent then
				if bPercent ~= 0 then
					self:Chat('replenished',self:_name(pid)..' replenished health by '.._.f(percent-bPercent)..'% '..(down>0 and '+'..down..' downcount' or ''))
				end
				self:Stat(pid,'downAll',self:Stat(pid,'down'),true)
				self:Stat(pid,'down',0)
			end
			self:Stat(pid,'health',percent)
		end
		hook( HUDManager, 'set_teammate_health', function( ... )
			local self, i, data = unpack({...})
			local pid
			if i == 4 then
				pid = me.pid
			else
				for _, data in pairs( managers.criminals._characters ) do
					if data.taken and i == data.data.panel_id then
						pid = data.peer_id
					end
				end
			end
			if pid then
				OnCriminalHealth(pid,data)
			end
			return Run('set_teammate_health', ...)
		end)
		local OnCriminalDowned = function(pid)
			self:Stat(pid,'down',1,true)
			if self:Stat(pid,'down') == 3 then
				self:Chat('downedWarning','Warning:'..me:_name(pid)..' was downed '..me:Stat(pid,'down')..' times.')
			end
		end
		hook( PlayerBleedOut, '_enter', function( self, ... )
			OnCriminalDowned(me.pid)
			return Run('_enter', self,  ...)
		end)
		hook( HuskPlayerMovement, '_get_max_move_speed', function( self, ... )
			return Run('_get_max_move_speed', self,  ...) * 3
		end)
		hook( HuskPlayerMovement, '_start_bleedout', function( self, ... )
			local pid = me:_pid(self._unit)
			if pid then
				OnCriminalDowned(pid)
			end
			return Run('_start_bleedout', self,  ...)
		end)
		hook( getmetatable(managers.subtitle.__presenter), 'show_text', function( self, ... )
			local text, duration = unpack({...})
			local label = self.__subtitle_panel:child("label") or self.__subtitle_panel:text({
				name = "label",
				x = 1,
				y = 1,
				font = self.__font_name,
				font_size = self.__font_size,
				color = cl.White,
				align = "center",
				vertical = "bottom",
				layer = 1,
				wrap = true,
				word_wrap = true
			})
			local shadow = self.__subtitle_panel:child("shadow") or self.__subtitle_panel:text({
				name = "shadow",
				x = 2,
				y = 2,
				font = self.__font_name,
				font_size = self.__font_size,
				color = cl.Black:with_alpha(0.8),
				align = "center",
				vertical = "bottom",
				layer = 0,
				wrap = true,
				word_wrap = true
			})
			label:set_text(text)
			shadow:set_text(text)
		end)

		-- Criminal Custody
		local OnCriminalCustody = function(criminal_name)
			local pid
			for _, data in pairs( managers.criminals._characters ) do
				if data.taken and criminal_name == data.name then
					pid = data.peer_id
				end
			end
			if pid and self:Stat(pid,'health',0) ~= 0 then
				self:Stat(pid,'downAll',self:Stat(pid,'down'),true)
				self:Stat(pid,'down',0)
				self:Stat(pid,'health',0)
				self:Chat('custody',self:PeerIDToName(pid)..' is in custody.')
			end
		end
		hook( UnitNetworkHandler, 'set_trade_death', function( ... )
			local self, criminal_name, respawn_penalty, hostages_killed = unpack({...})
			OnCriminalCustody(criminal_name)
			return Run('set_trade_death', ...)
		end)
		hook( TradeManager, 'on_player_criminal_death', function( ... )
			local self, criminal_name, respawn_penalty, hostages_killed, skip_netsend = unpack({...})
			OnCriminalCustody(criminal_name)
			return Run('on_player_criminal_death', ...)
		end)
		-- TimerGUI
		hook( TimerGui, 'update', function( ... )
			local self, unit, t, dt = unpack({...})
			local result = Run('update', ...)
			me:Float(unit,1,false)
			return result
		end)
		hook( ContourExt, 'add', function( ... )
			local self, type, sync, multiplier = unpack({...})
			local result = Run('add', ...)
			me:Float(self._unit,0,result.fadeout_t or now()+4)
			return result
		end)
	end
end
--- Utility functions ---
function TPocoHud3:test()
	if inGame then
		self:AnnounceStat(true)
		if true then return end
		if _.r() then
			managers.groupai:state():detonate_smoke_grenade(_.r().position,self.camPos,10,false)
		end
		if self.foo then
			self.pnl.dbg:remove(self.foo)
			self.foo = nil
		elseif false then
			self.foo = self.pnl.dbg:bitmap{ name='foo', texture='guis/textures/hud_icons' or "guis/textures/pd2/pd2_waypoints"
				or 'guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types',
						--[[texture_rect = {
						240,
						192,
						32,
						32
					},]]
				blend_mode = 'normal', layer=1, x=0,y=100, cl.White}

		end
	else
		local pings = {}
		local falsy = self:_name(5)
		for i=1,4 do
			local name = self:_name(i)
			if name ~= falsy then
				table.insert(pings,name..':')
				table.insert(pings,self:Stat(i,'ping'))
			end
		end
		if #pings > 0 then
			_.c('Ping',_.s(unpack(pings)))
		else
			_.c('Ping','No ping data')
		end
	end
end
function TPocoHud3:_v2p(pos)
	return alive(self._ws) and pos and self._ws:world_to_screen( self.cam, pos )
end
function TPocoHud3:_setupWws()
	self._wws = World:newgui():create_world_workspace( 10, 10, Vector3(0,0,0), Vector3(10,0,0), Vector3(0,0,-10) )
	self.wws = {
		pnl = self._wws:panel()
	}
	local wws = self.wws

	wws.valid = function()
		return self.cam and alive( self._wws )
	end
	wws.set_visible = function(set)
		if not wws.valid() then return end
		if set then
			wws.pnl:show()
		else
			wws.pnl:hide()
		end
	end
	wws.reflow = function(distance)
		local mul = distance/1000
	end
	wws.size = function()
		if not wws.valid() then return end
		local __,__,w,h = wws.lbl:text_rect()
		return w,h
	end
	wws.set_position = function(pos,distance)
		if not (pos and wws.valid()) then return end
		wws.reflow(distance or mvector3.distance(self.cam:position(),pos))
		local w,h = wws.size()
		if not w then return end
		local rot = self.rot
		self._wws:set_world( w,h, pos - Vector3( w / 2, 0, -h / 2 ):rotate_with( rot ), rot:x() * w, -rot:z() * h )
	end
end
function TPocoHud3:_vectorToScreen(v3pos)
	if not self._ws then return end
	local cam = managers.viewport:get_current_camera()
	return (cam and v3pos) and self._ws:world_to_screen( cam, v3pos )
end
function TPocoHud3:_lbl(lbl,txts)
	local result = ''
	if type(txts)=='table' and alive(lbl) then
		local pos = 0
		local posEnd = 0
		local ranges = {}
		for _k,txtObj in ipairs(txts or {}) do
			txtObj[1] = tostring(txtObj[1])
			result = result..txtObj[1]
			local __, count = txtObj[1]:gsub('[^\128-\193]', '')
			posEnd = pos + count
			table.insert(ranges,{pos,posEnd,txtObj[2] or cl.Blue})
			pos = posEnd
		end
		lbl:set_text(result)
		for _,range in ipairs(ranges) do
			lbl:set_range_color( range[1], range[2], range[3] or cl.Green)
		end
	elseif type(txts)=='string' then
		result = txts
		lbl:set_text(txts)
	end
	return result
end
--- Class end ---
if Poco and not Poco.dead then
	me = Poco:AddOn(TPocoHud3)
	if me and not me.dead then
		PocoHud3 = me
	else
		PocoHud3 = true
	end
else
	managers.menu_component:post_event( "zoom_out")
end