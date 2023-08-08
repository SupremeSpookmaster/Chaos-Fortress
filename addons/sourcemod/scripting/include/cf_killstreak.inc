public const char CFKS_Announcer_Administrator_KS[][] =
{
	"vo/killstreak/announcer_ks_03.mp3",
	"vo/killstreak/announcer_ks_04.mp3",
	"vo/killstreak/announcer_ks_05.mp3",
	"vo/killstreak/announcer_ks_06.mp3",
	"vo/killstreak/announcer_ks_07.mp3",
	"vo/killstreak/announcer_ks_08.mp3",
	"vo/killstreak/announcer_ks_09.mp3",
	"vo/killstreak/announcer_ks_10.mp3",
	"vo/killstreak/announcer_ks_11.mp3",
	"vo/killstreak/announcer_ks_12.mp3",
	"vo/killstreak/announcer_ks_13.mp3",
	"vo/killstreak/announcer_ks_14.mp3",
	"vo/killstreak/announcer_ks_15.mp3",
	"vo/killstreak/announcer_ks_16.mp3",
	"vo/killstreak/announcer_ks_17.mp3",
	"vo/killstreak/announcer_ks_18.mp3",
	"vo/killstreak/announcer_ks_19.mp3",
	"vo/killstreak/announcer_ks_21.mp3",
	"vo/killstreak/announcer_ks_22.mp3",
	"vo/killstreak/announcer_ks_23.mp3",
	"vo/killstreak/announcer_ks_24.mp3",
	"vo/killstreak/announcer_ks_25.mp3",
	"vo/killstreak/announcer_ks_26.mp3"
};

public const char CFKS_Announcer_Administrator_KSEnded[][] =
{
	"vo/announced_sd_monkeynaut_end_crash01.mp3",
	"vo/announcer_you_must_not_fail_again.mp3",
	"vo/announcer_failure.mp3",
	"vo/announcer_plr_firststageoutcome02.mp3"
};

public const char CFKS_Announcer_Administrator_EndedOwnKS[][] =
{
	"vo/announcer_am_lastmanforfeit03.mp3",
	"vo/announcer_am_lastmanforfeit04.mp3"
};

public const char CFKS_Announcer_Merasmus_KS[][] =
{
	"vo/halloween_merasmus/sf14_merasmus_general_purpose_18.mp3",
	"vo/halloween_merasmus/sf14_merasmus_general_purpose_17.mp3",
	"vo/halloween_merasmus/sf14_merasmus_general_purpose_16.mp3",
	"vo/halloween_merasmus/sf14_merasmus_minigame_all_otherteamdead_04.mp3",
	"vo/halloween_merasmus/sf14_merasmus_minigame_all_otherteamdead_05.mp3"
};

public const char CFKS_Announcer_Merasmus_KSEnded[][] =
{
	"vo/halloween_merasmus/sf14_merasmus_general_purpose_06.mp3",
	"vo/halloween_merasmus/sf14_merasmus_general_purpose_14.mp3",
	"vo/halloween_merasmus/sf14_merasmus_general_purpose_08.mp3",
	"vo/halloween_merasmus/sf14_merasmus_general_purpose_07.mp3",
	"vo/halloween_merasmus/hall2015_fightmeras_win_04.mp3"
};

public const char CFKS_Announcer_Merasmus_EndedOwnKS[][] =
{
	"vo/halloween_merasmus/sf14_merasmus_general_purpose_15.mp3",
	"vo/halloween_merasmus/hall2015_fightmeras_win_13.mp3",
	"vo/halloween_merasmus/hall2015_fightmeras_win_03.mp3"
};

#define CFKS_SFX_Killstreak		"misc/killstreak.wav"
#define CFKS_SFX_EndedOwnKS		"music/trombonetauntv2.mp3"
#define CFKS_SFX_KSEnded		"misc/ks_tier_01_death.wav"

int i_CFKillstreak[MAXPLAYERS+1] = {0, ...};

