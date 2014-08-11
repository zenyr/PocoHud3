local scheme = {
	root = {
		enable = {'bool',TRUE}
		verboseKey = {'key','`',nil,'Keybind for verbose mode'}
		verboseToggle = {'bool',FALSE,nil,'Toggle verbose mode'}
	}, corner = {
		color  = {'color','white','color'}
		size  = {'num',22,{10,30},'Font size'}
		defaultFont  = {'bool',FALSE}
		verboseOnly  = {'bool',FALSE}
		showFPS  = {'bool',TRUE}
		showClockIngame  = {'bool',FALSE}
		showClockOutgame  = {'bool',TRUE}
	}, buff = {
		enable = {'bool',TRUE}

		left  = {'num',10,{0,100}}
		top   = {'num',22,{0,100}}
		maxFPS  = {'num',50}
		size  = {'num',70}
		gap  = {'num',10}
		align  = {'num',1,{1,3}}
		style  = {'num',2,{1,2}}

		noSprintDelay  = {'bool',TRUE}
		hideInteractionCircle  = {'bool',FALSE}
		simpleBusy  = {'bool',TRUE}
		simpleBusyRadius  = {'num',10,{5,30}}
	}, playerFloat = {
		enable = {'bool',TRUE}
		showRank = {'num',2,{0,2},nil,'Verbose'}
		showDistance = {'num',2,{0,2},nil,'Verbose'}
		showInspire = {'num',2,{0,2},nil,'Verbose'}
	}, playerBottom = {
		enable = {'bool',TRUE}
		size = {'num',17}
		clock = {'bool',TRUE}
		showRank = {'bool',TRUE}
		showInteraction = {'num',2,{0,2},nil,'Verbose'}
		showKill = {'num',2,{0,2},nil,'Verbose'}
		showSpecial = {'num',1,{0,2},nil,'Verbose'}
		showInspire = {'num',2,{0,2},nil,'Verbose'}
		showDistance = {'num',2,{0,2},nil,'Verbose'}
		showPing = {'num',1,{0,2},nil,'Verbose'}
		showMinion = {'num',1,{0,2},nil,'Verbose'}
	}, popup = {
		enable = {'bool',TRUE}
		size  = {'num',22,{10,30}}
		damageDecay  = {'num',10,{3,15}}
		myDamage  = {'bool',TRUE}
		crewDamage  = {'bool',TRUE}
		AIDamage  = {'bool',TRUE}
		handsUp  = {'bool',TRUE}
		dominated  = {'bool',TRUE}

	}, chat = {
		enable = {'bool',TRUE}
		midStat  = {'num',1,{0,5},nil,'ChatSend'}
		endStat  = {'num',2,{0,5},nil,'ChatSend'}
		endStatCredit  = {'num',2,{0,5},nil,'ChatSend'}
		dominated  = {'num',2,{0,5},nil,'ChatSend'}
		converted  = {'num',2,{0,5},nil,'ChatSend'}
		minionLost  = {'num',2,{0,5},nil,'ChatSend'}
		minionShot  = {'num',4,{0,5},nil,'ChatSend'}
		hostageChanged  = {'num',2,{0,5},nil,'ChatSend'}
		custody  = {'num',2,{0,5},nil,'ChatSend'}
		downed  = {'num',1,{0,5},nil,'ChatSend'}
		downedWarning  = {'num',4,{0,5},nil,'ChatSend'}
		replenished  = {'num',3,{0,5},nil,'ChatSend'}
		messiah  = {'num',5,{0,5},nil,'ChatSend'}
	}, hit = {
		enable = {'bool',TRUE}
		duration  = {'num',0,{0,5}}
		opacity  = {'num',50,{0,100}}
		number  = {'bool',TRUE}
		numberSize  = {'num',25,{20,30}}
		numberDefaultFont  = {'bool',FALSE}
		sizeStart  = {'num',100,{50,150}}
		sizeEnd  = {'num',200,{100,300}}
		shieldColor = {'color','Aqua','color'}
		healthColor = {'color','Red','color'}
	}, float = {
		enable = {'bool',TRUE}
		border = {'bool',FALSE}
		size = {'num',15,{10,20}}
		margin = {'num',3,{0,5}}
		keepOnScreen = {'bool',TRUE}
		KeepOnScreenMarginX = {'num',2,{0,20}}
		KeepOnScreenMarginY = {'num',15,{0,20}}
		opacity  = {'num',90,{10,100}}
		unit = {'bool',TRUE}
		drills = {'bool',TRUE}
		minion = {'bool',TRUE}
		bags = {'bool',TRUE}
	}, game = {
		fasterDesyncResolve = {'bool',TRUE}
		showRemaining = {'bool',TRUE}
	}
}
----------------------------------------------------
local JSONFileName = 'poco\\hud3_config.json'
local Option = class()
PocoHud3Class.Option = Option
function Option:init()
	self:reset()
	self.scheme = table.deepcopy(self.items)
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
	return self:_get(true,category,name)[5]
end

function Option:set(category, name, value)
	self.items[category] = self.items[category] or {}
	self.items[category][name] = value
end

function Option:_get(isScheme, category,name)
	local o = isScheme and self.scheme or self.items
	return o[category] and o[category][name] or {}
end

function Option:get(category,name,raw)
	if not name then
		return self:getCategory(category)
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

function Option:getCategory(category)
	local result = {}
	for name in pairs(self.scheme[category] or {}) do
		result[name] = self:get(category,name)
	end
	return result
end

function Option:_default(category,name)
	return self:_get(true,category,name)[2]
end

function Option:isDefault(category,name,value)
	return value == self:_default(category,name)
end