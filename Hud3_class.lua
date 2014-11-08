---
local ALTFONT = 'fonts/font_eroded'
local FONT =  'fonts/font_medium_mf' -- or tweak_data.hud_present.title_font or tweak_data.hud_players.name_font or 'fonts/font_eroded' or 'core/fonts/system_font'
local FONTLARGE = 'fonts/font_large_mf'
local clGood =  cl.YellowGreen
local clBad =  cl.Gold
local isNil = function(a) return a == nil end
local inGame = CopDamage ~= nil
local KitsJSONFileName = 'poco\\hud3_kits.json'

local Icon = {
	A=57344, B=57345,	X=57346, Y=57347, Back=57348, Start=57349,
	Skull = 57364, Ghost = 57363, Dot = 1031, Chapter = 1015, Div = 1014, BigDot = 1012,
	Times = 215, Divided = 247, LC=139, RC=155, DRC = 1035, Deg = 1024, PM= 1030, No = 1033,
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
	Click = 'onClick',
	WheelUp = 'onWheelUp',
	WheelDown = 'onWheelDown',
	Move = 'onMove',
}
local O, K, L, me
PocoHud3Class = {
	ALTFONT	= ALTFONT	,
	FONT		= FONT		,
	FONTLARGE = FONTLARGE,
	clGood	= clGood	,
	clBad		= clBad		,
	Icon		= Icon		,
	PocoEvent = PocoEvent,
}
PocoHud3Class.loadVar = function(_O,_me,_L)
	O = _O
	L = _L
	me = _me
	clGood = O:get('root','colorPositive')
	clBad = O:get('root','colorNegative')
end
local _defaultLocaleData = {
	_opt_root = 'Root',
	_enable = 'ENABLE',
	_detailedModeKey = 'DETAILED MODE KEY',
	_detailedModeToggle = 'DETAILED MODE TOGGLE',
	_showMusicTitlePrefix = 'SHOW MUSIC TITLE PREFIX',
	_showMusicTitle = 'SHOW MUSIC TITLE',
	_silentKitShortcut = 'SILENT KIT SHORTCUT',
	_pocoRoseKey = 'POCO ROSE KEY',
	_language = 'LANGUAGE',
	_24HourClock = '24HOUR CLOCK',
	_opt_corner = 'Corner',
	_color = 'COLOR',
	_opacity = 'OPACITY',
	_size = 'SIZE',
	_defaultFont = 'DEFAULT FONT',
	_detailedOnly = 'DETAILED ONLY',
	_showFPS = 'SHOW FPS',
	_showClockIngame = 'SHOW CLOCK INGAME',
	_showClockOutgame = 'SHOW CLOCK OUTGAME',
	_opt_buff = 'Buff',
	_xPosition = 'X POSITION',
	_yPosition = 'Y POSITION',
	_maxFPS = 'MAX FPS',
	_buffSize = 'BUFF SIZE',
	_gap = 'GAP',
	_justify = 'JUSTIFY',
	_style = 'STYLE',
	_showBerserker = 'SHOW BERSERKER',
	_showStamina = 'SHOW STAMINA',
	_showCharge = 'SHOW CHARGE',
	_showTransition = 'SHOW TRANSITION',
	_showCarryDrop = 'SHOW CARRY DROP',
	_showInteract = 'SHOW INTERACT',
	_showInteraction = 'SHOW INTERACTION',
	_showInspire = 'SHOW INSPIRE',
	_showBoost = 'SHOW BOOST',
	_showShield = 'SHOW SHIELD',
	_showECM = 'SHOW ECM',
	_showFeedback = 'SHOW FEEDBACK',
	_showTapeLoop = 'SHOW TAPE LOOP',
	_showOverkill = 'SHOW OVERKILL',
	_showCombatMedic = 'SHOW COMBAT MEDIC',
	_showUnderdog = 'SHOW UNDERDOG',
	_showBulletstorm = 'SHOW BULLETSTORM',
	_showSuppressed = 'SHOW SUPPRESSED',
	_showReload = 'SHOW RELOAD',
	_noSprintDelay = 'NO SPRINT DELAY',
	_hideInteractionCircle = 'HIDE INTERACTION CIRCLE',
	_simpleBusyIndicator = 'SIMPLE BUSY INDICATOR',
	_simpleBusySize = 'SIMPLE BUSY SIZE',
	_opt_playerFloat = '',
	_uppercaseNames = 'UPPERCASE NAMES',
	_showIcon = 'SHOW ICON',
	_showRank = 'SHOW RANK',
	_showDistance = 'SHOW DISTANCE',
	_opt_playerBottom = '',
	_offset = 'OFFSET',
	_underneath = 'UNDERNEATH',
	_showClock = 'SHOW CLOCK',
	_showInteractionTime = 'SHOW INTERACTION TIME',
	_showKill = 'SHOW KILL',
	_showPosition = 'SHOW POSITION',
	_showSpecial = 'SHOW SPECIAL',
	_showAverageDamage = 'SHOW AVERAGE DAMAGE',
	_showDowns = 'SHOW DOWNS',
	_showPing = 'SHOW PING',
	_showConvertedEnemy = 'SHOW CONVERTED ENEMY',
	_showArrow = 'SHOW ARROW',
	_opt_popup = '',
	_damageDecay = 'DAMAGE DECAY',
	_myDamage = 'MY DAMAGE',
	_crewDamage = 'CREW DAMAGE',
	_AiDamage = 'AI DAMAGE',
	_handsUp = 'HANDS UP',
	_dominated = 'DOMINATED',
	_opt_chat = '',
	_fallbackToMe = 'FALLBACK TO ME',
	_includeLocation = 'INCLUDE LOCATION',
	_midstatAnnounce = 'MIDSTAT ANNOUNCE',
	_midStat = 'MID STAT',
	_endStat = 'END STAT',
	_endStatCredit = 'END STAT CREDIT',
	_converted = 'CONVERTED',
	_minionLost = 'MINION LOST',
	_minionShot = 'MINION SHOT',
	_hostageChanged = 'HOSTAGE CHANGED',
	_custody = 'CUSTODY',
	_downed = 'DOWNED',
	_downedWarning = 'DOWNED WARNING',
	_replenished = 'REPLENISHED',
	_messiah = 'MESSIAH',
	_drillDone = 'DRILL DONE',
	_drillAlmostDone = 'DRILL ALMOST DONE',
	_opt_hit = '',
	_duration = 'DURATION',
	_number = 'NUMBER',
	_numberSize = 'NUMBER SIZE',
	_numberDefaultFont = 'NUMBER DEFAULT FONT',
	_sizeStart = 'SIZE START',
	_sizeEnd = 'SIZE END',
	_shieldColor = 'SHIELD COLOR',
	_healthColor = 'HEALTH COLOR',
	_shieldColorDepleted = 'SHIELD COLOR DEPLETED',
	_healthColorDepleted = 'HEALTH COLOR DEPLETED',
	_opt_float = '',
	_frame = 'FRAME',
	_margin = 'MARGIN',
	_keepOnScreen = 'KEEP ON SCREEN',
	_keepOnScreenMarginX = 'KEEP ON SCREEN MARGIN X',
	_keepOnScreenMarginY = 'KEEP ON SCREEN MARGIN Y',
	_showTargets = 'SHOW TARGETS',
	_showDrills = 'SHOW DRILLS',
	_showHighlighted = 'SHOW HIGHLIGHTED',
	_showBags = 'SHOW BAGS',
	_opt_game = '',
	_fasterDesyncResolve = 'FASTER DESYNC RESOLVE',
	_ingameJoinRemaining = 'INGAME JOIN REMAINING',
	_showRankInKickMenu = 'SHOW RANK IN KICK MENU',
	_corpseLimit = 'CORPSE LIMIT',
	_corpseRagdollTimeout = 'CORPSE RAGDOLL TIMEOUT',
	_cantedSightCrook = 'CANTED SIGHT CROOK',
	_rememberGadgetState = 'REMEMBER GADGET STATE',
	_subtitleFontSize = 'SUBTITLE FONT SIZE',
	_subtitleFontColor = 'SUBTITLE FONT COLOR',
	_subtitleOpacity = 'SUBTITLE OPACITY',
	_truncateNames = 'TRUNCATE NAMES',
	_truncateTags = 'TRUNCATE TAGS',
	_opt_root_desc = 'PocoHud3 Main configuration',
	_enable_desc = 'Enable this feature',
	_detailedModeKey_desc = 'Keybind for detailed(verbose) mode.\nDefault: ` (tilde key)',
	_detailedModeToggle_desc = 'Make detailed mode key toggles mode.',
	_showMusicTitlePrefix_desc = 'Prefix for music titles',
	_showMusicTitle_desc = 'Show title of the music when it is being set',
	_silentKitShortcut_desc = 'Ignore Kit Profiler shortcuts success message',
	_pocoRoseKey_desc = 'Keybind for PocoRose.\nDefault: B',
	_language_desc = 'PocoHud3 Language\n* Not implemented',
	_24HourClock_desc = 'Use 24 hour clock instead of 12 hours clock at the corner and bottom player infobox',
	_opt_corner_desc = 'Static text ticker which works as FPS counter / Outgame clock',
	_color_desc = 'Font color',
	_opacity_desc = 'Font opacity',
	_size_desc = 'Font size',
	_defaultFont_desc = 'Use sans-serif font',
	_detailedOnly_desc = 'Hide corner text while \'Detailed\' mode is not activated',
	_showFPS_desc = 'Show FPS',
	_showClockIngame_desc = 'Show in-game clock',
	_showClockOutgame_desc = 'Show out-game clock',
	_opt_buff_desc = 'Shows realtime buff status',
	_xPosition_desc = 'Origin point X (% from left of screen)',
	_yPosition_desc = 'Origin point Y (% from top of screen)',
	_maxFPS_desc = 'FPS cap to reduce performance hit',
	_buffSize_desc = 'Icon size (ignored with Vanilla style)',
	_gap_desc = 'Icon gap',
	_justify_desc = 'Icon alignment (vertical for Vanilla style)',
	_style_desc = 'Buff icon style',
	_showBerserker_desc = 'Berserker indicator',
	_showStamina_desc = 'Stamina indicator',
	_showCharge_desc = 'Melee charge indicator',
	_showTransition_desc = 'Transitions like weapon swap, melee cooldown',
	_showCarryDrop_desc = 'Bag interaction cooldown',
	_showInteract_desc = 'Shout cooldown',
	_showInteraction_desc = 'Interaction timer that involves holding USE key',
	_showInspire_desc = 'Inspire cooldown (giving end)',
	_showBoost_desc = 'Inspire duration (receiving end)',
	_showShield_desc = 'Shield recovery cooldown',
	_showECM_desc = 'ECM duration',
	_showFeedback_desc = 'ECM Feedback duration',
	_showTapeLoop_desc = 'Tapeloop duration',
	_showOverkill_desc = 'Overkill duration',
	_showCombatMedic_desc = 'Combat medic duration',
	_showUnderdog_desc = 'Underdog duration',
	_showBulletstorm_desc = 'Bulletstorm duration',
	_showSuppressed_desc = 'Suppression that prevents shield recovery and increases bullet deviation.\n(Bullet deviation not in effect)',
	_showReload_desc = 'Show Reload indicator',
	_noSprintDelay_desc = 'Ignore after-sprint delay',
	_hideInteractionCircle_desc = 'Hide vanilla game\'s interaction circle',
	_simpleBusyIndicator_desc = 'Replace \'busy\' icons with simple red circle at the crosshair\nSuch as: Reloading, Weapon-swap, melee',
	_simpleBusySize_desc = 'Set size of SimpleBusy indicator if simpleBusy is used',
	_opt_playerFloat_desc = 'Floating info panel above crew members\' head',
	_uppercaseNames_desc = 'Name as uppercase',
	_showIcon_desc = 'Infamy Spade icon',
	_showRank_desc = 'e.g) V-100',
	_showDistance_desc = 'e.g) 25m',
	_showInspire_desc2 = 'Inspire speed-boost',
	_opt_playerBottom_desc = 'Info text at the bottom of the HUD',
	_offset_desc = 'Vertical offset if you REALLY want to move it around',
	_underneath_desc = 'Put PlayerBottom infobox at the very bottom of the screen',
	_showClock_desc = 'Put a clock after local player info',
	_showInteractionTime_desc = 'How much time left',
	_showKill_desc = 'Kill counter',
	_showPosition_desc = 'Show player\'s position.\n* BETA',
	_showSpecial_desc = 'Special kill counter',
	_showAverageDamage_desc = 'Average Damage per bullet',
	_showDowns_desc = 'Downs counter',
	_showPing_desc = 'Latency as miliseconds',
	_showConvertedEnemy_desc = 'Minion health as percent if one has any',
	_showArrow_desc = 'Arrow pointing at players\' position',
	_opt_popup_desc = 'Shows damages in 3D space',
	_damageDecay_desc = 'Decay time',
	_myDamage_desc = 'Show local player\'s damage',
	_crewDamage_desc = 'Show other player\'s damage',
	_AiDamage_desc = 'Show AI\'s damage',
	_handsUp_desc = 'Show when an AI is going to surrender',
	_dominated_desc = 'Show when an AI has cuffed himself',
	_opt_chat_desc = {'_opt_chat_desc_1',{'_opt_chat_desc_2',cl.White:with_alpha(0.5)},{'_opt_chat_desc_3',cl.White:with_alpha(0.6)},{'_opt_chat_desc_4',cl.White:with_alpha(0.7)},{'_opt_chat_desc_5',cl.White:with_alpha(0.8)},{'_opt_chat_desc_6',cl.White:with_alpha(0.9)},{'_opt_chat_desc_7',cl.White:with_alpha(1)}},
	_fallbackToMe_desc = 'If an event is set to be sent to everyone but the condition is not fulfilled, show it to myself instead.',
	_includeLocation_desc = 'If location data is available, include it in chat message.',
	_midstatAnnounce_desc = 'Announce stats on every X kills. Considered as \'Midgame stat\'',
	_midStat_desc = 'Midgame stat. (limited to ServerSend)',
	_endStat_desc = 'Endgame stat',
	_endStatCredit_desc = 'PocoMods group plug after endgame stat ;)',
	_converted_desc = 'Someone converted a police enforcer',
	_minionLost_desc = 'Someone lost a minion',
	_minionShot_desc = 'Someone shot a minion',
	_hostageChanged_desc = 'Hostage count has been changed\n* Not implemented',
	_custody_desc = 'Someone is in custody',
	_downed_desc = 'Someone is downed',
	_downedWarning_desc = 'Someone is downed more than twice in a row',
	_replenished_desc = 'Someone replenished health(usually by Med kit)',
	_messiah_desc = 'You consumed a pistol messiah shot',
	_drillDone_desc = 'A drill is done.\n* Requires Float-ShowDrills option enabled',
	_drillAlmostDone_desc = 'A drill has less than 10 seconds left.\n* Requires Float-ShowDrills option enabled',
	_opt_hit_desc = 'Hit indicator that shows where you\'ve been shot from',
	_duration_desc = 'Seconds. 0 means auto (follows shield recovery time)',
	_number_desc = 'Show the exact amount you lost',
	_numberSize_desc = 'Number size',
	_numberDefaultFont_desc = 'Number uses default font',
	_sizeStart_desc = 'Size at the beginning',
	_sizeEnd_desc = 'Size at the end',
	_shieldColor_desc = 'Shield lost color, full amount',
	_healthColor_desc = 'Health lost color, full amount',
	_shieldColorDepleted_desc = 'Shield lost color, depleted',
	_healthColorDepleted_desc = 'Health lost color, depleted',
	_opt_float_desc = 'Floating infobox in 3D position',
	_frame_desc = 'Alternative box frame',
	_margin_desc = 'Box inner padding',
	_keepOnScreen_desc = 'Keep floating boxes on screen',
	_keepOnScreenMarginX_desc = 'Margin for Left and Right',
	_keepOnScreenMarginY_desc = 'Margin for Top and Bottom',
	_showTargets_desc = 'Show pointed mobs',
	_showDrills_desc = 'Show active drills',
	_showHighlighted_desc = 'Show floating infobox while highlighted.\nPager answering timer also depends on this.',
	_showConvertedEnemy_desc2 = 'Try to color-code them to the master.',
	_showBags_desc = 'Show pointed bags.\n* Requires \'Show Targets\' enabled',
	_opt_game_desc = 'Game specific enhancements',
	_fasterDesyncResolve_desc = 'In-game Player husks will catch up severe desync faster and represent more accurate position.',
	_ingameJoinRemaining_desc = 'In-game SOMEONE IS JOINING dialog will show you how many seconds left',
	_showRankInKickMenu_desc = 'In-game Kick menu will display player levels with their name',
	_corpseLimit_desc = 'In-game corpse limit\nDefault is 8.\nEach step multiplies/divides result by 2.',
	_corpseRagdollTimeout_desc = 'Corpse ragdoll timeout in loud game.\nDefault is 3 seconds. Each step increase/decrease the time by 1 second.',
	_cantedSightCrook_desc = 'In-game canted sight(as gadget) indicator',
	_rememberGadgetState_desc = 'Remembers gadget(laser, flashlight, angled sight) status between weapon swaps',
	_subtitleFontSize_desc = 'Subtitle font size',
	_subtitleFontColor_desc = 'Subtitle font color',
	_subtitleOpacity_desc = 'Subtitle opacity',
	_truncateNames_desc = 'Truncate Player names by length, if required.',
	_truncateTags_desc = {'_truncateTags_desc_1',{'[Poco]Hud',cl.Tan},' > ', {PocoHud3Class.Icon.Dot..'Hud',cl.Tan}},
	_truncateTags_desc_1 = 'Truncate Player tags with square brakets.\ne.g)',
	_opt_chat_desc_1 = 'If an event listed below happens and fulfill set condition, PocoHud will tell others via chat. Possible targets are:\n',
	_opt_chat_desc_2 = '* No one: No One\n',
	_opt_chat_desc_3 = '* Only me: Only me\n',
	_opt_chat_desc_4 = '* Everyone-Host: Everyone if I am host\n',
	_opt_chat_desc_5 = '* Everyone-EM: Everyone if I have attended the entire match\n',
	_opt_chat_desc_6 = '* Everyone-Alone: Everyone if I am the only one who has PocoHud\n',
	_opt_chat_desc_7 = '* Everyone-Always: Everyone, regardless of someone else already broadcasted with PocoHud or not',
	_city_swat = 'a Gensec Elite',
	_cop = 'a cop',
	_fbi = 'an FBI agent',
	_fbi_heavy_swat = 'an FBI heavy SWAT',
	_fbi_swat = 'an FBI SWAT',
	_gangster = 'a gangster',
	_gensec = 'a Gensec guard',
	_heavy_swat = 'a heavy SWAT',
	_security = 'a guard',
	_shield = 'a shield',
	_sniper = 'a sniper',
	_spooc = 'a cloaker',
	_swat = 'a SWAT',
	_tank = 'a bulldozer',
	_taser = 'a taser',
	_msg_minionShot = '[1] damaged [2] minion for [3]',
	_vanity_chatsend = 'No one,Only me,Everyone-Host,Everyone-EM,Everyone-Alone,Everyone-Always',
	_vanity_verbose = 'Never,Detailed mode only,Always',
	_vanity_midstat = 'Never,50,100',
	_vanity_align = 'none,Start,Middle,End',
	_vanity_style = 'N/A,PocoHud,Vanilla,Glow',
	_vanity_auto = 'Auto',
	_vanity_desyncresolve = 'N/A,Off,Faster,Aggressive',
	_vanity_corpse = 'N/A,Minimum,Less,Default,More,a Lot,Considerable,Massive,Mammoth,Colossal,Ridiculous',
	_vanity_cantedsight = 'N/A,Off,Subtle,Obvious,Maximum',
	_vanity_truncatenames = 'N/A,Off,3,6,9,12,15,18,21',
	_tab_about = 'About',
	_tab_options = 'Options',
	_tab_statistics = 'Statistics',
	_tab_heistStatus = 'Heist Status',
	_tab_upgradeSkills = 'Upgrade Skills',
	_upgr_crewBonusFrom = 'Crew bonus from [1]',
	_yourPerks = 'Perks that you have acquired',
	_youAndCrewsPerks = 'Perks that you and your crew will benefit from',
	_tab_tools = 'Tools',
	_tab_kitProfiler = 'Kit Profiler',
	_tab_Inspect = 'Inspect Players',
	_tab_jukebox = 'Jukebox',
	_stat_crewKills = '[1]Crew: [2]',
	_msg_converted = '[1] converted [2] [3]',
	_buff_exhausted = 'Exhausted',
	_msg_minionLost = '[1] lost a minion to [2] [3].',
	_msg_around = 'around [1]',
	_buff_combatMedicDamageShort = 'Dmg+',
	_buff_bulletStormShort = 'BS',
	_buff_underdogShort = 'Dmg+',
	_buff_overkillShort = 'Dmg+',
	_msg_usedPistolMessiah = 'Used Pistol messiah, [1] left.',
	_msg_usedPistolMessiahCharges = '[1] charge',
	_msg_usedPistolMessiahChargesPlu = '[1] charges',
	_msg_captured = '[1] has been captured [2]',
	_msg_repenished = '[1] replenished health by [2]% [3]',
	_msg_replenishedDown = '(+[1] down)',
	_msg_replenishedDownPlu = '(+[1] downs)',
	_msg_downedWarning = 'Warning: [1] has been downed [2] times',
	_msg_downed = '[1] was downed',
	_tab_stat_perheist = 'Per Heist',
	_word_broker = 'Broker',
	_word_job = 'Job',
	_word_heat = 'Heat',
	_word_na = 'N/A',
	_tab_stat_perday = 'Per Day',
	_word_heist = 'Heist',
	_word_day = 'Day',
	_word_started = 'Started',
	_word_completed = 'Completed',
	_word_time = 'Time',
	_desc_heist_count_started_1 = 'From Beginning: ',
	_desc_heist_count_started_2 = '\nDropped in: ',
	_desc_heist_count_completed = 'Quit: ',
	_desc_heist_time_hm = '[1]h [2]m',
	_desc_heist_time_m = '[1]m',
	_desc_heist_time_ms = '[1]m [1]s',
	_desc_heist_time_average = 'Average: ',
	_desc_heist_day = 'day [1]',
	_desc_heist_dayalt = 'day [1] alt [2]',
	_desc_heist_unlisted = '-- Not listed heists --',
	_desc_heist_may_not_match = '* Numbers may not match between heists and days.',
	_word_yes = 'Yes',
	_word_no = 'No',
	_desc_not_in_effect = 'Not in effect',
	_desc_no_upgrades_acquired = 'No upgrades acquired\n',
	_btn_apply_and_reload = 'APPLY & RELOAD',
	_btn_discard = 'DISCARD CHANGES',
	_btn_reset = 'RESET TO DEFAULT',
	_btn_reset_category = 'RESET THIS CATEGORY',
	_desc_apply_and_reload = 'Some options will be applied on the next session.',
	_desc_discard = 'Discard temporary changes and revert to previous settings',
	_desc_reset = 'Revert to the default setting.',
	_desc_reset_category = 'Revert this category to the default setting.',
	_desc_reset_ask = '\nContinue?',
	_tab_buff = 'Buff',
	_tab_chat = 'Chat',
	_tab_corner = 'Corner Text',
	_tab_float = 'Floating Labels',
	_tab_game = 'Game mechanisms',
	_tab_hit = 'Hit indicator',
	_tab_playerBottom = 'Bottom Infobox',
	_tab_playerFloat = 'Overhead infobox',
	_tab_popup = 'Popup Labels',
	_tab_root = 'PocoHud3',
	_msg_not_implemented = 'Not Implemented for now',
	_rose_whistle = 'whistle',
	_rose_cable = 'use cableties',
	_rose_medbag = 'need medbag',
	_rose_shoot = 'shoot em',
	_rose_drill = 'i got the drill',
	_rose_overrun = 'we\'re overrun',
	_rose_timetogo = 'time to go',
	_rose_thisway = 'this way',
	_rose_straight = 'straight ahead',
	_rose_cantstay = 'can\'t stay here',
	_rose_almost = 'almost there',
	_rose_getout = 'get out',
	_rose_upstairs = 'upstairs',
	_rose_hurry = 'hurry',
	_rose_alright = 'alright',
	_rose_letsgo = 'let\'s go',
	_rose_left = 'Left',
	_rose_right = 'Right',
	_rose_thanks = 'thanks',
	_rose_halfway = 'halfway done',
	_rose_careful = 'careful',
	_rose_downstairs = 'downstairs',
	_rose_inside = 'inside',
	_rose_anysecond = 'ANY second',
	_rose_fewminutes = 'few more minutes',
	_rose_down = 'down here',
	_rose_wrong = 'wrong way',
	_rose_defended = 'keep defended',
	_rose_cams = 'take cams',
	_rose_shit = 'shit',
	_rose_ammo = 'need ammo',
	_rose_fuck = 'oh fuck',
	_kit_categories = 'SET NAME,PRIMARY,SECONDARY,ARMOR,GADGET,MELEE',
	_buff_painkillerShort = 'PK',
	_showPainkiller_desc = 'Show received Painkiller duration',
	_buff_swanSongShort = 'SS',
	_showSwanSong_desc = 'Show Swansong duration',
	_tab_juke_stop = 'STOP',
	_tab_juke_stealth = 'STEALTH',
	_tab_juke_control = 'CONTROL',
	_tab_juke_anticipation = 'ANTICIPATION',
	_tab_juke_assault = 'ASSAULT',
	_tab_juke_heist = 'Heist tracks',
	_tab_juke_menu = 'Menu tracks',
	_tab_stat_day = '(DAY)',
	_tab_stat_night = '(NIGHT)',
	_colorNegative_desc = 'De-buff color\n(Ignored in "vanilla" style)',
	_colorPositive_desc = 'Buff color\n(Ignored in "vanilla" style)',
	_mirrorDirection_desc = 'Increase buff gauge clockwise',

}
--- miniClass start ---
local TBuff = class()
PocoHud3Class.TBuff = TBuff
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
	local buffO = O:get('buff')
	local style = buffO.style
	local vanilla = style == 2
	local glowy = style == 3

	local size = style==2 and 40 or buffO.buffSize
	local data = self.data
	local simple = self.owner:_isSimple(data.key)
	self.created = true
	if simple then
		local simpleRadius = buffO.simpleBusySize
		local pnl = self.ppnl:panel({x = self.owner.ww/2-simpleRadius,y=self.owner.hh/2-simpleRadius, w=simpleRadius*2,h=simpleRadius*2})
		self.pnl = pnl
		local texture = data.good and 'guis/textures/pd2/hud_progress_active' or 'guis/textures/pd2/hud_progress_invalid'
		self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = texture, radius = simpleRadius, sides = 64, current = 20, total = 64, blend_mode = 'add', layer = 0} )
	elseif vanilla then
		local pnl = self.ppnl:panel({x = 0,y=0, w=100,h=100})
		self.pnl = pnl
		self.lbl = pnl:text{text='', font=FONT, align='center', font_size = size/2, color = data.color or data.good and clGood or clBad, x=1,y=1, layer=2, blend_mode = 'normal'}
		self.bg = HUDBGBox_create( pnl, { w = size, h = size, x = 0, y = 0 }, { color = cl.White, blend_mode = 'normal' } )
		self.bmp = data.icon and pnl:bitmap( { name='icon', texture=data.icon, texture_rect=data.iconRect, blend_mode = 'add', layer=1, x=0,y=0, color=style==2 and cl.White or data.good and clGood or clBad } ) or nil
		local texture = data.good and 'guis/textures/pd2/hud_progress_active' or 'guis/textures/pd2/hud_progress_invalid'
		if self.bmp then
			if self.bmp:width() > size then
				self.bmp:set_size(size,size)
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
		if glowy then
			self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = 'guis/textures/pd2/specialization/progress_ring',
			radius = size/2*1.2, sides = 64, current = 20, total = 64, blend_mode = 'add', layer = 0} )
			self.pie:set_position( -size*0.1, -size*0.1)
		else
			local texture = data.good and 'guis/textures/pd2/hud_progress_active' or 'guis/textures/pd2/hud_progress_invalid'
			self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = texture, radius = size/2, sides = 64, current = 20, total = 64, blend_mode = 'add', layer = 0} )
			self.pie:set_position( 0, 0)
		end
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
		local st,et = data.st,data.et or 0
		local prog = (now()-st)/(et-st)
		local style = O:get('buff','style')
		local vanilla = style == 2
		local glowy = style == 3
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
					txts = {{data.text and data.text..' ' or '',data.color}}
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
			if self.pie then
				if O:get('buff','mirrorDirection') then
					self.pie._circle:set_rotation(-(1-prog)*360)
				end
				self.pie:set_current(1-prog)
			end
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
				pnl:animate( callback( self, self, '_fade' ), callback( self, self, 'destroy' , true), 0.25 )
			end
		else
			self.ppnl:remove(self.pnl)
			self.owner.buffs[self.data.key] = nil
		end
	end
