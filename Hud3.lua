-- PocoHud3 by zenyr@zenyr.com
if not TPocoBase then return end
local disclamer = [[
Okay, you're trying to read my code and I know it is unavoidable, but frankly speaking I did not want to let malicious people to get access to certain things.
As I already promised I will open my source code someday, and for extreme early adopters like YOU, I did not put any kind of DRM, obfuscation or countermeasure to protect the code other than BASIC compilation.
I understand your curiosity. I would've do the same. This basic luac would not bar you from what you want, I just wanted to avoid script kids' code-theft a bit. I expect you the guru would not need to do such thing.
Have a nice day and feel free to ask me through my mail: zenyr@zenyr.com. But please understand that I'm quite clumsy, cannot guarantee I'll reply what you want..
]]
local _ = UNDERSCORE
local VR = 0.111
local VRR = 'T'
local inGame = CopDamage ~= nil
local me
--- Options ---
local YES,NO,yes,no = true,false,true,false
local O = {
	enable = YES, -- YES/NO : 포코허드 전체 스위치
	debug = {
		color = cl.White:with_alpha(0.5),
		size = 22,
		defaultFont = NO,
		verboseOnly = NO,
		showFPS = YES,
		showClockIngame = NO,
		showClockOutgame = YES,
	},
	buff = {			-- === 버프 설정 === >> 재장전, 스태미너, ECM, 버서커, 불렛스톰등 표현
		show = YES,	-- YES/NO : 버프 표현기능 사용
		left = 10,  -- 0~100% : 버프 기준점 가로 %
		top  = 22,  -- 0~100% : 버프 기준점 세로 %
		maxFPS = 50,-- 자연수 : 버프 갱신주기
		size = 70,  -- 자연수 : 버프 아이콘 크기 (단, "바닐라 스타일"에서는 무시)
		gap = 10,   -- 자연수 : 버프 아이콘 간격 (단, "바닐라 스타일"에서는 무시)
		align = 1,  -- [1,2,3] : 아이콘 정렬방향 1왼쪽 2중앙 3오른쪽
		style = 2,  -- [1,2]: 버프아이콘 스타일 1포코허드(컬러) 2바닐라(순정Feel)


		noSprintDelay = YES,
		hideInteractionCircle = NO,
		simpleBusy = YES,
		simpleBusyRadius = 10,
	},
	popup = {			-- === 데미지팝업 설정 ===
		show = YES,		-- YES/NO : 데미지팝업 사용
		size = 20,		-- 자연수 : 팝업 글자크기
		damageDecay = 10,	-- 초 : 팝업 지속시간
		myDamage = YES,   	-- YES/NO : 내 데미지 표시
		crewDamage = YES, 	-- YES/NO : 동료 플레이어 데미지 표시
		AIDamage = YES,	-- YES/NO : 동료 AI 데미지 표시
		handsUp = YES,		-- YES/NO : 몹이 투항하려 할 때 표시
		dominated = YES,	-- YES/NO : 투항 완료시 표시
	},
	float = {				-- === 가리킨 대상 정보 설정 ===
		show = YES,			-- YES/NO : 사용여부
		border = NO,			-- YES/NO : 모서리 표시 사용
		size = 15,			-- 자연수 : 정보 글자크기
		margin = 3,			-- 자연수 : 정보 항목간 간격
		keepOnScreen = YES,		-- YES/NO : 화면 내 유지여부
		keepOnScreenMargin = {2,15},	-- {%,%} : 화면 내 유지시 가로, 세로 여백
		maxOpacity = 0.9,		-- 0-1 : 불투명도
		unit = YES,			-- YES/NO : 유닛정보 표시
		drills = YES,			-- YES/NO : 드릴정보 표시
	},
	info = {				-- === 플레이어 정보 ===
		size = 17,			-- 자연수 : 정보 글자크기
		clock = YES,			-- YES/NO : 내 정보란 빈칸을 활용해 (현실)시간 표시
		verboseKey = '`',		-- 문자 : 자세히 보기 모드 단축키
	},
	minion = {			-- === 미니언 정보 === >> Float을 활용해 Joker스킬 사용한 미니언 표시
		show = YES		-- YES/NO
	},
	chat = {		-- === 주요 이벤트 채팅 방송기능 === >> 이벤트별로 중요도를 할당해, 내 자격에 따라 방송 여부 결정가능
		readThreshold = 2,			-- 이 수치보다 높은 이벤트 발생시 내 채팅창에만 표시
		serverSendThreshold = 3,		-- 내가 방장인 경우 플레이어에게 모두 방송
		clientFullGameSendThreshold = 4,	-- 내가 방장이 아니지만 방장과 동시에 시작했을 경우 플레이어에게 모두 방송
		clientMidGameSendThreshold = 5,	-- 내가 방장도 아니고 중간에 입장했지만 플레이어에게 모두 방송
		alwaysSendThreshold = 8, -- Mute상태에서도 무조건 방송

		midgameAnnounce = 50,			-- 팀원+AI합산한 킬수마다 게임 중간 통계 출력 (이벤트 중요도에 따라 방송여부 결정)

		index = { -- Index: 이벤트별 중요도 할당. 높은 수치는 '많은 사람들이 알아야 하는 중요한 정보', 낮은 수치는 '별로 필요 없는 사소한 정보'를 의미
			midStat = 3,			-- 게임 중간통계 (*게임중 입장시 부정확)
			endStat = 4,			-- 게임 최종통계 (*게임중 입장시 부정확)
			endStatCredit = 4, -- 게임 최종통계 후 모드 특성 설명
			dominated = 4,			-- 몹이 투항했을 경우
			converted = 4,			-- 플레이어가 몹을 미니언으로 변환한 경우
			minionLost = 4,		-- 미니언 사망
			minionShot = 4,		-- 플레이어에 의한 미니언 피격
			hostageChanged = 1,		-- 몹 인질 수 변동
			custody = 5,			-- 플레이어 체포
			downed = 2,			-- 플레이어 다운(단, 클로커/테이저 등 다운카운트 감소시키는 경우만)
			downedWarning = 5,		-- 플레이어가 3회 이상 다운
			replenished = 5,		-- 플레이어가 의료킷으로 체력&다운카운트 복구
			messiah = 8,			-- 플레이어가 피스톨메시아 사용
		}
	},
	hitDirection = {			-- === 피격 표시 설정 ===
		replace = YES,			-- YES/NO : 사용여부
		duration = YES,		-- YES/초 : 지속시간을 초로 입력. YES로 설정시 쉴드 복구시간으로 자동설정(권장)
		opacity = 0.5,			-- 0-1 : 투명도
		number = YES,			-- YES/NO : 피해량 표시
		numberSize = 25,		-- 피해량 글자 크기
		numberDefaultFont = NO,	-- 피해량 폰트를 기본폰트로
		sizeStart = 100,		-- 최초 크기
		sizeEnd = 200,			-- 사라지기 직전의 크기
		color = {
			shield = cl.Aqua,	-- Color('RRGGBB') : 쉴드 손실시 색상
			health = cl.Red	-- Color('RRGGBB') : 체력 손실시 색상
		}
	},
	conv = {	-- === 미니언 사망 원인 표현용, 변경할 필요 없음 ===
		city_swat = 'a Gensec Elite',
		cop = 'a cop',
		fbi = 'an FBI agent',
		fbi_heavy_swat = 'an FBI heavy SWAT',
		fbi_swat = 'an FBI SWAT',
		gangster = 'a gangster',
		gensec = 'a Gensec guard',
		heavy_swat = 'a heavy SWAT',
		security = 'a guard',
		shield = 'a shield',
		sniper = 'a sniper',
		spooc = 'a cloaker',
		swat = 'a SWAT',
		tank = 'a bulldozer',
		taser = 'a taser',
	},
}
local _BAGS = {}
_BAGS['8f59e19e1e45a05e']='Ammo'
_BAGS['43ed278b1faf89b3']='Med'
_BAGS['a163786a6ddb0291']='Body'
local ALTFONT = 'fonts/font_eroded'
local FONT =  'fonts/font_medium_mf' or tweak_data.hud_present.title_font or tweak_data.hud_players.name_font or "fonts/font_eroded" or 'core/fonts/system_font'
local clGood =  Color( 255, 146, 208, 80 ) / 255
local clBad =  Color( 255, 255, 192, 0 ) / 255
local Icon = {
	A=57344, B=57345,	X=57346, Y=57347, Back=57348, Start=57349,
	Skull = 57364, Ghost = 57363, Dot = 1031, Chapter = 1015, Div = 1014, BigDot = 1012,
	Times = 215, Divided = 247, LC=139, RC=155, Deg = 1024, PM= 1025, No = 1033,
}
for k,v in pairs(Icon) do
	Icon[k] = utf8.char(v)
