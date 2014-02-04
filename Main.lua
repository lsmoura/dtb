--
-- DruidTimerBars - Druid ability and debuff tracker
-- Gilbert - Tichondrius US
-- Some portions borrowed from SquawkAndAwe, Adorielle, Eldre'Thalas US
--

-- Stop now if the player isn't a Druid.
if select(2, UnitClass('player')) ~= "DRUID" then
    DisableAddOn("DTB")
    return
end

-- Ace3 setup
DTB = LibStub("AceAddon-3.0"):NewAddon("DTB", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DTB")
local M = LibStub:GetLibrary("LibSharedMedia-3.0")

-- Bars & Frames stuff
DTB.frame		= CreateFrame("Frame",nil,UIParent)
DTB.barList		= {}
DTB.visibleBars		= 0
local barIndex		= 0
DTB.resort		= nil

-- Other variables
local playerGUID, playerName, playerTarget, playerLevel, form, isBalance
local powericon		= 0
local lastupdate	= 0
DTB.testbars		= false

-- Spell information. For cooldowns, list the remaining cooldown after the duration of the spell.
-- IE, Barkskin has a 1 minute cooldown from activation, but lasts 12 seconds, so its cooldown is 48.
-- cdm means this spell should use the Cooldown Model.
-- cdms means the Cooldown Model is in progress.
DTB.Starfall		= { id=48505, cdm=-1, cdms=nil, name=GetSpellInfo(48505), cd=80,   cdend=nil, focus=nil, talented=nil, surges=0, active=nil }
DTB.Starsurge		= { id=78674, cdm=-1, cdms=nil, name=GetSpellInfo(78674), cd=15,   used=nil,  oncd=nil }
DTB.TigersFury		= { id=5217,  cdm=-1, cdms=nil, name=GetSpellInfo(5217),  cd=24,   cdend=nil }
DTB.Berserk		= { id=50334, cdm=-1, cdms=nil, name=GetSpellInfo(50334), cd=165,  cdend=nil }
DTB.Barkskin		= { id=22812, cdm=-1, cdms=nil, name=GetSpellInfo(22812), cd=48,   cdend=nil }
DTB.ForceofNature	= { id=33831, cdm=-1, cdms=nil, name=GetSpellInfo(33831), cd=180,  used=nil, oncd=nil }
DTB.SolarBeam		= { id=78675, cdm=-1, cdms=nil, name=GetSpellInfo(78675), cd=60,   used=nil, oncd=nil }
DTB.Innervate		= { id=29166, cdm=-1, cdms=nil, name=GetSpellInfo(29166), cd=180,  used=nil, oncd=nil }
DTB.WildGrowth		= { id=48438, cdm=-1, cdms=nil, name=GetSpellInfo(48438), cd=10,   used=nil, oncd=nil }
DTB.NaturesSwiftness	= { id=132158,cdm=-1, cdms=nil, name=GetSpellInfo(132158),cd=180,  used=nil, oncd=nil }
DTB.Swiftmend		= { id=18562, cdm=-1, cdms=nil, name=GetSpellInfo(18562), cd=15,   used=nil, oncd=nil }
DTB.Tranquility		= { id=740,   cdm=-1, cdms=nil, name=GetSpellInfo(740),   cd=480,  used=nil, oncd=nil }
DTB.TreeofLife		= { id=33891, cdm=-1, cdms=nil, name=GetSpellInfo(33891), cd=300,  used=nil, oncd=nil }
DTB.Rebirth		= { id=20484, cdm=-1, cdms=nil, name=GetSpellInfo(20484), cd=1800, used=nil, oncd=nil }
DTB.NaturesGrace	= { id=16886, cdm=-1, cdms=nil, name=GetSpellInfo(16886), cd=45,   cdend=nil }
DTB.Rip			= { id=1079,  cdm=-1, cdms=nil, name=GetSpellInfo(1079)  }
DTB.Moonfire		= { id=8921,  cdm=-1, cdms=nil, name=GetSpellInfo(8921)  }
DTB.Sunfire		= { id=93402, cdm=-1, cdms=nil, name=GetSpellInfo(93402) }
DTB.FaerieFire		= { id=770,   cdm=-1, cdms=nil, name=GetSpellInfo(770)   }
DTB.FaerieSwarm	= { id=102355,   cdm=-1, cdms=nil, name=GetSpellInfo(102355)   }
DTB.Rake		= { id=1822,  cdm=-1, cdms=nil, name=GetSpellInfo(1822)  }
DTB.Lacerate		= { id=33745, cdm=-1, cdms=nil, name=GetSpellInfo(33745) }
DTB.SavageRoar		= { id=127538, cdm=-1, cdms=nil, name=GetSpellInfo(127538) }
DTB.OmenOfClarity	= { id=16870, cdm=-1, cdms=nil, name=GetSpellInfo(16870) }
DTB.SolarEclipse	= { id=48517, name=GetSpellInfo(48517) }
DTB.LunarEclipse	= { id=48518, name=GetSpellInfo(48518) }
DTB.WeakenedBlows	= { id=115798, cdm=-1, cdms=nil }
DTB.WeakenedArmor	= { id=113746, cdm=-1, cdms=nil }

-- Startup & Initialization
function DTB:OnInitialize()
    DTB.db = LibStub("AceDB-3.0"):New("DTBdb", DTB:Defaults(), "Default")
    LibStub("AceConfig-3.0"):RegisterOptionsTable("DTB", DTB:Options())

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(DTB.db))
    DTB.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DTB", "DruidTimerBars")
    DTB:RegisterChatCommand("DTB", "ChatCommand")
    DTB.db:RegisterDefaults(DTB:Defaults())

    DTB.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")

    DTB:MakeFrame()

    -- Hide the Eclipse frame if needed
    DTB:SetEclipseFrame()

    -- And keep it hidden
    EclipseBarFrame:HookScript("OnShow", function() DTB:SetEclipseFrame() end) 

    -- Register events
    DTB:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    DTB:RegisterEvent("PLAYER_TARGET_CHANGED")
    DTB:RegisterEvent("PLAYER_ENTERING_WORLD")
    DTB:RegisterEvent("PLAYER_ALIVE")
    DTB:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    DTB:RegisterEvent("PLAYER_TALENT_UPDATE")

    -- Hello
    print("DTB loaded.")
end

