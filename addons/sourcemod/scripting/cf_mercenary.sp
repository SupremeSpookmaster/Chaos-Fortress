#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define MERC		"cf_mercenary"
#define SPRINT		"merc_sprint"
#define FRAG		"merc_frag"

#define SPRINT_PARTICLE_RED		"scout_dodge_red"
#define SPRINT_PARTICLE_BLUE	"scout_dodge_blue"

public void OnMapStart()
{
	
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (StrContains(abilityName, SPRINT) != -1)
	{
		Sprint_Begin(client, abilityName);
	}
	
	if (StrContains(abilityName, FRAG) != -1)
	{
		Frag_Throw(client, abilityName);
	}
}

public void CF_OnHeldEnd_Ability(int client, bool resupply, char pluginName[255], char abilityName[255])
{
	if (StrContains(abilityName, SPRINT) != -1)
	{
		Sprint_End(client, false, resupply);
	}
}

public void CF_OnPlayerKilled(int victim, int inflictor, int attacker, int deadRinger)
{
	if (!deadRinger && IsValidClient(victim))
		Sprint_End(victim);
}

float Sprint_MaxTime[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_StartTime[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_CD[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_MinCD[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_MaxCD[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_Potency[MAXPLAYERS + 1] = { 0.0, ... };

int Sprint_Particle[MAXPLAYERS + 1] = { -1, ... };
int Sprint_Wearable[MAXPLAYERS + 1] = { -1, ... };

bool Sprint_Active[MAXPLAYERS + 1] = { false, ... };

CF_AbilityType Sprint_Slot[MAXPLAYERS + 1] = { CF_AbilityType_M2, ... };

public void Sprint_Begin(int client, char abilityName[255])
{
	if (!IsValidMulti(client))
		return;
		
	Sprint_MaxTime[client] = CF_GetArgF(client, MERC, abilityName, "max_duration");
	Sprint_CD[client] = CF_GetArgF(client, MERC, abilityName, "cooldown");
	Sprint_MinCD[client] = CF_GetArgF(client, MERC, abilityName, "min_cd");
	Sprint_MaxCD[client] = CF_GetArgF(client, MERC, abilityName, "max_cd");
	Sprint_Potency[client] = CF_GetArgF(client, MERC, abilityName, "potency");
	Sprint_Slot[client] = CF_GetAbilitySlot(client, MERC, abilityName);
	
	Sprint_Active[client] = true;
	Sprint_StartTime[client] = GetGameTime();
	
	Sprint_ApplyAttributes(client);
	SDKUnhook(client, SDKHook_PreThink, Sprint_PreThink);
	SDKHook(client, SDKHook_PreThink, Sprint_PreThink);
}

void Sprint_End(int client, bool TimeLimit = false, bool resupply = false)
{
	if (!Sprint_Active[client])
		return;
	
	Sprint_Active[client] = false;
	
	if (!resupply)
	{
		float useTime = GetGameTime() - Sprint_StartTime[client];
		float cd = useTime * Sprint_CD[client];
		
		if (cd > Sprint_MaxCD[client])
			cd = Sprint_MaxCD[client];
			
		if (cd < Sprint_MinCD[client])
			cd = Sprint_MinCD[client];
		
		if (TimeLimit)
		{
			switch(Sprint_Slot[client])
			{
				case CF_AbilityType_M2:
				{
					CF_EndHeldAbilitySlot(client, 2, false);
				}
				case CF_AbilityType_M3:
				{
					CF_EndHeldAbilitySlot(client, 3, false);
				}
				case CF_AbilityType_Reload:
				{
					CF_EndHeldAbilitySlot(client, 4, false);
				}
			}
		}
	
		CF_ApplyAbilityCooldown(client, cd, Sprint_Slot[client], true);
	}

	Sprint_RemoveAttributes(client);
	SDKUnhook(client, SDKHook_PreThink, Sprint_PreThink);
}

public void Sprint_RemoveAttributes(int client)
{
	int particle = EntRefToEntIndex(Sprint_Particle[client]);
	if (IsValidEntity(particle) && particle > MaxClients && particle < 2049)
	{
		RemoveEntity(particle);
		Sprint_Particle[client] = -1;
	}
	
	int wearable = EntRefToEntIndex(Sprint_Wearable[client]);
	if (IsValidEntity(wearable) && wearable > MaxClients && wearable < 2049)
	{
		TF2_RemoveWearable(client, wearable);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.0001);
	}
}

public void Sprint_ApplyAttributes(int client)
{
	Sprint_RemoveAttributes(client);
	
	int particle = CF_AttachParticle(client, TF2_GetClientTeam(client) == TFTeam_Red ? SPRINT_PARTICLE_RED : SPRINT_PARTICLE_BLUE, "root", _, _, _, 20.0);
	if (IsValidEntity(particle))
	{
		Sprint_Particle[client] = EntIndexToEntRef(particle);
	}
	
	char atts[255];
	Format(atts, sizeof(atts), "442 ; %.4f", Sprint_Potency[client]);
	int wearable = CF_AttachWearable(client, view_as<int>(CF_ClassToken_Soldier), false, 0, 0, atts);
	if (IsValidEntity(wearable))
	{
		Sprint_Wearable[client] = EntIndexToEntRef(wearable);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.0001);
	}
}

public Action Sprint_PreThink(int client)
{
	if (GetGameTime() >= (Sprint_StartTime[client] + Sprint_MaxTime[client]))
		Sprint_End(client, true);
		
	return Plugin_Continue;
}

public void Frag_Throw(int client, char abilityName[255])
{
	if (!IsValidMulti(client))
		return;
		
	float damage = CF_GetArgF(client, MERC, abilityName, "damage");
	float velocity = CF_GetArgF(client, MERC, abilityName, "velocity");
	
	int grenade = CreateEntityByName("tf_projectile_pipe");
	if (IsValidEntity(grenade))
	{
		int team = GetClientTeam(client);
		SetEntPropEnt(grenade, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(grenade,    Prop_Send, "m_bCritical", 0);
		SetEntProp(grenade,    Prop_Send, "m_iTeamNum",     team, 1);
		SetEntPropFloat(grenade, Prop_Send, "m_flDamage", damage);
		int offs = FindSendPropInfo("CTFGrenadePipebombProjectile", "m_bDefensiveBomb") - 4;
		SetEntDataFloat(grenade, offs, damage);
		SetEntData(grenade, FindSendPropInfo("CTFGrenadePipebombProjectile", "m_nSkin"), (team-2), 1, true);
		
		DispatchSpawn(grenade);

		float pos[3], vecAngles[3], vecVelocity[3];
		GetClientEyeAngles(client, vecAngles);
		GetClientEyePosition(client, pos);
		vecAngles[0] -= 8.0;
		
		vecVelocity[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*velocity;
		vecVelocity[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*velocity;
		vecVelocity[2] = Sine(DegToRad(vecAngles[0])) * velocity;
		vecVelocity[2] *= -1;
		
		TeleportEntity(grenade, pos, vecAngles, vecVelocity);
	}
}