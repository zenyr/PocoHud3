---
local ALTFONT = 'fonts/font_eroded'
local FONT =  'fonts/font_medium_mf' -- or tweak_data.hud_present.title_font or tweak_data.hud_players.name_font or "fonts/font_eroded" or 'core/fonts/system_font'
local FONTLARGE = 'fonts/font_large_mf'
local clGood =  cl.YellowGreen
local clBad =  cl.Gold
local Icon = {
	A=57344, B=57345,	X=57346, Y=57347, Back=57348, Start=57349,
	Skull = 57364, Ghost = 57363, Dot = 1031, Chapter = 1015, Div = 1014, BigDot = 1012,
	Times = 215, Divided = 247, LC=139, RC=155, Deg = 1024, PM= 1025, No = 1033,
}
for k,v in pairs(Icon) do
	Icon[k] = utf8.char(v)
end
local now = function () return managers.player:player_timer():time() --[[TimerManager:game():time()]] end
local PocoEvent = {
	In = 'onEnter',
	Out = 'onExit',
	Pressed = 'onPressed',
	Released = 'onReleased',
	PressedAlt = 'onPressedAlt',
	ReleasedAlt = 'onReleasedAlt',
	WheelUp = 'onWheelUp',
	WheelDown = 'onWheelDown',
	Move = 'onMove',
}
local O, me
PocoHud3Class = {
	ALTFONT	= ALTFONT	,
	FONT		= FONT		,
	FONTLARGE = FONTLARGE,
	clGood	= clGood	,
	clBad		= clBad		,
	Icon		= Icon		,
	PocoEvent = PocoEvent,
}
PocoHud3Class.loadVar = function(_O,_me)
	O = _O
	me = _me
end

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
	local simple = self.owner:_isSimple(data.key)
	self.created = true
	if simple then
		local simpleRadius = O.buff.simpleBusyRadius
		local pnl = self.ppnl:panel({x = self.owner.ww/2-simpleRadius,y=self.owner.hh/2-simpleRadius, w=simpleRadius*2,h=simpleRadius*2})
		self.pnl = pnl
		local texture = data.good and "guis/textures/pd2/hud_progress_active" or "guis/textures/pd2/hud_progress_invalid"
		self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = texture, radius = simpleRadius, sides = 64, current = 20, total = 64, blend_mode = "add", layer = 0} )
	elseif style == 2 then
		local pnl = self.ppnl:panel({x = 0,y=0, w=100,h=100})
		self.pnl = pnl
		self.lbl = pnl:text{text='', font=FONT, align='center', font_size = size/2, color = data.color or data.good and clGood or clBad, x=1,y=1, layer=2, blend_mode = 'normal'}
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
		local simple = self.owner:_isSimple(data.key)
		if (prog >= 1 or prog < 0) and et ~= 1 then
			self.dead = true
		elseif alive(self.pnl) then
			if et == 1 then
				prog = st
			end
			x = self.x and self.x + (x-self.x)/5 or x
			y = self.y and self.y + (y-self.y)/5 or y
			if not simple then
				self.pnl:set_center(x,y)
			end
			self.x = x
			self.y = y
			local txts
			if simple then

			elseif vanilla then
				local sTxt = self.owner:_lbl(nil,data.text)
				if et == 1 then -- Special
					sTxt = sTxt ~= '' and (sTxt or ''):gsub(' ','\n') or  _.f(prog*100,1)..'%'
				else
					sTxt = _.f(et-now(),1)..'s'
				end
				txts = {{sTxt,cl.White}}
			else
				if type(data.text)=='table' then
					txts = data.text
				else
					txts = {{data.text or '',data.color}}
					table.insert(txts,{_.f(et ~= 1 and et-now() or prog*100)..(et == 1 and '%' or 's'),data.good and clGood or clBad})
				end
			end
			if not simple then
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
				mvector3.set_y(pPos,pPos.y - math.lerp(100,0, math.pow(1-prog,7)))
			end

			if prog >= 1 then
				self.dead = true
			else
				local dx,dy,d,ww,hh = 0,0,1,self.owner.ww,self.owner.hh
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
	self.tag = data.tag or {}
	self.temp = data.temp
	self.lastT = type(self.temp) == 'number' and self.temp or now()
	self.ppnl = owner.pnl.pop
	self:_make()