function DTB:OnProfileChanged(event, database, newProfileKey)
	print ("profile changed")
    self:HideAllBars()

	DTB:SetBarWidth(nil, self.db.profile.BarWidth)
	DTB:SetBarHeight(nil, self.db.profile.BarHeight)
	DTB:SetBarSpacing(nil, self.db.profile.BarSpacing)
	DTB:SetBarTexture(nil, self.db.profile.BarTexture)
	DTBdb:SetBarFont(nil, self.db.profile.BarFont)
	DTB:ToggleIconOnly(nil, self.db.profile.IconOnly)
	DTB:ToggleIconRow(nil, self.db.profile.IconRow)
	DTB:ToggleHideIcons(nil, self.db.profile.HideIcons)

end

-- Set up the main addon frame
function DTB:MakeFrame()
    DTB.frame:SetFrameStrata("BACKGROUND")

    if DTB.db.profile.IconOnly then
		if DTB.db.profile.IconRow then
		    DTB.frame:SetWidth(((DTB.db.profile.BarHeight + DTB.db.profile.BarSpacing) * 16) + DTB.db.profile.BarSpacing)
		    DTB.frame:SetHeight(DTB.db.profile.BarHeight + (DTB.db.profile.BarSpacing * 2))
		else
		    DTB.frame:SetWidth(DTB.db.profile.BarHeight + (DTB.db.profile.BarSpacing * 2))
		    DTB.frame:SetHeight(((DTB.db.profile.BarHeight + DTB.db.profile.BarSpacing) * 16) + DTB.db.profile.BarSpacing)
		end
	    else
		-- If we're not showing icons, don't widen the frame to accomodate them.
		if DTB.db.profile.HideIcons then
		    DTB.frame:SetWidth((DTB.db.profile.BarWidth + (DTB.db.profile.BarSpacing * 2)))
		else
		    -- Width of the bar, plus width of the icon, plus padding
		    DTB.frame:SetWidth((DTB.db.profile.BarWidth + DTB.db.profile.BarHeight + (DTB.db.profile.BarSpacing * 2)))
		end

		-- 16 bar slots
		DTB.frame:SetHeight(((DTB.db.profile.BarHeight + DTB.db.profile.BarSpacing) * 16) + (DTB.db.profile.BarSpacing + 2))
    end

    DTB.frame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })

    -- Make the frame 50% black if unlocked.
    if self.db.profile.FrameUnlocked then
		DTB.frame:SetBackdropColor(0,0,0,.5)
    else
		DTB.frame:SetBackdropColor(DTB.db.profile.FrameColor.r, DTB.db.profile.FrameColor.g, DTB.db.profile.FrameColor.b, DTB.db.profile.FrameColor.a)
    end

    DTB.frame:RegisterForDrag("LeftButton")
    DTB.frame:ClearAllPoints()
    DTB.frame:SetPoint(DTB.db.profile.point, DTB.db.profile.relativeTo, DTB.db.profile.relativePoint, DTB.db.profile.xOffset, DTB.db.profile.yOffset)

    DTB.frame:SetScript("OnDragStart",	function() if DTB.frame:IsMovable() then DTB.frame:StartMoving() end end)
    DTB.frame:SetScript("OnDragStop", function() DTB.frame:StopMovingOrSizing() DTB:SavePosition(DTB.db.profile, DTB.frame) end)

    DTB.frame:Show()
    DTB.frame:EnableMouse(true)
    DTB.frame:SetMovable(DTB.db.profile.FrameUnlocked)
    DTB.frame:EnableMouse(DTB.db.profile.FrameUnlocked)
end

