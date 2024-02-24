#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define GADGETEER		"cf_gadgeteer"
#define TOSS			"gadgeteer_sentry_toss"

#define MODEL_TOSS		"models/weapons/w_models/w_toolbox.mdl"
#define MODEL_HOOK		"models/props_mining/cranehook001.mdl"
#define MODEL_ROPE_RED	"materials/cable/cable_red.vmt"
#define MODEL_ROPE_BLUE	"materials/cable/cable_blue.vmt"
#define MODEL_DRG		"models/weapons/w_models/w_drg_ball.mdl"

#define SOUND_TOSS_BUILD_1	"weapons/sentry_upgrading1.wav"
#define SOUND_TOSS_BUILD_2	"weapons/sentry_upgrading2.wav"
#define SOUND_TOSS_BUILD_3	"weapons/sentry_upgrading3.wav"
#define SOUND_TOSS_BUILD_4	"weapons/sentry_upgrading4.wav"
#define SOUND_TOSS_BUILD_5	"weapons/sentry_upgrading5.wav"
#define SOUND_TOSS_BUILD_6	"weapons/sentry_upgrading6.wav"
#define SOUND_TOSS_BUILD_7	"weapons/sentry_upgrading7.wav"
#define SOUND_TOSS_BUILD_8	"weapons/sentry_upgrading8.wav"

#define PARTICLE_TOSS_BUILD		"rd_robot_explosion"//"kart_impact_sparks"

public void OnMapStart()
{
	PrecacheModel(MODEL_TOSS);
	PrecacheModel(MODEL_HOOK);
	PrecacheModel(MODEL_ROPE_RED);
	PrecacheModel(MODEL_ROPE_BLUE);
	PrecacheModel(MODEL_DRG);
	
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

int Toss_Owner[2049] = { -1, ... };
int Toss_Max[MAXPLAYERS + 1] = { 0, ... };

float Toss_DMG[2049] = { 0.0, ... };
float Toss_KB[2049] = { 0.0, ... };
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
		
		GetClientEyeAngles(client, Toss_FacingAng[toolbox]);
		Toss_FacingAng[toolbox][0] = 0.0;
		Toss_FacingAng[toolbox][2] = 0.0;
		
		SetEntityModel(toolbox, MODEL_DRG);
		AttachModelToEntity(MODEL_TOSS, "", toolbox, _, TF2_GetClientTeam(client) == TFTeam_Red ? "0" : "1");
		
		float randAng[3];
		for (int i = 0; i < 3; i++)
			randAng[i] = GetRandomFloat(0.0, 360.0);
			
		TeleportEntity(toolbox, NULL_VECTOR, randAng);
		RequestFrame(Toss_Spin, EntIndexToEntRef(toolbox));
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, toolbox, Toss_Explode);
	}
}

public MRESReturn Toss_Explode(int toolbox)
{
	int owner = GetEntPropEnt(toolbox, Prop_Send, "m_hOwnerEntity");
	int team = GetEntProp(toolbox, Prop_Send, "m_iTeamNum");
	
	if (!IsValidClient(owner))
	{
		RemoveEntity(toolbox);
		return MRES_Supercede;
	}

	float pos[3];
	GetEntPropVector(toolbox, Prop_Send, "m_vecOrigin", pos);
	
	int chosen = GetRandomInt(0, sizeof(Toss_BuildSFX) - 1);
	EmitSoundToAll(Toss_BuildSFX[chosen], toolbox, SNDCHAN_STATIC, 120, _, _, GetRandomInt(90, 110));
	EmitSoundToAll(Toss_BuildSFX[chosen], toolbox, SNDCHAN_STATIC, 120, _, _, GetRandomInt(90, 110));
	SpawnParticle(pos, PARTICLE_TOSS_BUILD, 2.0);
	
	int prop = CreateEntityByName("prop_physics_override");
	if (IsValidEntity(prop))
	{
		DispatchKeyValue(prop, "targetname", "droneparent"); 
		DispatchKeyValue(prop, "model", MODEL_DRONE_PARENT);
		
		DispatchSpawn(prop);
		
		ActivateEntity(prop);
		
		if (IsValidClient(owner))
		{
			SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", owner);
			SetEntProp(prop, Prop_Send, "m_iTeamNum", GetClientTeam(owner));
		}
		
		DispatchKeyValue(prop, "skin", skin);
		char healthChar[16];
		Format(healthChar, sizeof(healthChar), "%i", RoundFloat(health));
		DispatchKeyValue(prop, "Health", healthChar);
		SetEntityHealth(prop, RoundFloat(health));
		
		char scalechar[16];
		Format(scalechar, sizeof(scalechar), "%f", scale);
		DispatchKeyValue(prop, "modelscale", scalechar);
		
		SetEntityGravity(prop, 0.0);
		
		//TODO: Spawn the prop_physics, make it float above the ground if spawned on the ground, if it spawns too close to a wall it should face away from the wall.
		//The prop_physics should be invisible, with a prop_dynamic parented to it to handle the visuals and animations.
		//The prop_physics needs to be added to the user's queue of sentries.
		//The prop_physics needs custom sentry logic (turns to face targets, shoots them, etc).
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
	Toss_Owner[sentry] = GetClientUserId(client);
	
	if (Toss_Max[client] <= 0)
		return;
		
	while (Toss_Sentries[client].Length > Toss_Max[client])
	{
		int oldest = EntRefToEntIndex(Toss_Sentries[client].Pop());
		if (IsValidEntity(oldest))
		{
			Toss_Owner[oldest] = -1;
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