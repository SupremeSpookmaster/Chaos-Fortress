#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define GADGETEER		"cf_gadgeteer"
#define TOSS			"gadgeteer_sentry_toss"

#define MODEL_TOSS		"models/weapons/w_models/w_toolbox.mdl"

#define SOUND_TOSS_BUILD_1	"weapons/sentry_upgrading1.wav"
#define SOUND_TOSS_BUILD_2	"weapons/sentry_upgrading2.wav"
#define SOUND_TOSS_BUILD_3	"weapons/sentry_upgrading3.wav"
#define SOUND_TOSS_BUILD_4	"weapons/sentry_upgrading4.wav"
#define SOUND_TOSS_BUILD_5	"weapons/sentry_upgrading5.wav"
#define SOUND_TOSS_BUILD_6	"weapons/sentry_upgrading6.wav"
#define SOUND_TOSS_BUILD_7	"weapons/sentry_upgrading7.wav"
#define SOUND_TOSS_BUILD_8	"weapons/sentry_upgrading8.wav"

#define PARTICLE_TOSS_BUILD		"kart_impact_sparks"

public void OnMapStart()
{
	PrecacheModel(MODEL_TOSS);
	
	PrecacheSound(SOUND_TOSS_BUILD_1);
	PrecacheSound(SOUND_TOSS_BUILD_2);
	PrecacheSound(SOUND_TOSS_BUILD_3);
	PrecacheSound(SOUND_TOSS_BUILD_4);
	PrecacheSound(SOUND_TOSS_BUILD_5);
	PrecacheSound(SOUND_TOSS_BUILD_6);
	PrecacheSound(SOUND_TOSS_BUILD_7);
	PrecacheSound(SOUND_TOSS_BUILD_8);
}

public const char Toss_BuildSFX[][] =
{
	SOUND_TOSS_BUILD_1,
	SOUND_TOSS_BUILD_2,
	SOUND_TOSS_BUILD_3,
	SOUND_TOSS_BUILD_4,
	SOUND_TOSS_BUILD_5,
	SOUND_TOSS_BUILD_6,
	SOUND_TOSS_BUILD_7,
	SOUND_TOSS_BUILD_8
};

DynamicHook g_DHookRocketExplode;

public void OnPluginStart()
{
	GameData gamedata = LoadGameConfigFile("chaos_fortress");
	g_DHookRocketExplode = DHook_CreateVirtual(gamedata, "CTFBaseRocket::Explode");
	delete gamedata;
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, GADGETEER))
		return;
	
	if (StrContains(abilityName, TOSS) != -1)
		Toss_Activate(client, abilityName);
}

int Toss_Level[2049] = { -1, ... };
int Toss_Owner[2049] = { -1, ... };
int Toss_Max[MAXPLAYERS + 1] = { 0, ... };

float Toss_DMG[2049] = { 0.0, ... };
float Toss_KB[2049] = { 0.0, ... };
float Toss_Scale[2049] = { 0.0, ... };
float Toss_FacingAng[2049][3];

Queue Toss_Sentries[MAXPLAYERS + 1] = { null, ... };

public void Toss_Activate(int client, char abilityName[255])
{
	Toss_Max[client] = CF_GetArgI(client, GADGETEER, abilityName, "sentry_max");
	float velocity = CF_GetArgF(client, GADGETEER, abilityName, "velocity");
	
	int toolbox = CF_FireGenericRocket(client, 0.0, velocity, false);
	if (IsValidEntity(toolbox))
	{
		float gravity = CF_GetArgF(client, GADGETEER, abilityName, "gravity");
		SetEntityMoveType(toolbox, MOVETYPE_FLYGRAVITY);
		SetEntityGravity(toolbox, gravity);
		
		Toss_DMG[toolbox] = CF_GetArgF(client, GADGETEER, abilityName, "damage");
		Toss_KB[toolbox] = CF_GetArgF(client, GADGETEER, abilityName, "knockback");
		
		Toss_Scale[toolbox] = CF_GetArgF(client, GADGETEER, abilityName, "sentry_scale");
		Toss_Level[toolbox] = CF_GetArgI(client, GADGETEER, abilityName, "sentry_level");
		
		GetClientEyeAngles(client, Toss_FacingAng[toolbox]);
		Toss_FacingAng[toolbox][0] = 0.0;
		Toss_FacingAng[toolbox][2] = 0.0;
		
		SetEntityModel(toolbox, MODEL_TOSS);
		DispatchKeyValue(toolbox, "skin", TF2_GetClientTeam(client) == TFTeam_Red ? "0" : "1");
		
		float randAng[3];
		for (int i = 0; i < 3; i++)
			randAng[i] = GetRandomFloat(0.0, 360.0);
			
		TeleportEntity(toolbox, NULL_VECTOR, randAng);
		RequestFrame(Toss_Spin, EntIndexToEntRef(toolbox));
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, toolbox, Toss_Explode);
	}
}