end
local _BROADCASTHDR, _BROADCASTHDR_HIDDEN = Icon.Div,Icon.Ghost
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
PocoTab = PocoTab or class()
function PocoTab:init(parent,ppnl,tabName)
	self.ppnl = ppnl
	self.name = tabName
	self.wrapper = ppnl:panel({ x=0, y=parent.config.th,w = ppnl:w(), h = ppnl:h()-parent.config.th, name = tabName})
	self.pnl = self.wrapper:panel({ x=0, y=0, w = ppnl:w(), h = ppnl:h(), name = 'content' , visible = true})
	self.hotZones = {}
end

function PocoTab:insideTab(x,y)
	return self.bg and self.bg:inside(x, y)
end

function PocoTab:registerHotZone(itm,bg,callback)
	if bg then
		bg:set_visible(false)
	end
	table.insert(self.hotZones,{elem=itm,bg=bg,cbk=callback})
end
function PocoTab:isHot(x,y)
	if self.wrapper:inside(x,y) then
		for i,hotZone in pairs(self.hotZones) do
			if hotZone.elem and hotZone.elem:inside(x,y) then
				return true, hotZone
			end
		end
	end
	return false
end

function PocoTab:scroll(val, force)
	local tVal = force and 0 or self.pnl:y() + val
	local pVal = math.clamp(tVal,self.wrapper:h()-self.pnl:h()-200,0)
	if pVal ~= tVal then
		self._errCnt = 1+ (self._errCnt or 0)
	else
		self._errCnt = 0
	end
	return self.pnl:set_y(pVal)
end

