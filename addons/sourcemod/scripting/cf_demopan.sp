#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define DEMOPAN		"cf_demopan"
#define PASSIVES	"demopan_passives"
#define BOMB		"demopan_refined_bomb"
#define SHIELD		"demopan_medigun_shield"
#define TRADE		"demopan_ultimate"

int lgtModel;
int glowModel;

float f_WasCharging[MAXPLAYERS + 1] = { 0.0, ... };

#define PARTICLE_REFINED_RED			"mvm_cash_embers_red"
#define PARTICLE_REFINED_BLUE			"mvm_cash_embers"
#define PARTICLE_REFINED_TRAIL_RED		"flaregun_trail_red"
#define PARTICLE_REFINED_TRAIL_BLUE		"flaregun_trail_blue"
#define PARTICLE_REFINED_LAUNCH_RED		"spell_lightningball_hit_red"
#define PARTICLE_REFINED_LAUNCH_BLUE	"spell_lightningball_hit_blue"
#define PARTICLE_REFINED_SPAWN			"merasmus_spawn_flash2"
#define PARTICLE_REFINED_DESPAWN		"mvm_loot_smoke"
#define PARTICLE_SHIELD_RED				"drg_cow_explosioncore_charged"
#define PARTICLE_SHIELD_BLUE			"drg_cow_explosioncore_charged_blue"
#define PARTICLE_TRADE_WARNING_RED		"spell_lightningball_parent_red"
#define PARTICLE_TRADE_WARNING_BLUE		"spell_lightningball_parent_blue"
#define PARTICLE_TRADE_RED				"warp_version"
#define PARTICLE_TRADE_BLUE				"warp_version"
#define PARTICLE_TRADE_EXPLOSION		"ExplosionCore_MidAir"

#define PARTICLE_REFINED_EXPLODE		"mvm_cash_explosion"

#define MODEL_REFINED					"models/player/items/taunts/cash_wad.mdl"
#define MODEL_SHIELD_DAMAGED			"models/chaos_fortress/demopan/refined_shield.mdl"

#define SOUND_BOMB_EXPLODE				")weapons/explode1.wav"
#define SOUND_BOMB_LOOP					")weapons/cow_mangler_idle.wav"
#define SOUND_SHIELD_HIT				")misc/halloween/spell_lightning_ball_impact.wav"
#define SOUND_SHIELD_TAKEDAMAGE			")weapons/fx/rics/ric1.wav"
#define SOUND_SHIELD_STAGEBREAK			")chaos_fortress/demopan/demopan_shield_break_minor.mp3"
#define SOUND_SHIELD_FULLBREAK			")chaos_fortress/demopan/demopan_shield_break_final.mp3"
#define SOUND_TRADE_EXPLOSION_1			")weapons/explode1.wav"
#define SOUND_TRADE_EXPLOSION_2			")ui/notification_alert.wav"

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("PNPC.SetVelocity");
	MarkNativeAsOptional("PNPC_IsNPC");
	MarkNativeAsOptional("PNPC.i_Health.get");
	MarkNativeAsOptional("PNPC.b_IsABuilding.get");
	return APLRes_Success;
}

public void OnMapStart()
{
	PrecacheSound(SOUND_BOMB_EXPLODE);
	PrecacheSound(SOUND_BOMB_LOOP);
	PrecacheSound(SOUND_SHIELD_HIT);
	PrecacheSound(SOUND_SHIELD_TAKEDAMAGE);
	PrecacheSound(SOUND_SHIELD_STAGEBREAK);
	PrecacheSound(SOUND_SHIELD_FULLBREAK);
	PrecacheSound(SOUND_TRADE_EXPLOSION_1);
	PrecacheSound(SOUND_TRADE_EXPLOSION_2);
	
	PrecacheModel(MODEL_REFINED, true);
	PrecacheModel(MODEL_SHIELD_DAMAGED, true);
	
	lgtModel = PrecacheModel("materials/sprites/lgtning.vmt");
	glowModel = PrecacheModel("materials/sprites/glow02.vmt");
}

public void CF_OnCharacterCreated(int client)
{
	if (CF_HasAbility(client, DEMOPAN, PASSIVES))
	{
		SDKUnhook(client, SDKHook_PreThink, Passives_PreThink);
		SDKHook(client, SDKHook_PreThink, Passives_PreThink);
	}
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, DEMOPAN))
		return;
		
	if (StrContains(abilityName, BOMB) != -1)
		Bomb_Activate(client, abilityName);
		
	if (StrContains(abilityName, SHIELD) != -1)
		Shield_Activate(client, abilityName);
		
	if (StrContains(abilityName, TRADE) != -1)
		Trade_Activate(client, abilityName);
}

public void CF_OnHeldEnd_Ability(int client, bool resupply, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, DEMOPAN))
		return;
		
	if (StrContains(abilityName, BOMB) != -1)
		Bomb_Launch(client, abilityName, resupply);
		
	if (StrContains(abilityName, SHIELD) != -1)
		Shield_End(client, abilityName, resupply);
}

int i_HeldBomb[MAXPLAYERS+1] = { -1, ... };

bool b_IsABomb[2049] = { false, ... };

float f_Rotation[MAXPLAYERS + 1] = { 0.0, ... };
float f_NextBeamEffect[MAXPLAYERS + 1] = { 0.0, ... };
bool b_IsResourceProp[2049] = { false, ... };

Queue g_RefProps[MAXPLAYERS + 1] = { null, ... };

public Action CF_OnSpecialResourceApplied(int client, float current, float &amt)
{
	if (!CF_HasAbility(client, DEMOPAN, PASSIVES))
		return Plugin_Continue;
		
	DataPack pack = new DataPack();
	
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, RoundToFloor(amt));
	
	RequestFrame(Passives_Check, pack);
		
	return Plugin_Continue;
}

