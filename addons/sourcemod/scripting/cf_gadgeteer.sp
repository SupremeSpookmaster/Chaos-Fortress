#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <math>

#define GADGETEER		"cf_gadgeteer"
#define TOSS			"gadgeteer_sentry_toss"

#define MODEL_TOSS		"models/weapons/w_models/w_toolbox.mdl"
#define MODEL_HOOK		"models/props_mining/cranehook001.mdl"
#define MODEL_ROPE_RED	"materials/cable/cable_red.vmt"
#define MODEL_ROPE_BLUE	"materials/cable/cable_blue.vmt"
#define MODEL_DRG		"models/weapons/w_models/w_drg_ball.mdl"
#define MODEL_DRONE_PARENT	"models/props_c17/cashregister01a.mdl"
#define MODEL_DRONE_VISUAL	"models/player/items/all_class/pet_robro.mdl"

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
	PrecacheModel(MODEL_DRONE_PARENT);
	PrecacheModel(MODEL_DRONE_VISUAL);
	
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

CustomSentry Toss_SentryStats[2049];

enum struct CustomSentry
{
	int owner;
	int entity;
	int dummy;
	int target;
	
	float hoverHeight;
	float scale;
	float radiusDetection;
	float radiusFire;
	float turnRate;
	float fireRate;
	float damage;
	float maxHealth;
	float turnDirection;
	float startingYaw;
	float yawOffset;
	float NextShot;
	
	bool exists;
	bool shooting;

	void CreateFromArgs(int client, char abilityName[255], int entity)
	{
		this.owner = GetClientUserId(client);
		this.entity = EntIndexToEntRef(entity);
		
		this.hoverHeight = CF_GetArgF(client, GADGETEER, abilityName, "height");
		this.scale = CF_GetArgF(client, GADGETEER, abilityName, "scale");
		this.radiusDetection = CF_GetArgF(client, GADGETEER, abilityName, "radius_detect");
		this.radiusFire = CF_GetArgF(client, GADGETEER, abilityName, "radius_fire");
		this.turnRate = CF_GetArgF(client, GADGETEER, abilityName, "rotation");
		this.fireRate = CF_GetArgF(client, GADGETEER, abilityName, "rate");
		this.damage = CF_GetArgF(client, GADGETEER, abilityName, "damage");
		this.maxHealth = CF_GetArgF(client, GADGETEER, abilityName, "max_health");
	}
	
	void CopyFromOther(CustomSentry other, int entity)
	{
		this.owner = other.owner;
		this.entity = EntIndexToEntRef(entity);
		
		this.hoverHeight = other.hoverHeight;
		this.scale = other.scale;
		this.radiusDetection = other.radiusDetection;
		this.radiusFire = other.radiusFire;
		this.turnRate = other.turnRate;
		this.fireRate = other.fireRate;
		this.damage = other.damage;
		this.maxHealth = other.maxHealth;
	}
	
	void Activate()
	{
		int prop = EntRefToEntIndex(this.entity);
		int owner = GetClientOfUserId(this.owner);
		if (!IsValidEntity(prop) || !IsValidClient(owner))
			return;
			
			
		float angles[3];
		GetEntPropVector(prop, Prop_Send, "m_angRotation", angles);
		
		//SetEntProp(prop, Prop_Send, "m_fEffects", 32);
		TFTeam team = view_as<TFTeam>(GetEntProp(prop, Prop_Send, "m_iTeamNum"));
		int model = AttachModelToEntity(MODEL_DRONE_VISUAL, "", prop, _, team == TFTeam_Red ? "0" : "1");
		if (IsValidEntity(model))
		{
			this.dummy = EntIndexToEntRef(model);
			char scalechar[16];
			Format(scalechar, sizeof(scalechar), "%f", this.scale);
			DispatchKeyValue(model, "modelscale", scalechar);
			SetEntityGravity(model, 0.0);
			TeleportEntity(model, NULL_VECTOR, angles);
		}
		
		SetEntityGravity(prop, 0.0);
		SetEntityCollisionGroup(prop, 23);
		SetEntityMoveType(prop, MOVETYPE_FLY);
		
		Toss_AddToQueue(owner, prop);
		
		this.startingYaw = angles[1];
		CPrintToChatAll("Starting yaw: %f", this.startingYaw);
		this.turnDirection = 1.0;
		this.yawOffset = 0.0
		
		RequestFrame(Toss_CustomSentryLogic, this.entity);
		
		this.exists = true;
	}
	