-- Main loop. Check bars and update their progress, etc.
DTB.frame:SetScript("OnUpdate", function (self, elapsed)
    local i = 1
    local time = GetTime()
    local tmp, progress, timeleft
    local _,_,_,_,_,_,gcd = GetSpellInfo(8936) -- Check Regrowth's cast time to find our GCD
    gcd = gcd/1000

    -- OnUpdate throttle. We don't really need to check everything 60+ times a second.
    lastupdate = lastupdate + elapsed

    if lastupdate > .05 then
    	lastupdate = 0

		-- For config: If testbars is on, we want to redraw them so people can see
		-- color changes and such in realtime.
		if DTB.testbars then
		    DTB:ShowAllBars()
		end

		if DTB.db.profile.TrackEclipsePower and isBalance then
		    DTB:GetEclipsePower()
		end

		-- Scan our buffs for Eclipse, Savage Roar, etc.
		while UnitBuff("player",i) do
			local _,_,_,_,_,duration,expires,source,_,_,id = UnitBuff("player",i)

			if source == "player" then
				progress = ((expires - time) / duration) * 100
				timeleft = expires - time

				if DTB.db.profile.TrackEclipse and id == DTB.SolarEclipse.id then
					DTB:UpdateBar("SolarEclipse", DTB.SolarEclipse.name, 100, -1, id)
				elseif DTB.db.profile.TrackEclipse and id == DTB.LunarEclipse.id then
					DTB:UpdateBar("LunarEclipse", DTB.LunarEclipse.name, 100, -1, id)
				elseif DTB.db.profile.TrackStarfall and id == DTB.Starfall.id then
					if not DTB.Starfall.active then
						DTB.Starfall.active = GetTime()
					end
					DTB:UpdateBar("Starfall", DTB.Starfall.name, progress, timeleft, id)
				elseif DTB.db.profile.TrackSavageRoar and id == DTB.SavageRoar.id then
					DTB:UpdateBar("SavageRoar", DTB.SavageRoar.name, progress, timeleft, id)
				elseif DTB.db.profile.TrackOmenOfClarity and id == DTB.OmenOfClarity.id then
					DTB:UpdateBar("OmenOfClarity", DTB.OmenOfClarity.name, progress, timeleft, id)
				elseif DTB.db.profile.TrackTigersFury and id == DTB.TigersFury.id then
					DTB:UpdateBar("TigersFury", DTB.TigersFury.name, progress, timeleft, id)
				elseif DTB.db.profile.TrackNaturesGrace and id == DTB.NaturesGrace.id then
					DTB:UpdateBar("NaturesGrace", DTB.NaturesGrace.name, progress, timeleft, id)
				elseif DTB.db.profile.TrackBerserk and id == DTB.Berserk.id then
					DTB:UpdateBar("Berserk", DTB.Berserk.name, progress, timeleft, id)
				elseif DTB.db.profile.TrackBarkskin and id == DTB.Barkskin.id then
					DTB:UpdateBar("Barkskin", DTB.Barkskin.name, progress, timeleft, id)
				--else
				--	print("UnitBuff (player) id: " .. id .. " / expires:" .. expires .. " / source: " .. source .. " / duration: " .. duration)
				--	print("UnitBuff -------- name: " .. GetSpellInfo(id))
				end
			end

			i = i + 1
		end

		i = 1

		-- Scan all the debuffs on the current target for ones we care about that belong to us.
		while UnitDebuff("target",i) do
			local _,_,_,count,_,duration,expires,source,_,_,id = UnitDebuff("target",i)

			progress = ((expires - time) / duration) * 100
			timeleft = expires - time

			--print("UnitBuff (target) id: " .. id .. " / expires:" .. expires .. " / source: " .. source .. " / duration: " .. duration .. " / count: " .. count)
			--print("UnitBuff -------- name: " .. GetSpellInfo(id))

			if source == "player" then
				if DTB.db.profile.TrackSunfire and id == DTB.Sunfire.id then
				    DTB:UpdateBar("Sunfire",DTB.Sunfire.name,progress,timeleft,id)
				elseif DTB.db.profile.TrackMoonfire and id == DTB.Moonfire.id then
				    DTB:UpdateBar("Moonfire",DTB.Moonfire.name,progress,timeleft,id)
				elseif DTB.db.profile.TrackRake and id == DTB.Rake.id then
				    DTB:UpdateBar("Rake",DTB.Rake.name,progress,timeleft,id)
				elseif DTB.db.profile.TrackRake and id == DTB.Rake.id then
				    DTB:UpdateBar("Rake",DTB.Rake.name,progress,timeleft,id)
				elseif DTB.db.profile.TrackRip and id == DTB.Rip.id then
				    DTB:UpdateBar("Rip",DTB.Rip.name,progress,timeleft,id)
				elseif DTB.db.profile.TrackLacerate and id == DTB.Lacerate.id then
				    DTB:UpdateBar("Lacerate",DTB.Lacerate.name.." x "..count,progress,timeleft,id)
				end
		    end

		    -- Just look for Faerie Fire, Faerie Swarm, Weakened Armor and WeakenedBlows, we don't care whos it is.
		    if DTB.db.profile.TrackFaerieFire then
		    	if id == DTB.FaerieFire.id then
					DTB:UpdateBar("FaerieFire", DTB.FaerieFire.name, progress, timeleft, id)
				elseif id == DTB.FaerieSwarm.id then
					DTB:UpdateBar("FaerieFire", DTB.FaerieSwarm.name, progress, timeleft, id)
				end
		    end

		    -- Weakened Armor
		    if DTB.db.profile.TrackWeakenedArmor and id == DTB.WeakenedArmor.id then
		    	DTB:UpdateBar("WeakenedArmor", L["WEAKENEDARMOR"] .. " x " .. count, progress, timeleft, id)
		    end

		    if DTB.db.profile.TrackWeakenedBlows and (form == 1 or form == 3) and id == DTB.WeakenedBlows.id then
				DTB:UpdateBar("WeakenedBlows", L["WEAKENEDBLOWS"], progress, timeleft, id)
		    end

		    i = i + 1
		end

		-- For these abilities, we want to show a cooldown bar when the buff fades.
		if DTB.Starfall.cdend then DTB:CheckBarProgress("Starfall",time,0,0,nil) end
		if DTB.TigersFury.cdend then DTB:CheckBarProgress("TigersFury",time,0,0,nil) end
		if DTB.NaturesGrace.cdend then DTB:CheckBarProgress("NaturesGrace",time,0,nil,nil) end
		if DTB.Berserk.cdend then DTB:CheckBarProgress("Berserk",time,0,0,nil) end
		if DTB.Barkskin.cdend then DTB:CheckBarProgress("Barkskin",time,0,0,nil) end

		-- These abilities don't apply any buffs or debuffs we can track, so we have to check their cooldowns instead.
		if DTB.db.profile.TrackRebirth and DTB.Rebirth.used then DTB:CheckBarProgress("Rebirth",time,gcd,1,1) end
		if DTB.db.profile.TrackStarsurge and DTB.Starsurge.used then DTB:CheckBarProgress("Starsurge",time,gcd,1,1) end
		if DTB.db.profile.TrackForceofNature and DTB.ForceofNature.used then DTB:CheckBarProgress("ForceofNature",time,gcd,1,1) end
		if DTB.db.profile.TrackSolarBeam and DTB.SolarBeam.used then DTB:CheckBarProgress("SolarBeam",time,gcd,1,1) end
		if DTB.db.profile.TrackWildGrowth and DTB.WildGrowth.used then DTB:CheckBarProgress("WildGrowth",time,gcd,1,1) end
		if DTB.db.profile.TrackNaturesSwiftness and DTB.NaturesSwiftness.used then DTB:CheckBarProgress("NaturesSwiftness",time,gcd,1,1) end
		if DTB.db.profile.TrackSwiftmend and DTB.Swiftmend.used then DTB:CheckBarProgress("Swiftmend",time,gcd,1,1) end
		if DTB.db.profile.TrackTranquility and DTB.Tranquility.used then DTB:CheckBarProgress("Tranquility",time,gcd,1,1) end
		if DTB.db.profile.TrackTreeofLife and DTB.TreeofLife.used then DTB:CheckBarProgress("TreeofLife",time,gcd,1,1) end
		if DTB.db.profile.TrackInnervate and DTB.Innervate.used then DTB:CheckBarProgress("Innervate",time,gcd,1,1) end

		-- If we're tracking Starfall's range, we'll use it's bar when its not active.
		if DTB.Starfall.talented and DTB.db.profile.TrackStarfallRange and not DTB.Starfall.active and not DTB.Starfall.cdend
		   and UnitCanAttack("player","target") and form ~= 1 and form ~= 3 then
		    DTB:UpdateBar("Starfall",DTB.Starfall.name.." "..L["RANGE"],100,-1,DTB.Starfall.id)
		end

		-- Re-order the bars
		if DTB.resort then
			DTB:SortBars()
		end
	end
end)

-- Hide all bars on a target change.
function DTB:PLAYER_TARGET_CHANGED()
    playerTarget = UnitName("target")
    DTB:HideAllBars()
end

-- Hide all bars when shifting (for form specific bars)
function DTB:UPDATE_SHAPESHIFT_FORM()
    form = GetShapeshiftForm()

    DTB:HideAllBars()
end

-- Stuff to do on load.
function DTB:PLAYER_ENTERING_WORLD()
    playerGUID = UnitGUID("player")
    playerName = UnitName("player")
    playerLevel = UnitLevel("player")

    form = GetShapeshiftForm()

    -- We use Discombobulator Ray to check our distance from the target for Starfall.
    -- We need to make sure it's cached in our client before this check will work.
    if not GetItemInfo(4388) then
		GameTooltip:SetHyperlink("item:4388")
    end

    -- Create each bar here. This way, they're in the array in the order we want them
    -- to appear visually. Is there a better way to do this?
    DTB:ShowAllBars()
    DTB:HideAllBars()

    -- Wipe out the "test bar" cooldown models
    DTB:ResetCooldownModels()

    -- Check for certain talents
    DTB:ScanTalents()
