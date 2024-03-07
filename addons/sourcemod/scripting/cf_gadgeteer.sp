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
#define MODEL_TOSS_GIB_1	"models/player/gibs/gibs_gear2.mdl"
#define MODEL_TOSS_GIB_2	"models/player/gibs/gibs_gear3.mdl"
#define MODEL_TOSS_GIB_3	"models/player/gibs/gibs_gear4.mdl"
#define MODEL_TOSS_GIB_4	"models/player/gibs/gibs_spring1.mdl"
#define MODEL_TOSS_GIB_5	"models/player/gibs/gibs_spring2.mdl"

#define SOUND_TOSS_BUILD_1	"weapons/sentry_upgrading1.wav"
#define SOUND_TOSS_BUILD_2	"weapons/sentry_upgrading2.wav"
#define SOUND_TOSS_BUILD_3	"weapons/sentry_upgrading3.wav"
#define SOUND_TOSS_BUILD_4	"weapons/sentry_upgrading4.wav"
#define SOUND_TOSS_BUILD_5	"weapons/sentry_upgrading5.wav"
#define SOUND_TOSS_BUILD_6	"weapons/sentry_upgrading6.wav"
#define SOUND_TOSS_BUILD_7	"weapons/sentry_upgrading7.wav"
#define SOUND_TOSS_BUILD_8	"weapons/sentry_upgrading8.wav"
#define SOUND_TOSS_DESTROYED	"weapons/teleporter_explode.wav"
#define SOUND_TOSS_TARGETLOCKED	"weapons/sentry_spot.wav"
#define SOUND_TOSS_TARGETWARNING	"weapons/sentry_spot_client.wav"
#define SOUND_TOSS_TOOLBOX_HIT_PLAYER	"misc/doomsday_cap_open_start.wav"

#define PARTICLE_TOSS_BUILD		"kart_impact_sparks"
#define PARTICLE_TOSS_DESTROYED	"rd_robot_explosion"

public void OnMapStart()
{
	PrecacheModel(MODEL_TOSS);
	PrecacheModel(MODEL_HOOK);
	PrecacheModel(MODEL_ROPE_RED);
	PrecacheModel(MODEL_ROPE_BLUE);
	PrecacheModel(MODEL_DRG);
	PrecacheModel(MODEL_DRONE_PARENT);
	PrecacheModel(MODEL_DRONE_VISUAL);
	PrecacheModel(MODEL_TOSS_GIB_1);
	PrecacheModel(MODEL_TOSS_GIB_2);
	PrecacheModel(MODEL_TOSS_GIB_3);
	PrecacheModel(MODEL_TOSS_GIB_4);
	PrecacheModel(MODEL_TOSS_GIB_5);
	
	PrecacheSound(SOUND_TOSS_BUILD_1);
	PrecacheSound(SOUND_TOSS_BUILD_2);
	PrecacheSound(SOUND_TOSS_BUILD_3);
	PrecacheSound(SOUND_TOSS_BUILD_4);
	PrecacheSound(SOUND_TOSS_BUILD_5);
	PrecacheSound(SOUND_TOSS_BUILD_6);
	PrecacheSound(SOUND_TOSS_BUILD_7);
	PrecacheSound(SOUND_TOSS_BUILD_8);
	PrecacheSound(SOUND_TOSS_DESTROYED);
	PrecacheSound(SOUND_TOSS_TARGETLOCKED);
	PrecacheSound(SOUND_TOSS_TARGETWARNING);
	PrecacheSound(SOUND_TOSS_TOOLBOX_HIT_PLAYER);
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

public const char Model_Gears[][255] =
{
	MODEL_TOSS_GIB_1,
	MODEL_TOSS_GIB_2,
	MODEL_TOSS_GIB_3,
	MODEL_TOSS_GIB_4,
	MODEL_TOSS_GIB_5
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
		this.turnDirection = 1.0;
		this.yawOffset = 0.0
		
		RequestFrame(Toss_CustomSentryLogic, this.entity);
		
		this.exists = true;
	}
	
	void Destroy()
	{
		int prop = EntRefToEntIndex(this.entity);
		if (IsValidEntity(prop))
		{
			float pos[3];
			GetEntPropVector(prop, Prop_Send, "m_vecOrigin", pos);
			
			SpawnParticle(pos, PARTICLE_TOSS_DESTROYED, 3.0);
			
			EmitSoundToAll(SOUND_TOSS_DESTROYED, prop, _, _, _, _, GetRandomInt(80, 110), -1);
			
			for (int i = 0; i < GetRandomInt(4, 6); i++)
			{
				float randAng[3], randVel[3];
				for (int vec = 0; vec < 3; vec++)
				{
					randAng[vec] = GetRandomFloat(0.0, 360.0);
					
					if (vec < 2)
						randVel[vec] = GetRandomFloat(0.0, 360.0);
					else
						randVel[vec] = GetRandomFloat(200.0, 800.0);
				}
				
				int gear = SpawnPhysicsProp(Model_Gears[GetRandomInt(0, sizeof(Model_Gears) - 1)], GetClientOfUserId(this.owner), "0", 99999.0, true, 1.0, pos, randAng, randVel, 5.0);
				
				if (IsValidEntity(gear))
				{
					SetEntityCollisionGroup(gear, 1);
					SetEntityRenderMode(gear, RENDER_TRANSALPHA);
					RequestFrame(Toss_FadeOutGib, EntIndexToEntRef(gear));
				}
			}
		}
		
		this.exists = false;
		this.shooting = false;
	}
}