function PocoTab:canScroll(down,x,y)
	local result = self:isLarge() and self.wrapper:inside(x,y)
	if (self._errCnt or 0) > 1 then
		result = false
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
	self.pnl = ws:panel():panel{ name = config.name , x = config.x, y = config.y, w = config.w, h = config.h, layer = 505}
	self.items = {} -- array of PocoTab
	self.sPnl = self.pnl:panel{ name = config.name , x = 0, y = config.th, w = config.w, h = config.h-config.th , layer = 501}

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
		managers.menu_component:post_event("highlight")
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
			layer = 0, color = cl.White:with_alpha(isSelected and 1 or 0.1)
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

	self.pnl = ws:panel():panel({ name = 'bg' , layer = 450})
	self.pnl:rect{color = cl.Black:with_alpha(0.7)}
	self.pnl:bitmap({
		texture = "guis/textures/test_blur_df",
		w = self.pnl:w(),h = self.pnl:h(),
		render_template = "VertexColorTexturedBlur3D",
		layer = -1
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
	local xx,yy = managers.gui_data:safe_to_full(x, y)
	for ind,tab in pairs(self.gui.items) do
		if tab:insideTab(xx,yy) and self.tabIndex ~= ind then
			return true, 'link'
		end
	end
	local currentTab = self.gui and self.gui.currentTab
	if self._hotBg then
		self._hotBg:set_visible(false)
		self._hotBg = nil
	end
	if currentTab and currentTab:isHot(xx,yy) then
		local __, hotZone = currentTab:isHot(xx,yy)
		if hotZone.bg then
			self._hotBg = hotZone.bg
			hotZone.bg:set_visible(true)
		end
		return true, 'link'
	end
	return true, 'arrow'
end

function PocoMenu:mouse_pressed(panel, button, x, y)
	pcall(function()
		local scrollStep = 40
		local currentTab = self.gui and self.gui.currentTab
		if button == Idstring("mouse wheel down") then
			if currentTab and currentTab:canScroll(true,x,y) then
				return currentTab:scroll(-scrollStep)
			end
			if now() - self._lastMove > 0.2 then
				self._lastMove = now()
				self.gui:move(1)
			end
			return
		elseif button == Idstring("mouse wheel up") then
			if currentTab and currentTab:canScroll(false,x,y) then
				return currentTab:scroll(scrollStep)
			end
			if now() - self._lastMove > 0.2 then
				self._lastMove = now()
				self.gui:move(-1)
			end

			return
		end

		if button == Idstring("0") then
			for ind,tab in pairs(self.gui.items) do
				if tab:insideTab(x,y) and self.tabIndex ~= ind then
					self.gui:goTo(ind)
					return true
				end
			end
			if currentTab and currentTab:isHot(x,y) then
				local __, hotZone = currentTab:isHot(x,y)
				hotZone.cbk()
			end
		end
	end)
end

function PocoMenu:mouse_released(panel, button, x, y)
	if button == Idstring("1") then
		me:Menu(true)
	end
end


--- Class Start ---
local TPocoHud3 = class(TPocoBase)
TPocoHud3.className = 'Hud'
TPocoHud3.classVersion = 3
--- Inherited ---
function TPocoHud3:onInit() -- ★설정
	Poco:LoadOptions(self:name(1),O)
	if not O.enable then
		return false
	end
	self._ws = inGame and managers.gui_data:create_fullscreen_workspace() or managers.gui_data:create_fullscreen_16_9_workspace()
	error = function(msg)
		if self.dead then
			_('ERR:',msg)
		else
			self:err(msg,1)
		end
	end
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
	self.hits = {} -- to prevent HitDirection markers gc
	self.gadget = self.gadget or {}
--	self.tmp = self.pnl.dbg:bitmap{name='x', blend_mode = 'add', layer=1, x=0,y=40, color=clGood ,texture = "guis/textures/hud_icons"}
	local dbgO = O.debug
	self.dbgLbl = self.pnl.dbg:text{text='HUD '..(inGame and 'Ingame' or 'Outgame'), font= dbgO.defaultFont and FONT or ALTFONT, font_size = dbgO.size, color = dbgO.color, x=0,y=self.pnl.dbg:height()-dbgO.size, layer=0}
	self:_hook()
	local verboseKey = O.info.verboseKey
	if verboseKey then
		Poco:Bind(self,verboseKey,callback(self,self,'toggleVerbose',true),callback(self,self,'toggleVerbose',false))
	end
	Poco:Bind(self,14,callback(self,self,'Menu',false))

	return true
end
function TPocoHud3:onResolutionChanged()
	if alive(self._ws) then
		if inGame then
			managers.gui_data:layout_fullscreen_workspace( self._ws )
			self.dbgLbl:set_y(self.pnl.dbg:height()-self.dbgLbl:height())
		else
			managers.gui_data:layout_fullscreen_16_9_workspace( self._ws )
			self.dbgLbl:set_y(self.pnl.dbg:height()-self.dbgLbl:height())
		end
	else
		self:err('No WS to reschange')
	end
end
function TPocoHud3:import(data)
	self.killa = data.killa
	self.stats = data.stats
end
function TPocoHud3:export()
	Poco.save[self.className] = {
		stats = self.stats,
		killa = self.killa,
	}
end
function TPocoHud3:Update(t,dt)
	local r,err = pcall(self._update,self,t,dt)
	if not r then _(err) end
end
function TPocoHud3:onDestroy(gameEnd)
	self:Menu(true) -- Force dismiss menu
	if( alive( self._ws ) ) then
		managers.gui_data:destroy_workspace(self._ws)
	end
	if( alive( self._worldws ) ) then
		World:newgui():destroy_workspace( self._worldws )
	end
end
function TPocoHud3:AddDmgPopByUnit(sender,unit,offset,damage,death,head,dmgType)
	if unit then
		local uType = unit:base()._tweak_table or 0
		local _arr = {russian=1,german=1,spanish=1,american=1}
		if not _arr[uType] then -- this filters PlayerDrama related events out when hosting a game
			self:AddDmgPop(sender,self:_pos(unit),unit,offset,damage,death,head,dmgType)
		end
	end
end
local _lastAttk, _lastAttkpid = 0,0
function TPocoHud3:AddDmgPop(sender,hitPos,unit,offset,damage,death,head,dmgType)
	local Opt = O.popup
	if self.dead or not Opt.show then return end
	local pid = self:_pid(sender)

	local isPercent = damage<0
	local dmgTime = Opt.damageDecay
	local rDamage = damage>=0 and damage or -damage
	if isPercent and unit and unit:character_damage() and unit:character_damage()._HEALTH_INIT then
		rDamage = math.min(unit:character_damage()._HEALTH_INIT * rDamage / 100,unit:character_damage()._health)
	end
	local isSpecial = false
	if unit then
		local senderTweak = sender and sender:base()._tweak_table or '?'
		isSpecial = tweak_data.character[ unit:base()._tweak_table ].priority_shout
		if isSpecial =='f34' then isSpecial = false end
		for i = 1,4 do
			local minion = self:Stat(i,'minion')
			if unit == minion then
				local apid = self:_pid(senderTweak)
				self:Stat(i,'minionHit',senderTweak)
				if apid and apid > 0 and (apid ~= _lastAttkpid or now()-_lastAttk > 5) then
					_lastAttk = now()
					_lastAttkpid = apid
					self:Chat('minionShot',_.s(self:_name(senderTweak),'damaged',(i==apid and 'own' or self:_name(i)..'\'s'),'minion for',_.f(rDamage*10)))
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
				if Network:is_server() and (self.killa % O.chat.midgameAnnounce == 0) then
					self:AnnounceStat(true)
				end
			end
		end
		if pid == self.pid and not Opt.myDamage then return
		elseif pid == 0 and not Opt.AIDamage then return
		elseif not Opt.crewDamage then
			if pid > 0 and pid ~= self.pid then
				return
			end
		end
		self:Popup( {pos=pos, text=texts, stay=false, et=now()+dmgTime })
	end)
	if not r then _(err) end
end
--- Internal functions ---
function TPocoHud3:Menu(dismiss,...)
	local titlecase = function (str)
			local buf = {}
			for word in string.gfind(str, "%S+") do
					local first, rest = string.sub(word, 1, 1), string.sub(word, 2)
					table.insert(buf, string.upper(first) .. string.lower(rest))
			end
			return table.concat(buf, " ")
	end
	local _drawUpgrades = function(pnl, data, isTeam, desc, offsetY)
		local _ignore = {}
		offsetY = offsetY or 0
		pnl:text{
			x = 10, y = offsetY+10, w = 600, h = 30,
			name = 'tab_desc', text = Icon.Chapter..' '..desc,
			font = 'fonts/font_large_mf', font_size = 25, color = cl.CornFlowerBlue,
		}
		local large = 5
		local y,fontSize,w = offsetY+35, 19, 970
		if data then
			local merged = table.deepcopy(data)
			for category, upgrades in _pairs(merged) do
				local row,cnt = {},0
				y = self:_drawRow(pnl,fontSize*1.1,{{titlecase(category:gsub('_',' ')),cl.Peru},''},5,y,w)
				for name,value in _pairs(upgrades) do
					local isMulti = name:find('multiplier') or name:find('_chance') or name:find('_mul')
					local val = isTeam and managers.player:team_upgrade_value(category, name, 1) or managers.player:upgrade_value(category, name, 1)
					if not (isMulti and val == 1) then
						cnt = cnt + 1
						if isMulti and type(val) == 'number' then
							val = _.s(val*100) .. '%'
						elseif type(val) == 'table' then
							val = _.s( type(val[1]) == 'number' and _.s(val[1]*100) .. '%' or _.s(val[1]==true and 'Yes' or val[1]), _.s(val[2],'sec') )
						elseif val == true then
							val = 'Yes'
						else
							val = _.s(val)
						end
						row[#row+1] = {
							{(name:gsub('_multiplier',''):gsub('_',' '))..' ',cl.WhiteSmoke}
						}
						row[#row+1] = {
							{val..' ',cl.LightSteelBlue}
						}

						if #row> large then
							y = self:_drawRow(pnl,fontSize,row,15,y,w,true,{0,1,0,1,0,1})
							row = {}
						end
					end
				end
				if cnt == 0 then
					row[#row+1] =  {'Not effective',cl.LightSteelBlue}
				end
				if #row > 0 then
					while (#row <= large) do
						table.insert(row,'')
					end
					y = self:_drawRow(pnl,fontSize,row,15,y,w,true,{0,1,0,1,0,1})
					row = {}
				end
			end
			if pnl:h() < y then
				pnl:set_h(y)
			end
		else
			y = self:_drawRow(pnl,fontSize,{{'No upgrades acquired\n',cl.White:with_alpha(0.5)}},0,y,w)
		end
		return y
	end
	local _drawPlayer = function(pnl, pid, member, offsetY)
		offsetY = offsetY or 0
		pnl:text{
			x = 10, y = offsetY+10, w = 600, h = 30,
			name = 'tab_desc', text = self:_name(pid),
			font = 'fonts/font_large_mf', font_size = 25, color = self:_color(pid)
		}
		local y,fontSize,w = offsetY+35, 19, 970
		return y
	end

	local r,err = pcall(function()
		local menu = self.menuGui
		if menu then -- Remove
			managers.menu_component:post_event("menu_exit")
			menu:destroy()
			self.menuGui = nil
		elseif not dismiss then -- Show
			managers.menu_component:post_event("menu_enter")
			local gui = PocoMenu:new(self._ws)
			self.menuGui = gui
			--- Install tabs here ---
			local tab = gui:add('About')

			local btn = tab.pnl:panel{w = 400,h=100, x = 10, y = 10}
			local bg = BoxGuiObject:new(btn, {sides = {1,1,1,1}})

			_.l({
				pnl = tab.pnl,w = 400,h=100,
				x = 10, y = 10, font = FONT, font_size = 20, color = cl.White,
				align = 'center', vertical = 'center'
			},{{'PocoHud3 '},{_.f(VR,4)..VRR,cl.Green},{' by ',cl.White},{'Zenyr',cl.MediumTurquoise},{'\nDiscuss/suggest at PocoMods steam group!',cl.LightSkyBlue},{'\n\n(Click here to visit)',cl.Tomato}})
			tab:registerHotZone(btn,bg,function()
				managers.menu:post_event("prompt_enter")
				Steam:overlay_activate('url', 'http://steamcommunity.com/groups/pocomods')
			end)

			btn = tab.pnl:panel{w = 400,h=40, x = 10, y = 120}
			bg = BoxGuiObject:new(btn, {sides = {1,1,1,1}})

			_.l({
				pnl = tab.pnl,w = 400,h=40, x = 10, y = 120, font = FONT, font_size = 20, color = cl.White,
				align = 'center', vertical = 'center'
			},{'@zenyr',cl.OrangeRed})
			tab:registerHotZone(btn,bg,function()
				managers.menu:post_event("prompt_enter")
				Steam:overlay_activate('url', 'http://twitter.com/zenyr')

			end)

			tab = gui:add('Heist Status')
			self:_drawStat(true,tab.pnl)
			tab = gui:add('Upgrade Skills')
			local y = 0
			if inGame then
				for pid,upg in pairs(_.g('Global.player_manager.synced_team_upgrades',{})) do
					if upg then
						y = _drawUpgrades(tab.pnl,upg,true,'Crew bonus from '..self:_name(pid),y)
					end
				end
			end
			y = _drawUpgrades(tab.pnl,_.g('Global.player_manager.team_upgrades'),true,'Perks that you and your crew will benefit from',y)
			y = _drawUpgrades(tab.pnl,_.g('Global.player_manager.upgrades'),false,'Perks that you have acquired',y)
			tab = gui:add('Inspect')
			y = 0
			for i=1,4 do
				local member= self:_member(i)
				if member and member._unit then
					y = _drawPlayer(tab.pnl, i, member, y)
				end
			end
			_.l({
				pnl = tab.pnl,
				x = 10, y = y+10, font = FONT, font_size = 20, color = cl.White,
				align = 'center', vertical = 'center'
			},{{'*to be announced',cl.Crimson}},true)
		end
	end)
	if not r then _('MenuCallErr',err) end
end
function TPocoHud3:AnnounceStat(midgame)
	local txt = {}
	table.insert(txt,Icon.LC..'PocoHud³ v'.._.f(VR,3).. ' '.. VRR ..Icon.RC..' '..' Crew Kills:'..self.killa..Icon.Skull)
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
			self:Stat(pid,'ping',math.floor(Network:qos( peer:rpc() ).ping))
		end
		self.pid = _.g('managers.network:session():local_peer():id()')
	end
end
function TPocoHud3:_update(t,dt)
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
		mobPos = managers.player:player_unit():position()
	end
	managers.environment_controller._hit_some = math.min(managers.environment_controller._hit_some + managers.environment_controller._hit_amount, 1)
	if mobPos then
		-- TODO: Change intensity according to dmg?
		table.insert(self.hits,THitDirection:new(self,{mobPos=mobPos,shield=data.shield,dmg=data.dmg,time=data.time}))
	end
end
function TPocoHud3:Minion(pid,unit)
	if alive(unit) then
		self:Stat(pid,'minion',unit)
		self:Chat('converted',_.s(self:_name(pid),'converted',self:_name(unit)))
	else
		self:Stat(pid,'minion',0)
	end
end
function TPocoHud3:Chat(category,text)
	local Opt = O.chat
	local catInd = Opt.index[category] or -1
	local forceSend = catInd >= Opt.alwaysSendThreshold
	if Opt.muted and not forceSend then return _('Muted:',text) end
	local canRead = catInd >= Opt.readThreshold
	local isFullGame = not managers.statistics:is_dropin()
	local canSend = catInd >= (Network:is_server() and Opt.serverSendThreshold or isFullGame and Opt.clientFullGameSendThreshold or Opt.clientMidGameSendThreshold)
	local tStr = _.g('managers.hud._hud_heist_timer._timer_text:text()')
	if canRead or canSend then
		_.c(tStr..(canSend and '' or _BROADCASTHDR_HIDDEN), text , canSend and self:_color(self.pid) or nil)
		if canSend then
			managers.network:session():send_to_peers_ip_verified( "send_chat_message", 1, tStr.._BROADCASTHDR..text )
		end
	end
end
function TPocoHud3:Float(unit,category,temp,tag)
	local key = unit.key and unit:key()
	if not key then return end
	local float = self.floats[key]
	if float then
		float:renew({tag=tag,temp=temp})
	else
		if category == 1 and not O.float.drills then
			--
		else
			self.floats[key] = TFloat:new(self,{category=category,key=key,unit=unit,temp=temp, tag=tag})
		end
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
				local text = {{(mMul>1 and _.f(mMul)..'x' or '')..(rMul>1 and ' '.._.f(rMul)..'x' or ''),clBad}}
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
	if false and supp and supp > 0 then -- disabled
		local supp2 = math.lerp( 1, tweak_data.player.suppression.spread_mul, supp )
		self:Buff({
			key= 'supp', good=false,
			icon=skillIcon,
			iconRect = { 7*64, 0*64,64,64 },
			text='', --_.f(supp2)..'x',
			st=supp, et=1
		})
	else
		self:RemoveBuff('supp')
	end

	local melee = self.state and self.state._state_data.meleeing and self.state:_get_melee_charge_lerp_value( t ) or 0
	if melee > 0 then
		self:Buff({
			key= 'charge', good=true,
			icon=skillIcon,
			iconRect = { 1*64, 3*64,64,64 },
			text='',
			st=melee, et=1
		})
	else
		self:RemoveBuff('charge')
	end
end

function TPocoHud3:_updatePlayers(t)
	if t-(self._lastUP or 0) > 0.1 then
		self._lastUP = t
	else
		return
	end
	local ranks = {'I','II','III','IV','V','V+'}
	for i = 1,4 do
		local name = self:_name(i)
		name = name ~= self:_name(-1) and name
		local nData = managers.hud:_name_label_by_peer_id( i )
		local isMe = i==self.pid
		local pnl = self['pnl_'..i]
		pnl = pnl ~= 0 and pnl or nil
		if pnl and not name then
			-- killPnl
			self.pnl.stat:remove(pnl)
			self['pnl_'..i] = nil
		elseif not pnl and name and (isMe or nData) then
			-- makePnl
			if managers.criminals:character_unit_by_name( managers.criminals:character_name_by_peer_id(i) ) then
				local cdata = managers.criminals:character_data_by_peer_id( i ) or {}
				local bPnl = managers.hud._teammate_panels[ isMe and 4 or cdata.panel_id or -1 ]
				if bPnl and not (not isMe and bPnl == managers.hud._teammate_panels[4]) then
					local member = self:_member(i)
					if member and alive(member:unit()) then
						local peer = member and member:peer()
						local rank = isMe and managers.experience:current_rank() or peer and peer:rank() or ''
						rank = ranks[rank] and (ranks[rank]..'Ї') or ''
						local lvl = isMe and managers.experience:current_level() or peer and peer:level() or ''
						local defaultLbl = bPnl._panel:child( "name" )
						local nameBg =  bPnl._panel:child( "name_bg" )
						self:_lbl(defaultLbl,{{rank,cl.White},{lvl..' ',cl.White:with_alpha(0.8)},{self:_name(i),self:_color(i)}})
						local txtRect = {defaultLbl:text_rect()}
						defaultLbl:set_size(txtRect[3],txtRect[4])
						local shape = {defaultLbl:shape()}
						nameBg:set_shape(shape[1]-3,shape[2],shape[3]+6,shape[4])

						pnl = self.pnl.stat:panel{x = 0,y=0, w=240,h=80}
						local wp = {bPnl._player_panel:world_position()}
						pnl:set_world_position(wp[1],wp[2]-30)

						--self['pnl_blur'..i] = pnl:bitmap( { name='blur', texture="guis/textures/test_blur_df", render_template="VertexColorTexturedBlur3D", layer=-1, x=0,y=0 } )
						self['pnl_lbl'..i] = pnl:text{name='lbl',align='right', text='-', font=FONT, font_size = O.info.size, color = cl.Red, x=1,y=0, layer=2, blend_mode = 'normal'}
						self['pnl_lblA'..i] = pnl:text{name='lblA',align='right', text='-', font=FONT, font_size = O.info.size, color = cl.Black:with_alpha(0.4), x=0,y=0, layer=1, blend_mode = 'normal'}
						self['pnl_lblB'..i] = pnl:text{name='lblB',align='right', text='-', font=FONT, font_size = O.info.size, color = cl.Black:with_alpha(0.4), x=2,y=0, layer=1, blend_mode = 'normal'}
						self['pnl_'..i] = pnl
					end
				end
			end
		end
		-- FillIn
		if pnl and (nData or isMe) then
			local lbl = self['pnl_lbl'..i]
			local cdata = managers.criminals:character_data_by_peer_id( i ) or {}
			local pInd = isMe and 4 or cdata.panel_id
			local bPnl = managers.hud._teammate_panels[ pInd ]
			local equip = (bPnl and #bPnl._special_equipment > 0)
			local interText = nData and nData.interact:visible() and nData.panel:child( "action" ):text()
			if isMe then
				interText = managers.hud._progress_timer
					and managers.hud._progress_timer._hud_panel:child( "progress_timer_text" ):visible()
					and managers.hud._progress_timer._hud_panel:child( "progress_timer_text" ):text()
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
			local color = self:_color(i)
			local boost = self:Stat(i,'boost') > now()
			local distance = unit and mvector3.distance(unit:position(),self.camPos) or 0
			local dist_sq = unit and mvector3.distance_sq(unit:position(),self.camPos) or 0
			local rally_skill_data = _.g('managers.player:player_unit():movement():rally_skill_data()')
			local canBoost = rally_skill_data and rally_skill_data.long_dis_revive and rally_skill_data.range_sq > dist_sq
			local ping = self:Stat(i,'ping')>0 and ' '..self:Stat(i,'ping')..'ms' or ''
			local lives =	isMe and managers.player:upgrade_value( "player", "additional_lives", 0) or 0
			local txts = {}
			if interText then
				txts[#txts+1]={' '..interText..'\n',color}
			end
			txts[#txts+1]={' '..Icon.Skull..kill,color}
			txts[#txts+1]={' '..Icon.Skull..killS,cl.Yellow:with_alpha(0.8)}
			if self.verbose then
				txts[#txts+1]={' !',color:with_red(1)}
				txts[#txts+1]={_.f(head/hit*100,1)..'%',color:with_red(1)}
				txts[#txts+1]={' '..avgDmg,color:with_alpha(0.8)}
				txts[#txts+1]={Icon.Times..accuracy..'%',accColor}
			end
			if boost then
				txts[#txts+1]={' '..Icon.Start or '',clGood:with_alpha(0.5)}
			end
			if distance>0 then
				txts[#txts+1]={' '..math.ceil(distance/100)..'m',(canBoost and clGood or clBad):with_alpha(0.8)}
			end
			txts[#txts+1]={ping,cl.White:with_alpha(0.5)}
			txts[#txts+1]={' '..Icon.Ghost..downs..(lives>0 and '/4' or ''),downs<3 and clGood or Color.red}

			if isMe and O.info.clock then
				txts[#txts+1]={os.date(' %X'),Color.white}
			end
			txts[#txts+1] = {' ',cl.White}
			if alive(lbl) and self['pnl_txt'..i]~=self:_lbl(nil,txts) then
				local txt = self:_lbl(lbl,txts)
				self['pnl_txt'..i]=txt
				self['pnl_lblA'..i]:set_text(txt)
				self['pnl_lblB'..i]:set_text(txt)
				local tr = {lbl:text_rect()}
				lbl:set_size(pnl:w(),tr[4])
				self['pnl_lblA'..i]:set_size(pnl:w(),tr[4])
				self['pnl_lblB'..i]:set_size(pnl:w(),tr[4])
				lbl:set_bottom(equip and 55 or 80)
				self['pnl_lblA'..i]:set_bottom(equip and 56 or 81)
				self['pnl_lblB'..i]:set_bottom(equip and 56 or 81)
				--local sh = {lbl:shape()}
				--self['pnl_blur'..i]:set_shape((sh[3]-tr[3])/2,sh[2],tr[3],tr[4])
			end

			local nLbl = nData and nData.text
			if alive(nLbl) then
				local member = self:_member(i)
				local peer = member and member:peer()
				local rank = peer and peer:rank() or ''
				rank = ranks[rank] and (ranks[rank]..'Ї') or ''
				local lvl = peer and peer:level() or '?'
				txts = {
					{rank,cl.White},{lvl..' ',cl.White:with_alpha(0.8)},
					{name,color},
					{' ('..math.ceil(distance/100)..'m)',color:with_alpha(0.5)}
				}
				self:_lbl(nLbl,txts)
				local x,__,w,h = nLbl:text_rect()
				nLbl:set_size(w,h)
				nData.bag:set_x(nLbl:x()+w)
				nData.panel:set_width(nLbl:x()+w + 20)
			end
		end
	end
end
function TPocoHud3:_isSimple(key)
	return O.buff.simpleBusy and (key == 'transition' or key == 'charge')
end
local _mask = World:make_slot_mask(1, 2, 8, 11, 12, 14, 16, 18, 21, 22, 25, 26, 33, 34, 35 )
--1, 11, 38
_mask = World:make_slot_mask(1, 8, 11, 12, 14, 16, 18, 21, 22, 24, 25, 26, 33, 34, 35 )
function TPocoHud3:_updateItems(t,dt)
	if self.dead then return end
	self.state = self.state or _.g('managers.player:player_unit():movement():current_state()')
	self.ADS= self.state and self.state._state_data.in_steelsight
	self:_scanSmoke(t)
	self:_updatePlayers(t)
	-- ScanFloat
	if O.float.unit then
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
	end
	-- ScanMinion
	for i = 1,4 do
		local minion = self:Stat(i,'minion')
		if minion and minion ~= 0 then
			if alive(minion) and minion:character_damage()._health > 0 then
				self:Float(minion,0,false,{minion = i})
			else
				local attacker = self:_name(self:Stat(i,'minionHit'))
				self:Stat(i,'minion',0)
				self:Chat('minionLost',_.s(self:_name(i),'lost a minion to',attacker,'.'))
			end
		end
	end
	-- ScanBuff
	self:_checkBuff(t)
	if t - (self._lastBuff or 0) >= 1/O.buff.maxFPS then
		self._lastBuff = t
		local style = O.buff.style
		local vanilla = style == 2
		local align = O.buff.align
		local size = (vanilla and 40 or O.buff.size) + O.buff.gap
		local count = 0
		for key,buff in pairs(self.buffs) do
			if not (buff.dead or buff.dying or self:_isSimple(key)) then
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
	local dO = O.debug
	if dO.verboseOnly then
		self.dbgLbl:set_visible(self.verbose)
	end
	self._keyList = ''--_.s(#(Poco._kbd:down_list() or {})>0 and Poco._kbd:down_list() or '')
	self._dbgTxt = _.s(self._keyList,self:lastError())
	local txts = {}
	if dO.showFPS then
		txts[#txts+1] = math.floor(1/dt)
	end
	if (inGame and dO.showClockIngame) or (not inGame and dO.showClockOutgame) then
		txts[#txts+1] = os.date('%X')
	end
	txts[#txts+1] = self._dbgTxt
	if t-(self._last_upd_dbgLbl or 0) > 0.5 or self._dbgTxt ~= self.__dbgTxt  then
		self.__dbgTxt = self._dbgTxt
		self.dbgLbl:set_text(string.upper(_.s(unpack(txts))))
		self._last_upd_dbgLbl = t
	end
end
function TPocoHud3:_drawStat(state,pnl)
	local ppnl = pnl or self.pnl.dbg
	if state then -- Show Stat
		local w, h, ww, hh = 0,0, ppnl:size()
		local pnl = ppnl:panel( { name='stat', visible=true, x=10, y=10, w=ww - 20, h=hh - 20} )
		local font,fontSize = tweak_data.menu.pd2_small_font, tweak_data.menu.pd2_small_font_size
		local _rowCnt = 0

		local host_list, level_list, job_list, mask_list, weapon_list = tweak_data.achievement.job_list, managers.statistics:_get_stat_tables()
		local risks = { "risk_pd", "risk_swat", "risk_fbi", "risk_death_squad", "risk_murder_squad"}
		local x, y, tbl = 5, 5, {}
		tbl[#tbl+1] = {{'Broker',cl.BlanchedAlmond},'Job',{Icon.Skull,cl.PaleGreen:with_alpha(0.3)},{Icon.Skull,cl.PaleGoldenrod},{Icon.Skull..Icon.Skull,cl.LavenderBlush},{string.rep(Icon.Skull,3),cl.Wheat},{string.rep(Icon.Skull,4),cl.Tomato},'Heat'}
		local addJob = function(host,heist)
			local job_string =managers.localization:to_upper_text(tweak_data.narrative.jobs[heist].name_id) or heist
			local pro = tweak_data.narrative.jobs[heist].professional
			if pro then
				job_string = {job_string, cl.Red}
			end
			local rowObj = {host:upper(),job_string}

			for i, name in ipairs( risks ) do
				local c = managers.statistics:completed_job( heist, tweak_data:index_to_difficulty( i + 1 ) )
				local f = managers.statistics._global.sessions.jobs[heist .. "_" .. tweak_data:index_to_difficulty( i + 1 ) .. "_started"] or 0
				if i > 1 or not pro then
					table.insert(rowObj, {{c, c<1 and cl.Salmon or cl.White:with_alpha(0.8)},{' / '..f,cl.White:with_alpha(0.4)}})
				else
					table.insert(rowObj, {c > 0 and c or 'N/A', cl.Tan:with_alpha(0.4)})
				end
			end
			local multi = managers.job:get_job_heat_multipliers(heist)
			local color = multi >= 1 and math.lerp( cl.Khaki, cl.Chartreuse, 2*(multi - 1) ) or math.lerp( cl.Crimson, cl.OrangeRed, multi )
			table.insert(rowObj,{{_.f(multi*100,5)..'%',color},{' ('..managers.job:get_job_heat(heist)..')',color:with_alpha(0.3)}})
			tbl[#tbl+1] = rowObj
		end
		for host,jobs in pairs(host_list) do
			for no,heist in pairs(jobs) do
				job_list[table.get_key(job_list,heist)] = nil
				addJob(host,heist)
			end
		end
		for no,heist in pairs(job_list) do
			addJob('N/A',heist) -- Just in case
		end
		local _lastHost = ''
		for row, _tbl in pairs(tbl) do
			if _lastHost == _tbl[1] then
				_tbl[1] = ''
			else
				_lastHost = _tbl[1]
			end
			_rowCnt = _rowCnt + 1
			y = self:_drawRow(pnl,fontSize,_tbl,x,y,970, _rowCnt % 2 == 0,{1,_rowCnt == 1 and 1 or 0})
		end

	else -- Hide Stat
		local fade = function(pnl,cb,seconds, ppnl)
			pnl:set_visible( true )
			pnl:set_alpha( 1 )
			local t = seconds
			while alive(pnl) and t > 0 do
				if me.verbose then
					break
				end
				local dt = coroutine.yield()
				t = t - dt
				pnl:set_alpha(t/seconds )
			end
			if not alive(pnl) then
				return
			end
			if not me.verbose then
				pnl:set_visible( false )
				ppnl:remove(pnl)
				me.dbgStat = nil
			else
				pnl:set_alpha(1)
			end
		end

		self.dbgStat:animate( fade, callback( self, self, "destroy" , true), 0.2, ppnl )

	end
end
function TPocoHud3:_scanSmoke(t)
	local smokeDecay = 3
	local units = World:find_units_quick( "all", World:make_slot_mask( 14 ))
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
				name = name..Icon.Times.._.s(smoke:base()._ammo_amount or smoke:base()._amount or smoke:base()._bodybag_amount or '?')
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
	if self.dead then return end
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
	elseif str == 'Unit' then
			return self:_name(something:base()._tweak_table)
	elseif str == 'string' then -- tweak_table name
		local pName = managers.criminals:character_peer_id_by_name( something )
		if pName then
			return self:_name(pName)
		else
			local conv = O.conv
			return conv[something] or 'AI'
		end
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
				if me.dead then
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
	if not inGame then
		-- Moved Heist stat to DbgLbl
	else
		--PlayerStandards
		hook( PlayerStandard, '_update_check_actions', function( self ,...)
			if not me.menuGui then
				Run('_update_check_actions', self,... )
			end
		end)

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
		-- PlayerManager
		hook( PlayerManager, 'drop_carry', function( self ,...)
			Run('drop_carry', self,... )
			pcall(me.Buff,me,({
				key='drop_carry', good=false,
				icon=skillIcon, iconRect = {6*64, 0*64, 64, 64},
				text='',
				st=Application:time(), et=managers.player._carry_blocked_cooldown_t
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
		hook( PlayerStandard, '_end_action_running', function( self,t, input, complete  )
			Run('_end_action_running', self, t, input, complete )
			local et = self._end_running_expire_t
			if not (self.RUN_AND_SHOOT or O.buff.noSprintDelay) and et then
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
					key='interaction', good=true,
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
					text='',
					st=now(), et=et
				}) )
			end
		end)
		hook( PlayerDamage, '_look_for_friendly_fire', function( self, attacker_unit )
			me._lastAttkUnit = attacker_unit
			return Run('_look_for_friendly_fire', self, attacker_unit)
		end)
		if O.hitDirection.replace then
			hook( PlayerDamage, '_hit_direction', function( self, col_ray )
				if not col_ray then
					Run('_hit_direction', self, col_ray)
				end -- Nullify if possible
			end)
			local _hitDirection = function(self,result,data,shield)
				local sd = self._supperssion_data and self._supperssion_data.decay_start_t
				if sd then
					sd = math.max(0,sd-now())
				end
				local et = (self._regenerate_timer or 0)+(sd or 0)
				if et == 0 then
					et = 2 -- Failsafe
				end
				me:HitDirection(data.col_ray,{dmg=result,shield=shield,time=et})
			end
			hook( PlayerDamage, '_calc_armor_damage', function( self, attack_data )
				local valid = self:get_real_armor() > 0
				local result = Run('_calc_armor_damage', self, attack_data)
				if valid then
					_hitDirection(self,result,attack_data,true)
				end
				return result
			end)
			hook( PlayerDamage, '_calc_health_damage', function( self, attack_data )
				local result = Run('_calc_health_damage', self, attack_data)
				if result > 0 then
					_hitDirection(self,result,attack_data,false)
				end
				return result
			end)
		end
		hook( PlayerDamage, 'consume_messiah_charge', function( self)
			local result = Run('consume_messiah_charge', self)
			if result then
				me:Chat('messiah',_.s('Used pistol messiah.', self._messiah_charges ,'left'))
			end
			return result
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
			me:AddDmgPopByUnit(attacker_unit,subject_unit,height_offset,damage*-0.1953125,death,head,'bullet')
			return Run('damage_bullet',...)
		end)
		hook( UnitNetworkHandler, 'damage_explosion', function(...)
			local self, subject_unit, attacker_unit, damage, i_attack_variant, death, direction, sender = unpack({...})
			me:AddDmgPopByUnit(attacker_unit,subject_unit,0,damage*-0.1953125,death,false,'explosion')
			return Run('damage_explosion', ... )
		end)
		hook( UnitNetworkHandler, 'damage_melee', function(...)
			local self, subject_unit, attacker_unit, damage, damage_effect, i_body, height_offset, variant, death, sender  = unpack({...})
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
					me:AddDmgPop(info.attacker_unit,hitPos,self._unit,0,info.damage,self._dead,head,info.variant)
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
					me:Chat('dominated',me:_name(self._unit)..' around '..me:_name(me:_pos(self._unit))..' has been captured.'..(me._hostageTxt or ''))
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
		hook( UnitNetworkHandler, 'mark_minion', function( self,  ... )
			local unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender = unpack{...}
			Run('mark_minion', self, ... )
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

		local OnCriminalHealth = function(pid,data)
			local percent = (pid==self.pid and data.current/data.total or data.current)*100
			local bPercent = self:Stat(pid,'health')
			local down = self:Stat(pid,'down')
			if percent >= 99.8 and bPercent < percent then
				if bPercent ~= 0 and self:_name(pid) ~= self:_name(-1) then
					self:Chat('replenished',self:_name(pid)..' replenished health by '.._.f(percent-bPercent)..'%'..(down>0 and '(+'..down..' down'..(down>1 and 's' or '')..')' or ''))
				end
				self:Stat(pid,'custody',0)
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
		end)
		local OnCriminalDowned = function(pid)
			self:Stat(pid,'down',1,true)
			if self:Stat(pid,'down') >= 3 then
				self:Chat('downedWarning','Warning:'..me:_name(pid)..' has been downed '..me:Stat(pid,'down')..' times.')
			else
				self:Chat('downed',me:_name(pid)..' was downed.')
			end
		end
		hook( PlayerBleedOut, '_enter', function( self, ... )
			OnCriminalDowned(me.pid)
			return Run('_enter', self,  ...)
		end)
		hook( HuskPlayerMovement, '_get_max_move_speed', function( self, ... )
			return Run('_get_max_move_speed', self,  ...) * 3
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
			for __, data in pairs( managers.criminals._characters ) do
				if data.taken and criminal_name == data.name then
					pid = data.peer_id
				end
			end
			if pid and self:Stat(pid,'custody') == 0 then
				self:Stat(pid,'downAll',self:Stat(pid,'down'),true)
				self:Stat(pid,'down',0)
				self:Stat(pid,'custody',1)
				self:Stat(pid,'health',0)
				self:Chat('custody',self:_name(pid)..' is in custody.')
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
			me:Float(unit,1)
			return result
		end)
		hook( DigitalGui, 'update*', function( ... )
			local self, unit, t, dt = unpack({...})
			local result = Run('update*', ...)
			if self:is_timer() then
				me:Float(unit,1)
			end
			return result
		end)
		-- Spot
		hook( ContourExt, 'add', function( ... )
			local self, type, sync, multiplier = unpack({...})
			local result = Run('add', ...)
			me:Float(self._unit,0,result.fadeout_t or now()+4)
			return result
		end)
		hook( ContourExt, '_upd_color', function( ... )
			local self = unpack({...})
			local idstr_contour_color = Idstring( "contour_color" )
			local minionClr = false
			Run('_upd_color', ...)
			for i = 1, 4 do
				if not minionClr and me:Stat(i,'minion')==self._unit then
					minionClr = me:_color(i)
				end
			end
			if minionClr then
				for __, material in ipairs( self._materials or {}) do
					material:set_variable( idstr_contour_color, Vector3(minionClr.r/1.5,minionClr.g/1.5,minionClr.b/1.5))
				end
			end
		end)
		-- AmmoUsage
		hook( HUDTeammate, 'set_ammo_amount_by_type', function( ... )
			local self, type, max_clip, current_clip, current_left, max = unpack({...})
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
		-- Teammate Interaction
		--[[	local text = managers.localization:text( text_id, string_macros )
		hook( HUDManager, 'teammate_progress', function( ... )
			local self, peer_id, type_index, enabled, tweak_data_id, timer, success = unpack({...})
			local action_text = managers.localization:text( tweak_data.interaction[ tweak_data_id ].action_text_id or "hud_action_generic" )

			if enabled then
				me:Stat(peer_id,'interact',{tweak_data_id,timer})
			else
				me:Stat(peer_id,'interact',0)
			end
			return Run('teammate_progress', ...)
		end)]]

		-- Joining
		hook( MenuManager, 'show_person_joining', function( ... )
			local self, id, nick = unpack({...})
			self['_joinT_'..id] = os.clock()
			local result = Run('show_person_joining', ...)

			local peer = managers.network:session():peer(id)
			if peer and 0 < peer:rank() then
				managers.hud:post_event("infamous_player_join_stinger")
				local dlg = managers.system_menu:get_dialog("user_dropin" .. id)
				if dlg then
					local name = peer:level()..' '..string.upper(nick)
					if peer:rank()>0 then
						name = peer:rank()..'-'..name
					end
					dlg:set_title(_.s(
						managers.localization:text("dialog_dropin_title", {	USER = name	})
						))
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
			local dlg = managers.system_menu:get_dialog("user_dropin" .. id)
			if dlg then
				dlg:set_text(_.s(
					managers.localization:text("dialog_wait"), progress_percentage.."%",
					tT-dT,'s left'
					))
			end
		end)
		-- Hide interaction circle
		if O.buff.hideInteractionCircle then
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
		-- Mouse hook plugin
		hook( MenuComponentManager, 'mouse_moved', function( ... )
			local self, o, x, y = unpack{...}
			if me.menuGui then
				return me.menuGui:mouse_moved(o, x, y)
			end
			return Run('mouse_moved', ...)
		end)
		hook( MenuComponentManager, 'mouse_pressed', function( ... )
			local self, o, button, x, y = unpack{...}
			if me.menuGui and me.menuGui.mouse_pressed then
				local used, pointer = me.menuGui:mouse_pressed(o, button, x, y)
				if used then
					return true, pointer
				end
			end
			return Run('mouse_pressed', ...)
		end)
		hook( MenuComponentManager, 'mouse_released', function( ... )
			local self, o, button, x, y = unpack{...}
			if me.menuGui and me.menuGui.mouse_released then
				local used, pointer = me.menuGui:mouse_released(o, button, x, y)
				if used then
					return true, pointer
				end
			end
			return Run('mouse_released', ...)
		end)
		hook( MenuManager, 'toggle_menu_state', function( ... )
			me:Menu(true) -- dismiss Menu when actual game-menu is called
			return Run('toggle_menu_state', ...)
		end)
		-- Kick menu
		hook( KickPlayer, 'modify_node', function( ... )
			local self, node, up = unpack{...}
			local new_node = deep_clone( node )
			if managers.network:session() then
				for __,peer in pairs( managers.network:session():peers() ) do
					local rank = peer:rank()
					local params = {
									name			= peer:name(),
									text_id			= _.s((rank and rank..'-' or '')..(peer:level() or '?'),peer:name()),
									callback		= "kick_player",
									to_upper		= false,
									localize		= "false",
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

	end
end
--- Utility functions ---
function TPocoHud3:toggleVerbose(state)
	self.verbose = state
end
function TPocoHud3:test()
-- reserved
	self:Menu()
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
function TPocoHud3:_drawRow(pnl, fontSize, texts, _x, _y, _w, bg, align)
	local _fontSize = fontSize * 1
	if bg then
		pnl:rect( { x=_x,y=_y,w=_w,h=_fontSize,color=cl.White, alpha=0.05, layer=0 } )
	end
	local count = #texts
	local iw = _w / count
	local isCenter = function(i)
		return align == true or (type(align)=='table' and align[i]~=0)
	end
	for i,text in pairs(texts) do
		if text ~= '' then
			local res, lbl = _.l({ pnl=pnl,font=FONT, color=cl.White, font_size=fontSize * 0.92, x=_x + iw*(i-0.5), y=math.floor(_y)+1, text='', blend_mode='add'},text,true)
			if isCenter(i) then
				lbl:set_center_x(math.round(_x + iw*(i-0.5)))
			else
				lbl:set_x(math.round(_x+iw*(i-1)))
			end
		end
	end
	return _y + _fontSize
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