end
function TFloat:__shadow(x)
	if x then
		self.lblShadow1:set_x(x+1)
		self.lblShadow2:set_x(x-1)
	else
		self.lblShadow1:set_text(self._txts)
		self.lblShadow2:set_text(self._txts)
	end
end
function TFloat:_make()
	local size = O.float.size
	local m = O.float.margin
	local pnl = self.ppnl:panel({x = 0,y=-size, w=300,h=100})
	local texture = 'guis/textures/pd2/hud_health' or 'guis/textures/pd2/hud_progress_32px'
	self.pnl = pnl
	self.bg = O.float.border
		and HUDBGBox_create(pnl, {x= 0,y= 0,w= 1,h= 1},{color=cl.White:with_alpha(1)})
		or pnl:bitmap( { name='blur', texture="guis/textures/test_blur_df", render_template="VertexColorTexturedBlur3D", layer=-1, x=0,y=0 } )
	self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=m,y=m,image = texture, radius = size/2, sides = 64, current = 20, total = 64, blend_mode = 'normal', layer = 4} )
	self.pieBg = pnl:bitmap( { name='pieBg', texture='guis/textures/pd2/hud_progress_active', w = size, h = size, layer=3, x=m,y=m, color=cl.Black:with_alpha(0.5) } )
	self.lbl = pnl:text{text='text', font=FONT, font_size = size, color = cl.White, x=size+m*2,y=m, layer=3, blend_mode = 'normal'}
	self.lblShadow1 = pnl:text{text='shadow', font=FONT, font_size = size, color = cl.Black:with_alpha(0.3), x=1+size+m*2,y=1+m, layer=2, blend_mode = 'normal'}
	self.lblShadow2 = pnl:text{text='shadow', font=FONT, font_size = size, color = cl.Black:with_alpha(0.3), x=size+m*2-1,y=1+m, layer=2, blend_mode = 'normal'}
