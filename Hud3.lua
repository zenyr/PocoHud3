if not TPocoBase then return end
local inGame = CopDamage ~= nil
local me
--- Options ---
local YES,NO,yes,no = true,false,true,false
local O = {
	enable = YES,
	buff = {
		show = YES,
		maxFPS = 30,
		size = 70,
		gap = 20,
		align = 2, -- 1:left 2:center 3:right
		style = 1, -- 1:PocoHud style 2:Vanilla style
	},
	popup = {
		size = 20,
		damageDecay = 10,
		myDamage = YES,
		crewDamage = YES,
		AIDamage = YES,
		handsUp = YES,
		dominated = YES,
	},
	clock = {

	},
	minion = {
		show = YES
	},
	chat = {
		neverSend = NO,
		readThreshold = 2,
		sendThreshold = 3,
		index = {
			midStat = 2,
			endStat = 3,
			dominated = 4,
			converted = 4,
			minionLost = 4,
			hostageChanged = 1,
			downedWarning = 5,
			replenish = 5,
		}
	},
}
local FONT = tweak_data.hud_players.name_font
local clGood =  Color( 255, 146, 208, 80 ) / 255
local clBad =  Color( 255, 255, 192, 0 ) / 255
local iconSkull,iconShadow,iconRight,iconDot,iconChapter,iconDiv,iconBigDot = '', '', '','Ї','ϸ','϶','ϴ'
local iconTimes,iconDivided,iconLC,iconRC,iconDeg,iconPM = '×','÷','','','Ѐ','Ё'
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
	local size = O.buff.size
	local data = self.data
	if O.buff.style == 1 then
		self.created = true
		local pnl = self.ppnl:panel({x = 0,y=0, w=100,h=100})
		self.pnl = pnl
		self.lbl = pnl:text{text='', font=FONT, font_size = size/4, color = data.color or data.good and clGood or clBad, x=1,y=1, layer=2, blend_mode = 'normal'}
		self.bg = pnl:bitmap( { name='bg', texture= 'guis/textures/pd2/hud_tabs',texture_rect=  { 105, 34, 19, 19 }, color= Color.black:with_alpha(0.2), layer=0, x=0,y=0 } )
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
			if type(data.text)=='table' then
				txts = clone(data.text)
			else
				txts = {{data.text or '',data.color}}
				table.insert(txts,{_.f(et ~= 1 and et-now() or prog*100)..(et == 1 and '%' or 's'),clGood})
			end
			self.owner:_lbl(self.lbl,txts)
			local _x,_y,w,h = self.lbl:text_rect()
			local ww, hh = self.pnl:size()
			self.lbl:set_size(w,h)
			self.lbl:set_center(ww/2,hh-h/2)
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
		pnl:set_alpha( t/seconds )
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
	self.ppnl = owner.pnl.pop
	self:_make()
end
function TPop:_make()
	local size = O.popup.size
	local pnl = self.ppnl:panel({x = 0, y = 0, w=100, h=100})
		local data = self.data
	self.pnl = pnl
	self.lbl = pnl:text{text='', font=FONT, font_size = size, color = data.color or data.good and clGood or clBad, x=0,y=0, layer=3, blend_mode = 'add'}
	local _txt = self.owner:_lbl(self.lbl,data.text)
	self.lblBg = pnl:text{text=_txt, font=FONT, font_size = size, color = Color.black, x=1,y=1, layer=2, blend_mode = 'normal'}
	local x,y,w,h = self.lblBg:text_rect()
	pnl:set_shape(-100,-100,w,h)
end
function TPop:draw(t)
	local isADS = self.owner.ADS
	local camPos = self.owner.camPos
	if not self.dead then
		local data = self.data
		local st,et = data.st,data.et
		local prog = (now()-st)/(et-st)
		local pos = data.pos + Vector3()
		local nl_dir = pos - camPos
		mvector3.normalize( nl_dir )
		local dot = mvector3.dot( self.owner.nl_cam_forward, nl_dir )
		local pPos = self.owner:_v2p(pos)
		if not data.stay then
			mvector3.set_y(pPos,pPos.y - math.lerp(100,0, math.pow((1-prog),7)))
		end

		if prog >= 1 then
			self.dead = true
		elseif alive(self.pnl) then
			local dx,dy,d,ww,hh = 0,0,1,self.owner._ws:size()
			self.pnl:set_visible( dot > 0 )
			self.pnl:set_center( pPos.x,pPos.y)
			if isADS then
				dx = pPos.x - ww/2
				dy = pPos.y - hh/2
				d = math.clamp((dx*dx+dy*dy-2000)/1000,0,1)
			else
				d = 1-math.pow(prog,5)
			end
			self.pnl:set_alpha(math.min(1-prog,d))
		end
	end
