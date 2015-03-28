-- PocoHud3 by zenyr@zenyr.com
if not TPocoBase then return end
local disclaimer = [[
feel free to ask me through my mail: zenyr(at)zenyr.com. But please understand that I'm quite clumsy, cannot guarantee I'll reply what you want..
]]

-- Note: Due to quirky PreCommit hook, revision number would *appear to* be 1 revision before than "released" luac files.
local _ = UNDERSCORE
local REV = 351
local TAG = '0.262 hotfix 1 (32f7c14)'
local inGame = CopDamage ~= nil
local inGameDeep
local me
local currDir = PocoDir
Poco.currDir = currDir
PocoHud3Class = nil
Poco._req (currDir..'Hud3_class.lua')
if not PocoHud3Class then return end
Poco._req (currDir..'Hud3_Options.lua')
if not PocoHud3Class.Option then return end
local O = PocoHud3Class.Option:new()
PocoHud3Class.O = O
local K = PocoHud3Class.Kits:new()
PocoHud3Class.K = K
local L = PocoHud3Class.Localizer:new()
PocoHud3Class.L = L

--- Options ---
local YES,NO,yes,no = true,false,true,false
local ALTFONT= PocoHud3Class.ALTFONT
local FONT= PocoHud3Class.FONT
local FONTLARGE = PocoHud3Class.FONTLARGE
local clGood= PocoHud3Class.clGood
local clBad= PocoHud3Class.clBad
local Icon= PocoHud3Class.Icon
local PocoEvent= PocoHud3Class.PocoEvent

local _BAGS = {
	['8f59e19e1e45a05e']='Ammo',
	['43ed278b1faf89b3']='Med',
	['a163786a6ddb0291']='Body',
	['e1474cdfd02aa274']='Aid',
}

local _BROADCASTHDR, _BROADCASTHDR_HIDDEN = Icon.Div,Icon.Ghost
local skillIcon = 'guis/textures/pd2/skilltree/icons_atlas'
local now = function (type) return type and TimerManager:game():time() or managers.player:player_timer():time() end
local _conv = {
	city_swat	=	L('_mob_city_swat'),
	cop	=	L('_mob_cop'),
	fbi	=	L('_mob_fbi'),
	fbi_heavy_swat	=	L('_mob_fbi_heavy_swat'),
	fbi_swat	=	L('_mob_fbi_swat'),
	gangster	=	L('_mob_gangster'),
	gensec	=	L('_mob_gensec'),
	heavy_swat	=	L('_mob_heavy_swat'),
	security	=	L('_mob_security'),
	shield	=	L('_mob_shield'),
	sniper	=	L('_mob_sniper'),
	spooc	=	L('_mob_spooc'),
	swat	=	L('_mob_swat'),
	tank	=	L('_mob_tank'),
	taser	=	L('_mob_taser'),
}
--- Class Start ---
local TPocoHud3 = class(TPocoBase)
PocoHud3Class.TPocoHud3 = TPocoHud3
TPocoHud3.className = 'Hud'
TPocoHud3.classVersion = 3
--- Inherited ---
function TPocoHud3:onInit() -- ★설정
--	Poco:LoadOptions(self:name(1),O)
	O:load()
	L:load()
	clGood = O:get('root','colorPositive')
	clBad = O:get('root','colorNegative')
	self._ws = managers.gui_data:create_fullscreen_workspace()
	error = function(msg)
		if self.dead then
			_('ERR:',msg)
		else
			self:err(msg,1)
		end
	end
	--self:_setupWws()
	self.pnl = {
		dbg = self._ws:panel():panel({ name = 'dbg_sheet' , layer = 50000}),
		pop = self._ws:panel():panel({ name = 'dmg_sheet' , layer = 4}),
		buff = self._ws:panel():panel({ name = 'buff_sheet' , layer = 5}),
		stat = self._ws:panel():panel({ name = 'stat_sheet' , layer = 9}),
	}
	self.killa = self.killa or 0
	self.stats = self.stats or {}
	self.hooks = {}
	self.pops = {}
	self.buffs = {}
	self.floats = {}
	self.sFloats = {}
	self.smokes = {}
	self.hits = {} -- to prevent HitDirection markers gc
	self.gadget = self.gadget or {}
--	self.tmp = self.pnl.dbg:bitmap{name='x', blend_mode = 'add', layer=1, x=0,y=40, color=clGood ,texture = 'guis/textures/hud_icons'}
	local dbgO = O:get('corner')
	self.dbgLbl = self.pnl.dbg:text{text='HUD '..(inGame and 'Ingame' or 'Outgame'), font= dbgO.defaultFont and FONT or ALTFONT, font_size = dbgO.size, color = dbgO.color:with_alpha(dbgO.opacity/100), x=0,y=self.pnl.dbg:height()-dbgO.size, layer=0}
	self:_hook()
	self:_updateBind()
	return true
end
function TPocoHud3:onResolutionChanged()
	if alive(self._ws) then
		managers.gui_data:layout_fullscreen_workspace( self._ws )
		self.dbgLbl:set_y(self.pnl.dbg:height()-self.dbgLbl:height())
	else
		self:err('No WS to reschange')
	end
end
function TPocoHud3:import(data)
	self.killa = data.killa
	self.stats = data.stats
	self._muted = data._muted
	self._startGameT = data._startGameT
end
function TPocoHud3:export()
	Poco.save[self.className] = {
		stats = self.stats,
		killa = self.killa,
		_muted = self._muted,
		_startGameT = self._startGameT,
	}
end
function TPocoHud3:Update(t,dt)
	if managers.vote:is_restarting() then return end
	local r,err = pcall(self._update,self,t,dt)
	if not r then _(err) end
end
function TPocoHud3:onDestroy(gameEnd)
	self:Menu(true,true) -- Force dismiss menu
	if( alive( self._ws ) ) then
		managers.gui_data:destroy_workspace(self._ws)
	end
end
function TPocoHud3:AddDmgPopByUnit(sender,unit,offset,damage,death,head,dmgType)
	if unit and alive(unit) then
		local isPlayer = unit:base().upgrade_value
		if not isPlayer then -- this filters PlayerDrama related events out when hosting a game
			self:AddDmgPop(sender,self:_pos(unit),unit,offset,damage,death,head,dmgType)
		end
	end
end
local _lastAttk, _lastAttkpid = 0,0
function TPocoHud3:AddDmgPop(sender,hitPos,unit,offset,damage,death,head,dmgType)
	local Opt = O:get('popup')
	if self.dead then return end
	local pid = self:_pid(sender)

	local isPercent = damage<0
	local dmgTime = Opt.damageDecay
	local rDamage = damage>=0 and damage or -damage
	if isPercent and unit and unit:character_damage() and unit:character_damage()._HEALTH_INIT then
		rDamage = math.min(unit:character_damage()._HEALTH_INIT * rDamage / 100,unit:character_damage()._health)
	end
	local isSpecial = false
	if unit then
		if not alive(sender) then return end -- If an attacker died/nonexist just before this, abandon.
		local senderTweak = sender and alive(sender) and sender:base()._tweak_table
		local unitTweak = unit and alive(unit) and unit:base()._tweak_table
		isSpecial = tweak_data.character[ unitTweak ]
		isSpecial = isSpecial and isSpecial.priority_shout
		if isSpecial =='f34' then isSpecial = false end
		for i = 1,4 do
			local minion = self:Stat(i,'minion')
			if unit == minion then
				local apid = self:_pid(senderTweak)
				self:Stat(i,'minionHit',senderTweak)
				if (rDamage or 0) > 0 and apid and apid > 0 and (apid ~= _lastAttkpid or now()-_lastAttk > 5) then
					_lastAttk = now()
					_lastAttkpid = apid
					self:Chat('minionShot',L('_msg_minionShot',{self:_name(senderTweak),i==apid and 'own' or self:_name(i)..'\'s',_.f(rDamage*10)}))
				end
			end
		end
	end
	local color = (self:_color(sender,cl.White)):with_alpha(death and 1 or 0.5)
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
		if sender then
			if self:Stat(pid,'time') == 0 then
				self:Stat(pid,'time',now())
			end
			if dmgType == 'bullet' then
				self:Stat(pid,'dmg',rDamage*10,true)
				self:Stat(pid,'hit',1,true)
			end
			if head then
				self:Stat(pid,'head',1,true)
			end
			if death then
				self.killa = self.killa +1
				self:Stat(pid,'kill',1,true)
				if isSpecial then
					self:Stat(pid,'killS',1,true)
				end
				local mA = O:get('chat','midstatAnnounce') or 0
				if mA > 0 and Network:is_server() and (self.killa % (mA*50) == 0 ) then
					self:AnnounceStat(true)
				end
			end
		end
		if pid == self.pid and not Opt.myDamage then return
		elseif pid == 0 and not Opt.AiDamage then return
		elseif not Opt.crewDamage then
			if pid > 0 and pid ~= self.pid then
				return
			end
		end
		if Opt.enable then
			self:Popup( {pos=pos, text=texts, stay=false, et=now()+dmgTime })
		end
	end)
	if not r then _(err) end
end
--- Internal functions ---
function TPocoHud3:say(line,sync)
	if line then
		--[[local cs = _.g('managers.player:player_unit():movement()._current_state')
		if cs then
			cs._intimidate_t = now()
			pcall(self.Buff,self,({
				key='interact', good=false,
				icon=skillIcon,
				iconRect = { 2*64, 8*64 ,64,64 },
				st=now(), et=now()+tweak_data.player.movement_state.interaction_delay
			}) )
		end]]
		--[[
		if _.g('managers.groupai:state()') then
			managers.groupai:state():teammate_comment(_.g('managers.player:player_unit()'), line, nil, false, nil, false)
			return true
		end]]
		local sound = _.g('managers.player:player_unit():sound()')
		if not sound then return end
		return sound:say(line,true,sync)
	end
end

function TPocoHud3:toggleRose(show)
	if self._noRose then return end
	local C = PocoHud3Class
	local canOpen = inGameDeep and (not self._lastSay or now()-self._lastSay > tweak_data.player.movement_state.interaction_delay / 2)
	local r,err = pcall(function()
		local menu = self.menuGui
		if menu and not self._guiFading then -- hide
			self.menuGui = nil
			self._guiFading = true
			if self._say then
				if self:say(self._say,true) then
					self._lastSay = now()
				end
				self._say = nil
			end
			menu:fadeOut(function()
				self._guiFading = nil
				menu:destroy()
			end)
		elseif canOpen and show and not self._guiFading then -- create
			local gui = C.PocoMenu:new(self._ws,true)
			self.menuGui = gui
			gui:fadeIn()
			local tab = gui:add('Rose')
			C._drawRose(tab)
		elseif not canOpen and show then
			-- managers.menu:post_event('menu_error')
		end
	end)
	if not r then
		self:err(_.s('ToggleRose',err))
	end
end

function TPocoHud3:Menu(dismiss,skipAnim)
	local C = PocoHud3Class
	local _drawUpgrades = C._drawUpgrades
	local _drawPlayer = C._drawPlayer

	local r,err = pcall(function()
		local menu = self.menuGui
		if menu then -- Remove
			self:_updateBind()
			if not self._stringFocused or (now()-self._stringFocused > 0.1) then
				self.menuGui = nil
				self._noRose = nil
				self._guiFading = true
				if self.onMenuDismiss then
					local cbk = self.onMenuDismiss
					self.onMenuDismiss = nil
					cbk()
				end
				if not self:say('g92',true) then
					managers.menu_component:post_event('menu_exit')
				end

				if skipAnim then
					menu:destroy()
					self._guiFading = nil
				else
					menu:fadeOut(function()
						self._guiFading = nil
						menu:destroy()
					end)
				end
			end
		elseif not dismiss and not self._guiFading and not managers.system_menu:is_active() then -- Show
			if not self:say('a01x_any',true) then
				managers.menu_component:post_event('menu_enter')
			end
			local gui = C.PocoMenu:new(self._ws)
			self.menuGui = gui
			self._noRose = true
			gui:fadeIn()
			--- Install tabs Begin --- ===================================
			local tab = gui:add(L('_tab_about'))
			C._drawAbout(tab,REV,TAG)

			local tab = gui:add(L('_tab_options'))
			C._drawOptions(tab)

			local y = 0
			tab = gui:add(L('_tab_statistics'))
			do
				local oTabs = C.PocoTabs:new(self._ws,{name = 'stats',x = 10, y = 10, w = 970, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})
				local oTab = oTabs:add(L('_tab_heistStatus'))
				local r,err = pcall(C._drawHeistStats,oTab) -- yeaaaah just in case. I know. I'm cheap
				if not r then me:err('DHS:',err) end

				oTab = oTabs:add(L('_tab_upgradeSkills'))
				if inGame then
					for pid,upg in pairs(_.g('Global.player_manager.synced_team_upgrades',{})) do
						if upg then
							y = _drawUpgrades(oTab,upg,true,L('_upgr_crewBonusFrom',{self:_name(pid)}) ,y)
						end
					end
				end
				y = _drawUpgrades(oTab,_.g('Global.player_manager.team_upgrades'),true,L('_line_youAndCrewsPerks'),y)
				y = _drawUpgrades(oTab,_.g('Global.player_manager.upgrades'),false,L('_line_yourPerks'),y)
			end

			tab = gui:add(L('_tab_tools'))
			do
				local oTabs = C.PocoTabs:new(self._ws,{name = 'tools',x = 10, y = 10, w = 970, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})
				local oTab = oTabs:add(L('_tab_kitProfiler'))
				PocoHud3Class._drawKit(oTab)

				local oTab = oTabs:add(L('_tab_Inspect'))
				y = _drawPlayer(oTab, 0)
				oTab:set_h(y)

				local oTab = oTabs:add(L('_tab_jukebox'))
				PocoHud3Class._drawJukebox(oTab)
			end
		end
	end)
	if not r then _('MenuCallErr',err) end
