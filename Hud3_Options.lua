local scheme = {
	root = {
		enable = {'bool',TRUE,nil,nil,nil}
		verboseKey = {'key','`',nil,Keybind for verbose mode,nil}
		verboseToggle = {'bool',FALSE,nil,Toggle verbose mode,nil}
	}, corner = {
		color  = {'color','white','color',nil,nil}
		size  = {'num',22,{10,30},nil,nil}
		defaultFont  = {'bool',FALSE,nil,nil,nil}
		verboseOnly  = {'bool',FALSE,nil,nil,nil}
		showFPS  = {'bool',TRUE,nil,nil,nil}
		showClockIngame  = {'bool',FALSE,nil,nil,nil}
		showClockOutgame  = {'bool',TRUE,nil,nil,nil}
	}, buff = {
		enable = {'bool',TRUE,nil,nil,nil}

		left  = {'num',10,{0,100},nil,nil}
		top   = {'num',22,{0,100},nil,nil}
		maxFPS  = {'num',50,nil,nil,nil}
		size  = {'num',70,nil,nil,nil}
		gap  = {'num',10,nil,nil,nil}
		align  = {'num',1,{1,3},nil,nil}
		style  = {'num',2,{1,2},nil,nil}

		noSprintDelay  = {'bool',TRUE,nil,nil,nil}
		hideInteractionCircle  = {'bool',FALSE,nil,nil,nil}
		simpleBusy  = {'bool',TRUE,nil,nil,nil}
		simpleBusyRadius  = {'num',10,{5,30},nil,nil}
	}, playerFloat = {
		enable = {'bool',TRUE,nil,nil,nil}
		showRank = {'num',2,{0,2},nil,'Verbose'}
		showDistance = {'num',2,{0,2},nil,'Verbose'}
		showInspire = {'num',2,{0,2},nil,'Verbose'}
	}, playerBottom = {
		enable = {'bool',TRUE,nil,nil,nil}
		size = {'num',17,nil,nil,nil}
		clock = {'bool',TRUE,nil,nil,nil}
		showRank = {'bool',TRUE,nil,nil,nil}
		showInteraction = {'num',2,{0,2},nil,'Verbose'}
		showKill = {'num',2,{0,2},nil,'Verbose'}
		showSpecial = {'num',1,{0,2},nil,'Verbose'}
		showInspire = {'num',2,{0,2},nil,'Verbose'}
		showDistance = {'num',2,{0,2},nil,'Verbose'}
		showPing = {'num',1,{0,2},nil,'Verbose'}
		showMinion = {'num',1,{0,2},nil,'Verbose'}
	}, popup = {
		enable = {'bool',TRUE,nil,nil,nil}
		size  = {'num',22,{10,30},nil,nil}
		damageDecay  = {'num',10,{3,15},nil,nil}
		myDamage  = {'bool',TRUE,nil,nil,nil}
		crewDamage  = {'bool',TRUE,nil,nil,nil}
		AIDamage  = {'bool',TRUE,nil,nil,nil}
		handsUp  = {'bool',TRUE,nil,nil,nil}
		dominated  = {'bool',TRUE,nil,nil,nil}

	}, chat = {
		enable = {'bool',TRUE,nil,nil,nil}
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
		enable = {'bool',TRUE,nil,nil,nil}
		duration  = {'num',0,{0,5},nil,nil}
		opacity  = {'num',50,{0,100},nil,nil}
		number  = {'bool',TRUE,nil,nil,nil}
		numberSize  = {'num',25,{20,30},nil,nil}
		numberDefaultFont  = {'bool',FALSE,nil,nil,nil}
		sizeStart  = {'num',100,{50,150},nil,nil}
		sizeEnd  = {'num',200,{100,300},nil,nil}
		shieldColor = {'color','Aqua','color',nil,nil}
		healthColor = {'color','Red','color',nil,nil}
	}, game = {
		fasterDesyncResolve = {'bool',TRUE,nil,nil,nil}
		showRemaining = {'bool',TRUE,nil,nil,nil}
	}
}
----------------------------------------------------
local Option = class()
PocoHud3Class.Option = Option
function Option:init()
	self:reset()
	self.scheme = table.deepcopy(self.items)
end

function Option:reset()
	self.items = {}
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
function Option:get(category,name)
	local result = self:_get(false,category,name)
	if result == nil then
		result = self:_default(category,name)
	end
	return result
end

function Option:_default(category,name)
	return self:_get(true,category,name)[2]
end