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

#define PARTICLE_REFINED_RED			"critical_rocket_red"
#define PARTICLE_REFINED_BLUE			"critical_rocket_blue"
#define PARTICLE_REFINED_LAUNCH_RED		"spell_lightningball_hit_red"
#define PARTICLE_REFINED_LAUNCH_BLUE	"spell_lightningball_hit_blue"

#define PARTICLE_REFINED_EXPLODE		"rd_robot_explosion"

#define MODEL_REFINED					"models/player/items/taunts/cash_wad.mdl"

#define SOUND_BOMB_EXPLODE				"weapons/explode1.wav"

public void OnMapStart()
{
	PrecacheSound(SOUND_BOMB_EXPLODE);
	
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
}

int i_HeldBomb[2049] = { -1, ... };

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
	float diff = amt - current;
	if (diff > -1.0 && diff < 1.0)
		return Plugin_Continue;
		
	DataPack pack = new DataPack();
	WritePackCell(pack, GetClientUserId(client));
	WritePackFloat(pack, diff);
	RequestFrame(Passives_Check, pack);
		
	return Plugin_Continue;
}

public void Passives_Check(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float diff = ReadPackFloat(pack);
	
	if (!CF_HasAbility(client, DEMOPAN, PASSIVES))
		return;
		
	if (g_RefProps[client] == null)
		g_RefProps[client] = new Queue();
		
	if (diff <= -1.0)
	{
		for (int i = 0; i < diff; i++)
		{
			if (!g_RefProps[client].Empty)
			{
				int prop = EntRefToEntIndex(g_RefProps[client].Pop());
				if (IsValidEntity(prop))
					RemoveEntity(prop);
			}
		}
	}
	else if (diff >= 1.0)
	{
		for (float i = 0.0; i < diff; i += 1.0)
		{
			Passives_AddProp(client);
		}
	}
}

public void Passives_AddProp(int client)
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
		
		DispatchKeyValue(prop, "spawnflags", "1");
		SetVariantString("!activator");
		AcceptEntityInput(prop, "SetParent", phys);
	
		b_IsResourceProp[phys] = true;
		g_RefProps[client].Push(EntIndexToEntRef(phys));
	}
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
		
		f_NextBeamEffect[client] = gt + 0.075;
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
		
	pos = ConstrainDistance(eyeLoc, pos, 95.0);
	
	Passives_MoveProp(prop, pos);
}

public void Passives_MoveProp(int prop, float pos[3])
{
	float currentLoc[3], targVel[3], currentAng[3];
	GetEntPropVector(prop, Prop_Send, "m_vecOrigin", currentLoc);
	GetEntPropVector(prop, Prop_Send, "m_angRotation", currentAng);

	for (int i = 0; i < 3; i++)
	{
		currentAng[i] += 2.0;
	}

	SubtractVectors(pos, currentLoc, targVel);
	ScaleVector(targVel, 5.0);
	TeleportEntity(prop, NULL_VECTOR, currentAng, targVel);
}

public bool Passives_Trace(entity, contentsMask)
{
	if (entity <= MaxClients)
		return false;
		
	if (b_IsResourceProp[entity])
		return false;
	
	char classname[255];
	GetEntityClassname(entity, classname, sizeof(classname));
	
	if (StrContains(classname, "tf_projectile") != -1)
		return false;
		
	return true;
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
		
		delete g_RefProps[client];
	}
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
	if (g_RefProps[client] == null)
		return;
		
	Queue cloned = g_RefProps[client].Clone();
	
	int bomb = -1;
	while (!IsValidEntity(bomb) && !cloned.Empty)
	{
		bomb = EntRefToEntIndex(cloned.Pop());
	}
		
	if (IsValidEntity(bomb))
	{
		i_HeldBomb[client] = EntIndexToEntRef(bomb);
		b_IsABomb[bomb] = true;
		CF_PlayRandomSound(client, "", "sound_refined_bomb_prepare");
	}
}

public void Bomb_Launch(int client, char abilityName[255], bool resupply)
{
	int bomb = EntRefToEntIndex(i_HeldBomb[client]);
	if (!IsValidEntity(bomb))
		return;
		
	if (resupply)
	{
		b_IsABomb[bomb] = false;
	}
	else
	{
		float pos[3];
		GetEntPropVector(bomb, Prop_Send, "m_vecOrigin", pos);
		
		Passives_RemoveProp(client, bomb);
		
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
			Bomb_Particle[bomb] = EntIndexToEntRef(AttachParticleToEntity(bomb, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_REFINED_RED : PARTICLE_REFINED_BLUE, "", _, _, _, 5.0));
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

		for (int i = 0; i < 3; i++)
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

public void Shield_Activate(int client, char abilityName[255])
{
	
}

public void Trade_Activate(int client, char abilityName[255])
{
	
}

public void CF_OnGenericProjectileTeamChanged(int entity, TFTeam newTeam)
{
	int oldParticle = EntRefToEntIndex(Bomb_Particle[entity]);
	if (IsValidEntity(oldParticle))
		RemoveEntity(oldParticle);
		
	Bomb_Particle[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_REFINED_RED : PARTICLE_REFINED_BLUE, ""));
	SetEntityRenderColor(entity, newTeam == TFTeam_Red ? 255 : 120, 120, newTeam == TFTeam_Blue ? 255 : 120, 255);
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
	{
		Bomb_Particle[entity] = -1;
		b_IsABomb[entity] = false;
	}
}

public void CF_OnCharacterRemoved(int client)
{
	Passives_RemoveAllRefProps(client);
}