public void Passives_Check(DataPack pack)
{
	ResetPack(pack);
	
	int client = GetClientOfUserId(ReadPackCell(pack));
	int amt = ReadPackCell(pack);
	int maxAmt = RoundFloat(CF_GetMaxSpecialResource(client));
	if (amt > maxAmt)
		amt = maxAmt;
	
	delete pack;
		
	if (g_RefProps[client] == null)
	{
		delete g_RefProps[client];
		g_RefProps[client] = new Queue();
	}
		
	while (g_RefProps[client].Length > amt && !g_RefProps[client].Empty)
	{
		int prop = EntRefToEntIndex(g_RefProps[client].Pop());
		if (IsValidEntity(prop))
			RemoveEntity(prop);
	}
		
	while (g_RefProps[client].Length < amt)
	{
		int prop = Passives_SpawnProp(client);
		g_RefProps[client].Push(EntIndexToEntRef(prop));
	}
}

public int Passives_SpawnProp(int client)
{
	int phys = CreateEntityByName("prop_physics_override");
	int prop = CreateEntityByName("prop_dynamic_override");
	
	if (IsValidEntity(phys) && IsValidEntity(prop))
	{
		DispatchKeyValue(phys, "targetname", "refparent"); 
		DispatchKeyValue(phys, "spawnflags", "2"); 
		DispatchKeyValue(phys, "model", "models/props_c17/briefcase001a.mdl");
				
		DispatchSpawn(phys);
				
		ActivateEntity(phys);
		
		SetEntProp(phys, Prop_Data, "m_takedamage", 0, 1);
		
		if (IsValidClient(client))
		{
			SetEntPropEnt(phys, Prop_Data, "m_hOwnerEntity", client);
			SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", client);
		}
			
		SetEntProp(phys, Prop_Send, "m_fEffects", 32);
		
		SetEntityModel(prop, MODEL_REFINED);
					
		DispatchKeyValue(prop, "modelscale", "1.0");
		DispatchKeyValue(prop, "StartDisabled", "false");
					
		DispatchSpawn(prop);
					
		AcceptEntityInput(prop, "Enable");
		
		float pos[3], eyeLoc[3], randAng[3];
		GetClientEyePosition(client, eyeLoc);
		for (int vec = 0; vec < 3; vec++)
		{
			randAng[vec] = GetRandomFloat(0.0, 360.0);
		}
		
		Handle trace = TR_TraceRayFilterEx(eyeLoc, randAng, MASK_SOLID, RayType_Infinite, Passives_Trace);
		TR_GetEndPosition(pos, trace);
		delete trace;
		
		pos = ConstrainDistance(eyeLoc, pos, 180.0);
		
		TeleportEntity(phys, pos, NULL_VECTOR, NULL_VECTOR);
		TeleportEntity(prop, pos, NULL_VECTOR, NULL_VECTOR);
		SpawnParticle(pos, PARTICLE_REFINED_SPAWN, 2.0);
		
		DispatchKeyValue(prop, "spawnflags", "1");
		SetVariantString("!activator");
		AcceptEntityInput(prop, "SetParent", phys);
		SetEntProp(phys, Prop_Send, "m_nSolidType", 0);
	
		b_IsResourceProp[phys] = true;
	
		return phys;
	}
	
	return -1;
}

public Action Passives_PreThink(int client)
{
	if (g_RefProps[client] == null)
		return Plugin_Continue;
		
	Queue Cloned = g_RefProps[client].Clone();
	
	float increment = 360.0 / (float(Cloned.Length) - (IsValidEntity(EntRefToEntIndex(i_HeldBomb[client])) ? 1.0 : 0.0));
	float current = 0.0 + f_Rotation[client];
	
	while (!Cloned.Empty)
	{
		int prop = EntRefToEntIndex(Cloned.Pop());
		if (IsValidEntity(prop))
		{
			if (b_IsABomb[prop])
			{
				Passives_HoldProp(client, prop);
			}
			else
			{
				Passives_AdjustTargetPosition(client, prop, current);
				current += increment;
			}
		}
	}
	
	delete Cloned;
	
	f_Rotation[client] += 2.0;
	if (f_Rotation[client] >= 360.0)
		f_Rotation[client] = 0.0;
	
	return Plugin_Continue;
}

public void Passives_HoldProp(int client, int prop)
{
	float pos[3], eyeLoc[3], eyeAng[3], currentLoc[3];
	GetClientEyePosition(client, eyeLoc);
	GetClientEyeAngles(client, eyeAng);
		
	Handle trace = TR_TraceRayFilterEx(eyeLoc, eyeAng, MASK_SOLID, RayType_Infinite, Passives_Trace);
	TR_GetEndPosition(pos, trace);
	delete trace;
		
	pos = ConstrainDistance(eyeLoc, pos, 90.0);
	
	GetEntPropVector(prop, Prop_Send, "m_vecOrigin", currentLoc);
	eyeLoc[2] -= 20.0;
	int r = 255;
	int b = 120;
	if (TF2_GetClientTeam(client) == TFTeam_Blue)
	{
		r = 120;
		b = 25;
	}
	
	float gt = GetGameTime();
	if (gt > f_NextBeamEffect[client])
	{
		SpawnBeam_Vectors(eyeLoc, currentLoc, 0.1, r, 120, b, 255, lgtModel, _, _, _, 10.0);
		SpawnBeam_Vectors(eyeLoc, currentLoc, 0.1, r, 120, b, 160, glowModel, 6.0, 6.0, _, 10.0);
		
		f_NextBeamEffect[client] = gt + 0.05;
	}
	
	Passives_MoveProp(prop, pos);
}

public void Passives_AdjustTargetPosition(int client, int prop, float angle)
{
	float pos[3], eyeLoc[3], eyeAng[3];
	GetClientEyePosition(client, eyeLoc);
	eyeAng[0] = -30.0;
	eyeAng[1] = angle;
	eyeAng[2] = 0.0;
		
	Handle trace = TR_TraceRayFilterEx(eyeLoc, eyeAng, MASK_SOLID, RayType_Infinite, Passives_Trace);
	TR_GetEndPosition(pos, trace);
	delete trace;
		
	pos = ConstrainDistance(eyeLoc, pos, 75.0);
	
	Passives_MoveProp(prop, pos);
}

void Passives_MoveProp(int prop, float pos[3], bool spin = true)
{
	float currentLoc[3], targVel[3], currentAng[3];
	GetEntPropVector(prop, Prop_Send, "m_vecOrigin", currentLoc);
	GetEntPropVector(prop, Prop_Send, "m_angRotation", currentAng);

	if (spin)
	{
		for (int i = 0; i < 3; i++)
		{
			currentAng[i] += 2.0;
		}
	}

	SubtractVectors(pos, currentLoc, targVel);
	ScaleVector(targVel, 10.0);
	TeleportEntity(prop, NULL_VECTOR, currentAng, targVel);
}