end
function TPocoHud3:AnnounceStat(midgame)
	local txt = {}
	table.insert(txt,Icon.LC..'PocoHud³ r'..REV.. ' '.. Icon.RC..' '..L('_stat_crewKills',{Icon.Skull,self.killa}))
	for pid = 0,4 do
		local kill = self:Stat(pid,'kill')
		local killS = self:Stat(pid,'killS')
		if kill > 0 then
			local dt = now()-self:Stat(pid,'time')
			local dps = _.f(self:Stat(pid,'dmg')/dt or 0)
			local hit = math.max(self:Stat(pid,'hit'),1)
			local shot = math.max(self:Stat(pid,'shot'),1)
			local accuracy = _.f(hit/shot*100,0)..'%'
			local kpm = _.f(60*kill/dt)
			local downs = self:Stat(pid,'down')+self:Stat(pid,'downAll')
			if midgame then
				table.insert(txt,
					_.s(Icon.LC..self:_name(pid)..Icon.RC,
						kill..Icon.Skull..(killS>0 and '('..killS..' Sp)' or ''),
						(downs>0 and downs..Icon.Ghost or nil)
					)
				)
			else
				table.insert(txt,
					_.s(Icon.LC..self:_name(pid)..Icon.RC,
						kill..Icon.Skull..(killS>0 and '('..killS..' Sp)' or ''),'|',
						'DPS:'..dps,'|',
						'KPM:'..kpm,'|',
						'Acc:'..(pid==0 and 'N/A' or accuracy),
						(downs>0 and downs..Icon.Ghost or nil)
					)
				)
			end
		end
	end
	if #txt > 3 then
		for ___,tx in ipairs(txt) do
		self:Chat(midgame and 'midStat' or 'endStat',tx)
		end
	else
		self:Chat(midgame and 'midStat' or 'endStat',table.concat(txt,'\n'))
	end
	if not midgame then
		self:Chat('endStatCredit','-- PocoHud³ : More info @ steam group "pocomods" --')
	end
end
local lastSlowT = 0
function TPocoHud3:_slowUpdate(t,dt)
	self.ww = self.pnl.dbg:w()
	self.hh = self.pnl.dbg:h()
	if inGame then
		local peers = _.g('managers.network:session():peers()',{})
		for pid,peer in pairs( peers ) do
			if peer and peer:rpc() then
				self:Stat(pid,'ping',math.floor(Network:qos( peer:rpc() ).ping))
			end
		end
		self.pid = _.g('managers.network:session():local_peer():id()')
	end
end
function TPocoHud3:_update(t,dt)
	if not (PocoHud3Class and not self.dead) then return end
	inGameDeep = inGame and BaseNetworkHandler._verify_gamestate(BaseNetworkHandler._gamestate_filter.any_ingame_playing)
	if self.inGameDeep ~= inGameDeep then
		if inGameDeep then
			self._startGameT = now()
		else
			self._endGameT = now()
		end
		self.inGameDeep = inGameDeep
	end
	self:_upd_dbgLbl(t,dt)
	self.cam = managers.viewport:get_current_camera()
	if not self.cam then return end
	self.rot = self.cam:rotation()
	self.camPos = self.cam:position()
	self.nl_cam_forward = self.rot:y()
	if t - lastSlowT > 5 then -- SlowUpdate
		lastSlowT = t
		self:_slowUpdate(t,dt)
	end

	if inGame then
		self:_updateItems(t,dt)
	end
	if self.menuGui then
		self.menuGui:update(t,dt)
	end
	local location = PocoHud3Class.PocoLocation
	location:update(t,dt)

	if inGameDeep and now() - (self._lastRoom or 0) > 1 then
		self._lastRoom = now()
		local room = _.g('Poco.room')
		local game = managers.network:game()
		if game then
			for pid=1,4 do
				local unit = self:Stat(pid,'custody') == 0 and room and game:unit_from_peer_id(pid)
				if unit and alive(unit) then
					self:Stat(pid,'room',room:get(unit:movement():m_pos(),true))
				end
			end
		end
	end

	if self._music_started then
		if O:get('root','showMusicTitle') then
			me:SimpleFloat{key='showMusicTitle',x=10,y=10,time=5,anim=1,offset={200,0},
				text={{_.s(O:get('root','showMusicTitlePrefix')),cl.White:with_alpha(0.6)},{self._music_started,cl.Tan}},
				size=24, icon = {tweak_data.hud_icons:get_icon_data('jukebox_playing_icon')}
			}
		end
		self._music_started = nil
	end
end

function TPocoHud3:HitDirection(col_ray,data)
	local mobPos
	if self._lastAttkUnit and alive(self._lastAttkUnit) then
		mobPos = self._lastAttkUnit:position()
		self._lastAttkUnit = nil
	elseif col_ray and col_ray.position and col_ray.distance then
		mobPos = col_ray.position - (col_ray.ray*(col_ray.distance or 0))
	end
	if not mobPos then -- still nothing? now we search data
		local mobUnit = data.weapon_unit or data.attacker_unit
		if mobUnit and alive(mobUnit) then
			mobPos = mobUnit:position()
		else
			mobPos = data.hit_pos or data.position
		end
	end
	if not mobPos then -- still no?... set to player position
		mobPos = _.g('managers.player:player_unit():position()')
	end
	if mobPos then
		table.insert(self.hits,PocoHud3Class.THitDirection:new(self,{mobPos=mobPos,shield=data.shield,dmg=data.dmg,time=data.time,rate=data.rate}))
	end
end
function TPocoHud3:Minion(pid,unit)
	if alive(unit) then
		self:Stat(pid,'minion',unit)
		self:Chat('converted',L('_msg_converted',{self:_name(pid),self:_name(unit),O:get('chat','includeLocation') and self:_name(pid,true) or ''}))
	else
		self:Stat(pid,'minion',0)
	end
end
function TPocoHud3:Chat(category,text,system)
	local catInd = O:get('chat',category) or -1
	local forceSend = catInd >= 5
	if not O:get('chat','enable') then return end
	if self._muted and not forceSend then return _('Muted:',text) end
	local canRead = catInd >= 1
	local isFullGame = not managers.statistics:is_dropin()
	local canSend = catInd >= (Network:is_server() and 2 or isFullGame and 3 or 4)
	if catInd >= 3 and not canSend and not O:get('chat','fallbackToMe')then
		canRead = false
	end
	local tStr = _.g('managers.hud._hud_heist_timer._timer_text:text()')
	if canRead or canSend then
		_.c(tStr..(canSend and '' or _BROADCASTHDR_HIDDEN), text , canSend and self:_color(self.pid) or nil)
		if canSend then
			managers.network:session():send_to_peers_ip_verified( 'send_chat_message', system and 8 or 1, tStr.._BROADCASTHDR.._.s(text) )
		end
	end
end
function TPocoHud3:Float(unit,category,temp,tag)
	local key = unit.key and unit:key()
	if not O:get('float','enable') then return end
	if not key then return end
	local float = self.floats[key]
	if float then
		float:renew({tag=tag,temp=temp})
	else
		if category == 1 and not O:get('float','showDrills') then
			--
		else
			self.floats[key] = PocoHud3Class.TFloat:new(self,{category=category,key=key,unit=unit,temp=temp, tag=tag})
		end
	end
end
function TPocoHud3:Buff(data) -- {key='',icon=''||{},text={{},{}},st,et}
	if not O:get('buff','enable') then return end
	if not O:get('buff','show'.. ((data.key):gsub('^%l', string.upper)) ) then return end
	local buff = self.buffs[data.key]
	if buff and (buff.data.et ~= data.et or buff.data.good ~= data.good )then
		buff:destroy(1)
		buff = nil
	end
	if not buff then
		buff = PocoHud3Class.TBuff:new(self,data)
		self.buffs[data.key] = buff
	else
		buff:set(data)
	end
end

function TPocoHud3:SimpleFloat(data) -- {key,x,y,time,text,size,val,anim,offset,icon,rect}
	local key = data.key
	if key and self.sFloats[key] then
		self.sFloats[key]:hide()
		self.sFloats[key] = nil
	end
	local pnl = self.pnl.dbg:panel{x = data.x, y = data.y, w=500, h=100}
	if key then
		self.sFloats[key] = pnl
	end
	pnl:rect{color=cl.Black,layer=-1,alpha=data.rect or 0.9}
	local offset = data.offset or {0,0}
	local anim = data.anim
	local __, lbl = _.l({pnl=pnl,x=5,y=5, font=FONT, color=cl.White, font_size=data.size},data.text,true)
	if data.icon then
		local icon,rect = unpack(data.icon)
		local bmp = pnl:bitmap{
			name = 'icon',
			texture = icon,
			texture_rect = rect,
			x = 5, y = 5
		}
		bmp:set_center_y(5 + data.size/2)

		lbl:set_x(bmp:width()+10)
	end
	pnl:set_size(lbl:right()+5,lbl:bottom()+5)
	pnl:stop()
	local t = now()
	pnl:animate(function(p)
		while alive(p) and p:visible() do
			local dt = now() - t
			local r = dt / data.time
			if r > 1 then break end
			if anim == 1 then
				r = math.pow(r,0.5)
				local rr = math.min(r,1-r)
				p:set_alpha(math.pow(rr,0.4))
			end
			local dx,dy = offset[1] * r, offset[2] * r
			p:set_position(math.floor(data.x + dx),math.floor(data.y + dy))
			coroutine.yield()
		end
		if alive(p) then
			if p:visible() then
				self.sFloats[key] = nil
			end
			p:parent():remove(p)
		end
	end)
end

function TPocoHud3:Popup(data) -- {pos=pos,text={{},{}},stay=true,st,et}
	table.insert(self.pops ,PocoHud3Class.TPop:new(self,data))
end

function TPocoHud3:_updateBind()
	Poco:UnBind(self)
	local verboseKey = O:get('root','detailedModeKey')
	if verboseKey then
		if O:get('root','detailedModeToggle') then
			Poco:Bind(self,verboseKey,callback(self,self,'toggleVerbose','toggle'))
		else
			Poco:Bind(self,verboseKey,callback(self,self,'toggleVerbose',true),callback(self,self,'toggleVerbose',false))
		end
	end
	local pocoRoseKey = O:get('root','pocoRoseKey')
	Poco:Bind(self,pocoRoseKey,callback(self,self,'toggleRose',true,false),callback(self,self,'toggleRose',false,false))

	Poco:Bind(self,14,function()
		self:Menu(false,false)
	end)
	local keys = K:keys()
	for key,index in pairs(keys) do
		Poco:Bind(self,key,function()
			if not inGameDeep and ctrl() and alt() and not managers.system_menu:is_active() then
				K:equip(index,not O:get('root','silentKitShortcut'))
				managers.menu:post_event('finalize_mask')
			end
		end)
	end
end