end
	-------
local TPop = class()
PocoHud3Class.TPop = TPop

function TPop:init(owner,data)
	self.owner = owner
	self.data = data
	self.data.st=now()
	self.ppnl = owner.pnl.pop
	self:_make()
end
function TPop:_make()
	local size = O:get('popup','size')
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
PocoHud3Class.TFloat = TFloat
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
	local floatO = O:get('float')
	local size = floatO.size
	local m = floatO.margin
	local pnl = self.ppnl:panel({x = 0,y=-size, w=300,h=100})
	local texture = 'guis/textures/pd2/hud_health' or 'guis/textures/pd2/hud_progress_32px'
	self.pnl = pnl
	self.bg = floatO.frame
		and HUDBGBox_create(pnl, {x= 0,y= 0,w= 1,h= 1},{color=cl.White:with_alpha(1)})
		or pnl:bitmap( { name='blur', texture='guis/textures/test_blur_df', render_template='VertexColorTexturedBlur3D', layer=-1, x=0,y=0 } )
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
	hack_suburbia = 'Hacking Machine',
	hold_download_keys = 'Encryption Keys', -- Hoxton Breakout
	hold_hack_comp = 'Security Clearance', -- Hoxton Breakout Directors PC
	hold_analyze_evidence = 'Evidence Analysis', -- Hoxton Breakout
	digitalgui = 'Timelock',
	huge_lance = 'The Beast',
}
local _drillHosts = {
	['d2e9092f3a57cefc'] = 'a mini safe',
	['e87e439e3e1a7313'] = 'a mini titan safe',
	['ad6fb7a483695e19'] = 'a safe',
	['dbfbfbb21eddcd30'] = 'a titan safe',
	['3e964910f730f3d7'] = 'a huge safe',
	['246cc067a20249df'] = 'a huge titan safe',
	['8834e3a4da3df5c6'] = 'a tall safe',
	['e3ab30d889c6db5f'] = 'a tall titan safe',
	['4407f5e571e2f51a'] = 'a door',
	['0afafcebe54ae7c4'] = 'a cage door',
	['1153b673d51ed6ad'] = 'a Gensec truck',
	['04080fd150a77c7f'] = 'a crashed Gensec truck',
	['0d07ff22a1333115'] = 'a sniped Gensec truck',
	['a8715759c090b251'] = 'a fence door',
	['a7b371bf0e3fd30a'] = 'a truck hinge',
	['07e2cf254ef76c5e'] = 'a vault cage door',
	['d475830b4e6eda32'] = 'a vault door',
	['b2928ed7d5b8797e'] = 'a cage door',
	['43132b0a273df773'] = 'an office door',
}
local __n = {}
function TFloat:_getName()
	local name = self._name or 'Drill'
	local host = self._host
	local a = not name:find('The ') and 'A' or ''
	if a then
		local n = name:sub(1,1):lower()
		if n == 'a' or n == 'e' or n == 'i' or n == 'o' or n == 'u' then
			a = a .. 'n'
		end
	end
	return _.s(a,name:lower(),host and 'on' or nil,host)
end
function TFloat:_getHost()
	local mD = self.unit and alive(self.unit) and self.unit:mission_door_device()
	local pD = mD and mD._parent_door
	local key = pD and pD:name():key()
	if key and not _drillHosts[key] then
		_(os.date(),'Found a new DrillHost',key,'\n')
	end
	return key and _drillHosts[key] or nil