public void Passives_RemoveAllRefProps(int client)
{
	if (g_RefProps[client] != null)
	{
		while (!g_RefProps[client].Empty)
		{
			int prop = EntRefToEntIndex(g_RefProps[client].Pop());
			if (IsValidEntity(prop))
				RemoveEntity(prop);
		}
	}
	
	delete g_RefProps[client];
}

public void Passives_RemoveProp(int client, int prop)
{
	Queue replacement = new Queue();
	int ref = EntIndexToEntRef(prop);
	
	while (!g_RefProps[client].Empty)
	{
		int current = g_RefProps[client].Pop();
		if (current != ref)
			replacement.Push(current);
	}
	
	delete g_RefProps[client];
	g_RefProps[client] = replacement.Clone();
	delete replacement;
	
	RemoveEntity(prop);
}

int Bomb_Particle[2049] = { -1, ... };

float Bomb_DMG[2049] = { 0.0, ... };
float Bomb_Radius[2049] = { 0.0, ... };
float Bomb_FalloffStart[2049] = { 0.0, ... };
float Bomb_FalloffMax[2049] = { 0.0, ... };

public void Bomb_Activate(int client, char abilityName[255])
{
	int bomb = -1;

	if (CF_HasAbility(client, DEMOPAN, PASSIVES) && g_RefProps[client] != null)
	{
		Queue cloned = g_RefProps[client].Clone();
		
		while (!IsValidEntity(bomb) && !cloned.Empty)
		{
			bomb = EntRefToEntIndex(cloned.Pop());
		}
		
		delete cloned;
	}
	else
	{
		bomb = Passives_SpawnProp(client);
		SDKUnhook(client, SDKHook_PreThink, Bomb_PreThink);
		SDKHook(client, SDKHook_PreThink, Bomb_PreThink);
	}
		
	if (IsValidEntity(bomb))
	{
		i_HeldBomb[client] = EntIndexToEntRef(bomb);
		b_IsABomb[bomb] = true;
		CF_PlayRandomSound(client, "", "sound_refined_bomb_prepare");
		EmitSoundToClient(client, SOUND_BOMB_LOOP);
		AttachParticleToEntity(bomb, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_REFINED_RED : PARTICLE_REFINED_BLUE, "", 6.0);
	}
}

public Action Bomb_PreThink(int client)
{
	int bomb = EntRefToEntIndex(i_HeldBomb[client]);
	if (!IsValidEntity(bomb))
		return Plugin_Stop;
		
	Passives_HoldProp(client, bomb);
	
	return Plugin_Continue;
}

public void Bomb_Launch(int client, char abilityName[255], bool resupply)
{
	StopSound(client, SNDCHAN_AUTO, SOUND_BOMB_LOOP);
	
	int bomb = EntRefToEntIndex(i_HeldBomb[client]);
	if (!IsValidEntity(bomb))
		return;
		
	bool hasPassives = CF_HasAbility(client, DEMOPAN, PASSIVES);
		
	if (resupply)
	{
		b_IsABomb[bomb] = false;
		if (!hasPassives)
			RemoveEntity(bomb);
	}
	else
	{
		float pos[3];
		GetEntPropVector(bomb, Prop_Send, "m_vecOrigin", pos);
		
		if (hasPassives)
			Passives_RemoveProp(client, bomb);
		else
			RemoveEntity(bomb);
		
		float velocity = CF_GetArgF(client, DEMOPAN, abilityName, "velocity");
		bomb = CF_FireGenericRocket(client, 0.0, velocity, false, false, DEMOPAN, Bomb_Explode);
		if (IsValidEntity(bomb))
		{
			SetEntityMoveType(bomb, MOVETYPE_FLYGRAVITY);
			
			Bomb_DMG[bomb] = CF_GetArgF(client, DEMOPAN, abilityName, "damage");
			Bomb_Radius[bomb] = CF_GetArgF(client, DEMOPAN, abilityName, "radius");
			Bomb_FalloffStart[bomb] = CF_GetArgF(client, DEMOPAN, abilityName, "falloff_start");
			Bomb_FalloffMax[bomb] = CF_GetArgF(client, DEMOPAN, abilityName, "falloff_max");
			
			SetEntityModel(bomb, MODEL_REFINED);
			Bomb_Particle[bomb] = EntIndexToEntRef(AttachParticleToEntity(bomb, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_REFINED_TRAIL_RED : PARTICLE_REFINED_TRAIL_BLUE, "", _, _, _, 5.0));
			
			RequestFrame(Bomb_Spin, EntIndexToEntRef(bomb));
			CF_PlayRandomSound(client, "", "sound_refined_bomb_launch");
		}
	}
	
	i_HeldBomb[client] = -1;
}

public void Bomb_Spin(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
	{
		float currentAng[3];
		GetEntPropVector(ent, Prop_Send, "m_angRotation", currentAng);

		for (int i = 0; i < 2; i++)
		{
			currentAng[i] += 2.0;
		}
		
		TeleportEntity(ent, NULL_VECTOR, currentAng, NULL_VECTOR);
		
		RequestFrame(Bomb_Spin, ref);
	}
}

public void Bomb_Explode(int bomb, int owner, int teamNum, int other, float pos[3])
{
	float dmg = Bomb_DMG[bomb];
	
	CF_GenericAOEDamage(owner, bomb, -1, dmg, DMG_CLUB|DMG_BLAST|DMG_ALWAYSGIB, Bomb_Radius[bomb], pos, Bomb_FalloffStart[bomb], Bomb_FalloffMax[bomb]);		
	
	EmitSoundToAll(SOUND_BOMB_EXPLODE, bomb, SNDCHAN_STATIC, _, _, _, GetRandomInt(90, 110));
	SpawnParticle(pos, PARTICLE_REFINED_EXPLODE, 3.0);
	
	RemoveEntity(bomb);
}

int i_Shield[MAXPLAYERS + 1] = { -1, ... };
int i_ShieldProp[2049] = { -1, ... };