function TPocoHud3:_checkBuff(t)
	-- Check Another Buffs
	-- Berserker
	if managers.player:upgrade_value( 'player', 'melee_damage_health_ratio_multiplier', 0 )>0 then
		local health_ratio = _.g('managers.player:player_unit():character_damage():health_ratio()')
		if(health_ratio and health_ratio <= tweak_data.upgrades.player_damage_health_ratio_threshold ) then
			local damage_ratio = 1 - ( health_ratio / math.max( 0.01, tweak_data.upgrades.player_damage_health_ratio_threshold ) )
			local mMul =  1 + managers.player:upgrade_value( 'player', 'melee_damage_health_ratio_multiplier', 0 ) * damage_ratio
			local rMul =  1 + managers.player:upgrade_value( 'player', 'damage_health_ratio_multiplier', 0 ) * damage_ratio
			if mMul*rMul > 1 then
				local text = {{(mMul>1 and _.f(mMul)..'x' or '')..(rMul>1 and ' '.._.f(rMul)..'x' or ''),clBad}}
				self:Buff({
					key= 'berserker', good=true,
					icon=skillIcon,
					iconRect = { 2*64, 2*64,64,64 },
					text=text,
					color=cl.Red,
					st=O:get('buff','style')==2 and damage_ratio or 1-damage_ratio, et=1
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
				text=thrSt and '' or L('_buff_exhausted'),
				st=(currSt/maxSt), et=1
			})
		else
			self:RemoveBuff('stamina')
		end
	end
	-- Suppression
	local supp = _.g('managers.player:player_unit():character_damage():effective_suppression_ratio()')
	if supp and supp > 0 then
		-- Not in effect as of now : local supp2 = math.lerp( 1, tweak_data.player.suppression.spread_mul, supp )
		self:Buff({
			key= 'suppressed', good=false,
			icon=skillIcon,
			iconRect = { 7*64, 0*64,64,64 },
			text='', --_.f(supp2)..'x',
			st=supp, et=1
		})
	else
		self:RemoveBuff('suppressed')
	end

	local melee = self.state and self.state._state_data.meleeing and self.state:_get_melee_charge_lerp_value( t ) or 0
	if melee > 0 then
		self:Buff({
			key= 'charge', good=true,
			icon=skillIcon,
			iconRect = { 4*64, 12*64,64,64 },
			text='',
			st=melee, et=1
		})
	else
		self:RemoveBuff('charge')
	end
end

local _roman = {
	{'M',1000}, {'CM',900}, {'D',500}, {'CD',400}, {'C',100}, {'XC',90}, {'L',50}, {'XL',40}, {'X',10}, {'IX',9}, {'V',5}, {'IV',4}, {'I',1}
}
function TPocoHud3:_romanic_number(num)
	local result = '';
	if O:get('game','romanInfamy') then
		while(num > 0) do
			for i, val in pairs(_roman) do
				if(num >= val[2]) then
					num = num - val[2];
					result = result .. val[1];
					break;
				end
			end
		end
	else
		result = tostring(num)
	end
	return result;
end