end
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
	local floatO = O:get('float')
	local verbose = self.owner.verbose
	local onScr = floatO.keepOnScreen
	local size = floatO.size
	local m = floatO.margin
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
		local _sm = {floatO.keepOnScreenMarginX,floatO.keepOnScreenMarginY}
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
			local color = isCiv and cl.Lime or math.lerp( cl.Red:with_alpha(0.8), cl.Yellow, prog )
			if self.tag and self.tag.minion then
				color = self.owner:_color(self.tag.minion)
			end
			local distance = unit and mvector3.distance( unit:position(), camPos ) or 0
			if cCarry then
				color = cl.White
				table.insert(txts,{managers.localization:text(tweak_data.carry[cCarry._carry_id].name_id) or 'Bag',color})
			else
				local isWhisper = managers.groupai:state():whisper_mode()
				local pager = isWhisper and unit:interaction()._pager
				if pager then
					local eT,tT = now()-pager, unit:interaction()._pagerT or 12
					local r = eT/tT
					local pColor = math.lerp( cl.Red:with_alpha(0.8), cl.Yellow, 1-r )
					if r < 1 then
						prog = 1 - r
						table.insert(txts,{_.s(_.f(tT - eT),'/',_.f(tT)),pColor})
					end
				end
				if pDist > 100000 then
					--table.insert(txts,{''})
				elseif cHealth == 0 then
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
			local name
			local leftT
			if not alive(unit) then
				self.dead = true
			elseif tGUI then
				if tGUI._time_left <= 0 then
					self.dead = true
				end
				name = unit and unit:interaction() and unit:interaction().tweak_data
				name = name and name:gsub('_jammed',''):gsub('_upgrade','') or 'drill'
				name = _drillNames[name] or name
				leftT = tGUI._time_left
				prog = 1-tGUI._time_left/tGUI._timer
				if pDist < 10000 or verbose then
					table.insert(txts,{_.s(name..':',self.owner:_time(tGUI._time_left)..(tGUI._jammed and '!' or ''),'/',self.owner:_time(tGUI._timer)),tGUI._jammed and cl.Red or cl.White})
				else
					table.insert(txts,{_.s(self.owner:_time(tGUI._time_left))..(tGUI._jammed and '!' or ''),tGUI._jammed and cl.Red or cl.White})
				end
			elseif dGUI then
				dGUI._maxx = math.max( dGUI._maxx or 0, dGUI._timer or 0)
				if not (dGUI._ws and dGUI._ws:visible()) or dGUI._floored_last_timer <= 0 then
					return self:destroy(1)
				else
					self:renew()
				end
				name = 'digitalgui'
				name = _drillNames[name] or 'Timelock'
				leftT = dGUI._timer
				prog = 1-dGUI._timer/math.max(dGUI._maxx,1)
				if pDist < 10000 or self.owner.verbose then
					table.insert(txts,{_.s(name..':',self.owner:_time(dGUI._timer),'/',self.owner:_time(dGUI._maxx)),cl.White})
				else
					table.insert(txts,{_.s(self.owner:_time(dGUI._timer)),cl.White})
				end
			end
			if not self._name then
				self._name = name
				self._host = self:_getHost()
			end
			self.isDrill = not not tGUI
			if self.isDrill and not self._almost and leftT and leftT <= 10 then
				self._almost = true
				me:Chat('drillAlmostDone',_.s(self:_getName(),' < 10s left'))
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
		d = math.min(d,floatO.opacity/100)
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
	if self.category == 1 and self.isDrill and not self._done and not me._endGameT then
		local r,err = pcall(function()
			self._done = true
			me:Chat('drillDone',_.s(self:_getName(),'is done'))
		end)
		if not r then me:err(err) end
	end

	local pnl = self.pnl
	if alive(self.ppnl) and alive(pnl) then
		if not skipAnim then
			if not self.dying then
				self.dying = true
				pnl:stop()
				pnl:animate( callback( self, TBuff, '_fade' ), callback( self, self, 'destroy' , true), 0.2 )
			end
		else
			self.ppnl:remove(self.pnl)
			self.owner.floats[self.key] = nil
		end
	end
end
local THitDirection = class()
PocoHud3Class.THitDirection = THitDirection
function THitDirection:init(owner,data)
	self.owner = owner
	self.ppnl = owner.pnl.buff
	self.data = data
	self.sT = now()
	local pnl = self.ppnl:panel{x = 0,y=0, w=200,h=200}
	local Opt = O:get('hit')
	local rate, color = 1-(data.rate or 1)
	color = data.shield and math.lerp( Opt.shieldColor, Opt.shieldColorDepleted, rate ) or math.lerp( Opt.healthColor, Opt.healthColorDepleted, rate )

	self.pnl = pnl
	local bmp = pnl:bitmap{
		name = 'hit', rotation = 360, visible = true,
		texture = 'guis/textures/pd2/hitdirection',
		color = color,
		blend_mode='add', alpha = 1, halign = 'right'
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
			align = 'center',
			layer = 1
		}
		lbl:set_center(100,100)
		self.lbl = lbl
		lbl = pnl:text{
			x = 1,y = 1,font = font, font_size = nSize,
			w = nSize*3, h = nSize,
			text = '-'.._.f(data.dmg*10),
			color = cl.Black:with_alpha(0.2),
			align = 'center',
			layer = 1
		}
		lbl:set_center(101,101)
		self.lbl1 = lbl
		lbl = pnl:text{
			x = 1,y = 1,font = font, font_size = nSize,
			w = nSize*3, h = nSize,
			text = '-'.._.f(data.dmg*10),
			color = cl.Black:with_alpha(0.2),
			align = 'center',
			layer = 1
		}
		lbl:set_center(99,101)
		self.lbl2 = lbl
	end
	pnl:stop()
	local du = Opt.duration
	if du == 0 then
		du = self.data.time or 2
	end
	pnl:animate( callback( self, self, 'draw' ), callback( self, self, 'destroy'), du )
end
function THitDirection:draw(pnl, done_cb, seconds)
	local pnl = self.pnl
	local Opt = O:get('hit')
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
		self.bmp:set_alpha( math.pow(p,0.5) * Opt.opacity/100 )

		local target_vec = self.data.mobPos - self.owner.camPos
		local fwd = self.owner.nl_cam_forward
		local angle = target_vec:to_polar_with_reference( fwd, math.UP ).spin
		local r = Opt.sizeStart + (1-math.pow(p,0.5)) * (Opt.sizeEnd-Opt.sizeStart)

		self.bmp:set_rotation(-(angle+90))
		if self.lbl then
			self.lbl:set_rotation(-(angle))
			self.lbl1:set_rotation(-(angle))
			self.lbl2:set_rotation(-(angle))
		end
		pnl:set_center(ww/2-math.sin(angle)*r,hh/2-math.cos(angle)*r)
	end
	pnl:set_visible( false )
	if done_cb then done_cb(pnl) end
end
function THitDirection:destroy()
	self.ppnl:remove(self.pnl)
	self = nil
end
--- Location start ---
local PocoLocation = {
	rooms = {},
	r = Draw:pen( 'no_z', cl.Red:with_alpha(0.5) )   ,
	g = Draw:pen( 'no_z', cl.Green:with_alpha(0.5) ),
	b = Draw:pen( 'no_z', cl.Blue:with_alpha(0.5) ) ,
}
PocoHud3Class.PocoLocation = PocoLocation
function PocoLocation:newRoom(name)
	local currentRoom = {}
	self.currentName = name
	self.currentRoom = currentRoom
	_.c('NewRoom',name)
end
function PocoLocation:endRoom()
	local lvl = managers.job:current_level_id() or ''
	local currentRooms = self.rooms[lvl] or {}
	if type(currentRooms) == 'string' then
		currentRooms = self.rooms[currentRooms] or {}
	end
	self.rooms[lvl] = currentRooms
	self.currentRooms = currentRooms
	local parsedRoom -- {x,y,z,x,y,z}
	if self.currentRoom then
		local mi,ma = {}, {}
		for i,point in pairs(self.currentRoom) do
			mi.x = mi.x and math.min(point.x,mi.x) or point.x
			mi.y = mi.y and math.min(point.y,mi.y) or point.y
			mi.z = mi.z and math.min(point.z,mi.z) or point.z
			ma.x = ma.x and math.max(point.x,ma.x) or point.x
			ma.y = ma.y and math.max(point.y,ma.y) or point.y
			ma.z = ma.z and math.max(point.z,ma.z) or point.z
		end
		parsedRoom = {mi,ma}
	end

	if parsedRoom then
		currentRooms[self.currentName] = parsedRoom
		_.c('EndRoom',self.currentName)
	end
end
function PocoLocation:addPoint(pos)
	if self.currentRoom then
		table.insert(self.currentRoom,pos)
		_.c('AddPoint',tostring(pos))
	else
		_.c('AddPoint','NoRoom')
	end
end

function PocoLocation:_drawBox(pen,a,b)
	if not (pen and a and a.x) then
		return
	end
	pen:sphere(Vector3(a.x,a.y,a.z),3)
	pen:sphere(Vector3(b.x,b.y,b.z),3)

	pen:line(Vector3(a.x,a.y,a.z),Vector3(a.x,b.y,a.z))
	pen:line(Vector3(a.x,a.y,a.z),Vector3(b.x,a.y,a.z))
	pen:line(Vector3(a.x,b.y,a.z),Vector3(b.x,b.y,a.z))
	pen:line(Vector3(b.x,a.y,a.z),Vector3(b.x,b.y,a.z))

	pen:line(Vector3(a.x,a.y,b.z),Vector3(a.x,b.y,b.z))
	pen:line(Vector3(a.x,a.y,b.z),Vector3(b.x,a.y,b.z))
	pen:line(Vector3(a.x,b.y,b.z),Vector3(b.x,b.y,b.z))
	pen:line(Vector3(b.x,a.y,b.z),Vector3(b.x,b.y,b.z))

	pen:line(Vector3(a.x,a.y,a.z),Vector3(a.x,a.y,b.z))
	pen:line(Vector3(a.x,b.y,a.z),Vector3(a.x,b.y,b.z))
	pen:line(Vector3(b.x,a.y,a.z),Vector3(b.x,a.y,b.z))
	pen:line(Vector3(b.x,b.y,a.z),Vector3(b.x,b.y,b.z))

end

function PocoLocation:get(pos,translate)
	local found, foundVol
	if pos and pos.x then
		local x,y,z = pos.x,pos.y,pos.z
		for name,room in pairs(self.currentRooms or {}) do
			local mi,ma = room[1],room[2]
			if (mi.x <= x and ma.x >= x) and
				(mi.y <= y and ma.y >= y) and
				(mi.z <= z and ma.z >= z) then
				local vol = math.abs((ma.x-mi.x)*(ma.y-mi.y)*(ma.z-mi.z))
				if not found or foundVol > vol then
					found = name
					foundVol = vol
				end
			end
		end
	end
	if found and translate then
		return found -- TODO
	else
		return found,foundVol
	end
end

function PocoLocation:update(t,dt)
	Poco.room = self
	if not self._loaded then
		self._loaded = true
		self:load()
	end
	local ff = _.g('setup:freeflight()')
	if ff then
		ff:update(t, dt)
	end
	if not Poco.roomOn then return end

	local fCam = ff and ff:enabled() and ff._camera_object
	local pos = fCam and fCam:position() or _.g('managers.player:player_unit():position()')
