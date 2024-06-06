ntopp_v2.NERFED_PEPPINO_IN_COOP = CV_RegisterVar({
	name = "ntoppv2_nerfed_coop",
	defaultvalue = "No",
	flags = CV_NETVAR|CV_SHOWMODIF,
	PossibleValue = CV_YesNo
})

ntopp_v2.NERFED_PEPPINO_IN_OTHER = CV_RegisterVar({
	name = "ntoppv2_nerfed_other",
	defaultvalue = "Yes",
	flags = CV_NETVAR|CV_SHOWMODIF,
	PossibleValue = CV_YesNo
})

ntopp_v2.HOLD_TO_WALK = CV_RegisterVar({
	name = "ntoppv2_hold_to_walk",
	defaultvalue = "No",
	flags = CV_SHOWMODIF|CV_SAVE,
	PossibleValue = CV_YesNo
})

ntopp_v2.MACH_SOUNDS = CV_RegisterVar({
	name = "ntoppv2_machsounds",
	defaultvalue = "4",
	flags = CV_SHOWMODIF|CV_SAVE,
	PossibleValue = CV_Natural
})

ntopp_v2.machsounds = {}

ntopp_v2.machsounds[1] = {
	[1] = sfx_etbm1,
	[2] = sfx_etbm2,
	[3] = {
		[1] = sfx_etbm2,
		[2] = sfx_etbm3
	},
	[4] = {
		[1] = sfx_etbm2,
		[2] = sfx_etbm3
	}
}
ntopp_v2.machsounds[2] = {
	[1] = sfx_de2m1,
	[2] = sfx_de2m2,
	[3] = sfx_de2m3,
	[4] = sfx_de2m4
}

ntopp_v2.machsounds[3] = {
	[1] = sfx_hwma1,
	[2] = sfx_hwma2,
	[3] = {
		[1] = {
			[1] = sfx_hwma3,
			[2] = function(player) return (player.ntoppv2_machtime < 3 and not S_SoundPlaying(player.mo, sfx_hwma3)) or S_SoundPlaying(player.mo, sfx_hwma3) end
		},
		[2] = sfx_hwma2
	},
	[4] = {
		[1] = {
			[1] = sfx_hwma3,
			[2] = function(player) return (player.ntoppv2_machtime < 3 and not S_SoundPlaying(player.mo, sfx_hwma3)) or S_SoundPlaying(player.mo, sfx_hwma3) end
		},
		[2] = sfx_hwma2
	}
}

ntopp_v2.machsounds[4] = {
	[1] = sfx_mach1,
	[2] = sfx_mach2,
	[3] = sfx_mach3,
	[4] = sfx_mach4,
	["nthe_noise"] = {
		[1] = {
			[1] = sfx_nmc2g,
			[2] = {
				[1] = sfx_nmch2,
				[2] = function() return true end -- i swear, this function stuff is going to be bad because people can do literally anything with it
			},
		},
		[3] = {
			[1] = {
				[1] = sfx_nmc3g,
				[2] = function(player) return P_IsObjectOnGround(player.mo) end
			},
			[2] = sfx_nmch3
		},
		[4] = {
			[1] = {
				[1] = sfx_nmc4g,
				[2] = function(player) return P_IsObjectOnGround(player.mo) end
			},
			[2] = sfx_nmch4
		}
	},
	["ngustavo"] = {
		[1] = sfx_gum1,
		[2] = sfx_gum1, //if you somehow manage to trigger peppino's mach run instead of gustavo and brick's dash
		[3] = {
			[1] = {
				[1] = sfx_gum2,
				[2] = function(player) return P_IsObjectOnGround(player.mo) end
			},
			[2] = {
				[1] = sfx_gum2a,
				[2] = function(player) return not P_IsObjectOnGround(player.mo) end
			}
		},
		[4] = {
			[1] = {
				[1] = sfx_nmc4g,
				[2] = function(player) return P_IsObjectOnGround(player.mo) end
			},
			[2] = sfx_nmch4
		}
	},
	["ngustavo"] = {
		[1] = sfx_gum1,
		[2] = sfx_gum1, //if you somehow manage to trigger peppino's mach run instead of gustavo and brick's dash
		[3] = sfx_gum2,
		[4] = sfx_gum2 //if you somehow manage to trigger peppino's mach run instead of gustavo and brick's dash
	}
}

ntopp_v2.machsounds[4]["nthe_noise"][2] = ntopp_v2.machsounds[4]["nthe_noise"][1]
ntopp_v2.machsounds[4]["ngustavo"][2] = ntopp_v2.machsounds[4]["ngustavo"][1]