//Some of this was borrowed from RTD's "Spawn Sentry" perk and then modified a lot.
public MRESReturn Toss_Explode(int toolbox)
{
	int owner = GetEntPropEnt(toolbox, Prop_Send, "m_hOwnerEntity");
	int team = GetEntProp(toolbox, Prop_Send, "m_iTeamNum");

	float pos[3];
	GetEntPropVector(toolbox, Prop_Send, "m_vecOrigin", pos);
	
	EmitSoundToAll(Toss_BuildSFX[GetRandomInt(0, sizeof(Toss_BuildSFX) - 1)], toolbox, SNDCHAN_STATIC, _, _, _, GetRandomInt(90, 110));
	SpawnParticle(pos, PARTICLE_TOSS_BUILD, 2.0);
	
	//TODO: Figure out how to make wall/ceiling-mounted sentries align with the angle of the surface they are mounted to.
	//		- Probably make an "anchor point" at the exact spot the sentry wall/ceiling check detected a hit, then angle the sentry to face that point.
	//		- Also set the sentry's position to the anchor point's position.
	//		- If this doesn't work, we're going to need to make a method which calculates the slope of a given surface. That will be a NIGHTMARE.
	//TODO: Figure out how to make wall/ceiling-mounted sentries actually aim at what they're shooting.
	//		- There HAS to be a netprop for this somewhere. m_iDesiredBuildRotations is the most promising.
	//		- It's not the end of the world if this doesn't work. It will be a mild nuisance but whatever, can't win every battle with the Source engine.
	//TODO: Make sure toolboxes can't collide with sentries or each other.
	//TODO: Make sure the player can't collide with their own sentries.
	int sentry = CreateEntityByName("obj_sentrygun");
	if (IsValidEntity(sentry))
	{
		SetEntProp(sentry, Prop_Send, "m_iTeamNum", team);
		SetEntPropEnt(sentry, Prop_Send, "m_hOwnerEntity", owner);
		SetEntPropEnt(sentry, Prop_Send, "m_hBuilder", owner);
			
		DispatchKeyValue(sentry, "skin", team == view_as<int>(TFTeam_Red) ? "0" : "1");
		
		int level = Toss_Level[toolbox];
		if (level < 1 || level > 3)
		{
			SetEntProp(sentry, Prop_Send, "m_bMiniBuilding", 1);
			level = 1;
			
			float fMinsMini[3] = {-15.0, -15.0, 0.0};
			float fMaxsMini[3] = {15.0, 15.0, 49.5};
			ScaleVector(fMinsMini, Toss_Scale[toolbox]);
			ScaleVector(fMaxsMini, Toss_Scale[toolbox]);
			
			SetEntPropVector(sentry, Prop_Send, "m_vecMins", fMinsMini);
			SetEntPropVector(sentry, Prop_Send, "m_vecMaxs", fMaxsMini);
		}
		
		SetEntProp(sentry, Prop_Send, "m_iUpgradeLevel", level);
		SetEntProp(sentry, Prop_Send, "m_iHighestUpgradeLevel", level);
		
		SetEntPropFloat(sentry, Prop_Send, "m_flPercentageConstructed", 0.0);
		SetEntProp(sentry, Prop_Send, "m_bBuilding", 1);
		
		SetEntPropFloat(sentry, Prop_Send, "m_flModelScale", Toss_Scale[toolbox]); 
		
		SetEntProp(sentry, Prop_Data, "m_spawnflags", 4);
		
		DispatchSpawn(sentry);
		//ActivateEntity(sentry);
		
		if (Toss_GetDistanceToCeiling(pos, sentry) <= 50.0)
			Toss_FacingAng[toolbox][2] += 180.0;
		else if (Toss_GetDistanceToWall(pos, Toss_FacingAng[toolbox], sentry) <= 16.0)
			Toss_FacingAng[toolbox][0] -= 90.0;
			
		DispatchKeyValueVector(sentry, "origin", pos);
		DispatchKeyValueVector(sentry, "angles", Toss_FacingAng[toolbox]);
		TeleportEntity(sentry, pos, Toss_FacingAng[toolbox], NULL_VECTOR);
		
		Toss_AddToQueue(owner, sentry);
	}
	
	RemoveEntity(toolbox);
	
	return MRES_Supercede;
}