bool b_HoldingShield[MAXPLAYERS + 1] = { false, ... };
bool b_IsShield[2049] = { false, ... };
bool b_ShieldIsDamaged[2049] = { false, ... };
bool b_PropIsBreaking[2049] = { false, ... };

float f_ShieldBaseSpeed[MAXPLAYERS + 1] = { 0.0, ... };
float f_ShieldDistance[MAXPLAYERS + 1] = { 0.0, ... };
float f_ShieldHeight[MAXPLAYERS + 1] = { 0.0, ... };
float f_ShieldDMG[2049] = { 0.0, ... };
float f_ShieldKB[2049] = { 0.0, ... };
float f_ShieldHitRate[2049] = { 0.0, ... };
float f_ShieldBlockCollision[2049] = { 0.0, ... };
float f_ShieldAnimTime[2049] = { 0.0, ... };
float f_NextShieldHit[2049][MAXPLAYERS + 1];
float f_OldPercentage[2049] = { 1.0, ... };

int Flash_BaseMainColor = 160;
int Flash_BaseSecondaryColor = 60;
int Flash_BaseAlpha = 180;
int Flash_MaxMainColor = 255;
int Flash_MaxSecondaryColor = 200;
int Flash_MaxAlpha = 255;
int Flash_MainDecay = 6;
int Flash_SecondaryDecay = 4;
int Flash_AlphaDecay = 4;

public void Shield_Activate(int client, char abilityName[255])
{
	float hp = CF_GetArgF(client, DEMOPAN, abilityName, "health");
	float scaling = CF_GetArgF(client, DEMOPAN, abilityName, "health_scaling");
	float lifespan = CF_GetArgF(client, DEMOPAN, abilityName, "lifespan");
	float scale = CF_GetArgF(client, DEMOPAN, abilityName, "scale");
	f_ShieldDistance[client] = CF_GetArgF(client, DEMOPAN, abilityName, "distance");
	f_ShieldHeight[client] = CF_GetArgF(client, DEMOPAN, abilityName, "height");
	char model[255];
	CF_GetArgS(client, DEMOPAN, abilityName, "model", model, sizeof(model));
	
	float pos[3], eyeLoc[3], ang[3], buffer[3];
	GetClientEyePosition(client, eyeLoc);
	GetClientEyeAngles(client, ang);
		
	Handle trace = TR_TraceRayFilterEx(eyeLoc, ang, MASK_SOLID, RayType_Infinite, Passives_Trace);
	TR_GetEndPosition(pos, trace);
	delete trace;
		
	pos = ConstrainDistance(eyeLoc, pos, f_ShieldDistance[client]);
	GetAngleVectors(ang, NULL_VECTOR, NULL_VECTOR, buffer);
	pos[0] -= f_ShieldHeight[client] * buffer[0];
	pos[1] -= f_ShieldHeight[client] * buffer[1];
	pos[2] -= f_ShieldHeight[client] * buffer[2];
	
	TFTeam team = TF2_GetClientTeam(client);

	float numFoes = 0.0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (CF_IsValidTarget(i, grabEnemyTeam(client)))
		{
			numFoes += 1.0;
		}
	}

	if (numFoes > 1.0)
		hp += scaling * numFoes;
	
	int shield = CF_CreateShieldWall(client, model, team == TFTeam_Red ? "0" : "1", scale, hp, pos, ang, lifespan);
	
	if (IsValidEntity(shield))
	{
		i_Shield[client] = EntIndexToEntRef(shield);
		b_HoldingShield[client] = true;
		b_IsShield[shield] = true;
		b_ShieldIsDamaged[shield] = false;
		f_ShieldAnimTime[shield] = 0.0;
		SetEntityMoveType(shield, MOVETYPE_NONE);
		SDKUnhook(client, SDKHook_PreThink, Shield_PreThink);
		SDKHook(client, SDKHook_PreThink, Shield_PreThink);
		f_ShieldBaseSpeed[client] = CF_GetCharacterSpeed(client);
		CF_SetCharacterSpeed(client, CF_GetArgF(client, DEMOPAN, abilityName, "speed"));
		CF_PlayRandomSound(client, "", "sound_medigun_shield_start");
		
		f_ShieldDMG[shield] = CF_GetArgF(client, DEMOPAN, abilityName, "damage");
		f_ShieldKB[shield] = CF_GetArgF(client, DEMOPAN, abilityName, "knockback");
		f_ShieldHitRate[shield] = CF_GetArgF(client, DEMOPAN, abilityName, "hit_rate");
		
		Shield_ClearHits(shield);
		
		int r = team == TFTeam_Red ? Flash_BaseMainColor : Flash_BaseSecondaryColor;
		int g = Flash_BaseSecondaryColor;
		int b = team == TFTeam_Red ? Flash_BaseSecondaryColor : Flash_BaseMainColor;
		int a = Flash_BaseAlpha;
		
		SetEntityRenderMode(shield, RENDER_TRANSALPHA);
		SetEntityRenderColor(shield, r, g, b, a);
		RequestFrame(Shield_FlashDecay, EntIndexToEntRef(shield));
		
		//Block collision while the user is holding the shield, otherwise you can trap people with them which is very bad.
		//f_ShieldBlockCollision[shield] = 999999.0;
	}
}

public void Shield_FlashDecay(int ref)
{
	int shield = EntRefToEntIndex(ref);
	if (!IsValidEntity(shield))
		return;
		
	if (b_ShieldIsDamaged[shield])
	{
		SetEntityRenderColor(shield, 0, 0, 0, 0);
		return;
	}
	
	TFTeam team = view_as<TFTeam>(GetEntProp(shield, Prop_Send, "m_iTeamNum"));
	
	int r, g, b, a;
	GetEntityRenderColor(shield, r, g, b, a);
	
	if (r > (team == TFTeam_Red ? Flash_BaseMainColor : Flash_BaseSecondaryColor))
	{
		r -= (team == TFTeam_Red ? Flash_MainDecay : Flash_SecondaryDecay);
		if (r < (team == TFTeam_Red ? Flash_BaseMainColor : Flash_BaseSecondaryColor))
			r = (team == TFTeam_Red ? Flash_BaseMainColor : Flash_BaseSecondaryColor);
	}
	
	if (g > Flash_BaseSecondaryColor)
	{
		g -= Flash_SecondaryDecay;
		if (g < Flash_BaseSecondaryColor)
			g = Flash_BaseSecondaryColor;
	}
	
	if (b > (team == TFTeam_Blue ? Flash_BaseMainColor : Flash_BaseSecondaryColor))
	{
		b -= (team == TFTeam_Blue ? Flash_MainDecay : Flash_SecondaryDecay);
		if (b < (team == TFTeam_Blue ? Flash_BaseMainColor : Flash_BaseSecondaryColor))
			b = (team == TFTeam_Blue ? Flash_BaseMainColor : Flash_BaseSecondaryColor);
	}
	
	if (a > Flash_BaseAlpha)
	{
		a -= Flash_AlphaDecay;
		if (a < Flash_BaseAlpha)
			a = Flash_BaseAlpha;
	}
	
	SetEntityRenderColor(shield, r, g, b, a);
	
	RequestFrame(Shield_FlashDecay, EntIndexToEntRef(shield));
}