end

-- Talents aren't available when PLAYER_ENTERING_WORLD fires, so we'll have to check here.
function DTB:PLAYER_ALIVE()
    DTB:ScanTalents()
    isBalance = DTB:IsBalance()

    -- We don't need this anymore
    DTB:UnregisterEvent("PLAYER_ALIVE")
end

-- Talent changes, check some stuff.
function DTB:PLAYER_TALENT_UPDATE()
	local _,_,_,_,starfall = GetTalentInfo(1,20,false)

	-- Check for Starfall, so we can hide the bar for people who aren't Balance at the moment.
	if starfall == 1 then
		DTB.Starfall.talented = true
	else
		DTB.Starfall.talented = nil
	end

	isBalance = DTB:IsBalance()

	DTB:HideAllBars()
end

-- Combat Log handler. We watch here for buffs/debuffs fading from us or our target.
function DTB:COMBAT_LOG_EVENT_UNFILTERED(_,_,event,_,sourceGUID,_,sourceFlags,_,_,destName,destFlags,_,spellID,...)
	-- Watch for our buffs and debuffs expiring.
	if sourceGUID == playerGUID and event == "SPELL_AURA_REMOVED" then
		-- Self buffs
		if destName == playerName then
			if DTB.db.profile.TrackEclipse and spellID == DTB.SolarEclipse.id then
				DTB:HideBar("SolarEclipse")
			elseif DTB.db.profile.TrackEclipse and spellID == DTB.LunarEclipse.id then
				DTB:HideBar("LunarEclipse")
			elseif DTB.db.profile.TrackStarfall and spellID == DTB.Starfall.id then
				DTB.Starfall.cdend = GetTime() + DTB.Starfall.cd

				-- If Starsurge was cast while Starfall was active, it reduced the cooldown of Starfall.
				-- Because of how we track cooldowns, we need to apply these reductions now.
				if DTB.Starfall.surges then
					DTB.Starfall.cdend = DTB.Starfall.cdend - (DTB.Starfall.surges * 5)
					DTB.Starfall.surges = 0
					DTB.Starfall.cdm = -1
					DTB.Starfall.cdms = nil
				end

				DTB.Starfall.active = nil
			elseif spellID == DTB.SavageRoar.id then
				DTB:HideBar("SavageRoar")
			elseif spellID == DTB.OmenOfClarity.id then
				DTB:HideBar("OmenOfClarity")
			elseif DTB.db.profile.TrackTigersFury and spellID == DTB.TigersFury.id then
				DTB.TigersFury.cdend = GetTime() + DTB.TigersFury.cd
			elseif DTB.db.profile.TrackNaturesGrace and spellID == DTB.NaturesGrace.id then
				DTB.NaturesGrace.cdend = GetTime() + DTB.NaturesGrace.cd
			elseif DTB.db.profile.TrackBerserk and spellID == DTB.Berserk.id then
				DTB.Berserk.cdend = GetTime() + DTB.Berserk.cd
			elseif DTB.db.profile.TrackBarkskin and spellID == DTB.Barkskin.id then
				DTB.Barkskin.cdend = GetTime() + DTB.Barkskin.cd
			end
		end

		-- Debuffs on our target
		if destName == playerTarget then
			if spellID == DTB.Moonfire.id then
				DTB:HideBar("Moonfire")
			elseif spellID == DTB.Sunfire.id then
				DTB:HideBar("Sunfire")
			elseif spellID == DTB.Rake.id then
				DTB:HideBar("Rake")
			elseif spellID == DTB.Rip.id then
				DTB:HideBar("Rip")
			elseif spellID == DTB.Lacerate.id then
				DTB:HideBar("Lacerate")
			end
		end
	end

	-- Spells we want to track the cooldown of after casting
	if sourceGUID == playerGUID then
		if spellID == DTB.Starsurge.id then
			if event == "SPELL_MISS" or event == "SPELL_DAMAGE" then
				DTB.Starsurge.used = 1
			end
		end

		if event == "SPELL_CAST_SUCCESS" then
			if spellID == DTB.WildGrowth.id then
				DTB.WildGrowth.used = 1
			elseif spellID == DTB.NaturesSwiftness.id then
				DTB.NaturesSwiftness.used = 1
			elseif spellID == DTB.Swiftmend.id then
				DTB.Swiftmend.used = 1
			elseif spellID == DTB.Rebirth.id then
				DTB.Rebirth.used = 1
			elseif spellID == DTB.Tranquility.id then
				DTB.Tranquility.used = 1
			elseif spellID == DTB.TreeofLife.id then
				DTB.TreeofLife.used = 1
			elseif spellID == DTB.ForceofNature.id then
				DTB.ForceofNature.used = 1
			elseif spellID == DTB.SolarBeam.id then
				DTB.SolarBeam.used = 1
			elseif spellID == DTB.Innervate.id then
				DTB.Innervate.used = 1
			end
		end

		if event == "SPELL_RESURRECT" then
			if spellID == DTB.Rebirth.id then
				DTB.Rebirth.used = 1
			end
		end
	end

	-- We track these debuffs regardless of who applied them.
	if destName == playerTarget and event == "SPELL_AURA_REMOVED" then
		if spellID == DTB.WeakenedBlows.id then
			DTB:HideBar("WeakenedBlows")
		elseif spellID == DTB.FaerieFire.id then
			DTB:HideBar("FaerieFire")
		elseif spellID == DTB.WeakenedArmor.id then
			DTB:HideBar("WeakenedArmor")
		end
	end
end

-- Mouseover, create a tooltip
local function OnEnter(self)
    local name = GetSpellInfo(self.spellID)

    GameTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")

    -- Special case: Custom tooltip for Eclipse Power.
    if self:GetName() == "EclipsePower" then
	local power = UnitPower("player",8)
	local type = "Solar"

	if power and power < 0 then
	    power = power - (power*2)
	    type = "Lunar"
	end

	GameTooltip:ClearLines()
	GameTooltip:AddLine("|cffffffff"..L["ECLIPSE_POWER"])
	GameTooltip:AddLine("|cffffd200"..L[strupper(type).."_POWER"]..power.."%")
    elseif UnitAura("player",GetSpellInfo(self.spellID)) then -- Is it a buff?
	for i=1,40 do
	    if UnitAura("player",i) == name then
		GameTooltip:SetUnitAura("player",i)
		break
	    end
	end
    elseif UnitAura("target",GetSpellInfo(self.spellID),nil,"HARMFUL") then -- Is it a debuff?
	for i=1,40 do
	    if UnitAura("target",i,"HARMFUL") == name then
		GameTooltip:SetUnitAura("target",i,"HARMFUL")
		break
	    end
	end
    else
	GameTooltip:SetHyperlink(GetSpellLink(self.spellID))
    end

    GameTooltip:Show()
