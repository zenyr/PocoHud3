local TRUE,FALSE = true,false
local scheme = {
	root = {	'PocoHud3 Main configuration',
		enable = {'bool',TRUE,nil,'Not implemented.'},
		verboseKey = {'key','`',nil,'Keybind for verbose mode.\nDefault: ` (tilde key)\nRequires reloading'},
		verboseToggle = {'bool',FALSE,nil,'Toggle verbose mode.\nRequires reloading'},
	}, corner = {	'Static text ticker which works as FPS counter / Outgame clock',
		color  = {'color','White','color','Font color'},
		opacity = {'num',80,{0,100},'Font opacity',nil,5},
		size  = {'num',22,{10,30},'Font size'},
		defaultFont  = {'bool',FALSE,nil,'Use sans-serif font'},
		verboseOnly  = {'bool',FALSE,nil,'Hide corner text while \'Verbose\' mode is not activated'},
		showFPS  = {'bool',TRUE,nil,'Show FPS'},
		showClockIngame  = {'bool',FALSE,nil,'Show in-game clock'},
		showClockOutgame  = {'bool',TRUE,nil,'Show out-game clock'},
	}, buff = {	'Shows realtime buff status',
		enable = {'bool',TRUE},

		xPosition = {'num',10,{0,100},'Origin point X (% from left of screen)',nil,2,1},
		yPosition = {'num',22,{0,100},'Origin point Y (% from top of screen)',nil,2,2},
		maxFPS  = {'num',50,nil,'FPS cap to reduce performance hit',nil,5,3},
		buffSize = {'num',70,nil,'Icon size (ignored with Vanilla style)',nil,nil,4},
		gap = {'num',10,nil,'Icon gap',nil,nil,5},
		justify = {'num',1,{1,3},'Icon alignment (vertical for Vanilla style)','align',nil,6},
		style = {'num',1,{1,2},'Buff icon style','style',nil,7},

		hideBerserker = {'bool',FALSE,nil,'Berserker indicator'},
		hideStamina = {'bool',FALSE,nil,'Stamina indicator'},
		hideCharge = {'bool',FALSE,nil,'Melee charge indicator'},
		hideTransition = {'bool',FALSE,nil,'Transitions like weapon swap, melee cooldown'},
		hideCarryDrop = {'bool',FALSE,nil,'Bag interaction cooldown'},
		hideInteract = {'bool',FALSE,nil,'Shout cooldown'},
		hideInteraction = {'bool',FALSE,nil,'Interaction timer that involves holding USE key'},
		hideInspire = {'bool',FALSE,nil,'Inspire cooldown (giving end)'},
		hideBoost = {'bool',FALSE,nil,'Inspire duration (receiving end)'},
		hideShield = {'bool',FALSE,nil,'Shield recovery cooldown'},
		hideECM = {'bool',FALSE,nil,'ECM duration'},
		hideFeedback = {'bool',FALSE,nil,'ECM Feedback duration'},
		hideTapeLoop = {'bool',FALSE,nil,'Tapeloop duration'},
		hideOverkill = {'bool',FALSE,nil,'Overkill duration'},
		hideCombatMedic = {'bool',FALSE,nil,'Combat medic duration'},
		hideUnderdog = {'bool',FALSE,nil,'Underdog duration'},
		hideBulletstorm = {'bool',FALSE,nil,'Bulletstorm duration'},
		hideSuppressed = {'bool',TRUE,nil,'Suppression that prevents shield recovery and increases bullet deviation.\n(Bullet deviation not in effect)'},

		noSprintDelay  = {'bool',TRUE,nil,'Ignore after-sprint delay '},
		hideInteractionCircle  = {'bool',FALSE,nil,'Hide vanilla game\'s interaction circle'},
		simpleBusyIndicator = {'bool',TRUE,nil,'Replace \'busy\' icons with simple red circle at the crosshair\nSuch as: Reloading, Weapon-swap, melee'},
		simpleBusySize = {'num',10,{5,30},'Set size of SimpleBusy indicator if simpleBusy is used',nil,5},
	}, playerFloat = {	'Floating info panel above crew members\' head',
		enable = {'bool',TRUE},
		uppercaseNames = {'bool',TRUE,nil,'Name as uppercase'},
		showIcon = {'num',2,{0,2},'Infamy Spade icon','Verbose'},
		showRank = {'num',2,{0,2},'e.g) V-100','Verbose'},
		showDistance = {'num',2,{0,2},'e.g) 25m','Verbose'},
		showInspire = {'num',2,{0,2},'Inspire speed-boost','Verbose'},
	}, playerBottom = {	'Info text at the bottom of the HUD',
		enable = {'bool',TRUE},
		size = {'num',17,{15,30},'Text size',nil,2},
		offset = {'num',0,{-30,30},'Vertical offset if you REALLY want to move it around',nil,2},
		underneath = {'bool',TRUE,nil,'Put PlayerBottom infobox at the very bottom of the screen'},
		showClock = {'num',2,{0,2},'Put a clock after local player info','Verbose'},
		showRank = {'bool',TRUE,nil,'Add Infamy & level info in front of player names'},
		showInteraction = {'num',2,{0,2},'Interaction label if one is busy','Verbose'},
		showInteractionTime = {'num',2,{0,2},'How much time left','Verbose'},
		showKill = {'num',2,{0,2},'Kill counter','Verbose'},
		showSpecial = {'num',2,{0,2},'Special kill counter','Verbose'},
		showInspire = {'num',2,{0,2},'Inspire boost status (if casted by local player)','Verbose'},
		showAverageDamage = {'num',1,{0,2},'Average Damage per bullet','Verbose'},
		showDistance = {'num',2,{0,2},'Distance boost status (if casted by local player)','Verbose'},
		showDowns = {'num',2,{0,2},'Downs counter','Verbose'},
		showPing = {'num',1,{0,2},'Distance as meter','Verbose'},
		showMinion = {'num',1,{0,2},'Minion health as percent if one has any','Verbose'},
	}, popup = {	'Shows damages in 3D space',
		enable = {'bool',TRUE},
		size  = {'num',22,{10,30},'Text size'},
		damageDecay  = {'num',10,{3,15},'Decay time'},
		myDamage  = {'bool',TRUE,nil,'Show local player\'s damage'},
		crewDamage  = {'bool',TRUE,nil,'Show other player\'s damage'},
		AIDamage  = {'bool',TRUE,nil,'Show AI\'s damage'},
		handsUp  = {'bool',TRUE,nil,'Show when an AI is going to surrender'},
		dominated  = {'bool',TRUE,nil,'Show when an AI has cuffed himself'},

	}, chat = {	{'If an event listed below happens and fulfill set condition, PocoHud will tell others through chat.\nPossible targets are:\n',{' No one: No One\n',cl.White:with_alpha(1)},{' Only me: Only me\n',cl.White:with_alpha(1)},{' Everyone-Host: Everyone if I am host\n',cl.White:with_alpha(1)},{' Everyone-EM: Everyone if I have attended the entire match\n',cl.White:with_alpha(1)},{' Everyone-Alone: Everyone if I am the only one who has PocoHud\n',cl.White:with_alpha(1)},{' Everyone-Always: Everyone, regardless of someone else already broadcasted with PocoHud or not',cl.White:with_alpha(1)}},
		enable = {'bool',TRUE},
		fallbackToMe = {'bool',TRUE,nil,'if an event is set to be sent to everyone but the condition is not fulfilled, show it to myself instead.',nil,nil,1},
		midstatAnnounce = {'num',0,{0,2},'Announce stats on every X kills. Considered as \'Midgame stat\'','MidStat',nil,2},
		midStat  = {'num',1,{0,2},'Midgame stat. (limited to ServerSend)','ChatSend',nil,2},
		endStat  = {'num',2,{0,4},'Endgame stat','ChatSend',nil,2},
		endStatCredit  = {'num',2,{0,4},'PocoMods group plug after endgame stat ;)','ChatSend',nil,2},
		dominated  = {'num',2,{0,4},'Someone dominated a police enforcer','ChatSend',nil,2},
		converted  = {'num',2,{0,4},'Someone converted a police enforcer','ChatSend',nil,2},
		minionLost  = {'num',2,{0,4},'Someone lost a minion','ChatSend',nil,2},
		minionShot  = {'num',4,{0,4},'Someone shot a minion','ChatSend',nil,2},
		hostageChanged  = {'num',2,{0,4},'Hostage count has been changed (Not implemented)','ChatSend',nil,2},
		custody  = {'num',2,{0,4},'Someone is in custody','ChatSend',nil,2},
		downed  = {'num',1,{0,4},'Someone is downed','ChatSend',nil,2},
		downedWarning  = {'num',4,{0,4},'Someone is downed more than twice in a row','ChatSend',nil,2},
		replenished  = {'num',3,{0,4},'Someone replenished health(usually by Med kit)','ChatSend',nil,2},
		messiah  = {'num',5,{0,5},'You consumed a pistol messiah shot','ChatSend',nil,2},
		drillDone = {'num',2,{0,4},'A drill is done.\n* Requires Float-Drill option enabled','ChatSend',nil,2},
		drillAlmostDone = {'num',2,{0,4},'A drill has less than 10 seconds left.\n* Requires Float-Drill option enabled','ChatSend',nil,2},
	}, hit = {	'Hit indicator that shows where you\'ve been shot from',
		enable = {'bool',TRUE},
		duration  = {'num',0,{0,10},'Seconds. 0 means auto (follows shield recovery time)','Auto'},
		opacity  = {'num',50,{0,100},'Max opacity',nil,5},
		number  = {'bool',TRUE,nil,'Show the exact amount you lost'},
		numberSize  = {'num',25,{20,30},'Number size'},
		numberDefaultFont  = {'bool',FALSE,nil,'Number uses default font'},
		sizeStart  = {'num',100,{50,150},'Size at the beginning',nil,50},
		sizeEnd  = {'num',200,{100,300},'Size at the end',nil,50},
		shieldColor = {'color','LawnGreen','color','Shield lost color, full amount'},
		healthColor = {'color','Red','color','Health lost color, full amount'},
		shieldColorDepleted = {'color','Aqua','color','Shield lost color, depleted'},
		healthColorDepleted = {'color','Magenta','color','Health lost color, depleted'},
	}, float = {	'Floating infobox in 3D position',
		enable = {'bool',TRUE},
		border = {'bool',FALSE,nil,'Alternative box background'},
		size = {'num',15,{10,20},'Font size'},
		margin = {'num',3,{0,5},'Box inner padding'},
		keepOnScreen = {'bool',TRUE,nil,'Keep floating boxes on screen'},
		keepOnScreenMarginX = {'num',2,{0,20},'Margin for Left and Right'},
		keepOnScreenMarginY = {'num',15,{0,20},'Margin for Top and Bottom'},
		opacity  = {'num',90,{10,100},'Max opacity',nil,5},
		unit = {'bool',TRUE,nil,'Show pointed mobs'},
		drills = {'bool',TRUE,nil,'Show active drills'},
		highlight = {'bool',TRUE,nil,'Configuration not implemented'},
		minion = {'bool',TRUE,nil,'Configuration not implemented'},
		bags = {'bool',TRUE,nil,'Configuration not implemented'},
	}, game = {	'Game specific enhancements',
		fasterDesyncResolve = {'num',2,{1,3},'In-game Player husks will catch up severe desync faster and represent more accurate position.\n','DesyncResolve'},
		ingameJoinRemaining = {'bool',TRUE,nil,'In-game SOMEONE IS JOINING dialog will show you how many seconds left'},
		kickMenuRank = {'bool',TRUE,nil,'In-game Kick menu will display player levels with their name'},
		corpseLimit = {'num',3,{1,10},'In-game corpse limit\nDefault is 8.\nEach step multiplies/divides result by 2.','corpse'},
		cantedSightCrook = {'num',4,{1,4},'In-game canted sight(as gadget) indicator','cantedSight'},
		rememberGadgetState = {'bool',TRUE,nil,'Remembers gadget(laser, flashlight, angled sight) status between weapon swaps'},
		subtitleFontSize = {'num',20,{10,30},'Subtitle font size'},
		subtitleFontColor = {'color','White',nil,'Subtitle font color'},
		subtitleOpacity = {'num',100,{10,100},'Subtitle opacity',nil,10},
	}
}
local _vanity = {
	ChatSend = 'No one,Only me,Everyone-Host,Everyone-EM,Everyone-Alone,Everyone-Always',
	Verbose = 'Never,Verbose only,Always',
	MidStat = 'Never,50,100',
	align = 'none,Start,Middle,End',
	style = 'N/A,PocoHud,Vanilla',
	Auto = 'Auto',
	DesyncResolve = 'N/A,Off,Faster,Aggressive',
	corpse = 'N/A,Minimum,Less,Default,More,a Lot,Considerable,Massive,Mammoth,Colossal,Ridiculous',
	cantedSight = 'N/A,Off,Subtle,Obvious,Maximum',
}
----------------------------------------------------
local JSONFileName = 'poco\\hud3_config.json'
local KitsJSONFileName = 'poco\\hud3_kits.json'
local isNil = function(a)
	return a == nil