public void Shield_ClearHits(int shield)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		f_NextShieldHit[shield][i] = 0.0;
	}
}

public void CF_OnFakeMediShieldCollision(int shield, int collider, int owner)
{
	if (!IsValidClient(owner) || !b_IsShield[shield])
		return;
		
	if (!IsValidMulti(collider, true, _, true, grabEnemyTeam(owner)))
		return;
		
	float gt = GetGameTime();
	if (f_NextShieldHit[shield][collider] > gt)
		return;
		
	int prop = EntRefToEntIndex(i_ShieldProp[shield]);
		
	bool AtLeastOne = false;
	if (f_ShieldDMG[shield] > 0.0)
	{
		DataPack pack = new DataPack();
		WritePackCell(pack, GetClientUserId(owner));
		WritePackCell(pack, GetClientUserId(collider));
		WritePackFloat(pack, f_ShieldDMG[shield]);
		RequestFrame(Shield_DealDamage, pack);
		
		AtLeastOne = true;
	}
	
	float pos[3];
	GetClientAbsOrigin(collider, pos);
	pos[2] += 40.0;
	
	if (f_ShieldKB[shield] > 0.0 && !TF2_IsPlayerInCondition(collider, TFCond_MegaHeal))
	{
		float dummy[3], ang[3], vel[3];
		GetAngleToPoint(shield, pos, dummy, ang, _, _, f_ShieldHeight[owner]);
		
		GetAngleVectors(ang, dummy, NULL_VECTOR, NULL_VECTOR);
		vel[0] = dummy[0] * f_ShieldKB[shield];
		vel[1] = dummy[1] * f_ShieldKB[shield];
		vel[2] = dummy[2] * f_ShieldKB[shield] + 200.0;
		
		if ((GetEntityFlags(collider) & FL_ONGROUND) != 0 || GetEntProp(collider, Prop_Send, "m_nWaterLevel") >= 1)
			vel[2] = fmax(vel[2], 310.0);
		else
			vel[2] += 50.0;
		
		TeleportEntity(collider, NULL_VECTOR, NULL_VECTOR, vel);
		
		AtLeastOne = true;
	}
	
	if (AtLeastOne)
	{
		SpawnParticle(pos, TF2_GetClientTeam(owner) == TFTeam_Red ? PARTICLE_SHIELD_RED : PARTICLE_SHIELD_BLUE, 3.0);
		EmitSoundToClient(collider, SOUND_SHIELD_HIT);
		EmitSoundToClient(owner, SOUND_SHIELD_HIT);
		f_NextShieldHit[shield][collider] = gt + f_ShieldHitRate[shield];
		
		Shield_Flash(IsValidEntity(prop) ? prop : shield);
		
		if (gt <= f_ShieldBlockCollision[shield])
		{
			f_ShieldBlockCollision[shield] = gt + 0.2;
		}
	}
}

public int Shield_CreateProp(int shield)
{
	if (!IsValidEntity(shield))
		return -1;
		
	int prop = CreateEntityByName("prop_dynamic_override");
	if (IsValidEntity(prop))
	{
		int owner = GetEntPropEnt(shield, Prop_Send, "m_hOwnerEntity");
		int team = GetEntProp(shield, Prop_Send, "m_iTeamNum");
		
		SetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity", owner);
		SetEntProp(prop, Prop_Send, "m_iTeamNum", team);

		SetEntityModel(prop, MODEL_SHIELD_DAMAGED);
		DispatchKeyValue(prop, "skin", team == view_as<int>(TFTeam_Red) ? "0" : "1");
		
		DispatchSpawn(prop);
					
		AcceptEntityInput(prop, "Enable");
		
		float pos[3], ang[3];
		GetEntPropVector(shield, Prop_Send, "m_vecOrigin", pos);
		GetEntPropVector(shield, Prop_Data, "m_angRotation", ang);

		float scale = GetEntPropFloat(shield, Prop_Send, "m_flModelScale");
		SetEntPropFloat(prop, Prop_Send, "m_flModelScale", scale); 

		//ang[1] += 180.0;
		TeleportEntity(prop, pos, ang, NULL_VECTOR);
		SetEntityRenderMode(prop, RENDER_TRANSALPHA);
	}
	
	return prop;
}