end

-- Mouse left the frame, hide the tooltip
local function OnLeave(self)
    GameTooltip:Hide()
end

-- Update/create a bar
function DTB:UpdateBar(name,text,progress,timeleft,spellID)
    local tmpalpha = DTB.db.profile[name].a
    local tmptype = DTB.db.profile[name]

    newBar = DTB:GetBar(name,spellID)

    -- Only show our cooldown label if we're not using Blizzards
    if timeleft and ((DTB.db.profile.IconOnly and not DTB.db.profile.CooldownModel) or not DTB.db.profile.IconOnly) then
	newBar.dshadow:SetText(DTB:Duration(timeleft))
	newBar.duration:SetText(DTB:Duration(timeleft))
    else
	newBar.dshadow:SetText()
	newBar.duration:SetText()
    end

    -- Swap the Eclipse Power icons
    if name == "EclipsePower" then
	local power = UnitPower("player",8)

	if (power == 100 and powericon == 2) or ((powericon == 0 and power ~=0) and power < 0) then
	    newBar.icon:SetBackdrop({bgFile = "Interface\\Addons\\DruidTimerBars\\img\\solarpower.tga"})
	    powericon = 1
	elseif power == -100 and powericon == 1 or ((powericon == 0 and power ~=0) and power > 0)  then
	    newBar.icon:SetBackdrop({bgFile = "Interface\\Addons\\DruidTimerBars\\img\\lunarpower.tga"})
	    powericon = 2
	end

	if powericon == 1 then
	    tmpalpha = DTB.db.profile.SolarEclipse.a
	    tmptype = DTB.db.profile.SolarEclipse
	else
	    tmpalpha = DTB.db.profile.LunarEclipse.a
	    tmptype = DTB.db.profile.LunarEclipse
	end
    end

    if DTB.db.profile.IconOnly then
	-- Default
	newBar.icon:SetBackdropColor(1,1,1,1)

	-- Check the cooldown model
	if DTB.db.profile.CooldownModel then
	    local time = GetTime()

	    -- Show the cooldown model, unless it's the Starfall Range finder.
	    if not text == DTB.Starfall.name.." "..L["RANGE"] then
		newBar.cooldown:Show()
	    end

	    if DTB[name] and timeleft > 0 then
		DTB:CheckCooldownModel(name,time,timeleft)
	    end

	    -- Start the cooldown model if needed
	    if DTB[name] and DTB[name].cdm and DTB[name].cdm > 0 and not DTB[name].cdms then
		newBar.cooldown:SetCooldown(time,(DTB[name].cdm-time))
		newBar.cooldown:SetReverse(true)
		DTB[name].cdms = true
	    end
	end

	-- For cooldown bars, we'll make them semi transparent.
	if (name == "Starfall" and DTB.Starfall.cdend) or
	   (name == "TigersFury" and DTB.TigersFury.cdend) or
	   (name == "NaturesGrace" and DTB.NaturesGrace.cdend) or
	   (name == "Berserk" and DTB.Berserk.cdend) or
	   (name == "Barkskin" and DTB.Barkskin.cdend) or
	   (name == "NaturesSwiftness" and DTB.NaturesSwiftness.cdend) or
	   (name == "TreeOfLife" and DTB.TreeOfLife.cdend) or
	   (name == "Innervate" and DTB.Innervate.cdend) then
	    newBar.icon:SetBackdropColor(.75,.75,.75,.75)
	end

	-- While we want to ignore the label for most bars, we do want to
	-- show a few things.
	if name == "Lacerate" then
	    newBar.shadow:SetText(strsub(text,-1))
	    newBar.label:SetText(strsub(text,-1))
	elseif name == "FaerieFire" then
	    newBar.shadow:SetText(strsub(text,-1))
	    newBar.label:SetText(strsub(text,-1))
	elseif name == "EclipsePower" then
	    local power = UnitPower("player",8)

	    if power < 0 then
		power = power - (power*2)
	    end

	    newBar.dshadow:SetText(power.."%")
	    newBar.duration:SetText(power.."%")
	    newBar.shadow:SetText()
	    newBar.label:SetText()
	else
	    newBar.shadow:SetText()
	    newBar.label:SetText()
	end

	-- Special case: We want to make the Starfall icon red if it's out of range.
	if name == "Starfall" and DTB:CheckStarfallRange() ~= 1 then
	    newBar.icon:SetBackdropColor(1,0,0,1)
	end
    else
	if DTB.db.profile.HideIcons then
	    newBar.icon:Hide()
	end

	-- For cooldown bars, we'll make them semi transparent.
	if (name == "Starfall" and DTB.Starfall.cdend) or
	   (name == "TigersFury" and DTB.TigersFury.cdend) or
	   (name == "NaturesGrace" and DTB.NaturesGrace.cdend) or
	   (name == "Berserk" and DTB.Berserk.cdend) or
	   (name == "Barkskin" and DTB.Barkskin.cdend) or
	   (name == "NaturesSwiftness" and DTB.NaturesSwiftness.cdend) or
	   (name == "TreeOfLife" and DTB.TreeOfLife.cdend) or
	   (name == "Innervate" and DTB.Innervate.cdend) then
	    tmpalpha = (tmpalpha / 1.33)
	end

	-- Special case: We want to make the Starfall bar red if it's out of range.
	if name == "Starfall" and DTB:CheckStarfallRange() ~= 1 then
	    newBar:SetStatusBarColor(1, (tmptype.g/2), (tmptype.b/2), tmpalpha)
	else
	    newBar:SetStatusBarColor(tmptype.r, tmptype.g, tmptype.b, tmpalpha)
	end

	newBar.shadow:SetText(text)
	newBar.label:SetText(text)

	newBar.spark:ClearAllPoints()
	newBar.spark:SetPoint("LEFT",newBar,"LEFT",progress/100*DTB.db.profile.BarWidth-5,0)
	newBar:SetValue(progress)

	-- Hide the spark for full bars.
	if progress == 100 then
	    newBar.spark:Hide()
	else
	    newBar.spark:Show()
	end
    end
end

