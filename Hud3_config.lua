local YES,NO,yes,no = true,false,true,false
return {
	enable = YES,
	buff = {
		show = YES,
		maxFPS = 30,
		size = 70,
		gap = 20,
		align = 2, -- 1:left 2:center 3:right
		style = 1, -- 1:PocoHud style 2:Vanilla style
	},
	popup = {
		size = 20,
		damageDecay = 10,
		myDamage = YES,
		crewDamage = YES,
		AIDamage = YES,
		handsUp = YES,
		dominated = YES,
	},
	clock = {

	},
	minion = {
		show = YES
	},
	chat = {
		neverSend = NO,
		readThreshold = 2,
		sendThreshold = 3,
		index = {
			midStat = 2,
			endStat = 3,
			dominated = 4,
			converted = 4,
			minionLost = 4,
			hostageChanged = 1,
			downedWarning = 5,
			replenish = 5,
		}
	},
}