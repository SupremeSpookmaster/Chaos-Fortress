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

public const char CFKS_Announcer_Administrator_KS_Godlike[][] =
{
	"vo/compmode/cm_admin_teamwipe_05.mp3",
	"vo/compmode/cm_admin_teamwipe_12.mp3",
	"vo/compmode/cm_admin_teamwipe_14.mp3",
	"vo/announcer_plr_racegeneral14.mp3"
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
	"vo/halloween_merasmus/sf14_merasmus_general_purpose_16.mp3"
};

public const char CFKS_Announcer_Merasmus_KS_Godlike[][] =
{
	"vo/halloween_merasmus/sf14_merasmus_minigame_all_otherteamdead_03.mp3",
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

int i_CFCurrentAnnouncer = 0;
int i_CFKillstreak[MAXPLAYERS+1] = {0, ...};

float f_CFKillstreakForwardTime[MAXPLAYERS + 1] = { 0.0, ... };

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

/**
 * Called when a player's Chaos Fortress killstreak is changed.
 *
 * @param client			The client whose killstreak was changed.
 * @param kills				The new killstreak.
 */
forward void CF_OnKillstreakChanged(int client, int kills)

GlobalForward g_OnKillstreakChanged;

public void CFKS_MakeNatives()
{
	CreateNative("CF_GetKillstreak", Native_CF_GetKillstreak);
	CreateNative("CF_SetKillstreak", Native_CF_SetKillstreak);
}

public void CFKS_MakeForwards()
{
	g_OnKillstreakChanged = new GlobalForward("CF_OnKillstreakChanged", ET_Ignore, Param_Cell, Param_Cell);
}

/**
 * Precaches announcer dialogue for killstreaks.
 *
 * @param announcer		The announcer currently in-use. 0: Administrator, 1: Merasmus
 */
public void CFKS_Precache(int announcer)
{
	PrecacheSound(CFKS_SFX_Killstreak);
	PrecacheSound(CFKS_SFX_EndedOwnKS);
	PrecacheSound(CFKS_SFX_KSEnded);
	
	if (announcer == 0)
	{
		for (int i = 0; i < (sizeof(CFKS_Announcer_Administrator_KS));       i++) { PrecacheSound(CFKS_Announcer_Administrator_KS[i]);       }
		for (int i = 0; i < (sizeof(CFKS_Announcer_Administrator_KS_Godlike));       i++) { PrecacheSound(CFKS_Announcer_Administrator_KS_Godlike[i]);       }
		for (int i = 0; i < (sizeof(CFKS_Announcer_Administrator_KSEnded));       i++) { PrecacheSound(CFKS_Announcer_Administrator_KSEnded[i]);       }
		for (int i = 0; i < (sizeof(CFKS_Announcer_Administrator_EndedOwnKS));       i++) { PrecacheSound(CFKS_Announcer_Administrator_EndedOwnKS[i]);       }
	}
	else
	{
		for (int i = 0; i < (sizeof(CFKS_Announcer_Merasmus_KS));       i++) { PrecacheSound(CFKS_Announcer_Merasmus_KS[i]);       }
		for (int i = 0; i < (sizeof(CFKS_Announcer_Merasmus_KS_Godlike));       i++) { PrecacheSound(CFKS_Announcer_Merasmus_KS_Godlike[i]);       }
		for (int i = 0; i < (sizeof(CFKS_Announcer_Merasmus_KSEnded));       i++) { PrecacheSound(CFKS_Announcer_Merasmus_KSEnded[i]);       }
		for (int i = 0; i < (sizeof(CFKS_Announcer_Merasmus_EndedOwnKS));       i++) { PrecacheSound(CFKS_Announcer_Merasmus_EndedOwnKS[i]);       }
	}
	
	i_CFCurrentAnnouncer = announcer;
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

public Native_CF_SetKillstreak(Handle plugin, int numParams)
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
	 		CPrintToChatAll("%N is on a %i-player killstreak!", client, kills);
	 		
	 		if (i_CFCurrentAnnouncer == 0)
	 		{
	 			if (kills >= 20 && kills % 20 == 0)
	 			{
	 				EmitSoundToAll(CFKS_Announcer_Administrator_KS_Godlike[GetRandomInt(0, sizeof(CFKS_Announcer_Administrator_KS_Godlike) - 1)], _, _, 110);
	 			}
	 			else
	 			{
	 				EmitSoundToAll(CFKS_Announcer_Administrator_KS[GetRandomInt(0, sizeof(CFKS_Announcer_Administrator_KS) - 1)], _, _, 110);
	 			}
	 		}
	 		else
	 		{
	 			if (kills >= 20 && kills % 20 == 0)
	 			{
	 				EmitSoundToAll(CFKS_Announcer_Merasmus_KS_Godlike[GetRandomInt(0, sizeof(CFKS_Announcer_Merasmus_KS_Godlike) - 1)], _, _, 110);
	 			}
	 			else
	 			{
	 				EmitSoundToAll(CFKS_Announcer_Merasmus_KS[GetRandomInt(0, sizeof(CFKS_Announcer_Merasmus_KS) - 1)], _, _, 110);
	 			}
	 		}
	 		
	 		ksMessage = true;
	 	}
 		
 		if (kills == 0 && i_CFKillstreak[client] >= 10 && !ksMessage)
 		{
 			if (IsValidClient(killer) && killer != client)
 			{
	 			CPrintToChatAll("%N finally ended %N's %i-player killstreak!", killer, client, i_CFKillstreak[client]);
	 			
	 			if (i_CFCurrentAnnouncer == 0)
		 		{
		 			EmitSoundToAll(CFKS_Announcer_Administrator_KSEnded[GetRandomInt(0, sizeof(CFKS_Announcer_Administrator_KSEnded) - 1)], _, _, 110);
		 		}
		 		else
		 		{
		 			EmitSoundToAll(CFKS_Announcer_Merasmus_KSEnded[GetRandomInt(0, sizeof(CFKS_Announcer_Merasmus_KSEnded) - 1)], _, _, 110);
		 		}
	 		}
	 		else
	 		{
	 			CPrintToChatAll("%N brought an end to their own %i-player killstreak...", client, i_CFKillstreak[client]);
	 			
	 			EmitSoundToAll(CFKS_SFX_EndedOwnKS, _, _, 110);
	 			
	 			if (i_CFCurrentAnnouncer == 0)
		 		{
		 			EmitSoundToAll(CFKS_Announcer_Administrator_EndedOwnKS[GetRandomInt(0, sizeof(CFKS_Announcer_Administrator_EndedOwnKS) - 1)], _, _, 110);
		 		}
		 		else
		 		{
		 			EmitSoundToAll(CFKS_Announcer_Merasmus_EndedOwnKS[GetRandomInt(0, sizeof(CFKS_Announcer_Merasmus_EndedOwnKS) - 1)], _, _, 110);
		 		}
	 		}
 		}
 		
	 	i_CFKillstreak[client] = kills;
	 	SetEntProp(client, Prop_Send, "m_nStreaks", kills, _, 0);
	 	
	 	if (f_CFKillstreakForwardTime[client] < GetGameTime()) //Prevent infinite loops from happening if people call CF_SetKillstreak on the client in this forward.
	 	{
	 		f_CFKillstreakForwardTime[client] = GetGameTime() + 0.2;
	 		
		 	Call_StartForward(g_OnKillstreakChanged);
		
			Call_PushCell(client);
			Call_PushCell(kills);
	
			Call_Finish();
		}
	 	
	 	#if defined DEBUG_KILLSTREAKS
	 	CPrintToChatAll("Attempted to change %N's killstreak to %i.", client, kills);
	 	CPrintToChatAll("Their current killstreak is %i.", i_CFKillstreak[client]);
	 	#endif
	}
 		
 	return ReturnValue;
}