-- Return a pointer to a bar. If we've already made the
-- bar we want, re-use it, otherwise make a new one.
function DTB:GetBar(name,spellID)
    -- Have we already made this bar?
    for i,v in ipairs(DTB.barList) do
	if v:GetName() == name then
	    if not v:IsVisible() then
		DTB.visibleBars = DTB.visibleBars + 1

		v:Show()
		v.icon:Show()

		DTB.resort = true
	    end

	    return v
	end
    end

    -- If we get here, we didn't find the bar we wanted, so make a new one.
    barIndex = barIndex + 1

    local newBar = DTB.barList[barIndex]
    newBar = CreateFrame("StatusBar", name, DTB.frame)

    -- Create all the portions of the bar
    newBar.icon = CreateFrame("Frame", name.."Icon", DTB.frame)
    newBar.cooldown = CreateFrame("Cooldown", name.."Cooldown", newBar.icon)
    newBar.cooldown:SetAllPoints(newBar.icon)
    newBar.dshadow = newBar:CreateFontString(nil,"OVERLAY")
    newBar.duration = newBar:CreateFontString(nil,"OVERLAY")
    newBar.shadow = newBar:CreateFontString(nil,"OVERLAY")
    newBar.label = newBar:CreateFontString(nil,"OVERLAY")
    newBar.spark = newBar:CreateTexture(nil, "OVERLAY")

    -- Icon stuff
    newBar.icon:SetWidth(DTB.db.profile.BarHeight)
    newBar.icon:SetHeight(DTB.db.profile.BarHeight)
    newBar.icon:SetBackdropColor(1,1,1,1)

    -- Special case: We want to use a custom icon for Eclipse Power instead of an in game one.
    if newBar:GetName() == "EclipsePower" then
	if self.db.profile.LastEclipse == 1 then
	    newBar.icon:SetBackdrop({bgFile = "Interface\\Addons\\DruidTimerBars\\img\\solarpower.tga"})
	    powericon = 1
	else
	    newBar.icon:SetBackdrop({bgFile = "Interface\\Addons\\DruidTimerBars\\img\\lunarpower.tga"})
	    powericon = 2
	end
    else
	local _,_,icon = GetSpellInfo(spellID)
	newBar.icon:SetBackdrop({bgFile = icon})
    end

    -- Set the spellID for tooltips
    newBar.spellID = spellID
    newBar.icon.spellID = spellID

    -- Tooltips
    newBar:EnableMouse(true)
    newBar:SetScript("OnEnter", OnEnter)
    newBar:SetScript("OnLeave", OnLeave)
    newBar.icon:EnableMouse(true)
    newBar.icon:SetScript("OnEnter", OnEnter)
    newBar.icon:SetScript("OnLeave", OnLeave)

    if DTB.db.profile.IconOnly then
	newBar.icon:SetPoint("CENTER", name, "CENTER")
    else
	newBar.icon:SetPoint("RIGHT", name, "LEFT", -3, 0)
    end

    DTB:CreateBar(newBar)

    DTB.barList[barIndex] = newBar

    return newBar
end

-- (Re)set the entire bar.
function DTB:CreateBar(newBar)
    newBar:SetHeight(DTB.db.profile.BarHeight)
    newBar:SetParent(DTB.frame)
    newBar:SetMinMaxValues(0,100)

    -- Show icons only. We'll scale the icons based on height alone, and overlay the duration on the icon.
    if DTB.db.profile.IconOnly then
	newBar:SetWidth(DTB.db.profile.BarHeight)

	-- Duration backdrop
	newBar.dshadow:SetTextColor(0,0,0,1)

	-- Special case: We want the Eclipse Power text centered on its icon, and slightly smaller so it fits.
	if newBar:GetName() == "EclipsePower" then
	    newBar.dshadow:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/2.5))
	    newBar.dshadow:ClearAllPoints()
	    newBar.dshadow:SetPoint("CENTER", newBar.icon,"CENTER", 1, -1)
	else
	    newBar.dshadow:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/2))
	    newBar.dshadow:ClearAllPoints()
	    newBar.dshadow:SetPoint("TOPLEFT", newBar.icon,"TOPLEFT", 3, -3)
	end

	-- Duration
	newBar.duration:SetTextColor(DTB.db.profile.FontColor.r,DTB.db.profile.FontColor.g,DTB.db.profile.FontColor.b,DTB.db.profile.FontColor.a)

	-- Special case: We want the Eclipse Power text centered on its icon, and slightly smaller so it fits.
	if newBar:GetName() == "EclipsePower" then
	    newBar.duration:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/2.5))
	    newBar.duration:ClearAllPoints()
	    newBar.duration:SetPoint("CENTER", newBar.icon,"CENTER", 0, 0)
	else
	    newBar.duration:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/2))
	    newBar.duration:ClearAllPoints()
	    newBar.duration:SetPoint("TOPLEFT", newBar.icon,"TOPLEFT", 2, -2)
	end

	-- Text backdrop
	newBar.shadow:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/2.5))
	newBar.shadow:SetTextColor(0,0,0,.75)
	newBar.shadow:ClearAllPoints()
	newBar.shadow:SetPoint("BOTTOMRIGHT", newBar.icon, "BOTTOMRIGHT", -4.5, 4.5)

	-- Label
	newBar.label:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/2.5))
	newBar.label:SetTextColor(DTB.db.profile.FontColor.r,DTB.db.profile.FontColor.g,DTB.db.profile.FontColor.b,DTB.db.profile.FontColor.a)
	newBar.label:ClearAllPoints()
	newBar.label:SetPoint("BOTTOMRIGHT", newBar.icon, "BOTTOMRIGHT", -4, 4)
    else
	newBar:SetWidth(DTB.db.profile.BarWidth)
	newBar:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
	newBar:SetStatusBarTexture(M:Fetch("statusbar",M:List("statusbar")[DTB.db.profile.BarTexture]))
	newBar:SetBackdropColor(0,0,0,1)

	-- Duration backdrop
	newBar.dshadow:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/1.3))
	newBar.dshadow:SetTextColor(0,0,0,.75)
	newBar.dshadow:ClearAllPoints()
	newBar.dshadow:SetPoint("RIGHT", newBar, "RIGHT", -6, -1)

	-- Duration
	newBar.duration:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/1.3))
	newBar.duration:SetTextColor(DTB.db.profile.FontColor.r,DTB.db.profile.FontColor.g,DTB.db.profile.FontColor.b,DTB.db.profile.FontColor.a)
	newBar.duration:ClearAllPoints()
	newBar.duration:SetPoint("RIGHT",newBar,"RIGHT", -5, 0)

	-- Text backdrop
	newBar.shadow:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/1.3))
	newBar.shadow:SetTextColor(0,0,0,.75)
	newBar.shadow:ClearAllPoints()
	newBar.shadow:SetPoint("LEFT", newBar, "LEFT", 6, -1)

	-- Label
	newBar.label:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/1.3))
	newBar.label:SetTextColor(DTB.db.profile.FontColor.r,DTB.db.profile.FontColor.g,DTB.db.profile.FontColor.b,DTB.db.profile.FontColor.a)
	newBar.label:ClearAllPoints()
	newBar.label:SetPoint("LEFT", newBar, "LEFT", 5, 0)
    end

    -- Spark
    newBar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    newBar.spark:SetWidth(10)
    newBar.spark:SetBlendMode("ADD")