end

local Option = class()
PocoHud3Class.Option = Option
function Option:init()
	self:default()
	self.scheme = scheme
end

function Option:reset()
	os.remove(JSONFileName)
end

function Option:default()
	self.items = {}
end

function Option:load()
	local f,err = io.open(JSONFileName, 'r')
	local result = false
	if f then
		local t = f:read('*all')
		local o = JSON:decode(t)
		if type(o) == 'table' then
			self.items = o
		end
		f:close()
	end
end

function Option:save()
	local f = io.open(JSONFileName, 'w')
	if f then
		f:write(JSON:encode_pretty(self.items))
		f:close()
	end
end


function Option:_type(category,name)
	return self:_get(true,category,name)[1]
end

function Option:_range(category,name)
	return self:_get(true,category,name)[3]
end

function Option:_hint(category,name)
	return self:_get(true,category,name)[4]
end

function Option:_vanity(category,name)
	local vanity = self:_get(true,category,name)[5]
	if vanity then
		vanity = (_vanity[vanity] or '?'):split(',')
	end
	return vanity
end

function Option:_step(category,name)
	return self:_get(true,category,name)[6]
end

function Option:_sort(category,name)
	return self:_get(true,category,name)[7]
end

function Option:set(category, name, value)
	self.items[category] = self.items[category] or {}
	self.items[category][name] = value
