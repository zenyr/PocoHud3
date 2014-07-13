local YES,NO,yes,no = true,false,true,false
return {
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
		maxFPS = 30,-- 자연수 : 버프 갱신주기
		size = 70,  -- 자연수 : 버프 아이콘 크기 (단, "바닐라 스타일"에서는 무시)
		gap = 10,   -- 자연수 : 버프 아이콘 간격 (단, "바닐라 스타일"에서는 무시)
		align = 1,  -- [1,2,3] : 아이콘 정렬방향 1왼쪽 2중앙 3오른쪽
		style = 2,  -- [1,2]: 버프아이콘 스타일 1포코허드(컬러) 2바닐라(순정Feel)
	},
	popup = {						-- === 데미지팝업 설정 ===
		show = YES,				-- YES/NO : 데미지팝업 사용
		size = 20,				-- 자연수 : 팝업 글자크기
		damageDecay = 10,	-- 초 : 팝업 지속시간
		myDamage = YES,   -- YES/NO : 내 데미지 표시
		crewDamage = YES, -- YES/NO : 동료 플레이어 데미지 표시
		AIDamage = YES,		-- YES/NO : 동료 AI 데미지 표시
		handsUp = YES,		-- YES/NO : 몹이 투항하려 할 때 표시
		dominated = YES,	-- YES/NO : 투항 완료시 표시
	},
	float = {											-- === 가리킨 대상 정보 설정 ===
		show = YES,									-- YES/NO : 사용여부
		border = NO,								-- YES/NO : 모서리 표시 사용
		size = 15,									-- 자연수 : 정보 글자크기
		margin = 3,									-- 자연수 : 정보 항목간 간격
		keepOnScreen = YES,					-- YES/NO : 화면 내 유지여부
		keepOnScreenMargin = {2,15},-- {%,%} : 화면 내 유지시 가로, 세로 여백
		maxOpacity = 0.9,						-- 0-1 : 불투명도
		unit = YES,									-- YES/NO : 유닛정보 표시
		drills = YES,								-- YES/NO : 드릴정보 표시
	},
	info = {				-- === 플레이어 정보 ===
		size = 17,		-- 자연수 : 정보 글자크기
		clock = YES,	-- YES/NO : 내 정보란 빈칸을 활용해 (현실)시간 표시
		verboseKey = '`',
	},
	minion = {			-- === 미니언 정보 === >> Float을 활용해 Joker스킬 사용한 미니언 표시
		show = YES		-- YES/NO
	},
	chat = {													-- === 주요 이벤트 채팅 방송기능 === >> 이벤트별로 중요도를 할당해, 내 자격에 따라 방송 여부 결정가능
		readThreshold = 2,							-- 이 수치보다 높은 이벤트 발생시 내 채팅창에만 표시
		serverSendThreshold = 3,				-- 내가 방장인 경우 플레이어에게 모두 방송
		clientFullGameSendThreshold = 4,-- 내가 방장이 아니지만 방장과 동시에 시작했을 경우 플레이어에게 모두 방송
		clientMidGameSendThreshold = 5,	-- 내가 방장도 아니고 중간에 입장했지만 워낙 중요한 이벤트기 때문에 플레이어에게 모두 방송

		midgameAnnounce = 50,						-- 팀원+AI합산한 킬수마다 게임 중간 통계 출력 (이벤트 중요도에 따라 방송여부 결정)

		index = { -- Index: 이벤트별 중요도 할당. 높은 수치는 '많은 사람들이 알아야 하는 중요한 정보', 낮은 수치는 '별로 필요 없는 사소한 정보'를 의미
			midStat = 3,				-- 게임 중간통계 (*게임중 입장시 부정확)
			endStat = 4,				-- 게임 최종통계 (*게임중 입장시 부정확)
			dominated = 4,			-- 몹이 투항했을 경우
			converted = 4,			-- 플레이어가 몹을 미니언으로 변환한 경우
			minionLost = 4,			-- 미니언 사망
			minionShot = 4,			-- 플레이어에 의한 미니언 피격
			hostageChanged = 1,	-- 몹 인질 수 변동
			custody = 5,				-- 플레이어 체포
			downed = 2,					-- 플레이어 다운(단, 클로커/테이저 등 다운카운트 감소시키는 경우만)
			downedWarning = 5,	-- 플레이어가 3회 이상 다운
			replenished = 5,		-- 플레이어가 의료킷으로 체력&다운카운트 복구
			messiah = 5,				-- 플레이어가 피스톨메시아 사용
		}
	},
	hitDirection = {					-- === 피격 표시 설정 ===
		replace = YES,					-- YES/NO : 사용여부
		duration = YES,					-- YES/초 : 지속시간을 초로 입력. YES로 설정시 쉴드 복구시간으로 자동설정(권장)
		opacity = 0.5,					-- 0-1 : 투명도
		number = YES,						-- YES/NO : 피해량 표시
--		numberAsPercent = NO,
		numberSize = 25,				-- 피해량 글자 크기
		numberDefaultFont = NO,	-- 피해량 폰트를 기본폰트로
		sizeStart = 100,				-- 최초 크기
		sizeEnd = 200,					-- 사라지기 직전의 크기
		color = {
			shield = cl.Aqua,			-- Color('RRGGBB') : 쉴드 손실시 색상
			health = cl.Red				-- Color('RRGGBB') : 체력 손실시 색상
		}
	},
	conv = {	-- === 미니언 사망 원인 표현용, 변경할 필요 없음 ===
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