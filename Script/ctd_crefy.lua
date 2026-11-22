-- Standalone | UI: Crefy (Obsidian / Linoria fork)
local Repo         = "https://raw.githubusercontent.com/lrexzyq/Crefy/main/"
local _CREFY_LIB   = loadstring(game:HttpGet(Repo .. "Library.lua"))()
local _CREFY_THEME = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local _CREFY_SAVE  = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()
local Options      = _CREFY_LIB.Options
local Toggles      = _CREFY_LIB.Toggles

-- HTTP request (thay thế barrage request)
local _httpFuncs = {}
local function _tryHttp(fn) if type(fn) == "function" then _httpFuncs[#_httpFuncs + 1] = fn end end
pcall(function() _tryHttp(type(syn) == "table" and syn.request) end)
pcall(function() _tryHttp(type(http) == "table" and http.request) end)
pcall(function() _tryHttp(type(fluxus) == "table" and fluxus.request) end)
pcall(function() _tryHttp(request) end)
pcall(function() _tryHttp(http_request) end)

local function _copyOpts(o)
	local c = {}
	for k, v in next, o do c[k] = v end
	if type(o.Headers) == "table" then
		local h = {}; for k, v in next, o.Headers do h[k] = v end; c.Headers = h
	end
	return c
end
local function _normResp(r)
	if type(r) ~= "table" then return nil end
	local body = r.Body or r.body or r.ResponseBody or r.responseBody or ""
	local code = tonumber(r.StatusCode or r.Status or r.status_code or r.statusCode)
	if not code or code == 0 then
		code = (r.Success == false or r.success == false) and 0 or 200
	end
	return {
		Body    = type(body) == "string" and body or tostring(body or ""),
		Headers = r.Headers or r.headers or {},
		StatusCode = code,
		Success = code >= 200 and code < 300,
	}
end
local _reqPrimary
shared._barrageRequest = function(opts)
	if type(opts) ~= "table" then return nil, "invalid options" end
	local lastErr = "request unavailable"
	if _reqPrimary then
		local ok, r = pcall(_reqPrimary, _copyOpts(opts))
		local n = ok and _normResp(r)
		if n then return n end
		lastErr = ok and "invalid response" or tostring(r); _reqPrimary = nil
	end
	for _, fn in ipairs(_httpFuncs) do
		local ok, r = pcall(fn, _copyOpts(opts))
		local n = ok and _normResp(r)
		if n then _reqPrimary = fn; return n end
		lastErr = ok and "invalid response" or tostring(r)
	end
	return nil, lastErr
end

-- Bypass barrage auth — client state luôn hợp lệ
shared._barrageClientState  = { Dead = false, Owner = true, Premium = true }
shared._barrageWebhook      = shared._barrageWebhook or ""
shared._barrageUID          = game:GetService("Players").LocalPlayer.UserId



local function geniter(f, s, c)
	if type(f) ~= "function" then
		local mt = getmetatable(f)

		if type(mt) == "table" and mt.__iter then
			f, s, c = mt.__iter(f)
		elseif type(f) == "table" then
			f, s, c = next, f, nil
		end
	end

	return function()
		local r = table.pack(f(s, c))

		if r[1] == nil then
			return false
		end

		c = r[1]

		return true, table.unpack(r, 1, r.n)
	end
end

local v4 = true  -- bypass barrage auth

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer

if type(shared._barrageCameramanTowerDefenseShutdown) == "function" then
	pcall(shared._barrageCameramanTowerDefenseShutdown)
end

shared._barrageCameramanTowerDefenseShutdown = nil

local t1 = {}
local t2, t3, t4, t5, t6, t7, t8, t9, t10, t11
local t12, t13, t14, v29, v30, t15, t16

do
	t1._gti = getthreadidentity or getidentity or type(syn) == "table" and syn.get_thread_identity or nil
	t1._sti = setthreadidentity or setidentity or type(syn) == "table" and syn.set_thread_identity or nil

	do
		pcall(function()
			t1._identity = t1._gti()
		end)
	end

	t1._restoreIdentity = function()
		if t1._identity ~= nil and type(t1._sti) == "function" then
			pcall(t1._sti, t1._identity)
		end
	end

	local t17 = {
		"Easy",
		"Normal",
		"Hard",
		"Insane",
		"Nightmare"
	}

	t2 = {
		"Basic",
		"Uncommon",
		"Rare",
		"Epic",
		"Legendary",
		"Mythic",
		"Godly",
		"Exclusive"
	}
	t3 = {
		"Engineer",
		"NewMaps",
		"RELEASE",
		"UPDATE1",
		"UpgradedTitanSpeakerman"
	}

	local t18 = {
		"AFK 15 Minutes",
		"Kill 500 Toilets",
		"Place 25",
		"Win Games 3"
	}
	local t19 = {
		"Cameraman HQ",
		"Desert",
		"Toilet City"
	}
	local t20 = {
		"First",
		"Last",
		"Closest",
		"Strong",
		"Weak"
	}

	t4 = { "Keep One Of Each" }
	t5 = {
		"Coins",
		"Lucky"
	}
	t6 = {
		"Front",
		"Center",
		"Last"
	}
	t7 = {
		"25%",
		"50%",
		"75%",
		"100%"
	}
	t8 = {
		"Mute Music",
		"Mute Sounds",
		"Trades Off",
		"VFX Off"
	}
	t9 = {
		"Free",
		"Premium"
	}
	t10 = {
		"Beat Waves",
		"Collect Candies",
		"Destroy Toilets",
		"Open Crates",
		"Play Time"
	}
	t11 = {
		DeployDelay = {
			0,
			10,
			1
		},
		UpgradeDelay = {
			0,
			10,
			1
		},
		SellDelay = {
			0,
			10,
			1
		},
		SkipDelay = {
			0,
			10,
			1
		},
		TargetDelay = {
			0,
			10,
			1
		},
		EndDelay = {
			0,
			30,
			1
		},
		JoinDelay = {
			0,
			60,
			1
		},
		VoteDelay = {
			0,
			10,
			1
		},
		ModVoteDelay = {
			0,
			10,
			1
		},
		SummonDelay = {
			0,
			15,
			1
		},
		AutosellDelay = {
			0,
			15,
			1
		},
		EquipDelay = {
			0,
			15,
			1
		},
		UnitSellDelay = {
			0,
			15,
			1
		},
		CodesDelay = {
			0,
			15,
			1
		},
		BoostDelay = {
			0,
			15,
			1
		},
		CrateDelay = {
			0,
			15,
			1
		},
		PassDelay = {
			0,
			15,
			1
		},
		MacroDelay = {
			0,
			10,
			1
		},
		QuestDelay = {
			0,
			15,
			1
		},
		PassTierDelay = {
			0,
			15,
			1
		},
		PassQuestDelay = {
			0,
			15,
			1
		},
		ShopDelay = {
			0,
			15,
			1
		},
		WalkDelay = {
			0,
			10,
			1
		},
		WalkRange = {
			0,
			100,
			0
		},
		AbilityDelay = {
			0,
			10,
			1
		},
		RankDelay = {
			0,
			15,
			1
		},
		MedalDelay = {
			0,
			15,
			1
		},
		AssistDelay = {
			0,
			10,
			1
		},
		SpecialQuestDelay = {
			0,
			15,
			1
		},
		RngRollDelay = {
			0,
			15,
			1
		}
	}
	t12 = {
		AutoPlay = false,
		AutoPlayKeybind = "None",
		PlayPreset = "Blatant",
		PlayStrategy = "Balanced",
		PlaceMode = "Smart Deploy",
		UseSavedPositions = false,
		DeployActions = {
			"Save For Top Pick",
			"Skip Late Farms"
		},
		SmartDeployPaths = { "Auto (All Paths)" },
		CashReserve = 0,
		DeployDelay = {
			Min = 0,
			Max = 0
		},
		DeployCoverage = 100,
		CoverageQuick = "100%",
		CoveragePreset = "Whole Lane",
		CoverageFrom = "Front",
		EspCoverage = false,
		EspCoverageColor = {
			255,
			0,
			0
		},
		EspCoverageTransparency = 30,
		SmartDeployPreview = false,
		SmartDeployPreviewTransparency = 50,
		SmartDeployPreviewShow = {
			"Highlight",
			"Text"
		},
		AutoWalk = false,
		AutoWalkKeybind = "None",
		WalkTo = {
			"Ability",
			"Placement",
			"Target Change",
			"Upgrade"
		},
		WalkRange = {
			Min = 0,
			Max = 0
		},
		WalkDelay = {
			Min = 0,
			Max = 0
		},
		DeployPreset = "Loadout Order",
		DeployRarities = {},
		DeployRaritiesSeen = {},
		UnitSpacing = 0,
		GridDesign = "Honeycomb",
		CustomPriority = false,
		FillSlotFirst = false,
		TopPickWait = 0,
		TargetPreset = "All Smart",
		AutoTarget = false,
		AutoTargetKeybind = "None",
		SmartTargetRules = {
			"Boss In Range: Strong",
			"Leaking Enemy: First",
			"Last Unit Before Base: First",
			"Area Units On Crowds: First",
			"Low Health Swarm: Weak",
			"Split Bosses Across Units"
		},
		SmartLeakPct = 80,
		SmartSwitchHold = 1500,
		TargetDelay = {
			Min = 0,
			Max = 0
		},
		AutoUpgrade = false,
		AutoUpgradeKeybind = "None",
		UpgradeStrategy = "Balanced",
		UpgradePreset = "Instant",
		UpgradeTiming = "Place All First",
		UpgradeActions = {
			"Farms Early",
			"Skip Late Farm Upgrades"
		},
		FarmUpgradeMode = "Payback",
		FarmsEarlyWave = 10,
		SkipLateFarmWaves = 4,
		UpgradeReserve = 0,
		UpgradeDelay = {
			Min = 0,
			Max = 0
		},
		UpgradePriority = false,
		UpgradeOrderPreset = "Place All, Then Upgrade",
		RecordPreset = "Full Strategy",
		MacroRecord = false,
		MacroRecordActions = {
			"Placements",
			"Sells",
			"Targets",
			"Upgrades"
		},
		MacroStopWave = 0,
		RunPreset = "Wave Safe",
		MacroRun = false,
		MacroSelected = "",
		MacroName = "",
		MacroPause = {
			"Auto Play",
			"Auto Sell",
			"Auto Target",
			"Auto Upgrade"
		},
		MacroActions = { "Wait For Recorded Wave" },
		MacroDelay = {
			Min = 0,
			Max = 0
		},
		MacroRetries = 3,
		AssistPreset = "One Tap",
		DeployAssist = false,
		DeployAssistKeybind = "F",
		AssistUnit = "Auto Play's Pick",
		AssistSpot = "Same As Auto Play",
		AssistCount = "1",
		AssistUpgrades = 0,
		AssistReserve = 0,
		AssistDelay = {
			Min = 0,
			Max = 0
		},
		SkipPreset = "Safe",
		AutoSkip = false,
		SkipFromWave = 1,
		SkipDelay = {
			Min = 0,
			Max = 0
		},
		SellPreset = "Sell Farms Late",
		AutoSell = false,
		SellActions = { "Sell Farms Before End" },
		SellTowers = {},
		SellFarmsBeforeEnd = 2,
		SellFarmUnits = {},
		SellFarmUnitsSeen = {},
		UpgradeFarmUnits = {},
		UpgradeFarmUnitsSeen = {},
		SellAllAtWave = 0,
		SellSelectedWave = 0,
		SellLowLives = 0,
		Positions = {},
		PlacementPreview = true,
		PlacementPreviewColor = {
			255,
			0,
			0
		},
		PlacementPreviewTransparency = 40,
		MarkerPreset = "Labeled",
		PlacementLabels = true,
		PlacementMarkerSize = 3,
		MoveMode = "Teleport",
		TweenSpeed = 150,
		WalkSpeed = 50,
		MatchModPreset = "Place Anywhere",
		MatchMods = false,
		MatchSkips = {
			"Ground",
			"Overlap",
			"Road"
		},
		StackGap = 1,
		MoveModPreset = "Blatant",
		MoveMods = false,
		MoveModsKeybind = "None",
		MoveModActions = {
			"Fly",
			"Infinite Jump",
			"Jump Boost",
			"Noclip",
			"Speed"
		},
		ModWalkSpeed = 100,
		ModFlySpeed = 120,
		ModJumpPower = 120,
		EspRoute = false,
		EspRouteColor = {
			255,
			0,
			0
		},
		EspRouteTransparency = 35,
		EspNodes = false,
		EspNodesColor = {
			255,
			0,
			0
		},
		EspNodesTransparency = 25,
		EspDirection = false,
		EspDirectionColor = {
			255,
			0,
			0
		},
		EspDirectionTransparency = 30,
		EspRanges = false,
		EspRangesColor = {
			255,
			0,
			0
		},
		EspRangesTransparency = 35,
		EspEnemies = false,
		EspEnemiesColor = {
			255,
			0,
			0
		},
		EspEnemiesTransparency = 0,
		EspEnemyDetail = {
			"Health",
			"Tags"
		},
		EspSpots = false,
		EspSpotsColor = {
			255,
			0,
			0
		},
		EspSpotsTransparency = 35,
		EspSpotLimit = 6000,
		SpotsPreset = "Every Spot",
		EspSpotKinds = { "Ground" },
		EspHillSpotsColor = {
			255,
			170,
			0
		},
		EspGround = false,
		EspGroundColor = {
			255,
			0,
			0
		},
		EspGroundTransparency = 70,
		GroundPreset = "Build Ground",
		EspGroundKinds = { "Ground" },
		EspGroundHillColor = {
			255,
			170,
			0
		},
		EspGroundOutline = false,
		EspPath = false,
		EspPathColor = {
			255,
			0,
			0
		},
		EspPathTransparency = 60,
		EspMaxRange = false,
		EspMaxRangeColor = {
			255,
			200,
			0
		},
		EspMaxRangeTransparency = 40,
		BlackScreen = false,
		BlackScreenKeybind = "None",
		DeleteMap = false,
		FpsCap = 0,
		Webhook = false,
		WebhookUrl = "",
		WebhookUserId = "",
		HookMatch = true,
		HistoryView = "Matches",
		HistoryOrder = "Newest",
		HistoryAmount = 25,
		HistoryPreview = true,
		HistoryPreviewKeybind = "None",
		HookMatchSend = "Every Round",
		HookMatchDetails = {
			"Coins Reward",
			"Duration",
			"Map And Mode",
			"Session Record",
			"Waves"
		},
		HookMatchActions = {},
		AntiAFK = true,
		UnitFacing = "Path Entrance",
		AutoMatchEnd = false,
		EndPreset = "Natural Replay",
		EndAction = "Play Again",
		EndDelay = {
			Min = 3,
			Max = 3
		},
		StopAfterRounds = 0,
		StopAfterMinutes = 0,
		StopAction = "Stay In Lobby",
		AutoSpeed = false,
		GameSpeed = "2x",
		SpeedBossSlow = false,
		SkipWhen = "Base Untouched",
		SkipUntilWave = 0,
		SkipMinHealth = 0,
		SkipHoldBoss = false,
		AutoJoin = false,
		JoinMap = "Any Map",
		JoinParty = "Solo",
		JoinModifiers = {},
		JoinDelay = {
			Min = 0,
			Max = 0
		},
		JoinBy = "Elevator",
		MatchSize = "Duo",
		JoinPreset = "Fast Solo",
		AutoVote = false,
		VotePreset = "Climb",
		VoteMode = "Smart Progression",
		VoteDelay = {
			Min = 0,
			Max = 0
		},
		AutoModVote = false,
		ModVotePreset = "Instant",
		ModVotePicks = {},
		ModVotePicksSeen = {},
		ModVoteDelay = {
			Min = 0,
			Max = 0
		},
		AutoSummon = false,
		SummonPreset = "Max Pulls",
		SummonCrate = "Basic Crate",
		SummonAmount = "Smart",
		SummonKeep = 0,
		SummonDelay = {
			Min = 0,
			Max = 0
		},
		SummonWanted = {},
		SummonStopWanted = false,
		AutoAutosell = false,
		AutosellPreset = "Lowest Two",
		AutosellRarities = {
			"Basic",
			"Uncommon"
		},
		AutosellDelay = {
			Min = 0,
			Max = 0
		},
		AutoEquip = false,
		EquipPreset = "Instant",
		EquipBy = "Smart",
		EquipTeam = {},
		EquipDelay = {
			Min = 0,
			Max = 0
		},
		AutoUnitSell = false,
		UnitSellPreset = "Lowest Two",
		UnitSellRarities = {
			"Basic",
			"Uncommon"
		},
		UnitSellKeep = table.clone(t4),
		UnitSellDelay = {
			Min = 0,
			Max = 0
		},
		AutoQuests = false,
		QuestPreset = "Instant",
		QuestSelection = table.clone(t18),
		QuestSelectionSeen = table.clone(t18),
		QuestDelay = {
			Min = 0,
			Max = 0
		},
		AutoCodes = false,
		CodeSelection = table.clone(t3),
		CodeSelectionSeen = table.clone(t3),
		CodesDelay = {
			Min = 0,
			Max = 0
		},
		CodesExtra = "",
		AutoBoosts = false,
		BoostPreset = "Instant",
		BoostSelection = table.clone(t5),
		BoostDelay = {
			Min = 0,
			Max = 0
		},
		AutoCrates = false,
		CratePreset = "Instant",
		CrateSelection = {},
		CrateSelectionSeen = {},
		CrateDelay = {
			Min = 0,
			Max = 0
		},
		AutoPassItems = false,
		PassItemPreset = "Instant",
		PassItemSelection = {},
		PassItemSelectionSeen = {},
		PassDelay = {
			Min = 0,
			Max = 0
		},
		AutoPassTiers = false,
		TierPreset = "Every Track",
		PassTracks = table.clone(t9),
		PassTierDelay = {
			Min = 0,
			Max = 0
		},
		AutoPassQuests = false,
		PassQuestPreset = "Instant",
		PassChains = table.clone(t10),
		PassQuestDelay = {
			Min = 0,
			Max = 0
		},
		AutoCrateShop = false,
		ShopPreset = "Spend All",
		ShopCrates = { "Exclusive Halloween Crate" },
		ShopKeepGems = 0,
		ShopKeepCandy = 0,
		ShopDelay = {
			Min = 0,
			Max = 0
		},
		GameSettings = false,
		GameSettingPicks = {},
		SettingsPreset = "Custom",
		HookSummons = true,
		HookSummonRarity = "Legendary And Above",
		HookSummonPing = true,
		HookSummaryEvery = 10,
		HookWaves = true,
		HookWaveEvery = 5,
		HookWaveActions = {
			"Base Health",
			"Cash",
			"Enemies Left",
			"Towers Placed",
			"Wave Time"
		},
		BlackScreenWhen = "Always",
		EmergencyLeave = false,
		LeavePreset = "Balanced",
		LeaveActions = { "Base Health Below" },
		LeaveBaseHP = 30,
		LeaveBossPath = 80,
		LeaveAtWave = false,
		LeaveWave = 30,
		AutoAbility = false,
		AbilityPreset = "With Enemies",
		AbilityActions = { "Only With Enemies" },
		AbilityMinEnemies = 1,
		AbilityFromWave = 0,
		AbilityMinGain = 20,
		AbilityDelay = {
			Min = 0,
			Max = 0
		},
		AutoMedal = false,
		MedalPreset = "Instant",
		MedalSelection = { "Clip Partner Reward" },
		MedalDelay = {
			Min = 0,
			Max = 0
		},
		AutoRanks = false,
		RankPreset = "Instant",
		RankSelection = {},
		RankSelectionSeen = {},
		RankDelay = {
			Min = 0,
			Max = 0
		},
		PartyRole = "Off",
		PartyAltNames = "",
		HostPreset = "Wait For Party",
		WaitForAlts = true,
		AltWaitTime = 60,
		PartyHostName = "",
		AltPreset = "Same Server",
		FollowHost = true,
		HostServerId = "",
		JoinHostServer = false,
		AutoSpecialQuests = false,
		SpecialQuestPreset = "Every Milestone",
		SpecialQuestSelection = {},
		SpecialQuestSelectionSeen = {},
		SpecialQuestDelay = {
			Min = 0,
			Max = 0
		},
		AutoRngRoll = false,
		RngRollPreset = "Every Slot",
		RngRollDelay = {
			Min = 0,
			Max = 0
		}
	}
	t13 = {
		"Ability Actions",
		"On Cooldown",
		"With Enemies",
		"Boss Waves",
		"Off"
	}
	t1.TARGET_RULES = {
		"Boss In Range: Strong",
		"Leaking Enemy: First",
		"Last Unit Before Base: First",
		"Area Units On Crowds: First",
		"Low Health Swarm: Weak",
		"Split Bosses Across Units"
	}

	for i = 1, 5 do
		t12["SlotPri" .. i] = tostring(i)
		t12["SlotLimit" .. i] = "Game Limit"
		t12["SlotTarget" .. i] = "Smart"
		t12["SlotUpgPri" .. i] = tostring(i)
		t12["SlotMaxLevel" .. i] = 0
		t12["SlotAbility" .. i] = "Ability Actions"
	end

	for k, v in pairs(table.clone(t12)) do
		if type(v) == "boolean" and t12[k .. "Keybind"] == nil then
			t12[k .. "Keybind"] = "None"
		end
	end

	t14 = {}

	for k, v in pairs(t12) do
		t14[k] = type(v) == "table" and table.clone(v) or v
	end

	local t21 = {}

	for k in pairs(t12) do
		if k ~= "MacroRecord" and k ~= "PlayStrategy" then
			t21[#t21 + 1] = k
		end
	end

	table.sort(t21)
	t1.PRESETS = {
		SkipPreset = {
			keys = {
				"SkipWhen",
				"SkipFromWave",
				"SkipUntilWave",
				"SkipMinHealth",
				"SkipHoldBoss"
			},
			values = {
				Safe = {
					SkipWhen = "Base Untouched",
					SkipFromWave = 0,
					SkipUntilWave = 0,
					SkipMinHealth = 0,
					SkipHoldBoss = false
				},
				["Every Wave"] = {
					SkipWhen = "Always",
					SkipFromWave = 0,
					SkipUntilWave = 0,
					SkipMinHealth = 0,
					SkipHoldBoss = false
				},
				["Boss Careful"] = {
					SkipWhen = "Always",
					SkipFromWave = 0,
					SkipUntilWave = 0,
					SkipMinHealth = 50,
					SkipHoldBoss = true
				}
			}
		},
		AbilityPreset = {
			keys = {
				"AbilityActions",
				"AbilityMinEnemies",
				"AbilityFromWave"
			},
			values = {
				["With Enemies"] = {
					AbilityActions = { "Only With Enemies" },
					AbilityMinEnemies = 1,
					AbilityFromWave = 0
				},
				["On Cooldown"] = {
					AbilityActions = {},
					AbilityMinEnemies = 1,
					AbilityFromWave = 0
				},
				["Crowds Only"] = {
					AbilityActions = { "Only With Enemies" },
					AbilityMinEnemies = 5,
					AbilityFromWave = 0
				},
				["Boss Waves"] = {
					AbilityActions = {
						"Only On Boss Waves",
						"Only With Enemies"
					},
					AbilityMinEnemies = 1,
					AbilityFromWave = 0
				}
			}
		}
	}

	local function v44(p1, p2, p3, p4)
		local function v45(p5, p6)
			local function v46()
				local t22 = {
					[p2] = {
						Min = p5,
						Max = p6
					}
				}

				if p1 then
					local ok, result = pcall(p3)

					t22[p1] = ok and type(result) == "table" and table.clone(result) or {}
				end

				local v50 = p4 or {}

				for k, v in pairs(v50) do
					t22[k] = type(v) == "table" and table.clone(v) or v
				end

				return t22
			end

			return v46
		end

		local t23 = { p2 }

		if p1 then
			table.insert(t23, 1, p1)
		end

		local v54 = p4 or {}

		for k in pairs(v54) do
			t23[#t23 + 1] = k
		end

		return {
			keys = t23,
			values = {
				Instant = v45(0, 0),
				Natural = v45(2, 5)
			}
		}
	end

	do
		local function v56(p7)
			local function v57()
				local ok, result = pcall(p7)

				return ok and type(result) == "table" and result or {}
			end

			return v57
		end

		local t24 = {
			Min = 0,
			Max = 0
		}

		t1.PRESETS.EndPreset = {
			keys = {
				"EndAction",
				"EndDelay"
			},
			values = {
				["Quick Replay"] = {
					EndAction = "Play Again",
					EndDelay = {
						Min = 0,
						Max = 0
					}
				},
				["Natural Replay"] = {
					EndAction = "Play Again",
					EndDelay = {
						Min = 3,
						Max = 3
					}
				},
				["Fresh Server"] = {
					EndAction = "Lobby",
					EndDelay = {
						Min = 3,
						Max = 3
					}
				}
			}
		}
		t1.PRESETS.LeavePreset = {
			keys = {
				"LeaveActions",
				"LeaveBaseHP",
				"LeaveBossPath"
			},
			values = {
				Balanced = {
					LeaveActions = { "Base Health Below" },
					LeaveBaseHP = 30,
					LeaveBossPath = 80
				},
				Careful = {
					LeaveActions = {
						"Base Health Below",
						"Boss Path Progress"
					},
					LeaveBaseHP = 50,
					LeaveBossPath = 70
				},
				["Last Resort"] = {
					LeaveActions = { "Base Health Below" },
					LeaveBaseHP = 10,
					LeaveBossPath = 95
				}
			}
		}
		t1.PRESETS.JoinPreset = {
			keys = {
				"JoinBy",
				"JoinParty",
				"MatchSize",
				"JoinModifiers",
				"JoinDelay"
			},
			values = {
				["Fast Solo"] = {
					JoinBy = "Elevator",
					JoinParty = "Solo",
					MatchSize = "Duo",
					JoinModifiers = {},
					JoinDelay = table.clone(t24)
				},
				["Bonus Rewards"] = function()
					return {
						JoinBy = "Elevator",
						JoinParty = "Solo",
						MatchSize = "Duo",
						JoinModifiers = v56(function()
							return t1.Queue.modNames()
						end)(),
						JoinDelay = table.clone(t24)
					}
				end,
				["Public Duo"] = {
					JoinBy = "Matchmaking",
					JoinParty = "Solo",
					MatchSize = "Duo",
					JoinModifiers = {},
					JoinDelay = table.clone(t24)
				},
				["Join Others"] = {
					JoinBy = "Elevator",
					JoinParty = "Any Free",
					MatchSize = "Duo",
					JoinModifiers = {},
					JoinDelay = {
						Min = 2,
						Max = 6
					}
				}
			}
		}
		t1.PRESETS.VotePreset = {
			keys = {
				"VoteMode",
				"VoteDelay"
			},
			values = {
				Climb = {
					VoteMode = "Smart Progression",
					VoteDelay = table.clone(t24)
				},
				["Natural Climb"] = {
					VoteMode = "Smart Progression",
					VoteDelay = {
						Min = 2,
						Max = 5
					}
				},
				["Top Payout"] = function()
					local v61 = v56(function()
						return t1.Vote.ladder()
					end)()
					local v63 = v61[#v61]
					local t25 = {
						VoteMode = v63 or "Smart Progression",
						VoteDelay = table.clone(t24)
					}

					return t25
				end
			}
		}
		t1.PRESETS.ModVotePreset = v44("ModVotePicks", "ModVoteDelay", function()
			return t1.Queue.modNames()
		end)
		t1.PRESETS.HostPreset = {
			keys = {
				"WaitForAlts",
				"AltWaitTime"
			},
			values = {
				["Wait For Party"] = {
					WaitForAlts = true,
					AltWaitTime = 60
				},
				Patient = {
					WaitForAlts = true,
					AltWaitTime = 120
				},
				["Quick Start"] = {
					WaitForAlts = true,
					AltWaitTime = 30
				},
				["No Wait"] = {
					WaitForAlts = false,
					AltWaitTime = 60
				}
			}
		}
		t1.PRESETS.AltPreset = {
			keys = {
				"FollowHost",
				"JoinHostServer"
			},
			values = {
				["Full Follow"] = {
					FollowHost = true,
					JoinHostServer = true
				},
				["Same Server"] = {
					FollowHost = true,
					JoinHostServer = false
				},
				Manual = {
					FollowHost = false,
					JoinHostServer = false
				}
			}
		}
		t1.PRESETS.SummonPreset = {
			keys = {
				"SummonAmount",
				"SummonKeep",
				"SummonStopWanted",
				"SummonDelay"
			},
			values = {
				["Max Pulls"] = {
					SummonAmount = "Smart",
					SummonKeep = 0,
					SummonStopWanted = false,
					SummonDelay = table.clone(t24)
				},
				["Hunt Wanted"] = {
					SummonAmount = "Smart",
					SummonKeep = 0,
					SummonStopWanted = true,
					SummonDelay = table.clone(t24)
				},
				["Keep A Reserve"] = {
					SummonAmount = "Smart",
					SummonKeep = 5000,
					SummonStopWanted = false,
					SummonDelay = table.clone(t24)
				}
			}
		}

		local function v64(p8, p9)
			local function v65()
				local v66 = v56(function()
					return p9 and t1.ASell.rarities() or t1.Rarities()
				end)()
				local t26 = {}

				for i = 1, math.min(p8, #v66) do
					t26[i] = v66[i]
				end

				return t26
			end

			return v65
		end

		t1.PRESETS.AutosellPreset = {
			keys = {
				"AutosellRarities",
				"AutosellDelay"
			},
			values = {
				["Lowest Two"] = function()
					return {
						AutosellRarities = v64(2, true)(),
						AutosellDelay = table.clone(t24)
					}
				end,
				["Lowest Three"] = function()
					return {
						AutosellRarities = v64(3, true)(),
						AutosellDelay = table.clone(t24)
					}
				end,
				["Lowest Four"] = function()
					return {
						AutosellRarities = v64(4, true)(),
						AutosellDelay = table.clone(t24)
					}
				end
			}
		}
		t1.PRESETS.UnitSellPreset = {
			keys = {
				"UnitSellRarities",
				"UnitSellKeep",
				"UnitSellDelay"
			},
			values = {
				["Lowest Two"] = function()
					return {
						UnitSellRarities = v64(2)(),
						UnitSellKeep = table.clone(t4),
						UnitSellDelay = table.clone(t24)
					}
				end,
				["Lowest Three"] = function()
					return {
						UnitSellRarities = v64(3)(),
						UnitSellKeep = table.clone(t4),
						UnitSellDelay = table.clone(t24)
					}
				end,
				["Lowest Four"] = function()
					return {
						UnitSellRarities = v64(4)(),
						UnitSellKeep = table.clone(t4),
						UnitSellDelay = table.clone(t24)
					}
				end
			}
		}
		t1.PRESETS.EquipPreset = v44(nil, "EquipDelay", nil, {
			EquipBy = "Smart"
		})
		t1.PRESETS.ShopPreset = {
			keys = {
				"ShopCrates",
				"ShopKeepGems",
				"ShopKeepCandy",
				"ShopDelay"
			},
			values = {
				["Spend All"] = function()
					return {
						ShopCrates = v56(function()
							return t1.Shop.names()
						end)(),
						ShopKeepGems = 0,
						ShopKeepCandy = 0,
						ShopDelay = table.clone(t24)
					}
				end,
				["Keep A Reserve"] = function()
					return {
						ShopCrates = v56(function()
							return t1.Shop.names()
						end)(),
						ShopKeepGems = 500,
						ShopKeepCandy = 1000,
						ShopDelay = table.clone(t24)
					}
				end
			}
		}
		t1.PRESETS.BoostPreset = v44("BoostSelection", "BoostDelay", function()
			return t5
		end)
		t1.PRESETS.QuestPreset = v44("QuestSelection", "QuestDelay", function()
			return t1.Quest.names()
		end)
		t1.PRESETS.RankPreset = v44("RankSelection", "RankDelay", function()
			return t1.Rank.names()
		end)
		t1.MEDAL_REWARDS = { "Clip Partner Reward" }
		t1.PRESETS.MedalPreset = v44("MedalSelection", "MedalDelay", function()
			return t1.MEDAL_REWARDS
		end)
		t1.PRESETS.CratePreset = v44("CrateSelection", "CrateDelay", function()
			return t1.Crates.names()
		end)
		t1.PRESETS.PassItemPreset = v44("PassItemSelection", "PassDelay", function()
			return t1.Pass.names()
		end)
		t1.PRESETS.TierPreset = {
			keys = {
				"PassTracks",
				"PassTierDelay"
			},
			values = {
				["Every Track"] = {
					PassTracks = table.clone(t9),
					PassTierDelay = table.clone(t24)
				},
				["Free Track"] = {
					PassTracks = { "Free" },
					PassTierDelay = table.clone(t24)
				},
				Natural = {
					PassTracks = table.clone(t9),
					PassTierDelay = {
						Min = 2,
						Max = 5
					}
				}
			}
		}
	end

	t1.PRESETS.PassQuestPreset = v44("PassChains", "PassQuestDelay", function()
		return t10
	end)

	do
		t1._presetFor = function(p10)
			local v69 = t1.PRESETS[p10]

			for k, value in pairs(v69.values) do
				if type(value) == "function" then
					local ok, result = pcall(value)

					value = ok and type(result) == "table" and result or {}
				end

				local v74 = true

				for _, key in ipairs(v69.keys) do
					local v77 = t12[key]
					local v78 = value[key]

					if type(v77) == "table" and type(v78) == "table" and (v77.Min ~= nil or v78.Min ~= nil) then
						if t1._n(v77.Min) ~= t1._n(v78.Min) or t1._n(v77.Max) ~= t1._n(v78.Max) then
							v74 = false
						end
					elseif type(v77) == "table" and type(v78) == "table" then
						local v79 = t1._set(v77)
						local v80 = t1._set(v78)

						for k2 in pairs(v79) do
							if not v80[k2] then
								v74 = false
							end
						end

						for k2 in pairs(v80) do
							if not v79[k2] then
								v74 = false
							end
						end
					elseif v77 ~= v78 then
						v74 = false
					end
				end

				if v74 then
					return k
				end
			end

			return "Custom"
		end
	end

	v29 = function(p11, p12)
		local v83 = t11[p11]
		local v84 = t14[p11]
		local v85
		local v86

		if type(p12) == "number" then
			v85 = p12
			v86 = p12
		elseif type(p12) == "table" then
			v85 = tonumber(p12.Min)
			v86 = tonumber(p12.Max)
		end

		local v87 = 10 ^ v83[3]
		local v88 = math.clamp(math.floor((v85 or v84.Min) * v87 + 0.5) / v87, v83[1], v83[2])
		local v89 = math.clamp(math.floor((v86 or v84.Max) * v87 + 0.5) / v87, v83[1], v83[2])

		if v89 < v88 then
			local v90 = v88

			v88 = v89
			v89 = v90
		end

		return {
			Min = v88,
			Max = v89
		}
	end

	do
		local s1 = ""

		local function v92()
			if not writefile then
				return false
			end

			local t27 = {}

			for _, v in ipairs(t21) do
				if t12[v] ~= nil then
					t27[v] = t12[v]
				end
			end

			local ok, result = pcall(HttpService.JSONEncode, HttpService, t27)

			if ok and result ~= s1 then
				s1 = result

				local function v98()
					writefile("barrage_cameramantowerdefense.json", HttpService:JSONEncode({
						version = "4.0",
						timestamp = os.time(),
						settings = t27
					}))
				end

				return pcall(v98)
			end

			return ok
		end

		v30 = function()
			if not readfile then
				return false
			end

			local ok, result = pcall(function()
				return HttpService:JSONDecode(readfile("barrage_cameramantowerdefense.json"))
			end)

			if not ok or type(result) ~= "table" or type(result.settings) ~= "table" then
				return false
			end

			local settings = result.settings

			if settings.CoverageFrom == "First" then
				settings.CoverageFrom = "Front"
			end

			if settings.MoneyReserve ~= nil and settings.CashReserve == nil then
				settings.CashReserve = settings.MoneyReserve
			end

			if settings.PlaceMods == true and settings.MatchMods == nil then
				settings.MatchMods = true

				local PlaceModActions = type(settings.PlaceModActions) == "table" and settings.PlaceModActions or {}
				local matchSkips = { "Overlap" }

				if table.find(PlaceModActions, "Place Anywhere") or PlaceModActions["Place Anywhere"] == true then
					matchSkips = {
						"Ground",
						"Overlap",
						"Road"
					}
				end

				settings.MatchSkips = matchSkips
			end

			if settings.PlaceOnPath == true and settings.MatchSkips == nil then
				settings.MatchSkips = { "Road" }
			end

			local t28 = {
				[400] = 1500,
				[1500] = 6000,
				[3000] = 10000
			}

			if t28[tonumber(settings.EspSpotLimit) or 0] then
				settings.EspSpotLimit = t28[tonumber(settings.EspSpotLimit)]
			end

			if settings.UseSavedPositions == nil and settings.PlaceMode == "Set Positions" then
				settings.UseSavedPositions = true
			end

			settings.PlaceMode = settings.UseSavedPositions == true and "Set Positions" or "Smart Deploy"

			if settings.EspArea ~= nil and settings.EspGround == nil then
				settings.EspGround = settings.EspArea
			end

			if settings.EspNoBuild ~= nil and settings.EspPath == nil then
				settings.EspPath = settings.EspNoBuild
			end

			if type(settings.Positions) == "table" then
				local positions = {}
				local PickActive = type(settings.PickActive) == "table" and settings.PickActive or {}

				for k, position in pairs(settings.Positions) do
					if type(k) == "string" and type(position) == "table" then
						local match, v110 = k:match("^(.-)#(.+)$")

						if match then
							if next(position) ~= nil and (positions[match] == nil or PickActive[match] == v110) then
								positions[match] = position
							end
						elseif positions[k] == nil then
							positions[k] = position
						end
					end
				end

				settings.Positions = positions
			end

			for _, v in ipairs({
				"MoneyReserve",
				"PlaceMods",
				"PlaceModActions",
				"PlaceOnPath",
				"EspArea",
				"EspNoBuild",
				"PlacePreset",
				"DeployStrategy",
				"PriorityOrder",
				"DeployPriority",
				"UpgradeOrder",
				"UpgradeMax",
				"MacroPreset",
				"MacroPicks",
				"PickActive",
				"WalkPreset",
				"TargetMode",
				"TargetBossFirst",
				"UnitTargets",
				"AssistPlaceAt",
				"AssistUpgrade"
			}) do
				local v113 = v .. "Keybind"

				settings[v] = nil
				settings[v113] = nil
			end

			for k, setting in pairs(settings) do
				if t11[k] then
					t12[k] = v29(k, setting)
				elseif t12[k] ~= nil and type(setting) == type(t12[k]) then
					t12[k] = setting
				end
			end

			if t12.MoveMode ~= "Teleport" and t12.MoveMode ~= "Tween" and t12.MoveMode ~= "Walk" then
				t12.MoveMode = "Teleport"
			end

			if not table.find(t6, t12.CoverageFrom) then
				t12.CoverageFrom = t14.CoverageFrom
			end

			t12.DeployCoverage = math.clamp(math.floor((tonumber(t12.DeployCoverage) or 100) + 0.5), 10, 100)

			if t12.SkipWhen ~= "Always" and t12.SkipWhen ~= "Base Untouched" then
				t12.SkipWhen = t14.SkipWhen
			end

			if t12.SummonAmount ~= "Smart" and t12.SummonAmount ~= "Single" and t12.SummonAmount ~= "Ten" then
				t12.SummonAmount = t14.SummonAmount
			end

			if t12.JoinParty ~= "Solo" and t12.JoinParty ~= "Any Free" then
				t12.JoinParty = t14.JoinParty
			end

			if not table.find({
				"Every Round",
				"Losses Only",
				"Summaries Only",
				"Wins Only"
			}, t12.HookMatchSend) then
				t12.HookMatchSend = t14.HookMatchSend
			end

			if not table.find({
				"Lobby",
				"Play Again"
			}, t12.EndAction) then
				t12.EndAction = t14.EndAction
			end

			if not table.find({
				"1x",
				"1.5x",
				"2x"
			}, t12.GameSpeed) then
				t12.GameSpeed = t14.GameSpeed
			end

			if not table.find({
				"Stay In Lobby",
				"Close Game"
			}, t12.StopAction) then
				t12.StopAction = t14.StopAction
			end

			if type(t12.EquipTeam) ~= "table" then
				t12.EquipTeam = {}
			end

			if not table.find({
				"Always",
				"When Unfocused"
			}, t12.BlackScreenWhen) then
				t12.BlackScreenWhen = t14.BlackScreenWhen
			end

			if t12.HookSummonRarity ~= "Every Pull" then
				if not tostring(t12.HookSummonRarity):find(" And Above$") then
					t12.HookSummonRarity = t14.HookSummonRarity
				end
			end

			if not table.find({
				"Payback",
				"Farms First",
				"Never"
			}, t12.FarmUpgradeMode) then
				t12.FarmUpgradeMode = t14.FarmUpgradeMode
			end

			if not table.find({
				"Off",
				"Host",
				"Alt"
			}, t12.PartyRole) then
				t12.PartyRole = t14.PartyRole
			end

			for _, v in ipairs({
				"PartyAltNames",
				"PartyHostName",
				"HostServerId"
			}) do
				if type(t12[v]) ~= "string" then
					t12[v] = t14[v]
				end
			end

			if type(t12.SmartTargetRules) == "table" then
				local t29 = {
					["Boss In Range: Strongest"] = "Boss In Range: Strong",
					["Low Health Swarm: Weakest"] = "Low Health Swarm: Weak"
				}
				local smartTargetRules = {}

				for _, smartTargetRule in ipairs(t12.SmartTargetRules) do
					local v122 = t29[smartTargetRule] or smartTargetRule

					if table.find(t1.TARGET_RULES, v122) and not table.find(smartTargetRules, v122) then
						smartTargetRules[#smartTargetRules + 1] = v122
					end
				end

				t12.SmartTargetRules = smartTargetRules
			end

			for i = 1, 5 do
				if not (t12["SlotTarget" .. i] == "Smart" or table.find(t20, t12["SlotTarget" .. i])) then
					t12["SlotTarget" .. i] = "Smart"
				end

				if not table.find(t13, t12["SlotAbility" .. i]) then
					t12["SlotAbility" .. i] = t14["SlotAbility" .. i]
				end

				local v124 = t12["SlotLimit" .. i]
				local v125 = t12["SlotUpgPri" .. i]

				if v124 ~= "Game Limit" and (not tonumber(v124) or not (tonumber(v124) >= 1) or not (tonumber(v124) <= 15)) then
					t12["SlotLimit" .. i] = t14["SlotLimit" .. i]
				end

				if v125 ~= "Skip" and (not tonumber(v125) or not (tonumber(v125) >= 1) or not (tonumber(v125) <= 5)) then
					t12["SlotUpgPri" .. i] = t14["SlotUpgPri" .. i]
				end
			end

			t12.MacroRecord = false

			for k, preset in pairs(t1.PRESETS) do
				if settings[k] == nil or not (t12[k] == "Custom" or preset.values[t12[k]]) then
					t12[k] = t1._presetFor(k)
				end
			end

			return true
		end
		t1.State = {
			data = {
				codes = {},
				streak = 0,
				losses = 0,
				mode = nil,
				settings = {}
			}
		}
		t1.State.load = function()
			if not readfile then
				return
			end

			local ok, result = pcall(function()
				return HttpService:JSONDecode(readfile("barrage_cameramantowerdefense_state.json"))
			end)

			if ok then
				if type(result) == "table" then
					t1.State.data.codes = type(result.codes) == "table" and result.codes or {}
					t1.State.data.streak = tonumber(result.streak) or 0
					t1.State.data.losses = tonumber(result.losses) or 0
					t1.State.data.mode = type(result.mode) == "string" and result.mode or nil
					t1.State.data.settings = type(result.settings) == "table" and result.settings or {}
				end
			end
		end
		t1.State.save = function()
			if not writefile then
				return
			end

			pcall(function()
				writefile("barrage_cameramantowerdefense_state.json", HttpService:JSONEncode(t1.State.data))
			end)
		end
		t1.ICON = "rbxthumb://type=AvatarHeadShot&id=583572860&w=420&h=420"
		t1.DISCORD = "https://discord.gg/nXPZeBPTdA"
		t1.Hub = nil
		t1.Notify = nil
		t1.Win = nil
		t1.CfgMgr = nil
		t1.Running = true
		t1.Generation = 0
		t1.Conns = {}
		t1._ctl = {}
		t1._rng = Random.new()
		t1._shutdown = function()
			if not t1.Running then
				return
			end

			pcall(v92)
			t1.Running = false
			t1.Generation += 1

			if t1._events then
				pcall(function()
					t1._events:Fire("shutdown")
				end)
			end

			for _, conn in ipairs(t1.Conns) do
				pcall(function()
					conn:Disconnect()
				end)
			end

			table.clear(t1.Conns)

			local _cleanups = t1._cleanups or {}

			for _, _cleanup in ipairs(_cleanups) do
				pcall(_cleanup)
			end

			if t1.Move then
				pcall(t1.Move.stop)
			end

			for _, v in ipairs({
				t1._charConns,
				t1._matchConns,
				t1._lobbyConns
			}) do
				pcall(t1._drop, v)
			end

			if t1._dropReplica then
				pcall(t1._dropReplica)
			end

			if t1.Walk then
				pcall(t1.Walk.clear)
			end

			if t1.Esp then
				pcall(t1.Esp.clear)
			end

			if t1.Pick then
				pcall(t1.Pick.cancel)
			end

			if t1._moveEnd then
				pcall(function()
					t1._moveEnd:Destroy()
				end)
			end

			pcall(function()
				if t1.Hub then
					if type(t1.Hub.Destroy) == "function" then
						t1.Hub:Destroy()
					end
				end
			end)

			if shared._barrageCameramanTowerDefenseShutdown == t1._shutdown then
				shared._barrageCameramanTowerDefenseShutdown = nil
			end
		end
		shared._barrageCameramanTowerDefenseShutdown = t1._shutdown
		t1._cleanups = {}
		t1._saveQueued = false
		t1._saveSoon = function()
			if t1._saveQueued then
				return
			end

			t1._saveQueued = true
			task.delay(1, function()
				t1._saveQueued = false
				pcall(v92)
			end)
		end
	end

	do
		t1._conn = function(p13, p14, p15)
			local connection = p13:Connect(p14)
			local Conns = p15 or t1.Conns

			Conns[#Conns + 1] = connection

			return connection
		end
	end

	t1._drop = function(p16)
		for _, v in ipairs(p16) do
			pcall(function()
				v:Disconnect()
			end)
		end

		table.clear(p16)
	end
	t1._ids = setmetatable({}, {
		__mode = "k"
	})
	t1._idN = 0
	t1._key = function(p17)
		local _idN = t1._ids[p17]

		if not _idN then
			t1._idN += 1
			_idN = t1._idN
			t1._ids[p17] = _idN
		end

		return _idN
	end
	t1._multiList = function(p18, p19)
		if type(p18) ~= "table" then
			return p19
		end

		local t30 = {}

		for k, v in pairs(p18) do
			if type(k) == "string" then
				if v then
					t30[#t30 + 1] = k
				end

				continue
			end

			if type(v) ~= "string" then
				return p19
			end

			t30[#t30 + 1] = v
		end

		table.sort(t30)

		return t30
	end
	t1._set = function(p20)
		local t31 = {}

		if type(p20) == "table" then
			for _, v in ipairs(p20) do
				t31[v] = true
			end
		end

		return t31
	end
	t1._listHas = function(p21, p22)
		if type(p21) ~= "table" then
			return false
		end

		for _, v in ipairs(p21) do
			if v == p22 then
				return true
			end
		end

		return p21[p22] == true
	end
	t1._has = function(p23, p24)
		if type(p23) == "string" then
			p23 = t12[p23]
		end

		return t1._listHas(p23, p24)
	end
	t1._adopt = function(p25, p26, p27)
		local v150 = t1._set(t12[p26])
		local v151 = false

		for _, v in ipairs(p27) do
			if not v150[v] then
				t12[p26][#t12[p26] + 1] = v

				if not t1._listHas(t12[p25], v) then
					t12[p25][#t12[p25] + 1] = v
				end

				v151 = true
			end
		end

		if v151 then
			t1._saveSoon()
		end

		return v151
	end
	t1._seed = function(p28, p29)
		local v154 = table.clone(p29 or {})
		local v155 = t12[p28]
		local v156 = type(v155) == "table" and v155 or { v155 }

		for _, v in ipairs(v156) do
			if type(v) == "string" and not table.find(v154, v) then
				v154[#v154 + 1] = v
			end
		end

		return v154
	end
	t1._refill = function(p30, p31, p32)
		if not p30 then
			return
		end

		t1._refreshing = true
		pcall(function()
			p30:SetValues(t1._sorted(p32))
		end)

		if t1._setControl then
			t1._setControl(p31, t12[p31])
		end

		t1._refreshing = false
	end
	t1._fmt = function(p33)
		local v159 = math.floor(tonumber(p33) or 0)

		return (v159 < 0 and "-" or "") .. tostring(math.abs(v159)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end
	t1._n = function(p34, p35)
		local v160 = tonumber(p34) or p35

		return v160 or 0
	end
	t1._flat = function(p36)
		return Vector3.new(p36.X, 0, p36.Z)
	end

	local t32 = {
		{
			1e33,
			"De"
		},
		{
			1e30,
			"No"
		},
		{
			1e27,
			"Oc"
		},
		{
			1e24,
			"Sp"
		},
		{
			1e21,
			"Sx"
		},
		{
			1e18,
			"Qi"
		},
		{
			1e15,
			"Qa"
		},
		{
			1e12,
			"T"
		},
		{
			1e9,
			"B"
		},
		{
			1000000,
			"M"
		},
		{
			1000,
			"K"
		}
	}

	t1._num = function(p37)
		local v162 = tonumber(p37) or 0
		local v163 = math.abs(v162)

		for _, v in ipairs(t32) do
			if v[1] <= v163 then
				return (("%.1f%s"):format(v162 / v[1], v[2]):gsub("%.0(%a+)$", "%1"))
			end
		end

		return tostring(math.floor(v162 * 10 + 0.5) / 10)
	end
	t1._numOf = function(p38)
		if type(p38) == "number" then
			return p38
		end

		if type(p38) ~= "string" then
			return nil
		end

		local v166 = p38:gsub("[,%s]", "")

		return tonumber(v166)
	end
	t1._now = function()
		return workspace:GetServerTimeNow()
	end
	t1._roll = function(p39, p40)
		if type(p39) ~= "table" then
			return tonumber(p39) or 0
		end

		local v167 = tonumber(p39.Min) or 0
		local v168 = tonumber(p39.Max) or 0

		if v168 <= v167 then
			return v167
		end

		if p40 then
			return t1._rng:NextInteger(math.ceil(v167), math.floor(v168))
		end

		return t1._rng:NextNumber(v167, v168)
	end
	t1._label = function(p41)
		return (tostring(p41 or ""):gsub("_", " "))
	end
	t1._await = function(p42, p43, p44)
		if not p42 then
			return nil
		end

		local v169 = coroutine.running()
		local u170 = false
		local u171
		local connection

		local function v173(p45)
			if u170 then
				return
			end

			u170 = true
			u171 = p45

			if connection then
				connection:Disconnect()
			end

			task.spawn(v169)
		end

		connection = p42:Connect(function(...)
			if not t1.Running then
				return v173(nil)
			end

			local ok, result = pcall(p43, ...)

			if ok and result ~= nil and result ~= false then
				v173(result)
			end
		end)
		task.delay(p44 or 6, function()
			v173(nil)
		end)
		coroutine.yield()

		return u171
	end
	t1._events = Instance.new("BindableEvent")

	do
		t1._awaitEvent = function(p46, p47, p48)
			if p47() then
				return true
			end

			if t1._await(t1._events.Event, function(p49)
				return p49 == p46 and p47()
			end, p48) == true then
				return true
			end

			local v176 = p47() and true or false

			return v176
		end
	end

	t1._signal = function(p50, ...)
		t1._events:Fire(p50, ...)
	end
	t1._display = function(p51)
		if type(p51) == "string" then
			return (p51:gsub("^[Ss]ummer%s*%d*%s+[Ee]vent!?", "Summer Hunt", 1))
		end

		return p51
	end
	t1._title = function(p52)
		local v177 = tostring(p52 or ""):gsub("(%l)(%u)", "%1 %2"):gsub("_", " ")
		local _display = t1._display
		local v179 = v177:gsub("(%f[%w]%l)", string.upper)

		return _display(v179)
	end
	t1.mods = function()
		local ok, result = pcall(function()
			return getrenv and getrenv().shared
		end)
		local Modules = ok and type(result) == "table" and result.Modules

		if type(Modules) ~= "table" and type(shared) == "table" then
			Modules = shared.Modules
		end

		local v183 = type(Modules) == "table" and Modules or {}

		return v183
	end
	t1.M = {}
	t1._modRetry = {}

	do
		t1.mod = function(p53, p54)
			local v184 = t1.mods()[p53]

			if type(v184) == "table" then
				return v184
			end

			local v185 = t1.M[p53]

			if v185 ~= nil then
				return v185
			end

			if p54 then
				local v186 = t1._modRetry[p53] or 0

				if not (os.clock() < v186) then
					local v187 = ReplicatedStorage

					for match in p54:gmatch("[^%.]+") do
						v187 = v187 and v187:FindFirstChild(match)
					end

					if v187 then
						if v187:IsA("ModuleScript") then
							local ok, result = pcall(require, v187)

							t1._restoreIdentity()

							if ok and type(result) == "table" then
								t1.M[p53] = result

								return result
							end

							t1._modRetry[p53] = os.clock() + 5

							return nil
						end
					end

					t1._modRetry[p53] = os.clock() + 5

					return nil
				end
			end

			return nil
		end
	end

	t1.gcall = function(p55, ...)
		if type(p55) ~= "function" then
			return nil
		end

		local v191 = table.pack(pcall(p55, ...))

		t1._restoreIdentity()

		if v191[1] then
			return table.unpack(v191, 2, v191.n)
		end

		return nil
	end
	t1.Cfg = function()
		return t1.mod("Config", "ModuleLoader.Configs.Config")
	end

	do
		t1.Modes = function()
			return t1.mod("Modes", "ModuleLoader.Shared.Modes")
		end
	end

	t1.towerCfg = function(p56)
		local v192 = t1.Cfg()
		local v193 = v192

		v193 = v193 and type(v192.Towers) == "table" and v192.Towers[p56]

		return type(v193) == "table" and v193 or nil
	end
	t1.enemyCfg = function(p57)
		local v194 = t1.Cfg()
		local v195 = v194 and type(v194.Enemies) == "table" and v194.Enemies[p57]

		return type(v195) == "table" and v195 or nil
	end

	do
		t1.gameSettings = function()
			local v196 = t1.Cfg()

			return v196 and type(v196.GameSettings) == "table" and v196.GameSettings or {}
		end
	end

	do
		t1._ownReplica = function(p58)
			if type(p58) == "table" then
				if type(p58.Tags) == "table" then
					if p58.Token == "ArchitectData" then
						return p58.Tags[1] == LocalPlayer.UserId
					end

					return p58.Token == "Replication" and p58.Tags.UserId == LocalPlayer.UserId
				end
			end

			return false
		end
	end

	do
		t1.replica = function()
			local _replica = t1._replica

			if _replica and (type(_replica.IsActive) ~= "function" or t1.gcall(_replica.IsActive, _replica)) then
				return _replica
			end

			t1._replica = nil

			local _replicaMiss = t1._replicaMiss or 0

			if os.clock() < _replicaMiss then
				return nil
			end

			local ReplicaClient = t1.mods().ReplicaClient
			local v200 = ReplicaClient and t1.gcall(ReplicaClient.Test)
			local Replicas = type(v200) == "table" and type(v200.Replicas) == "table" and v200.Replicas or {}

			for _, Replica in pairs(Replicas) do
				if t1._ownReplica(Replica) and t1.gcall(Replica.IsActive, Replica) then
					t1._replica = Replica

					return Replica
				end
			end

			if not ReplicaClient and filtergc then
				if (t1._replicaScans or 0) < 3 then
					if (t1._replicaScanAt or 0) < os.clock() then
						local _replicaScans = t1._replicaScans or 0
						local replicaScanAt = os.clock() + 10

						t1._replicaScans = _replicaScans + 1
						t1._replicaScanAt = replicaScanAt
						task.spawn(function()
							local v206

							if filtergc then
								v206 = t1.gcall(filtergc, "table", {
									Keys = {
										"Token",
										"Tags",
										"Data"
									}
								})
							end

							local v207 = type(v206) == "table" and v206 or {}

							for i, v in ipairs(v207) do
								if type(v) == "table" and type(rawget(v, "Token")) == "string" and type(rawget(v, "Tags")) == "table" and type(rawget(v, "Data")) == "table" and t1._ownReplica(v) then
									local Slots = t1.Slots

									t1._replica = v
									t1._replicaMiss = nil
									Slots.cache = nil
									t1._wake("lobbydata")

									return
								end

								if i % 20000 == 0 then
									task.wait()
								end

								if t1.Running then
									continue
								end

								return
							end
						end)
					end
				end
			end

			t1._replicaMiss = os.clock() + 3

			return nil
		end
	end

	do
		t1.data = function()
			local v211 = t1.replica()

			return v211 and type(v211.Data) == "table" and v211.Data or nil
		end
	end

	do
		local t33 = {
			TowerAdd = 0.3,
			TowerUpgrade = 0.25,
			TowerSell = 0.25,
			TowerTarget = 0.25,
			TowerAbility = 0.3,
			WaveSkip = 0.6,
			ModeVote = 0.6,
			OnLeave = 3.2,
			PlayAgain = 2,
			ElevatorStart = 3.2,
			ElevatorEnter = 0.6,
			ElevatorLeave = 0.6,
			ElevatorSetModifiers = 0.6,
			SummonTowers = 2.1,
			AutosellEnable = 0.35,
			EquipPart = 0.4,
			SellPart = 0.85,
			RedeemCode = 1.1,
			UseBoost = 0.6,
			OpenCrate = 2.1,
			OpenGamepass = 1.1,
			UpdateSetting = 0.35,
			ChangeSpeed = 0.6,
			ClaimTier = 0.5,
			CollectPassQuest = 0.6,
			CollectQuest = 0.6,
			BuyCrate = 1.1,
			GetSummonSet = 0.6,
			RequestQuestData = 1.1,
			ClaimRankReward = 0.6,
			ModifierVote = 0.35,
			MatchJoinQueue = 1.2,
			MatchLeaveQueue = 1.2,
			MatchStatus = 0.6,
			Medal = 1.1
		}
		local t34 = {
			TowerAdd = true,
			TowerUpgrade = true,
			TowerSell = true,
			TowerTarget = true,
			TowerAbility = true,
			OnLeave = true,
			ChangeSpeed = true,
			SellPart = true,
			EquipPart = true,
			OpenCrate = true,
			SummonTowers = true,
			BuyCrate = true,
			OpenGamepass = true,
			RedeemCode = true,
			AutosellEnable = true,
			UpdateSetting = true,
			ClaimTier = true,
			CollectQuest = true,
			CollectPassQuest = true,
			UseBoost = true,
			RequestQuestData = true
		}

		t15 = {
			play = "AutoPlay",
			upgrade = "AutoUpgrade",
			sell = "AutoSell",
			skip = "AutoSkip",
			matchend = "AutoMatchEnd",
			target = "AutoTarget",
			vote = "AutoVote",
			queue = "AutoJoin",
			summon = "AutoSummon",
			autosell = "AutoAutosell",
			equip = "AutoEquip",
			unitsell = "AutoUnitSell",
			modvote = "AutoModVote",
			codes = "AutoCodes",
			boosts = "AutoBoosts",
			crates = "AutoCrates",
			passitems = "AutoPassItems",
			settings = "GameSettings",
			assist = "DeployAssist",
			speed = "AutoSpeed",
			quests = "AutoQuests",
			passtiers = "AutoPassTiers",
			passquests = "AutoPassQuests",
			crateshop = "AutoCrateShop",
			autowalk = "AutoWalk",
			ability = "AutoAbility",
			ranks = "AutoRanks",
			medal = "AutoMedal",
			eleave = "EmergencyLeave",
			special = "AutoSpecialQuests",
			rng = "AutoRngRoll"
		}
		t1._owners = setmetatable({}, {
			__mode = "k"
		})
		t1._backOwners = t1._owners
		t1._gateOpen = {}
		t1._manualPass = {}
		t1._remoteNext = {}
		t1._globalNext = 0
		t1._gate = function(p59)
			local now = os.clock()
			local v215 = math.max(now, t1._remoteNext[p59] or 0, t1._globalNext)

			t1._remoteNext[p59] = v215 + math.max(0.1, t33[p59] or 0.25)
			t1._globalNext = v215 + 0.02

			if now < v215 then
				task.wait(v215 - now)
			end

			if not t1.Running then
				return false
			end

			local v216 = t1._owners[coroutine.running()]
			local v217 = v216 and t15[v216]

			return v217 == nil or v216 == "macro" or t12[v217] == true or t1._gateOpen[v216] == true or t1._manualPass[v216] == true
		end
		t1._seamMissing = function(p60)
			local seam = t1._owners[coroutine.running()]
			local _ownerOf = seam and t1._ownerOf

			_ownerOf = _ownerOf and t1._ownerOf[seam]

			if _ownerOf and t1.Running then
				_ownerOf.text = "[NO SEAM] " .. p60
				t1._alarm(seam, 10, "seam:" .. seam)
				t1._wake("status")
			end
		end
		t1._reply = function(p61, p62, p63)
			if not p61 then
				return false, tostring(p62 or "Timeout")
			end

			if p62 ~= nil then
				if p62 ~= false then
					return true, p62, p63
				end
			end

			return false, tostring(p63 or "Refused")
		end
		t1.R = {}
		t1.net = function(p64)
			local v220 = t1.R[p64]

			if v220 and v220.Parent then
				return v220
			end

			local v221 = t1._at(ReplicatedStorage, "ModuleLoader.Shared.Network")
			local children = v221 and v221:GetChildren() or {}

			for _, child in ipairs(children) do
				local v225 = child:FindFirstChild(p64)

				if v225 and (v225:IsA("RemoteEvent") or v225:IsA("RemoteFunction")) then
					t1.R[p64] = v225

					return v225
				end
			end

			t1.R[p64] = nil

			return nil
		end
		t1.fire = function(p65, ...)
			local v226 = t1.net(p65)

			if not v226 or not v226:IsA("RemoteEvent") then
				return false
			end

			if t34[p65] then
				t1._econWait()
			end

			if not t1._gate(p65) then
				return false
			end

			if t34[p65] then
				t1._econWait()
			end

			local ok = pcall(v226.FireServer, v226, ...)

			t1._restoreIdentity()

			if ok and t1.AutoWalk and t1.AutoWalk.KIND[p65] then
				pcall(t1.AutoWalk.note, p65, ...)
			end

			return ok
		end
		t1._invokeRaw = function(p66, p67, ...)
			local v228 = table.pack(...)
			local v229 = coroutine.running()
			local n1 = 0
			local u231

			local function v232(p68)
				if n1 == 2 then
					return
				end

				local v233 = n1 == 1

				n1 = 2
				u231 = p68

				if v233 then
					task.spawn(v229)
				end
			end

			task.spawn(function()
				v232(table.pack(pcall(p66.InvokeServer, p66, table.unpack(v228, 1, v228.n))))
			end)
			task.delay(p67 or 8, function()
				v232(nil)
			end)

			if n1 ~= 2 then
				n1 = 1
				coroutine.yield()
			end

			t1._restoreIdentity()

			if u231 and u231[1] then
				return true, table.unpack(u231, 2, u231.n)
			end

			return false
		end
		t1._busy = function(p69)
			return p69 == "BUSY" or p69 == "RATE_LIMIT" or p69 == "SERVER_BUSY"
		end
		t1._econ = {
			thread = nil,
			at = 0
		}

		local function v234()
			local _econ = t1._econ
			local v236 = _econ.thread ~= nil and _econ.thread ~= coroutine.running()

			return v236 and coroutine.status(_econ.thread) ~= "dead" and os.clock() - _econ.at < 10
		end

		t1._econWait = function()
			while v234() do
				t1._awaitEvent("econ", function()
					return not v234()
				end, 10)
			end
		end
		t1.invoke = function(p70, p71, ...)
			local v237 = t1.net(p70)

			if v237 then
				if v237:IsA("RemoteFunction") then
					local v238 = t34[p70]
					local v239

					for i = 1, 3 do
						if v238 then
							t1._econWait()
						end

						if not t1._gate(p70) then
							return false
						end

						if v238 then
							t1._econWait()

							local _econ = t1._econ
							local _econ2 = t1._econ
							local v243 = coroutine.running()
							local now = os.clock()

							_econ.thread = v243
							_econ2.at = now
						end

						v239 = table.pack(t1._invokeRaw(v237, p71 or 8, ...))

						if v238 and t1._econ.thread == coroutine.running() then
							t1._econ.thread = nil
							t1._signal("econ")
						end

						if not v239[1] or v239[2] ~= false or not t1._busy(v239[3]) then
							break
						end
					end

					return table.unpack(v239, 1, v239.n)
				end
			end

			return false
		end
	end

	t1._back = {}
	t1._backN = 0
	t1._backoff = function(p72, p73)
		t1._backN += 1

		if t1._backN % 200 == 0 then
			local now = os.clock()

			for k, v in pairs(t1._back) do
				if v < now then
					t1._back[k] = nil
				end
			end
		end

		t1._back[p72] = os.clock() + p73

		local v248 = t1._owners[coroutine.running()]

		if v248 and t1._alarm then
			t1._alarm(v248, p73 + 0.25, "back:" .. p72)
		end
	end
	t1._backed = function(p74)
		local v249 = t1._back[p74]

		if v249 == nil then
			return false
		end

		if os.clock() < v249 then
			return true
		end

		t1._back[p74] = nil

		return false
	end
	t1._gui = function(p75)
		local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

		return PlayerGui and PlayerGui:FindFirstChild(p75)
	end
	t1._at = function(p76, p77)
		for match in p77:gmatch("[^%.]+") do
			p76 = p76 and p76:FindFirstChild(match)
		end

		return p76
	end
	t1._json = function(p78)
		if type(p78) == "string" then
			if p78 ~= "" then
				local ok, result = pcall(HttpService.JSONDecode, HttpService, p78)

				return ok and type(result) == "table" and result or nil
			end
		end

		return nil
	end
	t1._statusRegistry = {}
	t1.registerStatus = function(p79)
		t1._statusRegistry[#t1._statusRegistry + 1] = p79
	end
	t1._timers = {}

	do
		local t35 = {
			deploy = "AutoPlay",
			upgrade = "AutoUpgrade",
			target = "AutoTarget",
			ability = "AutoAbility",
			sell = "AutoSell",
			skip = "AutoSkip",
			matchend = "AutoMatchEnd",
			vote = "AutoVote",
			modvote = "AutoModVote",
			speed = "AutoSpeed",
			queue = "AutoJoin",
			summon = "AutoSummon",
			autosell = "AutoAutosell",
			equip = "AutoEquip",
			unitsell = "AutoUnitSell",
			codes = "AutoCodes",
			quests = "AutoQuests",
			boosts = "AutoBoosts",
			crates = "AutoCrates",
			passitems = "AutoPassItems",
			passtiers = "AutoPassTiers",
			passquests = "AutoPassQuests",
			crateshop = "AutoCrateShop",
			settings = "GameSettings",
			ranks = "AutoRanks",
			special = "AutoSpecialQuests",
			rng = "AutoRngRoll",
			macro = "MacroRun",
			assist = "DeployAssist",
			autowalk = "AutoWalk",
			eleave = function()
				return t12.EmergencyLeave or t12.LeaveAtWave
			end
		}

		t1._timerTag = function(p80)
			return "{timer:" .. p80 .. "}"
		end
		t1._timer = function(p81, p82)
			t1._timers[p81] = os.clock() + math.max(0, tonumber(p82) or 0)
			t1._startTicker()
		end
		t1._pause = function(p83, p84, p85, p86, p87)
			if type(p84) == "table" then
				local v255 = t1._n(p84.Min)
				local v256 = t1._n(p84.Max)

				p84 = v256 > v255 and v255 + math.random() * (v256 - v255) or v255
			end

			local v257 = tonumber(p84) or 0

			if v257 <= 0 then
				return true
			end

			t1._timer(p83, v257)
			p85.text = "[" .. (p87 or "DELAY") .. "] " .. p86 .. " | " .. t1._timerTag(p83)
			t1._wake("status")

			local v258 = t35[p83]

			local function v259()
				if type(v258) == "function" then
					return not v258()
				end

				return v258 ~= nil and t12[v258] ~= true
			end

			local Generation = t1.Generation
			local v261 = os.clock() + v257

			repeat
				if not (os.clock() < v261) then
					local v262 = t1.Running and not v259()

					return v262
				end

				task.wait(math.min(0.5, v261 - os.clock()))
			until not t1.Running or Generation ~= t1.Generation or v259()

			return false
		end
		t1._startTicker = function(p88)
			if t1._ticking then
				return
			end

			t1._ticking = true

			local Generation = t1.Generation

			task.delay(p88 or 1, function()
				t1._ticking = false

				if not t1.Running or Generation ~= t1.Generation then
					return
				end

				local now = os.clock()
				local v265

				for k, timer in pairs(t1._timers) do
					local v268 = t35[k]
					local v269 = type(v268) == "function" and not v268() or type(v268) == "string" and not t12[v268]

					if timer <= now or v269 then
						t1._timers[k] = nil
					else
						v265 = math.min(v265 or math.huge, timer - now)
					end
				end

				t1._wake("status")

				if v265 then
					t1._startTicker(v265 > 150 and 30 or 1)
				end
			end)
		end
	end

	t1._liveStatusText = function(p89)
		local v270 = tostring(p89 or "[WAITING]"):gsub("{timer:([%w_]+)}", function(p90)
			local v271 = math.max(0, math.ceil((t1._timers[p90] or 0) - os.clock()))

			if v271 >= 3600 then
				return math.floor(v271 / 3600) .. "h " .. math.floor(v271 % 3600 / 60) .. "m"
			end

			if v271 >= 150 then
				return math.ceil(v271 / 60) .. "m"
			end

			if v271 >= 60 then
				return math.floor(v271 / 60) .. "m " .. v271 % 60 .. "s"
			end

			return v271 .. "s"
		end)
		local v272 = v270:gsub("{cash}", function()
			return t1._fmt(t1.Match and t1.Match.cash() or 0)
		end):gsub("^%[IDLE%]", "[WAITING]")

		return (v272:gsub("(%f[%w]%l)", string.upper))
	end

	do
		local function v273(p91, p92)
			if p91._busy then
				if os.clock() - (p91._busyAt or 0) < 5 then
					local _result = p91._result

					if _result then
						return _result[1], _result[2]
					end

					return nil, nil, true
				end

				p91._busy = false

				if p91._co then
					pcall(task.cancel, p91._co)
				end

				p91._co = nil
				t1._note("status:stuck:" .. tostring(p92), "Status line " .. tostring(p92) .. ": its text never finished; re-run.")
			end

			local u275 = false
			local v276 = false
			local gen = (p91._gen or 0) + 1
			local now = os.clock()

			p91._gen = gen
			p91._busy = true
			p91._busyAt = now

			local function v279()
				local ok, result = pcall(p91.live)

				if p91._gen ~= gen then
					return
				end

				u275 = true
				p91._busy = false
				p91._co = nil

				local _result = p91._result

				p91._result = {
					ok,
					result
				}

				if v276 then
					if not _result or _result[1] ~= ok or _result[2] ~= result then
						t1._wakeThrottled("status", 0.25)
					end
				else
					return
				end
			end

			local thread = coroutine.create(v279)
			local v284, v285 = coroutine.resume(thread)

			if not v284 then
				p91._busy = false

				return false, v285
			end

			if u275 then
				return p91._result[1], p91._result[2]
			end

			v276 = true
			p91._co = thread

			local _result = p91._result

			if _result then
				return _result[1], _result[2]
			end

			return nil, nil, true
		end

		t1.syncStatuses = function()
			for i, v in ipairs(t1._statusRegistry) do
				if v.para then
					local ok, result = pcall(v.on)
					local v291 = ok and result
					local idle = v.idle or "[IDLE]"

					if v291 then
						local v293, v294, v295 = v273(v, i)

						if v295 then
							idle = "[WAITING]"
						elseif v293 then
							idle = t1._liveStatusText(v294)
						else
							idle = "[ERROR] " .. tostring(v294):gsub("^.-:%d+: ", "")
						end
					end

					if v._last ~= idle then
						v._last = idle
						pcall(function()
							v.para:SetContent(idle)
						end)
					end

					local lastIcon = ""

					if v291 and v.icon then
						local ok2, result2 = pcall(v.icon)
						local v299 = ok2 and type(result2) == "string" and result2

						lastIcon = v299 or ""
					end

					if v._lastIcon ~= lastIcon then
						v._lastIcon = lastIcon
						pcall(function()
							v.para:SetIcon(lastIcon)
						end)
					end
				end
			end

			if t1.syncBars then
				t1.syncBars()
			end
		end
	end

	t1._resyncStatuses = function()
		for _, v in ipairs(t1._statusRegistry) do
			v._last = nil
			v._lastIcon = nil
		end

		t1.syncStatuses()
	end
	t1._wakeQueued = {}
	t1._ownerOf = {}
	t1._statusAt = 0
	t1._statusLater = false
	t1._wakeHandlers = {
		status = function()
			local now = os.clock()

			if now - t1._statusAt >= 0.1 then
				t1._statusAt = now
				t1.syncStatuses()

				return
			end

			if t1._statusLater then
				return
			end

			t1._statusLater = true

			local Generation = t1.Generation

			task.delay(0.1 - (now - t1._statusAt), function()
				t1._statusLater = false

				if t1.Running and Generation == t1.Generation then
					t1._statusAt = os.clock()
					t1.syncStatuses()
				end
			end)
		end
	}

	do
		local getthreadidentity_ = getthreadidentity or getidentity
		local setthreadidentity_ = setthreadidentity or setidentity

		if type(getthreadidentity_) == "function" then
			pcall(function()
				t1._identity = getthreadidentity_()
			end)
		end

		t1._wakeList = {}
		t1._dispatchQueued = false
		t1._dispatchAt = 0
		t1._wakeDepth = 0
		t1._scheduleWakes = function()
			local now = os.clock()

			t1._dispatchQueued = true
			t1._dispatchAt = now

			local v307 = t1._wakeDepth + 1

			if v307 > 8 then
				task.delay(0, t1._runWakes, 1)
			else
				task.defer(t1._runWakes, v307)
			end
		end
		t1._runWakes = function(p93)
			if type(setthreadidentity_) == "function" then
				if t1._identity ~= nil then
					pcall(setthreadidentity_, t1._identity)
				end
			end

			t1._dispatchQueued = false

			if t1._notes and next(t1._notes) ~= nil then
				task.spawn(t1._flushNotes)
			end

			t1._wakeDepth = tonumber(p93) or 1
			pcall(function()
				local now = os.clock()
				local _wakeList = t1._wakeList

				t1._wakeList = {}

				for i, v in ipairs(_wakeList) do
					if i > 1 and os.clock() - now > 0.05 then
						local v312 = table.move(_wakeList, i, #_wakeList, 1, {})

						table.move(t1._wakeList, 1, #t1._wakeList, #v312 + 1, v312)
						t1._wakeList = v312

						break
					end

					t1._wakeQueued[v] = false

					local v313 = t1._wakeHandlers[v]

					if t1.Running and v313 then
						task.spawn(pcall, v313)
					end
				end
			end)

			if #t1._wakeList > 0 and not t1._dispatchQueued then
				t1._scheduleWakes()
			end

			t1._wakeDepth = 0
		end
	end

	t1._noted = {}
	t1._notes = {}

	do
		t1._note = function(p94, p95)
			if t1._noted[p94] then
				return
			end

			t1._notes[p94] = p95
		end
	end

	do
		t1._flushNotes = function()
			if not t1.Running or not t1.Notify then
				return
			end

			for k, note in pairs(t1._notes) do
				t1._notes[k] = nil

				if pcall(t1.Notify, "Recovered", note, 6) then
					t1._noted[k] = true
				end
			end
		end
	end

	t1._wakeAt = {}
	t1._wake = function(p96)
		local now = os.clock()

		if t1._wakeQueued[p96] then
			if now - (t1._wakeAt[p96] or now) < 2 then
				return
			end
		end

		local v317 = t1._wakeQueued[p96] == true
		local _wakeAt = t1._wakeAt

		t1._wakeQueued[p96] = true
		_wakeAt[p96] = now

		local v319 = t1._dispatchQueued and now - t1._dispatchAt > 2

		if v317 or v319 then
			local wakeList = {}
			local t36 = {}

			for _, v in ipairs(t1._wakeList) do
				if not t36[v] then
					t36[v] = true
					wakeList[#wakeList + 1] = v
				end
			end

			for k, v in pairs(t1._wakeQueued) do
				if v and not t36[k] then
					t36[k] = true
					wakeList[#wakeList + 1] = k
				end
			end

			t1._wakeList = wakeList
			t1._note(v319 and "wake:stuck" or "wake:lost", v319 and "Automation wakes: a scheduled run never ran; rescheduled." or "Automation wakes: a queued wake was dropped; re-queued.")
			t1._dispatchQueued = false

			if not t1._dispatchQueued then
				t1._scheduleWakes()
			end
		else
			t1._wakeList[#t1._wakeList + 1] = p96

			if not t1._dispatchQueued then
				t1._scheduleWakes()
			end
		end
	end
	t1._throttle = {}
	t1._wakeThrottled = function(p97, p98)
		local v326 = t1._throttle[p97] or {}

		t1._throttle[p97] = v326

		local now = os.clock()

		if p98 <= now - (v326.at or 0) then
			v326.at = now
			t1._wake(p97)
		elseif not v326.queued then
			v326.queued = true

			local Generation = t1.Generation

			task.delay(p98 - (now - v326.at), function()
				v326.queued = false
				v326.at = os.clock()

				if t1.Running and Generation == t1.Generation then
					t1._wake(p97)
				end
			end)
		end
	end
	t1._alarms = {}
	t1._alarm = function(p99, p100, p101)
		local Generation = t1.Generation
		local t37 = {}
		local v331 = p101 or p99

		t1._alarms[v331] = t37
		task.delay(math.max(0.2, p100), function()
			if t1._alarms[v331] ~= t37 then
				return
			end

			t1._alarms[v331] = nil

			if t1.Running and Generation == t1.Generation then
				t1._wake(p99)
			end
		end)
	end

	do
		t1._needs = function(p102, p103, p104)
			if type(t12[p102]) == "table" then
				if #t12[p102] > 0 then
					return true
				end
			end

			p104.text = "[WAITING] Awaiting Selection | " .. p103
			p104.due = false
			t1._wake("status")

			return false
		end
	end

	t1._tail = function(p105, p106)
		if p106 then
			if not tostring(p105):find("|", 1, true) then
				return p105 .. " | " .. p106
			end
		end

		return p105
	end
	t1._delayRange = function(p107, p108, p109, p110, p111)
		local v332 = t1._roll(p108)

		if v332 <= 0 then
			return true
		end

		t1._timer(p107, v332)
		p109.text = p110 .. " | " .. t1._timerTag(p107)
		t1._wake("status")

		local Generation = t1.Generation
		local v334 = os.clock() + v332

		if t1.Running and Generation == t1.Generation and os.clock() < v334 then
			while true do
				task.wait(math.min(0.5, v334 - os.clock()))

				if p111 and not t12[p111] then
					return false
				elseif not t1.Running or Generation ~= t1.Generation or not (os.clock() < v334) then
					break
				end
			end
		end

		return t1.Running and Generation == t1.Generation
	end

	local t38 = {
		"Awaiting Match",
		"Awaiting Lobby",
		"Awaiting Results",
		"Awaiting Rotation",
		"Awaiting Merchant",
		"Awaiting Egg",
		"Mode Locked",
		"Awaiting Raid",
		"Awaiting Unlock",
		"Awaiting Level",
		"Awaiting World",
		"Awaiting Portal",
		"Awaiting Mode",
		"Awaiting Dungeon",
		"Awaiting Run",
		"No Base Panel",
		"Awaiting Settings",
		"Mode Off",
		"Awaiting Players",
		"Awaiting Key",
		"Awaiting Event",
		"Awaiting Hunt",
		"Awaiting Spawn",
		"Awaiting Alts",
		"Awaiting Invite",
		"Awaiting Host",
		"Awaiting Fodder",
		"Awaiting Food",
		"Awaiting Units",
		"Awaiting Enemies",
		"Awaiting Abilities"
	}

	t1._evented = function(p112)
		local Ctx = t1.Ctx and t1.Ctx.place()

		if Ctx ~= "LOBBY" and Ctx ~= "MATCH" then
			return true
		end

		for _, v in ipairs(t38) do
			if p112:find(v, 1, true) then
				return true
			end
		end

		return false
	end

	do
		t1._worker = function(p113, p114, p115)
			t1._ownerOf[p113] = p114
			t1._wakeHandlers[p113] = function()
				if p114.running then
					local thread = p114.thread

					if not (os.clock() - (p114.runAt or 0) > 30) or thread and coroutine.status(thread) ~= "dead" then
						p114.pending = true

						return
					end

					p114.running = false
				end

				local now = os.clock()

				p114.running = true
				p114.runAt = now
				p114.thread = nil

				local thread = task.spawn(function()
					t1._owners[coroutine.running()] = p113
					pcall(function()
						repeat
							p114.pending = false
							t1._restoreIdentity()

							local ok, result = pcall(p115, p114)

							t1._restoreIdentity()

							if not ok then
								p114.text = "[ERROR] " .. tostring(result):gsub("^.-:%d+: ", "")
							end
						until not p114.pending or not t1.Running
					end)
					p114.running = false
					p114.thread = nil
					pcall(function()
						local v344 = t15[p113]
						local text = type(p114.text) == "string" and p114.text or ""

						if not t1.Running or v344 and t12[v344] ~= true or not text:find("^%[WAITING%]") and not text:find("^%[UNAVAILABLE%]") and not text:find("^%[ERROR%]") and not text:find("^%[NO SEAM%]") then
							p114._fbText = nil
							p114._fbN = 0

							return
						end

						if t1._evented(text) then
							p114._fbText = nil
							p114._fbN = 0
						else
							local fbN = 0

							if (not t1.Ctx or t1.Ctx.place() ~= "MATCH") and p114._fbText == text then
								fbN = math.min((p114._fbN or 0) + 1, 3)
							end

							p114._fbText = text
							p114._fbN = fbN

							local v347 = "fallback:" .. p113

							t1._alarm(p113, math.min(5 * 2 ^ fbN, 30), v347)
						end
					end)
					t1._wake("status")
				end)

				if p114.running then
					p114.thread = thread
				end
			end
		end
	end

	t1._allWorkers = {}
	t1._wakeAll = function()
		for _, allWorker in ipairs(t1._allWorkers) do
			t1._wake(allWorker)
		end

		t1._wake("status")
		t1._wake("esp")
	end

	do
		t1._hum = function()
			local Character = LocalPlayer.Character

			return Character and Character:FindFirstChildOfClass("Humanoid")
		end
	end

	t1._hrp = function()
		local Character = LocalPlayer.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

		return HumanoidRootPart and HumanoidRootPart:IsA("BasePart") and HumanoidRootPart or nil
	end
	t1._alive = function()
		local v353 = t1._hum()

		return v353 ~= nil and v353.Health > 0 and t1._hrp() ~= nil
	end
	t1._partOf = function(p116)
		if not p116 then
			return nil
		end

		if p116:IsA("BasePart") then
			return p116
		end

		if p116:IsA("Model") then
			return p116.PrimaryPart or p116:FindFirstChildWhichIsA("BasePart", true)
		end

		return p116:FindFirstChildWhichIsA("BasePart", true)
	end
	t1.Lease = {
		RANK = {},
		LABEL = {},
		WANT_TTL = 5,
		HOLD_TTL = 12,
		MIN_HOLD = 3,
		list = {},
		clock = os.clock
	}
	t1.Lease.rank = function(p117)
		return t1.Lease.RANK[p117] or 5
	end
	t1.Lease.new = function(p118)
		local t39 = {
			name = p118,
			owner = nil,
			last = nil,
			since = 0,
			renewed = 0,
			waiting = {},
			retrying = {},
			cleanup = {}
		}

		t1.Lease.list[#t1.Lease.list + 1] = t39

		local function v355(p119)
			if t39.retrying[p119] then
				return
			end

			t39.retrying[p119] = true
			task.delay(1, function()
				t39.retrying[p119] = nil

				if t39.waiting[p119] then
					t1._wake(p119)
				end
			end)
		end
		local function v356(p120)
			local v357 = t39.cleanup[p120]

			if v357 then
				pcall(v357)
			end

			if t39.onRelease then
				pcall(t39.onRelease, p120)
			end
		end

		t39.lease = function(p121)
			local v358 = t1.Lease.clock()
			local v359 = t1.Lease.rank(p121)

			if t39.owner == p121 then
				t39.renewed = v358

				return true
			end

			if t39.owner ~= nil and t1.Lease.HOLD_TTL < v358 - t39.renewed then
				t39.release(t39.owner)
			end

			if t39.owner ~= nil then
				if v359 ~= 1 or t1.Lease.rank(t39.owner) == 1 then
					t39.waiting[p121] = v358
					v355(p121)

					return false
				end

				local owner = t39.owner

				t39.owner = nil
				v356(owner)

				if t39.cancel then
					pcall(t39.cancel)
				end

				t39.waiting[owner] = v358
				v355(owner)
			end

			for k, v in pairs(t39.waiting) do
				local v363 = t1.Lease.rank(k)

				if k == p121 or not (v358 - v < t1.Lease.WANT_TTL) or not (v363 < v359) and (v363 ~= v359 or t39.last ~= p121) then
					continue
				end

				t39.waiting[p121] = v358
				v355(p121)

				return false
			end

			t39.waiting[p121] = nil
			t39.owner = p121
			t39.since = v358
			t39.renewed = v358

			return true
		end

		local s2 = "release"

		local function v365(p122)
			if t39.owner ~= p122 then
				return
			end

			t39.owner = nil
			t39.last = p122
			t39.waiting[p122] = nil
			v356(p122)

			local v366 = t1.Lease.clock()
			local t40 = {}

			for k, v in pairs(t39.waiting) do
				if v366 - v < t1.Lease.WANT_TTL then
					t40[#t40 + 1] = k
				else
					t39.waiting[k] = nil
				end
			end

			task.defer(function()
				for _, v in ipairs(t40) do
					t1._wake(v)
				end
			end)
		end

		t39[s2] = v365
		t39.drop = function(p123)
			t39.waiting[p123] = nil
			t39.release(p123)
		end
		t39.held = function(p124)
			if t39.owner ~= p124 then
				return false
			end

			t39.renewed = t1.Lease.clock()

			return true
		end
		t39.contested = function(p125)
			local v372 = t1.Lease.clock()
			local v373 = t1.Lease.rank(p125)

			for k, v in pairs(t39.waiting) do
				local v376 = t1.Lease.rank(k)

				if k ~= p125 and v372 - v < t1.Lease.WANT_TTL and (v376 < v373 or v376 == v373 and t1.Lease.MIN_HOLD <= v372 - t39.since) then
					return true
				end
			end

			return false
		end
		t39.busyText = function()
			return "[WAITING] Awaiting " .. t39.name .. " | " .. (t1.Lease.LABEL[t39.owner] or "Busy")
		end
		t39.run = function(p126, p127, ...)
			if not t39.lease(p126) then
				return false
			end

			local ok, result = pcall(p127, ...)

			t39.release(p126)

			return ok, result
		end

		return t39
	end
	t1.Lease.all = function(p128, p129, p130, ...)
		for i, v in ipairs(p129) do
			if v.lease(p128) then
				continue
			end

			for i2 = i - 1, 1, -1 do
				p129[i2].release(p128)
			end

			return false
		end

		local ok, result = pcall(p130, ...)

		for i = #p129, 1, -1 do
			p129[i].release(p128)
		end

		return ok, result
	end
	t1.Lease.dropAll = function(p131)
		for _, v in ipairs(t1.Lease.list) do
			v.drop(p131)
		end
	end

	do
		t1._confirm = function(p132, p133)
			local v387 = os.clock() + (p133 or 3)

			while t1.Running and os.clock() < v387 do
				local ok, result = pcall(p132)

				if ok and result then
					return result
				end

				t1._await(t1._events.Event, function()
					return true
				end, math.min(0.25, math.max(0.03, v387 - os.clock())))
			end

			local ok, result = pcall(p132)
			local v392 = ok and result or nil

			return v392
		end
	end

	t1.Move = t1.Lease.new("Movement")
	t1.Move.text = "[READY] Teleport"
	t1.Move.moves = 0
	t1._moveEnd = Instance.new("BindableEvent")
	t1.Move.stop = function()
		local tween = t1.Move.tween

		t1.Move.tween = nil

		if tween then
			pcall(function()
				tween:Cancel()
			end)
		end

		t1._moveEnd:Fire()

		local walkRestore = t1.Move.walkRestore

		t1.Move.walkRestore = nil

		if walkRestore and walkRestore.hum.Parent then
			walkRestore.hum.WalkSpeed = walkRestore.speed
		end
	end
	t1.Move.await = function(p134, p135)
		local v395 = coroutine.running()
		local u396 = false
		local t41 = {}

		local function v398()
			if u396 then
				return
			end

			u396 = true

			for _, v in ipairs(t41) do
				v:Disconnect()
			end

			task.spawn(v395)
		end

		for _, v in ipairs(p135) do
			t41[#t41 + 1] = v:Connect(v398)
		end

		t41[#t41 + 1] = p134.AncestryChanged:Connect(function()
			if not p134:IsDescendantOf(workspace) then
				v398()
			end
		end)
		t41[#t41 + 1] = t1._moveEnd.Event:Connect(v398)
		coroutine.yield()
	end

	do
		t1.Move.tweenTo = function(p136, p137)
			local tween = t1.Move.tween

			t1.Move.tween = nil

			if tween then
				pcall(function()
					tween:Cancel()
				end)
			end

			local tween2 = TweenService:Create(p136, TweenInfo.new(math.max(0.05, (p136.Position - p137.Position).Magnitude / math.max(10, t1._n(t12.TweenSpeed, 150))), Enum.EasingStyle.Linear), {
				CFrame = p137
			})

			t1.Move.tween = tween2
			tween2:Play()
			t1.Move.await(p136, { tween2.Completed })

			if t1.Move.tween == tween2 then
				t1.Move.tween = nil
			end

			pcall(function()
				p136.AssemblyLinearVelocity = Vector3.zero
			end)
		end
	end

	t1.Move.to = function(p138)
		local v405 = t1._hrp()
		local v406 = t1._hum()

		if not v405 or not v406 or not p138 or v405.Anchored then
			return false
		end

		local v407 = p138 + Vector3.new(0, 3, 0)
		local MoveMode = t12.MoveMode

		t1.Move.moves += 1
		t1.Move.text = "[" .. MoveMode:upper() .. "] " .. t1._num(math.floor((v405.Position - v407).Magnitude)) .. " Studs | " .. t1.Move.moves .. " Moves"

		local cFrame = CFrame.new(v407)

		if MoveMode == "Tween" then
			t1.Move.tweenTo(v405, cFrame)
		elseif MoveMode == "Walk" then
			local walkRestore = {
				hum = v406,
				speed = v406.WalkSpeed
			}

			t1.Move.walkRestore = walkRestore
			v406.WalkSpeed = math.max(8, t1._n(t12.WalkSpeed, 50))

			local Generation = t1.Generation

			for i = 1, 8 do
				v406:MoveTo(p138)
				t1.Move.await(v405, {
					v406.MoveToFinished,
					v406.Died
				})

				if not t1.Running or Generation ~= t1.Generation or t1.Move.walkRestore ~= walkRestore or not (v406.Health > 0) or (Vector3.new(v405.Position.X, p138.Y, v405.Position.Z) - p138).Magnitude < 4 then
					break
				end
			end

			if t1.Move.walkRestore == walkRestore then
				t1.Move.walkRestore = nil

				if v406.Parent then
					v406.WalkSpeed = walkRestore.speed
				end
			end

			if t1.Running and v405.Parent and (v405.Position - v407).Magnitude > 8 then
				v405.CFrame = cFrame
				pcall(function()
					v405.AssemblyLinearVelocity = Vector3.zero
				end)
			end
		else
			v405.CFrame = cFrame
			pcall(function()
				v405.AssemblyLinearVelocity = Vector3.zero
			end)
			task.wait()
			task.wait()
		end

		task.wait()
		t1._wake("status")

		local Running = t1.Running and v405:IsDescendantOf(workspace)

		return Running
	end

	do
		t1.Move.go = function(p139, p140)
			if not p139 then
				return false
			end

			local v414 = t1._hrp()

			if v414 then
				if (v414.Position - (p139 + Vector3.new(0, 3, 0))).Magnitude <= (p140 or 3) then
					return true
				end
			end

			return t1.Move.to(p139)
		end
	end

	t1.Move.live = function()
		local owner = t1.Move.owner

		if owner then
			return "[MOVING] " .. (t1.Lease.LABEL[owner] or owner) .. " | " .. t1.Move.moves .. " Moves"
		end

		return t1.Move.text
	end
	t1.Move.cancel = function()
		t1.Move.stop()
	end
	t1.Move.onRelease = function()
		t1.Move.stop()
	end
	t1.teleportTo = function(p141)
		if t1._teleporting then
			return
		end

		t1._teleporting = true
		task.spawn(function()
			local ok, result = pcall(p141)

			if ok and typeof(result) == "Vector3" then
				if t1.Move.lease("teleport") then
					pcall(t1.Move.to, result)
					t1.Move.drop("teleport")
				end
			end

			t1._teleporting = false
		end)
	end
	t1.Lease.RANK = {
		teleport = 1,
		queue = 4,
		summon = 4,
		party = 4,
		special = 5,
		autowalk = 6
	}
	t1.Lease.LABEL = {
		play = "Auto Play",
		upgrade = "Auto Upgrade",
		sell = "Auto Sell",
		skip = "Auto Skip",
		matchend = "Match End",
		target = "Auto Target",
		vote = "Mode Vote",
		queue = "Auto Join",
		summon = "Auto Summon",
		autosell = "Summon Autosell",
		equip = "Equip Best",
		unitsell = "Unit Sell",
		modvote = "Modifier Vote",
		codes = "Auto Codes",
		boosts = "Auto Boosts",
		crates = "Open Crates",
		passitems = "Use Pass Items",
		settings = "Game Settings",
		assist = "Deploy Assist",
		speed = "Game Speed",
		quests = "Daily Quests",
		passtiers = "Claim Tiers",
		passquests = "Pass Quests",
		crateshop = "Crate Shop",
		autowalk = "Auto Walk",
		ability = "Auto Ability",
		eleave = "Emergency Leave",
		ranks = "Rank Rewards",
		party = "Alt Farm",
		special = "Special Quests",
		rng = "RNG Roll",
		teleport = "Teleport"
	}
	t1.Ctx = {
		leaving = false
	}
	t1.Ctx.place = function()
		if t1.Ctx.leaving then
			return "TELEPORTING"
		end

		if game.PlaceId == 114068177100380 or t1._at(workspace, "Game.Waypoints") then
			local attribute = workspace:GetAttribute("Message")

			if attribute ~= "You Won!" and attribute ~= "You Lost!" or t1.Ctx.restarting() or t1.End and t1.End.stale == attribute then
				return "MATCH"
			end

			return "RESULTS"
		end

		if game.PlaceId ~= 132929771812494 then
			if not workspace:FindFirstChild("Elevators") then
				return "OTHER"
			end
		end

		return "LOBBY"
	end
	t1.Ctx.restarting = function()
		local attribute = workspace:GetAttribute("GameState")

		return attribute == "Restarting" or attribute == "Voting"
	end
	t1.Ctx.lobby = function()
		return t1.Ctx.place() == "LOBBY"
	end
	t1.Ctx.inMatch = function()
		return t1.Ctx.place() == "MATCH"
	end
	t1.Match = {
		roundId = 0,
		plans = {}
	}
	t1.G = {
		result = nil
	}
	t1.Match.state = function()
		local v420 = t1.Ctx.place()

		if v420 == "RESULTS" then
			return "RESULTS"
		end

		if v420 ~= "MATCH" then
			return "LOBBY"
		end

		if workspace:GetAttribute("IsVoting") == true then
			if t1._n(workspace:GetAttribute("Wave")) <= 0 then
				return "PREGAME"
			end
		end

		return "MATCH"
	end
	t1.Match.money = function()
		local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
		local Money = leaderstats and leaderstats:FindFirstChild("Money")

		return Money and t1._n(Money.Value) or 0
	end
	t1.Match.cash = t1.Match.money

	do
		t1.Match.moneyText = function(p142)
			if tostring(p142):find("{money}", 1, true) then
				return (tostring(p142):gsub("{money}", "$" .. t1._num(t1.Match.money())))
			end

			return p142
		end
	end

	t1.Match.mode = function()
		return tostring(workspace:GetAttribute("Mode") or "")
	end
	t1.Match.plan = function(p143)
		local v423 = t1.Match.plans[p143]

		if v423 then
			return v423
		end

		local v424 = t1.Modes()
		local v425 = v424 and v424[p143]

		if type(v425) ~= "string" then
			return nil
		end

		local t42 = {
			total = 0,
			reward = tonumber(v425:match("Money%s*=%s*(%d+)") or v425:match("Reward:%s*(%d+)")) or 0
		}

		t42.candy = tonumber(v425:match("Candy%s*=%s*(%d+)")) or 0
		t42.waves = {}
		t42.hiddenAt = nil
		t42.bossAt = nil

		local t43

		for match in v425:gmatch("[^\n]+") do
			local v429 = tonumber(match:match("WAVE:%s*(%d+)"))

			if v429 then
				t43 = {}
				t42.waves[v429] = t43
				t42.total = math.max(t42.total, v429)
			elseif t43 then
				local match2, v431, v432 = match:match("^%s*(.-)%s+(%d+)%s+([%d%.]+)%s*$")

				if match2 and match2 ~= "" then
					local v433 = tonumber(v431)
					local v434 = tonumber(v432) or 1

					t43[#t43 + 1] = {
						name = match2,
						count = v433,
						gap = v434
					}

					local v435 = t1.enemyCfg(match2)

					if v435 and v435.HideDetection and (not t42.hiddenAt or t42.total < t42.hiddenAt) then
						t42.hiddenAt = t42.total
					end

					if match2:find("Boss") and (not t42.bossAt or t42.total < t42.bossAt) then
						t42.bossAt = t42.total
					end

					if v433 >= 30 and v434 <= 0.3 then
						t43.swarm = true
					end

					if match2:find("Boss") or v435 and t1._n(v435.BaseHealth) >= 5000 then
						t43.boss = true
					end

					if v435 and t1._n(v435.StunDuration) > 0 and t1._n(v435.StunRange) > 0 then
						t43.stun = math.max(t43.stun or 0, t1._n(v435.StunRange))
					end
				end
			end
		end

		local v436 = t1.Cfg()

		if v436 and type(v436.Enemies) == "table" then
			t1.Match.plans[p143] = t42
		end

		return t42
	end
	t1.Match.waves = function()
		local v437 = t1.Match.plan(t1.Match.mode())

		return t1._n(workspace:GetAttribute("Wave")), v437 and v437.total or 0
	end
	t1.Match.wave = t1.Match.waves
	t1.Match.totalWaves = function()
		return select(2, t1.Match.waves())
	end
	t1.Match.endless = function()
		local v438 = t1.Match.plan(t1.Match.mode())

		return v438 ~= nil and v438.total <= 0
	end
	t1.Match.wavesLeft = function()
		if t1.Match.endless() then
			return math.huge
		end

		local v439, v440 = t1.Match.waves()

		if v440 <= 0 then
			return math.huge
		end

		return math.max(0, v440 - v439)
	end
	t1.Match.base = function()
		local v441 = t1._at(workspace, "Game.Base")

		if v441 then
			local v442 = t1._n(v441:GetAttribute("MaxHealth"), 1000)

			return t1._n(v441:GetAttribute("Health"), v442) / math.max(1, v442)
		end

		return 1
	end
	t1.Match.livesPct = function()
		if t1.Ctx.place() == "MATCH" then
			return math.clamp(t1.Match.base() * 100, 0, 100)
		end

		return nil
	end
	t1.Match.solo = function()
		return #Players:GetPlayers() <= 1
	end
	t1.Match.mapKey = function()
		local Game = workspace:FindFirstChild("Game")
		local attribute = Game and Game:GetAttribute("LoadedMap")

		if type(attribute) ~= "string" or attribute == "" then
			attribute = workspace:GetAttribute("Map")
		end

		if (type(attribute) ~= "string" or attribute == "") and Game then
			local Waypoints = Game:FindFirstChild("Waypoints")

			attribute = Waypoints and Waypoints:GetAttribute("MapName")
		end

		return type(attribute) == "string" and attribute ~= "" and attribute or nil
	end
	t1.Match.mapId = function()
		return t1.Match.mapKey() or t1.Paths and t1.Paths.signature and t1.Paths.signature() or nil
	end

	do
		t1.Match.mapName = function(p144)
			local v446 = p144 or t1.Match.mapId()

			return v446 and tostring(v446) or "Unknown Map"
		end
	end

	t1.Match.level = function()
		if t1.Ctx.place() == "MATCH" or t1.Ctx.place() == "RESULTS" then
			return {
				id = t1.Match.mode(),
				map = t1.Match.mapKey(),
				name = t1.Match.mode()
			}
		end

		return nil
	end
	t1.Match.levelId = function()
		local v447 = t1.Match.mode()

		return v447 ~= "" and v447 or nil
	end
	t1.Match.modeName = function()
		local v448 = t1.Match.mode()

		return v448 ~= "" and v448 or "Other"
	end
	t1.Match.difficulty = t1.Match.mode
	t1.Match.enemyModels = function()
		local v449 = t1._at(workspace, "Game.Enemies")

		return v449 and v449:GetChildren() or {}
	end
	t1.Match.isBoss = function(p145)
		return tostring(p145):find("Boss", 1, true) ~= nil
	end
	t1.Match.enemyHp = function(p146)
		local v450 = tonumber(p146:GetAttribute("Health"))
		local v451 = tonumber(p146:GetAttribute("MaxHealth"))

		if v450 and v451 then
			return v450, v451
		end

		local HealthGui = p146:FindFirstChild("HealthGui")
		local HealthTitle = HealthGui and HealthGui:FindFirstChild("HealthTitle")
		local match, v455 = (HealthTitle and HealthTitle:IsA("TextLabel") and HealthTitle.Text or ""):match("([%d%.]+)%s*/%s*([%d%.]+)")

		if match then
			return tonumber(match), tonumber(v455)
		end

		local Humanoid = p146:FindFirstChildOfClass("Humanoid")

		if Humanoid then
			return Humanoid.Health, Humanoid.MaxHealth
		end

		local v457 = t1.enemyCfg(p146.Name)
		local v458 = v457 and t1._n(v457.BaseHealth) or 1

		return v458, v458
	end
	t1.Match.pos = function(p147)
		if type(p147) == "table" then
			if typeof(p147.Pos) == "Vector3" then
				return p147.Pos
			end

			return typeof(p147.CFrame) == "CFrame" and p147.CFrame.Position or nil
		end

		if typeof(p147) ~= "Instance" then
			return nil
		end

		if p147:IsA("BasePart") then
			return p147.Position
		end

		local HumanoidRootPart = p147:FindFirstChild("HumanoidRootPart") or p147.PrimaryPart

		if HumanoidRootPart and HumanoidRootPart:IsA("BasePart") then
			return HumanoidRootPart.Position
		end

		local ok, result = pcall(p147.GetPivot, p147)

		return ok and result.Position or nil
	end
	t1.Match.enemies = function()
		local now = os.clock()

		if t1.Match._enemies then
			if now - t1.Match._enemiesAt < 0.1 then
				return t1.Match._enemies
			end
		end

		local enemies = {}
		local Match = t1.Match

		t1.Match._enemies = enemies
		Match._enemiesAt = now

		for _, v in ipairs(t1.Match.enemyModels()) do
			if v:IsA("Model") then
				local v467, v468 = t1.Match.enemyHp(v)

				if v467 == nil or v467 > 0 then
					local v469 = t1.enemyCfg(v.Name)

					enemies[#enemies + 1] = {
						rec = v,
						id = t1._key(v),
						name = v.Name,
						hp = v467 or 1,
						maxHp = v468 or 1,
						boss = t1.Match.isBoss(v.Name) or v469 ~= nil and t1._n(v469.BaseHealth) >= 5000,
						hidden = v469 ~= nil and v469.HideDetection == true,
						pos = t1.Match.pos(v),
						path = t1._n(v:GetAttribute("PathIndex"), 1)
					}
				end
			end
		end

		return enemies
	end
	t1.Match.boss = function()
		for _, v in ipairs(t1.Match.enemies()) do
			if v.boss then
				return true
			end
		end

		return false
	end
	t1.Match.ahead = function(p148, p149)
		local v472 = t1.Match.plan(t1.Match.mode())

		if not v472 then
			return nil
		end

		local v473 = t1._n(workspace:GetAttribute("Wave"))
		local v474

		for i = math.max(1, v473), v473 + p149 do
			local v476 = v472.waves[i] and v472.waves[i][p148]

			if v476 ~= nil and (v474 == nil or type(v476) == "number" and v474 < v476) then
				v474 = v476
			end
		end

		return v474
	end
	t1.Match.stunRange = function()
		local v477 = t1._n(t1.Match.ahead("stun", 2))

		for _, v in ipairs(t1.Match.enemyModels()) do
			local v480 = t1.enemyCfg(v.Name)

			if v480 and t1._n(v480.StunDuration) > 0 then
				v477 = math.max(v477, t1._n(v480.StunRange))
			end
		end

		return v477
	end
	t1.Match.leaking = function()
		local v481 = t1.Match.base()
		local Match = t1.Match

		if v481 < (Match._lastHp or 1) - 0.001 then
			Match._leakAt = os.clock()
		end

		Match._lastHp = v481

		return Match._leakAt ~= nil and os.clock() - Match._leakAt < 60
	end
	t1.Match.pressure = function()
		return t1.Match.base() < 1 or t1.Match.boss() or #t1.Match.enemyModels() >= 20
	end
	t1.Units = {
		shapes = {}
	}
	t1.Units.stats = function(p150, p151)
		local v483 = t1.towerCfg(p150)
		local v484 = v483 and type(v483.Upgrades) == "table"

		if v484 then
			v484 = v483.Upgrades[p151 or 1]
		end

		return type(v484) == "table" and v484 or nil
	end
	t1.Units.maxLevel = function(p152)
		local v485 = t1.towerCfg(p152)

		return v485 and type(v485.Upgrades) == "table" and #v485.Upgrades or 0
	end
	t1.Units.price = function(p153, p154)
		local v486 = t1.Units.stats(p153, p154)

		return v486 and t1._n(v486.Price) or 0
	end
	t1.Units.dps = function(p155)
		if type(p155) ~= "table" then
			return 0
		end

		local v487 = t1._n(p155.Damage) / math.max(0.1, t1._n(p155.Cooldown, 1))

		if p155.AOE then
			v487 *= 1.5
		end

		if type(p155.SecondaryAttacks) == "table" then
			for _, secondaryAttack in ipairs(p155.SecondaryAttacks) do
				if type(secondaryAttack) == "table" then
					local v490 = t1._n(secondaryAttack.Damage) / math.max(0.1, t1._n(secondaryAttack.Cooldown, 1))

					v487 += secondaryAttack.AOE and v490 * 1.5 or v490
				end
			end
		end

		return v487 + t1._n(p155.AllyDPS)
	end
	t1.Units.tag = function(p156, p157)
		local v491 = t1.towerCfg(p156)

		return v491 ~= nil and type(v491.Tags) == "table" and v491.Tags[p157] ~= nil
	end
	t1.Units.hidden = function(p158)
		local v492 = t1.towerCfg(p158)

		return v492 ~= nil and v492.HideDetection == true
	end
	t1.Units.medic = function(p159)
		local v493 = t1.Units.stats(p159, 1)

		return v493 ~= nil and v493.IsMedic == true
	end
	t1.Units.limit = function(p160)
		local v494 = t1.towerCfg(p160)

		return v494 and tonumber(v494.PlacementLimit) or nil
	end
	t1.Units.power = function(p161)
		local v495 = t1.Units.stats(p161, t1.Units.maxLevel(p161))

		if not v495 then
			return 0
		end

		local v496 = t1.Units.tag(p161, "Spawner") and 12 or math.max(4, t1._n(v495.Range))

		return t1.Units.dps(v495) * v496
	end
	t1.Units.aoe = function(p162)
		local v497 = t1.Units.stats(p162, 1)

		return t1.Units.tag(p162, "AOE") or v497 ~= nil and v497.AOE == true
	end
	t1.Units.income = function(p163)
		local v498 = t1.Units.stats(p163, t1.Units.maxLevel(p163))

		return v498 and t1._n(v498.CashPerWave) or 0
	end
	t1.Units.rarityRank = function(p164)
		local v499 = t1.towerCfg(p164)
		local RarityOrder = t1.gameSettings().RarityOrder

		return v499 and type(RarityOrder) == "table" and t1._n(RarityOrder[v499.Rarity]) or 0
	end
	t1.Units.rarity = function(p165)
		local v501 = t1.towerCfg(p165)

		return v501 and type(v501.Rarity) == "string" and v501.Rarity or nil
	end

	do
		t1.Units.shape = function(p166)
			local v502 = t1.Units.shapes[p166]

			if v502 then
				return v502
			end

			local v503 = t1.towerCfg(p166)
			local Model = v503 and v503.Model
			local t44 = {
				lift = 0,
				size = Vector3.new(4, 4, 4),
				offset = CFrame.new()
			}

			if typeof(Model) == "Instance" and Model:IsA("Model") then
				pcall(function()
					local boundingBox, v507 = Model:GetBoundingBox()
					local pivot = Model:GetPivot()

					t44.lift = math.max(pivot.Position.Y - (boundingBox.Position.Y - v507.Y / 2), 0)

					local PrimaryPart = Model.PrimaryPart

					PrimaryPart = PrimaryPart or Model:FindFirstChildWhichIsA("BasePart")

					if PrimaryPart then
						t44.offset = pivot:ToObjectSpace(PrimaryPart.CFrame)
					end

					t44.size = typeof(v503.HitboxSize) == "Vector3" and v503.HitboxSize or Model:GetExtentsSize()
				end)
			elseif v503 and typeof(v503.HitboxSize) == "Vector3" then
				t44.size = v503.HitboxSize
			end

			t1.Units.shapes[p166] = t44

			return t44
		end
	end

	t1.Units.owned = function(p167)
		local v510 = t1.data()
		local t45 = {}
		local t46 = {}
		local Towers = v510 and type(v510.Towers) == "table" and v510.Towers or {}

		for _, Tower in pairs(Towers) do
			local Name = type(Tower) == "table" and Tower.Name
			local v517 = type(Name) == "string" and t1.Units.stats(Name, 1)

			if v517 and not t46[Name] and (not p167 or t1._n(v517.CashPerWave) <= 0 and t1._n(v517.Range) > 0 and v517.IsMedic ~= true) then
				t46[Name] = true
				t45[#t45 + 1] = Name
			end
		end

		table.sort(t45)

		return t45
	end
	t1.Data = {
		roles = {},
		radii = {},
		profiles = {}
	}
	t1.Data.cfg = function(p168)
		return p168 ~= nil and t1.towerCfg(p168) or nil
	end
	t1.Data.exists = function(p169)
		return t1.Data.cfg(p169) ~= nil
	end
	t1.Data.name = function(p170)
		return tostring(p170 or "Unit")
	end
	t1.Data.maxLevel = function(p171)
		return math.max(1, t1.Units.maxLevel(p171))
	end
	t1.Data.stats = function(p172, p173)
		return t1.Units.stats(p172, math.clamp(p173 or 1, 1, t1.Data.maxLevel(p172)))
	end
	t1.Data.role = function(p174)
		local v518 = t1.Data.roles[p174]

		if v518 then
			return v518
		end

		if not t1.Data.cfg(p174) then
			return "Damage"
		end

		local s3 = "Damage"

		if t1.Units.tag(p174, "Farm") or t1.Units.income(p174) > 0 then
			s3 = "Farm"
		elseif t1.Units.tag(p174, "Booster") or t1.Units.medic(p174) then
			s3 = "Support"
		else
			if t1._n((t1.Units.stats(p174, 1) or {}).Range) <= 0 and not t1.Units.tag(p174, "Spawner") then
				s3 = "Support"
				t1.Data.roles[p174] = s3

				return s3
			end
		end

		t1.Data.roles[p174] = s3

		return s3
	end
	t1.Data.farms = function()
		local v520 = t1.Cfg()
		local Towers = v520 and type(v520.Towers) == "table" and v520.Towers or nil

		if not Towers then
			return {}
		end

		if t1.Data._farmsFor == Towers and t1.Data._farms then
			return table.clone(t1.Data._farms)
		end

		local farms = {}

		for k, Tower in pairs(Towers) do
			if type(Tower) == "table" and t1.Data.role(k) == "Farm" then
				farms[#farms + 1] = k
			end
		end

		table.sort(farms)

		local Data = t1.Data

		t1.Data._farmsFor = Towers
		Data._farms = farms

		return table.clone(farms)
	end

	do
		t1.Data.tag = function(p175)
			if p175 == nil then
				return "Unit"
			end

			local tags = t1.Data.tags and t1.Data.tags[p175]

			if tags then
				return tags
			end

			local v527 = t1.Data.role(p175) == "Farm" and "Farm" or t1.Units.tag(p175, "Booster") and "Booster" or t1.Data.role(p175) == "Support" and "Support" or t1.Units.tag(p175, "Spawner") and "Spawner" or t1.Units.aoe(p175) and "AOE" or "Attack"
			local v528 = t1.Data.name(p175) .. " [" .. string.upper(v527) .. "]"

			if t1.Data.cfg(p175) then
				t1.Data.tags = t1.Data.tags or {}
				t1.Data.tags[p175] = v528
			end

			return v528
		end
	end

	t1.Data.worth = function(p176, p177)
		local v529 = t1.Data.stats(p176, p177)

		if not v529 then
			return 0
		end

		if t1.Data.role(p176) == "Farm" then
			return t1._n(v529.CashPerWave) / 30
		end

		return t1.Units.dps(v529)
	end

	do
		t1.Data.costScale = function()
			return 1
		end
	end

	do
		t1.Data.placeCost = function(p178)
			local v530 = t1.Units.stats(p178, 1)
			local huge = v530 and t1._n(v530.Price, math.huge) or math.huge

			return t1.Cash and t1.Cash.price("p:" .. tostring(p178), huge) or huge
		end
	end

	do
		t1.Data.range = function(p179, p180)
			local v532 = t1.Data.stats(p179, p180)

			return math.max(t1._n(v532 and v532.Range, 12), 4)
		end
	end

	t1.Data.onPath = function()
		return false
	end
	t1.Data.baseUnit = function(p181)
		return p181
	end
	t1.Data.hill = function()
		return false
	end
	t1.Data.hybrid = function()
		return false
	end
	t1.Data.radius = function(p182)
		local v533 = t1.Data.radii[p182]

		if v533 then
			return v533
		end

		if not t1.Data.cfg(p182) then
			return 1.75
		end

		local v534 = t1.Units.shape(p182)
		local v535 = math.clamp(math.max(v534.size.X, v534.size.Z) / 2, 0.6, 6)

		t1.Data.radii[p182] = v535

		return v535
	end
	t1.Data.learnRadius = function()
	end
	t1.Data.cap = function(p183)
		return t1.Units.limit(p183) or 15
	end

	do
		t1.Data.planLevel = function(p184)
			if not t12.AutoUpgrade then
				return 1
			end

			local v536 = t1.Data.maxLevel(p184)
			local v537 = t1.Match.slotOf(p184)
			local UpgradePriority = t12.UpgradePriority and v537 and t1._n(t12["SlotMaxLevel" .. v537]) or 0

			if UpgradePriority > 0 then
				v536 = math.min(v536, UpgradePriority)
			end

			return v536
		end
	end

	t1.Data.profile = function(p185)
		local v539 = t1.Data.planLevel(p185)
		local v540 = tostring(p185) .. ":" .. v539
		local v541 = t1.Data.profiles[v540]

		if v541 then
			return v541
		end

		local v542 = t1.Units.aoe(p185)
		local t47 = {
			id = p185,
			level = v539,
			role = t1.Data.role(p185),
			shape = v542 and "Splash" or "Single",
			area = v542,
			hold = false,
			range = t1.Data.range(p185, v539),
			summon = t1.Units.tag(p185, "Spawner"),
			hill = false,
			hybrid = false,
			hidden = t1.Units.hidden(p185),
			dps = t1.Data.worth(p185, v539)
		}

		t1.Data.profiles[v540] = t47

		return t47
	end
	t1.Data.spawnCfg = function(p186)
		return t1.Data.cfg(p186)
	end
	t1.Match.gr = function()
		local GameReplicator = t1.mods().GameReplicator

		if type(GameReplicator) == "table" and type(GameReplicator.Data) == "table" then
			return GameReplicator
		end

		if t1.Match._gr then
			return t1.Match._gr
		end

		local _grRetry = t1.Match._grRetry or 0

		if os.clock() < _grRetry then
			return nil
		end

		t1.Match._grRetry = os.clock() + 5

		local TowerAdd = t1.net("TowerAdd")
		local getupvalues_ = debug.getupvalues or getupvalues

		if not TowerAdd or not getconnections or not getupvalues_ then
			return nil
		end

		local v548, v549, v550 = ipairs(t1.gcall(getconnections, TowerAdd.OnClientEvent) or {})
		local v551 = geniter(v548, v549, v550)

		while true do
			local v552 = table.pack(v551())

			if not v552[1] then
				break
			end

			local v553 = v552[3]

			while true do
				local ok, result = pcall(function()
					return v553.Function
				end)
				local v556 = ok and result or nil
				local v557, v558, v559 = pairs(type(v556) == "function" and t1.gcall(getupvalues_, v556) or {})
				local v560 = geniter(v557, v558, v559)
				local v561 = table.pack(v560())

				if not v561[1] then
					break
				end

				local v562 = v561[3]
				local exitTo

				while true do
					if type(v562) ~= "table" then
						local v564 = table.pack(v560())

						if not v564[1] then
							break
						end

						v562 = v564[3]

						continue
					end

					if type(rawget(v562, "Data")) == "table" then
						if type(rawget(v562, "Towers")) == "table" then
							if type(rawget(v562, "Enemies")) == "table" then
								exitTo = 1

								break
							end

							local v565 = table.pack(v560())

							if v565[1] then
								v562 = v565[3]

								continue
							end

							exitTo = 2

							break
						end

						local v566 = table.pack(v560())

						if v566[1] then
							v562 = v566[3]

							continue
						end
					else
						local v567 = table.pack(v560())

						if v567[1] then
							v562 = v567[3]

							continue
						end
					end

					break
				end

				if exitTo == 1 then
					t1.Match._gr = v562

					return v562
				end

				if exitTo ~= 2 then
					break
				end

				local v568 = table.pack(v551())

				if v568[1] then
					v553 = v568[3]

					continue
				end

				return nil
			end
		end

		return nil
	end
	t1.Match.mirror = {}

	do
		local function records()
			local v570 = t1.Match.gr()

			if v570 then
				if type(v570.Data) == "table" and type(v570.Data.Towers) == "table" then
					return v570.Data.Towers
				end
			end

			return t1.Match.mirror
		end

		t1.Match.records = records
	end

	do
		t1.Match.key = function(p187)
			local Id = type(p187) == "table" and (p187.Id or p187.Index)

			return Id ~= nil and tostring(Id) or nil
		end
	end

	t1.Match.mirrorList = function(p188)
		local mirror = {}

		for k, v in pairs(p188) do
			if type(v) == "table" and v.Name and v.Pos then
				mirror[v.Id ~= nil and tostring(v.Id) or tostring(k)] = v
			end
		end

		t1.Match.mirror = mirror
	end

	do
		t1.Match.MIRROR = {
			TowerAdd = function(p189)
				local v575 = t1.Match.key(p189)

				if v575 and p189.Name and p189.Pos then
					t1.Match.mirror[v575] = p189
				end
			end,
			TowerRemove = function(p190)
				local v576 = t1.Match.key(p190)

				if v576 then
					t1.Match.mirror[v576] = nil
				end

				if type(p190) == "table" and type(p190.Towers) == "table" then
					t1.Match.mirrorList(p190.Towers)
				end
			end,
			TowerUpgrade = function(p191)
				local v577 = t1.Match.mirror[t1.Match.key(p191) or ""]

				if v577 then
					v577.Level = p191.Level or v577.Level
					v577.Stats = p191.Stats or v577.Stats
				end
			end,
			TowerTarget = function(p192)
				local v578 = t1.Match.mirror[t1.Match.key(p192) or ""]

				if v578 then
					if p192.TargetMode then
						v578.TargetMode = p192.TargetMode
					end
				end
			end,
			TowerMove = function(p193)
				local mirror = t1.Match.mirror
				local v580 = mirror[t1.Match.key(p193) or ""]

				if v580 and typeof(p193.Pos) == "Vector3" then
					v580.Pos = p193.Pos

					if typeof(p193.CFrame) == "CFrame" then
						v580.CFrame = p193.CFrame
					end
				end
			end,
			Replication = function(p194)
				if type(p194) == "table" and type(p194.Towers) == "table" then
					t1.Match.mirrorList(p194.Towers)
				end
			end
		}
	end

	t1.Match.ours = {}
	t1.Match.mine = function(p195, p196)
		if p195.Id ~= nil then
			if t1.Match.ours[tostring(p195.Id)] then
				return true
			end
		end

		local OwnerUserId = p195.OwnerUserId
		local Owner = p195.Owner
		local OwnerName = p195.OwnerName

		if OwnerUserId ~= nil and tostring(OwnerUserId) == tostring(LocalPlayer.UserId) then
			return true
		end

		if Owner ~= nil and (Owner == LocalPlayer or tostring(Owner) == LocalPlayer.Name or tostring(Owner) == tostring(LocalPlayer.UserId)) then
			return true
		end

		if OwnerName ~= nil and (tostring(OwnerName) == LocalPlayer.Name or tostring(OwnerName) == LocalPlayer.DisplayName) then
			return true
		end

		return OwnerUserId == nil and Owner == nil and OwnerName == nil and p196
	end
	t1.Match.isMine = function(p197)
		local v584 = type(p197) == "table" and p197.Name ~= nil

		return v584 and t1.Match.mine(p197, t1.Match.solo())
	end
	t1.Match.statOf = function(p198, p199)
		if type(p198) ~= "table" then
			return nil
		end

		if p199 == "upgrade" then
			return t1._n(p198.Level, 1) - 1
		end

		if p199 == "range" then
			local Stats = type(p198.Stats) == "table" and p198.Stats

			return Stats and tonumber(Stats.Range) or t1.Data.range(p198.Name, t1._n(p198.Level, 1))
		end

		if p199 == "id" then
			return p198.Name
		end

		if p199 == "uuid" then
			return p198.Id
		end

		if p199 == "priority" then
			return p198.TargetMode
		end

		if p199 == "player" then
			return t1.Match.isMine(p198) and LocalPlayer or nil
		end

		local Stats = type(p198.Stats) == "table" and p198.Stats

		return Stats and Stats[p199] or p198[p199]
	end
	t1.Match.byHash = {}
	t1.Match.row = function(p200)
		local v587 = t1.Match.key(p200)

		t1.Match.byHash[v587] = p200

		local Stats = type(p200.Stats) == "table" and p200.Stats

		return {
			rec = p200,
			hash = v587,
			id = tostring(p200.Name),
			uuid = v587,
			level = t1._n(p200.Level, 1),
			pos = t1.Match.pos(p200),
			range = Stats and tonumber(Stats.Range) or t1.Data.range(p200.Name, t1._n(p200.Level, 1)),
			target = p200.TargetMode
		}
	end
	t1.Match.towers = function()
		local now = os.clock()

		if t1.Match._towers and now - t1.Match._towersAt < 0.1 then
			return t1.Match._towers
		end

		local towers = {}
		local v591 = t1.Match.solo()

		for k, v in pairs(t1.Match.records()) do
			if type(v) == "table" and v.Name and t1.Match.mine(v, v591) then
				if v.Id == nil then
					v.Id = k
				end

				towers[#towers + 1] = t1.Match.row(v)
			end
		end

		local function v594(p201, p202)
			return p201.hash < p202.hash
		end

		table.sort(towers, v594)

		local Match = t1.Match

		t1.Match._towers = towers
		Match._towersAt = now

		return towers
	end
	t1.Match.dirty = function()
		local Match = t1.Match
		local Match2 = t1.Match

		t1.Match._towers = nil
		Match._enemies = nil
		Match2._units = nil
	end
	t1.Match.tower = function(p203)
		if p203 == nil then
			return nil
		end

		local v598 = t1.Match.records()
		local v599 = v598[p203]

		if not v599 then
			v599 = v598[tonumber(p203) or p203]
		end

		if type(v599) ~= "table" then
			for _, v in pairs(v598) do
				if type(v) == "table" and tostring(v.Id) == tostring(p203) then
					v599 = v

					break
				end
			end
		end

		return type(v599) == "table" and t1.Match.isMine(v599) and v599 or nil
	end
	t1.Match.units = function()
		local t48 = {}

		for _, v in ipairs(t1.Match.towers()) do
			t48[#t48 + 1] = {
				id = v.hash,
				name = v.id,
				level = v.level,
				pos = v.pos,
				target = v.target,
				rec = v.rec
			}
		end

		return t48
	end

	do
		t1.Match.unit = function(p204)
			for _, v in ipairs(t1.Match.units()) do
				if v.id == p204 then
					return v
				end
			end

			return nil
		end
	end

	t1.Match.placedCount = function()
		local PlacedTowers = LocalPlayer:FindFirstChild("PlacedTowers")
		local v608 = PlacedTowers and t1._n(PlacedTowers.Value)

		return v608 or #t1.Match.towers()
	end
	t1.Match.countOf = function(p205, p206)
		local n2 = 0
		local v610 = p206 or t1.Match.towers()

		for _, v in ipairs(v610) do
			if v.id == p205 and v.hash or v.name == p205 then
				n2 += 1
			end
		end

		return n2
	end
	t1.Match.hasHidden = function()
		local v613, v614, v615 = ipairs(t1.Match.towers())
		local v616 = geniter(v613, v614, v615)
		local v617 = table.pack(v616())

		if v617[1] then
			local v618 = v617[3]

			while true do
				if t1.Units.hidden(v618.id) then
					return true
				end

				local v619 = table.pack(v616())

				if not v619[1] then
					break
				end

				v618 = v619[3]
			end
		end

		return false
	end
	t1.Match.recent = {}
	t1.Match.placed = function()
		local t49 = {}

		for _, v in pairs(t1.Match.records()) do
			local Name = type(v) == "table" and v.Name and t1.Match.pos(v)

			if Name then
				t49[#t49 + 1] = {
					pos = Name,
					r = t1.Data.radius(v.Name)
				}
			end
		end

		local recent = t1.Match.recent
		local now = os.clock()
		local v626 = #t49

		for i = #recent, 1, -1 do
			local v628 = recent[i]
			local v629 = false

			for i2 = 1, v626 do
				local v631 = t1._flat(t49[i2].pos - v628.pos)

				if v631.X * v631.X + v631.Z * v631.Z < 1 then
					v629 = true

					break
				end
			end

			if not v629 then
				if not (v628.till < now) then
					t49[#t49 + 1] = {
						pos = v628.pos,
						r = v628.r
					}

					continue
				end
			end

			table.remove(recent, i)
		end

		return t49
	end
	t1.Match.present = function()
		local v632 = t1.Match.enemies()
		local t50 = {
			boss = false,
			count = #v632,
			lead = 0
		}

		for _, v in ipairs(v632) do
			t50.boss = t50.boss or v.boss

			local pos = v.pos and t1.Target.progress(v) or 0

			if t50.lead < pos then
				local pos2 = v.pos

				t50.lead = pos
				t50.leadPos = pos2
			end
		end

		return t50
	end
	t1.Match.ready = function()
		return t1.net("TowerAdd") ~= nil and t1._at(workspace, "Game.Towers") ~= nil
	end
	t1.Match.maxedOut = function()
		return t1.Match.placedCount() >= 15
	end
	t1.Slots = {
		cache = nil,
		at = 0
	}
	t1.Slots.list = function()
		if t1.Slots.cache then
			if os.clock() - t1.Slots.at < 0.5 then
				return t1.Slots.cache
			end
		end

		local v638 = not (LocalPlayer:GetAttribute("RNGLoadout") == true) and t1.data()
		local Towers = v638 and type(v638.Towers) == "table" and v638.Towers or nil
		local v640 = false
		local v641, v642, v643 = pairs(Towers or {})
		local v644 = geniter(v641, v642, v643)

		while true do
			local v645 = table.pack(v644())

			if v645[1] then
				local v646 = v645[3]

				if type(v646) == "table" and tonumber(v646.Equipped) then
					v640 = true

					break
				end
			else
				break
			end
		end

		if not v640 then
			Towers = {}

			for i = 1, math.max(5, t1._n(t1.gameSettings().HotbarSlots, 5)) do
				local attribute = LocalPlayer:GetAttribute("Slot" .. i)
				local attribute2 = LocalPlayer:GetAttribute("Slot" .. i .. "Id")

				if type(attribute) == "string" then
					if attribute ~= "" and type(attribute2) == "string" and attribute2 ~= "" then
						Towers[attribute2] = {
							Name = attribute,
							Equipped = i
						}
					end
				end
			end
		end

		local cache = {}
		local v651, v652, v653 = pairs(Towers)

		for k, v in v651, v652, v653 do
			local v656 = type(v) == "table" and tonumber(v.Equipped)
			local v657 = v656 and t1.Units.stats(v.Name, 1)

			if v657 then
				cache[#cache + 1] = {
					slot = v656,
					uuid = k,
					name = tostring(v.Name),
					cost = t1._n(v657.Price),
					range = t1._n(v657.Range),
					dps = t1.Units.dps(v657),
					farm = t1._n(v657.CashPerWave) > 0,
					spawner = t1.Units.tag(v.Name, "Spawner"),
					hidden = t1.Units.hidden(v.Name),
					limit = t1.Units.limit(v.Name),
					medic = v657.IsMedic == true,
					aoe = t1.Units.aoe(v.Name),
					income = t1._n(v657.CashPerWave)
				}
			end
		end

		table.sort(cache, function(p207, p208)
			return p207.slot < p208.slot
		end)

		local Slots = t1.Slots
		local Slots2 = t1.Slots
		local now = os.clock()

		Slots.cache = cache
		Slots2.at = now

		return cache
	end

	do
		t1.Slots.get = function(p209)
			for _, v in ipairs(t1.Slots.list()) do
				if v.slot == p209 then
					return v
				end
			end

			return nil
		end
	end

	t1.Slots.byName = function(p210)
		for _, v in ipairs(t1.Slots.list()) do
			if v.name == p210 then
				return v
			end
		end

		return nil
	end
	t1.Match.slots = function()
		local now = os.clock()

		if t1.Match._slots and now - t1.Match._slotsAt < 0.25 then
			return t1.Match._slots
		end

		local slots = {}

		for _, v in ipairs(t1.Slots.list()) do
			slots[#slots + 1] = {
				slot = v.slot,
				uuid = v.uuid,
				id = v.name,
				role = t1.Data.role(v.name),
				name = v.name,
				tag = t1.Data.tag(v.name),
				entry = {
					Name = v.name,
					uuid = v.uuid
				},
				hot = v
			}
		end

		local Match = t1.Match

		t1.Match._slots = slots
		Match._slotsAt = now

		return slots
	end
	t1.Match.slotOf = function(p211)
		for _, v in ipairs(t1.Match.slots()) do
			if v.id == p211 then
				return v.slot
			end
		end

		return nil
	end
	t1.Match.slotRec = function(p212)
		for _, v in ipairs(t1.Match.slots()) do
			if v.id == p212 then
				return v
			end
		end

		return nil
	end
	t1.Units.equipped = function()
		local t51 = {}

		for _, v in ipairs(t1.Slots.list()) do
			t51[v.slot] = v.name
		end

		return t51
	end
	t1.Match.result = function()
		local attribute = workspace:GetAttribute("Message")

		if t1.Ctx.place() == "RESULTS" then
			return attribute == "You Won!" and "Victory" or attribute == "You Lost!" and "Defeat" or nil
		end

		return nil
	end

	do
		t1.Match.idle = function(p213)
			if t1.Match.state() == "RESULTS" then
				local v678 = t1.Match.result()

				return v678 and "[DONE] " .. v678 or "[WAITING] Awaiting Verdict"
			end

			if t1.Match.state() == "PREGAME" then
				return p213 or "[WAITING] Awaiting Waves | Mode Vote"
			end

			return p213 or "[WAITING] Awaiting Match"
		end
	end

	t1.Paths = {
		rev = 0,
		AUTO = "Auto (All Paths)"
	}

	do
		local function v679(p214)
			local t52 = {}
			local n3 = 1

			while n3 <= 500 do
				local v682 = p214:FindFirstChild(tostring(n3))

				if not v682 or not v682:IsA("BasePart") then
					break
				end

				t52[#t52 + 1] = v682.Position
				n3 += 1
			end

			local v683 = t1._n(p214:GetAttribute("TotalWaypoints"))

			if #t52 < 2 or v683 > 0 and v683 > #t52 then
				return nil
			end

			return t52
		end

		t1.Paths.folder = function()
			local Game = workspace:FindFirstChild("Game")
			local Waypoints = Game and Game:FindFirstChild("Waypoints")

			if not Waypoints then
				return nil
			end

			local attribute = Game:GetAttribute("LoadedMap")

			if Game:GetAttribute("MapReady") == false or type(attribute) == "string" and Waypoints:GetAttribute("MapName") ~= nil and Waypoints:GetAttribute("MapName") ~= attribute then
				return nil
			end

			return Waypoints
		end
		t1.Paths.waypoints = function()
			local t53 = {}
			local v688 = t1.Paths.folder()

			if not v688 then
				return t53
			end

			local attribute = v688:GetAttribute("RouteFolders")
			local v690 = v688:FindFirstChild("1")

			if attribute == nil then
				attribute = v690 ~= nil and not v690:IsA("BasePart")
			end

			if attribute then
				for i = 1, math.max(1, t1._n(v688:GetAttribute("RouteCount"), 1)) do
					local v692 = v688:FindFirstChild(tostring(i))
					local v693 = v692 and not v692:IsA("BasePart") and v679(v692)

					if not v693 then
						break
					end

					t53[#t53 + 1] = {
						index = i,
						points = v693
					}
				end
			else
				local v694 = v679(v688)

				if v694 then
					t53[1] = {
						index = 1,
						points = v694
					}
				end
			end

			return t53
		end
	end

	do
		t1.Paths.signature = function()
			local v695 = t1.Paths.waypoints()

			if #v695 == 0 then
				return nil
			end

			local v696 = v695[1].points[1]

			return "lanes:" .. #v695 .. ":" .. math.floor(v696.X) .. ":" .. math.floor(v696.Z)
		end
	end

	t1.Paths.stamp = function()
		local Paths = t1.Paths
		local now = os.clock()

		if Paths._st and now - Paths._stAt < 0.5 then
			return Paths._st
		end

		Paths._st = t1.Paths._stamp0()
		Paths._stAt = now

		return Paths._st
	end
	t1.Paths._stamp0 = function()
		local v699 = tostring(t1.Match.mapId())
		local v700 = t1.Paths.folder()

		if not v700 then
			return v699
		end

		local v701 = t1.Paths.waypoints()
		local v702 = v701[1] and v701[1].points[1]

		return v699 .. ":" .. tostring(v700) .. ":" .. #v701 .. ":" .. (v701[1] and #v701[1].points or 0) .. ":" .. (v702 and math.floor(v702.X) .. ":" .. math.floor(v702.Z) or "")
	end
	t1.Paths.ground = function(p215)
		local raycastParams = RaycastParams.new()

		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		local filterDescendantsInstances = {}

		if LocalPlayer.Character then
			filterDescendantsInstances[#filterDescendantsInstances + 1] = LocalPlayer.Character
		end

		for _, v in ipairs({
			"Towers",
			"PlacingTowers",
			"Enemies",
			"Units",
			"Waypoints"
		}) do
			local v707 = t1._at(workspace, "Game." .. v)

			if v707 then
				filterDescendantsInstances[#filterDescendantsInstances + 1] = v707
			end
		end

		if t1.Esp and t1.Esp.folder then
			filterDescendantsInstances[#filterDescendantsInstances + 1] = t1.Esp.folder
		end

		raycastParams.FilterDescendantsInstances = filterDescendantsInstances

		local v708 = t1._at(workspace, "Game.TowerArea")

		local function v709(p216, p217)
			for i = 1, 6 do
				local hit = workspace:Raycast(p216, Vector3.new(0, -p217, 0), raycastParams)

				if not hit then
					return nil
				end

				local Instance_ = hit.Instance

				if v708 and Instance_:IsDescendantOf(v708) or Instance_:IsA("BasePart") and Instance_.Transparency < 0.95 and Instance_.CanCollide then
					return hit.Position.Y
				end

				p217 = p217 - (p216.Y - hit.Position.Y) - 0.05
				p216 = hit.Position - Vector3.new(0, 0.05, 0)

				if p217 <= 0 then
					return nil
				end
			end

			return nil
		end

		local t54 = {}

		for _, v in ipairs(p215) do
			local v716 = v709(v + Vector3.new(0, 3, 0), 2000)
			local vector3 = v716 and v.Y - v716 > 1 and Vector3.new(v.X, v716, v.Z) or v
			local v718 = t54[#t54]

			if not v718 or t1._flat(vector3 - v718).Magnitude > 0.25 then
				t54[#t54 + 1] = vector3
			end
		end

		local v719 = #t54

		if v719 >= 2 then
			if t54[2].Y + 1 < t54[1].Y then
				t54[1] = Vector3.new(t54[1].X, t54[2].Y, t54[1].Z)
			end

			if t54[v719 - 1].Y + 1 < t54[v719].Y then
				t54[v719] = Vector3.new(t54[v719].X, t54[v719 - 1].Y, t54[v719].Z)
			end
		end

		return t54
	end
	t1.Paths.get = function()
		local Paths = t1.Paths
		local v721 = t1.Paths.stamp()

		if Paths._data and Paths._stamp == v721 then
			return Paths._data
		end

		local v722 = t1.Paths.waypoints()

		if #v722 == 0 then
			return nil
		end

		for _, v in ipairs(v722) do
			v.points = t1.Paths.ground(v.points)
		end

		local data = {
			paths = {},
			samples = {},
			nums = {}
		}
		local t55 = {}

		local function v727(p218, p219)
			local v728 = math.floor(p218.pos.X / 3) .. ":" .. math.floor(p218.pos.Z / 3)
			local v729 = t55[v728]

			if v729 then
				v729.walkers[p219] = true
			else
				t55[v728] = p218
				p218.walkers = {
					[p219] = true
				}
				data.samples[#data.samples + 1] = p218
			end
		end

		local C_2_, V_2_, U_2_

		for _, v in ipairs(v722) do
			local n4 = 0

			for i = 1, #v.points - 1 do
				n4 += (v.points[i + 1] - v.points[i]).Magnitude
			end

			if #v.points >= 2 and n4 > 1 then
				local t56 = {
					index = #data.paths + 1,
					id = #data.paths + 1,
					pathIndex = v.index,
					samples = {},
					length = n4,
					points = v.points,
					entry = v.points[1],
					finish = v.points[#v.points]
				}

				data.nums[v.index] = true

				local n5 = 0

				for i = 1, #v.points - 1 do
					local v740 = v.points[i]
					local v741 = v.points[i + 1]
					local Magnitude = (v741 - v740).Magnitude
					local Unit = Magnitude > 0 and (v741 - v740).Unit or Vector3.new(1, 0, 0)
					local v744 = math.max(1, math.floor(Magnitude / 2))
					local n6 = 0
					local v746 = v744 - 1
					local v747, v748, t57, v750

					if n6 <= v746 then
						v747 = n6

						while true do
							v748 = v747 / v744
							t57 = {
								pos = v740:Lerp(v741, v748),
								progress = (n5 + Magnitude * v748) / n4,
								path = t56.index,
								pathIndex = v.index,
								dist = n5 + Magnitude * v748,
								dir = Unit
							}
							v750 = #t56.samples + 1
							t56.samples[v750] = t57
							v727(t57, v.index)
							V_2_ += C_2_

							if not (C_2_ <= 0) then
								if V_2_ <= U_2_ then
									v747 = V_2_

									continue
								end

								break
							end

							if V_2_ >= U_2_ then
								v747 = V_2_

								continue
							end

							break
						end
					end

					V_2_ = V_2
					U_2_ = U_2
					C_2_ = C_2
					n5 += Magnitude
				end

				local v751 = v.points[#v.points]
				local t58 = {
					pos = v751,
					progress = 1,
					path = t56.index,
					pathIndex = v.index,
					dist = n4,
					dir = (v751 - v.points[#v.points - 1]).Unit
				}

				t56.samples[#t56.samples + 1] = t58
				v727(t58, v.index)
				data.paths[t56.index] = t56
			end
		end

		if #data.paths == 0 then
			return nil
		end

		t1.Paths.weigh(data)

		if Paths._stamp ~= nil and Paths._stamp ~= v721 then
			Paths.rev += 1
		end

		Paths._data = data
		Paths._stamp = v721
		Paths.rev += 1

		if t1.Place then
			local Place = t1.Place

			t1.Place._cands = nil
			Place._candKey = nil
		end

		if t1.Play and t1.Play.refreshPaths then
			task.defer(pcall, t1.Play.refreshPaths)
		end

		return data
	end

	do
		t1.Paths.laneWalk = function()
			return nil
		end
	end

	t1.Paths.count = function()
		local v754 = t1.Paths.get()

		return v754 and #v754.paths or 0
	end
	t1.Paths.selected = function()
		local v755 = t1.Paths.get()
		local SmartDeployPaths = t12.SmartDeployPaths

		if not v755 or type(SmartDeployPaths) ~= "table" or t1._has(SmartDeployPaths, t1.Paths.AUTO) then
			return nil
		end

		local t59 = {}
		local n7 = 0

		for _, SmartDeployPath in ipairs(SmartDeployPaths) do
			local v761 = tonumber(tostring(SmartDeployPath):match("^Path (%d+)$"))

			if not v761 or not v755.paths[v761] then
				return nil
			end

			if not t59[v761] then
				n7 += 1
				t59[v761] = true
			end
		end

		if n7 == 0 or n7 >= #v755.paths then
			return nil
		end

		return t59
	end
	t1.Paths.selKey = function()
		local v762 = t1.Paths.selected()

		if not v762 then
			return "all"
		end

		local t60 = {}

		for k in pairs(v762) do
			t60[#t60 + 1] = k
		end

		table.sort(t60)

		return table.concat(t60, "+")
	end
	t1.Paths.samples = function()
		local v765 = t1.Paths.get()

		if not v765 then
			return {}
		end

		local v766 = t1.Paths.selected()

		if not v766 then
			return v765.samples
		end

		local v767 = t1.Paths.selKey()

		if v765._selKey == v767 then
			return v765._sel
		end

		local t61 = {}

		for k in pairs(v766) do
			t61[v765.paths[k].pathIndex] = true
		end

		local sel = {}

		for _, sample in ipairs(v765.samples) do
			local pairs_ = pairs
			local walkers = sample.walkers or {}

			for k in pairs_(walkers) do
				if t61[k] then
					sel[#sel + 1] = sample

					break
				end
			end
		end

		v765._selKey = v767
		v765._sel = sel

		return sel
	end
	t1.Paths.nearest = function(p220)
		local v776
		local huge = math.huge
		local v778 = t1.Paths.get()
		local v779 = t1._flat(p220)
		local samples = v778 and v778.samples or {}

		for _, sample in ipairs(samples) do
			local Magnitude = (t1._flat(sample.pos) - v779).Magnitude

			if Magnitude < huge then
				v776 = sample
				huge = Magnitude
			end
		end

		return v776, huge
	end
	t1.Paths.reset = function()
		local Paths = t1.Paths

		t1.Paths._data = nil
		Paths._stamp = nil
		t1.Paths.rev += 1
	end
	t1.Paths.traffic = {
		map = nil,
		seen = {},
		counts = {},
		total = 0,
		weighed = 0
	}
	t1.Paths.weigh = function(p221)
		local traffic = t1.Paths.traffic
		local n8 = 0

		for _ in pairs(p221.nums) do
			n8 += 1
		end

		local v788 = traffic.total / math.max(n8, 1)

		for _, sample in ipairs(p221.samples) do
			local n9 = 0
			local pairs_ = pairs
			local walkers = sample.walkers or {}

			for k in pairs_(walkers) do
				n9 += ((traffic.counts[k] or 0) + 3) / (v788 + 3)
			end

			sample.w = n9 > 0 and n9 or 1
		end
	end
	t1.Paths.watch = function()
		local traffic = t1.Paths.traffic
		local v796 = t1.Match.mapId()

		if traffic.map ~= v796 then
			traffic.map = v796
			traffic.seen = {}
			traffic.counts = {}
			traffic.total = 0
			traffic.weighed = 0
		end

		local seen = {}

		for _, v in ipairs(t1.Match.enemies()) do
			if v.id ~= nil then
				if not traffic.seen[v.id] then
					traffic.counts[v.path] = (traffic.counts[v.path] or 0) + 1
					traffic.total += 1
				end

				seen[v.id] = true
			end
		end

		traffic.seen = seen

		if traffic.total > 0 then
			if traffic.weighed == 0 or traffic.total - traffic.weighed >= 10 or traffic.weighed * 1.25 <= traffic.total then
				local v800 = t1.Paths.get()

				if v800 then
					t1.Paths.weigh(v800)
					traffic.weighed = traffic.total
				end
			end
		end
	end
	t1.Map = {}
	t1.Map.paths = function()
		local v801 = t1.Paths.get()

		return v801 and v801.paths or {}
	end
	t1.Place = {
		refused = {}
	}
	t1.Place.rp = function(p222, p223, p224, p225)
		local Place = t1.Place

		Place._rp = Place._rp or {}

		local v803 = Place._rp[p222]

		if v803 and v803[2] == p223 and v803[3] == p224 and v803[4] == p225 then
			return v803[1]
		end

		local raycastParams = RaycastParams.new()

		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = {
			p223,
			p224,
			p225
		}
		Place._rp[p222] = {
			raycastParams,
			p223,
			p224,
			p225
		}

		return raycastParams
	end

	do
		t1.Place.mapRp = function()
			local Place = t1.Place
			local Game = workspace:FindFirstChild("Game")
			local Character = LocalPlayer.Character

			if Place._mapRp and Place._mapRpFor == Game and Place._mapRpChar == Character then
				return Place._mapRp
			end

			local raycastParams = RaycastParams.new()

			raycastParams.FilterType = Enum.RaycastFilterType.Exclude

			local filterDescendantsInstances = {}

			if Character then
				filterDescendantsInstances[#filterDescendantsInstances + 1] = Character
			end

			for _, v in ipairs({
				"Towers",
				"PlacingTowers",
				"Enemies",
				"Units",
				"Waypoints"
			}) do
				local v812 = Game and Game:FindFirstChild(v)

				if v812 then
					filterDescendantsInstances[#filterDescendantsInstances + 1] = v812
				end
			end

			if t1.Esp and t1.Esp.folder then
				filterDescendantsInstances[#filterDescendantsInstances + 1] = t1.Esp.folder
			end

			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			Place._mapRp = raycastParams
			Place._mapRpFor = Game
			Place._mapRpChar = Character

			return raycastParams
		end
	end

	t1.Place.folders = function()
		return t1._at(workspace, "Game.TowerArea"), nil, nil
	end

	do
		t1.Place.top = function()
			local Place = t1.Place
			local v814 = t1.Paths.get()

			if not v814 then
				return 500
			end

			if Place._topFor == v814 then
				return Place._top
			end

			local Y
			local Y2

			for _, path in pairs(v814.paths) do
				local ipairs_ = ipairs
				local points = path.points or {}

				for _, point in ipairs_(points) do
					if not Y or Y < point.Y then
						Y = point.Y
					end

					if not Y2 or point.Y < Y2 then
						Y2 = point.Y
					end
				end
			end

			local top = Y and Y + 20 or 500

			Place._topFor = v814
			Place._top = top
			Place._low = Y2

			return Place._top
		end
	end

	t1.Place.castRange = function()
		local Place = t1.Place
		local now = os.clock()
		local v826 = t1.Place.top()

		if Place._crTop == v826 and Place._crFor == Place._topFor then
			if now < (Place._crNext or 0) then
				return Place._crHi, Place._crLo
			end
		end

		local _low = Place._topFor and Place._low
		local v828, v829 = t1.Place.groundSpan()

		Place._crHi = math.max(500, v826 + 200, (v828 or -math.huge) + 50)
		Place._crLo = math.min(-500, (_low or 0) - 300, (v829 or math.huge) - 50)

		local _topFor = Place._topFor

		Place._crTop = v826
		Place._crFor = _topFor
		Place._crNext = now + 2

		return Place._crHi, Place._crLo
	end
	t1.Place.groundSpan = function()
		local Place = t1.Place
		local v832, v833 = t1.Place.folders()

		if not v832 then
			return nil, nil
		end

		local gsN = #v832:GetChildren() + (v833 and #v833:GetChildren() or 0)

		if Place._gsFor == v832 and Place._gsHill == v833 and Place._gsN == gsN then
			return Place._gsTop, Place._gsLow
		end

		local gsTop
		local gsLow
		local v837 = v833 and {
			v832,
			v833
		} or { v832 }

		for _, v in ipairs(v837) do
			local descendants = v:GetDescendants()

			if v:IsA("BasePart") then
				descendants[#descendants + 1] = v
			end

			for _, descendant in ipairs(descendants) do
				if descendant:IsA("BasePart") then
					local v843 = t1.Place.bottom(descendant)
					local v844 = 2 * descendant.Position.Y - v843
					local max = math.max
					local v846 = gsTop

					gsTop = max(v846 or v844, v844)
					gsLow = math.min(gsLow or v843, v843)
				end
			end
		end

		Place._gsFor = v832
		Place._gsHill = v833
		Place._gsN = gsN
		Place._gsTop = gsTop
		Place._gsLow = gsLow

		return gsTop, gsLow
	end

	do
		t1.Place.surface = function(p226)
			return p226.Position
		end
	end

	do
		t1.Place.bottom = function(p227)
			local CFrame_ = p227.CFrame
			local Size = p227.Size

			return CFrame_.Position.Y - (math.abs(CFrame_.RightVector.Y) * Size.X + math.abs(CFrame_.UpVector.Y) * Size.Y + math.abs(CFrame_.LookVector.Y) * Size.Z) / 2
		end
	end

	do
		t1.Place.ground = function(p228, p229, p230, p231)
			if p231 == "hill" then
				return nil
			end

			local v849 = t1.Place.folders()

			if not v849 then
				return nil
			end

			local ground = t1.Place.rp("ground", v849)
			local v851, v852 = t1.Place.castRange()
			local hit = workspace:Raycast(Vector3.new(p228, v851, p229), Vector3.new(0, v852 - v851, 0), ground)

			if not hit then
				return nil
			end

			t1.Place._lastPart = hit.Instance

			return hit.Position
		end
	end

	t1.Place.COLUMN_H = 5
	t1.Place.inBounds = function()
		return false
	end
	t1._cleanups[#t1._cleanups + 1] = function()
		local Place = t1.Place

		Place._rp = nil
		Place._gsFor = nil
		Place._gsHill = nil
		Place._crFor = nil
		Place._crNext = nil
	end

	do
		local overlapParams = OverlapParams.new()

		overlapParams.FilterType = Enum.RaycastFilterType.Include
		t1.Place.pending = {}
		t1.Place.pivot = function(p232, p233, p234)
			local v856 = t1.Units.shape(p232)

			return CFrame.lookAt(p233 + Vector3.new(0, v856.lift, 0), p233 + Vector3.new(0, v856.lift, 0) + t1.Place.look(p234), Vector3.yAxis), v856
		end

		local function boxBlocked(p235, p236)
			if not p236 then
				return false
			end

			local v858, v859 = t1.Place.pivot(p236, p235, t1.Place.yaw(p235))
			local v860 = t1._at(workspace, "Game.Towers")
			local now

			if v860 then
				if overlapParams.FilterDescendantsInstances[1] ~= v860 then
					overlapParams.FilterDescendantsInstances = { v860 }
				end

				local ok, result = pcall(workspace.GetPartBoundsInBox, workspace, v858 * v859.offset, v859.size * 0.98, overlapParams)

				if ok and type(result) == "table" and #result > 0 then
					return true
				end

				now = os.clock()
			else
				now = os.clock()
			end

			for i = #t1.Place.pending, 1, -1 do
				local v865 = t1.Place.pending[i]

				if now - v865.at > 3 then
					table.remove(t1.Place.pending, i)

					continue
				end

				if math.abs(v865.pos.X - p235.X) < (v865.size.X + v859.size.X) / 2 and math.abs(v865.pos.Z - p235.Z) < (v865.size.Z + v859.size.Z) / 2 then
					return true
				end
			end

			return false
		end

		t1.Place.boxBlocked = boxBlocked
	end

	t1.Place.pathDist = function(p237, p238)
		local v866 = t1.Paths.get()
		local huge = math.huge
		local paths = v866 and v866.paths or {}

		for _, path in ipairs(paths) do
			local points = path.points

			for i = 2, #points do
				local v873 = points[i - 1]
				local v874 = points[i]
				local v875 = v874.X - v873.X
				local v876 = v874.Z - v873.Z
				local v877 = v875 * v875 + v876 * v876
				local v878 = v877 > 0 and math.clamp(((p237 - v873.X) * v875 + (p238 - v873.Z) * v876) / v877, 0, 1) or 0
				local v879 = v873.X + v875 * v878 - p237
				local v880 = v873.Z + v876 * v878 - p238

				huge = math.min(huge, v879 * v879 + v880 * v880)
			end
		end

		return math.sqrt(huge)
	end

	do
		t1.Place.roadHalf = function()
			local Place = t1.Place
			local v882 = t1.Paths.get()

			if not v882 then
				return 4
			end

			if Place._halfFor == v882 then
				return Place._half
			end

			if Place._halfBusy then
				local _half = Place._half or 4

				return _half
			end

			Place._halfBusy = true

			local ok, result = pcall(function()
				local raycastParams = RaycastParams.new()

				raycastParams.FilterType = Enum.RaycastFilterType.Exclude

				local filterDescendantsInstances = {}

				if LocalPlayer.Character then
					filterDescendantsInstances[#filterDescendantsInstances + 1] = LocalPlayer.Character
				end

				for _, v in ipairs({
					"Towers",
					"PlacingTowers",
					"Enemies",
					"Units"
				}) do
					local v890 = t1._at(workspace, "Game." .. v)

					if v890 then
						filterDescendantsInstances[#filterDescendantsInstances + 1] = v890
					end
				end

				raycastParams.FilterDescendantsInstances = filterDescendantsInstances

				local samples = v882.samples
				local t62 = {}
				local v893 = math.max(1, math.floor(#samples / 10))

				for i = v893, #samples - 1, v893 do
					local v895 = samples[i]
					local vector3 = Vector3.new(-v895.dir.Z, 0, v895.dir.X)
					local Unit = vector3.Magnitude > 0.01 and vector3.Unit or Vector3.new(1, 0, 0)
					local hit = workspace:Raycast(v895.pos + Vector3.new(0, 30, 0), Vector3.new(0, -80, 0), raycastParams)

					if hit then
						for i2 = -1, 1, 2 do
							local v900

							for i3 = 1, 12, 0.5 do
								local hit2 = workspace:Raycast(v895.pos + Unit * (i2 * i3) + Vector3.new(0, 30, 0), Vector3.new(0, -80, 0), raycastParams)

								if not (hit2 and (hit2.Instance ~= hit.Instance or hit2.Material ~= hit.Material or hit2.Instance.Color ~= hit.Instance.Color)) then
									v900 = nil
								else
									if v900 and i3 - v900 >= 1 then
										local v903 = v895.pos + Unit * (i2 * v900)

										if v900 - 0.5 <= t1.Place.pathDist(v903.X, v903.Z) then
											t62[#t62 + 1] = v900
										end

										break
									end

									v900 = v900 or i3
								end
							end
						end
					end

					task.wait()
				end

				if #t62 < 3 then
					return 4
				end

				table.sort(t62)

				return math.clamp(t62[math.ceil(#t62 / 2)], 2, 10)
			end)

			Place._halfBusy = false

			local half = ok and result or 4

			Place._halfFor = v882
			Place._half = half

			return Place._half
		end
	end

	t1.Place.roadWidth = function()
		local Place = t1.Place
		local now = os.clock()

		if Place._rwAt and now - Place._rwAt < 1 then
			return Place._rw
		end

		local _half = Place._halfFor == t1.Paths.get() and Place._half or 4
		local _, v909 = t1.Plan.midRange()

		Place._rw = math.max(0.5, math.min(_half * 0.5, v909 / 3))
		Place._rwAt = now

		return Place._rw
	end
	t1.Place.onRoad = function(p239, p240)
		return t1.Place.pathDist(p239, p240) < t1.Place.roadWidth()
	end
	t1.Place.roadBlocks = function()
		return not (t1.Mods and t1.Mods.skip("Road"))
	end
	t1.Place.open = function(p241, p242)
		local v910 = t1.Place.ground(p241, p242)

		if not v910 or t1.Place.roadBlocks() and t1.Place.onRoad(p241, p242, v910) then
			return nil
		end

		return v910
	end
	t1.Place.valid = function(p243, p244, p245)
		local Ground = (t1.Mods and t1.Mods.skip or function()
			return false
		end)("Ground")
		local v912 = not t1.Place.roadBlocks()

		if Ground and v912 then
			return true, p243
		end

		local v913 = t1.Place.ground(p243.X, p243.Z, p244, p245)

		if not v913 then
			if not Ground then
				return false, "ground"
			end

			v913 = p243
		end

		if v912 or not t1.Place.roadBlocks() or not t1.Place.onRoad(p243.X, p243.Z, v913) then
			return true, v913
		end

		return false, "road"
	end
	t1.Place.check = function(p246, p247, p248, p249, p250)
		local v914

		if t1.Place.clear(p246, p248, p249, p250) and (t1.Mods and t1.Mods.skip("Overlap") or not t1.Place.boxBlocked(p246, p247)) then
			local v915, v916 = t1.Place.valid(p246, p247)

			if v915 then
				return true, v916
			end

			v914 = v916 or "ground"
		else
			v914 = "clear"
		end

		local rejects = t1.Place.rejects or {}

		t1.Place.rejects = rejects
		rejects[v914] = (rejects[v914] or 0) + 1

		return false
	end
	t1.Place.rejectText = function()
		local rejects = t1.Place.rejects

		if not rejects then
			return ""
		end

		local t63 = {}

		for _, v in ipairs({
			"road",
			"ground",
			"clear"
		}) do
			if rejects[v] then
				t63[#t63 + 1] = t1._title(v) .. " " .. rejects[v]
			end
		end

		return #t63 > 0 and " (" .. table.concat(t63, ", ") .. ")" or ""
	end

	local function isRefused(p251)
		return (t1.Place.refused[p251] or 0) > os.clock()
	end

	t1.Place.isRefused = isRefused

	do
		t1.Place.gap = function()
			return math.clamp(t1._n(t12.UnitSpacing), -1, 1)
		end
	end

	t1.Place.clear = function(p252, p253, p254, p255)
		local Overlap = t1.Mods and t1.Mods.skip("Overlap")

		for _, v in ipairs(p254) do
			local v926 = t1._flat(v.pos) - t1._flat(p252)
			local v927 = Overlap and math.max(1, t1._n(t12.StackGap, 1)) + 0.05

			if not v927 then
				v927 = (p253 + v.r) * (1 + (p255 or 0))
			end

			if v926.X * v926.X + v926.Z * v926.Z < v927 * v927 then
				return false
			end
		end

		return true
	end
	t1.Place.FACINGS = {
		"Path Entrance",
		"Path Exit",
		"Nearest Path",
		"Incoming Enemies",
		"North",
		"North East",
		"East",
		"South East",
		"South",
		"South West",
		"West",
		"North West"
	}
	t1.Place.COMPASS = {
		North = 0,
		["North East"] = -45,
		East = -90,
		["South East"] = -135,
		South = 180,
		["South West"] = 135,
		West = 90,
		["North West"] = 45
	}

	do
		local function v928(p256, p257)
			local v929 = p257.X - p256.X
			local v930 = p257.Z - p256.Z

			if v929 * v929 + v930 * v930 < 0.01 then
				return 180
			end

			return math.deg(math.atan2(-v929, -v930))
		end

		t1.Place.yaw = function(p258, p259)
			local UnitFacing = p259 or t12.UnitFacing or "Nearest Path"
			local v932 = t1.Place.COMPASS[UnitFacing]

			if v932 then
				return v932
			end

			local v933 = p258 and t1.Paths.get()
			local v934 = v933 and v933.paths[1]

			if not v934 then
				return 180
			end

			if UnitFacing == "Path Entrance" then
				return v928(p258, v934.entry)
			end

			if UnitFacing == "Path Exit" then
				return v928(p258, v934.finish)
			end

			local v935 = t1.Paths.nearest(p258)

			if not v935 then
				return v928(p258, v934.entry)
			end

			if UnitFacing == "Incoming Enemies" then
				return v928(p258, v935.pos - (v935.dir or Vector3.zero) * 12)
			end

			return v928(p258, v935.pos)
		end
	end

	do
		t1.Place.look = function(p260)
			local v936 = math.rad(t1._n(p260, 180))

			return Vector3.new(-math.sin(v936), 0, -math.cos(v936))
		end
	end

	local t64 = {
		0,
		1.5,
		3,
		4.5,
		6,
		7.5,
		9,
		11,
		13.5,
		16,
		19,
		23
	}

	t1.Place.candidates = function()
		local state = 1
		local v939, Place, candKey, v942, cands, t65, n10, v946, samples, n11, v949, v950, v951, vector3, v953, v954, n12, n13, v957, v958, v959, v960, C_3_, v962, U_3_, n14, v965, v966

		while true do
			if state == 1 then
				v939 = t1.Paths.get()

				if v939 then
					state = 3
				else
					state = 2
				end
			else
				if state == 2 then
					return nil
				end

				if state == 3 then
					Place = t1.Place
					candKey = tostring(t1.Paths._stamp)

					if Place._candKey == candKey and Place._cands then
						state = 4
					else
						state = 5
					end
				else
					if state == 4 then
						return Place._cands
					end

					if state == 5 then
						v942 = t1.Match.mapId()
						cands = {}
						t65 = {}
						n10 = 0

						local v967, v968, v969 = ipairs(v939.paths)

						v946 = geniter(v967, v968, v969)
						state = 6
					elseif state == 6 then
						local v970 = table.pack(v946())

						if v970[1] then
							state = 7
						else
							state = 33
						end
					elseif state == 7 then
						samples = (t176_56_1[3]).samples
						n11 = 1
						v949 = #samples
						state = 10
					elseif state == 8 then
						if n11 >= v949 then
							state = 9
						else
							state = 53
						end
					elseif state == 9 then
						v950 = n11
						state = 12
					elseif state == 10 then
						if n11 <= v949 then
							state = 11
						else
							state = 53
						end
					elseif state == 11 then
						v950 = n11
						state = 12
					elseif state == 12 then
						state = 13
					elseif state == 13 then
						v951 = samples[v950]
						vector3 = Vector3.new(-v951.dir.Z, 0, v951.dir.X)

						local v971, v972, v973 = ipairs(t64)

						v953 = geniter(v971, v972, v973)
						state = 14
					elseif state == 14 then
						local v974 = table.pack(v953())

						if v974[1] then
							state = 15
						else
							state = 29
						end
					elseif state == 15 then
						v954 = t273_104_1[3]
						n12 = -1
						n13 = 1
						state = 17
					elseif state == 16 then
						if n12 >= n13 then
							state = 39
						else
							state = 52
						end
					elseif state == 17 then
						if n12 <= n13 then
							state = 18
						else
							state = 52
						end
					elseif state == 18 then
						v957 = n12
						state = 19
					elseif state == 19 then
						v958 = v951.pos + vector3 * v954 * v957
						v959 = math.floor(v958.X / 2) .. ":" .. math.floor(v958.Z / 2)

						if t65[v959] then
							state = 37
						else
							state = 20
						end
					elseif state == 20 then
						t65[v959] = true
						v960 = t1.Place.open(v958.X, v958.Z)

						if v960 then
							state = 22
						else
							state = 21
						end
					elseif state == 21 then
						n10 += 1

						if n10 % 60 == 0 then
							state = 23
						else
							state = 37
						end
					elseif state == 22 then
						cands[#cands + 1] = {
							pos = v960,
							key = v959
						}
						n10 += 1

						if n10 % 60 == 0 then
							state = 23
						else
							state = 25
						end
					elseif state == 23 then
						task.wait()

						if t1.Running and t1.Match.mapId() == v942 then
							state = 25
						else
							state = 24
						end
					else
						if state == 24 then
							return nil
						end

						if state == 25 then
							v962 += C_3_

							if C_3_ <= 0 then
								state = 26
							else
								state = 27
							end
						elseif state == 26 then
							if v962 >= U_3_ then
								state = 39
							else
								state = 28
							end
						elseif state == 27 then
							if v962 <= U_3_ then
								state = 18
							else
								state = 28
							end
						elseif state == 28 then
							v962 = v953
							U_3_ = U_3
							C_3_ = C_3

							local v975 = table.pack(v953())

							if v975[1] then
								state = 36
							else
								state = 29
							end
						elseif state == 29 then
							v965 += n14

							if n14 <= 0 then
								state = 30
							else
								state = 31
							end
						elseif state == 30 then
							if v965 >= v966 then
								state = 44
							else
								state = 32
							end
						elseif state == 31 then
							if v965 <= v966 then
								state = 46
							else
								state = 32
							end
						elseif state == 32 then
							local v976 = table.pack(v946())

							if v976[1] then
								state = 35
							else
								state = 33
							end
						elseif state == 33 then
							Place._candKey = candKey
							Place._cands = cands
							state = 34
						else
							if state == 34 then
								return cands
							end

							if state == 35 then
								samples = (t176_308_1[3]).samples
								n14 = 2
								v966 = #samples + 0
								v965 = 1 - n14
								state = 29
							elseif state == 36 then
								v954 = t273_293_1[3]
								C_3_ = 2
								U_3_ = 1
								v962 = n12 - C_3_
								state = 25
							elseif state == 37 then
								v962 += C_3_

								if C_3_ <= 0 then
									state = 38
								else
									state = 40
								end
							elseif state == 38 then
								if v962 >= U_3_ then
									state = 39
								else
									state = 41
								end
							elseif state == 39 then
								v957 = n12
								state = 19
							elseif state == 40 then
								if v962 <= U_3_ then
									state = 18
								else
									state = 41
								end
							elseif state == 41 then
								v962 = v953
								U_3_ = U_3
								C_3_ = C_3

								local v977 = table.pack(v953())

								if v977[1] then
									state = 51
								else
									state = 42
								end
							elseif state == 42 then
								v965 += n14

								if n14 <= 0 then
									state = 43
								else
									state = 45
								end
							elseif state == 43 then
								if v965 >= v966 then
									state = 44
								else
									state = 47
								end
							elseif state == 44 then
								v950 = v965
								state = 13
							elseif state == 45 then
								if v965 <= v966 then
									state = 46
								else
									state = 47
								end
							elseif state == 46 then
								v950 = v965
								state = 13
							elseif state == 47 then
								local v978 = table.pack(v946())

								if v978[1] then
									state = 50
								else
									state = 48
								end
							elseif state == 48 then
								Place._candKey = candKey
								Place._cands = cands
								state = 49
							else
								if state == 49 then
									return cands
								end

								if state == 50 then
									samples = (t176_175_1[3]).samples
									n14 = 2
									v966 = #samples + 0
									v965 = 1 - n14
									state = 42
								elseif state == 51 then
									v954 = t273_160_1[3]
									C_3_ = 2
									U_3_ = 1
									v962 = n12 - C_3_
									state = 37
								elseif state == 52 then
									v962 = v953
									U_3_ = U_3
									C_3_ = C_3
									state = 14
								elseif state == 53 then
									v965 = v946
									v966 = U_1
									n14 = C_1
									state = 6
								end
							end
						end
					end
				end
			end
		end
	end

	do
		t1.Place.coverage = function(p261, p262, p263)
			local n15 = 0
			local huge = math.huge
			local v981 = t1._flat(p261)
			local v982 = p262 * p262

			for _, v in ipairs(t1.Paths.samples()) do
				local v985 = t1._flat(v.pos) - v981
				local v986 = v985.X * v985.X + v985.Z * v985.Z

				if v986 < huge then
					huge = v986
				end

				if v986 <= v982 then
					n15 += (p263 and p263(v.progress) or 1) * (v.w or 1)
				end
			end

			return n15, math.sqrt(huge)
		end
	end

	t1.Place.rowPitch = function(p264)
		local t66 = {}

		for _, v in ipairs(t1.Match.slots()) do
			if v.role ~= "Farm" then
				t66[#t66 + 1] = t1.Data.radius(v.id)
			end
		end

		if #t66 == 0 then
			for _, v in ipairs(t1.Match.slots()) do
				t66[#t66 + 1] = t1.Data.radius(v.id)
			end
		end

		table.sort(t66)

		local v992 = #t66
		local n16 = 1.75

		if v992 > 0 then
			n16 = v992 % 2 == 1 and t66[(v992 + 1) / 2] or (t66[v992 / 2] + t66[v992 / 2 + 1]) / 2
		end

		local n17 = 1.3

		return math.max(n17, n16 * 2 * (1 + (p264 or t1.Place.gap())) + 0.1)
	end
	t1.Place.hillSpots = function()
		return {}
	end
	t1.Cash = {
		holds = {},
		floor = {},
		busy = nil,
		waiters = {},
		names = {
			play = "Deploy",
			assist = "Deploy Assist",
			upgrade = "Upgrade",
			macro = "Strategy"
		}
	}

	do
		t1.Cash.expired = function(p265, p266)
			if p265.replied then
				return p266 - p265.replied > 4
			end

			return p266 - p265.at >= 13 or p265.thread ~= nil and coroutine.status(p265.thread) == "dead"
		end
	end

	do
		t1.Cash.reset = function()
			table.clear(t1.Cash.holds)
			t1.Cash.busy = nil
			t1.Cash.waiters = {}
		end
	end

	t1._cleanups[#t1._cleanups + 1] = t1.Cash.reset
	t1.Cash.held = function()
		local now = os.clock()
		local v996 = t1.Match.cash()
		local n18 = 0
		local holds = t1.Cash.holds

		for i = #holds, 1, -1 do
			local v1000 = holds[i]

			if v1000.done and (now - v1000.done > 1.5 or v996 <= v1000.cash0 - 0.9 * v1000.amount) or t1.Cash.expired(v1000, now) then
				table.remove(holds, i)

				if t1.Cash.busy == v1000 then
					t1.Cash.busy = nil
				end
			else
				n18 += v1000.amount
			end
		end

		return n18
	end
	t1.Cash.free = function(p267)
		return t1.Match.cash() - t1.Cash.held() - t1._n(p267)
	end
	t1.Cash.name = function(p268)
		local v1001 = t1.Cash.names[p268]

		if not v1001 then
			v1001 = t1._title(tostring(p268 or "Spend"))
		end

		return v1001
	end
	t1.Cash.wait = function(p269, p270)
		if not p269 then
			return
		end

		t1.Cash.waiters[p269] = true
		t1._alarm(p269, p270, p269 .. ":cash")
	end
	t1.Cash.claim = function(p271, p272)
		local v1002 = t1._owners[coroutine.running()]
		local v1003 = t1._n(p271)
		local v1004 = t1.Cash.held()
		local busy = t1.Cash.busy

		if busy then
			local now = os.clock()

			t1.Cash.wait(v1002, busy.replied and 4.1 - (now - busy.replied) or math.min(13 - (now - busy.at), 2))

			return nil, "busy", busy.who
		end

		local v1007 = t1.Match.cash()

		if not (v1007 - v1004 - t1._n(p272) < v1003) then
			local busy2 = {
				who = v1002,
				amount = v1003,
				at = os.clock(),
				cash0 = v1007,
				thread = coroutine.running()
			}

			t1.Cash.holds[#t1.Cash.holds + 1] = busy2
			t1.Cash.busy = busy2

			return busy2
		end

		if v1004 > 0 then
			t1.Cash.wait(v1002, 1.6)
		end

		return nil, "cash"
	end
	t1.Cash.replied = function(p273)
		if p273 then
			p273.replied = os.clock()
		end
	end
	t1.Cash.release = function(p274, p275)
		if not p274 then
			return
		end

		if p275 == false then
			p274.amount = 0
		end

		p274.replied = p274.replied or os.clock()
		p274.done = p274.done or os.clock()

		if t1.Cash.busy == p274 then
			t1.Cash.busy = nil
		end

		local waiters = t1.Cash.waiters

		if next(waiters) == nil then
			return
		end

		t1.Cash.waiters = {}

		for k in pairs(waiters) do
			if k ~= p274.who then
				t1._wake(k)
			end

			t1._alarm(k, 1.6, k .. ":cash")
		end
	end
	t1.Cash.price = function(p276, p277)
		local v1011 = t1.Cash.floor[p276]

		return v1011 and math.max(t1._n(p277), v1011) or p277
	end

	do
		t1.Cash.refused = function(p278, p279)
			if not p279 or not (p279.amount <= p279.cash0) then
				return
			end

			t1.Cash.floor[p278] = math.floor(p279.cash0) + 1

			return t1.Cash.floor[p278]
		end
	end

	do
		t1.Cash.busyText = function(p280)
			return "[WAITING] Awaiting " .. t1.Cash.name(p280) .. " | In Progress"
		end
	end

	t1.Cash.shared = function()
		return t12.AutoPlay and t12.AutoUpgrade and t12.UpgradeTiming == "Upgrade While Deploying" and t12.UpgradePriority == true
	end
	t1.Cash.upgradeKeep = function(p281)
		if not t1.Cash.shared() then
			return 0, nil
		end

		local plan = t1.Upg and t1.Upg.plan and t1.Upg.plan[1]

		if plan and p281.slot and plan.group < t1.Play.rank(p281) then
			return t1._n(plan.cost), plan
		end

		return 0, nil
	end

	do
		t1.Cash.turn = function()
			local want = t1.Play.want

			if not t1.Cash.shared() then
				if t12.AutoPlay and want and t1.Play.owner.running then
					local v1014 = t1.Cash.free(t12.CashReserve)

					if t1._n(want.cost) <= v1014 then
						return "play", want
					end
				end

				return "upgrade"
			end

			local running = want and t1.Play.owner.running and want or t1.Play.saving
			local plan = t1.Upg and t1.Upg.plan and t1.Upg.plan[1]

			if running and running.slot and (not plan or not (plan.group < t1.Play.rank(running))) then
				return "play", running
			end

			return "upgrade"
		end
	end

	t1.Play = {
		owner = {
			text = "[IDLE]"
		},
		fails = {},
		capped = {},
		done = false
	}

	local owner = t1.Play.owner

	t1._allWorkers[#t1._allWorkers + 1] = "play"
	t1.Play.count = function(p282)
		local n19 = 0

		for _, v in ipairs(t1.Match.towers()) do
			if v.id == p282 then
				n19 += 1
			end
		end

		return n19
	end
	t1.Play._counts = {}

	do
		t1.Play.counts = function(p283)
			local v1021 = t1.Data.cap(p283)

			if not v1021 then
				return nil
			end

			local v1022 = t1.Match.countOf(p283)

			return v1022, v1021, v1021 == 1, v1022 >= v1021 or t1.Match.maxedOut()
		end
	end

	do
		t1.Play.unique = function()
			return false
		end
	end

	t1.Play.typeLimit = function(p284)
		local _, v1024 = t1.Play.counts(p284)

		return v1024 or 5
	end
	t1.Play.full = function(p285)
		local v1025, _, _, v1028 = t1.Play.counts(p285)

		if v1025 then
			return v1028
		end

		return t1.Play.count(p285) >= t1.Play.typeLimit(p285) or t1.Match.maxedOut()
	end
	t1.Play.limit = function(p286)
		local huge = t1.Play.typeLimit(p286.id) or math.huge

		if not p286.slot then
			return huge
		end

		if t12.CustomPriority and t12["SlotPri" .. p286.slot] == "EXCLUDE" then
			return 0
		end

		local v1030 = tonumber(t12["SlotLimit" .. p286.slot])

		if v1030 then
			return math.min(huge, v1030)
		end

		return huge
	end

	do
		t1.Play.priority = function(p287)
			return tonumber(t12["SlotPri" .. p287]) or 99
		end
	end

	t1.Play.cooldown = function()
		return 0
	end

	do
		local t67 = {
			Balanced = {
				Damage = 1,
				Farm = 2,
				Support = 3
			},
			["Damage First"] = {
				Damage = 1,
				Support = 2,
				Farm = 3
			},
			["Economy First"] = {
				Farm = 1,
				Damage = 2,
				Support = 3
			},
			["Spread Evenly"] = {
				Damage = 1,
				Farm = 1,
				Support = 1
			}
		}

		t1.Play.rarities = function()
			if t1.Play._rarities then
				return t1.Play._rarities, true
			end

			local RarityOrder = t1.gameSettings().RarityOrder

			if type(RarityOrder) ~= "table" or next(RarityOrder) == nil then
				return table.clone(t2), false
			end

			t1.Play._rarities = t1.Rarities()

			return t1.Play._rarities, true
		end
		t1.Play.rarityOk = function(p288)
			local DeployRarities = t12.DeployRarities

			if type(DeployRarities) ~= "table" or #DeployRarities == 0 then
				return true
			end

			local v1034 = t1.Units.rarity(p288)

			if v1034 == "" or table.find(DeployRarities, v1034) then
				return true
			end

			return not t1.Play.rarityActive()
		end
		t1.Play.rarityActive = function()
			local DeployRarities = t12.DeployRarities

			if type(DeployRarities) ~= "table" or #DeployRarities == 0 then
				return false
			end

			local v1036 = t1.Play.rarities()

			for _, v in ipairs(v1036) do
				if table.find(DeployRarities, v) then
					continue
				end

				return true
			end

			return false
		end
		t1.Play.names = function(p289)
			if type(p289) == "table" then
				return table.concat(p289, ", ")
			end

			return ""
		end
		t1.Play.progress = function()
			local n20 = 0
			local n21 = 0

			for _, v in ipairs(t1.Match.slots()) do
				if t1.Play.rarityOk(v.id) then
					local v1043 = t1.Play.limit(v)
					local v1044 = t1.Play.count(v.id)

					if v1043 == math.huge then
						v1043 = v1044
					end

					n20 += math.min(v1044, v1043)
					n21 += v1043
				end
			end

			return n20, n21
		end
		t1.Play.rank = function(p290)
			if t12.CustomPriority then
				return t1.Play.priority(p290.slot)
			end

			for i, v in ipairs(t1.Play.order(t1.Match.slots(), {})) do
				if v.slot == p290.slot then
					return i
				end
			end

			return 99
		end
		t1.Play.order = function(p291, p292)
			local t68 = {}

			for _, v in ipairs(p291) do
				if t1.Play.rarityOk(v.id) then
					t68[#t68 + 1] = v
				end
			end

			local Balanced = t67.Balanced or t67.Balanced
			local v1051 = t12.FillSlotFirst == true
			local n22 = 0

			for _, v in ipairs(p291) do
				if v.role == "Damage" then
					n22 += p292[v.id] or 0
				end
			end

			local function v1055(p293)
				if p293.role == "Damage" and n22 > 0 then
					return 2
				end

				if p293.role == "Farm" and n22 > 0 then
					return 1
				end

				return Balanced[p293.role] or 3
			end

			table.sort(t68, function(p294, p295)
				local v1056 = p292[p294.id] or 0
				local v1057 = p292[p295.id] or 0

				if t12.CustomPriority then
					local v1058 = t1.Play.priority(p294.slot)
					local v1059 = t1.Play.priority(p295.slot)

					if not (v1051 or v1056 == v1057) then
						return v1056 < v1057
					end

					if v1058 == v1059 then
						return p294.slot < p295.slot
					end

					return v1058 < v1059
				end

				local v1060 = v1055(p294)
				local v1061 = v1055(p295)

				if v1060 ~= v1061 then
					return v1060 < v1061
				end

				if v1056 == v1057 then
					return p294.slot < p295.slot
				end

				return v1056 < v1057
			end)

			return t68
		end
	end

	t1.Play.savingSince = {}
	t1.Play.pick = function(p296)
		local t69 = {}

		for _, v in ipairs(p296) do
			t69[v.id] = (t69[v.id] or 0) + 1
		end

		local v1065 = t1._owners[coroutine.running()] == "play"
		local unplaced = false

		local function v1067(...)
			if v1065 then
				t1.Play.unplaced = unplaced
			end

			return ...
		end

		local v1068, v1069, v1070 = t1.Sell.phase()

		if v1068 then
			return v1067(nil, nil, "sold")
		end

		local v1071 = t1.Match.slots()

		if #v1071 == 0 then
			return v1067(nil, nil, "empty")
		end

		local v1072 = t1.Play.order(v1071, t69)

		if #v1072 == 0 then
			return v1067(nil, nil, "rarity")
		end

		local v1073 = t1.Match.cash()
		local v1074 = t1._n(t12.CashReserve)
		local v1075 = t1._has(t12.DeployActions, "Save For Top Pick")
		local v1076 = t1._has(t12.DeployActions, "Skip Late Farms")
		local v1077 = t1.Match.wavesLeft()
		local v1078
		local v1079
		local v1080
		local v1081
		local v1082

		for _, v in ipairs(v1072) do
			local v1085 = t1.Play.limit(v)
			local v1086 = v.role == "Farm" and (v1069 and t1.Sell.farmPicked(v.id) or v1076 and v1077 < 6)
			local v1087 = t1.Play.capped[v.id] and t1.Play.full(v.id)
			local v1088 = t1.Play.fails[v.id] and t1.Play.fails[v.id] > os.clock()

			if (t69[v.id] or 0) < v1085 and not v1086 and not v1087 and (not v1070 or not v1070[v.name]) and v1088 and not t1.Play.full(v.id) and not t1.Play.unsaved(v) then
				v1081 = v1081 or v
			end

			if not ((t69[v.id] or 0) < v1085) or v1086 or v1087 or v1070 and v1070[v.name] or v1088 or t1.Play.full(v.id) or t1.Play.unsaved(v) then
				continue
			end

			unplaced = true

			local v1089 = t1.Play.cooldown(v.id)

			if v1089 > 0 then
				v1079 = v1079 and math.min(v1079, v1089) or v1089

				continue
			end

			local v1090 = t1.Data.placeCost(v.id)

			v.cost = v1090

			local v1091, v1092 = t1.Cash.upgradeKeep(v)

			if v1090 <= v1073 - v1074 - v1091 then
				table.clear(t1.Play.savingSince)

				return v1067(v)
			end

			if v1092 and v1090 <= v1073 - v1074 then
				v1080 = v1080 or v1092
			end

			if not v1082 or v1090 < v1082.cost then
				v1082 = v
			end

			if v1075 and not (v1078 or v1092) then
				local now = t1.Play.savingSince[v.id] or os.clock()

				t1.Play.savingSince[v.id] = now

				local v1094 = t1._n(t12.TopPickWait)

				if not (v1094 <= 0) and not (os.clock() - now < v1094) then
					v1078 = v

					continue
				end

				if v1094 > 0 then
					t1._alarm("play", v1094 - (os.clock() - now) + 0.1, "play:toppick")
				end

				return v1067(nil, v, "cash")
			end
		end

		if v1078 then
			return v1067(nil, v1078, "cash")
		end

		if v1080 then
			return v1067(nil, nil, "upgrade", v1080)
		end

		if v1079 then
			t1._alarm("play", v1079 + 0.1, "play:cooldown")

			return v1067(nil, nil, "cooldown", v1079)
		end

		if v1081 then
			return v1067(nil, nil, "space", v1081)
		end

		if v1082 then
			return v1067(nil, nil, "poor", v1082)
		end

		return v1067(nil, nil, "done")
	end

	local t70 = {
		["Smart Deploy"] = function(p297)
			return 1.3 - 0.6 * p297
		end
	}

	t1.Cover = {}
	t1.Cover.share = function()
		return math.clamp(t1._n(t12.DeployCoverage, 100), 10, 100)
	end

	do
		t1.Cover.from = function()
			local CoverageFrom = t12.CoverageFrom

			if CoverageFrom == "Center" or CoverageFrom == "Last" then
				return CoverageFrom
			end

			return "Front"
		end
	end

	t1.Cover.window = function()
		local v1097 = t1.Cover.share()

		if v1097 >= 100 then
			return nil
		end

		local v1098 = v1097 / 100
		local v1099 = t1.Cover.from()
		local v1100 = v1099 == "Last" and 1 - v1098 or v1099 == "Center" and (1 - v1098) / 2 or 0

		return v1100, v1100 + v1098
	end
	t1.Cover.mode = function()
		return "Smart Deploy"
	end

	do
		t1.Cover.text = function()
			local v1101 = t1.Cover.share()

			return v1101 >= 100 and "Whole Lane" or t1.Cover.from() .. " " .. v1101 .. "% Of Each Lane"
		end
	end

	t1.Cover.short = function()
		return t1.Cover.from() .. " " .. t1.Cover.share() .. "%"
	end
	t1.Cover.span = function()
		local v1102, v1103 = t1.Cover.window()

		if v1102 then
			return math.floor(v1102 * 100 + 0.5) .. "-" .. math.floor(v1103 * 100 + 0.5) .. "%"
		end

		return "0-100%"
	end
	t1.Cover.inside = function(p298)
		local v1104, v1105 = t1.Cover.window()

		return not v1104 or p298 == nil or p298 >= v1104 - 1e-06 and p298 <= v1105 + 1e-06
	end
	t1.Cover.key = function()
		return t1.Cover.share() .. ":" .. t1.Cover.from()
	end
	t1.Cover.weight = function(p299, p300)
		local v1106, v1107 = t1.Cover.window()

		if not v1106 then
			return p300
		end

		local function v1108(p301)
			if p301 < v1106 - 1e-06 or v1107 + 1e-06 < p301 then
				return 0
			end

			return p300(p301)
		end

		return v1108
	end
	t16 = {
		reach = 24,
		corner = 35,
		farm = 2,
		touch = 1.6
	}
	t1.Plan = {
		ghosts = {},
		ghostFail = {}
	}
	t1.Plan.segDist = function(p302, p303, p304)
		local v1109 = p304.X - p303.X
		local v1110 = p304.Z - p303.Z
		local v1111 = p302.X - p303.X
		local v1112 = p302.Z - p303.Z
		local v1113 = v1109 * v1109 + v1110 * v1110
		local v1114 = v1113 > 0 and math.clamp((v1111 * v1109 + v1112 * v1110) / v1113, 0, 1) or 0
		local v1115 = v1111 - v1109 * v1114
		local v1116 = v1112 - v1110 * v1114

		return math.sqrt(v1115 * v1115 + v1116 * v1116)
	end
	t1.Plan.laneDist = function(p305, p306)
		local huge = math.huge

		for _, path in ipairs(p305.paths) do
			local points = path.points

			for i = 1, #points - 1 do
				huge = math.min(huge, t1.Plan.segDist(p306, points[i], points[i + 1]))
			end
		end

		return huge
	end

	do
		t1.Plan.offset = function(p307, p308, p309)
			local points = p307.points
			local t71 = {}
			local v1124 = #points
			local n23 = 0
			local v1126

			for i = 1, v1124 do
				if i > 1 then
					n23 += t1._flat(points[i] - points[i - 1]).Magnitude
				end

				local Unit

				if i < v1124 then
					local v1129 = t1._flat(points[i + 1] - points[i])

					if v1129.Magnitude > 0.001 then
						Unit = v1129.Unit
					end
				end

				local v1130 = points[i]

				if v1126 and Unit then
					local v1131 = Vector3.new(-v1126.Z, 0, v1126.X) * p309
					local v1132 = Vector3.new(-Unit.Z, 0, Unit.X) * p309
					local v1133 = math.deg(math.acos(math.clamp(v1126:Dot(Unit), -1, 1)))
					local v1134 = v1131 + v1132
					local v1135 = v1134.Magnitude > 0.001 and v1134.Unit:Dot(v1132) or 0

					if v1135 >= 0.5 then
						t71[#t71 + 1] = {
							pos = v1130 + v1134.Unit * (p308 / v1135),
							dist = n23,
							turn = v1133
						}
					else
						t71[#t71 + 1] = {
							pos = v1130 + v1131 * p308,
							dist = n23,
							turn = v1133
						}
						t71[#t71 + 1] = {
							pos = v1130 + v1132 * p308,
							dist = n23,
							turn = v1133
						}
					end
				elseif v1126 or Unit then
					local v1136 = v1126 or Unit

					t71[#t71 + 1] = {
						pos = v1130 + Vector3.new(-v1136.Z, 0, v1136.X) * p309 * p308,
						dist = n23,
						turn = 0
					}
				end

				v1126 = Unit or v1126
			end

			return t71
		end
	end

	t1.Plan.slots = function()
		local v1137 = t1.Paths.get()

		if not v1137 then
			return nil
		end

		local Plan = t1.Plan
		local v1139 = t1.Place.rowPitch()
		local v1140 = v1139 / 2 + 0.1
		local slotKey = tostring(v1137) .. ":" .. v1139 .. ":" .. tostring(t1.Place.roadBlocks())

		if Plan._slotKey == slotKey and Plan._slots then
			return Plan._slots
		end

		local v1142 = t1.Match.mapId()
		local n24 = 0

		local function v1144(p310)
			n24 += p310

			if n24 < 120 then
				return true
			end

			n24 = 0
			task.wait()

			return t1.Running and t1.Match.mapId() == v1142
		end

		local slots = {}
		local t72 = {}
		local v1147 = (v1139 * 0.9) ^ 2

		local function v1148(p311)
			local v1149 = math.floor(p311.X / v1139)
			local v1150 = math.floor(p311.Z / v1139)

			for i = -1, 1 do
				for i2 = -1, 1 do
					local ipairs_ = ipairs
					local v1154 = t72[v1149 + i .. ":" .. v1150 + i2] or {}

					for _, v in ipairs_(v1154) do
						local v1157 = v.pos - p311

						if v1157.X * v1157.X + v1157.Z * v1157.Z < v1147 then
							return true
						end
					end
				end
			end

			return false
		end

		local n25 = 0

		for _, path in ipairs(v1137.paths) do
			n25 += math.max(#path.points - 1, 0)
		end

		for _, path in ipairs(v1137.paths) do
			for i = -1, 1, 2 do
				local t73 = {}

				for i2 = 1, #path.samples, 4 do
					local v1166 = path.samples[i2]
					local dir = v1166.dir or Vector3.new(0, 0, 1)
					local v1168 = Vector3.new(-dir.Z, 0, dir.X) * i

					for i3 = 0, t16.reach, 0.5 do
						local v1170 = v1166.pos + v1168 * i3
						local v1171 = t1.Place.open(v1170.X, v1170.Z)

						if v1144(2) then
							if not v1171 then
								continue
							end

							t73[#t73 + 1] = i3

							break
						end

						return nil
					end
				end

				if #t73 > 0 then
					table.sort(t73)

					local v1172 = t73[math.ceil(#t73 / 2)] + v1140

					for i2, v in ipairs({
						v1172,
						v1172 + v1139,
						v1172 + t16.farm * v1139
					}) do
						local t74 = {}
						local v1176 = t1.Plan.offset(path, v, i)
						local t75 = {}
						local n26 = 0

						for i3, v2 in ipairs(v1176) do
							if i3 > 1 then
								n26 += t1._flat(v2.pos - v1176[i3 - 1].pos).Magnitude
							end

							t75[i3] = n26
						end

						local t76 = {}

						for i3, v2 in ipairs(v1176) do
							if t16.corner <= v2.turn then
								t76[#t76 + 1] = t75[i3]
							end
						end

						local v1184 = 4 + math.ceil(n25 / 16 + #t76 / 32)
						local v1185 = v1139 / 2

						for i3 = 1, #v1176 - 1 do
							local v1187 = v1176[i3]
							local v1188 = v1176[i3 + 1]
							local Magnitude = t1._flat(v1188.pos - v1187.pos).Magnitude

							while v1185 <= Magnitude do
								local v1190 = Magnitude > 0 and v1185 / Magnitude or 0
								local v1191 = v1187.pos:Lerp(v1188.pos, v1190)
								local v1192 = t1.Place.open(v1191.X, v1191.Z)

								if v1192 and math.abs(v1192.Y - v1191.Y) < 6 and v1172 - 0.5 <= t1.Plan.laneDist(v1137, v1192) and not v1148(v1192) and not t1.Place.inBounds(v1192) then
									local v1193 = t75[i3] + v1185
									local v1194 = false

									for _, v2 in ipairs(t76) do
										if math.abs(v2 - v1193) <= v1139 * 1.5 then
											v1194 = true

											break
										end
									end

									local t77 = {
										pos = v1192,
										key = "plan:" .. math.floor(v1192.X * 2) .. ":" .. math.floor(v1192.Z * 2),
										lane = i2,
										path = path.index,
										sign = i,
										corner = v1194,
										chain = t74,
										progress = math.clamp((v1187.dist + (v1188.dist - v1187.dist) * v1190) / path.length, 0, 1)
									}

									t74[#t74 + 1] = t77
									t77.ci = #t74

									local v1198 = math.floor(v1192.X / v1139) .. ":" .. math.floor(v1192.Z / v1139)

									t72[v1198] = t72[v1198] or {}
									table.insert(t72[v1198], t77)
									slots[#slots + 1] = t77
								end

								v1185 += v1139

								if v1144(v1184) then
									continue
								end

								return nil
							end

							v1185 -= Magnitude
						end
					end
				end
			end
		end

		Plan._slotKey = slotKey
		Plan._slots = slots

		return slots
	end
	t1.Plan.reach = function(p312, p313, p314)
		p312.inr = p312.inr or {}

		local v1199 = math.floor(p313 * 2)
		local v1200 = p312.inr[v1199]

		if v1200 then
			return v1200
		end

		local t78 = {}
		local t79 = {}
		local v1203 = t1._flat(p312.pos)
		local v1204 = p313 * p313

		for i, v in ipairs(p314) do
			local v1207 = t1._flat(v.pos) - v1203

			if v1207.X * v1207.X + v1207.Z * v1207.Z <= v1204 then
				t78[#t78 + 1] = i

				local v1208 = t79[v.path] or {}

				t79[v.path] = v1208
				v1208[#v1208 + 1] = v.dist
			end
		end

		local n27 = 0

		for _, v in pairs(t79) do
			table.sort(v)
			n27 += 1

			for i = 2, #v do
				if v[i] - v[i - 1] > 5 then
					n27 += 1
				end
			end
		end

		local t80 = {
			list = t78,
			passes = n27
		}

		p312.inr[v1199] = t80

		return t80
	end
	t1.Plan.weights = function(p315, p316)
		local v1214 = t1.Paths.get()

		if not v1214 then
			return nil
		end

		local samples = v1214.samples
		local v1216 = t1.Cover.weight(p316, t70[p316] or t70["Smart Deploy"])
		local v1217, v1218 = t1.Cover.window()
		local v1219 = t1.Paths.selected()
		local t81 = {}

		for _, path in ipairs(v1214.paths) do
			if not v1219 or v1219[path.index] then
				t81[path.pathIndex] = path.index
			end
		end

		local t82 = {}
		local t83 = {}
		local t84 = {}

		for i, sample in ipairs(samples) do
			local v1228 = false
			local pairs_ = pairs
			local walkers = sample.walkers or {}

			for k in pairs_(walkers) do
				if t81[k] then
					v1228 = true
				end
			end

			t84[i] = v1228 and (not v1217 or sample.progress >= v1217 - 1e-06 and sample.progress <= v1218 + 1e-06)

			local v1232 = v1228

			if v1232 then
				v1232 = v1216(sample.progress) * (sample.w or 1)
			end

			t82[i] = v1232 or 0
			t83[i] = 0
		end

		for _, v in ipairs(p315) do
			if v.pos and t1.Data.role(v.id) ~= "Farm" then
				local v1235 = math.max(v.range or t1.Data.range(v.id, v.level), 4)
				local v1236 = t1._flat(v.pos)
				local v1237 = v1235 * v1235

				for i, sample in ipairs(samples) do
					if t82[i] > 0 or t84[i] then
						local v1240 = t1._flat(sample.pos) - v1236

						if v1240.X * v1240.X + v1240.Z * v1240.Z <= v1237 then
							t83[i] += 1
							t82[i] *= 0.5
						end
					end
				end
			end
		end

		local t85 = {}
		local n28 = 0
		local n29 = 0

		for i in ipairs(samples) do
			if t84[i] then
				n28 += 1

				if t83[i] > 0 then
					n29 += 1
				end
			end
		end

		for k, v in pairs(t81) do
			local n30 = 0
			local n31 = 0

			for i, sample in ipairs(samples) do
				if t84[i] and sample.walkers[k] then
					n30 += 1

					if t83[i] > 0 then
						n31 += 1
					end
				end
			end

			t85[v] = {
				num = k,
				total = n30,
				covered = n31,
				share = n30 > 0 and n31 / n30 or 1
			}
		end

		return {
			samples = samples,
			base = t82,
			hits = t83,
			want = t84,
			shares = t85,
			all = n28 > 0 and n29 / n28 or 1
		}
	end
	t1.Plan.coverage = function()
		local Plan = t1.Plan
		local v1252 = t1.Match.towers()
		local v1253 = t1.Cover.mode()
		local covKey = #v1252 .. ":" .. t1.Paths.selKey() .. ":" .. t1.Cover.key() .. ":" .. t1.Paths.rev .. ":" .. tostring(v1253)

		if Plan._covKey == covKey then
			if os.clock() - (Plan._covAt or 0) < 2 then
				return Plan._cov
			end
		end

		local v1255 = t1.Plan.weights(v1252, v1253)
		local now = os.clock()
		local cov = v1255 and {
			shares = v1255.shares,
			all = v1255.all,
			block = t1.Plan.blockSpan(v1252)
		}

		Plan._covKey = covKey
		Plan._covAt = now
		Plan._cov = cov

		return Plan._cov
	end
	t1.Plan.blockSpan = function(p317)
		local v1258
		local v1259
		local n32 = 0
		local t86 = {}

		for _, v in ipairs(p317) do
			if v.pos and t1.Data.role(v.id) ~= "Farm" then
				local v1264 = t1.Paths.nearest(v.pos)

				if v1264 and v1264.progress then
					n32 += 1
					v1258 = math.min(v1258 or 1, v1264.progress)
					v1259 = math.max(v1259 or 0, v1264.progress)

					if v1264.path then
						t86[v1264.path] = true
					end
				end
			end
		end

		if n32 == 0 then
			return nil
		end

		local t87 = {}

		for k in pairs(t86) do
			t87[#t87 + 1] = k
		end

		table.sort(t87)

		return {
			n = n32,
			lo = v1258,
			hi = v1259,
			paths = t87
		}
	end
	t1.Plan.coverText = function()
		local v1267 = t1.Plan.coverage()

		if not v1267 then
			return ""
		end

		local t88 = {}

		for k in pairs(v1267.shares) do
			t88[#t88 + 1] = k
		end

		table.sort(t88)

		local t89 = {}

		for _, v in ipairs(t88) do
			t89[#t89 + 1] = "Path " .. v .. " | " .. math.floor(v1267.shares[v].share * 100 + 0.5) .. "%"
		end

		if #t88 > 1 then
			t89[#t89 + 1] = "Paths " .. table.concat(t88, "+") .. " | " .. math.floor(v1267.all * 100 + 0.5) .. "%"
		end

		local block = v1267.block

		if block then
			local v1274 = #block.paths > 0

			if v1274 then
				v1274 = (#block.paths > 1 and "Paths " or "Path ") .. table.concat(block.paths, "+") .. " "
			end

			v1274 = v1274 or ""
			t89[#t89 + 1] = "Block | " .. v1274 .. math.floor(block.lo * 100) .. "-" .. math.ceil(block.hi * 100) .. "% | " .. block.n .. (block.n == 1 and " Unit" or " Units")
		end

		return #t89 > 0 and "\n" .. table.concat(t89, "\n") or ""
	end
	t1.Plan.savedPoints = function()
		local v1275 = type(t12.Positions) == "table"

		if v1275 then
			v1275 = t12.Positions[t1.Match.mapId() or ""]
		end

		local t90 = {}
		local v1277 = type(v1275) == "table" and v1275 or {}

		for _, v in pairs(v1277) do
			local ipairs_ = ipairs
			local v1281 = type(v) == "table" and v or {}

			for _, v2 in ipairs_(v1281) do
				if type(v2) == "table" then
					t90[#t90 + 1] = Vector3.new(t1._n(v2[1]), t1._n(v2[2]), t1._n(v2[3]))
				end
			end
		end

		return t90
	end
	t1.Plan.near = function(p318, p319)
		local huge = math.huge
		local v1285 = t1._flat(p319)

		for _, v in ipairs(p318) do
			huge = math.min(huge, (t1._flat(v) - v1285).Magnitude)
		end

		return huge
	end

	do
		t1.Plan.onHill = function(p320, p321, p322)
			local v1288 = t1._flat(p321)
			local v1289 = (p322 * 0.8) ^ 2

			for _, v in ipairs(p320) do
				local v1292 = t1._flat(v.pos) - v1288

				if v1292.X * v1292.X + v1292.Z * v1292.Z <= v1289 and v.pos.Y - 1.5 < p321.Y then
					return v.hill
				end
			end

			return nil
		end
	end

	t1.Plan.spot = function(p323, p324, p325, p326)
		local v1293 = t1.Plan.slots()

		if not v1293 then
			return nil, "map"
		end

		t1.Paths.watch()

		local v1294 = t1.Plan.weights(p324, p326)

		if not v1294 then
			return nil, "map"
		end

		local samples = v1294.samples
		local base = v1294.base
		local v1297 = t1.Data.profile(p323.id, p323.entry)
		local role = v1297.role
		local v1299 = t1.Place.rowPitch()
		local v1300 = t1.Cover.window()
		local v1301
		local n33 = 0

		for k, share in pairs(v1294.shares) do
			n33 += 1

			if share.total > 0 and share.covered == 0 and (not v1301 or k < v1301) then
				v1301 = k
			end
		end

		if n33 < 2 or role == "Farm" then
			v1301 = nil
		end

		if v1301 then
			local v1305 = v1294.shares[v1301].num

			base = table.clone(base)

			for i, sample in ipairs(samples) do
				if sample.walkers[v1305] then
					base[i] *= 3
				end
			end
		end

		local v1308 = t1.Place.hillSpots()
		local t91 = {}
		local t92 = {}
		local t93 = {}
		local t94 = {}
		local t95 = {}
		local t96 = {}
		local t97 = {}

		for _, v in ipairs(p324) do
			if v.pos then
				local v1318 = t1.Data.role(v.id)

				if v1318 == "Farm" then
					t94[#t94 + 1] = v.pos
				else
					t93[#t93 + 1] = v.pos

					local v1319 = #v1308 > 0 and t1.Plan.onHill(v1308, v.pos, v1299)

					if v1319 then
						t92[#t92 + 1] = v.pos
						t97[v1319] = true
					else
						t91[#t91 + 1] = v.pos
					end
				end

				if v1318 == "Damage" then
					t95[#t95 + 1] = v.pos

					local v1320 = t1.Paths.nearest(v.pos)

					t96[#t95] = v1320 and v1320.walkers or {}
				end
			end
		end

		local v1321

		if #t93 > 0 then
			local vector3 = Vector3.zero

			for _, v in ipairs(t93) do
				vector3 += v
			end

			v1321 = vector3 / #t93
		end

		local progress

		for i, sample in ipairs(samples) do
			if v1294.want[i] and v1294.hits[i] > 0 and (not progress or sample.progress < progress) then
				progress = sample.progress
			end
		end

		local v1328 = false
		local v1329 = false

		if role ~= "Farm" then
			local huge = math.huge
			local v1331 = false

			for _, v in ipairs(t1.Match.slots()) do
				if not (v.role == "Farm" or v.role == "Support" or v.id == p323.id or t1.Data.hill(v.id)) then
					local v1334 = t1.Data.profile(v.id, v.entry)
					local v1335 = t1.Play.count(v.id) < t1.Play.limit(v)

					if v1334.range < huge then
						huge = v1334.range
						v1331 = v1335
					end

					if v1335 and v1297.dps < v1334.dps then
						v1329 = true
					end
				end
			end

			v1328 = v1331 and v1297.range >= huge * 1.6
		end

		local v1336 = role == "Support" and not v1297.hold and #t95 > 0
		local t98 = {}

		if v1297.hill then
			for _, v in ipairs(v1308) do
				t98[#t98 + 1] = v
			end
		else
			for _, v in ipairs(v1293) do
				if role == "Farm" == (v.lane == 3) then
					t98[#t98 + 1] = v
				end
			end

			if v1297.hybrid and role ~= "Farm" then
				for _, v in ipairs(v1308) do
					t98[#t98 + 1] = v
				end
			end
		end

		if #t98 == 0 then
			return nil, "none"
		end

		if v1300 and not v1336 then
			local t99 = {}

			for _, v in ipairs(t98) do
				if v.progress and t1.Cover.inside(v.progress) then
					t99[#t99 + 1] = v
				end
			end

			if #t99 == 0 then
				local v1347
				local v1348 = role == "Farm" and "space" or "full"

				return v1347, v1348
			end

			t98 = t99
		end

		local v1349 = t1.Plan.savedPoints()
		local t100 = {}

		local function v1351(p327)
			local v1352 = t100[p327]

			if v1352 then
				return v1352[1], v1352[2], v1352[3]
			end

			local v1353 = t1.Plan.reach(p327, v1297.range, samples)
			local n34 = 0
			local n35 = 0

			for _, v in ipairs(v1353.list) do
				local v1358 = base[v]

				n34 += v1358

				if progress and samples[v].progress <= progress + 0.02 then
					n35 += v1358
				end
			end

			t100[p327] = {
				n34,
				n35,
				v1353.passes
			}

			return n34, n35, v1353.passes
		end

		local t101 = {}

		for i, v in ipairs(t98) do
			if not t1.Place.isRefused(v.key) and (#v1349 == 0 or v1299 <= t1.Plan.near(v1349, v.pos)) then
				local v1362
				local s4

				if role == "Farm" then
					if #t94 > 0 then
						v1362 = -t1.Plan.near(t94, v.pos)
						s4 = "Back Row, Beside Farms"
					elseif #t93 > 0 and v1300 then
						v1362 = -t1.Plan.near(t93, v.pos)
						s4 = "Back Row, Behind Block"
					elseif #t93 > 0 then
						v1362 = math.min(t1.Plan.near(t93, v.pos), 80)
						s4 = "Back Row, Away From Block"
					else
						v1362 = v.progress or 0
						s4 = "Back Row"
					end
				elseif v1336 then
					local n36 = 0
					local t102 = {}
					local n37 = 0

					for i2, v2 in ipairs(t95) do
						if (t1._flat(v2) - t1._flat(v.pos)).Magnitude <= v1297.range then
							n36 += 1

							for k in pairs(t96[i2]) do
								t102[k] = true
							end
						end
					end

					for _ in pairs(t102) do
						n37 += 1
					end

					if n36 > 0 then
						v1362 = n36 * 10 + n37 * 5 - t1.Plan.near({ v1321 }, v.pos) * 0.05
						s4 = n36 .. " In Aura"
					end
				else
					local v1371, v1372, v1373 = v1351(v)

					if v1371 > 0 then
						local v1374 = 1 + (v1297.area and 0.3 or 0.1) * math.min(v1373 - 1, 3)

						if v.corner and v1297.area then
							v1374 *= 1.15
						end

						if v.lane == 1 and v1328 then
							v1374 *= 0.75
						elseif v.lane == 2 and not v1328 then
							v1374 *= 0.9
						end

						if v.hill then
							if v.edge then
								v1374 *= 1.15
							end

							if t97[v.hill] then
								v1374 *= 1.1
							end
						end

						if v1297.hybrid then
							if #(v.hill and t92 or t91) == 0 and #(v.hill and t91 or t92) > 0 then
								v1374 *= 0.8
							end
						end

						if v1329 and v1373 >= 2 then
							v1374 *= 0.85
						end

						if (v1297.hold or v1297.summon) and progress then
							v1374 *= 1 + 0.6 * v1372 / v1371
						end

						v1362 = v1371 * v1374

						local t103 = { v.hill and "Hill" or "Lane " .. tostring(v.lane) }

						if v.hill and v.edge then
							t103[#t103 + 1] = "Front Row"
						end

						if v1301 then
							t103[#t103 + 1] = "Path " .. v1301 .. " Uncovered"
						end

						if v.corner then
							t103[#t103 + 1] = "Corner"
						end

						if v1373 >= 2 then
							t103[#t103 + 1] = v1373 .. " Passes"
						end

						if (v1297.hold or v1297.summon) and v1372 > 0 then
							t103[#t103 + 1] = "Road Entry"
						end

						if v1300 then
							t103[#t103 + 1] = "In Coverage " .. t1.Cover.span()
						end

						s4 = table.concat(t103, ", ")
					end
				end

				if v1362 then
					t101[#t101 + 1] = {
						c = v,
						score = v1362,
						why = s4
					}
				end
			end

			if i % 100 == 0 then
				task.wait()
			end
		end

		if #t101 == 0 then
			local v1376
			local v1377 = role == "Farm" and "space" or "full"

			return v1376, v1377
		end

		if not (role == "Farm" or v1336) then
			for _, v in ipairs(t101) do
				local c = v.c

				if #(c.hill and t92 or t91) == 0 then
					if c.chain then
						for i = -2, 2 do
							local v1382 = i ~= 0 and c.chain[c.ci + i]

							if v1382 and t1.Cover.inside(v1382.progress) then
								v.score += 0.5 * v1351(v1382)
							end
						end
					else
						local ipairs_ = ipairs
						local nb = c.nb or {}

						for _, v2 in ipairs_(nb) do
							if t1.Cover.inside(v2.progress) then
								v.score += 0.5 * v1351(v2)
							end
						end
					end
				end
			end
		end

		table.sort(t101, function(p328, p329)
			if p328.score == p329.score then
				return p328.c.key < p329.c.key
			end

			return p328.score > p329.score
		end)

		local v1387 = t16.touch * v1299
		local v1388 = t1.Data.radius(p323.id)
		local v1389 = t1.Place.gap()

		local function v1390(p330)
			local n38 = 0

			for _, v in ipairs(t101) do
				local hill = role == "Farm" and t94 or v.c.hill and t92 or t91

				if p330 and #hill ~= 0 and not (t1.Plan.near(hill, v.c.pos) <= v1387) then
					continue
				end

				n38 += 1

				if n38 > 40 then
					return nil
				end

				local v1395, v1396 = t1.Place.check(v.c.pos, p323.id, v1388, p325, v1389)

				if v1395 then
					v.at = v1396

					return v
				end
			end

			return nil
		end

		local v1397 = not v1301 and v1390(true) or nil or v1390(false)

		if not v1397 then
			return nil, "space"
		end

		local t104 = {
			pos = v1397.at or v1397.c.pos,
			key = v1397.c.key,
			why = v1397.why
		}

		return t104
	end
	t16.pod = {
		{
			0,
			0
		},
		{
			-1,
			0,
			1
		},
		{
			1,
			0,
			1
		},
		{
			-0.5,
			1,
			2,
			1
		},
		{
			0.5,
			1,
			1,
			3
		},
		{
			2,
			0,
			3
		},
		{
			1.5,
			1,
			3,
			6
		},
		{
			0,
			2,
			4,
			5
		},
		{
			1,
			2,
			5,
			7
		},
		{
			-1,
			2,
			4
		}
	}
	t16.caps = {
		5,
		7,
		10
	}
	t16.tries = 40
	t16.PATTERNS = {
		Honeycomb = {
			a = {
				1,
				0
			},
			b = {
				0.5,
				0.866
			},
			sites = { {
				0,
				0,
				{
					{
						0,
						0.48497422611928565
					},
					{
						0.42,
						0.24248711305964282
					},
					{
						0.42,
						-0.24248711305964282
					},
					{
						0,
						-0.48497422611928565
					},
					{
						-0.42,
						-0.24248711305964282
					},
					{
						-0.42,
						0.24248711305964282
					}
				}
			} }
		},
		Square = {
			a = {
				1,
				0
			},
			b = {
				0,
				1
			},
			sites = { {
				0,
				0,
				{
					{
						0.42,
						0.42
					},
					{
						0.42,
						-0.42
					},
					{
						-0.42,
						-0.42
					},
					{
						-0.42,
						0.42
					}
				}
			} }
		},
		Diamond = {
			a = {
				1.414,
				0
			},
			b = {
				0.707,
				0.707
			},
			sites = { {
				0,
				0,
				{
					{
						0.6,
						0
					},
					{
						0,
						-0.6
					},
					{
						-0.6,
						0
					},
					{
						0,
						0.6
					}
				}
			} }
		},
		Brick = {
			a = {
				1.7,
				0
			},
			b = {
				0.85,
				1
			},
			sites = { {
				0,
				0,
				{
					{
						0.78,
						0.42
					},
					{
						0.78,
						-0.42
					},
					{
						-0.78,
						-0.42
					},
					{
						-0.78,
						0.42
					}
				}
			} }
		},
		Triangle = {
			a = {
				1.8,
				0
			},
			b = {
				0.9,
				1.5588
			},
			sites = {
				{
					0.9,
					0.5196,
					{
						{
							-0.738,
							-0.42607199999999995
						},
						{
							0.738,
							-0.42607199999999995
						},
						{
							0,
							0.8521439999999999
						}
					}
				},
				{
					1.8,
					1.0392,
					{
						{
							0,
							-0.8521439999999999
						},
						{
							0.738,
							0.42607199999999995
						},
						{
							-0.738,
							0.42607199999999995
						}
					}
				}
			}
		}
	}
	t16.PATTERN_LIST = {
		"Honeycomb",
		"Square",
		"Diamond",
		"Brick",
		"Triangle",
		"Random"
	}
	t1.Plan.design = function()
		local GridDesign = t12.GridDesign

		if not (GridDesign == "Random" or t16.PATTERNS[GridDesign]) then
			GridDesign = "Honeycomb"
		end

		return GridDesign, false
	end

	do
		t1.Plan.midRange = function()
			local t105 = {}

			for _, v in ipairs(t1.Match.slots()) do
				if v.role ~= "Farm" and v.role ~= "Support" and not t1.Data.hill(v.id) and t1.Play.rarityOk(v.id) then
					t105[#t105 + 1] = t1.Data.range(v.id, 1)
				end
			end

			if #t105 == 0 then
				return 12, 12
			end

			table.sort(t105)

			return math.max(t105[math.ceil(#t105 / 2)], 4), math.max(t105[1], 4)
		end
	end

	t1.Plan.hillRange = function()
		local t106 = {}

		for _, v in ipairs(t1.Match.slots()) do
			if v.role ~= "Farm" and v.role ~= "Support" and (t1.Data.hill(v.id) or t1.Data.hybrid(v.id)) and t1.Play.rarityOk(v.id) then
				t106[#t106 + 1] = t1.Data.range(v.id, 1)
			end
		end

		if #t106 == 0 then
			return 12
		end

		table.sort(t106)

		return math.max(t106[math.ceil(#t106 / 2)], 4)
	end
	t1.Plan.hillsUsed = function(p331, p332)
		local v1406 = p332 or t1.Place.hillSpots()
		local t107 = {}
		local n39 = 0
		local v1409 = t1.Place.rowPitch()
		local v1410 = p331 or {}

		for _, v in ipairs(v1410) do
			local pos = v.pos and t1.Plan.onHill(v1406, v.pos, v1409)

			if pos and not t107[pos] then
				n39 += 1
				t107[pos] = true
			end
		end

		return t107, n39
	end
	t1.Plan.dead = function()
		local Plan = t1.Plan
		local v1415 = tostring(t1.Match.mapId()) .. ":" .. tostring(t1.Match.roundId) .. ":" .. t1.Cover.key() .. ":" .. tostring(t1.Place.roadBlocks())

		if not Plan._dead or Plan._dead.key ~= v1415 then
			Plan._dead = {
				key = v1415,
				set = {}
			}
		end

		return Plan._dead.set
	end
	t1.Plan.copies = function(p333)
		local n40 = 0

		for _, v in ipairs(t1.Match.slots()) do
			if v.role ~= "Farm" then
				if t1.Data.hill(v.id) == true == p333 and t1.Play.rarityOk(v.id) then
					n40 += math.min(t1.Play.limit(v), 6)
				end
			end
		end

		return math.max(n40, 1)
	end
	t1.Plan.hillPitch = function(p334)
		local t108 = {}

		for _, v in ipairs(t1.Match.slots()) do
			if (t1.Data.hill(v.id) or t1.Data.hybrid(v.id)) and t1.Play.rarityOk(v.id) then
				t108[#t108 + 1] = t1.Data.radius(v.id)
			end
		end

		if #t108 == 0 then
			return t1.Place.rowPitch(p334)
		end

		table.sort(t108)

		local n41 = 1.3

		return math.max(n41, t108[math.ceil(#t108 / 2)] * 2 * (1 + (p334 or t1.Place.gap())) + 0.1)
	end
	t1.Plan.legs = function(p335)
		local v1423 = t1.Paths.get()
		local t109 = {}
		local huge = math.huge

		if not v1423 then
			return t109, huge
		end

		local v1426 = t1._flat(p335)

		for _, path in ipairs(v1423.paths) do
			local points = path.points

			for i = 1, #points - 1 do
				local v1431 = t1._flat(points[i])
				local v1432 = t1._flat(points[i + 1]) - v1431
				local v1433 = v1432:Dot(v1432)
				local v1434 = v1433 > 0 and v1431 + v1432 * math.clamp((v1426 - v1431):Dot(v1432) / v1433, 0, 1)

				v1434 = v1434 or v1431

				local Magnitude = (v1426 - v1434).Magnitude

				if Magnitude > 0.001 then
					t109[#t109 + 1] = {
						d = Magnitude,
						v = (v1426 - v1434) / Magnitude
					}
				end

				huge = math.min(huge, Magnitude)
			end
		end

		return t109, huge
	end

	do
		t1.Plan.frame = function(p336, p337)
			local v1436, v1437 = t1.Plan.legs(p336.pos)
			local v1438

			for _, v in ipairs(v1436) do
				if v.d == v1437 then
					v1438 = v.v

					break
				end
			end

			if v1438 and not (v1437 < 0.5) then
				return {
					e = p336.pos - v1438 * p337,
					t = Vector3.new(-v1438.Z, 0, v1438.X),
					n = v1438,
					ld = v1437 - p337,
					c = p336,
					hill = p336.hill
				}
			end

			return nil
		end
	end

	t1.Plan.shift = function(p338, p339)
		return {
			e = p338.e + p338.n * p339,
			t = p338.t,
			n = p338.n,
			ld = p338.ld + p339,
			c = p338.c,
			hill = p338.hill
		}
	end
	t1.Plan.toFrame = function(p340, p341)
		local v1441 = t1._flat(p341 - p340.e)

		return v1441:Dot(p340.t), v1441:Dot(p340.n)
	end
	t1.Plan.fromFrame = function(p342, p343, p344)
		return p342.e + p342.t * p343 + p342.n * p344
	end
	t1.Plan.curl = function(p345, p346)
		local v1442 = ((t1.Paths.get() or {}).paths or {})[p345.path]
		local samples = v1442 and v1442.samples

		if not samples or #samples < 3 then
			return 0
		end

		if not v1442._cum then
			local cum = { 0 }

			for i = 2, #samples do
				local v1446 = t1._flat(samples[i - 1].dir)
				local v1447 = t1._flat(samples[i].dir)
				local vector3 = Vector3.new(-v1446.Z, 0, v1446.X)

				cum[i] = cum[i - 1] + math.atan2(v1447:Dot(vector3), v1447:Dot(v1446))
			end

			v1442._cum = cum
		end

		local v1449 = p345.progress * v1442.length

		local function v1450(p347)
			local n42 = 1
			local v1452 = #samples

			while n42 < v1452 do
				local v1453 = (n42 + v1452) // 2

				if samples[v1453].dist < p347 then
					n42 = v1453 + 1
				else
					v1452 = v1453
				end
			end

			return n42
		end

		return (v1442._cum[v1450(v1449 + p346)] - v1442._cum[v1450(v1449 - p346)]) * p345.sign
	end
	t1.Plan.anchors = function(p348, p349)
		local v1454 = t1.Plan.slots()

		if not v1454 then
			return nil
		end

		local Plan = t1.Plan
		local v1456 = t1.Place.rowPitch()
		local ancKey = tostring(Plan._slotKey) .. ":" .. t1.Cover.key() .. ":" .. t1.Paths.selKey() .. ":" .. math.floor(p349 * 2)

		if Plan._ancKey == ancKey and Plan._anc then
			return Plan._anc, Plan._bend
		end

		local v1458 = t1.Cover.window()
		local v1459 = v1456 / 2 + 0.1
		local t110 = {}

		for i, v in ipairs(v1454) do
			if v.lane == 1 and v.progress and (not v1458 or t1.Cover.inside(v.progress)) then
				if v._f == nil then
					v._f = t1.Plan.frame(v, v1459) or false
				end

				local _f = v._f

				if _f then
					if v._pod == nil then
						local v1464 = t1.Plan.fromFrame(_f, 0, v1456 * 0.85)
						local v1465 = t1.Place.open(v1464.X, v1464.Z)

						v._pod = v1465 and math.abs(v1465.Y - _f.e.Y) < 6 and {
							pos = v1465
						} or false
					end

					local v1466 = t1.Plan.reach(v._pod or v, p349, p348.samples)
					local t111 = {}
					local n43 = 0

					for _, v2 in ipairs(v1466.list) do
						if p348.want[v2] and p348.base[v2] > 0 then
							t111[#t111 + 1] = v2
							n43 += p348.base[v2]
						end
					end

					local v1471 = 1 + 0.5 * math.clamp(t1.Plan.curl(v, p349) / 1.5707963267948966, -1, 1)

					if n43 > 0 then
						t110[#t110 + 1] = {
							c = v,
							f = _f,
							list = t111,
							score = n43,
							passes = v1466.passes,
							m = v1471
						}
					end
				end
			end

			if i % 100 == 0 then
				task.wait()
			end
		end

		local t112 = {}
		local paths = (t1.Paths.get() or {}).paths or {}

		for _, path in ipairs(paths) do
			t112[path.index] = path.length
		end

		local anc = {}
		local v1477 = (v1456 * 4) ^ 2
		local v1478 = v1456 * 5
		local v1479 = table.clone(p348.base)

		local function v1480(p350)
			for _, v in ipairs(anc) do
				local v1483 = t1._flat(v.c.pos - p350.c.pos)
				local v1484 = v.c.path == p350.c.path and t112[p350.c.path]

				if v1483.X * v1483.X + v1483.Z * v1483.Z < v1477 or v1484 and math.abs(v.c.progress - p350.c.progress) * v1484 < v1478 then
					return false
				end
			end

			return true
		end

		while #anc < 6 do
			local v1485
			local n44 = 0

			for _, v in ipairs(t110) do
				if not v.out then
					if v1480(v) then
						local n45 = 0

						for _, v2 in ipairs(v.list) do
							n45 += v1479[v2]
						end

						local v1492 = n45 * v.m

						if not v1485 or n44 + 1e-06 < v1492 or n44 - 1e-06 < v1492 and (v1485.passes < v.passes or v.passes == v1485.passes and v.c.key < v1485.c.key) then
							v1485 = v
							n44 = v1492
						end
					else
						v.out = true
					end
				end
			end

			if not v1485 or n44 <= 0 then
				break
			end

			v1485.out = true
			v1485.f.m = v1485.m
			anc[#anc + 1] = v1485.f

			for _, v in ipairs(v1485.list) do
				v1479[v] *= 0.5
			end
		end

		local v1495
		local t113

		for _, v in ipairs(t110) do
			if v.c.corner then
				local v1499 = t1.Plan.bendFrame(v.c, v1459, v1456)

				if v1499 and (not t113 or t113[1] < v1499.legs or v1499.legs == t113[1] and t113[2] < v.passes) then
					t113 = {
						v1499.legs,
						v.passes
					}
					v1495 = v1499
				end
			end
		end

		Plan._ancKey = ancKey
		Plan._anc = anc
		Plan._bend = v1495

		return anc, v1495
	end
	t1.Plan.bendFrame = function(p351, p352, p353)
		local v1500, v1501 = t1.Plan.legs(p351.pos)
		local vector3 = Vector3.zero
		local n46 = 0

		for _, v in ipairs(v1500) do
			if v.d <= v1501 + p353 * 0.5 then
				vector3 += v.v
				n46 += 1
			end
		end

		if n46 == 0 or vector3.Magnitude < 0.001 then
			local v1506 = t1.Plan.frame(p351, p352)

			if v1506 then
				v1506.legs = 0
			end

			return v1506
		end

		local Unit = vector3.Unit

		return {
			e = p351.pos - Unit * p352,
			t = Vector3.new(-Unit.Z, 0, Unit.X),
			n = Unit,
			ld = v1501 - p352,
			c = p351,
			legs = n46
		}
	end
	t1.Plan.hillFrames = function(p354, p355, p356, p357)
		local v1508 = t1.Place.hillSpots()
		local Plan = t1.Plan
		local hfKey = tostring(t1.Place._hillKey) .. ":" .. t1.Cover.key() .. ":" .. t1.Paths.selKey() .. ":" .. math.floor(p355 * 2)

		if Plan._hfKey ~= hfKey or not Plan._hf then
			local v1511 = t1.Cover.window()
			local t114 = {}
			local v1513, v1514, v1515 = ipairs(v1508)

			for k, v in v1513, v1514, v1515 do
				if v.edge and (not v1511 or v.progress and t1.Cover.inside(v.progress)) then
					local n47 = 0

					for _, v2 in ipairs(t1.Plan.reach(v, p355, p354.samples).list) do
						if p354.want[v2] then
							n47 += p354.base[v2]
						end
					end

					local v1521 = t114[v.hill]

					if n47 > 0 and (not v1521 or v1521.score < n47) then
						t114[v.hill] = {
							c = v,
							score = n47
						}
					end
				end

				if k % 150 == 0 then
					task.wait()
				end
			end

			local t115 = {}
			local v1523, v1524, v1525 = pairs(t114)

			for _, v in v1523, v1524, v1525 do
				t115[#t115 + 1] = v
			end

			table.sort(t115, function(p358, p359)
				if p358.score == p359.score then
					return p358.c.key < p359.c.key
				end

				return p358.score > p359.score
			end)

			local hf = {}
			local v1529 = t1.Place.rowPitch() / 2 + 0.1
			local _, v1531 = t1.Place.folders()
			local descendants = v1531 and v1531:GetDescendants() or {}
			local v1533, v1534, v1535 = ipairs(t115)

			for _, v in v1533, v1534, v1535 do
				local v1538 = t1.Plan.frame(v.c, v1529)

				if v1538 then
					local v1539 = descendants[v.c.hill]

					if v1539 and v1539:IsA("BasePart") and math.abs(v1539.CFrame.UpVector.Y) >= 0.9 then
						local CFrame_ = v1539.CFrame
						local Size = v1539.Size
						local v1542 = t1._flat(v.c.pos - CFrame_.Position)
						local v1543
						local v1544
						local v1545

						for _, v2 in ipairs({
							{
								CFrame_.RightVector,
								Size.X / 2,
								Size.Z / 2
							},
							{
								-CFrame_.RightVector,
								Size.X / 2,
								Size.Z / 2
							},
							{
								CFrame_.LookVector,
								Size.Z / 2,
								Size.X / 2
							},
							{
								-CFrame_.LookVector,
								Size.Z / 2,
								Size.X / 2
							}
						}) do
							local v1548 = t1._flat(v2[1])

							if v1548.Magnitude > 0.5 then
								local Unit = v1548.Unit

								if v1543 then
									local v1550 = Unit:Dot(v1538.n)

									if not (v1543:Dot(v1538.n) < v1550) then
										continue
									end
								end

								v1544 = v2[2]
								v1545 = v2[3]
								v1543 = Unit
							end
						end

						local vector3 = v1543 and Vector3.new(-v1543.Z, 0, v1543.X)

						if v1543 and math.abs(v1542:Dot(v1543)) <= v1544 + 0.5 and math.abs(v1542:Dot(vector3)) <= v1545 + 0.5 then
							v1538.n = v1543
							v1538.t = vector3
							v1538.e = v.c.pos - v1543 * (v1542:Dot(v1543) + v1544)
						end
					end

					v1538.score = v.score
					hf[#hf + 1] = v1538
				end
			end

			Plan._hfKey = hfKey
			Plan._hf = hf
		end

		local v1552 = table.clone(Plan._hf)
		local t116 = {}
		local v1554 = t1.Plan.hillsUsed(p357, v1508)
		local v1555, v1556, v1557 = ipairs(v1552)
		local v1558 = geniter(v1555, v1556, v1557)

		while true do
			local v1559 = table.pack(v1558())

			if not v1559[1] then
				break
			end

			local v1560 = v1559[2]
			local v1561 = v1559[3]
			local t117 = {}
			local v1563 = v1554[v1561.hill] and 0 or 1

			if p356 then
				local exitTo

				repeat
					local Magnitude = t1._flat(v1561.e - p356).Magnitude

					exitTo = nil

					while true do
						Magnitude = Magnitude or v1560
						t117[1] = v1563
						t117[2] = Magnitude
						t116[v1561] = t117

						local v1566 = table.pack(v1558())

						if not v1566[1] then
							break
						end

						v1560 = v1566[2]
						v1561 = v1566[3]
						t117 = {}
						v1563 = v1554[v1561.hill] and 0 or 1
						Magnitude = p356

						if Magnitude then
							exitTo = 1

							break
						end
					end
				until exitTo ~= 1

				table.sort(v1552, function(p360, p361)
					local v1567 = t116[p360]
					local v1568 = t116[p361]

					if v1567[1] == v1568[1] then
						return v1567[2] < v1568[2]
					end

					return v1567[1] < v1568[1]
				end)

				return v1552
			end

			t117[1] = v1563
			t117[2] = v1560
			t116[v1561] = t117
		end

		table.sort(v1552, function(p362, p363)
			local v1569 = t116[p362]
			local v1570 = t116[p363]

			if v1569[1] == v1570[1] then
				return v1569[2] < v1570[2]
			end

			return v1569[1] < v1570[1]
		end)

		return v1552
	end
	t1.Plan.podPoint = function(p364, p365, p366, p367)
		local v1571 = t16.pod[p364]
		local v1572 = v1571[1]
		local v1573 = v1571[2]
		local v1574 = v1571[3]
		local v1575 = v1571[4]
		local v1576 = v1574 and p366[v1574]
		local v1577 = v1575 and p366[v1575]

		if v1573 == 0 then
			local v1578 = p365 + 0.1

			if not v1576 then
				return v1572 * (2 * p365 * (1 + p367) + 0.1), v1578
			end

			local v1579 = (v1576.r + p365) * (1 + p367) + 0.1
			local v1580 = v1578 - v1576.b
			local v1581 = math.sqrt(math.max(v1579 * v1579 - v1580 * v1580, 0))

			return v1576.a + (v1572 > t16.pod[v1574][1] and v1581 or -v1581), v1578
		end

		if v1576 and v1577 then
			local v1582 = (v1576.r + p365) * (1 + p367) + 0.1
			local v1583 = (v1577.r + p365) * (1 + p367) + 0.1
			local v1584 = v1577.a - v1576.a
			local v1585 = v1577.b - v1576.b
			local v1586 = math.sqrt(v1584 * v1584 + v1585 * v1585)

			if v1586 > 0.001 and v1586 < v1582 + v1583 and math.abs(v1582 - v1583) < v1586 then
				local v1587 = (v1582 * v1582 - v1583 * v1583 + v1586 * v1586) / (2 * v1586)
				local v1588 = math.sqrt(math.max(v1582 * v1582 - v1587 * v1587, 0))
				local v1589 = v1576.a + v1584 * v1587 / v1586
				local v1590 = v1576.b + v1585 * v1587 / v1586
				local v1591 = -v1585 / v1586 * v1588
				local v1592 = v1584 / v1586 * v1588

				if v1592 >= 0 then
					return v1589 + v1591, v1590 + v1592
				end

				return v1589 - v1591, v1590 - v1592
			end
		end

		local v1593 = v1576 or v1577
		local v1594 = v1576 and v1574 or v1575

		if v1593 then
			local v1595 = (v1593.r + p365) * (1 + p367) + 0.1
			local v1596 = v1572 - t16.pod[v1594][1]
			local v1597 = (v1573 - t16.pod[v1594][2]) * 0.866
			local v1598 = math.sqrt(v1596 * v1596 + v1597 * v1597)

			return v1593.a + v1595 * v1596 / v1598, v1593.b + v1595 * v1597 / v1598
		end

		local v1599 = 2 * p365 * (1 + p367) + 0.1

		return v1572 * v1599, p365 + 0.1 + v1573 * v1599 * 0.866
	end
	t1.Plan.podState = function(p368, p369, p370)
		local t118 = {}
		local t119 = {}
		local n48 = 0

		for i = 1, #t16.pod do
			for i2, v in ipairs(p369) do
				if not t119[i2] then
					local v1606, v1607 = t1.Plan.toFrame(p368, v.pos)

					if v1607 > -2 and v1607 < 18 and math.abs(v1606) < 20 then
						local v1608, v1609 = t1.Plan.podPoint(i, v.r, t118, p370)

						if (v1608 - v1606) ^ 2 + (v1609 - v1607) ^ 2 <= 0.5625 then
							n48 += 1
							t118[i] = {
								a = v1606,
								b = v1607,
								r = v.r
							}
							t119[i2] = true

							break
						end
					end
				end
			end
		end

		if n48 < #p369 then
			for i = 1, #t16.pod do
				if not t118[i] then
					for i2, v in ipairs(p369) do
						if not t119[i2] then
							local v1613, v1614 = t1.Plan.toFrame(p368, v.pos)
							local v1615, v1616 = t1.Plan.podPoint(i, v.r, {}, p370)

							if (v1615 - v1613) ^ 2 + (v1616 - v1614) ^ 2 <= v.r * v.r then
								n48 += 1
								t118[i] = {
									a = v1613,
									b = v1614,
									r = v.r
								}
								t119[i2] = true

								break
							end
						end
					end
				end
			end
		end

		return t118, n48
	end

	do
		local function capOf(p371)
			for _, cap in ipairs(t16.caps) do
				if p371 <= cap then
					return cap
				end
			end

			return t16.caps[#t16.caps]
		end

		t1.Plan.capOf = capOf
	end

	t1.Plan.gridNodes = function(p372, p373, p374, p375, p376, p377)
		local t120 = {}
		local v1621 = p372 and p375 * 0.866 or p375
		local t121 = {}

		for i = 0, p374 * 2 do
			t121[#t121 + 1] = i == 0 and 0 or i % 2 == 1 and (i + 1) / 2 or -i / 2
		end

		local function v1624(p378, p379)
			local v1625 = #t120 + 1
			local v1627 = p372 and p379 % 2 == 1 and 0.5 or 0
			local t122 = {
				(p378 + v1627) * p375,
				p375 / 2 + 0.1 + p379 * v1621
			}

			t120[v1625] = t122
		end

		if not p377 then
			for _, v in ipairs(t121) do
				for i = 0, p373 - 1 do
					v1624(v, p376 and p373 - 1 - i or i)
				end
			end

			return t120
		end

		local v1632 = p373 > 1 and (p376 and 0 or p373 - 1) or nil

		local function v1633(p380, p381)
			for i = 0, p373 - 1 do
				local v1635 = p376 and p373 - 1 - i

				v1635 = v1635 or i

				if v1635 ~= v1632 then
					for i2 = p380, p381 do
						v1624(t121[i2], v1635)
					end
				end
			end
		end

		local v1637 = math.min(p377, #t121)

		v1633(1, v1637)
		v1633(v1637 + 1, #t121)

		if v1632 then
			for _, v in ipairs(t121) do
				v1624(v, v1632)
			end
		end

		return t120
	end
	t1.Plan.gridDepth = function(p382, p383, p384, p385)
		return math.max(1, math.floor((p385 - 0.5 - p382.ld - p383 / 2) / p384) + 1)
	end
	t1.Plan.taken = function(p386, p387, p388, p389, p390)
		local v1640 = t1._flat(t1.Plan.fromFrame(p386, p387, p388))

		for _, v in ipairs(p389) do
			local v1643 = t1._flat(v.pos) - v1640

			if v1643.X * v1643.X + v1643.Z * v1643.Z < p390 * p390 then
				return true
			end
		end

		return false
	end
	t1.Plan.fit = function(p391, p392, p393, p394)
		local v1644 = t1.Plan.fromFrame(p392, p393, p394)

		if not t1.Place.clear(v1644, p391.r, p391.placed, p391.gap) then
			local rejects = t1.Place.rejects or {}
			local Place = t1.Place
			local clear = rejects.clear or 0

			Place.rejects = rejects
			rejects.clear = clear + 1

			return nil
		end

		local v1648 = t1.Plan.dead()
		local v1649 = (p391.cls or "g") .. (p392.hill and "H" or "G") .. ":" .. math.floor(v1644.X * 2) .. ":" .. math.floor(v1644.Z * 2)
		local v1650 = p391.lo and not p391.aura

		if v1648[v1649] or v1650 and v1648["c" .. v1649] then
			return nil
		end

		if not p392.hill and t1.Plan.laneDist(p391.data, v1644) < p392.ld - 0.5 then
			return nil
		end

		p391.tries += 1

		if t16.tries < p391.tries then
			return nil
		end

		local v1651 = t1.Place.ground(v1644.X, v1644.Z, p391.rec.id)

		if not v1651 or (p392.hill and p391.cls ~= "h" and 1.5 or 6) <= math.abs(v1651.Y - p392.e.Y) then
			v1648[v1649] = true

			return nil
		end

		if v1650 then
			local v1652 = t1.Paths.nearest(v1651)

			if not v1652 or not v1652.progress or not t1.Cover.inside(v1652.progress) then
				v1648["c" .. v1649] = true

				return nil
			end
		end

		local v1653 = "grid:" .. math.floor(v1651.X * 2) .. ":" .. math.floor(v1651.Z * 2)

		if t1.Place.isRefused(v1653) then
			return nil
		end

		if t1.Place.check(v1651, p391.rec.id, p391.r, p391.placed, p391.gap) then
			return v1651, v1653
		end

		return nil
	end
	t1.Plan.honeyTry = function(p395, p396, p397)
		local t123 = {}

		for i, v in ipairs(p396) do
			local v1657, v1658 = t1.Plan.podState(v, p395.placed, p395.gap)

			t123[i] = {
				at = v1657,
				n = v1658
			}
		end

		local t124 = {}

		if p395.aura then
			local t125 = {}

			for i in ipairs(p396) do
				if t123[i].n > 0 then
					t125[#t125 + 1] = i
				end
			end

			table.sort(t125, function(p398, p399)
				if t123[p398].n == t123[p399].n then
					return p398 < p399
				end

				return t123[p398].n > t123[p399].n
			end)

			for _, v in ipairs(t125) do
				t124[#t124 + 1] = {
					v,
					#t16.pod
				}
			end
		elseif p395.value then
			local t126 = {}

			for i, v in ipairs(p396) do
				local v1667 = t123[i]

				for i2 = 1, #t16.pod do
					if not v1667.at[i2] then
						local v1669, v1670 = t1.Plan.podPoint(i2, p395.r, v1667.at, p395.gap)

						t126[#t126 + 1] = {
							i = i,
							v = p395.value(t1.Plan.fromFrame(v, v1669, v1670)) * (v.m or 1)
						}

						break
					end
				end
			end

			table.sort(t126, function(p400, p401)
				if math.abs(p400.v - p401.v) > 1e-06 then
					return p400.v > p401.v
				end

				return p400.i < p401.i
			end)

			for _, v in ipairs(t126) do
				local i = v.i
				local v1674 = t123[v.i]

				for i2 = 1, #t16.pod do
					if v1674.at[i2] then
						continue
					end

					local v1676, v1677 = t1.Plan.podPoint(i2, p395.r, v1674.at, p395.gap)
					local v1678, v1679 = t1.Plan.fit(p395, p396[i], v1676, v1677)

					if v1678 then
						return {
							pos = v1678,
							key = v1679,
							why = p397 .. " " .. i .. " " .. v1674.n + 1 .. "/" .. t1.Plan.capOf(v1674.n + 1)
						}
					end

					if not (t16.tries < p395.tries) then
						continue
					end

					return nil, "space"
				end
			end

			return nil, "space"
		end

		local caps = p395.lo and {
			3,
			5,
			7,
			10
		} or t16.caps

		for _, cap in ipairs(caps) do
			for i in ipairs(p396) do
				t124[#t124 + 1] = {
					i,
					cap
				}
			end
		end

		local t127 = {}

		for _, v in ipairs(t124) do
			local v1687 = v[1]
			local v1688 = v[2]
			local v1689 = t123[v1687]

			if not (v1689.n < v1688) then
				continue
			end

			for i = 1, v1688 do
				if v1689.at[i] or t127[v1687 * 100 + i] then
					continue
				end

				t127[v1687 * 100 + i] = true

				local v1691, v1692 = t1.Plan.podPoint(i, p395.r, v1689.at, p395.gap)
				local v1693, v1694 = t1.Plan.fit(p395, p396[v1687], v1691, v1692)

				if not v1693 then
					if not (t16.tries < p395.tries) then
						continue
					end

					return nil, "space"
				end

				local t128 = {
					pos = v1693,
					key = v1694,
					why = p397 .. " " .. v1687 .. " " .. v1689.n + 1 .. "/" .. (p395.aura and t1.Plan.capOf(v1689.n + 1) or v1688)
				}

				return t128
			end
		end

		return nil, "space"
	end
	t1.Plan.blockTry = function(p402, p403, p404, p405, p406)
		local v1696 = p404 and p406 * 0.866 or p406
		local v1697 = math.ceil(math.sqrt(p402.copies))

		for i, v in ipairs(p403) do
			local v1700 = p402.hill and math.min(v1697, 4) or math.min(v1697, t1.Plan.gridDepth(v, p406, v1696, p402.range))
			local v1701 = t1.Plan.gridNodes(p404, v1700, math.ceil(p402.copies / v1700) + 1, p406, p402.long, math.ceil(p402.copies / v1700))
			local n49 = 0

			for _, v2 in ipairs(v1701) do
				if t1.Plan.taken(v, v2[1], v2[2], p402.placed, p406 * 0.45) then
					n49 += 1
				end
			end

			for _, v2 in ipairs(v1701) do
				if t1.Plan.taken(v, v2[1], v2[2], p402.placed, p406 * 0.45) then
					continue
				end

				local v1707, v1708 = t1.Plan.fit(p402, v, v2[1], v2[2])

				if v1707 then
					return {
						pos = v1707,
						key = v1708,
						why = p405 .. (p402.hill and " Hill " .. i or i > 1 and " Area " .. i or "") .. " " .. math.ceil((n49 + 1) / v1700) .. "x" .. v1700
					}
				end

				if t16.tries < p402.tries then
					return nil, "space"
				end
			end
		end

		return nil, "space"
	end
	t1.Plan.cornerNodes = function(p407, p408, p409)
		if p407._wrap and p407._wrapP == p408 then
			return p407._wrap
		end

		local t129 = {}

		for _, v in ipairs(t1.Plan.gridNodes(false, math.min(t1.Plan.gridDepth(p407, p408, p408, p409), 3), 2, p408)) do
			t129[#t129 + 1] = {
				v[1],
				v[2]
			}
		end

		local v1712 = (p408 * 8) ^ 2
		local v1713 = t1.Plan.slots() or {}

		for _, v in ipairs(v1713) do
			if v.lane ~= 3 and v.path == p407.c.path and v.sign == p407.c.sign then
				local v1716, v1717 = t1.Plan.toFrame(p407, v.pos)

				if v1716 * v1716 + v1717 * v1717 <= v1712 then
					t129[#t129 + 1] = {
						v1716,
						v1717
					}
				end
			end
		end

		local v1718 = p408 / 2 + 0.1

		table.sort(t129, function(p410, p411)
			local v1719 = p410[1] * p410[1] + (p410[2] - v1718) ^ 2
			local v1720 = p411[1] * p411[1] + (p411[2] - v1718) ^ 2

			if v1719 == v1720 then
				return p410[1] < p411[1]
			end

			return v1719 < v1720
		end)

		local wrap = {}
		local v1722 = (p408 * 0.9) ^ 2

		for _, v in ipairs(t129) do
			local v1725 = true

			for _, v2 in ipairs(wrap) do
				if (v[1] - v2[1]) ^ 2 + (v[2] - v2[2]) ^ 2 < v1722 then
					v1725 = false

					break
				end
			end

			if v1725 then
				wrap[#wrap + 1] = v
			end
		end

		p407._wrap = wrap
		p407._wrapP = p408

		return wrap
	end

	do
		t1.Plan.cornerTry = function(p412, p413, p414)
			local pitch = p412.pitch
			local areaLeft = p412.area and 0 or p412.areaLeft

			for i, v in ipairs(t1.Plan.cornerNodes(p413, pitch, p412.range)) do
				if t1.Plan.taken(p413, v[1], v[2], p412.placed, pitch * 0.45) then
					continue
				end

				if areaLeft > 0 then
					areaLeft -= 1

					continue
				end

				local v1732, v1733 = t1.Plan.fit(p412, p413, v[1], v[2])

				if v1732 then
					return {
						pos = v1732,
						key = v1733,
						why = p414 .. " Cell " .. i
					}
				end

				if t16.tries < p412.tries then
					return nil, "space"
				end
			end

			return nil, "space"
		end
	end

	t1.Plan.mirror = function(p415)
		if p415._m ~= nil then
			return p415._m or nil
		end

		local v1734 = t1.Paths.nearest(p415.c.pos)
		local v1735
		local v1736 = (t1.Place.rowPitch() * 2) ^ 2

		if v1734 then
			local v1737 = v1734.pos - t1._flat(p415.c.pos - v1734.pos)
			local ipairs_ = ipairs
			local v1739 = t1.Plan.slots() or {}

			for _, v in ipairs_(v1739) do
				if v.lane == 1 and v.path == p415.c.path and v.sign ~= p415.c.sign then
					local v1742 = t1._flat(v.pos - v1737)
					local v1743 = v1742.X * v1742.X + v1742.Z * v1742.Z

					if v1743 < v1736 then
						v1735 = v
						v1736 = v1743
					end
				end
			end
		end

		p415._m = v1735 and t1.Plan.frame(v1735, t1.Place.rowPitch() / 2 + 0.1) or false

		return p415._m or nil
	end
	t1.Plan.sidesTry = function(p416, p417, p418)
		local pitch = p416.pitch

		for _, v in ipairs(p417) do
			local v1747 = t1.Plan.mirror(v)
			local v1748 = t1.Plan.gridNodes(false, math.min(2, t1.Plan.gridDepth(v, pitch, pitch, p416.range)), math.ceil(p416.copies / 4) + 1, pitch)
			local t130 = {
				v,
				v1747
			}
			local t131 = {
				0,
				0
			}

			for i, v2 in ipairs(t130) do
				local v1753, v1754, v1755 = ipairs(v1748)

				for _, v3 in v1753, v1754, v1755 do
					if t1.Plan.taken(v2, v3[1], v3[2], p416.placed, pitch * 0.45) then
						t131[i] += 1
					end
				end
			end

			local v1758 = v1747 and t131[2] < t131[1] and 2 or 1

			for _, v2 in ipairs({
				v1758,
				3 - v1758
			}) do
				local v1761 = t130[v2]

				if v1761 then
					local v1762, v1763, v1764 = ipairs(v1748)
					local v1765 = geniter(v1762, v1763, v1764)
					local v1766 = table.pack(v1765())

					if not v1766[1] then
						continue
					end

					local v1767 = v1766[3]

					while true do
						if not t1.Plan.taken(v1761, v1767[1], v1767[2], p416.placed, pitch * 0.45) then
							local v1768, v1769 = t1.Plan.fit(p416, v1761, v1767[1], v1767[2])

							if v1768 then
								t131[v2] += 1

								return {
									pos = v1768,
									key = v1769,
									why = p418 .. " " .. t131[1] .. "+" .. t131[2]
								}
							end

							if t16.tries < p416.tries then
								return nil, "space"
							end
						end

						local v1770 = table.pack(v1765())

						if not v1770[1] then
							break
						end

						v1767 = v1770[3]
					end
				end
			end
		end

		return nil, "space"
	end

	do
		t1.Plan.grid = function(p419, p420, p421, p422, p423, p424)
			local v1771 = t1.Paths.get()

			if not v1771 or not t1.Plan.slots() then
				return nil, "map"
			end

			t1.Paths.watch()

			local v1772 = t1.Plan.weights({}, p422)

			if not v1772 then
				return nil, "map"
			end

			local v1773 = t1.Data.profile(p419.id, p419.entry)
			local v1774 = t1.Place.rowPitch()
			local v1775, v1776 = t1.Plan.midRange()
			local t132 = {
				rec = p419,
				data = v1771,
				placed = p421,
				gap = t1.Place.gap(),
				r = t1.Data.radius(p419.id),
				pitch = v1774,
				range = v1775,
				lo = t1.Cover.window(),
				tries = 0,
				aura = v1773.role == "Support" and not v1773.hold,
				area = v1773.area,
				long = v1773.role ~= "Farm" and v1773.range >= v1776 * 1.4,
				areaLeft = 0,
				cls = v1773.hill and "h" or v1773.hybrid and "y" or "g"
			}

			if not (v1773.role == "Farm" or t132.aura) then
				local v1778 = math.max(t1._n(v1773.range, v1775), 4) ^ 2
				local samples = v1772.samples

				t132.value = function(p425)
					local v1780 = t1._flat(p425)
					local n50 = 0

					for i, sample in ipairs(samples) do
						if v1772.want[i] and v1772.base[i] > 0 then
							local v1784 = t1._flat(sample.pos) - v1780

							if v1784.X * v1784.X + v1784.Z * v1784.Z <= v1778 then
								n50 += v1772.base[i]
							end
						end
					end

					return n50
				end
			end

			if not (v1773.area or p423 ~= "Corner Wrap") then
				for _, v in ipairs(t1.Match.slots()) do
					if v.id ~= p419.id and v.role ~= "Farm" and t1.Play.rarityOk(v.id) and t1.Data.profile(v.id, v.entry).area then
						t132.areaLeft += math.max(math.min(t1.Play.limit(v), 6) - t1.Play.count(v.id), 0)
					end
				end
			end

			local v1787, v1788 = t1.Plan.anchors(v1772, v1775)

			if not v1787 then
				return nil, "map"
			end

			local v1789 = (p424 and "Auto: " or "") .. (p423 == "Honeycomb" and "Honeycomb" or "Grid " .. p423)
			local v1790 = v1773.hill and { true } or v1773.hybrid and v1773.role ~= "Farm" and {
				false,
				true
			} or { false }
			local s5 = "none"

			for _, v in ipairs(v1790) do
				local v1794
				local v1795

				t132.hill = v
				t132.tries = 0

				if v then
					local v1796 = p423 == "Corner Wrap" or p423 == "Both Sides"

					if v1796 then
						v1796 = (v1788 or v1787[1] or {}).e
					end

					v1796 = v1796 or nil

					local v1797 = t1.Plan.hillFrames(v1772, t1.Plan.hillRange(), v1796, p420)

					t132.copies = t1.Plan.copies(true)

					if #v1797 > 0 then
						if p423 == "Honeycomb" then
							v1794, v1795 = t1.Plan.honeyTry(t132, v1797, v1789 .. " Hill")
						else
							v1794, v1795 = t1.Plan.blockTry(t132, v1797, p423 == "Staggered", v1789, t1.Plan.hillPitch())
						end
					elseif #t1.Place.hillSpots() > 0 then
						v1795 = "full"
					end
				elseif #v1787 == 0 then
					v1795 = v1773.role == "Farm" and "space" or "full"
				elseif v1773.role == "Farm" then
					t132.copies = t1.Plan.copies(false)

					local t133 = {}
					local v1799 = math.min(math.ceil(math.sqrt(t132.copies)), 4)

					for _, v2 in ipairs(v1787) do
						t133[#t133 + 1] = t1.Plan.shift(v2, p423 == "Honeycomb" and v1774 * 2.75 or math.min(v1799, t1.Plan.gridDepth(v2, v1774, v1774, v1775)) * v1774)
					end

					if p423 == "Honeycomb" then
						v1794, v1795 = t1.Plan.honeyTry(t132, t133, v1789 .. " Farms")
					else
						t132.copies = 6
						t132.long = false
						v1794, v1795 = t1.Plan.blockTry(t132, t133, false, v1789 .. " Farm Row", v1774)
					end
				else
					t132.copies = t1.Plan.copies(false)

					if p423 == "Honeycomb" then
						v1794, v1795 = t1.Plan.honeyTry(t132, v1787, v1789 .. " Pod")
					elseif p423 == "Corner Wrap" then
						v1794, v1795 = t1.Plan.cornerTry(t132, v1788 or v1787[1], v1789)
					elseif p423 == "Both Sides" then
						v1794, v1795 = t1.Plan.sidesTry(t132, v1787, v1789)
					else
						v1794, v1795 = t1.Plan.blockTry(t132, v1787, p423 == "Staggered", v1789, v1774)
					end
				end

				if not v1794 then
					if v1795 and s5 ~= "space" then
						s5 = v1795
					end

					continue
				end

				if not v then
					local _, v1803 = t1.Plan.hillsUsed(p420)

					if v1803 > 0 then
						v1794.why ..= " | Hill " .. v1803
					end
				end

				return v1794
			end

			return nil, s5
		end
	end

	t1.Play.savedList = function(p426)
		local v1804 = type(t12.Positions) == "table"

		if v1804 then
			v1804 = t12.Positions[t1.Match.mapId() or ""]
		end

		local v1805 = type(v1804) == "table" and p426 and v1804[p426]

		return type(v1805) == "table" and v1805 or nil, v1804
	end

	do
		t1.Play.savedSpot = function(p427, p428, p429)
			local v1806 = t1.Play.savedList(p427.id)

			if not v1806 or #v1806 == 0 then
				return nil, false
			end

			local v1807 = t1.Data.radius(p427.id)
			local v1808 = t1.Place.gap()
			local v1809 = math.max(1.3, v1807 * 2 * (1 + v1808) + 0.1)
			local t134 = {}
			local t135 = {}
			local t136 = {}

			for i, v in ipairs(v1806) do
				t134[i] = Vector3.new(t1._n(v[1]), t1._n(v[2]), t1._n(v[3]))
				t135[i] = 0
				t136[i] = i
			end

			local v1815 = p429 or t1.Match.towers()

			for _, v in ipairs(v1815) do
				if v.id == p427.id and v.pos then
					local v1818
					local v1819

					for i, v2 in ipairs(t134) do
						local Magnitude = (t1._flat(v.pos) - t1._flat(v2)).Magnitude

						if not v1819 or Magnitude < v1819 then
							v1818 = i
							v1819 = Magnitude
						end
					end

					t135[v1818] += 1
				end
			end

			table.sort(t136, function(p430, p431)
				if t135[p430] == t135[p431] then
					return p430 < p431
				end

				return t135[p430] < t135[p431]
			end)

			local n51 = 0

			for _, v in ipairs(t136) do
				local v1826 = t134[v]
				local v1827 = "saved:" .. math.floor(v1826.X * 4) .. ":" .. math.floor(v1826.Z * 4)

				if not t1.Place.isRefused(v1827) and t1.Place.clear(v1826, v1807, p428) then
					return {
						pos = v1826,
						key = v1827
					}, true
				end

				for i = 1, 4 do
					local v1829 = v1809 * i
					local v1830 = math.max(6, math.floor(6.2831853071795862 * v1829 / v1809))

					for i2 = 0, v1830 - 1 do
						local v1832 = i2 / v1830 * 2 * math.pi
						local v1833 = v1826.X + math.cos(v1832) * v1829
						local v1834 = v1826.Z + math.sin(v1832) * v1829
						local v1835 = "saved:" .. math.floor(v1833 * 4) .. ":" .. math.floor(v1834 * 4)

						if not t1.Place.isRefused(v1835) then
							local v1836 = t1.Place.ground(v1833, v1834, p427.id)

							if v1836 and t1.Place.clear(v1836, v1807, p428, v1808) and t1.Place.valid(v1836, p427.id) then
								return {
									pos = v1836,
									key = v1835
								}, true
							end
						end

						n51 += 1

						if n51 % 20 == 0 then
							task.wait()
						end
					end
				end
			end

			return nil, true
		end
	end

	t1.Play.unsaved = function(p432)
		if t12.PlaceMode ~= "Set Positions" then
			return false
		end

		local v1837, v1838 = t1.Play.savedList(p432.id)

		if type(v1838) ~= "table" or next(v1838) == nil then
			return false
		end

		return not v1837 or #v1837 == 0
	end
	t1.Plan.roadEdge = function(p433, p434)
		local t137 = {}

		for _, path in ipairs(p433.paths) do
			for i = -1, 1, 2 do
				for i2 = 1, #path.samples, 4 do
					local v1844 = path.samples[i2]
					local dir = v1844.dir or Vector3.new(0, 0, 1)
					local v1846 = Vector3.new(-dir.Z, 0, dir.X) * i

					for i3 = 0, t16.reach, 0.5 do
						local v1848 = v1844.pos + v1846 * i3

						if not p434(2) then
							return nil
						end

						if not t1.Place.open(v1848.X, v1848.Z) then
							continue
						end

						t137[#t137 + 1] = i3

						break
					end
				end
			end
		end

		if #t137 == 0 then
			return nil
		end

		table.sort(t137)

		return t137[math.ceil(#t137 / 2)]
	end
	t1.Plan.shapeKey = function(p435)
		local v1849 = t1.Paths.get()

		if not v1849 then
			return nil
		end

		local v1850, v1851 = t1.Place.folders()

		return table.concat({
			tostring(v1849),
			tostring(t1.Match.mapId()),
			t1.Place.rowPitch(),
			p435,
			t1.Paths.selKey(),
			t1.Cover.key(),
			math.floor(t1.Plan.midRange()),
			tostring(t1.Place.roadBlocks()),
			string.format("%.1f", t1.Place.roadWidth()),
			tostring(v1850),
			tostring(v1851),
			v1851 and #v1851:GetChildren() or 0
		}, "|"), v1849
	end
	t1.Plan.shapeSpots = function(p436, p437)
		local v1852, v1853 = t1.Plan.shapeKey(p436)

		if not v1852 then
			return nil
		end

		local Plan = t1.Plan
		local _shape, ok2, result, v1858

		if Plan._shapeKey ~= v1852 or not Plan._shape then
			if Plan._shapeBuilding == v1852 then
				if p437 then
					return nil
				end

				while Plan._shapeBuilding == v1852 and t1.Running do
					task.wait(0.2)
				end

				_shape = Plan._shapeKey == v1852 and Plan._shape or nil

				return _shape
			end

			Plan._shapeBuilding = v1852

			if p437 then
				task.spawn(function()
					local ok3, result2 = pcall(t1.Plan.build, v1853, v1852, p436)
					local ok = not not ok3
					local shapeErr

					if not ok then
						shapeErr = tostring(result2):gsub("^.-:%d+: ", "")
						ok = not shapeErr
					end

					if ok then
						shapeErr = nil
					end

					Plan._shapeErr = shapeErr

					if Plan._shapeBuilding == v1852 then
						Plan._shapeBuilding = nil
					end

					if Plan._shapeKey == v1852 then
						t1._wake("play")
					end

					t1._wake("esp")
				end)

				return nil
			end

			ok2, result = pcall(t1.Plan.build, v1853, v1852, p436)

			local shapeErr = not ok2 and tostring(result):gsub("^.-:%d+: ", "") or nil

			Plan._shapeErr = shapeErr

			if Plan._shapeBuilding == v1852 then
				Plan._shapeBuilding = nil
			end

			if Plan._shapeKey == v1852 then
				t1._wake("play")
			end

			v1858 = ok2 and result or nil

			return v1858
		end

		if not (#Plan._shape > 0) then
			if not (os.clock() - (Plan._shapeAt or 0) < 3) then
				if Plan._shapeBuilding == v1852 then
					if p437 then
						return nil
					end

					while Plan._shapeBuilding == v1852 and t1.Running do
						task.wait(0.2)
					end

					_shape = Plan._shapeKey == v1852 and Plan._shape or nil

					return _shape
				end

				Plan._shapeBuilding = v1852

				if p437 then
					task.spawn(function()
						local ok3, result2 = pcall(t1.Plan.build, v1853, v1852, p436)
						local ok = not not ok3
						local shapeErr

						if not ok then
							shapeErr = tostring(result2):gsub("^.-:%d+: ", "")
							ok = not shapeErr
						end

						if ok then
							shapeErr = nil
						end

						Plan._shapeErr = shapeErr

						if Plan._shapeBuilding == v1852 then
							Plan._shapeBuilding = nil
						end

						if Plan._shapeKey == v1852 then
							t1._wake("play")
						end

						t1._wake("esp")
					end)

					return nil
				end

				ok2, result = pcall(t1.Plan.build, v1853, v1852, p436)
				Plan._shapeErr = not ok2 and tostring(result):gsub("^.-:%d+: ", "") or nil

				if Plan._shapeBuilding == v1852 then
					Plan._shapeBuilding = nil
				end

				if Plan._shapeKey == v1852 then
					t1._wake("play")
				end

				v1858 = ok2 and result or nil

				return v1858
			end
		end

		return Plan._shape
	end
	t1.Plan.build = function(p438, p439, p440)
		local Plan = t1.Plan
		local Honeycomb = t16.PATTERNS[p440] or t16.PATTERNS.Honeycomb
		local v1870 = t1.Place.rowPitch()
		local v1871 = t1.Match.mapId()
		local n52 = 0

		local function v1873(p441)
			n52 += p441

			if n52 < 160 then
				return true
			end

			n52 = 0
			task.wait()

			return t1.Running and t1.Match.mapId() == v1871
		end

		local v1874 = t1.Place.roadBlocks() and (t1.Plan.roadEdge(p438, v1873) or 1) or 0
		local v1875 = v1870 / 2 + 0.1
		local shape = {}
		local t138 = {}
		local shapeTally = {}
		local v1879 = (v1870 * 0.8) ^ 2

		local function v1880(p442, p443)
			local v1881 = math.floor(p442.X / v1870)
			local v1882 = math.floor(p442.Z / v1870)

			for i = -1, 1 do
				for i2 = -1, 1 do
					local ipairs_ = ipairs
					local v1886 = t138[v1881 + i .. ":" .. v1882 + i2] or {}

					for _, v in ipairs_(v1886) do
						local v1889 = v.pos - p442

						if v1889.X * v1889.X + v1889.Z * v1889.Z < v1879 then
							return true
						end
					end
				end
			end

			local v1890 = p443 or {}

			for _, v in ipairs(v1890) do
				local v1893 = v.pos - p442

				if v1893.X * v1893.X + v1893.Z * v1893.Z < v1879 then
					return true
				end
			end

			return false
		end
		local function v1894(p444)
			shapeTally[p444] = (shapeTally[p444] or 0) + 1
		end
		local function v1895(p445, p446)
			if not v1873(5) then
				return false
			end

			local v1896, v1897 = t1.Place.valid(p445, nil, "ground")
			local v1898 = false

			if not (v1896 or v1897 ~= "ground") then
				if not v1873(5) then
					return false
				end

				local v1899, v1900 = t1.Place.valid(p445, nil, "hill")

				if v1899 then
					v1896 = true
					v1897 = v1900
					v1898 = true
				end
			end

			if not v1896 then
				v1894(v1897 or "ground")

				return nil
			end

			if t1.Plan.laneDist(p438, v1897) < v1874 then
				v1894("road")

				return nil
			end

			if v1880(v1897, p446) then
				v1894("overlap")

				return nil
			end

			return v1897, v1898
		end
		local function v1901(p447, p448)
			for _, v in ipairs(p447) do
				v.batch = p448

				if not v.progress then
					local v1904 = t1.Paths.nearest(v.pos)

					v.progress = v1904 and v1904.progress or 0
				end

				v.key = "pat:" .. math.floor(v.pos.X * 2) .. ":" .. math.floor(v.pos.Z * 2)

				local v1905 = math.floor(v.pos.X / v1870) .. ":" .. math.floor(v.pos.Z / v1870)

				t138[v1905] = t138[v1905] or {}
				table.insert(t138[v1905], v)
				shape[#shape + 1] = v
			end
		end

		local v1906 = t1.Paths.selected()
		local t139 = {}

		for _, path in ipairs(p438.paths) do
			if v1906 == nil or v1906[path.index] then
				t139[#t139 + 1] = path
			end
		end

		if #t139 == 0 then
			local now = os.clock()

			Plan._shapeKey = p439
			Plan._shape = shape
			Plan._shapeTally = shapeTally
			Plan._shapeAt = now

			return shape
		end

		local v1911 = v1874
		local v1912 = math.clamp(t1.Plan.midRange() * 0.8, v1874 + v1875 + 3 * v1870 * 0.866, 32)
		local n53 = 0
		local n54 = 0
		local huge = math.huge
		local huge2 = math.huge
		local v1917 = -math.huge
		local v1918 = -math.huge

		for _, v in ipairs(t139) do
			local points = v.points

			for i = 1, #points do
				local v1923 = points[i]

				huge = math.min(huge, v1923.X)
				huge2 = math.min(huge2, v1923.Z)
				v1917 = math.max(v1917, v1923.X)
				v1918 = math.max(v1918, v1923.Z)

				if i > 1 then
					local v1924 = t1._flat(v1923 - points[i - 1])
					local v1925 = math.atan2(v1924.Z, v1924.X) * 4

					n53 += math.cos(v1925) * v1924.Magnitude
					n54 += math.sin(v1925) * v1924.Magnitude
				end
			end
		end

		local shapeTheta = math.atan2(n54, n53) / 4

		Plan._shapeTheta = shapeTheta

		local vector3 = Vector3.new(math.cos(shapeTheta), 0, math.sin(shapeTheta))
		local vector32 = Vector3.new(-vector3.Z, 0, vector3.X)
		local vector33 = Vector3.new((huge + v1917) / 2, 0, (huge2 + v1918) / 2)
		local v1930 = math.max(v1917 - huge, v1918 - huge2) / 2 + v1912 + v1870 * 2
		local v1931 = math.ceil(v1930 / (Honeycomb.b[2] * v1870)) + 1
		local v1932 = math.ceil(v1930 / (Honeycomb.a[1] * v1870) + v1931 * Honeycomb.b[1] / Honeycomb.a[1]) + 2
		local v1933 = math.max(v1912, 4)
		local t140 = {}

		for _, v in ipairs(t139) do
			local points = v.points
			local n55 = 0
			local n56 = 0

			for i = 1, #points - 1 do
				n56 += t1._flat(points[i + 1] - points[i]).Magnitude
			end

			for i = 1, #points - 1 do
				local v1942 = points[i]
				local v1943 = points[i + 1]
				local Magnitude = t1._flat(v1943 - v1942).Magnitude

				if Magnitude > 0.001 then
					local t141 = {
						a = v1942,
						b = v1943,
						run = n55,
						len = Magnitude,
						total = math.max(n56, 0.001)
					}

					for i2 = math.floor((math.min(v1942.X, v1943.X) - v1912) / v1933), math.floor((math.max(v1942.X, v1943.X) + v1912) / v1933) do
						for i3 = math.floor((math.min(v1942.Z, v1943.Z) - v1912) / v1933), math.floor((math.max(v1942.Z, v1943.Z) + v1912) / v1933) do
							local v1948 = i2 .. ":" .. i3
							local v1949 = t140[v1948]

							if not v1949 then
								v1949 = {}
								t140[v1948] = v1949
							end

							v1949[#v1949 + 1] = t141
						end
					end
				end

				n55 += Magnitude
			end
		end

		local function v1950(p449)
			local huge3 = math.huge
			local n57 = 0
			local n58 = 0
			local v1954 = false
			local v1955 = t140[math.floor(p449.X / v1933) .. ":" .. math.floor(p449.Z / v1933)]

			if not v1955 then
				return huge3, n57, n58
			end

			local v1956 = t1._flat(p449)

			for _, v in ipairs(v1955) do
				local a = v.a
				local b = v.b
				local v1961 = t1._flat(b - a)
				local v1962 = (v1956 - t1._flat(a)):Dot(v1961) / (v.len * v.len)
				local v1963 = math.clamp(v1962, 0, 1)
				local Magnitude = (t1._flat(a) + v1961 * v1963 - v1956).Magnitude

				if Magnitude < huge3 then
					n57 = math.clamp((v.run + v.len * v1963) / v.total, 0, 1)
					n58 = a.Y + (b.Y - a.Y) * v1963
					huge3 = Magnitude
					v1954 = v1962 < 0 and v.run < 0.001 or v1962 > 1 and v.run + v.len >= v.total - 0.001
				end
			end

			if v1954 then
				return math.huge, n57, n58
			end

			return huge3, n57, n58
		end

		for i = -v1931, v1931 do
			for i2 = -v1932, v1932 do
				for _, site in ipairs(Honeycomb.sites) do
					local v1969 = vector33 + vector3 * ((Honeycomb.a[1] * i2 + Honeycomb.b[1] * i + site[1]) * v1870) + vector32 * ((Honeycomb.a[2] * i2 + Honeycomb.b[2] * i + site[2]) * v1870)

					if not v1873(0.25) then
						return nil
					end

					local v1970, v1971, v1972 = v1950(v1969)

					if not (v1911 <= v1970) or not (v1970 <= v1912) or not t1.Cover.inside(v1971) then
						continue
					end

					local v1973, v1974 = v1895(v1969 + Vector3.new(0, v1972, 0))

					if v1973 == false then
						return nil
					end

					if v1973 then
						v1901({ {
							pos = v1973,
							dir = vector3,
							tile = site[3],
							progress = v1971,
							onHill = v1974 or nil,
							row = math.max(0, math.floor((v1970 - v1911) / (v1870 * 0.866)))
						} }, 0)
					end
				end
			end
		end

		local now = os.clock()

		Plan._shapeKey = p439
		Plan._shape = shape
		Plan._shapeTally = shapeTally
		Plan._shapeAt = now

		if #shape == 0 then
			t1._alarm("play", 3.1, "play:pattern")
			t1._alarm("esp", 3.1, "esp:pattern")
		end

		return shape
	end
	t1.Plan.bandText = function()
		local _shape = t1.Plan._shape
		local _shapeTally = t1.Plan._shapeTally
		local v1978 = t1.Plan.design()

		if v1978 == "Random" then
			return "[RANDOM] Any Open Ground | No Pattern"
		end

		if t1.Plan._shapeErr then
			return "[ERROR] " .. v1978 .. " | " .. t1.Plan._shapeErr
		end

		if t1.Plan._shapeBuilding then
			return "[WAITING] Awaiting " .. v1978 .. " | Building Spots"
		end

		if not _shape then
			return "[WAITING] Awaiting Lanes | Match"
		end

		local t142 = {}

		for _, v in ipairs({
			"props",
			"bounds",
			"ground",
			"road",
			"overlap"
		}) do
			if _shapeTally and _shapeTally[v] then
				t142[#t142 + 1] = t1._title(v) .. " " .. _shapeTally[v]
			end
		end

		local n59 = 0

		for _, v in ipairs(_shape) do
			if not v.onHill then
				n59 += 1
			end
		end

		return "[SPOTS] " .. n59 .. " " .. v1978 .. " Spots" .. (#t142 > 0 and " | Refused: " .. table.concat(t142, ", ") or "")
	end
	t1.Plan.spotsText = function()
		local t143 = {}

		if t1._has(t12.EspSpotKinds, "Ground") then
			t143[#t143 + 1] = t1.Plan.bandText()
		end

		if t1._has(t12.EspSpotKinds, "Hill") and t1.Plan._shape and t1.Plan.design() ~= "Random" then
			local n60 = 0

			for _, v in ipairs(t1.Plan._shape) do
				if v.onHill then
					n60 += 1
				end
			end

			local _, v1990 = t1.Place.folders()

			if v1990 then
				if n60 == 0 then
					t143[#t143 + 1] = "[NONE] Hill Tiles | No Hill In Deploy Coverage"
				else
					t143[#t143 + 1] = "[SPOTS] " .. n60 .. " Hill Tiles | " .. t1.Plan.design()
				end
			else
				t143[#t143 + 1] = "[NONE] Hill Tiles | No Hills On This Map"
			end
		end

		return #t143 > 0 and table.concat(t143, "\n") or "[IDLE] Show Spots | None Picked"
	end
	t1.Plan.drawn = function(p450, p451, p452)
		local Plan = t1.Plan
		local orderKey = tostring(p450) .. ":" .. t1.Cover.key()

		if Plan._orderKey ~= orderKey then
			local order = {}

			for _, v in ipairs(p450) do
				if t1.Cover.inside(v.progress) then
					order[#order + 1] = v
				end
			end

			table.sort(order, function(p453, p454)
				if p453.row == p454.row then
					return p453.progress < p454.progress
				end

				return p453.row < p454.row
			end)
			Plan._orderKey = orderKey
			Plan._order = order
		end

		local v1996 = p452 or math.max(1, math.floor(t1._n(t12.EspSpotLimit, 6000)))
		local t144 = {
			ground = {},
			hill = {}
		}
		local v1998 = coroutine.isyieldable()

		for i, v in ipairs(Plan._order) do
			if t1.Place.clear(v.pos, 0.9, p451) then
				local v2001 = t144[v.onHill and "hill" or "ground"]

				v2001[#v2001 + 1] = v
			end

			if v1998 and i % 400 == 0 then
				task.wait()
			end
		end

		local t145 = {}

		for _, v in ipairs({
			"ground",
			"hill"
		}) do
			local v2005 = t144[v]
			local n61 = 1
			local n62 = 0

			while n61 <= #v2005 and n62 < v1996 do
				local v2008 = n61

				while v2008 < #v2005 and v2005[v2008 + 1].row == v2005[n61].row do
					v2008 += 1
				end

				local v2009 = v2008 - n61 + 1

				if n62 + v2009 <= v1996 then
					for i = n61, v2008 do
						t145[#t145 + 1] = v2005[i]
					end

					n62 += v2009
				else
					local v2011 = v1996 - n62

					for i = 1, v2011 do
						t145[#t145 + 1] = v2005[n61 + math.floor((i - 0.5) * v2009 / v2011)]
					end

					n62 = v1996
				end

				n61 = v2008 + 1
			end
		end

		return t145
	end
	t1.Plan.bandPick = function(p455, p456, p457, p458)
		local v2013 = t1.Plan.design()
		local v2014 = t1.Plan.shapeSpots(v2013, true)

		if not v2014 or #v2014 == 0 then
			return nil
		end

		local v2015 = t1.Plan.drawn(v2014, p457, math.huge)
		local v2016 = t1.Data.hill(p455.id)
		local v2017 = t1.Data.hybrid(p455.id)
		local v2018 = t1.Data.profile(p455.id, p455.entry)
		local role = v2018.role
		local v2020 = t1.Data.range(p455.id, 1)
		local v2021 = t1.Data.radius(p455.id)
		local v2022 = t1.Place.gap()
		local v2023 = t1.Place.rowPitch()
		local v2024 = t1.Cover.weight(p458, t70[p458])
		local t146 = {}
		local t147 = {}
		local n63 = 0

		for _, v in ipairs(p456) do
			if v.pos then
				t146[#t146 + 1] = v.pos

				local v2030 = t1.Data.role(v.id)

				if v2030 ~= "Farm" and v2030 ~= "Support" then
					local v2031 = t1._n(t1.Data.profile(v.id).dps)

					t147[#t147 + 1] = {
						pos = t1._flat(v.pos),
						dps = v2031
					}
					n63 = math.max(n63, v2031)
				end
			end
		end

		local v2032 = role == "Support" and not v2018.hold

		if v2032 and #t147 == 0 then
			for _, v in ipairs(t1.Match.slots()) do
				if v.role == "Farm" or v.role == "Support" then
					continue
				end

				if t1.Play.rarityOk(v.id) then
					if t1.Play.fails[v.id] then
						local v2035 = t1.Play.fails[v.id]

						if os.clock() < v2035 then
							continue
						end
					end

					if not (t1.Play.count(v.id) < t1.Play.limit(v)) then
						continue
					end

					return nil, "attackers"
				end
			end
		end

		local Plan = t1.Plan
		local bandCovKey = tostring(Plan._shapeKey) .. ":" .. t1.Paths.selKey() .. ":" .. t1.Cover.key()

		if Plan._bandCovKey ~= bandCovKey then
			Plan._bandCovKey = bandCovKey
			Plan._bandCovs = {}
		end

		local v2038 = math.floor(v2020 * 2)

		Plan._bandCovs[v2038] = Plan._bandCovs[v2038] or {}

		local v2039 = Plan._bandCovs[v2038]
		local t148 = {}
		local n64 = 0

		for _, v in ipairs(v2015) do
			local key = v.key

			if (v2017 or v.onHill == true == v2016) and not t1.Place.isRefused(v.key) and t1.Place.clear(v.pos, v2021, p457, v2022) then
				local v2045 = false
				local v2046, v2047, v2048 = ipairs(t146)
				local v2049 = geniter(v2046, v2047, v2048)

				while true do
					local v2050 = table.pack(v2049())

					if v2050[1] then
						local v2051 = t1._flat(v2050[3] - v.pos)

						if v2051.X * v2051.X + v2051.Z * v2051.Z <= (v2023 * 1.6) ^ 2 then
							v2045 = true

							break
						end
					else
						break
					end
				end

				local v2052
				local v2053

				if role == "Farm" then
					v2053 = math.min(v.row, 3) * 10 + (v2045 and 5 or 0) - v.progress
				elseif v2032 and #t147 > 0 then
					local n65 = 0
					local n66 = 0
					local v2056 = t1._flat(v.pos)
					local v2057, v2058, v2059 = ipairs(t147)

					for _, v2 in v2057, v2058, v2059 do
						if (v2.pos - v2056).Magnitude <= v2020 then
							n65 += 1
							n66 += n63 > 0 and v2.dps / n63 or 1
						end
					end

					if not v2039[key] then
						v2039[key] = t1.Place.coverage(v.pos, v2020, v2024)
						n64 += 1
					end

					v2053 = n65 * 1000000 + n66 * 10000 + v2039[key]

					local v2062 = n65 > 0

					if v2062 then
						v2062 = "Buffs " .. n65 .. " Unit" .. (n65 == 1 and "" or "s")
					end

					v2052 = v2062 or nil
				else
					if not v2039[key] then
						v2039[key] = t1.Place.coverage(v.pos, v2020, v2024)
						n64 += 1
					end

					v2053 = v2039[key] * (v2045 and 1.05 or 1) - v.row * 0.001
				end

				t148[#t148 + 1] = {
					c = v,
					v = v2053,
					why = v2052
				}

				if n64 >= 40 then
					n64 = 0
					task.wait()
				end
			end
		end

		table.sort(t148, function(p459, p460)
			return p459.v > p460.v
		end)

		local v2063
		local why

		for i = 1, math.min(12, #t148) do
			local c = t148[i].c

			if t1.Place.check(c.pos, p455.id, v2021, p457, v2022) then
				why = t148[i].why
				v2063 = c

				break
			end

			t1.Place.refused[c.key] = os.clock() + 20
		end

		if not v2063 then
			return nil
		end

		local t149 = {
			pos = v2063.pos,
			key = v2063.key,
			why = v2013 .. " Row " .. v2063.row + 1 .. (why and ", " .. why or "")
		}

		return t149
	end
	t1.Play.spot = function(p461, p462)
		local v2068 = t1.Match.placed()

		if t12.PlaceMode == "Set Positions" then
			local v2069, v2070 = t1.Play.savedSpot(p461, v2068, p462)

			if v2070 then
				return v2069, "positions"
			end
		end

		t1.Place.rejects = nil

		local v2071, v2072 = t1.Plan.design()

		if v2071 == "Random" then
			return t1.Play.scatter(p461, p462, "Smart Deploy", t1.Cover.weight("Smart Deploy", t70["Smart Deploy"]), v2068)
		end

		if t1.Data.hill(p461.id) then
			if t1.Plan.shapeSpots(v2071, true) then
				local v2073, v2074 = t1.Plan.bandPick(p461, p462, v2068, "Smart Deploy")

				if v2073 then
					return v2073, "spot"
				end

				if v2074 == "attackers" then
					return nil, v2074
				end
			end

			v2071 = "Honeycomb"
		end

		if not t1.Data.hill(p461.id) then
			if t1.Plan.shapeSpots(v2071, true) then
				local v2075, v2076 = t1.Plan.bandPick(p461, p462, v2068, "Smart Deploy")

				if v2075 then
					return v2075, "spot"
				end

				return nil, v2076 or "full"
			end

			return nil, "building"
		end

		if v2071 ~= "Free" then
			local v2077
			local v2078

			if v2071 ~= "Rows" then
				v2077, v2078 = t1.Plan.grid(p461, p462, v2068, "Smart Deploy", v2071, v2072)
			end

			if not v2077 and (v2071 == "Rows" or v2078 == "none" or v2078 == "space") then
				local v2079, v2080 = t1.Plan.spot(p461, p462, v2068, "Smart Deploy")

				if v2079 and v2072 then
					v2079.why = "Auto: Rows, " .. tostring(v2079.why)
				end

				if v2079 or v2071 == "Rows" or v2078 == "none" then
					v2077 = v2079
					v2078 = v2080
				end
			end

			if v2077 then
				if v2072 and t1.Plan._auto then
					t1.Plan._auto.locked = t1.Match.roundId
				end

				return v2077, "spot"
			end

			if v2078 ~= "none" then
				return nil, v2078
			end
		end

		return t1.Play.scatter(p461, p462, "Smart Deploy", t1.Cover.weight("Smart Deploy", t70["Smart Deploy"]), v2068)
	end
	t1.Play.scatter = function(p463, p464, p465, p466, p467)
		local v2081 = t1.Place.candidates()

		if not v2081 then
			return nil, "map"
		end

		local role = p463.role
		local v2083 = t1.Data.range(p463.id, 1)
		local v2084 = p465 .. ":" .. math.floor(v2083) .. ":" .. t1.Paths.selKey() .. ":" .. t1.Cover.key()
		local t150 = {}
		local t151 = {}

		for _, v in ipairs(p464) do
			if v.pos then
				t151[#t151 + 1] = v.pos
			end

			if v.pos and t1.Data.role(v.id) == "Damage" then
				t150[#t150 + 1] = v.pos
			end
		end

		local function v2089(p468, p469)
			local huge = math.huge

			for _, v in ipairs(p468) do
				huge = math.min(huge, (t1._flat(v) - t1._flat(p469)).Magnitude)
			end

			return huge
		end

		local v2093 = t1.Data.radius(p463.id)
		local v2094 = t1.Place.gap()
		local v2095 = table.clone(v2081)

		if t1.Data.hill(p463.id) or t1.Data.hybrid(p463.id) then
			for _, v in ipairs(t1.Place.hillSpots()) do
				v2095[#v2095 + 1] = v
			end
		end

		for i, v in ipairs(p467) do
			local v2100 = (v2093 + v.r) * (1 + v2094) + 0.05

			for i2 = 0, 15 do
				local v2102 = i2 * math.pi / 8
				local v2103 = v.pos.X + math.cos(v2102) * v2100
				local v2104 = v.pos.Z + math.sin(v2102) * v2100
				local v2105 = t1.Place.ground(v2103, v2104, p463.id)

				if v2105 then
					v2095[#v2095 + 1] = {
						pos = v2105,
						key = "ring:" .. math.floor(v2103 * 2) .. ":" .. math.floor(v2104 * 2)
					}
				end
			end

			if i % 4 == 0 then
				task.wait()
			end
		end

		local t152 = {}

		for i, v in ipairs(v2095) do
			if not t1.Place.isRefused(v.key) then
				v.cov = v.cov or {}

				local v2109 = v.cov[v2084]

				if not v2109 then
					local v2110

					v2109, v2110 = t1.Place.coverage(v.pos, v2083, p466)
					v.cov[v2084] = v2109
					v.lane = v2110
				end

				local lane = v.lane or 0
				local v2112

				if role == "Farm" then
					v2112 = -select(1, t1.Place.coverage(v.pos, 8)) * 10 - (#t151 > 0 and math.min(v2089(t151, v.pos), 60) or lane) * 0.2
				elseif role == "Support" and #t150 > 0 then
					v2112 = v2109 * 0.2 - v2089(t150, v.pos)
				else
					v2112 = v2109 * (1 + 0.25 * (1 - math.min(1, lane / v2083))) - lane * 0.01
				end

				if role ~= "Farm" and #t151 > 0 then
					v2112 -= math.min(v2089(t151, v.pos), 20) * 0.05
				end

				if role == "Farm" or role == "Support" or v2109 > 0 then
					t152[#t152 + 1] = {
						c = v,
						score = v2112
					}
				end
			end

			if i % 150 == 0 then
				task.wait()
			end
		end

		table.sort(t152, function(p470, p471)
			return p470.score > p471.score
		end)

		for i = 1, math.min(#t152, 60) do
			local c = t152[i].c
			local v2115, v2116 = t1.Place.check(c.pos, p463.id, v2093, p467, v2094)

			if v2115 then
				if v2116 and v2116 ~= c.pos then
					c = table.clone(c)
					c.pos = v2116
				end

				return c, "spot"
			end
		end

		local v2117
		local v2118 = #t152 == 0 and "range" or "full"

		return v2117, v2118
	end
	t1.Play.lastReason = nil
	t1.Play.cframe = function(p472, p473, p474)
		if p474 then
			return (t1.Place.pivot(p474, p472, p473))
		end

		return CFrame.lookAt(p472, p472 + t1.Place.look(p473), Vector3.yAxis)
	end

	do
		t1.Play._send = function(p475, p476, p477, p478)
			local t153 = {}

			for k, v in pairs(t1.Match.records()) do
				t153[t1.Match.key(v) or tostring(k)] = true
			end

			local v2122, v2123 = t1.Place.pivot(p475.id, p476, p477)
			local TowerAdd = t1.fire("TowerAdd", {
				Name = p475.id,
				UnitId = p475.uuid,
				Pos = v2122.Position,
				CFrame = v2122
			})

			t1.Cash.replied(p478)

			if not TowerAdd then
				local v2125
				local v2126 = t1.Running and "Stopped" or "Refused"

				return v2125, v2126
			end

			local recent = t1.Match.recent

			recent[#recent + 1] = {
				pos = p476,
				r = t1.Data.radius(p475.id),
				till = os.clock() + 6
			}

			if t12.EspSpots then
				task.delay(6.2, function()
					if t1.Running then
						t1._wakeThrottled("espTowers", 0.5)
					end
				end)
			end

			t1.Place.pending[#t1.Place.pending + 1] = {
				pos = p476,
				size = v2123.size,
				at = os.clock()
			}

			local v2128 = t1._confirm(function()
				for k, v in pairs(t1.Match.records()) do
					local v2131 = t1.Match.key(v) or tostring(k)

					if t153[v2131] or v.Name ~= p475.id then
						continue
					end

					local v2132 = t1.Match.pos(v)

					if v2132 and (t1._flat(v2132) - t1._flat(p476)).Magnitude < 4 then
						t1.Match.ours[v2131] = true
						t1.Match.dirty()

						return v2131
					end
				end
			end, 2.5)

			if v2128 then
				t1._signal("placed", v2128, p475.id)

				return v2128
			end

			return nil, "Unit Sync"
		end
	end

	t1.Play.send = function(p479, p480, p481, p482)
		local v2133 = t1.Data.placeCost(p479.id)
		local v2134, v2135, v2136 = t1.Cash.claim(v2133 < math.huge and v2133 or 0, p482)

		if not v2134 then
			return nil, v2135 == "busy" and "Busy" or "Need Cash", v2136
		end

		local ok, result, result2 = pcall(t1.Play._send, p479, p480, p481, v2134)

		t1.Cash.release(v2134, ok and (result ~= nil or result2 == "Unit Sync" or result2 == "Timeout"))

		if not ok then
			return nil, "Refused"
		end

		local v2140 = "p:" .. tostring(p479.id)

		if result then
			t1.Cash.floor[v2140] = nil
		else
			local v2141 = tostring(result2 or ""):lower()

			if (v2141:find("money", 1, true) or v2141:find("cash", 1, true) or v2141:find("yen", 1, true) or v2141:find("afford", 1, true)) and t1.Cash.refused(v2140, v2134) then
				return nil, "Price", t1.Cash.floor[v2140]
			end
		end

		return result, result2
	end

	do
		t1.Play.place = function(p483, p484)
			local v2142, v2143, v2144 = t1.Play.send(p483, p484.pos, p484.rot or t1.Place.yaw(p484.pos), t12.CashReserve)

			if v2142 then
				t1.Place.refused[p484.key] = nil
				t1.Play.lastReason = nil

				return true
			end

			local v2145 = tostring(v2143 or "")

			if v2145 == "Stopped" then
				return false
			end

			if v2145 == "Busy" then
				local Play = t1.Play

				t1.Play.lastReason = "Busy"
				Play.busyBy = v2144

				return false
			end

			if v2145 == "Price" then
				local Play = t1.Play

				t1.Play.lastReason = "Price"
				Play.floorAt = v2144
				t1.Play.fails[p483.id] = os.clock() + 3
				t1._alarm("play", 3.2, "play:price")

				return false
			end

			if v2145 == "Need Cash" or t1.Cash.free(t12.CashReserve) < t1._n(p483.cost) then
				t1.Play.lastReason = "Need Cash"
				t1._alarm("play", 3, "play:cash")

				return false
			end

			if t1.Play.full(p483.id) then
				t1.Play.capped[p483.id] = true
				t1.Play.lastReason = "Unit Limit"
			elseif t1.Play.cooldown(p483.id) > 0 then
				t1.Play.lastReason = "Cooldown"
			else
				t1.Play.lastReason = "Spot Refused"

				if not t1.Place.roadBlocks() and t1.Place.onRoad(p484.pos.X, p484.pos.Z, p484.pos) then
					local Place = t1.Place

					if Place._roadMap ~= t1.Match.mapId() then
						Place._roadMap = t1.Match.mapId()
						Place._roadNo = 0
					end

					Place._roadNo += 1
				end

				local _fails = t1.Place._fails and t1.Place._failsMap == t1.Match.mapId() and t1.Place._fails or {}

				t1.Place._failsMap = t1.Match.mapId()
				t1.Place._fails = _fails
				_fails[p484.key] = (_fails[p484.key] or 0) + 1

				if (v2145 == "Timeout" and 2 or 1) <= _fails[p484.key] then
					_fails[p484.key] = 0
					t1.Place.refused[p484.key] = os.clock() + 60
					t1._alarm("play", 60, "play:refused")
				end
			end

			t1.Play.fails[p483.id] = os.clock() + 2
			t1._alarm("play", 2.2, "play:fail")

			return false
		end
	end

	t1.Play.resetCaps = function()
		table.clear(t1.Play.capped)
		table.clear(t1.Cash.floor)
		t1.Cash.reset()
	end
	t1.Play.release = function(p485, p486)
		local Play = t1.Play
		local Play2 = t1.Play

		t1.Play.done = true
		Play.saving = p485
		Play2.want = nil

		if not p486 then
			t1.Play.unplaced = false
		end

		t1._wake("upgrade")
	end
	t1.Play.timingText = function()
		local v2152 = tostring(t12.UpgradeTiming)

		if v2152 == "Place All First" then
			local v2153, v2154 = t1.Play.progress()

			return "Place All First: " .. v2153 .. "/" .. v2154 .. " Placed"
		end

		if t1.Cash.shared() then
			return "Upgrade While Deploying: Shared By Priority"
		end

		return v2152
	end

	do
		local function v2155()
			local v2156 = t1._n(t12.CashReserve)

			if v2156 > 0 then
				return " (Reserve " .. t1._fmt(v2156) .. ")"
			end
		end

		t1.Play.run = function(p487)
			if not t12.AutoPlay then
				local Play = t1.Play

				t1.Play.done = false
				Play.saving = nil
				p487.text = "[IDLE]"

				return
			end

			if t1.Macro and t1.Macro.pausing("Auto Play") then
				p487.text = "[PAUSED] Strategy Running"
				t1.Play.release()

				return
			end

			local v2158 = t1.Match.state()

			if v2158 == "LOBBY" then
				local Play = t1.Play

				t1.Play.done = false
				Play.saving = nil
				p487.text = "[WAITING] Awaiting Match"

				return
			end

			if v2158 ~= "MATCH" then
				local Play = t1.Play

				t1.Play.done = false
				Play.saving = nil
				p487.text = t1.Match.idle("[WAITING] Awaiting Match | Vote Start")

				return
			end

			if not t1.Match.ready() then
				p487.text = "[UNAVAILABLE] Game Modules"
				t1.Play.release()

				return
			end

			if not (t1.Paths.get() or t12.PlaceMode == "Set Positions") then
				p487.text = "[WAITING] Awaiting Paths"
				t1._alarm("play", 1, "play:paths")
				t1.Play.release()

				return
			end

			while t12.AutoPlay and t1.Running and t1.Match.state() == "MATCH" do
				local v2161 = t1.Match.towers()

				if t12.AutoUpgrade and t12.UpgradeTiming == "Upgrade First" and #v2161 > 0 and t1.Upg and t1.Upg.next(v2161) then
					p487.text = "[WAITING] Awaiting Upgrades | Upgrade First"

					local Play = t1.Play

					t1.Play.done = false
					Play.saving = nil

					return
				end

				local v2163, v2164, v2165, v2166 = t1.Play.pick(v2161)

				if not v2163 then
					t1.Play.want = nil

					if v2165 == "cooldown" then
						local Play = t1.Play

						t1.Play.done = false
						Play.saving = nil
					else
						t1.Play.release(v2164, true)
					end

					if v2165 == "sold" then
						p487.text = "[DONE] Deploy | Sell Wave Reached"
					elseif v2164 then
						p487.text = "[SAVING] " .. v2164.name .. " | {cash}/" .. t1._fmt(v2164.cost) .. (v2155() or "")
						t1.Plan.mark = t1.Plan.shown ~= nil

						if not t1.Plan._previewing then
							t1.Plan._previewing = true
							task.spawn(function()
								pcall(t1.Plan.preview, v2164, v2161)
								t1.Plan._previewing = false
							end)
						end
					elseif v2165 == "cooldown" then
						p487.text = "[WAITING] Awaiting Cooldown | " .. math.ceil(v2166 or 1) .. "s"
					elseif v2165 == "poor" then
						p487.text = "[WAITING] Awaiting Cash | " .. tostring(v2166 and v2166.tag or "Unit") .. " {cash}/" .. t1._fmt(v2166 and v2166.cost or 0) .. (v2155() or "")
					elseif v2165 == "space" then
						p487.text = "[WAITING] Awaiting Space | " .. tostring(v2166 and v2166.tag or "Unit") .. t1.Place.rejectText()
						t1._alarm("play", 5.2, "play:spot")
					elseif v2165 == "empty" then
						p487.text = "[WAITING] Awaiting Loadout"
					elseif v2165 == "rarity" then
						p487.text = "[WAITING] Awaiting Unit | No " .. t1.Play.names(t12.DeployRarities) .. " Equipped"
					elseif v2165 == "upgrade" then
						p487.text = "[WAITING] Awaiting Upgrade | " .. tostring(v2166 and v2166.tag or "Unit") .. " Group " .. tostring(v2166 and v2166.group or "")
						t1._alarm("play", 3, "play:upgturn")
					else
						p487.text = "[DONE] Deploy Plan | " .. #v2161 .. " Placed"
					end

					return
				end

				local Play = t1.Play
				local Play2 = t1.Play

				t1.Play.done = false
				Play.saving = nil
				Play2.want = v2163

				local spot
				local v2171
				local previewSpot = t1.Plan.previewSpot

				t1.Plan.previewSpot = nil

				if previewSpot and previewSpot.id == v2163.id and previewSpot.map == t1.Match.mapId() and not t1.Place.isRefused(previewSpot.spot.key) and t1.Place.check(previewSpot.spot.pos, v2163.id, t1.Data.radius(v2163.id), t1.Match.placed(), t1.Place.gap()) then
					spot = previewSpot.spot
				end

				if not spot then
					spot, v2171 = t1.Play.spot(v2163, v2161)
				end

				if not spot then
					if v2171 == "building" then
						p487.text = "[WAITING] Awaiting " .. t1.Plan.design() .. " | Building Spots"
						t1.Play.release()
						t1._alarm("play", 1, "play:pattern")

						return
					end

					if v2171 == "positions" then
						p487.text = "[WAITING] Awaiting Spots | " .. v2163.tag .. " Full"
					elseif v2171 == "attackers" then
						p487.text = "[WAITING] Awaiting Attackers | " .. v2163.tag .. " Buffs Them"
					elseif v2171 == "map" then
						p487.text = "[WAITING] Awaiting Spots"
					elseif v2171 == "full" and t1.Cover.window() and v2163.role ~= "Farm" then
						p487.text = "[WAITING] Awaiting Space | Coverage Full (" .. t1.Cover.short() .. ")"
					else
						p487.text = "[WAITING] Awaiting Space | " .. v2163.tag .. t1.Place.rejectText()
					end

					t1.Play.fails[v2163.id] = os.clock() + 5
					t1._alarm("play", 5.2, "play:spot")
					t1.Play.release()

					return
				end

				t1.Play.want = v2163
				p487.text = "[DEPLOY] " .. v2163.tag .. " | " .. (spot.why or "Slot " .. v2163.slot)
				t1.Plan.show(v2163, spot, spot.why or "Slot " .. v2163.slot)
				t1._wake("status")

				local v2173 = t1.Play.place(v2163, spot)

				if v2173 then
					t1.Plan.hide()
				end

				if not v2173 and t1.Play.lastReason then
					p487.text = "[RETRY] " .. v2163.tag .. " | " .. t1._title(t1.Play.lastReason)

					if t1.Play.lastReason == "Busy" then
						p487.text = t1.Cash.busyText(t1.Play.busyBy)

						return
					end

					if t1.Play.lastReason == "Price" then
						t1.Play.want = nil
						p487.text = "[SAVING] " .. v2163.tag .. " | {cash}/" .. t1._fmt(t1.Play.floorAt) .. " (price above estimate)"

						return
					end

					if t1.Play.lastReason == "Need Cash" or t1.Play.lastReason == "Cooldown" then
						if t1.Play.lastReason == "Need Cash" then
							t1.Play.release(v2163)
						end

						return
					end
				end

				if t1._pause("deploy", t12.DeployDelay, p487, "Next Placement") then
					continue
				end

				return
			end
		end
	end

	t1._worker("play", owner, function(p488)
		t1.Plan.mark = false

		local ok, result = pcall(t1.Play.run, p488)

		if not t1.Plan.mark then
			t1.Plan.hide()
		end

		if not ok then
			error(result, 0)
		end
	end)
	t1.Upg = {
		owner = {
			text = "[IDLE]"
		}
	}

	do
		local owner2 = t1.Upg.owner

		t1._allWorkers[#t1._allWorkers + 1] = "upgrade"
		t1.Upg.slotOf = function(p489)
			local v2177 = t1.Match.slots()
			local id = p489
			local uuid

			if type(p489) == "table" then
				id = p489.id
				uuid = p489.uuid
			end

			if uuid ~= nil then
				for _, v in ipairs(v2177) do
					if v.uuid == uuid then
						return v.slot
					end
				end
			end

			for _, v in ipairs(v2177) do
				if v.id == id then
					return v.slot
				end
			end

			return nil
		end
		t1.Upg.cost = function(p490)
			local v2184 = t1.Units.stats(p490.id, p490.level + 1)
			local v2185 = v2184 and tonumber(v2184.Price)

			if v2185 then
				local level = p490.level

				if not (t1.Data.maxLevel(p490.id) <= level) then
					return t1.Cash.price("u:" .. tostring(p490.hash) .. ":" .. tostring(p490.level), math.ceil(v2185 * t1.Data.costScale()))
				end
			end

			return math.huge
		end
		t1.Upg._info = {}

		local function info(p491, p492)
			local v2188 = tostring(p491) .. ":" .. tostring(p492)
			local v2189 = t1.Upg._info[v2188]

			if not v2189 then
				v2189 = {
					role = t1.Data.role(p491),
					max = t1.Data.maxLevel(p491),
					gain = math.max(t1.Data.worth(p491, p492 + 1) - t1.Data.worth(p491, p492), 0)
				}

				if t1.Data.cfg(p491) ~= nil then
					t1.Upg._info[v2188] = v2189
				end
			end

			return v2189
		end

		t1.Upg.info = info
		t1._cleanups[#t1._cleanups + 1] = function()
			t1.Upg._info = {}
		end
		t1.Upg.source = function()
			local v2190 = tostring(t12.UpgradeStrategy or "Balanced")
			local v2191 = t12.FarmUpgradeMode == "Farms First" and " | Farms First" or t12.FarmUpgradeMode == "Never" and " | Farms Never" or ""

			return (t12.UpgradePriority and "Upgrade Priority > " .. v2190 or v2190) .. v2191
		end
		t1.Upg.farmPicked = function(p493)
			return table.find(t12.UpgradeFarmUnits, t1.Data.name(p493)) ~= nil
		end
		t1.Upg.header = function()
			return "[ORDER] " .. t1.Upg.source()
		end
		t1.Upg.roleRank = function(p494, p495)
			local UpgradeStrategy = t12.UpgradeStrategy

			if UpgradeStrategy == "Damage First" then
				return p494 == "Damage" and 0 or p494 == "Support" and 1 or 2
			end

			if UpgradeStrategy == "Cheapest First" or UpgradeStrategy == "Lowest Level First" then
				return 0
			end

			local v2193 = t1._has(t12.UpgradeActions, "Farms Early") and p494 == "Farm"

			if v2193 then
				v2193 = (p495 or 0) <= t1._n(t12.FarmsEarlyWave, 10)
			end

			return v2193 and 0 or 1
		end
		t1.Upg.build = function(p496)
			local v2194 = t12.UpgradePriority == true
			local value = select(1, t1.Match.wave())
			local UpgradeStrategy = t12.UpgradeStrategy
			local v2197 = t1._has(t12.UpgradeActions, "Skip Late Farm Upgrades") and t1.Match.wavesLeft() < t1._n(t12.SkipLateFarmWaves, 4)
			local FarmUpgradeMode = t12.FarmUpgradeMode
			local t154 = {}

			t1.Upg.backed = 0

			for _, v in ipairs(p496) do
				local v2202 = t1.Upg.slotOf(v)
				local v2203 = v2194 and v2202 and t12["SlotUpgPri" .. v2202] or nil
				local v2204 = v2203 ~= "OFF" and t1._backed("upgrade:" .. tostring(v.hash))

				if v2204 then
					t1.Upg.backed += 1
				end

				if not (v2203 == "OFF" or v2204) then
					local v2205 = t1.Upg.info(v.id, v.level)
					local v2206 = v2194 and v2202 and t1._n(t12["SlotMaxLevel" .. v2202]) or 0
					local max = v2206 > 0 and math.min(v2205.max, v2206) or v2205.max
					local v2208 = v.level < max

					if v2208 then
						v2208 = not ((v2197 or FarmUpgradeMode == "Never" or not t1.Upg.farmPicked(v.id)) and v2205.role == "Farm")
					end

					v2208 = v2208 and t1.Upg.cost(v) or math.huge

					if v2208 < math.huge then
						local v2209 = v2205.gain / math.max(v2208, 1)
						local v2210 = FarmUpgradeMode == "Farms First" and v2205.role == "Farm" and 0 or 1
						local level = t1.Upg.roleRank(v2205.role, value)
						local level2

						if UpgradeStrategy == "Cheapest First" then
							level2 = v.level
							level = v2208
						elseif UpgradeStrategy == "Lowest Level First" then
							level = v.level
							level2 = v2208
						elseif UpgradeStrategy == "Finish One First" then
							level = -v.level
							level2 = v2208
						elseif UpgradeStrategy == "Priciest First" then
							level = -v2208
							level2 = v.level
						elseif UpgradeStrategy == "Strongest First" then
							level = -t1._n(t1.Data.profile(v.id).dps)
							level2 = v2208
						elseif v2210 == 0 or UpgradeStrategy == "Damage First" then
							level2 = v2205.role == "Farm" and v2208 or -v2209
						else
							level2 = level == 0 and v2208 or -v2209
						end

						t154[#t154 + 1] = {
							t = v,
							slot = v2202,
							group = v2194 and (tonumber(v2203) or v2202 or 99) or 0,
							cost = v2208,
							capped = max < v2205.max,
							tag = t1.Data.tag(v.id),
							role = v2205.role,
							k0 = v2210,
							k1 = level,
							k2 = level2
						}
					end
				end
			end

			table.sort(t154, function(p497, p498)
				if p497.group ~= p498.group then
					return p497.group < p498.group
				end

				if p497.k0 ~= p498.k0 then
					return p497.k0 < p498.k0
				end

				if p497.k1 ~= p498.k1 then
					return p497.k1 < p498.k1
				end

				if p497.k2 == p498.k2 then
					return tostring(p497.t.hash) < tostring(p498.t.hash)
				end

				return p497.k2 < p498.k2
			end)

			return t154
		end
		t1.Upg.restNote = function(p499, p500)
			if #p499 == 0 then
				return "[WAITING] Awaiting Units"
			end

			if #p500 == 0 then
				if (t1.Upg.backed or 0) > 0 then
					return "[RETRY] Upgrade | " .. t1.Upg.backed .. " Backing Off"
				end
			end

			return "[DONE] Settings Reached"
		end
		t1.Upg.next = function(p501)
			return t1.Upg.build(p501)[1]
		end
		t1.Upg.publish = function(p502, p503)
			t1.Match.slots()

			local v2213 = t1.Upg.header()
			local t155 = {
				v2213,
				tostring(p503),
				#p502
			}

			for i = 1, math.min(5, #p502) do
				local v2216 = p502[i]

				t155[#t155 + 1] = tostring(v2216.t.hash) .. ":" .. v2216.t.level .. ":" .. v2216.cost .. ":" .. v2216.group
			end

			local planSig = table.concat(t155, "|")
			local Upg = t1.Upg
			local Upg2 = t1.Upg
			local Upg3 = t1.Upg
			local Upg4 = t1.Upg
			local now = os.clock()

			Upg.plan = p502
			Upg2.planNote = p503
			Upg3.planHead = v2213
			Upg4.planAt = now

			if planSig ~= t1.Upg.planSig then
				t1.Upg.planSig = planSig
				t1._wake("status")
			end
		end
		t1.Upg._one = function(p504, p505)
			local level = p504.level
			local TowerUpgrade = t1.fire("TowerUpgrade", {
				Id = p504.rec.Id or p504.hash
			})

			t1.Cash.replied(p505)

			if TowerUpgrade then
				return t1._confirm(function()
					local v2225 = t1.Match.tower(p504.hash)

					return v2225 and t1._n(v2225.Level, 1) > level
				end, 2.5) ~= nil, false
			end

			return false, false
		end
		t1.Upg.one = function(p506, p507)
			local v2226 = t1.Upg.cost(p506)
			local v2227, v2228, v2229 = t1.Cash.claim(v2226 < math.huge and v2226 or 0, p507)

			if not v2227 then
				return false, v2228, v2229
			end

			local ok, result, result2 = pcall(t1.Upg._one, p506, v2227)

			t1.Cash.release(v2227, ok and result2 ~= true)

			local v2233 = "u:" .. tostring(p506.hash) .. ":" .. tostring(p506.level)

			if ok and result then
				t1.Cash.floor[v2233] = nil

				if t1.Upg.info(p506.id, p506.level).role == "Farm" then
					t1.Upg.lastFarm = {
						tag = t1.Data.tag(p506.id),
						level = p506.level + 1,
						at = os.clock(),
						round = t1.Match.roundId
					}
				end

				if t1.Cash.shared() then
					t1._wake("play")
				end

				return true
			end

			local v2234 = ok and result2 and t1.Cash.refused(v2233, v2227)

			if v2234 then
				return false, "price", v2234
			end

			return false, ok and result2 and "refused" or "sync"
		end
		t1._worker("upgrade", owner2, function(p508)
			if not t12.AutoUpgrade then
				t1.Upg.publish({})
				p508.text = "[IDLE]"

				return
			end

			local v2235 = " | " .. t1.Upg.source()

			if t1.Match.state() ~= "MATCH" then
				local v2236 = t1.Match.idle()

				t1.Upg.publish({}, v2236)
				p508.text = v2236 .. v2235

				return
			end

			if not t1.Match.ready() then
				t1.Upg.publish({}, "[UNAVAILABLE] Game Modules")
				p508.text = "[UNAVAILABLE] Game Modules" .. v2235

				return
			end

			while t12.AutoUpgrade and t1.Running and t1.Match.state() == "MATCH" do
				local v2237 = " | " .. t1.Upg.source()
				local v2238 = t1.Match.towers()
				local v2239 = t1.Upg.build(v2238)

				t1.Upg.publish(v2239, t1.Upg.restNote(v2238, v2239))

				if t1.Macro and t1.Macro.pausing("Auto Upgrade") then
					p508.text = "[PAUSED] Strategy Running" .. v2237

					return
				end

				if t12.AutoPlay and t12.UpgradeTiming == "Deploy First" and not t1.Play.done then
					p508.text = "[WAITING] Awaiting Deploys | Deploy First" .. v2237

					return
				end

				if t12.AutoPlay and t12.UpgradeTiming == "Place All First" and t1.Play.unplaced then
					local v2240, v2241 = t1.Play.progress()

					p508.text = "[WAITING] Awaiting Deploys | " .. v2240 .. "/" .. v2241 .. " Placed" .. v2237

					return
				end

				if #v2238 == 0 then
					p508.text = "[WAITING] Awaiting Units" .. v2237

					return
				end

				local v2242 = v2239[1]

				if not v2242 then
					if t1.Upg.backed > 0 then
						p508.text = "[RETRY] Upgrade | " .. t1.Upg.backed .. " Backing Off" .. v2237

						return
					end

					p508.text = "[DONE] Upgrades | " .. #v2238 .. " Units" .. v2237

					return
				end

				local t = v2242.t
				local tag = v2242.tag
				local v2245 = tag .. " Lv" .. t.level + 1
				local saving = t12.AutoPlay and t1.Play.saving
				local v2247 = saving and t1.Cash.shared() and saving.slot and v2242.group < t1.Play.rank(saving)
				local v2248 = saving and not v2247 and (t12.UpgradeTiming == "Deploy First" or t1._has(t12.DeployActions, "Save For Top Pick")) and t1._n(saving.cost) or 0
				local v2249, v2250 = t1.Cash.turn()

				if v2249 == "play" then
					if v2242.cost <= t1.Cash.free(t1._n(t12.UpgradeReserve) + v2248) and t1.Cash.free(t1._n(t12.UpgradeReserve) + v2248 + t1._n(v2250.cost)) < v2242.cost then
						p508.text = "[WAITING] Awaiting Deploy | " .. v2250.tag .. v2237
						t1._alarm("upgrade", 1.5, "upgrade:turn")

						return
					end

					v2248 += t1._n(v2250.cost)
				end

				local v2251 = t1._n(t12.UpgradeReserve) + v2248

				if t1.Cash.free(v2251) < v2242.cost then
					p508.text = "[SAVING] " .. v2245 .. " | {cash}/" .. t1._fmt(v2242.cost + v2248) .. v2237

					return
				end

				p508.text = "[UPGRADE] " .. tag .. " | Level " .. t.level + 1 .. v2237
				t1._wake("status")

				local v2252, v2253, v2254 = t1.Upg.one(t, v2251)

				if v2252 then
					t1.Match.dirty()

					local v2255 = t1.Match.towers()
					local v2256 = t1.Upg.build(v2255)

					t1.Upg.publish(v2256, t1.Upg.restNote(v2255, v2256))

					if t1._pause("upgrade", t12.UpgradeDelay, p508, "Next Upgrade") then
						continue
					end

					return
				end

				if v2253 == "busy" then
					p508.text = t1.Cash.busyText(v2254) .. v2237

					return
				end

				if v2253 == "cash" then
					p508.text = "[SAVING] " .. v2245 .. " | {cash}/" .. t1._fmt(v2242.cost + v2248) .. v2237

					return
				end

				t1._backoff("upgrade:" .. tostring(t.hash), v2253 == "price" and 3 or 4)

				if v2253 == "price" then
					p508.text = "[SAVING] " .. v2245 .. " | {cash}/" .. t1._fmt(v2254) .. " (price above estimate)" .. v2237
				else
					p508.text = "[RETRY] " .. v2245 .. " | Server Refused" .. v2237
				end

				return
			end
		end)
	end

	t1.Assist = {
		owner = {
			text = "[IDLE]"
		},
		want = false,
		fromKey = false
	}

	do
		local owner2 = t1.Assist.owner

		t1._allWorkers[#t1._allWorkers + 1] = "assist"
		t1.Assist.UNITS = {
			"Auto Play's Pick",
			"Cheapest",
			"Priciest",
			"Slot 1",
			"Slot 2",
			"Slot 3",
			"Slot 4",
			"Slot 5"
		}
		t1.Assist.SPOTS = {
			"Near Character",
			"Near Mouse",
			"Same As Auto Play"
		}
		t1.Assist.COUNTS = {
			"1",
			"2",
			"3",
			"All Affordable"
		}
		t1.Assist.press = function(p509)
			local Assist = t1.Assist

			t1.Assist.want = true
			Assist.fromKey = p509 == true
			t1._wake("assist")
		end
		t1.Assist.summary = function()
			return (t12.AssistCount == "All Affordable" and "All Affordable" or tostring(t12.AssistCount) .. "x") .. " " .. tostring(t12.AssistUnit) .. " | " .. tostring(t12.AssistSpot)
		end
		t1.Assist.pick = function(p510)
			local v2259 = tostring(t12.AssistUnit)

			if v2259 == "Auto Play's Pick" then
				return (t1.Play.pick(p510))
			end

			local v2260 = t1.Cash.free(t12.AssistReserve)
			local v2261

			for _, v in ipairs(t1.Match.slots()) do
				if (v2259 == "Cheapest" or v2259 == "Priciest" or v2259 == "Slot " .. v.slot) and not t1.Play.full(v.id) and t1.Play.cooldown(v.id) <= 0 then
					local v2264 = t1.Data.placeCost(v.id)

					v.cost = v2264

					if v2264 <= v2260 and (not v2261 or v2259 == "Priciest" and v2261.cost < v2264 or v2259 ~= "Priciest" and v2264 < v2261.cost) then
						v2261 = v
					end
				end
			end

			return v2261
		end
		t1.Assist.aim = function()
			if t12.AssistSpot == "Near Mouse" and t1.Assist.fromKey and UserInputService.MouseEnabled then
				local CurrentCamera = workspace.CurrentCamera
				local v2266, v2267, v2268 = t1.Place.folders()

				if CurrentCamera and v2266 then
					local mouseLocation = UserInputService:GetMouseLocation()
					local v2270 = CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
					local raycastParams = RaycastParams.new()

					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = {
						v2266,
						v2267,
						v2268
					}

					local hit = workspace:Raycast(v2270.Origin, v2270.Direction * 1000, raycastParams)

					if hit then
						return hit.Position
					end
				end
			end

			local v2273 = t1._hrp()

			return v2273 and v2273.Position or nil
		end
		t1.Assist.near = function(p511, p512)
			local v2274 = t1.Match.placed()
			local v2275 = t1.Data.radius(p511.id)
			local v2276 = t1.Place.gap()
			local v2277 = math.max(v2275 * 2 * (1 + v2276), 1.5)

			local function v2278(p513, p514)
				local v2279 = t1.Place.ground(p513, p514, p511.id)

				if v2279 and t1.Place.clear(v2279, v2275, v2274, v2276) and t1.Place.valid(v2279, p511.id) then
					return {
						pos = v2279,
						key = "assist:" .. math.floor(p513 * 2) .. ":" .. math.floor(p514 * 2)
					}
				end

				return nil
			end

			local v2280 = v2278(p512.X, p512.Z)

			if v2280 then
				return v2280
			end

			for i = 1, 6 do
				local v2282 = v2277 * i
				local v2283 = math.max(8, math.floor(6.2831853071795862 * v2282 / v2277))

				for i2 = 0, v2283 - 1 do
					local v2285 = i2 / v2283 * 2 * math.pi
					local v2286 = v2278(p512.X + math.cos(v2285) * v2282, p512.Z + math.sin(v2285) * v2282)

					if v2286 then
						return v2286
					end
				end

				task.wait()
			end

			return nil
		end
		t1.Assist.spot = function(p515, p516)
			if t12.AssistSpot == "Same As Auto Play" then
				return (t1.Play.spot(p515, p516))
			end

			local v2287 = t1.Assist.aim()

			return v2287 and t1.Assist.near(p515, v2287) or nil
		end
		t1.Assist.upgrade = function(p517, p518, p519)
			local v2288

			for i = 1, math.floor(t1._n(t12.AssistUpgrades)) do
				if t12.DeployAssist and t1.Running and t1.Match.state() == "MATCH" then
					local v2290 = t1.Match.tower(p519)

					if v2290 then
						local v2291 = t1.Match.row(v2290)
						local v2292 = t1.Upg.cost(v2291)
						local level = v2291.level

						if not (t1.Data.maxLevel(v2291.id) <= level) and v2292 ~= math.huge then
							if t1.Cash.free(t12.AssistReserve) < v2292 then
								v2288 = "[SAVING] " .. p518.tag .. " Lv" .. v2291.level + 1 .. " | {cash}/" .. t1._fmt(v2292)

								break
							end

							p517.text = "[UPGRADE] " .. p518.tag .. " | Level " .. v2291.level + 1
							t1._wake("status")

							local v2294, v2295, v2296 = t1.Upg.one(v2291, t12.AssistReserve)

							if v2294 then
								v2288 = "[UPGRADED] " .. p518.tag .. " | Level " .. v2291.level + 1

								continue
							end

							if v2295 == "busy" then
								v2288 = t1.Cash.busyText(v2296)
							elseif v2295 == "cash" or v2295 == "price" then
								v2288 = "[SAVING] " .. p518.tag .. " Lv" .. v2291.level + 1 .. " | {cash}/" .. t1._fmt(v2295 == "price" and v2296 or v2292)
							else
								v2288 = "[REFUSED] " .. p518.tag .. " Lv" .. v2291.level + 1 .. " | Server Refused"
							end

							break
						end
					end
				end

				break
			end

			return v2288
		end
		t1._worker("assist", owner2, function(p520)
			local Assist = t1.Assist

			if not t12.DeployAssist then
				Assist.want = false
				p520.text = "[IDLE]"

				return
			end

			if t1.Match.state() ~= "MATCH" then
				Assist.want = false
				p520.text = t1.Match.idle()

				return
			end

			if not t1.Match.ready() then
				p520.text = "[UNAVAILABLE] Game Modules"

				return
			end

			if not Assist.want then
				p520.text = "[READY] Press " .. tostring(t12.DeployAssistKeybind) .. " | " .. t1.Assist.summary()

				return
			end

			Assist.want = false

			local huge = t12.AssistCount == "All Affordable" and math.huge or math.max(1, math.floor(t1._n(tonumber(t12.AssistCount), 1)))
			local n67 = 0
			local text

			while n67 < huge and t12.DeployAssist and t1.Running do
				if t1.Match.state() == "MATCH" then
					if not (n67 > 0) or t1._pause("assist", t12.AssistDelay, p520, "Next Unit") then
						local v2301 = t1.Match.towers()
						local v2302 = t1.Assist.pick(v2301)

						if v2302 then
							local v2303 = t1.Assist.spot(v2302, v2301)

							if not v2303 then
								text = "[BLOCKED] " .. v2302.tag .. " | No Free Spot"

								break
							end

							p520.text = "[DEPLOY] " .. v2302.tag .. " | Slot " .. v2302.slot
							t1._wake("status")

							local v2304, v2305, v2306 = t1.Play.send(v2302, v2303.pos, v2303.rot or t1.Place.yaw(v2303.pos), t12.AssistReserve)

							if v2305 == "Busy" then
								Assist.want = true
								text = t1.Cash.busyText(v2306)

								break
							end

							if v2304 then
								n67 += 1
								text = "[PLACED] " .. v2302.tag .. " | " .. n67 .. " This Press"

								local v2307 = t1.Assist.upgrade(p520, v2302, v2304)

								text = v2307 or text

								if not v2307 or v2307:find("^%[UPGRADED%]") then
									continue
								end
							else
								text = "[REFUSED] " .. v2302.tag .. " | " .. t1._title(tostring(v2305 or "Refused"))

								break
							end
						else
							text = text or "[WAITING] Awaiting Cash | " .. tostring(t12.AssistUnit)

							break
						end
					end
				end

				break
			end

			p520.text = text or "[READY] Press " .. tostring(t12.DeployAssistKeybind) .. " | " .. t1.Assist.summary()
			t1.Match.dirty()
			t1._wake("upgrade")
			t1._wake("target")
		end)
	end

	t1.Sell = {
		owner = {
			text = "[IDLE]"
		}
	}

	do
		local owner2 = t1.Sell.owner

		t1._allWorkers[#t1._allWorkers + 1] = "sell"
		t1.Sell.one = function(p521)
			t1.Life.mark(t1.Life.sold, p521.hash)
			t1.fire("TowerSell", {
				Id = p521.rec.Id or p521.hash
			})
			t1.Match.dirty()

			local v2309 = t1._confirm(function()
				t1.Match.dirty()

				return t1.Match.tower(p521.hash) == nil
			end, 2) ~= nil

			if not v2309 then
				t1.Life.sold[p521.hash] = nil
			end

			return v2309
		end
		t1.Sell.farmPicked = function(p522)
			return t1.Data.role(p522) == "Farm" and table.find(t12.SellFarmUnits, t1.Data.name(p522)) ~= nil
		end
		t1.Sell.lowLives = function()
			if not t1._has(t12.SellActions, "Sell Farms At Low Base") or t1._n(t12.SellLowLives) <= 0 then
				return false
			end

			local v2310 = t1.Match.livesPct()

			return v2310 ~= nil and v2310 <= t1._n(t12.SellLowLives)
		end
		t1.Sell.phase = function()
			if not t12.AutoSell or t1.Match.state() ~= "MATCH" then
				return false, false
			end

			if t1.Macro and t1.Macro.pausing("Auto Sell") then
				return false, false
			end

			local v2311, v2312 = t1.Match.wave()
			local v2313 = t1._has(t12.SellActions, "Sell All At Wave") and t1._n(t12.SellAllAtWave) > 0
			local v2314 = t1._has(t12.SellActions, "Sell Farms Before End") and t1._n(t12.SellFarmsBeforeEnd) > 0
			local v2315 = v2313 and v2311 >= t1._n(t12.SellAllAtWave)
			local v2316 = v2314 and not t1.Match.endless() and v2312 > 0 and v2311 >= v2312 - t1._n(t12.SellFarmsBeforeEnd) or t1.Sell.lowLives()

			return v2315, v2316, t1._has(t12.SellActions, "Sell Selected At Wave") and t1._n(t12.SellSelectedWave) > 0 and #t12.SellTowers > 0 and v2311 >= t1._n(t12.SellSelectedWave) and t1._set(t12.SellTowers) or nil
		end
		t1._worker("sell", owner2, function(p523)
			if not t12.AutoSell then
				p523.text = "[IDLE]"

				return
			end

			if t1.Macro and t1.Macro.pausing("Auto Sell") then
				p523.text = "[PAUSED] Strategy Running"

				return
			end

			if t1.Match.state() ~= "MATCH" then
				p523.text = t1.Match.idle()

				return
			end

			if not t1._needs("SellActions", "Sell", p523) then
				return
			end

			local v2317, v2318 = t1.Match.wave()
			local v2319 = t1._has(t12.SellActions, "Sell All At Wave") and t1._n(t12.SellAllAtWave) > 0
			local v2320 = t1._has(t12.SellActions, "Sell Farms Before End") and t1._n(t12.SellFarmsBeforeEnd) > 0 and not t1.Match.endless()
			local v2321 = t1._has(t12.SellActions, "Sell Selected At Wave") and t1._n(t12.SellSelectedWave) > 0 and #t12.SellTowers > 0
			local v2322, v2323, v2324 = t1.Sell.phase()

			if v2322 or v2323 or v2324 then
				local n68 = 0
				local v2326 = t1.Match.towers()

				if v2323 and not (v2322 or v2324) then
					if #t12.SellFarmUnits == 0 then
						p523.text = "[WAITING] Awaiting Farms | None Picked"

						return
					end

					local v2327 = false

					for _, v in ipairs(v2326) do
						if t1.Sell.farmPicked(v.id) then
							v2327 = true

							break
						end
					end

					if not v2327 then
						p523.text = "[WAITING] Awaiting Farm | Wave " .. v2317

						return
					end
				end

				for _, v in ipairs(v2326) do
					if v2322 or v2323 and t1.Sell.farmPicked(v.id) or v2324 and v2324[t1.Data.name(v.id)] then
						p523.text = "[SELL] " .. t1.Data.name(v.id) .. " | Wave " .. v2317
						t1._wake("status")

						if t1.Sell.one(v) then
							n68 += 1
						end

						if t12.AutoSell then
							continue
						end

						return
					end
				end

				p523.text = "[DONE] " .. (n68 > 0 and "Sold " .. n68 or "Nothing Sold") .. " | Wave " .. v2317

				return
			end

			local v2332
			local v2334 = v2319 and t1._n(t12.SellAllAtWave) or false
			local v2335 = v2320 and v2318 - t1._n(t12.SellFarmsBeforeEnd) or false
			local v2336 = v2321 and t1._n(t12.SellSelectedWave)

			v2336 = v2336 or false

			local t156 = {
				v2334,
				v2335,
				v2336
			}

			for _, v in ipairs(t156) do
				if v and v2317 < v and (not v2332 or v < v2332) then
					v2332 = v
				end
			end

			local v2339 = t1._has(t12.SellActions, "Sell Farms At Low Base") and t1.Match.livesPct()

			p523.text = v2332 and "[WAITING] Awaiting Wave | " .. v2317 .. "/" .. math.max(v2332, 1) or v2339 and "[WAITING] Awaiting Damage | Base " .. math.floor(v2339) .. "%" or "[WAITING] Awaiting Rule"
		end)
	end

	t1.Macro = {
		owner = {
			text = "[IDLE]"
		},
		rec = {
			text = "[IDLE]"
		},
		recording = false,
		events = {},
		snap = {},
		index = {},
		step = 1,
		map = {}
	}

	do
		local owner2 = t1.Macro.owner

		t1._allWorkers[#t1._allWorkers + 1] = "macro"
		t1.Macro.pausing = function(p524)
			return t12.MacroRun == true and t1.Macro.active == true and t1._has(t12.MacroPause, p524)
		end
		t1.Macro.folder = function()
			if not makefolder or not isfolder then
				return false
			end

			pcall(function()
				if not isfolder("BARRAGE") then
					makefolder("BARRAGE")
				end

				if not isfolder("BARRAGE/CameramanTowerDefenseStrategies") then
					makefolder("BARRAGE/CameramanTowerDefenseStrategies")
				end
			end)

			return true
		end
		t1.Macro.list = function()
			if t1.Macro._list and os.clock() - t1.Macro._listAt < 30 then
				return table.clone(t1.Macro._list)
			end

			local list = {}

			if not listfiles or not t1.Macro.folder() then
				return list
			end

			local ok, result = pcall(listfiles, "BARRAGE/CameramanTowerDefenseStrategies")
			local v2344 = ok and result or {}

			for _, v in ipairs(v2344) do
				local match = tostring(v):match("([^/\\]+)%.json$")

				if match then
					list[#list + 1] = match
				end
			end

			table.sort(list)

			local Macro = t1.Macro
			local Macro2 = t1.Macro
			local now = os.clock()

			Macro._list = list
			Macro2._listAt = now

			return table.clone(list)
		end
		t1.Macro.load = function(p525)
			if not readfile or not isfile or p525 == "" then
				return nil
			end

			local v2351 = "BARRAGE/CameramanTowerDefenseStrategies" .. "/" .. p525 .. ".json"
			local ok, result = pcall(function()
				return isfile(v2351) and HttpService:JSONDecode(readfile(v2351))
			end)

			if ok and type(result) == "table" and type(result.events) == "table" then
				return result
			end

			return nil
		end
		t1.Macro.save = function(p526)
			t1.Macro._list = nil

			local v2354 = tostring(p526 or ""):gsub("[^%w%-_ ]", ""):sub(1, 40)

			if v2354 == "" or not writefile or not t1.Macro.folder() then
				return false, "Name"
			end

			if #(t1.Macro.events or {}) == 0 then
				return false, "Empty"
			end

			return pcall(function()
				writefile("BARRAGE/CameramanTowerDefenseStrategies" .. "/" .. v2354 .. ".json", HttpService:JSONEncode({
					version = 1,
					map = t1.Match.mapId(),
					level = t1.Match.levelId(),
					difficulty = t1.Match.difficulty(),
					events = t1.Macro.events
				}))
			end), v2354
		end
		t1.Macro.delete = function(p527)
			t1.Macro._list = nil

			if not delfile or not isfile or p527 == "" then
				return false
			end

			local v2355 = "BARRAGE/CameramanTowerDefenseStrategies" .. "/" .. p527 .. ".json"

			local function v2356()
				if isfile(v2355) then
					delfile(v2355)
				end
			end

			return pcall(v2356)
		end

		local function v2357()
			local t157 = {}

			t1.Match.dirty()

			for _, v in ipairs(t1.Match.towers()) do
				v.target = t1.Target and t1.Target.current(v.rec) or nil
				t157[v.hash] = v
			end

			return t157
		end

		t1.Macro.startRecording = function()
			t1.Macro.events = {}
			t1.Macro.index = {}
			t1.Macro.snap = v2357()

			local count = 0

			for k in pairs(t1.Macro.snap) do
				count += 1
				t1.Macro.index[k] = count
			end

			t1.Macro.count = count
			t1.Macro.lost = {}
			t1.Macro.recording = true
			t1.Macro.rec.text = "[RECORDING] 0 Actions | Wave " .. select(1, t1.Match.wave())
			t1._wake("status")
		end
		t1.Macro.stopRecording = function()
			if not t1.Macro.recording then
				return
			end

			t1.Macro.recording = false
			t12.MacroRecord = false

			if t1._setControl then
				t1._setControl("MacroRecord", false)
			end

			local v2363, v2364 = t1.Macro.save(t12.MacroName ~= "" and t12.MacroName or "Strategy " .. os.date("%m-%d %H%M"))

			if v2363 then
				t1.Macro.rec.text = "[SAVED] " .. v2364 .. " | " .. #t1.Macro.events .. " Actions"

				if t1.Macro.refreshList then
					t1.Macro.refreshList()
				end
			else
				t1.Macro.rec.text = v2364 == "Empty" and "[STOPPED] Nothing Recorded" or "[FAILED] Save | Executor File Access"
			end

			t1._wake("status")
		end
		t1.Macro.diff = function()
			if not t1.Macro.recording then
				return
			end

			local v2365 = v2357()
			local value = select(1, t1.Match.wave())

			if t1._n(t12.MacroStopWave) > 0 and t1._n(t12.MacroStopWave) < value then
				t1.Macro.stopRecording()

				return
			end

			local events = t1.Macro.events
			local v2368 = t1._set(t12.MacroRecordActions)

			local function v2369(p528)
				if t1.Match.waveAt then
					p528.t = math.floor((os.clock() - t1.Match.waveAt) * 10 + 0.5) / 10
				end

				if v2368[({
					place = "Placements",
					upgrade = "Upgrades",
					sell = "Sells",
					target = "Targets"
				})[p528.a]] then
					events[#events + 1] = p528
				end
			end

			for k, v in pairs(v2365) do
				local v2372 = t1.Macro.snap[k]
				local v2373 = not v2372 and t1.Macro.retake(v)

				if v2373 then
					t1.Macro.index[k] = v2373.n

					for i = v2373.level + 1, v.level do
						v2369({
							a = "upgrade",
							n = v2373.n,
							lvl = i,
							wave = value
						})
					end

					v.level = math.max(v.level, v2373.level)
				elseif v2372 then
					for i = v2372.level + 1, v.level do
						v2369({
							a = "upgrade",
							n = t1.Macro.index[k],
							lvl = i,
							wave = value
						})
					end

					if v.target and v.target ~= v2372.target then
						v2369({
							a = "target",
							n = t1.Macro.index[k],
							mode = v.target,
							wave = value
						})
					end
				else
					t1.Macro.count = (t1.Macro.count or 0) + 1
					t1.Macro.index[k] = t1.Macro.count

					local pos = v.pos or Vector3.zero

					v2369({
						a = "place",
						n = t1.Macro.count,
						id = v.id,
						x = pos.X,
						y = pos.Y,
						z = pos.Z,
						r = t1.Place.yaw(pos),
						wave = value,
						cost = t1.Data.placeCost(v.id)
					})

					for i = 2, v.level do
						v2369({
							a = "upgrade",
							n = t1.Macro.count,
							lvl = i,
							wave = value
						})
					end
				end
			end

			for k, v in pairs(t1.Macro.snap) do
				if not v2365[k] and t1.Macro.index[k] then
					if t1.Life.destroyed(k) then
						t1.Macro.lost[#t1.Macro.lost + 1] = {
							n = t1.Macro.index[k],
							h = k,
							id = v.id,
							pos = v.pos,
							level = v.level
						}
					else
						v2369({
							a = "sell",
							n = t1.Macro.index[k],
							wave = value
						})
					end
				end
			end

			t1.Macro.snap = v2365
			t1.Macro.rec.text = "[RECORDING] " .. #events .. " Actions | Wave " .. value
			t1._wake("status")
		end
		t1.Macro.retake = function(p529)
			local lost = t1.Macro.lost or {}

			for i, v in ipairs(lost) do
				local v2383 = v.pos and p529.pos and math.abs(v.pos.X - p529.pos.X) < 3 and math.abs(v.pos.Z - p529.pos.Z) < 3

				if v.id == p529.id and (v2383 or t1.Act.moved[v.h] == p529.hash) then
					return table.remove(t1.Macro.lost, i)
				end
			end

			return nil
		end
		t1.Life = {
			sold = {},
			died = {}
		}
		t1.Life.mark = function(p530, p531)
			local now = os.clock()

			for k, v in pairs(p530) do
				if now - v > 60 then
					p530[k] = nil
				end
			end

			p530[p531] = now
		end
		t1.Life.recent = function(p532, p533)
			local v2387 = p533 ~= nil and p532[p533] or nil

			return v2387 ~= nil and os.clock() - v2387 <= 60
		end
		t1.Life.destroyed = function(p534)
			return p534 ~= nil and t1.Life.recent(t1.Life.died, p534) and not t1.Life.recent(t1.Life.sold, p534)
		end
		t1.Act = {
			moved = {}
		}
		t1.Act.resolve = function(p535)
			for i = 1, 8 do
				local v2389 = p535 ~= nil and t1.Act.moved[p535] or nil

				if v2389 == nil then
					return p535
				end

				p535 = v2389
			end

			return p535
		end
		t1.Act.place = function(p536, p537, p538, p539, p540, p541, p542)
			local v2390 = t1.Data.tag(p536)
			local v2391 = t1.Match.slotRec(p536)

			if not v2391 then
				return nil, "[BLOCKED] " .. v2390 .. " | Not Equipped"
			end

			local v2392 = t1.Play.cooldown(p536)

			if v2392 > 0 then
				return nil, "[WAITING] Awaiting Cooldown | " .. math.ceil(v2392) .. "s"
			end

			p541.text = "[PLACE] " .. v2390 .. " | " .. p542
			t1._wake("status")

			local v2393, v2394, v2395 = t1.Play.send(v2391, Vector3.new(t1._n(p537), t1._n(p538), t1._n(p539)), t1._n(p540, 180))

			if v2394 == "Busy" then
				return nil, t1.Cash.busyText(v2395)
			end

			if v2394 == "Need Cash" or v2394 == "Price" then
				return nil, "[SAVING] " .. v2390 .. " | {cash}/" .. t1._fmt(v2394 == "Price" and v2395 or t1.Data.placeCost(p536))
			end

			if v2393 then
				t1.Act.moved[v2393] = nil

				return v2393
			end

			return nil, "[RETRY] " .. v2390 .. " | " .. t1._title(tostring(v2394 or "Refused"):sub(1, 24))
		end
		t1.Act.row = function(p543)
			local v2396 = p543 and t1.Match.tower(p543)

			return v2396 and t1.Match.row(v2396) or nil
		end
		t1.Act.upgrade = function(p544, p545, p546)
			local v2397 = t1.Act.row(p544)

			if not v2397 then
				return false, "[WAITING] Awaiting Unit"
			end

			local v2398 = t1.Data.tag(v2397.id)
			local level = v2397.level

			if t1._n(p545) <= level then
				return true
			end

			local v2400 = t1.Upg.cost(v2397)

			if v2400 < math.huge and t1.Cash.free() < v2400 then
				return false, "[SAVING] " .. v2398 .. " Lv" .. t1._n(p545) .. " | {cash}/" .. t1._fmt(v2400)
			end

			p546.text = "[UPGRADE] " .. v2398 .. " | Level " .. t1._n(p545)
			t1._wake("status")

			local v2401, v2402, v2403 = t1.Upg.one(v2397)

			if v2401 then
				return true
			end

			if v2402 == "busy" then
				return false, t1.Cash.busyText(v2403)
			end

			if v2402 == "cash" or v2402 == "price" then
				return false, "[SAVING] " .. v2398 .. " Lv" .. t1._n(p545) .. " | {cash}/" .. t1._fmt(v2402 == "price" and v2403 or v2400)
			end

			return false, "[RETRY] Upgrade | Refused"
		end
		t1.Act.target = function(p547, p548)
			local v2404 = t1.Match.tower(p547)

			if v2404 then
				t1.Target.set(v2404, p548)
			end

			return true
		end
		t1.Macro.run = function(p549, p550)
			if p549.a == "place" then
				local v2405, v2406 = t1.Act.place(p549.id, p549.x, p549.y, p549.z, p549.r, p550, "Step " .. t1.Macro.step)

				if v2405 then
					t1.Macro.map[p549.n] = v2405

					return true
				end

				return false, v2406
			end

			local v2407 = t1.Act.resolve(t1.Macro.map[p549.n])

			t1.Macro.map[p549.n] = v2407

			local v2408 = t1.Act.row(v2407)

			if not v2408 then
				return true
			end

			if p549.a == "upgrade" then
				return t1.Act.upgrade(v2407, p549.lvl, p550)
			end

			if p549.a == "sell" then
				t1.Sell.one(v2408)

				return true
			end

			if p549.a == "target" then
				return t1.Act.target(v2407, p549.mode)
			end

			return true
		end
		t1.Macro.pick = function()
			return t12.MacroSelected or ""
		end
		t1._worker("macro", owner2, function(p551)
			if not t12.MacroRun then
				t1.Macro.active = false
				p551.text = "[IDLE]"

				return
			end

			local v2409 = t1.Macro.pick()

			if v2409 == "" then
				p551.text = "[WAITING] Awaiting Strategy"

				return
			end

			if t1.Match.state() ~= "MATCH" then
				t1.Macro.active = false
				p551.text = t1.Match.idle()

				return
			end

			local roundKey = tostring(t1.Match.levelId()) .. ":" .. tostring(t1.Match.roundId)

			if t1.Macro.roundKey ~= roundKey or t1.Macro.loadedName ~= v2409 then
				t1.Macro.roundKey = roundKey
				t1.Macro.loadedName = v2409
				t1.Macro.data = t1.Macro.load(v2409)
				t1.Macro.step = 1
				t1.Macro.map = {}
			end

			local data = t1.Macro.data

			if not data then
				p551.text = "[ERROR] Strategy File | Unreadable"

				return
			end

			t1.Macro.active = t1.Macro.step <= #data.events

			local exitTo
			local v2413, v2414, v2415, v2416

			while t12.MacroRun and t1.Running and t1.Macro.step <= #data.events do
				if t1.Match.state() ~= "MATCH" then
					break
				end

				v2413 = data.events[t1.Macro.step]

				local value = select(1, t1.Match.wave())

				if t1._has(t12.MacroActions, "Wait For Recorded Wave") and value < t1._n(v2413.wave) then
					exitTo = 1

					break
				end

				local ok = not (not not t1._has(t12.MacroActions, "Recorded Timing") and type(v2413.t) == "number" and not not t1.Match.waveAt and t1._n(v2413.wave) == value)

				if not ok then
					v2414 = v2413.t - (os.clock() - t1.Match.waveAt)
					ok = not (v2414 > 0.05)
				end

				if not ok then
					exitTo = 2

					break
				end

				v2415 = v2413.a == "place" and t1._n(v2413.cost) or 0

				if v2415 > 0 and v2415 < math.huge and t1.Cash.free() < v2415 then
					exitTo = 3

					break
				end

				local v2419

				v2419, v2416 = t1.Macro.run(v2413, p551)

				if v2419 then
					t1.Macro.fails = 0
					t1.Macro.step += 1

					if t1._pause("macro", t12.MacroDelay, p551, "Next Step") then
						continue
					end

					exitTo = 6

					break
				end

				if tostring(v2416):find("^%[SAVING%]") then
					exitTo = 4

					break
				end

				if tostring(v2416):find("^%[WAITING%]") then
					exitTo = 4

					break
				end

				t1.Macro.fails = (t1.Macro.fails or 0) + 1

				if t1._n(t12.MacroRetries) > 0 then
					local fails = t1.Macro.fails

					if t1._n(t12.MacroRetries) <= fails and t1._has(t12.MacroActions, "Skip Failed Steps") then
						t1.Macro.fails = 0
						t1.Macro.step += 1

						continue
					end

					exitTo = 5

					break
				end

				exitTo = 5

				break
			end

			if exitTo == 1 then
				p551.text = "[WAITING] Awaiting Wave " .. t1._n(v2413.wave) .. " | Step " .. t1.Macro.step .. "/" .. #data.events

				return
			end

			if exitTo == 2 then
				p551.text = "[WAITING] Awaiting Timing | " .. math.ceil(v2414) .. "s"
				t1._alarm("macro", v2414, "macro:time")

				return
			end

			if exitTo == 3 then
				p551.text = "[SAVING] Step " .. t1.Macro.step .. "/" .. #data.events .. " | {cash}/" .. t1._fmt(v2415)

				return
			end

			if exitTo == 4 then
				p551.text = v2416
				t1._alarm("macro", 1.5, "macro:wait")

				return
			end

			if exitTo == 5 then
				p551.text = v2416 or "[RETRY] Step " .. t1.Macro.step
				t1._alarm("macro", 2, "macro:retry")

				return
			end

			if exitTo == 6 then
				return
			end

			if t1.Macro.step > #data.events then
				t1.Macro.active = false
				p551.text = "[DONE] " .. v2409 .. " | " .. #data.events .. " Steps"

				for _, v in ipairs({
					"play",
					"upgrade",
					"sell",
					"target"
				}) do
					t1._wake(v)
				end
			end
		end)
	end

	t1.Target = {
		owner = {
			text = "[IDLE]"
		},
		asked = {}
	}

	do
		local owner2 = t1.Target.owner

		t1._allWorkers[#t1._allWorkers + 1] = "target"

		local t158 = {}

		for i, v in ipairs(t20) do
			t158[v:lower()] = i
		end

		t1.Target.valid = function()
			return t158
		end
		t1.Target.modes = function()
			return table.clone(t20)
		end
		t1.Target.current = function(p552)
			local TargetMode = type(p552) == "table" and p552.TargetMode

			return type(TargetMode) == "string" and TargetMode or nil
		end
		t1.Target.set = function(p553, p554)
			if not (type(p553) == "table" and type(p554) == "string" and t158[p554:lower()]) then
				return false
			end

			local v2428 = t1.Match.key(p553)

			for i = 1, #t20 do
				local v2430 = v2428 and t1.Match.tower(v2428) or p553
				local v2431 = t1.Target.current(v2430)

				if v2431 == p554 then
					return true
				end

				if t1.fire("TowerTarget", {
					Id = v2430.Id or v2428
				}) then
					if t1._confirm(function()
						local v2432 = v2428 and t1.Match.tower(v2428)

						return v2432 ~= nil and t1.Target.current(v2432) ~= v2431
					end, 2) then
						continue
					end

					return false
				end

				return false
			end

			local current = t1.Target.current
			local v2434 = v2428 and t1.Match.tower(v2428) or p553

			return current(v2434) == p554
		end

		local Target = t1.Target
		local Target2 = t1.Target

		t1.Target.pend = {}
		Target.slotWhy = {}
		Target2.cover = {}
		t1.Target.RULES = t1.TARGET_RULES
		t1.Target.rule = function(p555)
			return t1._has(t12.SmartTargetRules, p555)
		end
		t1.Target.progress = function(p556)
			if p556.prog then
				return p556.prog
			end

			local v2437 = t1.Paths.get()
			local prog = 0
			local huge = math.huge

			if v2437 and p556.pos then
				local v2440 = t1._flat(p556.pos)
				local v2441 = false

				for _, path in ipairs(v2437.paths) do
					if path.pathIndex == p556.path then
						v2441 = true
					end
				end

				for _, path in ipairs(v2437.paths) do
					if not v2441 or path.pathIndex == p556.path then
						for _, sample in ipairs(path.samples) do
							local Magnitude = (t1._flat(sample.pos) - v2440).Magnitude

							if Magnitude < huge then
								prog = sample.progress
								huge = Magnitude
							end
						end
					end
				end
			end

			p556.prog = prog

			return prog
		end
		t1.Target.reach = function(p557, p558)
			local v2449 = math.floor(p557.pos.X) .. ":" .. math.floor(p557.pos.Z) .. ":" .. math.floor(p558) .. ":" .. t1.Paths.rev
			local v2450 = t1.Target.cover[p557.hash]

			if v2450 and v2450.key == v2449 then
				return v2450.top
			end

			local t159 = {}
			local v2452 = t1.Paths.get()
			local v2453 = p558 * p558
			local paths = v2452 and v2452.paths or {}

			for _, path in ipairs(paths) do
				for _, sample in ipairs(path.samples) do
					local v2459 = sample.pos.X - p557.pos.X
					local v2460 = sample.pos.Z - p557.pos.Z

					if v2459 * v2459 + v2460 * v2460 <= v2453 then
						if (t159[path.pathIndex] or -1) < sample.progress then
							t159[path.pathIndex] = sample.progress
						end
					end
				end
			end

			t1.Target.cover[p557.hash] = {
				key = v2449,
				top = t159
			}

			return t159
		end
		t1.Target.plan = function(p559, p560)
			local Target3 = t1.Target
			local t160 = {}
			local t161 = {}
			local v2464 = Target3.rule("Last Unit Before Base: First")
			local v2465 = Target3.rule("Leaking Enemy: First")
			local v2466 = math.clamp(t1._n(t12.SmartLeakPct, 80), 50, 95) / 100
			local v2467 = Target3.rule("Boss In Range: Strong")
			local v2468 = Target3.rule("Split Bosses Across Units")
			local v2469 = Target3.rule("Area Units On Crowds: First")
			local v2470 = Target3.rule("Low Health Swarm: Weak")
			local v2471 = type(t12.SmartTargetRules) == "table" and next(t12.SmartTargetRules) ~= nil
			local t162 = {}

			for _, v in ipairs(p559) do
				local v2475 = t1.Upg.slotOf(v)
				local v2476 = v2475 and t12["SlotTarget" .. v2475] or "Smart"

				if v2476 == "Smart" then
					if t1.Data.role(v.id) == "Damage" and v.pos then
						local range = t1._n(v.range, 0) > 0 and v.range or t1.Data.range(v.id, v.level)
						local v2478 = range * range
						local t163 = {}
						local v2480, v2481, v2482 = ipairs(p560)

						for _, v2 in v2480, v2481, v2482 do
							if v2.pos then
								local v2485 = v2.pos.X - v.pos.X
								local v2486 = v2.pos.Z - v.pos.Z

								if v2485 * v2485 + v2486 * v2486 <= v2478 then
									t163[#t163 + 1] = v2
								end
							end
						end

						local t164 = {
							t = v,
							slot = v2475,
							near = t163,
							r = range
						}

						t161[#t161 + 1] = t164

						if v2464 then
							local v2488, v2489, v2490 = pairs(Target3.reach(v, range))

							for k, v2 in v2488, v2489, v2490 do
								if not t162[k] or t162[k].top < v2 then
									t162[k] = {
										top = v2,
										u = t164
									}
								end
							end
						end
					end
				else
					t160[v.hash] = {
						mode = v2476,
						why = "fixed"
					}
				end
			end

			local t165 = {}

			for _, v in ipairs(t161) do
				local t = v.t
				local near = v.near
				local v2498 = t1.Target.valid(t.rec)
				local mode
				local why

				if v2471 then
					if #near == 0 then
						mode = nil
						why = "waiting (no enemies in range)"
					end
				else
					mode = "First"
					why = "no rules on"
				end

				if v2471 and #near > 0 then
					if v2464 then
						local v2501, v2502, v2503 = pairs(t162)
						local v2504 = geniter(v2501, v2502, v2503)

						repeat
							local v2505 = table.pack(v2504())

							if not v2505[1] then
								break
							end

							local v2506 = v2505[2]

							if (v2505[3]).u == v then
								for _, v2 in ipairs(near) do
									if v2.path == v2506 or t1.Paths.count() <= 1 then
										mode = "First"
										why = "last unit before base"

										break
									end
								end
							end
						until mode
					end

					if not mode and v2465 then
						local n69 = 0
						local v2510, v2511, v2512 = ipairs(near)

						for _, v2 in v2510, v2511, v2512 do
							n69 = math.max(n69, Target3.progress(v2))
						end

						if v2466 <= n69 then
							why = "leak " .. math.floor(n69 * 100) .. "%"
							mode = "First"
						end
					end

					local area = t1.Data.profile(t.id).area

					if not mode and v2467 then
						local n70 = 0
						local v2517, v2518, v2519 = ipairs(near)

						for _, v2 in v2517, v2518, v2519 do
							if v2.boss then
								n70 += 1
							end
						end

						if n70 > 0 and (not area or n70 == #near) and v2498.strong then
							why = area and "boss alone in range" or "boss in range"
							mode = "Strong"

							if v2468 then
								t165[#t165 + 1] = v
							end
						end
					end

					if not mode and v2469 and area and #near >= 3 then
						why = "crowd of " .. #near
						mode = "First"
					end

					if not mode and v2470 and not area and #near >= 4 and v2498.weak then
						local n71 = 0
						local v2523, v2524, v2525 = ipairs(near)

						for _, v2 in v2523, v2524, v2525 do
							if v2.maxHp > 0 and v2.hp / v2.maxHp < 0.4 then
								n71 += 1
							end
						end

						if n71 * 2 >= #near then
							mode = "Weak"
							why = "low health swarm"
						end
					end

					if not mode then
						why = #near .. " in range"
						mode = "First"
					end
				end

				v.mode = mode
				v.why = why
			end

			table.sort(t165, function(p561, p562)
				return t1.Data.worth(p561.t.id, p561.t.level) > t1.Data.worth(p562.t.id, p562.t.level)
			end)

			local t166 = {}

			for _, v in ipairs(t165) do
				local v2531
				local v2532, v2533, v2534 = ipairs(v.near)

				for _, v2 in v2532, v2533, v2534 do
					if v2.boss and not t166[v2.id] and (not v2531 or v2531.hp < v2.hp) then
						v2531 = v2
					end
				end

				if v2531 then
					t166[v2531.id] = true
				else
					v.mode = "First"
					v.why = "boss split"
				end
			end

			table.clear(Target3.slotWhy)

			for _, v in ipairs(t161) do
				t160[v.t.hash] = {
					mode = v.mode,
					why = v.why,
					smart = true
				}

				local slot = v.slot and Target3.slotWhy[v.slot]

				if v.slot and (not slot or slot.mode == nil and v.mode ~= nil or slot.mode == "First" and v.mode and v.mode ~= "First") then
					Target3.slotWhy[v.slot] = {
						mode = v.mode,
						why = v.why
					}
				end
			end

			return t160
		end
		t1.Target.slotText = function(p563)
			if t12["SlotTarget" .. p563] ~= "Smart" then
				return "Fixed: " .. tostring(t12["SlotTarget" .. p563])
			end

			local id

			for _, v in ipairs(t1.Match.slots()) do
				if v.slot == p563 then
					id = v.id
				end
			end

			if id and t1.Data.role(id) ~= "Damage" then
				return "Smart: not managed (" .. t1._title((tostring(t1.Data.tag(id)):match("%[([^%]]+)%]$") or t1.Data.role(id)):lower()) .. " unit)"
			end

			local v2543 = t1.Target.slotWhy[p563]

			if v2543 and v2543.mode then
				return "Smart now: " .. v2543.mode .. " â€” " .. v2543.why
			end

			return "Smart: waiting (no enemies in range)"
		end
		t1._worker("target", owner2, function(p564)
			if not t12.AutoTarget then
				p564.text = "[IDLE]"

				return
			end

			if t1.Macro.pausing("Auto Target") then
				p564.text = "[PAUSED] Strategy Running"

				return
			end

			if t1.Match.state() ~= "MATCH" then
				table.clear(t1.Target.slotWhy)
				p564.text = t1.Match.idle()

				return
			end

			local v2544 = t1.Match.towers()

			if #v2544 == 0 then
				p564.text = "[WAITING] Awaiting Units"

				return
			end

			local Target3 = t1.Target
			local v2546 = t1.Match.enemies()
			local v2547 = Target3.plan(v2544, v2546)
			local now = os.clock()
			local u2549
			local v2550 = math.clamp(t1._n(t12.SmartSwitchHold, 1500), 500, 5000) / 1000

			local function v2551(p565)
				u2549 = u2549 and math.min(u2549, p565) or p565
			end

			for _, v in ipairs(v2544) do
				local v2554 = v2547[v.hash]
				local mode = v2554 and v2554.mode
				local v2556 = t1.Target.current(v.rec)

				if t1.Data.role(v.id) == "Farm" or not mode or v2556 == mode or not t1.Target.valid(v.rec)[mode:lower()] then
					Target3.pend[v.hash] = nil

					continue
				end

				local v2557 = Target3.pend[v.hash]

				if not v2557 or v2557.mode ~= mode then
					v2557 = {
						mode = mode,
						at = now
					}
					Target3.pend[v.hash] = v2557
				end

				local v2558 = Target3.asked[v.hash]

				if v2554.smart and v2556 ~= nil and now - v2557.at < v2550 then
					v2551(v2550 - (now - v2557.at))

					continue
				end

				if v2558 and (v2558.mode == mode and now - v2558.at < 10 or now - v2558.at < 3) then
					v2551((v2558.mode == mode and 10 or 3) - (now - v2558.at))

					continue
				end

				p564.text = "[TARGET] " .. t1.Data.name(v.id) .. " | " .. mode
				t1._wake("status")
				Target3.asked[v.hash] = {
					mode = mode,
					at = now
				}
				t1.Target.set(v.rec, mode)

				if not t12.AutoTarget then
					return
				end

				if t1._pause("target", t12.TargetDelay, p564, "Next Target") then
					continue
				end

				return
			end

			if u2549 then
				t1._alarm("target", u2549 + 0.1, "target:hold")
			end

			if #v2546 > 0 then
				t1._alarm("target", 0.75, "target:tick")
			end

			local v2559 = false

			for _, v in ipairs(v2546) do
				v2559 = v2559 or v.boss
			end

			local text = #v2546 == 0 and "[WAITING] Awaiting Enemies"

			if not text then
				text = "[DONE] Targets Set | " .. (v2559 and "Boss Up" or #v2544 .. " Units")
			end

			p564.text = text
		end)
	end

	t1.Mods = {
		owner = {
			text = "[IDLE]"
		}
	}
	t1.Mods.on = function(p566)
		local v2563 = t12.MatchMods == true and p566 == "Place Anywhere"

		if v2563 then
			v2563 = #(t12.MatchSkips or {}) > 0
		end

		return v2563
	end
	t1.Mods.CHECKS = {
		"Ground",
		"Road",
		"Overlap"
	}
	t1.Mods.skip = function(p567)
		return t12.MatchMods == true and t1._has(t12.MatchSkips, p567)
	end
	t1.Skip = {
		text = "[IDLE]",
		n = 0,
		wave = nil
	}
	t1.Skip.run = function()
		local Skip = t1.Skip

		if not t12.AutoSkip then
			return t1._wake("status")
		end

		if not t1.Ctx.inMatch() then
			Skip.text = "[WAITING] Awaiting Match"

			return t1._wake("status")
		end

		if t1._backed("skip") then
			return t1._wake("status")
		end

		local v2565 = t1._n(workspace:GetAttribute("Wave"))

		if t12.SkipUntilWave > 0 and t12.SkipUntilWave <= v2565 then
			Skip.text = "[STOPPED] Wave " .. t12.SkipUntilWave .. " | " .. Skip.n .. " Skips"

			return t1._wake("status")
		end

		if workspace:GetAttribute("CanSkip") ~= true then
			Skip.text = "[WAITING] Awaiting Skip | " .. Skip.n .. " Skips"

			return t1._wake("status")
		end

		if Skip.wave == v2565 then
			Skip.text = "[VOTED] Skip Wave " .. v2565 .. " | " .. t1._n(workspace:GetAttribute("Votes")) .. " / " .. t1._n(workspace:GetAttribute("RequiredVotes"), 1)

			return t1._wake("status")
		end

		if t12.SkipFromWave > 0 then
			if v2565 < t12.SkipFromWave then
				Skip.text = "[WAITING] Awaiting Wave " .. t12.SkipFromWave .. " | " .. Skip.n .. " Skips"

				return t1._wake("status")
			end
		end

		if t12.SkipWhen == "Base Untouched" and t1.Match.base() < 1 then
			Skip.text = "[HOLDING] Skip | Base Damaged"

			return t1._wake("status")
		end

		if t12.SkipMinHealth > 0 and t1.Match.base() * 100 < t12.SkipMinHealth then
			Skip.text = "[HOLDING] Skip | Base Below " .. t12.SkipMinHealth .. "%"

			return t1._wake("status")
		end

		if t12.SkipHoldBoss and t1.Match.boss() then
			Skip.text = "[HOLDING] Skip | Boss Alive"

			return t1._wake("status")
		end

		if not t1._delayRange("skip", t12.SkipDelay, Skip, "[DELAY] Skip Wave " .. v2565, "AutoSkip") then
			return
		end

		if t12.AutoSkip then
			if workspace:GetAttribute("CanSkip") == true then
				local v2566 = t1._n(workspace:GetAttribute("Votes"))

				if t1.fire("WaveSkip") and t1._confirm(function()
					return workspace:GetAttribute("CanSkip") ~= true or t1._n(workspace:GetAttribute("Votes")) > v2566 or t1._n(workspace:GetAttribute("Wave")) ~= v2565
				end, 3) then
					Skip.wave = v2565
					Skip.n += 1
					Skip.text = "[VOTED] Skip Wave " .. v2565 .. " | " .. Skip.n .. " Skips"
				else
					t1._backoff("skip", 2)
					Skip.text = "[RETRYING] Skip Wave " .. v2565 .. " | No Vote Counted"
				end

				t1._wake("status")

				return
			end
		end

		return t1._wake("skip")
	end
	t1.End = {
		text = "[IDLE]",
		result = nil,
		wins = 0,
		losses = 0,
		seen = nil,
		round = 0,
		votedAt = nil
	}
	t1.End.voted = function(p568)
		local v2567 = tostring(p568 or LocalPlayer.UserId)
		local attribute = workspace:GetAttribute("PlayAgainVoters")
		local v2569 = type(attribute) == "string" and t1._json(attribute)
		local v2570 = type(v2569) == "table" and v2569 or {}

		for _, v in pairs(v2570) do
			if tostring(v) == v2567 then
				return true
			end
		end

		return false
	end
	t1.End.onMessage = function()
		local attribute = workspace:GetAttribute("Message")
		local v2574 = attribute == "You Won!" or attribute == "You Lost!"

		if not v2574 or t1.Ctx.restarting() then
			if t1.End.seen then
				local End = t1.End
				local End2 = t1.End
				local round = t1.End.round + 1

				t1.End.seen = nil
				End.votedAt = nil
				End2.round = round
				t1.Skip.wave = nil
				table.clear(t1.Speed.refusals)
			end

			t1.End.stale = v2574 and attribute or nil

			return
		end

		if t1.End.seen == attribute or t1.End.stale == attribute then
			return
		end

		t1.End.seen = attribute

		local data = t1.State.data
		local v2579 = t1.Match.mode()

		if attribute == "You Won!" then
			t1.End.wins += 1
			data.streak = t1._n(data.streak) + 1
			data.losses = 0

			if v2579 ~= "" then
				data.mode = v2579
			end
		else
			t1.End.losses += 1

			local losses = t1._n(data.losses) + 1

			data.streak = 0
			data.losses = losses

			if v2579 ~= "" then
				data.mode = v2579
			end
		end

		t1.Vote.advance(attribute == "You Won!")
		data.goalRounds = t1._n(data.goalRounds) + 1
		t1.State.save()
		pcall(t1.Hook.roundEnd, attribute == "You Won!")

		if t1.Macro.recording then
			t1.Macro.stopRecording()
		end
	end
	t1.End.goal = function()
		local data = t1.State.data
		local v2582 = t1._n(t12.StopAfterRounds)
		local v2583 = t1._n(t12.StopAfterMinutes)

		if v2582 <= 0 and v2583 <= 0 then
			return nil
		end

		local goalSig = v2582 .. ":" .. v2583

		if data.goalSig ~= goalSig or not data.goalAt then
			local now = os.time()

			data.goalSig = goalSig
			data.goalRounds = 0
			data.goalAt = now
			t1.State.save()
		end

		if v2582 > 0 and v2582 <= t1._n(data.goalRounds) then
			return v2582 .. (v2582 == 1 and " Round" or " Rounds") .. " Played"
		end

		if v2583 > 0 and v2583 * 60 <= os.time() - t1._n(data.goalAt) then
			return t1.Hook.clock(os.time() - t1._n(data.goalAt)) .. " Played"
		end

		return nil
	end

	do
		t1.End.sessionText = function()
			local v2586 = t1.Hook.record()
			local v2587 = v2586.wins + v2586.losses

			if v2587 == 0 then
				return "[SESSION] No Matches | This Session"
			end

			local v2588 = math.max(os.time() - v2586.startedAt, 60)
			local v2589 = "[SESSION] " .. v2587 .. (v2587 == 1 and " Match" or " Matches") .. " | " .. v2586.wins .. "W " .. v2586.losses .. "L, " .. t1._num(math.floor(v2586.coins / (v2588 / 3600) + 0.5)) .. " Coins/h, " .. t1.Hook.clock(v2588)
			local v2590 = t1._n(t12.StopAfterRounds)

			if v2590 > 0 then
				v2589 ..= ", Goal " .. math.min(t1._n(t1.State.data.goalRounds), v2590) .. "/" .. v2590
			end

			return v2589
		end
	end

	t1.End.close = function(p569)
		t1.End.text = "[CLOSING] Game | " .. p569
		t1._wake("status")
		task.delay(2, function()
			if not pcall(game.Shutdown, game) then
				pcall(LocalPlayer.Kick, LocalPlayer, "Barrage: session goal reached (" .. p569 .. ")")
			end
		end)
	end

	do
		t1.End.run = function()
			local End = t1.End

			if not t12.AutoMatchEnd then
				return t1._wake("status")
			end

			if t1.Ctx.place() ~= "RESULTS" then
				End.text = "[WAITING] Awaiting Results | " .. End.wins .. " Wins / " .. End.losses .. " Losses"

				return t1._wake("status")
			end

			if t1.Party.following() then
				End.text = "[FOLLOWING] Host | Alt Farm Picks Play Again Or Lobby"

				return t1._wake("status")
			end

			if t1._backed("end") then
				return t1._wake("status")
			end

			local v2592 = End.goal()

			if v2592 and t12.StopAction == "Close Game" then
				return End.close(v2592)
			end

			local v2593 = t12.EndAction == "Play Again" and not v2592

			if v2593 and End.voted() then
				End.votedAt = End.votedAt or os.clock()

				local v2594 = t1._n(workspace:GetAttribute("PlayAgainTimer"))
				local v2595 = math.max(60 - (os.clock() - End.votedAt), v2594 > 0 and v2594 + 5 or 0)

				if v2595 > 0 then
					End.text = "[VOTED] Play Again | " .. t1._n(workspace:GetAttribute("PlayAgainTimer")) .. "s Left"
					t1._alarm("matchend", math.min(5, v2595), "end:again")

					return t1._wake("status")
				end

				v2593 = false
			end

			local v2596 = v2593 and "Play Again" or "Lobby"

			if not t1._delayRange("end", t12.EndDelay, End, "[DELAY] " .. v2596, "AutoMatchEnd") then
				return
			end

			if not t12.AutoMatchEnd or t1.Ctx.place() ~= "RESULTS" then
				return
			end

			if not v2593 then
				End.text = "[LEAVING] Lobby"
				t1._wake("status")

				local OnLeave = t1.fire("OnLeave")

				if OnLeave and t1._confirm(function()
					return t1.Ctx.leaving
				end, 8) then
					End.text = "[DONE] Lobby | " .. End.wins .. " Wins / " .. End.losses .. " Losses"
				else
					t1._backoff("end", 3)
					End.text = "[RETRYING] Lobby | " .. (OnLeave and "No Teleport" or "Not Sent")
				end

				t1._wake("status")

				return
			end

			if End.voted() then
				return t1._wake("matchend")
			end

			End.text = "[VOTING] Play Again | Awaiting Votes"
			t1._wake("status")

			local PlayAgain = t1.fire("PlayAgain")

			if PlayAgain and t1._confirm(function()
				return End.voted() or t1.Ctx.place() ~= "RESULTS"
			end, 4) then
				End.votedAt = os.clock()
				End.text = "[VOTED] Play Again | " .. End.wins .. " Wins / " .. End.losses .. " Losses"
				t1._alarm("matchend", 5, "end:again")
			else
				t1._backoff("end", 3)
				End.text = "[RETRYING] Play Again | " .. (PlayAgain and "Vote Not Counted" or "Not Sent")
			end

			return t1._wake("status")
		end
	end

	t1.Speed = {
		text = "[IDLE]",
		refusals = {}
	}
	t1.Speed.label = function(p570)
		return (p570 == math.floor(p570) and string.format("%d", p570) or tostring(p570)) .. "x"
	end

	do
		t1.Speed.want = function()
			if t12.SpeedBossSlow and t1.Ctx.inMatch() then
				if t1.Match.ahead("boss", 0) == true or t1.Match.boss() then
					return 1, false, true
				end
			end

			local v2599 = tostring(t12.GameSpeed):gsub("x$", "")
			local v2600 = tonumber(v2599) or 2

			if v2600 > 1.5 and t1._n(t1.Speed.refusals[v2600]) >= 2 then
				return 1.5, true
			end

			return v2600, false
		end
	end

	t1.Speed.run = function()
		local Speed = t1.Speed

		if not t12.AutoSpeed then
			return t1._wake("status")
		end

		local v2602, v2603, v2604 = Speed.want()
		local v2605 = v2604 and " | Boss Wave" or v2603 and " | " .. tostring(t12.GameSpeed) .. " Refused" or ""

		if t12.SpeedBossSlow and t1.Ctx.inMatch() then
			t1._alarm("speed", 5, "speed:boss")
		end

		if not t1.Ctx.inMatch() then
			Speed.text = "[WAITING] Awaiting Match | " .. Speed.label(v2602)

			return t1._wake("status")
		end

		if tonumber(workspace:GetAttribute("GameSpeed")) == v2602 then
			Speed.text = "[ACTIVE] " .. Speed.label(v2602) .. v2605

			return t1._wake("status")
		end

		if v2602 <= 1.5 and t1._n(Speed.refusals[v2602]) >= 2 then
			Speed.text = "[REFUSED] " .. Speed.label(v2602) .. " | Server Said No This Round"

			return t1._wake("status")
		end

		if t1._backed("speed") then
			return t1._wake("status")
		end

		Speed.text = "[SETTING] " .. Speed.label(v2602)
		t1._wake("status")

		local ChangeSpeed, v2607, v2608 = t1.invoke("ChangeSpeed", 6, v2602)

		if ChangeSpeed and v2607 and t1._confirm(function()
			return tonumber(workspace:GetAttribute("GameSpeed")) == v2602
		end, 3) then
			Speed.text = "[ACTIVE] " .. Speed.label(v2602) .. v2605
		elseif ChangeSpeed and not v2607 and t1._busy(v2608) then
			t1._backoff("speed", 2)
			Speed.text = "[RETRYING] " .. Speed.label(v2602) .. " | Server Busy"
		elseif ChangeSpeed and not v2607 then
			if workspace:GetAttribute("IsVoting") ~= true then
				Speed.refusals[v2602] = t1._n(Speed.refusals[v2602]) + 1
			end

			t1._backoff("speed", math.min(30, 5 * math.max(1, t1._n(Speed.refusals[v2602]))))

			local v2609 = v2602 > 1.5 and "X2 Speed Requirement" or "Server Said No"

			Speed.text = "[REFUSED] " .. Speed.label(v2602) .. " | " .. v2609
		else
			t1._backoff("speed", 5)
			Speed.text = "[RETRYING] " .. Speed.label(v2602) .. " | " .. (ChangeSpeed and "No Echo" or "Not Sent")
		end

		t1._wake("status")
	end
	t1.Vote = {
		text = "[IDLE]",
		voted = nil
	}

	do
		local function modes()
			local v2611 = t1.Modes()
			local t167 = {}
			local v2613 = type(v2611) == "table" and v2611 or {}

			for k, v in pairs(v2613) do
				if type(v) == "string" and v:find("WAVE:", 1, true) then
					t167[#t167 + 1] = k
				end
			end

			if #t167 == 0 then
				return table.clone(t17)
			end

			table.sort(t167, function(p571, p572)
				local v2616 = t1.Match.plan(p571)
				local v2617 = t1.Match.plan(p572)
				local reward = v2616 and v2616.reward or 0
				local reward2 = v2617 and v2617.reward or 0

				if reward == reward2 then
					return p571 < p572
				end

				return reward < reward2
			end)

			return t167
		end

		t1.Vote.modes = modes
	end

	t1.Vote.ladder = function()
		local t168 = {}

		for _, v in ipairs(t1.Vote.modes()) do
			local v2623 = t1.Match.plan(v)

			if v2623 and v2623.reward > 0 then
				t168[#t168 + 1] = v
			end
		end

		return #t168 > 0 and t168 or t1.Vote.modes()
	end
	t1.Vote.advance = function(p573)
		local data = t1.State.data
		local v2625 = t1.Vote.ladder()
		local v2626 = table.find(v2625, data.mode or "") or 1

		if p573 and t1._n(data.streak) >= 2 and v2626 < #v2625 then
			data.mode = v2625[v2626 + 1]
			data.streak = 0
		elseif not p573 and v2626 > 1 then
			data.mode = v2625[v2626 - 1]
		end
	end
	t1.Vote.pick = function()
		if t12.VoteMode ~= "Smart Progression" then
			return t12.VoteMode
		end

		local v2627 = t1.Vote.ladder()
		local mode = t1.State.data.mode

		return table.find(v2627, mode or "") and mode or v2627[1]
	end
	t1.Vote.mine = function(p574)
		local attribute = workspace:GetAttribute(tostring(p574) .. "Voters")
		local v2630 = type(attribute) == "string" and t1._json(attribute)
		local v2631 = type(v2630) == "table" and v2630 or {}

		for _, v in pairs(v2631) do
			if v == LocalPlayer.UserId or tostring(v) == tostring(LocalPlayer.UserId) or v == LocalPlayer.Name then
				return true
			end
		end

		return false
	end
	t1.Vote.run = function()
		local Vote = t1.Vote

		if not t12.AutoVote then
			return t1._wake("status")
		end

		if not t1.Ctx.inMatch() then
			Vote.text = "[WAITING] Awaiting Match | " .. t1.Vote.pick()

			return t1._wake("status")
		end

		if workspace:GetAttribute("IsVoting") ~= true then
			local v2635 = t1.Match.mode()

			Vote.text = v2635 ~= "" and "[PLAYING] " .. v2635 .. " | Next " .. t1.Vote.pick() or "[WAITING] Awaiting Vote"

			return t1._wake("status")
		end

		local v2636 = Vote.pick()

		if Vote.mine(v2636) then
			Vote.text = "[VOTED] " .. v2636

			return t1._wake("status")
		end

		if t1._backed("vote") then
			return t1._wake("status")
		end

		if not t1._delayRange("vote", t12.VoteDelay, Vote, "[DELAY] " .. v2636, "AutoVote") then
			return
		end

		if t12.AutoVote then
			if workspace:GetAttribute("IsVoting") == true then
				if t1.fire("ModeVote", v2636) and t1._confirm(function()
					return Vote.mine(v2636) or workspace:GetAttribute("IsVoting") ~= true
				end, 3) then
					Vote.voted = v2636
					Vote.text = "[VOTED] " .. v2636
				else
					t1._backoff("vote", 2)
					Vote.text = "[RETRYING] " .. v2636 .. " | Vote Not Counted"
				end

				t1._wake("status")

				return
			end
		end

		return t1._wake("vote")
	end
	t1.ModVote = {
		text = "[IDLE]"
	}
	t1.ModVote.votes = function()
		local attribute = workspace:GetAttribute("ModifierVotes")
		local v2638 = type(attribute) == "string" and t1._json(attribute)

		return type(v2638) == "table" and v2638 or {}
	end
	t1.ModVote.mine = function(p575)
		local v2639 = t1.ModVote.votes()[p575] or {}

		for _, v in pairs(v2639) do
			if v == LocalPlayer.UserId or tostring(v) == tostring(LocalPlayer.UserId) then
				return true
			end
		end

		return false
	end
	t1.ModVote.run = function()
		local ModVote = t1.ModVote

		if not t12.AutoModVote then
			return t1._wake("status")
		end

		if not t1.Ctx.inMatch() then
			ModVote.text = "[WAITING] Awaiting Match | Modifier Vote"

			return t1._wake("status")
		end

		if workspace:GetAttribute("IsModifierVoting") ~= true then
			ModVote.text = "[WAITING] Awaiting Vote | Modifiers Open At Match Start"

			return t1._wake("status")
		end

		local v2643 = t1._set(t12.ModVotePicks)
		local t169 = {}
		local t170 = {}

		for _, v in ipairs(t1.Queue.mods()) do
			if v2643[v.name] then
				if ModVote.mine(v.key) then
					t170[#t170 + 1] = v.name
				else
					t169[#t169 + 1] = v
				end
			end
		end

		if #t169 == 0 and #t170 == 0 then
			ModVote.text = "[WAITING] Awaiting Selection | Modifiers To Vote"

			return t1._wake("status")
		end

		local v2648 = t1._n(workspace:GetAttribute("ModifierVotesNeeded"), 1)

		if #t169 == 0 then
			local v2649 = t1.ModVote.votes()
			local t171 = {}

			for _, v in ipairs(t1.Queue.mods()) do
				if v2643[v.name] then
					t171[#t171 + 1] = v.name .. " " .. #(v2649[v.key] or {}) .. " / " .. v2648
				end
			end

			ModVote.text = "[VOTED] " .. table.concat(t171, ", ")

			return t1._wake("status")
		end

		local v2653

		for _, v in ipairs(t169) do
			if not t1._backed("modvote:" .. v.key) then
				v2653 = v

				break
			end
		end

		if not v2653 then
			return t1._wake("status")
		end

		if not t1._delayRange("modvote", t12.ModVoteDelay, ModVote, "[DELAY] " .. v2653.name, "AutoModVote") then
			return
		end

		if t12.AutoModVote then
			if workspace:GetAttribute("IsModifierVoting") == true then
				if not ModVote.mine(v2653.key) then
					if t1.fire("ModifierVote", v2653.key) and t1._confirm(function()
						return ModVote.mine(v2653.key) or workspace:GetAttribute("IsModifierVoting") ~= true
					end, 3) then
						ModVote.text = "[VOTED] " .. v2653.name
					else
						t1._backoff("modvote:" .. v2653.key, 30)
						ModVote.text = "[REFUSED] " .. v2653.name .. " | Vote Not Counted"
					end
				end

				t1._wake("modvote")
				t1._wake("status")

				return
			end
		end

		return t1._wake("modvote")
	end
	t1.Chores = {}
	t1._chore = function(p576, p577)
		t1.Chores[#t1.Chores + 1] = {
			name = p576,
			T = p577
		}
		p577.text = p577.text or "[IDLE]"
		p577.due = false

		return p577
	end

	local t172 = {}

	for k, v in pairs(t15) do
		t172[v] = k
	end

	t1._lobbyGate = function(p578, p579)
		if not t12[p579] then
			p578.due = false
			t1._wake("status")

			return false
		end

		if not t1.Ctx.lobby() then
			p578.due = false
			p578.text = "[WAITING] Awaiting Lobby"
			t1._wake("status")

			return false
		end

		if not t1.data() then
			p578.text = "[WAITING] Awaiting Data"
			t1._alarm(t172[p579], 2, "data:" .. p579)
			t1._wake("status")

			return false
		end

		if not (t1._replicaFor == t1._replica or t1._replicaTry) then
			t1._wake("replica")
		end

		if t1._backed(t172[p579]) then
			p578.due = false
			t1._wake("status")

			return false
		end

		return true
	end
	t1._done = function(p580, p581)
		p580.due = false
		p580.text = p581
		t1._wake("status")
		t1._wake("queue")
	end

	do
		t1.Bag = function()
			local v2659 = t1.data()

			return v2659 and type(v2659.Towers) == "table" and v2659.Towers or {}
		end
	end

	t1.BagCount = function()
		local n72 = 0

		for _ in pairs(t1.Bag()) do
			n72 += 1
		end

		return n72
	end
	t1.Space = function()
		local v2662 = t1.data()

		return v2662 and t1._n(v2662.InventorySpace, 999) or 999
	end
	t1.Rarities = function()
		local RarityOrder = t1.gameSettings().RarityOrder
		local t173 = {}
		local v2665 = type(RarityOrder) == "table" and RarityOrder or {}

		for k in pairs(v2665) do
			t173[#t173 + 1] = k
		end

		if #t173 == 0 then
			return table.clone(t2)
		end

		table.sort(t173, function(p582, p583)
			return t1._n(RarityOrder[p582]) < t1._n(RarityOrder[p583])
		end)

		return t173
	end
	t1.Sum = t1._chore("summon", {
		got = 0,
		trip = 0
	})
	t1.Sum.crates = function()
		local t174 = {}
		local SummonCrates = type(t1.gameSettings().SummonCrates) == "table" and t1.gameSettings().SummonCrates or {}

		for _, SummonCrate in ipairs(SummonCrates) do
			if type(SummonCrate) == "table" and SummonCrate.Name then
				t174[#t174 + 1] = SummonCrate
			end
		end

		return t174
	end
	t1.Sum.names = function()
		local t175 = {}

		for _, v in ipairs(t1.Sum.crates()) do
			t175[#t175 + 1] = tostring(v.Name)
		end

		if #t175 == 0 then
			t175 = { "Basic Crate" }
		end

		return t175
	end

	do
		t1.Sum.current = function(p584)
			if t1.Sum.set == nil then
				if not t1._backed("sumset") then
					local GetSummonSet, v2675 = t1.invoke("GetSummonSet", 6)

					if GetSummonSet and type(v2675) == "table" then
						t1.Sum.set = v2675
					else
						t1._backoff("sumset", 15)
					end
				end
			end

			local v2676 = type(t1.Sum.set) == "table" and t1.Sum.set[p584]

			return type(v2676) == "table" and v2676 or nil
		end
	end

	t1.Sum.wanted = function(p585)
		if type(t12.SummonWanted) ~= "table" or next(t12.SummonWanted) == nil then
			return true
		end

		local v2677 = t1.Sum.current(p585) or {}

		for _, v in pairs(v2677) do
			if t1._has("SummonWanted", tostring(v)) then
				return tostring(v)
			end
		end

		return nil
	end
	t1.Sum.unitNames = function()
		local v2680 = t1.Cfg()
		local v2681 = t1._set(t1.gameSettings().SummonRarities)
		local t176 = {}
		local Towers = v2680 and type(v2680.Towers) == "table" and v2680.Towers or {}

		for k, Tower in pairs(Towers) do
			if type(Tower) == "table" and Tower.NotInSummon ~= true and (next(v2681) == nil or v2681[Tower.Rarity]) then
				t176[#t176 + 1] = tostring(k)
			end
		end

		table.sort(t176)

		return t176
	end
	t1.Sum.found = function(p586)
		if not t12.SummonStopWanted or type(t12.SummonWanted) ~= "table" or next(t12.SummonWanted) == nil then
			return false
		end

		for _, v in ipairs(p586) do
			local Name = type(v) == "table" and v.Name or v

			if type(Name) == "string" and t1._has("SummonWanted", Name) then
				t12.AutoSummon = false

				if t1._setControl then
					t1._setControl("AutoSummon", false)
				end

				t1._saveSoon()
				t1.Sum.text = "[FOUND] " .. Name .. " | Auto Summon Stopped"
				t1._wake("status")

				return true
			end
		end

		return false
	end
	t1.Sum.run = function()
		local Sum = t1.Sum

		if not t1._lobbyGate(Sum, "AutoSummon") then
			return
		end

		local v2690

		for _, v in ipairs(Sum.crates()) do
			if v.Name == t12.SummonCrate then
				v2690 = v
			end
		end

		local v2693 = v2690 or Sum.crates()[1]

		if not v2693 then
			return t1._done(Sum, "[WAITING] Awaiting Crates")
		end

		local v2694 = t1._n(v2693.SummonPrice)
		local v2695 = t1._n(t1.data().Money) - t1._n(t12.SummonKeep)
		local v2696 = t1.Space() - t1.BagCount()

		if v2696 <= 0 then
			t1._wake("unitsell")

			return t1._done(Sum, "[FULL] Inventory | " .. t1.BagCount() .. " / " .. t1.Space())
		end

		local n73 = 1

		if t12.SummonAmount == "Ten" or t12.SummonAmount == "Smart" and v2694 * 9 <= v2695 and v2696 >= 10 then
			n73 = 10
		end

		local v2698 = n73 == 10 and v2694 * 9 or v2694

		if v2695 < v2698 then
			return t1._done(Sum, "[SAVING] " .. v2693.Name .. " | " .. t1._num(math.max(0, v2695)) .. " / " .. t1._num(v2698) .. " Coins")
		end

		if not Sum.wanted(v2693.Name) then
			return t1._done(Sum, "[WAITING] Awaiting Rotation | No Wanted Unit")
		end

		Sum.due = true

		if not t1._delayRange("summon", t12.SummonDelay, Sum, "[DELAY] " .. v2693.Name, "AutoSummon") then
			return
		end

		if not t12.AutoSummon then
			return
		end

		Sum.text = "[SUMMONING] " .. v2693.Name .. " | x" .. n73
		t1._wake("status")

		local SummonTowers, v2700, v2701 = t1.invoke("SummonTowers", 10, v2693.Name, n73)

		if SummonTowers and type(v2700) == "table" and #v2700 > 0 then
			pcall(t1.Hook.summons, v2700, v2693.Name)
			Sum.got += #v2700
			Sum.text = "[SUMMONED] " .. #v2700 .. " Units | " .. Sum.got .. " Total"

			if Sum.found(v2700) then
				t1._wake("equip")

				return t1._wake("unitsell")
			end

			t1._wake("equip")
			t1._wake("unitsell")
			t1._wake("summon")

			return t1._wake("status")
		end

		if not SummonTowers or v2700 == false and t1._busy(v2701) then
			Sum.due = false
			t1._backoff("summon", SummonTowers and 3 or 5)
			Sum.text = "[WAITING] Awaiting Server | " .. v2693.Name

			return t1._wake("status")
		end

		local v2702 = t1._at(workspace, "Zones.Summon")
		local isBasePart = v2702 and (v2702:IsA("BasePart") and v2702 or v2702:FindFirstChildWhichIsA("BasePart", true))

		if isBasePart and not t1.Queue.inside and os.clock() - Sum.trip > 30 and t1.Move.lease("summon") then
			Sum.trip = os.clock()
			Sum.text = "[MOVING] Summon Zone"
			t1._wake("status")
			t1.Move.to(isBasePart.Position - Vector3.new(0, 2, 0))

			local SummonTowers2, v2705 = t1.invoke("SummonTowers", 10, v2693.Name, n73)

			t1.Move.release("summon")

			if SummonTowers2 and type(v2705) == "table" and #v2705 > 0 then
				pcall(t1.Hook.summons, v2705, v2693.Name)
				Sum.got += #v2705
				Sum.text = "[SUMMONED] " .. #v2705 .. " Units | " .. Sum.got .. " Total"

				if Sum.found(v2705) then
					return
				end

				t1._wake("summon")

				return t1._wake("status")
			end
		end

		Sum.due = false
		t1._backoff("summon", 10)
		Sum.text = "[REFUSED] " .. v2693.Name .. " | Coins Or Inventory"
		t1._wake("status")
	end
	t1.ASell = t1._chore("autosell", {})

	do
		local function rarities()
			local SummonRarities = t1.gameSettings().SummonRarities
			local t177 = {}
			local v2709 = type(SummonRarities) == "table" and SummonRarities or {}

			for k, v in pairs(v2709) do
				local Name = type(k) == "string" and k or type(v) == "string" and v or type(v) == "table" and v.Name

				if type(Name) == "string" and not table.find(t177, Name) then
					t177[#t177 + 1] = Name
				end
			end

			if #t177 == 0 then
				for _, v in ipairs(t1.Rarities()) do
					if v ~= "Exclusive" then
						t177[#t177 + 1] = v
					end
				end
			end

			return t177
		end

		t1.ASell.rarities = rarities
	end

	t1.ASell.run = function()
		local ASell = t1.ASell

		if not t1._lobbyGate(ASell, "AutoAutosell") then
			return
		end

		local Autosell = type(t1.data().Autosell) == "table" and t1.data().Autosell or {}
		local as
		local v2718, v2719, v2720 = ipairs(ASell.rarities())
		local v2721 = geniter(v2718, v2719, v2720)

		while true do
			local v2722 = table.pack(v2721())

			if v2722[1] then
				local as2 = v2722[3]

				if not (Autosell[as2] == true == t1._has("AutosellRarities", as2) or t1._backed("as:" .. as2)) then
					as = as2

					break
				end
			else
				break
			end
		end

		if not as then
			local t178 = {}
			local v2725, v2726, v2727 = ipairs(ASell.rarities())

			for _, v in v2725, v2726, v2727 do
				if Autosell[v] == true then
					t178[#t178 + 1] = v
				end
			end

			local _done = t1._done
			local v2731 = ASell
			local v2732 = #t178 > 0 and table.concat(t178, ", ") or "None"

			return _done(v2731, "[SYNCED] Autosell | " .. v2732)
		end

		ASell.due = true

		if not t1._delayRange("autosell", t12.AutosellDelay, ASell, "[DELAY] " .. as, "AutoAutosell") then
			return
		end

		local AutosellRarities = t1._has("AutosellRarities", as)

		if t1.fire("AutosellEnable", as) and t1._confirm(function()
			local Autosell2 = t1.data()

			Autosell2 = Autosell2 and t1.data().Autosell

			return type(Autosell2) == "table" and Autosell2[as] == true == AutosellRarities
		end, 3) then
			ASell.text = "[SET] " .. as .. " | " .. (AutosellRarities and "Sell" or "Keep")
		else
			t1._backoff("as:" .. as, 300)
			ASell.text = "[REFUSED] " .. as .. " | No Change"
		end

		t1._wake("autosell")
		t1._wake("status")
	end
	t1.Equip = t1._chore("equip", {
		swaps = 0
	})

	do
		t1.Equip.score = function(p587)
			if t12.EquipBy == "Rarity" then
				return t1.Units.rarityRank(p587) * 1e9 + t1.Units.power(p587)
			end

			return t1.Units.power(p587)
		end
	end

	do
		t1.Equip.want = function()
			local t179 = {}
			local v2736, v2737, v2738 = pairs(t1.Bag())

			for k, v in v2736, v2737, v2738 do
				local Name = type(v) == "table" and v.Name

				if Name and t1.towerCfg(Name) then
					local v2742 = t179[Name]
					local v2743 = type(v.Equipped) == "number"

					if not v2742 or v2743 and not v2742.equipped then
						t179[Name] = {
							uuid = k,
							name = Name,
							equipped = v2743
						}
					end
				end
			end

			local v2744 = math.max(1, t1._n(t1.gameSettings().HotbarSlots, 5))

			if t12.EquipBy == "Saved Team" then
				local t180 = {}
				local v2746, v2747, v2748 = ipairs(t12.EquipTeam)

				for _, v in v2746, v2747, v2748 do
					local v2751 = t179[tostring(v)]

					if v2751 and v2744 > #t180 and not table.find(t180, v2751) then
						t180[#t180 + 1] = v2751
					end
				end

				return t180, v2744
			end

			local t181 = {}
			local v2753, v2754, v2755 = pairs(t179)

			for _, v in v2753, v2754, v2755 do
				t181[#t181 + 1] = v
			end

			table.sort(t181, function(p588, p589)
				local v2758 = t1.Equip.score(p588.name)
				local v2759 = t1.Equip.score(p589.name)

				if v2758 == v2759 then
					return p588.name < p589.name
				end

				return v2758 > v2759
			end)

			local t182 = {}

			if t12.EquipBy == "Smart" then
				local v2761
				local v2762
				local v2763, v2764, v2765 = ipairs(t181)

				for _, v in v2763, v2764, v2765 do
					if not v2761 and t1.Units.hidden(v.name) then
						v2761 = v
					end
				end

				local v2768, v2769, v2770 = ipairs(t181)

				for _, v in v2768, v2769, v2770 do
					if t1.Units.income(v.name) > 0 then
						if v2762 then
							local v2773 = t1.Units.income(v.name)

							if not (t1.Units.income(v2762.name) < v2773) then
								continue
							end
						end

						v2762 = v
					end
				end

				if v2761 then
					t182[#t182 + 1] = v2761
				end

				if v2762 and v2762 ~= v2761 then
					t182[#t182 + 1] = v2762
				end
			end

			local v2774, v2775, v2776 = ipairs(t181)
			local v2777 = geniter(v2774, v2775, v2776)

			while true do
				local v2778 = table.pack(v2777())

				if v2778[1] then
					local v2779 = v2778[3]

					if v2744 <= #t182 then
						break
					end

					if not table.find(t182, v2779) and t1.Units.income(v2779.name) <= 0 then
						t182[#t182 + 1] = v2779
					end

					continue
				end

				break
			end

			local v2780, v2781, v2782 = ipairs(t181)

			for _, v in v2780, v2781, v2782 do
				if v2744 <= #t182 then
					break
				end

				if not table.find(t182, v) then
					t182[#t182 + 1] = v
				end
			end

			return t182, v2744
		end
	end

	t1.Equip.saveTeam = function()
		local t183 = {}

		for _, v in pairs(t1.Bag()) do
			if type(v) == "table" and type(v.Equipped) == "number" and v.Name then
				t183[#t183 + 1] = v
			end
		end

		table.sort(t183, function(p590, p591)
			return p590.Equipped < p591.Equipped
		end)

		local equipTeam = {}

		for _, v in ipairs(t183) do
			if not table.find(equipTeam, tostring(v.Name)) then
				equipTeam[#equipTeam + 1] = tostring(v.Name)
			end
		end

		if #equipTeam == 0 then
			t1.Equip.text = "[EMPTY] Team | No Units Equipped"

			return t1._wake("status")
		end

		t12.EquipTeam = equipTeam
		t1._saveSoon()
		t1.Equip.text = "[SAVED] Team | " .. table.concat(equipTeam, ", ")
		t1._wake("equip")
		t1._wake("status")
	end
	t1.Equip.run = function()
		local Equip = t1.Equip

		if not t1._lobbyGate(Equip, "AutoEquip") then
			return
		end

		if t12.EquipBy == "Saved Team" and #t12.EquipTeam == 0 then
			return t1._done(Equip, "[WAITING] Awaiting Team | Saved Team Requirement")
		end

		local v2792, v2793 = Equip.want()
		local t184 = {}

		for _, v in ipairs(v2792) do
			t184[v.name] = v
		end

		local t185 = {}
		local v2798
		local n74 = 0

		for k, v in pairs(t1.Bag()) do
			if type(v) == "table" and type(v.Equipped) == "number" then
				t185[#t185 + 1] = k

				if t184[v.Name] and t184[v.Name].uuid == k then
					n74 += 1
				end

				if (not t184[v.Name] or t184[v.Name].uuid ~= k) and (not v2798 or t1.Equip.score(v.Name) < t1.Equip.score(t1.Bag()[v2798].Name)) then
					v2798 = k
				end
			end
		end

		local v2802

		for _, v in ipairs(v2792) do
			local v2805 = t1.Bag()[v.uuid]

			if v2805 then
				if not (type(v2805.Equipped) == "number" or t1._backed("eq:" .. v.uuid)) then
					v2802 = v

					break
				end
			end
		end

		if not (v2802 or not not v2798 and v2793 < #t185) then
			return t1._done(Equip, "[EQUIPPED] Best Units | " .. #t185 .. " / " .. v2793)
		end

		Equip.due = true

		if not t1._delayRange("equip", t12.EquipDelay, Equip, "[DELAY] " .. (v2802 and v2802.name or "Hotbar"), "AutoEquip") then
			return
		end

		if #t185 >= 2 and n74 == 0 and v2802 then
			if t1.fire("EquipPart", "UnequipAll") and t1._confirm(function()
				for _, v in pairs(t1.Bag()) do
					if type(v) == "table" and type(v.Equipped) == "number" then
						return false
					end
				end

				return true
			end, 3) then
				Equip.text = "[CLEARED] Hotbar | Unequip All"
				t1._wake("equip")

				return t1._wake("status")
			end

			t1._backoff("equip", 10)
			Equip.due = false
			Equip.text = "[REFUSED] Unequip All | No Change"

			return t1._wake("status")
		end

		if v2793 <= #t185 and v2798 then
			local Name = t1.Bag()[v2798] and t1.Bag()[v2798].Name

			if not (t1.fire("EquipPart", v2798) and t1._confirm(function()
				local v2809 = t1.Bag()[v2798]

				return not v2809 or type(v2809.Equipped) ~= "number"
			end, 3)) then
				t1._backoff("equip", 10)
				Equip.due = false
				Equip.text = "[REFUSED] Unequip " .. tostring(Name) .. " | No Change"

				return t1._wake("status")
			end
		end

		if v2802 then
			if t1.fire("EquipPart", v2802.uuid) and t1._confirm(function()
				local v2810 = t1.Bag()[v2802.uuid]

				return v2810 and type(v2810.Equipped) == "number"
			end, 3) then
				Equip.swaps += 1
				Equip.text = "[EQUIPPED] " .. v2802.name .. " | " .. Equip.swaps .. " Swaps"
			else
				t1._backoff("eq:" .. v2802.uuid, 15)
				Equip.text = "[REFUSED] " .. v2802.name .. " | No Change"
			end
		end

		t1._wake("equip")
		t1._wake("status")
	end
	t1.USell = t1._chore("unitsell", {
		sold = 0
	})
	t1.USell.pick = function()
		local StarterTower = t1.gameSettings().StarterTower or "Speakerman"
		local UnitSellKeep = t1._has("UnitSellKeep", "Keep One Of Each")
		local t186 = {}
		local t187 = {}

		for _, v in pairs(t1.Bag()) do
			if type(v) == "table" and type(v.Equipped) == "number" then
				t186[v.Name] = true
			end
		end

		local t188 = {}

		for k in pairs(t1.Bag()) do
			t188[#t188 + 1] = k
		end

		table.sort(t188)

		for _, v in ipairs(t188) do
			local v2821 = t1.Bag()[v]
			local v2822 = type(v2821) == "table" and t1.towerCfg(v2821.Name)

			if v2822 and type(v2821.Equipped) ~= "number" and v2821.Name ~= StarterTower and t1._has("UnitSellRarities", v2822.Rarity) then
				if UnitSellKeep and not t186[v2821.Name] then
					t186[v2821.Name] = true

					continue
				end

				t187[#t187 + 1] = v

				if not (#t187 >= 25) then
					continue
				end
			else
				continue
			end

			break
		end

		return t187
	end
	t1.USell.run = function()
		local USell = t1.USell

		if not t1._lobbyGate(USell, "AutoUnitSell") then
			return
		end

		if not t1._needs("UnitSellRarities", "Rarities", USell) then
			return
		end

		local v2824 = USell.pick()

		if #v2824 == 0 then
			return t1._done(USell, "[DONE] Unit Sell | " .. USell.sold .. " Sold")
		end

		USell.due = true

		if not t1._delayRange("unitsell", t12.UnitSellDelay, USell, "[DELAY] " .. #v2824 .. " Units", "AutoUnitSell") then
			return
		end

		if not t12.AutoUnitSell then
			return
		end

		local v2825 = t1.BagCount()

		if t1.fire("SellPart", v2824) and t1._confirm(function()
			return t1.BagCount() < v2825
		end, 3) then
			USell.sold += v2825 - t1.BagCount()
			USell.text = "[SOLD] " .. v2825 - t1.BagCount() .. " Units | " .. USell.sold .. " Total"
			t1._wake("summon")
		else
			t1._backoff("unitsell", 15)
			USell.text = "[REFUSED] Unit Sell | No Change"
		end

		t1._wake("unitsell")
		t1._wake("status")
	end
	t1.Codes = t1._chore("codes", {
		got = 0
	})
	t1.Codes.extra = function()
		local t189 = {}
		local t190 = {}
		local CodesExtra = t12.CodesExtra or ""

		for match in tostring(CodesExtra):gmatch("[^%s,;]+") do
			if #match <= 40 and not t190[match:lower()] then
				t190[match:lower()] = true
				t189[#t189 + 1] = match
			end
		end

		return t189
	end
	t1.Codes.names = function()
		local v2830 = table.clone(t3)

		for _, v in ipairs(t1.Codes.extra()) do
			if not table.find(v2830, v) then
				v2830[#v2830 + 1] = v
			end
		end

		return v2830
	end
	t1.Codes.redeemed = function(p592)
		local RedeemedCodes = t1.data() and t1.data().RedeemedCodes

		if type(RedeemedCodes) ~= "table" then
			return false
		end

		for k, RedeemedCode in pairs(RedeemedCodes) do
			if type(RedeemedCode) == "string" and RedeemedCode:lower() == p592:lower() or type(k) == "string" and k:lower() == p592:lower() and RedeemedCode then
				return true
			end
		end

		return false
	end
	t1.Codes.run = function()
		local Codes = t1.Codes

		if not t1._lobbyGate(Codes, "AutoCodes") then
			return
		end

		local v2837 = t1._n(t1.data().Wins)

		if v2837 < 3 then
			return t1._done(Codes, "[WAITING] Awaiting Wins | " .. v2837 .. " / 3")
		end

		t1.State.data.codes = t1.State.data.codes or {}

		local v2838 = t1.State.data.codes[tostring(LocalPlayer.UserId)] or {}

		t1.State.data.codes[tostring(LocalPlayer.UserId)] = v2838

		local v2839
		local n75 = 0
		local v2841 = t1._set(Codes.extra())

		for _, v in ipairs(Codes.names()) do
			if t1._has("CodeSelection", v) or v2841[v] then
				n75 += 1

				if not (v2838[v] or Codes.redeemed(v)) then
					v2839 = v

					break
				end
			end
		end

		if not v2839 then
			if n75 == 0 then
				return t1._done(Codes, "[DONE] Codes | None Selected")
			end

			return t1._done(Codes, "[DONE] Codes | " .. Codes.got .. " Redeemed")
		end

		Codes.due = true

		if not t1._delayRange("codes", t12.CodesDelay, Codes, "[DELAY] " .. v2839, "AutoCodes") then
			return
		end

		if not t12.AutoCodes then
			return
		end

		Codes.text = "[REDEEMING] " .. v2839
		t1._wake("status")

		if not t1.fire("RedeemCode", v2839) then
			Codes.due = false
			t1._backoff("codes", 10)
			Codes.text = "[WAITING] Awaiting Server | " .. v2839

			return t1._wake("status")
		end

		local v2844 = t1._confirm(function()
			return Codes.redeemed(v2839)
		end, 3)

		v2838[v2839] = true
		t1.State.save()

		if v2844 then
			Codes.got += 1
			Codes.text = "[REDEEMED] " .. v2839
		else
			Codes.text = "[REFUSED] " .. v2839 .. " | Used Or Expired"
		end

		t1._wake("codes")
		t1._wake("status")
	end
	t1.Quest = t1._chore("quests", {
		got = 0,
		list = nil,
		asked = 0,
		unanswered = 0
	})
	t1.Quest.label = function(p593)
		return (tostring(p593):gsub("(%l)(%u)", "%1 %2"):gsub("(%a)(%d)", "%1 %2"):gsub("(%d)(%a)", "%1 %2"))
	end
	t1.Quest.names = function()
		local v2845 = table.clone(t18)
		local list = type(t1.Quest.list) == "table" and t1.Quest.list or {}

		for _, v in pairs(list) do
			local pairs_ = pairs
			local v2850 = type(v) == "table" and v or {}

			for _, v2 in pairs_(v2850) do
				local v2853 = type(v2) == "table" and v2.Id ~= nil and t1.Quest.label(v2.Id)

				if v2853 and not table.find(v2845, v2853) then
					v2845[#v2845 + 1] = v2853
				end
			end
		end

		table.sort(v2845)

		return v2845
	end

	do
		t1.Quest.find = function(p594)
			local list = type(t1.Quest.list) == "table" and t1.Quest.list or {}

			for _, v in pairs(list) do
				local pairs_ = pairs
				local v2858 = type(v) == "table" and v or {}

				for _, v2 in pairs_(v2858) do
					if type(v2) == "table" and v2.Id ~= nil then
						if p594 == nil then
							if v2.State == "Completed" and not v2.RewardClaimed and t1._has("QuestSelection", t1.Quest.label(v2.Id)) and not t1._backed("quest:" .. tostring(v2.Id)) then
								return v2
							end

							continue
						end

						if tostring(v2.Id) == tostring(p594) then
							return v2
						end
					end
				end
			end

			return nil
		end
	end

	t1.Quest.ask = function()
		t1.Quest.list = nil
		t1.Quest.asked = os.clock()

		return t1.fire("RequestQuestData")
	end
	t1.Quest.run = function()
		local Quest = t1.Quest

		if not t1._lobbyGate(Quest, "AutoQuests") then
			return
		end

		if not t1._needs("QuestSelection", "Quests", Quest) then
			return
		end

		local v2862 = t1._n(t1.data().Wins)

		if v2862 < 20 then
			return t1._done(Quest, "[WAITING] Awaiting Wins | " .. v2862 .. " / 20")
		end

		if Quest.list == nil then
			local v2863 = os.clock() - Quest.asked

			if v2863 < 5 then
				Quest.text = "[LOADING] Quests | Awaiting Data"
				t1._alarm("quests", 5.25 - v2863, "quest:ask")

				return t1._wake("status")
			end

			if Quest.unanswered >= 3 then
				Quest.unanswered = 0
				t1._backoff("quests", 60)

				return t1._done(Quest, "[WAITING] Awaiting Server | No Quest Data")
			end

			Quest.due = true
			Quest.unanswered += 1

			if Quest.ask() then
				Quest.text = "[LOADING] Quests | Awaiting Data"
				t1._alarm("quests", 5.25, "quest:ask")

				return t1._wake("status")
			end

			t1._backoff("quests", 10)

			return t1._done(Quest, "[WAITING] Awaiting Server | Quests")
		end

		local v2864 = Quest.find()

		if not v2864 then
			return t1._done(Quest, "[DONE] Quests | " .. Quest.got .. " Claimed")
		end

		Quest.due = true

		local Id = v2864.Id
		local v2866 = t1.Quest.label(v2864.Id)

		if not t1._delayRange("quests", t12.QuestDelay, Quest, "[DELAY] " .. v2866, "AutoQuests") then
			return
		end

		if not t12.AutoQuests then
			return
		end

		Quest.text = "[CLAIMING] " .. v2866
		t1._wake("status")

		local CollectQuest = t1.invoke("CollectQuest", 8, Id, "Daily")

		if CollectQuest and Quest.ask() and t1._confirm(function()
			if Quest.list == nil then
				return false
			end

			local v2868 = Quest.find(Id)

			return not v2868 or v2868.RewardClaimed == true
		end, 5) then
			Quest.got += 1
			Quest.text = "[CLAIMED] " .. v2866
		else
			t1._backoff("quest:" .. tostring(Id), 60)
			Quest.text = "[REFUSED] " .. v2866 .. " | " .. (CollectQuest and "Not Claimed" or "Not Sent")
		end

		t1._wake("quests")
		t1._wake("status")
	end
	t1.Boost = t1._chore("boosts", {
		used = 0
	})
	t1.Boost.active = function(p595)
		local Boosts = t1.data() and t1.data().Boosts
		local v2870 = p595:lower():sub(1, 4)
		local now = os.time()
		local v2872 = type(Boosts) == "table" and Boosts or {}

		for k, v in pairs(v2872) do
			local v2875 = type(v) == "table"

			if v2875 then
				v2875 = tostring(v.Name or k)
			end

			v2875 = v2875 or tostring(k)

			local v2876 = type(v) == "table" and t1._n(v.ExpireTime) or t1._n(v)

			if v2875:lower():find(v2870, 1, true) and now < v2876 then
				return true
			end
		end

		return false
	end
	t1.Boost.stored = function(p596)
		local StoredBoosts = t1.data() and t1.data().StoredBoosts

		return type(StoredBoosts) == "table" and t1._n(StoredBoosts[p596]) or 0
	end
	t1.Boost.run = function()
		local Boost = t1.Boost

		if not t1._lobbyGate(Boost, "AutoBoosts") then
			return
		end

		if not t1._needs("BoostSelection", "Boosts", Boost) then
			return
		end

		local boost

		for _, v in ipairs(t5) do
			if t1._has("BoostSelection", v) and Boost.stored(v) > 0 and not (Boost.active(v) or t1._backed("boost:" .. v)) then
				boost = v

				break
			end
		end

		if not boost then
			return t1._done(Boost, "[DONE] Boosts | " .. Boost.used .. " Used")
		end

		Boost.due = true

		if not t1._delayRange("boosts", t12.BoostDelay, Boost, "[DELAY] " .. boost, "AutoBoosts") then
			return
		end

		local v2882 = Boost.stored(boost)

		if t1.fire("UseBoost", boost) then
			if t1._confirm(function()
				return Boost.stored(boost) < v2882 or Boost.active(boost)
			end, 3) then
				Boost.used += 1
				Boost.text = "[USED] " .. boost .. " Boost | " .. Boost.stored(boost) .. " Left"
			else
				t1._backoff("boost:" .. boost, 30)
				Boost.text = "[REFUSED] " .. boost .. " Boost | No Change"
			end
		else
			t1._backoff("boost:" .. boost, 30)
			Boost.text = "[REFUSED] " .. boost .. " Boost | No Change"
			t1._wake("boosts")
			t1._wake("status")

			return
		end

		t1._wake("boosts")
		t1._wake("status")
	end
	t1.Crates = t1._chore("crates", {
		opened = 0
	})

	do
		t1.Items = function()
			local v2883 = t1.data()

			return v2883 and type(v2883.Items) == "table" and v2883.Items or {}
		end
	end

	t1.Crates.names = function()
		local t191 = {}
		local t192 = {}

		local function v2886(p597)
			local v2887 = p597 and tostring(p597)

			if v2887 and not (v2887 == "" or t192[v2887]) then
				t192[v2887] = true
				t191[#t191 + 1] = v2887
			end
		end

		for _, v in ipairs(t1.Sum.crates()) do
			v2886(v.Name)
		end

		for _, v in pairs(t1.Items()) do
			if type(v) == "table" and v.Type == "Crate" then
				v2886(v.Name)
			end
		end

		table.sort(t191)

		return t191
	end
	t1.Crates.run = function()
		local Crates = t1.Crates

		if not t1._lobbyGate(Crates, "AutoCrates") then
			return
		end

		if not t1._needs("CrateSelection", "Crates To Open", Crates) then
			return
		end

		local crate
		local v2894

		for k, v in pairs(t1.Items()) do
			if type(v) == "table" and v.Type == "Crate" and t1._has("CrateSelection", tostring(v.Name)) and not t1._backed("crate:" .. k) then
				crate = k
				v2894 = v

				break
			end
		end

		if not crate then
			return t1._done(Crates, "[DONE] Crates | " .. Crates.opened .. " Opened")
		end

		if t1.Space() - t1.BagCount() <= 0 then
			t1._wake("unitsell")

			return t1._done(Crates, "[FULL] Inventory | " .. t1.BagCount() .. " / " .. t1.Space())
		end

		Crates.due = true

		if not t1._delayRange("crates", t12.CrateDelay, Crates, "[DELAY] " .. tostring(v2894.Name), "AutoCrates") then
			return
		end

		local OpenCrate, v2898 = t1.invoke("OpenCrate", 10, crate, 1)

		if not OpenCrate then
			t1._backoff("crate:" .. crate, 30)
			Crates.text = "[REFUSED] " .. tostring(v2894.Name) .. " | Not Opened"
			t1._wake("crates")
			t1._wake("status")

			return
		end

		if type(v2898) == "table" and #v2898 > 0 or t1._confirm(function()
			return t1.Items()[crate] ~= v2894
		end, 2) then
			Crates.opened += 1
			Crates.text = "[OPENED] " .. tostring(v2894.Name) .. " | x1"

			if type(v2898) == "table" and not t1.net("OpenAnim") then
				pcall(t1.Hook.summons, v2898, tostring(v2894.Name))
			end

			t1._wake("equip")
		else
			t1._backoff("crate:" .. crate, 30)
			Crates.text = "[REFUSED] " .. tostring(v2894.Name) .. " | Not Opened"
		end

		t1._wake("crates")
		t1._wake("status")
	end
	t1.Pass = t1._chore("passitems", {
		used = 0
	})
	t1.Pass.products = function()
		local v2899 = t1.Cfg()

		return v2899 and type(v2899.Ids) == "table" and type(v2899.Ids.Products) == "table" and v2899.Ids.Products or {}
	end
	t1.Pass.names = function()
		local t193 = {}

		for k, v in pairs(t1.Pass.products()) do
			local v2903 = tostring(k)

			if type(v) == "table" and tonumber(v.Id) and not (v2903:find("Coins%d") or v2903:find("Gems%d") or v2903:find("Candy%d") or v2903:find("Boost") or v2903:find("CrateX") or v2903:find("SkipTier")) then
				t193[#t193 + 1] = tostring(k)
			end
		end

		table.sort(t193)

		return t193
	end
	t1.Pass.run = function()
		local Pass = t1.Pass

		if not t1._lobbyGate(Pass, "AutoPassItems") then
			return
		end

		if not t1._needs("PassItemSelection", "Pass Items", Pass) then
			return
		end

		local v2905 = Pass.products()
		local pass
		local v2907

		for k, v in pairs(t1.Items()) do
			if type(v) == "table" and v.Type ~= "Crate" and v.Type ~= "Tower" and type(v2905[v.Name]) == "table" and t1._has("PassItemSelection", v.Name) and not t1._backed("pass:" .. k) then
				pass = k
				v2907 = v

				break
			end
		end

		if not pass then
			return t1._done(Pass, "[DONE] Pass Items | " .. Pass.used .. " Used")
		end

		Pass.due = true

		if not t1._delayRange("passitems", t12.PassDelay, Pass, "[DELAY] " .. tostring(v2907.Name), "AutoPassItems") then
			return
		end

		if t1.invoke("OpenGamepass", 10, v2905[v2907.Name].Id, pass) and t1._confirm(function()
			return t1.Items()[pass] == nil
		end, 3) then
			Pass.used += 1
			Pass.text = "[USED] " .. tostring(v2907.Name)
			t1._wake("equip")
		else
			t1._backoff("pass:" .. pass, 60)
			Pass.text = "[REFUSED] " .. tostring(v2907.Name) .. " | Not Used"
		end

		t1._wake("passitems")
		t1._wake("status")
	end
	t1.Settings = t1._chore("settings", {})

	local t194 = {
		["Mute Music"] = "Music",
		["Mute Sounds"] = "Sounds",
		["Trades Off"] = "Trades",
		["VFX Off"] = "VFX"
	}

	t1.Settings.apply = function(p598, p599)
		if p598 == "Music" or p598 == "Sounds" then
			local v2911 = game:GetService("SoundService"):FindFirstChild(p598)

			if v2911 and v2911:IsA("SoundGroup") then
				pcall(function()
					v2911.Volume = p599 and 0.5 or 0
				end)
			end
		end
	end
	t1.Settings.is = function(p600, p601, p602)
		if p602 ~= "off" then
			return p601 == p602
		end

		if p600 == "Trades" then
			return type(p601) == "string" and p601 ~= "All" and p601 ~= "Friends"
		end

		return p601 == false
	end
	t1.Settings.fails = {}
	t1.Settings.drop = function(p603, p604, p605)
		local settings = t1.State.data.settings

		if p604 and not t12.GameSettings then
			local fails = t1.Settings.fails

			fails[p603] = (t1.Settings.fails[p603] or 0) + 1

			if t1.Settings.fails[p603] >= 3 then
				local fails2 = t1.Settings.fails

				settings[p603] = nil
				fails2[p603] = nil

				return
			end
		end

		t1._backoff("set:" .. p603, p605 or 10)
	end
	t1.Settings.run = function()
		local Settings = t1.Settings
		local settings = t1.State.data.settings

		t1._gateOpen.settings = next(settings) ~= nil

		local v2917 = not t12.GameSettings

		if t12.GameSettings then
			if not t1._lobbyGate(Settings, "GameSettings") then
				return
			end
		elseif next(settings) == nil then
			return t1._wake("status")
		end

		if not t1.Ctx.lobby() then
			return t1._wake("status")
		end

		local synced = tostring(t12.GameSettings)

		for _, v in ipairs(t8) do
			synced ..= t1._has("GameSettingPicks", v) and "1" or "0"
		end

		if synced == Settings.synced then
			if t12.GameSettings then
				return t1._done(Settings, Settings.text ~= "[IDLE]" and Settings.text or "[SYNCED] Game Settings")
			end

			return t1._wake("status")
		end

		local v2921 = true

		Settings.text = "[IDLE]"

		for _, v in ipairs(t8) do
			if not t12.GameSettings ~= v2917 then
				v2921 = false

				break
			end

			local set = t194[v]
			local s6

			if t12.GameSettings and t1._has("GameSettingPicks", v) then
				s6 = "off"
			end

			if s6 == nil and settings[set] ~= nil then
				s6 = settings[set]
			end

			if s6 ~= nil then
				if t1._backed("set:" .. set) then
					v2921 = false

					continue
				end
			end

			if s6 ~= nil then
				local UpdateSetting, v2927 = t1.invoke("UpdateSetting", 6, false, set)

				if UpdateSetting and v2927 ~= nil then
					if t1.Settings.is(set, v2927, s6) then
						t1.Settings.fails[set] = nil

						if s6 == settings[set] then
							settings[set] = nil
						end

						t1.Settings.apply(set, v2927)
					else
						Settings.due = true

						if s6 == "off" and settings[set] == nil then
							settings[set] = v2927
							t1._gateOpen.settings = true
							t1.State.save()
						end

						local v2928 = v2927
						local n76 = 1
						local v2930 = set == "Trades" and 3 or 1

						for i = n76, v2930 do
							local UpdateSetting2, v2933 = t1.invoke("UpdateSetting", 6, true, set)

							if UpdateSetting2 then
								v2928 = v2933

								if not t1.Settings.is(set, v2928, s6) then
									continue
								end
							end

							break
						end

						if t1.Settings.is(set, v2928, s6) then
							t1.Settings.fails[set] = nil

							if s6 ~= "off" then
								settings[set] = nil
							end

							t1.Settings.apply(set, v2928)
							Settings.text = "[SET] " .. set .. " | " .. (type(v2928) == "string" and v2928 or v2928 and "On" or "Off")
						else
							v2921 = false
							t1.Settings.drop(set, v2917, 30)
							Settings.text = "[REFUSED] " .. set .. " | No Change"
						end
					end
				else
					v2921 = false
					t1.Settings.drop(set, v2917)
				end
			end
		end

		if v2921 then
			Settings.synced = synced
		end

		t1.State.save()

		if t12.GameSettings then
			return t1._done(Settings, Settings.text ~= "[IDLE]" and Settings.text or "[SYNCED] Game Settings")
		end

		t1._wake("status")
	end
	t1.BP = {
		sig = nil
	}
	t1.BP.data = function()
		local v2934 = t1.data()

		return v2934 and type(v2934.Battlepass) == "table" and v2934.Battlepass or nil
	end
	t1.BP.tiers = function()
		local v2935 = t1.Cfg()
		local Battlepass = v2935 and type(v2935.Battlepass) == "table" and v2935.Battlepass

		return Battlepass and type(Battlepass.Tiers) == "table" and Battlepass.Tiers or {}
	end
	t1.BP.tier = function(p606)
		for _, v in pairs(t1.BP.tiers()) do
			if type(v) == "table" and tonumber(v.TierNumber) == p606 then
				return v
			end
		end

		return nil
	end
	t1.BP.maxTier = function()
		local n77 = 0

		for _, v in pairs(t1.BP.tiers()) do
			if type(v) == "table" then
				n77 = math.max(n77, t1._n(v.TierNumber))
			end
		end

		return n77
	end
	t1.BP.claimed = function(p607, p608, p609)
		local ClaimedTiers = type(p607.ClaimedTiers) == "table" and p607.ClaimedTiers or {}
		local Premium

		if p609 then
			Premium = ClaimedTiers.Premium or p607.ClaimedPremiumTiers
		else
			Premium = ClaimedTiers.Default or ClaimedTiers
		end

		return type(Premium) == "table" and (Premium[p608] == true or Premium[tostring(p608)] == true)
	end
	t1.BP.next = function()
		local v2944 = t1.BP.data()

		if not v2944 then
			return nil
		end

		if t1._has("PassTracks", "Free") then
			local v2945 = tonumber(v2944.NextTier) or t1._n(v2944.CurrentTier) + 1
			local v2946 = t1.BP.tier(v2945)

			if v2946 then
				local v2947 = t1._n(v2944.EXP)

				if t1._n(v2946.TierEXP, math.huge) <= v2947 and not (t1.BP.claimed(v2944, v2945, false) or t1._backed("tier:" .. v2945 .. ":free")) then
					return v2945, false
				end
			end
		end

		if t1._has("PassTracks", "Premium") and v2944.Premium == true then
			for i = 1, t1._n(v2944.CurrentTier) do
				if t1.BP.tier(i) and not t1.BP.claimed(v2944, i, true) then
					if t1._backed("tier:" .. i .. ":premium") then
						continue
					end

					return i, true
				end
			end
		end

		return nil
	end
	t1.Tier = t1._chore("passtiers", {
		got = 0
	})
	t1.Tier.idle = function(p610)
		local v2949 = t1._n(p610.CurrentTier)
		local v2950 = t1.BP.maxTier()

		if v2950 > 0 and v2950 <= v2949 then
			return "[DONE] Pass Tiers | Tier " .. v2949 .. " Max"
		end

		if t1._has("PassTracks", "Free") then
			local v2951 = tonumber(p610.NextTier) or v2949 + 1
			local v2952 = t1.BP.tier(v2951)

			if v2952 then
				return "[WAITING] Awaiting XP | Tier " .. v2951 .. " " .. t1._num(t1._n(p610.EXP)) .. " / " .. t1._num(t1._n(v2952.TierEXP))
			end
		end

		if p610.Premium == true then
			return "[DONE] Pass Tiers | " .. t1.Tier.got .. " Claimed"
		end

		return "[WAITING] Awaiting Premium | Pass Requirement"
	end
	t1.Tier.run = function()
		local Tier = t1.Tier

		if not t1._lobbyGate(Tier, "AutoPassTiers") then
			return
		end

		if not t1._needs("PassTracks", "Tracks", Tier) then
			return
		end

		local v2954 = t1.BP.data()

		if not v2954 then
			return t1._done(Tier, "[WAITING] Awaiting Data | Battlepass")
		end

		local v2955, v2956 = t1.BP.next()

		if not v2955 then
			return t1._done(Tier, Tier.idle(v2954))
		end

		Tier.due = true

		local v2957 = "Tier " .. v2955 .. " | " .. (v2956 and "Premium" or "Free")

		if not t1._delayRange("passtiers", t12.PassTierDelay, Tier, "[DELAY] " .. v2957, "AutoPassTiers") then
			return
		end

		if not t12.AutoPassTiers then
			return
		end

		Tier.text = "[CLAIMING] " .. v2957
		t1._wake("status")

		local ClaimTier = t1.invoke("ClaimTier", 8, v2955, v2956)

		if ClaimTier and t1._confirm(function()
			local v2959 = t1.BP.data()

			return v2959 and (t1.BP.claimed(v2959, v2955, v2956) or not v2956 and t1._n(v2959.NextTier) > v2955)
		end, 5) then
			Tier.got += 1
			Tier.text = "[CLAIMED] " .. v2957
		else
			t1._backoff("tier:" .. v2955 .. (v2956 and ":premium" or ":free"), 60)
			Tier.text = "[REFUSED] " .. v2957 .. " | " .. (ClaimTier and "Not Claimed" or "Not Sent")
		end

		t1._wake("passtiers")
		t1._wake("status")
	end
	t1.PQ = t1._chore("passquests", {
		got = 0,
		pushed = nil,
		pushedAt = 0
	})
	t1.PQ.list = function()
		local pushed = t1.PQ.pushed

		if not pushed or not (os.clock() - t1.PQ.pushedAt < 5) then
			local v2961 = t1.BP.data()

			pushed = v2961 and v2961.PassQuests
		end

		return type(pushed) == "table" and type(pushed.Quests) == "table" and pushed.Quests or {}
	end
	t1.PQ.find = function(p611)
		for _, v in pairs(t1.PQ.list()) do
			if type(v) == "table" and v.Id ~= nil then
				if p611 ~= nil then
					if tostring(v.Id) == tostring(p611) then
						return v
					end

					continue
				end

				if v.State ~= "Completed" or v.RewardClaimed or t1._backed("pq:" .. tostring(v.Id)) then
					continue
				end

				local match = tostring(v.Id):match("^%a+")
				local ipairs_ = ipairs
				local PassChains = type(t12.PassChains) == "table" and t12.PassChains or {}

				for _, PassChain in ipairs_(PassChains) do
					if tostring(PassChain):match("^%a+") == match then
						return v
					end
				end
			end
		end

		return nil
	end
	t1.PQ.run = function()
		local PQ = t1.PQ

		if not t1._lobbyGate(PQ, "AutoPassQuests") then
			return
		end

		if not t1._needs("PassChains", "Quest Lines", PQ) then
			return
		end

		local v2970 = PQ.find()

		if not v2970 then
			return t1._done(PQ, "[DONE] Pass Quests | " .. PQ.got .. " Claimed")
		end

		PQ.due = true

		local Id = v2970.Id
		local v2972 = tostring(v2970.Name or t1.Quest.label(Id))

		if not t1._delayRange("passquests", t12.PassQuestDelay, PQ, "[DELAY] " .. v2972, "AutoPassQuests") then
			return
		end

		if not t12.AutoPassQuests then
			return
		end

		PQ.text = "[CLAIMING] " .. v2972
		t1._wake("status")

		local CollectPassQuest, v2974 = t1.invoke("CollectPassQuest", 8, Id)

		if CollectPassQuest and (v2974 or t1._confirm(function()
			local v2975 = PQ.find(Id)

			return not v2975 or v2975.RewardClaimed == true
		end, 3)) then
			PQ.got += 1
			PQ.text = "[CLAIMED] " .. v2972 .. (tonumber(v2970.Currency) and " | +" .. t1._num(v2970.Currency) .. " Candy" or "")
			t1._backoff("pq:" .. tostring(Id), 10)
		else
			t1._backoff("pq:" .. tostring(Id), 60)
			PQ.text = "[REFUSED] " .. v2972 .. " | " .. (CollectPassQuest and "Not Claimed" or "Not Sent")
		end

		t1._wake("passquests")
		t1._wake("status")
	end

	do
		t1._wakeHandlers.passdata = function()
			t1._signal("data")

			local v2976 = t1.BP.data()

			if not v2976 then
				return
			end

			if t12.AutoPassTiers then
				local sig = tostring(v2976.CurrentTier) .. ":" .. tostring(v2976.NextTier) .. ":" .. tostring(v2976.EXP) .. ":" .. tostring(v2976.Premium)

				if sig ~= t1.BP.sig then
					t1.BP.sig = sig
					t1._wake("passtiers")
				end
			end

			if t12.AutoPassQuests and t1.PQ.find() then
				t1._wake("passquests")
			end
		end
	end

	t1.Shop = t1._chore("crateshop", {
		bought = 0,
		cap = {}
	})

	do
		t1.Shop.crates = function()
			local t195 = {}
			local ShopCrates = t1.gameSettings().ShopCrates
			local v2980 = type(ShopCrates) == "table" and ShopCrates or {}

			for _, v in pairs(v2980) do
				local Price = type(v) == "table" and v.IsRobux ~= true and v.Name ~= nil and v.Price

				if type(Price) == "table" and type(Price.Type) == "string" and t1._n(Price.Amount) > 0 then
					t195[#t195 + 1] = v
				end
			end

			table.sort(t195, function(p612, p613)
				return tostring(p612.Name) < tostring(p613.Name)
			end)

			return t195
		end
	end

	t1.Shop.names = function()
		local t196 = {}

		for _, v in ipairs(t1.Shop.crates()) do
			t196[#t196 + 1] = tostring(v.Name)
		end

		return t196
	end
	t1.Shop.spendable = function(p614)
		local ShopKeepGems = p614 == "Gems" and t12.ShopKeepGems or p614 == "Candy" and t12.ShopKeepCandy or 0

		return t1._n(t1.data()[p614]) - t1._n(ShopKeepGems)
	end
	t1.Shop.run = function()
		local Shop = t1.Shop

		if not t1._lobbyGate(Shop, "AutoCrateShop") then
			return
		end

		if not t1._needs("ShopCrates", "Crates", Shop) then
			return
		end

		local v2989
		local v2990
		local v2991

		for _, v in ipairs(Shop.crates()) do
			local shop = tostring(v.Name)

			if t1._has("ShopCrates", shop) and not t1._backed("shop:" .. shop) then
				local v2995 = t1._n(v.Price.Amount)
				local v2996 = Shop.spendable(v.Price.Type)
				local v2997 = math.min(math.floor(v2996 / v2995), Shop.cap[shop] or 10)

				if v2997 >= 1 then
					v2990 = v2997 >= 10 and 10 or v2997 >= 3 and 3 or 1
					v2989 = v

					break
				else
					v2991 = v2991 or tostring(v.Price.Type) .. " | " .. t1._num(math.max(0, v2996)) .. " / " .. t1._num(v2995)
				end
			end
		end

		if not v2989 then
			local _done = t1._done
			local v2999 = Shop
			local v3000 = v2991 and "[WAITING] Awaiting " .. v2991 or "[DONE] Crate Shop | " .. Shop.bought .. " Bought"

			return _done(v2999, v3000)
		end

		Shop.due = true

		local shop = tostring(v2989.Name)
		local v3002 = tostring(v2989.Price.Type)

		if not t1._delayRange("crateshop", t12.ShopDelay, Shop, "[DELAY] " .. shop, "AutoCrateShop") then
			return
		end

		if not t12.AutoCrateShop then
			return
		end

		local v3003 = t1._n(t1.data()[v3002])

		Shop.text = "[BUYING] " .. shop .. " | x" .. v2990
		t1._wake("status")

		local BuyCrate = t1.fire("BuyCrate", shop, v2990)

		if BuyCrate and t1._confirm(function()
			local v3005 = t1.data()

			return v3005 and t1._n(v3005[v3002]) < v3003
		end, 5) then
			Shop.bought += v2990
			Shop.text = "[BOUGHT] " .. shop .. " | x" .. v2990
			t1._wake("crates")
		elseif BuyCrate and v2990 > 1 then
			Shop.cap[shop] = v2990 == 10 and 3 or 1
			t1._backoff("shop:" .. shop, 2)
			Shop.text = "[REFUSED] " .. shop .. " | x" .. v2990 .. " Not Offered"
		else
			t1._backoff("shop:" .. shop, 30)
			Shop.text = "[REFUSED] " .. shop .. " | " .. (BuyCrate and "Not Bought" or "Not Sent")
		end

		t1._wake("crateshop")
		t1._wake("status")
	end
	t1.MM = {
		st = {
			queued = false,
			revision = -1
		},
		at = 0,
		map = nil
	}
	t1.MM.SIZES = {
		Duo = "duo",
		Trio = "trio",
		Quad = "quad"
	}
	t1.MM.CAP = {
		Duo = 2,
		Trio = 3,
		Quad = 4
	}
	t1.MM.LABELS = {
		PARTY_FULL = "Party Full",
		QUEUE_EXPIRED = "No Match Found",
		INVALID_SELECTION = "Map Requirement",
		PROFILE_LOADING = "Profile Loading",
		PARTY_TOO_LARGE = "Party Size",
		JOIN_FAILED = "Join Failed",
		PARTY_BUSY = "Party Busy",
		TELEPORT_FAILED = "Teleport Failed",
		BUSY = "Rate Limit",
		RATE_LIMIT = "Rate Limit",
		LEADER_ONLY = "Leader Requirement",
		PARTY_CHANGED = "Party Changed"
	}
	t1.MM.apply = function(p615)
		if type(p615) ~= "table" then
			return
		end

		local v3006 = tonumber(p615.revision)

		if v3006 then
			if v3006 < t1._n(t1.MM.st.revision, -1) then
				return
			end
		end

		local MM = t1.MM
		local MM2 = t1.MM
		local now = os.clock()

		MM.st = p615
		MM2.at = now
	end

	do
		t1.MM.refresh = function()
			local MatchStatus, v3011 = t1.invoke("MatchStatus", 6)

			if MatchStatus and type(v3011) == "table" then
				t1.MM.apply(v3011)
			end
		end
	end

	t1.MM.maps = function()
		local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		local v3013 = PlayerGui and t1._at(PlayerGui, "Main.Main.Matchmaking.MatchmakingFrame.Maps")
		local t197 = {}
		local children = v3013 and v3013:GetChildren() or {}

		for _, child in ipairs(children) do
			if child:IsA("GuiButton") then
				t197[#t197 + 1] = child.Name
			end
		end

		table.sort(t197)

		return t197
	end

	do
		t1.MM.pickMap = function()
			local v3018 = t1.MM.maps()

			if table.find(v3018, t12.JoinMap) then
				return t12.JoinMap
			end

			if t12.JoinMap == "Any Map" then
				return v3018[1]
			end

			return nil
		end
	end

	do
		t1.MM.leader = function()
			local party = t1.MM.st.party

			return not (type(party) == "table" and party.leader) or tostring(party.leader) == tostring(LocalPlayer.UserId)
		end
	end

	t1.MM.members = function()
		local party = t1.MM.st.party

		return type(party) == "table" and type(party.members) == "table" and math.max(1, #party.members) or 1
	end
	t1.MM.label = function(p616)
		local v3021 = tostring(p616 or "")
		local v3022 = t1.MM.LABELS[v3021] or v3021:lower():gsub("_", " "):gsub("(%a)(%w*)", function(p617, p618)
			return p617:upper() .. p618
		end)

		return v3022
	end
	t1.MM.run = function(p619)
		local MM = t1.MM

		t1.Move.drop("queue")

		if os.clock() - MM.at > 30 then
			MM.refresh()
		end

		local st = MM.st
		local MatchSize = MM.SIZES[t12.MatchSize] and t12.MatchSize or "Duo"

		if st.teleporting then
			p619.text = "[TELEPORTING] Match | Matchmaking"

			return t1._wake("status")
		end

		if st.queued then
			p619.text = "[QUEUED] Matchmaking | " .. MatchSize .. ", " .. tostring(MM.map or t12.JoinMap)
			t1._alarm("queue", 30, "queue:mm")

			return t1._wake("status")
		end

		if not MM.leader() then
			p619.text = "[WAITING] Awaiting Leader | Party Leader Queues"

			return t1._wake("status")
		end

		local v3026 = p619.due()

		if v3026 then
			p619.text = "[WAITING] Awaiting Errands | " .. v3026

			return t1._wake("status")
		end

		if MM.CAP[MatchSize] < MM.members() then
			p619.text = "[REFUSED] Matchmaking | Party Size " .. MM.members() .. " / " .. MM.CAP[MatchSize]

			return t1._wake("status")
		end

		local v3027 = MM.pickMap()

		if not v3027 then
			p619.text = "[WAITING] Awaiting Map | " .. t12.JoinMap .. " Not In Matchmaking"
			t1._alarm("queue", 15, "queue:mm")

			return t1._wake("status")
		end

		if t1._backed("mm") then
			return t1._wake("status")
		end

		if not t1._delayRange("join", t12.JoinDelay, p619, "[DELAY] " .. v3027, "AutoJoin") then
			return
		end

		if not t12.AutoJoin or t12.JoinBy ~= "Matchmaking" or not t1.Ctx.lobby() then
			return t1._wake("queue")
		end

		p619.text = "[JOINING] Matchmaking | " .. MatchSize .. ", " .. v3027
		t1._wake("status")

		local MatchJoinQueue, v3029, v3030 = t1.invoke("MatchJoinQueue", 8, MM.SIZES[MatchSize], v3027)

		if MatchJoinQueue and type(v3029) == "table" then
			MM.apply(v3029)
		end

		local message = type(v3029) == "table" and v3029.message or (not MatchJoinQueue or v3029 == nil) and (v3030 or "JOIN_FAILED") or nil

		if MatchJoinQueue and type(v3029) == "table" and v3029.queued and not v3029.message then
			MM.map = v3027
			p619.text = "[QUEUED] Matchmaking | " .. MatchSize .. ", " .. v3027
		else
			t1._backoff("mm", message == "QUEUE_EXPIRED" and 2 or 10)
			p619.text = "[REFUSED] Matchmaking | " .. MM.label(message or "JOIN_FAILED")
		end

		t1._wake("queue")
		t1._wake("status")
	end
	t1.MM.leave = function()
		local MM = t1.MM

		if MM.leaving or not MM.st.queued or MM.st.teleporting then
			return
		end

		MM.leaving = true

		local ok, result, result2 = pcall(t1.invoke, "MatchLeaveQueue", 6)

		MM.leaving = false

		if ok and result and type(result2) == "table" then
			MM.apply(result2)
		end
	end
	t1.Queue = {
		text = "[IDLE]",
		inside = nil,
		leader = false,
		startAt = 0
	}
	t1.Queue.parts = function(p620)
		local function v3036(p621)
			local v3037 = p620:FindFirstChild(p621)
			local isBasePart = v3037 and v3037:IsA("BasePart") and v3037

			return isBasePart or nil
		end

		local Area = v3036("Area") or v3036("Hitbox") or p620:FindFirstChildWhichIsA("BasePart")
		local Hitbox = v3036("Hitbox") or p620:FindFirstChildWhichIsA("BasePart")

		if not Area or not Hitbox then
			return nil
		end

		local Position = Area.Position

		for _, v in ipairs({
			Area.Position,
			Hitbox.Position
		}) do
			if t1.Queue.inBox(Area, v) and t1.Queue.inBox(Hitbox, v) then
				Position = v

				break
			end
		end

		return Area, Position
	end

	do
		t1.Queue.list = function()
			local t198 = {}
			local Elevators = workspace:FindFirstChild("Elevators")
			local children = Elevators and Elevators:GetChildren() or {}

			for _, child in ipairs(children) do
				local v3049
				local v3050

				if child:IsA("Model") then
					v3049, v3050 = t1.Queue.parts(child)
				end

				if v3049 then
					t198[#t198 + 1] = {
						name = child.Name,
						model = child,
						box = v3049,
						spot = v3050,
						players = t1._n(child:GetAttribute("Players")),
						max = t1._n(child:GetAttribute("MaxPlayers"), 5),
						map = tostring(child:GetAttribute("Map") or "")
					}
				end
			end

			table.sort(t198, function(p622, p623)
				return p622.name < p623.name
			end)

			return t198
		end
	end

	t1.Queue.mapNames = function()
		local t199 = {}

		for _, v in ipairs(t1.Queue.list()) do
			if not (v.map == "" or v.map == "0" or table.find(t199, v.map)) then
				t199[#t199 + 1] = v.map
			end
		end

		if #t199 == 0 then
			t199 = table.clone(t19)
		end

		table.sort(t199)

		return t199
	end
	t1.Queue.choose = function()
		local v3054

		for _, v in ipairs(t1.Queue.list()) do
			local v3057 = t12.JoinMap == "Any Map" or v.map == t12.JoinMap
			local v3058 = t1.Queue.solo() and v.players == 0 or v.players < v.max

			if v3057 and v3058 and not t1._backed("elev:" .. v.name) and (not v3054 or not t1.Queue.solo() and v3054.players < v.players) then
				v3054 = v
			end
		end

		return v3054
	end

	do
		t1.Queue.solo = function()
			return t12.JoinParty == "Solo" or t12.PartyRole == "Host"
		end
	end
end

t1.Queue.mods = function()
	local t200 = {}
	local Modifiers = t1.gameSettings().Modifiers
	local v3061 = type(Modifiers) == "table" and Modifiers or {}

	for k, v in pairs(v3061) do
		if type(k) == "string" then
			t200[#t200 + 1] = {
				key = k,
				name = type(v) == "table" and type(v.Name) == "string" and v.Name or k
			}
		end
	end

	table.sort(t200, function(p624, p625)
		return p624.name < p625.name
	end)

	return t200
end

do
	t1.Queue.modNames = function()
		local t201 = {}

		for _, v in ipairs(t1.Queue.mods()) do
			t201[#t201 + 1] = v.name
		end

		return t201
	end
end

t1.Queue.setMods = function()
	local Queue = t1.Queue
	local t202 = {}
	local v3069 = t1._set(t12.JoinModifiers)

	for _, v in ipairs(Queue.mods()) do
		if v3069[v.name] and #t202 < 4 then
			t202[#t202 + 1] = v.key
		end
	end

	local mods = Queue.inside .. "|" .. table.concat(t202, ",")

	if Queue.modSig == mods or #t202 == 0 and Queue.modSig == nil then
		return
	end

	if t1._backed("mods:" .. mods) then
		return
	end

	local ElevatorSetModifiers, v3074 = t1.invoke("ElevatorSetModifiers", 6, Queue.inside, t202)

	if ElevatorSetModifiers and v3074 ~= false then
		Queue.modSig = mods
	else
		t1._backoff("mods:" .. mods, 15)
	end
end
t1.Queue.due = function()
	for _, chore in ipairs(t1.Chores) do
		if chore.T.due and t12[t15[chore.name]] then
			if t1._backed(chore.name) then
				continue
			end

			return t1.Lease.LABEL[chore.name] or chore.name
		end
	end

	return nil
end
t1.Queue.adopt = function(p626)
	local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local ElevatorGui = PlayerGui and PlayerGui:FindFirstChild("ElevatorGui")
	local QueueFrame = ElevatorGui and ElevatorGui:FindFirstChild("QueueFrame")

	if not QueueFrame or not QueueFrame.Visible or t1.Queue.inside then
		return
	end

	local MapName = QueueFrame:FindFirstChild("MapName")

	for _, v in ipairs(t1.Queue.list()) do
		if t1.Queue.inBox(v.box) and (not MapName or not MapName:IsA("TextLabel") or MapName.Text == v.map) then
			local ReadyButton = QueueFrame:FindFirstChild("ReadyButton")
			local Queue = t1.Queue
			local Queue2 = t1.Queue
			local name = v.name
			local Visible = ReadyButton ~= nil and ReadyButton:IsA("GuiObject") and ReadyButton.Visible

			Queue.inside = name
			Queue2.leader = Visible
			t1.Queue.joined = v.name

			if not p626 then
				t1._wake("queue")
			end

			return true
		end
	end
end

do
	t1.Queue.inBox = function(p627, p628)
		if not p628 then
			local v3088 = t1._hrp()

			p628 = v3088 and v3088.Position
		end

		if not p628 or not p627 or not p627.Parent then
			return false
		end

		local v3089 = p627.CFrame:PointToObjectSpace(p628)
		local v3090 = p627.Size * 0.5

		return math.abs(v3089.X) <= v3090.X and math.abs(v3089.Y) <= v3090.Y and math.abs(v3089.Z) <= v3090.Z
	end
end

t1.Queue.run = function()
	local Queue = t1.Queue

	if not t12.AutoJoin then
		t1.Move.drop("queue")
		t1.MM.leave()

		return t1._wake("status")
	end

	local v3092 = t1.Ctx.place()

	if v3092 == "TELEPORTING" then
		Queue.text = "[TELEPORTING] Match"

		return t1._wake("status")
	end

	if v3092 ~= "LOBBY" then
		Queue.text = "[WAITING] Awaiting Lobby"
		t1.Move.drop("queue")

		return t1._wake("status")
	end

	if t1.Party.following() then
		Queue.text = "[FOLLOWING] Host | Alt Farm Joins The Host's Elevator"
		t1.Move.drop("queue")
		t1.MM.leave()

		return t1._wake("status")
	end

	local v3093 = t1.End.goal()

	if v3093 then
		t1.Move.drop("queue")
		t1.MM.leave()

		if t12.StopAction == "Close Game" then
			return t1.End.close(v3093)
		end

		Queue.text = "[DONE] Session Goal | " .. v3093

		return t1._wake("status")
	end

	if t12.JoinBy == "Matchmaking" and t12.PartyRole == "Off" and not Queue.inside then
		return t1.MM.run(Queue)
	end

	if t1.MM.st.queued and not t1.MM.st.teleporting then
		t1.MM.leave()
	end

	if Queue.inside then
		local QueueInside = workspace:FindFirstChild("Elevators") and workspace.Elevators:FindFirstChild(Queue.inside)
		local v3095
		local v3096

		if QueueInside then
			v3095, v3096 = Queue.parts(QueueInside)
		end

		if not v3095 then
			Queue.inside = nil
			Queue.modSig = nil

			return t1._wake("queue")
		end

		if not Queue.inBox(v3095) and t1.Move.lease("queue") then
			t1.Move.to(v3096 - Vector3.new(0, 3, 0))
		end

		local v3097 = tostring(QueueInside:GetAttribute("Map") or "")

		if Queue.joined == Queue.inside and t12.JoinMap ~= "Any Map" and v3097 ~= "" and v3097 ~= t12.JoinMap and t1.Move.lease("queue") then
			local inside = Queue.inside

			Queue.text = "[LEAVING] " .. v3097
			t1._wake("status")
			t1.Move.to((v3095.CFrame * CFrame.new(0, 0, v3095.Size.Z * 0.5 + 6)).Position - Vector3.new(0, 3, 0))
			t1.invoke("ElevatorLeave", 6, inside)
			t1._awaitEvent("elevator", function()
				return Queue.inside ~= inside
			end, 3)
			Queue.joined = nil
			t1.Move.drop("queue")

			return t1._wake("queue")
		end

		local v3099 = t1._n(QueueInside:GetAttribute("Players"))
		local v3100 = t1._n(QueueInside:GetAttribute("MaxPlayers"), 5)

		if Queue.leader then
			Queue.setMods()
		end

		if not Queue.inside then
			return t1._wake("queue")
		end

		Queue.text = "[QUEUED] " .. tostring(QueueInside:GetAttribute("Map") or Queue.inside) .. " | " .. v3099 .. " / " .. v3100 .. " Players, " .. t1._n(QueueInside:GetAttribute("Time")) .. "s"

		local leader = Queue.leader and t1.Party.hold(v3095)

		if Queue.leader and Queue.solo() and not leader and Queue.startAt <= os.clock() then
			Queue.startAt = os.clock() + 5
			t1.invoke("ElevatorStart", 6, Queue.inside)
		end

		if Queue.leader and Queue.solo() and not leader then
			t1._alarm("queue", 5, "queue:hold")
		end

		return t1._wake("status")
	end

	t1.Party.holdSince = nil

	local v3102 = Queue.due()

	if v3102 then
		Queue.text = "[WAITING] Awaiting Errands | " .. v3102
		t1.Move.drop("queue")

		return t1._wake("status")
	end

	local v3103 = Queue.choose()

	if not v3103 then
		Queue.text = "[WAITING] Awaiting Elevator | " .. (Queue.solo() and "Empty " or "") .. t12.JoinMap
		t1._alarm("queue", 15, "queue:none")
		t1.Move.drop("queue")

		return t1._wake("status")
	end

	if not t1._delayRange("join", t12.JoinDelay, Queue, "[DELAY] " .. v3103.map, "AutoJoin") then
		return
	end

	if not t12.AutoJoin or not t1.Ctx.lobby() then
		return
	end

	if not t1.Move.lease("queue") then
		Queue.text = t1.Move.busyText()

		return t1._wake("status")
	end

	Queue.text = "[JOINING] " .. (v3103.map ~= "" and v3103.map or v3103.name)
	t1._wake("status")
	t1.Move.to(v3103.spot - Vector3.new(0, 3, 0))

	local function v3104()
		Queue.adopt(true)

		return Queue.inside ~= nil
	end

	local elevator = t1._awaitEvent("elevator", v3104, 1)

	if not elevator then
		local ElevatorEnter, v3107 = t1.invoke("ElevatorEnter", 6, v3103.name)

		if ElevatorEnter and v3107 and not Queue.inside then
			Queue.inside = v3103.name
		end

		elevator = t1._awaitEvent("elevator", v3104, 2)
	end

	if elevator then
		Queue.joined = Queue.inside
	end

	if not elevator then
		t1._backoff("elev:" .. v3103.name, 10)
		Queue.text = "[REFUSED] " .. v3103.name .. " | Not Entered"
		t1.Move.drop("queue")
	end

	t1._wake("queue")
	t1._wake("status")
end
t1.Rank = t1._chore("ranks", {
	got = 0
})

do
	t1.Rank.list = function()
		local t203 = {}
		local PathHonor = t1.gameSettings().PathHonor
		local v3110 = type(PathHonor) == "table" and PathHonor or {}

		for k, v in pairs(v3110) do
			if type(v) == "table" then
				t203[#t203 + 1] = {
					name = tostring(k),
					exp = t1._n(v.RequiredEXP),
					rewards = v.Rewards
				}
			end
		end

		table.sort(t203, function(p629, p630)
			if p629.exp == p630.exp then
				return p629.name < p630.name
			end

			return p629.exp < p630.exp
		end)

		return t203
	end
end

t1.Rank.names = function()
	local t204 = {}

	for _, v in ipairs(t1.Rank.list()) do
		if type(v.rewards) == "table" and next(v.rewards) ~= nil then
			t204[#t204 + 1] = v.name
		end
	end

	return t204
end
t1.Rank.data = function()
	local v3116 = t1.data()
	local v3117 = v3116 and type(v3116.Ranks) == "table"

	return v3117 and v3116.Ranks or nil
end
t1.Rank.claimed = function(p631, p632)
	return type(p631.ClaimedRanks) == "table" and p631.ClaimedRanks[p632] == true
end

do
	t1.Rank.next = function(p633)
		local OwnedRanks = type(p633.OwnedRanks) == "table" and p633.OwnedRanks or {}

		for _, v in ipairs(t1.Rank.list()) do
			if OwnedRanks[v.name] and t1._has("RankSelection", v.name) and not t1.Rank.claimed(p633, v.name) and type(v.rewards) == "table" and next(v.rewards) ~= nil and not t1._backed("rank:" .. v.name) then
				return v
			end
		end

		return nil
	end
end

t1.Rank.run = function()
	local Rank = t1.Rank

	if not t1._lobbyGate(Rank, "AutoRanks") then
		return
	end

	if not t1._needs("RankSelection", "Rank Rewards", Rank) then
		return
	end

	local v3122 = t1.Rank.data()

	if not v3122 then
		return t1._done(Rank, "[WAITING] Awaiting Data | Ranks")
	end

	local v3123 = t1.Rank.next(v3122)

	if not v3123 then
		local _done = t1._done
		local v3125 = Rank
		local tostring_ = tostring
		local CurrentRank = v3122.CurrentRank or "Unranked"

		return _done(v3125, "[DONE] Rank Rewards | " .. tostring_(CurrentRank) .. ", " .. Rank.got .. " Claimed")
	end

	Rank.due = true

	local v3128 = "Rank " .. v3123.name

	if not t1._delayRange("ranks", t12.RankDelay, Rank, "[DELAY] " .. v3128, "AutoRanks") then
		return
	end

	if not t12.AutoRanks then
		return
	end

	Rank.text = "[CLAIMING] " .. v3128
	t1._wake("status")

	local ClaimRankReward = t1.fire("ClaimRankReward", v3123.name)

	if ClaimRankReward and t1._confirm(function()
		local v3130 = t1.Rank.data()

		return v3130 and t1.Rank.claimed(v3130, v3123.name)
	end, 5) then
		Rank.got += 1
		Rank.text = "[CLAIMED] " .. v3128
	else
		t1._backoff("rank:" .. v3123.name, 60)
		Rank.text = "[REFUSED] " .. v3128 .. " | " .. (ClaimRankReward and "Not Claimed" or "Not Sent")
	end

	t1._wake("ranks")
	t1._wake("status")
end
t1.Medal = t1._chore("medal", {
	sent = false
})
t1.Medal.run = function()
	local Medal = t1.Medal

	if not t1._lobbyGate(Medal, "AutoMedal") then
		return
	end

	if not t1._needs("MedalSelection", "Medal Reward", Medal) then
		return
	end

	if Medal.sent then
		return t1._done(Medal, "[DONE] Medal Reward | Claimed This Server")
	end

	if not t1.net("Medal") then
		return t1._done(Medal, "[UNAVAILABLE] Medal Reward | No Medal Remote")
	end

	Medal.due = true

	if not t1._delayRange("medal", t12.MedalDelay, Medal, "[DELAY] Medal Reward", "AutoMedal") then
		return
	end

	if not t12.AutoMedal then
		return
	end

	Medal.text = "[CLAIMING] Medal Reward"
	t1._wake("status")

	if t1.fire("Medal") then
		Medal.sent = true
		t1._done(Medal, "[CLAIMED] Medal Reward | Claim Sent")
	else
		t1._backoff("medal", 30)
		t1._done(Medal, "[REFUSED] Medal Reward | Not Sent")
		t1._alarm("medal", 30, "medal:retry")
	end
end
t1.leaveMatch = function()
	if t1.Ctx.leaving then
		return true
	end

	if t1.fire("OnLeave") and t1._confirm(function()
		return t1.Ctx.leaving
	end, 5) then
		return true
	end

	pcall(TeleportService.Teleport, TeleportService, 132929771812494, LocalPlayer)

	local v3132 = t1._confirm(function()
		return t1.Ctx.leaving
	end, 8) and true or false

	return v3132
end
t1.Leave = {
	text = "[IDLE]",
	players = 0
}

do
	t1.Leave.bossProgress = function()
		local n78 = 0

		for _, v in ipairs(t1.Match.enemies()) do
			if v.boss then
				local v3136 = t1._n(t1.Target.progress(v))

				if n78 < v3136 then
					n78 = v3136
				end
			end
		end

		return math.floor(n78 * 100 + 0.5)
	end
end

do
	t1.Leave.why = function()
		local Leave = t1.Leave
		local v3138 = t1.Match.waves()
		local v3139 = #Players:GetPlayers()

		Leave.players = math.max(Leave.players, v3139)

		if t12.LeaveAtWave and t1._n(t12.LeaveWave) > 0 and t1._n(t12.LeaveWave) <= v3138 then
			return "Wave " .. v3138
		end

		if not t12.EmergencyLeave then
			return nil
		end

		local v3140 = math.floor(t1.Match.base() * 100 + 0.5)

		if t1._has("LeaveActions", "Base Health Below") and v3140 < t1._n(t12.LeaveBaseHP) then
			return "Base " .. v3140 .. "%"
		end

		if t1._has("LeaveActions", "Boss Path Progress") then
			local v3141 = Leave.bossProgress()

			if t1._n(t12.LeaveBossPath, 80) <= v3141 then
				return "Boss At " .. v3141 .. "% Path"
			end
		end

		if t1._has("LeaveActions", "Players Left") and v3139 < Leave.players then
			return "Players " .. v3139 .. " / " .. Leave.players
		end

		return nil
	end
end

t1.Leave.run = function()
	local Leave = t1.Leave

	if not (t12.EmergencyLeave or t12.LeaveAtWave) then
		Leave.text = "[IDLE]"

		return t1._wake("status")
	end

	local v3143 = t1.Ctx.place()

	if v3143 == "TELEPORTING" then
		Leave.text = "[TELEPORTING] Lobby"

		return t1._wake("status")
	end

	if v3143 == "RESULTS" then
		Leave.text = "[WAITING] Awaiting Results | Match End"

		return t1._wake("status")
	end

	if v3143 ~= "MATCH" then
		Leave.text = "[WAITING] Awaiting Match"

		return t1._wake("status")
	end

	local v3144 = Leave.why()

	if not v3144 then
		if t12.EmergencyLeave and t1._has("LeaveActions", "Boss Path Progress") and t1.Match.boss() then
			t1._alarm("eleave", 1, "eleave:boss")
		end

		local v3145 = t1.Match.waves()

		Leave.text = "[WATCHING] Base " .. math.floor(t1.Match.base() * 100 + 0.5) .. "% | Wave " .. v3145 .. (t12.LeaveAtWave and " / " .. t1._n(t12.LeaveWave) or "")

		return t1._wake("status")
	end

	if t1._backed("eleave") then
		return t1._wake("status")
	end

	Leave.text = "[LEAVING] " .. v3144 .. " | Lobby"
	t1._wake("status")

	if t1.leaveMatch() then
		Leave.text = "[DONE] Left | " .. v3144
	else
		t1._backoff("eleave", 5)
		Leave.text = "[RETRYING] Leave | No Teleport"
	end

	t1._wake("status")
end
t1.Ability = {
	text = "[IDLE]",
	cd = {},
	n = 0,
	tried = {},
	best = {}
}

do
	t1.Ability.info = function(p634)
		local v3146 = t1.towerCfg(p634)
		local Ability = v3146 and v3146.Ability

		return type(Ability) == "table" and Ability.Relocate == true and Ability or nil
	end
end

t1.Ability.gate = function(p635)
	local v3148 = t1.Slots.byName(p635)
	local v3149 = v3148 and t12["SlotAbility" .. tostring(v3148.slot)] or "Ability Actions"

	if v3149 == "Off" then
		return false, "Slot Off"
	end

	if v3149 == "On Cooldown" then
		return true
	end

	local v3150 = #t1.Match.enemies()

	if v3149 == "With Enemies" then
		return v3150 > 0, "No Enemies"
	end

	if v3149 == "Boss Waves" then
		return t1.Match.boss(), "No Boss"
	end

	if t1._has("AbilityActions", "Only On Boss Waves") and not t1.Match.boss() then
		return false, "No Boss"
	end

	local v3151 = math.max(1, t1._n(t12.AbilityMinEnemies, 1))

	if t1._has("AbilityActions", "Only With Enemies") and v3150 < v3151 then
		return false, v3150 .. " / " .. v3151 .. " Enemies"
	end

	return true
end
t1.Ability.target = function(p636, p637)
	local v3152 = t1._n(p636.range, t1.Data.range(p636.id, p636.level))

	if v3152 <= 0 or not p636.pos then
		return nil
	end

	local v3153 = t1.Place.candidates()

	if type(v3153) ~= "table" or #v3153 == 0 then
		return nil
	end

	local v3154 = select(1, t1.Place.coverage(p636.pos, v3152)) or 0
	local v3155 = t1._n(p637.MaxFlyDistance, 100)
	local v3156 = v3155 * v3155
	local v3157 = t1.Data.radius(p636.id)
	local v3158 = t1.Place.gap()
	local t205 = {}

	for _, v in ipairs(t1.Match.placed()) do
		if (t1._flat(v.pos) - t1._flat(p636.pos)).Magnitude > 0.5 then
			t205[#t205 + 1] = v
		end
	end

	local pos
	local v3163 = math.max(v3154 * (1 + t1._n(t12.AbilityMinGain, 20) / 100), v3154 + 4) - 0.001

	for i, v in ipairs(v3153) do
		local v3166 = v.pos.X - p636.pos.X
		local v3167 = v.pos.Z - p636.pos.Z

		if v3166 * v3166 + v3167 * v3167 <= v3156 then
			local v3168 = select(1, t1.Place.coverage(v.pos, v3152)) or 0

			if v3163 < v3168 then
				local v3169, v3170 = t1.Place.check(v.pos, p636.id, v3157, t205, v3158)

				if v3169 then
					pos = typeof(v3170) == "Vector3" and v3170 or v.pos
					v3163 = v3168
				end
			end
		end

		if i % 400 == 0 then
			task.wait()
		end
	end

	if pos then
		return pos, math.floor(v3163 - v3154 + 0.5)
	end

	return nil
end

do
	t1.Ability.use = function(p638, p639, p640, p641)
		local Ability = t1.Ability
		local v3172 = t1.Data.name(p638.id)
		local v3173 = v3172 .. " | +" .. p641 .. " Studs Covered"

		if not t1._delayRange("ability", t12.AbilityDelay, Ability, "[DELAY] " .. v3172, "AutoAbility") then
			return
		end

		if not t12.AutoAbility or not t1.Ctx.inMatch() then
			return t1._wake("status")
		end

		local v3174 = t1.Place.pivot(p638.id, p640, t1.Place.yaw(p640))
		local v3175 = Ability.cd[p638.hash]
		local pos = p638.pos

		Ability.text = "[RELOCATING] " .. v3173
		t1._wake("status")

		local TowerAbility = t1.fire("TowerAbility", {
			Id = p638.rec.Id or p638.hash,
			Args = {
				TargetPosition = v3174.Position,
				TargetCFrame = v3174
			}
		})

		if TowerAbility and t1._confirm(function()
			if Ability.cd[p638.hash] ~= v3175 then
				return true
			end

			local v3178 = t1.Match.tower(p638.hash)
			local v3179 = v3178 and t1.Match.pos(v3178)

			return v3179 ~= nil and (v3179 - pos).Magnitude > 2
		end, 4) then
			Ability.n += 1
			Ability.text = "[RELOCATED] " .. v3173

			if Ability.cd[p638.hash] == v3175 then
				Ability.cd[p638.hash] = workspace:GetServerTimeNow() + t1._n(p639.Cooldown, 60)
			end

			t1.Match.dirty()
		else
			Ability.tried[p638.hash] = os.clock() + 30
			Ability.text = "[REFUSED] " .. v3172 .. " | " .. (TowerAbility and "Not Moved" or "Not Sent")
		end

		t1._wake("ability")
		t1._wake("status")
	end
end

t1.Ability.run = function()
	local Ability = t1.Ability

	if not t12.AutoAbility then
		return t1._wake("status")
	end

	if not t1.Ctx.inMatch() then
		Ability.text = "[WAITING] Awaiting Match"

		return t1._wake("status")
	end

	local v3181 = t1._n(t12.AbilityFromWave)

	if v3181 > 0 and t1.Match.waves() < v3181 then
		Ability.text = "[WAITING] Awaiting Wave " .. v3181 .. " | " .. Ability.n .. " Used"

		return t1._wake("status")
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local now = os.clock()
	local huge = math.huge
	local text
	local v3186 = false

	for _, v in ipairs(t1.Match.towers()) do
		local v3189 = t1.Ability.info(v.id)

		if v3189 then
			v3186 = true

			local v3190 = t1._n(Ability.cd[v.hash])

			if v.level < t1._n(v3189.UnlockLevel, 1) then
				text = text or "[WAITING] Awaiting Level " .. t1._n(v3189.UnlockLevel, 1) .. " | " .. t1.Data.name(v.id)

				continue
			end

			if serverTimeNow < v3190 then
				huge = math.min(huge, v3190 - serverTimeNow)

				continue
			end

			if now < t1._n(Ability.tried[v.hash]) then
				huge = math.min(huge, Ability.tried[v.hash] - now)

				continue
			end

			if Ability.best[v.hash] == v.level then
				continue
			end

			local v3191, v3192 = t1.Ability.gate(v.id)

			if not v3191 then
				text = text or "[HOLDING] " .. t1.Data.name(v.id) .. " | " .. v3192

				continue
			end

			if not (t1.Match.cash() < t1._n(v3189.Price)) then
				local v3193, v3194 = t1.Ability.target(v, v3189)

				if v3193 then
					return t1.Ability.use(v, v3189, v3193, v3194)
				end

				Ability.best[v.hash] = v.level

				continue
			end

			text = text or "[WAITING] Awaiting Money | " .. t1.Data.name(v.id) .. " " .. t1._num(t1._n(v3189.Price))
		end
	end

	if huge < math.huge then
		t1._alarm("ability", huge + 0.25, "ability:cd")
	end

	if text then
		Ability.text = text
	elseif huge < math.huge then
		Ability.text = "[WAITING] Awaiting Cooldown | " .. math.ceil(huge) .. "s"
	elseif v3186 then
		Ability.text = "[DONE] Auto Ability | " .. Ability.n .. " Relocations, Best Spots Held"
	else
		Ability.text = "[WAITING] Awaiting Titans | Relocate Units"
	end

	t1._wake("status")
end
t1.Party = {
	text = "[IDLE]",
	holdSince = nil,
	hopped = {},
	seen = false,
	dir = "BARRAGE/CameramanTowerDefenseParty"
}

do
	t1.Party.names = function(p642)
		local t206 = {}
		local v3196 = tostring(p642 or "")

		for match in v3196:lower():gmatch("[^,%s]+") do
			t206[#t206 + 1] = match
		end

		return t206
	end
end

do
	t1.Party.find = function(p643)
		local v3198 = tostring(p643 or ""):lower()

		if v3198 == "" then
			return nil
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player == LocalPlayer then
				continue
			end

			if player.Name:lower() == v3198 then
				return player
			end

			if player.DisplayName:lower() == v3198 then
				return player
			end
		end

		return nil
	end
end

t1.Party.root = function(p644)
	local Character = p644 and p644.Character
	local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

	return HumanoidRootPart and HumanoidRootPart:IsA("BasePart") and HumanoidRootPart or nil
end
t1.Party.box = function(p645)
	local Elevators = workspace:FindFirstChild("Elevators")
	local v3204 = Elevators and p645 and Elevators:FindFirstChild(p645)

	return v3204 and t1.Queue.parts(v3204) or nil
end

do
	t1.Party.alts = function(p646)
		local t207 = {}
		local t208 = {}
		local t209 = {}

		for _, v in ipairs(t1.Party.names(t12.PartyAltNames)) do
			local v3210 = t1.Party.find(v)
			local v3211 = t1.Party.root(v3210)

			if v3210 then
				if p646 and v3211 and t1.Queue.inBox(p646, v3211.Position) then
					t207[#t207 + 1] = v3210.Name
				else
					t208[#t208 + 1] = v3210.Name
				end
			else
				t209[#t209 + 1] = v
			end
		end

		return t207, t208, t209
	end
end

t1.Party.altLines = function()
	if #t1.Party.names(t12.PartyAltNames) == 0 then
		return "[WAITING] Awaiting Alts | Alt Names Requirement"
	end

	local v3212, v3213, v3214 = t1.Party.alts(t1.Party.box(t1.Queue.inside))
	local t210 = {}

	for _, v in ipairs(v3212) do
		t210[#t210 + 1] = "[IN ELEVATOR] " .. v
	end

	for _, v in ipairs(v3213) do
		t210[#t210 + 1] = "[IN SERVER] " .. v
	end

	for _, v in ipairs(v3214) do
		t210[#t210 + 1] = "[MISSING] " .. v
	end

	return table.concat(t210, "\n")
end

do
	t1.Party.following = function()
		return t12.PartyRole == "Alt" and t12.FollowHost == true
	end
end

t1.Party.hold = function(p647)
	if not (t12.PartyRole == "Host" and t12.WaitForAlts) then
		t1.Party.holdSince = nil

		return false
	end

	local v3222 = #t1.Party.names(t12.PartyAltNames)

	if v3222 == 0 then
		return false
	end

	local v3223 = t1.Party.alts(p647)
	local now = os.clock()

	t1.Party.holdSince = t1.Party.holdSince or now

	local v3225 = t1._n(t12.AltWaitTime, 60) - (now - t1.Party.holdSince)

	if v3222 <= #v3223 or v3225 <= 0 then
		return false
	end

	t1.Queue.text = "[WAITING] Awaiting Alts | " .. #v3223 .. " / " .. v3222 .. " In Elevator, " .. math.ceil(v3225) .. "s"
	t1._alarm("queue", 1, "queue:alts")

	return true
end

do
	t1.Party.file = function(p648)
		return t1.Party.dir .. "/" .. tostring(p648):lower():gsub("[^%w_]", "") .. ".json"
	end
end

do
	t1.Party.write = function()
		local fs = t1.Macro.fs

		if type(writefile) ~= "function" or not fs.makefolder or not fs.isfolder then
			return false
		end

		local function v3227()
			if not fs.isfolder("BARRAGE") then
				fs.makefolder("BARRAGE")
			end

			if not fs.isfolder(t1.Party.dir) then
				fs.makefolder(t1.Party.dir)
			end

			writefile(t1.Party.file(LocalPlayer.Name), HttpService:JSONEncode({
				job = game.JobId,
				place = t1.Ctx.place(),
				t = os.time()
			}))
		end

		return pcall(v3227)
	end
end

t1.Party.hostJob = function()
	local fs = t1.Macro.fs
	local v3229 = tostring(t12.PartyHostName or "")

	if type(readfile) == "function" and fs.isfile and v3229 ~= "" then
		local v3230 = t1.Party.file(v3229)
		local ok, result = pcall(function()
			return fs.isfile(v3230) and readfile(v3230) or nil
		end)
		local v3233 = ok and t1._json(result)

		if v3233 and v3233.place == "LOBBY" and os.time() - t1._n(v3233.t) <= 30 and type(v3233.job) == "string" and v3233.job ~= "" then
			return v3233.job
		end
	end

	local v3234 = tostring(t12.HostServerId or ""):gsub("%s", "")

	if t12.JoinHostServer and v3234 ~= "" then
		return v3234
	end

	return nil
end

do
	t1.Party.lobby = function(p649)
		local Party = t1.Party
		local Queue = t1.Queue

		if not p649 then
			local v3237 = Party.hostJob()

			if not v3237 or v3237 == game.JobId or Party.hopped[v3237] then
				Party.text = "[WAITING] Awaiting Host | Not In This Server"
			else
				Party.hopped[v3237] = true
				Party.text = "[JOINING] Host Server"
				t1._wake("status")

				if pcall(TeleportService.TeleportToPlaceInstance, TeleportService, 132929771812494, v3237, LocalPlayer) and t1._confirm(function()
					return t1.Ctx.leaving
				end, 8) then
					return t1._wake("status")
				end

				Party.text = "[REFUSED] Host Server | No Teleport"
			end

			t1._alarm("party", 5, "party:host")

			return t1._wake("status")
		end

		if not t12.FollowHost then
			Party.text = "[JOINED] Host Server | Follow Host Requirement"

			return t1._wake("status")
		end

		local v3238 = Party.root(p649)
		local v3239

		for _, v in ipairs(Queue.list()) do
			if v3238 and Queue.inBox(v.box, v3238.Position) then
				v3239 = v

				break
			end
		end

		if Queue.inside and (not v3239 or Queue.inside ~= v3239.name) then
			local inside = Queue.inside

			if not t1.Move.lease("party") then
				Party.text = t1.Move.busyText()

				return t1._wake("status")
			end

			Party.text = "[LEAVING] " .. inside .. " | Host Not In It"
			t1._wake("status")

			local v3243 = Party.box(inside)

			if v3243 then
				t1.Move.to((v3243.CFrame * CFrame.new(0, 0, v3243.Size.Z * 0.5 + 6)).Position - Vector3.new(0, 3, 0))
			end

			t1.invoke("ElevatorLeave", 6, inside)
			t1._awaitEvent("elevator", function()
				return Queue.inside ~= inside
			end, 3)
			t1.Move.drop("party")
			t1._alarm("party", 3, "party:leave")

			return t1._wake("status")
		end

		if not v3239 then
			Party.text = "[FOLLOWING] Host | Awaiting Host's Elevator"

			return t1._wake("status")
		end

		if Queue.inside == v3239.name then
			if not Queue.inBox(v3239.box) and t1.Move.lease("party") then
				t1.Move.to(v3239.spot - Vector3.new(0, 3, 0))
				t1.Move.drop("party")
			end

			Party.text = "[QUEUED] With Host | " .. v3239.players .. " / " .. v3239.max .. " Players"

			return t1._wake("status")
		end

		if v3239.max <= v3239.players then
			Party.text = "[WAITING] Awaiting Space | Host's Elevator"

			return t1._wake("status")
		end

		if t1._backed("party:enter") then
			return t1._wake("status")
		end

		if not t1.Move.lease("party") then
			Party.text = t1.Move.busyText()

			return t1._wake("status")
		end

		Party.text = "[JOINING] Host | " .. (v3239.map ~= "" and v3239.map or v3239.name)
		t1._wake("status")
		t1.Move.to(v3239.spot - Vector3.new(0, 3, 0))

		local function v3244()
			Queue.adopt(true)

			return Queue.inside ~= nil
		end

		if t1._awaitEvent("elevator", v3244, 1) then
			t1.Move.drop("party")
		else
			local ElevatorEnter, v3246 = t1.invoke("ElevatorEnter", 6, v3239.name)

			if ElevatorEnter and v3246 and not Queue.inside then
				Queue.inside = v3239.name
			end

			local elevator = t1._awaitEvent("elevator", v3244, 2)

			t1.Move.drop("party")

			if not elevator then
				t1._backoff("party:enter", 5)
				Party.text = "[REFUSED] " .. v3239.name .. " | Not Entered"
			end
		end

		t1._wake("party")
		t1._wake("status")
	end
end

do
	t1.Party.match = function(p650, p651)
		local Party = t1.Party
		local End = t1.End

		if not t12.FollowHost then
			Party.text = "[JOINED] Host Match | Follow Host Requirement"

			return t1._wake("status")
		end

		if p650 then
			Party.seen = true
		end

		if not p650 then
			if not Party.seen then
				Party.text = "[WAITING] Awaiting Host | Loading In"

				return t1._wake("status")
			end

			if t1._backed("party:out") then
				return t1._wake("status")
			end

			Party.text = "[LEAVING] Host Left | Lobby"
			t1._wake("status")

			if not t1.leaveMatch() then
				t1._backoff("party:out", 5)
				Party.text = "[RETRYING] Lobby | No Teleport"
			end

			return t1._wake("status")
		end

		if p651 ~= "RESULTS" or not End.voted(p650.UserId) or End.voted() then
			if p651 == "RESULTS" then
				Party.text = "[FOLLOWING] Host | Results"
			else
				Party.text = "[FOLLOWING] Host | In Match"
			end

			t1._wake("status")

			return
		end

		if t1._backed("party:again") then
			return t1._wake("status")
		end

		Party.text = "[VOTING] Play Again | Host Voted"
		t1._wake("status")

		local PlayAgain = t1.fire("PlayAgain")

		if PlayAgain and t1._confirm(function()
			return End.voted() or t1.Ctx.place() ~= "RESULTS"
		end, 4) then
			Party.text = "[VOTED] Play Again | With Host"
		else
			t1._backoff("party:again", 3)
			Party.text = "[RETRYING] Play Again | " .. (PlayAgain and "Vote Not Counted" or "Not Sent")
		end

		return t1._wake("status")
	end
end

t1.Party.run = function()
	local Party = t1.Party
	local PartyRole = t12.PartyRole

	if PartyRole ~= "Host" and PartyRole ~= "Alt" then
		Party.text = "[IDLE]"
		t1.Move.drop("party")

		return t1._wake("status")
	end

	local v3253 = t1.Ctx.place()

	if v3253 == "TELEPORTING" then
		Party.text = "[TELEPORTING] " .. PartyRole

		return t1._wake("status")
	end

	if PartyRole == "Host" then
		local v3254 = #Party.names(t12.PartyAltNames)

		if v3253 == "LOBBY" then
			Party.write()
			t1._alarm("party", 10, "party:beat")
		end

		if v3254 == 0 then
			Party.text = "[WAITING] Awaiting Alts | Alt Names Requirement"
		elseif v3253 == "LOBBY" and not t12.AutoJoin then
			Party.text = "[WAITING] Awaiting Elevator | Auto Join Requirement"
		else
			local _, _, v3257 = Party.alts(nil)

			Party.text = "[HOSTING] " .. v3254 .. " Alts | " .. v3254 - #v3257 .. " In Server"
		end

		return t1._wake("status")
	end

	if tostring(t12.PartyHostName or "") == "" then
		Party.text = "[WAITING] Awaiting Host | Host Name Requirement"

		return t1._wake("status")
	end

	local v3258 = Party.find(t12.PartyHostName)

	if v3253 == "LOBBY" then
		return Party.lobby(v3258)
	end

	if v3253 == "MATCH" or v3253 == "RESULTS" then
		return Party.match(v3258, v3253)
	end

	Party.text = "[WAITING] Awaiting Lobby"
	t1._wake("status")
end
t1.Special = t1._chore("special", {
	got = 0,
	found = 0
})

do
	t1.Special.event = function()
		return ReplicatedStorage:FindFirstChild("SpeakermanQuestEvent")
	end
end

do
	t1.Special.active = function()
		local v3259 = t1.Special.event()

		return v3259 ~= nil and v3259:GetAttribute("Active") == true and workspace:GetServerTimeNow() < t1._n(v3259:GetAttribute("EndsAt"))
	end
end

do
	t1.Special.eventId = function()
		local v3260 = t1.Special.event()

		return v3260 and v3260:GetAttribute("EventId")
	end
end

t1.Special.cfg = function()
	local SpecialQuests = t1.gameSettings().SpecialQuests

	return type(SpecialQuests) == "table" and SpecialQuests or {}
end

do
	t1.Special.areas = function()
		local t211 = {}

		for k in pairs(t1.Special.cfg()) do
			if type(k) == "string" then
				t211[#t211 + 1] = k
			end
		end

		table.sort(t211)

		return t211
	end
end

do
	t1.Special.milestones = function()
		local t212 = {}
		local SpecialQuestMilestones = t1.gameSettings().SpecialQuestMilestones
		local v3266 = type(SpecialQuestMilestones) == "table" and SpecialQuestMilestones or {}

		for k, v in pairs(v3266) do
			if tonumber(k) and type(v) == "table" then
				local v3269 = tostring(v.Title or v.Boost or "Reward")

				t212[#t212 + 1] = {
					n = tonumber(k),
					title = v3269,
					label = tonumber(k) .. " Speakers: " .. v3269
				}
			end
		end

		table.sort(t212, function(p652, p653)
			return p652.n < p653.n
		end)

		return t212
	end
end

do
	t1.Special.names = function()
		local t213 = {}

		for _, v in ipairs(t1.Special.milestones()) do
			t213[#t213 + 1] = v.label
		end

		return t213
	end
end

do
	t1.Special.data = function()
		local v3273 = t1.data()
		local SpecialQuests = v3273 and v3273.SpecialQuests

		if type(SpecialQuests) == "table" and SpecialQuests.EventId == t1.Special.eventId() then
			return SpecialQuests
		end

		return nil
	end
end

do
	t1.Special.isFound = function(p654, p655)
		local v3275 = t1.Special.data()
		local v3276 = v3275 and v3275[p654]

		return type(v3276) == "table" and type(v3276[tostring(p655)]) == "table" and v3276[tostring(p655)].Found == true
	end
end

t1.Special.count = function()
	local v3277 = t1.Special.data()

	if not v3277 then
		return 0
	end

	local n79 = 0
	local v3279 = t1.Special.cfg()

	for _, v in ipairs(t1.Special.areas()) do
		local v3282 = v3279[v]
		local v3283 = v3277[v]

		if type(v3282) == "table" and type(v3282.Find) == "table" and type(v3283) == "table" then
			for k in pairs(v3282.Find) do
				if type(v3283[tostring(k)]) == "table" and v3283[tostring(k)].Found == true then
					n79 += 1
				end
			end
		end
	end

	return n79
end

do
	t1.Special.total = function()
		local n80 = 0

		for _, v in ipairs(t1.Special.areas()) do
			local v3288 = t1.Special.cfg()[v]

			if type(v3288) == "table" and type(v3288.Find) == "table" then
				for _ in pairs(v3288.Find) do
					n80 += 1
				end
			end
		end

		return n80
	end
end

do
	t1.Special.claimed = function(p656)
		local v3290 = t1.Special.data()

		return v3290 ~= nil and type(v3290.Milestones) == "table" and v3290.Milestones[tostring(p656)] == true
	end
end

t1.Special.area = function()
	for k, v in pairs(t1.Special.cfg()) do
		if type(v) == "table" and v.PlaceId == game.PlaceId then
			return k
		end
	end

	return nil
end

do
	t1.Special.speakers = function()
		local v3293 = t1.Special.area()

		if not v3293 then
			return {}
		end

		local t214 = {}
		local ItemsToFind = workspace:FindFirstChild("ItemsToFind")

		if ItemsToFind then
			t214[#t214 + 1] = ItemsToFind:FindFirstChild(v3293) or v3293 == "Match" and ItemsToFind:FindFirstChild("Game") or nil
		end

		if v3293 == "Match" then
			local _mroots = t1.Special._mroots
			local v3297 = not _mroots

			if not v3297 then
				v3297 = os.clock() - (t1.Special._mrootsAt or 0) > 10
			end

			local ipairs_ = ipairs
			local v3299 = _mroots or {}

			for _, v in ipairs_(v3299) do
				if not v.Parent then
					v3297 = true
				end
			end

			if v3297 then
				_mroots = {}

				local Game = workspace:FindFirstChild("Game")
				local ipairs_2 = ipairs
				local descendants = Game and Game:GetDescendants() or {}

				for _, descendant in ipairs_2(descendants) do
					if descendant.Name == "ItemsToFind" then
						_mroots[#_mroots + 1] = descendant
					end
				end

				local Special = t1.Special
				local Special2 = t1.Special
				local now = os.clock()

				Special._mroots = _mroots
				Special2._mrootsAt = now
			end

			for _, _mroot in ipairs(_mroots) do
				t214[#t214 + 1] = _mroot
			end
		end

		local Find = type(t1.Special.cfg()[v3293]) == "table" and t1.Special.cfg()[v3293].Find or {}
		local t215 = {}

		for _, v in ipairs(t214) do
			for _, child in ipairs(v:GetChildren()) do
				local v3318 = tonumber(child.Name)

				if child:IsA("BasePart") and v3318 and not (Find[v3318] == nil or t1.Special.isFound(v3293, v3318) or t1._backed("special:sp" .. v3318)) then
					t215[#t215 + 1] = {
						part = child,
						id = v3318,
						area = v3293,
						cd = child:FindFirstChildOfClass("ClickDetector")
					}
				end
			end
		end

		table.sort(t215, function(p657, p658)
			return p657.id < p658.id
		end)

		return t215
	end
end

do
	t1.Special.nextMilestone = function()
		if LocalPlayer.AccountAge < 7 then
			return nil, "Account Under 7 Days"
		end

		local v3319 = t1.Special.count()

		for _, v in ipairs(t1.Special.milestones()) do
			if t1._has("SpecialQuestSelection", v.label) and not t1.Special.claimed(v.n) and v.n <= v3319 and not t1._backed("special:" .. v.n) then
				return v
			end
		end

		return nil
	end
end

t1.Special.collect = function(p659)
	if p659.cd then
		if type(fireclickdetector) == "function" then
			local u3322 = false
			local special, v3324 = t1.Move.run("special", function()
				u3322 = t1.Move.go(p659.part.Position, 8)

				if u3322 and t1.Move.held("special") and t12.AutoSpecialQuests then
					pcall(fireclickdetector, p659.cd)
				end
			end)

			if not special then
				local v3325 = false
				local v3326 = v3324 and "Move Failed" or "Character Busy"

				return v3325, v3326
			end

			if not u3322 then
				return false, "Not Reached"
			end

			local function v3327()
				return t1.Special.isFound(p659.area, p659.id)
			end

			return t1._confirm(v3327, 5)
		end
	end

	return false, "No Click"
end

do
	t1.Special.trip = function()
		local v3328 = t1.Special.speakers()[1]

		if v3328 then
			t1.teleportTo(function()
				return v3328.part.Position
			end)
		end

		return v3328 ~= nil
	end
end

do
	t1.Special.run = function()
		local Special = t1.Special

		if not t12.AutoSpecialQuests then
			Special.due = false

			return t1._wake("status")
		end

		if not t1.Special.event() then
			return t1._done(Special, "[UNAVAILABLE] Special Quests | No Speakerman Event")
		end

		if not t1.Special.active() then
			return t1._done(Special, "[WAITING] Awaiting Event | Speakerman Away")
		end

		local v3330 = t1._n(t1.Special.event():GetAttribute("EndsAt")) - workspace:GetServerTimeNow()

		if v3330 > 0 then
			t1._alarm("special", v3330 + 1, "special:end")
		end

		if not t1.data() then
			Special.text = "[WAITING] Awaiting Data"
			t1._alarm("special", 2, "data:special")

			return t1._wake("status")
		end

		local v3331 = t1.Special.count()
		local v3332 = t1.Special.total()
		local v3333 = t1.Special.speakers()[1]

		if v3333 then
			Special.due = true

			local v3334 = "Speaker #" .. v3333.id .. " | " .. v3331 .. "/" .. v3332 .. " Found"

			if not t1._delayRange("special", t12.SpecialQuestDelay, Special, "[DELAY] " .. v3334, "AutoSpecialQuests") then
				return
			end

			Special.text = "[FINDING] " .. v3334
			t1._wake("status")

			local v3335, v3336 = t1.Special.collect(v3333)

			if v3335 then
				Special.found += 1
				Special.text = "[FOUND] Speaker #" .. v3333.id
			else
				t1._backoff("special:sp" .. v3333.id, v3336 == "Character Busy" and 5 or 30)
				Special.text = "[REFUSED] Speaker #" .. v3333.id .. " | " .. (v3336 or "Not Found")
			end

			t1._wake("special")

			return t1._wake("status")
		end

		local v3337 = t1._at(ReplicatedStorage, "SpecialQuestRemotes.ClaimMilestone")
		local v3338, v3339 = t1.Special.nextMilestone()

		if not v3338 or not v3337 then
			local v3340 = type(t12.SpecialQuestSelection) ~= "table" or #t12.SpecialQuestSelection == 0
			local v3341 = v3339 or not v3337 and "Claims In Lobby" or v3340 and "Speakers Only" or "Nothing To Claim"

			return t1._done(Special, "[DONE] Special Quests | " .. v3331 .. "/" .. v3332 .. " Found, " .. v3341)
		end

		Special.due = true

		local label = v3338.label

		if not t1._delayRange("special", t12.SpecialQuestDelay, Special, "[DELAY] " .. label, "AutoSpecialQuests") then
			return
		end

		Special.text = "[CLAIMING] " .. label
		t1._wake("status")

		local v3343 = t1.Special.eventId()
		local v3344 = false

		if t1._gate("ClaimMilestone") then
			local v3345 = table.pack(t1._invokeRaw(v3337, 8, v3338.n, v3343))

			v3344 = v3345[1] == true and v3345[2] == true
		end

		if v3344 or t1._confirm(function()
			return t1.Special.claimed(v3338.n)
		end, 3) then
			Special.got += 1
			Special.text = "[CLAIMED] " .. label
		else
			t1._backoff("special:" .. v3338.n, 60)
			Special.text = "[REFUSED] " .. label .. " | Not Claimed"
		end

		t1._wake("special")
		t1._wake("status")
	end
end

t1.Rng = {
	text = "[IDLE]",
	n = 0
}

do
	t1.Rng.map = function()
		local MatchLoadout = t1.mod("MatchLoadout", "ModuleLoader.Shared.MatchLoadout")

		return type(MatchLoadout) == "table" and MatchLoadout.Map or "Tasty Large Cake"
	end
end

do
	t1.Rng.on = function()
		local attribute = workspace:GetAttribute("GameState")

		return workspace:GetAttribute("Map") == t1.Rng.map() and LocalPlayer:GetAttribute("RNGLoadout") == true and attribute ~= "Won" and attribute ~= "Lost" and attribute ~= "Restarting"
	end
end

do
	t1.Rng.empty = function()
		local n81 = 0

		for i = 1, math.max(1, t1._n(t1.gameSettings().HotbarSlots, 5)) do
			local attribute = LocalPlayer:GetAttribute("Slot" .. i)
			local attribute2 = LocalPlayer:GetAttribute("Slot" .. i .. "Id")

			if type(attribute) ~= "string" or attribute == "" or type(attribute2) ~= "string" or attribute2 == "" then
				n81 += 1
			end
		end

		return n81
	end
end

t1.Rng.run = function()
	local Rng = t1.Rng

	if not t12.AutoRngRoll then
		return t1._wake("status")
	end

	if not t1.Ctx.inMatch() then
		Rng.text = "[WAITING] Awaiting Match"

		return t1._wake("status")
	end

	if not t1.Rng.on() then
		Rng.text = "[WAITING] Awaiting Mode | RNG World"

		return t1._wake("status")
	end

	if t1._backed("rng") then
		Rng.text = "[RETRY] RNG Roll | Refused"

		return t1._wake("status")
	end

	local v3353 = t1.Rng.empty()

	if v3353 == 0 then
		Rng.text = "[DONE] RNG Roll | Every Slot Filled, " .. Rng.n .. " Rolls"

		return t1._wake("status")
	end

	if not t1._delayRange("rng", t12.RngRollDelay, Rng, "[DELAY] Roll | " .. v3353 .. " Empty Slots", "AutoRngRoll") then
		return
	end

	Rng.text = "[ROLLING] " .. v3353 .. " Empty Slots"
	t1._wake("status")

	local RNGRoll, v3355 = t1.invoke("RNGRoll", 8)

	if RNGRoll and type(v3355) == "table" and type(v3355.Name) == "string" then
		Rng.n += 1
		Rng.text = "[ROLLED] " .. t1.Data.name(v3355.Name) .. (type(v3355.Slot) == "number" and " | Slot " .. v3355.Slot or "")
		t1.Match._slots = nil
		t1._wake("play")
		t1._alarm("rng", 0.6, "rng:next")
	else
		t1._backoff("rng", 3)
		Rng.text = "[REFUSED] RNG Roll | Try Again"
	end

	t1._wake("status")
end
t1.AutoWalk = {
	owner = {
		text = "[IDLE]"
	},
	walks = 0,
	seq = 0,
	want = nil,
	last = nil,
	STEP = 0.5,
	jumps = 0,
	LIST = {
		"Ability",
		"Placement",
		"Target Change",
		"Upgrade"
	},
	KIND = {
		TowerAdd = "Placement",
		TowerUpgrade = "Upgrade",
		TowerAbility = "Ability",
		TowerTarget = "Target Change"
	},
	conns = {},
	watched = {}
}
t1._allWorkers[#t1._allWorkers + 1] = "autowalk"
t1.AutoWalk.halt = function()
	local v3356 = t1._hrp()
	local v3357 = t1._hum()

	if v3356 and v3357 and v3357.Health > 0 then
		pcall(v3357.MoveTo, v3357, v3356.Position)
	end
end
t1.Move.cleanup.autowalk = t1.AutoWalk.halt
t1.AutoWalk.interrupt = function()
	if t1.Move.owner == "autowalk" then
		pcall(function()
			t1._moveEnd:Fire()
		end)
	end
end
t1.AutoWalk.byUuid = function(p660)
	if p660 == nil then
		return nil
	end

	t1.Match.dirty()

	return t1.Match.tower(tostring(p660))
end
t1.AutoWalk.aim = function(p661, p662)
	local AutoWalk = t1.AutoWalk

	if t12.AutoWalk ~= true or not t1._has(t12.WalkTo, p661) or not p662 then
		return
	end

	local want = AutoWalk.want

	if want and want.kind == p661 and want.target == p662 then
		if os.clock() - (want.at or 0) < 1 then
			return
		end
	end

	AutoWalk.seq += 1
	AutoWalk.want = {
		kind = p661,
		target = p662,
		seq = AutoWalk.seq,
		at = os.clock()
	}
	AutoWalk.interrupt()
	t1._wake("autowalk")
end
t1.AutoWalk.note = function(p663, p664)
	local AutoWalk = t1.AutoWalk
	local v3361 = AutoWalk.KIND[p663]

	if t12.AutoWalk ~= true or not t1._has(t12.WalkTo, v3361) or type(p664) ~= "table" then
		return
	end

	local Pos

	if p663 == "TowerAdd" then
		Pos = typeof(p664.Pos) == "Vector3" and p664.Pos or typeof(p664.CFrame) == "CFrame" and p664.CFrame.Position or nil
	else
		Pos = AutoWalk.byUuid(p664.Id)
	end

	AutoWalk.aim(v3361, Pos)
end
t1.AutoWalk.unbind = function()
	local AutoWalk = t1.AutoWalk

	t1._drop(AutoWalk.conns)
	table.clear(AutoWalk.watched)
	AutoWalk.boundTo = nil
end
t1.AutoWalk.bind = function()
	local AutoWalk = t1.AutoWalk
	local v3365 = t1._at(workspace, "Game.Towers")

	if v3365 then
		if AutoWalk.boundTo ~= v3365 then
			AutoWalk.unbind()
			AutoWalk.boundTo = v3365
			AutoWalk.conns[#AutoWalk.conns + 1] = v3365.ChildAdded:Connect(function(child)
				task.delay(0.4, function()
					if t1.Running and t12.AutoWalk then
						if child.Parent then
							local v3366 = t1.Match.tower(child.Name)

							if v3366 then
								AutoWalk.aim("Placement", v3366)
							end

							return
						end
					end
				end)
			end)

			return
		end
	end
end
t1._cleanups[#t1._cleanups + 1] = t1.AutoWalk.unbind
t1.AutoWalk.resolve = function(p665)
	local target = p665.target

	if typeof(target) == "Vector3" then
		local rec
		local v3369

		for _, v in ipairs(t1.Match.towers()) do
			local pos = v.pos
			local Magnitude = pos and Vector2.new(pos.X - target.X, pos.Z - target.Z).Magnitude

			if Magnitude and Magnitude < 2 and (not v3369 or Magnitude < v3369) then
				rec = v.rec
				v3369 = Magnitude
			end
		end

		if not rec then
			return target, nil
		end

		p665.target = rec
		target = rec
	end

	local v3374 = type(target) == "table" and t1.Match.key(target)
	local v3375 = v3374 and t1.Match.tower(v3374)

	if not v3375 then
		return nil
	end

	p665.target = v3375

	return t1.Match.pos(v3375), v3375
end

do
	t1.AutoWalk.goal = function(p666, p667, p668, p669)
		if not p668 then
			return p667
		end

		if p666.offset == nil then
			local WalkRange = v29("WalkRange", t12.WalkRange)
			local v3377 = tonumber(t1.Match.statOf(p668, "range")) or 0

			p666.offset = Vector3.zero

			if WalkRange.Max > 0 and v3377 > 0 then
				for i = 1, 6 do
					local v3379 = WalkRange.Min + math.random() * (WalkRange.Max - WalkRange.Min)
					local v3380 = math.random() * math.pi * 2
					local v3381 = v3377 * v3379 / 100
					local vector3 = Vector3.new(math.cos(v3380) * v3381, 0, math.sin(v3380) * v3381)
					local hit = workspace:Raycast(p667 + vector3 + Vector3.new(0, 12, 0), Vector3.new(0, -40, 0), p669)

					if hit and math.abs(hit.Position.Y - p667.Y) < 12 then
						p666.offset = Vector3.new(vector3.X, hit.Position.Y - p667.Y, vector3.Z)

						break
					end
				end
			end
		end

		return p667 + p666.offset
	end
end

t1.AutoWalk.jumpHeight = function(p670)
	if p670.UseJumpPower then
		return p670.JumpPower ^ 2 / (2 * workspace.Gravity)
	end

	return p670.JumpHeight
end
t1.AutoWalk.wallAhead = function(p671, p672, p673, p674)
	local Position = p671.Position
	local vector3 = Vector3.new(p673.X - Position.X, 0, p673.Z - Position.Z)
	local Magnitude = vector3.Magnitude

	if Magnitude < 1 then
		return false
	end

	local v3387 = vector3 / Magnitude
	local v3388 = Position.Y - p672.HipHeight - p671.Size.Y / 2
	local v3389 = math.min(Magnitude, math.max(2.5, p672.WalkSpeed * 0.3))
	local v3390 = t1.AutoWalk.jumpHeight(p672)

	for _, v in ipairs({
		0.4,
		1.2,
		2.2,
		3.4
	}) do
		local hit = workspace:Raycast(Vector3.new(Position.X, v3388 + v, Position.Z), v3387 * v3389, p674)

		if hit then
			if not (hit.Normal.Y < 0.7) then
				continue
			end

			local v3394 = hit.Position + v3387 * 0.6
			local hit2 = workspace:Raycast(Vector3.new(v3394.X, v3388 + v3390 + 2, v3394.Z), Vector3.new(0, -(v3390 + 2), 0), p674)

			return not hit2 or hit2.Position.Y - v3388 <= v3390 + 0.5
		end
	end

	return false
end

do
	t1.AutoWalk.jumpStep = function(p675, p676)
		local AutoWalk = t1.AutoWalk
		local v3397 = t1._hrp()
		local v3398 = t1._hum()
		local goalPos = AutoWalk.goalPos

		if not v3397 or not v3398 or not goalPos or not (v3398.Health > 0) then
			return
		end

		local state = v3398:GetState()

		if v3398.FloorMaterial == Enum.Material.Air or state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
			AutoWalk.slow = 0

			return
		end

		local Position = v3397.Position

		if Vector2.new(goalPos.X - Position.X, goalPos.Z - Position.Z).Magnitude < 1.5 then
			return
		end

		local AssemblyLinearVelocity = v3397.AssemblyLinearVelocity
		local slow = Vector2.new(AssemblyLinearVelocity.X, AssemblyLinearVelocity.Z).Magnitude < math.max(2, v3398.WalkSpeed * 0.25)

		if slow then
			slow = (AutoWalk.slow or 0) + p675
		end

		AutoWalk.slow = slow or 0

		local now = os.clock()

		if now - (AutoWalk.jumpedAt or 0) < 0.4 then
			return
		end

		p676.FilterDescendantsInstances = { LocalPlayer.Character }

		if AutoWalk.slow > 0.25 or AutoWalk.wallAhead(v3397, v3398, goalPos, p676) then
			local jumps = AutoWalk.jumps + 1

			AutoWalk.jumpedAt = now
			AutoWalk.slow = 0
			AutoWalk.jumps = jumps
			v3398.Jump = true
			v3398:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end

do
	t1._worker("autowalk", t1.AutoWalk.owner, function(p677)
		local AutoWalk = t1.AutoWalk

		if not t12.AutoWalk then
			AutoWalk.want = nil
			AutoWalk.unbind()
			t1.Move.drop("autowalk")
			p677.text = "[IDLE]"

			return
		end

		if not t1._needs("WalkTo", "Walk To", p677) then
			AutoWalk.want = nil
			t1.Move.drop("autowalk")

			return
		end

		if t1.Ctx.place() ~= "MATCH" then
			AutoWalk.want = nil
			AutoWalk.last = nil
			AutoWalk.unbind()
			t1.Move.drop("autowalk")
			p677.text = "[WAITING] Awaiting Match"

			return
		end

		AutoWalk.bind()

		if not AutoWalk.boundTo then
			t1._alarm("autowalk", 2, "autowalk:bind")
		end

		local want = AutoWalk.want

		if not want then
			t1.Move.drop("autowalk")
			p677.text = AutoWalk.last or "[READY] Next Action"

			return
		end

		if not want.paused then
			if not t1._pause("autowalk", t12.WalkDelay, p677, "Walk") then
				return
			end

			local want2 = AutoWalk.want

			if not want2 then
				return
			end

			want2.paused = true
		end

		if not t1.Move.lease("autowalk") then
			p677.text = t1.Move.busyText()

			return
		end

		local Generation = t1.Generation
		local n82 = 0
		local v3411
		local BindableEvent = Instance.new("BindableEvent")
		local raycastParams = RaycastParams.new()

		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.RespectCanCollide = true

		local raycastParams2 = RaycastParams.new()

		raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams2.RespectCanCollide = true

		local connection

		connection = RunService.Heartbeat:Connect(function(dt)
			if not t1.Running or Generation ~= t1.Generation or t1.Move.owner ~= "autowalk" then
				connection:Disconnect()

				return
			end

			AutoWalk.jumpStep(dt, raycastParams2)
		end)

		while t1.Running and Generation == t1.Generation and t12.AutoWalk and t1.Move.held("autowalk") do
			local want2 = AutoWalk.want

			if not want2 or not t1._has(t12.WalkTo, want2.kind) then
				AutoWalk.want = nil
				p677.text = AutoWalk.last or "[READY] Next Action"

				break
			end

			local v3417 = t1._hrp()
			local v3418 = t1._hum()

			if not v3417 or not v3418 or not (v3418.Health > 0) then
				p677.text = "[WAITING] Awaiting Character"

				break
			end

			local v3419, v3420 = AutoWalk.resolve(want2)

			if not v3419 then
				if AutoWalk.want == want2 then
					AutoWalk.want = nil
				end

				AutoWalk.last = "[GONE] Unit | " .. want2.kind
				p677.text = AutoWalk.last

				break
			end

			local v3421 = v3420 and t1._at(workspace, "Game.Towers." .. tostring(t1.Match.key(v3420)))

			raycastParams.FilterDescendantsInstances = v3421 and {
				LocalPlayer.Character,
				v3421
			} or { LocalPlayer.Character }

			local v3422 = AutoWalk.goal(want2, v3419, v3420, raycastParams)

			AutoWalk.goalPos = v3422

			local v3423 = v3420 and t1.Data.name(tostring(v3420.Name)) or "Unit"
			local Magnitude = Vector2.new(v3422.X - v3417.Position.X, v3422.Z - v3417.Position.Z).Magnitude

			if Magnitude <= 1 then
				AutoWalk.walks += 1

				if AutoWalk.want == want2 then
					AutoWalk.want = nil
				end

				AutoWalk.last = "[ARRIVED] " .. v3423 .. " | " .. want2.kind .. " | x" .. AutoWalk.walks
				p677.text = AutoWalk.last

				break
			end

			if t1.Move.contested("autowalk") then
				p677.pending = true

				break
			end

			if want2 == AutoWalk.cur then
				if v3411 and v3411 - Magnitude < 0.5 then
					n82 += 1
				else
					n82 = 0
				end
			else
				AutoWalk.cur = want2
				n82 = 0
			end

			v3411 = Magnitude

			if n82 >= 10 then
				if AutoWalk.want == want2 then
					AutoWalk.want = nil
				end

				AutoWalk.last = "[BLOCKED] " .. v3423 .. " | " .. math.floor(Magnitude + 0.5) .. " Studs"
				p677.text = AutoWalk.last

				break
			else
				p677.text = "[WALKING] " .. v3423 .. " | " .. want2.kind .. ", " .. math.floor(Magnitude + 0.5) .. " Studs"
				t1._wake("status")
				v3418:MoveTo(v3422)
				task.delay(AutoWalk.STEP, function()
					pcall(function()
						BindableEvent:Fire()
					end)
				end)
				t1.Move.await(v3417, {
					v3418.MoveToFinished,
					v3418.Died,
					BindableEvent.Event
				})
			end
		end

		connection:Disconnect()
		BindableEvent:Destroy()
		AutoWalk.cur = nil
		AutoWalk.goalPos = nil
		AutoWalk.slow = 0
		t1.Move.release("autowalk")
	end)
end

t1.Walk = {
	conns = {},
	parts = {},
	hum = nil,
	walk = nil,
	jump = nil
}

do
	t1.Walk.clear = function()
		local Walk = t1.Walk

		t1._drop(Walk.conns)

		for k in pairs(Walk.parts) do
			if k.Parent then
				pcall(function()
					k.CanCollide = true
				end)
			end
		end

		table.clear(Walk.parts)

		local hum = Walk.hum

		if hum and hum.Parent then
			pcall(function()
				if Walk.walk then
					hum.WalkSpeed = Walk.walk
				end

				if Walk.jump then
					hum.JumpPower = Walk.jump
				end
			end)
		end

		Walk.hum = nil
		Walk.walk = nil
		Walk.jump = nil
	end
end

t1.Walk.run = function()
	local Walk = t1.Walk

	Walk.clear()

	if not t12.MoveMods or #t12.MoveModActions == 0 then
		return t1._wake("status")
	end

	local Character = LocalPlayer.Character
	local v3430 = t1._hum()
	local v3431 = t1._hrp()

	if not Character or not v3430 or not v3431 then
		if Character then
			t1._conn(Character.ChildAdded, function()
				t1._wake("walk")
			end, Walk.conns)
		end

		return t1._wake("status")
	end

	local v3432 = t1._set(t12.MoveModActions)

	Walk.hum = v3430

	if v3432.Speed then
		Walk.walk = v3430.WalkSpeed
		v3430.WalkSpeed = t1._n(t12.ModWalkSpeed, 100)
		t1._conn(v3430:GetPropertyChangedSignal("WalkSpeed"), function()
			local v3433 = t1._n(t12.ModWalkSpeed, 100)

			if v3430.WalkSpeed ~= v3433 and v3430.WalkSpeed > 0 then
				v3430.WalkSpeed = v3433
			end
		end, Walk.conns)
	end

	if v3432["Jump Boost"] then
		Walk.jump = v3430.JumpPower
		v3430.UseJumpPower = true
		v3430.JumpPower = t1._n(t12.ModJumpPower, 120)
		t1._conn(v3430:GetPropertyChangedSignal("JumpPower"), function()
			local v3434 = t1._n(t12.ModJumpPower, 120)

			if v3430.JumpPower ~= v3434 then
				v3430.JumpPower = v3434
			end
		end, Walk.conns)
	end

	if v3432["Infinite Jump"] then
		t1._conn(UserInputService.JumpRequest, function()
			if v3430.Parent then
				if v3430.Health > 0 and not (v3430.SeatPart or v3431.Anchored) then
					v3430:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
		end, Walk.conns)
	end

	if v3432.Noclip or v3432.Fly then
		local t216 = {}

		for _, descendant in ipairs(Character:GetDescendants()) do
			if descendant:IsA("BasePart") then
				t216[descendant] = true
			end
		end

		t1._conn(Character.DescendantAdded, function(p678)
			if p678:IsA("BasePart") then
				t216[p678] = true
			end
		end, Walk.conns)
		t1._conn(Character.DescendantRemoving, function(p679)
			t216[p679] = nil
		end, Walk.conns)
		t1._conn(RunService.Stepped, function()
			if v3430.SeatPart then
				return
			end

			for k in pairs(t216) do
				if k.CanCollide and k.Parent then
					k.CanCollide = false
					Walk.parts[k] = true
				end
			end
		end, Walk.conns)
	end

	if v3432.Fly then
		t1._conn(RunService.Heartbeat, function()
			if not v3431.Parent or not v3430.Parent or v3431.Anchored or v3430.SeatPart then
				return
			end

			local MoveDirection = v3430.MoveDirection
			local n83 = 0

			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				n83 += 1
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				n83 -= 1
			end

			if MoveDirection.Magnitude > 0.05 and workspace.CurrentCamera then
				local LookVector = workspace.CurrentCamera.CFrame.LookVector
				local vector3 = Vector3.new(LookVector.X, 0, LookVector.Z)

				MoveDirection += Vector3.new(0, LookVector.Y * (vector3.Magnitude > 0.001 and MoveDirection:Dot(vector3.Unit) or 0), 0)
			end

			local v3443 = t1._n(t12.ModFlySpeed, 120)
			local vector3 = MoveDirection.Magnitude > 0.001 and MoveDirection.Unit * v3443 or Vector3.zero
			local _flyHold = t1._flyHold
			local now = os.clock()
			local v3447 = n83 * v3443

			if n83 == 0 and math.abs(vector3.Y) < v3443 * 0.5 then
				local vector32 = Vector3.new(vector3.X, 0, vector3.Z)

				vector3 = vector32.Magnitude > 0.001 and vector32.Unit * vector3.Magnitude or Vector3.zero

				if not _flyHold or _flyHold.root ~= v3431 or now - _flyHold.at > 0.5 then
					_flyHold = {
						root = v3431,
						y = v3431.Position.Y,
						at = now
					}
				end

				v3447 = (_flyHold.y - v3431.Position.Y) * 10
			else
				_flyHold = {
					root = v3431,
					y = v3431.Position.Y,
					at = _flyHold and _flyHold.at or now
				}
			end

			local v3449 = math.clamp(now - _flyHold.at, 0.0041666666666666666, 0.1)

			_flyHold.at = now
			t1._flyHold = _flyHold
			v3431.AssemblyLinearVelocity = vector3 + Vector3.new(0, v3447 + workspace.Gravity * v3449, 0)
		end, Walk.conns)
	end

	t1._wake("status")
end
t1._wakeHandlers.walk = t1.Walk.run
t1.Walk.live = function()
	if #t12.MoveModActions == 0 then
		return "[WAITING] Awaiting Selection | Mods"
	end

	local v3450 = t1._hum()

	if v3450 then
		return "[ACTIVE] " .. #t12.MoveModActions .. " Mods | Speed " .. math.floor(v3450.WalkSpeed)
	end

	return "[WAITING] Awaiting Character"
end
t1.Walk.modsText = function()
	return t12.MoveMods and t1.Walk.live() or "[IDLE]"
end
t1.Esp = {
	folder = nil,
	enemyTags = {},
	conns = {},
	lights = {},
	road = {
		gen = 0
	},
	old = {}
}
t1.Esp.TAG = {
	enemy = UDim2.fromOffset(112, 26),
	lane = UDim2.fromOffset(48, 16),
	next = UDim2.fromOffset(180, 34),
	marker = UDim2.fromOffset(98, 16),
	cursor = UDim2.fromOffset(120, 16),
	maxText = 14
}
t1.Esp.cap = function(p680)
	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")

	UITextSizeConstraint.MaxTextSize = t1.Esp.TAG.maxText
	UITextSizeConstraint.Parent = p680

	return p680
end

local function v3452(p681)
	local v3453 = t12[p681 .. "Color"]

	if type(v3453) == "table" then
		return Color3.fromRGB(t1._n(v3453[1], 255), t1._n(v3453[2]), t1._n(v3453[3]))
	end

	return Color3.new(1, 0, 0)
end
local function v3454(p682)
	return math.clamp(t1._n(t12[p682 .. "Transparency"]) / 100, 0, 1)
end

t1.Esp.clear = function(p683)
	if not p683 then
		t1.Esp.roadClear()
	end

	t1._drop(t1.Esp.conns)

	if t1.Esp.folder then
		pcall(function()
			t1.Esp.folder:Destroy()
		end)
	end

	t1.Esp.folder = nil

	for _, v in ipairs(t1.Esp.old) do
		pcall(function()
			v:Destroy()
		end)
	end

	table.clear(t1.Esp.old)
	t1.Esp.spotsClear()
	t1.Esp.enemyGroup = nil
	table.clear(t1.Esp.enemyTags)

	local lights = t1.Esp.lights or {}

	for _, light in pairs(lights) do
		pcall(function()
			light:Destroy()
		end)
	end

	t1.Esp.lights = {}
end
t1.Esp.roadClear = function()
	local road = t1.Esp.road

	if road.folder then
		pcall(function()
			road.folder:Destroy()
		end)
	end

	local gen = road.gen + 1

	road.folder = nil
	road.key = nil
	road.building = nil
	road.gen = gen
end
t1.Esp.spotsClear = function()
	if t1.Esp.spots then
		pcall(function()
			t1.Esp.spots:Destroy()
		end)
	end

	local Esp = t1.Esp

	t1.Esp.spots = nil
	Esp._spotsSig = nil
end
t1.Esp.floor = function(p684)
	local Esp = t1.Esp
	local v3464 = t1.Paths.stamp()

	if Esp._floorMap ~= v3464 then
		Esp._floorMap = v3464
		Esp._floor = {}
	end

	local v3465 = math.floor(p684.X * 2) .. ":" .. math.floor(p684.Y * 2) .. ":" .. math.floor(p684.Z * 2)
	local v3466 = Esp._floor[v3465]

	if v3466 then
		return v3466
	end

	local v3467 = t1.Place.mapRp()
	local Y

	for _, v in ipairs({
		1.5,
		8,
		25
	}) do
		local hit = workspace:Raycast(p684 + Vector3.new(0, v, 0), Vector3.new(0, -(v + 60), 0), v3467)

		if hit then
			Y = hit.Position.Y
		end

		if Y then
			break
		end
	end

	local vector3 = Vector3.new(p684.X, Y or p684.Y, p684.Z)

	Esp._floor[v3465] = vector3

	return vector3
end
t1.Esp.track = function(p685)
	local t217 = {}

	for i = 1, #p685 do
		if i > 1 then
			local v3475 = p685[i - 1]
			local v3476 = p685[i]
			local v3477 = math.floor(t1._flat(v3476 - v3475).Magnitude / 3)

			for i2 = 1, v3477 - 1 do
				t217[#t217 + 1] = t1.Esp.floor(v3475:Lerp(v3476, i2 / v3477))
			end
		end

		t217[#t217 + 1] = t1.Esp.floor(p685[i])
	end

	local t218 = { t217[1] }

	for i = 2, #t217 - 1 do
		local v3481 = t218[#t218]
		local v3482 = t217[i]
		local v3483 = t217[i + 1] - v3481

		if (v3481 + v3483 * math.clamp((v3482 - v3481):Dot(v3483) / math.max(v3483:Dot(v3483), 1e-06), 0, 1) - v3482).Magnitude > 0.1 then
			t218[#t218 + 1] = v3482
		end
	end

	if #t217 > 1 then
		t218[#t218 + 1] = t217[#t217]
	end

	return t218
end
t1.Esp.ribbon = function(p686)
	local road = t1.Esp.road

	if not p686 or not p686.paths or not p686.paths[1] then
		t1.Esp.roadClear()

		return false
	end

	local building = tostring(p686) .. ":" .. t1.Paths.rev .. ":" .. tostring(t1.Match.mapId()) .. ":" .. tostring(v3452("EspPath")) .. ":" .. v3454("EspPath")

	if road.key == building and road.folder and road.folder.Parent then
		return true
	end

	if road.building == building then
		return true
	end

	road.building = building

	local gen = road.gen
	local v3487 = math.clamp(t1.Place.roadHalf(), 1, 15)
	local v3488 = v3487 * 2
	local Folder = Instance.new("Folder")

	Folder.Name = "BarrageCameramanTowerDefenseRoad"

	local function v3490(p687)
		return Vector3.new(p687.X, 0, p687.Z)
	end
	local function v3491(p688)
		return Vector3.new(-p688.Z, 0, p688.X)
	end

	local t219 = {}
	local t220 = {}

	local function v3494(p689, p690, p691)
		t219[#t219 + 1] = {
			p689,
			p690,
			p691
		}
	end

	local t221 = {}

	local function v3496(p692)
		for _, v in ipairs(t221) do
			local v3499 = v[2] - v[1]

			if (v[1] + v3499 * math.clamp((p692 - v[1]):Dot(v3499) / math.max(v3499:Dot(v3499), 1e-06), 0, 1) - p692).Magnitude <= v3488 * 0.25 then
				return true
			end
		end

		return false
	end

	local v3500

	for _, path in ipairs(p686.paths) do
		local t222 = {}

		for _, point in ipairs(path.points) do
			local v3506 = t1.Esp.floor(point) + Vector3.new(0, 0.07, 0)
			local v3507 = #t222

			if v3507 == 0 or v3490(v3506 - t222[v3507]).Magnitude > 0.3 then
				if v3507 >= 2 then
					if v3490(t222[v3507] - t222[v3507 - 1]).Unit:Dot(v3490(v3506 - t222[v3507]).Unit) > 0.9986 and v3496(v3490(v3506)) == v3496(v3490(t222[v3507])) then
						t222[v3507] = v3506

						continue
					end
				end

				t222[v3507 + 1] = v3506
			end
		end

		local v3508 = #t222
		local t223 = {}
		local t224 = {}
		local t225 = {}

		for i = 1, v3508 - 1 do
			local v3513 = v3490(t222[i + 1] - t222[i])
			local Magnitude = v3513.Magnitude

			t223[i] = v3513.Unit
			t224[i] = Magnitude

			local v3515 = v3490(t222[i])
			local v3516 = v3490(t222[i + 1])

			t225[i] = v3496(v3515) and v3496(v3516) and v3496((v3515 + v3516) / 2)
		end

		local t226 = {}
		local t227 = {}
		local t228 = {}

		v3500 = function(p693)
			local v3520 = t222[p693]
			local v3521 = t223[p693 - 1]
			local v3522 = t223[p693]

			if not v3521 or not v3522 or t228[p693] then
				local v3523 = v3522 or v3521
				local v3524 = v3520 + v3491(v3523) * v3487
				local v3525 = v3520 - v3491(v3523) * v3487

				t226[p693] = v3524
				t227[p693] = v3525

				return
			end

			local v3526 = v3491(v3521) + v3491(v3522)
			local v3527 = v3526.Magnitude > 0.001 and v3526.Unit:Dot(v3491(v3522)) or 0

			if v3527 < 0.34 or t225[p693 - 1] ~= t225[p693] then
				t228[p693] = true

				return v3500(p693)
			end

			local v3528 = v3526.Unit * (v3487 / v3527)

			t226[p693] = v3520 + v3528
			t227[p693] = v3520 - v3528
		end

		for i = 1, v3508 do
			v3500(i)
		end

		local function v3530(p694, p695)
			if t228[p694] then
				return 0, 0
			end

			return (t226[p694] - t222[p694]):Dot(t223[p695]), (t227[p694] - t222[p694]):Dot(t223[p695])
		end

		for i = 1, v3508 - 1 do
			local v3532, v3533 = v3530(i, i)
			local v3534, v3535 = v3530(i + 1, i)

			if t224[i] + math.min(v3534, v3535) < math.max(v3532, v3533) - 0.01 then
				if i > 1 then
					t228[i] = true
					v3500(i)
				end

				if i + 1 < v3508 then
					t228[i + 1] = true
					v3500(i + 1)
				end
			end
		end

		for i = 1, v3508 - 1 do
			if not t225[i] then
				local v3537 = t223[i]
				local v3538, v3539

				if t228[i] or i == 1 then
					v3538 = t222[i] + v3491(v3537) * v3487
					v3539 = t222[i] - v3491(v3537) * v3487
				else
					v3538 = t226[i]
					v3539 = t227[i]
				end

				local v3540, v3541

				if t228[i + 1] or i + 1 == v3508 then
					v3540 = t222[i + 1] + v3491(v3537) * v3487
					v3541 = t222[i + 1] - v3491(v3537) * v3487
				else
					v3540 = t226[i + 1]
					v3541 = t227[i + 1]
				end

				v3494(v3538, v3539, v3541)
				v3494(v3538, v3541, v3540)
			end
		end

		for i = 2, v3508 - 1 do
			if t228[i] and (not t225[i - 1] or not t225[i]) then
				t220[#t220 + 1] = t222[i]
			end
		end

		for i = 1, v3508 - 1 do
			if not t225[i] then
				t221[#t221 + 1] = {
					v3490(t222[i]),
					v3490(t222[i + 1])
				}
			end
		end
	end

	local v3544 = table.clone(t219)

	for _, v in ipairs(t220) do
		t1.Esp.fan(v3544, v, v3487, 16)
	end

	if not t1.Esp.mesh(Folder, "EspPath", v3544) then
		local function v3547(p696, p697)
			local v3548 = t1.Esp.part(Folder, "EspPath", p696, p697)
			local SpecialMesh = Instance.new("SpecialMesh")

			SpecialMesh.MeshType = Enum.MeshType.Wedge
			SpecialMesh.Parent = v3548
		end

		for _, v in ipairs(t219) do
			t1.Esp.wedgeFace(v3547, v[1], v[2], v[3])
		end

		for _, v in ipairs(t220) do
			t1.Esp.part(Folder, "EspPath", Vector3.new(0.1, v3488, v3488), CFrame.new(v) * CFrame.Angles(0, 0, 1.5707963267948966), Enum.PartType.Cylinder)
		end
	end

	if road.gen ~= gen or road.building ~= building then
		pcall(function()
			Folder:Destroy()
		end)

		return false
	end

	Folder.Parent = workspace

	local folder = road.folder

	road.folder = Folder
	road.key = building
	road.building = nil

	if folder and folder ~= Folder then
		pcall(function()
			folder:Destroy()
		end)
	end

	return true
end
t1.Esp.strip = function(p698, p699, p700, p701, p702)
	local v3555 = t1.Esp.stripTris(p700, p701)
	local v3556 = t1.Esp.mesh(p698, p699, v3555, p702)

	if v3556 then
		return { v3556 }
	end

	local t229 = {}

	local function v3558(p703, p704)
		local v3559 = t1.Esp.part(p698, p699, p703, p704)
		local SpecialMesh = Instance.new("SpecialMesh")

		SpecialMesh.MeshType = Enum.MeshType.Wedge
		SpecialMesh.Parent = v3559

		if p702 then
			v3559.Transparency = p702
		end

		t229[#t229 + 1] = v3559
	end

	for _, v in ipairs(v3555) do
		t1.Esp.wedgeFace(v3558, v[1], v[2], v[3])
	end

	return t229
end

do
	t1.Esp.wedgeFace = function(p705, p706, p707, p708)
		local v3563 = p707 - p706
		local v3564 = p708 - p706
		local v3565 = p708 - p707
		local v3566 = v3563:Dot(v3563)
		local v3567 = v3564:Dot(v3564)
		local v3568 = v3565:Dot(v3565)

		if v3567 < v3566 and v3568 < v3566 then
			local v3569 = p708

			p708 = p706
			p706 = v3569
		elseif v3568 < v3567 and v3566 < v3567 then
			local v3570 = p706

			p706 = p707
			p707 = v3570
		end

		local v3571 = p707 - p706
		local v3572 = p708 - p706
		local v3573 = p708 - p707

		if v3571:Cross(v3572).Magnitude < 0.0001 or v3573.Magnitude < 0.001 then
			return
		end

		local Unit = v3572:Cross(v3571).Unit
		local Unit2 = v3573:Cross(Unit).Unit
		local Unit3 = v3573.Unit
		local v3577 = math.abs(v3571:Dot(Unit2))

		if v3577 < 0.02 then
			return
		end

		local v3578 = math.abs(v3571:Dot(Unit3))
		local v3579 = math.abs(v3572:Dot(Unit3))

		if v3578 > 0.02 then
			p705(Vector3.new(0.1, v3577, v3578), CFrame.fromMatrix((p706 + p707) / 2, Unit, Unit2, Unit3))
		end

		if v3579 > 0.02 then
			p705(Vector3.new(0.1, v3577, v3579), CFrame.fromMatrix((p706 + p708) / 2, -Unit, Unit2, -Unit3))
		end
	end
end

t1.Esp.stripTris = function(p709, p710)
	local t230 = {}
	local v3581 = p710 / 2

	local function v3582(p711)
		return Vector3.new(p711.X, 0, p711.Z)
	end
	local function v3583(p712)
		return Vector3.new(-p712.Z, 0, p712.X)
	end

	local t231 = {}

	for _, v in ipairs(p709) do
		local v3587 = #t231

		if v3587 == 0 or v3582(v - t231[v3587]).Magnitude > 0.3 then
			if v3587 >= 2 then
				if v3582(t231[v3587] - t231[v3587 - 1]).Unit:Dot(v3582(v - t231[v3587]).Unit) > 0.9986 then
					t231[v3587] = v

					continue
				end
			end

			t231[v3587 + 1] = v
		end
	end

	local v3588 = #t231

	if v3588 < 2 then
		return t230
	end

	local t232 = {}

	for i = 1, v3588 - 1 do
		t232[i] = v3582(t231[i + 1] - t231[i]).Unit
	end

	local t233 = {}
	local t234 = {}

	for i = 1, v3588 do
		local v3594 = t232[i - 1]
		local v3595 = t232[i]
		local v3596 = v3594 and v3595 and v3583(v3594) + v3583(v3595)

		v3596 = v3596 or nil

		local v3597 = v3596 and v3596.Magnitude > 0.001 and v3596.Unit:Dot(v3583(v3595)) or 0

		if v3596 and v3597 >= 0.34 then
			local v3598 = v3596.Unit * (v3581 / v3597)
			local v3599 = t231[i] - v3598

			t233[i] = t231[i] + v3598
			t234[i] = v3599
		end
	end

	for i = 1, v3588 - 1 do
		local v3601 = t232[i]
		local v3602 = t233[i]
		local v3603 = t234[i]

		if not v3602 then
			v3602 = t231[i] + v3583(v3601) * v3581
			v3603 = t231[i] - v3583(v3601) * v3581
		end

		local v3604 = t233[i + 1]
		local v3605 = t234[i + 1]

		if not v3604 then
			v3604 = t231[i + 1] + v3583(v3601) * v3581
			v3605 = t231[i + 1] - v3583(v3601) * v3581
		end

		t230[#t230 + 1] = {
			v3602,
			v3603,
			v3605
		}
		t230[#t230 + 1] = {
			v3602,
			v3605,
			v3604
		}
	end

	return t230
end
t1.Esp.tileTris = function(p713, p714, p715)
	local tile = p713.tile or t16.PATTERNS.Honeycomb.sites[1][3]
	local dir = p713.dir
	local vector3 = Vector3.new(-dir.Z, 0, dir.X)
	local v3609 = p713.pos + Vector3.new(0, 0.06, 0)
	local t235 = {}

	for i, v in ipairs(tile) do
		t235[i] = v3609 + dir * (v[1] * p714) + vector3 * (v[2] * p714)
	end

	for i = 2, #t235 - 1 do
		p715[#p715 + 1] = {
			t235[1],
			t235[i],
			t235[i + 1]
		}
	end

	return p715
end

do
	t1.Esp.mesh = function(p716, p717, p718, p719)
		if t1.Esp._noMesh or #p718 == 0 then
			return nil
		end

		local u3614

		if pcall(function()
			local AssetService = game:GetService("AssetService")
			local v3616 = AssetService:CreateEditableMesh()
			local vector3 = Vector3.new(math.huge, math.huge, math.huge)
			local vector32 = Vector3.new(-math.huge, -math.huge, -math.huge)

			for _, v in ipairs(p718) do
				for i = 1, 3 do
					vector3 = vector3:Min(v[i])
					vector32 = vector32:Max(v[i])
				end
			end

			local v3622 = (vector3 + vector32) / 2

			for _, v in ipairs(p718) do
				local v3625 = v3616:AddVertex(v[1] - v3622)
				local v3626 = v3616:AddVertex(v[2] - v3622)
				local v3627 = v3616:AddVertex(v[3] - v3622)

				v3616:AddTriangle(v3625, v3626, v3627)
				v3616:AddTriangle(v3625, v3627, v3626)
			end

			u3614 = AssetService:CreateMeshPartAsync(Content.fromObject(v3616))
			u3614.Anchored = true
			u3614.CanCollide = false
			u3614.CanTouch = false
			u3614.CanQuery = false
			u3614.CastShadow = false
			u3614.Material = Enum.Material.Neon
			u3614.Color = v3452(p717)
			u3614.Transparency = p719 or v3454(p717)
			u3614.CFrame = CFrame.new(v3622)
			u3614.Parent = p716
		end) then
			return u3614
		end

		if not pcall(function()
			return game:GetService("AssetService").CreateEditableMesh
		end) then
			t1.Esp._noMesh = true
		end

		if u3614 then
			pcall(function()
				u3614:Destroy()
			end)
		end

		return nil
	end
end

t1.Esp.fan = function(p720, p721, p722, p723, p724)
	for i = 0, p723 - 1 do
		local v3629 = (p724 or 0) + i / p723 * 2 * math.pi
		local v3630 = (p724 or 0) + (i + 1) / p723 * 2 * math.pi

		p720[#p720 + 1] = {
			p721,
			p721 + Vector3.new(math.cos(v3629), 0, math.sin(v3629)) * p722,
			p721 + Vector3.new(math.cos(v3630), 0, math.sin(v3630)) * p722
		}
	end
end

do
	t1.Esp.hexTemplate = function(p725)
		local Esp = t1.Esp
		local hexKey = p725 .. ":" .. tostring(v3452("EspSpots")) .. ":" .. v3454("EspSpots")

		if Esp._hexKey == hexKey then
			local _hex = Esp._hex or nil

			return _hex
		end

		if Esp._hex then
			pcall(function()
				Esp._hex:Destroy()
			end)
		end

		Esp._hexKey = hexKey
		Esp._hex = false

		local v3634 = p725 * 0.42
		local v3635 = v3634 * 2 / math.sqrt(3)
		local Folder = Instance.new("Folder")

		Folder.Name = "BarrageHexTemplate"
		Folder.Parent = workspace

		local vector3 = Vector3.new(1, 0, 0)
		local vector32 = Vector3.new(0, 0, 1)
		local vector33 = Vector3.new(0, 1, 0)
		local v3640 = t1.Esp.part(Folder, "EspSpots", Vector3.new(2 * v3634, 0.06, v3635), CFrame.fromMatrix(Vector3.zero, vector3, vector33, vector32))
		local t236 = {}

		for _, v in ipairs({
			1,
			-1
		}) do
			for _, v2 in ipairs({
				1,
				-1
			}) do
				local v3646 = vector3 * v2
				local v3647 = vector32 * v
				local v3648 = t1.Esp.part(Folder, "EspSpots", Vector3.new(0.06, v3634, v3635 / 2), CFrame.fromMatrix(v3647 * (v3635 / 2) + v3646 * (v3634 / 2) + v3647 * (v3635 / 4), v3646:Cross(-v3647), v3646, -v3647))
				local SpecialMesh = Instance.new("SpecialMesh")

				SpecialMesh.MeshType = Enum.MeshType.Wedge
				SpecialMesh.Parent = v3648
				t236[#t236 + 1] = v3648
			end
		end

		for i, v in ipairs(t236) do
			local WedgePart = Instance.new("WedgePart")

			WedgePart.Anchored = true
			WedgePart.CanCollide = false
			WedgePart.CanTouch = false
			WedgePart.CanQuery = false
			WedgePart.CastShadow = false

			local CFrame_ = v.CFrame

			WedgePart.Size = v.Size
			WedgePart.CFrame = CFrame_
			WedgePart.Parent = Folder
			v:Destroy()
			t236[i] = WedgePart
		end

		local ok, hex = pcall(function()
			return v3640:UnionAsync(t236)
		end)

		if ok and hex then
			hex.Anchored = true
			hex.CanCollide = false
			hex.CanTouch = false
			hex.CanQuery = false
			hex.CastShadow = false
			hex.UsePartColor = true
			hex.Material = Enum.Material.Neon
			hex.Color = v3452("EspSpots")
			hex.Transparency = v3454("EspSpots")
			hex.Parent = nil
			Esp._hex = hex
		end

		Folder:Destroy()

		if Esp._hexKey ~= hexKey then
			return nil
		end

		local _hex = Esp._hex or nil

		return _hex
	end
end

t1._cleanups[#t1._cleanups + 1] = function()
	if t1.Esp._hex then
		pcall(function()
			t1.Esp._hex:Destroy()
		end)
	end

	local Esp = t1.Esp

	t1.Esp._hex = nil
	Esp._hexKey = nil
end

do
	t1.Esp.part = function(p726, p727, p728, p729, p730)
		local Part = Instance.new("Part")

		Part.Anchored = true
		Part.CanCollide = false
		Part.CanTouch = false
		Part.CanQuery = false
		Part.CastShadow = false
		Part.Material = Enum.Material.Neon
		Part.Color = v3452(p727)
		Part.Transparency = v3454(p727)
		Part.Size = p728
		Part.CFrame = p729

		if p730 then
			Part.Shape = p730
		end

		Part.Parent = p726

		return Part
	end
end

t1.Esp.group = function(p731)
	local Folder = Instance.new("Folder")

	Folder.Name = p731
	Folder.Parent = t1.Esp.folder

	return Folder
end

do
	t1.Esp.any = function()
		return t12.EspRoute or t12.EspNodes or t12.EspDirection or t12.EspRanges or t12.EspEnemies or t12.EspSpots or t12.EspGround or t12.EspPath or t12.EspCoverage
	end
end

t1.Esp.box = function(p732, p733, p734)
	local BoxHandleAdornment = Instance.new("BoxHandleAdornment")

	BoxHandleAdornment.Adornee = p734
	BoxHandleAdornment.Size = p734.Size
	BoxHandleAdornment.Color3 = v3452(p733)
	BoxHandleAdornment.Transparency = p733 == "EspGround" and t12.EspGroundOutline == true and math.max(v3454(p733), 0.85) or v3454(p733)
	BoxHandleAdornment.AlwaysOnTop = false
	BoxHandleAdornment.ZIndex = 1
	BoxHandleAdornment.Parent = p732

	return BoxHandleAdornment
end
t1.Esp.light = function(p735, p736, p737)
	if not p736 or not p736.Parent or #t1.Esp.lights >= 30 then
		return
	end

	if not (p736:IsA("Model") or p736:IsA("BasePart")) then
		for _, child in ipairs(p736:GetChildren()) do
			t1.Esp.light(p735, child, p737)
		end

		return
	end

	local Highlight = Instance.new("Highlight")

	Highlight.Adornee = p736
	Highlight.FillColor = v3452(p737 or p735)
	Highlight.OutlineColor = v3452(p737 or p735)
	Highlight.FillTransparency = p735 == "EspGround" and t12.EspGroundOutline == true and 1 or v3454(p735)
	Highlight.OutlineTransparency = math.min(1, v3454(p735) + 0.2)
	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	Highlight.Parent = t1.Esp.folder
	t1.Esp.lights[#t1.Esp.lights + 1] = Highlight
end
t1.Esp.towerGen = 0
t1.Esp.towerLayers = function(p738)
	t1.Esp.towerGen += 1

	local towerGen = t1.Esp.towerGen

	local function v3665()
		return t1.Esp.folder ~= p738 or t1.Esp.towerGen ~= towerGen
	end

	local v3666

	if t12.EspSpots then
		local v3667 = t1.Plan.design()
		local t237 = {}
		local tostring_ = tostring
		local v3670 = t1.Plan.shapeKey(v3667)
		local v3671 = tostring_(v3670)
		local v3672 = v3667
		local concat = table.concat
		local EspSpotKinds = t12.EspSpotKinds or {}

		do
			local values = table.pack(v3671, v3672, concat(EspSpotKinds, ","), tostring(t12.EspSpotLimit), tostring(v3452("EspSpots")), tostring(v3452("EspHillSpots")), tostring(v3454("EspSpots")))

			table.move(values, 1, values.n, 1, t237)
		end

		for _, v in ipairs(t1.Match.towers()) do
			if v.pos then
				t237[#t237 + 1] = math.floor(v.pos.X * 2) .. "," .. math.floor(v.pos.Z * 2)
			end
		end

		v3666 = table.concat(t237, "|")
	end

	local spots = t1.Esp.spots
	local v3679 = v3666 ~= nil and t1.Esp._spotsSig == v3666 and spots ~= nil and spots.Parent ~= nil
	local Ranges = p738:FindFirstChild("Ranges")

	if Ranges then
		Ranges:Destroy()
	end

	if not t12.EspSpots then
		t1.Esp.spotsClear()
	end

	if t12.EspRanges then
		local Ranges2 = t1.Esp.group("Ranges")

		for _, v in ipairs(t1.Match.towers()) do
			local v3684 = t1._n(v.range, t1.Data.range(v.id, v.level))

			if v.pos and v3684 > 0 and t1.Data.role(v.id) ~= "Farm" then
				local v3685 = t1.Place.ground(v.pos.X, v.pos.Z)
				local Y = v3685 and v3685.Y or v.pos.Y

				t1.Esp.part(Ranges2, "EspRanges", Vector3.new(0.1, v3684 * 2, v3684 * 2), CFrame.new(v.pos.X, Y + 0.15, v.pos.Z) * CFrame.Angles(0, 0, 1.5707963267948966), Enum.PartType.Cylinder)
			end
		end
	end

	if t12.EspSpots and not v3679 then
		local Folder = Instance.new("Folder")

		Folder.Name = "BarrageCameramanTowerDefenseSpots"

		local function v3688()
			if v3665() then
				local function v3689()
					Folder:Destroy()
				end

				return pcall(v3689)
			end

			local spots2 = t1.Esp.spots

			Folder.Parent = workspace

			local Esp = t1.Esp
			local v3692 = v3666

			t1.Esp.spots = Folder
			Esp._spotsSig = v3692

			if spots2 and spots2 ~= Folder then
				pcall(function()
					spots2:Destroy()
				end)
			end
		end

		task.spawn(function()
			local v3693 = t1.Match.placed()
			local v3694 = t1.Place.rowPitch()

			if t1.Plan.design() == "Random" then
				v3688()

				return t1._wake("status")
			end

			local v3695 = t1.Plan.shapeSpots(t1.Plan.design())

			t1._wake("status")

			if not v3695 or v3665() then
				return v3688()
			end

			local v3696 = t1._has(t12.EspSpotKinds, "Ground")
			local v3697 = t1._has(t12.EspSpotKinds, "Hill")
			local t238 = {}
			local t239 = {}

			for _, v in ipairs(t1.Plan.drawn(v3695, v3693)) do
				if v.onHill then
					if v3697 then
						t239[#t239 + 1] = v
					end
				elseif v3696 then
					t238[#t238 + 1] = v
				end
			end

			if v3665() then
				return
			end

			local u3702

			local function v3703(p739, p740, p741)
				if u3702 == nil then
					u3702 = t1.Esp.hexTemplate(v3694) or false
				end

				local vector3 = Vector3.new(-p741.Z, 0, p741.X)
				local cFrame = CFrame.fromMatrix(p740, p741, Vector3.new(0, 1, 0), vector3)

				if u3702 then
					local clone = u3702:Clone()

					clone.CFrame = cFrame
					clone.Parent = p739
				else
					local v3707 = v3694 * 0.42
					local v3708 = v3707 * 2 / math.sqrt(3)

					t1.Esp.part(p739, "EspSpots", Vector3.new(2 * v3707, 0.06, v3708), cFrame)

					for _, v in ipairs({
						1,
						-1
					}) do
						for _, v2 in ipairs({
							1,
							-1
						}) do
							local v3713 = p741 * v2
							local v3714 = vector3 * v
							local v3715 = t1.Esp.part(p739, "EspSpots", Vector3.new(0.06, v3707, v3708 / 2), CFrame.fromMatrix(p740 + v3714 * (v3708 / 2) + v3713 * (v3707 / 2) + v3714 * (v3708 / 4), v3713:Cross(-v3714), v3713, -v3714))
							local SpecialMesh = Instance.new("SpecialMesh")

							SpecialMesh.MeshType = Enum.MeshType.Wedge
							SpecialMesh.Parent = v3715
						end
					end
				end
			end

			local v3717 = t1.Plan.design() == "Honeycomb"

			local function v3718(p742, p743)
				if #p742 == 0 or v3665() then
					return
				end

				local v3719 = true

				for i = 1, #p742, 1500 do
					local t240 = {}

					for i2 = i, math.min(i + 1499, #p742) do
						t1.Esp.tileTris(p742[i2], v3694, t240)
					end

					if not t1.Esp.mesh(Folder, p743, t240, v3454("EspSpots")) then
						v3719 = false

						break
					end

					if not v3665() then
						continue
					end

					return
				end

				if v3719 or v3665() then
					return
				end

				for _, child in ipairs(Folder:GetChildren()) do
					if child:IsA("MeshPart") and child.Color == v3452(p743) then
						child:Destroy()
					end
				end

				local Folder2 = Instance.new("Folder")

				Folder2.Name = p743
				Folder2.Parent = Folder

				local function v3726(p744, p745)
					local v3727 = t1.Esp.part(Folder2, "EspSpots", p744, p745)
					local SpecialMesh = Instance.new("SpecialMesh")

					SpecialMesh.MeshType = Enum.MeshType.Wedge
					SpecialMesh.Parent = v3727
				end

				for i, v in ipairs(p742) do
					if v3665() then
						return
					end

					if v3717 then
						v3703(Folder2, v.pos + Vector3.new(0, 0.06, 0), v.dir)
					else
						for _, v2 in ipairs(t1.Esp.tileTris(v, v3694, {})) do
							t1.Esp.wedgeFace(v3726, v2[1], v2[2], v2[3])
						end
					end

					if i % 120 == 0 then
						task.wait()
					end
				end

				if p743 ~= "EspSpots" then
					local v3733 = v3452(p743)

					for _, descendant in ipairs(Folder2:GetDescendants()) do
						if descendant:IsA("BasePart") then
							descendant.Color = v3733
						end
					end
				end
			end

			v3718(t238, "EspSpots")
			v3718(t239, "EspHillSpots")
			v3688()
		end)
	end
end
t1.Esp.run = function()
	if not t1.Esp.any() or t1.Ctx.place() ~= "MATCH" then
		t1.Esp.clear(true)
		t1.Esp.roadClear()

		return t1._wake("status")
	end

	local Esp = t1.Esp

	if Esp.folder then
		Esp.old[#Esp.old + 1] = Esp.folder
	end

	t1._drop(Esp.conns)
	Esp.enemyGroup = nil
	table.clear(Esp.enemyTags)
	Esp.lights = {}

	local v3737 = t1.Paths.get()
	local Folder = Instance.new("Folder")

	Folder.Name = "BarrageCameramanTowerDefenseVisuals"
	Esp.folder = Folder

	local ok, result = pcall(t1.Esp.layers, Folder, v3737)

	if Esp.folder ~= Folder then
		pcall(function()
			Folder:Destroy()
		end)

		return
	end

	Folder.Parent = workspace

	for _, v in ipairs(Esp.old) do
		pcall(function()
			v:Destroy()
		end)
	end

	table.clear(Esp.old)
	t1._wake("status")

	if not ok then
		error(result, 0)
	end
end

do
	t1.Esp.layers = function(p746, p747)
		if p747 and (t12.EspRoute or t12.EspNodes or t12.EspDirection) then
			local Route = t12.EspRoute and t1.Esp.group("Route")
			local Nodes = t12.EspNodes and t1.Esp.group("Nodes")
			local Direction = t12.EspDirection and t1.Esp.group("Direction")
			local vector3 = Vector3.new(0, 0.12, 0)
			local t241 = {}
			local t242 = {}

			for _, path in ipairs(p747.paths) do
				if Nodes then
					for _, point in ipairs(path.points) do
						t1.Esp.fan(t241, t1.Esp.floor(point) + Vector3.new(0, 0.2, 0), 0.8, 4)
					end
				end

				if Route then
					local v3753 = t1.Esp.track(path.points)

					for i, v in ipairs(v3753) do
						v3753[i] = v + vector3
					end

					t1.Esp.strip(Route, "EspRoute", v3753, 0.35)
				end

				local points = path.points

				for i = 1, #points - 1 do
					local v3758 = points[i]
					local v3759 = points[i + 1]
					local Magnitude = t1._flat(v3759 - v3758).Magnitude

					if Direction and Magnitude > 0.05 then
						local Unit = t1._flat(v3759 - v3758).Unit
						local vector32 = Vector3.new(-Unit.Z, 0, Unit.X)

						for i2 = 4, Magnitude, 8 do
							local v3764 = t1.Esp.floor(v3758:Lerp(v3759, i2 / Magnitude)) + Vector3.new(0, 0.25, 0)

							t242[#t242 + 1] = {
								v3764 + Unit * 0.8,
								v3764 - Unit * 0.8 + vector32 * 0.6,
								v3764 - Unit * 0.8 - vector32 * 0.6
							}
						end
					end
				end

				local BillboardGui = Instance.new("BillboardGui")

				BillboardGui.Name = "Path" .. path.id
				BillboardGui.AlwaysOnTop = true
				BillboardGui.Size = t1.Esp.TAG.lane
				BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)
				BillboardGui.SizeOffset = Vector2.new(0, 0.5)

				local TextLabel = Instance.new("TextLabel")

				TextLabel.BackgroundTransparency = 1
				TextLabel.Size = UDim2.fromScale(1, 1)
				TextLabel.Font = Enum.Font.GothamBold
				TextLabel.TextScaled = true
				TextLabel.TextStrokeTransparency = 0.4
				TextLabel.TextColor3 = v3452(Route and "EspRoute" or Nodes and "EspNodes" or "EspDirection")
				TextLabel.Text = "Path " .. path.id
				t1.Esp.cap(TextLabel).Parent = BillboardGui

				local v3767 = t1.Esp.part(Route or Nodes or Direction, Route and "EspRoute" or Nodes and "EspNodes" or "EspDirection", Vector3.new(0.2, 0.2, 0.2), CFrame.new(t1.Esp.floor(path.entry) + vector3))

				v3767.Transparency = 1
				BillboardGui.Adornee = v3767
				BillboardGui.Parent = v3767
			end

			if Nodes and #t241 > 0 and not t1.Esp.mesh(Nodes, "EspNodes", t241) then
				for _, path in ipairs(p747.paths) do
					for _, point in ipairs(path.points) do
						t1.Esp.part(Nodes, "EspNodes", Vector3.new(1.4, 1.4, 1.4), CFrame.new(t1.Esp.floor(point) + Vector3.new(0, 0.7, 0)), Enum.PartType.Ball)
					end
				end
			end

			if Direction and #t242 > 0 and not t1.Esp.mesh(Direction, "EspDirection", t242) then
				local function v3772(p748, p749)
					local v3773 = t1.Esp.part(Direction, "EspDirection", p748, p749)
					local SpecialMesh = Instance.new("SpecialMesh")

					SpecialMesh.MeshType = Enum.MeshType.Wedge
					SpecialMesh.Parent = v3773
				end

				for _, v in ipairs(t242) do
					t1.Esp.wedgeFace(v3772, v[1], v[2], v[3])
				end
			end
		end

		if p747 and t12.EspCoverage then
			local Coverage = t1.Esp.group("Coverage")
			local v3778, v3779 = t1.Cover.window()
			local v3780 = v3778 or 0
			local v3781 = v3779 or 1
			local v3782 = t1.Paths.selected()
			local vector3 = Vector3.new(0, 0.16, 0)
			local t243 = {}
			local t244 = {}
			local t245 = {}

			local function v3787(p750)
				if #t243 >= 2 then
					for _, v in ipairs(t1.Esp.stripTris(t243, 1.2)) do
						local v3790 = p750 and t245 or t244

						v3790[#v3790 + 1] = v
					end
				end

				t243 = {}
			end

			for _, path in ipairs(p747.paths) do
				local v3793 = v3782 ~= nil and not v3782[path.index]
				local samples = path.samples

				for i = 1, #samples - 1 do
					local v3796 = samples[i]
					local v3797 = samples[i + 1]
					local v3798 = t1.Esp.floor(v3796.pos)
					local v3799 = t1.Esp.floor(v3797.pos)

					if v3780 <= v3796.progress and v3797.progress <= v3781 and (v3799 - v3798).Magnitude > 0.05 then
						t243[#t243 + 1] = v3798 + vector3
						t243[#t243 + 1] = v3799 + vector3
					else
						v3787(v3793)
					end
				end

				v3787(v3793)
			end

			local EspCoverage = v3454("EspCoverage")

			for _, v in ipairs({
				{
					t244,
					EspCoverage
				},
				{
					t245,
					1 - (1 - EspCoverage) * 0.35
				}
			}) do
				local v3803 = v[1]
				local v3804 = v[2]

				if #v3803 > 0 and not t1.Esp.mesh(Coverage, "EspCoverage", v3803, v3804) then
					local function v3805(p751, p752)
						local v3806 = t1.Esp.part(Coverage, "EspCoverage", p751, p752)

						v3806.Transparency = v3804

						local SpecialMesh = Instance.new("SpecialMesh")

						SpecialMesh.MeshType = Enum.MeshType.Wedge
						SpecialMesh.Parent = v3806
					end

					for _, v2 in ipairs(v3803) do
						t1.Esp.wedgeFace(v3805, v2[1], v2[2], v2[3])
					end
				end
			end
		end

		pcall(t1.Esp.towerLayers, p746)

		if t12.EspGround and t1._has(t12.EspGroundKinds, "Ground") then
			local Ground = t1.Esp.group("Ground")
			local v3811 = t1.Place.folders()
			local descendants = v3811 and v3811:GetDescendants() or {}

			if v3811 and v3811:IsA("BasePart") then
				descendants[#descendants + 1] = v3811
			end

			local n84 = 0

			for _, descendant in ipairs(descendants) do
				if descendant:IsA("BasePart") and n84 < 600 then
					n84 += 1
					t1.Esp.box(Ground, "EspGround", descendant)
				end
			end
		end

		if t12.EspPath then
			t1.Esp.ribbon(p747)
		else
			t1.Esp.roadClear()
		end

		if t12.EspEnemies then
			t1.Esp.enemyGroup = t1.Esp.group("Enemies")
			t1.Esp.enemies()

			local Generation = t1.Generation

			task.spawn(function()
				while t1.Running and Generation == t1.Generation and t12.EspEnemies and t1.Esp.folder == p746 do
					task.wait(next(t1.Esp.enemyTags) ~= nil and 0.2 or 1)
					pcall(t1.Esp.enemies)
				end
			end)
		end
	end
end

do
	t1._wakeHandlers.esp = function()
		t1._wakeThrottled("espBuild", 0.5)
	end
end

t1._wakeHandlers.espBuild = t1.Esp.run
t1._wakeHandlers.espTowers = function()
	local folder = t1.Esp.folder

	if folder then
		if folder.Parent and t1.Ctx.place() == "MATCH" then
			t1.Esp.towerLayers(folder)
		else
			t1._wakeThrottled("espBuild", 0.5)
		end
	else
		t1._wakeThrottled("espBuild", 0.5)

		return
	end
end
t1.Vis = {
	conns = {},
	ringConns = {},
	ring = nil,
	mapConns = {},
	veiled = setmetatable({}, {
		__mode = "k"
	}),
	mapGen = 0,
	mapN = 0,
	mapOn = false,
	mapGame = nil,
	render = false,
	cover = nil,
	capped = false,
	KEEP = {
		Waypoints = true,
		TowerArea = true,
		Towers = true,
		PlacingTowers = true,
		Enemies = true,
		Units = true,
		Base = true,
		Paths = true
	}
}
t1.Vis.blackOff = function()
	local Vis = t1.Vis

	if Vis.render then
		Vis.render = false
		pcall(RunService.Set3dRenderingEnabled, RunService, true)
	end

	if Vis.cover then
		pcall(function()
			Vis.cover:Destroy()
		end)
		Vis.cover = nil
	end
end
t1.Vis.capOff = function()
	if t1.Vis.capped then
		t1.Vis.capped = false
		pcall(setfpscap, 0)
	end
end

do
	t1.Vis.makeCover = function()
		local parent = type(gethui) == "function" and select(2, pcall(gethui))

		if typeof(parent) ~= "Instance" then
			return nil
		end

		local ScreenGui = Instance.new("ScreenGui")

		ScreenGui.Name = "BarrageCameramanTowerDefenseBlack"
		ScreenGui.IgnoreGuiInset = true
		ScreenGui.ResetOnSpawn = false
		ScreenGui.DisplayOrder = -1

		local Frame = Instance.new("Frame")

		Frame.Size = UDim2.fromScale(1, 1)
		Frame.BackgroundColor3 = Color3.new(0, 0, 0)
		Frame.BorderSizePixel = 0
		Frame.Parent = ScreenGui

		local TextLabel = Instance.new("TextLabel")

		TextLabel.BackgroundTransparency = 1
		TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		TextLabel.Position = UDim2.fromScale(0.5, 0.5)
		TextLabel.Size = UDim2.fromScale(0.6, 0.06)
		TextLabel.Font = Enum.Font.GothamMedium
		TextLabel.TextScaled = true
		TextLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
		TextLabel.Text = "Black Screen is on. Switch it off in Settings > Performance."
		TextLabel.Parent = Frame
		ScreenGui.Parent = parent

		return ScreenGui
	end
end

do
	t1.Vis.spared = function(p753)
		if not (p753:IsA("Camera") or p753:IsA("Terrain")) then
			if p753.Name:sub(1, 7) ~= "Barrage" then
				if p753:IsA("Model") and (Players:GetPlayerFromCharacter(p753) or p753:FindFirstChildOfClass("Humanoid")) then
					return true
				end

				return false
			end
		end

		return true
	end
end

t1.Vis.hide = function(p754)
	local Vis = t1.Vis

	if Vis.veiled[p754] ~= nil then
		return
	end

	if p754:IsA("BasePart") then
		local Size = p754.Size
		local v3825 = math.min(Size.X, Size.Z)

		if v3825 >= 12 and Size.Y <= v3825 * 0.25 then
			return
		end
	elseif not p754:IsA("Decal") then
		return
	end

	Vis.veiled[p754] = p754.LocalTransparencyModifier
	p754.LocalTransparencyModifier = 1
	Vis.mapN += 1
end
t1.Vis.mapOff = function()
	local Vis = t1.Vis

	Vis.mapGen += 1
	t1._drop(Vis.mapConns)

	for k, v in pairs(Vis.veiled) do
		if k.Parent then
			pcall(function()
				k.LocalTransparencyModifier = v
			end)
		end
	end

	table.clear(Vis.veiled)
	Vis.mapOn = false
	Vis.mapGame = nil
	Vis.mapN = 0
end

do
	t1.Vis.veil = function(p755, p756)
		local Vis = t1.Vis

		t1._conn(p755.DescendantAdded, function(p757)
			task.defer(function()
				if Vis.mapGen == p756 and p757.Parent then
					pcall(Vis.hide, p757)
				end
			end)
		end, Vis.mapConns)

		local descendants = p755:GetDescendants()

		descendants[#descendants + 1] = p755
		task.spawn(function()
			local now = os.clock()

			for _, descendant in ipairs(descendants) do
				if not t1.Running or Vis.mapGen ~= p756 then
					return
				end

				pcall(Vis.hide, descendant)

				if os.clock() - now > 0.004 then
					task.wait()
					now = os.clock()
				end
			end

			t1._wake("status")
		end)
	end
end

t1.Vis.mapRun = function()
	local Vis = t1.Vis
	local v3835 = t12.DeleteMap == true and t1.Ctx.inMatch()
	local Game = workspace:FindFirstChild("Game")

	if v3835 and Vis.mapOn and Vis.mapGame == Game then
		return
	end

	Vis.mapOff()

	if not v3835 then
		return
	end

	Vis.mapOn = true
	Vis.mapGame = Game

	local mapGen = Vis.mapGen

	local function v3838(p758)
		if p758 == Game or Vis.spared(p758) then
			return
		end

		Vis.veil(p758, mapGen)
	end

	t1._conn(workspace.ChildAdded, function(p759)
		if p759.Name == "Game" then
			return t1._wake("vis")
		end

		task.defer(function()
			if Vis.mapGen == mapGen and p759.Parent == workspace then
				pcall(v3838, p759)
			end
		end)
	end, Vis.mapConns)

	for _, child in ipairs(workspace:GetChildren()) do
		pcall(v3838, child)
	end

	if not Game then
		return
	end

	local function v3841(p760)
		if not Vis.KEEP[p760.Name] then
			Vis.veil(p760, mapGen)
		end
	end

	t1._conn(Game.ChildAdded, function(p761)
		task.defer(function()
			if Vis.mapGen == mapGen and p761.Parent == Game then
				pcall(v3841, p761)
			end
		end)
	end, Vis.mapConns)
	t1._conn(Game.AncestryChanged, function()
		if Game.Parent ~= workspace then
			t1._wake("vis")
		end
	end, Vis.mapConns)

	for _, child in ipairs(Game:GetChildren()) do
		pcall(v3841, child)
	end
end

do
	t1.Vis.black = function()
		return t12.BlackScreen == true and (t12.BlackScreenWhen ~= "When Unfocused" or t1.Vis.unfocused == true)
	end
end

t1._conn(UserInputService.WindowFocusReleased, function()
	t1.Vis.unfocused = true

	if t12.BlackScreen then
		t1._wake("vis")
	end
end)
t1._conn(UserInputService.WindowFocused, function()
	t1.Vis.unfocused = false

	if t12.BlackScreen then
		t1._wake("vis")
	end
end)
t1.Vis.run = function()
	local Vis = t1.Vis

	if not t1.Running then
		return
	end

	local v3845 = Vis.black()

	if v3845 and not Vis.render then
		Vis.render = pcall(RunService.Set3dRenderingEnabled, RunService, false)

		if not Vis.cover then
			Vis.cover = Vis.makeCover()
		end
	elseif not v3845 and (Vis.render or Vis.cover) then
		Vis.blackOff()
	end

	local v3846 = t1._n(t12.FpsCap, 0)

	if v3846 > 0 and type(setfpscap) == "function" then
		Vis.capped = pcall(setfpscap, v3846)
	else
		Vis.capOff()
	end

	Vis.mapRun()
	t1._wake("status")
end
t1.Vis.ringOff = function()
	local Vis = t1.Vis

	t1._drop(Vis.ringConns)

	if Vis.ring then
		pcall(function()
			Vis.ring:Destroy()
		end)
	end

	Vis.ring = nil
end

do
	t1.Vis.ghostId = function(p762)
		if t1.towerCfg(p762.Name) then
			return p762.Name
		end

		for _, v in ipairs(t1.Match.slots()) do
			local v3850 = t1.towerCfg(v.id)

			if v3850 and typeof(v3850.Model) == "Instance" and v3850.Model.Name == p762.Name then
				return v.id
			end
		end

		return nil
	end
end

do
	t1.Vis.track = function(p763)
		local Vis = t1.Vis

		if not p763:IsA("Model") then
			return
		end

		local v3852 = Vis.ghostId(p763)

		if not v3852 then
			return
		end

		local v3853 = t1.Data.range(v3852, 1)
		local v3854 = t1.Data.range(v3852, t1.Data.maxLevel(v3852))

		if not (v3854 > 0) or not (v3853 + 0.05 < v3854) then
			return
		end

		Vis.ringOff()

		local cFrame = CFrame.Angles(0, 0, 1.5707963267948966)
		local v3856 = t1.Esp.part(workspace, "EspMaxRange", Vector3.new(0.1, v3854 * 2, v3854 * 2), p763:GetPivot() * cFrame, Enum.PartType.Cylinder)

		v3856.Name = "BarrageCameramanTowerDefenseMaxRange"
		Vis.ring = v3856
		t1._conn(RunService.Heartbeat, function()
			if not p763.Parent then
				return Vis.ringOff()
			end

			local ok, result, result2 = pcall(p763.GetBoundingBox, p763)
			local Position = p763:GetPivot().Position

			v3856.CFrame = CFrame.new(Position.X, (ok and result.Position.Y - result2.Y / 2 or Position.Y) + 0.05, Position.Z) * cFrame
		end, Vis.ringConns)
	end
end

do
	t1.Vis.ringRun = function()
		local Vis = t1.Vis

		t1._drop(Vis.conns)
		Vis.ringOff()

		if not t1.Running or t12.EspMaxRange ~= true or t1.Ctx.place() ~= "MATCH" then
			return
		end

		local v3862 = t1._at(workspace, "Game.PlacingTowers")

		if not v3862 then
			t1._conn((workspace:FindFirstChild("Game") or workspace).ChildAdded, function(p764)
				if p764.Name == "PlacingTowers" or p764.Name == "Game" then
					t1._wake("placering")
				end
			end, Vis.conns)

			return
		end

		t1._conn(v3862.ChildAdded, function(p765)
			task.defer(function()
				if t1.Running and t12.EspMaxRange == true then
					pcall(Vis.track, p765)
				end
			end)
		end, Vis.conns)
		t1._conn(v3862.ChildRemoved, function()
			if #v3862:GetChildren() == 0 then
				Vis.ringOff()
			end
		end, Vis.conns)

		for _, child in ipairs(v3862:GetChildren()) do
			pcall(Vis.track, child)
		end
	end
end

do
	t1.Vis.clear = function()
		t1._drop(t1.Vis.conns)
		t1.Vis.ringOff()
		t1.Vis.blackOff()
		t1.Vis.capOff()
		t1.Vis.mapOff()
	end
end

do
	t1.Vis.any = function()
		return t12.BlackScreen == true or t12.DeleteMap == true or t1._n(t12.FpsCap, 0) > 0
	end
end

t1.Vis.live = function()
	local Vis = t1.Vis
	local t246 = {}

	if t12.BlackScreen == true then
		t246[#t246 + 1] = not Vis.black() and "3D Off When Unfocused" or Vis.render and "3D Off" or "3D Off Unsupported"
	end

	if t12.DeleteMap == true then
		t246[#t246 + 1] = not t1.Ctx.inMatch() and "Map In Match Only" or Vis.mapN .. " Map Parts Hidden"
	end

	local v3867 = t1._n(t12.FpsCap, 0)

	if v3867 > 0 then
		t246[#t246 + 1] = type(setfpscap) == "function" and v3867 .. " FPS Cap" or "FPS Cap Unsupported"
	end

	if #t246 == 0 then
		return "[IDLE]"
	end

	return "[ACTIVE] Performance | " .. table.concat(t246, ", ")
end
t1._wakeHandlers.vis = t1.Vis.run
t1._wakeHandlers.placering = t1.Vis.ringRun
t1._allWorkers[#t1._allWorkers + 1] = "vis"
t1._allWorkers[#t1._allWorkers + 1] = "placering"
t1._cleanups[#t1._cleanups + 1] = t1.Vis.clear

do
	t1.Esp.enemies = function()
		local enemyGroup = t1.Esp.enemyGroup

		if not enemyGroup or not enemyGroup.Parent then
			return
		end

		local t247 = {}
		local v3870 = t1._set(t12.EspEnemyDetail)
		local Distance = v3870.Distance and t1._hrp()

		for _, v in ipairs(t1.Match.enemies()) do
			local rec = v.rec
			local PrimaryPart = rec.PrimaryPart or rec:FindFirstChild("HumanoidRootPart") or rec:FindFirstChildWhichIsA("BasePart")

			if PrimaryPart and PrimaryPart:IsA("BasePart") then
				t247[v.id] = true

				local BillboardGui = t1.Esp.enemyTags[v.id]

				if not BillboardGui or not BillboardGui.Parent then
					BillboardGui = Instance.new("BillboardGui")
					BillboardGui.Size = t1.Esp.TAG.enemy

					local ok, result, result2 = pcall(rec.GetBoundingBox, rec)

					BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, (ok and math.clamp(result.Y + result2.Y / 2 - PrimaryPart.Position.Y, 0.5, 12) or 3) + 0.6, 0)
					BillboardGui.SizeOffset = Vector2.new(0, 0.5)
					BillboardGui.AlwaysOnTop = true
					BillboardGui.LightInfluence = 0

					local TextLabel = Instance.new("TextLabel")

					TextLabel.Name = "Info"
					TextLabel.Size = UDim2.fromScale(1, 1)
					TextLabel.BackgroundTransparency = 1
					TextLabel.Font = Enum.Font.GothamBold
					TextLabel.TextScaled = true
					TextLabel.TextStrokeTransparency = 0.4
					t1.Esp.cap(TextLabel).Parent = BillboardGui
					BillboardGui.Parent = enemyGroup
					t1.Esp.enemyTags[v.id] = BillboardGui
				end

				if BillboardGui.Adornee ~= PrimaryPart then
					BillboardGui.Adornee = PrimaryPart
				end

				local Info = BillboardGui:FindFirstChild("Info")
				local text = (v3870.Tags and v.boss and "[BOSS] " or "") .. v.name

				if v3870.Health then
					text ..= " | " .. t1._fmt(v.hp) .. "/" .. t1._fmt(v.maxHp)
				end

				if Distance then
					text ..= " | " .. math.floor((Distance.Position - PrimaryPart.Position).Magnitude) .. "m"
				end

				local EspEnemies = v3452("EspEnemies")
				local EspEnemies2 = v3454("EspEnemies")

				if Info.TextColor3 ~= EspEnemies then
					Info.TextColor3 = EspEnemies
				end

				if Info.TextTransparency ~= EspEnemies2 then
					Info.TextTransparency = EspEnemies2
				end

				if Info.Text ~= text then
					Info.Text = text
				end
			end
		end

		for k, enemyTag in pairs(t1.Esp.enemyTags) do
			if not t247[k] then
				enemyTag:Destroy()
				t1.Esp.enemyTags[k] = nil
			end
		end
	end
end

t1.Ghost = {
	lifts = setmetatable({}, {
		__mode = "k"
	}),
	tops = setmetatable({}, {
		__mode = "k"
	}),
	mids = setmetatable({}, {
		__mode = "k"
	}),
	orig = setmetatable({}, {
		__mode = "k"
	})
}

do
	t1.Ghost.make = function(p766, p767, p768)
		local v3887 = t1.towerCfg(p766)
		local Model = v3887 and v3887.Model

		if not (typeof(Model) == "Instance" and Model:IsA("Model")) then
			return nil
		end

		local Archivable = Model.Archivable

		if not Archivable then
			pcall(function()
				Model.Archivable = true
			end)
		end

		local ok, result = pcall(Model.Clone, Model)

		if not Archivable then
			pcall(function()
				Model.Archivable = false
			end)
		end

		if not ok or typeof(result) ~= "Instance" then
			return nil
		end

		Model = result
		Model.Name = "BarrageCameramanTowerDefenseGhost"

		local orig = t1.Ghost.orig

		for _, descendant in ipairs(Model:GetDescendants()) do
			if descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Light") or descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Sparkles") or descendant:IsA("BillboardGui") or descendant:IsA("ProximityPrompt") or descendant:IsA("Highlight") then
				pcall(descendant.Destroy, descendant)
			elseif descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanTouch = false
				descendant.CanQuery = false
				descendant.CastShadow = false
				orig[descendant] = descendant.Name == "_hitbox" and 1 or descendant.Transparency
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				orig[descendant] = descendant.Transparency
			elseif descendant:IsA("Humanoid") then
				descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				descendant.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			end
		end

		t1.Ghost.fade(Model, p768 or 0.5)

		local pivot = Model:GetPivot()
		local v3896
		local v3897

		for _, descendant in ipairs(Model:GetDescendants()) do
			local v3900 = orig[descendant]

			if v3900 and v3900 < 1 and descendant:IsA("BasePart") then
				local CFrame_ = descendant.CFrame
				local v3902 = descendant.Size / 2
				local RightVector = CFrame_.RightVector
				local UpVector = CFrame_.UpVector
				local LookVector = CFrame_.LookVector
				local vector3 = Vector3.new(math.abs(RightVector.X) * v3902.X + math.abs(UpVector.X) * v3902.Y + math.abs(LookVector.X) * v3902.Z, math.abs(RightVector.Y) * v3902.X + math.abs(UpVector.Y) * v3902.Y + math.abs(LookVector.Y) * v3902.Z, math.abs(RightVector.Z) * v3902.X + math.abs(UpVector.Z) * v3902.Y + math.abs(LookVector.Z) * v3902.Z)

				v3896 = v3896 and v3896:Min(CFrame_.Position - vector3) or CFrame_.Position - vector3
				v3897 = v3897 and v3897:Max(CFrame_.Position + vector3) or CFrame_.Position + vector3
			end
		end

		if not v3896 then
			local ok2, result2, result3 = pcall(Model.GetBoundingBox, Model)

			if ok2 then
				v3896 = result2.Position - result3 / 2
				v3897 = result2.Position + result3 / 2
			end
		end

		if v3896 then
			t1.Ghost.lifts[Model] = pivot.Y - v3896.Y
			t1.Ghost.tops[Model] = v3897.Y - pivot.Y

			local v3910 = pivot:PointToObjectSpace((v3896 + v3897) / 2)

			t1.Ghost.mids[Model] = Vector3.new(v3910.X, 0, v3910.Z)
		else
			t1.Ghost.lifts[Model] = 0
		end

		return Model
	end
end

t1.Ghost.fade = function(p769, p770)
	local orig = t1.Ghost.orig

	for _, descendant in ipairs(p769:GetDescendants()) do
		local v3914 = orig[descendant]

		if v3914 then
			descendant.Transparency = 1 - (1 - v3914) * (1 - p770)
		end
	end
end

do
	t1.Ghost.outline = function(p771, p772)
		local BarrageOutline = p771:FindFirstChild("BarrageOutline")

		if not BarrageOutline then
			BarrageOutline = Instance.new("Highlight")
			BarrageOutline.Name = "BarrageOutline"
			BarrageOutline.FillTransparency = 1
			BarrageOutline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			BarrageOutline.Adornee = p771
			BarrageOutline.Parent = p771
		end

		BarrageOutline.OutlineColor = p772
		BarrageOutline.FillColor = p772

		return BarrageOutline
	end
end

t1.Ghost.put = function(p773, p774, p775)
	local v3916 = p774 + Vector3.new(0, t1.Ghost.lifts[p773] or 0, 0)

	p773:PivotTo(CFrame.lookAt(v3916, v3916 + t1.Place.look(p775), Vector3.yAxis))
end

do
	t1.Ghost.folder = function()
		local _folder = t1.Ghost._folder

		if _folder and _folder.Parent then
			return _folder
		end

		local Folder = Instance.new("Folder")

		Folder.Name = "BarrageCameramanTowerDefenseGhosts"
		Folder.Parent = workspace
		t1.Ghost._folder = Folder

		return Folder
	end
end

t1.Ghost.tag = function(p776, p777)
	local Part = Instance.new("Part")

	Part.Name = p776
	Part.Anchored = true
	Part.CanCollide = false
	Part.CanTouch = false
	Part.CanQuery = false
	Part.CastShadow = false
	Part.Transparency = 1
	Part.Size = Vector3.new(0.05, 0.05, 0.05)

	local BillboardGui = Instance.new("BillboardGui")

	BillboardGui.Name = "Info"
	BillboardGui.Size = p777
	BillboardGui.SizeOffset = Vector2.new(0, 0.5)
	BillboardGui.AlwaysOnTop = true
	BillboardGui.LightInfluence = 0
	BillboardGui.Adornee = Part

	local TextLabel = Instance.new("TextLabel")

	TextLabel.Name = "Info"
	TextLabel.Size = UDim2.fromScale(1, 1)
	TextLabel.BackgroundTransparency = 1
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.TextXAlignment = Enum.TextXAlignment.Center
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.TextScaled = true
	TextLabel.TextStrokeTransparency = 0.4
	t1.Esp.cap(TextLabel).Parent = BillboardGui
	BillboardGui.Parent = Part

	return Part, TextLabel
end

do
	t1.Ghost.tagAt = function(p778, p779, p780)
		local vector3

		if p779 and t1.Ghost.tops[p779] then
			local pivot = p779:GetPivot()
			local v3924 = pivot:PointToWorldSpace(t1.Ghost.mids[p779] or Vector3.zero)

			vector3 = Vector3.new(v3924.X, pivot.Y + t1.Ghost.tops[p779] + 0.8, v3924.Z)
		elseif p779 then
			local ok, result, result2 = pcall(p779.GetBoundingBox, p779)

			if ok then
				vector3 = Vector3.new(result.X, result.Y + result2.Y / 2 + 0.8, result.Z)
			end
		end

		p778.CFrame = CFrame.new(vector3 or p780 + Vector3.new(0, 3, 0))
	end
end

t1.Plan.alpha = function()
	return math.clamp(t1._n(t12.SmartDeployPreviewTransparency, 50), 0, 90) / 100
end
t1.Plan.faded = setmetatable({}, {
	__mode = "k"
})
t1.Plan.fade = function()
	local model = t1.Plan.shown and t1.Plan.shown.model

	if not model then
		return
	end

	local v3929 = t1.Plan.alpha()

	t1.Ghost.fade(model, v3929)
	t1.Plan.faded[model] = v3929
end

do
	t1.Plan.text = function(p781, p782)
		return tostring(p781.tag or p781.name or "Unit") .. (p782 and p782 ~= "" and "\n" .. p782 or "")
	end
end

t1.Plan.label = function(p783, p784)
	local Plan = t1.Plan

	if not Plan.anchor or not Plan.anchor.Parent then
		local BarrageCameramanTowerDefenseNextTag, v3932 = t1.Ghost.tag("BarrageCameramanTowerDefenseNextTag", t1.Esp.TAG.next)

		Plan.anchor = BarrageCameramanTowerDefenseNextTag
		Plan.anchorText = v3932
	end

	t1.Ghost.tagAt(Plan.anchor, p784, p783)
	Plan.anchor.Parent = t1.Ghost.folder()
end

do
	t1.Plan.say = function(p785)
		local Plan = t1.Plan
		local anchorText = Plan.anchor and Plan.anchor.Parent and Plan.anchorText

		if anchorText then
			anchorText.Text = p785
			anchorText.TextColor3 = v3452("EspCoverage")
		end
	end
end

t1.Plan.show = function(p786, p787, p788)
	local Plan = t1.Plan

	Plan.mark = true

	if not t12.SmartDeployPreview or not t1.Running or not p787 or not p787.pos then
		return t1.Plan.hide()
	end

	local shown = Plan.shown

	if not shown or shown.id ~= p786.id or shown.key ~= p787.key then
		if shown and shown.id ~= p786.id then
			t1.Plan.hide()
		end

		local v3937 = Plan.ghosts[p786.id]

		if not v3937 then
			if (Plan.ghostFail[p786.id] or 0) <= os.clock() then
				v3937 = t1.Ghost.make(p786.id, p786.entry, t1.Plan.alpha())

				if v3937 then
					Plan.faded[v3937] = t1.Plan.alpha()

					local n85 = 0

					for _ in pairs(Plan.ghosts) do
						n85 += 1
					end

					if n85 >= 8 then
						for k, ghost in pairs(Plan.ghosts) do
							pcall(ghost.Destroy, ghost)
							Plan.ghosts[k] = nil
						end
					end

					Plan.ghosts[p786.id] = v3937
				else
					Plan.ghostFail[p786.id] = os.clock() + 30
				end
			end
		end

		if not t12.SmartDeployPreview or not t1.Running then
			return t1.Plan.hide()
		end

		if v3937 then
			local v3942 = t1.Plan.alpha()

			if Plan.faded[v3937] ~= v3942 then
				t1.Ghost.fade(v3937, v3942)
				Plan.faded[v3937] = v3942
			end

			t1.Ghost.put(v3937, p787.pos, p787.rot or t1.Place.yaw(p787.pos))
			v3937.Parent = t1.Ghost.folder()
		end

		Plan.shown = {
			id = p786.id,
			key = p787.key,
			model = v3937,
			pos = p787.pos
		}
	end

	Plan.shown.saving = nil
	Plan.shown.text = t1.Plan.text(p786, p788)
	t1.Plan.extras()
end

do
	t1.Plan.cash = function()
		local shown = t1.Plan.shown
		local saving = shown and shown.saving

		if not saving then
			return
		end

		shown.text = t1.Plan.text(saving, "Saving " .. t1._fmt(t1.Match.cash()) .. "/" .. t1._fmt(saving.cost))
		t1.Plan.say(shown.text)
	end
end

do
	t1.Plan.extras = function()
		local Plan = t1.Plan
		local shown = Plan.shown

		if not shown then
			return
		end

		local v3947 = t1._set(type(t12.SmartDeployPreviewShow) == "table" and t12.SmartDeployPreviewShow or {})
		local model = shown.model

		if model then
			local BarrageOutline = model:FindFirstChild("BarrageOutline")

			if v3947.Highlight then
				local v3950 = t1.Ghost.outline(model, v3452("EspCoverage"))

				v3950.FillTransparency = 0.75
				v3950.DepthMode = Enum.HighlightDepthMode.Occluded
			elseif BarrageOutline then
				pcall(BarrageOutline.Destroy, BarrageOutline)
			end
		end

		if v3947.Text then
			t1.Plan.label(shown.pos, model)
			t1.Plan.say(shown.text or "")
		elseif Plan.anchor then
			pcall(function()
				Plan.anchor:Destroy()
			end)
			Plan.anchor = nil
			Plan.anchorText = nil
		end
	end
end

t1.Plan.hide = function()
	local Plan = t1.Plan

	if Plan.shown and Plan.shown.model then
		Plan.shown.model.Parent = nil
	end

	if Plan.anchor then
		pcall(function()
			Plan.anchor:Destroy()
		end)
	end

	Plan.anchor = nil
	Plan.anchorText = nil
	Plan.shown = nil
	Plan._prevKey = nil
end
t1.Plan.preview = function(p789, p790)
	if not t12.SmartDeployPreview or not p789 then
		return
	end

	local Plan = t1.Plan
	local v3953 = "Saving " .. t1._fmt(t1.Match.cash()) .. "/" .. t1._fmt(p789.cost)
	local prevKey = tostring(p789.id) .. ":" .. #p790 .. ":" .. t1.Paths.selKey() .. ":" .. t1.Cover.key() .. ":" .. tostring(t12.PlaceMode) .. ":" .. t1.Paths.rev .. ":" .. tostring(t12.GridDesign)

	if Plan._prevKey == prevKey and Plan.shown and Plan.shown.id == p789.id then
		Plan.mark = true
		Plan.shown.text = t1.Plan.text(p789, v3953)
		Plan.shown.saving = p789
		t1.Plan.say(Plan.shown.text)

		return
	end

	local v3955 = t1.Play.spot(p789, p790)

	t1.Plan.previewSpot = v3955 and {
		id = p789.id,
		spot = v3955,
		map = t1.Match.mapId()
	} or nil

	if v3955 then
		t1.Plan.show(p789, v3955, v3953)

		if Plan.shown then
			Plan.shown.saving = p789
		end

		Plan._prevKey = prevKey
	end
end
t1._cleanups[#t1._cleanups + 1] = function()
	t1.Plan.hide()

	for k, ghost in pairs(t1.Plan.ghosts) do
		pcall(ghost.Destroy, ghost)
		t1.Plan.ghosts[k] = nil
	end

	if t1.Ghost._folder then
		pcall(function()
			t1.Ghost._folder:Destroy()
		end)
	end

	t1.Ghost._folder = nil
end
t1.Pick = {
	slot = nil,
	conns = {},
	owner = {
		text = "[IDLE]"
	},
	textAt = 0
}
t1.Pick.say = function(p791)
	t1.Pick.owner.text = p791
	t1.Pick.textAt = os.clock()
	t1._wake("status")

	local Generation = t1.Generation

	task.delay(6.1, function()
		if t1.Running and Generation == t1.Generation then
			t1._wake("status")
		end
	end)
end

do
	t1.Pick.cancel = function()
		t1._drop(t1.Pick.conns)
		t1.Pick.slot = nil
		pcall(t1.Pick.ghostSync)
		t1._wake("status")
	end
end

t1.Pick.positions = function(p792, p793)
	if type(t12.Positions) ~= "table" then
		t12.Positions = {}
	end

	local v3959 = p792 or t1.Match.mapId()

	if not v3959 then
		return nil
	end

	local v3960 = t12.Positions[v3959]

	if type(v3960) ~= "table" and p793 then
		v3960 = {}
		t12.Positions[v3959] = v3960
	end

	return v3960
end
t1.Pick.unit = function(p794)
	for _, v in ipairs(t1.Match.slots()) do
		if v.slot == p794 then
			return v.id
		end
	end

	return nil
end
t1.Pick.count = function(p795)
	local v3963 = t1.Pick.unit(p795)
	local v3964 = t1.Pick.positions()
	local v3965 = v3964 and v3963 and v3964[v3963]

	return type(v3965) == "table" and #v3965 or 0
end
t1.Pick.label = function(p796)
	for _, v in ipairs(t1.Match.slots()) do
		if v.slot == p796 and v.name then
			return v.name
		end
	end

	return "Slot " .. tostring(p796)
end
t1.Pick.spotFor = function(p797, p798)
	local raycastParams = RaycastParams.new()

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local filterDescendantsInstances = {}

	if LocalPlayer.Character then
		filterDescendantsInstances[#filterDescendantsInstances + 1] = LocalPlayer.Character
	end

	if t1.Esp.folder then
		filterDescendantsInstances[#filterDescendantsInstances + 1] = t1.Esp.folder
	end

	if t1.Pick.markerFolder then
		filterDescendantsInstances[#filterDescendantsInstances + 1] = t1.Pick.markerFolder
	end

	if t1.Pick.ghost then
		filterDescendantsInstances[#filterDescendantsInstances + 1] = t1.Pick.ghost
	end

	if t1.Ghost._folder then
		filterDescendantsInstances[#filterDescendantsInstances + 1] = t1.Ghost._folder
	end

	if t12.DeleteMap == true and t1.Vis.mapRoot then
		filterDescendantsInstances[#filterDescendantsInstances + 1] = t1.Vis.mapRoot
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances

	local hit = workspace:Raycast(p798.Origin, p798.Direction * 2000, raycastParams)

	if not hit then
		return nil, "Not A Surface"
	end

	local v3971 = t1.Pick.unit(p797)
	local v3972 = t1.Place.ground(hit.Position.X, hit.Position.Z, v3971)

	if v3972 and (not v3971 or t1.Place.valid(v3972, v3971)) then
		return v3972
	end

	return nil, "Not A Build Spot", hit.Position
end
t1.Pick.at = function(p799, p800)
	if t1.Pick.slot ~= p799 then
		return
	end

	if not workspace.CurrentCamera then
		return
	end

	local v3973 = t1.Pick.unit(p799)

	if not v3973 then
		t1.Pick.say("[PICK] Slot " .. p799 .. " | Empty Slot")

		return
	end

	local v3974, v3975 = t1.Pick.spotFor(p799, workspace.CurrentCamera:ScreenPointToRay(p800.X, p800.Y))

	if not v3974 then
		t1.Pick.say("[PICK] " .. t1.Pick.label(p799) .. " | " .. v3975)

		return
	end

	local v3976 = t1.Pick.positions(nil, true)

	v3976[v3973] = type(v3976[v3973]) == "table" and v3976[v3973] or {}
	table.insert(v3976[v3973], {
		math.floor(v3974.X * 100 + 0.5) / 100,
		math.floor(v3974.Y * 100 + 0.5) / 100,
		math.floor(v3974.Z * 100 + 0.5) / 100,
		t1.Place.yaw(v3974)
	})
	t1._saveSoon()
	t1.Pick.say("[SAVED] " .. t1.Pick.label(p799) .. " | Spot " .. #v3976[v3973])
	t1.Pick.cancel()
	t1.Pick.onSaved()
	t1._wake("esp")
	t1._wake("play")
end
t1.Pick.start = function(p801)
	if t1.Pick.slot == p801 then
		t1.Pick.cancel()
		t1.Pick.say("[CANCELLED] " .. t1.Pick.label(p801))

		return "cancelled"
	end

	t1.Pick.cancel()

	if not (t1.Ctx.place() == "MATCH" and t1.Match.mapId()) then
		t1.Pick.say("[WAITING] Awaiting Match")

		return
	end

	t1.Pick.slot = p801
	t1.Pick.say("[PICK] " .. t1.Pick.label(p801) .. " | " .. (UserInputService.TouchEnabled and "Tap A Spot" or "Click A Spot"))

	local token = {}

	t1.Pick.token = token
	task.delay(20, function()
		if t1.Pick.token == token and t1.Pick.slot == p801 then
			t1.Pick.say("[IDLE]")
			t1.Pick.cancel()
		end
	end)
	t1._conn(UserInputService.InputBegan, function(p802, p803)
		if p803 or p802.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		t1.Pick.at(p801, p802.Position)
	end, t1.Pick.conns)
	t1._conn(UserInputService.TouchTapInWorld, function(p804, p805)
		if not p805 then
			t1.Pick.at(p801, p804)
		end
	end, t1.Pick.conns)
	t1.Pick.ghostSync()

	if workspace.CurrentCamera and UserInputService.MouseEnabled then
		local function v3978()
			local mouseLocation = UserInputService:GetMouseLocation()

			t1.Pick.hover(workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y))
		end

		t1._conn(UserInputService.InputChanged, function(p806)
			if p806.UserInputType == Enum.UserInputType.MouseMovement then
				v3978()
			end
		end, t1.Pick.conns)
		t1._conn(workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"), v3978, t1.Pick.conns)
		v3978()
	end

	return "picking"
end
t1.Pick.clear = function(p807)
	local v3980 = t1.Pick.unit(p807)
	local v3981 = t1.Pick.positions()

	if v3981 and v3980 then
		v3981[v3980] = nil
	end

	t1._saveSoon()
	t1.Pick.say("[CLEARED] " .. t1.Pick.label(p807))
	t1.Pick.onSaved()
	t1._wake("play")
end

do
	t1.Pick.markers = function()
		pcall(t1.Pick.ghostSync)

		if t1.Pick.markerFolder then
			pcall(function()
				t1.Pick.markerFolder:Destroy()
			end)
		end

		t1.Pick.markerFolder = nil

		if not t1.Running or not t12.PlacementPreview or t1.Ctx.place() ~= "MATCH" then
			return
		end

		local v3982 = t1.Pick.positions()

		if type(v3982) ~= "table" or next(v3982) == nil then
			return
		end

		local Folder = Instance.new("Folder")

		Folder.Name = "BarrageCameramanTowerDefensePositions"

		for k, v in pairs(v3982) do
			local ipairs_ = ipairs
			local v3987 = type(v) == "table" and v or {}

			for k2, v2 in ipairs_(v3987) do
				local Part = Instance.new("Part")

				Part.Anchored = true
				Part.CanCollide = false
				Part.CanTouch = false
				Part.CanQuery = false
				Part.CastShadow = false
				Part.Shape = Enum.PartType.Cylinder
				Part.Material = Enum.Material.Neon
				Part.Color = v3452("PlacementPreview")
				Part.Transparency = v3454("PlacementPreview")

				local v3991 = math.clamp(t1._n(t12.PlacementMarkerSize, 3), 1, 8)

				Part.Size = Vector3.new(0.2, v3991, v3991)
				Part.CFrame = CFrame.new(t1._n(v2[1]), t1._n(v2[2]) + 0.1, t1._n(v2[3])) * CFrame.Angles(0, 0, 1.5707963267948966)

				if t12.PlacementLabels ~= false then
					local Tag, v3993 = t1.Ghost.tag("Tag", t1.Esp.TAG.marker)

					v3993.Text = t1.Data.name(k) .. " #" .. k2
					t1.Ghost.tagAt(Tag, nil, Vector3.new(t1._n(v2[1]), t1._n(v2[2]), t1._n(v2[3])))
					Tag.Parent = Folder
				end

				Part.Parent = Folder
			end
		end

		Folder.Parent = workspace
		t1.Pick.markerFolder = Folder
	end
end

do
	t1.Pick.ghostSync = function()
		if not (t1.Running and t1.Pick.slot ~= nil and t12.PlacementPreview and t1.Ctx.place() == "MATCH") then
			if t1.Pick.ghost then
				pcall(function()
					t1.Pick.ghost:Destroy()
				end)
			end

			local Pick = t1.Pick
			local Pick2 = t1.Pick
			local Pick3 = t1.Pick
			local Pick4 = t1.Pick
			local Pick5 = t1.Pick

			t1.Pick.ghost = nil
			Pick.ghostBB = nil
			Pick2.ghostLabel = nil
			Pick3.ghostModel = nil
			Pick4.ghostToken = nil
			Pick5.ghostTag = nil

			return
		end

		if t1.Pick.ghost and t1.Pick.ghost.Parent then
			return
		end

		local Part = Instance.new("Part")

		Part.Name = "BarrageCameramanTowerDefensePick"
		Part.Anchored = true
		Part.CanCollide = false
		Part.CanTouch = false
		Part.CanQuery = false
		Part.CastShadow = false
		Part.Shape = Enum.PartType.Cylinder
		Part.Material = Enum.Material.Neon
		Part.Size = Vector3.new(0.2, 3, 3)
		Part.Transparency = 1

		local Tag, v4001 = t1.Ghost.tag("Tag", t1.Esp.TAG.cursor)
		local Info = Tag.Info

		Info.Enabled = false
		Tag.Parent = Part
		Part.Parent = workspace

		local Pick = t1.Pick
		local Pick2 = t1.Pick
		local Pick3 = t1.Pick

		t1.Pick.ghost = Part
		Pick.ghostBB = Info
		Pick2.ghostLabel = v4001
		Pick3.ghostTag = Tag

		local slot = t1.Pick.slot
		local ghostToken = {}

		t1.Pick.ghostToken = ghostToken
		task.spawn(function()
			local v4008

			for _, v in ipairs(t1.Match.slots()) do
				if v.slot == slot then
					v4008 = v
				end
			end

			local v4011 = v4008 and t1.Ghost.make(v4008.id, v4008.entry)

			if not v4011 then
				return
			end

			if t1.Pick.ghostToken ~= ghostToken or t1.Pick.ghost ~= Part or not Part.Parent then
				v4011:Destroy()

				return
			end

			t1.Ghost.outline(v4011, v3452("PlacementPreview"))
			t1.Pick.ghostModel = v4011

			if t1.Pick.lastRay then
				t1.Pick.hover(t1.Pick.lastRay)
			end
		end)
	end
end

do
	t1.Pick.hover = function(p808)
		local ghost = t1.Pick.ghost

		if not ghost or not t1.Pick.slot then
			return
		end

		t1.Pick.lastRay = p808

		local v4013, _, v4015 = t1.Pick.spotFor(t1.Pick.slot, p808)
		local v4016 = v4013 or v4015
		local ghostModel = t1.Pick.ghostModel

		if not v4016 then
			ghost.Transparency = 1
			t1.Pick.ghostBB.Enabled = false

			if ghostModel then
				ghostModel.Parent = nil
			end

			return
		end

		ghost.CFrame = CFrame.new(v4016 + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)

		local PlacementPreview = v4013 and v3452("PlacementPreview") or Color3.fromRGB(255, 70, 70)

		ghost.Color = PlacementPreview

		if ghostModel then
			ghost.Transparency = 1
			t1.Ghost.put(ghostModel, v4016, t1.Place.yaw(v4016))
			t1.Ghost.outline(ghostModel, PlacementPreview).FillTransparency = v4013 and 1 or 0.6
			ghostModel.Parent = ghost
		else
			ghost.Transparency = v3454("PlacementPreview")
		end

		t1.Ghost.tagAt(t1.Pick.ghostTag, ghostModel, v4016)
		t1.Pick.ghostLabel.Text = "[PREVIEW] " .. t1.Pick.label(t1.Pick.slot)
		t1.Pick.ghostBB.Enabled = true
	end
end

do
	t1.Pick.migrate = function()
	end
end

t1.Pick.onSaved = function()
	pcall(t1.Pick.migrate)
	pcall(t1.Pick.markers)

	if t1.Pick.refreshMaps then
		pcall(t1.Pick.refreshMaps)
	end

	t1._wake("status")
end

do
	t1._wakeHandlers.markers = function()
		pcall(t1.Pick.markers)
	end
end

t1._cleanups[#t1._cleanups + 1] = function()
	if t1.Pick.markerFolder then
		pcall(function()
			t1.Pick.markerFolder:Destroy()
		end)
	end

	if t1.Pick.ghost then
		pcall(function()
			t1.Pick.ghost:Destroy()
		end)
	end
end
t1._errors = {}

do
	local function v4019(p809, p810, p811)
		t1._allWorkers[#t1._allWorkers + 1] = p809
		t1._worker(p809, p810, function()
			p811()
		end)
	end

	v4019("skip", t1.Skip, function()
		t1.Skip.run()
	end)
	v4019("matchend", t1.End, function()
		t1.End.run()
	end)
	v4019("vote", t1.Vote, function()
		t1.Vote.run()
	end)
	v4019("modvote", t1.ModVote, function()
		t1.ModVote.run()
	end)
	v4019("speed", t1.Speed, function()
		t1.Speed.run()
	end)
	v4019("ability", t1.Ability, function()
		t1.Ability.run()
	end)
	v4019("eleave", t1.Leave, function()
		t1.Leave.run()
	end)
	v4019("party", t1.Party, function()
		t1.Party.run()
	end)
	v4019("queue", t1.Queue, function()
		t1.Queue.run()
	end)
	v4019("summon", t1.Sum, function()
		t1.Sum.run()
	end)
	v4019("autosell", t1.ASell, function()
		t1.ASell.run()
	end)
	v4019("equip", t1.Equip, function()
		t1.Equip.run()
	end)
	v4019("unitsell", t1.USell, function()
		t1.USell.run()
	end)
	v4019("codes", t1.Codes, function()
		t1.Codes.run()
	end)
	v4019("quests", t1.Quest, function()
		t1.Quest.run()
	end)
	v4019("boosts", t1.Boost, function()
		t1.Boost.run()
	end)
	v4019("crates", t1.Crates, function()
		t1.Crates.run()
	end)
	v4019("passitems", t1.Pass, function()
		t1.Pass.run()
	end)
	v4019("settings", t1.Settings, function()
		t1.Settings.run()
	end)
	v4019("passtiers", t1.Tier, function()
		t1.Tier.run()
	end)
	v4019("passquests", t1.PQ, function()
		t1.PQ.run()
	end)
	v4019("crateshop", t1.Shop, function()
		t1.Shop.run()
	end)
	v4019("ranks", t1.Rank, function()
		t1.Rank.run()
	end)
	v4019("medal", t1.Medal, function()
		t1.Medal.run()
	end)
	v4019("special", t1.Special, function()
		t1.Special.run()
	end)
	v4019("rng", t1.Rng, function()
		t1.Rng.run()
	end)
end

t1._wakeHandlers.espEnemies = function()
	pcall(t1.Esp.enemies)
end

do
	local t248 = {
		"summon",
		"autosell",
		"equip",
		"unitsell",
		"codes",
		"quests",
		"boosts",
		"crates",
		"passitems",
		"settings",
		"passtiers",
		"passquests",
		"crateshop",
		"queue",
		"ranks",
		"medal",
		"special",
		"rng"
	}

	t1._wakeHandlers.lobbydata = function()
		t1.Slots.cache = nil
		t1.Match._slots = nil
		t1._signal("data")

		for _, v in ipairs(t248) do
			t1._wakeThrottled(v, 1)
		end

		t1._wakeThrottled("status", 0.5)
	end
end

do
	local function v4023(p812, p813)
		for _, v in ipairs(p812) do
			if p813 then
				t1._wakeThrottled(v, p813)
			else
				t1._wake(v)
			end
		end
	end

	local t249 = {
		"play",
		"assist",
		"upgrade",
		"target",
		"ability",
		"sell",
		"skip",
		"matchend",
		"macro",
		"vote",
		"modvote",
		"speed",
		"eleave",
		"party"
	}

	t1._charConns = {}
	t1._bindCharacter = function(p814)
		t1._drop(t1._charConns)

		local Humanoid = p814 and p814:FindFirstChildOfClass("Humanoid")

		if Humanoid then
			t1._conn(Humanoid.Died, function()
				t1.Move.stop()
			end, t1._charConns)
		end
	end

	local function v4028()
		t1.Match.roundId += 1
		t1.G.result = nil
		t1.Skip.wave = nil
		t1.Leave.players = 0
		pcall(t1.Play.resetCaps)
		table.clear(t1.Place.refused)
		table.clear(t1.Play.fails)
		table.clear(t1.Target.asked)
		table.clear(t1.Target.pend)
		table.clear(t1.Target.slotWhy)
		table.clear(t1.Target.cover)
		table.clear(t1.Ability.cd)
		table.clear(t1.Ability.tried)
		table.clear(t1.Ability.best)
		table.clear(t1.Match.ours)
		t1.Match.mirror = {}
		t1.Match.dirty()
		v4023(t249)
		t1._wake("esp")
		t1._wakeThrottled("status", 0.25)
	end

	t1._wakeHandlers.mapChanged = function()
		t1.Match._mapSeen = t1.Match.mapId()
		pcall(t1.Pick.migrate)
		t1.Paths.reset()
		pcall(t1.Play.resetCaps)
		t1.Place._rp = nil

		local mapTok = {}

		t1.Match._mapTok = mapTok
		task.delay(1, function()
			if not t1.Running or t1.Match._mapTok ~= mapTok then
				return
			end

			pcall(t1.Pick.onSaved)
			t1._wake("esp")
			t1._wake("markers")
			t1._wakeAll()
		end)
	end
	t1._wakeHandlers.macroDiff = function()
		pcall(t1.Macro.diff)
	end
	t1._wakeHandlers.traffic = function()
		pcall(t1.Paths.watch)
	end
	t1._matchConns = {}

	local function v4030()
		t1.Slots.cache = nil
		t1.Match.dirty()
		t1._signal("units")
		v4023({
			"play",
			"upgrade",
			"target",
			"ability",
			"sell",
			"macro"
		}, 0.2)

		if t1.Macro.recording then
			t1._wakeThrottled("macroDiff", 0.3)
		end

		if t12.EspRanges or t12.EspSpots then
			t1._wakeThrottled("espTowers", 0.5)
		end

		t1._wakeThrottled("status", 0.3)
	end
	local function v4031()
		t1.Match._enemies = nil
		v4023({
			"skip",
			"ability",
			"target",
			"sell",
			"eleave"
		}, 0.3)
		t1._wakeThrottled("play", 1)

		if t12.EspEnemies then
			t1._wakeThrottled("espEnemies", 0.15)
		end

		t1._wakeThrottled("traffic", 1)
	end
	local function v4032()
		t1.Match.waveAt = os.clock()
		t1._signal("wave")

		if t12.Webhook then
			t1._alarm("hookWave", 1, "hook:wave")
		end

		v4023({
			"play",
			"upgrade",
			"sell",
			"skip",
			"vote",
			"macro",
			"ability",
			"eleave",
			"party",
			"speed"
		})
		t1._wakeThrottled("status", 0.5)
	end
	local function v4033()
		task.spawn(function()
			pcall(t1.End.onMessage)
		end)
	end

	t1._bindMatch = function()
		if not t1.Running then
			return
		end

		t1._drop(t1._matchConns)

		local Game = workspace:FindFirstChild("Game")

		if not Game then
			return
		end

		for _, v in ipairs({
			"Towers",
			"Enemies",
			"PlacingTowers"
		}) do
			local v4037 = Game:FindFirstChild(v)

			if v4037 then
				local v4038 = v == "Towers" and v4030 or v == "Enemies" and v4031 or function()
					t1._wakeThrottled("assist", 0.2)
					t1._wakeThrottled("placering", 0.1)
				end

				t1._conn(v4037.ChildAdded, v4038, t1._matchConns)
				t1._conn(v4037.ChildRemoved, v4038, t1._matchConns)
			end
		end

		local Match = t1.Match
		local Match2 = t1.Match

		t1.Match.mirror = {}
		Match._gr = nil
		Match2._grRetry = nil

		local Party = t1.Party

		t1.Leave.players = 0
		Party.seen = false
		table.clear(t1.Ability.cd)
		table.clear(t1.Ability.tried)
		table.clear(t1.Ability.best)

		local TowerAbilityUpdate = t1.net("TowerAbilityUpdate")

		if TowerAbilityUpdate and TowerAbilityUpdate:IsA("RemoteEvent") then
			t1._conn(TowerAbilityUpdate.OnClientEvent, function(p815)
				local v4043 = t1.Match.key(p815)

				if not v4043 then
					return
				end

				t1.Ability.cd[v4043] = tonumber(p815.CooldownEndsAt)
				t1._signal("ability")

				if t12.AutoAbility then
					t1._wake("ability")
				end
			end, t1._matchConns)
		end

		for _, v in ipairs({
			"TowerAdd",
			"TowerRemove",
			"TowerUpgrade",
			"TowerTarget",
			"Replication"
		}) do
			local v4046 = t1.net(v)
			local v4047 = t1.Match.MIRROR[v]

			if v4046 and v4046:IsA("RemoteEvent") then
				t1._conn(v4046.OnClientEvent, function(p816)
					pcall(v4047, p816)

					if v ~= "Replication" or type(p816) == "table" and p816.Towers then
						task.defer(v4030)
					end
				end, t1._matchConns)
			end
		end

		t1._conn(workspace:GetAttributeChangedSignal("Wave"), v4032, t1._matchConns)

		for _, v in ipairs({
			"CanSkip",
			"Votes",
			"RequiredVotes"
		}) do
			t1._conn(workspace:GetAttributeChangedSignal(v), function()
				t1._signal("skip")
				t1._wake("skip")
			end, t1._matchConns)
		end

		t1._conn(workspace:GetAttributeChangedSignal("Message"), function()
			v4033()
			t1._signal("results")
			v4023({
				"matchend",
				"vote",
				"speed",
				"status"
			})
		end, t1._matchConns)

		for _, v in ipairs({
			"IsVoting",
			"Mode"
		}) do
			t1._conn(workspace:GetAttributeChangedSignal(v), function()
				t1._signal("vote")
				v4023({
					"vote",
					"play",
					"sell",
					"speed"
				})
			end, t1._matchConns)
		end

		t1._conn(workspace:GetAttributeChangedSignal("GameState"), function()
			v4033()

			if workspace:GetAttribute("GameState") == "Restarting" then
				v4028()
			end

			t1._wakeAll()
		end, t1._matchConns)
		t1._conn(workspace:GetAttributeChangedSignal("GameSpeed"), function()
			t1._signal("speed")
			t1._wake("speed")
		end, t1._matchConns)
		t1._conn(workspace:GetAttributeChangedSignal("PlayAgainTimer"), function()
			if t12.AutoMatchEnd and t1.End.votedAt then
				t1._wakeThrottled("matchend", 1)
			end
		end, t1._matchConns)
		t1._conn(workspace:GetAttributeChangedSignal("Map"), function()
			t1._wake("mapChanged")
		end, t1._matchConns)

		for _, v in ipairs({
			"MapReady",
			"LoadedMap"
		}) do
			t1._conn(Game:GetAttributeChangedSignal(v), function()
				t1._wake("mapChanged")
			end, t1._matchConns)
		end

		for _, v in ipairs({
			"IsModifierVoting",
			"ModifierVotes",
			"ModifierVotesNeeded"
		}) do
			t1._conn(workspace:GetAttributeChangedSignal(v), function()
				t1._signal("modvote")
				t1._wake("modvote")
			end, t1._matchConns)
		end

		t1._conn(workspace.AttributeChanged, function(p817)
			if p817 == "PlayAgainVoters" then
				t1._signal("results")
				t1._wake("matchend")

				if t12.PartyRole == "Alt" then
					t1._wake("party")
				end
			elseif tostring(p817):find("Voters$") then
				t1._signal("vote")
				t1._wake("vote")
			end
		end, t1._matchConns)

		local Base = Game:FindFirstChild("Base")

		if Base then
			local Match3 = t1.Match

			t1.Match._lastHp = nil
			Match3._leakAt = nil
			t1._conn(Base:GetAttributeChangedSignal("Health"), function()
				t1.Match.leaking()
				v4023({
					"play",
					"skip",
					"target",
					"sell"
				}, 1)

				if t12.EmergencyLeave then
					t1._wakeThrottled("eleave", 0.5)
				end
			end, t1._matchConns)
		end

		local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
		local Money = leaderstats and leaderstats:FindFirstChild("Money")

		if Money then
			t1._conn(Money.Changed, function()
				v4023({
					"play",
					"upgrade",
					"macro"
				}, 0.25)
				t1._wakeThrottled("assist", 0.5)

				if t12.AutoAbility then
					t1._wakeThrottled("ability", 1)
				end

				if t1.Plan.shown then
					pcall(t1.Plan.cash)
				end

				t1._wakeThrottled("status", 0.5)
			end, t1._matchConns)
		end

		local PlacedTowers = LocalPlayer:FindFirstChild("PlacedTowers")

		if PlacedTowers then
			t1._conn(PlacedTowers.Changed, v4030, t1._matchConns)
		end

		t1._wake("mapChanged")
		v4033()
	end
end

t1._lobbyConns = {}
t1._dropReplica = function()
	local _replicaConn = t1._replicaConn

	t1._replicaConn = nil

	if _replicaConn then
		pcall(function()
			_replicaConn:Disconnect()
		end)
	end
end

do
	t1._lobbyWanted = function()
		if t12.AutoJoin then
			return true
		end

		for _, chore in ipairs(t1.Chores) do
			if t12[t15[chore.name]] then
				return true
			end
		end

		return false
	end
end

do
	local function bindReplica()
		if not t1.Running then
			return
		end

		local v4065 = t1.replica()

		if t1._replicaConn and t1._replicaFor == v4065 then
			if t1._lobbyWanted() then
				t1._alarm("replica", 30, "replica")
			end

			return
		end

		if not v4065 then
			if not t1._lobbyWanted() then
				t1._replicaTry = nil

				return
			end

			t1._replicaTry = math.min(15, (t1._replicaTry or 1) * 2)
			t1._alarm("replica", t1._replicaTry, "replica")

			return
		end

		t1._dropReplica()

		local ok, replicaConn = pcall(v4065.OnChange, v4065, function(p818, p819)
			if (type(p819) == "table" and p819[1] or type(p819) == "string" and p819:match("^[^%.]+") or nil) == "Battlepass" then
				return t1._wakeThrottled("passdata", 1)
			end

			t1._wakeThrottled("lobbydata", 1)
		end)

		t1._restoreIdentity()

		if ok and replicaConn then
			t1._replicaTry = nil
			t1._replicaConn = replicaConn
			t1._replicaFor = v4065

			if t1._lobbyWanted() then
				t1._alarm("replica", 30, "replica")
			end

			t1._wake("lobbydata")
			t1._wake("hydrate")

			return
		end

		if not t1._lobbyWanted() then
			t1._replicaTry = nil

			return
		end

		t1._replicaTry = math.min(15, (t1._replicaTry or 1) * 2)
		t1._alarm("replica", t1._replicaTry, "replica")
	end

	t1._bindReplica = bindReplica
end

t1._wakeHandlers.replica = t1._bindReplica
t1._bindLobby = function()
	t1._drop(t1._lobbyConns)
	t1._dropReplica()
	t1._bindReplica()

	local SummonSetUpdated = t1.net("SummonSetUpdated")

	if SummonSetUpdated then
		t1._conn(SummonSetUpdated.OnClientEvent, function(p820)
			t1.Sum.set = type(p820) == "table" and p820 or nil
			t1._wake("summon")
		end, t1._lobbyConns)
	end

	local SendQuestData = t1.net("SendQuestData")

	if SendQuestData then
		t1._conn(SendQuestData.OnClientEvent, function(p821)
			t1.Quest.list = type(p821) == "table" and p821 or {}
			t1.Quest.unanswered = 0
			t1._signal("quests")
			t1._wake("quests")
			t1._wakeThrottled("hydrate", 2)
		end, t1._lobbyConns)
	end

	local SendPassQuestData = t1.net("SendPassQuestData")

	if SendPassQuestData then
		t1._conn(SendPassQuestData.OnClientEvent, function(p822)
			if type(p822) ~= "table" then
				return
			end

			local PQ = t1.PQ
			local PQ2 = t1.PQ
			local now = os.clock()

			PQ.pushed = p822
			PQ2.pushedAt = now

			if t12.AutoPassQuests and t1.PQ.find() then
				t1._wake("passquests")
			end
		end, t1._lobbyConns)
	end

	local OpenAnim = t1.net("OpenAnim")

	if OpenAnim then
		t1._conn(OpenAnim.OnClientEvent, function(p823, p824)
			if type(p823) == "table" then
				pcall(t1.Hook.summons, p823, tostring(p824 or "Crate"))
			end
		end, t1._lobbyConns)
	end

	local QuestCompleted = t1.net("QuestCompleted")

	if QuestCompleted then
		t1._conn(QuestCompleted.OnClientEvent, function()
			local Quest = t1.Quest

			t1.Quest.list = nil
			Quest.asked = 0
			t1._wake("quests")
		end, t1._lobbyConns)
	end

	local MatchUpdate = t1.net("MatchUpdate")

	if MatchUpdate and MatchUpdate:IsA("RemoteEvent") then
		t1._conn(MatchUpdate.OnClientEvent, function(p825)
			t1.MM.apply(p825)
			t1._signal("matchmaking")

			if t12.AutoJoin then
				t1._wake("queue")
			end
		end, t1._lobbyConns)
	end

	local ElevatorEntered = t1.net("ElevatorEntered")

	t1.Queue.adopt()

	if ElevatorEntered then
		t1._conn(ElevatorEntered.OnClientEvent, function(p826, p827)
			local Queue = t1.Queue

			t1.Queue.inside = tostring(p826)
			Queue.leader = p827 == true
			t1._signal("elevator")
			t1._wake("queue")

			if t12.PartyRole ~= "Off" then
				t1._wake("party")
			end
		end, t1._lobbyConns)
	end

	for _, v in ipairs({
		"ElevatorLeft",
		"ElevatorTeleporting"
	}) do
		local v4082 = t1.net(v)

		if v4082 then
			t1._conn(v4082.OnClientEvent, function()
				if v == "ElevatorTeleporting" then
					t1.Ctx.leaving = true

					local leaveToken = {}

					t1.Ctx.leaveToken = leaveToken
					task.delay(8, function()
						if t1.Running and t1.Ctx.leaveToken == leaveToken then
							local Ctx = t1.Ctx

							t1.Ctx.leaving = false
							Ctx.leaveToken = nil
							t1._wake("queue")
							t1._wake("status")
						end
					end)
				end

				if v == "ElevatorLeft" then
					local Queue = t1.Queue
					local Queue2 = t1.Queue

					t1.Queue.inside = nil
					Queue.leader = false
					Queue2.modSig = nil
				end

				t1._signal("elevator")
				t1._wake("queue")

				if t12.PartyRole ~= "Off" then
					t1._wake("party")
				end
			end, t1._lobbyConns)
		end
	end

	local Elevators = workspace:FindFirstChild("Elevators")

	local function v4088(p828)
		t1._conn(p828.AttributeChanged, function()
			if t12.AutoJoin then
				t1._wakeThrottled("queue", 1)
			end

			if t12.PartyRole ~= "Off" then
				t1._wakeThrottled("party", 0.5)
			end
		end, t1._lobbyConns)
	end

	local children = Elevators and Elevators:GetChildren() or {}

	for _, child in ipairs(children) do
		v4088(child)
	end

	if Elevators then
		t1._conn(Elevators.ChildAdded, function(p829)
			v4088(p829)

			if t12.AutoJoin then
				t1._wakeThrottled("queue", 1)
			end

			t1._wakeThrottled("hydrate", 2)
		end, t1._lobbyConns)
	end
end
t1._bind = function()
	if not t1.Running then
		return
	end

	t1._wake("hydrate")
	t1._conn(LocalPlayer.OnTeleport, function(p830)
		t1.Ctx.leaving = p830 ~= Enum.TeleportState.Failed

		local leaveToken = t1.Ctx.leaving and {} or nil

		t1.Ctx.leaveToken = leaveToken

		if leaveToken then
			task.delay(30, function()
				if t1.Running and t1.Ctx.leaveToken == leaveToken then
					local Ctx = t1.Ctx

					t1.Ctx.leaving = false
					Ctx.leaveToken = nil
					t1._wakeAll()
				end
			end)
		end

		t1._signal("teleport")
		t1._wakeAll()
	end)

	local function v4094(p831)
		if p831 and p831.Name == "SpeakermanQuestEvent" then
			t1._conn(p831.AttributeChanged, function()
				t1._wakeThrottled("special", 0.5)
			end)
			t1._wake("special")
		end
	end

	v4094(ReplicatedStorage:FindFirstChild("SpeakermanQuestEvent"))
	t1._conn(ReplicatedStorage.ChildAdded, v4094)
	t1._conn(LocalPlayer:GetAttributeChangedSignal("RNGLoadout"), function()
		t1._wake("rng")
	end)

	for _, v in ipairs({
		Players.PlayerAdded,
		Players.PlayerRemoving
	}) do
		t1._conn(v, function()
			if t12.PartyRole ~= "Off" then
				t1._wakeThrottled("party", 0.5)
			end

			if t12.EmergencyLeave then
				t1._wakeThrottled("eleave", 0.5)
			end
		end)
	end

	t1._conn(LocalPlayer.CharacterAdded, function(p832)
		t1.Move.stop()
		t1._wake("walk")
		t1._wake("autowalk")
		p832:WaitForChild("HumanoidRootPart", 10)

		if t1.Running and LocalPlayer.Character == p832 then
			t1._bindCharacter(p832)
			t1._wake("walk")
			t1._wake("autowalk")
			t1._wakeAll()
		end
	end)
	t1._bindCharacter(LocalPlayer.Character)

	local ok = game.PlaceId == 114068177100380

	if not ok then
		ok = not not workspace:FindFirstChild("Game")
	end

	if ok then
		local Game = workspace:WaitForChild("Game", 30)

		if Game then
			for _, v in ipairs({
				"Towers",
				"Enemies",
				"Waypoints"
			}) do
				Game:WaitForChild(v, 10)
			end
		else
			t1._conn(workspace.ChildAdded, function(p833)
				if p833.Name ~= "Game" then
					return
				end

				task.spawn(function()
					for _, v in ipairs({
						"Towers",
						"Enemies",
						"Waypoints"
					}) do
						p833:WaitForChild(v, 10)
					end

					if not t1.Running then
						return
					end

					t1._bindMatch()
					t1._wakeAll()
				end)
			end)
		end

		LocalPlayer:WaitForChild("leaderstats", 10)

		if not t1.Running then
			return
		end

		t1._bindMatch()
	else
		workspace:WaitForChild("Elevators", 20)

		if not t1.Running then
			return
		end

		t1._bindLobby()
	end

	t1._wake("esp")
	t1._wake("markers")
	t1._wake("hydrate")
	t1._wakeAll()
end
t1._lastInput = os.clock()

do
	local function v4103()
		t1._restoreIdentity()
		pcall(function()
			VirtualUser:CaptureController()
		end)

		if not pcall(function()
			VirtualUser:ClickButton2(Vector2.new())
		end) then
			pcall(function()
				local CFrame_ = workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new()

				VirtualUser:Button2Down(Vector2.new(), CFrame_)
				VirtualUser:Button2Up(Vector2.new(), CFrame_)
			end)
		end

		t1._lastInput = os.clock()
	end

	t1._conn(UserInputService.InputBegan, function()
		t1._lastInput = os.clock()
	end)
	t1._conn(LocalPlayer.Idled, v4103)
	t1._wakeHandlers.afk = function()
		if os.clock() - t1._lastInput >= 235 then
			v4103()
		end

		t1._alarm("afk", math.max(5, 240 - (os.clock() - t1._lastInput)))
	end
end

t1._alarm("afk", 240)

do
	t1.Play.slotHeader = function(p834, p835)
		for _, v in ipairs(t1.Match.slots()) do
			if v.slot ~= p834 then
				continue
			end

			local v4107 = t1.Units.rarity(v.id)
			local v4108 = v.tag .. " | $" .. t1._fmt(t1.Data.placeCost(v.id)) .. (v4107 ~= "" and " | " .. v4107 or "")

			if p835 and not t1.Play.rarityOk(v.id) then
				v4108 ..= " | [SKIPPED] Rarity"
			end

			return v4108
		end

		return "[NONE] Empty Slot"
	end
end

t1.Play.queueText = function()
	if t1.Match.state() == "LOBBY" then
		return "[WAITING] Awaiting Match"
	end

	local t250 = {}

	for _, v in ipairs(t1.Match.towers()) do
		t250[v.id] = (t250[v.id] or 0) + 1
	end

	local t251 = {}

	for _, v in ipairs(t1.Play.order(t1.Match.slots(), t250)) do
		local v4115 = t1.Play.limit(v)
		local v4116 = t250[v.id] or 0

		t251[#t251 + 1] = #t251 + 1 .. "). " .. v.tag .. " | x" .. v4116 .. "/" .. (v4115 == math.huge and "Any" or tostring(v4115)) .. (v4116 >= v4115 and " [DONE]" or " | $" .. t1._fmt(t1.Data.placeCost(v.id)))
	end

	return #t251 > 0 and table.concat(t251, "\n") or "[WAITING] Awaiting Loadout"
end

do
	t1.Upg.queueText = function()
		local plan = t1.Upg.plan or {}
		local planHead = t1.Upg.planHead or t1.Upg.header()

		if #plan == 0 then
			return planHead .. "\n" .. (t1.Upg.planNote or "[WAITING] Awaiting Match")
		end

		local t252 = { planHead }

		for i = 1, math.min(3, #plan) do
			local v4121 = plan[i]
			local v4122 = v4121.group > 0 and (v4121.slot and " | Group " .. v4121.group or " | No Slot") or ""

			t252[#t252 + 1] = i .. "). " .. v4121.tag .. " Lv" .. v4121.t.level + 1 .. " | $" .. t1._fmt(v4121.cost) .. v4122
		end

		return table.concat(t252, "\n")
	end
end

t1.Upg.farmText = function()
	t1.Upg._farmBar = nil

	local v4123 = tostring(t12.FarmUpgradeMode or "Payback")
	local v4124 = t1._has(t12.UpgradeActions, "Farms Early")
	local v4125 = t1._has(t12.UpgradeActions, "Skip Late Farm Upgrades")
	local v4126 = select(1, t1.Match.wave()) or 0
	local v4127 = t1._n(t12.SkipLateFarmWaves, 4)
	local v4128 = t12.UpgradePriority == true
	local n86 = 0
	local n87 = 0
	local n88 = 0
	local n89 = 0
	local n90 = 0
	local t253 = {}
	local n91 = 0
	local v4136

	for _, v in ipairs(t1.Match.towers()) do
		local v4139 = t1.Upg.info(v.id, v.level)

		if v4139.role == "Farm" then
			n91 += 1
		end

		if v4139.role == "Farm" and t1.Upg.farmPicked(v.id) then
			n86 += 1
			t253[#t253 + 1] = v.level

			local v4140 = t1.Upg.slotOf(v)
			local v4141 = v4128 and v4140 and t12["SlotUpgPri" .. v4140] or nil
			local v4142 = v4128 and v4140 and t1._n(t12["SlotMaxLevel" .. v4140]) or 0

			if v.level < v4139.max and (not v4136 or v.level < v4136.level) then
				v4136 = v
			end

			if v4139.max <= v.level then
				n87 += 1
			elseif v4141 == "OFF" then
				n88 += 1
			elseif v4142 > 0 and v4142 <= v.level then
				n89 += 1
			elseif t1._backed("upgrade:" .. tostring(v.hash)) then
				n90 += 1
			end
		end
	end

	local t254 = {}
	local plan = t12.AutoUpgrade and t1.Upg.plan or {}
	local v4145
	local v4146

	for i, v in ipairs(plan) do
		if v.role == "Farm" then
			v4145 = i
			v4146 = v

			break
		end
	end

	local v4149 = v4125 and n86 > 0 and t1.Match.wavesLeft() < v4127

	if not t12.AutoUpgrade then
		t254[1] = "[WAITING] Awaiting Upgrade | Auto Upgrade Requirement"
	elseif #t12.UpgradeFarmUnits == 0 then
		t254[1] = "[WAITING] Awaiting Farms | None Picked"
	elseif n86 == 0 then
		t254[1] = n91 > 0 and "[WAITING] Awaiting Farms | No Picked Farm Placed" or "[WAITING] Awaiting Farms"
	elseif v4123 == "Never" then
		t254[1] = "[OFF] Farms Not Upgraded | Farm Upgrade Mode Never"
	elseif v4149 then
		t254[1] = "[PAUSED] Skip Late Farm Upgrades | Last " .. v4127 .. " Waves"
	elseif n87 == n86 then
		t254[1] = "[DONE] Farms Maxed"
	elseif v4146 then
		t254[1] = (v4145 > 1 and "[QUEUED]" or t1.Cash.free(t12.UpgradeReserve) >= v4146.cost and "[ACTIVE]" or "[SAVING]") .. " " .. v4146.tag .. " Lv" .. v4146.t.level + 1
	elseif n88 + n89 + n90 > 0 then
		t254[1] = "[SKIPPED] No Farm To Upgrade"
	else
		t254[1] = "[WAITING] Awaiting Plan"
	end

	if n86 > 0 then
		local v4150, v4151 = t1.Match.wave()

		if v4150 then
			local v4152 = t1.Match.wavesLeft()

			t254[#t254 + 1] = "Wave: " .. v4150 .. (v4151 and v4151 > 0 and v4152 ~= math.huge and "/" .. v4151 .. " | " .. v4152 .. " Left" or "")
		end

		local v4153 = math.max(t1.Cash.free(t12.UpgradeReserve), 0)
		local t = v4146 and v4146.t or v4136
		local cost = v4146 and v4146.cost or v4136 and t1.Upg.cost(v4136)

		if t and cost and cost < math.huge then
			t254[#t254 + 1] = (v4146 and "Upgrading: " or "Held: ") .. t1.Data.tag(t.id) .. " Lv" .. t.level + 1 .. " | $" .. t1._fmt(cost) .. (v4153 < cost and " | Need $" .. t1._fmt(cost - v4153) or "")

			if v4146 then
				t1.Upg._farmBar = {
					v4153 / math.max(cost, 1) * 100,
					t1.Data.tag(t.id) .. " Lv" .. t.level + 1
				}
			end
		end

		local v4156 = #t254 + 1
		local v4157 = t1._fmt(v4153)
		local ok = not (t1._n(t12.UpgradeReserve) > 0)
		local v4159

		if not ok then
			v4159 = " | Reserve $" .. t1._fmt(t1._n(t12.UpgradeReserve))
			ok = not v4159
		end

		if ok then
			v4159 = ""
		end

		t254[v4156] = "Money: $" .. v4157 .. v4159

		if v4146 and v4145 > 1 then
			t254[#t254 + 1] = "Queue: #" .. v4145 .. " | Now " .. plan[1].tag .. " Lv" .. plan[1].t.level + 1
		end

		local lastFarm = t1.Upg.lastFarm

		if lastFarm and lastFarm.round == t1.Match.roundId then
			t254[#t254 + 1] = "Last: " .. lastFarm.tag .. " Lv" .. lastFarm.level .. " | " .. math.floor(os.clock() - lastFarm.at) .. "s Ago"
		end
	end

	if n86 > 0 then
		table.sort(t253)

		local t255 = {}

		for i = 1, math.min(#t253, 4) do
			t255[i] = "Lv" .. t253[i]
		end

		t254[#t254 + 1] = "Farms: " .. n86 .. " | " .. table.concat(t255, " ") .. (#t253 > 4 and " +" .. #t253 - 4 or "") .. (n87 > 0 and " | " .. n87 .. " Maxed" or "")
	end

	local t256 = {}

	if n88 > 0 then
		t256[#t256 + 1] = n88 .. " OFF In Upgrade Priority"
	end

	if n89 > 0 then
		t256[#t256 + 1] = n89 .. " At Max Level"
	end

	if n90 > 0 then
		t256[#t256 + 1] = n90 .. " Backing Off"
	end

	if #t256 > 0 then
		t254[#t254 + 1] = "Skipped: " .. table.concat(t256, " | ")
	end

	if v4124 and n86 > 0 and v4126 <= t1._n(t12.FarmsEarlyWave, 10) then
		t254[#t254 + 1] = "Farms Early: Until Wave " .. t1._n(t12.FarmsEarlyWave, 10)
	end

	return table.concat(t254, "\n")
end
t1.Upg.priorityText = function()
	local t257 = {}
	local t258 = {}
	local t259 = {}
	local t260 = {}

	for _, v in ipairs(t1.Match.slots()) do
		local v4170 = t12["SlotUpgPri" .. v.slot]
		local tag = v.tag

		if t1.Play.rarityOk(v.id) then
			if v4170 == "OFF" then
				t259[#t259 + 1] = tag
			else
				local slot = tonumber(v4170) or v.slot

				if not t257[slot] then
					t257[slot] = {}
					t258[#t258 + 1] = slot
				end

				table.insert(t257[slot], tag)
			end
		else
			t260[#t260 + 1] = v.tag
		end
	end

	if #t258 == 0 and #t259 == 0 and #t260 == 0 then
		return "[WAITING] Awaiting Loadout"
	end

	table.sort(t258)

	local t261 = {
		t12.AutoUpgrade and "[ACTIVE] Upgrade Groups" or "[WAITING] Awaiting Upgrade | Auto Upgrade Requirement",
		"Timing: " .. t1.Play.timingText()
	}

	for _, v in ipairs(t258) do
		t261[#t261 + 1] = "Group " .. v .. ": " .. table.concat(t257[v], ", ")
	end

	local v4176 = #t261 + 1
	local ok = not (#t259 > 0)
	local off

	if not ok then
		off = table.concat(t259, ", ")
		ok = not off
	end

	if ok then
		off = "None"
	end

	t261[v4176] = "OFF: " .. off

	if #t260 > 0 then
		t261[#t261 + 1] = "[SKIPPED] Rarity: " .. t1.Play.names(t260)
	end

	return table.concat(t261, "\n")
end

do
	t1.Upg.limitText = function(p836)
		local v4179 = t1.Play.slotHeader(p836)
		local id

		for _, v in ipairs(t1.Match.slots()) do
			if v.slot == p836 then
				id = v.id
			end
		end

		if not id then
			return v4179
		end

		local v4183 = t1._n(t12["SlotMaxLevel" .. p836])
		local v4184 = t1.Data.maxLevel(id)
		local v4185 = t12["SlotUpgPri" .. p836]
		local v4186 = not t1.Play.rarityOk(id) and "[SKIPPED] Rarity" or v4185 == "OFF" and "OFF"

		if not v4186 then
			v4186 = "Group " .. (tonumber(v4185) or p836)
		end

		return v4179 .. "\n[LIMIT] Level " .. (v4183 > 0 and math.min(v4183, v4184) or v4184) .. "/" .. v4184 .. " | " .. v4186
	end
end

do
	t1.Play.priorityText = function()
		local v4187 = t12.CustomPriority == true
		local t262 = {}

		for _, v in ipairs(t1.Match.slots()) do
			t262[#t262 + 1] = v
		end

		table.sort(t262, function(p837, p838)
			if v4187 then
				local v4191 = t1.Play.priority(p837.slot)
				local v4192 = t1.Play.priority(p838.slot)

				if v4191 ~= v4192 then
					return v4191 < v4192
				end
			end

			return p837.slot < p838.slot
		end)

		local t263 = {}
		local n92 = 0

		for _, v in ipairs(t262) do
			local v4197

			if t1.Play.rarityOk(v.id) then
				local v4198 = t1.Play.limit(v)
				local v4199 = v4187 and t12["SlotPri" .. v.slot] == "EXCLUDE" and " | [EXCLUDED]"

				if not v4199 then
					v4199 = " | Limit " .. (v4198 == math.huge and "Any" or v4198)
				end

				v4197 = v4199
			else
				v4197 = " | [SKIPPED] Rarity"
				n92 += 1
			end

			t263[#t263 + 1] = #t263 + 1 .. "). " .. v.tag .. v4197
		end

		if #t263 == 0 then
			return "[WAITING] Awaiting Loadout"
		end

		if t12.AutoUpgrade then
			t263[#t263 + 1] = "Upgrades: " .. t1.Play.timingText()
		end

		if t1.Play.rarityActive() then
			table.insert(t263, 1, "[FILTER] Rarity | " .. t1.Play.names(t12.DeployRarities) .. " | " .. n92 .. " Skipped")
		elseif #t12.DeployRarities == 0 then
			t263[#t263 + 1] = "(No Rarity Picked = All)"
		end

		return table.concat(t263, "\n")
	end
end

t1.Pick.slotText = function(p839)
	local v4200 = t1.Play.slotHeader(p839)

	if t1.Pick.slot == p839 then
		return "[PICK] Slot " .. p839 .. " | " .. (UserInputService.TouchEnabled and "Tap" or "Click") .. " A Spot"
	end

	if t1.Ctx.place() ~= "MATCH" then
		return v4200
	end

	local v4201 = t1.Pick.count(p839)

	if v4201 == 0 then
		return v4200 .. "\n[NONE] Awaiting Spots"
	end

	return v4200 .. "\n[SAVED] " .. v4201 .. " Spots | " .. t1.Match.mapName()
end

do
	t1.Mods.live = function(p840)
		local function v4202()
			if p840 ~= "match" then
				return "[IDLE]"
			end

			if not t12.MatchMods then
				return "[IDLE]"
			end

			local t264 = {}

			for _, check in ipairs(t1.Mods.CHECKS) do
				if t1._has(t12.MatchSkips, check) then
					t264[#t264 + 1] = check
				end
			end

			if #t264 == 0 then
				return "[WAITING] Awaiting Selection | Checks"
			end

			return "[ACTIVE] Skipping " .. #t264 .. (#t264 == 1 and " Check" or " Checks") .. " | " .. table.concat(t264, ", ")
		end

		return v4202
	end
end

v30()
t12.MacroRecord = false
t1.State.load()
t1.Hook = {
	text = "[IDLE]",
	queue = {},
	sentAt = {},
	lastBy = {},
	countBy = {},
	nextAt = 0,
	fails = 0,
	sent = 0,
	round = 0,
	recordFile = "barrage_cameramantowerdefense_record.json",
	game = "Cameraman Tower Defense",
	accent = 14433340,
	groups = {
		Connected = "main",
		Summons = "summon",
		["Match Results"] = "match",
		["Session Summary"] = "match",
		Disconnected = "match",
		["Wave Alerts"] = "wave"
	},
	hosts = {
		["discord.com"] = true,
		["discordapp.com"] = true,
		["ptb.discord.com"] = true,
		["canary.discord.com"] = true
	}
}
t1.Hook.url = function()
	local match = tostring(t12.WebhookUrl or ""):match("^%s*(.-)%s*$")
	local match2 = match:match("^https://([%w%.]+)/api/webhooks/%d+/[%w_%-]+$")

	return match2 and t1.Hook.hosts[match2:lower()] and match or nil
end

do
	t1.Hook.allowed = function(p841)
		if not t12.Webhook then
			return false
		end

		local v4208 = t1.Hook.groups[p841]

		if v4208 == "summon" then
			return t12.HookSummons == true
		end

		if v4208 == "match" then
			return t12.HookMatch == true
		end

		if v4208 == "wave" then
			return t12.HookWaves == true
		end

		return v4208 == "main"
	end
end

t1.Hook.cooldown = function(p842)
	if p842 == "Match Results" then
		return 30
	end

	return 0
end

do
	t1.Hook.clock = function(p843)
		local v4209 = math.max(0, math.floor(t1._n(p843)))

		if v4209 >= 3600 then
			return math.floor(v4209 / 3600) .. "h " .. math.floor(v4209 % 3600 / 60) .. "m"
		end

		return math.floor(v4209 / 60) .. "m " .. v4209 % 60 .. "s"
	end
end

t1.Hook.rank = function(p844)
	local RarityOrder = t1.gameSettings().RarityOrder

	return type(RarityOrder) == "table" and tonumber(RarityOrder[p844]) or table.find(t2, p844) or 0
end
t1.Hook.rarities = function()
	local t265 = { "Every Pull" }
	local v4212 = t1.Rarities()

	for i = 2, #v4212 do
		t265[#t265 + 1] = v4212[i] .. " And Above"
	end

	return t265
end
t1.Hook.notable = function(p845)
	if t12.HookSummonRarity == "Every Pull" then
		return true
	end

	local match = tostring(t12.HookSummonRarity):match("^(.-) And Above$")
	local v4215 = t1.towerCfg(p845)

	return match ~= nil and v4215 ~= nil and t1.Hook.rank(v4215.Rarity) >= t1.Hook.rank(match)
end
t1.Hook.push = function(p846, p847, p848, p849, p850)
	if not t1.Hook.allowed(p846) then
		return
	end

	local queue = t1.Hook.queue

	if #queue >= 40 then
		table.remove(queue, 1)
	end

	local t266 = {}
	local v4218 = type(p849) == "table" and p849 or {}

	for _, v in ipairs(v4218) do
		if v[1] ~= nil and v[2] ~= nil then
			t266[#t266 + 1] = {
				tostring(v[1]):sub(1, 200),
				tostring(v[2]):sub(1, 200)
			}
		end
	end

	queue[#queue + 1] = {
		kind = p846,
		title = tostring(p847):sub(1, 200),
		text = p848 ~= nil and tostring(p848):sub(1, 1000) or nil,
		fields = t266,
		ping = p850 == true
	}
	t1._wake("webhook")
end
t1.Hook.groupText = function(p851, p852)
	if not t12.Webhook then
		return "[WAITING] Awaiting Webhook"
	end

	if not t1.Hook.url() then
		return "[WAITING] Awaiting URL"
	end

	if t1.Hook.parked then
		return "[FAILED] Webhook | Invalid URL"
	end

	return t1.Hook.lastBy[p851] or p852
end
t1.Hook.greet = function()
	local v4221 = t1.Hook.url()

	if not t12.Webhook or not v4221 or t1.Hook.greeted == v4221 then
		return
	end

	t1.Hook.greeted = v4221

	local t267 = {}

	if t12.HookSummons then
		t267[#t267 + 1] = "Summons"
	end

	if t12.HookWaves then
		t267[#t267 + 1] = "Waves"
	end

	if t12.HookMatch then
		t267[#t267 + 1] = "Match Results"
	end

	t1.Hook.push("Connected", "Webhook Connected", "-# Alerts for " .. LocalPlayer.Name .. " arrive here while the script runs.", { {
		"Alerts",
		#t267 > 0 and table.concat(t267, ", ") or "None"
	} })
end
t1._wakeHandlers.hookGreet = t1.Hook.greet
t1.Hook.fetchIcon = function(p853)
	local ok, result = pcall(p853, {
		Url = "https://thumbnails.roblox.com/v1/games/icons?universeIds=" .. game.GameId .. "&size=512x512&format=Png&isCircular=false",
		Method = "GET"
	})

	if not ok or type(result) ~= "table" or t1._n(result.StatusCode) ~= 200 then
		return nil
	end

	local ok2, result2 = pcall(HttpService.JSONDecode, HttpService, result.Body or "")
	local v4227 = ok2 and type(result2) == "table" and type(result2.data) == "table" and result2.data[1]
	local imageUrl = type(v4227) == "table" and v4227.state == "Completed" and v4227.imageUrl

	return type(imageUrl) == "string" and imageUrl:match("^https://") and imageUrl or nil
end
t1.Hook.embed = function(p854)
	local Hook = t1.Hook
	local t268 = {
		author = {
			name = "BARRAGE"
		},
		color = Hook.accent,
		footer = {
			text = Hook.game .. " | " .. LocalPlayer.Name .. " | " .. DateTime.now():FormatLocalTime("HH:mm", "en-us")
		},
		thumbnail = Hook.icon and {
			url = Hook.icon
		} or nil
	}

	if #p854 == 1 then
		local v4231 = p854[1]

		t268.description = "# " .. v4231.title .. (v4231.text and "\n" .. v4231.text or "")

		local t269 = {}

		for _, field in ipairs(v4231.fields) do
			t269[#t269 + 1] = {
				name = field[1],
				value = "**" .. field[2] .. "**",
				inline = true
			}
		end

		t268.fields = #t269 > 0 and t269 or nil

		return t268
	end

	t268.description = "# " .. #p854 .. " Alerts"

	local fields = {}
	local v4236 = math.min(math.floor(4800 / #p854), 1024)

	for _, v in ipairs(p854) do
		local t270 = { v.text }

		for _, field in ipairs(v.fields) do
			t270[#t270 + 1] = field[1] .. ": **" .. field[2] .. "**"
		end

		local v4242 = table.concat(t270, "\n")

		fields[#fields + 1] = {
			name = v.title,
			value = v4242 ~= "" and v4242:sub(1, v4236) or "Sent",
			inline = false
		}
	end

	t268.fields = fields

	return t268
end

do
	t1.Hook.send = function(p855, p856, p857)
		local v4243 = false

		for _, v in ipairs(p857) do
			v4243 = v4243 or v.ping
		end

		local match = tostring(t12.WebhookUserId or ""):match("^%s*(%d+)%s*$")
		local v4247 = v4243 and match or nil
		local ok, result = pcall(HttpService.JSONEncode, HttpService, {
			username = "BARRAGE | " .. t1.Hook.game,
			content = v4247 and "<@" .. v4247 .. ">" or nil,
			allowed_mentions = {
				parse = {},
				users = v4247 and { v4247 } or {}
			},
			embeds = { t1.Hook.embed(p857) }
		})

		if not ok then
			return "rejected"
		end

		local ok2, result2 = pcall(p855, {
			Url = p856,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = result
		})

		if not ok2 or type(result2) ~= "table" then
			return "No Reply"
		end

		local v4252 = t1._n(result2.StatusCode)

		if v4252 >= 200 and v4252 < 300 then
			return "ok"
		end

		if v4252 ~= 429 then
			if v4252 == 401 or v4252 == 403 or v4252 == 404 then
				return "invalid"
			end

			if v4252 == 400 or v4252 == 413 then
				return "rejected"
			end

			return v4252 > 0 and "HTTP " .. v4252 or "No Reply"
		end

		local ok3, result3 = pcall(HttpService.JSONDecode, HttpService, result2.Body or "")
		local v4255 = ok3 and type(result3) == "table" and tonumber(result3.retry_after)
		local Headers = type(result2.Headers) == "table" and result2.Headers or {}
		local v4257 = v4255

		if not v4257 then
			v4257 = tonumber(Headers["Retry-After"] or Headers["retry-after"])
		end

		return "limited", math.clamp(v4257 or 5, 1, 300)
	end
end

do
	t1.Hook.step = function()
		local Hook = t1.Hook

		if not t12.Webhook then
			table.clear(Hook.queue)
			Hook.text = "[IDLE]"

			return
		end

		local v4259 = Hook.url()

		if not v4259 then
			Hook.text = tostring(t12.WebhookUrl or ""):match("%S") and "[FAILED] Webhook | Invalid URL" or "[WAITING] Awaiting URL"

			return
		end

		if Hook.parked == v4259 then
			return
		end

		Hook.parked = nil

		if type(shared._barrageRequest) ~= "function" then
			Hook.text = "[UNAVAILABLE] Webhook | No HTTP Request"

			return
		end

		while t12.Webhook and t1.Running and Hook.url() == v4259 do
			local now = os.clock()

			if now < Hook.nextAt then
				t1._alarm("webhook", Hook.nextAt - now, "hook:next")

				return
			end

			local t271 = {}
			local queue = {}
			local v4263

			for _, v in ipairs(Hook.queue) do
				local v4266 = Hook.cooldown(v.kind)
				local v4267 = v4266 > 0

				if v4267 then
					v4267 = (Hook.sentAt[v.kind] or -math.huge) + v4266
				end

				v4267 = v4267 or 0

				if v4267 <= now and #t271 < 10 then
					t271[#t271 + 1] = v
				else
					queue[#queue + 1] = v

					if now < v4267 then
						v4263 = math.min(v4263 or math.huge, v4267 - now)
					end
				end
			end

			if #t271 == 0 then
				if v4263 then
					t1._timer("webhook", v4263)
					t1._alarm("webhook", v4263, "hook:cooldown")
					Hook.text = "[WAITING] Awaiting Cooldown | " .. #queue .. " Queued " .. t1._timerTag("webhook")
				else
					Hook.text = Hook.last or "[READY] Webhook | Listening"
				end

				return
			end

			Hook.queue = queue

			if Hook.icon == nil then
				Hook.icon = Hook.fetchIcon(shared._barrageRequest) or false
			end

			Hook.text = "[SEND] Webhook | " .. #t271 .. (#t271 == 1 and " Alert" or " Alerts")
			t1._wake("status")

			local v4268, v4269 = Hook.send(shared._barrageRequest, v4259, t271)

			Hook.nextAt = os.clock() + 2

			if v4268 == "ok" then
				Hook.fails = 0
				Hook.sent += #t271

				for _, v in ipairs(t271) do
					Hook.sentAt[v.kind] = os.clock()

					local v4272 = Hook.groups[v.kind] or "main"

					Hook.countBy[v4272] = (Hook.countBy[v4272] or 0) + 1
					Hook.lastBy[v4272] = "[SENT] " .. v.title .. " | " .. Hook.countBy[v4272] .. " Sent"
				end

				Hook.last = "[SENT] " .. (#t271 == 1 and t271[1].title or #t271 .. " Alerts") .. " | " .. Hook.sent .. " Sent"
				Hook.text = Hook.last

				continue
			end

			if v4268 == "invalid" then
				Hook.parked = v4259
				table.clear(Hook.queue)
				Hook.text = "[FAILED] Webhook | Invalid URL"

				return
			end

			if v4268 == "rejected" then
				Hook.text = "[FAILED] Webhook | Message Refused"
			else
				if v4268 == "limited" then
					Hook.nextAt = os.clock() + v4269
				else
					Hook.fails += 1
					Hook.nextAt = os.clock() + (Hook.fails >= 3 and 60 or 3 * Hook.fails)
				end

				if v4268 == "limited" or not (Hook.fails >= 3) then
					for i = #t271, 1, -1 do
						table.insert(Hook.queue, 1, t271[i])
					end

					t1._timer("webhook", Hook.nextAt - os.clock())
					Hook.text = "[RETRY] Webhook | " .. (v4268 == "limited" and "Rate Limited" or v4268) .. " " .. t1._timerTag("webhook")
				else
					Hook.fails = 0
					t1._timer("webhook", 60)
					Hook.text = "[FAILED] Webhook | " .. v4268 .. " " .. t1._timerTag("webhook")
				end
			end
		end
	end
end

do
	t1.Hook.run = function()
		t1.Hook.step()
		t1._wake("status")
	end
end

t1.Hook.summons = function(p858, p859)
	if not t1.Hook.allowed("Summons") or type(p858) ~= "table" then
		return
	end

	local t272 = {}
	local t273 = {}
	local v4276
	local n93 = -1

	for _, v in ipairs(p858) do
		local Name = type(v) == "table" and v.Name or v

		if type(Name) == "string" and t1.Hook.notable(Name) then
			local v4281 = t1.towerCfg(Name)
			local v4282 = v4281 and tostring(v4281.Rarity) or "?"

			t273[#t273 + 1] = Name
			t272[#t272 + 1] = "- **" .. Name .. "** (" .. v4282 .. ")"

			local v4283 = t1.Hook.rank(v4282)

			if n93 < v4283 then
				v4276 = v4282
				n93 = v4283
			end
		end
	end

	if #t273 == 0 then
		return
	end

	local v4284 = #p858 .. (#p858 == 1 and " Pull" or " Pulls")
	local v4285 = t12.HookSummonPing == true

	if #t273 == 1 then
		t1.Hook.push("Summons", "Pulled " .. t273[1], nil, {
			{
				"Rarity",
				v4276
			},
			{
				"Source",
				p859
			},
			{
				"Summon",
				v4284
			}
		}, v4285)
	else
		t1.Hook.push("Summons", "Pulled " .. #t273 .. " Units", table.concat(t272, "\n"), {
			{
				"Best Rarity",
				v4276
			},
			{
				"Source",
				p859
			},
			{
				"Summon",
				v4284
			}
		}, v4285)
	end
end

do
	t1._wakeHandlers.hookWave = function()
		local Hook = t1.Hook

		if t1.Ctx.place() ~= "MATCH" then
			return
		end

		local v4287, v4288 = t1.Match.waves()
		local waveKey = Hook.round .. ":" .. v4287

		if Hook.waveKey == waveKey then
			return
		end

		local now = os.clock()
		local waveClock = Hook.waveClock

		Hook.waveKey = waveKey
		Hook.waveClock = now

		if v4287 <= 1 or not Hook.roundAt then
			Hook.roundAt = now
		end

		if v4287 <= 0 or not Hook.allowed("Wave Alerts") then
			return
		end

		if v4287 % math.max(1, t1._n(t12.HookWaveEvery, 1)) ~= 0 then
			return
		end

		local v4292 = t1._set(t12.HookWaveActions)
		local t274 = {}
		local t275 = { "-# " .. tostring(workspace:GetAttribute("Map") or "Match") .. " | " .. t1.Match.mode() }

		if v4292.Cash then
			t274[#t274 + 1] = {
				"Cash",
				"$" .. t1._num(t1.Match.money())
			}
		end

		if v4292["Base Health"] then
			local v4295 = t1._at(workspace, "Game.Base")
			local attribute = v4295 and v4295:GetAttribute("Health")
			local attribute2 = v4295 and v4295:GetAttribute("MaxHealth")

			if type(attribute) == "number" and type(attribute2) == "number" and attribute2 > 0 then
				t274[#t274 + 1] = {
					"Base Health",
					t1._num(attribute) .. "/" .. t1._num(attribute2) .. " (" .. math.floor(math.clamp(attribute / attribute2, 0, 1) * 100 + 0.5) .. "%)"
				}
			end
		end

		if v4292["Enemies Left"] then
			t274[#t274 + 1] = {
				"Enemies Left",
				#t1.Match.enemies()
			}
		end

		if v4292["Wave Time"] and waveClock then
			t274[#t274 + 1] = {
				"Last Wave",
				Hook.clock(now - waveClock)
			}
		end

		if v4292["Towers Placed"] then
			local v4298 = t1.Match.units()
			local t276 = {}
			local t277 = {}

			for _, v in ipairs(v4298) do
				local v4303 = t276[v.name]

				if not v4303 then
					v4303 = {
						name = v.name,
						n = 0,
						lo = math.huge,
						hi = 0
					}
					t276[v.name] = v4303
					t277[#t277 + 1] = v4303
				end

				local v4304 = v4303.n + 1
				local lo = math.min(v4303.lo, v.level)
				local hi = math.max(v4303.hi, v.level)

				v4303.n = v4304
				v4303.lo = lo
				v4303.hi = hi
			end

			table.sort(t277, function(p860, p861)
				return p860.n > p861.n or p860.n == p861.n and p860.name < p861.name
			end)

			for _, v in ipairs(t277) do
				t275[#t275 + 1] = "- **" .. v.name .. "** x" .. v.n .. " (Lv " .. (v.lo == v.hi and v.hi or v.lo .. "-" .. v.hi) .. ")"
			end

			t274[#t274 + 1] = {
				"Towers",
				#v4298
			}
		end

		Hook.push("Wave Alerts", "Wave " .. v4287 .. (v4288 > 0 and "/" .. v4288 or ""), table.concat(t275, "\n"), t274, v4292["Ping Me"] == true)
	end
end

t1.Hook.record = function()
	local _record = t1.Hook._record

	if not _record then
		if readfile then
			local ok, result = pcall(function()
				return HttpService:JSONDecode(readfile(t1.Hook.recordFile))
			end)

			if ok and type(result) == "table" and os.time() - t1._n(result.updatedAt) < 3600 then
				_record = result
			end
		end

		_record = _record or {
			startedAt = os.time()
		}

		for _, v in ipairs({
			"wins",
			"losses",
			"streak",
			"best",
			"coins",
			"lastAt"
		}) do
			_record[v] = t1._n(_record[v])
		end

		_record.startedAt = t1._n(_record.startedAt, os.time())
		_record.updatedAt = t1._n(_record.updatedAt, os.time())
		_record.lastKey = type(_record.lastKey) == "string" and _record.lastKey or ""
		t1.Hook._record = _record
	end

	return _record
end
t1.Hook.saveRecord = function()
	local v4314 = t1.Hook.record()

	v4314.updatedAt = os.time()

	if writefile then
		pcall(function()
			writefile(t1.Hook.recordFile, HttpService:JSONEncode(v4314))
		end)
	end
end

do
	t1.Hook.resetRecord = function()
		t1.Hook._record = {
			wins = 0,
			losses = 0,
			streak = 0,
			best = 0,
			coins = 0,
			lastAt = 0,
			lastKey = "",
			startedAt = os.time(),
			updatedAt = os.time()
		}
		t1.Hook.saveRecord()
		t1._wake("status")
	end
end

t1.Hist = {
	VIEWS = {
		"Matches",
		"Maps",
		"Modes",
		"Rewards"
	}
}
t1.Hist.rows = function()
	local v4315 = t1.Hook.record()

	if type(v4315.rows) ~= "table" then
		v4315.rows = {}
	end

	return v4315.rows
end
t1.Hist.add = function(p862)
	local t278 = {}

	if t1._n(p862.reward) > 0 then
		t278[#t278 + 1] = "+" .. t1._num(p862.reward) .. " Coins"
	end

	if t1._n(p862.candy) > 0 then
		t278[#t278 + 1] = "+" .. t1._num(p862.candy) .. " Candy"
	end

	local v4317 = t1.Hist.rows()

	table.insert(v4317, 1, {
		t = os.time(),
		won = p862.won == true,
		mode = tostring(p862.mode ~= "" and p862.mode or "Normal"),
		map = tostring(p862.map or "Unknown Map"),
		waves = tonumber(p862.wave) or 0,
		total = tonumber(p862.total) or 0,
		secs = tonumber(p862.secs),
		rewards = t278
	})

	for i = #v4317, 101, -1 do
		v4317[i] = nil
	end

	t1.Hook.saveRecord()
	t1.Hist.refresh()
	t1._wake("status")
end
t1.Hist.lines = function(p863)
	local t279 = {}
	local v4320 = t1.Hist.rows()

	if p863 == "Modes" or p863 == "Maps" then
		local t280 = {}
		local t281 = {}

		for _, v in ipairs(v4320) do
			local map = p863 == "Maps" and v.map or v.mode
			local v4326 = t280[map]

			if not v4326 then
				v4326 = {
					w = 0,
					l = 0,
					best = 0
				}
				t280[map] = v4326
				t281[#t281 + 1] = map
			end

			if v.won then
				v4326.w += 1
			else
				v4326.l += 1
			end

			v4326.best = math.max(v4326.best, t1._n(v.waves))
		end

		for _, v in ipairs(t281) do
			local v4329 = t280[v]

			t279[#t279 + 1] = v .. " | " .. v4329.w .. "W " .. v4329.l .. "L (" .. math.floor(v4329.w / (v4329.w + v4329.l) * 100 + 0.5) .. "%) | Best Wave " .. v4329.best
		end

		return t279
	end

	for _, v in ipairs(v4320) do
		local v4332 = os.date("%H:%M", t1._n(v.t, os.time()))

		if p863 == "Rewards" then
			if type(v.rewards) == "table" and #v.rewards > 0 then
				t279[#t279 + 1] = v4332 .. " | " .. v.map .. " | " .. table.concat(v.rewards, ", ")
			end
		else
			t279[#t279 + 1] = v4332 .. " | " .. (v.won and "WIN" or "LOSS") .. " | " .. v.mode .. " | " .. v.map .. " | Wave " .. t1._n(v.waves) .. (t1._n(v.total) > 0 and "/" .. v.total or "") .. (v.secs and " | " .. t1.Hook.clock(v.secs) or "")
		end
	end

	return t279
end

do
	local function refresh()
		local Hist = t1.Hist

		if not t1.Running or not Hist.list then
			return
		end

		local t282 = {}

		if t12.HistoryPreview then
			local v4336 = Hist.lines(t12.HistoryView)

			for i = 1, math.min(math.clamp(math.floor(t1._n(t12.HistoryAmount, 25)), 5, 100), #v4336) do
				if t12.HistoryOrder == "Oldest" then
					table.insert(t282, 1, v4336[i])
				else
					t282[#t282 + 1] = v4336[i]
				end
			end
		end

		local sig = tostring(t12.HistoryView) .. "\0" .. table.concat(t282, "\0")

		if sig == Hist.sig then
			return
		end

		Hist.sig = sig
		pcall(function()
			Hist.list:SetItems(t282)
		end)
	end

	t1.Hist.refresh = refresh
end

t1.Hist.status = function()
	local v4339 = t1.Hist.rows()

	if #v4339 == 0 then
		return "[WAITING] Awaiting Match | No Rounds This Session"
	end

	return t1.Hook.recordText() .. "\n[SESSION] " .. #v4339 .. (#v4339 == 1 and " Round" or " Rounds") .. " | Since " .. os.date("%H:%M", t1._n(t1.Hook.record().startedAt, os.time()))
end
t1.Hook.recordLine = function(p864)
	local v4340 = p864.wins + p864.losses
	local v4341 = v4340 > 0 and math.floor(p864.wins / v4340 * 100 + 0.5) or 0

	return p864.wins .. "W " .. p864.losses .. "L (" .. v4341 .. "%)", p864.streak > 0 and "W" .. p864.streak or p864.streak < 0 and "L" .. -p864.streak or "None"
end

do
	t1.Hook.recordText = function()
		local v4342 = t1.Hook.record()

		if v4342.wins + v4342.losses == 0 then
			return "[RECORD] No Rounds | This Session"
		end

		local v4343, v4344 = t1.Hook.recordLine(v4342)

		return "[RECORD] " .. v4343 .. " | " .. v4344 .. " Streak, Best W" .. v4342.best
	end
end

do
	t1.Hook.roundEnd = function(p865)
		local Hook = t1.Hook
		local v4346, v4347 = t1.Match.waves()
		local v4348 = Hook.record()
		local lastKey = tostring(game.JobId) .. ":" .. tostring(p865) .. ":" .. v4346

		if v4348.lastKey == lastKey and os.time() - v4348.lastAt < 120 then
			return
		end

		local now = os.time()

		v4348.lastKey = lastKey
		v4348.lastAt = now

		local v4351 = t1.Match.plan(t1.Match.mode())
		local v4352 = p865 and v4351 and t1._n(v4351.reward) or not p865 and v4346 or 0
		local v4353 = p865 and v4351 and t1._n(v4351.candy) or 0

		v4348.coins += v4352

		if p865 then
			v4348.wins += 1
			v4348.streak = v4348.streak > 0 and v4348.streak + 1 or 1
		else
			v4348.losses += 1
			v4348.streak = v4348.streak < 0 and v4348.streak - 1 or -1
		end

		v4348.best = math.max(v4348.best, v4348.streak)
		Hook.saveRecord()

		local t283 = {
			won = p865,
			wave = v4346,
			total = v4347,
			map = tostring(workspace:GetAttribute("Map") or "Match"),
			mode = t1.Match.mode(),
			reward = v4352,
			candy = v4353,
			secs = Hook.roundAt and os.clock() - Hook.roundAt
		}

		Hook.round += 1
		Hook.roundAt = nil
		Hook.waveClock = nil
		t1._wake("status")
		pcall(t1.Hist.add, t283)
		pcall(Hook.matchAlert, t283)
	end
end

t1.Hook.matchAlert = function(p866)
	if not t1.Hook.allowed("Match Results") then
		return
	end

	local v4355 = t1.Hook.record()
	local v4356 = v4355.wins + v4355.losses
	local v4357, v4358 = t1.Hook.recordLine(v4355)
	local HookMatchSend = t12.HookMatchSend

	if HookMatchSend == "Every Round" or HookMatchSend == "Wins Only" and p866.won or HookMatchSend == "Losses Only" and not p866.won then
		local v4360 = t1._set(t12.HookMatchDetails)
		local t284 = {}
		local mapAndMode = v4360["Map And Mode"]

		if mapAndMode then
			mapAndMode = "-# " .. p866.map .. (p866.mode ~= "" and " | " .. p866.mode or "")
		end

		mapAndMode = mapAndMode or p866.won and "-# Round won" or "-# Round lost"

		if v4360.Waves then
			local v4363 = #t284 + 1
			local s7 = "Wave"
			local wave = p866.wave
			local v4367 = p866.total > 0 and "/" .. p866.total or ""
			local t285 = {
				s7,
				wave .. v4367
			}

			t284[v4363] = t285
		end

		if v4360.Duration and p866.secs then
			t284[#t284 + 1] = {
				"Time",
				t1.Hook.clock(p866.secs)
			}
		end

		if v4360["Coins Reward"] and p866.reward > 0 then
			local v4368 = #t284 + 1
			local s8 = "Coins Reward"
			local v4371 = t1._num(p866.reward)
			local v4372 = p866.candy > 0 and " | +" .. t1._num(p866.candy) .. " Candy" or ""
			local t286 = {
				s8,
				"+" .. v4371 .. v4372
			}

			t284[v4368] = t286
		end

		if v4360["Session Record"] then
			t284[#t284 + 1] = {
				"Record",
				v4357
			}
			t284[#t284 + 1] = {
				"Streak",
				v4358
			}
		end

		local HookMatchActions = t1._has("HookMatchActions", p866.won and "Ping On Win" or "Ping On Loss")

		t1.Hook.push("Match Results", p866.won and "Victory" or "Defeat", mapAndMode, t284, HookMatchActions)
	end

	local v4374 = t1._n(t12.HookSummaryEvery)

	if v4374 > 0 and v4356 > 0 and v4356 % v4374 == 0 then
		local v4375 = math.max(os.time() - v4355.startedAt, 60)
		local t288 = {
			"Record",
			v4357
		}
		local s9 = "Best Streak"
		local best = v4355.best
		local v4381 = v4355.best == 1 and " Win" or " Wins"
		local t289 = {
			s9,
			best .. v4381
		}
		local t290 = {
			"Rounds Per Hour",
			string.format("%.1f", v4356 / (v4375 / 3600))
		}
		local t291 = {
			"Session Time",
			t1.Hook.clock(os.time() - v4355.startedAt)
		}
		local t287 = {
			t288,
			t289,
			t290,
			t291
		}

		if v4355.coins > 0 then
			t287[#t287 + 1] = {
				"Coins From Wins",
				"+" .. t1._num(v4355.coins)
			}
		end

		t1.Hook.push("Session Summary", "Session Summary", "-# " .. v4356 .. " rounds this session", t287, t1._has("HookMatchActions", "Ping On Summary"))
	end
end
t1._allWorkers[#t1._allWorkers + 1] = "webhook"

do
	t1._worker("webhook", t1.Hook, function()
		t1.Hook.run()
	end)
end

do
	t1.Hook.onError = function()
		local erred = tostring(game:GetService("GuiService"):GetErrorMessage() or "")

		if erred == "" or t1.Hook.erred == erred or not t1._has("HookMatchActions", "Disconnect Alert") then
			return
		end

		t1.Hook.erred = erred

		local v4385 = t1.Hook.record()
		local v4386 = t1.Hook.recordLine(v4385)

		t1.Hook.push("Disconnected", "Disconnected", "-# " .. erred:sub(1, 300), {
			{
				"Record",
				v4386
			},
			{
				"Session Time",
				t1.Hook.clock(os.time() - v4385.startedAt)
			}
		}, t1._has("HookMatchActions", "Ping On Disconnect"))
	end
end

do
	t1._conn(game:GetService("GuiService").ErrorMessageChanged, function()
		pcall(t1.Hook.onError)
	end)
end

t1.Hook.greeted = t12.Webhook and t1.Hook.url() or nil
t1._restoreIdentity()

local v4387, GlowButton, v4389
local v4390, v4391, v4392

do
	-- ═══════════════════════════════════════════════════════════
	-- Crefy (Obsidian/Linoria) Window + Barrage-compatible API shim
	-- ═══════════════════════════════════════════════════════════
	local _crWin = _CREFY_LIB:CreateWindow({
		Title           = "Cameraman TD | Auto",
		NotifySide      = "Right",
		ShowCustomCursor = false,
	})
	local _settingsTabRef = nil

	-- ── Section factory ──────────────────────────────────────
	local function _makeSection(gb)
		local sec = { _gb = gb }

		-- helper: vắng AddHelper = tooltip compat (Crefy ko có SetTooltip trực tiếp)
		local function _mkLink(flag)
			return {
				AddHelper = function() end,
				AddKeybind = function(_, k)
					local kbf = tostring(k.Flag or "")
					if kbf == "" then return { GetValue = function() end, SetValue = function() end } end
					pcall(function()
						local lbl = gb:AddLabel("   Keybind")
						lbl:AddKeyPicker(kbf, {
							Default = k.Default or "None",
							Mode    = "Toggle",
							Text    = "Keybind",
							NoUI    = false,
						})
						if k.Callback then
							pcall(function()
								Options[kbf]:OnChanged(function(v) pcall(k.Callback, v) end)
							end)
						end
					end)
					return {
						GetValue = function()
							return Options[kbf] and Options[kbf].Value or k.Default or "None"
						end,
						SetValue = function(_, v)
							pcall(function() Options[kbf]:SetValue(v) end)
						end,
					}
				end,
			}
		end

		-- AddToggle({Name, Default, Flag, Callback})
		function sec:AddToggle(o)
			local flag = tostring(o.Flag or "")
			if flag ~= "" then
				pcall(function()
					gb:AddToggle(flag, {
						Text     = tostring(o.Name or ""),
						Default  = o.Default == true,
						Callback = function(v)
							if o.Callback then pcall(o.Callback, v) end
						end,
					})
				end)
			end
			return {
				Link     = _mkLink(flag),
				SetValue = function(_, v)
					pcall(function() Toggles[flag]:SetValue(v == true) end)
				end,
				GetValue = function(_)
					return Toggles[flag] and Toggles[flag].Value
				end,
			}
		end

		-- AddDropdown({Name, Values, Default, Multi, Deselect, Flag, Callback})
		function sec:AddDropdown(o)
			local flag = tostring(o.Flag or "")
			local def  = o.Default
			if o.Multi and type(def) ~= "table" then def = {} end
			if flag ~= "" then
				pcall(function()
					gb:AddDropdown(flag, {
						Text       = tostring(o.Name or ""),
						Values     = o.Values or {},
						Default    = def,
						Multi      = o.Multi == true,
						Searchable = #(o.Values or {}) > 8,
						Callback   = function(v)
							if o.Callback then pcall(o.Callback, v) end
						end,
					})
				end)
			end
			return {
				Link      = _mkLink(flag),
				SetValue  = function(_, v)
					pcall(function() Options[flag]:SetValue(v) end)
				end,
				GetValue  = function(_)
					return Options[flag] and Options[flag].Value
				end,
				SetValues = function(_, vals)
					pcall(function() Options[flag]:SetValues(vals) end)
				end,
			}
		end

		-- AddSlider({Name, Min, Max, Default, Round, Suffix, Flag, Callback})
		function sec:AddSlider(o)
			local flag = tostring(o.Flag or "")
			if flag ~= "" then
				pcall(function()
					gb:AddSlider(flag, {
						Text     = tostring(o.Name or ""),
						Default  = tonumber(o.Default) or tonumber(o.Min) or 0,
						Min      = tonumber(o.Min)     or 0,
						Max      = tonumber(o.Max)     or 100,
						Rounding = tonumber(o.Round)   or 0,
						Suffix   = o.Suffix or "",
						Callback = function(v)
							if o.Callback then pcall(o.Callback, v) end
						end,
					})
				end)
			end
			return {
				Link     = _mkLink(flag),
				SetValue = function(_, v)
					pcall(function() Options[flag]:SetValue(v) end)
				end,
				GetValue = function(_)
					return Options[flag] and Options[flag].Value
				end,
			}
		end

		-- AddRangeSlider → 2 sliders riêng (Crefy không có RangeSlider)
		function sec:AddRangeSlider(o)
			local flag    = tostring(o.Flag or "")
			local minFlag = flag .. "Min"
			local maxFlag = flag .. "Max"
			local minVal  = tonumber(o.Min)        or 0
			local maxVal  = tonumber(o.Max)        or 10
			local defMin  = tonumber(o.DefaultMin) or minVal
			local defMax  = tonumber(o.DefaultMax) or maxVal
			local round   = tonumber(o.Round)      or 0
			local suffix  = o.Suffix or " s"

			pcall(function()
				gb:AddSlider(minFlag, {
					Text     = tostring(o.Name or "") .. " Min",
					Default  = defMin, Min = minVal, Max = maxVal,
					Rounding = round, Suffix = suffix,
					Callback = function(v)
						if o.Callback then
							local hi = Options[maxFlag] and Options[maxFlag].Value or maxVal
							pcall(o.Callback, { Min = v, Max = hi })
						end
					end,
				})
				gb:AddSlider(maxFlag, {
					Text     = tostring(o.Name or "") .. " Max",
					Default  = defMax, Min = minVal, Max = maxVal,
					Rounding = round, Suffix = suffix,
					Callback = function(v)
						if o.Callback then
							local lo = Options[minFlag] and Options[minFlag].Value or minVal
							pcall(o.Callback, { Min = lo, Max = v })
						end
					end,
				})
			end)

			local c = { Link = _mkLink(flag) }
			function c:SetValue(v)
				if type(v) == "table" then
					pcall(function() Options[minFlag]:SetValue(v.Min or minVal) end)
					pcall(function() Options[maxFlag]:SetValue(v.Max or maxVal) end)
				end
			end
			return c
		end

		-- AddSegmented → Dropdown (Crefy không có Segmented)
		function sec:AddSegmented(o)
			local flag = "__seg_" .. tostring(o.Name or ""):gsub("[^%w]", "_")
			pcall(function()
				gb:AddDropdown(flag, {
					Text     = tostring(o.Name or ""),
					Values   = o.Values or {},
					Default  = o.Default,
					Multi    = o.Multi == true,
					Callback = function(v)
						if o.Callback then pcall(o.Callback, v) end
					end,
				})
			end)
			local c = { Link = _mkLink(flag) }
			function c:SetValue(v) pcall(function() Options[flag]:SetValue(v) end) end
			return c
		end

		-- AddParagraph({Title, Content}) → Label + metatable text tracking
		function sec:AddParagraph(o)
			local title   = tostring(o.Title   or "Status")
			local init    = tostring(o.Content or "[IDLE]")
			local lblIdx  = "__para_" .. title:gsub("[^%w]", "_") .. tostring(math.random(9999))
			local _txt    = init

			pcall(function()
				gb:AddLabel(lblIdx, { Text = title .. ":  " .. init, DoesWrap = false })
			end)

			local p = {}
			function p:SetContent(v)
				_txt = tostring(v or "")
				pcall(function()
					if Options[lblIdx] and Options[lblIdx].SetText then
						Options[lblIdx]:SetText(title .. ":  " .. _txt)
					end
				end)
			end
			function p:SetIcon(_) end

			return setmetatable(p, {
				__index = function(_, k)
					if k == "text" then return _txt end
				end,
				__newindex = function(t, k, v)
					if k == "text" then
						_txt = tostring(v or "")
						pcall(function()
							if Options[lblIdx] and Options[lblIdx].SetText then
								Options[lblIdx]:SetText(title .. ":  " .. _txt)
							end
						end)
					else
						rawset(t, k, v)
					end
				end,
			})
		end

		-- AddProgressBar({Name, Default, Max, Suffix}) → Label
		function sec:AddProgressBar(o)
			local name   = tostring(o.Name or "Progress")
			local lblIdx = "__bar_" .. name:gsub("[^%w]", "_") .. tostring(math.random(9999))
			pcall(function()
				gb:AddLabel(lblIdx, { Text = name .. ":  0%", DoesWrap = false })
			end)
			local c = {}
			function c:SetValue(v)
				local pct = math.floor(tonumber(v) or 0)
				pcall(function()
					if Options[lblIdx] and Options[lblIdx].SetText then
						Options[lblIdx]:SetText(name .. ":  " .. pct .. "%")
					end
				end)
			end
			function c:SetText(_) end
			return c
		end

		-- AddColorPicker({Name, Default, Callback}) → Label:AddColorPicker
		function sec:AddColorPicker(o)
			local flag = "__cp_" .. tostring(o.Name or ""):gsub("[^%w]", "_")
			pcall(function()
				local lbl = gb:AddLabel(tostring(o.Name or "Color"))
				lbl:AddColorPicker(flag, {
					Default     = o.Default or Color3.fromRGB(255, 255, 255),
					Title       = tostring(o.Name or "Color"),
					Transparency = 0,
					Callback    = function(v)
						if o.Callback then pcall(o.Callback, v) end
					end,
				})
			end)
			local c = { Link = _mkLink(flag) }
			function c:SetValue(v)
				pcall(function() Options[flag]:SetValueRGB(v) end)
			end
			return c
		end

		return sec
	end

	-- ── Tab factory ──────────────────────────────────────────
	local function _makeTab(tabObj)
		local tab = {}
		function tab:DrawSection(o)
			local name = tostring(o.Name or "Section")
			local gb   = (o.Position or "left") == "right"
				and tabObj:AddRightGroupbox(name)
				or  tabObj:AddLeftGroupbox(name)
			return _makeSection(gb)
		end
		return tab
	end

	-- ── t1 UI objects ────────────────────────────────────────
	t1.Win = {
		DrawCategory = function() end,
		DrawTab = function(_, o)
			local name   = tostring(o.Name or "Tab")
			local tabObj = _crWin:AddTab(name, o.Icon)
			if name == "Settings" then _settingsTabRef = tabObj end
			return _makeTab(tabObj)
		end,
	}

	t1.Hub = {
		Destroy = function() pcall(function() _CREFY_LIB:Unload() end) end,
	}

	t1.Notify = function(title, msg, duration)
		local text = msg ~= nil
			and (tostring(title or "") .. ": " .. tostring(msg))
			or  tostring(title or "")
		pcall(function()
			_CREFY_LIB:Notify({
				Title       = text,
				Description = "",
				Time        = tonumber(duration) or 4,
			})
		end)
	end

	t1.CfgMgr = {
		LoadConfig           = function() end,
		LoadConfigFromString = function() end,
	}

	GlowButton = function(section, name, callback)
		if type(section) == "table" and section._gb then
			pcall(function()
				section._gb:AddButton({
					Text = tostring(name or "Action"),
					Func = function() pcall(callback) end,
				})
			end)
		end
	end

	v4387 = {
		BuildSettings = function()
			pcall(function()
				_CREFY_THEME:SetLibrary(_CREFY_LIB)
				_CREFY_SAVE:SetLibrary(_CREFY_LIB)
				_CREFY_SAVE:IgnoreThemeSettings()
				_CREFY_SAVE:SetIgnoreIndexes({ "MenuKeybind" })
				_CREFY_THEME:SetFolder("CTD_Cameraman")
				_CREFY_SAVE:SetFolder("CTD_Cameraman/ctd")
				if _settingsTabRef then
					-- Thêm menu keybind vào Settings tab
					local menuGb = _settingsTabRef:AddLeftGroupbox("Menu", "settings")
					menuGb:AddLabel("Menu Bind")
						:AddKeyPicker("MenuKeybind", {
							Default = "RightShift",
							NoUI    = true,
							Text    = "Toggle Menu",
						})
					menuGb:AddButton({
						Text = "Unload",
						Func = function() pcall(function() _CREFY_LIB:Unload() end) end,
					})
					_CREFY_SAVE:BuildConfigSection(_settingsTabRef)
					_CREFY_THEME:ApplyToTab(_settingsTabRef)
					_CREFY_SAVE:LoadAutoloadConfig()
				end
				_CREFY_LIB.ToggleKeybind = Options.MenuKeybind
			end)
		end,
	}

	t1._multiFlags = {}
	t1._refreshSig = setmetatable({}, {
		__mode = "k"
	})
	t1._setControl = function(p872, p873)
		local v4434 = t1._ctl[p872]

		if not v4434 or not v4434.SetValue then
			return
		end

		local v4435 = p873

		if t1._multiFlags[p872] and type(p873) == "table" then
			v4435 = t1._set(p873)
		end

		pcall(function()
			v4434:SetValue(v4435)
		end)
	end
	t1._settingsChanged = function()
		if t1.Queue and t1.Queue._tt then
			table.clear(t1.Queue._tt)
		end

		for _, allWorker in ipairs(t1._allWorkers) do
			t1._wakeThrottled(allWorker, 0.2)
		end

		t1._wakeThrottled("walk", 0.2)
		t1._wakeThrottled("status", 0.2)
	end
	t1._secFlags = {}
	t1._kbCtl = {}
	t1._track = function(p874, p875)
		local v4438 = t1._secFlags[p874]

		if not v4438 then
			v4438 = {}
			t1._secFlags[p874] = v4438
		end

		if not table.find(v4438, p875) then
			v4438[#v4438 + 1] = p875
		end
	end
	t1._restoreValue = {}
	t1._restore = function(p876, p877, p878)
		if type(p877) == "function" then
			p878 = p877
		end

		GlowButton(p876, "Restore Defaults", function()
			t1._applyingPreset = true

			local v4439 = t1._secFlags[p876] or {}

			for _, v in ipairs(v4439) do
				local v4442 = t14[v]

				if t1._restoreValue[v] then
					local ok, result2 = pcall(t1._restoreValue[v])

					v4442 = ok and result2 or nil
				end

				if v4442 ~= nil then
					if type(v4442) == "table" then
						v4442 = table.clone(v4442)
					end

					t12[v] = v4442
					t1._setControl(v, v4442)

					if t1._kbCtl[v] then
						pcall(function()
							t1._kbCtl[v]:SetValue(v4442)
						end)
					end
				end
			end

			t1._applyingPreset = false

			if p878 then
				p878()
			end

			t1._saveSoon()
			t1._settingsChanged()
			t1._wake("esp")
		end)
	end
	t1._presetOwner = {}
	t1._applyingPreset = false
	t1._markCustom = function(p879)
		if t1._applyingPreset or t1._loadingCfg then
			return
		end

		local v4445 = t1._presetOwner[p879]

		if v4445 and t12[v4445] ~= "Custom" then
			t12[v4445] = "Custom"
			t1._applyingPreset = true
			t1._setControl(v4445, "Custom")
			t1._applyingPreset = false
		end
	end
	t1._applyValues = function(p880)
		t1._applyingPreset = true

		for k, v in pairs(p880) do
			if type(v) == "table" then
				v = table.clone(v)
			end

			t12[k] = v
			t1._setControl(k, v)
		end

		t1._applyingPreset = false
		t1._saveSoon()
		t1._settingsChanged()
	end
	t1._sorted = function(p881)
		local v4448 = table.clone(p881)

		local function v4449(p882)
			local v4450 = tostring(p882):lower()

			return (v4450:gsub("%d+", function(p883)
				return ("%012d"):format(tonumber(p883))
			end))
		end

		table.sort(v4448, function(p884, p885)
			return v4449(p884) < v4449(p885)
		end)

		return v4448
	end
	t1._refreshValues = function(p886, p887, p888)
		if not p886 then
			return
		end

		local v4451 = type(p888) == "table" and "" or tostring(p888)

		if type(p888) == "table" then
			local t296 = {}

			for k, v in pairs(p888) do
				if v then
					t296[#t296 + 1] = tostring(k)
				end
			end

			table.sort(t296)
			v4451 = table.concat(t296, ",")
		end

		local v4455 = table.concat(p887, "\31") .. "|" .. v4451

		if t1._refreshSig[p886] == v4455 then
			return
		end

		t1._refreshSig[p886] = v4455
		t1._refreshing = true
		pcall(function()
			p886:SetValues(p887)

			if p888 ~= nil then
				p886:SetValue(p888)
			end
		end)
		t1._refreshing = false
	end
	t1._loadoutPresets = {}
	t1._liveMulti = function(p889, p890, p891)
		if type(p890) ~= "table" or #p890 == 0 then
			return
		end

		local v4456 = type(t12[p889]) == "table" and t12[p889] or {}
		local v4457 = type(t12[p889 .. "Seen"]) == "table" and t12[p889 .. "Seen"] or {}
		local v4458 = #v4457 == 0

		if not v4458 then
			v4458 = true

			local v4459, v4460, v4461 = ipairs(v4457)
			local v4462 = geniter(v4459, v4460, v4461)

			while true do
				local v4463 = table.pack(v4462())

				if v4463[1] then
					if not table.find(v4456, v4463[3]) then
						v4458 = false

						break
					end
				else
					break
				end
			end
		end

		local t297 = {}

		if v4458 then
			t297 = table.clone(p890)
		else
			local v4465, v4466, v4467 = ipairs(v4456)

			for _, v in v4465, v4466, v4467 do
				if table.find(p890, v) then
					t297[#t297 + 1] = v
				end
			end
		end

		local v4470 = table.concat(t297, "\31") ~= table.concat(v4456, "\31") or table.concat(p890, "\31") ~= table.concat(v4457, "\31")
		local v4471 = p889 .. "Seen"
		local v4472 = table.clone(p890)

		t12[p889] = t297
		t12[v4471] = v4472

		if p891 then
			t1._refreshValues(p891, p890, t1._set(t297))
		end

		if v4470 then
			t1._saveSoon()
		end
	end

	local function preset(p892, p893, p894, p895, p896, p897)
		t1._track(p892, p894)

		for _, v in ipairs(p896) do
			t1._presetOwner[v] = p894
		end

		local t298 = { "Custom" }

		for k in pairs(p895) do
			t298[#t298 + 1] = k
		end

		local v4478 = p892:AddDropdown({
			Name = p893,
			Values = t1._sorted(t298),
			Default = t12[p894],
			Flag = p894,
			Callback = function(p898)
				if t1._applyingPreset or t1._refreshing or p898 == t12[p894] then
					return
				end

				t12[p894] = p898

				if t1._loadingCfg then
					return
				end

				local v4479 = p895[p898]

				if type(v4479) == "function" then
					v4479 = v4479()
				end

				if type(v4479) == "table" then
					t1._applyValues(v4479)
				end

				t1._saveSoon()
			end
		})

		t1._ctl[p894] = v4478

		if p897 and v4478.Link then
			v4478.Link:AddHelper({
				Text = p897
			})
		end

		return v4478
	end

	t1._preset = preset
	t1._flagGen = {}
	t1._toggle = function(p899, p900, p901, p902, p903, p904)
		if p904 == nil and t12[p901 .. "Keybind"] ~= nil then
			p904 = p901 .. "Keybind"
		end

		t1._track(p899, p901)

		if p904 then
			t1._track(p899, p904)
		end

		local v4480 = p899:AddToggle({
			Name = p900,
			Default = t12[p901],
			Flag = p901,
			Callback = function(p905)
				t12[p901] = p905 == true
				t1._flagGen[p901] = (t1._flagGen[p901] or 0) + 1
				t1._saveSoon()

				if p903 then
					p903(t12[p901])
				end

				t1._settingsChanged()
			end
		})

		t1._ctl[p901] = v4480

		if p902 and v4480.Link then
			v4480.Link:AddHelper({
				Text = p902
			})
		end

		if p904 and v4480.Link then
			local v4481 = v4480.Link:AddKeybind({
				Default = t12[p904],
				Flag = p904,
				Callback = function(p906)
					t12[p904] = p906
					t1._saveSoon()
				end
			})

			t1._kbReg = t1._kbReg or {}
			t1._kbReg[#t1._kbReg + 1] = {
				kb = v4481,
				control = v4480,
				flag = p901,
				kbFlag = p904
			}
			t1._kbCtl[p904] = v4481
		end

		return v4480
	end
	t1._dropdown = function(p907, p908, p909, p910, p911, p912, p913, p914)
		t1._track(p907, p910)

		local v4482 = p907:AddDropdown({
			Name = p908,
			Values = p914 and p909 or t1._sorted(p909),
			Default = p911 and t1._set(t12[p910]) or t12[p910],
			Multi = p911 == true,
			Flag = p910,
			Callback = function(p915)
				if t1._refreshing then
					return
				end

				if p911 then
					t12[p910] = t1._multiList(p915, t12[p910])
				else
					t12[p910] = p915
				end

				t1._markCustom(p910)
				t1._saveSoon()

				if p913 then
					p913(t12[p910])
				end

				t1._settingsChanged()
			end
		})

		t1._ctl[p910] = v4482

		if p911 then
			t1._multiFlags[p910] = true
		end

		if p912 and v4482.Link then
			v4482.Link:AddHelper({
				Text = p912
			})
		end

		return v4482
	end
	t1._segmented = function(p916, p917, p918, p919, p920, p921, p922)
		t1._track(p916, p919)

		local t299 = {}

		for i, v in ipairs(p918) do
			t299[i] = string.upper(v)
		end

		local function v4486(p923)
			if p922 and (p923 == nil or p923 == "") then
				return nil
			end

			return string.upper(tostring(p923))
		end

		local v4487 = p916:AddSegmented({
			Name = p917,
			Values = t299,
			Default = v4486(t12[p919]),
			Deselect = p922 == true,
			Callback = function(p924)
				if t1._refreshing then
					return
				end

				if p922 and p924 == nil then
					t12[p919] = ""
				else
					t12[p919] = p918[table.find(t299, p924) or 1]
				end

				t1._markCustom(p919)
				t1._saveSoon()

				if p921 then
					p921(t12[p919])
				end

				t1._settingsChanged()
			end
		})

		t1._ctl[p919] = {
			SetValue = function(p925, p926)
				pcall(function()
					v4487:SetValue(v4486(p926))
				end)
			end
		}

		if p920 and v4487.Link then
			v4487.Link:AddHelper({
				Text = p920
			})
		end

		return v4487
	end
	t1._segmentedMulti = function(p927, p928, p929, p930, p931, p932, p933)
		t1._track(p927, p930)

		local t300 = {}

		for i, v in ipairs(p929) do
			t300[i] = string.upper(v)
		end

		local function v4491(p934)
			local t301 = {}
			local v4493 = type(p934) == "table" and p934 or {}

			for _, v in ipairs(v4493) do
				local v4496 = table.find(p929, v)

				if v4496 then
					t301[t300[v4496]] = true
				end
			end

			return t301
		end

		if p933 and next(v4491(t12[p930])) == nil then
			t12[p930] = { p929[1] }
		end

		local v4497 = p927:AddSegmented({
			Name = p928,
			Values = t300,
			Default = v4491(t12[p930]),
			Multi = true,
			Required = p933 == true,
			Callback = function(p935)
				if t1._refreshing then
					return
				end

				local t302 = {}

				for i, v in ipairs(p929) do
					if type(p935) == "table" and p935[t300[i]] then
						t302[#t302 + 1] = v
					end
				end

				t12[p930] = t302
				t1._markCustom(p930)
				t1._saveSoon()

				if p932 then
					p932(t12[p930])
				end

				t1._settingsChanged()
			end
		})

		t1._ctl[p930] = {
			SetValue = function(p936, p937)
				pcall(function()
					v4497:SetValue(v4491(p937))
				end)
			end
		}

		if p931 and v4497.Link then
			v4497.Link:AddHelper({
				Text = p931
			})
		end

		return v4497
	end
	t1._slider = function(p938, p939, p940, p941, p942, p943, p944, p945, p946)
		t1._track(p938, p942)

		local v4501 = p938:AddSlider({
			Name = p939,
			Min = p940,
			Max = p941,
			Default = t12[p942],
			Round = p946 or 0,
			Suffix = p945,
			Flag = p942,
			Callback = function(p947)
				local v4502 = tonumber(p947) or t14[p942] or p940
				local v4503 = 10 ^ (p946 or 0)

				t12[p942] = math.clamp(p946 and math.floor(v4502 * v4503 + 0.5) / v4503 or math.floor(v4502), p940, p941)
				t1._markCustom(p942)
				t1._saveSoon()

				if p944 then
					p944(t12[p942])
				end

				t1._settingsChanged()
			end
		})

		t1._ctl[p942] = v4501

		if p943 and v4501.Link then
			v4501.Link:AddHelper({
				Text = p943
			})
		end

		return v4501
	end
	t1._range = function(p948, p949, p950, p951, p952, p953)
		t1._track(p948, p950)

		local v4504 = t11[p950]
		local v4505 = p948:AddRangeSlider({
			Name = p949,
			Min = v4504[1],
			Max = v4504[2],
			DefaultMin = t12[p950].Min,
			DefaultMax = t12[p950].Max,
			Round = v4504[3] or 0,
			Suffix = p953 or " s",
			Flag = p950,
			Callback = function(p954, p955)
				t12[p950] = v29(p950, {
					Min = p954,
					Max = p955
				})
				t1._markCustom(p950)
				t1._saveSoon()

				if p952 then
					p952(t12[p950])
				end

				t1._wake("status")
			end
		})

		t1._ctl[p950] = v4505

		if p951 and v4505.Link then
			v4505.Link:AddHelper({
				Text = p951
			})
		end

		return v4505
	end
	t1._status = function(p956, p957, p958, p959)
		local v4506 = p956:AddParagraph({
			Title = "Status",
			Content = "[IDLE]"
		})

		t1.registerStatus({
			para = v4506,
			on = p957,
			live = p958,
			idle = "[IDLE]",
			icon = p959
		})

		return v4506
	end
	t1._bars = {}
	t1._bar = function(p960, p961, p962, p963)
		local v4507 = p960:AddProgressBar({
			Name = p961,
			Default = 0,
			Max = 100,
			Suffix = "%"
		})

		t1._bars[#t1._bars + 1] = {
			ctl = v4507,
			on = p962,
			read = p963,
			idle = p961
		}

		return v4507
	end
	t1.syncBars = function()
		for _, bar in ipairs(t1._bars) do
			local ok, result2 = pcall(bar.on)
			local v4512 = false
			local n95 = 0
			local text

			if ok and result2 then
				v4512, n95, text = pcall(bar.read)
			end

			if not v4512 or text == nil then
				text = bar.idle
				n95 = 0
			end

			local pct = math.clamp(math.floor(t1._n(n95) + 0.5), 0, 100)

			if bar.pct ~= pct or bar.text ~= text then
				bar.pct = pct
				bar.text = text
				pcall(function()
					bar.ctl:SetValue(pct)
					bar.ctl:SetText(text)
				end)
			end
		end
	end
	t1._cashBar = function(p964)
		local function v4516()
			local match, v4518 = tostring(p964.text or ""):match("^%[SAVING%]%s*([^|]-)%s*|%s*{cash}/([%d,]+)")
			local ok = not v4518
			local v4520

			if not ok then
				v4520 = v4518:gsub(",", "")
				ok = not v4520
			end

			if ok then
				v4520 = ""
			end

			local v4521 = tonumber(v4520)

			if v4521 and v4521 > 0 then
				return t1._n(t1.Match.cash()) / v4521 * 100, match
			end

			return nil
		end

		return v4516
	end
	t1._countBar = function(p965, p966)
		local function v4522()
			local match, v4524 = tostring(p965.text or ""):match(p966 .. " (%d+)/(%d+)")
			local v4525 = tonumber(match)
			local v4526 = tonumber(v4524)

			if v4525 and v4526 and v4526 > 0 then
				return v4525 / v4526 * 100, p966 .. " " .. v4525 .. "/" .. v4526
			end

			return nil
		end

		return v4522
	end
	t1._slotPara = function(p967, p968, p969, p970)
		local v4527 = p967:AddParagraph({
			Title = "Slot " .. p968,
			Content = "[IDLE]"
		})

		t1.registerStatus({
			para = v4527,
			on = p969,
			live = p970,
			idle = "[IDLE]"
		})

		return v4527
	end
	v4389 = function(...)
		local t303 = { ... }

		local function v4529()
			for _, v in ipairs(t303) do
				t1._wake(v)
			end
		end

		return v4529
	end
	t1._flagSeen = {}
	v4390 = function(p971)
		local function v4532()
			if t12[p971] then
				t1._flagSeen[p971] = nil

				return true
			end

			if t1._refreshing then
				return false
			end

			local v4533 = t1._ctl[p971]
			local ok, result2 = pcall(function()
				return v4533 and v4533:GetValue()
			end)

			if not ok or result2 ~= true then
				t1._flagSeen[p971] = nil

				return false
			end

			local v4536 = t1._flagSeen[p971]
			local now = os.clock()
			local v4538 = t1._flagGen[p971] or 0

			if not v4536 or v4536.gen ~= v4538 then
				t1._flagSeen[p971] = {
					at = now,
					gen = v4538
				}
				task.delay(1.1, function()
					if t1.Running then
						t1._wake("status")
					end
				end)

				return false
			end

			if now - v4536.at < 1 then
				return false
			end

			t1._flagSeen[p971] = nil
			t12[p971] = true
			t1._note("flag:" .. p971, p971 .. ": flag desync (toggle on, setting off); fixed.")
			t1._settingsChanged()

			for _, allWorker in ipairs(t1._allWorkers) do
				t1._wake(allWorker)
			end

			return true
		end

		return v4532
	end
	v4391 = function(p972)
		local function v4541()
			return p972.text ~= "" and p972.text or "[WAITING]"
		end

		return v4541
	end
	v4392 = function(p973)
		local t304 = {}

		for i = 1, 5 do
			t304[i] = p973 .. i
		end

		return t304
	end
end

local function v4544(p974, p975, p976)
	local v4545 = p976 or {}

	for i = 1, 5 do
		v4545[p974 .. i] = p975
	end

	return v4545
end

local t305 = {}

for i = 1, 5 do
	t305[i] = tostring(i)
end

t305[#t305 + 1] = "EXCLUDE"

local n96 = 8

for _, v in ipairs(t1.Match.slots()) do
	n96 = math.max(n96, t1.Data.maxLevel(v.id))
end

for i = 1, 5 do
	n96 = math.max(n96, t1._n(t12["SlotMaxLevel" .. i]))
end

local v4553 = math.min(n96, 20)

t1.Win:DrawCategory({
	Name = "AUTOMATION"
})

local t306 = {
	Play = t1.Win:DrawTab({
		Name = "Auto Play",
		Icon = "gamepad-2",
		EnableScrolling = true
	}),
	Upgrade = t1.Win:DrawTab({
		Name = "Auto Upgrade",
		Icon = "wrench",
		EnableScrolling = true
	}),
	Order = t1.Win:DrawTab({
		Name = "Deploy Order",
		Icon = "list-ordered",
		EnableScrolling = true
	})
}

t1.Win:DrawCategory({
	Name = "PLACEMENT"
})
t306.Place = t1.Win:DrawTab({
	Name = "Custom Placement",
	Icon = "map-pinned",
	EnableScrolling = true
})
t306.Macro = t1.Win:DrawTab({
	Name = "Macro",
	Icon = "list-video",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "MATCH"
})
t306.End = t1.Win:DrawTab({
	Name = "Match End",
	Icon = "flag",
	EnableScrolling = true
})
t306.Flow = t1.Win:DrawTab({
	Name = "Match Flow",
	Icon = "fast-forward",
	EnableScrolling = true
})
t306.Session = t1.Win:DrawTab({
	Name = "Session History",
	Icon = "history",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "JOIN"
})
t306.AltFarm = t1.Win:DrawTab({
	Name = "Alt Farm",
	Icon = "handshake",
	EnableScrolling = true
})
t306.Queue = t1.Win:DrawTab({
	Name = "Auto Join",
	Icon = "list-start",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "BATTLE"
})
t306.Battle = t1.Win:DrawTab({
	Name = "Battle",
	Icon = "swords",
	EnableScrolling = true
})
t306.Leave = t1.Win:DrawTab({
	Name = "Emergency Leave",
	Icon = "siren",
	EnableScrolling = true
})
t306.Votes = t1.Win:DrawTab({
	Name = "Votes",
	Icon = "vote",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "ABILITIES"
})
t306.Ability = t1.Win:DrawTab({
	Name = "Auto Ability",
	Icon = "zap",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "REWARDS"
})
t306.Claim = t1.Win:DrawTab({
	Name = "Auto Claim",
	Icon = "gift",
	EnableScrolling = true
})
t306.Quests = t1.Win:DrawTab({
	Name = "Quests",
	Icon = "scroll-text",
	EnableScrolling = true
})
t306.Items = t1.Win:DrawTab({
	Name = "Auto Items",
	Icon = "package-open",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "UNITS"
})
t306.Summon = t1.Win:DrawTab({
	Name = "Auto Summon",
	Icon = "sparkles",
	EnableScrolling = true
})
t306.Units = t1.Win:DrawTab({
	Name = "Auto Units",
	Icon = "users",
	EnableScrolling = true
})
t306.Shop = t1.Win:DrawTab({
	Name = "Crate Shop",
	Icon = "shopping-cart",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "BATTLEPASS"
})
t306.Pass = t1.Win:DrawTab({
	Name = "Battlepass",
	Icon = "ticket",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "VISUALS"
})
t306.Esp = t1.Win:DrawTab({
	Name = "ESP",
	Icon = "eye",
	EnableScrolling = true
})
t306.Grids = t1.Win:DrawTab({
	Name = "Grids",
	Icon = "grid-3x3",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "MODS"
})
t306.GameMods = t1.Win:DrawTab({
	Name = "Match Mods",
	Icon = "flame",
	EnableScrolling = true
})
t306.PlayerMods = t1.Win:DrawTab({
	Name = "Player Mods",
	Icon = "person-standing",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "WEBHOOKS"
})
t306.Webhook = t1.Win:DrawTab({
	Name = "Webhook",
	Icon = "send",
	EnableScrolling = true
})
t1.Win:DrawCategory({
	Name = "SETTINGS"
})
t306.Settings = t1.Win:DrawTab({
	Name = "Settings",
	Icon = "settings",
	EnableScrolling = true
})

local function v4555(p977, p978, p979, p980, p981, p982)
	t1._track(p977, p979 .. "Color")

	local v4556 = t12[p979 .. "Color"]
	local v4557 = p977:AddColorPicker({
		Name = p978 .. " Color",
		Default = Color3.fromRGB(t1._n(v4556 and v4556[1], 255), t1._n(v4556 and v4556[2]), t1._n(v4556 and v4556[3])),
		Callback = function(p983)
			if typeof(p983) ~= "Color3" then
				return
			end

			t12[p979 .. "Color"] = {
				math.floor(p983.R * 255 + 0.5),
				math.floor(p983.G * 255 + 0.5),
				math.floor(p983.B * 255 + 0.5)
			}
			t1._saveSoon()
			t1._wake(p981 or "esp")

			if p979 == "EspCoverage" then
				pcall(t1.Plan.extras)
			end
		end
	})

	t1._ctl[p979 .. "Color"] = {
		SetValue = function(p984, p985)
			if type(p985) == "table" then
				pcall(function()
					v4557:SetValue(Color3.fromRGB(t1._n(p985[1]), t1._n(p985[2]), t1._n(p985[3])))
				end)
			end
		end
	}
	t1._toggle(p977, p978, p979, p980, function()
		t1._wake(p981 or "esp")
	end)
	t1._slider(p977, p982 or p978 .. " Transparency", 0, 90, p979 .. "Transparency", nil, function()
		t1._wake(p981 or "esp")
	end, "%")
end
local function v4558(p986, p987, p988, p989)
	t1._track(p986, p988)

	local v4559 = t12[p988]
	local v4560 = p986:AddColorPicker({
		Name = p987,
		Default = Color3.fromRGB(t1._n(v4559 and v4559[1], 255), t1._n(v4559 and v4559[2]), t1._n(v4559 and v4559[3])),
		Callback = function(p990)
			if typeof(p990) ~= "Color3" then
				return
			end

			t12[p988] = {
				math.floor(p990.R * 255 + 0.5),
				math.floor(p990.G * 255 + 0.5),
				math.floor(p990.B * 255 + 0.5)
			}
			t1._saveSoon()
			t1._wake(p989 or "esp")
		end
	})

	t1._ctl[p988] = {
		SetValue = function(p991, p992)
			if type(p992) == "table" then
				pcall(function()
					v4560:SetValue(Color3.fromRGB(t1._n(p992[1]), t1._n(p992[2]), t1._n(p992[3])))
				end)
			end
		end
	}
end

t1._drops = {}

do
	local function v4561(p993)
		local function v4562()
			local v4563 = p993()

			return #v4563 > 0 and v4563 or nil
		end

		return v4562
	end

	t1._restoreValue.CrateSelection = v4561(function()
		return t1.Crates.names()
	end)
	t1._restoreValue.ModVotePicks = v4561(function()
		return t1.Queue.modNames()
	end)
	t1._restoreValue.ShopCrates = v4561(function()
		return t1.Shop.names()
	end)
	t1._restoreValue.CodeSelection = v4561(function()
		return t1.Codes.names()
	end)
	t1._restoreValue.QuestSelection = function()
		return t1.Quest.names()
	end
	t1._restoreValue.RankSelection = v4561(function()
		return t1.Rank.names()
	end)
	t1._restoreValue.SpecialQuestSelection = v4561(function()
		return t1.Special.names()
	end)
end

do
	local t307 = {
		"Save For Top Pick",
		"Skip Late Farms"
	}
	local v4565 = t306.Play:DrawSection({
		Name = "Smart Deploy",
		Position = "left"
	})

	t1._status(v4565, v4390("AutoPlay"), v4391(t1.Play.owner))
	t1.registerStatus({
		para = v4565:AddParagraph({
			Title = "Placement Queue",
			Content = "[IDLE]"
		}),
		on = v4390("AutoPlay"),
		idle = "[IDLE]",
		live = t1.Play.queueText
	})
	t1._bar(v4565, "Unit", v4390("AutoPlay"), t1._cashBar(t1.Play.owner))
	t1._preset(v4565, "Play Preset", "PlayPreset", {
		Blatant = {
			DeployActions = t307,
			CashReserve = 0,
			DeployDelay = {
				Min = 0,
				Max = 0
			},
			UnitSpacing = 0
		},
		Economy = {
			DeployActions = { "Skip Late Farms" },
			CashReserve = 0,
			DeployDelay = {
				Min = 0,
				Max = 0
			},
			UnitSpacing = 0
		},
		["Damage Rush"] = {
			DeployActions = {},
			CashReserve = 0,
			DeployDelay = {
				Min = 0,
				Max = 0
			},
			UnitSpacing = 0
		},
		Humanized = {
			DeployActions = t307,
			CashReserve = 0,
			DeployDelay = {
				Min = 1,
				Max = 3
			},
			UnitSpacing = 0.3
		}
	}, {
		"DeployActions",
		"CashReserve",
		"DeployDelay",
		"UnitSpacing"
	}, "Placement only; the order units go in is set in Deploy Order. Every preset places on the picked Pattern. Blatant (recommended): no waits. Economy: no new farms late in the match. Damage Rush: no deploy actions. Humanized: 1-3 seconds between placements with Unit Spacing 0.3.")
	t1._toggle(v4565, "Enable Deployment", "AutoPlay", "Places your equipped units with the game's own TowerAdd call, exactly as the hotbar sends it, on Game.TowerArea ground the game's placement accepts. The game has no reach rule, so your character never moves. Each placement is confirmed by the new tower appearing in the match data.", v4389("play"))

	local u4566 = t1._set(t12.SmartDeployPaths)

	t1._dropdown(v4565, "Pattern", t16.PATTERN_LIST, "GridDesign", false, "The tiling Smart Deploy places ground units on, laid over the whole Deploy Coverage on ground the game accepts and drawn by Valid Spots. Honeycomb (recommended): hexagons, the tightest packing. Square: a straight grid. Diamond: the grid turned 45 degrees. Brick: wide tiles in offset rows. Triangle: alternating triangles. Random: any open ground inside Deploy Coverage, no tiles.", function()
		table.clear(t1.Play.fails)
		t1.Plan.previewSpot = nil
		t1._wake("play")
		t1._wake("esp")
	end)
	t1._dropdown(v4565, "Deploy Paths", { t1.Paths.AUTO }, "SmartDeployPaths", true, "Lanes Smart Deploy places on and scores (the path ESP numbers them at their entry). Auto (All Paths): every lane, busier lanes weigh more. Picking lanes limits placement, scoring and Deploy Coverage to them. A saved lane this map lacks falls back to Auto here and stays saved for maps that have it.", function(p994)
		if t1._has(p994, t1.Paths.AUTO) and #p994 > 1 then
			if u4566[t1.Paths.AUTO] then
				local smartDeployPaths = {}

				for _, v in ipairs(p994) do
					if v ~= t1.Paths.AUTO then
						smartDeployPaths[#smartDeployPaths + 1] = v
					end
				end

				t12.SmartDeployPaths = smartDeployPaths
			else
				t12.SmartDeployPaths = { t1.Paths.AUTO }
			end

			task.defer(pcall, t1.Play.refreshPaths)
		end

		u4566 = t1._set(t12.SmartDeployPaths)
		table.clear(t1.Play.fails)
		t1._wake("play")
		t1._wake("esp")
	end, true)
	t1.Play.refreshPaths = function()
		local v4570 = t1.Paths.count()
		local t308 = { t1.Paths.AUTO }

		if v4570 == 1 then
			t308 = { "Path 1" }
		end

		if v4570 > 1 then
			for i = 1, v4570 do
				t308[#t308 + 1] = "Path " .. i
			end
		end

		local t309 = {}
		local v4574 = true
		local SmartDeployPaths = type(t12.SmartDeployPaths) == "table" and t12.SmartDeployPaths or {}

		for _, SmartDeployPath in ipairs(SmartDeployPaths) do
			if table.find(t308, SmartDeployPath) then
				t309[SmartDeployPath] = true
			else
				v4574 = false
			end
		end

		if not v4574 or next(t309) == nil then
			t309 = {
				[t308[1]] = true
			}
		end

		u4566 = t309
		t1._refreshValues(t1._ctl.SmartDeployPaths, t308, t309)
	end
	t1.Play.useSaved = function(p995)
		t12.PlaceMode = p995 and "Set Positions" or "Smart Deploy"
		table.clear(t1.Play.fails)
		t1._wake("play")
	end
	t1._dropdown(v4565, "Deploy Actions", t307, "DeployActions", true, "Save For Top Pick: waits for Money for the next unit in order instead of buying cheaper ones. Skip Late Farms: no new farms when fewer than 6 waves remain (they would not pay back). Nothing selected = none of these.", v4389("play"))
	t1._toggle(v4565, "Use Saved Positions", "UseSavedPositions", "On: units with a saved spot on this map (Placement > Custom Placement) go there; the rest use Smart Deploy.", t1.Play.useSaved)
	t1._slider(v4565, "Cash Reserve", 0, 100000, "CashReserve", "Match Money kept back when placing.", nil, " Money")
	t1._slider(v4565, "Unit Spacing", -1, 1, "UnitSpacing", "Space between units, by their size, in the Honeycomb and on Valid Spots. -1 = inside each other, 0 = edge to edge, 1 = double the space.", v4389("play", "esp"), "", 1)
	t1._range(v4565, "Deploy Delay", "DeployDelay", "Random wait between placements, rolled once per placement; the status counts down. 0-0 = no wait.")
	t1._restore(v4565, "Smart Deploy")
end

do
	local function v4578()
		table.clear(t1.Play.fails)
		t1._wake("play")
		t1._wake("esp")
	end

	local v4579 = t306.Play:DrawSection({
		Name = "Deploy Coverage",
		Position = "right"
	})

	t1._status(v4579, function()
		return t12.EspCoverage == true
	end, function()
		local v4580 = "[ACTIVE] " .. t1.Cover.text()

		if t1.Match.state() == "MATCH" then
			v4580 ..= t1.Plan.coverText()
		end

		return v4580
	end)
	t1._preset(v4579, "Coverage Preset", "CoveragePreset", {
		["Whole Lane"] = {
			DeployCoverage = 100,
			CoverageQuick = "100%",
			CoverageFrom = "Front"
		},
		["Front Half"] = {
			DeployCoverage = 50,
			CoverageQuick = "50%",
			CoverageFrom = "Front"
		},
		["Middle Half"] = {
			DeployCoverage = 50,
			CoverageQuick = "50%",
			CoverageFrom = "Center"
		},
		["Base Guard"] = {
			DeployCoverage = 50,
			CoverageQuick = "50%",
			CoverageFrom = "Last"
		}
	}, {
		"DeployCoverage",
		"CoverageQuick",
		"CoverageFrom"
	}, "Whole Lane (recommended): units spread over the whole road. Front Half: the first half, where enemies enter. Middle Half: the middle half. Base Guard: the half right before your base.")
	v4555(v4579, "Deploy Coverage", "EspCoverage", "Draws the covered stretch of each lane on the road; lanes Deploy Paths leaves out are drawn dim. Only you see it; it never blocks placement.", nil, "Coverage Transparency")
	t1._toggle(v4579, "Placement Queue", "SmartDeployPreview", "Shows the next unit Smart Deploy will place, on the exact spot it picked.", function(p996)
		if not p996 then
			t1.Plan.hide()
		end

		t1._wake("play")
	end)
	t1._segmented(v4579, "Coverage From", t6, "CoverageFrom", "Which end the covered share starts from. Front: where enemies enter. Center: the middle. Last: right before your base.", v4578)
	t1._segmented(v4579, "Coverage Amount", t7, "CoverageQuick", "Quick Deploy Coverage: sets the slider below to 25, 50, 75 or 100% of each lane.", function(p997)
		t12.DeployCoverage = tonumber(tostring(p997):match("%d+")) or 100

		local DeployCoverage = t1._ctl.DeployCoverage

		if DeployCoverage then
			DeployCoverage:SetValue(t12.DeployCoverage)
		end

		v4578()
	end)
	t1._slider(v4579, "Deploy Coverage", 10, 100, "DeployCoverage", "How much of each lane Smart Deploy defends, from the side picked in Coverage From. 30% = damage units only go where they cover the first 30% of the road, and the whole block stays there. 100 = the whole lane.", v4578, "%")
	t1._dropdown(v4579, "Queue Preview Style", {
		"Highlight",
		"Text"
	}, "SmartDeployPreviewShow", true, "Highlight: outlines the model in your Deploy Coverage colour. Text: the unit and why it picked that spot.", function()
		pcall(t1.Plan.extras)
	end, true)
	t1._slider(v4579, "Queue Preview Transparency", 0, 90, "SmartDeployPreviewTransparency", "How see-through the Show Placement Queue model is. 0 = as solid as the unit itself, 90 = nearly invisible. The label above it stays solid.", function()
		t1.Plan.fade()
	end, "%")
	t1._restore(v4579, "Deploy Coverage", v4578)
end

do
	local v4582 = t306.Play:DrawSection({
		Name = "Auto Walk",
		Position = "right"
	})

	t1._status(v4582, v4390("AutoWalk"), v4391(t1.AutoWalk.owner))
	t1._dropdown(v4582, "Walk To", t1.AutoWalk.LIST, "WalkTo", true, "Which actions your character walks to. Placement: each unit you place. Upgrade: each unit upgraded. Ability: each unit whose ability is used. Target Change: each unit whose targeting changes. The newest one wins.", v4389("autowalk"))
	t1._toggle(v4582, "Enable Auto Walk", "AutoWalk", "Walks your character to the unit the newest Walk To action was for (its exact centre, or a spot in its range with Walk Range), jumping over anything in the way. If the walk gets cut off (you move, a respawn, Special Quests or Auto Join needs the character), it walks there again.", function(p998)
		if not p998 then
			t1.AutoWalk.interrupt()
		end

		t1._wake("autowalk")
	end)
	t1._range(v4582, "Walk Range", "WalkRange", "Where around the unit you walk to, in % of that unit's own range: a random spot that far from its centre, rolled once per action. 0-0 = the exact centre. 50-100 = somewhere between half and the edge of its range.")
	t1._range(v4582, "Walk Delay", "WalkDelay", "Random wait before each walk starts, rolled once per walk; the status counts down. 0-0 = walk right away.")
	t1._restore(v4582, "Auto Walk")
end

do
	local v4583 = t306.Order:DrawSection({
		Name = "Deploy Priority",
		Position = "left"
	})

	t1._status(v4583, function()
		return t12.CustomPriority == true
	end, t1.Play.priorityText)

	local t310 = {
		["Loadout Order"] = {
			fill = true
		},
		["One Of Each"] = {
			fill = false
		},
		["Farms First"] = {
			roles = {
				Farm = 1,
				Damage = 2,
				Support = 3
			},
			fill = true
		},
		["Damage First"] = {
			roles = {
				Damage = 1,
				Support = 2,
				Farm = 3
			},
			fill = true
		},
		["Damage, Then Farms"] = {
			roles = {
				Damage = 1,
				Farm = 2,
				Support = 3
			},
			fill = true
		},
		["Strongest First"] = {
			sort = "dps",
			fill = true
		},
		["Cheapest First"] = {
			sort = "cheap",
			fill = false
		},
		["Priciest First"] = {
			sort = "pricey",
			fill = true
		},
		["No Farms"] = {
			roles = {
				Damage = 1,
				Support = 2
			},
			skip = {
				Farm = true
			},
			fill = true
		}
	}

	local function orderValues(p999)
		local loadoutOrder = t310[p999] or t310["Loadout Order"]
		local v4587 = t1.Match.slots()
		local t311 = {}

		for _, v in ipairs(v4587) do
			if t1.Play.rarityOk(v.id) and (not loadoutOrder.skip or not loadoutOrder.skip[v.role]) then
				t311[#t311 + 1] = v
			end
		end

		table.sort(t311, function(p1000, p1001)
			if loadoutOrder.roles then
				local v4591 = loadoutOrder.roles[p1000.role] or 9
				local v4592 = loadoutOrder.roles[p1001.role] or 9

				if v4591 ~= v4592 then
					return v4591 < v4592
				end
			end

			if loadoutOrder.sort == "dps" then
				local v4593 = t1._n(t1.Data.profile(p1000.id, p1000.entry).dps)
				local v4594 = t1._n(t1.Data.profile(p1001.id, p1001.entry).dps)

				if v4593 ~= v4594 then
					return v4593 > v4594
				end
			elseif loadoutOrder.sort then
				local v4595 = t1.Data.placeCost(p1000.id)
				local v4596 = t1.Data.placeCost(p1001.id)

				if v4595 ~= v4596 then
					if loadoutOrder.sort == "cheap" then
						return v4595 < v4596
					end

					return v4595 > v4596
				end
			end

			return p1000.slot < p1001.slot
		end)

		local SlotPri = v4544("SlotPri", "EXCLUDE")

		for i = 1, 5 do
			SlotPri["SlotPri" .. i] = tostring(i)
		end

		for _, v in ipairs(v4587) do
			SlotPri["SlotPri" .. v.slot] = "EXCLUDE"
		end

		for i, v in ipairs(t311) do
			SlotPri["SlotPri" .. v.slot] = tostring(i)
		end

		SlotPri.FillSlotFirst = loadoutOrder.fill
		SlotPri.CustomPriority = true

		return SlotPri
	end

	t1.Play.orderValues = orderValues

	local handlers = {}

	for k in pairs(t310) do
		handlers[k] = function()
			return orderValues(k)
		end
	end

	t1._loadoutPresets.DeployPreset = handlers

	local SlotPri = v4392("SlotPri")

	SlotPri[#SlotPri + 1] = "FillSlotFirst"
	t1._preset(v4583, "Deploy Order Preset", "DeployPreset", handlers, SlotPri, "Numbers your equipped units in this order and turns Enable Deploy Priority on; only the rarities picked below, the rest EXCLUDE. Your Slot Limits stay. Loadout Order: slot 1 to its limit, then slot 2. One Of Each: one copy of every unit, then the next round. Farms First: every farm, then damage, then support. Damage First: damage, support, then farms. Damage, Then Farms: damage, farms, then support. Strongest First: highest DPS first. Cheapest First: one copy each, cheapest first. Priciest First: most expensive first. No Farms: farms EXCLUDE.")
	t1.Play.applyRarities = function()
		if t1._loadingCfg then
			t1._wake("status")

			return
		end

		if not handlers[t12.DeployPreset] then
			t1._applyingPreset = true
			t12.DeployPreset = "Loadout Order"
			t1._setControl("DeployPreset", "Loadout Order")
			t1._applyingPreset = false
		end

		local v4606 = handlers[t12.DeployPreset]()

		v4606.CustomPriority = nil
		t1._applyValues(v4606)
		t1._wake("play")
		t1._wake("status")
	end
	t1.Play.refreshRarities = function(p1002)
		local rarityDrop = t1.Play.rarityDrop

		if not rarityDrop then
			return
		end

		local v4608, v4609 = t1.Play.rarities()
		local DeployRarities = t12.DeployRarities
		local DeployRaritiesSeen = t12.DeployRaritiesSeen

		if not (v4609 or p1002 or not (#DeployRaritiesSeen > 0)) then
			return
		end

		local deployRarities

		if #DeployRaritiesSeen == 0 then
			deployRarities = table.clone(v4608)
		else
			local v4613 = true
			local v4614, v4615, v4616 = ipairs(DeployRaritiesSeen)
			local v4617 = geniter(v4614, v4615, v4616)

			while true do
				local v4618 = table.pack(v4617())

				if v4618[1] then
					if not table.find(DeployRarities, v4618[3]) then
						v4613 = false

						break
					end
				else
					break
				end
			end

			deployRarities = {}

			if v4613 then
				deployRarities = table.clone(v4608)
			else
				local v4619, v4620, v4621 = ipairs(DeployRarities)

				for _, v in v4619, v4620, v4621 do
					if not v4609 or table.find(v4608, v) then
						deployRarities[#deployRarities + 1] = v
					end
				end
			end
		end

		local function v4624(p1003)
			for _, v in ipairs(v4608) do
				if #p1003 > 0 and not table.find(p1003, v) then
					return table.concat(p1003, ",")
				end
			end

			return "*"
		end

		local v4627 = v4624(DeployRarities)
		local v4628 = table.clone(v4608)

		t12.DeployRarities = deployRarities
		t12.DeployRaritiesSeen = v4628
		t1._refreshValues(rarityDrop, v4608, t1._set(deployRarities))

		if table.concat(deployRarities, ",") ~= table.concat(DeployRarities, ",") then
			t1._saveSoon()
		end

		if p1002 or v4624(deployRarities) ~= v4627 then
			t1.Play.applyRarities()
		end
	end
	t1.Play.rarityDrop = t1._dropdown(v4583, "Deploy Order Rarities", t1.Play.rarities(), "DeployRarities", true, "Only places equipped units of these rarities. Pick Legendary alone for Only Legendary. None picked = every rarity.", t1.Play.applyRarities, true)
	t1._toggle(v4583, "Enable Deploy Priority", "CustomPriority", "Places slots by the numbers below: 1 first, EXCLUDE never, each up to its limit. Off = a balanced order (damage first, then farms, then the rest).", v4389("play"))
	t1.Play.limitDrops = {}

	for i = 1, 5 do
		t1._slotPara(v4583, i, v4390("CustomPriority"), function()
			return t1.Play.slotHeader(i, true)
		end)
		t1._dropdown(v4583, "Slot " .. i .. " Priority", t305, "SlotPri" .. i, false, i == 1 and "1 is placed first. EXCLUDE never places this slot." or nil, v4389("play"), true)

		local t312 = { tostring(t12["SlotLimit" .. i]):find("^Game Limit") and t12["SlotLimit" .. i] or "Game Limit" }

		for i2 = 1, 20 do
			t312[#t312 + 1] = tostring(i2)
		end

		t1.Play.limitDrops[i] = t1._dropdown(v4583, "Slot " .. i .. " Limit", t312, "SlotLimit" .. i, false, i == 1 and "Most copies of this slot's unit, with Enable Deploy Priority on or off. Game Limit | N is that unit's own deploy limit here, as the game counts it (its placement limit)." or nil, v4389("play"), true)
	end

	t1._toggle(v4583, "Fill Slot Before Next", "FillSlotFirst", "Places every copy of the top slot before moving on. Off = one copy of each in order, then repeat.", v4389("play"))
	t1._slider(v4583, "Top Pick Wait", 0, 120, "TopPickWait", "Seconds to save for the top unit before buying the next one (with Save For Top Pick). 0 = wait for it.", nil, " s")
	t1._restore(v4583, "Deploy Priority", function()
		t12.DeployRaritiesSeen = {}
		t1.Play.refreshRarities(true)
	end)
end

do
	local v4632 = t306.Order:DrawSection({
		Name = "Target Priority",
		Position = "right"
	})

	t1._status(v4632, v4390("AutoTarget"), v4391(t1.Target.owner))

	local RULES = t1.Target.RULES

	local function v4634(...)
		local t313 = { ... }
		local t314 = {}

		for _, v in ipairs(RULES) do
			if not table.find(t313, v) then
				t314[#t314 + 1] = v
			end
		end

		return t314
	end
	local function v4639(p1004, p1005, p1006)
		return v4544("SlotTarget", p1004, {
			SmartTargetRules = p1005,
			SmartLeakPct = p1006,
			SmartSwitchHold = 1500,
			TargetDelay = {
				Min = 0,
				Max = 0
			}
		})
	end

	local t315 = {
		["All Smart"] = v4639("Smart", v4634(), 80),
		["Smart Boss Focus"] = v4639("Smart", v4634("Low Health Swarm: Weakest"), 80),
		["Smart Leak Guard"] = v4639("Smart", v4634(), 70),
		["All First"] = v4639("First", v4634(), 80),
		["All Strongest"] = v4639("Strongest", v4634(), 80),
		["All Last"] = v4639("Last", v4634(), 80)
	}
	local SlotTarget = v4392("SlotTarget")

	for _, v in ipairs({
		"SmartTargetRules",
		"SmartLeakPct",
		"SmartSwitchHold",
		"TargetDelay"
	}) do
		SlotTarget[#SlotTarget + 1] = v
	end

	t1._preset(v4632, "Target Preset", "TargetPreset", t315, SlotTarget, "All Smart (recommended): each unit picks from the enemies in its own range with every Smart Rule on. Boss Focus: no Weakest. Leak Guard: Leaking Enemy fires at 70%.")
	t1._toggle(v4632, "Enable Targeting", "AutoTarget", "Sets each slot's target mode on every placed unit with the unit panel's own change_priority call, only to modes that unit allows (the modes get_valid_priorities offers that unit). Farms are left alone.", v4389("target"))

	local t316 = { "Smart" }

	for _, v in ipairs(t1.Target.modes()) do
		t316[#t316 + 1] = v
	end

	for i = 1, 5 do
		t1._slotPara(v4632, i, v4390("AutoTarget"), function()
			return t1.Play.slotHeader(i) .. "\n" .. t1.Target.slotText(i)
		end)
		t1._dropdown(v4632, "Slot " .. i .. " Target", t316, "SlotTarget" .. i, false, i == 1 and "Smart: each attack unit picks a mode from the enemies in its own range, by the Smart Rules. The list is the game's own target modes." or nil, v4389("target"), true)
	end

	t1._dropdown(v4632, "Smart Rules", RULES, "SmartTargetRules", true, "Checked in this order: Last Unit Before Base, Leaking Enemy, Boss In Range (Split Bosses), Flying, Area/Swarm, else First. Area units take Strongest only when the boss is alone in range. Weakest is for single-target units in a crowd of low-health enemies. Split Bosses: the highest-DPS unit on each boss takes Strongest and the rest stay First. All off: First.", v4389("target"))
	t1._slider(v4632, "Leak Threshold", 50, 95, "SmartLeakPct", "Lane progress at which Leaking Enemy sends a unit to First.", v4389("target"), "%")
	t1._slider(v4632, "Switch Hold", 500, 5000, "SmartSwitchHold", "How long a new Smart mode must stay best before the unit switches. Each unit still changes at most once every 3 s.", v4389("target"), " ms")
	t1._range(v4632, "Target Delay", "TargetDelay", "Random wait between target changes, rolled once per change.")
	t1._restore(v4632, "Target Priority")
end

do
	local t317 = {
		"Farms Early",
		"Skip Late Farm Upgrades"
	}
	local v4649 = t306.Upgrade:DrawSection({
		Name = "Auto Upgrade",
		Position = "left"
	})

	t1._status(v4649, v4390("AutoUpgrade"), v4391(t1.Upg.owner))
	t1.registerStatus({
		para = v4649:AddParagraph({
			Title = "Upgrade Queue",
			Content = "[IDLE]"
		}),
		on = v4390("AutoUpgrade"),
		idle = "[IDLE]",
		live = t1.Upg.queueText
	})
	t1._bar(v4649, "Upgrade", v4390("AutoUpgrade"), t1._cashBar(t1.Upg.owner))
	t1._preset(v4649, "Upgrade Preset", "UpgradePreset", {
		Instant = {
			UpgradeReserve = 0,
			UpgradeDelay = {
				Min = 0,
				Max = 0
			}
		},
		["Keep A Buffer"] = {
			UpgradeReserve = 1000,
			UpgradeDelay = {
				Min = 0,
				Max = 0
			}
		},
		Humanized = {
			UpgradeReserve = 0,
			UpgradeDelay = {
				Min = 1,
				Max = 3
			}
		}
	}, {
		"UpgradeReserve",
		"UpgradeDelay"
	}, "Spending only; what upgrades and when is set by Upgrade Strategy, Upgrade Timing and Upgrade Priority. Instant (recommended): upgrades the moment the Money is there. Keep A Buffer: always keeps 1,000 Money back. Humanized: 1-3 seconds between upgrades.")
	t1._toggle(v4649, "Enable Auto Upgrade", "AutoUpgrade", "Upgrades placed units with the unit panel's own TowerUpgrade call at the game's own price and confirms the tower's level rose.", v4389("upgrade"))
	t1._dropdown(v4649, "Upgrade Strategy", {
		"Balanced",
		"Damage First",
		"Strongest First",
		"Cheapest First",
		"Priciest First",
		"Lowest Level First",
		"Finish One First"
	}, "UpgradeStrategy", false, "Which placed unit upgrades next. Upgrade Priority off: this is the whole order. Upgrade Priority on: group 1 goes first and this orders the units inside each group. Balanced (recommended): the most damage gained per Money, farms first while Farms Early runs. Damage First: damage units, then support, then farms. Strongest First: the highest-DPS unit first. Cheapest First: the cheapest upgrade first. Priciest First: the most expensive first. Lowest Level First: evens levels out. Finish One First: the highest-level unit first, so one unit maxes before the next.", v4389("upgrade"))
	t1._dropdown(v4649, "Upgrade Timing", {
		"Place All First",
		"Deploy First",
		"Upgrade While Deploying",
		"Upgrade First"
	}, "UpgradeTiming", false, "Place All First (recommended): no upgrade until every unit Auto Play places is at its deploy limit (your Slot Limit, else the game's own limit; EXCLUDE and Deploy Order Rarities count as done); a unit with no open spot never holds it. Deploy First: upgrades whenever Auto Play cannot place right now, only with the Money beyond the unit it saves for. Upgrade While Deploying: both spend; with Upgrade Priority on they share the Money by number (a unit's deploy rank, its Deploy Priority number or its place in Auto Play's own order, against the Upgrade group: deploy rank 1 before group 2, group 1 before deploy rank 2, a tie to the deploy) and the other keeps that price back; with Upgrade Priority off an affordable deploy goes first. Upgrade First: Auto Play waits until nothing is left to upgrade (after the first unit).", v4389("upgrade", "play"))
	t1._slider(v4649, "Upgrade Money Reserve", 0, 100000, "UpgradeReserve", "Match Money kept back when upgrading.", nil, " Money")
	t1._range(v4649, "Upgrade Delay", "UpgradeDelay", "Random wait between upgrades, rolled once per upgrade.")
	t1._restore(v4649, "Auto Upgrade")

	local v4650 = t306.Upgrade:DrawSection({
		Name = "Farm Upgrades",
		Position = "left"
	})

	t1._status(v4650, function()
		return true
	end, t1.Upg.farmText)
	t1._bar(v4650, "Farm", v4390("AutoUpgrade"), function()
		local _farmBar = t1.Upg._farmBar

		if _farmBar then
			return _farmBar[1], _farmBar[2]
		end
	end)
	t1._dropdown(v4650, "Farm Upgrade Mode", {
		"Payback",
		"Farms First",
		"Never"
	}, "FarmUpgradeMode", false, "How Auto Upgrade treats farms. Payback (recommended): farms take their turn in the Upgrade Strategy, and Farm Rules keep them to waves where they pay back. Farms First: farms upgrade before other units (inside each Upgrade Priority group while it is on). Never: farms are never upgraded.", v4389("upgrade"))

	local v4652 = t1.Data.farms()
	local v4653 = t1._dropdown(v4650, "Farm Units", #v4652 > 0 and v4652 or { "" }, "UpgradeFarmUnits", true, "Every farm unit in the game; Auto Upgrade upgrades only the picked farms you have placed. All picked by default; untick a farm to leave it at its level. Nothing selected = waiting.", v4389("upgrade"), true)

	t1._liveMulti("UpgradeFarmUnits", v4652, v4653)
	t1.Upg.farmDrop = v4653
	t1._dropdown(v4650, "Farm Rules", t317, "UpgradeActions", true, "Farms Early: Balanced upgrades farms first until Farms Early Until Wave. Skip Late Farm Upgrades: no farm upgrades in the last Skip Farms In Last Waves waves.", v4389("upgrade"))
	t1._slider(v4650, "Farms Early Until Wave", 1, 50, "FarmsEarlyWave", "The last wave Farms Early puts farms first.", v4389("upgrade"))
	t1._slider(v4650, "Skip Farms In Last Waves", 1, 20, "SkipLateFarmWaves", "Skip Late Farm Upgrades stops farm upgrades during the match's last this many waves.", v4389("upgrade"))
	t1._restore(v4650, "Farm Upgrades")
end

do
	local v4654 = t306.Upgrade:DrawSection({
		Name = "Upgrade Priority",
		Position = "right"
	})

	local function v4655()
		return t12.UpgradePriority == true
	end

	t1._status(v4654, v4655, t1.Upg.priorityText)

	local t318 = {}

	for i = 1, 5 do
		t318[i] = tostring(i)
	end

	t318[#t318 + 1] = "OFF"

	local function v4658(p1007, p1008, p1009)
		local t319 = {}
		local v4660 = table.clone(t1.Match.slots())
		local v4661 = table.clone(v4660)

		table.sort(v4661, function(p1010, p1011)
			return t1._n(t1.Data.profile(p1010.id, p1010.entry).dps) > t1._n(t1.Data.profile(p1011.id, p1011.entry).dps)
		end)

		local t320 = {}

		for i, v in ipairs(v4661) do
			t320[v.slot] = i
		end

		local orderValues = p1009 and t1.Play.orderValues and t1.Play.orderValues(p1009)

		if orderValues then
			for k, orderValue in pairs(orderValues) do
				t319[k] = orderValue
			end

			t319.DeployPreset = p1009
		end

		for i = 1, 5 do
			t319["SlotUpgPri" .. i] = tostring(i)
		end

		for _, v in ipairs(v4660) do
			local v4671 = p1008(v, t320[v.slot] or v.slot, orderValues)
			local v4672 = "SlotUpgPri" .. v.slot
			local v4673 = v4671 == "OFF" and "OFF"

			if not v4673 then
				v4673 = tostring(math.clamp(tonumber(v4671) or 1, 1, 5))
			end

			t319[v4672] = v4673
		end

		t319.UpgradeTiming = p1007
		t319.UpgradeStrategy = "Balanced"
		t319.UpgradePriority = true

		return t319
	end
	local function v4674(p1012)
		local function v4675(p1013)
			return p1012[p1013.role] or 3
		end

		return v4675
	end
	local function v4676(p1014)
		return p1014.slot
	end

	local SlotUpgPri = v4392("SlotUpgPri")

	SlotUpgPri[#SlotUpgPri + 1] = "UpgradeTiming"
	SlotUpgPri[#SlotUpgPri + 1] = "UpgradeStrategy"

	local upgradeOrderPreset = {
		["Place All, Then Upgrade"] = function()
			local function v4679()
				return 1
			end

			return v4658("Place All First", v4679)
		end,
		["Place All, Then Farms"] = function()
			return v4658("Place All First", v4674({
				Farm = 1,
				Damage = 2,
				Support = 2
			}))
		end,
		["Place All, Then Damage"] = function()
			return v4658("Place All First", v4674({
				Damage = 1,
				Support = 2,
				Farm = 3
			}))
		end,
		["Place All, Strongest First"] = function()
			local placeAllFirst = v4658("Place All First", function()
				return 1
			end)

			placeAllFirst.UpgradeStrategy = "Strongest First"

			return placeAllFirst
		end,
		["Farms First, Then Rest"] = function()
			return v4658("Place All First", v4674({
				Farm = 1,
				Damage = 2,
				Support = 2
			}), "Farms First")
		end,
		["Loadout Order"] = function()
			return v4658("Place All First", v4676)
		end,
		["One Unit At A Time"] = function()
			local function v4681(p1015)
				if t12.CustomPriority and t12["SlotPri" .. p1015.slot] == "EXCLUDE" then
					return "OFF"
				end

				return t1.Play.rank(p1015)
			end

			return v4658("Upgrade While Deploying", v4681)
		end,
		["Farms While Placing"] = function()
			return v4658("Upgrade While Deploying", v4674({
				Farm = 1,
				Damage = 6,
				Support = 6
			}))
		end,
		["Upgrade As You Go"] = function()
			local function v4682()
				return 1
			end

			return v4658("Upgrade First", v4682)
		end,
		["Damage Only"] = function()
			local function v4683(p1016)
				return p1016.role == "Damage" and 1 or "OFF"
			end

			return v4658("Place All First", v4683)
		end,
		["No Farm Upgrades"] = function()
			local function v4684(p1017)
				return p1017.role == "Farm" and "OFF" or 1
			end

			return v4658("Place All First", v4684)
		end
	}

	t1._loadoutPresets.UpgradeOrderPreset = upgradeOrderPreset
	t1._preset(v4654, "Upgrade Order Preset", "UpgradeOrderPreset", upgradeOrderPreset, SlotUpgPri, "Sets each equipped slot's group and the Upgrade Timing, and turns Enable Upgrade Priority on; your Max Level sliders and Slot Limits stay, and it re-runs when you change units. Place All, Then Upgrade (recommended): every unit to its deploy limit first, then upgrades by the Upgrade Strategy. Place All, Then Farms / Then Damage: the same, that role upgraded first. Place All, Strongest First: highest DPS unit upgraded first. Farms First, Then Rest: places farms, then the rest, then upgrades farms, then the rest (also sets Deploy Order to Farms First). Loadout Order: place all, then slot 1, slot 2 and on. One Unit At A Time: places a unit, upgrades it to its Max Level, then the next, in your deploy order (Deploy Priority numbers, or Auto Play's own order while that is off). Farms While Placing: farm upgrades go before every deploy after the first unit, the rest after placing. Upgrade As You Go: upgrades everything before the next placement. Damage Only: only damage units upgrade. No Farm Upgrades: farms stay at their level.")
	t1._toggle(v4654, "Enable Upgrade Priority", "UpgradePriority", "On: slot numbers group your units (1 first); the Upgrade Strategy orders each group. OFF slots never upgrade.", v4389("upgrade"))

	for i = 1, 5 do
		t1._slotPara(v4654, i, v4655, function()
			return t1.Upg.limitText(i)
		end)
		t1._dropdown(v4654, "Slot " .. i .. " Upgrade Priority", t318, "SlotUpgPri" .. i, false, i == 1 and "The slot's group: group 1 upgrades first, slots with the same number share a group. OFF never upgrades this slot." or nil, v4389("upgrade"), true)
		t1._slider(v4654, "Slot " .. i .. " Max Level", 0, v4553, "SlotMaxLevel" .. i, i == 1 and "Highest level for this slot's units. 0 = the unit's last level." or nil, v4389("upgrade"))
	end

	t1._restore(v4654, "Upgrade Priority")
end

do
	local v4686 = t306.Place:DrawSection({
		Name = "Placement Setup",
		Position = "left"
	})

	t1._status(v4686, function()
		return true
	end, function()
		if (t1.Pick.slot or os.clock() - t1.Pick.textAt < 6) and t1.Pick.owner.text ~= "[IDLE]" then
			return t1.Pick.owner.text
		end

		if t1.Ctx.place() ~= "MATCH" then
			return "[WAITING] Awaiting Match | Positions Save Per Map"
		end

		local n97 = 0

		for i = 1, 5 do
			n97 += t1.Pick.count(i)
		end

		return "[MAP] " .. t1.Match.mapName() .. " | " .. n97 .. " Saved Spots"
	end)

	for i = 1, 5 do
		t1._slotPara(v4686, i, function()
			return true
		end, function()
			return t1.Pick.slotText(i)
		end)
		GlowButton(v4686, "Set Slot " .. i .. " Position", function()
			if t1.Pick.start(i) == "cancelled" then
				return
			end

			if not t12.UseSavedPositions then
				t12.UseSavedPositions = true
				t1.Play.useSaved(true)
				t1._setControl("UseSavedPositions", true)
				t1._saveSoon()
				t1._settingsChanged()
			end
		end)
		GlowButton(v4686, "Clear Slot " .. i .. " Positions", function()
			t1.Pick.clear(i)
		end)
	end

	t1._restore(v4686, "Placement Setup")
end

do
	local v4690 = t306.Place:DrawSection({
		Name = "Saved Positions",
		Position = "right"
	})
	local id
	local s10 = ""
	local u4693
	local n98 = 0

	local function v4695()
		local t321 = {}
		local Positions = type(t12.Positions) == "table" and t12.Positions or {}

		for k, Position in pairs(Positions) do
			if type(Position) == "table" and next(Position) ~= nil then
				t321[#t321 + 1] = {
					id = k,
					label = t1.Match.mapName(k)
				}
			end
		end

		table.sort(t321, function(p1018, p1019)
			return p1018.label < p1019.label
		end)

		return t321
	end
	local function v4700(p1020)
		local now = os.clock()

		u4693 = p1020
		n98 = now
		t1._wake("status")
	end

	t1._status(v4690, function()
		return true
	end, function()
		if u4693 and os.clock() - n98 < 8 then
			return u4693
		end

		local v4702 = id and t12.Positions[id]

		if type(v4702) ~= "table" then
			local v4703 = #v4695()

			return v4703 > 0 and "[SAVED] " .. v4703 .. " Map Configs" or "[EMPTY] No Saved Positions"
		end

		local t322 = { "[SELECTED] " .. t1.Match.mapName(id) }

		for k, v in pairs(v4702) do
			local ipairs_ = ipairs
			local v4708 = type(v) == "table" and v or {}

			for _, v2 in ipairs_(v4708) do
				t322[#t322 + 1] = #t322 .. "). " .. t1.Data.name(k) .. " | " .. string.format("%.1f, %.1f, %.1f", t1._n(v2[1]), t1._n(v2[2]), t1._n(v2[3]))
			end
		end

		return table.concat(t322, "\n")
	end)

	local v4711 = v4690:AddDropdown({
		Name = "Select Map Config",
		Values = { "None" },
		Default = "None",
		Callback = function(p1021)
			if t1._refreshing then
				return
			end

			id = nil

			for _, v in ipairs(v4695()) do
				if v.label == p1021 then
					id = v.id
				end
			end

			t1._wake("status")
		end
	})

	if v4711 and v4711.Link then
		v4711.Link:AddHelper({
			Text = "Every map you saved positions on. In a match, the current map is selected automatically; Reset Config clears the selected map and Export Code shares it."
		})
	end

	t1.Pick.refreshMaps = function()
		local v4714 = t1.Ctx.place() == "MATCH" and t1.Match.mapId() or nil

		if v4714 and type(t12.Positions) == "table" and type(t12.Positions[v4714]) == "table" and next(t12.Positions[v4714]) ~= nil then
			id = v4714
		end

		local t323 = { "None" }
		local s11 = "None"

		for _, v in ipairs(v4695()) do
			t323[#t323 + 1] = v.label

			if v.id == id then
				s11 = v.label
			end
		end

		if s11 == "None" then
			id = nil
		end

		t1._refreshValues(v4711, t323, s11)
		t1._wake("status")
	end
	GlowButton(v4690, "Reset Config", function()
		if id and type(t12.Positions) == "table" then
			t12.Positions[id] = nil
			id = nil
			t1._saveSoon()
			t1.Pick.onSaved()
			t1._wake("play")
		end
	end)

	local v4719 = v4690:AddTextBox({
		Name = "Share Code",
		Default = "",
		Placeholder = "BRGAA1:...",
		Callback = function(p1022)
			s10 = tostring(p1022 or "")
		end
	})

	if v4719 and v4719.Link then
		v4719.Link:AddHelper({
			Text = "Paste a code here, then Import Code. Export Code copies the selected map's positions (every map when none is selected)."
		})
	end

	GlowButton(v4690, "Export Code", function()
		local t324 = {}
		local Positions = type(t12.Positions) == "table" and t12.Positions or {}

		for k, Position in pairs(Positions) do
			if type(Position) == "table" and next(Position) ~= nil and (not id or k == id) then
				t324[tostring(k)] = Position
			end
		end

		if next(t324) == nil then
			return v4700("[EMPTY] Export | No Saved Positions")
		end

		local ok, result = pcall(HttpService.JSONEncode, HttpService, {
			maps = t324
		})

		if not ok then
			return v4700("[FAILED] Export | Unreadable Positions")
		end

		local v4726 = "BRGAA1:" .. result

		s10 = v4726
		pcall(function()
			v4719:SetValue(v4726)
		end)

		local ok2 = type(setclipboard) == "function" and pcall(setclipboard, v4726)

		v4700(ok2 and "[COPIED] Share Code | Clipboard" or "[READY] Share Code | In The Box")
	end)
	GlowButton(v4690, "Import Code", function()
		local match = tostring(s10 or ""):match("BRGAA1:(.+)$")

		if not match then
			return v4700("[INVALID] Share Code | Missing BRGAA1 Prefix")
		end

		local ok, result = pcall(HttpService.JSONDecode, HttpService, match)

		if not ok or type(result) ~= "table" or type(result.maps) ~= "table" then
			return v4700("[INVALID] Share Code | Unreadable")
		end

		if type(t12.Positions) ~= "table" then
			t12.Positions = {}
		end

		local n99 = 0
		local n100 = 0

		for k, map in pairs(result.maps) do
			local t325 = {}
			local pairs_ = pairs
			local v4737 = type(map) == "table" and map or {}

			for k2, v in pairs_(v4737) do
				local t326 = {}
				local ipairs_ = ipairs
				local v4742 = type(v) == "table" and v or {}

				for _, v2 in ipairs_(v4742) do
					if type(v2) == "table" and tonumber(v2[1]) and tonumber(v2[2]) and tonumber(v2[3]) then
						t326[#t326 + 1] = {
							tonumber(v2[1]),
							tonumber(v2[2]),
							tonumber(v2[3]),
							tonumber(v2[4]) or 180
						}
					end
				end

				if #t326 > 0 then
					t325[tostring(k2)] = t326
					n100 += #t326
				end
			end

			if next(t325) ~= nil then
				t12.Positions[tostring(k)] = t325
				n99 += 1
			end
		end

		if n99 == 0 then
			return v4700("[INVALID] Share Code | No Positions")
		end

		t1._saveSoon()
		t1.Pick._migrated = nil
		t1.Pick.onSaved()
		t1.Pick.refreshMaps()
		t1._wake("play")
		v4700("[IMPORTED] " .. n99 .. " Maps | " .. n100 .. " Spots")
	end)
end

do
	local v4745 = t306.Macro:DrawSection({
		Name = "Strategy Recorder",
		Position = "left"
	})

	t1._status(v4745, v4390("MacroRecord"), v4391(t1.Macro.rec))
	t1._preset(v4745, "Record Preset", "RecordPreset", {
		["Full Strategy"] = {
			MacroRecordActions = {
				"Placements",
				"Sells",
				"Targets",
				"Upgrades"
			},
			MacroStopWave = 0
		},
		["Build Only"] = {
			MacroRecordActions = {
				"Placements",
				"Upgrades"
			},
			MacroStopWave = 0
		}
	}, {
		"MacroRecordActions",
		"MacroStopWave"
	}, "Full Strategy (recommended): records every placement, upgrade, sell and target change you make.")
	t1._toggle(v4745, "Record Strategy", "MacroRecord", "Watches your units while you play and records each change with its wave and cost. Turning it off saves the strategy under Strategy Name (or the date).", function(p1023)
		if p1023 then
			if t1.Ctx.place() ~= "MATCH" then
				t1.Macro.rec.text = "[WAITING] Awaiting Match"
				t12.MacroRecord = false
				t1._setControl("MacroRecord", false)
				t1._wake("status")

				return
			end

			t1.Macro.startRecording()
		elseif t1.Macro.recording then
			t1.Macro.stopRecording()
		end
	end)
	t1._track(v4745, "MacroName")
	t1._ctl.MacroName = v4745:AddTextBox({
		Name = "Strategy Name",
		Default = t12.MacroName,
		Placeholder = "BARRAGE_1",
		Flag = "MacroName",
		Callback = function(p1024)
			t12.MacroName = tostring(p1024 or "")
			t1._saveSoon()
		end
	})
	t1._slider(v4745, "Stop At Wave", 0, 100, "MacroStopWave", "Recording stops by itself after this wave. 0 = until you turn it off.")
	t1._dropdown(v4745, "Record Actions", {
		"Placements",
		"Sells",
		"Targets",
		"Upgrades"
	}, "MacroRecordActions", true, "What the recording keeps.")
	t1._restore(v4745, "Strategy Recorder")
end

do
	local v4746 = t306.Macro:DrawSection({
		Name = "Run Saved Strategy",
		Position = "right"
	})

	t1._status(v4746, v4390("MacroRun"), v4391(t1.Macro.owner))
	t1._bar(v4746, "Steps", v4390("MacroRun"), t1._countBar(t1.Macro.owner, "Step"))
	t1._preset(v4746, "Run Preset", "RunPreset", {
		["Wave Safe"] = {
			MacroPause = {
				"Auto Play",
				"Auto Sell",
				"Auto Target",
				"Auto Upgrade"
			},
			MacroActions = { "Wait For Recorded Wave" },
			MacroDelay = {
				Min = 0,
				Max = 0
			}
		},
		Fast = {
			MacroPause = {
				"Auto Play",
				"Auto Sell",
				"Auto Target",
				"Auto Upgrade"
			},
			MacroActions = { "Skip Failed Steps" },
			MacroDelay = {
				Min = 0,
				Max = 0
			}
		}
	}, {
		"MacroPause",
		"MacroActions",
		"MacroDelay"
	}, "Wave Safe (recommended): each step waits for its recorded wave and its cost. Fast: steps run as soon as the Money is there.")
	t1._toggle(v4746, "Run Strategy", "MacroRun", "Replays the selected strategy in every match. Placements go to the recorded spots with the game's own TowerAdd call.", v4389("macro"))
	t1.Macro.drop = t1._dropdown(v4746, "Strategy", { "" }, "MacroSelected", false, "Saved strategies in your executor's BARRAGE/CameramanTowerDefenseStrategies folder; Strategy Steps lists the selected one.", function()
		t1._wake("macro")

		if t1.Macro.showSteps then
			t1.Macro.showSteps()
		end
	end)
	t1._dropdown(v4746, "Pause While Running", {
		"Auto Play",
		"Auto Sell",
		"Auto Target",
		"Auto Upgrade"
	}, "MacroPause", true, "Features that stand down while the strategy still has steps left.", v4389("macro"))
	t1._range(v4746, "Step Delay", "MacroDelay", "Random wait between steps, rolled once per step.")
	t1._slider(v4746, "Retry Limit", 0, 10, "MacroRetries", "Failed tries before Skip Failed Steps moves on. 0 = never skip.", v4389("macro"))
	t1._dropdown(v4746, "Strategy Actions", {
		"Recorded Timing",
		"Skip Failed Steps",
		"Wait For Recorded Wave"
	}, "MacroActions", true, "Wait For Recorded Wave: each step waits for its recorded wave (off = as soon as it is affordable). Recorded Timing: also waits for the second into the wave it was recorded at. Skip Failed Steps: moves on after Retry Limit failed tries (for example a unit no longer equipped).", v4389("macro"))

	local v4747 = v4746:AddList({
		Name = "Strategy Steps",
		Height = 210,
		MaxItems = 300,
		AutoScroll = false
	})

	t1.Macro.showSteps = function()
		local v4748 = t1.Macro.load(t12.MacroSelected or "")
		local t327 = {}
		local t328 = {}
		local events = v4748 and v4748.events or {}

		for _, event in ipairs(events) do
			if event.a == "place" and event.n ~= nil then
				t328[event.n] = t1.Data.name(event.id)
			end

			local v4754 = (t328[event.n] or "Unit") .. " #" .. tostring(event.n)
			local v4755 = event.a == "place" and "Place " .. v4754 .. " | " .. t1._fmt(t1._n(event.cost)) .. " Money" or event.a == "upgrade" and "Upgrade " .. v4754 .. " | Lv" .. tostring(event.lvl) or event.a == "target" and "Target " .. v4754 .. " | " .. tostring(event.mode) or "Sell " .. v4754

			t327[#t327 + 1] = #t327 + 1 .. "). Wave " .. tostring(event.wave or 0) .. (type(event.t) == "number" and " +" .. event.t .. "s" or "") .. " | " .. v4755
		end

		if #t327 == 0 then
			t327[1] = t12.MacroSelected ~= "" and "[EMPTY] No Steps" or "[EMPTY] Select A Strategy"
		end

		pcall(function()
			v4747:SetItems(t327)
		end)
	end
	t1.Macro.refreshList = function()
		local v4756 = t1.Macro.list()
		local MacroSelected = table.find(v4756, t12.MacroSelected) and t12.MacroSelected or v4756[1] or ""

		if MacroSelected ~= t12.MacroSelected then
			t12.MacroSelected = MacroSelected
		end

		t1._refreshValues(t1.Macro.drop, #v4756 > 0 and v4756 or { "" }, MacroSelected)

		local stepsSig = MacroSelected .. "|" .. table.concat(v4756, "|")

		if stepsSig ~= t1.Macro.stepsSig then
			t1.Macro.stepsSig = stepsSig
			t1.Macro.showSteps()
		end
	end
	GlowButton(v4746, "Delete Selected Strategy", function()
		if t12.MacroSelected ~= "" and t1.Macro.delete(t12.MacroSelected) then
			t12.MacroSelected = ""
			t1.Macro.refreshList()
			t1._wake("status")
		end
	end)
	t1._restore(v4746, "Run Saved Strategy")
end

do
	local v4759 = t306.Leave:DrawSection({
		Name = "Emergency Leave",
		Position = "left"
	})

	t1._status(v4759, v4390("EmergencyLeave"), v4391(t1.Leave))
	t1._preset(v4759, "Leave Preset", "LeavePreset", t1.PRESETS.LeavePreset.values, t1.PRESETS.LeavePreset.keys, "Balanced (recommended): leaves once the base drops under 30%. Careful: under 50%, or a boss 70% along the path. Last Resort: only under 10%.")
	t1._toggle(v4759, "Enable Emergency Leave", "EmergencyLeave", "Leaves the match for the lobby the moment a selected Leave Action trips, as the results Lobby button does (OnLeave, with a teleport to the lobby as backup), so a lost run ends early and the next one starts sooner.", v4389("eleave"))
	t1._dropdown(v4759, "Leave Actions", {
		"Base Health Below",
		"Boss Path Progress",
		"Players Left"
	}, "LeaveActions", true, "Base Health Below: your base drops under the health below. Boss Path Progress: a boss walks past the share of the path below. Players Left: someone leaves the match. Nothing selected = never.", v4389("eleave"))
	t1._slider(v4759, "Base Health Below", 0, 90, "LeaveBaseHP", "Leaves once the base is under this health. 30 (recommended).", v4389("eleave"), "%")
	t1._slider(v4759, "Boss Path Progress", 0, 100, "LeaveBossPath", "Leaves once a boss has walked this far along the path. 80 (recommended).", v4389("eleave"), "%")
	t1._restore(v4759)
end

do
	local v4760 = t306.Leave:DrawSection({
		Name = "Leave At Wave",
		Position = "right"
	})

	t1._status(v4760, v4390("LeaveAtWave"), v4391(t1.Leave))
	t1._toggle(v4760, "Enable Leave At Wave", "LeaveAtWave", "Leaves the match for the lobby once this wave starts, for short farming runs that skip the hard late waves.", v4389("eleave"))
	t1._slider(v4760, "Leave At Wave", 1, 200, "LeaveWave", "The wave that starts the leave.", v4389("eleave"))
	t1._restore(v4760)
end

do
	local v4761 = t306.Ability:DrawSection({
		Name = "Auto Ability",
		Position = "left"
	})

	t1._status(v4761, v4390("AutoAbility"), v4391(t1.Ability))
	t1._preset(v4761, "Ability Preset", "AbilityPreset", t1.PRESETS.AbilityPreset.values, t1.PRESETS.AbilityPreset.keys, "With Enemies (recommended): relocates while enemies are on the path. On Cooldown: as soon as it is ready. Crowds Only: with 5 or more enemies out. Boss Waves: only while a boss is out.")
	t1._toggle(v4761, "Enable Auto Ability", "AutoAbility", "Uses Relocate on Upgraded Titan Cameraman and Upgraded Titan TV Man, as the unit panel's ability button does: each flies to the free spot within its fly distance that covers the most path at its range. It waits for the unlock level, the cooldown and the ability price.", v4389("ability"))
	t1._dropdown(v4761, "Ability Actions", {
		"Only On Boss Waves",
		"Only With Enemies"
	}, "AbilityActions", true, "Only On Boss Waves: while a boss is out. Only With Enemies: with at least Min Enemies on the path. Nothing selected = on cooldown.", v4389("ability"))
	t1._slider(v4761, "Min Enemies", 1, 20, "AbilityMinEnemies", "Enemies on the path before Only With Enemies relocates.", v4389("ability"))
	t1._slider(v4761, "Start From Wave", 0, 50, "AbilityFromWave", "No ability before this wave (0 = from the start).", v4389("ability"))
	t1._slider(v4761, "Min Coverage Gain", 0, 100, "AbilityMinGain", "Relocates only to a spot covering at least this much more path than the current one. 20 (recommended).", function()
		table.clear(t1.Ability.best)
		v4389("ability")()
	end, "%")
	t1._range(v4761, "Ability Delay", "AbilityDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("ability"))
	t1._restore(v4761)
end

do
	local v4762 = t306.Ability:DrawSection({
		Name = "Hotbar Abilities",
		Position = "right"
	})

	for i = 1, 5 do
		t1._slotPara(v4762, i, v4390("AutoAbility"), function()
			local v4764 = t1.Slots.get(i)

			if not v4764 then
				return "[NONE] Empty Slot"
			end

			local v4765 = t1.Ability.info(v4764.name)

			if v4765 then
				return "[" .. tostring(t12["SlotAbility" .. i]):upper() .. "] " .. v4764.name .. " | Lv " .. t1._n(v4765.UnlockLevel, 1) .. ", " .. t1._n(v4765.Cooldown) .. "s"
			end

			return "[NONE] " .. v4764.name .. " | No Relocate"
		end)
		t1._dropdown(v4762, "Slot " .. i .. " Ability", t13, "SlotAbility" .. i, false, i == 1 and "Ability Actions (recommended): the rules on the left. On Cooldown: whenever ready. With Enemies: while enemies are out. Boss Waves: while a boss is out. Off: never for this slot." or nil, v4389("ability"), true)
	end

	t1._restore(v4762)
end

do
	local function v4766(p1025, p1026, p1027, p1028, p1029, p1030)
		t1._track(p1025, p1027)

		local v4767 = p1025:AddTextBox({
			Name = p1026,
			Default = tostring(t12[p1027] or ""),
			Placeholder = p1028,
			Flag = p1027,
			Callback = function(p1031)
				t12[p1027] = tostring(p1031 or "")
				t1._saveSoon()

				if p1030 then
					p1030()
				end

				t1._wake("status")
			end
		})

		t1._ctl[p1027] = v4767

		if p1029 and v4767 and v4767.Link then
			v4767.Link:AddHelper({
				Text = p1029
			})
		end

		return v4767
	end

	local v4768 = t306.AltFarm:DrawSection({
		Name = "Host",
		Position = "left"
	})

	t1._status(v4768, function()
		return t12.PartyRole == "Host"
	end, v4391(t1.Party))
	t1._preset(v4768, "Host Preset", "HostPreset", t1.PRESETS.HostPreset.values, t1.PRESETS.HostPreset.keys, "Wait For Party (recommended): holds the start up to 60 s for every alt. Patient: up to 120 s. Quick Start: up to 30 s. No Wait: starts at once.")
	t1._dropdown(v4768, "Role", {
		"Off",
		"Host",
		"Alt"
	}, "PartyRole", false, "Host: this account picks the elevator (with Auto Join on) and waits for its alts. Alt: this account follows the host named on the right into its server, its elevator and its results choice. Off: plays alone.", v4389("party", "queue", "matchend"))
	t1.registerStatus({
		para = v4768:AddParagraph({
			Title = "Alts",
			Content = "[IDLE]"
		}),
		on = function()
			return t12.PartyRole == "Host"
		end,
		idle = "[IDLE]",
		live = t1.Party.altLines
	})
	v4766(v4768, "Alt Names", "PartyAltNames", "alt1, alt2", "Your alts' usernames, separated by commas.", v4389("party", "queue"))
	t1._toggle(v4768, "Wait For Alts", "WaitForAlts", "Holds the elevator's Ready start until every listed alt stands in it, or Alt Wait Time runs out.", v4389("queue"))
	t1._slider(v4768, "Alt Wait Time", 10, 300, "AltWaitTime", "The longest the host holds the start for its alts.", v4389("queue"), " s")
	t1.registerStatus({
		para = v4768:AddParagraph({
			Title = "Server ID",
			Content = "[IDLE]"
		}),
		on = function()
			return t12.PartyRole == "Host"
		end,
		idle = "[IDLE]",
		live = function()
			if t1.Party.note and os.clock() < t1.Party.noteUntil then
				return t1.Party.note
			end

			return "[SERVER] " .. (game.JobId ~= "" and game.JobId or "Private Test")
		end
	})
	GlowButton(v4768, "Copy Server ID", function()
		local ok = type(setclipboard) == "function" and pcall(setclipboard, game.JobId)
		local Party = t1.Party
		local Party2 = t1.Party
		local note = ok and "[COPIED] Server ID | In Clipboard" or "[FAILED] Copy | Clipboard Unavailable"
		local noteUntil = os.clock() + 4

		Party.note = note
		Party2.noteUntil = noteUntil
		t1._alarm("status", 4.1, "party:note")
		t1._wake("status")
	end)
	t1._restore(v4768)

	local v4774 = t306.AltFarm:DrawSection({
		Name = "Alt",
		Position = "right"
	})

	t1._status(v4774, function()
		return t12.PartyRole == "Alt"
	end, v4391(t1.Party))
	t1._preset(v4774, "Alt Preset", "AltPreset", t1.PRESETS.AltPreset.values, t1.PRESETS.AltPreset.keys, "Same Server (recommended): follows the host in its server, elevator and results. Full Follow: also teleports into the Host Server ID when the host is elsewhere. Manual: only joins the host's server.")
	v4766(v4774, "Host Name", "PartyHostName", "Host username", "The host's username. An alt on the same PC finds the host's lobby server by itself.", v4389("party"))
	t1._toggle(v4774, "Follow Host", "FollowHost", "Walks into the host's elevator, leaves the match when the host leaves, and votes Play Again when the host does. Off: only joins the host's server.", v4389("party", "queue", "matchend"))
	v4766(v4774, "Host Server ID", "HostServerId", "Paste the host's Server ID", "For a host on another PC: paste the Server ID its Host section copies.", v4389("party"))
	t1._toggle(v4774, "Join Host Server", "JoinHostServer", "Teleports into the Host Server ID's lobby server when the host is not in this one.", v4389("party"))
	t1._restore(v4774)
end

do
	local v4775 = t306.Quests:DrawSection({
		Name = "Rank Rewards",
		Position = "right"
	})

	t1._status(v4775, v4390("AutoRanks"), v4391(t1.Rank))
	t1._preset(v4775, "Rank Preset", "RankPreset", t1.PRESETS.RankPreset.values, t1.PRESETS.RankPreset.keys, "Instant (recommended): claims every rank reward the game lists once you reach it. Natural: the same with a 2-5 s pause before each claim.")
	t1._toggle(v4775, "Enable Rank Rewards", "AutoRanks", "Claims the selected rank rewards you have reached, in the lobby, as the Ranks panel's Claim button does.", v4389("ranks"))
	t1._drops.RankSelection = t1._dropdown(v4775, "Rank Rewards", t1._seed("RankSelection", t1.Rank.names()), "RankSelection", true, "Rank rewards it claims; new ranks the game adds are picked automatically. Nothing selected = does nothing.", v4389("ranks"))
	t1._range(v4775, "Claim Delay", "RankDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("ranks"))
	t1._restore(v4775)
end

do
	local v4776 = t306.Battle:DrawSection({
		Name = "Deploy Assist",
		Position = "left"
	})

	t1._status(v4776, v4390("DeployAssist"), v4391(t1.Assist.owner))
	t1._preset(v4776, "Assist Preset", "AssistPreset", {
		["One Tap"] = {
			AssistUnit = "Auto Play's Pick",
			AssistSpot = "Same As Auto Play",
			AssistCount = "1",
			AssistUpgrades = 0
		},
		Precise = {
			AssistUnit = "Auto Play's Pick",
			AssistSpot = "Near Mouse",
			AssistCount = "1",
			AssistUpgrades = 0
		},
		Swarm = {
			AssistUnit = "Cheapest",
			AssistSpot = "Same As Auto Play",
			AssistCount = "All Affordable",
			AssistUpgrades = 0
		},
		Carry = {
			AssistUnit = "Priciest",
			AssistSpot = "Same As Auto Play",
			AssistCount = "1",
			AssistUpgrades = 5
		}
	}, {
		"AssistUnit",
		"AssistSpot",
		"AssistCount",
		"AssistUpgrades"
	}, "One Tap (recommended): each press places Auto Play's next unit on Auto Play's best spot. Precise: on the free spot nearest your mouse. Swarm: the cheapest unit as many times as you can pay. Carry: your priciest unit, upgraded 5 times.")
	t1._toggle(v4776, "Enable Deploy Assist", "DeployAssist", "Manual deploying: the key next to this toggle (F by default) or Place Units places your chosen unit with the slot's own TowerAdd call on the chosen spot, then upgrades it with the unit panel's TowerUpgrade. The key places units instead of turning this off.", v4389("assist"), "DeployAssistKeybind")

	local _kbReg = t1._kbReg and t1._kbReg[#t1._kbReg]

	if _kbReg and _kbReg.flag == "DeployAssist" then
		_kbReg.press = function()
			t1.Assist.press(true)
		end
	end

	t1._dropdown(v4776, "Unit", t1.Assist.UNITS, "AssistUnit", false, "Auto Play's Pick: the unit Auto Play would place next. Cheapest / Priciest: of the units you can pay for right now. Slot N: that hotbar slot.", v4389("assist"), true)
	t1._dropdown(v4776, "Spot", t1.Assist.SPOTS, "AssistSpot", false, "Same As Auto Play: Auto Play's placement and Deploy Coverage. Near Mouse: the free spot nearest your cursor when you press the key (your character with the button or on touch). Near Character: the free spot nearest your character.", v4389("assist"))
	t1._dropdown(v4776, "Units Per Press", t1.Assist.COUNTS, "AssistCount", false, "Units placed by one press. All Affordable: until the Money runs out.", v4389("assist"), true)
	t1._slider(v4776, "Upgrade After Place", 0, 10, "AssistUpgrades", "Upgrades bought on each unit right after it is placed. 0 = none.", v4389("assist"))
	t1._slider(v4776, "Assist Money Reserve", 0, 100000, "AssistReserve", "Match Money kept back by presses (Auto Play's Pick uses Cash Reserve).", nil, " Money")
	t1._range(v4776, "Assist Delay", "AssistDelay", "Random wait between the units of one press.")
	GlowButton(v4776, "Place Units", function()
		if t12.DeployAssist then
			t1.Assist.press(false)
		end
	end)
	t1._restore(v4776, "Deploy Assist")
end

do
	local v4778 = t306.Flow:DrawSection({
		Name = "Auto Skip",
		Position = "left"
	})

	t1._status(v4778, v4390("AutoSkip"), v4391(t1.Skip))
	t1._preset(v4778, "Skip Preset", "SkipPreset", t1.PRESETS.SkipPreset.values, t1.PRESETS.SkipPreset.keys, "Safe (recommended): skips only while your base has full health. Every Wave: skips every wave. Boss Careful: skips every wave while the base is above half health, and holds while a boss is on the path.")
	t1._toggle(v4778, "Enable Auto Skip", "AutoSkip", "Votes Skip Wave once per wave while the game offers it, as the Skip Wave button does. Skipping starts the next wave early for more money per minute.", v4389("skip"))
	t1._dropdown(v4778, "Skip When", {
		"Always",
		"Base Untouched"
	}, "SkipWhen", false, "Base Untouched (recommended): only while your base has full health, so a leaking defence gets the full wave timer. Always: every wave.", v4389("skip"))
	t1._slider(v4778, "Skip From Wave", 0, 100, "SkipFromWave", "Starts skipping at this wave (0 = from wave 1), so the opening waves get the full timer to set up.", v4389("skip"))
	t1._slider(v4778, "Skip Until Wave", 0, 100, "SkipUntilWave", "Skips every wave before this one, then stops skipping for the rest of the match. 45 = skips waves 1-44 and plays wave 45 on normally. 0 = skips every wave.", v4389("skip"))
	t1._slider(v4778, "Min Base Health", 0, 100, "SkipMinHealth", "Holds the skip while your base is below this health (0 = off).", v4389("skip"), "%")
	t1._toggle(v4778, "Hold On Boss", "SkipHoldBoss", "No skip while a boss is on the path, so the boss wave gets the full timer.", v4389("skip"))
	t1._range(v4778, "Skip Delay", "SkipDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("skip"))
	t1._restore(v4778)
end

do
	local v4779 = t306.Flow:DrawSection({
		Name = "Game Speed",
		Position = "right"
	})

	t1._status(v4779, v4390("AutoSpeed"), v4391(t1.Speed))
	t1._toggle(v4779, "Enable Game Speed", "AutoSpeed", "Sets the match speed as soon as each match starts, as the speed buttons by the wave counter do, and sets it again if the game resets it.", v4389("speed"))
	t1._dropdown(v4779, "Speed", {
		"1x",
		"1.5x",
		"2x"
	}, "GameSpeed", false, "2x (recommended): the fastest rounds; if the server refuses 2x twice (it may need the game's X2 Speed purchase) it uses 1.5x for the rest of the round. 1x: normal speed.", v4389("speed"))
	t1._toggle(v4779, "Slow On Boss Waves", "SpeedBossSlow", "Drops to 1x while a boss wave is on, so your units get more time on the boss, then goes back to Speed.", v4389("speed"))
	t1._restore(v4779)
end

do
	local v4780 = t306.End:DrawSection({
		Name = "Match End",
		Position = "left"
	})

	t1._status(v4780, v4390("AutoMatchEnd"), v4391(t1.End))
	t1.registerStatus({
		para = v4780:AddParagraph({
			Title = "Session",
			Content = "[IDLE]"
		}),
		on = function()
			return true
		end,
		idle = "[IDLE]",
		live = t1.End.sessionText
	})
	t1._preset(v4780, "Match End Preset", "EndPreset", t1.PRESETS.EndPreset.values, t1.PRESETS.EndPreset.keys, "Natural Replay (recommended): votes Play Again 3 s after the results show. Quick Replay: votes Play Again the moment they show. Fresh Server: goes back to the lobby after 3 s, so Auto Join picks the next elevator.")
	t1._toggle(v4780, "Enable Match End", "AutoMatchEnd", "Presses a results screen button after a win or a loss so the next round starts on its own.", v4389("matchend"))
	t1._dropdown(v4780, "After Match", {
		"Lobby",
		"Play Again"
	}, "EndAction", false, "Play Again (recommended): votes the results screen's Play Again so the next round starts in this server without a teleport; if the round has not restarted once the vote runs out it goes to the lobby. Lobby: returns to the lobby so Auto Join picks the next elevator.", v4389("matchend"))
	t1._range(v4780, "Match End Delay", "EndDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("matchend"))
	t1._slider(v4780, "Stop After Rounds", 0, 200, "StopAfterRounds", "Stops farming after this many matches (0 = never): the last match goes to the lobby and Auto Join holds there. Counts from when you set it, across teleports.", v4389("matchend", "queue"))
	t1._slider(v4780, "Stop After Minutes", 0, 720, "StopAfterMinutes", "Stops farming once this long has passed since you set it (0 = never); the match being played finishes first.", v4389("matchend", "queue"), " Min")
	t1._dropdown(v4780, "When Done", {
		"Stay In Lobby",
		"Close Game"
	}, "StopAction", false, "Stay In Lobby (recommended): goes to the lobby and joins nothing more. Close Game: closes Roblox once the goal is reached.", v4389("matchend", "queue"))
	t1._restore(v4780)
end

do
	local v4781 = t306.End:DrawSection({
		Name = "Auto Sell",
		Position = "right"
	})

	t1._status(v4781, v4390("AutoSell"), v4391(t1.Sell.owner))
	t1._preset(v4781, "Sell Preset", "SellPreset", {
		["Sell Farms Late"] = {
			SellActions = { "Sell Farms Before End" },
			SellFarmsBeforeEnd = 2,
			SellAllAtWave = 0,
			SellSelectedWave = 0,
			SellLowLives = 0
		},
		["Farms Last Wave"] = {
			SellActions = { "Sell Farms Before End" },
			SellFarmsBeforeEnd = 1,
			SellAllAtWave = 0,
			SellSelectedWave = 0,
			SellLowLives = 0
		},
		["Emergency Sell"] = {
			SellActions = {
				"Sell Farms At Low Base",
				"Sell Farms Before End"
			},
			SellFarmsBeforeEnd = 2,
			SellAllAtWave = 0,
			SellSelectedWave = 0,
			SellLowLives = 30
		}
	}, {
		"SellActions",
		"SellFarmsBeforeEnd",
		"SellAllAtWave",
		"SellSelectedWave",
		"SellLowLives"
	}, "Sell Farms Late (recommended): sells farms 2 waves before the end so the money goes into upgrades for the final waves. Infinite modes never sell farms.")
	t1._toggle(v4781, "Enable Auto Sell", "AutoSell", "Sells placed towers with the unit panel's own TowerSell call and confirms the tower is gone.", v4389("sell"))
	t1._dropdown(v4781, "Sell Actions", {
		"Sell All At Wave",
		"Sell Farms At Low Base",
		"Sell Farms Before End",
		"Sell Selected At Wave"
	}, "SellActions", true, "Sell Farms Before End: sells farms when the waves left reach the slider. Sell Farms At Low Base: sells farms once base health drops to the slider. Sell All At Wave: sells every unit at that wave. Sell Selected At Wave: sells the picked units at their wave (Auto Play stops re-placing them). Nothing selected = waiting.", v4389("sell"))

	local v4782 = t1.Data.farms()
	local v4783 = t1._dropdown(v4781, "Farm Units", #v4782 > 0 and v4782 or { "" }, "SellFarmUnits", true, "Every farm unit in the game; the farm rules sell only the picked farms you have placed. All picked by default; untick a farm to keep it. Nothing selected = waiting.", v4389("sell", "play"), true)

	t1._liveMulti("SellFarmUnits", v4782, v4783)
	t1.Sell.drop = t1._dropdown(v4781, "Sell Units", #t12.SellTowers > 0 and table.clone(t12.SellTowers) or { "" }, "SellTowers", true, "Units for Sell Selected At Wave; the list follows your equipped units.", v4389("sell", "play"))
	t1._slider(v4781, "Farms Before End", 0, 10, "SellFarmsBeforeEnd", "Waves before the last wave to sell farms.")
	t1._slider(v4781, "Low Base Sell", 0, 90, "SellLowLives", "Base health (percent) that sells farms. 0 = off.", nil, "%")
	t1._slider(v4781, "Sell All At Wave", 0, 200, "SellAllAtWave", "Wave to sell everything. 0 = off.")
	t1._slider(v4781, "Sell Selected At Wave", 0, 200, "SellSelectedWave", "Wave to sell the picked units. 0 = off.")
	t1._restore(v4781, "Auto Sell")
end

do
	local v4784 = t306.Session:DrawSection({
		Name = "SESSION HISTORY",
		Position = "left"
	})

	t1._status(v4784, function()
		return true
	end, t1.Hist.status)
	t1._segmented(v4784, "History View", t1.Hist.VIEWS, "HistoryView", "What the list shows. MATCHES: time, result, mode, map, wave reached and length of each round. MAPS: wins, losses and best wave per map. MODES: the same per mode. REWARDS: the Coins and Candy each round paid. Every view reads the same session, kept across the lobby and match servers until an hour without a match.", function()
		t1.Hist.refresh()
	end)

	local v4785 = v4784:AddList({
		Name = "Session History",
		Height = 220,
		MaxItems = 100,
		AutoScroll = false
	})

	if v4785 and v4785.Link then
		pcall(v4785.Link.AddHelper, v4785.Link, {
			Text = "One row per finished round, from the game's own results message."
		})
	end

	t1.Hist.list = v4785
	t1._segmented(v4784, "History Order", {
		"Newest",
		"Oldest"
	}, "HistoryOrder", "Whether the newest or oldest rows appear first.", function()
		t1.Hist.refresh()
	end)
	t1._slider(v4784, "History Amount", 5, 100, "HistoryAmount", "How many rows the list shows.", function()
		t1.Hist.refresh()
	end)
	t1._toggle(v4784, "Preview History", "HistoryPreview", "Shows or hides the rows. Recording continues while it is off.", function()
		t1.Hist.refresh()
	end)
	GlowButton(v4784, "Clear History", function()
		t1.Hook.resetRecord()
		t1.Hist.sig = nil
		t1.Hist.refresh()
	end)
	t1._restore(v4784, "Session History", function()
		t1.Hist.refresh()
	end)
end

t1.Hist.refresh()

do
	local v4786 = t306.Queue:DrawSection({
		Name = "Auto Join",
		Position = "left"
	})

	t1._status(v4786, v4390("AutoJoin"), v4391(t1.Queue))
	t1._preset(v4786, "Join Preset", "JoinPreset", t1.PRESETS.JoinPreset.values, t1.PRESETS.JoinPreset.keys, "Fast Solo (recommended): an empty elevator started at once. Bonus Rewards: the same with every elevator modifier set, for bigger win rewards. Public Duo: the Matchmaking queue at Duo size. Join Others: the fullest elevator with room after a 2-6 s pause.")
	t1._toggle(v4786, "Enable Auto Join", "AutoJoin", "Joins the next match from the lobby. Elevator: steps into a free lobby elevator for the chosen map and, alone, starts it with the elevator's Ready button. Matchmaking: queues the chosen map at the Match Size, as the Matchmaking panel's Join button does, and waits for the server to fill the match. Lobby errands that are due finish first.", v4389("queue"))
	t1._segmented(v4786, "Join By", {
		"Elevator",
		"Matchmaking"
	}, "JoinBy", "ELEVATOR (recommended): a lobby elevator, solo or with others. MATCHMAKING: the game's public queue, matched with other players at the Match Size (Alt Farm always uses elevators).", function()
		v4389("queue")()
	end)
	t1._drops.JoinMap = t1._dropdown(v4786, "Map", t1._seed("JoinMap", { "Any Map" }), "JoinMap", false, "Any Map (recommended): the first free elevator, or the first map the Matchmaking panel lists. A map: only that map.", v4389("queue"))
	t1._dropdown(v4786, "Party", {
		"Any Free",
		"Solo"
	}, "JoinParty", false, "Elevator only. Solo (recommended): an empty elevator, started at once. Any Free: the fullest elevator with room, which starts on its timer.", v4389("queue"))
	t1._segmented(v4786, "Match Size", {
		"Duo",
		"Trio",
		"Quad"
	}, "MatchSize", "Matchmaking only: how many players the match fills to. DUO (recommended): 2, the fastest to fill. TRIO: 3. QUAD: 4.", v4389("queue"))
	t1._drops.JoinModifiers = t1._dropdown(v4786, "Elevator Modifiers", t1._seed("JoinModifiers", t1.Queue.modNames()), "JoinModifiers", true, "Elevator only: modifiers set on the elevator before it starts, as its modifier buttons do (up to 4, only when you lead it). Each makes the enemies harder and adds its reward multiplier on a win. Nothing selected = none.", v4389("queue"))
	t1._range(v4786, "Join Delay", "JoinDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("queue"))
	GlowButton(v4786, "Teleport", function()
		t1.teleportTo(function()
			if not t1.Ctx.lobby() then
				return nil
			end

			local v4787 = t1.Queue.choose() or t1.Queue.list()[1]

			return v4787 and v4787.spot
		end)
	end)
	t1._restore(v4786)
end

do
	local v4788 = t306.Votes:DrawSection({
		Name = "Mode Vote",
		Position = "left"
	})

	t1._status(v4788, v4390("AutoVote"), v4391(t1.Vote))
	t1._preset(v4788, "Vote Preset", "VotePreset", t1.PRESETS.VotePreset.values, t1.PRESETS.VotePreset.keys, "Climb (recommended): Smart Progression, voting at once. Natural Climb: Smart Progression with a 2-5 s pause. Top Payout: always the mode that pays the most coins.")
	t1._toggle(v4788, "Enable Mode Vote", "AutoVote", "Votes the match difficulty at the start of the round, as its mode buttons do.", v4389("vote"))
	t1._drops.VoteMode = t1._dropdown(v4788, "Mode", t1._seed("VoteMode", { "Smart Progression" }), "VoteMode", false, "Smart Progression (recommended): starts on the easiest mode that pays coins, moves up after two wins in a row and back down after a loss (harder modes pay more; event modes that pay no coins are left out). A mode: always that one.", v4389("vote"), true)
	t1._range(v4788, "Vote Delay", "VoteDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("vote"))
	t1._restore(v4788)
end

do
	local v4789 = t306.Votes:DrawSection({
		Name = "Modifier Vote",
		Position = "right"
	})

	t1._status(v4789, v4390("AutoModVote"), v4391(t1.ModVote))
	t1._preset(v4789, "Modifier Preset", "ModVotePreset", t1.PRESETS.ModVotePreset.values, t1.PRESETS.ModVotePreset.keys, "Instant (recommended): votes every modifier the game lists the moment the vote opens. Natural: the same with a 2-5 s pause before each vote.")
	t1._toggle(v4789, "Enable Modifier Vote", "AutoModVote", "Votes for the selected modifiers while the match's modifier vote is open, once each, as its modifier buttons do. Each modifier that passes makes the enemies harder and adds its reward multiplier on a win.", v4389("modvote"), "AutoModVoteKeybind")
	t1._drops.ModVotePicks = t1._dropdown(v4789, "Modifiers To Vote", t1._seed("ModVotePicks", t1.Queue.modNames()), "ModVotePicks", true, "Modifiers it votes for, read live from the game; new modifiers are picked automatically. Nothing selected = does nothing.", v4389("modvote"))
	t1._range(v4789, "Vote Delay", "ModVoteDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("modvote"))
	t1._restore(v4789)
end

do
	local v4790 = t306.Summon:DrawSection({
		Name = "Auto Summon",
		Position = "left"
	})

	t1._status(v4790, v4390("AutoSummon"), v4391(t1.Sum))
	t1._preset(v4790, "Summon Preset", "SummonPreset", t1.PRESETS.SummonPreset.values, t1.PRESETS.SummonPreset.keys, "Max Pulls (recommended): spends every coin on Smart pulls. Hunt Wanted: the same, stopping once a Wanted Unit drops. Keep A Reserve: never spends the last 5,000 coins.")
	t1._toggle(v4790, "Enable Auto Summon", "AutoSummon", "Summons from the chosen crate with coins while you have more than Keep Coins and bag room, as the summon frame's buttons do.", v4389("summon"))
	t1._drops.SummonCrate = t1._dropdown(v4790, "Crate", t1._seed("SummonCrate", { "Basic Crate" }), "SummonCrate", false, "Crate it summons from, read live from the game.", v4389("summon"), true)
	t1._drops.SummonWanted = t1._dropdown(v4790, "Wanted Units", t1._seed("SummonWanted", {}), "SummonWanted", true, "Summons only while the crate's current rotation holds one of these units. Nothing selected = any rotation.", v4389("summon"))
	t1._toggle(v4790, "Stop When Found", "SummonStopWanted", "Turns Auto Summon off as soon as a pull gives you one of the Wanted Units, so it stops spending coins once you have it.", v4389("summon"))
	t1._dropdown(v4790, "Amount", {
		"Single",
		"Smart",
		"Ten"
	}, "SummonAmount", false, "Smart (recommended): Summon 10 (ten for the price of nine) whenever you can pay for it and have the bag room, else one. Single / Ten: that button.", v4389("summon"))
	t1._slider(v4790, "Keep Coins", 0, 100000, "SummonKeep", "Coins it never spends.", v4389("summon"))
	t1._range(v4790, "Summon Delay", "SummonDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("summon"))
	GlowButton(v4790, "Teleport", function()
		t1.teleportTo(function()
			local v4791 = t1._at(workspace, "Zones.Summon")
			local isBasePart = v4791 and (v4791:IsA("BasePart") and v4791 or v4791:FindFirstChildWhichIsA("BasePart", true))

			return isBasePart and isBasePart.Position
		end)
	end)
	t1._restore(v4790)
end

do
	local v4793 = t306.Summon:DrawSection({
		Name = "Summon Autosell",
		Position = "right"
	})

	t1._status(v4793, v4390("AutoAutosell"), v4391(t1.ASell))
	t1._preset(v4793, "Autosell Preset", "AutosellPreset", t1.PRESETS.AutosellPreset.values, t1.PRESETS.AutosellPreset.keys, "Lowest Two (recommended): the game sells its two lowest rarities on summon. Lowest Three / Lowest Four: one or two rarities more, for more coins and less bag space used.")
	t1._toggle(v4793, "Enable Summon Autosell", "AutoAutosell", "Sets the game's own summon autosell to the rarities below, as the summon frame's rarity buttons do; the server then sells those units the moment they are summoned.", v4389("autosell"))
	t1._drops.AutosellRarities = t1._dropdown(v4793, "Sell Rarities", t1._seed("AutosellRarities", t2), "AutosellRarities", true, "Rarities the game sells on summon. Nothing selected = autosell off for every rarity.", v4389("autosell"), true)
	t1._range(v4793, "Autosell Delay", "AutosellDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("autosell"))
	t1._restore(v4793)
end

do
	local v4794 = t306.Units:DrawSection({
		Name = "Equip Best",
		Position = "left"
	})

	t1._status(v4794, v4390("AutoEquip"), v4391(t1.Equip))
	t1._preset(v4794, "Equip Preset", "EquipPreset", t1.PRESETS.EquipPreset.values, t1.PRESETS.EquipPreset.keys, "Instant (recommended): Smart picks, equipped at once. Natural: Smart picks with a 2-5 s pause before each change.")
	t1._toggle(v4794, "Enable Equip Best", "AutoEquip", "Fills your 5 hotbar slots with your strongest units, one copy each, as the bag's unit button does.", v4389("equip"))
	t1._dropdown(v4794, "Equip By", {
		"Damage",
		"Rarity",
		"Saved Team",
		"Smart"
	}, "EquipBy", false, "Smart (recommended): strongest by max-level damage per second times range, keeping one Hidden-detection unit and your best farm. Damage: the strongest five. Rarity: rarest first. Saved Team: the team you saved with Save Current Team, put back whenever it changes.", v4389("equip"))
	t1._range(v4794, "Equip Delay", "EquipDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("equip"))
	GlowButton(v4794, "Save Current Team", function()
		t1.Equip.saveTeam()
	end)
	t1._restore(v4794)
end

do
	local v4795 = t306.Units:DrawSection({
		Name = "Unit Sell",
		Position = "right"
	})

	t1._status(v4795, v4390("AutoUnitSell"), v4391(t1.USell))
	t1._preset(v4795, "Unit Sell Preset", "UnitSellPreset", t1.PRESETS.UnitSellPreset.values, t1.PRESETS.UnitSellPreset.keys, "Lowest Two (recommended): sells spare units of the two lowest rarities. Lowest Three / Lowest Four: one or two rarities more. Every preset keeps one copy of each unit.")
	t1._toggle(v4795, "Enable Unit Sell", "AutoUnitSell", "Sells unequipped units of the chosen rarities for coins, as the bag's Sell Units does. Equipped units and your starter unit never go.", v4389("unitsell"))
	t1._drops.UnitSellRarities = t1._dropdown(v4795, "Sell Rarities", t1._seed("UnitSellRarities", t2), "UnitSellRarities", true, "Rarities it sells. Nothing selected = does nothing.", v4389("unitsell"), true)
	t1._dropdown(v4795, "Keep Rules", t4, "UnitSellKeep", true, "Keep One Of Each: keeps one copy of every unit.", v4389("unitsell"))
	t1._range(v4795, "Unit Sell Delay", "UnitSellDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("unitsell"))
	t1._restore(v4795)
end

do
	local v4796 = t306.Shop:DrawSection({
		Name = "Crate Shop",
		Position = "left"
	})

	t1._status(v4796, v4390("AutoCrateShop"), v4391(t1.Shop))
	t1._preset(v4796, "Shop Preset", "ShopPreset", t1.PRESETS.ShopPreset.values, t1.PRESETS.ShopPreset.keys, "Spend All (recommended): buys every shop crate with all your Gems and Candy. Keep A Reserve: the same, keeping 500 Gems and 1,000 Candy.")
	t1._toggle(v4796, "Enable Crate Shop", "AutoCrateShop", "Buys the chosen shop crates with Gems or Candy while you have more than the Keep amounts, ten at a time when you can pay for ten, as the shop's Buy buttons do. Never spends Robux; Open Crates opens what it buys.", v4389("crateshop"))
	t1._drops.ShopCrates = t1._dropdown(v4796, "Crates", t1._seed("ShopCrates", {
		"Exclusive Halloween Crate",
		"Exclusive Spider Crate"
	}), "ShopCrates", true, "Crates it buys, read live from the shop (each shows its Gems or Candy price in the shop). Nothing selected = does nothing.", v4389("crateshop"))
	t1._slider(v4796, "Keep Gems", 0, 10000, "ShopKeepGems", "Gems it never spends.", v4389("crateshop"))
	t1._slider(v4796, "Keep Candy", 0, 50000, "ShopKeepCandy", "Candy it never spends.", v4389("crateshop"))
	t1._range(v4796, "Buy Delay", "ShopDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("crateshop"))
	t1._restore(v4796)
end

do
	local v4797 = t306.Claim:DrawSection({
		Name = "Auto Codes",
		Position = "left"
	})

	t1._status(v4797, v4390("AutoCodes"), v4391(t1.Codes))
	t1._toggle(v4797, "Enable Auto Codes", "AutoCodes", "Redeems the selected codes once per account, as the shop's code box does. The game takes codes after 3 wins.", v4389("codes"))
	t1._drops.CodeSelection = t1._dropdown(v4797, "Codes", t1._seed("CodeSelection", t3), "CodeSelection", true, "Codes it redeems. Nothing selected = does nothing.", v4389("codes"))

	local v4798 = v4797:AddTextBox({
		Name = "Extra Codes",
		Default = tostring(t12.CodesExtra or ""),
		Placeholder = "NewCode1, NewCode2",
		Flag = "CodesExtra",
		Callback = function(p1032)
			t12.CodesExtra = tostring(p1032 or "")
			t1._saveSoon()
			t1._wakeThrottled("codes", 1)
		end
	})

	if v4798 and v4798.Link then
		v4798.Link:AddHelper({
			Text = "New codes that are not in the list yet (from the game's Discord or update log), separated by commas. Each is tried once per account. Kept when you restore defaults."
		})
	end

	t1._range(v4797, "Codes Delay", "CodesDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("codes"))
	t1._restore(v4797)
end

do
	local v4799 = t306.Quests:DrawSection({
		Name = "Daily Quests",
		Position = "left"
	})

	t1._status(v4799, v4390("AutoQuests"), v4391(t1.Quest))
	t1._preset(v4799, "Quest Preset", "QuestPreset", t1.PRESETS.QuestPreset.values, t1.PRESETS.QuestPreset.keys, "Instant (recommended): claims every quest the game lists as soon as it is done. Natural: the same with a 2-5 s pause before each claim.")
	t1._toggle(v4799, "Enable Daily Quests", "AutoQuests", "Claims each selected daily quest once it is finished, in the lobby, as the Quests panel's Claim button does. The game opens quests from 20 wins.", v4389("quests"))
	t1._drops.QuestSelection = t1._dropdown(v4799, "Quests", t1._seed("QuestSelection", t1.Quest.names()), "QuestSelection", true, "Quests it claims; new quests the game adds are picked automatically. Nothing selected = does nothing.", v4389("quests"))
	t1._range(v4799, "Claim Delay", "QuestDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("quests"))
	t1._restore(v4799)
end

do
	local v4800 = t306.Claim:DrawSection({
		Name = "Medal Reward",
		Position = "left"
	})

	t1._status(v4800, v4390("AutoMedal"), v4391(t1.Medal))
	t1._preset(v4800, "Medal Preset", "MedalPreset", t1.PRESETS.MedalPreset.values, t1.PRESETS.MedalPreset.keys, "Instant (recommended): claims the Medal reward as soon as you reach the lobby. Natural: the same after a 2-5 s pause.")
	t1._toggle(v4800, "Enable Medal Reward", "AutoMedal", "Claims the lobby's Medal panel reward once per server, as its Claim button does.", v4389("medal"))
	t1._dropdown(v4800, "Rewards", t1.MEDAL_REWARDS, "MedalSelection", true, "Clip Partner Reward: the Medal panel's Claim button (the panel has this one reward). Nothing selected = does nothing.", v4389("medal"))
	t1._range(v4800, "Claim Delay", "MedalDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("medal"))
	t1._restore(v4800)
end

do
	local v4801 = t306.Claim:DrawSection({
		Name = "Auto Boosts",
		Position = "right"
	})

	t1._status(v4801, v4390("AutoBoosts"), v4391(t1.Boost))
	t1._preset(v4801, "Boost Preset", "BoostPreset", t1.PRESETS.BoostPreset.values, t1.PRESETS.BoostPreset.keys, "Instant (recommended): drinks every boost the moment it runs out. Natural: the same with a 2-5 s pause.")
	t1._toggle(v4801, "Enable Auto Boosts", "AutoBoosts", "Drinks a stored Coins or Lucky potion whenever that boost is not running, as the shop's Use button does.", v4389("boosts"))
	t1._dropdown(v4801, "Boosts", t5, "BoostSelection", true, "Coins: more coins per round. Lucky: better summon odds. Nothing selected = does nothing.", v4389("boosts"))
	t1._range(v4801, "Boost Delay", "BoostDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("boosts"))
	t1._restore(v4801)
end

do
	local v4802 = t306.Items:DrawSection({
		Name = "Open Crates",
		Position = "left"
	})

	t1._status(v4802, v4390("AutoCrates"), v4391(t1.Crates))
	t1._preset(v4802, "Crate Preset", "CratePreset", t1.PRESETS.CratePreset.values, t1.PRESETS.CratePreset.keys, "Instant (recommended): opens every crate the game lists, one after another. Natural: the same with a 2-5 s pause before each.")
	t1._toggle(v4802, "Enable Open Crates", "AutoCrates", "Opens the selected crates in your items (from wins, rewards and the Crate Shop) one at a time, as the bag's Open button does.", v4389("crates"))
	t1._drops.CrateSelection = t1._dropdown(v4802, "Crates To Open", t1._seed("CrateSelection", t1.Crates.names()), "CrateSelection", true, "Crates it opens, read live from the game; new crates are picked automatically. Nothing selected = does nothing.", v4389("crates"))
	t1._range(v4802, "Crate Delay", "CrateDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("crates"))
	t1._restore(v4802)
end

do
	local v4803 = t306.Items:DrawSection({
		Name = "Use Pass Items",
		Position = "right"
	})

	t1._status(v4803, v4390("AutoPassItems"), v4391(t1.Pass))
	t1._preset(v4803, "Pass Item Preset", "PassItemPreset", t1.PRESETS.PassItemPreset.values, t1.PRESETS.PassItemPreset.keys, "Instant (recommended): uses every pass item the game lists once you own it. Natural: the same with a 2-5 s pause before each.")
	t1._toggle(v4803, "Enable Use Pass Items", "AutoPassItems", "Uses the selected pass items you own (gifted or won), as the bag's Use button does. Never buys anything.", v4389("passitems"))
	t1._drops.PassItemSelection = t1._dropdown(v4803, "Pass Items", t1._seed("PassItemSelection", {}), "PassItemSelection", true, "Pass items it uses, read live from the game. Nothing selected = does nothing.", v4389("passitems"))
	t1._range(v4803, "Pass Delay", "PassDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("passitems"))
	t1._restore(v4803)
end

do
	local v4804 = t306.Pass:DrawSection({
		Name = "Claim Tiers",
		Position = "left"
	})

	t1._status(v4804, v4390("AutoPassTiers"), v4391(t1.Tier))
	t1._preset(v4804, "Tier Preset", "TierPreset", t1.PRESETS.TierPreset.values, t1.PRESETS.TierPreset.keys, "Every Track (recommended): claims Free and Premium tiers at once. Free Track: only the free row. Natural: both rows with a 2-5 s pause before each claim.")
	t1._toggle(v4804, "Enable Claim Tiers", "AutoPassTiers", "Claims every Battlepass tier you have the XP for, as the pass's Claim buttons do; claiming the free tier is what levels the pass up. Never buys the Premium Pass or tier skips.", v4389("passtiers"))
	t1._dropdown(v4804, "Tracks", t9, "PassTracks", true, "Free: the free reward row. Premium: the Premium Pass row, skipped while you do not own the pass. Nothing selected = does nothing.", v4389("passtiers"))
	t1._range(v4804, "Claim Delay", "PassTierDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("passtiers"))
	t1._restore(v4804)
end

do
	local v4805 = t306.Pass:DrawSection({
		Name = "Pass Quests",
		Position = "right"
	})

	t1._status(v4805, v4390("AutoPassQuests"), v4391(t1.PQ))
	t1._preset(v4805, "Pass Quest Preset", "PassQuestPreset", t1.PRESETS.PassQuestPreset.values, t1.PRESETS.PassQuestPreset.keys, "Instant (recommended): claims every quest line as soon as a stage is done. Natural: the same with a 2-5 s pause before each claim.")
	t1._toggle(v4805, "Enable Pass Quests", "AutoPassQuests", "Claims finished Battlepass quests for their Candy and pass XP, as each quest's Claim button does; that line's next stage then starts.", v4389("passquests"))
	t1._dropdown(v4805, "Quest Lines", t10, "PassChains", true, "Quest lines it claims. Nothing selected = does nothing.", v4389("passquests"))
	t1._range(v4805, "Quest Delay", "PassQuestDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("passquests"))
	t1._restore(v4805)
end

do
	local v4806 = t306.Settings:DrawSection({
		Name = "Game Settings",
		Position = "left"
	})

	t1._status(v4806, v4390("GameSettings"), v4391(t1.Settings))
	t1._preset(v4806, "Settings Preset", "SettingsPreset", {
		Performance = {
			GameSettingPicks = { "VFX Off" }
		},
		Quiet = {
			GameSettingPicks = {
				"Mute Music",
				"Mute Sounds",
				"VFX Off"
			}
		},
		["No Trades"] = {
			GameSettingPicks = { "Trades Off" }
		}
	}, { "GameSettingPicks" }, "Performance (recommended): VFX Off, the biggest FPS gain in matches. Quiet: no music, sounds or tower effects. No Trades: other players cannot send you trades.")
	t1._toggle(v4806, "Enable Game Settings", "GameSettings", "Off by default. Turns the chosen game settings off in the lobby, as the settings menu does, and puts them back when you unpick them.", v4389("settings"))
	t1._dropdown(v4806, "Settings", t8, "GameSettingPicks", true, "Mute Music / Mute Sounds: the game's music and sound effects. Trades Off: other players cannot send you trades. VFX Off: no tower attack effects, camera shake or spawn effects in matches (big FPS gain). Nothing selected = nothing changes.", v4389("settings"))
	t1._restore(v4806)
end

do
	local v4807 = t306.Settings:DrawSection({
		Name = "Performance",
		Position = "right"
	})

	t1._status(v4807, t1.Vis.any, t1.Vis.live)
	t1._dropdown(v4807, "Black Screen When", {
		"Always",
		"When Unfocused"
	}, "BlackScreenWhen", false, "Always: black while Black Screen is on. When Unfocused: black only while you are in another window, and normal as soon as you click back into Roblox.", v4389("vis"))
	t1._toggle(v4807, "Black Screen", "BlackScreen", "Stops drawing the 3D world and covers the screen in black (the hub stays on top), for the lowest GPU use while farming. Everything keeps running.", v4389("vis"), "BlackScreenKeybind")
	t1._toggle(v4807, "Delete Map", "DeleteMap", "In a match, hides the map's scenery (the road, build area, units and enemies stay), for more FPS. Off puts it all back.", v4389("vis"), "DeleteMapKeybind")
	t1._slider(v4807, "FPS Cap", 0, 240, "FpsCap", "Highest frame rate (0 = your executor's default). Lower saves power while farming.", v4389("vis"), " fps")
	t1._restore(v4807)
end

do
	local v4808 = t306.Quests:DrawSection({
		Name = "Special Quests",
		Position = "left"
	})

	t1._status(v4808, v4390("AutoSpecialQuests"), v4391(t1.Special))
	t1._preset(v4808, "Special Quest Preset", "SpecialQuestPreset", {
		["Every Milestone"] = {
			SpecialQuestSelection = t1.Special.names(),
			SpecialQuestDelay = {
				Min = 0,
				Max = 0
			}
		},
		Humanized = {
			SpecialQuestSelection = t1.Special.names(),
			SpecialQuestDelay = {
				Min = 2,
				Max = 5
			}
		}
	}, {
		"SpecialQuestSelection",
		"SpecialQuestDelay"
	}, "Every Milestone (recommended): finds every speaker Speakerman hid in this server and claims each milestone reward. Humanized: 2-5 seconds between speakers and claims.")
	t1._toggle(v4808, "Enable Special Quests", "AutoSpecialQuests", "While Speakerman's event runs, goes to each speaker you have not found in this server (lobby or match) and clicks it with the speaker's own click detector, then claims the picked milestone rewards in the lobby with the quest board's own ClaimMilestone call. Rewards need an account at least 7 days old, as in the game.", v4389("special"))
	t1._drops.SpecialQuestSelection = t1._dropdown(v4808, "Milestones", t1._seed("SpecialQuestSelection", t1.Special.names()), "SpecialQuestSelection", true, "Milestone rewards to claim, from the game's own list (speakers found: reward). Nothing selected = finds speakers only.", v4389("special"), true)
	t1._range(v4808, "Special Quest Delay", "SpecialQuestDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("special"))
	GlowButton(v4808, "Teleport", function()
		if not t1.Special.trip() then
			t1._note("special:none", "Special Quests: no unfound speaker in this server.")
		end
	end)
	t1._restore(v4808, "Special Quests")
end

do
	local v4809 = t306.Items:DrawSection({
		Name = "RNG Roll",
		Position = "left"
	})

	t1._status(v4809, v4390("AutoRngRoll"), v4391(t1.Rng))
	t1._preset(v4809, "RNG Roll Preset", "RngRollPreset", {
		["Every Slot"] = {
			RngRollDelay = {
				Min = 0,
				Max = 0
			}
		},
		Humanized = {
			RngRollDelay = {
				Min = 1,
				Max = 3
			}
		}
	}, { "RngRollDelay" }, "Every Slot (recommended): rolls the moment a hotbar slot is empty until all five hold a unit. Humanized: 1-3 seconds between rolls.")
	t1._toggle(v4809, "Enable RNG Roll", "AutoRngRoll", "In RNG World (Tasty Large Cake), rolls with the RNG button's own RNGRoll call while a hotbar slot is empty, so Auto Play has units to place.", v4389("rng", "play"))
	t1._range(v4809, "Roll Delay", "RngRollDelay", "Random extra seconds before each action (0 to 0 = none); the status counts down.", v4389("rng"))
	t1._restore(v4809, "RNG Roll")
end

do
	local v4810 = t306.PlayerMods:DrawSection({
		Name = "Movement",
		Position = "left"
	})

	t1._status(v4810, function()
		return true
	end, t1.Move.live)
	t1._dropdown(v4810, "Movement Mode", {
		"Teleport",
		"Tween",
		"Walk"
	}, "MoveMode", false, "How Auto Join reaches the elevators. Teleport (recommended): instant. Tween: glides at Tween Speed. Walk: walks at Walk Speed.", function(p1033)
		t1.Move.stop()
		t1.Move.text = "[READY] " .. p1033
	end)
	t1._slider(v4810, "Tween Speed", 10, 400, "TweenSpeed", "Studs per second in Tween mode.", nil, " studs/s")
	t1._slider(v4810, "Walk Speed", 8, 250, "WalkSpeed", "Walk speed while walking to an elevator; your normal speed comes back after each walk.", nil)
	t1._restore(v4810)
end

do
	local v4811 = t306.GameMods:DrawSection({
		Name = "Match Mods",
		Position = "left"
	})

	t1._status(v4811, v4390("MatchMods"), t1.Mods.live("match"))
	t1._preset(v4811, "Match Mods Preset", "MatchModPreset", {
		["Place Anywhere"] = {
			MatchSkips = table.clone(t1.Mods.CHECKS),
			StackGap = 1
		},
		["Stack Units"] = {
			MatchSkips = { "Overlap" },
			StackGap = 1
		},
		["Off The Path"] = {
			MatchSkips = { "Road" },
			StackGap = 1
		}
	}, {
		"MatchSkips",
		"StackGap"
	}, "Place Anywhere (recommended): skips every client placement check and packs units 1 stud apart. Stack Units: keeps the ground and road checks but packs units together. Off The Path: only places on the path too.")
	t1._toggle(v4811, "Enable Match Mods", "MatchMods", "Auto Play, Smart Deploy, Valid Spots and the placement picker skip the client-only placement checks picked below; the server's reply keeps only the placements it accepts.", v4389("play"))
	t1._dropdown(v4811, "Skip Checks", t1.Mods.CHECKS, "MatchSkips", true, "Ground: places off Game.TowerArea (where no build ground is found). Road: places on the enemy path (the game allows it). Overlap: packs units Stacked Spacing apart (footprints may overlap). Nothing selected = waiting.", v4389("play"))
	t1._slider(v4811, "Stacked Spacing", 1, 5, "StackGap", "Studs between units when Overlap is skipped (footprints may overlap).", v4389("play"), " studs")
	t1._restore(v4811, "Match Mods")
end

do
	local t329 = {
		"Fly",
		"Infinite Jump",
		"Jump Boost",
		"Noclip",
		"Speed"
	}
	local v4813 = t306.PlayerMods:DrawSection({
		Name = "Player Mods",
		Position = "right"
	})

	t1._status(v4813, v4390("MoveMods"), t1.Walk.modsText)
	t1._preset(v4813, "Player Mods Preset", "MoveModPreset", {
		Blatant = {
			MoveModActions = t329,
			ModWalkSpeed = 100,
			ModFlySpeed = 120,
			ModJumpPower = 120
		},
		["Speed Only"] = {
			MoveModActions = {
				"Infinite Jump",
				"Speed"
			},
			ModWalkSpeed = 60,
			ModFlySpeed = 120,
			ModJumpPower = 120
		}
	}, {
		"MoveModActions",
		"ModWalkSpeed",
		"ModFlySpeed",
		"ModJumpPower"
	}, "Blatant (recommended): fly, noclip, fast walking and big jumps. Speed Only: faster walking and air jumps.")
	t1._toggle(v4813, "Enable Player Mods", "MoveMods", "Mods on your own character.", v4389("walk"))
	t1._slider(v4813, "Walk Speed", 16, 300, "ModWalkSpeed", "Walking speed for Speed.", v4389("walk"))
	t1._slider(v4813, "Fly Speed", 20, 400, "ModFlySpeed", "Flying speed for Fly.")
	t1._slider(v4813, "Jump Power", 50, 400, "ModJumpPower", "Jump power for Jump Boost.", v4389("walk"))
	t1._dropdown(v4813, "Mod Actions", t329, "MoveModActions", true, "Fly: WASD plus Space and Left Ctrl. Noclip: walk through walls. Speed: Walk Speed. Jump Boost: Jump Power. Infinite Jump: jump again in the air. Nothing selected = no mods.", v4389("walk"))
	t1._restore(v4813, "Player Mods", function()
		t1._wake("walk")
	end)
end

do
	local v4814 = t306.Esp:DrawSection({
		Name = "PATH VISUALS",
		Position = "left"
	})

	v4555(v4814, "Path Route", "EspRoute", "Every enemy lane on the map.")
	v4555(v4814, "Path Nodes", "EspNodes", "The lane's corners.")
	v4555(v4814, "Path Direction", "EspDirection", "Arrows in the direction enemies walk.")
end

do
	local v4815 = t306.Esp:DrawSection({
		Name = "COMBAT VISUALS",
		Position = "right"
	})

	v4555(v4815, "Unit Ranges", "EspRanges", "Attack range of your placed units at their current level.")
	v4555(v4815, "Enemy Info", "EspEnemies", "Name over every enemy, plus the details below.")
	t1._dropdown(v4815, "Enemy Detail", {
		"Distance",
		"Health",
		"Tags"
	}, "EspEnemyDetail", true, "Health: current and max health. Tags: [BOSS]. Distance: studs from you.", function()
		t1._wake("esp")
	end)
end

do
	local v4816 = t306.Grids:DrawSection({
		Name = "Valid Spots",
		Position = "left"
	})

	t1.registerStatus({
		para = v4816:AddParagraph({
			Title = "Spots",
			Content = ""
		}),
		on = function()
			return t12.EspSpots == true
		end,
		live = t1.Plan.spotsText,
		idle = "[IDLE]"
	})
	t1._preset(v4816, "Spots Preset", "SpotsPreset", {
		["Every Spot"] = {
			EspSpotKinds = { "Ground" },
			EspSpotLimit = 6000
		},
		["Light Load"] = {
			EspSpotKinds = { "Ground" },
			EspSpotLimit = 1500
		},
		["Whole Map"] = {
			EspSpotKinds = { "Ground" },
			EspSpotLimit = 10000
		}
	}, {
		"EspSpotKinds",
		"EspSpotLimit"
	}, "Every Spot (recommended): up to 6000 Pattern tiles. Light Load: 1500 tiles, for weaker PCs. Whole Map: up to 10000 tiles on the biggest maps. Only the drawing is limited: Smart Deploy always picks from every spot.")
	v4555(v4816, "Valid Spots", "EspSpots", "Draws the picked Pattern as its own tiles (hexagons, squares, diamonds, bricks or triangles; nothing for Random): every spot Smart Deploy places on, on the Game.TowerArea ground the game's own placement test accepts (no road, no other towers) beside the lanes inside Deploy Coverage. Smart Deploy puts each unit on the tile best for its range, next to units already placed, so they build up in batches.")
	t1._slider(v4816, "Spot Limit", 100, 10000, "EspSpotLimit", "Most tiles drawn of each kind, inner rows first (a cut row is spread over the whole lane). Smart Deploy still picks from every spot.", function()
		t1._wake("esp")
	end)
	t1._restore(v4816, "Valid Spots", function()
		t1._wake("esp")
	end)
end

do
	local v4817 = t306.Grids:DrawSection({
		Name = "Build Ground",
		Position = "right"
	})

	t1._status(v4817, v4390("EspGround"), function()
		if t1.Ctx.place() ~= "MATCH" then
			return "[IDLE] Build Ground | Match Only"
		end

		if t1.Place.folders() then
			return "[ACTIVE] " .. (t12.EspGroundOutline == true and "Outlining" or "Highlighting") .. " | Tower Area"
		end

		return "[WAITING] Awaiting Map | No Tower Area"
	end)
	t1._preset(v4817, "Ground Preset", "GroundPreset", {
		["Build Ground"] = {
			EspGroundKinds = { "Ground" },
			EspGroundOutline = false
		},
		Outlines = {
			EspGroundKinds = { "Ground" },
			EspGroundOutline = true
		}
	}, {
		"EspGroundKinds",
		"EspGroundOutline"
	}, "Build Ground (recommended): fills the map's tower area (Game.TowerArea). Outlines: its edges only.")
	v4555(v4817, "Build Ground", "EspGround", "Highlights the map's tower area (Game.TowerArea), the only ground units can be placed on.")
	t1._toggle(v4817, "Outline Only", "EspGroundOutline", "Draws only the edges, so the ground stays visible under them.", function()
		t1._wake("esp")
	end)
	t1._restore(v4817, "Build Ground", function()
		t1._wake("esp")
	end)
end

do
	local v4818 = t306.Grids:DrawSection({
		Name = "Road",
		Position = "left"
	})

	t1._status(v4818, v4390("EspPath"), function()
		if t1.Ctx.place() ~= "MATCH" then
			return "[IDLE] Road | Match Only"
		end

		if t1.Paths.get() then
			return "[ACTIVE] Road | Lane Ribbon"
		end

		return "[ACTIVE] Road | Road Parts"
	end)
	v4555(v4818, "Road", "EspPath", "Highlights the road enemies walk; Smart Deploy keeps units beside it unless Match Mods skip Road.")
	t1._restore(v4818, "Road", function()
		t1._wake("esp")
	end)
end

do
	local v4819 = t306.Grids:DrawSection({
		Name = "Position Markers",
		Position = "right"
	})

	t1._status(v4819, v4390("PlacementPreview"), function()
		if t1.Ctx.place() ~= "MATCH" then
			return "[IDLE] Saved Positions | Match Only"
		end

		local n101 = 0
		local v4821 = type(t1.Pick.positions()) == "table" and t1.Pick.positions() or {}

		for _, v in pairs(v4821) do
			n101 += type(v) == "table" and #v or 0
		end

		if n101 == 0 then
			return "[NONE] Saved Positions | This Map"
		end

		return "[ACTIVE] " .. n101 .. " Saved Positions | This Map"
	end)
	t1._preset(v4819, "Marker Preset", "MarkerPreset", {
		Labeled = {
			PlacementLabels = true,
			PlacementMarkerSize = 3
		},
		["Markers Only"] = {
			PlacementLabels = false,
			PlacementMarkerSize = 3
		},
		["Large Markers"] = {
			PlacementLabels = true,
			PlacementMarkerSize = 5
		}
	}, {
		"PlacementLabels",
		"PlacementMarkerSize"
	}, "Labeled (recommended): a marker and its unit's name at each saved position. Markers Only: no names. Large Markers: bigger markers with names.")
	v4555(v4819, "Saved Positions", "PlacementPreview", "A marker at each position saved in Custom Placement on this map, named for its unit (only you see it; it never blocks placement).", "markers")
	t1._toggle(v4819, "Show Labels", "PlacementLabels", "The unit name and number over each marker.", function()
		t1._wake("markers")
	end)
	t1._slider(v4819, "Marker Size", 1, 8, "PlacementMarkerSize", "Width of each marker.", function()
		t1._wake("markers")
	end, " studs")
	t1._restore(v4819, "Position Markers", function()
		t1._wake("markers")
	end)
end

do
	local v4824 = t306.Grids:DrawSection({
		Name = "Max Range Ring",
		Position = "left"
	})

	t1._status(v4824, v4390("EspMaxRange"), function()
		if t1.Ctx.place() ~= "MATCH" then
			return "[IDLE] Max Range Ring | Match Only"
		end

		if t1.Vis.ring then
			return "[ACTIVE] Max Range Ring | Placing"
		end

		return "[READY] Max Range Ring | Place A Unit By Hand"
	end)
	v4555(v4824, "Max Range On Placement", "EspMaxRange", "While you place a unit by hand, a second ring around the game's own range ring shows its range at max upgrade.", "placering")
	t1._restore(v4824, "Max Range Ring", function()
		t1._wake("placering")
	end)
end

do
	local v4825 = t306.Webhook:DrawSection({
		Name = "Webhook",
		Position = "left"
	})

	t1._status(v4825, v4390("Webhook"), v4391(t1.Hook))
	t1._toggle(v4825, "Enable Webhook", "Webhook", "Sends the alerts turned on in Summon Alerts, Wave Alerts and Match Results to your Discord webhook, at most one message every 2 seconds; alerts that arrive together are combined into one message. Turning it on sends a connected message as the test.", function(p1034)
		t1.Hook.parked = nil

		if p1034 then
			t1.Hook.greeted = nil
			t1.Hook.greet()
		end

		t1._wake("webhook")
	end)

	local v4826 = v4825:AddTextBox({
		Name = "Webhook URL",
		Default = tostring(t12.WebhookUrl or ""),
		Placeholder = "discord.com/api/webhooks/...",
		Flag = "WebhookUrl",
		Callback = function(p1035)
			t12.WebhookUrl = tostring(p1035 or "")
			t1._saveSoon()
			t1._alarm("hookGreet", 1.5, "hook:greet")
			t1._wakeThrottled("webhook", 0.5)
			t1._wakeThrottled("status", 0.5)
		end
	})

	if v4826 and v4826.Link then
		v4826.Link:AddHelper({
			Text = "Discord channel > Edit Channel > Integrations > Webhooks > Copy Webhook URL. Kept when you restore defaults."
		})
	end

	local v4827 = v4825:AddTextBox({
		Name = "Discord User ID",
		Default = tostring(t12.WebhookUserId or ""),
		Placeholder = "Ping me (optional)",
		Flag = "WebhookUserId",
		Callback = function(p1036)
			t12.WebhookUserId = tostring(p1036 or "")
			t1._saveSoon()
		end
	})

	if v4827 and v4827.Link then
		v4827.Link:AddHelper({
			Text = "Your numeric Discord user ID (Developer Mode > right click your name > Copy User ID). Pinged by the alerts set to ping in each alert section. Kept when you restore defaults."
		})
	end

	GlowButton(v4825, "Send Test Message", function()
		if t12.Webhook then
			if t1.Hook.url() then
				local Hook = t1.Hook

				t1.Hook.parked = nil
				Hook.greeted = nil
				t1.Hook.greet()
			else
				t1.Hook.text = "[WAITING] Awaiting URL"
			end
		else
			t1.Hook.text = "[WAITING] Awaiting Webhook"
		end

		t1._wake("status")
	end)
	t1._restore(v4825)
end

do
	local v4829 = t306.Webhook:DrawSection({
		Name = "Match Results",
		Position = "right"
	})

	t1._status(v4829, v4390("HookMatch"), t1.Hook.recordText)
	t1._dropdown(v4829, "Send On", {
		"Every Round",
		"Wins Only",
		"Losses Only",
		"Summaries Only"
	}, "HookMatchSend", false, "Every Round (recommended): a win or loss alert after each round. Summaries Only: just the session summary below.")
	t1._toggle(v4829, "Enable Match Alerts", "HookMatch", "Sends round results and session summaries. The win/loss record above counts every round; it carries across the lobby and match servers (run the script in both) and starts over after an hour without a round.", v4389("status"))
	t1._dropdown(v4829, "Match Details", {
		"Coins Reward",
		"Duration",
		"Map And Mode",
		"Session Record",
		"Waves"
	}, "HookMatchDetails", true, "Lines in each round alert. Coins Reward: the mode's Money and Candy on a win, Money for the wave reached on a loss. Nothing selected = just the result.")
	t1._dropdown(v4829, "Match Actions", {
		"Disconnect Alert",
		"Ping On Disconnect",
		"Ping On Loss",
		"Ping On Summary",
		"Ping On Win"
	}, "HookMatchActions", true, "Disconnect Alert: an alert with the reason when Roblox disconnects or kicks you, so you know a farm stopped. The Ping options ping your Discord user ID with that alert. Nothing selected = no pings.")
	t1._slider(v4829, "Summary Every", 0, 50, "HookSummaryEvery", "Rounds between session summaries (record, best streak, rounds per hour, coins from wins). 0 = off.", nil, " rounds")
	t1._restore(v4829, t1.Hook.resetRecord)
end

do
	local v4830 = t306.Webhook:DrawSection({
		Name = "Wave Alerts",
		Position = "right"
	})

	t1._status(v4830, v4390("HookWaves"), function()
		return t1.Hook.groupText("wave", "[READY] Wave Alerts | Every " .. math.max(1, t1._n(t12.HookWaveEvery, 1)) .. " Waves")
	end)
	t1._toggle(v4830, "Enable Wave Alerts", "HookWaves", "Sends a wave report a second after a new wave starts, with the details picked in Wave Actions.", v4389("status"))
	t1._slider(v4830, "Wave Every", 1, 50, "HookWaveEvery", "Waves between reports. 1 = every wave; 5 (recommended) reports waves 5, 10, 15 and so on.", v4389("status"), " waves")
	t1._dropdown(v4830, "Wave Actions", {
		"Base Health",
		"Cash",
		"Enemies Left",
		"Ping Me",
		"Towers Placed",
		"Wave Time"
	}, "HookWaveActions", true, "Base Health: base health left. Cash: your round money. Enemies Left: enemies on the path. Towers Placed: your units on the board by name, count and level. Wave Time: how long the last wave took. Ping Me: pings your Discord user ID.")
	t1._restore(v4830)
end

do
	local v4831 = t306.Webhook:DrawSection({
		Name = "Summon Alerts",
		Position = "left"
	})

	t1._status(v4831, v4390("HookSummons"), function()
		return t1.Hook.groupText("summon", "[READY] Summon Alerts | " .. tostring(t12.HookSummonRarity))
	end)
	t1._drops.HookSummonRarity = t1._dropdown(v4831, "Alert Rarity", t1._seed("HookSummonRarity", t1.Hook.rarities()), "HookSummonRarity", false, "Lowest rarity that sends a summon alert, by the game's own rarity order. Legendary And Above (recommended) keeps it to the rare pulls.", v4389("status"), true)
	t1._toggle(v4831, "Enable Summon Alerts", "HookSummons", "One alert per summon or crate opening with every unit at or above the alert rarity, from the units the server sends back to Auto Summon and every crate you open.", v4389("status"))
	t1._toggle(v4831, "Ping Me", "HookSummonPing", "Pings your Discord user ID with each summon alert.")
	t1._restore(v4831)
end

t1._conn(UserInputService.InputBegan, function(p1037, p1038)
	if p1038 or p1037.KeyCode == Enum.KeyCode.Unknown or not t1._kbReg or UserInputService:GetFocusedTextBox() then
		return
	end

	local Name = p1037.KeyCode.Name

	for _, v in ipairs(t1._kbReg) do
		local ok, result = pcall(function()
			return v.kb:GetValue()
		end)

		if ok and (result == nil or result == "") and t12[v.kbFlag] ~= "None" then
			t12[v.kbFlag] = "None"
			t1._saveSoon()
		end

		if ok and result ~= "None" and Name == result then
			if v.press then
				if t12[v.flag] then
					v.press()
				end
			else
				t12[v.flag] = not t12[v.flag]
				pcall(function()
					v.control:SetValue(t12[v.flag])
				end)
			end
		end
	end
end)
v4387.BuildSettings()

local function v4837(p1039, p1040, p1041, p1042)
	if not p1039 or #p1041 == 0 then
		return
	end

	if p1042 then
		local t330 = {}

		for _, v in ipairs(t12[p1040]) do
			if table.find(p1041, v) then
				t330[#t330 + 1] = v
			end
		end

		t12[p1040] = t330
		t1._refreshValues(p1039, p1041, t1._set(t330))
	else
		if not table.find(p1041, t12[p1040]) then
			t12[p1040] = p1041[1]
		end

		t1._refreshValues(p1039, p1041, t12[p1040])
	end
end

t1._reapplyLoadoutPresets = function()
	local t331 = {}

	for _, v in ipairs(t1.Match.slots()) do
		t331[#t331 + 1] = v.slot .. "=" .. tostring(v.id)
	end

	if #t331 == 0 then
		return
	end

	local loadoutSig = table.concat(t331, ",")

	if loadoutSig == t1._loadoutSig then
		return
	end

	t1._loadoutSig = loadoutSig

	for k, loadoutPreset in pairs(t1._loadoutPresets) do
		local v4847 = loadoutPreset[t12[k]]

		if type(v4847) == "function" then
			local ok, result = pcall(v4847)

			if ok and type(result) == "table" then
				result.UpgradePriority = nil
				result.CustomPriority = nil
				t1._applyValues(result)
			end
		end
	end
end
t1._hydrate = function()
	if not t1._drops then
		return
	end

	t1._refill(t1._drops.SummonCrate, "SummonCrate", t1.Sum.names())
	t1._refill(t1._drops.SummonWanted, "SummonWanted", t1.Sum.unitNames())

	local v4850 = t1.Shop.names()

	if #v4850 > 0 then
		t1._refill(t1._drops.ShopCrates, "ShopCrates", v4850)
	end

	local v4851 = t1.Rarities()

	t1._refill(t1._drops.AutosellRarities, "AutosellRarities", t1.ASell.rarities())
	t1._refill(t1._drops.UnitSellRarities, "UnitSellRarities", v4851)

	local t332 = { "Any Map" }

	for _, v in ipairs(t1.Queue.mapNames()) do
		t332[#t332 + 1] = v
	end

	for _, v in ipairs(t1.MM.maps()) do
		if not table.find(t332, v) then
			t332[#t332 + 1] = v
		end
	end

	t1._refill(t1._drops.JoinMap, "JoinMap", t332)

	local v4857 = t1.Queue.modNames()

	t1._refill(t1._drops.JoinModifiers, "JoinModifiers", t1._seed("JoinModifiers", v4857))

	if #v4857 > 0 then
		t1._adopt("ModVotePicks", "ModVotePicksSeen", v4857)
		t1._refill(t1._drops.ModVotePicks, "ModVotePicks", v4857)
	end

	local t333 = { "Smart Progression" }

	for _, v in ipairs(t1.Vote.modes()) do
		t333[#t333 + 1] = v
	end

	t1._refill(t1._drops.VoteMode, "VoteMode", t333)

	local v4861 = t1.Crates.names()

	if #v4861 > 0 then
		t1._adopt("CrateSelection", "CrateSelectionSeen", v4861)
		t1._refill(t1._drops.CrateSelection, "CrateSelection", v4861)
	end

	local v4862 = t1.Pass.names()

	if #v4862 > 0 then
		t1._adopt("PassItemSelection", "PassItemSelectionSeen", v4862)
		t1._refill(t1._drops.PassItemSelection, "PassItemSelection", v4862)
	end

	local v4863 = t1.Codes.names()

	t1._adopt("CodeSelection", "CodeSelectionSeen", v4863)
	t1._refill(t1._drops.CodeSelection, "CodeSelection", v4863)

	local v4864 = t1.Quest.names()

	t1._adopt("QuestSelection", "QuestSelectionSeen", v4864)
	t1._refill(t1._drops.QuestSelection, "QuestSelection", v4864)

	local v4865 = t1.Rank.names()

	if #v4865 > 0 then
		t1._adopt("RankSelection", "RankSelectionSeen", v4865)
		t1._refill(t1._drops.RankSelection, "RankSelection", v4865)
	end

	local HookSummonRarity = t1._drops.HookSummonRarity

	if HookSummonRarity then
		t1._refreshing = true
		pcall(function()
			HookSummonRarity:SetValues(t1.Hook.rarities())
		end)
		t1._setControl("HookSummonRarity", t12.HookSummonRarity)
		t1._refreshing = false
	end

	local v4867 = t1.Special.names()

	if #v4867 > 0 then
		t1._adopt("SpecialQuestSelection", "SpecialQuestSelectionSeen", v4867)
		t1._refill(t1._drops.SpecialQuestSelection, "SpecialQuestSelection", v4867)
	end
end

do
	t1.UI_hydrate = function()
		if t1.Play.refreshRarities then
			pcall(t1.Play.refreshRarities)
		end

		pcall(t1._reapplyLoadoutPresets)

		if t1.Play.refreshPaths then
			pcall(t1.Play.refreshPaths)
		end

		if t1.Upg.farmDrop then
			pcall(t1._liveMulti, "UpgradeFarmUnits", t1.Data.farms(), t1.Upg.farmDrop)
		end

		pcall(t1._hydrate)
		pcall(function()
			local t334 = {}

			for _, v in ipairs(t1.Match.slots()) do
				if not table.find(t334, v.name) then
					t334[#t334 + 1] = v.name
				end
			end

			for _, sellTower in ipairs(t12.SellTowers) do
				if not table.find(t334, sellTower) then
					t334[#t334 + 1] = sellTower
				end
			end

			if #t334 > 0 then
				t1._refreshValues(t1.Sell.drop, t1._sorted(t334), t1._set(t12.SellTowers))
			end
		end)

		if t1.Macro.refreshList then
			pcall(t1.Macro.refreshList)
		end

		if t1.Pick.refreshMaps then
			pcall(t1.Pick.refreshMaps)
		end

		pcall(function()
			local v4873 = t1.Match.slots()
			local limitDrops = t1.Play.limitDrops or {}

			for k, limitDrop in pairs(limitDrops) do
				local n102 = 20
				local v4878

				for _, v in ipairs(v4873) do
					if v.slot == k then
						v4878 = t1.Play.typeLimit(v.id)
						n102 = math.clamp(v4878 or 20, 1, 20)
					end
				end

				local t335 = { v4878 and "Game Limit | " .. v4878 or "Game Limit" }
				local v4882 = t12["SlotLimit" .. k]

				if tonumber(v4882) then
					n102 = math.clamp(math.max(n102, tonumber(v4882)), 1, 20)
				end

				for i = 1, n102 do
					t335[#t335 + 1] = tostring(i)
				end

				if not table.find(t335, v4882) then
					v4882 = t335[1]
					t12["SlotLimit" .. k] = v4882
				end

				t1._refreshValues(limitDrop, t335, v4882)
			end
		end)
	end
end

do
	t1._wakeHandlers.hydrate = function()
		pcall(t1.UI_hydrate)
		t1._resyncStatuses()
	end
end

pcall(t1.Pick.onSaved)
t1._wake("walk")
task.spawn(t1._bind)
task.defer(t1._resyncStatuses)

do
	local Generation = t1.Generation

	task.delay(5, function()
		if not t1.Running or Generation ~= t1.Generation then
			return
		end

		pcall(t1.UI_hydrate)
		t1._wakeAll()
	end)
end