public void Toss_AddToQueue(int client, int sentry)
{
	if (!IsValidClient(client) || !IsValidEntity(sentry))
		return;
		
	if (Toss_Sentries[client] == null)
		Toss_Sentries[client] = new Queue();
		
	Toss_Sentries[client].Push(EntIndexToEntRef(sentry));
	
	if (Toss_Max[client] <= 0)
		return;
		
	while (Toss_Sentries[client].Length > Toss_Max[client])
	{
		int oldest = EntRefToEntIndex(Toss_Sentries[client].Pop());
		if (IsValidEntity(oldest))
		{
			SetVariantInt(0);
			AcceptEntityInput(oldest, "SetHealth");
			SDKHooks_TakeDamage(oldest, 0, 0, 999999.0);
		}
	}
}

public void Toss_RemoveFromQueue(int client, int sentry)
{
	if (!IsValidClient(client) || !IsValidEntity(sentry))
		return;
		
	if (Toss_Sentries[client] == null)
		return;
		
	Queue clone = Toss_Sentries[client].Clone();
	
	delete Toss_Sentries[client];
	Queue transfer = new Queue();
	
	while (!clone.Empty)
	{
		int ent = EntRefToEntIndex(clone.Pop());
		if (ent != sentry)
			transfer.Push(EntIndexToEntRef(ent));
	}
	
	Toss_Sentries[client] = transfer.Clone();
	delete transfer;
	delete clone;
}

public void Toss_Spin(int ref)
{
	int toolbox = EntRefToEntIndex(ref);
	if (!IsValidEntity(toolbox))
		return;
		
	float currentAng[3];
	GetEntPropVector(toolbox, Prop_Send, "m_angRotation", currentAng);

	for (int i = 0; i < 2; i++)
	{
		currentAng[i] += 2.0;
	}
		
	TeleportEntity(toolbox, NULL_VECTOR, currentAng, NULL_VECTOR);
	RequestFrame(Toss_Spin, ref);
}

public void CF_OnCharacterCreated(int client)
{
	
}

public void CF_OnCharacterRemoved(int client)
{
	
}

public void OnClientDisconnect(int client)
{
	delete Toss_Sentries[client];
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
	{
		if (Toss_Owner[entity] != -1)
		{
			int owner = GetClientOfUserId(Toss_Owner[entity]);
			if (IsValidClient(owner))
			{
				Toss_RemoveFromQueue(owner, entity);
			}
			
			Toss_Owner[entity] = -1;
		}
	}
}

int Toss_FilterUser = -1;

stock float Toss_GetDistanceToCeiling(float location[3], int sentry)
{
	float angles[3], otherLoc[3];
	angles[0] = -90.0;
	angles[1] = 0.0;
	angles[2] = 0.0;
	
	Toss_FilterUser = sentry;
	Handle trace = TR_TraceRayFilterEx(location, angles, MASK_ALL, RayType_Infinite, Toss_Trace);
	TR_GetEndPosition(otherLoc, trace);
	//CloseHandle(trace);
	delete trace;
	
	return GetVectorDistance(location, otherLoc);
}

stock float Toss_GetDistanceToWall(float location[3], float angles[3], int sentry)
{
	float otherLoc[3];
	
	Toss_FilterUser = sentry;
	Handle trace = TR_TraceRayFilterEx(location, angles, MASK_ALL, RayType_Infinite, Toss_Trace);
	TR_GetEndPosition(otherLoc, trace);
	//CloseHandle(trace);
	delete trace;
	
	return GetVectorDistance(location, otherLoc);
}

stock float Toss_GetDistanceToGround(float location[3], int sentry)
{
	float angles[3], otherLoc[3];
	angles[0] = 90.0;
	angles[1] = 0.0;
	angles[2] = 0.0;
	
	Toss_FilterUser = sentry;
	Handle trace = TR_TraceRayFilterEx(location, angles, MASK_ALL, RayType_Infinite, Toss_Trace);
	TR_GetEndPosition(otherLoc, trace);
	//CloseHandle(trace);
	delete trace;
	
	return GetVectorDistance(location, otherLoc);
}

public bool Toss_Trace(entity, contentsMask)
{
	if (entity > MaxClients)
	{
		char classname[255];
		GetEntityClassname(entity, classname, sizeof(classname));
		if (StrContains(classname, "tf_projectile") != -1)
			return false;
	}
	
	return entity != Toss_FilterUser;
}