public Action CF_OnFakeMediShieldDamaged(int shield, int attacker, int inflictor, float &damage, int &damagetype, int owner)
{
	if (b_IsShield[shield] && damage > 0.0)
	{
		bool soundPlayed = false;
		float percentage = CF_GetShieldWallHealth(shield) / CF_GetShieldWallMaxHealth(shield);
		
		int prop = EntRefToEntIndex(i_ShieldProp[shield]);
		
		if (!b_ShieldIsDamaged[shield] && percentage <= 0.75)
		{
			prop = Shield_CreateProp(shield);
			if (IsValidEntity(prop))
			{
				i_ShieldProp[shield] = EntIndexToEntRef(prop);
				RequestFrame(Shield_FlashDecay, EntIndexToEntRef(prop));
				SetVariantString("idle_lightly_damaged");
				AcceptEntityInput(prop, "SetAnimation");
				EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 120);
				EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 120);
				EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 120);
				
				if (IsValidClient(owner))
					EmitSoundToClient(owner, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 120);
				
				if (IsValidClient(attacker))
					EmitSoundToClient(attacker, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 120);
					
				soundPlayed = true;
				
				SetEntityRenderColor(shield, 0, 0, 0, 0);
			}
			
			b_ShieldIsDamaged[shield] = true;
		}
		
		if (damage >= CF_GetShieldWallHealth(shield) && IsValidEntity(prop))
		{
			SetVariantString("break");
			AcceptEntityInput(prop, "SetAnimation");
			b_PropIsBreaking[prop] = true;
			CreateTimer(0.33, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
			RequestFrame(Shield_FadeOut, EntIndexToEntRef(prop));
			EmitSoundToAll(SOUND_SHIELD_FULLBREAK, prop, SNDCHAN_STATIC, 120);
			EmitSoundToAll(SOUND_SHIELD_FULLBREAK, prop, SNDCHAN_STATIC, 120);
			//EmitSoundToAll(SOUND_SHIELD_FULLBREAK, prop, SNDCHAN_STATIC, 120);
			
			if (IsValidClient(owner))
				EmitSoundToClient(owner, SOUND_SHIELD_FULLBREAK, _, SNDCHAN_STATIC, 120);
				
			if (IsValidClient(attacker))
				EmitSoundToClient(attacker, SOUND_SHIELD_FULLBREAK, _, SNDCHAN_STATIC, 120);
					
			soundPlayed = true;
		}
		else if (b_ShieldIsDamaged[shield] && IsValidEntity(prop) && f_ShieldAnimTime[prop] - GetGameTime() < 0.33)
		{
			if (percentage > 0.5)
			{
				SetVariantString("flinch_lightly_damaged");
				AcceptEntityInput(prop, "SetAnimation");
			}
			else if (percentage <= 0.5 && percentage > 0.25)
			{
				SetVariantString("flinch_mid_damaged");
				AcceptEntityInput(prop, "SetAnimation");
				if (f_OldPercentage[prop] > 0.5)
				{
					EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 100);
					EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 100);
					EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 100);
					
					if (IsValidClient(owner))
						EmitSoundToClient(owner, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 100);
				
					if (IsValidClient(attacker))
						EmitSoundToClient(attacker, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 100);
						
					soundPlayed = true;
				}
			}
			else
			{
				SetVariantString("flinch_heavily_damaged");
				AcceptEntityInput(prop, "SetAnimation");
				if (f_OldPercentage[prop] > 0.25)
				{
					EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 80);
					EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 80);
					EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 80);
					
					if (IsValidClient(owner))
						EmitSoundToClient(owner, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 80);
				
					if (IsValidClient(attacker))
						EmitSoundToClient(attacker, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 80);
						
					soundPlayed = true;
				}
			}
			
			f_ShieldAnimTime[prop] = GetGameTime() + 0.12;
			DataPack pack = new DataPack();
			CreateDataTimer(0.13, Shield_ResetSequence, pack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, EntIndexToEntRef(shield));
			WritePackCell(pack, EntIndexToEntRef(prop));
			
			f_OldPercentage[prop] = percentage;
		}
		
		Shield_Flash(IsValidEntity(prop) ? prop : shield);
		if (!soundPlayed)
			EmitSoundToAll(SOUND_SHIELD_TAKEDAMAGE, IsValidEntity(prop) ? prop : shield, SNDCHAN_STATIC, 80, _, _, GetRandomInt(80, 110));
	}
		
	return Plugin_Continue;
}

public void Shield_FadeOut(int ref)
{
	int prop = EntRefToEntIndex(ref);
	if (!IsValidEntity(prop))
		return;
		
	int r, g, b, a;
	GetEntityRenderColor(prop, r, g, b, a);
	a -= 6;
	if (a < 0)
		a = 0;
		
	SetEntityRenderColor(prop, r, g, b, a);
	
	RequestFrame(Shield_FadeOut, ref);
}

public Action Shield_ResetSequence(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int shield = EntRefToEntIndex(ReadPackCell(pack));
	int prop = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidEntity(shield) || !IsValidEntity(prop))
		return Plugin_Continue;
	
	if (GetGameTime() > f_ShieldAnimTime[prop])
	{
		float percentage = CF_GetShieldWallHealth(shield) / CF_GetShieldWallMaxHealth(shield);
		
		if (percentage > 0.5)
		{
			SetVariantString("idle_lightly_damaged");
		}
		else if (percentage <= 0.5 && percentage > 0.25)
		{
			SetVariantString("idle_mid_damaged");
		}
		else
		{
			SetVariantString("idle_heavily_damaged");
		}
		
		AcceptEntityInput(prop, "SetAnimation");
	}
	
	return Plugin_Continue;
}

public void Shield_DealDamage(DataPack pack)
{
	ResetPack(pack);
	int owner = GetClientOfUserId(ReadPackCell(pack));
	int collider = GetClientOfUserId(ReadPackCell(pack));
	float dmg = ReadPackFloat(pack);
	delete pack;
	
	if (IsValidClient(owner) && IsValidMulti(collider))
		SDKHooks_TakeDamage(collider, owner, owner, dmg);
}

public void Shield_Flash(int shield)
{
	TFTeam team = view_as<TFTeam>(GetEntProp(shield, Prop_Send, "m_iTeamNum"));
	
	int r = (team == TFTeam_Red ? Flash_MaxMainColor : Flash_MaxSecondaryColor);
	int g = Flash_MaxSecondaryColor;
	int b = (team == TFTeam_Blue ? Flash_MaxMainColor : Flash_MaxSecondaryColor);
	int a = Flash_MaxAlpha;
	
	SetEntityRenderColor(shield, r, g, b, a);
}