--	_.d('Room',self:get(pos) or 'None',#(self.currentRooms or {}))
	local ray = fCam and World:raycast("ray", fCam:position(), fCam:position() + fCam:rotation():y() * 10000) or _.r()
	if ray and ray.position then
		local g = 20
		local pos = Vector3(math.floor(ray.position.x/g+0.5)*g,math.floor(ray.position.y/g+0.5)*g,math.floor(ray.position.z/g+0.5)*g)
		if pos ~= self.pos then
			self.pos = pos
			self.b:sphere(pos,10)
		else
			self.r:sphere(pos,10)
		end
		if now()-(self._lastIn or 0) > 0.5 then
			if shift() then
				if ctrl() then
					self:endRoom()
					self._lastIn = now()
				else
					self:addPoint(pos)
					self._lastIn = now()
				end
			end
		end
	end
	if self.currentRoom then
		local mi,ma = {}, {}
		for i,point in pairs(self.currentRoom) do
			mi.x = mi.x and math.min(point.x,mi.x) or point.x
			mi.y = mi.y and math.min(point.y,mi.y) or point.y
			mi.z = mi.z and math.min(point.z,mi.z) or point.z
			ma.x = ma.x and math.max(point.x,ma.x) or point.x
			ma.y = ma.y and math.max(point.y,ma.y) or point.y
			ma.z = ma.z and math.max(point.z,ma.z) or point.z
		end
		if mi.x then
			self:_drawBox(self.g,mi,ma)
		end
	end
	for k,room in pairs(self.currentRooms or {}) do
		local mi,ma = room[1],room[2]
		if mi.x then
			self:_drawBox(self.b,mi,ma)
		end

	end
end
--- End of Location1
--[[
1. _.g('managers.player:player_unit():movement():nav_tracker():nav_segment()')
2. managers.navigation:get_nav_seg_metadata(_1_)
3.
]]

--- End of Location2

local LocationJSONFilename = 'poco\\hud3_rooms.json';
function PocoLocation:load()
	local f,err = io.open(LocationJSONFilename, 'r')
	local result = false
	if f then
		local t = f:read('*all')
		local o = JSON:decode(t)
		if type(o) == 'table' then
			self.rooms = o
			self:endRoom()
			result = true
		end
		f:close()
	end
	return result
end

function PocoLocation:save()
	local f = io.open(LocationJSONFilename, 'w')
	if f then
		f:write(JSON:encode_pretty(self.rooms))
		f:close()
	end
end

--- GUI start ---
local Layers = {
	Blur = 1001,
	Bg = 1002,
	TabHeader = 1003
}
local PocoUIElem = class()
local PocoUIHintLabel -- forward-declared
function PocoUIElem:init(parent,config)
	config = _.m({
		w = 400,h = 20,
	}, config)

	self.parent = parent
	self.config = config or {}
	self.ppnl = config.pnl or parent.pnl
	self.pnl = self.ppnl:panel({ name = config.name, x=config.x, y=config.y, w = config.w, h = config.h})
	self.status = 0

	if self.config[PocoEvent.Click] then
		self:_bind(PocoEvent.Out, function(self)
			self._pressed = nil
		end):_bind(PocoEvent.Pressed, function(self,x,y)
			self._pressed = true
		end):_bind(PocoEvent.Released, function(self,x,y)
			if self._pressed then
				self._pressed = nil
				return self:fire(PocoEvent.Click,x,y)
			end
		end)
	end

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

function PocoUIElem:set_y(y)
	self.pnl:set_y(y)
end
function PocoUIElem:set_center_x(x)
	self.pnl:set_center_x(x)
end
function PocoUIElem:set_x(x)
	self.pnl:set_x(x)
end
function PocoUIElem:inside(x,y)
	return alive(self.pnl) and self.pnl:inside(x,y)
end

function PocoUIElem:_bind(eventVal,cbk)
	if not self.config[eventVal] then
		self.config[eventVal] = cbk
	else
		local _old = self.config[eventVal]
		self.config[eventVal] = function(...)
			local result = _old(...)
			if not result then
				result = cbk(...)
			else
			end
			return result
		end
	end
	return self
end

function PocoUIElem:sound(sound)
	managers.menu_component:post_event(sound)
end

function PocoUIElem:hide()
	self._hide = true
	if alive(self.pnl) then
		self.pnl:set_visible(false)
	end
end

function PocoUIElem:setLabel(text)
	if alive(self.lbl) then
		self.lbl:set_text(text)
	end
end

function PocoUIElem:disable()
	self._disabled = true
end

function PocoUIElem:isHot(event,x,y)
	return not self._disabled and not self._hide and alive(self.pnl) and self.pnl:inside(x,y)
end

function PocoUIElem:fire(event,x,y)
	if self.parent.dead or not alive(self.pnl) then return end
	local result = {self.config[event](self,x,y)}
	local sound = {
		onPressed = 'prompt_enter'
	}
	if self.config[event] then
		if self.result == false then
			self:sound('menu_error')
			self.result = nil
			return true
		elseif self.mute then
			self.mute = nil
			return true
		end
		if sound[event] then
			self:sound(sound[event])
		end
		return unpack(result)
	end
end

local PocoRoseButton = class(PocoUIElem)
PocoHud3Class.PocoRoseButton = PocoRoseButton
function PocoRoseButton:init(parent,config,inherited)
	self.super.init(self,parent,config,true)
	self.pnl:set_center(config.x,config.y)

	local spnl
	local clShadow = cl.Black:with_alpha(0.8)
	local __, lbl = _.l({
		pnl = self.pnl,x=-1, y=0, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = clShadow,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)
	self.lbl1 = lbl
	__, lbl = _.l({
		pnl = self.pnl,x=0, y=1, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = clShadow,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)
	self.lbl2 = lbl
	__, lbl = _.l({
		pnl = self.pnl,x=1, y=0, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = clShadow,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)
	self.lbl3 = lbl
	__, lbl = _.l({
		pnl = self.pnl,x=0, y=-1, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = clShadow,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)
	self.lbl4 = lbl
	__, lbl = _.l({
		pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = config.fontColor or cl.White,
		align = config.align or 'center', vertical = config.vAlign or 'center', layer = 1
	},config.text,config.autoSize)
	self.lbl = lbl
	self.mul = 1
	self.pnl:animate(function(p)
		while alive(p) do
			local mul = math.ceil(100*self.mul)/100
			local t = config.fontSize*mul
			local r = self._r or 0
			r = r + (t-r)/10
			if p:visible() and math.abs(r - (self._r or 0)) > 0.1 then
				self._r = r
				self.lbl1:set_font_size(r)
				self.lbl2:set_font_size(r)
				self.lbl3:set_font_size(r)
				self.lbl4:set_font_size(r)
				self.lbl:set_font_size(r)
				self.lbl:set_alpha(r/config.fontSize/1.4)
			end
			coroutine.yield()
		end
	end)


	self:_bind(PocoEvent.In, function(self,x,y)
		if alive(self.pnl) then
			spnl = self.pnl:panel{}
			BoxGuiObject:new(spnl, {sides = {1,1,1,1}})
			spnl:rect{color=cl.Black,alpha=0.2,layer=-1}
			me._say = config.value
			self:sound('slider_grab')
			self.mul = 1.6
		end
	end):_bind(PocoEvent.Out, function(self,x,y)
		if alive(self.pnl) then
			if spnl then
				self.pnl:remove(spnl)
				spnl = nil
			end
			self.mul = 1
			me._say = nil
		end
	end)
	if not inherited then
		self:postInit(self)
	end
end


PocoUIHintLabel = class(PocoUIElem) -- Forward-declared as local
PocoHud3Class.PocoUIHintLabel = PocoUIHintLabel
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
	local hintPnl

	local _reposition = function(x,y)
		if hintPnl then
			x = math.max(0,math.min(self.ppnl:w()-hintPnl:w(),x+10))
			y = math.max(self.ppnl:world_y(),math.min((me.hh or 0)-20-hintPnl:h(),y))
			hintPnl:set_world_position(x,y+20)
		end
	end
	local _buildOne = function(x,y)
		hintPnl = self.ppnl:panel{
			x = 0, y = 0, w = 800, h = 200
		}
		local __, hintLbl = _.l({
			pnl = hintPnl,x=5, y=5, font = config.hintFont or FONT, font_size = config.hintFontSize or 18, color = config.hintFontColor or cl.White,
			align = config.align, vertical = config.vAlign, layer = 2, rotation = 360
		},config.hintText or '',true)
		hintPnl:set_size(hintLbl:size())
		hintPnl:grow(10,10)
		hintPnl:rect{ color = cl.Black:with_alpha(0.7), layer = 1, rotation = 360}
		_reposition(x,y)
	end
	self:_bind(PocoEvent.In, function(self,x,y)
		if not hintPnl then
			_buildOne(x,y)
		end
	end):_bind(PocoEvent.Out, function(self,x,y)
		if hintPnl then
			if alive(hintPnl) then
				self.ppnl:remove(hintPnl)
			end
			hintPnl = nil
		end
	end):_bind(PocoEvent.Move, function(self,x,y)
		_reposition(x,y)
	end)

end


local PocoUIButton = class(PocoUIElem)
PocoHud3Class.PocoUIButton = PocoUIButton

function PocoUIButton:init(parent,config,inherited)
	self.super.init(self,parent,config,true)

	local spnl = self.pnl:panel{}
	BoxGuiObject:new(spnl, {sides = {1,1,1,1}})
	spnl:rect{color=cl.Black,alpha=0.5,layer=-1}
	spnl:set_visible(false)
	local __, lbl = _.l({
		pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = config.fontColor or cl.White,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)

	self:_bind(PocoEvent.In, function(self,x,y)
		spnl:set_visible(true)
		self:sound('slider_grab')
	end):_bind(PocoEvent.Out, function(self,x,y)
		spnl:set_visible(false)
	end)

	self.lbl = lbl
	if not inherited then
		self:postInit(self)
	end
end

local PocoUIValue = class(PocoUIElem)
PocoHud3Class.PocoUIValue = PocoUIValue
function PocoUIValue:init(parent,config,inherited)
	PocoUIElem.init(self,parent,config,true)

	local bg = self.pnl:rect{color = cl.White:with_alpha(0.1),layer=-1}
	bg:set_visible(false)
	self:_bind(PocoEvent.In, function(self,x,y)
		bg:set_visible(true)
		self:sound('slider_grab')
	end):_bind(PocoEvent.Out, function(self,x,y)
		bg:set_visible(false)
	end)

	local __, lbl = _.l({
			pnl = self.pnl,x=5, y=0, w = config.w, h = config.h, font = FONT, font_size = config.fontSize or 24,
			color = config.fontColor or cl.White },config.text,true)
	self.lbl = lbl
	self.lbl:set_center_y(config.h/2)
	local __, lbl = _.l({
			pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = FONT, font_size = config.fontSize or 24,
			color = config.fontColor or cl.White },config.text,true)
	self.valLbl = lbl
	self.valLbl:set_center_y(config.h/2)

	if not config.noArrow then
		self.arrowLeft = self.pnl:bitmap({
			texture = 'guis/textures/menu_icons',
			texture_rect = {
				0,
				5,
				15,
				20
			},
			color = cl.White,
			x = 0,
			y = 0,
			blend_mode = 'add'
		})
		self.arrowRight = self.pnl:bitmap({
			texture = 'guis/textures/menu_icons',
			texture_rect = {
				10,
				5,
				20,
				20
			},
			color = cl.White,
			x = 20,
			y = 1,
			blend_mode = 'add',
			--rotation = 180,
		})
		self.arrowRight:set_right(config.w)
		self.arrowLeft:set_left(config.w/2)

		self.arrowLeft:set_center_y(config.h/2)
		self.arrowRight:set_center_y(config.h/2)

		local shift = function()
			return Poco._kbd:down(42) or Poco._kbd:down(54)
		end

		self:_bind(PocoEvent.Pressed,function(self,x,y)
			if self.arrowRight:inside(x,y) then
				self:next()
			elseif self.arrowLeft:inside(x,y) then
				self:prev()
			else
				self.mute = true
			end
		end):_bind(PocoEvent.Move,function(self,x,y)
			if self.arrowRight:inside(x,y) or self.arrowLeft:inside(x,y) then
				self.cursor = 'link'
			elseif shift() then
				self.cursor = 'grab'
			else
				self.cursor = 'arrow'
			end
		end):_bind(PocoEvent.WheelUp,function()
			if shift() then
				self:sound('slider_increase')
				return true, self:next()
			end
		end):_bind(PocoEvent.WheelDown,function(...)
			if shift() then
				self:sound('slider_decrease')
				return true, self:prev()
			end
		end)
	end


	-- Always inherited though
end

function PocoUIValue:next()
	self.result = false
end

function PocoUIValue:prev()
	self.result = false
end

function PocoUIValue:isValid(val)
	return true
end

function PocoUIValue:isDefault(val)
	if val == nil then
		val = self:val()
	end
	return O:isDefault(self.config.category,self.config.name,val)
end

function PocoUIValue:_markDefault(set)
	if self.config.category then
		local isChanged = O:isChanged(self.config.category,self.config.name,set)
		_.l(self.lbl,{self.config.text,self:isDefault(set) and cl.White or (isChanged and cl.LightSkyBlue or cl.DarkKhaki)})
	end
end

function PocoUIValue:val(set)
	if set ~= nil then
		if not self.value or self:isValid(set) then
			self.value = set
			_.l(self.valLbl,set,true)
			self.valLbl:set_center_x(self.config.valX or 12*self.config.w/16)
			self.valLbl:set_x(math.floor(self.valLbl:x()))
			self:_markDefault(set)
			return set
		else
			return false
		end
	else
		return self.value
	end
end

local PocoUIBoolean = class(PocoUIValue)
PocoHud3Class.PocoUIBoolean = PocoUIBoolean
function PocoUIBoolean:init(parent,config,inherited)
	config.noArrow = true
	self.super.init(self,parent,config,true)
	self.tick = self.pnl:bitmap({
		name = 'tick',
		texture = 'guis/textures/menu_tickbox',
		texture_rect = {
			0,
			0,
			24,
			24
		},
		w = 24,
		h = 24,
		color = cl.White
	})
	self.tick:set_center_y(config.h/2)

	self.lbl:set_x(self.lbl:x()+20)
	self.valLbl:set_visible(false)
	self:val(config.value or false)
	self:_bind(PocoEvent.Pressed,function(self,x,y)
		self:val(not self:val())
		self:sound('box_'..(self:val() and 'tick' or 'untick'))
		self.mute = true
	end)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIBoolean:val(set)
	if set ~= nil then
		if not self.value or self:isValid(set) then
			self.value = set
			if self.tick then
				if not set then
					self.tick:set_texture_rect(0,0,24,24)
				else
					self.tick:set_texture_rect(24,0,24,24)
				end
			end
			self:_markDefault(set)
			return set
		else
			return false
		end
	else
		return self.value
	end
end

local PocoUINumValue = class(PocoUIValue)
PocoHud3Class.PocoUINumValue = PocoUINumValue

function PocoUINumValue:init(parent,config,inherited)
	self.super.init(self,parent,config,true)
	self:val(tonumber(config.value) or 0)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUINumValue:next(predict)
	local tVal = self:val()+(self.config.step or 1)
	if predict then
		return self:isValid(tVal,1)
	else
		return self:val(tVal)
	end
end

function PocoUINumValue:prev(predict)
	local tVal = self:val()-(self.config.step or 1)
	if predict then
		return self:isValid(tVal,1)
	else
		return self:val(tVal)
	end
end

function PocoUINumValue:isValid(val,silent)
	local result = (type(val) == 'number') and (val <= (self.config.max or 100)) and (val >= (self.config.min or 0))
	if not silent then
		self.result = result
	end
	return result
end

function PocoUINumValue:val(set)
	local result = PocoUIValue.val(self,set)
	if set and self.config.vanity then
		_.l(self.valLbl,self.config.vanity[self:val()+1] or self:val(),true)
		self.valLbl:set_center_x(3*self.config.w/4)
		self.valLbl:set_x(math.floor(self.valLbl:x()))
	end
	if set and self.arrowLeft then
		self.arrowLeft:set_alpha(self:prev(1) and 1 or 0.1)
		self.arrowRight:set_alpha(self:next(1) and 1 or 0.1)
	end
	return result
end

local PocoUIChooseValue = class(PocoUIValue)
PocoHud3Class.PocoUIChooseValue = PocoUIChooseValue
function PocoUIChooseValue:init(parent,config,inherited)
	PocoUIValue.init(self,parent,config,true)
	-- abstract
end

function PocoUIChooseValue:selection()
	return {}
end

function PocoUIChooseValue:go(delta)
	local val = self:val()
	local sel = self:selection()
	local keys = table.sorted_keys(sel)
	local ind = table.index_of(keys,val)
	self:val(keys[ind+delta] or delta>0 and keys[1] or keys[#keys] )
end

function PocoUIChooseValue:next()
	self:go(1)
end

function PocoUIChooseValue:prev()
	self:go(-1)
end

function PocoUIChooseValue:innerVal(set)
	if set then
		local key = table.get_key(self:selection(),set)
		if key then
			return self:val(key)
		end
	else
		return self:selection()[self:val()]
	end
end

local PocoUIBooleanValue = class(PocoUIChooseValue)
PocoHud3Class.PocoUIBooleanValue = PocoUIBooleanValue

function PocoUIBooleanValue:init(parent,config,inherited)
	PocoUIChooseValue.init(self,parent,config,true)
	self:val(isNil(config.value) and 'YES' or config.value)
	if not inherited then
		self:postInit(self)
	end
end

function PocoUIBooleanValue:selection()
	return {YES = true, NO = false}
end

local PocoUIReversedBooleanValue = class(PocoUIBooleanValue)
PocoHud3Class.PocoUIReversedBooleanValue = PocoUIReversedBooleanValue

function PocoUIReversedBooleanValue:selection()
	return {YES=true,NO=false}
end
local PocoUIColorValue = class(PocoUIChooseValue)
PocoHud3Class.PocoUIColorValue = PocoUIColorValue
function PocoUIColorValue:init(parent,config,inherited)
	self.super.init(self,parent,config,true)
	self:val(config.value or 'White')

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIColorValue:selection()
	return cl
end

function PocoUIColorValue:val(set)
	local val = PocoUIValue.val(self,set)
	if set then
		local color = cl[val] or cl.White
		_.l(self.valLbl,{val,color})
	end
	return val
end

local PocoUIKeyValue = class(PocoUIValue)
PocoHud3Class.PocoUIKeyValue = PocoUIKeyValue
function PocoUIKeyValue:init(parent,config,inherited)
	config.noArrow = true
	self.super.init(self,parent,config,true)
	self:val(config.value or '')
	self:_bind(PocoEvent.Pressed,function(self,x,y)
		self.mute = true
		if self._waiting then
			self:sound('menu_error')
			self:cancel()
		else
			self:sound('prompt_enter')
			self:setup()
		end
	end):_bind(PocoEvent.Click,function(self,x,y)
		if not self:inside(x,y) then
			self:sound('menu_error')
			self:cancel()
		end
	end)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIKeyValue:setup()
	self._waiting = true
	me._focused = self
	me._ws:connect_keyboard(Input:keyboard())
	local onKeyPress = function(o, key)
		me._stringFocused = now()
		local keyName = Input:keyboard():button_name_str(key)
		if key == Idstring('backspace') then
			self:sound('menu_error')
			self:val('')
			self:cancel()
			return
		end
		local ignore = ('enter,space,esc,num abnt c1,num abnt c2,@,ax,convert,kana,kanji,no convert,oem 102,stop,unlabeled,yen,mouse 8,mouse 9'):split(',')
		for __,iKey in pairs(ignore) do
			if key == Idstring(iKey) then
				if iKey ~= 'esc' then
					managers.menu:show_key_binding_forbidden({KEY = keyName})
				end
				self:sound('menu_error')
				self:cancel()
				return
			end
		end
		self:sound('menu_skill_investment')
		self:val(keyName)
		self:cancel()
	end
	_.l(self.valLbl,'_',true)
	self.valLbl:key_press(onKeyPress)
end

function PocoUIKeyValue:cancel()
	self._waiting = nil
	me._ws:disconnect_keyboard()
	me._focused = nil
	self.valLbl:key_press(nil)
	self:val(self:val())
end

function PocoUIKeyValue:val(set)
	local val = PocoUIValue.val(self,set)
	if set then
		if set == '' then
			set = {'NONE',cl.Silver}
		else
			set = set:upper()
		end
		_.l(self.valLbl,set,true)
	end
	return val
end


local PocoUIStringValue = class(PocoUIValue)
PocoHud3Class.PocoUIStringValue = PocoUIStringValue

function PocoUIStringValue:init(parent,config,inherited)
	config.noArrow = true
	self.super.init(self,parent,config,true)
	self:_initLayout()
	self:val(config.value or '')
	self.box = self.pnl:rect{color = cl.White:with_alpha(0.3), visible = false}
	self:_bind(PocoEvent.Pressed,function(self,x,y)
		if not self._editing then
			self:startEdit()
			self:selectAll()
		else
			if now() - (self._lastClick or 0) < 0.3 then
				self:selectAll()
			elseif self.valLbl:inside(x,y) then
				self:_setCaret(x)
			else
				self:endEdit()
			end
		end
		self._lastClick = now()
	end):_bind(PocoEvent.WheelUp,self.next):_bind(PocoEvent.WheelDown,self.prev):_bind(PocoEvent.Click,function(self,x,y)
		if not self:inside(x,y) then
			self:endEdit()
		end
	end)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIStringValue:_initLayout()
	if not self.config.valX and self.config.text:gsub(' ','') == '' then
		self.config.valX = self.config.w / 2
	end
end

function PocoUIStringValue:val(set)
	if set then
		set = utf8.sub(set,1,self.config.max or 15)
	end
	local result =  PocoUIValue.val(self,set)
	self:repaint()
	return result
end

function PocoUIStringValue:startEdit()
	self._editing = true
	self.box:set_visible(true)
	me._ws:connect_keyboard(Input:keyboard())
	me._focused = self
	self.pnl:enter_text(callback(self, self, 'enter_text'))
	self.pnl:key_press(callback(self, self, 'key_press'))
	self.pnl:key_release(callback(self, self, 'key_release'))
	local l = utf8.len(self:val())
	self.valLbl:set_selection(l,l)
	self._rename_caret = self.pnl:rect({
		name = 'caret',
		layer = -1,
		x = 10,
		y = 10,
		w = 2,
		h = 2,
		color = cl.Red
	})
	self:repaint()
	self._rename_caret:animate(self.blink)
	self.beforeVal = self:val()
end

function PocoUIStringValue:selectAll()
	self:_select(0, utf8.len(self:val()))
	self._start = 0
	self._shift = nil
	self:repaint()
end

function PocoUIStringValue:_select(tS,tE)
	local s,e = self.valLbl:selection()
	local l = utf8.len(self:val())
	if tS and tE then
		s, e = math.max(0,tS),math.min(tE,l)
		if s == e then
			self._start = s
		end
		self.valLbl:set_selection(s,e)
	else
		return s,e
	end
end
function PocoUIStringValue:select(delta,shift)
	local s, e = self:_select()
	if shift then -- start Shift
		self._start = s
		self._shift = true
	elseif shift == false then
		self._shift = nil
	elseif self._shift then -- grow selection
		local ss = self._start
		if delta > 0 then
			if ss == s then
				self:_select(ss,e+delta)
			else
				self:_select(s+delta,ss)
			end
		elseif delta < 0 then
			if ss == e then
				self:_select(s+delta,ss)
			else
				self:_select(ss,e+delta)
			end
		end
	else -- simpleMove
		self:_select(s+delta,s+delta)
	end

end

function PocoUIStringValue:_setCaret(worldX)
	local lbl = self.valLbl
	local l = utf8.len(self:val())
	if l == 0 then
		self:select(0,0)
	end
	local c, x, y, w, h = -1
	repeat
		c = c + 1
		self:_select(c,c)
		x, y, w, h = self.valLbl:selection_rect()
	until x>=worldX or c > l
	self:_select(c-1,c-1)
	self:repaint()
end

function PocoUIStringValue:endEdit(cancel)
	self._editing = nil
	me._focused = nil
	self.box:set_visible(false)
	me._ws:disconnect_keyboard()
	self:_select(0,0)
	self.pnl:enter_text(nil)
	self.pnl:key_press(nil)
	self.pnl:key_release(nil)
	self.pnl:remove(self._rename_caret)
	self._rename_caret = nil
	if cancel then
		self:val(self.beforeVal)
	end
	self.beforeVal = nil
end

function PocoUIStringValue:repaint()
	me._stringFocused = now()
	if self.box then
		local x,y,w,h = self.valLbl:shape()
		x, y, w, h = x-5, y-5, w+10, math.max(h+10,self.config.h+10)
		self.box:set_shape(x,y,w,h)
	end
	if self._rename_caret then
		local x, y, w, h = self.valLbl:selection_rect()
		if x == 0 then
			x,y = self.valLbl:world_position()
		end
		w = math.max(w,3)
		h = math.max(h,20)
		self._rename_caret:set_world_shape(x,y,w,h)
	end
end

function PocoUIStringValue.blink(o)
	while alive(o) do
		o:set_color(cl.White:with_alpha(0.1))
		wait(0.2)
		o:set_color(cl.White:with_alpha(0.5))
		wait(0.3)
	end
end
function PocoUIStringValue:enter_text(o, s)
	if self._editing then
		self.valLbl:replace_text(s)
		self:val(self.valLbl:text())
	end
end

function PocoUIStringValue:key_release(o, k)
	if k == Idstring('left shift') or k == Idstring('right shift') then
		self:select(0,false)
	elseif k == Idstring('left ctrl') or k == Idstring('right ctrl') then
		self._key_ctrl_pressed = false
	end
end

function PocoUIStringValue:key_press(o, k)
	if managers.menu:active_menu() then
		managers.menu:active_menu().renderer:disable_input(0.2)
	end
	local lbl = self.valLbl
	local n = utf8.len(lbl:text())
	local s, e = lbl:selection()
	if k == Idstring('delete') then
		if s == e and s > 0 then
			lbl:set_selection(s, e+1)
		end
		self:enter_text('')
	elseif k == Idstring('backspace') then
		if s == e and s > 0 then
			lbl:set_selection(s - 1, e)
		end
		self:enter_text('')
	elseif k == Idstring('left') then
		self:select(-1)
		--[[
		if s < e then
			lbl:set_selection(s, s)
		elseif s > 0 then
			lbl:set_selection(s - 1, s - 1)
		end]]

	elseif k == Idstring('right') then
		self:select(1)
		--[[
		if s < e then
			lbl:set_selection(e, e)
		elseif s < n then
			lbl:set_selection(s + 1, s + 1)
		end]]
	elseif k == Idstring('end') then
		lbl:set_selection(n, n)
	elseif k == Idstring('home') then
		lbl:set_selection(0, 0)
	elseif k == Idstring('enter') or k == Idstring('tab') then
		self:endEdit()
	elseif k == Idstring('esc') then
		self:endEdit(true)
		return
	elseif k == Idstring('left shift') or k == Idstring('right shift') then
		self:select(0,true)
	elseif k == Idstring('left ctrl') or k == Idstring('right ctrl') then
		self._key_ctrl_pressed = true
	elseif self._key_ctrl_pressed == true then
		return
	end
	self:repaint()
end


local PocoScrollBox = class(PocoUIElem)
PocoHud3Class.PocoScrollBox = PocoScrollBox
function PocoScrollBox:init(parent,config,inherited)
	self.parent = parent
	self.config = config
	self.wrapper = config.pnl:panel(config)
	self.pnl = self.wrapper:panel{ x=0, y=0, w =self.wrapper:w(), h = self.wrapper:h(), name = 'content'}
	local m,sW = 10,4
	local sH = self.wrapper:h()-(2*m)
	local _matchScroll = function()
		local pH,wH = self.pnl:h(), self.wrapper:h()
		self.sPnl:set_y(m-self.pnl:y()*wH/pH)
		self.sPnl:set_h(self.wrapper:h()/self.pnl:h() * sH - m)
	end
	self._matchScroll = _matchScroll
	self.sPnl = self.wrapper:panel{ x=self.wrapper:w()-sW-m/2, y=m, w =sW, h = sH, name = 'scroll', visible = false}
	BoxGuiObject:new(self.sPnl, { sides = {2,2,0,0} }):set_aligns('scale', 'scale')
	self.sPnl:stop()
	self.sPnl:animate(function(p)
		while alive(p) do
			if p:visible() then
				local a = math.max(0.05,0.3-now()+(self._t or 0))*4
				if a ~= self._a then
					p:set_alpha(a)
					self._a = a
				end
			end
			coroutine.yield()
		end
	end)

	self.pnl:stop()
	self.pnl:animate(function(panel)
		while alive(panel) do
			if panel:visible() then
				local tY,cY = math.floor(self.y or 0),math.floor(panel:y())
				local rY = math.floor(cY + ((tY-cY)/5))
				if tY~=rY then
					if math.abs(tY - rY)<5 then
						rY = tY
					end
					rY = math.floor(rY + 1)
					self._t = now()
					panel:set_y(rY)
					_matchScroll()
				end
			end
			coroutine.yield()
		end
	end)

	local scrollStep = 60
	self:_bind(PocoEvent.WheelUp,function(_self,x,y)
		if not shift() and self:canScroll(false,x,y) then
			return true, self:scroll(scrollStep)
		end
	end):_bind(PocoEvent.WheelDown,function(_self,x,y)
		if not shift() and self:canScroll(true,x,y) then
			return true, self:scroll(-scrollStep)
		end
	end)
	if not inherited then
		self:postInit(self)
	end
end

function PocoScrollBox:set_h(_h)
	self.pnl:set_h(math.max(self.wrapper:h(),_h or 0))
	if self.pnl:h() > self.wrapper:h() then
		self.sPnl:set_visible(true)
	else
		self.sPnl:set_visible(false)
		self:scroll(0,true)
	end
	self:_matchScroll()
end

function PocoScrollBox:isLarge()
	return self.pnl:h() > self.wrapper:h()
end

function PocoScrollBox:canScroll(down,x,y)
	local result = self:isLarge() and self.wrapper:inside(x,y) and self
	if (self._errCnt or 0) > 1 then
		local pos = self.y or 0
		if (pos == 0) ~= down then
			result = false
		end
	end
	return result
end

function PocoScrollBox:scroll(val,force)
	local tVal = force and 0 or (self.y or 0) + val
	local pVal = math.clamp(tVal,self.wrapper:h()-self.pnl:h()-20,0)
	if pVal ~= tVal then
		self._errCnt = 1+ (self._errCnt or 0)
	else
		self._errCnt = 0
		if not force then
			managers.menu:post_event(val>0 and 'slider_increase' or 'slider_decrease')
		end
	end
	self.y = pVal
end

local PocoTab = class()
PocoHud3Class.PocoTab = PocoTab

function PocoTab:init(parent,ppnl,tabName)
	self.parent = parent -- tabs
	self.ppnl = ppnl
	self.name = tabName
	self.hotZones = {}
	self.box = PocoScrollBox:new(self,{ pnl = ppnl, x=0, y=parent.config.th,w = ppnl:w(), h = ppnl:h()-parent.config.th, name = tabName})
	self.pnl = self.box.pnl

end

function PocoTab:insideTabHeader(x,y,noChildren)
	local result = self.bg and alive(self.bg) and self.bg:inside(x, y) and self
	if not result and not noChildren then
		if self._children then
			for name,child in pairs(self._children) do
				if child.currentTab and child.currentTab:insideTabHeader(x,y) then
					return child,false
				end
			end
		end
	end
	return result,true
end

function PocoTab:addHotZone(event,item)
	self.hotZones[event] = self.hotZones[event] or {}
	table.insert(self.hotZones[event],item)
end

function PocoTab:isHot(event, x, y, autoFire)
	if self.hotZones[event] and alive(self.pnl) and self.box.wrapper:inside(x,y) then
		for i,hotZone in pairs(self.hotZones[event]) do
			if hotZone:isHot(event, x,y) then
				if autoFire then
					local r = hotZone:fire(event, x, y)
					if r then
						return r
					end
				else
					return hotZone
				end
			end
		end
	end
	if self._children then
		for name,child in pairs(self._children) do
			local cResult = child.currentTab and child.currentTab:isHot(event,x,y,autoFire)
			if cResult then return cResult end
		end
	end
	return false
end

function PocoTab:scroll(val, force)
	return self.box:scroll(val,force)
--	return self.pnl:set_y(pVal)
end

function PocoTab:canScroll(down,x,y)
	return self.box:canScroll(down,x,y)
end

function PocoTab:set_h(h)
	self.box:set_h(h)
end

function PocoTab:children(child)
	if child then
		local children = self._children or {}
		children[#children+1] = child
		self._children = children
	end
end

function PocoTab:destroy()
	self.dead = true
	for name,child in pairs(self._children or {}) do
		child:destroy()
	end
end

local PocoTabs = class()
PocoHud3Class.PocoTabs = PocoTabs

function PocoTabs:init(ws,config) -- name,x,y,w,th,h,alt
	self._ws = ws
	config.fontSize = config.fontSize or 20
	self.config = config
	self.pTab = config.pTab
	if self.pTab then
		self.pTab:children(self)
	end
	self.alt = config.alt
	self.pnl = (self.pTab and self.pTab.pnl or ws:panel()):panel{ name = config.name , x = config.x, y = config.y, w = config.w, h = config.h, layer = self.pTab and 0 or Layers.TabHeader}
	self.items = {} -- array of PocoTab
	self._children = {} -- array of PocoTabs
	self.sPnl = self.pnl:panel{ name = config.name , x = 0, y = config.th, w = config.w, h = config.h-config.th}
	if not self.alt then
		BoxGuiObject:new(self.sPnl, {
			sides = {
				1,
				1,
				2,
				1
			}
		})
	end
end

function PocoTabs:canScroll(down,x,y)
	local cTC = self.currentTab and self.currentTab._children
	if cTC then
		for ind,tabs in pairs(cTC) do
			local cResult = {tabs:canScroll(down,x,y)}
			if cResult[1] then
				return unpack(cResult)
			end
		end
	end
	if self.currentTab then
		return self.currentTab:canScroll(down,x,y)
	end
end

function PocoTabs:insideTabHeader(x,y,noChildren)
	for ind,tab in pairs(self.items) do
		local tResult = {tab:insideTabHeader(x,y,true)}
		if tResult[1] and self.tabIndex ~= ind then
			return self, ind
		end
	end
	local cTC = self.currentTab and self.currentTab._children
	if cTC then
		for ind,tabs in pairs(cTC) do
			local cResult = {tabs:insideTabHeader(x,y)}
			if cResult[1] then
				return unpack(cResult)
			end
		end
	end

	local dY = y-self.pnl:world_y()
	if dY>0 and self.config.th >= dY then
		if self.currentTab then
			return self, 0
		end
	end
end

function PocoTabs:goTo(index)
	local cnt = #self.items
	if index < 1 or index > cnt then
		return
	end
	if index ~= self.tabIndex then
		managers.menu:post_event('slider_release' or 'Play_star_hit')
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
		if not self.alt then
			local bg = hPnl:bitmap({
				name = 'tab_top',
				texture = 'guis/textures/pd2/shared_tab_box',
				w = self.config.w, h = self.config.th + 3,
				color = cl.White:with_alpha(isSelected and 1 or 0.1)
			})
			local lbl = hPnl:text({
				x = 10, y = 0, w = 200, h = self.config.th,
				name = 'tab_name', text = itm.name,
				font = FONT,
				font_size = self.config.fontSize,
				color = isSelected and cl.Black or cl.White,
				layer = 1,
				align = 'center',
				vertical = 'center'
			})
			local xx,yy,w,h = lbl:text_rect()

			lbl:set_size(w,self.config.th)

			bg:set_w(w + 20)
			x = x + w + 22
			itm.bg = bg
		end
		itm.hPnl = hPnl
		if itm.box then
			itm.box.wrapper:set_visible(isSelected)
		end
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
local PocoMenu = class()
PocoHud3Class.PocoMenu = PocoMenu
function PocoMenu:init(ws,alternative)
	self._ws = ws
	self.alt = alternative
	if alternative then
		self.pnl = ws:panel():panel({ name = 'bg' })
		self.gui = PocoTabs:new(ws,{name = 'PocoRose',x = 0, y = -1, w = ws:width(), th = 1, h = ws:height()+1, pTab = nil, alt = true})

	else
		self.gui = PocoTabs:new(ws,{name = 'PocoMenu',x = 10, y = 10, w = 1000, th = 30, h = ws:height()-20, pTab = nil})

		self.pnl = ws:panel():panel({ name = 'bg' })
		self.pnl:rect{color = cl.Black:with_alpha(0.7),layer = Layers.Bg}
		self.pnl:bitmap({
			layer = Layers.Blur,
			texture = 'guis/textures/test_blur_df',
			w = self.pnl:w(),h = self.pnl:h(),
			render_template = 'VertexColorTexturedBlur3D'
		})
		local __, lbl = _.l({pnl = self.pnl,x = 1010, y = 20, font = FONT, font_size = 17, layer = Layers.TabHeader},
			{'Bksp or Dbl-right-click to dismiss',cl.Gray},true)
		lbl:set_right(1000)
	end

	PocoMenu.m_id = PocoMenu.m_id or managers.mouse_pointer:get_id()
	managers.mouse_pointer:use_mouse{
		id = PocoMenu.m_id,
		mouse_move = callback(self, self, 'mouse_moved',true),
		mouse_press = callback(self, self, 'mouse_pressed',true),
		mouse_release = callback(self, self, 'mouse_released',true)
	}

	self._lastMove = 0
end

function PocoMenu:_fade(pnl, out, done_cb, seconds)
	local pnl = self.pnl
	pnl:set_visible( true )
	pnl:set_alpha( out and 1 or 0 )
	local t = seconds
	if self.alt and not out then
		managers.mouse_pointer:set_mouse_world_position(pnl:w()/2, pnl:h()/2)
	end
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local r = t/seconds
		pnl:set_alpha(out and r or 1-r)
		if self._tabs then
			for i,tabs in pairs(self._tabs) do
				tabs.pnl:set_alpha(out and r or 1-r)
			end
		end
		if self.gui and self.gui.pnl then
			self.gui.pnl:set_alpha(out and r or 1-r)
		end
	end
	if done_cb then
		done_cb()
	end
end


function PocoMenu:fadeIn()
	self.pnl:stop()
	self.pnl:animate( callback( self, self, '_fade' ), false, nil, self.alt and 0.1 or 0.25 )
end
function PocoMenu:fadeOut(cbk)
	self.pnl:stop()
	self.pnl:animate( callback( self, self, '_fade' ), true, cbk, self.alt and 0.1 or 0.25 )
end



function PocoMenu:add(...)
	self._tabs = self._tabs or {}
	local newTabs = self.gui:add(...)
	table.insert(self._tabs,newTabs)
	return newTabs
end

function PocoMenu:update(...)
end

function PocoMenu:destroy()
	if self.dead then return end
	self.dead = true
	if PocoMenu.m_id then
		managers.mouse_pointer:remove_mouse(PocoMenu.m_id)
	end

	if self.gui then
		self.gui:destroy()
	end
	if self.pnl then
		self._ws:panel():remove(self.pnl)
	end

end

function PocoMenu:mouse_moved(alt, panel, x, y)
	if not me or me.dead then return end
	local ret = function (a,b)
		if alt then
			managers.mouse_pointer:set_pointer_image(b)
		end
		return a, b
	end
	if self.dead then return end
	--if not inGame and alt then return end
	local isNewPos = self._x ~= x or self._y ~= y
	if isNewPos then
		self._close = nil
	else
		return
	end
	self._x = x
	self._y = y
	local _fireMouseOut = function()
		if self.lastHot then
			self.lastHot:fire(PocoEvent.Out,x,y)
			self.lastHot = nil
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
		return ret(true, hotElem.cursor or 'link')
	end
	if self.gui then
		local tabHdr = {self.gui:insideTabHeader(x,y)}
		if isNewPos and tabHdr[1] then
			return ret(true, tabHdr[2]~=0 and 'link' or 'arrow')
		end
	end
	return ret( true, 'arrow' )
end

function PocoMenu:mouse_pressed(alt, panel, button, x, y)
	if not me or me.dead then return end
	if self.dead then return end
	if self.alt then return end
	local tabT = 0.02
	pcall(function()
		local currentTab = self.gui and self.gui.currentTab
		if button == Idstring('mouse wheel down') then
			if currentTab:isHot(PocoEvent.WheelDown, x,y, true) then
				return true
			end
			local tabHdr = {self.gui:insideTabHeader(x,y)}
			if tabHdr[1] and now() - self._lastMove > tabT then
				self._lastMove = now()
				tabHdr[1]:move(1)
			end
		elseif button == Idstring('mouse wheel up') then
			if currentTab:isHot(PocoEvent.WheelUp, x,y, true) then
				return true
			end
			local tabHdr = {self.gui:insideTabHeader(x,y)}
			if tabHdr[1] and now() - self._lastMove > tabT then
				self._lastMove = now()
				tabHdr[1]:move(-1)
			end
		end

		if button == Idstring('0') then
			local focused = me._focused
			if focused and not focused:inside(x,y) then
				focused:fire(PocoEvent.Click,x,y)
				me._focused = nil
			end
			local tabs, tabInd = self.gui:insideTabHeader(x,y)
			if tabs and self.tabIndex ~= tabInd then
				if tabInd == 0 then
					tabs.currentTab:scroll(0,true)
				else
					tabs:goTo(tabInd)
				end
				return true
			end
			return currentTab and currentTab:isHot(PocoEvent.Pressed, x,y, true)
		end
		if button == Idstring('1') then
			return currentTab and currentTab:isHot(PocoEvent.PressedAlt, x,y, true)
		end
	end)
end

function PocoMenu:mouse_released(alt, panel, button, x, y)
	if not me or me.dead then return end
	if self.dead then return end
	if self.alt then return end
	local currentTab = self.gui and self.gui.currentTab
	if button == Idstring('0') then
		return currentTab and currentTab:isHot(PocoEvent.Released, x,y, true)
	end
	if button == Idstring('1') then
		local hot = currentTab and currentTab:isHot(PocoEvent.ReleasedAlt, x,y, true)
		if not hot then
			if self._close then
				me:Menu(true)
			else
				self._close = true
			end
		end
		return hot
	end
end

------------------------------
--- PocoHud3:Menu functions
------------------------------
local titlecase = function (str)
		local buf = {}
		for word in string.gfind(str, '%S+') do
				local first, rest = string.sub(word, 1, 1), string.sub(word, 2)
				table.insert(buf, string.upper(first) .. string.lower(rest))
		end
		return table.concat(buf, ' ')
end

function PocoHud3Class._open (url)
	if shift() then
		os.execute('start '..url)
	else
		Steam:overlay_activate('url', url)
	end
	managers.menu:post_event(not shift() and 'camera_monitor_engage' or 'trip_mine_sensor_alarm')
end

function PocoHud3Class._get (obj,url, cbk)
	if me._busy then
		if obj then
			obj:sound('menu_error')
		end
		return false
	else
		me._busy = true
		local _cbk = function(success,body)
			if obj then
				obj:sound(success and 'turret_alert' or 'trip_mine_sensor_alarm')
			end
			if success then
				Poco._getCache[url] = body
			end
			me._busy = false
			cbk(success,body)
		end

		if obj then
			obj:setLabel('Loading...')
			obj:sound('camera_monitor_engage')
		end
		Poco._getCache = Poco._getCache or {}
		if Poco._getCache[url] and not shift() then
			_cbk(true,Poco._getCache[url])
		else
			Steam:http_request(url, _cbk)
		end
		return true
	end
end

function PocoHud3Class._drawHeistStats (tab)
	local oTabs = PocoTabs:new(me._ws,{name = 'Options',x = 10, y = 10, w = 950, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})
	local host_list, level_list, job_list, mask_list, weapon_list = tweak_data.achievement.job_list, managers.statistics:_get_stat_tables()
	local risks = { 'risk_pd', 'risk_swat', 'risk_fbi', 'risk_death_squad', 'risk_murder_squad'}
	local x, y, tbl = 10, 10, {}

	-- [1] Per Heist
	local oTab = oTabs:add(L('_tab_stat_perheist'))
	local pnl = oTab.pnl
	local w, h, ww, hh = 0,0, pnl:size()
	local font,fontSize = tweak_data.menu.pd2_small_font, tweak_data.menu.pd2_small_font_size*0.98
	local _rowCnt = 0
	tbl[#tbl+1] = {{L('_word_broker'),cl.BlanchedAlmond},L('_word_job'),{Icon.Skull,cl.PaleGreen:with_alpha(0.3)},{Icon.Skull,cl.PaleGoldenrod},{Icon.Skull..Icon.Skull,cl.LavenderBlush},{string.rep(Icon.Skull,3),cl.Wheat},{string.rep(Icon.Skull,4),cl.Tomato},L('_word_heat')}
	local addJob = function(host,heist)
		local jobData = tweak_data.narrative.jobs[heist]
		if jobData.wrapped_to_job then
			jobData = tweak_data.narrative.jobs[jobData.wrapped_to_job]
		end
		local job_string =managers.localization:to_upper_text(jobData.name_id or heist) or heist
		local pro = jobData.professional
		if pro then
			job_string = {job_string, cl.Red}
		end
		local rowObj = {host:upper(),job_string}
		for i, name in ipairs( risks ) do
			local c = managers.statistics:completed_job( heist, tweak_data:index_to_difficulty( i + 1 ) )
			local f = managers.statistics._global.sessions.jobs[(heist .. '_' .. tweak_data:index_to_difficulty( i + 1 ) .. '_started'):gsub('_wrapper','')] or 0
			if i > 1 or not pro then
				table.insert(rowObj, {{c, c<1 and cl.Salmon or cl.White:with_alpha(0.8)},{' / '..f,cl.White:with_alpha(0.4)}})
			else
				table.insert(rowObj, {c > 0 and c or L('_word_na'), cl.Tan:with_alpha(0.4)})
			end
		end
		local multi = managers.job:get_job_heat_multipliers(heist)
		local color = multi >= 1 and math.lerp( cl.Khaki, cl.Chartreuse, 6*(multi - 1) ) or math.lerp( cl.Crimson, cl.OrangeRed, 3*(multi - 0.7) )
		table.insert(rowObj,{{_.f(multi*100,5)..'%',color},{' ('..(managers.job:get_job_heat(heist) or '?')..')',color:with_alpha(0.3)}})
		tbl[#tbl+1] = rowObj
	end
	for host,jobs in _.p(host_list) do
		for no,heist in _.p(jobs) do
			if table.get_key(job_list,heist) then
				job_list[table.get_key(job_list,heist)] = nil
			end
			addJob(host,heist)
		end
	end
	for no,heist in pairs(job_list) do
		addJob(L('_word_na'),heist) -- Just in case
	end
	local _lastHost = ''
	for row, _tbl in pairs(tbl) do
		if _lastHost == _tbl[1] then
			_tbl[1] = ''
		else
			_lastHost = _tbl[1]
		end
		_rowCnt = _rowCnt + 1
		y = me:_drawRow(pnl,fontSize,_tbl,x,y,ww-20, _rowCnt % 2 == 0,{1,_rowCnt == 1 and 1 or 0})
	end
	oTab:set_h(y)

	-- [2] Per day
	oTab = oTabs:add(L('_tab_stat_perday'))
	pnl = oTab.pnl
	y = 10
	local descs = {}
	tbl = {}
	tbl[#tbl+1] = {{L('_word_heist'),cl.BlanchedAlmond},{L('_word_day'),cl.Honeydew},{L('_word_started'),cl.LavenderBlush},{L('_word_completed'),cl.Wheat},L('_word_time')}
	local levels = _.g('managers.statistics._global.sessions.levels') or {}
	-- search JobsChain
	local addDay = function(val,prefix,suffix)
		if not level_list[table.get_key(level_list,val)] then return end
		if table.get_key(level_list,val) then
			level_list[table.get_key(level_list,val)] = nil
		end
		local level = levels[val]
		if not level then return end
		local isAlt = val:match('_night$') or val:match('_day$')
		local name = managers.localization:to_upper_text(tweak_data.levels[val].name_id)
		if name == prefix then
			prefix = {Icon.Ghost,cl.Gray}
		end
		name = name .. (isAlt and ' '..L('_tab_stat'..isAlt) or '')
		local _c = function(n,color)
			return {n,n and n>0 and (color or cl.Lime) or cl.Gray }
		end
		local _s = function(...)
			local t = {}
			for i,v in pairs{...} do
				t[i] = _.s(v)
			end
			return table.concat(t)
		end
		local t = level.time / 60
		local avg = t / math.max(1,level.completed)
		tbl[#tbl+1] = {
			prefix,
			PocoUIHintLabel:new(oTab,{x=0,y=0,w=200,h=fontSize,align='left',text=name,hintText=suffix}),
			PocoUIHintLabel:new(oTab,{x=0,y=0,w=200,h=fontSize,text=level.started,hintText={
				L('_desc_heist_count_started_1'),
				_c(level.from_beginning),
				L('_desc_heist_count_started_2'),
				_c(level.drop_in)
			}}),
			PocoUIHintLabel:new(oTab,{x=0,y=0,w=200,h=fontSize,text=level.completed,hintText={L('_desc_heist_count_completed'), _c(level.quited,cl.Red)}}),
			PocoUIHintLabel:new(oTab,{x=0,y=0,w=200,h=fontSize,text={
				t>0 and (
					t > 60 and L('_desc_heist_time_hm',{math.floor(t/60),math.floor(t%60)}) or L('_desc_heist_time_m',{_.f(t)} )
				) or {L('_word_na'),cl.Gray}
			},hintText={
				L('_desc_heist_time_average'),L('_desc_heist_time_ms',{math.floor(avg),math.floor(avg*60%60)})
			},avg>0 and cl.Lime or cl.Gray})
		}
	end
	for host,_jobs in _.p(host_list) do
		local jobs = table.deepcopy(_jobs)

		while table.size(jobs) > 0 do
			local heist = table.remove(jobs,1)
			local jobData = tweak_data.narrative.jobs[heist]
			local jobName
			if jobData.wrapped_to_job then
				jobName = tweak_data.narrative.jobs[jobData.wrapped_to_job].name_id
			else
				jobName = jobData.name_id
			end
			if jobData and jobData.job_wrapper then
				for k,realJobs in pairs(jobData.job_wrapper) do
					table.insert(jobs,realJobs)
				end
			end
			if jobData.chain then
				for day,level in pairs(jobData.chain) do
					local lID = level.level_id
					if lID then
						addDay(lID,managers.localization:to_upper_text(jobName),L('_desc_heist_day',{day}))
					else -- alt Days
						for alt,_level in pairs(level) do
							addDay(_level.level_id,managers.localization:to_upper_text(jobName),L('_desc_heist_dayalt',{day,alt}))
						end
					end
				end
			else
				_('no chain?',jobData.name_id)
			end
		end
	end
	-- the rest
	tbl[#tbl+1] = {{L('_desc_heist_unlisted'),cl.DodgerBlue}}
	for key,val in _.p(level_list) do
		addDay(val,{Icon.Ghost,cl.DodgerBlue})
	end

	-- draw
	_rowCnt = 0
	for row, _tbl in pairs(tbl) do
		if _lastHost == _tbl[1] then
			_tbl[1] = ''
		else
			_lastHost = _tbl[1]
			_tbl[1] = type(_tbl[1]) == 'string' and {_tbl[1],cl.BlanchedAlmond} or _tbl[1]
		end
		_rowCnt = _rowCnt + 1
		y = me:_drawRow(pnl,fontSize,_tbl,x,y,ww-20, _rowCnt % 2 == 0,{1,_rowCnt == 1 and 1 or 0})
	end
	local __, lbl = _.l({font=FONT, color=cl.LightSteelBlue, alpha=0.9, font_size=fontSize, pnl = pnl, x = 10, y = y+10},L('_desc_heist_may_not_match'),true)

	oTab:set_h(lbl:bottom())
end

function PocoHud3Class._drawUpgrades (tab, data, isTeam, desc, offsetY)
	local _ignore = {}
	local pnl = tab.pnl
	offsetY = offsetY or 0
	pnl:text{
		x = 10, y = offsetY+10, w = 600, h = 30,
		name = 'tab_desc', text = Icon.Chapter..' '..desc,
		font = FONTLARGE, font_size = 25, color = cl.CornFlowerBlue,
	}
	local large = 5
	local y,fontSize,w = offsetY+35, 19, pnl:w()
	if data then
		local merged = table.deepcopy(data)
		for category, upgrades in _.p(merged) do
			local row,cnt = {},0
			y = me:_drawRow(pnl,fontSize*1.1,{{titlecase(category:gsub('_',' ')),cl.Peru},''},5,y,w)
			for name,value in _.p(upgrades) do
				local isMulti = name:find('multiplier') or name:find('_chance') or name:find('_mul')
				local val = isTeam and managers.player:team_upgrade_value(category, name, 1) or managers.player:upgrade_value(category, name, 1)
				if not (isMulti and val == 1) then
					cnt = cnt + 1
					if isMulti and type(val) == 'number' then
						val = _.s(val*100) .. '%'
					elseif type(val) == 'table' then
						val = _.s( type(val[1]) == 'number' and _.s(val[1]*100) .. '%' or _.s(val[1]==true and 'Yes' or val[1]), _.s(val[2],'sec') )
					elseif val == true then
						val = L('_word_yes')
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
						y = me:_drawRow(pnl,fontSize,row,15,y,w,true,{0,1,0,1,0,1})
						row = {}
					end
				end
			end
			if cnt == 0 then
				row[#row+1] =  {L('_desc_not_in_effect'),cl.LightSteelBlue}
			end
			if #row > 0 then
				while (#row <= large) do
					table.insert(row,'')
				end
				y = me:_drawRow(pnl,fontSize,row,15,y,w,true,{0,1,0,1,0,1})
				row = {}
			end
		end
		tab:set_h(y)
	else
		y = me:_drawRow(pnl,fontSize,{{L('_desc_no_upgrades_acquired'),cl.White:with_alpha(0.5)}},0,y,w)
	end
	return y
end

function PocoHud3Class._drawPlayer(tab)
	local y
	local oTabs = PocoTabs:new(me._ws,{name = 'Players',x = 10, y = 10, w = tab.pnl:width()-20, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})

	for i = 1,4 do
		local member = me:_member(i)
		local peer = member and member:peer()
		if peer then
			local uid, __ = peer._user_id
			local oTab = oTabs:add(_.s('Player',i,':',peer._name))
			local isMe = i==me.pid

			local objs = {} -- stores UIelems & cbks

			local ooTabs = PocoTabs:new(me._ws,{name = 'Player'..i,x = 10, y = 10, w = oTab.pnl:width()-20, th = 30, fontSize = 18, h = oTab.pnl:height()-20, pTab = oTab})

			-- Inner - Basic
			local ooTab = ooTabs:add('Basic')
			local tbl = {{'Key','Value'}}
			y = 10
			objs.btnProfile = PocoUIButton:new(ooTab,{
				onClick = function()
					PocoHud3Class._open('http://steamcommunity.com/profiles/'..uid)
				end,
				x = 10, y = 10, w = 200,h=26, text=_.s(uid), hintText='Hold Shift to open in out-game browser.'
			})

			objs.btnSteam = PocoUIButton:new(ooTab,{
				onClick = function(self)
					PocoHud3Class._get(self,'http://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v0001/?key=BE48819D3E15C1FC4E5FDCD5AC1360BA&steamid='..uid, function(success, body)
						if success then
							local r, result = pcall(JSON.decode,JSON,body)
							if r then
								result = result.response
								if result and result.games then
									for i,obj in pairs(result.games or {}) do
										local lbl = objs['lblGame'..i]
										local lbl2 = objs['lblGameTime'..i]
										if lbl and alive(lbl) then
											lbl:set_text(_.s(obj.name))
											lbl2:set_text(_.s('Total',obj.playtime_forever/60,'h,',obj.playtime_2weeks/60,'h lately'))
										end
									end
									self:setLabel(_.s('Successfully received',#result.games,'games from Steam profile.'))
								else
									self:setLabel('Denied: Private/Member-only profile?')
								end
								self:disable()
							else
								me:err(result)
							end
						end
					end)
				end,
				x = 10, y = 10, w = 370,h=26,
				text='Fetch Recent Games'
			})
			__, objs.lblGame1 = _.l({pnl = ooTab.pnl, x=0,y=0,w=200, h=26,align='center',vertical='center',font = FONT, font_size = 20},'Game1')
			__, objs.lblGame2 = _.l({pnl = ooTab.pnl, x=0,y=0,w=200, h=26,align='center',vertical='center',font = FONT, font_size = 20},'Game2')
			__, objs.lblGame3 = _.l({pnl = ooTab.pnl, x=0,y=0,w=200, h=26,align='center',vertical='center',font = FONT, font_size = 20},'Game3')
			__, objs.lblGameTime1 = _.l({pnl = ooTab.pnl, x=0,y=0,w=200, h=26,align='center',vertical='center',font = FONT, font_size = 20},'-')
			__, objs.lblGameTime2 = _.l({pnl = ooTab.pnl, x=0,y=0,w=200, h=26,align='center',vertical='center',font = FONT, font_size = 20},'-')
			__, objs.lblGameTime3 = _.l({pnl = ooTab.pnl, x=0,y=0,w=200, h=26,align='center',vertical='center',font = FONT, font_size = 20},'-')

			objs.btnPD2Stats = PocoUIButton:new(ooTab,{
				onClick = function(self)
					PocoHud3Class._get(self,'http://api.pd2stats.com/cheater/v1/?id='..uid, function(success, body)
						if success then
							body = body:gsub('\t([%w_]-):','\t"%1":')
							local r, result = pcall(JSON.decode,JSON,body)
							if r then
								if result.error_code == 0 then
									self:disable()
									self:setLabel('Successfully received from PD2Stats.com')
									objs.btnPD2Cheater:setLabel(result.cheater and 'Suspicious.' or 'Seems legit.')
								else
									self:setLabel(result.error_string or 'Failed.')
								end
							else
								me:err(result)
							end
						end
					end)
				end,
				x = 10, y = 10, w = 370,h=26,
				text='Fetch PD2Stats.com data'
			})
			objs.btnPD2Cheater = PocoUIButton:new(ooTab,{
				onClick = function()
					PocoHud3Class._open('http://pd2stats.com/profiles/'..uid)
				end,
				x = 10, y = 10, w = 200,h=26, text='Unknown', hintText='Hold Shift to open in out-game browser.'
			})

--[[ Check Skills

			local upg = _.g('Global.player_manager.synced_team_upgrades')
			upg = upg and
--]]
			tbl[#tbl+1] = {{'Level',cl.Tan},_.s(isMe and managers.experience:current_rank() or peer:rank() or 0,Icon.Dot,isMe and managers.experience:current_level() or peer:level())}
			tbl[#tbl+1] = {{'Sync',cl.Tan},peer._synced and 'Completed' or 'Not completed'}
			tbl[#tbl+1] = {{'UID',cl.Tan},objs.btnProfile}
			tbl[#tbl+1] = {objs.btnSteam}
			tbl[#tbl+1] = {objs.lblGame1,objs.lblGameTime1}
			tbl[#tbl+1] = {objs.lblGame2,objs.lblGameTime2}
			tbl[#tbl+1] = {objs.lblGame3,objs.lblGameTime3}
			tbl[#tbl+1] = {objs.btnAchievement}
			tbl[#tbl+1] = {objs.btnPD2Stats}
			tbl[#tbl+1] = {{'PD2Stats Verdict',cl.Tan},objs.btnPD2Cheater}
			for k,row in pairs(tbl) do
				y = me:_drawRow(ooTab.pnl,20,row,10,y,600,k % 2 ~= 0,true,1.3)
			end

			ooTab:set_h(y)
			----

			-- CheckAchievement
			local ooTab = ooTabs:add('Achievements')
			PocoUIButton:new(ooTab,{
				onClick = function(self)
					PocoHud3Class._get(self,'http://steamcommunity.com/profiles/'..uid..'/stats/PAYDAY2', function(success, body)
						if success then
							me._busy = false
							self:hide()
							tbl = {{
								PocoUIButton:new(ooTab,{
									onClick=function() PocoHud3Class._open('http://steamcommunity.com/profiles/'..uid..'/stats/PAYDAY2') end,
									x=0,y=0,w=450,h=26,font_size=20,align='center',text={'Achievements',cl.Moccasin},hintText='Hold SHIFT to open in out-game browser'}),
								{'Date',cl.Moccasin}
							}}
							y = 10
							local _aids = '6cbdd,d20fb,deb36,ec3d5,33e42,83299,fa65a,f8702,c0613,1027c,44a32,db879,04a22,95eaf,82152,2a3af,e4c2d,4d059,e0d94,3bc9b,de5e1'
							_aids = _aids:split(',')
							local cnt = 0
							for aid,datetime,title,desc in body:gmatch('218620/(.-)%..-class="achieveUnlockTime".-Unlocked: (.-)%s*<.-<h3>(.-)</h3>.-<h5>(.-)</h5>') do
								if table.index_of(_aids,aid:sub(1,5)) > 0 then
									tbl[#tbl+1] = {
										PocoUIHintLabel:new(ooTab,{x=0,y=0,w=500,h=26,font_size=20,align='center',text=desc,hintText=title}),
										datetime
									}
								end
								cnt = cnt + 1
								if cnt > 500 then
									-- something is wrong I guess??
									break
								end
							end
							if cnt == 0 then
									tbl[#tbl+1] = {'Not found.'}
							end
							for k,row in pairs(tbl) do
								y = me:_drawRow(ooTab.pnl,20,row,10,y,ooTab.pnl:width()-20,k % 2 ~= 0,true,1.3)
							end

							ooTab:set_h(y)
							--_.o(body)
						end
					end)
				end,
				x = 10, y = 10, w = 400,h=50,
				text='Fetch Achievements data'
			})

--
			-- Inner - Raw (for DBG)
			if peer._synced and false then
				local ooTab = ooTabs:add('Raw')
				local __,lbl = _.l({pnl=ooTab.pnl,
					x = 10, y = 10, w = 800, h = 30,
					name = 'tab_desc', font = FONTLARGE, font_size = 20, color = cl.White
				},_.s(_.i(peer,{depth=5})),true)
				ooTab:set_h(lbl:bottom())
			end
			----
		end
	end
	if not y then
		oTabs:add('N/A')
		y = 0
	end
	return y
end

function PocoHud3Class._drawAbout(tab,REV,TAG)
	PocoUIButton:new(tab,{
		onClick = function(self)
			PocoHud3Class._open('http://steamcommunity.com/groups/pocomods')
		end,
		x = 10, y = 10, w = 200,h=100,
		text={{'PocoHud3 r'},{REV,cl.Gray},{' by ',cl.White},{'Zenyr',cl.MediumTurquoise},{'\n'..TAG,cl.Silver}},
		hintText = {{'Discuss/suggest at PocoMods steam group!',cl.LightSkyBlue},'\nHold ',{'SHIFT',cl.Tan},' key to open in out-game browser.'}
	})

	local __, lbl = _.l({font=FONT, color=cl.LightSteelBlue, alpha=0.9, font_size=25, pnl = tab.pnl, x = 220, y = 10},'Loading RSS...',true)
	local _strip = function(s)
		return s:gsub('&lt;','<'):gsub('&gt;','>'):gsub('<br>','\n'):gsub(string.char(13),''):gsub('<.->',''):gsub('&amp;','&'):gsub('&amp;','&')
	end
	local _onRSS = function (success, body, _rss)
		if not Poco then return end
		if success then
			local rss = _rss or {}
			if body then
				for title,desc,date,link in body:gmatch('<item>.-<title>(.-)</title>.-<description>(.-)</description>.-<pubDate>(.-)</pubDate>.-<guid.->(.-)</guid>') do
					local diffH = math.round((_.t()-_.t(1)) / 360)/10
					-- Based on http://stackoverflow.com/a/4600967
					local days,day,month,year,hour,min,sec=date:match('(.-), (.-) (.-) (.-) (.-):(.-):(.-) ')
					local MON={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}
					month=MON[month]
					local d = os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})+diffH*3600
					local diffS = - _.t(false,d)
					if diffS < 3600*24 then
						local h = math.max(0,math.floor(diffS/3600))
						date = _.s( h==1 and 'an' or h,h>1 and 'hrs' or 'hr','ago')
					else
						local d = math.floor(diffS/3600/24)
						date = _.s( d==1 and 'a' or d,d>1 and 'days' or 'day','ago')
					end
					rss[#rss+1] = {_strip(title),_strip(desc),date,link}

				end
			end
			Poco._rss = rss
			if not alive(lbl) then return end
			_.l(lbl,'Recent PocoMod Updates',true)
			local y = 35
			for ind,obj in pairs(rss) do
				local title = '   '..obj[1]
				local bef,name,rev,rest=title:match('^(.-)(PocoHud3 r)(%d-)( .-)$')
				if rev then
					title = {{bef,cl.CornFlowerBlue},{name..rev,tonumber(rev) > REV and cl.PapayaWhip or cl.DodgerBlue},{rest,cl.CornFlowerBlue}}
				else
					title = {title,cl.DeepSkyBlue}
				end
				PocoUIButton:new(tab,{
					onClick = function(self)
						PocoHud3Class._open(obj[4])
					end,
					x = 220, y = y, w = 500, h=50,
					fontSize = 22,align = 'left',
					text=title,
					hintText = {{obj[2]:sub(1,200)..'...'},'\nHold ',{'SHIFT',cl.Tan},' key to open in out-game browser.'}
				})
				local __, lbl = _.l({font=FONT, color=cl.Tan, alpha=0.9, font_size=18, pnl = tab.pnl, x = 340, y = y+25, w = 350, h=20, vertical = 'center',align='right'},obj[3])

				y = y + 60
				tab:set_h(y)
				--_.l(lbl,obj[1]..'\n'..obj[2],true)
			end
		end
	end
	if Poco._rss then
		_onRSS(true,nil,Poco._rss)
	else
		PocoHud3Class._get(nil,'http://steamcommunity.com/groups/pocomods/rss', _onRSS)
	end

	PocoUIButton:new(tab,{
		onClick = function(self)
			PocoHud3Class._open('https://twitter.com/zenyr')
		end,
		x = 10, y = 120, w = 200,h=40,
		text={'@zenyr',cl.OrangeRed},
		hintText = {'Not in English but feel free to ask in English\nas long as it is not a technical problem!',{' :)',cl.DarkKhaki},'\nHold ',{'SHIFT',cl.Tan},' key to open in out-game browser.'}
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			PocoHud3Class._open('http://msdn.microsoft.com/en-us/library/ie/aa358803(v=vs.85).aspx')
		end,
		x = 10, y = 170, w = 200,h=40,
		text={'Color codes reference page', cl.Silver},-- no moar fun tho
		hintText = {'Shows MSDN reference page that shows every possible color codes in PocoHud3 preset\nHold ',{'SHIFT',cl.Tan},' key to open in out-game browser.'}
	})

end

function PocoHud3Class._drawOptions(tab)
	local self = me
	local objs = {}
	self.onMenuDismiss = function()
		O:default()
		for __,obj in pairs(objs) do
			if not obj[1]:isDefault() then
				O:set(obj[2],obj[3],obj[1]:val())
			end
		end
		O:save()
		me:Menu(true)
	end
	PocoUIButton:new(tab,{
		onClick = function()
			me:Menu(true,true)
			PocoHud3Class.TPocoHud3.Toggle()
			PocoHud3 = nil -- will reload on its own
		end,
		x = 20, y = 10, w = 400, h=50,
		fontSize = 30,font = FONTLARGE,
		text={L('_btn_apply_and_reload'),cl.SteelBlue},
		hintText = L('_desc_apply_and_reload')
	})

	PocoUIButton:new(tab,{
		onClick = function()
			for __,obj in pairs(objs) do
				obj[1]:val(O:get(obj[2],obj[3],true))
			end
		end,
		x = 500, y = 10, w = 200, h=50,
		fontSize = 25,font = FONTLARGE,
		text={L('_btn_discard'),cl.Gray},
		hintText = L('_desc_discard')
	})
	PocoUIButton:new(tab,{
		onClick = function()
			managers.menu:show_default_option_dialog({
				text =  L('_desc_reset')..L('_desc_reset_ask'),
				callback = function()
					for __,obj in pairs(objs) do
						obj[1]:val(O:_default(obj[2],obj[3]))
					end
				end
			})
		end,
		x = 710, y = 10, w = 200, h=50,
		fontSize = 25,font = FONTLARGE,
		text={L('_btn_reset'),cl.Gray},
		hintText = L('_desc_reset')
	})

	local oTabs = PocoTabs:new(self._ws,{name = 'Options',x = 10, y = 70, w = tab.pnl:width()-20, th = 30, fontSize = 18, h = tab.pnl:height()-80, pTab = tab})
	for category, objects in _.p(O.scheme) do
		local _y, m, half = 10, 5
		local x,y = function()
			return half and 440 or 10
		end, function(h)
			_y = _y + h + m
			return _y - h - m
		end

		local oTab = oTabs:add(L('_tab_'..category))
		if objects[1] then
			local txts = L:parse(objects[1])
			local __, lbl = _.l({font=FONT, color=cl.LightSteelBlue, alpha=0.9, font_size=20, pnl = oTab.pnl, x = x(), y = y(0)},txts,true)
			y(lbl:h())
			--[[oTab.pnl:bitmap({
				texture = 'guis/textures/pd2/shared_lines',	wrap_mode = 'wrap',
				color = cl.White, x = 5, y = y(3), w = oTab.pnl:w()-10, h = 3, alpha = 0.3 })]]
		end

		local c = 0
		local _sy,_ty = _y
		for name,values in _.p(objects,function(a,b)
			local t1, t2 = O:_type(category,a),O:_type(category,b)
			local s1, s2 = O:_sort(category,a) or 99,O:_sort(category,b) or 99
			if a == 'enable' then
				return true
			elseif b == 'enable' then
				return  false
			elseif s1 ~= s2 and type(s1) == type(s2) then
				return s1 < s2
			elseif t1 == 'bool' and t2 ~= 'bool' then
				return true
			elseif t1 ~= 'bool' and t2 == 'bool' then
				return false
			end
			return tostring(a) < tostring(b)
		end) do
			if type(name) ~= 'number' then
				c = c + 1
				if not half and c > table.size(objects) / 2 then
					half = true
					_ty = _y
					_y = _sy
				end
				local type = O:_type(category,name)
				local value = O:get(category,name,true)
				local hint = O:_hint(category,name)
				hint = hint and L:parse(hint)
				local tName = name:gsub('(%U)(%u)','%1 %2'):upper()
				if type == 'bool' then
					objs[#objs+1] = {PocoUIBoolean:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName , value = value ,
						hintText = hint
					}),category,name}
				elseif type == 'color' then
					objs[#objs+1] = {PocoUIColorValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName, value = value,
						hintText = hint
					}),category,name}
				elseif type == 'key' then
					objs[#objs+1] = {PocoUIKeyValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName, value = value,
						hintText = hint
					}),category,name}
				elseif type == 'num' then
					local range = O:_range(category,name) or {}
					local vanity = O:_vanity(category,name)
					if vanity then
						vanity = PocoHud3Class.L(vanity):split(',')
					end
					local step = O:_step(category,name)

					objs[#objs+1] = {PocoUINumValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name, step = step,
						fontSize = 20, text=tName, value = value, min = range[1], max = range[2], vanity = vanity,
						hintText = hint
					}),category,name}
				elseif type == 'string' then
					objs[#objs+1] = {PocoUIStringValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName, value = value,
						hintText = hint
					}),category,name}
				else
					PocoUIButton:new(oTab,{
						hintText = L('_msg_not_implemented'),
						x = x()+10, y = y(30), w=390, h=30,
						text=_.s(name,type,value)
					})
				end
			end
		end
		oTab:set_h(math.max(_y,_ty)+40)
	end
end

function PocoHud3Class._drawRose(tab)
	local pnl = tab.pnl
	local layout = {
		{	{'_rose_whistle','whistling_attention'},	{'_rose_cable','g26'},	{'_rose_medbag','g80x_plu'},	{'_rose_shoot','g23'},	{'_rose_drill','g61'},	},
		{	{'_rose_overrun','g68'},	{'_rose_timetogo','g17'},	{'_rose_thisway','g12'},	{'_rose_straight','g19'},	{'_rose_cantstay','g69'},	},
		{	{'_rose_almost','g28'},	{'_rose_getout','g07'},	{'_rose_upstairs','g02'},	{'_rose_hurry','g09'},	{'alright','g92'},	},
		{	{'_rose_letsgo','g13'},	{'_rose_left','g03'},	false,	{'_rose_right','g04'},	{'_rose_thanks','s05x_sin'},	},
		{	{'_rose_halfway','t02x_sin'},	{'_rose_careful','g10'},	{'_rose_downstairs','g01'},	{'_rose_inside','g08'},	{'_rose_anysecond','t03x_sin'},	},
		{	{'_rose_fewminutes','t01x_sin'},	{'_rose_down','g20'},	{'_rose_wrong','g11'},	{'_rose_defended','g16'},	{'_rose_cams','g25'},	},
		{	false,	{'_rose_shit','g60'},	{'_rose_ammo','g81x_plu'},	{'_rose_fuck','g29'},	false,	},
	}
	layout = L:parse(layout)
	local w,h = 200,70
	local ox,oy = pnl:w()/2 - 2*w,pnl:h()/2 - 3*h
	for y,row in pairs(layout) do
		for x, obj in pairs(row) do
			if obj then
				local xx = ox + (x-1)*w
				local yy = oy + (y-1)*h
				if x == 3 then
					yy = yy + h*0.5*(y > 4 and 1 or -1)
				end
				if y == 4 then
					xx = xx + w*0.3*(x > 3 and 1 or -1)
				end
				PocoRoseButton:new(tab,{
					x = xx, y = yy, w=w, h=h,
					fontSize = 20, text=obj[1]:upper(), value=obj[2]
				})
			end
		end
	end
	local sPnl = pnl:panel{alpha = 0.4}
	sPnl:gradient{
		layer = -1,
		gradient_points = {
			0,
			cl.Black,
			1,
			cl.Black:with_alpha(0)
		},
		orientation = "vertical",
		h = pnl:h() / 3
	}
	sPnl:gradient{
		layer = -1,
		gradient_points = {
			0,
			cl.Black:with_alpha(0),
			1,
			cl.Black:with_alpha(1)
		},
		orientation = "vertical",
		y = pnl:h() / 3 * 2,
		h = pnl:h() / 3
	}
	sPnl:gradient{
		layer = -1,
		gradient_points = {
			0,
			cl.Black:with_alpha(1),
			1,
			cl.Black:with_alpha(0)
		},
		orientation = 'horizontal',
		w = pnl:w() / 3
	}
	sPnl:gradient{
		layer = -1,
		gradient_points = {
			0,
			cl.Black:with_alpha(0),
			1,
			cl.Black:with_alpha(1)
		},
		orientation = 'horizontal',
		x = pnl:w() / 3 * 2,
		w = pnl:w() / 3
	}
	--pnl:bitmap{ texture='guis/textures/test_blur_df', render_template='VertexColorTexturedBlur3D', layer=-1, w = pnl:w(), h = pnl:h()}
end

local _kitPnl,_kitPnlBtn
function PocoHud3Class._drawKit(tab)
	if not K then
		K = PocoHud3Class.K
	end
	local inGameDeep = me.inGameDeep
	local C,_y,m = PocoHud3Class,10,5
	local y = function(h,set)
		h = h and h+m or 0
		local __y = _y
		_y = set and h or _y + h
		return __y
	end
	local categories_vanity = L('_kit_categories'):split(',')
	local categories = ('name,primaries,secondaries,armor,gadget,melee'):split(',')
	local __, lbl = _.l({font=FONT, color=cl.Gray, font_size=20, pnl = tab.pnl, x = 10, y = 10},
		'* Kit profiler is dependant on your inventory setup. Any changes in your inventory(mods, sell) will be applied to the result.',true)

	local draw, _Current
	local oTabs = PocoTabs:new(me._ws,{name = 'kits',x = 10, y = 40, w = 950, th = 30, fontSize = 18, h = tab.pnl:height()-60, pTab = tab})

	local tabBtn = oTabs:add('USE KIT')
	local tabEdt =oTabs:add('EDIT')
	draw = function()
		y(10,true)
		if _kitPnl and alive(_kitPnl) then
			_kitPnl:parent():remove(_kitPnl)
		end
		local pnl = tabEdt.pnl:panel{}
		_kitPnl = pnl
		local cnt,row = 0
		local __, lbl = _.l({font=FONT, color=cl.LightSteelBlue, font_size=20, pnl = pnl, x = 20, y = y(0)},
			{PocoHud3Class.Icon.Chapter ..' Current Kit',{' '..PocoHud3Class.Icon.RC..' Save to the profiler. Unchecked items will be removed.',cl.White}},true)
		y(lbl:h())
		-- New Header with OpenIcon
		local mcm = _.g('managers.menu_component._mission_briefing_gui')
		local openInventory = function(num)
			num = num - 1
			if num == 3 or num == 4 then
				num = num + 1
			elseif num == 5 then
				num = 3
			end
			local lot = mcm and mcm._new_loadout_item
			if lot then
				me:Menu(true)
				lot:open_node(num)
			end
		end
		local hElems = {}
		for ind,name in pairs(categories_vanity) do
			if mcm and ind > 1 then
				hElems[#hElems+1] = PocoUIButton:new(tabEdt,{ pnl = pnl,
					onClick = function(self)
						openInventory(ind)
					end,
					x = 0, y = 0, w=150, h=24,
					fontSize = 22, text=name
				})
			else
				hElems[#hElems+1] = name
			end
		end
		local lH = me:_drawRow(pnl,20,hElems,20,y(),pnl:w()-40,true,true,1.3)
		y(lH,true)

		--[[ OLD drawRow
		local lH = me:_drawRow(pnl,20,categories_vanity,20,y(),pnl:w()-40,true,true,1.3)
		y(lH,true)
		--]]
		-- Current
		row = {}
		_Current = {}
		for col,category in pairs(categories) do
			if col ~= 1 then
				local text = K:current(category)
				local raw = K:current(category,true)
				local elem = PocoUIBoolean:new(tabEdt,{ pnl = pnl,
					x = 0, y = 0, w=150, h=20, category = false, name = false,
					fontSize = 18, text=text , value = true ,
				})

				_Current[category] = {elem,raw}
				row[#row+1] = elem
			else
				local s,sNum = 'kit',1
				while K.items[s..sNum] do
					sNum = sNum + 1
				end
				local elem = PocoUIStringValue:new(tabEdt,{ pnl = pnl,
					x = 0, y = 0, w=150, h=20, category = false, name = false,
					fontSize = 18, text=' ' , value = s..sNum , max = 20, hintText = 'Set this kit\'s Vanity name for yourself.'
				})
				_Current[category] = {elem}
				row[#row+1] = elem
			end
		end
		local elem = PocoUIColorValue:new(tabEdt,{ pnl = pnl,
			x = 330, y = 110, w = 300, h=30, category = false, name = false,
			fontSize = 18, text=('Button Color'):upper() , value = 'White', hintText = 'Set this kit\'s Vanity color for yourself.'
		})
		_Current['color'] = {elem}

		elem = PocoUIKeyValue:new(tabEdt,{ pnl = pnl,
			x = 120, y = 110, w = 200, h=30, category = false, name = false,
			fontSize = 18, text=('Key Bind'):upper() , value = '',
			hintText = {
				'If set, press ',{'Ctrl + ALT + THIS',cl.Yellow},' key while out-game to equip this kit.',
				{'\nCustom key-combination not available.\nDuplicated keybind can result unexpected result.\n(Only one kit can/will be equipped)',cl.Silver},
				{'\nBackspace to Remove bound key.',cl.Red}
			}
		})
		_Current['key'] = {elem}

		lH = me:_drawRow(pnl,20,row,20,y(),pnl:w()-40,false,true)
		y(lH,true)
		y(50)
		__, lbl = _.l({font=FONT, color=cl.LightSteelBlue, font_size=20, pnl = pnl, x = 20, y = y(0)},
			{PocoHud3Class.Icon.Chapter ..' Saved Kits',{' '..PocoHud3Class.Icon.RC ..' Edit or remove saved kits',cl.White}},true)
		y(lbl:h())
		lH = me:_drawRow(pnl,20,categories_vanity,20,y(),pnl:w()-40,true,true,1.3)
		y(lH,true)
		-- Kit Edt

		for ind,obj in _.p(K.items,function(a,b)return tostring(a)<tostring(b) end) do
			row = {}
			cnt = cnt + 1
			for col,category in pairs(categories) do
				if col ~= 1 then
					local val = K:get(ind,category,true)
					row[#row+1] = val and {val,K:locked(ind,category) and cl.Red:with_alpha(0.6) or cl.White} or {'LEAVE AS IS',cl.Gray}
				else
					row[#row+1] = PocoUIButton:new(tabEdt,{ pnl = pnl,
						onClick = function(self)
							if self._t and now()-self._t<0.2 then
								K.items[ind] = nil
								K:save()
								draw()
								self:sound('item_sell')
							else
								self._t = now()
								-- Copy this value to _Current Elems
								for cat,obj in pairs(_Current) do
									if cat == 'name' then
										obj[1]:val(ind)
									elseif cat == 'color' or cat == 'key' then
										obj[2] = K:get(ind,cat)
										obj[1]:val(obj[2] or cat == 'key' and '')
									else
										if K:get(ind,cat) then
											obj[2] = K:get(ind,cat)
											_.l(obj[1].lbl,{K:get(ind,cat,true),K:locked(ind,cat) and cl.Red or cl.White},true)
											obj[1]:val(true)
										else
											obj[1]:val(false)
										end
									end
								end
							end
						end,
						x = 0, y = 0, w=150, h=22,
						fontSize = 22, text={ind,cl[K:get(ind,'color') or 'White']}, hintText = {'Click to ',{'copy',cl.Tan},'\nDoubleClick to ',{'Remove',cl.Red},' this item'}
					})
				end
			end
			lH = me:_drawRow(pnl,22,row,20,y(),pnl:w()-40,cnt % 2 == 0,true,1.1)
			y(lH,true)
		end
		tabEdt:set_h(y()+50)
		pnl:set_h(tabEdt.pnl:h())

		-- Kit Btn
		if _kitPnlBtn and alive(_kitPnlBtn) then
			_kitPnlBtn:parent():remove(_kitPnlBtn)
		end
		pnl = tabBtn.pnl:panel{}
		_kitPnlBtn = pnl

		local c,x,y,m,ww,w,h = 0,0,0,10,pnl:w()-20,300,100
		local __, lbl = _.l({font=FONT, color=cl.LightSteelBlue, font_size=20, pnl = pnl, x = 20, y = 15},
			{PocoHud3Class.Icon.Chapter ..' Profiler',{' '..PocoHud3Class.Icon.RC ..' Double click to equip a kit setup',cl.White},me.inGameDeep and {' '..PocoHud3Class.Icon.BigDot..' Disabled in game.',cl.Red} or false},true)

		if table.size(K.items) == 0 then
			_.l({font=FONT, color=cl.Silver, font_size=25, pnl = pnl, x = m, y=m*2+lbl:h()},'No Kit profiles available',true)
		end
		for ind,obj in _.p(K.items,function(a,b)return tostring(a)<tostring(b) end) do
			x = m+(c % 3) * (w+m)
			y = 15+lbl:h()+ m+math.floor(c / 3) * (h+m)
			c = c + 1
			local name = ind
			local row = {}
			for col,category in pairs(categories) do
				if col ~= 1 then
					local val = K:get(ind,category,true)
					local locked = K:get(ind,category) and K:locked(ind,category)
					local enabled = val and not locked
					row[#row+1] = {categories_vanity[col]..' : ',enabled and cl.Tan or cl.Gray}
					if locked then
						row[#row+1] = {_.s(locked)..'\n',cl.Red:with_alpha(0.8)}
					else
						row[#row+1] = {(val or '-')..'\n',enabled and cl.White or cl.Gray}
					end
				end
			end
			local boundKey = K:get(ind,'key')
			if not inGameDeep and boundKey and boundKey ~= '' then
				row[#row+1] = {'KeyBind : ',cl.Tan}
				row[#row+1] = {'CTRL + ALT + '..boundKey..'\n',cl.Lime}
			end
			row[#row+1] = inGameDeep and 'N/A in game' or '* DoubleClick to Equip this item'
			PocoUIButton:new(tabBtn,{ pnl = pnl,
				onPressed = function(self)
					self.mute = true
				end,
				onClick = function(self)
					if not inGameDeep and self._t and now()-self._t<0.2 then
						K:equip(ind)
						self:sound('finalize_mask')
					else
						self._t = now()
					end
				end,
				x = x, y = y, w=w, h=h,
				fontSize = 25, text={ind,cl[K:get(ind,'color')] or cl.Tomato}, hintText = row
			})
		end
		tabBtn:set_h(y+h+50)
		pnl:set_h(tabBtn.pnl:h())
	end
	PocoUIButton:new(tabEdt,{
		onClick = function(self)
			local result = {}
			local name = 'Item'
			for cat,obj in pairs(_Current) do
				if cat == 'name' then
					name = obj[1]:val()
				elseif cat == 'color' or cat == 'key' then
					result[cat] = obj[1]:val()
				elseif obj[1]:val() then
						result[cat] = obj[2]
				end
			end
			if name and name~='' and table.size(result) > 0 then
				K.items[name] = result
				K:save()
				self:sound('item_buy')
				draw()
				me:_updateBind()
			else
				self:sound('menu_error')
			end
		end,
		x = 640, y = 105, w = 300, h=40,
		text={'SAVE',cl.CornFlowerBlue},hintText = {{'Add',cl.Tan},' or ',{'overwrite',cl.Tomato},' depending on the SET NAME'}
	})
	tabEdt.pnl:bitmap({
		texture = 'guis/textures/pd2/shared_lines',	wrap_mode = 'wrap',
		color = cl.White, x = 5, y = 150, w = tabEdt.pnl:w()-10, h = 2, alpha = 0.8
	})

	draw()
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
			if not obj then
				return 'invalid value'
			end
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
			if not obj then
				return 'invalid value'
			end
			local unlocked = obj and obj.unlocked
			return not unlocked and 'Locked'
		end,
		melee = function()
			local obj = val and Global.blackmarket_manager.melee_weapons[val]
			if not obj then
				return 'invalid value'
			end
			local unlocked = obj and obj.unlocked
			return not unlocked and 'Locked'
		end,
		color = function() return end
	}
	funcs.key = funcs.color
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

function Kits:keys()
	local r = {}
	for index,obj in pairs(self.items) do
		local nKey = obj.key and obj.key~='' and Poco:sanitizeKey(obj.key)
		if nKey then
			r[nKey] = index
		end
	end
	return r
end

function Kits:equip(index,showMessage)
	local _uoi = MenuCallbackHandler._update_outfit_information
	MenuCallbackHandler._update_outfit_information = function() end -- Avoid repeated submit
	local msg,gMsg = {},{}

	local r,err = pcall(function()
		local obj = self.items[index]
		if not obj then return false end
		for cat, slot in pairs(obj) do
			if self:locked(index,cat) then
				msg[#msg+1] = _.s('Ignored',cat:upper(),':',self:locked(index,cat),'.\n')
			else
				if cat == 'primaries' or cat == 'secondaries' then
					managers.blackmarket:equip_weapon(cat,slot)
				elseif cat == 'color' or cat == 'key' then
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
				if cat == 'color' or cat == 'key' then
					-- ignore gMsg
				else
					gMsg[#gMsg+1] = self:get(index,cat,true)
				end
			end
		end
	end)
	if not r then msg = {err} end
	local mcm = _.g('managers.menu_component._mission_briefing_gui:reload()')

	MenuCallbackHandler._update_outfit_information = _uoi -- restore
	MenuCallbackHandler:_update_outfit_information()

	if showMessage then
		msg[#msg+1] = 'Successfully equipped:\n'
		for __,o in ipairs(gMsg) do
			msg[#msg+1] = o .. (__<#gMsg and ', ' or '')
		end
	end
	if #msg > 0 then
		managers.system_menu:show{
			button_list = { {
					cancel_button = true,
					text = 'OK'
				} },
			text = table.concat(msg),
			title = 'Kits Profiler'..(index and ' : '..index or '')
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
	return asText and _asText[category] and _asText[category](obj[category]) or obj[category]
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

function PocoHud3Class._drawJukebox(tab)
	-- revised old code I made. also thx to PierreDjays for basic idea.
	local music
	music = {
		play = function(num)
			music.stop()
			Global.music_manager.source:set_switch( "music_randomizer", num )
			music.set(managers.music._last or 'setup')
		end,
		set = function(mode)
			managers.music._last = type(mode)~='table' and mode
			managers.music._skip_play = nil
			managers.music:post_event( type(mode)=='table' and mode[1] or "music_heist_"..mode )
		end,
		stop = function()
			managers.music:stop()
		end
	}
	PocoUIButton:new(tab,{
		onClick = function(self)
				music.stop()
		end,
		x = 440, y = 40, w = 200,h=40,
		text=L('_tab_juke_stop')
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			music.set('setup')
		end,
		x = 440, y = 90, w = 200,h=40,
		text=L('_tab_juke_stealth')
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			music.set('control')
		end,
		x = 440, y = 140, w = 200,h=40,
		text=L('_tab_juke_control')
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			music.set('anticipation')
		end,
		x = 440, y = 190, w = 200,h=40,
		text=L('_tab_juke_anticipation')
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			music.set('assault')
		end,
		x = 440, y = 240, w = 200,h=40,
		text=L('_tab_juke_assault')
	})

	local _addItems = function(oTab,inGame)
		local y = 10;
		local track_list,track_locked
		if inGame then
			track_list,track_locked = managers.music:jukebox_music_tracks()
		else
			track_list,track_locked = managers.music:jukebox_menu_tracks()
		end
		for __, track_name in pairs(track_list or {}) do
			local text = managers.localization:text((inGame and 'menu_jukebox_' or 'menu_jukebox_screen_')..track_name)
			local listed = inGame and managers.music:playlist_contains(track_name) or managers.music:playlist_menu_contains(track_name)
			local locked = track_locked[track_name]
			local hint = locked and managers.localization:text("menu_jukebox_locked_" .. locked) or nil
			PocoUIButton:new(oTab,{
				onClick = function(self)
					if not locked then
						music[inGame and 'play' or 'set'](inGame and track_name or {track_name})
					end
				end,
				x = 10, y = y, w = 400,h=30,
				text={text,locked and cl.Red or listed and cl.White or cl.Gray},
				hintText = hint
			})
			y = y + 35
		end
		oTab:set_h(y)
	end

	local oTabs = PocoTabs:new(me._ws,{name = 'jukeboxes',x = 10, y = 10, w = 420, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})
	-- [1] Heist musics
	_addItems(oTabs:add(L('_tab_juke_heist')), true)
	-- [2] Menu musics
	_addItems(oTabs:add(L('_tab_juke_menu')), false)



end

----------------------------------
-- Localizer : Auto Localizer
----------------------------------
local Localizer = class()
PocoHud3Class.Localizer = Localizer

function Localizer:init()
	-- Shorthand L(o,c)
	local mt = getmetatable(self)
	mt.__call = function(__,...)
		return self:parse(...)
	end
	setmetatable(self,mt)

	self.parser = {
		string = function(str,context)
			return str:find('^[_!]') and self:parse(self:get(str,context),context) or str
		end,
		table = function(tbl,context)
			local r = {}
			for k,v in pairs(tbl) do
				r[k] = self:parse(v,context)
			end
			return r
		end
	}
	self.data = {}
end

function Localizer:get(key,context)
	local val = self.data[key]
	if not val then
		val = _defaultLocaleData[key]
	end
	if val and type(context)=='table' then
		for k,v in pairs(context) do
			val = val:gsub('%['..k..'%]',v)
		end
	end
	return val or _.s('?:',key)
end

function Localizer:parse(object,context)
	local t = type(object)
	return self.parser[t] and self.parser[t](object,context) or object
end