function TPocoHud3:_updatePlayers(t)
	if t-(self._lastUP or 0) > 0.05 and inGameDeep then
		self._lastUP = t
	else
		return
	end
	for i = 1,4 do
		local name = self:_name(i)
		name = name ~= self:_name(-1) and name
		local nData = managers.hud:_name_label_by_peer_id( i )
		local isMe = i==self.pid
		local pnl = self['pnl_'..i]
		local btmO = O:get('playerBottom')
		local fltO = O:get('playerFloat')
		local _show = function(name,isFlt)
			local thr = (isFlt and fltO or btmO)['show'..name] or 0
			local ind = self.verbose and 1 or 2
			return thr >= ind
		end
		pnl = pnl ~= 0 and pnl or nil
		if pnl and (not name or not btmO.enable or (self:Stat(i,'_refreshBtm') ~= 0)) then
			-- killPnl
			self.pnl.stat:remove(pnl)
			self['pnl_'..i] = nil
			self:Stat(i,'_refreshBtm',0)
		elseif not pnl and name and (isMe or nData) then
			-- makePnl
			local __,err = pcall(function()
					if btmO.enable and managers.criminals:character_unit_by_name( managers.criminals:character_name_by_peer_id(i) ) then
						local cdata = managers.criminals:character_data_by_peer_id( i ) or {}
						local bPnl = managers.hud._teammate_panels[ isMe and 4 or cdata.panel_id or -1 ]
						if bPnl and not (not isMe and bPnl == managers.hud._teammate_panels[4]) then
							local member = self:_member(i)
							if member and alive(member:unit()) then
								if btmO.showRank then
									local peer = member and member:peer()
									local rank = isMe and managers.experience:current_rank() or (peer and peer:rank())
									rank = rank and (rank > 0) and (self:_romanic_number(rank)..'Ї') or ''
									local lvl = isMe and managers.experience:current_level() or peer and peer:level() or ''
									local defaultLbl = bPnl._panel:child( 'name' )
									local nameBg =  bPnl._panel:child( 'name_bg' )
									local nameTxt = self:_name(i)
									if btmO.uppercaseNames then
										nameTxt = utf8.to_upper(nameTxt)
									end
									self:_lbl(defaultLbl,{{rank,cl.White},{lvl..' ',cl.White:with_alpha(0.8)},{nameTxt,self:_color(i)}})
									local txtRect = {defaultLbl:text_rect()}
									defaultLbl:set_size(txtRect[3],txtRect[4])
									local shape = {defaultLbl:shape()}
									nameBg:set_shape(shape[1]-3,shape[2],shape[3]+6,shape[4])
								end
								pnl = self.pnl.stat:panel{x = 0,y=0, w=240,h=btmO.size*2+1}
								local wp = {bPnl._player_panel:world_position()}
								pnl:set_world_position(wp[1],wp[2]-pnl:h())
								local fontSize = btmO.size
								--self['pnl_blur'..i] = pnl:bitmap( { name='blur', texture='guis/textures/test_blur_df', render_template='VertexColorTexturedBlur3D', layer=-1, x=0,y=0 } )
								self['pnl_lbl'..i] = pnl:text{rotation=360,name='lbl',align='right', text='-', font=FONT, font_size = fontSize, color = cl.Red, x=1,y=0, layer=2, blend_mode = 'normal'}
								self['pnl_lblA'..i] = pnl:text{name='lblA',align='right', text='-', font=FONT, font_size = fontSize, color = cl.Black:with_alpha(0.4), x=0,y=1, layer=1, blend_mode = 'normal'}
								self['pnl_lblB'..i] = pnl:text{name='lblB',align='right', text='-', font=FONT, font_size = fontSize, color = cl.Black:with_alpha(0.4), x=2,y=1, layer=1, blend_mode = 'normal'}
								self['pnl_'..i] = pnl

								-- install arrow
								local hPnl = bPnl._player_panel:child('radial_health_panel')
								if hPnl:child('arrow') then
									hPnl:remove(hPnl:child('arrow'))
								end
								if O:get('playerBottom','showArrow') then
									local arrow = hPnl:bitmap{
										name= 'arrow', texture= 'guis/textures/pd2/scrollbar_arrows',
										texture_rect = {0,0,12,12},
										layer= 10,
										color= self:_color(i):with_alpha(0.7),
										blend_mode= 'add',
										x= 0, y=0,
										w= 20,
										h= 10,
										rotation = 360,
									}
									local currAngle = 360
									local tAngle = 360
									local lastT = 0
									local unit = isMe and self:Stat(i,'minion') or nData and nData.movement._unit
									local mcos,msin = math.cos,math.sin
									local w,h = hPnl:w(),hPnl:h()
									local r = (isMe and 64 or 48) / 2 +4
									hPnl:stop()
									hPnl:animate(function(p,t)
										while alive(p) and arrow and alive(arrow) do
											if now() - lastT > 0.1 then
												if isMe then
													unit = self:Stat(i,'minion')
												end
												lastT = now()
												tAngle = self:_getAngle(unit)
											end
											arrow:set_visible(not not tAngle)
											if tAngle then
												if math.abs(tAngle-currAngle) > 180 then
													currAngle = currAngle + (tAngle>currAngle and 360 or -360)
												end
												currAngle = currAngle + (tAngle - currAngle)/5
												if currAngle == 0 then
													currAngle = 360
												end
												arrow:set_rotation(currAngle)
												arrow:set_center(w/2 + r*msin(currAngle),h/2 - r*mcos(currAngle))
											end
											coroutine.yield()
										end
									end)

									self['pnl_arrow'..i] = arrow
								end
								-- arrow end
							end
						end
					end
			end)
		end
		-- playerBottom
		local color = self:_color(i)
		local txts = {}
		if pnl and (nData or isMe) then
			local lbl = self['pnl_lbl'..i]
			local cdata = managers.criminals:character_data_by_peer_id( i ) or {}
			local pInd = isMe and 4 or cdata.panel_id
			local bPnl = managers.hud._teammate_panels[ pInd ]
			local equip = (bPnl and #bPnl._special_equipment > 0)
			local interText = nData and nData.interact:visible() and nData.panel:child( 'action' ):text()
			if isMe then
				interText = managers.hud._progress_timer
					and managers.hud._progress_timer._hud_panel:child( 'progress_timer_text' ):visible()
					and managers.hud._progress_timer._hud_panel:child( 'progress_timer_text' ):text()
			end
			local unit = nData and nData.movement._unit
			local kill = self:Stat(i,'kill')
			local killS = self:Stat(i,'killS')
			local dmg = self:Stat(i,'dmg')
			local head = self:Stat(i,'head')
			local hit = math.max(self:Stat(i,'hit'),1)
			local shot = math.max(self:Stat(i,'shot'),1)
			local accuracy = _.f(hit/shot*100,0)
			local accColor = math.lerp(cl.Red,cl.Green,hit/shot)
			local avgDmg = _.f(dmg/hit,1)
			local downs = self:Stat(i,'down')
			local boost = self:Stat(i,'boost') > now()
			local unitPos = unit and alive(unit) and unit:position()
			local distance = unitPos and mvector3.distance(unitPos,self.camPos) or 0
			local dist_sq = unitPos and mvector3.distance_sq(unitPos,self.camPos) or 0
			local rally_skill_data = _.g('managers.player:player_unit():movement():rally_skill_data()')
			local canBoost = rally_skill_data and rally_skill_data.long_dis_revive and rally_skill_data.range_sq > dist_sq
			local ping = ' '..(self:Stat(i,'ping')>0 and self:Stat(i,'ping')..'ms' or '')
			local lives =	isMe and managers.player:upgrade_value( 'player', 'additional_lives', 0) or 0
			local interT = self:Stat(i,'interactET')
			local room = self:Stat(i,'room')
			if btmO.underneath then
				txts[#txts+1]={'\n'}
			end
			if interT>0 and _show('InteractionTime') then
				local st,et = self:Stat(i,'interactST'), interT
				local t,tt = now()-st,et-st
				local r,rt = t/math.max(0.01,tt), tt-t
				local c = math.lerp(cl.Aqua,cl.Lime,r)
				txts[#txts+1]={' '.._.f(rt),c}
				if rt < 0 then
					self:Stat(i,'interactET',0)
				end
			end
			if interText and _show('Interaction') then
				txts[#txts+1]={' '..interText,cl.White}
			end
			if room and room ~= 0 and _show('Position') then
				txts[#txts+1]={' '..utf8.to_upper(room),cl.White:with_alpha(0.5)}
			end
			if not btmO.underneath then
				txts[#txts+1]={'\n'}
			end
			if _show('Kill') then
				txts[#txts+1]={' '..Icon.Skull..kill,color}
			end
			if _show('Special') then
				txts[#txts+1]={' '..Icon.Skull..killS,cl.Yellow:with_alpha(0.8)}
			end
			if _show('AverageDamage') then
				txts[#txts+1]={' ±'..avgDmg,color:with_alpha(0.8)}
			end

			if _show('ConvertedEnemy') then
				local minion = self:Stat(i,'minion')
				if minion ~= 0 and alive(minion) then
					local cd = minion:character_damage()
					local c = cd._health
					local f = cd._health_max or cd._HEALTH_INIT
					if f then
						txts[#txts+1]={' '..math.floor(c/f*100)..'%',math.lerp( cl.OrangeRed, color, c/f ):with_alpha(0.5)}
					end
				else
					txts[#txts+1]={' '..Icon.Times,cl.OrangeRed:with_alpha(0.5)}
				end
			end

			--[[
				txts[#txts+1]={' !',color:with_red(1)}
				txts[#txts+1]={_.f(head/hit*100,1)..'%',color:with_red(1)}
				txts[#txts+1]={Icon.Times..accuracy..'%',accColor}
			]]

			if boost and _show('Inspire') then
				txts[#txts+1]={' '..Icon.Start or '',clGood:with_alpha(0.5)}
			end
			if distance>0 and _show('Distance') then
				txts[#txts+1]={' '..math.ceil(distance/100)..'m',(canBoost and clGood or clBad):with_alpha(0.8)}
			end
			if _show('Ping') then
				txts[#txts+1]={ping,cl.White:with_alpha(0.5)}
			end
			if isMe and _show('Hostages') then
				txts[#txts+1]={' '..(self._nr_hostages or 0),cl.White:with_alpha(0.8)}
			end
			if _show('Downs') then
				txts[#txts+1]={' '..Icon.Ghost..downs..(lives>0 and '/4' or ''),downs<3 and clGood or Color.red}
			end
			if isMe and _show('Clock') then
				if O:get('root','24HourClock') then
					txts[#txts+1]={os.date(' %X'),Color.white}
				else
					txts[#txts+1]={os.date(' %I:%M:%S%p'),Color.white}
				end
			end
			txts[#txts+1] = {' ',cl.White}
			local btm = (self.hh or 0) - (btmO.underneath and 1 or ( (equip and 140 or 115) - (isMe and 0 or 38)) ) + (btmO.offset or 0)
			if alive(pnl) then
				pnl:set_bottom(btm)
			end
			if alive(lbl) and self['pnl_txt'..i]~=_.l(nil,txts) and self.hh then
				local txt = _.l(lbl,txts)
				self['pnl_txt'..i]=txt
				self['pnl_lblA'..i]:set_text(txt)
				self['pnl_lblB'..i]:set_text(txt)
				local tr = {lbl:text_rect()}
				lbl:set_size(pnl:w(),tr[4])
				self['pnl_lblA'..i]:set_size(pnl:w(),tr[4])
				self['pnl_lblB'..i]:set_size(pnl:w(),tr[4])
			end
		end
		-- playerFloat
		local nLbl = nData and nData.text
		if alive(nLbl) and fltO.enable then
			local member = self:_member(i)
			local peer = member and member:peer()
			local rank = peer and peer:rank()
			rank = rank and (rank > 0) and (self:_romanic_number(rank)..'Ї') or ''
			local lvl = peer and peer:level() or '?'
			local unit = nData and nData.movement._unit
			local distance = unit and alive(unit) and mvector3.distance(unit:position(),self.camPos) or 0
			local boost = self:Stat(i,'boost') > now()
			if nData._infamy ~= _show('Icon',true) then
				local icon = nData.panel:child('infamy')
				if icon then
					icon:set_visible(not not _show('Icon',true)) -- :p
				end
				nData._infamy = _show('Icon',true)
			end
			txts = {
				_show('Rank',true) and {rank,cl.White},_show('Rank',true) and {lvl..' ',cl.White:with_alpha(0.8)},
				{fltO.uppercaseNames and utf8.to_upper(name) or name,color},
				boost and _show('Inspire',true) and {Icon.Start,color:with_alpha(0.5)},
				_show('Distance',true) and {' ('..math.ceil(distance/100)..'m)',color:with_alpha(0.5)},
			}
			_.l(nLbl,txts)
			local x,__,w,h = nLbl:text_rect()
			nLbl:set_size(w,h)
			nData.bag:set_x(nLbl:x()+w+5)
			nData.panel:set_width(nLbl:x()+w + 30)
		end
	end
end
function TPocoHud3:_processMsg(channel,name,message,color)
	-- ToDo : better priority balancing, transmit more info etc
	local pid = 0
	for i = 1,4 do
		if color == self:_color(i) then
			pid = i
		end
	end
	local isMine = pid == self.pid
	local isPrioritized = pid < (self.pid or 0)
	local isPoco = channel == 8
	if not self._muted and isPrioritized and message and message:find(_BROADCASTHDR) then
		_.c(_BROADCASTHDR_HIDDEN,'PocoHud broadcast Muted.')
		self._muted = true
	end
end
function TPocoHud3:_isSimple(key)
	return O:get('buff','simpleBusyIndicator') and (key == 'transition' or key == 'reload' or key == 'charge')
end
local _mask = World:make_slot_mask(1, 8, 11, 12, 14, 16, 18, 21, 22, 24, 25, 26, 33, 34, 35 )
function TPocoHud3:_updateItems(t,dt)
	if self.dead then return end
	self.state = self.state or _.g('managers.player:player_unit():movement():current_state()')
	self.ADS= self.state and self.state._state_data.in_steelsight
	self:_scanSmoke(t)
	self:_updatePlayers(t)
	-- ScanFloat
	if O:get('float','showTargets') then
		local r = _.r(_mask)
		if r and r.unit then
			local unit = r.unit
			if unit and unit:in_slot( 8 ) and alive( unit:parent() ) then -- shield
				unit = unit:parent()
			end
			unit = unit and (unit:movement() or unit:carry_data()) and unit
			local isBag = unit and unit:carry_data()
			if unit then
				local cHealth = unit:character_damage() and unit:character_damage()._health or false
				if not isBag and cHealth and cHealth > 0 then
					self:Float(unit,0,true) -- unit
				elseif isBag and unit:interaction()._active and O:get('float','showBags') then
					self:Float(unit,0,true)	-- lootbag
				end
			end
		end
	end
	-- ScanMinion
	for i = 1,4 do
		local minion = self:Stat(i,'minion')
		if minion and minion ~= 0 then
			if alive(minion) and minion:character_damage()._health > 0 then
				self:Float(minion,0,false,{minion = i})
			elseif not self._endGameT then
				local attacker = self:_name(self:Stat(i,'minionHit'))
				self:Stat(i,'minion',0)
				self:Chat('minionLost',L('_msg_minionLost',{self:_name(i),attacker,O:get('chat','includeLocation') and self:_name(i,true) or ''}))
			end
		end
	end
	-- ScanBuff
	self:_checkBuff(t)
	if t - (self._lastBuff or 0) >= 1/O:get('buff','maxFPS') then
		self._lastBuff = t
		local buffO = O:get('buff')
		local style = buffO.style
		local vanilla = style == 2
		local align = buffO.justify
		local size = (vanilla and 40 or buffO.buffSize) + buffO.gap
		local count = 0
		for key,buff in pairs(self.buffs) do
			if not (buff.dead or buff.dying or self:_isSimple(key)) then
				count = count + 1
			end
		end
		local x,y,move = self._ws:size()
		x = x * buffO.xPosition/100 - size/2
		y = y * buffO.yPosition/100 - size/2
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
		for key,buff in _.p(self.buffs) do
			if not (buff.dead or buff.dying) then
				if self:_isSimple(key) then
					-- do not move
				elseif vanilla then
					y = y + move
				else
					x = x + move
				end
				buff:draw(t,x,y)
			elseif not buff.dying then
				buff:destroy()
			end
		end
	end

	-- ProcessPops&Floats
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
	if self.dead then return end
	local dO = O:get('corner')
	if dO.detailedOnly then
		self.dbgLbl:set_visible(self.verbose)
	end
	self._keyList = ''--_.s(#(Poco._kbd:down_list() or {})>0 and Poco._kbd:down_list() or '')
	self._dbgTxt = _.s(self._keyList,self:lastError())
	local txts = {}
	if dO.showFPS then
		txts[#txts+1] = math.floor(1/dt)
	end
	if (inGameDeep and dO.showClockIngame) or (not inGameDeep and dO.showClockOutgame) then
		if O:get('root','24HourClock') then
			txts[#txts+1] = os.date('%X')
		else
			txts[#txts+1] = os.date('%I:%M:%S%p')
		end
	end
	txts[#txts+1] = self._dbgTxt
	if t-(self._last_upd_dbgLbl or 0) > 0.5 or self._dbgTxt ~= self.__dbgTxt  then
		self.__dbgTxt = self._dbgTxt
		self.dbgLbl:set_text(string.upper(_.s(unpack(txts))))
		self._last_upd_dbgLbl = t
	end
end

function TPocoHud3:_scanSmoke(t)
	local smokeDecay = 3
	local units = World:find_units_quick( 'all', World:make_slot_mask( 14 ))
	for i,smoke in pairs(units or {}) do
		if smoke:name():key() == '465d8f5aafa10ce5' then
			self.smokes[tostring(smoke:position())] = {smoke:position(),t}
		else
			local name = smoke:name():key()
			local per = 0
			name = _BAGS[name] or false
			if name then
				--[[if smoke:base().take_ammo then
					per = smoke:base()._ammo_amount / smoke:base()._max_ammo_amount
				end]]
				local sBase = smoke:base() or {}
				if sBase._damage_reduction_upgrade ~= nil then
					name = name..(sBase._damage_reduction_upgrade and '+' or '')
				else
					name = name..Icon.Times.._.s(sBase._ammo_amount or sBase._amount or sBase._bodybag_amount or '?')
				end
				self:Float(smoke,2,1,{text=name})
			end
		end
	end
	for id,smoke in pairs(clone(self.smokes)) do
		if t-smoke[2] > smokeDecay then
			self.smokes[id] = nil
		end
	end
end
function TPocoHud3:Stat(pid,key,data,add)
	if self.dead then return 0 end
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
		return stat[key] or 0
	end
end
function TPocoHud3:_pos(something,head)
	local t, unit = type(something)
	if t == 'number' then
		unit = managers.network:game():unit_from_peer_id(something)
	else
		unit = something
	end
	if not (unit and alive(unit)) then return Vector3() end
	local pos = Vector3()
	mvector3.set(pos,unit:position())
	if head and unit.movement and unit:movement() and unit:movement():m_head_pos() then
		mvector3.set_z(pos,unit:movement():m_head_pos().z+(type(head)=='number' and head or 0))
	end
	return pos
end
function TPocoHud3:_member(something)
	local t = type(something)
	local game = _.g('managers.network:game()')
	if not game then return end
	if t == 'userdata' then
		return something and alive(something) and game:member_from_unit( something )
	elseif t == 'number' then
		return game:member( something )
	elseif t == 'string' then
		return self:_member(managers.criminals:character_peer_id_by_name( something ))
	end
end
function TPocoHud3:_pid(something)
	local member = self:_member(something)
	return member and member:peer() and member:peer():id() or 0
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

function TPocoHud3:_name(something,asRoom)
	local str = type_name(something)
	if asRoom and str == 'number' and something > 0 then
		return self:_name(self:_pos(something),asRoom)
	elseif str == 'Vector3' then
		if Poco.room and Poco.room:get(something) then
			return Poco.room:get(something,true)
		end
		if asRoom then
			return -- requested room, nothing found
		end
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
		return L('_msg_around',{self:_name(pid or self.pid)})
	elseif str == 'Unit' then
			return self:_name(something:base()._tweak_table)
	elseif str == 'string' then -- tweak_table name
		local pName = managers.criminals:character_peer_id_by_name( something )
		if pName then
			return self:_name(pName)
		else
			local conv = _conv
			return conv[something] or 'AI'
		end
	end
	local member = self:_member(something)
	member = something==0 and 'AI' or (member and member:peer():name() or 'Someone')

	local hDot,fDot
	local truncated = member:gsub('^%b[]',''):gsub('^%b==',''):gsub('^%s*(.-)%s*$','%1')
	if O:get('game','truncateTags') and utf8.len(truncated) > 0 and member ~= truncated then
		member = truncated
		hDot = true
end
	local tLen = O:get('game','truncateNames')
	if tLen > 1 then
		tLen = (tLen - 1) * 3
		if tLen < utf8.len(member) then
			member = utf8.sub(member,1,tLen)
			fDot = true
		end
	end
	return (hDot and Icon.Dot or '')..member..(fDot and Icon.Dot or '')
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
function TPocoHud3:_show(state,isEndgame)
	if self.dead then return end
	if isEndgame and not state then
		self:AnnounceStat(false)
	end
	for k,pnl in pairs(self.pnl) do
		if not (isEndgame and pnl == self.pnl.dbg) then
			pnl:set_visible(state)
		end
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
		local realKey = key:gsub('*','')
		if Obj and not self.hooks[key] then
			self.hooks[key] = {Obj,Obj[realKey]}
			Obj[realKey] = function(...)
				if (me and me.dead) or not me then
					return Run(key,...)
				else
					return newFunc(...)
				end
			end
		else
			_('!!Hook Failed:'..key)
		end
	end
	--
	if inGame then
		-- Kill PocoHud on restart
		hook( GamePlayCentralManager, 'restart_the_game', function( self ,...)
			me:onDestroy(gameEnd)
			me.Toggle()
			Run('restart_the_game', self,... )
		end)

		--PlayerStandard
		hook( PlayerStandard, '_get_input', function( self ,...)
			return me.menuGui and {} or Run('_get_input', self,... )
		end)
		hook( PlayerStandard, '_determine_move_direction', function( self ,...)
			Run('_determine_move_direction', self,... )
			if O:get('root','pocoRoseHalt') and me.menuGui then
				self._move_dir = nil
				self._normal_move_dir = nil
			end
		end)

		--[[hook( PlayerStandard, '_update_check_actions', function( self ,...)
			if not me.menuGui then
				Run('_update_check_actions', self,... )
			end
		end)]]

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
			multiplier = multiplier * managers.player:upgrade_value( 'weapon', 'swap_speed_multiplier', 1 )
				* managers.player:upgrade_value( 'weapon', 'passive_swap_speed_multiplier', 1 )
				* managers.player:upgrade_value( altTD[ 'category' ], 'swap_speed_multiplier', 1 )

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
		local _tempStanceDisable
		local _matchStance = function(tempDisable)
			local r,err = pcall(function()
				_tempStanceDisable = tempDisable
				local crook = O:get('game','cantedSightCrook') or 0
				local state = _.g('managers.player:player_unit():movement():current_state()')
				if crook>1 and state and state._stance_entered then
					state:_stance_entered()
				end
				_tempStanceDisable = nil
			end)
			if not r then me:err(_.s('MatchStance:',err)) end
		end
		hook( PlayerStandard, '_start_action_equip_weapon', function( self,t )
			Run('_start_action_equip_weapon', self, t)
			if O:get('game','rememberGadgetState') then
				local wb = self._equipped_unit:base()
				if wb and me.gadget and me.gadget[wb._name_id] then
					if me.gadget[wb._name_id] > 0 then
						wb:set_gadget_on(me.gadget[wb._name_id] )

						local on = true or wb and wb.is_second_sight_on and wb:is_second_sight_on()
						if on then
							managers.enemy:add_delayed_clbk('gadget', function() _matchStance() end, now(1) + 0.01)
						end
					end
				end
			end
		end)
		hook( PlayerStandard, '_check_action_primary_attack', function( self, t, ... )
			local input = unpack{...}

			-- StickyInteraction trigger
			local lastInteractionStart, lastClick = me._lastInteractStart or 0, me._lastClick or 0
			if input.btn_steelsight_press and O:get('game','interactionClickStick') and self:_interacting() then
				if lastInteractionStart < lastClick then
					me._lastClick = 0
					self:_interupt_action_interact()
				else
					me._lastClick = t
				end
			end

			local result = Run('_check_action_primary_attack', self, t, ...)
				-- capture TriggerHappy
				local weap_base = self._equipped_unit:base()
				local weapon_category = weap_base:weapon_tweak_data().category
				if managers.player:has_category_upgrade(weapon_category, "stacking_hit_damage_multiplier") then
					local stack = self._state_data and self._state_data.stacking_dmg_mul and self._state_data.stacking_dmg_mul[weapon_category]
					if stack and stack[1] and t < stack[1] then
						local mul = 1 + managers.player:upgrade_value(weapon_category, "stacking_hit_damage_multiplier") * stack[2]
						me:Buff({
							key='triggerHappy', good=true,
							icon=skillIcon, iconRect = {7*64, 11*64, 64, 64},
							text=_.f(mul)..'x',
							st=t, et=stack[1]
						})
					else
						me:RemoveBuff('triggerHappy')
					end
				end
			return result
		end)

		hook( PlayerStandard, '_do_melee_damage', function( self, t, ... )
			local result = Run('_do_melee_damage', self, t, ...)

			-- capture Close Combat
			if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
				local stack = self._state_data.stacking_dmg_mul.melee
				if stack and stack[1] and t < stack[1] then
					local mul = 1 + managers.player:upgrade_value("melee", "stacking_hit_damage_multiplier") * stack[2]
					me:Buff({
						key='triggerHappy', good=true,
						icon=skillIcon, iconRect = {4*64, 0*64, 64, 64},
						text=_.f(mul)..'x',
						st=t, et=stack[1]
					})
				else
					me:RemoveBuff('triggerHappy')
				end

			end
		end)


		hook( FPCameraPlayerBase, 'clbk_stance_entered', function( ... )
			local self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration = unpack{...}
			local r,err = pcall(function()
				local crook = O:get('game','cantedSightCrook') or 0
				if crook > 1 and not _tempStanceDisable then
					local state = managers.player:player_unit():movement():current_state()
					local wb = state._equipped_unit and state._equipped_unit:base()
					local second_sight_on = wb and wb.is_second_sight_on and wb:is_second_sight_on()
					local category = wb:weapon_tweak_data().category
					if second_sight_on and not (state:_is_meleeing() or state:in_steelsight()) and category == 'snp' then
						local sMod = wb.stance_mod and wb:stance_mod()
						if crook == 2 then
							stance_mod.rotation = Rotation(0,0,-7)
						elseif crook == 3 then
							stance_mod.rotation = Rotation(0,0,-15)
						elseif crook == 4 and sMod then
							local translation = stance_mod.translation or Vector3()
							local rotation = stance_mod.rotation or Rotation()
							mvector3.add(translation, sMod.translation)
							mvector3.add(translation, Vector3(-10,2,0))
							mrotation.multiply(rotation, sMod.rotation)
							stance_mod.translation = translation
							stance_mod.rotation = rotation
						end
					end
				end
			end)
			if not r then
				me:err(_.s('CBSE',err))
			end
			Run('clbk_stance_entered', self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration)
		end)
		-- PlayerManager
		hook( PlayerManager, 'drop_carry', function( self ,...)
			Run('drop_carry', self,... )
			pcall(me.Buff,me,({
				key='carryDrop', good=false,
				icon=skillIcon, iconRect = {6*64, 0*64, 64, 64},
				text='',
				st=Application:time(), et=managers.player._carry_blocked_cooldown_t
			}) )
		end)
		local rectDict = {}
		-- rectDict.inner-skill-name = {Label, {iconX,iconY}, isPerkIcon, isDebuff }
		rectDict.combat_medic_damage_multiplier = {L('_buff_combatMedicDamageShort'), { 5, 7 }}
		rectDict.no_ammo_cost = {L('_buff_bulletStormShort'),{ 4, 5 }}
		rectDict.berserker_damage_multiplier = {L('_buff_swanSongShort'),{ 5, 12 }}

		rectDict.dmg_multiplier_outnumbered = {L('_buff_underdogShort'),{2,1}}
		rectDict.dmg_dampener_outnumbered = ''-- {'Def+',{2,1}} -- Dupe
		rectDict.dmg_dampener_outnumbered_strong = ''-- {'Def+',{2,1}} -- Dupe
		rectDict.overkill_damage_multiplier = {L('_buff_overkillShort'),{3,2}}
		rectDict.passive_revive_damage_reduction = {L('_buff_painkillerShort'), { 0, 10 }}

		rectDict.first_aid_damage_reduction = {L('_buff_first_aid_damage_reduction_upgrade'),{1,11}}
		rectDict.melee_life_leech = {L('_buff_lifeLeechShort'),{7,4},true,true}
		rectDict.dmg_dampener_close_contact = {L('_buff_first_aid_damage_reduction_upgrade'),{5,4},true}

		local _keys = { -- Better names for Option pnls
			BerserkerDamageMultiplier = 'SwanSong',
			PassiveReviveDamageReduction = 'Painkiller',
			FirstAidDamageReduction = 'FirstAid',
			DmgMultiplierOutnumbered = 'Underdog',
			CombatMedicDamageMultiplier = 'CombatMedic',
			OverkillDamageMultiplier = 'Overkill',
			NoAmmoCost = 'Bulletstorm',
			MeleeLifeLeech = 'LifeLeech',
			DmgDampenerCloseContact = 'CloseCombat'
		}
		hook( PlayerManager, 'activate_temporary_upgrade', function( self, category, upgrade )
			Run('activate_temporary_upgrade',  self, category, upgrade )
			local et = _.g('managers.player._temporary_upgrades.'..category ..'.'..upgrade..'.expire_time')
			if not et then return end
			local rect = rectDict[upgrade]
			if rect and rect ~= '' then
				local rect2 = rect and ({64*rect[2][1],64*rect[2][2],64,64})
				local key = ('_'..upgrade):gsub('_(%U)',function(a) return a:upper() end)
				key = _keys[key] or key
				pcall(me.Buff,me,({
					key=key, good=not rect[4],
					icon=(rect2 and (rect[3] and 'guis/textures/pd2/specialization/icons_atlas' or skillIcon)) or 'guis/textures/pd2/lock_incompatible', iconRect = rect2,
					text=rect and rect[1] or upgrade,
					st=now(), et=et
				}) )
			end
		end)
		hook( PlayerManager, 'activate_temporary_upgrade_by_level', function( self, category, upgrade, level )
			Run('activate_temporary_upgrade_by_level',  self, category, upgrade, level )
			local et = _.g('managers.player._temporary_upgrades.'..category ..'.'..upgrade..'.expire_time')
			if not et then return end
			local rect = rectDict[upgrade]
			if rect ~= '' then
				local rect2 = rect and ({64*rect[2][1],64*rect[2][2],64,64})
				local key = ('_'..upgrade):gsub('_(%U)',function(a) return a:upper() end)
				key = _keys[key] or key
				pcall(me.Buff,me,({
					key=key, good=true,
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

		hook( PlayerStandard, '_interupt_action_interact', function( self, t, input, complete  )
			-- StickyInteraction Execution
			local lastInteractionStart, lastClick = me._lastInteractStart or 0, me._lastClick or 0
			if not t and O:get('game','interactionClickStick') and not complete and (lastInteractionStart < lastClick) then
				local caller = debug.getinfo(3,'n')
				caller = caller and caller.name
				if caller == '_check_action_interact' then
					return -- ignore interruption
				end
			end
			Run('_interupt_action_interact', self, t, input, complete )
			local et = self._equip_weapon_expire_t
			if et then
				me:RemoveBuff('interaction')
				pcall(me.Buff,me,({
					key='transition', good=false,
					icon=skillIcon,
					iconRect = { 4*64, 3*64,64,64 },
					text='',
					st=now(), et=et
				}) )
			end
		end)
		hook( PlayerStandard, 'set_running', function( ... )
			local self, running = unpack{...}
			if not self.RUN_AND_SHOOT and running then
				_matchStance(true)
			end
			Run('set_running', ... )

		end)
		hook( PlayerStandard, '_end_action_running', function( self,t, input, complete  )
			if self._running and not self._end_running_expire_t and not self.RUN_AND_SHOOT then
				_matchStance()
			end
			Run('_end_action_running', self, t, input, complete )
			local et = self._end_running_expire_t
			if not (self.RUN_AND_SHOOT or O:get('buff','noSprintDelay')) and et then
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

		hook( PlayerStandard, '_start_action_interact', function( self, ...  )
			Run('_start_action_interact', self, ...)
			local t, input, timer, interact_object = unpack{...}
			me._lastInteractStart = t
		end)

		hook( PlayerStandard, '_start_action_reload', function( self,t  )
			Run('_start_action_reload', self, t )
			_matchStance(true)
			local et = O:get('buff','showReload') and self._state_data.reload_expire_t
			if et then
				pcall(me.Buff,me,({
					key='reload', good=false,
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
					key='interaction', good=true,
					icon = 'guis/textures/pd2/pd2_waypoints',
					iconRect = {224, 32, 32, 32 },
					--icon = 'guis/textures/hud_icons',
					--iconRect = { 96, 144, 48, 48 },
					text='',
					st=t, et=et
				}) )
			end
		end)
		hook( PlayerStandard, '_update_reload_timers', function( self, t,... )
			Run('_update_reload_timers', self, t,...)
			local et = self._state_data.reload_exit_expire_t
			if et and et > 0 and me.buffs['reload'] then
				me:RemoveBuff('reload')
			end
		end)

		hook( PlayerStandard, '_check_action_weapon_gadget', function( self,...)
			local  t, input = unpack{...}
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
				me:RemoveBuff('reload')
				_matchStance()
			end
			Run('_interupt_action_reload', self, t )
		end)

		hook( StatisticsManager, 'reloaded', function( ... )
			-- To restore stance once reload is done, without too much work
			Run('reloaded', ... )
			_matchStance()
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
					text='',
					st=now(), et=et
				}) )
			end
		end)
		hook( PlayerDamage, '_look_for_friendly_fire', function( self, attacker_unit )
			me._lastAttkUnit = attacker_unit
			return Run('_look_for_friendly_fire', self, attacker_unit)
		end)

		hook( PlayerDamage, 'change_health', function( self, change_of_health, ... )
			local before = self:get_real_health()
			local option = O:get('hit','gainIndicator') or 0
			Run('change_health', self, change_of_health, ... )
			if O:get('hit','enable') and option > 1 then
				-- Skill-originated Health regen
				local after = self:get_real_health()
				local delta = after - before
				if delta > 0 then
					if option > 2 then
						managers.menu_component:post_event("menu_skill_investment")
					end
					me:SimpleFloat{key='health',x=(me.ww or 800)/5*2,y=(me.hh or 600)/4*3,time=3,anim=1,offset={0,-1 * (me.hh or 600)/2},
						text={{'+',cl.White:with_alpha(0.6)},{_.f(delta*10),clGood}},
						size=18, rect=0.5
					}
				end
			end
		end)
		hook( PlayerDamage, 'restore_armor', function( self, regen_armor_bonus, ... )
			local before = self:get_real_armor()
			local option = O:get('hit','gainIndicator') or 0
			Run('restore_armor', self, regen_armor_bonus, ... )
			if O:get('hit','enable') and option > 1 then
				-- Skill-originated Shield regen
				local after = self:get_real_armor()
				local delta = after - before
				if delta > 0 then
					if option > 2 then
						managers.menu_component:post_event("menu_skill_investment")
					end
					me:SimpleFloat{key='armor',x=(me.ww or 800)/5*3,y=(me.hh or 600)/4*3,time=3,anim=1,offset={0,-1 * (me.hh or 600)/2},
						text={{'+',cl.White:with_alpha(0.6)},{_.f(delta*10),clGood}},
						size=18, rect=0.5
					}
				end
			end
		end)

		if O:get('hit','enable') then
			hook( PlayerDamage, '_hit_direction', function( self, col_ray )
				managers.environment_controller._hit_some = math.min(managers.environment_controller._hit_some + managers.environment_controller._hit_amount, 1)
				if not col_ray then
					Run('_hit_direction', self, col_ray)
				end -- Nullify if possible
			end)
			local _hitDirection = function(self,result,data,shield,rate)
				local sd = self._supperssion_data and self._supperssion_data.decay_start_t
				if sd then
					sd = math.max(0,sd-now())
				end
				local et = (self._regenerate_timer or 0)+(sd or 0)
				if et == 0 then
					et = 2 -- Failsafe
				end
				me:HitDirection(data.col_ray,{dmg=result,shield=shield,time=et,rate=rate})
			end
			hook( PlayerDamage, '_calc_armor_damage', function( self, attack_data )
				local valid = self:get_real_armor() > 0
				local result = Run('_calc_armor_damage', self, attack_data)
				if valid then
					_hitDirection(self,result,attack_data,true,self:get_real_armor() / self:_total_armor() )
				end
				return result
			end)
			hook( PlayerDamage, '_calc_health_damage', function( self, attack_data )
				local result = Run('_calc_health_damage', self, attack_data)
				if result > 0 then
					_hitDirection(self,result,attack_data,false,self:health_ratio())
				end
				return result
			end)
		end

		hook( PlayerDamage, 'consume_messiah_charge', function( self)
			local result = Run('consume_messiah_charge', self)
			if result then
				me:Chat('messiah',L('_msg_usedPistolMessiah',{L('_msg_usedPistolMessiahCharges'..(self._messiah_charges>1 and 'Plu' or ''),{self._messiah_charges})}))
			end
			return result
		end)

		--UnitNetwork
		hook( UnitNetworkHandler, 'long_dis_interaction', function( ... )
			local self, target_unit, amount, aggressor_unit  = unpack{...}
			local pid = me:_pid(target_unit)
			local pidA = me:_pid(aggressor_unit)
			if amount == 1 and pid and pid>0 then -- 3rd Person to me.
				me:Stat(pid,'boost',now() + tweak_data.upgrades.morale_boost_time)
			end
			return Run('long_dis_interaction',...)
		end)
		hook( BaseNetworkSession, 'send_to_peer', function( ... ) -- To capture boost
			local self, peer, fname, target_unit, amount, aggressor_unit = unpack{...}
			if fname == 'long_dis_interaction' and amount == 1 then
				local pid = me:_pid(target_unit)
				if pid then -- 3rd Person to Someone
					me:Stat(pid,'boost',now() + tweak_data.upgrades.morale_boost_time)
				end
			end
			return Run('send_to_peer',...)
		end)
		hook( UnitNetworkHandler, 'damage_bullet', function( ... )
			local self,subject_unit, attacker_unit, damage, i_body, height_offset, death, sender = unpack{...}
			local head = i_body and alive(subject_unit) and subject_unit:character_damage().is_head and subject_unit:character_damage():is_head(subject_unit:body(i_body))
			me:AddDmgPopByUnit(attacker_unit,subject_unit,height_offset,damage*-0.1953125,death,head,'bullet')
			return Run('damage_bullet',...)
		end)
		hook( UnitNetworkHandler, 'damage_explosion_fire', function(...)
			local self, subject_unit, attacker_unit, damage, i_attack_variant, death, direction, sender = unpack{...}

			local realAttacker = attacker_unit
			if realAttacker and alive(realAttacker) and realAttacker:base()._thrower_unit then
				realAttacker = realAttacker:base()._thrower_unit
			end

			me:AddDmgPopByUnit(realAttacker,subject_unit,0,damage*-0.1953125,death,false,'bullet')
			return Run('damage_explosion_fire', ... )
		end)
		hook( UnitNetworkHandler, 'damage_fire', function(...)
			local self, subject_unit, attacker_unit, damage, death, direction, weapon_type, weapon_unit, sender = unpack{...}

			local realAttacker = attacker_unit
			if realAttacker and alive(realAttacker) and realAttacker:base()._thrower_unit then
				realAttacker = realAttacker:base()._thrower_unit
			end

			me:AddDmgPopByUnit(realAttacker,subject_unit,0,damage*-0.1953125,death,false,'explosion')
			return Run('damage_fire', ... )
		end)
		hook( UnitNetworkHandler, 'damage_melee', function(...)
			local self, subject_unit, attacker_unit, damage, damage_effect, i_body, height_offset, variant, death, sender  = unpack{...}
			local head = i_body and alive(subject_unit) and subject_unit:character_damage().is_head and subject_unit:character_damage():is_head(subject_unit:body(i_body))
			me:AddDmgPopByUnit(attacker_unit,subject_unit,height_offset,damage*-0.1953125,death,head,'melee')
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
					local realAttacker = info.attacker_unit
					if alive(realAttacker) and realAttacker:base()._thrower_unit then
						realAttacker = realAttacker:base()._thrower_unit
					end
					me:AddDmgPop(realAttacker,hitPos,self._unit,0,info.damage,self._dead,head,info.variant)
				end
			end
			return result
		end)
		--CopMovement
		hook( CopMovement, 'action_request', function( ...  )
			local self, action_desc = unpack{...}
			local dmgTime = O:get('popup','damageDecay')
			if action_desc.variant == 'hands_up' and O:get('popup','handsUp') and O:get('popup','enable') then
				me:Popup({pos=me:_pos(self._unit),text={{'Hands-Up',cl.White}},stay=false,et=now()+dmgTime})
			elseif action_desc.variant == 'tied' and O:get('popup','dominated') and O:get('popup','enable') then
				if not managers.enemy:is_civilian( self._unit ) then
					me:Popup({pos=me:_pos(self._unit),text={{'Intimidated',cl.White}},stay=false,et=now()+dmgTime})
					me:Chat('dominated',L('_msg_captured',{me:_name(self._unit),me:_name(me:_pos(self._unit))}))
				end
			end
			if action_desc.type=='act' and action_desc.variant then
				--me:Popup({pos=me:_pos(self._unit),text={{action_desc.variant,Color.white}},stay=true,et=now()+dmgTime})
			end
			return Run('action_request', ... )
		end)

		--ETC
		hook( HUDManager, 'show_endscreen_hud', function( self )
			Run('show_endscreen_hud', self )
			me:_show(false,true)
		end)
		hook( HUDManager, 'set_disabled', function( self )
			Run('set_disabled', self )
			me:_show(false)
		end)
		hook( HUDManager, 'set_enabled', function( self )
			Run('set_enabled', self )
			me:_show(true)
		end)

		hook( ECMJammerBase, 'set_active', function( self, active )
			Run('set_active', self, active )
			local et = self:battery_life() + now()
			if active and (me._lastECM or 0 < et)then
				me._lastECM = et
				pcall(me.Buff,me,({
					key='ECM', good=true,
					icon=skillIcon,
					iconRect = { 1*64, 4*64,64,64 },
					text='',
					st=now(), et=et
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
			local tape_loop_t = unpack{...}
			Run('_start_tape_loop', self, ... )
			local et = tape_loop_t+6
			if et then
				pcall(me.Buff,me,({
					key='tapeLoop', good=true,
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
		hook( UnitNetworkHandler, 'mark_minion', function( self,  ... )
			local unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender = unpack{...}
			Run('mark_minion', self, ... )
			me:Minion(minion_owner_peer_id,unit)
		end)
		hook( ChatManager, '_receive_message', function( self, ... )
			local channel_id, name, message, color, icon = unpack{...}
			me:_processMsg(channel_id,name,message,color)
			return Run('_receive_message', self,  ...)
		end)
		-- CriminalDown
		hook( HUDManager, 'remove_teammate_panel', function( self, ... )
			local id = unpack{...}
			-- nothing
			return Run('remove_teammate_panel', self, ... )
		end)

		hook( HUDManager, 'add_teammate_panel', function( self, ... )
			local character_name, player_name, ai, peer_id = unpack{...}
			if peer_id then
				if me:Stat(peer_id,'name') ~= player_name then
					me:Stat(peer_id,'name',player_name)
					me:Stat(peer_id,'time',now())
					me:Stat(peer_id,'health',0)
					me:Stat(peer_id,'hit',0)
					me:Stat(peer_id,'head',0)
					me:Stat(peer_id,'dmg',0)
					me:Stat(peer_id,'shot',0)
					me:Stat(peer_id,'kill',0)
					me:Stat(peer_id,'killS',0)
					me:Stat(peer_id,'down',0)
					me:Stat(peer_id,'downAll',0)
					me:Stat(peer_id,'minion',0)
					me:Stat(peer_id,'custody',0)
				end
			end
			return Run('add_teammate_panel', self, ... )
		end)


		local onReplenish = function(pid,noReset)
			if (now()-(self._startGameT or now()) < 1) then return end
			local bHealth = self:Stat(pid,'bHealth')
			self:Stat(pid,'bHealth',-1)
			local bPercent = bHealth > 0 and bHealth or self:Stat(pid,'health') or 0
			local down = not noReset and self:Stat(pid,'down') or 0
			local downStr = down>0 and L('_msg_replenishedDown'..(down>1 and 'Plu' or ''),{down}) or ''
			self:Chat('replenished',L('_msg_repenished',{self:_name(pid),_.f(100-bPercent), downStr}))
			if not noReset then -- reset down cnt
				self:Stat(pid,'downAll',self:Stat(pid,'down'),true)
				self:Stat(pid,'down',0)
			end
		end

		hook( HUDManager, 'set_teammate_health', function( ... ) -- stash health
			local self, i, data = unpack{...}
			local pid
			if i == 4 then
				pid = me.pid
			else
				for __, data in pairs( managers.criminals._characters ) do
					if data.taken and i == data.data.panel_id then
						pid = data.peer_id
					end
				end
			end
			if pid then
				local bPercent = me:Stat(pid,'health')
				local percent = (pid==me.pid and data.current/data.total or data.current)*100 or 0
				if percent ~= 0 and bPercent == 0 then
					me:Stat(pid,'custody',0)
					me:Stat(pid,'_refreshBtm',1) -- Refresh btm when out of custody
				elseif bPercent < percent then
					me:Stat(pid,'bHealth',bPercent)
				end
				me:Stat(pid,'health',percent)
			end
			return Run('set_teammate_health', ...)
		end)

		-- 1. Kit
		hook( FirstAidKitBase, 'take', function( self, ... )
			onReplenish(me.pid,true)
			return Run('take',self,...)
		end)
		hook( FirstAidKitBase, 'sync_net_event', function( self, ... )
			local event_id, peer = unpack{...}
			if event_id == 2 and peer then
				onReplenish(peer:id(),true)
			end
			return Run('sync_net_event',self,...)
		end)

		-- 2. Med
		hook( DoctorBagBase, 'take*', function( self, ... )
			onReplenish(me.pid)
			return Run('take*',self,...)
		end)
		hook( UnitNetworkHandler, 'sync_doctor_bag_taken', function( self, ... )
			local unit, amount, sender = unpack{...}
			local peer = self._verify_sender(sender)
			local pid = peer and peer:id()
			if pid then
				onReplenish(pid)
			end
			return Run('sync_doctor_bag_taken',self,...)
		end)


		--[[local OnCriminalHealth = function(pid,data)
			local percent = (pid==self.pid and data.current/data.total or data.current)*100 or 0
			local bPercent = self:Stat(pid,'health') or 0
			local down = self:Stat(pid,'down') or 0
			if percent>= 99.8 and percent - bPercent > 2 then
				if bPercent ~= 0 and self:_name(pid) ~= self:_name(-1) and (now()-(self._startGameT or now()) > 1) then
					self:Chat('replenished',L('_msg_repenished',{self:_name(pid),_.f(percent-bPercent), down>0 and L('_msg_replenishedDown'..(down>1 and 'Plu' or ''),{down}) or ''}))
				elseif bPercent == 0 then
					self:Stat(pid,'_refreshBtm',1)
				end
				self:Stat(pid,'custody',0)
				self:Stat(pid,'downAll',self:Stat(pid,'down'),true)
				self:Stat(pid,'down',0)
			end
			self:Stat(pid,'health',percent)
		end
		hook( HUDManager, 'set_teammate_health', function( ... )
			local self, i, data = unpack{...}
			local pid
			if i == 4 then
				pid = me.pid
			else
				for __, data in pairs( managers.criminals._characters ) do
					if data.taken and i == data.data.panel_id then
						pid = data.peer_id
					end
				end
			end
			if pid then
				OnCriminalHealth(pid,data)
			end
			return Run('set_teammate_health', ...)
		end)]]
		local OnCriminalDowned = function(pid)
			self:Stat(pid,'down',1,true)
			if (self:Stat(pid,'down') or 0) >= 3 then
				self:Chat('downedWarning',L('_msg_downedWarning',{me:_name(pid),me:Stat(pid,'down')}))
			else
				self:Chat('downed',L('_msg_downed',{me:_name(pid)}))
			end
		end
		hook( PlayerBleedOut, '_enter', function( self, ... )
			OnCriminalDowned(me.pid)
			return Run('_enter', self,  ...)
		end)

		hook( CopActionWalk, '_get_current_max_walk_speed', function( self, ... )
			local coeff = Network:is_server() and 1 or math.max(1,math.min( O:get('game','fasterAIDesyncResolve'), 1.5))
			return Run('_get_current_max_walk_speed', self,  ...) * coeff
			-- Faster Desync resolve for Husk cops
		end)
		hook( HuskPlayerMovement, '_get_max_move_speed', function( self, ... )
			return Run('_get_max_move_speed', self,  ...) * math.max(1,O:get('game','fasterDesyncResolve'))
			-- because of this, husk players will catch up de-sync waaay easily, representing their position more accurate.
			-- If a host uses this, better stealth experience for all clients guaranteed. Now skill matters, instead of lag. :)
			-- This does not make them actually move 3 times faster. This only kick in after severe desync.
		end)
		hook( HuskPlayerMovement, '_start_bleedout', function( self, ... )
			local pid = me:_pid(self._unit)
			if pid then
				OnCriminalDowned(pid)
			end
			return Run('_start_bleedout', self,  ...)
		end)
		hook( getmetatable(managers.subtitle.__presenter), 'show_text', function( self, ... )
			local text, duration = unpack{...}
			local label = self.__subtitle_panel:child('label')
			local shadow = self.__subtitle_panel:child('shadow')
			local gameO = O:get('game')
			local apply = function()
				self._fontSize = gameO.subtitleFontSize
				self._fontColor = gameO.subtitleFontColor:with_alpha(gameO.subtitleOpacity/100)
			end
			if label then
				if self._fontSize ~= gameO.subtitleFontSize then
					apply()
					label:set_font_size(self._fontSize)
					shadow:set_font_size(self._fontSize)
				end
				if self._fontColor ~= gameO.subtitleFontColor then
					apply()
					label:set_color(self._fontColor)
				end
			else
				apply()
				label = self.__subtitle_panel:text({
					name = 'label',
					x = 1,
					y = 1,
					font = self.__font_name,
					font_size = self._fontSize,
					color = self._fontColor,
					align = 'center',
					vertical = 'bottom',
					layer = 1,
					wrap = true,
					word_wrap = true
				})
				shadow = self.__subtitle_panel:text({
					name = 'shadow',
					x = 2,
					y = 2,
					font = self.__font_name,
					font_size = self._fontSize,
					color = cl.Black:with_alpha(0.008*gameO.subtitleOpacity),
					align = 'center',
					vertical = 'bottom',
					layer = 0,
					wrap = true,
					word_wrap = true
				})
			end
			label:set_text(text)
			shadow:set_text(text)
		end)

		-- Criminal Custody
		local OnCriminalCustody = function(criminal_name)
			local pid
			for __, data in pairs( managers.criminals._characters ) do
				if data.taken and criminal_name == data.name then
					pid = data.peer_id
				end
			end
			if pid and self:Stat(pid,'custody') == 0 then
				self:Stat(pid,'downAll',self:Stat(pid,'down'),true)
				self:Stat(pid,'down',0)
				self:Stat(pid,'custody',1)
				self:Stat(pid,'room','in custody')
				self:Stat(pid,'health',0)
				self:Chat('custody',managers.localization:text('hint_teammate_dead',{TEAMMATE=self:_name(pid)}))
			end
		end
		hook( UnitNetworkHandler, 'set_trade_death', function( ... )
			local self, criminal_name, respawn_penalty, hostages_killed = unpack{...}
			OnCriminalCustody(criminal_name)
			return Run('set_trade_death', ...)
		end)
		hook( TradeManager, 'on_player_criminal_death', function( ... )
			local self, criminal_name, respawn_penalty, hostages_killed, skip_netsend = unpack{...}
			OnCriminalCustody(criminal_name)
			return Run('on_player_criminal_death', ...)
		end)
		-- TimerGUI
		hook( TimerGui, 'update', function( ... )
			local self, unit, t, dt = unpack{...}
			local result = Run('update', ...)
			me:Float(unit,1)
			return result
		end)
		hook( DigitalGui, 'update*', function( ... )
			local self, unit, t, dt = unpack{...}
			local result = Run('update*', ...)
			if self:is_timer() then
				me:Float(unit,1)
			end
			return result
		end)
		-- Spot
		hook( ContourExt, 'add', function( ... )
			local self, type, sync, multiplier = unpack{...}
			local result = Run('add', ...)
			if O:get('float','showHighlighted') and not (type == 'teammate') then
				local unit = self._unit -- TODO: compare this to filter Floats as Config
				local tweak = unit and unit:interaction() and unit:interaction().tweak_data
				local isPager = tweak == 'corpse_alarm_pager'
				me:Float(unit,0,result and result.fadeout_t or now()+(isPager and 12 or 4))
			end
			return result
		end)
		hook( ContourExt, '_upd_color', function( ... )
			local self = unpack{...}
			local idstr_contour_color = Idstring( 'contour_color' )
			local minionClr = false
			Run('_upd_color', ...)
			if O:get('float','showConvertedEnemy') then
			for i = 1, 4 do
				if not minionClr and me:Stat(i,'minion')==self._unit then
					minionClr = me:_color(i)
				end
			end
			if minionClr then
				for __, material in ipairs( self._materials or {}) do
						material:set_variable( idstr_contour_color, Vector3(minionClr.r,minionClr.g,minionClr.b)/4)
				end
			end
			end
		end)
		-- Pager
		hook( CopBrain, 'clbk_alarm_pager', function( ... )
			local self = unpack{...}
			Run('clbk_alarm_pager', ...)
			if self._unit:interaction().tweak_data == 'corpse_alarm_pager' and self._unit:interaction()._active then
				local pagerData = self._alarm_pager_data
				if pagerData and pagerData.nr_calls_made == 1 then
					local cbkID = pagerData.pager_clbk_id
					local t, cbk = me:_getDelayedCbk(cbkID)
					self._unit:interaction()._pagerT = (t or 0)*2
					self._unit:interaction()._pager = now()
				end
			end
		end)
		-- Ragdoll length
		hook( EnemyManager, 'add_delayed_clbk', function( ... )
			local self, id, clbk, execute_t = unpack{...}
			local isWhisper = managers.groupai:state():whisper_mode()

			if id and id:find('freeze_rag') and not isWhisper then
				local t = (O:get('game','corpseRagdollTimeout') or 3) - 3
				execute_t = execute_t + t
			end
			return Run('add_delayed_clbk', self, id, clbk, execute_t )
		end)
		-- AmmoUsage
		hook( HUDTeammate, 'set_ammo_amount_by_type', function( ... )
			local self, type, max_clip, current_clip, current_left, max = unpack{...}
			local result = Run('set_ammo_amount_by_type', ...)
			local out_of_ammo_clip = current_clip <= 0
			local pid = self:peer_id() or me.pid
			local lc = self['_last_clip_'..type] or 0
			if current_left < lc then
				me:Stat(pid,'shot',lc - current_left,true)
			end
			self['_last_clip_'..type] = current_left
			return result
		end)

		-- Interaction timers
		hook( HUDInteraction, 'set_interaction_bar_width', function( ... ) -- Local
			local self, current, total = unpack{...}
			if me:Stat(me.pid,'interactET') == 0 then
				me:Stat(me.pid,'interactST',now())
				me:Stat(me.pid,'interactET',now()+total)
			end
			local lastInteractionStart, lastClick = me._lastInteractStart or 0, me._lastClick or 0
			local sticky = O:get('game','interactionClickStick') and (lastInteractionStart < lastClick)
			if self._interact_circle and self.__lastSticky ~= sticky then
				local img = sticky and 'guis/textures/pd2/hud_progress_invalid' or 'guis/textures/pd2/hud_progress_bg'

				local anim_func = function(o)
					while alive(o) and sticky do
						over(0.75, function(p)
							o:set_alpha(math.sin(p * 180) * 0.5 )
						end)
					end
				end

				local bg = self._interact_circle._bg_circle
				if bg and alive(bg) then
					bg:stop()
					bg:animate(anim_func)
					bg:set_image(img)
				end

				self.__lastSticky = sticky
			end

			Run('set_interaction_bar_width',...)
		end)
		hook( HUDInteraction, 'hide_interaction_bar', function( ... ) -- Local
			me:Stat(me.pid,'interactST',0)
			me:Stat(me.pid,'interactET',0)
			Run('hide_interaction_bar',...)
		end)

		hook( HUDManager, 'teammate_progress', function( ... ) -- Remote
			local self, peer_id, type_index, enabled, tweak_data_id, timer, success = unpack{...}
			if enabled then
				me:Stat(peer_id,'interactST',now())
				me:Stat(peer_id,'interactET',now()+timer)
			else
				me:Stat(peer_id,'interactST',0)
				me:Stat(peer_id,'interactET',0)
			end
			return Run('teammate_progress', ...)
		end)

		-- Joining
		hook( MenuManager, 'show_person_joining', function( ... )
			local self, id, nick = unpack{...}
			self['_joinT_'..id] = os.clock()
			local result = Run('show_person_joining', ...)
			if O:get('game','ingameJoinRemaining') then
				local peer = managers.network:session():peer(id)
				if peer and 0 < peer:rank() then
					managers.hud:post_event('infamous_player_join_stinger')
					local dlg = managers.system_menu:get_dialog('user_dropin' .. id)
					if dlg then
						local name = peer:level()..' '..string.upper(nick)
						if peer:rank()>0 then
							name = peer:rank()..'-'..name
						end
						dlg:set_title(_.s(
							managers.localization:text('dialog_dropin_title', {	USER = name	})
							))
					end
				end
			end

			return result
		end)
		hook( MenuManager, 'update_person_joining', function( ... )
			local self, id, progress_percentage = unpack{...}
			local joinT = self['_joinT_'..id] or os.clock()
			local dT,per = os.clock()-joinT, math.max(1,progress_percentage)
			local tT = dT/per*100
			Run('update_person_joining', ...)
			if O:get('game','ingameJoinRemaining') then
				local dlg = managers.system_menu:get_dialog('user_dropin' .. id)
				if dlg then
					dlg:set_text(_.s(
						managers.localization:text('dialog_wait'), progress_percentage..'%',
						tT-dT,'s left'
						))
				end
			end
		end)
		-- Hide interaction circle
		if O:get('buff','hideInteractionCircle') then
			hook( HUDInteraction, 'show_interaction_bar', function( ... )
				local self, current, total = unpack{...}
				Run('show_interaction_bar', ...)
				self._interact_circle:set_visible(false)
			end)
			hook( HUDInteraction, '_animate_interaction_complete', function( ... )
				local self, bitmap, circle  = unpack{...}
				bitmap:parent():remove( bitmap )
				circle:remove()
				--Run('_animate_interaction_complete', ...)
			end)
		end
		-- Remove ExpCap
		if false then
			hook( HUDStageEndScreen, 'stage_init', function( ... )
				_('stageINITcalled')
				local self, t, dt = unpack{...}
				local _oldLvlCap = managers.experience.reached_level_cap
				managers.experience.reached_level_cap = function(self)
					_('lvlCAPcalled')
					return false
				end
				Run('stage_init', ...)
				managers.experience.reached_level_cap = _oldLvlCap
			end)
		end
		-- Corpse limit
		hook( EnemyManager, '_upd_corpse_disposal', function( ... )
			local self = unpack{...}
			self._MAX_NR_CORPSES = math.pow(2,O:get('game','corpseLimit') or 3)
			Run('_upd_corpse_disposal', ...)
			-- Clean up shields. :p
			local corpses,cnt = self._enemy_data.corpses, 0
			for i,corpse in pairs(corpses or {}) do
				local unit = corpse.unit
				if alive(unit) and unit:base()._tweak_table == 'shield' then
					cnt = cnt + 0
					if cnt > 2 or (now() - corpse.death_t > 10) then
						unit:base():set_slot(unit, 0)
					end
				end
			end
			--
		end)

		-- hostage counter
		hook( HUDAssaultCorner, 'set_control_info', function( self ,...)
			local data = unpack{...}
			Run('set_control_info', self,... )
			if data and data.nr_hostages then
				me._nr_hostages = data.nr_hostages
			end
		end)

	else -- if outGame

	end -- End of if inGame

	-- Global Romanic Rank
	hook( ExperienceManager , 'rank_string', function( ... )
		local self, rank = unpack{...}
		if O:get('game','romanInfamy') then
			return me:_romanic_number(rank)
		else
			return rank
		end
	end)

	-- Kick menu
	if O:get('game','showRankInKickMenu') then
		hook( KickPlayer, 'modify_node', function( ... )
			local self, node, up = unpack{...}
			local new_node = deep_clone( node )
			if managers.network:session() then
				for __,peer in pairs( managers.network:session():peers() ) do
					local rank = peer:rank()
					local params = {
									name			= peer:name(),
									text_id			= _.s((rank and rank..'-' or '')..(peer:level() or '?'),peer:name()),
									callback		= 'kick_player',
									to_upper		= false,
									localize		= 'false',
									rpc				= peer:rpc(),
									peer			= peer,
									}
					local new_item = node:create_item( nil, params )
					new_node:add_item( new_item )
				end
			end
			managers.menu:add_back_button( new_node )
			return new_node
		end)
	end
	-- Mouse hook plugin

	hook( MenuRenderer, 'mouse_moved', function( ... )
		local self, o, x, y = unpack{...}
		if me.menuGui then
			return true
		else
			return Run('mouse_moved', ...)
		end
	end)
	hook( MenuInput, 'mouse_moved*', function( ... )
		local self, o, x, y = unpack{...}
		if me.menuGui then
			if not inGame then
				return me.menuGui:mouse_moved(true, o, x,y)
			else
				return true
			end
		else
			return Run('mouse_moved*', ...)
		end
	end)
	hook( MenuManager, 'toggle_menu_state', function( ... )
		if me.menuGui then
			me:Menu(true) -- dismiss Menu when actual game-menu is called
			if managers.menu:active_menu() then
				managers.menu:active_menu().renderer:disable_input(0.2)
			end

		else
			return Run('toggle_menu_state', ...)
		end
	end)
	hook( MenuInput, 'update**', function( ... )
		if Poco._kbd:pressed(28) and alt() then
			managers.viewport:set_fullscreen(not RenderSettings.fullscreen)
		else
			return Run('update**', ...)
		end
	end)
	if inGame then
		hook( FPCameraPlayerBase, '_update_rot', function( ... )
			if me.menuGui then
				return false
			else
				return Run('_update_rot', ...)
			end
		end)
	end
	-- Music hook
	local ms = _.g('Global.music_manager.source')
	if ms then
		hook( getmetatable(ms), 'set_switch', function( ... )
			local self, type, val = unpack{...}
			if type == 'music_randomizer' then
				me._music_started = managers.localization:text('menu_jukebox_'..val)
			end
			return Run('set_switch', ...)
		end)
	end
	--MusicManager:jukebox_menu_track(name)
	hook( MusicManager, 'jukebox_menu_track', function( ... )
		local result = Run('jukebox_menu_track', ...)
		if result then
			me._music_started = managers.localization:text('menu_jukebox_screen_'..result)
		end
		return result
	end)
	--function LevelsTweakData:get_music_event(stage)
	hook( LevelsTweakData, 'get_music_event', function( ... )
		local result = Run('get_music_event', ...)
		if result and O('root','shuffleMusic') then
			local self,stage = unpack{...}
			if stage == 'control' then
				if self._poco_can_shuffle then
					_.g('managers.music:check_music_switch()')
				else
					self._poco_can_shuffle = 1
				end
			end
		end
		return result
	end)

--- DEBUG ONLY
--------------

	if not inGame then
		--function CrimeNetGui:_create_job_gui(data, type, fixed_x, fixed_y, fixed_location)
		hook( CrimeNetGui, '_create_job_gui', function( ... ) -- Hook crimenet font size & color
			local sizeMul = O('game','resizeCrimenet')
			local colorize = O('game','colorizeCrimenet')

			sizeMul = sizeMul and sizeMul / 10 + 0.5 or 1
			local size = tweak_data.menu.pd2_small_font_size
			tweak_data.menu.pd2_small_font_size = size * sizeMul
			local result = Run('_create_job_gui',...)
			tweak_data.menu.pd2_small_font_size = size
			local self,data = unpack{...}
			if colorize and result.side_panel and result.side_panel:child('job_name') then
				local colors = {cl.Red,cl.PaleGreen,cl.PaleGoldenrod,cl.LavenderBlush,cl.Wheat,cl.Tomato}
				result.side_panel:child('job_name'):set_color(colors[data.difficulty_id] or cl.White)
			end
			if colorize and result.heat_glow then
				result.heat_glow:set_alpha(result.heat_glow:alpha()*0.5)
			end
			return result
		end)

		hook( CrimeNetGui, '_create_locations', function( ... ) -- Hook locations[1]
			local result = Run('_create_locations', ...)
			if O('game','gridCrimenet') then
				local self = unpack{...}
				local newDots = {}
				local xx,yy = 10,10
				for i=1,xx do -- 224~1666 1442
					for j=1,yy do -- 165~945 780
						table.insert(newDots,{ 100+1642*i/xx, 100+680*(i % 2 == 0 and j or j - 0.5)/yy })
					end
				end
				self._locations[1][1].dots = newDots
			end
		end);

		hook( CrimeNetGui, '_get_job_location', function( ... ) -- Hook locations[2]
			if O('game','sortCrimenet') then
				local self,data = unpack{...}
				local diff = (data and data.difficulty_id or 2) - 2
				local diffX = 1800 / 10 * (diff * 2) + 200
				local locations = self:_get_contact_locations()
				local sorted = {}
				for k,dot in pairs(locations[1].dots) do
					if not dot[3] then
						table.insert(sorted,dot)
					end
				end
				if #sorted > 0 then
					local abs = math.abs
					table.sort(sorted,function(a,b)
						return abs(diffX-a[1]) < abs(diffX-b[1])
					end)
					local dot = sorted[1]
					local x,y = dot[1],dot[2]
					local tw = math.max(self._map_panel:child("map"):texture_width(), 1)
					local th = math.max(self._map_panel:child("map"):texture_height(), 1)
					x = math.round(x / tw * self._map_size_w)
					y = math.round(y / th * self._map_size_h)

					return x,y,dot
				else
					return self:_get_random_location() -- just in case of failure
				end
			else
				return Run('_get_job_location', ...)
			end
		end)
	end
end
--- Utility functions ---
function TPocoHud3:toggleVerbose(state)
	if state == 'toggle' then
		self.verbose = not self.verbose
	else
		self.verbose = state
	end
	if self.menuGui and self.menuGui.alt then return end
	if not inGameDeep and self.verbose then
		pcall(function()
			self:Menu()
			if self.menuGui then
				self.menuGui.gui:goTo(3)
			end
		end)
	end
end
function TPocoHud3:test()
-- reserved
	self:Menu()
end

function TPocoHud3:_getAngle(unit)
	if not (unit and type(unit)=='userdata' and alive(unit)) then
		return
	end
	local uPos = unit:position()
	local vec = self.camPos - uPos
	local fwd = self.cam:rotation():y()
	local ang = math.floor( vec:to_polar_with_reference( fwd, math.UP ).spin )
	return -(ang+180)
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

function TPocoHud3:_getDelayedCbk(id)
	local eM = managers.enemy
	local all_clbks = eM and eM._delayed_clbks or {}
	for __, clbk_data in ipairs(all_clbks) do
		if clbk_data[1] == id then
			return (clbk_data[2] or 0)-now(true), clbk_data[3]
		end
	end
end

function TPocoHud3:_lbl(lbl,txts)
	local result = ''
	if not alive(lbl) then
		if type(txts)=='table' then
			for __, t in pairs(txts) do
				result = result .. tostring(t[1])
			end
		else
			result = txts
		end
	else
		if type(txts)=='table' then
			local pos = 0
			local posEnd = 0
			local ranges = {}
			for _k,txtObj in ipairs(txts or {}) do
				txtObj[1] = tostring(txtObj[1])
				result = result..txtObj[1]
				local __, count = txtObj[1]:gsub('[^\128-\193]', '')
				posEnd = pos + count
				table.insert(ranges,{pos,posEnd,txtObj[2] or cl.White})
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
	end
	return result
end
function TPocoHud3:_drawRow(pnl, fontSize, texts, _x, _y, _w, bg, align, lineHeight)
	local _fontSize = fontSize * (lineHeight or 1.1)
	if bg then
		pnl:rect( { x=_x,y=_y,w=_w,h=_fontSize,color=cl.White, alpha=0.05, layer=0 } )
	end
	local count = #texts
	local iw = _w / count
	local isCenter = function(i)
		return align == true or (type(align)=='table' and align[i]~=0)
	end
	for i,text in pairs(texts) do
		if text and text ~= '' then
			if (type(text)=='table' or type(text)=='userdata') and text.set_y then
				text:set_y(_y)
				if isCenter(i) then
					text:set_center_x(math.round(_x + iw*(i-0.5)))
				else
					text:set_x(math.round(_x+iw*(i-1)))
				end
			else
				local res, lbl = _.l({ pnl=pnl,font=FONT, color=cl.White, font_size=fontSize, x=_x + iw*(i-0.5), y=math.floor(_y), w = iw, h = _fontSize, text='', align = isCenter(i) and 'center', vertical = 'center', blend_mode='add'},text,not isCenter(i))
				lbl:set_x(math.round(_x+iw*(i-1)))
				--[[if isCenter(i) then
					lbl:set_center_x(math.round(_x + iw*(i-0.5)))
				end]]

			end
		end
	end
	return _y + _fontSize
end
--- Class end ---
PocoHud3 = PocoHud3
TPocoHud3.Toggle = function()
	me = Poco:AddOn(TPocoHud3)
	if me and not me.dead then
		PocoHud3 = me
	else
		PocoHud3 = true
	end
	PocoHud3Class.loadVar(O,me,L)
end
if Poco and not Poco.dead then
	TPocoHud3.Toggle()
else
	managers.menu_component:post_event( 'zoom_out')
end