public void Toss_FadeOutGib(int ref)
{
	int gear = EntRefToEntIndex(ref);
	if (!IsValidEntity(gear))
		return;
		
	int r, g, b, a;
	GetEntityRenderColor(gear, r, g, b, a);
	a -= 1;
	if (a < 1)
		RemoveEntity(gear);
	else
	{
		SetEntityRenderColor(gear, r, g, b, a);
		RequestFrame(Toss_FadeOutGib, ref);
	}
}

int Toss_TraceTarget = -1;
int Toss_TraceTeam = -1;

public bool Toss_IgnoreAllButTarget(entity, contentsMask)
{
	return entity == Toss_TraceTarget;
}

public bool Toss_OnlyHitEnemies(entity, contentsMask)
{
	TFTeam otherTeam = view_as<TFTeam>(GetEntProp(entity, Prop_Send, "m_iTeamNum"));
	TFTeam thisTeam = view_as<TFTeam>(Toss_TraceTeam);
	return (otherTeam == TFTeam_Blue && thisTeam == TFTeam_Red) || (otherTeam == TFTeam_Red && thisTeam == TFTeam_Blue);
}

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
		if (IsValidEntity(target))
		{
			if (distance > Toss_SentryStats[entity].radiusDetection)
				target = -1;
			else
			{
				//TODO: Lock-on should not play globally... why does it play globally...
				EmitSoundToAll(SOUND_TOSS_TARGETLOCKED, entity, _, _, _, _, _, -1);
				EmitSoundToClient(target, SOUND_TOSS_TARGETWARNING, _, _, 110);
			}
		}
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
		
			bool CanShoot = true;
			for (int i = 0; i < 2; i++)
			{
				angles[i] = ApproachAngle(targAng[i], angles[i], turnSpeed);
				float test1 = NormalizeAngle(targAng[i]);
				float diff = GetDifference(angles[i], test1);
				if (diff > 0.5)
					CanShoot = false;
			}
			
			TeleportEntity(entity, NULL_VECTOR, angles);
			
			float gt = GetGameTime();
			if (gt >= Toss_SentryStats[entity].NextShot && CanShoot)
			{
				//TODO: VFX and SFX. Play sound, spawn muzzle flash, spawn laser beam. Also animations.
				Toss_SentryStats[entity].NextShot = gt + Toss_SentryStats[entity].fireRate;
				
				//TODO: Instead of just directly dealing damage, call a trace which hits ALL enemies and damage the first thing that gets hit.
				//The sentry still will not fire unless it is aiming at the intended target, but the shot can now be blocked by obstacles.
				
				float endPos[3];
				int victim = target;
				Toss_TraceTeam = GetEntProp(entity, Prop_Send, "m_iTeamNum");
				TR_TraceRayFilter(pos, angles, MASK_SHOT, RayType_Infinite, Toss_OnlyHitEnemies, _, TRACE_ENTITIES_ONLY);
				victim = TR_GetEntityIndex();
				TR_GetEndPosition(endPos);
				
				SpawnBeam_Vectors(pos, otherPos, 0.33, 255, 0, 0, 255, PrecacheModel("materials/sprites/laserbeam.vmt"), 8.0, 8.0, _, 0.0);
				
				Toss_TraceTarget = target;
				GetPointFromAngles(pos, angles, 99999.0, otherPos, Toss_IgnoreAllButTarget, MASK_SHOT);
				SpawnBeam_Vectors(pos, otherPos, 0.1, 255, 255, 255, 255, PrecacheModel("materials/sprites/laserbeam.vmt"), _, _, _, 0.0);
				
				//if (IsValidEntity(victim))
				SDKHooks_TakeDamage(target, entity, owner, Toss_SentryStats[entity].damage, DMG_BULLET);
			}
			
			Toss_SentryStats[entity].target = GetClientUserId(target);
		}
	}
	else	//We did not find a target, keep rotating normally.
	{
		turnSpeed *= 0.5;
		
		if (angles[0] != 0.0)
		{
			angles[0] = ApproachAngle(0.0, angles[0], turnSpeed);
		}
		
		if (angles[2] != 0.0)
		{
			angles[2] = ApproachAngle(0.0, angles[2], turnSpeed);
		}
		
		float turnDir = Toss_SentryStats[entity].turnDirection;
		angles[1] = ApproachAngle(Toss_SentryStats[entity].startingYaw + (turnDir * 45.0), angles[1], turnSpeed);
		
		float diff = GetAngleDifference(angles[1], Toss_SentryStats[entity].startingYaw + (turnDir * 45.0));
		
		if (GetDifference(diff, turnSpeed) < turnSpeed)
			Toss_SentryStats[entity].turnDirection *= -1.0;
			
		TeleportEntity(entity, NULL_VECTOR, angles);
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
	EmitSoundToAll(Toss_BuildSFX[chosen], toolbox, _, _, _, _, GetRandomInt(90, 110), -1);
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
		• If it spawns too close to a wall it should face backwards, away from the wall.
		• The prop_physics needs the following custom sentry logic:
			○ Visuals indicating different states of damage, as well as a sound which is played to the owner when they are heavily damaged.
			○ A worldtext entity which is ONLY visible to the sentry's owner, displaying its HP.
			○ Levitation if the sentry spawns on the ground.
			○ Line-of-sight check for detecting targets.
			○ Rescue ranger bolts should be able to collide with these sentries and heal them.
			○ When sentries fire, they need a custom firing animation, the star shooter's laser attack sound, and a team-colored plasma beam indicating where they fired.
		• If a player switches from Gadgeteer to a different character, their sentries do not get destroyed. This is abusable and needs to be fixed.
			○ Add a "CF_OnCharacterSwitched" forward which gets called when a player spawns as a new character.
		• Need to make a custom-rigged and animated version of the Drone for animations. This model needs to have working physics, as well as a particle point for the muzzle flash.
			○ This should be done last so that we don't waste the effort if something makes the ability unsalvageable.
		• Since the model is small and doesn't have a lot of obvious team color which can be seen from a distance, attach a team-colored particle to it.
			○ The Payload cart lights would be perfect for this.
		• Sentries can block the payload cart, this needs to be fixed.
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