end

function Option:_get(isScheme, category,name)
	local o = isScheme and self.scheme or self.items
	local result = o[category] and o[category][name]
	if isNil(result) then
		if isScheme then
			_('_get was Nil', category, name) -- this should NOT happen
		end
		result = isScheme and {} or nil
	end
	return result
end

function Option:get(category,name,raw)
	if not name then
		return self:getCategory(category,raw)
	end
	local result = self:_get(false,category,name)
	if result == nil then
		result = self:_default(category,name)
	end
	if not raw then
		local type = self:_type(category,name)
		if type == 'color' then
			return cl[result] or cl.White
		end
	end
	return result
end

function Option:getCategory(category,raw)
	local result = {}
	for name in pairs(self.scheme[category] or {}) do
		result[name] = self:get(category,name,raw)
	end
	return result
end

function Option:_default(category,name)
	return self:_get(true,category,name)[2]
end

function Option:isDefault(category,name,value)
	return value == self:_default(category,name)
end

function Option:isChanged(category,name,value)
	return value ~= self:get(category,name)
end
----------------------------------
-- Kits : Kit profiler
----------------------------------
local Kits = class()
PocoHud3Class.Kits = Kits

function Kits:init()
	self.items = {}
	self:load()
end

function Kits:load()
	local f,err = io.open(KitsJSONFileName, 'r')
	local result = false
	if f then
		local t = f:read('*all')
		local o = JSON:decode(t)
		if type(o) == 'table' then
			self.items = o
		end
		f:close()
	end