end
function TPop:destroy(key)
	self.ppnl:remove(self.pnl)
	if key then
		self.owner.pops[key] = nil
	end
end
--- Class Start ---
local TPocoHud3 = class(TPocoBase)
TPocoHud3.className = 'Hud'
TPocoHud3.classVersion = 3
--- Inherited ---
function TPocoHud3:onInit(saved) -- 설정
	saved = saved or {}
	Poco:LoadOptions(self:name(1),O)
	if not O.enable then
		return false
	end
	self._ws = inGame and managers.gui_data:create_fullscreen_workspace() or managers.gui_data:create_fullscreen_16_9_workspace()
	self:_setupWws()
	self.pnl = {
		dbg = self._ws:panel():panel({ name = "dbg_sheet" , layer = 50000}),
		pop = self._ws:panel():panel({ name = "dmg_sheet" , layer = 5}),
		buff = self._ws:panel():panel({ name = "buff_sheet" , layer = 5}),
	}
	self.killa = saved.killa or 0
	self.stats = saved.stats or {}
	self.hooks = {}
	self.pops = {}
	self.buffs = {}
--	self.tmp = self.pnl.dbg:bitmap{name='x', blend_mode = 'add', layer=1, x=0,y=40, color=clGood ,texture = "guis/textures/hud_icons"}
	local dbgSize = 20
	self.dbgLbl = self.pnl.dbg:text{text='HUD '..(inGame and 'Ingame' or 'Outgame'), font=FONT, font_size = dbgSize, color = Color.purple, x=0,y=self.pnl.dbg:height()-dbgSize, layer=0}
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
	local r,err = pcall(self._update,self,t,dt)
	if not r then _(err) end
end
function TPocoHud3:onDestroy()
	if( alive( self._ws ) ) then
		managers.gui_data:destroy_workspace(self._ws)
	end
	if( alive( self._worldws ) ) then
		World:newgui():destroy_workspace( self._worldws )
	end
end
function TPocoHud3:_pid(unit)
	if not (unit and alive(unit)) then return 0 end
	local member = managers.network:game():member_from_unit( unit )
	return member and member:peer():id() or 0
end
function TPocoHud3:_color(something,fbk)
	local fallback = fbk or Color.purple
	if type(something) == 'number' then
		return tweak_data.chat_colors[something] or fallback
	elseif type(something) == 'userdata' then
		local pid = self:_pid(something)
		return pid ~= 0 and self:_color(pid) or fallback
	end