	void Destroy()
	{
		//TODO: Play sounds, fancy explosion effects, etc
		this.exists = false;
		this.shooting = false;
	}
}

//TODO: Modify lerp logic into a custom function so that the sentries don't flip around wildly.
//Also, add a minimum turn speed so that lerping doesn't make them turn super slow.

public void Toss_CustomSentryLogic(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (!IsValidEntity(entity))
		return;
		
	int dummy = EntRefToEntIndex(Toss_SentryStats[entity].dummy);
	if (!IsValidEntity(dummy))
		return;
		
	TFTeam team = view_as<TFTeam>(GetEntProp(entity, Prop_Send, "m_iTeamNum"));
	int owner = GetClientOfUserId(Toss_SentryStats[entity].owner);
	int target = GetClientOfUserId(Toss_SentryStats[entity].target);
	float turnSpeed = Toss_SentryStats[entity].turnRate;
	
	float distance;
	float angles[3];
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	
	//We do not currently have a target, find one:
	if (!IsValidMulti(target))
	{
		target = Toss_GetClosestTarget(entity, team == TFTeam_Red ? TFTeam_Blue : TFTeam_Red, distance);
		if (distance > Toss_SentryStats[entity].radiusDetection)
			target = -1;
		//TODO: Emit targeting sound
	}
	
	if (IsValidMulti(target))	//We have a target, rotate to face them and fire if we are able.
	{
		float pos[3], otherPos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		GetClientAbsOrigin(target, otherPos);
		
		//The target has escaped our firing radius, un-lock.
		if (GetVectorDistance(pos, otherPos) > Toss_SentryStats[entity].radiusFire)
		{
			CPrintToChatAll("Disengaging target as they have escaped our range");
			target = -1;
			Toss_SentryStats[entity].target = -1;
		}
		else	//The target is still in our firing radius, turn to face them and fire if able.
		{
			otherPos[2] += 40.0 * (CF_GetCharacterScale(target));
			float dummyAng[3], targAng[3];
			GetAngleToPoint(entity, otherPos, dummyAng, targAng);
			
			//TODO: If the target pitch is negative, the sentry does a full flip before aiming, figure out a fix.
			for (int i = 0; i < 2; i++)
			{
				float test = targAng[i];
				float test2 = angles[i];
				if (test < 0.0)
					test *= -1.0;
				if (test2 < 0.0)
					test2 *= -1.0;
				
				//float diff;
				if (test > test2)
					angles[i] = ClampFloat(test2 + turnSpeed, test2, test);
				else
					angles[i] = ClampFloat(test2 - turnSpeed, test, test2);
					
				/*if (diff == 0.0)
					continue;
					
				
				if (test[i] > angles[i])
				{
					angles[i] = ClampFloat(angles[i] + turnSpeed, angles[i], targAng[i]);
				}
				else if (angles[i] > targAng[i])
				{
					angles[i] = ClampFloat(angles[i] - turnSpeed, targAng[i], angles[i]);
				}*/
			}
			
			TeleportEntity(entity, NULL_VECTOR, angles);
			
			float gt = GetGameTime();
			if (gt >= Toss_SentryStats[entity].NextShot && (angles[0] == targAng[0] && angles[1] == targAng[1]))
			{
				//TODO: VFX and SFX. Play sound, spawn muzzle flash, spawn laser beam. Also animations.
				Toss_SentryStats[entity].NextShot = gt + Toss_SentryStats[entity].fireRate;
				SDKHooks_TakeDamage(target, entity, owner, Toss_SentryStats[entity].damage, DMG_BULLET);
				CPrintToChatAll("FIRED AT %N", target);
			}
			
			Toss_SentryStats[entity].target = GetClientUserId(target);
		}
	}
	else	//We did not find a target, keep rotating normally.
	{
		turnSpeed *= 0.5;
		
		if (angles[0] != 0.0)
		{
			if (angles[0] < 0.0)
				angles[0] = ClampFloat(angles[0] + turnSpeed, -99999.0, 0.0);
			else if (angles[0] > 0.0)
				angles[0] = ClampFloat(angles[0] - turnSpeed, 0.0, 999999.0);
		}
		
		if (angles[2] != 0.0)
		{
			if (angles[2] < 0.0)
				angles[2] = ClampFloat(angles[2] + turnSpeed, -99999.0, 0.0);
			else if (angles[2] > 0.0)
				angles[2] = ClampFloat(angles[2] - turnSpeed, 0.0, 999999.0);
		}
		
		float yawOffset = Toss_SentryStats[entity].yawOffset;
		float turnDir = Toss_SentryStats[entity].turnDirection;
		
		yawOffset = ClampFloat(yawOffset + (turnSpeed * turnDir), -45.0, 45.0);
		if (yawOffset <= -45.0 || yawOffset >= 45.0)
			Toss_SentryStats[entity].turnDirection *= -1.0;
		
		Toss_SentryStats[entity].yawOffset = yawOffset;
		
		angles[1] = Toss_SentryStats[entity].startingYaw + yawOffset;
			
		TeleportEntity(entity, NULL_VECTOR, angles);
		//TeleportEntity(dummy, NULL_VECTOR, angles);
	}
		
	RequestFrame(Toss_CustomSentryLogic, ref);
}

