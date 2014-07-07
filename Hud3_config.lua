local YES,NO,yes,no = true,false,true,false
return {
	enable = YES, -- Killswitch. Because reasons.
	buff = {
		show = YES,
		left = 10,
		top  = 22,
		maxFPS = 30,
		size = 70, -- ignored by vanilla style
		gap = 10,
		align = 1, -- 1:left 2:center 3:right
		style = 1, -- 1:PocoHud style 2:Vanilla style
	},
	popup = {
		show = YES,
		size = 20,				-- Font size
		damageDecay = 10,
		myDamage = YES,
		crewDamage = YES,
		AIDamage = YES,
		handsUp = YES,
		dominated = YES,
	},
	float = {
		show = YES,
		border = NO,
		size = 15,
		margin = 3,
		keepOnScreen = YES,
		keepOnScreenMargin = {2,15}, -- Margin Percent
		maxOpacity = 0.9,
		unit = YES,
		drills = YES,
	},
	info = {
		size = 17,	 -- Font size
		clock = YES, -- Clock on top of local playername
	},
	minion = {
		show = YES
	},
	chat = {
		readThreshold = 2,
		serverSendThreshold = 3,
		clientFullGameSendThreshold = 4,
		clientMidGameSendThreshold = 5,
		midgameAnnounce = 50,
		index = {
			midStat = 3,
			endStat = 4,
			dominated = 4,
			converted = 4,
			minionLost = 4,
			minionShot = 4,
			hostageChanged = 1,
			custody = 5,
			downed = 2,
			downedWarning = 5,
			replenished = 5,
		}
	},
	hitDirection = {
		replace = YES, -- Better hit direction markers
		duration = YES,  -- YES(=auto) or number(=seconds)
		opacity = 0.5, -- 0~1
		color = {
			shield = cl.Aqua,
			health = cl.Red
		}
	},
	conv = {
		city_swat = 'a Gensec Elite',
		cop = 'a cop',
		fbi = 'a FBI agent',
		fbi_heavy_swat = 'a FBI heavy SWAT',
		fbi_swat = 'a FBI SWAT',
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