end

function Kits:save()
	local f = io.open(KitsJSONFileName, 'w')
	if f then
		f:write(JSON:encode_pretty(self.items))
		f:close()
	end
end

function Kits:locked(index,category)
	local val = self:get(index,category)
	local funcs = {
		primaries = function()
			local weapon_data = Global.blackmarket_manager.weapons
			local obj = val and managers.blackmarket:get_crafted_category_slot(category, val)
			local w_id = obj and obj.weapon_id
			local w_data = w_id and weapon_data[w_id]
			if not w_data then
				return _.s('Slot',val,'is empty')
			end
			local unlocked = w_data.unlocked
			return not unlocked and 'Locked'
		end,
		gadget = function()
			return not table.contains(managers.player:availible_equipment(1), val) and 'Locked'
		end,
		armor = function()
			local obj = val and Global.blackmarket_manager.armors[val]
			local unlocked = obj and obj.unlocked
			return not unlocked and 'Locked'
		end,
		melee = function()
			local obj = val and Global.blackmarket_manager.melee_weapons[val]
			local unlocked = obj and obj.unlocked
			return not unlocked and 'Locked'
		end,
		color = function() return end
	}
	funcs.secondaries = funcs.primaries
	if funcs[category] then
		local r,err = pcall(funcs[category])
		if r then
			return err
		else
			PocoHud3:err(err)
		end
	else
		return 'Unknown Cat'..category
	end
end