/**
 * Retrieves the killstreak of a given client.
 *
 * @param client		The client whose killstreak to retrieve.
 *
 * @return The player's current killstreak. 0 if dead, -1 if invalid client.
 */
native CF_GetKillstreak(int client);

/**
 * Sets the killstreak of a given client.
 *
 * @param client		The client whose killstreak to set.
 * @param kills			The new killstreak.
 * @param killer		The player who scored the kill. Used for announcing the end of a long killstreak.
 */
native CF_SetKillstreak(int client, int kills, int killer)

public void CFKS_MakeNatives()
{
	CreateNative("CF_GetKillstreak", Native_CF_GetKillstreak);
	CreateNative("CF_SetKillstreak", Native_CF_SetKillstreak);
}

/**
 * Retrieves the client's current character config.
 *
 * @param announcer		The announcer currently in-use. 0: Administrator, 1: Merasmus
 */
public void CFKS_Precache(int announcer)
{
	//TODO: Precache killstreak dialogue for whichever announcer is in-use.
}

public void CFKS_PlayerKilled(int victim, int attacker, bool deadRinger)
{
	if (!IsValidClient(victim))
		return;
		
	if (!deadRinger)
	{
		CF_SetKillstreak(victim, 0, attacker);
	}
	
	if (IsValidMulti(attacker, true) && attacker != victim)
 	{
 		CF_SetKillstreak(attacker, i_CFKillstreak[attacker] + 1, attacker);
 	}
}

public Native_CF_GetKillstreak(Handle plugin, int numParams)
{
	int ReturnValue = -1;
 	
 	int client = GetNativeCell(1);
 	
 	if (IsValidClient(client))
 	{
	 	ReturnValue = i_CFKillstreak[client];
	}
 		
 	return ReturnValue;
}

public Native_CF_SetKillstreak(Handle plugin, int numParams) //TODO: Make this set the killstreak property on the player as well, can't look it up rn because no wifi so can't look at other plugins' source code...
{
	int ReturnValue = -1;
 	
 	int client = GetNativeCell(1);
 	int kills = GetNativeCell(2);
 	int killer = GetNativeCell(3);
 	
 	if (IsValidClient(client))
 	{
 		bool ksMessage = false;
 		
 		if (kills > 0 && kills % 5 == 0)
	 	{
	 		PrintCenterTextAll("%N is on a %i-player killstreak!", client, kills);
	 		EmitSoundToAll(CFKS_SFX_Killstreak, _, _, 110);
	 		ksMessage = true;
	 	}
 		
 		if (kills == 0 && i_CFKillstreak[client] >= 10 && !ksMessage)
 		{
 			if (IsValidClient(killer))
 			{
	 			if (client == killer)
	 			{
	 				PrintCenterTextAll("%N put an end to their own %i-player killstreak...", client, i_CFKillstreak[client]);
	 				EmitSoundToAll(CFKS_SFX_EndedOwnKS, _, _, 110);
	 			}
	 			else
	 			{
	 				PrintCenterTextAll("%N's %i-player killstreak was finally ended by %N!", client, i_CFKillstreak[client], killer);
	 				EmitSoundToAll(CFKS_SFX_KSEnded, _, _, 110);
	 			}
	 		}
	 		else
	 		{
	 			PrintCenterTextAll("%N's %i-player killstreak was ended by a mysterious assailant...", client, i_CFKillstreak[client]);
	 			EmitSoundToAll(CFKS_SFX_KSEnded, _, _, 110);
	 		}
 		}
 		
	 	i_CFKillstreak[client] = kills;
	 	
	 	#if defined DEBUG_KILLSTREAKS
	 	CPrintToChatAll("Attempted to change %N's killstreak to %i.", client, kills);
	 	CPrintToChatAll("Their current killstreak is %i.", i_CFKillstreak[client]);
	 	#endif
	}
 		
 	return ReturnValue;
}