//TODO: Convert this to a Chaos Fortress native with the ability to pass a function to filter out targets. 
//This native should cycle through all entities, not just players.
public int Toss_GetClosestTarget(int entity, TFTeam targetTeam, float &distance)
{
	int closest = -1;
	float closestDist = 999999.0;
	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidMulti(i, true, true, true, targetTeam))
			continue;
			
		float otherPos[3];
		GetClientAbsOrigin(i, otherPos);
		float dist = GetVectorDistance(pos, otherPos);
		
		if (dist < closestDist/* && Toss_HasLineOfSight(entity, i)TODO LOS CHECK*/)
		{
			closest = i;
			closestDist = dist;
			distance = closestDist;
		}
	}
	
	return closest;
}

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
		
		Toss_SentryStats[toolbox].CreateFromArgs(client, abilityName, toolbox);
		
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
		Toss_SentryStats[prop].CopyFromOther(Toss_SentryStats[toolbox], prop);
		
		DispatchKeyValue(prop, "targetname", "droneparent"); 
		DispatchKeyValue(prop, "model", MODEL_DRONE_PARENT);
		
		DispatchSpawn(prop);
		
		ActivateEntity(prop);
		
		if (IsValidClient(owner))
		{
			SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", owner);
			SetEntProp(prop, Prop_Send, "m_iTeamNum", team);
		}
		
		DispatchKeyValue(prop, "skin", TF2_GetClientTeam(owner) == TFTeam_Red ? "0" : "1");
		float health = Toss_SentryStats[prop].maxHealth;
		char healthChar[16];
		Format(healthChar, sizeof(healthChar), "%i", RoundFloat(health));
		DispatchKeyValue(prop, "Health", healthChar);
		SetEntityHealth(prop, RoundFloat(health));
		
		char scalechar[16];
		Format(scalechar, sizeof(scalechar), "%f", Toss_SentryStats[prop].scale);
		DispatchKeyValue(prop, "modelscale", scalechar);
		
		SetEntityGravity(prop, 0.0);
		
		TeleportEntity(prop, pos, Toss_FacingAng[toolbox]);
		Toss_SentryStats[prop].Activate();
		
		/*
		TODO: 
		• If it spawns too close to a wall it should face away from the wall.
		• The prop_physics needs custom sentry logic (turns to face targets, shoots them, etc). This logic can also handle the levitation effect.
			○ Don't forget: the sentry needs to have visuals indicating it is damaged, as well as a sound which is played to the owner.
			○ Detect if the owner is aiming at the sentry and display a worldtext entity showing its current HP if they are.
			○ Rotation works as intended (minus aiming at targets, that is not yet implemented).
		• Figure out why the custom model scale doesn't work for the prop_dynamic.
		• If a player switches from Gadgeteer to a different character, their sentries do not get destroyed. This is abusable and needs to be fixed.
			○ Add a "CF_OnCharacterSwitched" forward which gets called when a player spawns as a new character.
		• Need to make a custom-rigged and animated version of the Drone for animations. This model needs to have working physics.
			○ This should be done last so that we don't waste the effort if something makes the ability unsalvageable.
		• Since the model is small and doesn't have a lot of obvious team color which can be seen from a distance, attach a team-colored particle to it.
			○ The Payload cart lights would be perfect for this.
		*/
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
	Toss_DeleteSentries(client);
}

public void Toss_DeleteSentries(int client)
{
	if (Toss_Sentries[client] != null)
	{
		while (!Toss_Sentries[client].Empty)
		{
			int ent = EntRefToEntIndex(Toss_Sentries[client].Pop());
			if (IsValidEntity(ent))
				RemoveEntity(ent);
		}
	}
	
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
		
		if (Toss_SentryStats[entity].exists)
		{
			Toss_SentryStats[entity].Destroy();
		}
	}
}