end

-- Sort the bars. 
function DTB:SortBars()
    if DTB.db.profile.BarSortingStyle == "Collapse" then
	local j, x, y, slot = 0, 0, 0, 0

	-- When centering, we want the icon stack to remain centered. We achieve this by anchoring from
	-- center, then offsetting by half the width of the visible icons. This moves the stack over
	-- so it remains centered on the frame.
	if DTB.db.profile.GrowFrom == "CENTER" then
	    y = ((DTB.db.profile.BarHeight + DTB.db.profile.BarSpacing) * (DTB.visibleBars + 1) / 2)
	end

	for i,v in ipairs(DTB.barList) do
	    if v:IsVisible() then
		slot = (j * (DTB.db.profile.BarHeight + DTB.db.profile.BarSpacing)) + DTB.db.profile.BarSpacing
		j = j + 1

		v:ClearAllPoints()

		if DTB.db.profile.GrowFrom == "BOTTOMLEFT" then
		    y = slot
		elseif DTB.db.profile.GrowFrom == "CENTER" then
		    y = y - (DTB.db.profile.BarHeight + DTB.db.profile.BarSpacing)
		elseif DTB.db.profile.GrowFrom == "BOTTOMRIGHT" then
		    y = slot - (slot * 2)
		end

		if DTB.db.profile.IconOnly then
		    if not DTB.db.profile.IconRow and not (DTB.db.profile.GrowFrom == "CENTER") then
			x = DTB.db.profile.BarSpacing
		    end
		else
		    if DTB.db.profile.HideIcons then
			x = DTB.db.profile.BarSpacing
		    else
			x = DTB.db.profile.BarHeight + DTB.db.profile.BarSpacing + 1
		    end
		end

		if DTB.db.profile.IconOnly and DTB.db.profile.IconRow then
		    v:SetPoint(DTB:GetAnchor(), DTB.frame, y, x)
		else
		    v:SetPoint(DTB:GetAnchor(), DTB.frame, x, y)
		end
	    end
	end
    else
	for i,v in ipairs(DTB.barList) do
	    if v:IsVisible() then
		slot = (DTB.db.profile.Sorting[v:GetName()] * (DTB.db.profile.BarHeight + DTB.db.profile.BarSpacing)) + DTB.db.profile.BarSpacing

		v:ClearAllPoints()

		if DTB.db.profile.GrowFrom == "BOTTOMLEFT" or DTB.db.profile.GrowFrom == "CENTER" then
		    y = slot
		elseif DTB.db.profile.GrowFrom == "BOTTOMRIGHT" then
		    y = slot - (slot * 2)
		end

		if DTB.db.profile.IconOnly then
		    if DTB.db.profile.IconRow then
			x = 0
		    else
			x = DTB.db.profile.BarSpacing
		    end
		else
		    if DTB.db.profile.HideIcons then
			x = DTB.db.profile.BarSpacing
		    else
			x = DTB.db.profile.BarHeight + DTB.db.profile.BarSpacing + 1
		    end
		end

		if DTB.db.profile.IconOnly and DTB.db.profile.IconRow then
		    v:SetPoint(DTB:GetAnchor(), DTB.frame, y, x)
		else
		    v:SetPoint(DTB:GetAnchor(), DTB.frame, x, y)
		end
	    end
	end
    end

    DTB.resort = nil
end

-- Return the proper anchor point for bars/icons
function DTB:GetAnchor()
    if not DTB.db.profile.IconOnly then
	if DTB.db.profile.GrowFrom == "CENTER" then
	    return "LEFT"
	elseif DTB.db.profile.GrowFrom == "BOTTOMRIGHT" then
	    return "TOPLEFT"
	end
    else
	if not DTB.db.profile.IconRow then
	    if DTB.db.profile.GrowFrom == "BOTTOMRIGHT" then
		return "TOPLEFT"
	    end

	    return DTB.db.profile.GrowFrom
	end
	if DTB.db.profile.GrowFrom == "BOTTOMLEFT" then
	    return "LEFT"
	elseif DTB.db.profile.GrowFrom == "BOTTOMRIGHT" then
	    return "RIGHT"
	end
    end

    return DTB.db.profile.GrowFrom
end

-- Show every bar. This is used on startup to create the bars, and when using the
-- Show Test Bars button.
function DTB:ShowAllBars()
    DTB:UpdateBar("FaerieFire",DTB.FaerieFire.name.." x ".."3",100,-1,DTB.FaerieFire.id)
    DTB:UpdateBar("Moonfire",DTB.Moonfire.name,100,-1,DTB.Moonfire.id)
    DTB:UpdateBar("Sunfire",DTB.Sunfire.name,100,-1,DTB.Sunfire.id)
    DTB:UpdateBar("SolarEclipse",DTB.SolarEclipse.name,100,-1,DTB.SolarEclipse.id)
    DTB:UpdateBar("LunarEclipse",DTB.LunarEclipse.name,100,-1,DTB.LunarEclipse.id)
    DTB:UpdateBar("Starfall",DTB.Starfall.name,100,-1,DTB.Starfall.id)
    DTB:UpdateBar("Starsurge",DTB.Starsurge.name,100,-1,DTB.Starsurge.id)
    DTB:UpdateBar("ForceofNature",DTB.ForceofNature.name,100,-1,DTB.ForceofNature.id)
    DTB:UpdateBar("SolarBeam",DTB.SolarBeam.name,100,-1,DTB.SolarBeam.id)
    DTB:UpdateBar("Innervate",DTB.Innervate.name,100,-1,DTB.Innervate.id)
    DTB:UpdateBar("OmenOfClarity",DTB.OmenOfClarity.name,100,-1,DTB.OmenOfClarity.id)
	DTB:UpdateBar("WeakenedBlows",L["WEAKENEDBLOWS"],100,-1,DTB.WeakenedBlows.id)
	DTB:UpdateBar("WeakenedArmor",L["WEAKENEDARMOR"],100,-1,DTB.WeakenedArmor.id)
    DTB:UpdateBar("Lacerate",DTB.Lacerate.name.." x ".."1",100,-1,DTB.Lacerate.id)
    DTB:UpdateBar("Rake",DTB.Rake.name,100,-1,DTB.Rake.id)
    DTB:UpdateBar("Rip",DTB.Rip.name,100,-1,DTB.Rip.id)
    DTB:UpdateBar("Berserk",DTB.Berserk.name,100,-1,DTB.Berserk.id)
    DTB:UpdateBar("TigersFury",DTB.TigersFury.name,100,-1,DTB.TigersFury.id)
    DTB:UpdateBar("SavageRoar",DTB.SavageRoar.name,100,-1,DTB.SavageRoar.id)
    DTB:UpdateBar("Barkskin",DTB.Barkskin.name,100,-1,DTB.Barkskin.id)
    DTB:UpdateBar("NaturesGrace",DTB.NaturesGrace.name,100,-1,DTB.NaturesGrace.id)
    DTB:UpdateBar("Rebirth",DTB.Rebirth.name,100,-1,DTB.Rebirth.id)
    DTB:UpdateBar("WildGrowth",DTB.WildGrowth.name,100,-1,DTB.WildGrowth.id)
    DTB:UpdateBar("NaturesSwiftness",DTB.NaturesSwiftness.name,100,-1,DTB.NaturesSwiftness.id)
    DTB:UpdateBar("Swiftmend",DTB.Swiftmend.name,100,-1,DTB.Swiftmend.id)
    DTB:UpdateBar("Tranquility",DTB.Tranquility.name,100,-1,DTB.Tranquility.id)
    DTB:UpdateBar("TreeofLife",DTB.TreeofLife.name,100,-1,DTB.TreeofLife.id)
    DTB:UpdateBar("EclipsePower",L["SOLAR_POWER"]..100,100,nil,DTB.SolarEclipse.id)