public Action Shield_PreThink(int client)
{
	int shield = EntRefToEntIndex(i_Shield[client]);
	
	if (!IsValidEntity(shield) || !b_HoldingShield[client])
		return Plugin_Stop;
		
	float pos[3], eyeLoc[3], eyeAng[3], buffer[3];
	GetClientEyePosition(client, eyeLoc);
	GetClientEyeAngles(client, eyeAng);
		
	Handle trace = TR_TraceRayFilterEx(eyeLoc, eyeAng, MASK_SOLID, RayType_Infinite, Passives_Trace);
	TR_GetEndPosition(pos, trace);
	delete trace;
		
	pos = ConstrainDistance(eyeLoc, pos, f_ShieldDistance[client]);
	
	GetAngleVectors(eyeAng, NULL_VECTOR, NULL_VECTOR, buffer);
	pos[0] -= f_ShieldHeight[client] * buffer[0];
	pos[1] -= f_ShieldHeight[client] * buffer[1];
	pos[2] -= f_ShieldHeight[client] * buffer[2];
	
	int frame = GetEntProp(shield, Prop_Send, "m_ubInterpolationFrame");
	
	TeleportEntity(shield, pos, eyeAng, NULL_VECTOR);
	
	SetEntProp(shield, Prop_Send, "m_ubInterpolationFrame", frame);
	
	int prop = EntRefToEntIndex(i_ShieldProp[shield]);
	if (IsValidEntity(prop))
	{
		//eyeAng[1] += 180.0;
		frame = GetEntProp(prop, Prop_Send, "m_ubInterpolationFrame");
	
		TeleportEntity(prop, pos, eyeAng, NULL_VECTOR);
	
		SetEntProp(prop, Prop_Send, "m_ubInterpolationFrame", frame);
	}
	
	return Plugin_Continue;
}

public void Shield_End(int client, char abilityName[255], bool resupply)
{
	int shield = EntRefToEntIndex(i_Shield[client]);
	if (IsValidEntity(shield))
	{
		if (resupply)
		{
			RemoveEntity(shield);
		}
		else
		{
			CF_PlayRandomSound(client, "", "sound_medigun_shield_end");
			f_ShieldBlockCollision[shield] = GetGameTime() + 0.2;
		}
	}
	
	CF_SetCharacterSpeed(client, f_ShieldBaseSpeed[client]);
	b_HoldingShield[client] = false;
}

float f_TradeEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_TradeNextHit[MAXPLAYERS + 1] = { 0.0, ... };
float f_TradeRadius[MAXPLAYERS + 1] = { 0.0, ... };
float f_TradeDamage[MAXPLAYERS + 1] = { 0.0, ... };
float f_TradeVelocity[MAXPLAYERS + 1] = { 0.0, ... };
float f_TradeHitRate[MAXPLAYERS + 1] = { 0.0, ... };

public void Trade_Activate(int client, char abilityName[255])
{
	float delay = CF_GetArgF(client, DEMOPAN, abilityName, "delay");
	float duration = CF_GetArgF(client, DEMOPAN, abilityName, "duration");
	
	f_TradeEndTime[client] = delay + duration + GetGameTime();
	f_TradeRadius[client] = CF_GetArgF(client, DEMOPAN, abilityName, "radius");
	f_TradeDamage[client] = CF_GetArgF(client, DEMOPAN, abilityName, "damage");
	f_TradeVelocity[client] = CF_GetArgF(client, DEMOPAN, abilityName, "velocity");
	f_TradeHitRate[client] = CF_GetArgF(client, DEMOPAN, abilityName, "hit_rate");
	f_TradeNextHit[client] = 0.0;
	
	SDKUnhook(client, SDKHook_PreThink, Trade_PreThink);
	//CF_AttachParticle(client, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_TRADE_WARNING_RED : PARTICLE_TRADE_WARNING_BLUE, "root", _, delay, 0.0, 0.0, 60.0 * CF_GetCharacterScale(client));
	TF2_AddCondition(client, TFCond_UberchargedCanteen, delay + 0.33);	//Give über for a little longer than the freeze time so snipers can't just cheese him out of his ult with a headshot.
	TF2_AddCondition(client, TFCond_FreezeInput, delay);
	TF2_AddCondition(client, TFCond_MegaHeal, delay + duration);
	SetEntityMoveType(client, MOVETYPE_NONE);
	CreateTimer(delay, Trade_Begin, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Trade_Begin(Handle begin, int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidClient(client))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		SDKUnhook(client, SDKHook_PreThink, Trade_PreThink);
		SDKHook(client, SDKHook_PreThink, Trade_PreThink);
		
		TF2_AddCondition(client, TFCond_HalloweenKartDash, f_TradeEndTime[client] - GetGameTime());
		
		float scale = CF_GetCharacterScale(client);
		
		for (float i = 0.0; i > -60.0; i -= 10.0)
		{
			CF_AttachParticle(client, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_TRADE_RED : PARTICLE_TRADE_BLUE, "flag", _, f_TradeEndTime[client] - GetGameTime(), 0.0, 0.0, i * scale);
		}
		
		float pos[3];
		GetClientAbsOrigin(client, pos);
		SpawnBigExplosion(pos);
	}
	
	return Plugin_Continue;
}

float Trade_KBVel[3];

public Action Trade_PreThink(int client)
{
	float gt = GetGameTime();
	if (gt >= f_TradeEndTime[client] || !IsPlayerAlive(client))
		return Plugin_Stop;
		
	float ang[3], vel[3], buffer[3], pos[3];
	GetClientEyeAngles(client, ang);
	GetClientAbsOrigin(client, pos);
	SpawnSpriteExplosion(pos);
	GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);
	
	for (int i = 0; i < 3; i++)
		vel[i] = buffer[i] * f_TradeVelocity[client];
		
	if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
		vel[2] = fmax(vel[2], 310.0);
	else
		vel[2] += 50.0;
		
	//int frame = GetEntProp(client, Prop_Send, "m_ubInterpolationFrame");
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
	//SetEntProp(client, Prop_Send, "m_ubInterpolationFrame", frame);
	Trade_KBVel = vel;
	
	if (gt >= f_TradeNextHit[client])
	{
		CF_GenericAOEDamage(client, client, client, f_TradeDamage[client], DMG_CLUB | DMG_BLAST | DMG_ALWAYSGIB, f_TradeRadius[client], pos, 99999.0, 0.0, false, false, false, _, _, DEMOPAN, Trade_OnHit);
		
		for (int i = 0; i < GetRandomInt(3, 5); i++)
		{
			GetClientAbsOrigin(client, pos);
			pos[0] += GetRandomFloat(-f_TradeRadius[client], f_TradeRadius[client]);
			pos[1] += GetRandomFloat(-f_TradeRadius[client], f_TradeRadius[client]);
			pos[2] += GetRandomFloat(-f_TradeRadius[client], f_TradeRadius[client]);
			SpawnSmallExplosion(pos);
		}
		
		EmitSoundToAll(SOUND_TRADE_EXPLOSION_1, client, SNDCHAN_STATIC);
		EmitSoundToAll(SOUND_TRADE_EXPLOSION_2, client, SNDCHAN_STATIC);
		
		f_TradeNextHit[client] = gt + f_TradeHitRate[client];
	}
		
	return Plugin_Continue;
}

