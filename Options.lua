--
-- DruidTimerBars - Druid ability and debuff tracker
-- Options - Stuff for the options panel, addon defaults.
-- Gilbert - Tichondrius US
--

-- Stop now if the player isn't a Druid.
if select(2, UnitClass('player')) ~= "DRUID" then
    DisableAddOn("DTB")
    return
end

local L = LibStub("AceLocale-3.0"):GetLocale("DTB")
local M = LibStub:GetLibrary("LibSharedMedia-3.0")

local barslots = { [0]="Slot 1",[1]="Slot 2",[2]="Slot 3",[3]="Slot 4",[4]="Slot 5",
		   [5]="Slot 6",[6]="Slot 7",[7]="Slot 8",[8]="Slot 9",[9]="Slot 10",
		   [10]="Slot 11",[11]="Slot 12",[12]="Slot 13",[13]="Slot 14",[14]="Slot 15",[15]="Slot 16" }

-- Options table
function DTB:Options()
    local options	= {
	name		= L["OPTIONS_HEADER"] .. " - v2.2.0",
	handler		= DTB,
	type		= "group",
	childGroups	= "tree",
	args		= {
	    balanceoptions	= {
		name		= L["BALANCE_OPTIONS"],
		handler		= DTB,
		type		= "group",
		childGroups	= "tab",
		order		= 0,
		args		= {
		    balancebars	= {
			name		= L["TOGGLE_BARS"],
			handler		= DTB,
			type		= "group",
			order		= 0,
			args		= {
			    trackstarfall	= {
				type	= "toggle",
				name	= DTB.Starfall.name,
				desc	= L["D_TRACKSTARFALL"],
				order	= 1,
				get	= function (info,value) return self.db.profile.TrackStarfall end,
				set	= function (info,value) self.db.profile.TrackStarfall = value self:HideAllBars() end,
			    },
			    trackstarsurge	= {
				type	= "toggle",
				name	= DTB.Starsurge.name,
				desc	= L["D_TRACKSTARSURGE"],
				order	= 2,
				get	= function (info,value) return self.db.profile.TrackStarsurge end,
				set	= function (info,value) self.db.profile.TrackStarsurge = value self:HideAllBars() end,
			    },
			    tracktreants	= {
				type	= "toggle",
				name	= DTB.ForceofNature.name,
				desc	= L["D_TRACKTREANTS"],
				order	= 3,
				get	= function (info,value) return self.db.profile.TrackForceofNature end,
				set	= function (info,value) self.db.profile.TrackForceofNature = value self:HideAllBars() end,
			    },
			    tracksolarbeam	= {
				type	= "toggle",
				name	= DTB.SolarBeam.name,
				desc	= L["D_TRACKSOLARBEAM"],
				order	= 4,
				get	= function (info,value) return self.db.profile.TrackSolarBeam end,
				set	= function (info,value) self.db.profile.TrackSolarBeam = value self:HideAllBars() end,
			    },
			    trackmoonfire	= {
				type	= "toggle",
				name	= DTB.Moonfire.name,
				desc	= L["D_TRACKMOONFIRE"],
				order	= 5,
				get	= function (info,value) return self.db.profile.TrackMoonfire end,
				set	= function (info,value) self.db.profile.TrackMoonfire = value self:HideAllBars() end,
			    },
			    tracksunfire	= {
				type	= "toggle",
				name	= DTB.Sunfire.name,
				desc	= L["D_TRACKSUNFIRE"],
				order	= 6,
				get	= function (info,value) return self.db.profile.TrackSunfire end,
				set	= function (info,value) self.db.profile.TrackSunfire = value self:HideAllBars() end,
			    },
			    starfallrange	= {
				type	= "toggle",
				name	= DTB.Starfall.name.." "..L["RANGE"],
				desc	= L["D_TRACKSFRANGE"],
				order	= 7,
				get	= function (info,value) return self.db.profile.TrackStarfallRange end,
				set	= function (info,value) self.db.profile.TrackStarfallRange = value self:HideAllBars() end,
			    },
			    trackeclipse	= {
				type	= "toggle",
				name	= L["ECLIPSE"],
				desc	= L["D_TRACKECLIPSE"],
				order	= 7,
				get	= function (info,value) return self.db.profile.TrackEclipse end,
				set	= function (info,value) self.db.profile.TrackEclipse = value self:HideAllBars() end,
			    },
			    eclipsepower	= {
				type	= "toggle",
				name	= L["ECLIPSE_POWER"],
				desc	= L["D_TRACKECLIPSEPOWER"],
				order	= 8,
				get	= function (info,value) return self.db.profile.TrackEclipsePower end,
				set	= function (info,value) self.db.profile.TrackEclipsePower = value self:HideAllBars() end,
			    },
			    eclipseframe	= {
				type	= "toggle",
				name	= L["ECLIPSE_FRAME"],
				desc	= L["D_SHOWECLIPSEFRAME"],
				order	= 9,
				get	= function (info,value) return self.db.profile.ShowEclipseFrame end,
				set	= function (info,value) self.db.profile.ShowEclipseFrame = value self:SetEclipseFrame() end,
			    },
			},
		    },
		    balancecolors = {
			name		= L["COLORS"],
			handler		= DTB,
			type		= "group",
			order		= 1,
			args		= {
			    Starfall= {
				type	= "color",
				name	= DTB.Starfall.name,
				desc	= DTB.Starfall.name .. L["D_COLOR"],
				order	= 1,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    Starsurge	= {
				type	= "color",
				name	= DTB.Starsurge.name,
				desc	= DTB.Starsurge.name .. L["D_COLOR"],
				order	= 2,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    ForceofNature	= {
				type	= "color",
				name	= DTB.ForceofNature.name,
				desc	= DTB.ForceofNature.name .. L["D_COLOR"],
				order	= 3,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    SolarBeam	= {
				type	= "color",
				name	= DTB.SolarBeam.name,
				desc	= DTB.SolarBeam.name .. L["D_COLOR"],
				order	= 4,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    Moonfire	= {
				type	= "color",
				name	= DTB.Moonfire.name,
				desc	= DTB.Moonfire.name .. L["D_COLOR"],
				order	= 5,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    Sunfire	= {
				type	= "color",
				name	= DTB.Sunfire.name,
				desc	= DTB.Sunfire.name .. L["D_COLOR"],
				order	= 6,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    SolarEclipse= {
				type	= "color",
				name	= DTB.SolarEclipse.name,
				desc	= DTB.SolarEclipse.name .. L["D_COLOR"],
				order	= 7,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    LunarEclipse= {
				type	= "color",
				name	= DTB.LunarEclipse.name,
				desc	= DTB.LunarEclipse.name .. L["D_COLOR"],
				order	= 8,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			},
		    },
		    balancebarorder = {
			name		= L["ORDERING"],
			handler		= DTB,
			type		= "group",
			order		= 2,
			args		= {
			    EclipsePower= {
				type	= "select",
				style	= "dropdown",
				name	= L["ECLIPSE_POWER"],
				order	= 0,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    SolarEclipse= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.SolarEclipse.name,
				order	= 1,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    LunarEclipse= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.LunarEclipse.name,
				order	= 2,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Starsurge	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Starsurge.name,
				order	= 3,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Starfall	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Starfall.name,
				order	= 4,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    ForceofNature	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.ForceofNature.name,
				order	= 5,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    SolarBeam	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.SolarBeam.name,
				order	= 6,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Moonfire	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Moonfire.name,
				order	= 7,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Sunfire	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Sunfire.name,
				order	= 8,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			},
		    },
		},
	    },
	    feraloptions	= {
		name		= L["FERAL_OPTIONS"],
		handler		= DTB,
		type		= "group",
		childGroups	= "tab",
		order		= 1,
		args		= {
		    feralbars	= {
			name		= L["TOGGLE_BARS"],
			handler		= DTB,
			type		= "group",
			order		= 0,
			args		= {
			    trackrip	= {
				type	= "toggle",
				name	= DTB.Rip.name,
				desc	= L["D_TRACKRIP"],
				order	= 0,
				get	= function (info,value) return self.db.profile.TrackRip end,
				set	= function (info,value) self.db.profile.TrackRip = value self:HideAllBars() end,
			    },
			    trackrake	= {
				type	= "toggle",
				name	= DTB.Rake.name,
				desc	= L["D_TRACKRAKE"],
				order	= 1,
				get	= function (info,value) return self.db.profile.TrackRake end,
				set	= function (info,value) self.db.profile.TrackRake = value self:HideAllBars() end,
			    },
			    trackweakenedblows	= {
				type	= "toggle",
				name	= L["WEAKENEDBLOWS"],
				desc	= L["D_TRACKWEAKENEDBLOWS"],
				order	= 2,
				get	= function (info,value) return self.db.profile.TrackWeakenedBlows end,
				set	= function (info,value) self.db.profile.TrackWeakenedBlows = value self:HideAllBars() end,
			    },
			    tracklacerate	= {
				type	= "toggle",
				name	= DTB.Lacerate.name,
				desc	= L["D_TRACKLACERATE"],
				order	= 3,
				get	= function (info,value) return self.db.profile.TrackLacerate end,
				set	= function (info,value) self.db.profile.TrackLacerate = value self:HideAllBars() end,
			    },
			    trackberserk	= {
				type	= "toggle",
				name	= DTB.Berserk.name,
				desc	= L["D_TRACKBERSERK"],
				order	= 4,
				get	= function (info,value) return self.db.profile.TrackBerserk end,
				set	= function (info,value) self.db.profile.TrackBerserk = value self:HideAllBars() end,
			    },
			    tracksavageroar	= {
				type	= "toggle",
				name	= DTB.SavageRoar.name,
				desc	= L["D_TRACKSAVAGEROAR"],
				order	= 5,
				get	= function (info,value) return self.db.profile.TrackSavageRoar end,
				set	= function (info,value) self.db.profile.TrackSavageRoar = value self:HideAllBars() end,
			    },
			    tracktigersfury	= {
				type	= "toggle",
				name	= DTB.TigersFury.name,
				desc	= L["D_TRACKTIGERSFURY"],
				order	= 6,
				get	= function (info,value) return self.db.profile.TrackTigersFury end,
				set	= function (info,value) self.db.profile.TrackTigersFury = value self:HideAllBars() end,
			    },
			},
		    },
		    feralcolors = {
			name		= L["COLORS"],
			handler		= DTB,
			type		= "group",
			order		= 1,
			args		= {
			    Rip= {
				type	= "color",
				name	= DTB.Rip.name,
				desc	= DTB.Rip.name .. L["D_COLOR"],
				order	= 0,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    Rake	= {
				type	= "color",
				name	= DTB.Rake.name,
				desc	= DTB.Rake.name .. L["D_COLOR"],
				order	= 1,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    WeakenedBlows= {
				type	= "color",
				name	= L["WEAKENEDBLOWS"],
				desc	= L["WEAKENEDBLOWS"] .. L["D_COLOR"],
				order	= 2,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    Lacerate	= {
				type	= "color",
				name	= DTB.Lacerate.name,
				desc	= DTB.Lacerate.name .. L["D_COLOR"],
				order	= 3,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    Berserk	= {
				type	= "color",
				name	= DTB.Berserk.name,
				desc	= DTB.Berserk.name .. L["D_COLOR"],
				order	= 4,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    SavageRoar	= {
				type	= "color",
				name	= DTB.SavageRoar.name,
				desc	= DTB.SavageRoar.name .. L["D_COLOR"],
				order	= 5,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    TigersFury	= {
				type	= "color",
				name	= DTB.TigersFury.name,
				desc	= DTB.TigersFury.name .. L["D_COLOR"],
				order	= 6,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			},
		    },
		    feralbarorder = {
			name		= L["ORDERING"],
			handler		= DTB,
			type		= "group",
			order		= 2,
			args		= {
			    WeakenedBlows= {
				type	= "select",
				style	= "dropdown",
				name	= L["WEAKENEDBLOWS"],
				order	= 0,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Lacerate	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Lacerate.name,
				order	= 1,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Rake	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Rake.name,
				order	= 2,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Rip	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Rip.name,
				order	= 4,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Berserk	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Berserk.name,
				order	= 5,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    SavageRoar	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.SavageRoar.name,
				order	= 7,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    TigersFury	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.TigersFury.name,
				order	= 8,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			},
		    },
		},
	    },
	    restooptions	= {
		name		= L["RESTO_OPTIONS"],
		handler		= DTB,
		type		= "group",
		childGroups	= "tab",
		order		= 2,
		args		= {
		    restobars	= {
			name		= L["TOGGLE_BARS"],
			handler		= DTB,
			type		= "group",
			order		= 0,
			args		= {
			    trackwildgrowth	= {
				type	= "toggle",
				name	= DTB.WildGrowth.name,
				desc	= L["D_TRACKWILDGROWTH"],
				order	= 0,
				get	= function (info,value) return self.db.profile.TrackWildGrowth end,
				set	= function (info,value) self.db.profile.TrackWildGrowth = value self:HideAllBars() end,
			    },
			    tracknaturesswiftness	= {
				type	= "toggle",
				name	= DTB.NaturesSwiftness.name,
				desc	= L["D_TRACKNS"],
				order	= 1,
				get	= function (info,value) return self.db.profile.TrackNaturesSwiftness end,
				set	= function (info,value) self.db.profile.TrackNaturesSwiftness = value self:HideAllBars() end,
			    },
			    trackswiftmend	= {
				type	= "toggle",
				name	= DTB.Swiftmend.name,
				desc	= L["D_TRACKSWIFTMEND"],
				order	= 2,
				get	= function (info,value) return self.db.profile.TrackSwiftmend end,
				set	= function (info,value) self.db.profile.TrackSwiftmend = value self:HideAllBars() end,
			    },
			    trackrebirth	= {
				type	= "toggle",
				name	= DTB.Rebirth.name,
				desc	= L["D_TRACKREBIRTH"],
				order	= 3,
				get	= function (info,value) return self.db.profile.TrackRebirth end,
				set	= function (info,value) self.db.profile.TrackRebirth = value self:HideAllBars() end,
			    },
			    tracktranquility	= {
				type	= "toggle",
				name	= DTB.Tranquility.name,
				desc	= L["D_TRACKTRANQUILITY"],
				order	= 4,
				get	= function (info,value) return self.db.profile.TrackTranquility end,
				set	= function (info,value) self.db.profile.TrackTranquility = value self:HideAllBars() end,
			    },
			    tracktreeoflife	= {
				type	= "toggle",
				name	= DTB.TreeofLife.name,
				desc	= L["D_TRACKTREEOFLIFE"],
				order	= 5,
				get	= function (info,value) return self.db.profile.TrackTreeofLife end,
				set	= function (info,value) self.db.profile.TrackTreeofLife = value self:HideAllBars() end,
			    },
			},
		    },
		    restocolors = {
			name		= L["COLORS"],
			handler		= DTB,
			type		= "group",
			order		= 1,
			args		= {
			    WildGrowth	= {
				type	= "color",
				name	= DTB.WildGrowth.name,
				desc	= DTB.WildGrowth.name .. L["D_COLOR"],
				order	= 0,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    NaturesSwiftness	= {
				type	= "color",
				name	= DTB.NaturesSwiftness.name,
				desc	= DTB.NaturesSwiftness.name .. L["D_COLOR"],
				order	= 1,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    Swiftmend = {
				type	= "color",
				name	= DTB.Swiftmend.name,
				desc	= DTB.Swiftmend.name .. L["D_COLOR"],
				order	= 2,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    Rebirth	= {
				type	= "color",
				name	= DTB.Rebirth.name,
				desc	= DTB.Rebirth.name .. L["D_COLOR"],
				order	= 3,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    Tranquility = {
				type	= "color",
				name	= DTB.Tranquility.name,
				desc	= DTB.Tranquility.name .. L["D_COLOR"],
				order	= 5,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    TreeofLife = {
				type	= "color",
				name	= DTB.TreeofLife.name,
				desc	= DTB.TreeofLife.name .. L["D_COLOR"],
				order	= 6,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			},
		    },
		    restobarorder = {
			name		= L["ORDERING"],
			handler		= DTB,
			type		= "group",
			order		= 2,
			args		= {
			    TreeofLife	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.TreeofLife.name,
				order	= 0,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    NaturesSwiftness= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.NaturesSwiftness.name,
				order	= 1,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    WildGrowth	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.WildGrowth.name,
				order	= 2,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Swiftmend	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Swiftmend.name,
				order	= 3,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Tranquility	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Tranquility.name,
				order	= 4,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Rebirth	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Rebirth.name,
				order	= 5,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			},
		    },
		},
	    },
	    otheroptions	= {
		name		= L["OTHER_OPTIONS"],
		handler		= DTB,
		type		= "group",
		childGroups	= "tab",
		order		= 3,
		args		= {
		    otherbars	= {
			name		= L["TOGGLE_BARS"],
			handler		= DTB,
			type		= "group",
			order		= 0,
			args		= {
			    trackbarkskin	= {
				type	= "toggle",
				name	= DTB.Barkskin.name,
				desc	= L["D_TRACKBARKSKIN"],
				order	= 1,
				get	= function (info,value) return self.db.profile.TrackBarkskin end,
				set	= function (info,value) self.db.profile.TrackBarkskin = value self:HideAllBars() end,
			    },
			    trackfaeriefire	= {
				type	= "toggle",
				name	= DTB.FaerieFire.name,
				desc	= L["D_TRACKFAERIEFIRE"],
				order	= 2,
				get	= function (info,value) return self.db.profile.TrackFaerieFire end,
				set	= function (info,value) self.db.profile.TrackFaerieFire = value self:HideAllBars() end,
			    },
			    trackomenofclarity	= {
				type	= "toggle",
				name	= DTB.OmenOfClarity.name,
				desc	= L["D_TRACKOMEN"],
				order	= 3,
				get	= function (info,value) return self.db.profile.TrackOmenOfClarity end,
				set	= function (info,value) self.db.profile.TrackOmenOfClarity = value self:HideAllBars() end,
			    },
			    trackinnervate	= {
				type	= "toggle",
				name	= DTB.Innervate.name,
				desc	= L["D_TRACKINNERVATE"],
				order	= 4,
				get	= function (info,value) return self.db.profile.TrackInnervate end,
				set	= function (info,value) self.db.profile.TrackInnervate = value self:HideAllBars() end,
			    },
			    tracknaturesgrace = {
				type	= "toggle",
				name	= DTB.NaturesGrace.name,
				desc	= L["D_TRACKNATURESGRACE"],
				order	= 6,
				get	= function (info,value) return self.db.profile.TrackNaturesGrace end,
				set	= function (info,value) self.db.profile.TrackNaturesGrace = value self:HideAllBars() end,
			    },
			},
		    },
		    othercolors = {
			name		= L["COLORS"],
			handler		= DTB,
			type		= "group",
			order		= 1,
			args		= {
			    Barkskin	= {
				type	= "color",
				name	= DTB.Barkskin.name,
				desc	= DTB.Barkskin.name .. L["D_COLOR"],
				order	= 0,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    FaerieFire	= {
				type	= "color",
				name	= DTB.FaerieFire.name,
				desc	= DTB.FaerieFire.name .. L["D_COLOR"],
				order	= 1,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    OmenOfClarity = {
				type	= "color",
				name	= DTB.OmenOfClarity.name,
				desc	= DTB.OmenOfClarity.name .. L["D_COLOR"],
				order	= 2,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    Innervate	= {
				type	= "color",
				name	= DTB.Innervate.name,
				desc	= DTB.Innervate.name .. L["D_COLOR"],
				order	= 4,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			    NaturesGrace = {
				type	= "color",
				name	= DTB.NaturesGrace.name,
				desc	= DTB.NaturesGrace.name .. L["D_COLOR"],
				order	= 6,
				get	= "GetItemColor",
				set	= "SetItemColor",
				hasAlpha= true,
			    },
			},
		    },
		    otherbarorder = {
			name		= L["ORDERING"],
			handler		= DTB,
			type		= "group",
			order		= 2,
			args		= {
			    FaerieFire	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.FaerieFire.name,
				order	= 0,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    OmenOfClarity	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.OmenOfClarity.name,
				order	= 1,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Barkskin	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Barkskin.name,
				order	= 2,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    Innervate	= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.Innervate.name,
				order	= 4,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			    NaturesGrace= {
				type	= "select",
				style	= "dropdown",
				name	= DTB.NaturesGrace.name,
				order	= 5,
				get	= "GetBarSlot",
				set	= "SetBarSlot",
				values  = barslots
			    },
			},
		    },
		},
	    },
	    lookandfeel = {
		name		= L["LOOKANDFEEL"],
		handler		= DTB,
		type		= "group",
		order		= 4,
		args		= {
		    texture	= {
			type	= 'select',
			name	= L["O_TEXTURE"],
			desc	= L["D_TEXTURE"],
			order	= 0,
			get	= function (info,value) return self.db.profile.BarTexture end,
			set	= "SetBarTexture",
			values	= M:List("statusbar"),
		    },
		    font	= {
			type	= 'select',
			name	= L["O_FONT"],
			desc	= L["D_FONT"],
			order	= 1,
			get	= function (info,value) return self.db.profile.BarFont end,
			set	= "SetBarFont",
			values	= M:List("font"),
		    },
		    growfrom	= {
			type	= "select",
			style	= "dropdown",
			name	= L["O_GROWFROM"],
			desc	= L["D_GROWFROM"],
			order	= 2,
			get	= function (info,value) return self.db.profile.GrowFrom end,
			set	= function (info,value) self.db.profile.GrowFrom = value DTB.resort = true end,
			values	= { CENTER = "Center", BOTTOMLEFT = "Bottom/Left", BOTTOMRIGHT = "Top/Right" }
		    },
		    barheight	= {
			type	= 'range',
			name	= L["O_BARHEIGHT"],
			desc	= L["D_BARHEIGHT"],
			order	= 3,
			min	= 10,
			max	= 70,
			step	= 1,
			get	= function (info,value) return self.db.profile.BarHeight end,
			set	= "SetBarHeight",
		    },
		    barwidth	= {
			type	= 'range',
			disabled= function (info,value) return self.db.profile.IconOnly end,
			name	= L["O_BARWIDTH"],
			desc	= L["D_BARWIDTH"],
			order	= 4,
			min	= 50,
			max	= 400,
			step	= 1,
			get	= function (info,value) return self.db.profile.BarWidth end,
			set	= "SetBarWidth",
		    },
		    barspacing	= {
			type	= 'range',
			name	= L["O_BARSPACING"],
			desc	= L["D_BARSPACING"],
			order	= 5,
			min	= 0,
			max	= 25,
			step	= 1,
			get	= function (info,value) return self.db.profile.BarSpacing end,
			set	= "SetBarSpacing",
		    },
		    hideicons	= {
			type	= 'toggle',
			disabled= function (info,value) return self.db.profile.IconOnly end,
			name	= L["O_HIDEICONS"],
			desc	= L["D_HIDEICONS"],
			order	= 6,
			get	= function (info,value) return self.db.profile.HideIcons end,
			set	= "ToggleHideIcons",
		    },
		    icononly	= {
			type	= 'toggle',
			name	= L["O_ICONONLY"],
			desc	= L["D_ICONONLY"],
			order	= 7,
			get	= function (info,value) return self.db.profile.IconOnly end,
			set	= "ToggleIconOnly",
		    },
		    iconrow	= {
			type	= 'toggle',
			disabled= function (info,value) return not self.db.profile.IconOnly end,
			name	= L["O_ICONROW"],
			desc	= L["D_ICONROW"],
			order	= 8,
			get	= function (info,value) return self.db.profile.IconRow end,
			set	= "ToggleIconRow",
		    },
		    cooldownmodel= {
			type	= 'toggle',
			disabled= function (info,value) return not self.db.profile.IconOnly end,
			name	= L["O_COOLDOWNMODEL"],
			desc	= L["D_COOLDOWNMODEL"],
			order	= 9,
			get	= function (info,value) return self.db.profile.CooldownModel end,
			set	= function (info,value) self.db.profile.CooldownModel = value self:HideAllBars() end,
		    },
		    FrameColor	= {
			type	= "color",
			name	= L["O_FRAMECOLOR"],
			desc	= L["D_FRAMECOLOR"],
			order	= 10,
			get	= "GetItemColor",
			set	= "SetItemColor",
			hasAlpha= true,
		    },
		    FontColor	= {
			type	= "color",
			name	= L["O_FONTCOLOR"],
			desc	= L["D_FONTCOLOR"],
			order	= 11,
			get	= "GetItemColor",
			set	= "SetItemColor",
			hasAlpha= true,
		    },
		    barsorting	= {
			type	= "select",
			style	= "dropdown",
			name	= L["O_SORTSTYLE"],
			desc	= L["D_SORTSTYLE"],
			order	= 12,
			get	= function (info,value) return self.db.profile.BarSortingStyle end,
			set	= function (info,value) self.db.profile.BarSortingStyle = value DTB.resort = true end,
			values	= { Collapse = "Collapse", Static = "Static" }
		    },
--		    testbars	= {
--			type	= 'execute',
--			name	= L["O_TESTBARS"],
--			desc	= L["D_TESTBARS"],
--			order	= 13,
--			func	= "ToggleTestBars",
--		    },
		    framelocked	= {
			type	= 'toggle',
			name	= L["O_FRAMELOCKED"],
			desc	= L["D_FRAMELOCKED"],
			order	= 14,
			get	= function (info,value) return self.db.profile.FrameUnlocked end,
			set	= "ToggleFrameLock",
		    },
		},
	    },
	    defaults = {
		name		= L["DEFAULTS"],
		handler		= DTB,
		type		= "group",
		order		= 5,
		args		= {
		    position	= {
			type	= 'execute',
			name	= L["O_RESET"],
			desc	= L["D_RESET"],
			order	= 0,
			func	= "ResetWindowPosition",
		    },
		    colors	= {
			type	= 'execute',
			name	= L["O_RESETCOLORS"],
			desc	= L["D_RESETCOLORS"],
			order	= 1,
			func	= "ResetColors",
		    },
		    bars	= {
			type	= 'execute',
			name	= L["O_RESETBARS"],
			desc	= L["D_RESETBARS"],
			order	= 2,
			func	= "ResetBars",
		    },
		},
	    },
	},
    }

    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    return options
end

-- Addon defaults
function DTB:Defaults()
    local defaults		= {
	profile			= {
	    TrackEclipse	= true,
	    TrackStarfall	= true,
	    TrackStarsurge	= true,
	    TrackForceofNature	= true,
	    TrackInnervate	= true,
	    TrackOmenOfClarity	= true,
	    TrackStarfallRange	= true,
	    TrackEclipsePower	= true,
	    TrackMoonfire	= true,
	    TrackSunfire	= true,
	    TrackFaerieFire	= true,
	    TrackTigersFury	= true,
	    TrackBerserk	= true,
	    TrackRake		= true,
	    TrackRip		= true,
	    TrackLacerate	= true,
	    TrackWeakenedBlows	= true,
	    TrackSavageRoar	= true,
	    TrackBarkskin	= true,
	    TrackSolarBeam	= true,
	    TrackWildGrowth	= true,
	    TrackNaturesSwiftness= true,
	    TrackSwiftmend	= true,
	    TrackTranquility	= true,
	    TrackTreeofLife	= true,
	    TrackRebirth	= true,
	    TrackNaturesGrace	= true,
	    BarSortingStyle	= "Collapse",
	    GrowFrom		= "BOTTOMLEFT",
	    BarTexture		= 1,
	    BarFont		= 1,
	    BarHeight		= 15,
	    BarWidth		= 200,
	    BarSpacing		= 5,
	    HideIcons		= false,
	    IconOnly		= false,
	    IconRow		= false,
	    CooldownModel	= false,
	    relativeTo		= "UIParent",
	    relativePoint	= "CENTER",
	    point		= "CENTER",
	    xOffset		= 0,
	    yOffset		= 0,
	    FrameUnlocked	= true,
	    Sorting		= { EclipsePower=0,WeakenedBlows=0,TreeofLife=0,SolarEclipse=1,LunarEclipse=1,Lacerate=1,Rake=1,NaturesSwiftness=1,
				    Starsurge=2,Rip=2,WildGrowth=2,Starfall=3,Berserk=3,Swiftmend=3,ForceofNature=4,
				    SavageRoar=4,SolarBeam=5,TigersFury=5,Moonfire=6,Sunfire=7,FaerieFire=8,OmenOfClarity=9,Barkskin=10,
				    Innervate=11,NaturesGrace=12,Tranquility=13,Rebirth=14 },
	    FrameColor		= { r=0, g=0, b=0, a=0 },
	    FontColor		= { r=1, g=1, b=1, a=1 },
	    SolarEclipse	= { r=1, g=.6, b=0, a=1 },
	    LunarEclipse	= { r=.95, g=.95, b=1, a=1 },
	    Starfall		= { r=.8, g=.8, b=1, a=1 },
	    OmenOfClarity	= { r=.4, g=.95, b=.75, a=1 },
	    Moonfire		= { r=.6, g=.5, b=.8, a=1 },
	    Sunfire		= { r=1, g=.25, b=0, a=1 },
	    Starsurge		= { r=.6, g=.1, b=.7, a=1 },
	    ForceofNature	= { r=.7, g=.45, b=.3, a=1 },
	    Innervate		= { r=.17, g=.33, b=1, a=1 },
	    NaturesGrace	= { r=.65, g=.5, b=.25, a=1 },
	    Rip			= { r=1, g=1, b=0, a=1 },
	    Rake		= { r=1, g=0, b=0, a=1 },
	    WeakenedBlows	= { r=1, g=.6, b=0, a=1 },
	    Lacerate		= { r=1, g=0, b=0, a=1 },
	    Berserk		= { r=.23, g=1, b=0, a=1 },
	    SavageRoar		= { r=.63, g=.86, b=1, a=1 },
	    TigersFury		= { r=.30, g=1, b=0, a=1 },
	    Barkskin		= { r=.75, g=.75, b=0, a=1 },
	    SolarBeam		= { r=.95, g=.95, b=.6, a=1 },
	    FaerieFire		= { r=1, g=.32, b=1, a=1 },
	    WildGrowth		= { r=.55, g=1, b=.1, a=1 },
	    NaturesSwiftness	= { r=.55, g=1, b=.85, a=1 },
	    Swiftmend		= { r=.3, g=.75, b=1, a=1 },
	    Tranquility		= { r=.5, g=.5, b=.5, a=1 },
	    TreeofLife		= { r=.7, g=.45, b=.3, a=1 },
	    Rebirth		= { r=1, g=.55, b=.24, a=1 },
	    EclipsePower	= { r=1, g=1, b=1, a=1 },
	},
    }
    return defaults
end

-- Command line stuff
function DTB:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)

	-- Make the frame wider.
	InterfaceOptionsFrame:SetWidth(975)
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(DTB, "DTB", input)
    end
end

-- Save the window position after being dragged
function DTB:SavePosition(var,frame)
    local point,relativeTo,relativePoint,xOffset,yOffset = frame:GetPoint();
    var.point		= point
    var.relativeTo	= type(relativeTo) == 'table' and relativeTo:GetName() or relativeTo
    var.relativePoint	= relativePoint
    var.xOffset		= xOffset
    var.yOffset		= yOffset
end

-- Reset the window position to default
function DTB:ResetWindowPosition()
    local defaults = DTB:Defaults()

    self.frame:ClearAllPoints()
    self.db.profile.point		= defaults.profile.point
    self.db.profile.relativeTo		= defaults.profile.relativeTo
    self.db.profile.relativePoint	= defaults.profile.relativePoint
    self.db.profile.xOffset		= defaults.profile.xOffset
    self.db.profile.yOffset		= defaults.profile.yOffset

    self.frame:SetPoint(self.db.profile.point, self.db.profile.relativeTo, self.db.profile.relativePoint, self.db.profile.xOffset,
			self.db.profile.yOffset)
end

-- Reset bar/frame colors to their defaults
function DTB:ResetColors()
    local defaults = DTB:Defaults()

    self.db.profile.FrameColor		= defaults.profile.FrameColor
    self.db.profile.FontColor		= defaults.profile.FontColor
    self.db.profile.SolarEclipse	= defaults.profile.SolarEclipse
    self.db.profile.LunarEclipse	= defaults.profile.LunarEclipse
    self.db.profile.Starfall		= defaults.profile.Starfall
    self.db.profile.Moonfire		= defaults.profile.Moonfire
    self.db.profile.Sunfire		= defaults.profile.Sunfire
    self.db.profile.Starsurge		= defaults.profile.Starsurge
    self.db.profile.ForceofNature	= defaults.profile.ForceofNature
    self.db.profile.Innervate		= defaults.profile.Innervate
    self.db.profile.OmenOfClarity	= defaults.profile.OmenOfClarity
    self.db.profile.Rip			= defaults.profile.Rip
    self.db.profile.Rake		= defaults.profile.Rake
    self.db.profile.WeakenedBlows	= defaults.profile.WeakenedBlows
    self.db.profile.Lacerate		= defaults.profile.Lacerate
    self.db.profile.Berserk		= defaults.profile.Berserk
    self.db.profile.SavageRoar		= defaults.profile.SavageRoar
    self.db.profile.TigersFury		= defaults.profile.TigersFury
    self.db.profile.FaerieFire		= defaults.profile.FaerieFire
    self.db.profile.Barkskin		= defaults.profile.Barkskin
    self.db.profile.SolarBeam		= defaults.profile.SolarBeam
    self.db.profile.WildGrowth		= defaults.profile.WildGrowth
    self.db.profile.NaturesSwiftness	= defaults.profile.NaturesSwiftness
    self.db.profile.Swiftmend		= defaults.profile.Swiftmend
    self.db.profile.Tranquility		= defaults.profile.Tranquility
    self.db.profile.Rebirth		= defaults.profile.Rebirth
    self.db.profile.NaturesGrace	= defaults.profile.NaturesGrace

    -- Make the frame 50% black when unlocked
    if self.db.profile.FrameUnlocked then
	DTB.frame:SetBackdropColor(0,0,0,.5)
    else
	self.frame:SetBackdropColor(defaults.profile.FrameColor.r, defaults.profile.FrameColor.g, defaults.profile.FrameColor.b,
				    defaults.profile.FrameColor.a)
    end

    -- Cycle through the bars to update them.
    for i,v in ipairs(DTB.barList) do
	self:CreateBar(v)
    end

    DTB:HideAllBars()
end

-- Reset the bar settings to default
function DTB:ResetBars()
    local defaults = DTB:Defaults()

    self.db.profile.BarSortingStyle	= defaults.profile.BarSortingStyle
    self.db.profile.BarSpacing		= defaults.profile.BarSpacing
    self.db.profile.GrowFrom		= defaults.profile.GrowFrom
    DTB:ToggleHideIcons(_,defaults.profile.HideIcons)
    DTB:ToggleIconOnly(_,defaults.profile.IconOnly)
    DTB:ToggleIconRow(_,defaults.profile.IconRow)
    DTB:SetBarTexture(_,defaults.profile.BarTexture)
    DTB:SetBarFont(_,defaults.profile.BarFont)
    DTB:SetBarHeight(_,defaults.profile.BarHeight)
    DTB:SetBarWidth(_,defaults.profile.BarWidth)
end

-- Change the width of the bars.
function DTB:SetBarWidth(info,value)
    self.db.profile.BarWidth = value

    -- Resize the frame
    if not self.db.profile.IconOnly then
	if self.db.profile.HideIcons then
	    self.frame:SetWidth(value + (self.db.profile.BarSpacing * 2))
	else
	    self.frame:SetWidth(value + self.db.profile.BarHeight + (self.db.profile.BarSpacing * 2))
	end
    end

    -- Cycle through the bars to update them.
    for i,v in ipairs(DTB.barList) do
	self:CreateBar(v)
    end

    self:HideAllBars()
end

-- Change the height of the bars.
function DTB:SetBarHeight(info,value)
    self.db.profile.BarHeight = value

    -- Resize the frame
    if self.db.profile.IconOnly == true then
	if self.db.profile.IconRow == true then
	    self.frame:SetWidth(((value + self.db.profile.BarSpacing) * 9) + self.db.profile.BarSpacing)
	    self.frame:SetHeight(value + (self.db.profile.BarSpacing * 2))
	else
	    self.frame:SetWidth(value + (self.db.profile.BarSpacing * 2))
	    self.frame:SetHeight(((value + self.db.profile.BarSpacing) * 9) + self.db.profile.BarSpacing)
	end
    else
	if self.db.profile.HideIcons then
	    self.frame:SetWidth(self.db.profile.BarWidth + (self.db.profile.BarSpacing * 2))
	else
	    self.frame:SetWidth(self.db.profile.BarWidth + value + (self.db.profile.BarSpacing * 2))
	end

	self.frame:SetHeight(((value + self.db.profile.BarSpacing) * 9) + (self.db.profile.BarSpacing + 2))
    end

    -- Cycle through the bars to update them.
    for i,v in ipairs(DTB.barList) do
	self:CreateBar(v)
	v.icon:SetWidth(value)
	v.icon:SetHeight(value)
    end

    self:HideAllBars()
end

-- Change the spacing of the bars.
function DTB:SetBarSpacing(info,value)
    self.db.profile.BarSpacing = value

    -- Change the frame dimensions to accomodate the new bar size.
    if self.db.profile.IconOnly == true then
	if self.db.profile.IconRow == true then
	    DTB.frame:SetWidth(((DTB.db.profile.BarHeight + value) * 9) + value)
	    DTB.frame:SetHeight(DTB.db.profile.BarHeight + (value * 2))
	else
	    DTB.frame:SetWidth(DTB.db.profile.BarHeight + (value * 2))
	    DTB.frame:SetHeight(((DTB.db.profile.BarHeight + value) * 9) + value)
	end
    else
	if self.db.profile.HideIcons then
	    self.frame:SetWidth(self.db.profile.BarWidth + (value * 2))
	else
	    self.frame:SetWidth(self.db.profile.BarWidth + self.db.profile.BarHeight + (value * 2))
	end

	self.frame:SetHeight(((self.db.profile.BarHeight + value) * 9) + (value + 2))
    end

    self:HideAllBars()
end

-- Change the texture of the bars.
function DTB:SetBarTexture(info,value)
    self.db.profile.BarTexture = value

    -- Cycle through the bars to update them.
    for i,v in ipairs(DTB.barList) do
	self:CreateBar(v)
    end
end

-- Change the font of the bars.
function DTB:SetBarFont(info,value)
    self.db.profile.BarFont = value

    -- Cycle through the bars to update them.
    for i,v in ipairs(DTB.barList) do
	self:CreateBar(v)
    end
end

-- Toggle the frame lock
function DTB:ToggleFrameLock()
    self.db.profile.FrameUnlocked = not self.db.profile.FrameUnlocked;
    self.frame:SetMovable(self.db.profile.FrameUnlocked)
    self.frame:EnableMouse(self.db.profile.FrameUnlocked)

    -- Make the frame 50% black when unlocked
    if self.db.profile.FrameUnlocked then
	DTB.frame:SetBackdropColor(0,0,0,.5)
    else
	DTB.frame:SetBackdropColor(DTB.db.profile.FrameColor.r, DTB.db.profile.FrameColor.g, DTB.db.profile.FrameColor.b,
				   DTB.db.profile.FrameColor.a)
    end
end

-- Toggle Hide Icons
function DTB:ToggleHideIcons(info,value)
    self.db.profile.HideIcons = value
    self:HideAllBars()

    -- Resize the frame
    if value == true then
	self.frame:SetWidth(self.db.profile.BarWidth + (self.db.profile.BarSpacing * 2))
    else
	self.frame:SetWidth(self.db.profile.BarWidth + self.db.profile.BarHeight + (self.db.profile.BarSpacing * 2))
    end
end

-- Toggle Icon Row
function DTB:ToggleIconRow(info,value)
    self.db.profile.IconRow = value
    self:HideAllBars()

    -- Resize the frame
    if value == true then
	self.frame:SetWidth(((self.db.profile.BarHeight + self.db.profile.BarSpacing) * 9) + self.db.profile.BarSpacing) -- 9 bar slots
	self.frame:SetHeight(self.db.profile.BarHeight + (self.db.profile.BarSpacing * 2)) -- Height of the bar, plus padding
    else
	self.frame:SetWidth(self.db.profile.BarHeight + (self.db.profile.BarSpacing * 2)) -- Height of the bar, plus padding
	self.frame:SetHeight(((self.db.profile.BarHeight + self.db.profile.BarSpacing) * 9) + self.db.profile.BarSpacing) -- 9 bar slots
    end
end

-- Toggle Icon Only mode. This entails basically recreating everything.
function DTB:ToggleIconOnly(info,value)
    self.db.profile.IconOnly = value
    self:HideAllBars()

    -- Icon only
    if value == true then
	-- Resize the frame
	if self.db.profile.IconRow == true then
	    self.frame:SetWidth(((self.db.profile.BarHeight + self.db.profile.BarSpacing) * 9) + self.db.profile.BarSpacing) -- 9 bar slots
	    self.frame:SetHeight(self.db.profile.BarHeight + (self.db.profile.BarSpacing * 2)) -- Height of the bar, plus padding
	else
	    self.frame:SetWidth(self.db.profile.BarHeight + (self.db.profile.BarSpacing * 2)) -- Height of the bar, plus padding
	    self.frame:SetHeight(((self.db.profile.BarHeight + self.db.profile.BarSpacing) * 9) + self.db.profile.BarSpacing) -- 9 bar slots
	end

	-- Cycle through each bar and set them up for icons only
	for i,v in ipairs(DTB.barList) do
	    v:SetWidth(self.db.profile.BarHeight)
	    v:SetBackdrop(nil)
	    v:SetStatusBarTexture(nil)
	    v:SetBackdropColor({ r=0, g=0, b=0, a=0})

	    -- Icon
	    v.icon:ClearAllPoints()
	    v.icon:SetPoint("CENTER", v, "CENTER", 0, 0)

	    -- Duration shadow
	    -- Special case: We want the Eclipse Power text centered on its icon, and slightly smaller so it fits.
	    if v:GetName() == "EclipsePower" then
		v.dshadow:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/2.5))
		v.dshadow:ClearAllPoints()
		v.dshadow:SetPoint("CENTER", v.icon,"CENTER", 1, -1)
	    else
		v.dshadow:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/2))
		v.dshadow:ClearAllPoints()
		v.dshadow:SetPoint("TOPLEFT", v.icon,"TOPLEFT", 3, -3)
	    end

	    -- Duration
	    -- Special case: We want the Eclipse Power text centered on its icon, and slightly smaller so it fits.
	    if v:GetName() == "EclipsePower" then
		v.duration:SetFont(M:Fetch("font",M:List("font")[DTB.db.profile.BarFont]),floor(DTB.db.profile.BarHeight/2.5))
		v.duration:ClearAllPoints()
		v.duration:SetPoint("CENTER", v.icon,"CENTER", 0, 0)
	    else
		v.duration:SetFont(M:Fetch("font",M:List("font")[self.db.profile.BarFont]),floor(self.db.profile.BarHeight/2))
		v.duration:ClearAllPoints()
		v.duration:SetPoint("TOPLEFT", v.icon, "TOPLEFT", 0, 0)
	    end

	    -- Text backdrop
	    v.shadow:SetFont(M:Fetch("font",M:List("font")[self.db.profile.BarFont]),floor(self.db.profile.BarHeight/3))
	    v.shadow:SetTextColor(0,0,0,.75)
	    v.shadow:ClearAllPoints()
	    v.shadow:SetPoint("BOTTOMRIGHT", v.icon, "BOTTOMRIGHT", -5, 5)

	    -- Label
	    v.label:SetFont(M:Fetch("font",M:List("font")[self.db.profile.BarFont]),floor(self.db.profile.BarHeight/3))
	    v.label:SetTextColor(self.db.profile.FontColor.r,self.db.profile.FontColor.g,self.db.profile.FontColor.b,self.db.profile.FontColor.a)
	    v.label:ClearAllPoints()
	    v.label:SetPoint("BOTTOMRIGHT", v.icon, "BOTTOMRIGHT", -4, 4)

	    v.spark:Hide()
	end
    else
	-- Resize the frame
	if self.db.profile.HideIcon then
	    self.frame:SetWidth((self.db.profile.BarWidth + (self.db.profile.BarSpacing * 2)))
	else
	    self.frame:SetWidth((self.db.profile.BarWidth + self.db.profile.BarHeight + (self.db.profile.BarSpacing * 2)))
	end

	self.frame:SetHeight(((self.db.profile.BarHeight + self.db.profile.BarSpacing) * 9) + self.db.profile.BarSpacing)

	-- Cycle through each bar and set them up for bar display
	for i,v in ipairs(DTB.barList) do
	    v:SetWidth(self.db.profile.BarWidth)
	    v:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
	    v:SetStatusBarTexture(M:Fetch("statusbar",M:List("statusbar")[self.db.profile.BarTexture]))
	    v:SetBackdropColor({ r=0, g=0, b=0, a=1})

	    -- Icon
	    v.icon:ClearAllPoints()
	    v.icon:SetPoint("RIGHT", v, "LEFT", -3, 0)
	    v.icon:SetBackdropColor(1,1,1,1)

	    -- Duration shadow
	    v.dshadow:SetFont(M:Fetch("font",M:List("font")[self.db.profile.BarFont]),floor(self.db.profile.BarHeight/1.3))
	    v.dshadow:ClearAllPoints()
	    v.dshadow:SetPoint("RIGHT", v, "RIGHT", -6, -1)

	    -- Duration
	    v.duration:SetFont(M:Fetch("font",M:List("font")[self.db.profile.BarFont]),floor(self.db.profile.BarHeight/1.3))
	    v.duration:ClearAllPoints()
	    v.duration:SetPoint("RIGHT",v,"RIGHT", -5, 0)

	    -- Text backdrop
	    v.shadow:SetFont(M:Fetch("font",M:List("font")[self.db.profile.BarFont]),floor(self.db.profile.BarHeight/1.3))
	    v.shadow:SetTextColor(0,0,0,.75)
	    v.shadow:ClearAllPoints()
	    v.shadow:SetPoint("LEFT", v, "LEFT", 6, -1)

	    -- Label
	    v.label:SetFont(M:Fetch("font",M:List("font")[self.db.profile.BarFont]),floor(self.db.profile.BarHeight/1.3))
	    v.label:SetTextColor(self.db.profile.FontColor.r,self.db.profile.FontColor.g,self.db.profile.FontColor.b,self.db.profile.FontColor.a)
	    v.label:ClearAllPoints()
	    v.label:SetPoint("LEFT", v, "LEFT", 5, 0)

	    v.spark:Show()
	end
    end
end

-- Toggle test bars. If a bar is off, turn it on, if its on, turn it off.
function DTB:ToggleTestBars()
    DTB.testbars = not DTB.testbars

    if not DTB.testbars then
	for i,v in ipairs(DTB.barList) do
	    DTB.visibleBars = 0
	    v:Hide()
	    v.icon:Hide()
	end
    else
	DTB:ShowAllBars()
	DTB.visibleBars = 0

	for i,v in ipairs(DTB.barList) do
	    DTB.visibleBars = DTB.visibleBars + 1
	    v:Show()
	    v.icon:Show()
	end
    end
end

-- Set the bar slot.
function DTB:SetBarSlot(info,value)
    self.db.profile.Sorting[info[#info]] = value
    DTB.resort = true
end

-- Fetch the bar slot.
function DTB:GetBarSlot(info)
    return self.db.profile.Sorting[info[#info]]
end

-- Return the colors of the specified item.
function DTB:GetItemColor(info,value)
    return self.db.profile[info[#info]].r,self.db.profile[info[#info]].g,self.db.profile[info[#info]].b,self.db.profile[info[#info]].a
end

-- Set the colors of the specified item.
function DTB:SetItemColor(info,r,g,b,a)
    self.db.profile[info[#info]].r = r
    self.db.profile[info[#info]].g = g
    self.db.profile[info[#info]].b = b
    self.db.profile[info[#info]].a = a

    if info[#info] == "FrameColor" then
	self.frame:SetBackdropColor(r,g,b,a)
    end

    -- Cycle through the bars to update them.
    for i,v in ipairs(DTB.barList) do
	self:CreateBar(v)
    end
end

-- Show or hide the Blizzard Eclipse frame.
function DTB:SetEclipseFrame()
    if self.db.profile.ShowEclipseFrame == true and DTB:IsBalance() == true then
	EclipseBarFrame:Show()
    else
	EclipseBarFrame:Hide()
    end
end