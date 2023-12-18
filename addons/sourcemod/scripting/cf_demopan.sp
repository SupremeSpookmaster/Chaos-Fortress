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

#define PARTICLE_REFINED_EXPLODE		"mvm_cash_explosion"

#define MODEL_REFINED					"models/player/items/taunts/cash_wad.mdl"

#define SOUND_BOMB_EXPLODE				"weapons/explode1.wav"
#define SOUND_BOMB_LOOP					"weapons/cow_mangler_idle.wav"
#define SOUND_SHIELD_HIT				"misc/halloween/spell_lightning_ball_impact.wav"

public void OnMapStart()
{
	PrecacheSound(SOUND_BOMB_EXPLODE);
	PrecacheSound(SOUND_BOMB_LOOP);
	PrecacheSound(SOUND_SHIELD_HIT);
	
	PrecacheModel(MODEL_REFINED);
	
	lgtModel = PrecacheModel("materials/sprites/lgtning.vmt");
	glowModel = PrecacheModel("materials/sprites/glow02.vmt");
}

DynamicHook g_DHookRocketExplode;

public void OnPluginStart()
{
	GameData gamedata = LoadGameConfigFile("chaos_fortress");
	g_DHookRocketExplode = DHook_CreateVirtual(gamedata, "CTFBaseRocket::Explode");
	delete gamedata;
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

public Action CF_OnPassFilter(int ent1, int ent2, bool &result)
{
	if (b_IsResourceProp[ent1] || b_IsResourceProp[ent2])
	{
		result = false;
		return Plugin_Changed;
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
	
	return Plugin_Continue;
}

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
		bomb = CF_FireGenericRocket(client, 0.0, velocity, false);
		if (IsValidEntity(bomb))
		{
			SetEntityMoveType(bomb, MOVETYPE_FLYGRAVITY);
			
			Bomb_DMG[bomb] = CF_GetArgF(client, DEMOPAN, abilityName, "damage");
			Bomb_Radius[bomb] = CF_GetArgF(client, DEMOPAN, abilityName, "radius");
			Bomb_FalloffStart[bomb] = CF_GetArgF(client, DEMOPAN, abilityName, "falloff_start");
			Bomb_FalloffMax[bomb] = CF_GetArgF(client, DEMOPAN, abilityName, "falloff_max");
			
			SetEntityModel(bomb, MODEL_REFINED);
			Bomb_Particle[bomb] = EntIndexToEntRef(AttachParticleToEntity(bomb, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_REFINED_TRAIL_RED : PARTICLE_REFINED_TRAIL_BLUE, "", _, _, _, 5.0));
			g_DHookRocketExplode.HookEntity(Hook_Pre, bomb, Bomb_Explode);
			
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

public MRESReturn Bomb_Explode(int bomb)
{
	int owner = GetEntPropEnt(bomb, Prop_Send, "m_hOwnerEntity");

	float dmg = Bomb_DMG[bomb];
	
	float pos[3];
	GetEntPropVector(bomb, Prop_Send, "m_vecOrigin", pos);
	
	Handle victims = CF_GenericAOEDamage(owner, bomb, -1, dmg, DMG_CLUB|DMG_BLAST|DMG_ALWAYSGIB, Bomb_Radius[bomb], pos, Bomb_FalloffStart[bomb],
										Bomb_FalloffMax[bomb]);		
	delete victims;
	
	EmitSoundToAll(SOUND_BOMB_EXPLODE, bomb, SNDCHAN_STATIC, _, _, _, GetRandomInt(90, 110));
	SpawnParticle(pos, PARTICLE_REFINED_EXPLODE, 3.0);
	
	RemoveEntity(bomb);
	
	return MRES_Supercede;
}

int i_Shield[MAXPLAYERS + 1] = { -1, ... };

bool b_HoldingShield[MAXPLAYERS + 1] = { false, ... };
bool b_IsShield[2049] = { false, ... };

float f_ShieldBaseSpeed[MAXPLAYERS + 1] = { 0.0, ... };
float f_ShieldDistance[MAXPLAYERS + 1] = { 0.0, ... };
float f_ShieldHeight[MAXPLAYERS + 1] = { 0.0, ... };
float f_ShieldDMG[2049] = { 0.0, ... };
float f_ShieldKB[2049] = { 0.0, ... };
float f_ShieldHitRate[2049] = { 0.0, ... };
float f_NextShieldHit[2049][MAXPLAYERS + 1];

public void Shield_Activate(int client, char abilityName[255])
{
	float hp = CF_GetArgF(client, DEMOPAN, abilityName, "health");
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
	
	int shield = CF_CreateShieldWall(client, model, TF2_GetClientTeam(client) == TFTeam_Red ? "0" : "1", scale, hp, pos, ang, lifespan);
	
	if (IsValidEntity(shield))
	{
		i_Shield[client] = EntIndexToEntRef(shield);
		b_HoldingShield[client] = true;
		b_IsShield[shield] = true;
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
	}
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
	if (!IsValidClient(owner))
		return;
		
	if (!IsValidMulti(collider, true, _, true, grabEnemyTeam(owner)))
		return;
		
	float gt = GetGameTime();
	if (f_NextShieldHit[shield][collider] > gt)
		return;
		
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
	
	if (f_ShieldKB[shield] > 0.0)
	{
		float dummy[3], ang[3], vel[3];
		GetAngleToPoint(shield, pos, dummy, ang, _, _, f_ShieldHeight[owner]);
		
		GetAngleVectors(ang, dummy, NULL_VECTOR, NULL_VECTOR);
		vel[0] = dummy[0] * f_ShieldKB[shield];
		vel[1] = dummy[1] * f_ShieldKB[shield];
		vel[2] = dummy[2] * f_ShieldKB[shield] + 100.0;
		
		TeleportEntity(collider, NULL_VECTOR, NULL_VECTOR, vel);
		
		AtLeastOne = true;
	}
	
	if (AtLeastOne)
	{
		SpawnParticle(pos, TF2_GetClientTeam(owner) == TFTeam_Red ? PARTICLE_SHIELD_RED : PARTICLE_SHIELD_BLUE, 3.0);
		EmitSoundToClient(collider, SOUND_SHIELD_HIT);
		EmitSoundToClient(owner, SOUND_SHIELD_HIT);
		f_NextShieldHit[shield][collider] = gt + f_ShieldHitRate[shield];
		
		Shield_Flash(shield, owner);
	}
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

public void Shield_Flash(int shield, int owner)
{
	if (!IsValidClient(owner))
		return;
		
	//TODO: MAKE IT FLASH
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
		}
	}
	
	CF_SetCharacterSpeed(client, f_ShieldBaseSpeed[client]);
	b_HoldingShield[client] = false;
}

public void Trade_Activate(int client, char abilityName[255])
{
	
}

public void CF_OnGenericProjectileTeamChanged(int entity, TFTeam newTeam)
{
	int oldParticle = EntRefToEntIndex(Bomb_Particle[entity]);
	if (IsValidEntity(oldParticle))
		RemoveEntity(oldParticle);
		
	Bomb_Particle[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_REFINED_TRAIL_RED : PARTICLE_REFINED_TRAIL_BLUE, ""));
	SetEntityRenderColor(entity, newTeam == TFTeam_Red ? 255 : 120, 120, newTeam == TFTeam_Blue ? 255 : 120, 255);
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
	{
		Bomb_Particle[entity] = -1;
		b_IsABomb[entity] = false;
		b_IsShield[entity] = false;
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

public void CF_OnCharacterRemoved(int client)
{
	Passives_RemoveAllRefProps(client);
	i_HeldBomb[client] = -1;
	b_HoldingShield[client] = false;
	StopSound(client, SNDCHAN_AUTO, SOUND_BOMB_LOOP);
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