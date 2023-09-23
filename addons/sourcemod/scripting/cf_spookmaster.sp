#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define SPOOKMASTER		"cf_spookmaster"
#define HARVESTER		"soul_harvester"
#define ABSORB			"soul_absorption"
#define DISCARD			"soul_discard"
#define CALCIUM			"calcium_cataclysm"

#define PARTICLE_DISCARD_RED		"spell_fireball_small_red"
#define PARTICLE_DISCARD_BLUE		"spell_fireball_small_blue"
#define PARTICLE_DISCARD_EXPLODE_RED	"spell_fireball_tendril_parent_red"
#define PARTICLE_DISCARD_EXPLODE2_RED	"spell_batball_impact_red"
#define PARTICLE_DISCARD_EXPLODE_BLUE	"spell_fireball_tendril_parent_blue"
#define PARTICLE_DISCARD_EXPLODE2_BLUE	"spell_batball_impact_blue"

#define SOUND_DISCARD_EXPLODE		"misc/halloween/spell_fireball_impact.wav"

#define MODEL_DISCARD				"models/chaos_fortress/spookmaster/skullrocket.mdl"

public void OnMapStart()
{
	PrecacheSound(SOUND_DISCARD_EXPLODE, true);
	
	PrecacheModel(MODEL_DISCARD, true);
}

DynamicHook g_DHookRocketExplode;

public void OnPluginStart()
{
	GameData gamedata = LoadGameConfigFile("chaos_fortress");
	g_DHookRocketExplode = DHook_CreateVirtual(gamedata, "CTFBaseRocket::Explode");
	delete gamedata;
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (StrContains(abilityName, HARVESTER) != -1)
		Harvester_Activate(client, abilityName);
		
	if (StrEqual(abilityName, ABSORB))
		Absorb_Activate(client, abilityName);
		
	if (StrContains(abilityName, DISCARD) != -1)
		Discard_Activate(client, abilityName);
}

int Harvester_LeftParticle[MAXPLAYERS + 1] = { -1, ... };
int Harvester_RightParticle[MAXPLAYERS + 1] = { -1, ... };

float Discard_Bonus[MAXPLAYERS + 1] = { 0.0, ... };

public void Harvester_Activate(int client, char abilityName[255])
{
	float resources = CF_GetSpecialResource(client);
	if (resources > 0.0)
	{
		int L = EntRefToEntIndex(Harvester_LeftParticle[client]);
		int R = EntRefToEntIndex(Harvester_RightParticle[client]);
			
		char LName[255], RName[255];
		if (TF2_GetClientTeam(client) == TFTeam_Red)
		{
			CF_GetArgS(client, SPOOKMASTER, abilityName, "left_red", LName, sizeof(LName));
			CF_GetArgS(client, SPOOKMASTER, abilityName, "right_red", RName, sizeof(RName));
		}
		else
		{
			CF_GetArgS(client, SPOOKMASTER, abilityName, "left_blue", LName, sizeof(LName));
			CF_GetArgS(client, SPOOKMASTER, abilityName, "right_blue", RName, sizeof(RName));
		}
		
		if (!IsValidEntity(L))
			Harvester_LeftParticle[client] = EntIndexToEntRef(CF_AttachParticle(client, LName, "effect_hand_L", true));
			
		if (!IsValidEntity(R))
			Harvester_RightParticle[client] = EntIndexToEntRef(CF_AttachParticle(client, RName, "effect_hand_R", true));
	}
	else
	{
		Harvester_DeleteParticles(client);
	}
}

public void Harvester_DeleteParticles(int client)
{
	int L = EntRefToEntIndex(Harvester_LeftParticle[client]);
	int R = EntRefToEntIndex(Harvester_RightParticle[client]);
	
	if (IsValidEntity(L))
		RemoveEntity(L);
		
	if (IsValidEntity(R))
		RemoveEntity(R);
		
	Harvester_LeftParticle[client] = -1;
	Harvester_RightParticle[client] = -1;
}