end
local _drillNames = {
	drill = 'Drill',
	lance = 'Thermal Drill',
	uload_database = 'Upload',
	votingmachine2 = 'Voting Machine',
	hack_suburbia = 'Hacking',
	digitalgui = 'Timelock',
	huge_lance = 'The Beast',
}
local __n = {}
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
	local verbose = self.owner.verbose
	local onScr = O.float.keepOnScreen
	local size = O.float.size
	local m = O.float.margin
	local isADS = self.owner.ADS
	local camPos = self.owner.camPos
	local category = self.category
	local prog,txts = 0,{}
	local unit = self.unit
	if not alive(unit) then return end
	local dx,dy,d,pDist,ww,hh= 0,0,1,0,self.owner.ww,self.owner.hh
	if not ww then return end
	local pos = self.owner:_pos(unit,true)
	local nl_dir = pos - camPos
	local dir = pos - camPos
	mvector3.normalize( nl_dir )
	local dot = mvector3.dot( self.owner.nl_cam_forward, nl_dir )
	local pPos = self.owner:_v2p(pos)
	local out = false
	if onScr and (category == 1 or self.temp) then
		local _sm = O.float.keepOnScreenMargin
		local sm = {x = _sm[1]/100, y = _sm[2]/100}
		local xm = {x = 1-sm.x, y = 1-sm.y}
		if dot < 0
			or pPos.x < sm.x*ww or pPos.y < sm.y*hh
			or pPos.x > xm.x*ww or pPos.y > xm.y*hh then
			local abs = math.abs
			local rr = (hh*(0.5-sm.y))/(ww*(0.5-sm.x))
			local cV = Vector3(ww/2,hh/2,0)
			local dV = pPos:with_z(0) - cV
			local mul = 1
			mvector3.normalize( dV )
			if abs(dV.x * rr) > abs(dV.y) then -- x
				mul = ww*(0.5-sm.x)/dV.x
			else -- y
				mul = hh*(0.5-sm.y)/dV.y
			end
			out = true
			pPos = cV + dV*abs(mul)
		end
	end
	dx = pPos.x - ww/2
	dy = pPos.y - hh/2
	pDist = dx*dx+dy*dy
	self.pnl:set_visible( (onScr and out) or dot > 0 )
	if dot > 0 or onScr then
		if category == 0 then -- Unit
			local cHealth = unit:character_damage() and unit:character_damage()._health and unit:character_damage()._health*10 or 0
			local fHealth = cHealth > 0 and unit:character_damage() and (unit:character_damage()._HEALTH_INIT and unit:character_damage()._HEALTH_INIT*10 or unit:character_damage()._health_max and unit:character_damage()._health_max*10 ) or 1
			prog = cHealth / fHealth
			local cCarry = unit:carry_data()
			local isCiv = unit and managers.enemy:is_civilian( unit )
			local color = isCiv and cl.Lime or math.lerp( cl.Red:with_alpha(0.6), cl.Yellow, prog )
			if self.tag and self.tag.minion then
				color = self.owner:_color(self.tag.minion)
			end
			local distance = unit and mvector3.distance( unit:position(), camPos ) or 0
			if cCarry then
				color = cl.White
				table.insert(txts,{managers.localization:text(tweak_data.carry[cCarry._carry_id].name_id) or 'Bag',color})
			else
				if pDist > 100000 then
					--table.insert(txts,{''})
				elseif cHealth == 0 then
					prog = 0
					table.insert(txts,{Icon.Skull,color})
				else
					table.insert(txts,{_.f(cHealth)..'/'.._.f(fHealth),color})
					if verbose then
					table.insert(txts,{' '..math.ceil(dir:length()/100)..'m',cl.White})
					end
				end
			end
			pPos = pPos:with_y(pPos.y-size*2)
		end
		if category == 1 then -- Drill
			local tGUI = unit and unit:timer_gui()
			local dGUI = unit and unit:digital_gui()
			if not alive(unit) then
				self.dead = true
			elseif tGUI then
				if tGUI._time_left <= 0 then
					self.dead = true
				end
				local name = unit and unit:interaction() and unit:interaction().tweak_data
				name = name and name:gsub('_jammed',''):gsub('_upgrade','') or 'drill'
				name = _drillNames[name] or 'Drill'
				prog = 1-tGUI._time_left/tGUI._timer
				if pDist < 10000 or verbose then
					table.insert(txts,{_.s(name..':',self.owner:_time(tGUI._time_left)..(tGUI._jammed and '!' or ''),'/',self.owner:_time(tGUI._timer)),tGUI._jammed and cl.Red or cl.White})
				else
					table.insert(txts,{_.s(self.owner:_time(tGUI._time_left))..(tGUI._jammed and '!' or ''),tGUI._jammed and cl.Red or cl.White})
				end
			elseif dGUI then
				dGUI._maxx = math.max( dGUI._maxx or 0, dGUI._timer)
				if not (dGUI._ws and dGUI._ws:visible()) or dGUI._floored_last_timer <= 0 then
					return self:destroy(1)
				else
					self:renew()
				end
				local name = 'digitalgui'
				name = _drillNames[name] or 'Timelock'
				prog = 1-dGUI._timer/math.max(dGUI._maxx,1)
				if pDist < 10000 or self.owner.verbose then
					table.insert(txts,{_.s(name..':',self.owner:_time(dGUI._timer),'/',self.owner:_time(dGUI._maxx)),cl.White})
				else
					table.insert(txts,{_.s(self.owner:_time(dGUI._timer)),cl.White})
				end
			end
		end
		if category == 2 then -- Deadsimple text
			local name = self.tag and self.tag.text
			if name and (pDist < 1e6/dir:length() or verbose) then
				table.insert(txts,{name,cl.White})
			end
			pPos = pPos:with_y(pPos.y-size)
			self.bg:set_visible(false)
			prog = 0
		end
		if prog > 0 then
			self.pie:set_current(prog)
			self.pieBg:set_visible(true)
			self.lbl:set_x(2*m+size)
			self:__shadow(2*m+size)
		else
			self.pie:set_visible(false)
			self.pieBg:set_visible(false)
			self.lbl:set_x(m)
			self:__shadow(m)
		end
		if self._txts ~= self.owner:_lbl(nil,txts) then
			self._txts = self.owner:_lbl(self.lbl,txts)
			self:__shadow()
		end
		local __,__,w,h = self.lbl:text_rect()
		h = math.max(h,size)
		self.pnl:set_size(m*2+(w>0 and w+m+1 or 0)+(prog>0 and size or 0),h+2*m)
		self.bg:set_size(self.pnl:size())
		self.pnl:set_center( pPos.x,pPos.y)
		if isADS then
			d = math.clamp((pDist-1000)/2000,0.4,1)
		else
			d = 1
		end
		if not (unit and unit:contour() and #(unit:contour()._contour_list or {}) > 0) then
			d = math.min(d,self.owner:_visibility(pos))
		end
		if out then
			d = math.min(d,0.5)
		end
		if not self.dying then
			self.pnl:set_alpha(d)
			self.lastD = d -- d is for starting alpha
		end
	end
end
function TFloat:renew(data)
	if data then
		self.tag = data.tag
		if type(data.temp)=='number' then
			self.temp = data.temp
			self.lastT = math.max(self.lastT,data.temp)
		end
	end
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
local THitDirection = class()
function THitDirection:init(owner,data)
	self.owner = owner
	self.ppnl = owner.pnl.buff
	self.data = data
	self.sT = now()
	local pnl = self.ppnl:panel{x = 0,y=0, w=200,h=200}
	local Opt = O.hitDirection
	local color = data.shield and Opt.color.shield or Opt.color.health
	self.pnl = pnl
	local bmp = pnl:bitmap{
		name = "hit", rotation = 360, visible = true,
		texture = "guis/textures/pd2/hitdirection",
		color = color,
		blend_mode="add", alpha = 1, halign = "right"
	}
	self.bmp = bmp
	bmp:set_center(100,100)
	if Opt.number then
		local nSize = Opt.numberSize
		local font = Opt.numberDefaultFont and FONT or ALTFONT
		local lbl = pnl:text{
			x = 1,y = 1,font = font, font_size = nSize,
			w = nSize*3, h = nSize,
			text = '-'.._.f(data.dmg*10),
			color = color,
			align = "center",
			layer = 1
		}
		lbl:set_center(100,100)
		self.lbl = lbl
		lbl = pnl:text{
			x = 1,y = 1,font = font, font_size = nSize,
			w = nSize*3, h = nSize,
			text = '-'.._.f(data.dmg*10),
			color = cl.Black:with_alpha(0.2),
			align = "center",
			layer = 1
		}
		lbl:set_center(101,101)
		self.lbl1 = lbl
		lbl = pnl:text{
			x = 1,y = 1,font = font, font_size = nSize,
			w = nSize*3, h = nSize,
			text = '-'.._.f(data.dmg*10),
			color = cl.Black:with_alpha(0.2),
			align = "center",
			layer = 1
		}
		lbl:set_center(99,101)
		self.lbl2 = lbl
	end
	pnl:stop()
	local du = Opt.duration
	if du == true then
		du = self.data.time or 2
	end
	pnl:animate( callback( self, self, 'draw' ), callback( self, self, 'destroy'), du )
end
function THitDirection:draw(pnl, done_cb, seconds)
	local pnl = self.pnl
	local Opt = O.hitDirection
	local ww,hh = self.owner.ww, self.owner.hh
	pnl:set_visible( true )
	self.bmp:set_alpha( 1 )
	local t = seconds
	while t > 0 do
		if self.owner.dead then
			break
		end
		local dt = coroutine.yield()
		t = t - dt
		local p = t/seconds
		self.bmp:set_alpha( math.pow(p,0.5) * Opt.opacity )

		local target_vec = self.data.mobPos - self.owner.camPos
		local fwd = self.owner.nl_cam_forward
		local angle = target_vec:to_polar_with_reference( fwd, math.UP ).spin
		local r = Opt.sizeStart + (1-math.pow(p,0.5)) * (Opt.sizeEnd-Opt.sizeStart)

		self.bmp:set_rotation(-(angle+90))
		self.lbl:set_rotation(-(angle))
		self.lbl1:set_rotation(-(angle))
		self.lbl2:set_rotation(-(angle))

		pnl:set_center(ww/2-math.sin(angle)*r,hh/2-math.cos(angle)*r)
	end
	pnl:set_visible( false )
	if done_cb then done_cb(pnl) end
end
function THitDirection:destroy()
	self.ppnl:remove(self.pnl)
	self = nil
end

--- GUI start ---
PocoUIElem = PocoUIElem or class()
DBG = 1
function PocoUIElem:init(parent,config)
	config = _.m({
		w = 400,h = 20,
	}, config)

	self.parent = parent
	self.config = config or {}
	self.ppnl = parent.pnl
	self.pnl = self.ppnl:panel({ name = config.name, x=config.x, y=config.y, w = config.w, h = config.h})
	self.status = 0

	if config.hintText then
		PocoUIHintLabel.makeHintPanel(self)
	end
end

function PocoUIElem:postInit()
	for event,eventVal in pairs(PocoEvent) do
		if self.config[eventVal] then
			self.parent:addHotZone(eventVal,self)
		end
	end
	self._bind = function()
		_('Warning:PocoUIElem._bind was called too late')
	end
end

function PocoUIElem:_bind(eventVal,cbk)
	if not self.config[eventVal] then
		self.config[eventVal] = cbk
	else
		local _old = self.config[eventVal]
		self.config[eventVal] = function(...)
			_old(...)
			cbk(...)
		end
	end
	return self
end
function PocoUIElem:isHot(event,x,y)
	return self.pnl:inside(x,y)
end

function PocoUIElem:fire(event,x,y)
	local sound = {
		onEnter = 'slider_grab',
		onPressed = 'prompt_enter'
	}
	if self.config[event] then
		if sound[event] then
			managers.menu:post_event(sound[event])
		end
		return true, self.config[event](self,x,y)
	end
end

PocoUIHintLabel = PocoUIHintLabel or class(PocoUIElem)
function PocoUIHintLabel:init(parent,config,inherited)
	self.super.init(self,parent,config,true)

	local __, lbl = _.l({
		pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = config.fontColor or cl.White,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text or 'Err: No text given',config.autoSize)
	self.lbl = lbl

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIHintLabel:makeHintPanel()
	local config = self.config
	local hintPnl = self.ppnl:panel{
		x = 0, y = 0, w = 500, h = 200,
		visible = false
	}
	hintPnl:rect{ color = cl.White:with_alpha(0.1), layer = 1005}
	local __, hintLbl = _.l({
		pnl = hintPnl,x=5, y=5, font = config.hintFont or FONT, font_size = config.hintFontSize or 20, color = config.hintFontColor or cl.White,
		align = config.align, vertical = config.vAlign
	},config.hintText or '',true)
	hintPnl:set_size(hintLbl:size())
	hintPnl:grow(10,10)
	self:_bind(PocoEvent.In, function(self,x,y)
		hintPnl:set_visible(true)
	end):_bind(PocoEvent.Out, function(self,x,y)
		hintPnl:set_visible(false)
	end):_bind(PocoEvent.Move, function(self,x,y)
		hintPnl:set_world_position(x+10,y+20)
	end)

end


PocoUIButton = PocoUIButton or class(PocoUIElem)
function PocoUIButton:init(parent,config,inherited)
	self.super.init(self,parent,config,true)

	local bg = BoxGuiObject:new(self.pnl, {sides = {1,1,1,1}})
	bg:set_visible(false)
	local __, lbl = _.l({
		pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = FONT, font_size = config.fontSize or 20, color = config.fontColor or cl.White,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)

	self:_bind(PocoEvent.In, function(self,x,y)
		bg:set_visible(true)
	end):_bind(PocoEvent.Out, function(self,x,y)
		bg:set_visible(false)
	end)

	self.lbl = lbl
	if not inherited then
		self:postInit(self)
	end
end

PocoUIValue = PocoUIValue or class(PocoUIElem)
function PocoUIValue:init(parent,config,inherited)
	PocoUIElem.init(self,parent,config,true)
	local __, lbl = _.l({
			pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = FONT, font_size = config.fontSize or 20,
			color = config.fontColor or cl.White },config.text,true)
	self.lbl = lbl
	local __, lbl = _.l({
			pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = FONT, font_size = config.fontSize or 20,
			color = config.fontColor or cl.White },config.text,true)
	self.valLbl = lbl

	if not config.noArrow then
		self.arrowLeft = self.pnl:bitmap({
			texture = "guis/textures/menu_arrows",
			texture_rect = {
				0,
				0,
				24,
				24
			},
			color = cl.Green,
			x = 0,
			y = 0,
			blend_mode = 'add'
		})
		self.arrowRight = self.pnl:bitmap({
			texture = "guis/textures/menu_arrows",
			texture_rect = {
				0,
				0,
				24,
				24
			},
			color = cl.Red,
			x = 20,
			y = 1,
			blend_mode = 'add',
			rotation = 180,
		})

		self.arrowRight:set_right(self.pnl:w())
		self:_bind(PocoEvent.Pressed,function(self,x,y)
			_('UIValuePressed',x,y)
		end)
	end

	-- Always inherited though
end

function PocoUIValue:isValid(val)
	return true
end

function PocoUIValue:val(set)
	if set then
		if not self.value or self:isValid(set) then
			self.value = set
		else
			return false
		end
	else
		return self.value
	end
end


PocoUINumValue = PocoUINumValue or class(PocoUIValue)
function PocoUINumValue:init(parent,config,inherited)
	self.super.init(self,parent,config,true)
	self:val(0)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUINumValue:isValid(val)
	return (type(val) == 'number') and (val >= (self.config.max or 100)) and (val <= (self.config.min or 100))
end

PocoTab = PocoTab or class()
function PocoTab:init(parent,ppnl,tabName)
	self.ppnl = ppnl
	self.name = tabName
	self.wrapper = ppnl:panel({ x=0, y=parent.config.th,w = ppnl:w(), h = ppnl:h()-parent.config.th, name = tabName})
	self.pnl = self.wrapper:panel({ x=0, y=0, w = ppnl:w(), h = ppnl:h(), name = 'content'})
	self.hotZones = {}
end

function PocoTab:insideTab(x,y)
	return self.bg and self.bg:inside(x, y)
end

function PocoTab:addHotZone(event,item)
	self.hotZones[event] = self.hotZones[event] or {}
	table.insert(self.hotZones[event],item)
end

function PocoTab:isHot(event, x, y, autoFire)
	if self.hotZones[event] and self.wrapper:inside(x,y) then
		for i,hotZone in pairs(self.hotZones[event]) do
			if hotZone:isHot(event, x,y) then
				if autoFire then
					hotZone:fire(event, x, y)
				end
				return hotZone
			end
		end
	else
		return false
	end
end

function PocoTab:scroll(val, force)
	local tVal = force and 0 or self.pnl:y() + val
	local pVal = math.clamp(tVal,self.wrapper:h()-self.pnl:h()-100,0)
	if pVal ~= tVal then
		self._errCnt = 1+ (self._errCnt or 0)
	else
		self._errCnt = 0
		if not force then
			managers.menu_component:post_event('slider_grab')
		end
	end
	return self.pnl:set_y(pVal)
end

function PocoTab:canScroll(down,x,y)
	local result = self:isLarge() and self.wrapper:inside(x,y)
	if (self._errCnt or 0) > 1 then
		local pos = self.pnl:y()
		if (pos == 0) ~= down then
			result = false
		end
	end
	return result
end

function PocoTab:isLarge()
	return self.pnl:h() > self.ppnl:h()
end

function PocoTab:destroy()
	-- does nothing yet
end

PocoTabs = PocoTabs or class()
function PocoTabs:init(ws,config) -- name,x,y,w,th, h
	self._ws = ws
	self.config = config
	self.pnl = ws:panel():panel{ name = config.name , x = config.x, y = config.y, w = config.w, h = config.h, layer = 1005}
	self.items = {} -- array of PocoTab
	self.sPnl = self.pnl:panel{ name = config.name , x = 0, y = config.th, w = config.w, h = config.h-config.th }

	BoxGuiObject:new(self.sPnl, {
		sides = {
			1,
			1,
			2,
			2
		}
	})
end
function PocoTabs:goTo(index)
	local cnt = #self.items
	if index < 1 then
		index = cnt
	elseif index > cnt then
		index = 1
	end
	if index ~= self.tabIndex then
		managers.menu_component:post_event('slider_release' or 'Play_star_hit')
		self.tabIndex = index
		self:repaint()
	end
end
function PocoTabs:move(delta)
	self:goTo((self.tabIndex or 1) + delta)
end
function PocoTabs:add(tabName)
	local item = PocoTab:new(self,self.pnl,tabName)
	table.insert(self.items,item)
	self.tabIndex = self.tabIndex or 1
	self:repaint()
	return item
end

function PocoTabs:repaint()
	local cnt = #self.items
	local x = 0
	if cnt == 0 then return end
	local tabIndex = self.tabIndex or 1
	for key,itm in pairs(self.items) do
		local isSelected = key == tabIndex
		if isSelected then
			self.currentTab = itm
		end
		local hPnl = self.pnl:panel{w = 200, h = self.config.th, x = x, y = 0}
		if itm.hPnl then
			self.pnl:remove(itm.hPnl)
		end
		local bg = hPnl:bitmap({
			name = 'tab_top',
			texture = 'guis/textures/pd2/shared_tab_box',
			w = self.config.w, h = self.config.th + 3,
			color = cl.White:with_alpha(isSelected and 1 or 0.1)
		})
		local lbl = hPnl:text({
			x = 10, y = 10, w = 200, h = self.config.th,
			name = 'tab_name', text = itm.name,
			font = FONT,
			font_size = 20,
			color = isSelected and cl.Black or cl.White,
			layer = 2,
			align = 'center',
			vertical = 'center'
		})
		local xx,yy,w,h = lbl:text_rect()

		lbl:set_size(w,h)

		bg:set_w(w + 20)
		x = x + w + 25
		itm.bg = bg
		itm.hPnl = hPnl
		itm.pnl:set_visible(isSelected)
	end
	if self.currentTab then
		self.currentTab:scroll(0,true)
	end
end

function PocoTabs:destroy(ws)
	for k,v in pairs(self.items) do
		v:destroy()
	end
	self._ws:panel():remove(self.pnl)
end
------------
PocoMenu = PocoMenu or class()
function PocoMenu:init(ws)
	self._ws = ws
	self.gui = PocoTabs:new(ws,{name = 'PocoMenu',x = 10, y = 10, w = 1000, th = 40, h = 700})

	self.pnl = ws:panel():panel({ name = 'bg' , layer = 1005})
	self.pnl:rect{color = cl.Black:with_alpha(0.7)}
	self.pnl:bitmap({
		texture = "guis/textures/test_blur_df",
		w = self.pnl:w(),h = self.pnl:h(),
		render_template = "VertexColorTexturedBlur3D"
	})
	local active_menu = managers.menu:active_menu()
	if active_menu then
		active_menu.input:set_force_input(false)
	end

	PocoMenu.m_id = managers.mouse_pointer:get_id()
	PocoMenu.__active = managers.mouse_pointer._active
	managers.mouse_pointer:use_mouse{
		id = PocoMenu.m_id,
		mouse_move = callback(self, self, 'mouse_moved'),
		mouse_press = callback(self, self, "mouse_pressed"),
		mouse_release = callback(self, self, "mouse_released")
	}
	local camBase = _.g('managers.player:player_unit():camera():camera_unit():base()')
	if camBase then
		camBase:set_limits(15,15)
	end
	self._lastMove = 0
end
function PocoMenu:add(...)
	return self.gui:add(...)
end

function PocoMenu:update(...)
	----TEST
	if self.gui then
		--self.gui:update(...)
	end
	----TESTEND
end
function PocoMenu:destroy()
	self.dead = true
	if PocoMenu.m_id then
		managers.mouse_pointer:remove_mouse(PocoMenu.m_id)
	end
	local camBase = _.g('managers.player:player_unit():camera():camera_unit():base()')
	if camBase then
		camBase:remove_limits()
	end
	if self.gui then
		self.gui:destroy()
	end
	if self.pnl then
		self._ws:panel():remove(self.pnl)
	end
	local active_menu = managers.menu:active_menu()
	if active_menu then
		active_menu.input:set_force_input(true)
	end


end

function PocoMenu:mouse_moved(panel, x, y)
	local isNewPos = self._x ~= x or self._y ~= y
	self._x = x
	self._y = y
	local _fireMouseOut = function()
		if self.lastHot then
			self.lastHot:fire(PocoEvent.Out,x,y)
			self.lastHot = nil
		end
	end
	for ind,tab in pairs(self.gui.items) do
		if tab:insideTab(x,y) and self.tabIndex ~= ind then
			return true, 'link'
		end
	end
	local currentTab = self.gui and self.gui.currentTab

	local hotElem = isNewPos and currentTab and currentTab:isHot(PocoEvent.Move, x,y)
	if hotElem then
		hotElem:fire(PocoEvent.Move,x,y)
	end

	local hotElem = isNewPos and currentTab and currentTab:isHot(PocoEvent.In, x,y)
	if hotElem then
		if hotElem ~= self.lastHot then
			_fireMouseOut()
			self.lastHot = hotElem
			hotElem:fire(PocoEvent.In,x,y)
		end
	elseif isNewPos then
		_fireMouseOut()
	end
	local hotElem = currentTab and currentTab:isHot(PocoEvent.Pressed, x,y)
	if hotElem then
		return true, hotElem.cursor or 'link'
	end
	return true, 'arrow'
end

function PocoMenu:mouse_pressed(panel, button, x, y)
	pcall(function()
		local scrollStep = 40
		local currentTab = self.gui and self.gui.currentTab
		if button == Idstring("mouse wheel down") then
			if currentTab:isHot(PocoEvent.WheelDown, x,y, true) then
				return true
			end
			if currentTab and currentTab:canScroll(true,x,y) then
				return currentTab:scroll(-scrollStep)
			end
			if now() - self._lastMove > 0.1 then
				self._lastMove = now()
				self.gui:move(1)
			end
		elseif button == Idstring("mouse wheel up") then
			if currentTab:isHot(PocoEvent.WheelUp, x,y, true) then
				return true
			end
			if currentTab and currentTab:canScroll(false,x,y) then
				return currentTab:scroll(scrollStep)
			end
			if now() - self._lastMove > 0.1 then
				self._lastMove = now()
				self.gui:move(-1)
			end
		end

		if button == Idstring('0') then
			for ind,tab in pairs(self.gui.items) do
				if tab:insideTab(x,y) and self.tabIndex ~= ind then
					self.gui:goTo(ind)
					return true
				end
			end
			return currentTab and currentTab:isHot(PocoEvent.Pressed, x,y, true)
		end
		if button == Idstring('1') then
			return currentTab and currentTab:isHot(PocoEvent.PressedAlt, x,y, true)
		end
	end)
end

function PocoMenu:mouse_released(panel, button, x, y)
	local currentTab = self.gui and self.gui.currentTab
	if button == Idstring('0') then
		return currentTab and currentTab:isHot(PocoEvent.Released, x,y, true)
	end
	if button == Idstring('1') then
		local hot = currentTab and currentTab:isHot(PocoEvent.ReleasedAlt, x,y, true)
		return hot or me:Menu(true)
	end
end