function Kits:equip(index)
	local _uoi = MenuCallbackHandler._update_outfit_information
	MenuCallbackHandler._update_outfit_information = function() end -- Avoid repeated submit
	local msg = {}

	local r,err = pcall(function()
		local obj = self.items[index]
		if not obj then return false end
		for cat, slot in pairs(obj) do
			if self:locked(index,cat) then
				-- msg[#msg+1] = _.s('[',cat:upper(),'] was invalid(Reason: ',self:locked(index,cat),'). ignored.\n')
			else
				if cat == 'primaries' or cat == 'secondaries' then
					managers.blackmarket:equip_weapon(cat,slot)
				elseif cat == 'color' then
					-- ignore
				elseif cat == 'armor' then
					managers.blackmarket:equip_armor(slot)
				elseif cat == 'gadget' then
					managers.blackmarket:equip_deployable(slot)
				elseif cat == 'melee' then
					managers.blackmarket:equip_melee_weapon(slot)
				else
					_('KitsEquip:',cat,'?')
				end
			end
		end
	end)
	if not r then msg = {err} end
	local mcm = _.g('managers.menu_component._mission_briefing_gui:reload()')

	MenuCallbackHandler._update_outfit_information = _uoi -- restore
	MenuCallbackHandler:_update_outfit_information()

	if #msg > 0 then
		managers.system_menu:show{
			button_list = { {
					cancel_button = true,
					text = 'OK'
				} },
			text = table.concat(msg),
			title = 'Kits Profiler'
		}
	end
end

function Kits:get(index,category,asText)
	if not index then return end
	local obj
	if not self.items[index] then
		self.items[index] = {}
	end
	obj = self.items[index]
	if category == nil then
		return obj
	end
	local _asText = {
		primaries = function(val)
			local obj = val and managers.blackmarket:get_crafted_category_slot(category, val) --Global.blackmarket_manager.crafted_items[category][val]
			if obj then
				local s = managers.weapon_factory:has_perk( 'silencer', obj.factory_id, obj.blueprint ) and PocoHud3Class.Icon.Ghost or ''
				return s..managers.blackmarket:get_weapon_name_by_category_slot(category,val)
			elseif val then
				return 'N/A'
			end
		end,
		armor = function(val)
			local tweak = val and tweak_data.blackmarket.armors[val]
			local name = tweak and managers.localization:text(tweak.name_id) or '?'
			if val == 'level_7' or val == 'level_6' then
				name = name:gsub('%U','')
			end
			return tweak and name
		end,
		gadget = function(val)
			return val and managers.localization:text(tweak_data.blackmarket.deployables[val].name_id)
		end,
		melee = function (val)
			local tweak = val and tweak_data.blackmarket.melee_weapons[val]
			return tweak and managers.localization:text(tweak.name_id)
		end,
		color = function(a) return a end
	}
	_asText.secondaries = _asText.primaries
	return asText and _asText[category](obj[category]) or obj[category]
end

--[[function Kits:set(index,category,slot)
	if not slot then
		if category == 'primaries' then
			local obj = Global.blackmarket_manager.crafted_items or {}
			for _slot, obj in pairs(obj) do
				if obj.equipped then
					slot = _slot
				end
			end
		end
	end
	if not slot then
		return
	end
	if self:get(index,category) ~= slot then
		self.items[index][category] = slot
		return slot
	end
end]]

function Kits:current(category,raw)
	local result
	local obj
	local a,b = {
		primaries = function()
			obj = Global.blackmarket_manager.crafted_items[category]
		end,
		armor = function()
			obj = Global.blackmarket_manager.armors
		end,
		gadget = function()
			obj = Global.player_manager.kit.equipment_slots
		end,
		melee = function()
			obj = Global.blackmarket_manager.melee_weapons
		end
	},{
		primaries = function(_slot,obj)
			if obj.equipped then
				if raw then
					return _slot
				else
					local s = managers.weapon_factory:has_perk( 'silencer', obj.factory_id, obj.blueprint ) and PocoHud3Class.Icon.Ghost or ''
					return s..managers.blackmarket:get_weapon_name_by_category_slot(category,_slot)
				end
			end
		end,
		armor = function(aID,obj)
			local armor = Global.blackmarket_manager.armors[aID]
			if armor.equipped and armor.unlocked and armor.owned then
				if raw then
					return aID
				else
					local tweak = tweak_data.blackmarket.armors[aID]
					return managers.localization:text(tweak.name_id)
				end
			end
		end,
		gadget = function(__,obj)
			return raw and obj or managers.localization:text(tweak_data.blackmarket.deployables[obj].name_id)
		end,
		melee = function (_slot,obj)
			if obj.equipped then
				if raw then
					return _slot
				else
					local tweak = tweak_data.blackmarket.melee_weapons[_slot]
					return managers.localization:text(tweak.name_id)
				end
			end
		end
	}
	a.secondaries = a.primaries
	b.secondaries = b.primaries
	if a[category] and b[category] then
		a[category]()
	else
		return category..'?'
	end
	for _slot, obj in pairs(obj) do
		local r = b[category](_slot, obj)
		if r then return r end
	end
	return '??'
end