public void Trade_OnHit(int victim, int &attacker, int &inflictor, int &weapon, float &damage)
{
	#if defined _pnpc_included_
	if (PNPC_IsNPC(victim))
		view_as<PNPC>(victim).SetVelocity(Trade_KBVel);
	else
		TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, Trade_KBVel);
	#else
	if (!IsABuilding(victim, false))
		TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, Trade_KBVel);
	#endif
}

public void CF_OnGenericProjectileTeamChanged(int entity, TFTeam newTeam)
{
	int oldParticle = EntRefToEntIndex(Bomb_Particle[entity]);
	if (!IsValidEntity(oldParticle))
		return;

	RemoveEntity(oldParticle);
	Bomb_Particle[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_REFINED_TRAIL_RED : PARTICLE_REFINED_TRAIL_BLUE, ""));
	SetEntityRenderColor(entity, newTeam == TFTeam_Red ? 255 : 120, 120, newTeam == TFTeam_Blue ? 255 : 120, 255);
}

public void OnMapEnd()
{
	for (int i = 0; i < 2049; i++)
	{
		b_IsResourceProp[i] = false;
	}
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
	{
		Bomb_Particle[entity] = -1;
		b_IsABomb[entity] = false;
		b_IsShield[entity] = false;
		b_PropIsBreaking[entity] = false;
		int prop = EntRefToEntIndex(i_ShieldProp[entity]);
		if (IsValidEntity(prop) && !b_PropIsBreaking[prop])
			RemoveEntity(prop);
		i_ShieldProp[entity] = -1;
		Shield_ClearHits(entity);
		
		if (b_IsResourceProp[entity])
		{
			float pos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			SpawnParticle(pos, PARTICLE_REFINED_DESPAWN, 2.0);
			
			int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			if (IsValidClient(owner) && CF_HasAbility(owner, DEMOPAN, PASSIVES))
			{
				Passives_RemoveProp(owner, entity);
			}
		}
		
		b_IsResourceProp[entity] = false;
	}
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	Passives_RemoveAllRefProps(client);
	i_HeldBomb[client] = -1;
	b_HoldingShield[client] = false;
	StopSound(client, SNDCHAN_AUTO, SOUND_BOMB_LOOP);
	SDKUnhook(client, SDKHook_PreThink, Trade_PreThink);
}

public bool Passives_Trace(entity, contentsMask)
{
	if (entity <= MaxClients)
		return false;
		
	if (b_IsResourceProp[entity] || b_IsShield[entity])
		return false;
	
	char classname[255];
	GetEntityClassname(entity, classname, sizeof(classname));
	
	if (StrContains(classname, "tf_projectile") != -1)
		return false;
		
	return true;
}

public Action CF_OnPassFilter(int ent1, int ent2, bool &result)
{
	if (b_IsResourceProp[ent1] || b_IsResourceProp[ent2])
	{
		result = false;
		return Plugin_Changed;
	}
	
	if (b_IsShield[ent1] && GetGameTime() <= f_ShieldBlockCollision[ent1])
	{
		TFTeam team = view_as<TFTeam>(GetEntProp(ent1, Prop_Send, "m_iTeamNum"));
		if (IsValidMulti(ent2, true, _, true, team == TFTeam_Red ? TFTeam_Blue : TFTeam_Red))
		{
			result = false;
			return Plugin_Changed;
		}
	}
	
	if (b_IsShield[ent2] && GetGameTime() <= f_ShieldBlockCollision[ent2])
	{
		TFTeam team = view_as<TFTeam>(GetEntProp(ent2, Prop_Send, "m_iTeamNum"));
		if (IsValidMulti(ent1, true, _, true, team == TFTeam_Red ? TFTeam_Blue : TFTeam_Red))
		{
			result = false;
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

public Action CF_OnShouldCollide(int ent1, int ent2, bool &result)
{
	if (b_IsResourceProp[ent1] || b_IsResourceProp[ent2])
	{
		result = false;
		return Plugin_Changed;
	}
	
	if (b_IsShield[ent1] && GetGameTime() <= f_ShieldBlockCollision[ent1])
	{
		TFTeam team = view_as<TFTeam>(GetEntProp(ent1, Prop_Send, "m_iTeamNum"));
		if (IsValidMulti(ent2, true, _, true, team == TFTeam_Red ? TFTeam_Blue : TFTeam_Red))
		{
			result = false;
			return Plugin_Changed;
		}
	}
	
	if (b_IsShield[ent2] && GetGameTime() <= f_ShieldBlockCollision[ent2])
	{
		TFTeam team = view_as<TFTeam>(GetEntProp(ent2, Prop_Send, "m_iTeamNum"));
		if (IsValidMulti(ent1, true, _, true, team == TFTeam_Red ? TFTeam_Blue : TFTeam_Red))
		{
			result = false;
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if (condition == TFCond_Charging)
		f_WasCharging[client] = GetGameTime() + 0.3;
}

public Action CF_OnTakeDamageAlive_Post(int victim, int attacker, int inflictor, float damage, int weapon)
{
	if (!IsValidEntity(weapon) || !IsValidMulti(attacker))
		return Plugin_Continue;

	if (GetEntityHealth(victim) > 0)
		return Plugin_Continue;

	float currentCharge = GetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter");
	if (GetGameTime() <= f_WasCharging[attacker] || TF2_IsPlayerInCondition(attacker, TFCond_Charging))
	{
		currentCharge += TF2CustAttr_GetFloat(weapon, "kills while charging restore charge", 0.0);
		f_WasCharging[attacker] = 0.0;
	}

	currentCharge += TF2CustAttr_GetFloat(weapon, "melee kills restore charge", 0.0);

	if (currentCharge > 100.0)
		currentCharge = 100.0;
	SetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter", currentCharge);

	return Plugin_Continue;
}