end

-- Hide a specific bar
function DTB:HideBar(name)
    for i,v in ipairs(DTB.barList) do
	-- We check if it's visible here to keep visibleBars correct.
	if v:GetName() == name and v:IsVisible() then
	    DTB.visibleBars = DTB.visibleBars - 1

	    -- Reset the cooldown model if it has one
	    if DTB[name] and DTB[name].cdm and DTB[name].cdm > 0 then
		DTB[name].cdm = -1
		DTB[name].cdms = nil
	    end

	    v:Hide()
	    v.icon:Hide()
	    v.cooldown:Hide()

	    DTB.resort = true
	end
    end

    -- Re-order the bars
    if DTB.visibleBars > 0 then
	DTB:SortBars()
    end
end

-- Hide all bars
function DTB:HideAllBars()
    DTB.visibleBars = 0

    for i,v in ipairs(DTB.barList) do
	local name = v:GetName()

	v:Hide()
	v.icon:Hide()
	v.cooldown:Hide()

	DTB.resort = true
    end
end

-- Check the progress of the bar and update or hide it as needed.
function DTB:CheckBarProgress(name, time, gcd, activated, cd)
    local tmp

    if activated then
		local start,duration = GetSpellCooldown(DTB[name].id)
		tmp = start + duration - time
    else
		tmp = DTB[name].cdend - time
    end

    if tmp > gcd then
		if cd then
		    DTB[name].oncd = 1
		end

		progress = (tmp / DTB[name].cd) * 100
		DTB:UpdateBar(name, DTB[name].name.." "..L["COOLDOWN"], progress, tmp, DTB[name].id)
    else
		if cd and DTB[name].oncd then
	    	DTB[name].oncd = nil
	    	DTB[name].used = nil
		else
	    	DTB[name].cdend = nil
		end

		DTB:HideBar(name)
    end
end

-- Check for certain talents.
function DTB:ScanTalents()
    -- Defaults
    DTB.Starfall.talented = nil

    local _,_,_,_,starfall = GetTalentInfo(1,18,false)

    if starfall == 1 then
		DTB.Starfall.talented = true
    end
end

-- Check if the player is Balance.
function DTB:IsBalance()
    if GetSpecialization() == 1 then
		return true
    end

    return false
end


-- Check if Starfall is in range from our target. Since Starfall has no
-- conventional range, we'll check Moonfire's range.
function DTB:CheckStarfallRange()
    local inrange

    inrange = IsSpellInRange(DTB.Moonfire.name, "target")

    return inrange
end

-- Update the Eclipse Power bar
function DTB:GetEclipsePower()
    -- Negative values are building towards a Lunar Eclipse, while positive values
    -- build towards a Solar Eclipse.
    if isBalance then
	local power = UnitPower("player",8)

	if power > 0 then
	    DTB:UpdateBar("EclipsePower", L["SOLAR_POWER"]..power.."%", power, nil, DTB.SolarEclipse.id)
	elseif power < 0 then
	    DTB:UpdateBar("EclipsePower", L["LUNAR_POWER"]..power-(power*2).."%",power-(power*2),nil,DTB.LunarEclipse.id)
	else
	    DTB:UpdateBar("EclipsePower", L["SOLAR_POWER"]..power.."%",power,nil,DTB.SolarEclipse.id)
	end

	-- Track which Eclipse we procced last, also reset the CD on Nature's Grace.
	if power == 100 then
	    self.db.profile.LastEclipse = 1
	    DTB.NaturesGrace.cdend = nil
	    DTB:HideBar("NaturesGrace")
	elseif power == -100 then
	    self.db.profile.LastEclipse = 2
	    DTB.NaturesGrace.cdend = nil
	    DTB:HideBar("NaturesGrace")
	end
    end
end

-- Start/restart the cooldown model
function DTB:CheckCooldownModel(name,time,timeleft)
    local cdend = time + timeleft

    if DTB[name].cdm and ceil(DTB[name].cdm) < cdend then
	DTB[name].cdm = cdend
	DTB[name].cdms = nil
    end
end

-- Reset the cooldown models
function DTB:ResetCooldownModels()
    for i,v in ipairs(DTB.barList) do
	local name = v:GetName()

	if DTB[name] and DTB[name].cdm and DTB[name].cdm > 0 then
	    DTB[name].cdm = -1
	    DTB[name].cdms = nil
	end
    end
end

-- Format a time value into something more useful.
function DTB:Duration(value)
    -- Hide negative values.
    if value < 0 then
		return nil
    end

    -- For icons, space is at a premium, so we'll lose the precision.
    if DTB.db.profile.IconOnly then
		if value >= 60 then
		    return ("%dm"):format(ceil(value/60))
		end

		return ("%d"):format(floor(value))
    else
		if value >= 60 then
		    return ("%dm %1.1fs"):format((value/60),(value%60))
		end

		return ("%1.1fs"):format(value)
    end
end
