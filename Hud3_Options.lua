local TRUE,FALSE = true,false
local scheme = {
	root = {	'PocoHud3 Main configuration',
		enable = {'bool',TRUE,nil,'Not working :)'},
		verboseKey = {'key','`',nil,'Keybind for verbose mode'},
		verboseToggle = {'bool',FALSE,nil,'Toggle verbose mode'},
	}, corner = {	'Static text ticker which works as FPS counter / Outgame clock',
		color  = {'color','White','color'},
		size  = {'num',22,{10,30},'Font size'},
		defaultFont  = {'bool',FALSE,nil,'Use sans-serif font'},
		verboseOnly  = {'bool',FALSE,nil,'Only show while \'Verbose\' mode is on'},
		showFPS  = {'bool',TRUE},
		showClockIngame  = {'bool',FALSE,nil,'Show in-game clock'},
		showClockOutgame  = {'bool',TRUE,nil,'Show out-game clock'},
	}, buff = {	'Shows realtime buff status',
		enable = {'bool',TRUE},

		originLeft = {'num',10,{0,100},'Origin point X (%)'},
		originTop = {'num',22,{0,100},'Origin point Y (%)'},
		maxFPS  = {'num',50,nil,'FPS cap to reduce performance hit'},
		size = {'num',70,nil,'Icon size (ignored with Vanilla style)'},
		gap = {'num',10,nil,'Icon gap'},
		align = {'num',1,{1,3},'Icon alignment (vertical for Vanilla style)','align'},
		style = {'num',1,{1,2},'Buff icon style','style'},

		noSprintDelay  = {'bool',TRUE,nil,'Ignore after-sprint delay '},
		hideInteractionCircle  = {'bool',FALSE,nil,'Hide vanilla game\'s interaction circle'},
		simpleBusy  = {'bool',TRUE,nil,'Replace \'busy\' icons with simple red circle at the crosshair'},
		simpleBusyRadius  = {'num',10,{5,30},'Set size of SimpleBusy indicator if simpleBusy is used'},
	}, playerFloat = {	'Floating info panel above crew members\' head',
		enable = {'bool',TRUE},
		showRank = {'num',2,{0,2},'e.g) V-100','Verbose'},
		showDistance = {'num',2,{0,2},'e.g) 25m','Verbose'},
		showInspire = {'num',2,{0,2},'Inspire speed-boost','Verbose'},
	}, playerBottom = {	'Info text at the bottom HUD',
		enable = {'bool',TRUE},
		size = {'num',17,nil,'Text size'},
		clock = {'bool',TRUE,nil,'Put a clock after local player info'},
		showRank = {'bool',TRUE,nil,'Add Infamy & level info in front of player names'},
		showInteraction = {'num',2,{0,2},'Interaction label if one is busy','Verbose'},
		showKill = {'num',2,{0,2},'Kill counter','Verbose'},
		showSpecial = {'num',1,{0,2},'Special kill counter','Verbose'},
		showInspire = {'num',2,{0,2},'Inspire boost status (if casted by local player)','Verbose'},
		showDistance = {'num',2,{0,2},'Distance boost status (if casted by local player)','Verbose'},
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
		dominated  = {'bool',TRUE,nil,'Show when an Ai has cuffed himself'},

	}, chat = {	'Broadcasts certain event.\nPossible conditions are: Never < ReadOnly < SendServer < SendFullClient < SendDropInClient < Always.\nLeft means less importance, right means more importance that people should know about.',
		enable = {'bool',TRUE},
		midstatAnnounce = {'num',0,{0,2},'Announce stats on every X kills. Considered as \'Midgame stat\'','MidStat'},
		midStat  = {'num',1,{0,5},'Midgame stat','ChatSend'},
		endStat  = {'num',2,{0,5},'Endgame stat','ChatSend'},
		endStatCredit  = {'num',2,{0,5},'PocoMods group plug after endgame stat :-p','ChatSend'},
		dominated  = {'num',2,{0,5},'Someone dominated a police enforcer','ChatSend'},
		converted  = {'num',2,{0,5},'Someone converted a police enforcer','ChatSend'},
		minionLost  = {'num',2,{0,5},'Someone lost a minion','ChatSend'},
		minionShot  = {'num',4,{0,5},'Someone shot a minion','ChatSend'},
		hostageChanged  = {'num',2,{0,5},'Hostage count has been changed (Not implemented)','ChatSend'},
		custody  = {'num',2,{0,5},'Someone is in custody','ChatSend'},
		downed  = {'num',1,{0,5},'Someone is downed','ChatSend'},
		downedWarning  = {'num',4,{0,5},'Someone is downed more than twice in a row','ChatSend'},
		replenished  = {'num',3,{0,5},'Someone replenished health(usually by Med kit)','ChatSend'},
		messiah  = {'num',5,{0,5},'You consumed a pistol messiah shot','ChatSend'},
	}, hit = {	'Hit indicator that shows where you\'ve been shot from',
		enable = {'bool',TRUE},
		duration  = {'num',0,{0,5},'Seconds. 0 means auto (follows shield recovery time)'},
		opacity  = {'num',50,{0,100},'Max opacity'},
		number  = {'bool',TRUE,nil,'Show the exact amount you lost'},
		numberSize  = {'num',25,{20,30},'Number size'},
		numberDefaultFont  = {'bool',FALSE,nil,'Number uses default font'},
		sizeStart  = {'num',100,{50,150},'Size at the beginning'},
		sizeEnd  = {'num',200,{100,300},'Size at the end'},
		shieldColor = {'color','Aqua','color','This means that you lost your armor point'},
		healthColor = {'color','Red','color','This means that you lost your health point'},
	}, float = {	'Floating infobox in 3D position',
		enable = {'bool',TRUE},
		border = {'bool',FALSE,nil,'Alternative box background'},
		size = {'num',15,{10,20},'Font size'},
		margin = {'num',3,{0,5},'Box inner padding'},
		keepOnScreen = {'bool',TRUE,nil,'Keep floating boxes on screen'},
		keepOnScreenMarginX = {'num',2,{0,20},'Margin for Left and Right'},
		keepOnScreenMarginY = {'num',15,{0,20},'Margin for Top and Bottom'},
		opacity  = {'num',90,{10,100},'Max opacity'},
		unit = {'bool',TRUE,nil,'Show pointed mobs'},
		drills = {'bool',TRUE,nil,'Show active drills'},
		highlight = {'bool',TRUE,nil,'Configuration not implemented'},
		minion = {'bool',TRUE,nil,'Configuration not implemented'},
		bags = {'bool',TRUE,nil,'Configuration not implemented'},
	}, game = {	'Game specific enhancements',
		fasterDesyncResolve = {'bool',TRUE,nil,'Configuration not implemented'},
		showRemaining = {'bool',TRUE,nil,'Configuration not implemented'},
		betterKickMenu = {'bool',TRUE,nil,'Configuration not implemented'},
	}
}
local _vanity = {
	ChatSend = 'never,readOnly,serverSend,clientFullSend,clientMidSend,alwaysSend',
	Verbose = 'Never,Verbose only,Always',
	MidStat = 'Never,50,100',
	align = 'N/A,Start,Middle,End',
	style = 'N/A,PocoHud,Vanilla',
}
----------------------------------------------------
local JSONFileName = 'poco\\hud3_config.json'
local isNil = function(a)
	return a == nil
end

local Option = class()
PocoHud3Class.Option = Option
function Option:init()
	self:reset()
	self.scheme = table.deepcopy(scheme)
end

function Option:reset()
	self.items = {}
	os.remove(JSONFileName)
end

function Option:load()
	local f = io.open(JSONFileName, 'r')
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
		f:write(JSON:encode(self.items))
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