int Absorb_Uses[MAXPLAYERS + 1] = { 0, ... };
float Absorb_Health[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Speed[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Heal[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Swing[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Melee[MAXPLAYERS + 1] = { 0.0, ... };

public void Absorb_Activate(int client, char abilityName[255])
{
	Discard_Bonus[client] += CF_GetArgF(client, SPOOKMASTER, abilityName, "discard_bonus");
	
	float bonusHP = CF_GetArgF(client, SPOOKMASTER, abilityName, "health_bonus");
	float currentHP = GetAttributeValue(client, 26, 0.0);
	Absorb_Health[client] = bonusHP + currentHP;
	
	float bonusSpeed = CF_GetArgF(client, SPOOKMASTER, abilityName, "speed_bonus");
	float currentSpeed = GetAttributeValue(client, 107, 0.0);
	Absorb_Speed[client] = bonusSpeed + currentSpeed;
	
	Absorb_Heal[client] = CF_GetArgF(client, SPOOKMASTER, abilityName, "heal");
	
	int weapon = GetPlayerWeaponSlot(client, 2);
	if (!IsValidEntity(weapon))
		return;
		
	float bonusSwing = CF_GetArgF(client, SPOOKMASTER, abilityName, "swing_bonus");
	float currentSwing = GetAttributeValue(weapon, 396, 1.0);
	Absorb_Swing[client] = currentSwing - bonusSwing;
	
	float bonusDmg = CF_GetArgF(client, SPOOKMASTER, abilityName, "melee_bonus");
	float currentDmg = GetAttributeValue(weapon, 2, 1.0);
	Absorb_Melee[client] = bonusDmg + currentDmg;
	
	Absorb_SetStats(client);
	Absorb_Uses[client]++;
}

void Absorb_SetStats(int client, float NumTimes = 0.0)
{
	TF2Attrib_SetByDefIndex(client, 26, Absorb_Health[client]);
	TF2Attrib_SetByDefIndex(client, 107, Absorb_Speed[client]);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	
	DataPack pack = new DataPack();
	RequestFrame(Absorb_HealOnDelay, pack);
	WritePackCell(pack, GetClientUserId(client));
	WritePackFloat(pack, NumTimes > 0.0 ? Absorb_Heal[client] * NumTimes : Absorb_Heal[client])
	
	int weapon = GetPlayerWeaponSlot(client, 2);
	if (!IsValidEntity(weapon))
		return;
		
	TF2Attrib_SetByDefIndex(weapon, 396, Absorb_Swing[client]);
	TF2Attrib_SetByDefIndex(weapon, 2, Absorb_Melee[client]);
}

public void Absorb_HealOnDelay(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float amt = ReadPackFloat(pack);
	delete pack;
	
	CF_HealPlayer(client, client, amt, 1.0);
}

public void CF_OnCharacterRemoved(int client)
{
	Discard_Bonus[client] = 0.0;
	Absorb_Uses[client] = 0;
}

public void CF_OnCharacterCreated(int client)
{
	if (CF_HasAbility(client, SPOOKMASTER, ABSORB) && Absorb_Uses[client] > 0)
		Absorb_SetStats(client, float(Absorb_Uses[client]));
}

int Discard_Particle[2049] = { -1, ... };

float Discard_BaseDMG[2049] = { 0.0, ... };
float Discard_Radius[2049] = { 0.0, ... };
float Discard_FalloffStart[2049] = { 0.0, ... };
float Discard_FalloffMax[2049] = { 0.0, ... };
float Discard_DecayStart[2049] = { 0.0, ... };
float Discard_DecayAmt[2049] = { 0.0, ... };
float Discard_DecayMax[2049] = { 0.0, ... };
float Discard_BurnTime[2049] = { 0.0, ... };

public void Discard_Activate(int client, char abilityName[255])
{
	float velocity = CF_GetArgF(client, SPOOKMASTER, abilityName, "velocity");
	
	int skull = CF_FireGenericRocket(client, 0.0, velocity, false);
	if (IsValidEntity(skull))
	{
		Discard_BaseDMG[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "damage");
		Discard_BaseDMG[skull] += Discard_Bonus[client];
		Discard_Radius[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "radius");
		Discard_FalloffStart[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "falloff_start");
		Discard_FalloffMax[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "falloff_max");
		
		float time = CF_GetArgF(client, SPOOKMASTER, abilityName, "decay_start");
		if (time > 0.0)
		{
			CreateTimer(time, Discard_StartDecay, EntIndexToEntRef(skull), TIMER_FLAG_NO_MAPCHANGE);
			Discard_DecayStart[skull] = 0.0;
		}
		else
		{
			Discard_DecayStart[skull] = GetGameTime();
		}
			
		Discard_DecayAmt[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "decay");
		Discard_DecayMax[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "decay_max");
		Discard_BurnTime[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "afterburn");
		
		SetEntityModel(skull, MODEL_DISCARD);
		DispatchKeyValue(skull, "modelscale", "1.33");
		Discard_Particle[skull] = EntIndexToEntRef(AttachParticleToEntity(skull, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_DISCARD_RED : PARTICLE_DISCARD_BLUE, "bloodpoint"));
		
		ForceViewmodelAnimation(client, 18);
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, skull, Discard_ExplodePre);
	}
}

public Action Discard_StartDecay(Handle decay, int ref)
{
	int skull = EntRefToEntIndex(ref);
	if (!IsValidEntity(skull))
		return Plugin_Continue;
		
	Discard_DecayStart[skull] = GetGameTime();
	return Plugin_Continue;
}

public MRESReturn Discard_ExplodePre(int skull)
{
	int owner = GetEntPropEnt(skull, Prop_Send, "m_hOwnerEntity");
	TFTeam team = view_as<TFTeam>(GetEntProp(skull, Prop_Send, "m_iTeamNum"));
	
	float dmg = Discard_BaseDMG[skull];
	CPrintToChatAll("Base damage is %i", RoundFloat(dmg));
	if (Discard_DecayStart[skull] > 0.0)
	{
		float TotalDecay = (GetGameTime() - Discard_DecayStart[skull]) * Discard_DecayAmt[skull];
		if (TotalDecay > Discard_DecayMax[skull])
			TotalDecay = Discard_DecayMax[skull];
			
		dmg -= TotalDecay;
	}
	
	float pos[3];
	GetEntPropVector(skull, Prop_Send, "m_vecOrigin", pos);
	
	Handle victims = CF_GenericAOEDamage(owner, skull, -1, dmg, DMG_CLUB|DMG_BLAST|DMG_ALWAYSGIB, Discard_Radius[skull], pos, Discard_FalloffStart[skull],
										Discard_FalloffMax[skull], CF_DefaultTrace);
				
	for (int i = 0; i < GetArraySize(victims); i++)
	{
		int vic = GetArrayCell(victims, i);
		if (IsValidMulti(vic) && vic != owner)
			TF2_IgnitePlayer(vic, IsValidClient(owner) ? owner : 0, Discard_BurnTime[skull]);
	}
	
	delete victims;
	
	EmitSoundToAll(SOUND_DISCARD_EXPLODE, skull, SNDCHAN_STATIC, _, _, _, GetRandomInt(90, 110));
	SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_DISCARD_EXPLODE_RED : PARTICLE_DISCARD_EXPLODE_BLUE, 3.0);
	SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_DISCARD_EXPLODE2_RED : PARTICLE_DISCARD_EXPLODE2_BLUE, 3.0);
	
	RemoveEntity(skull);
	
	return MRES_Supercede;
}