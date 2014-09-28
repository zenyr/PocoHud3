local TRUE,FALSE = true,false
local scheme = {
	root = {	'_opt_root_desc',
		enable = {'bool',TRUE,nil,'_enable_desc'},
		detailedModeKey = {'key','`',nil,'_detailedModeKey_desc'},
		detailedModeToggle = {'bool',FALSE,nil,'_detailedModeToggle_desc'},
		showMusicTitlePrefix = {'string','Now Playing: ',nil,'_showMusicTitlePrefix_desc'},
		showMusicTitle = {'bool',TRUE,nil,'_showMusicTitle_desc'},
		silentKitShortcut = {'bool',TRUE,nil,'_silentKitShortcut_desc'},
		pocoRoseKey = {'key','b',nil,'_pocoRoseKey_desc'},
		language = {'num',1,{1,2},'_language_desc'},
		['24HourClock'] = {'bool',TRUE,nil,'_24HourClock_desc'},
	}, corner = {	'_opt_corner_desc',
		color  = {'color','White','color','_color_desc'},
		opacity = {'num',80,{0,100},'_opacity_desc',nil,5},
		size  = {'num',22,{10,30},'_size_desc'},
		defaultFont  = {'bool',TRUE,nil,'_defaultFont_desc'},
		detailedOnly  = {'bool',FALSE,nil,'_detailedOnly_desc'},
		showFPS  = {'bool',TRUE,nil,'_showFPS_desc'},
		showClockIngame  = {'bool',FALSE,nil,'_showClockIngame_desc'},
		showClockOutgame  = {'bool',TRUE,nil,'_showClockOutgame_desc'},
	}, buff = {	'_opt_buff_desc',
		enable = {'bool',TRUE,nil,'_enable_desc'},

		xPosition = {'num',10,{0,100},'_xPosition_desc',nil,2,1},
		yPosition = {'num',22,{0,100},'_yPosition_desc',nil,2,1},
		maxFPS  = {'num',50,nil,'_maxFPS_desc',nil,5,3},
		buffSize = {'num',70,nil,'_buffSize_desc',nil,nil,2},
		gap = {'num',10,nil,'_gap_desc',nil,nil,2},
		justify = {'num',1,{1,3},'_justify_desc','align',nil,2},
		style = {'num',1,{1,2},'_style_desc','style',nil,2},

		showBerserker = {'bool',TRUE,nil,'_showBerserker_desc'},
		showStamina = {'bool',TRUE,nil,'_showStamina_desc'},
		showCharge = {'bool',TRUE,nil,'_showCharge_desc'},
		showTransition = {'bool',TRUE,nil,'_showTransition_desc'},
		showCarryDrop = {'bool',TRUE,nil,'_showCarryDrop_desc'},
		showInteract = {'bool',TRUE,nil,'_showInteract_desc'},
		showInteraction = {'bool',TRUE,nil,'_showInteraction_desc'},
		showInspire = {'bool',TRUE,nil,'_showInspire_desc'},
		showBoost = {'bool',TRUE,nil,'_showBoost_desc'},
		showShield = {'bool',TRUE,nil,'_showShield_desc'},
		showECM = {'bool',TRUE,nil,'_showECM_desc'},
		showFeedback = {'bool',TRUE,nil,'_showFeedback_desc'},
		showTapeLoop = {'bool',TRUE,nil,'_showTapeLoop_desc'},
		showOverkill = {'bool',TRUE,nil,'_showOverkill_desc'},
		showCombatMedic = {'bool',TRUE,nil,'_showCombatMedic_desc'},
		showUnderdog = {'bool',TRUE,nil,'_showUnderdog_desc'},
		showBulletstorm = {'bool',TRUE,nil,'_showBulletstorm_desc'},
		showSuppressed = {'bool',FALSE,nil,'_showSuppressed_desc'},
		showReload = {'bool',TRUE,nil,'_showReload_desc'},

		noSprintDelay  = {'bool',TRUE,nil,'_noSprintDelay_desc',nil,nil,4},
		hideInteractionCircle  = {'bool',FALSE,nil,'_hideInteractionCircle_desc',nil,nil,4},
		simpleBusyIndicator = {'bool',TRUE,nil,'_simpleBusyIndicator_desc',nil,nil,4},
		simpleBusySize = {'num',10,{5,30},'_simpleBusySize_desc',nil,5,4},
	}, playerFloat = {	'_opt_playerFloat_desc',
		enable = {'bool',TRUE,nil,'_enable_desc'},
		uppercaseNames = {'bool',TRUE,nil,'_uppercaseNames_desc'},
		showIcon = {'num',2,{0,2},'_showIcon_desc','Verbose'},
		showRank = {'num',2,{0,2},'_showRank_desc','Verbose'},
		showDistance = {'num',2,{0,2},'_showDistance_desc','Verbose'},
		showInspire = {'num',2,{0,2},'_showInspire_desc2','Verbose'},
	}, playerBottom = {	'_opt_playerBottom_desc',
		enable = {'bool',TRUE,nil,'_enable_desc'},
		size = {'num',17,{15,30},'_size_desc',nil,2,1},
		offset = {'num',0,{-30,30},'_offset_desc',nil,2,1},
		underneath = {'bool',TRUE,nil,'_underneath_desc',nil,nil,1},
		uppercaseNames = {'bool',TRUE,nil,'_uppercaseNames_desc',nil,nil,1},
		showClock = {'num',2,{0,2},'_showClock_desc','Verbose'},
		showRank = {'bool',TRUE,nil,'_showRank_desc'},
		showInteraction = {'num',2,{0,2},'_showInteraction_desc','Verbose'},
		showInteractionTime = {'num',2,{0,2},'_showInteractionTime_desc','Verbose'},
		showKill = {'num',2,{0,2},'_showKill_desc','Verbose'},
		showPosition = {'num',2,{0,2},'_showPosition_desc','Verbose'},
		showSpecial = {'num',2,{0,2},'_showSpecial_desc','Verbose'},
		showInspire = {'num',2,{0,2},'_showInspire_desc2','Verbose'},
		showAverageDamage = {'num',1,{0,2},'_showAverageDamage_desc','Verbose'},
		showDistance = {'num',2,{0,2},'_showDistance_desc','Verbose'},
		showDowns = {'num',2,{0,2},'_showDowns_desc','Verbose'},
		showPing = {'num',2,{0,2},'_showPing_desc','Verbose'},
		showConvertedEnemy = {'num',1,{0,2},'_showConvertedEnemy_desc','Verbose'},
		showArrow = {'bool',TRUE,nil,'_showArrow_desc'},
	}, popup = {	'_opt_popup_desc',
		enable = {'bool',TRUE,nil,'_enable_desc'},
		size  = {'num',22,{10,30},'_size_desc',nil,nil,1},
		damageDecay  = {'num',10,{3,15},'_damageDecay_desc',nil,nil,1},
		myDamage  = {'bool',TRUE,nil,'_myDamage_desc',nil,nil,2},
		crewDamage  = {'bool',TRUE,nil,'_crewDamage_desc',nil,nil,2},
		AiDamage  = {'bool',TRUE,nil,'_AiDamage_desc',nil,nil,3},
		handsUp  = {'bool',TRUE,nil,'_handsUp_desc',nil,nil,4},
		dominated  = {'bool',TRUE,nil,'_dominated_desc',nil,nil,4},

	}, chat = {	'_opt_chat_desc',
		enable = {'bool',TRUE,nil,'_enable_desc'},
		fallbackToMe = {'bool',TRUE,nil,'_fallbackToMe_desc',nil,nil,1},
		includeLocation = {'bool',TRUE,nil,'_includeLocation_desc',nil,nil,1},
		midstatAnnounce = {'num',0,{0,2},'_midstatAnnounce_desc','MidStat',nil,2},
		midStat  = {'num',1,{0,2},'_midStat_desc','ChatSend',nil,2},
		endStat  = {'num',2,{0,4},'_endStat_desc','ChatSend',nil,3},
		endStatCredit  = {'num',2,{0,4},'_endStatCredit_desc','ChatSend',nil,3},
		dominated  = {'num',2,{0,4},'_dominated_desc','ChatSend',nil,4},
		converted  = {'num',2,{0,4},'_converted_desc','ChatSend',nil,4},
		minionLost  = {'num',2,{0,4},'_minionLost_desc','ChatSend',nil,4},
		minionShot  = {'num',4,{0,4},'_minionShot_desc','ChatSend',nil,4},
		hostageChanged  = {'num',2,{0,4},'_hostageChanged_desc','ChatSend',nil,4},
		custody  = {'num',2,{0,4},'_custody_desc','ChatSend',nil,4},
		downed  = {'num',1,{0,4},'_downed_desc','ChatSend',nil,4},
		downedWarning  = {'num',4,{0,4},'_downedWarning_desc','ChatSend',nil,4},
		replenished  = {'num',3,{0,4},'_replenished_desc','ChatSend',nil,4},
		messiah  = {'num',5,{0,5},'_messiah_desc','ChatSend',nil,5},
		drillDone = {'num',2,{0,4},'_drillDone_desc','ChatSend',nil,6},
		drillAlmostDone = {'num',2,{0,4},'_drillAlmostDone_desc','ChatSend',nil,6},
	}, hit = {	'_opt_hit_desc',
		enable = {'bool',TRUE,nil,'_enable_desc'},
		duration  = {'num',0,{0,10},'_duration_desc','Auto',nil,1},
		opacity  = {'num',50,{0,100},'_opacity_desc',nil,5,1},
		number  = {'bool',TRUE,nil,'_number_desc',nil,nil,1},
		numberSize  = {'num',25,{20,30},'_numberSize_desc',nil,nil,1},
		numberDefaultFont  = {'bool',FALSE,nil,'_numberDefaultFont_desc',nil,nil,1},
		sizeStart  = {'num',100,{50,250},'_sizeStart_desc',nil,50,2},
		sizeEnd  = {'num',200,{50,500},'_sizeEnd_desc',nil,50,3},
		shieldColor = {'color','LawnGreen','color','_shieldColor_desc',nil,nil,4},
		healthColor = {'color','Red','color','_healthColor_desc',nil,nil,5},
		shieldColorDepleted = {'color','Aqua','color','_shieldColorDepleted_desc',nil,nil,4},
		healthColorDepleted = {'color','Magenta','color','_healthColorDepleted_desc',nil,nil,5},
	}, float = {	'_opt_float_desc',
		enable = {'bool',TRUE,nil,'_enable_desc'},
		frame = {'bool',FALSE,nil,'_frame_desc',nil,nil,3},
		size = {'num',15,{10,20},'_size_desc',nil,nil,1},
		margin = {'num',3,{0,5},'_margin_desc',nil,nil,1},
		keepOnScreen = {'bool',TRUE,nil,'_keepOnScreen_desc',nil,nil,2},
		keepOnScreenMarginX = {'num',2,{0,20},'_keepOnScreenMarginX_desc',nil,nil,2},
		keepOnScreenMarginY = {'num',15,{0,20},'_keepOnScreenMarginY_desc',nil,nil,2},
		opacity  = {'num',90,{10,100},'_opacity_desc',nil,5,1},
		showTargets = {'bool',TRUE,nil,'_showTargets_desc',nil,nil,4},
		showDrills = {'bool',TRUE,nil,'_showDrills_desc'},
		showHighlighted = {'bool',TRUE,nil,'_showHighlighted_desc'},
		showConvertedEnemy = {'bool',TRUE,nil,'_showConvertedEnemy_desc2'},
		showBags = {'bool',TRUE,nil,'_showBags_desc'},
	}, game = {	'_opt_game_desc',
		fasterDesyncResolve = {'num',2,{1,3},'_fasterDesyncResolve_desc','DesyncResolve',nil,1},
		ingameJoinRemaining = {'bool',TRUE,nil,'_ingameJoinRemaining_desc',nil,nil,1},
		showRankInKickMenu = {'bool',TRUE,nil,'_showRankInKickMenu_desc',nil,nil,1},
		corpseLimit = {'num',3,{1,10},'_corpseLimit_desc','corpse',nil,3},
		corpseRagdollTimeout = {'num',3,{2,10},'_corpseRagdollTimeout_desc','corpse',nil,3},
		cantedSightCrook = {'num',4,{1,4},'_cantedSightCrook_desc','cantedSight',nil,3},
		rememberGadgetState = {'bool',TRUE,nil,'_rememberGadgetState_desc',nil,nil,3},
		subtitleFontSize = {'num',20,{10,30},'_subtitleFontSize_desc',nil,nil,2},
		subtitleFontColor = {'color','White',nil,'_subtitleFontColor_desc',nil,nil,2},
		subtitleOpacity = {'num',100,{10,100},'_subtitleOpacity_desc',nil,10,2},
		truncateNames = {'num',1,{1,8},'_truncateNames_desc','truncateNames',nil,4},
		truncateTags = {'bool',TRUE,nil,'_truncateTags_desc','truncateNames',nil,4},
	}
}
local _vanity = {
	ChatSend = '_vanity_chatsend',
	Verbose = '_vanity_verbose',
	MidStat = '_vanity_midstat',
	align = '_vanity_align',
	style = '_vanity_style',
	Auto = '_vanity_auto',
	DesyncResolve = '_vanity_desyncresolve',
	corpse = '_vanity_corpse',
	cantedSight = '_vanity_cantedsight',
	truncateNames = '_vanity_truncatenames',
}
----------------------------------------------------
local JSONFileName = 'poco\\hud3_config.json'
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

function Option:default(category)
	if category then
		self.items[category] = nil
	else
		self.items = {}
	end
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
		vanity = _vanity[vanity] or '?'
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