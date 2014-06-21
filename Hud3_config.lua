local YES,NO,yes,no = true,false,true,false
return {
	enable = YES,
	buff = {
		show = YES,
		left = 10,
		top  = 23,
		maxFPS = 30,
		size = 70, -- ignored by vanilla style
		gap = 10,
		align = 1, -- 1:left 2:center 3:right
		style = 2, -- 1:PocoHud style 2:Vanilla style
	},
	popup = {
		show = YES,
		size = 20,
		damageDecay = 10,
		myDamage = YES,
		crewDamage = YES,
		AIDamage = YES,
		handsUp = YES,
		dominated = YES,
	},
	float = {
		show = YES,
		size = 15,
		margin = 3,
		maxOpacity = 0.9,
		unit = YES,
		drills = YES,
	},
	clock = {

	},
	minion = {
		show = YES
	},
	chat = {
		readThreshold = 2,
		serverSendThreshold = 3,
		clientSendThreshold = 9,
		index = {
			midStat = 2,
			endStat = 3,
			dominated = 4,
			converted = 4,
			minionLost = 4,
			minionShot = 4,
			hostageChanged = 1,
			custody = 5,
			downedWarning = 5,
			replenished = 5,
			ping = 1,
		}
	},
}