end
function TPocoHud3:AddDmgPop(sender,hitPos,unit,offset,damage,death,head)
	if self.dead then return end
	local isPercent = damage<0
	local dmgTime = O.popup.damageDecay
	local rDamage = damage>=0 and damage or -damage
	if isPercent and unit and unit:character_damage() and unit:character_damage()._HEALTH_INIT then
		rDamage = math.min(unit:character_damage()._HEALTH_INIT * rDamage / 100,unit:character_damage()._health)
	end
	local isSpecial = false
	if unit then
		isSpecial = tweak_data.character[ unit:base()._tweak_table ].priority_shout
		if isSpecial =='f34' then isSpecial = false end
		--[[for pid,minion in pairs(self.minions) do
			if unit:key() == minion:key() then
				local apid = self:UnitToPeerID(sender)
				if apid and apid > 0 and (apid ~= _lastAttkpid or now()-_lastAttk > 5) then
					_lastAttk = now()
					_lastAttkpid = apid
					self:Broadcast(''..toStr(self:PeerIDToName(apid),'attacked',(pid==apid and 'own' or self:PeerIDToName(pid)..'\'s'),'minion, Dmg:',ff(rDamage*10)) ,true)
				end
			end
		end]] -- TODO: Minion got shot
	end
	local color = (self:_color(sender,Color.white)):with_alpha(death and 1 or 0.5)
	local pid = self:_pid(sender)
	local texts = { }
	if rDamage>0 then
		texts[#texts+1] = {_.f(rDamage*10),color}
	end
	if head then
		texts[#texts+1] = {'!',color:with_red(1)}
	end
	if death then
		texts[#texts+1] = {'',isSpecial and color:with_red(1) or color}
	end
	local pos = Vector3()
	mvector3.set(pos,hitPos)
	mvector3.set_z(pos,pos.z + offset)
	local r,err = pcall(function()
		self:Popup( {pos=pos, text=texts, stay=false, st=now(), et=now()+dmgTime })
		if sender then
			if me:Stat(pid,'time') == 0 then
				me:Stat(pid,'time',now())
			end
			me:Stat(pid,'dmg',rDamage*10,true)
			if death then
				self.killa = self.killa +1
				me:Stat(pid,'kill',1,true)
				if isSpecial then
					me:Stat(pid,'killS',1,true)
				end
				--[[if Network:is_server() and (self.killa % 100 == 0) then
					self:AnnounceStat(true,true)
				end]] -- TODO : Announce every 100k
			end
		end
	end)
	if not r then _(err) end
end
--- Internal functions ---
function TPocoHud3:_update(t,dt)
	self:_upd_dbgLbl(t,dt)
	self.cam = alive(self.cam) and self.cam or managers.viewport:get_current_camera()
	if not self.cam then return end
	self.rot = self.cam:rotation()
	self.camPos = self.cam:position()
	self.nl_cam_forward = Rotation()
	mrotation.y( self.rot, self.nl_cam_forward )

	if inGame then
		self:_updateItems(t,dt)
	else

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
					color=Color.red,
					st=1-damage_ratio, et=1
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


function TPocoHud3:_updateItems(t,dt)
	self.state = self.state or _.g('managers.player:player_unit():movement():current_state()')
	self.ADS= self.state and self.state._state_data.in_steelsight
	self:_checkBuff(t)
	local size = O.buff.size + O.buff.gap
	local x,y = 200,200
	local a = {}
	for key,buff in _pairs(self.buffs) do
		if not (buff.dead or buff.dying) then
			if O.buff.style == 1 then
				x = x + size
			else
				y = y + size
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
function TPocoHud3:_hook()
	local Run = function(key,...)
		if self.hooks[key] then
			return self.hooks[key][2](...)
		else
		end
	end
	local hook = function(Obj,key,newFunc)
		_('hook',key)
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
			multiplier = multiplier * managers.player:upgrade_value( "weapon", "passive_swap_speed_multiplier", 1 )
			multiplier = multiplier * managers.player:upgrade_value( altTD[ "category" ], "swap_speed_multiplier", 1 )

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
			local pid = me:UnitToPeerID(target_unit)
			local pidA = me:UnitToPeerID(aggressor_unit)
			if amount == 1 and pid and pid>0 then -- 3rd Person to me.
				me:Stat(pid,'boost',now() + tweak_data.upgrades.morale_boost_time)
			end
			return Run('long_dis_interaction',...)
		end)
		hook( BaseNetworkSession, 'send_to_peer', function( ... ) -- To capture boost
			local self, peer, fname, target_unit, amount, aggressor_unit = unpack({...})
			if fname == 'long_dis_interaction' and amount == 1 then
				local pid = me:UnitToPeerID(target_unit)
				if pid then -- 3rd Person to Someone
					me:Stat(pid,'boost',now() + tweak_data.upgrades.morale_boost_time)
				end
			end
			return Run('send_to_peer',...)
		end)
		--CopDamage
		--###TODO START
			hook( CopDamage, '_on_damage_received', function(self,info)
				local result = Run('_on_damage_received',self,info)
				local hitPos = Vector3()
				if not info.col_ray then
					if self._unit then
					 -- PocoHud:AddDmgItemByUnit(nil,self._unit,0,info.damage,self._dead)
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
			hook( UnitNetworkHandler, 'damage_bullet', function( ... )
				local self,subject_unit, attacker_unit, damage, i_body, height_offset, death, sender = unpack({...})
				local head = i_body and alive(subject_unit) and subject_unit:character_damage().is_head and subject_unit:character_damage():is_head(subject_unit:body(i_body))
				PocoHud:AddDmgItemByUnit(attacker_unit,subject_unit,height_offset,damage*-0.1953125,death,head)
				return Run('damage_bullet',...)
			end)
			hook( UnitNetworkHandler, 'damage_explosion', function(...)
				local self, subject_unit, attacker_unit, damage, i_attack_variant, death, direction, sender = unpack({...})
				PocoHud:AddDmgItemByUnit(attacker_unit,subject_unit,0,damage*-0.1953125,death)
				return Run('damage_explosion', ... )
			end)
			hook( UnitNetworkHandler, 'damage_melee', function(...)
				local self, subject_unit, attacker_unit, damage, damage_effect, i_body, height_offset, variant, death, sender  = unpack({...})
				local head = i_body and alive(subject_unit) and subject_unit:character_damage().is_head and subject_unit:character_damage():is_head(subject_unit:body(i_body))
				PocoHud:AddDmgItemByUnit(attacker_unit,subject_unit,height_offset,damage*-0.1953125,death,head)
				return Run('damage_melee',...)
			end)
		--###TODO END
		--ETC
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

			hook( PlayerStandard, '_interupt_action_reload', function( self,t  )
				if self:_is_reloading() then
					me:RemoveBuff('transition')
				end
				Run('_interupt_action_reload', self, t )
			end)

	end
end
--- Utility functions ---
function TPocoHud3:test()
	_.d('TEST')
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
	me = Poco:AddOn(TPocoHud3)
	if me and not me.dead then
		PocoHud3 = me
	else
		PocoHud3 = true
	end
else
	managers.menu_component:post_event( "zoom_out")
end