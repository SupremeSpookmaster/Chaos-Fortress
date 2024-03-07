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
#define SOUND_TOSS_SHOOT			"weapons/shooting_star_shoot.wav"

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
	PrecacheSound(SOUND_TOSS_SHOOT);
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
int Toss_ToolboxOwner[2049] = { -1, ... };

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
	float superchargeDuration;
	float superchargeFire;
	float superchargeTurn;
	float superchargeEndTime;
	
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
		this.superchargeDuration = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_duration");
		this.superchargeFire = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_fire");
		this.superchargeTurn = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_turn");
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
		this.superchargeDuration = other.superchargeDuration;
		this.superchargeFire = other.superchargeFire;
		this.superchargeTurn = other.superchargeTurn;
	}
	
	void Activate(bool supercharged)
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
		SetEntityMoveType(prop, MOVETYPE_VPHYSICS);
		
		Toss_AddToQueue(owner, prop);
		
		this.startingYaw = angles[1];
		this.turnDirection = 1.0;
		this.yawOffset = 0.0
		
		RequestFrame(Toss_CustomSentryLogic, this.entity);
		
		if (supercharged)
		{
			this.superchargeEndTime = GetGameTime() + this.superchargeDuration;
			//TODO: PARTICLE, SOUND
		}
		
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

public bool Toss_IgnoreDrones(entity, contentsMask)
{
	return !Toss_SentryStats[entity].exists && entity > MaxClients;
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
		
	float gt = GetGameTime();
		
	TFTeam team = view_as<TFTeam>(GetEntProp(entity, Prop_Send, "m_iTeamNum"));
	int owner = GetClientOfUserId(Toss_SentryStats[entity].owner);
	int target = GetClientOfUserId(Toss_SentryStats[entity].target);
	float turnSpeed = Toss_SentryStats[entity].turnRate;
	
	if (gt <= Toss_SentryStats[entity].superchargeEndTime)
		turnSpeed *= Toss_SentryStats[entity].superchargeTurn;
	
	float distance;
	float angles[3], pos[3], vel[3];
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vel);
	
	float groundDist = Toss_GetDistanceToSurface(entity, 90.0, 0.0, 0.0);
	if (groundDist < Toss_SentryStats[entity].hoverHeight)
	{
		vel[2] = LerpFloat(0.01, vel[2], 100.0);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);
	}
	else if (vel[2] != 0.0)
	{
		if (vel[2] > 0.0)
			vel[2] = ClampFloat(vel[2] - 4.0, 0.0, 9999.0);
		else
			vel[2] = ClampFloat(vel[2] + 4.0, -9999.0, 0.0);
			
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);
	}
	
	//We do not currently have a target or our target is hiding behind something, find a new target:
	if (!IsValidMulti(target) || !Toss_HasLineOfSight(entity, target))
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
		float otherPos[3];
		GetClientAbsOrigin(target, otherPos);
		
		//The target has escaped our firing radius, un-lock.
		if (GetVectorDistance(pos, otherPos) > Toss_SentryStats[entity].radiusFire)
		{
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
			
			if (angles[2] != 0.0)
			{
				angles[2] = ApproachAngle(0.0, angles[2], turnSpeed);
			}
			
			TeleportEntity(entity, NULL_VECTOR, angles);
			
			if (gt >= Toss_SentryStats[entity].NextShot && CanShoot)
			{
				//TODO: VFX and SFX. Spawn muzzle flash, spawn laser beam. Also animations.
				Toss_SentryStats[entity].NextShot = gt + (Toss_SentryStats[entity].fireRate / (gt <= Toss_SentryStats[entity].superchargeEndTime ? Toss_SentryStats[entity].superchargeFire : 1.0));
				
				float endPos[3];
				int victim = target;
				Toss_TraceTeam = GetEntProp(entity, Prop_Send, "m_iTeamNum");
				TR_TraceRayFilter(pos, angles, MASK_SHOT, RayType_Infinite, Toss_OnlyHitEnemies);
				victim = TR_GetEntityIndex();
				TR_GetEndPosition(endPos);
				
				SpawnBeam_Vectors(pos, otherPos, 0.33, 255, 0, 0, 255, PrecacheModel("materials/sprites/laserbeam.vmt"), 8.0, 8.0, _, 0.0);
				
				Toss_TraceTarget = target;
				GetPointFromAngles(pos, angles, 99999.0, otherPos, Toss_IgnoreAllButTarget, MASK_SHOT);
				SpawnBeam_Vectors(pos, otherPos, 0.1, 255, 255, 255, 255, PrecacheModel("materials/sprites/laserbeam.vmt"), _, _, _, 0.0);
				
				if (IsValidEntity(victim))
					SDKHooks_TakeDamage(victim, entity, owner, Toss_SentryStats[entity].damage, DMG_BULLET);
				
				EmitSoundToAll(SOUND_TOSS_SHOOT, entity, _, _, _, _, _, -1);
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
		
		if (dist < closestDist && Toss_HasLineOfSight(entity, i))
		{
			closest = i;
			closestDist = dist;
			distance = closestDist;
		}
	}
	
	return closest;
}

public float Toss_GetDistanceToSurface(int entity, float pitchMod, float yawMod, float rollMod)
{
	if (!IsValidEntity(entity))
		return 0.0;
		
	float pos[3], ang[3], endPos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	ang[0] = pitchMod;
	ang[1] = yawMod;
	ang[2] = rollMod;
	
	TR_TraceRayFilter(pos, ang, MASK_SHOT, RayType_Infinite, Toss_IgnoreDrones);
	
	if (TR_DidHit())
	{
		TR_GetEndPosition(endPos);
		return GetVectorDistance(pos, endPos);
	}
	
	return 0.0;
}

public bool Toss_HasLineOfSight(int entity, int target)
{
	if (!IsValidEntity(entity) || !IsValidEntity(target))
		return false;
		
	float pos[3], otherPos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", otherPos);
	
	if (IsValidClient(target))
		otherPos[2] += 40.0 * CF_GetCharacterScale(target);
		
	Handle trace = TR_TraceRayFilterEx(pos, otherPos, MASK_SHOT, RayType_EndPoint, Toss_IgnoreDrones);
	bool DidHit = TR_DidHit(trace);
	delete trace;
	return !DidHit;
}

public void Toss_Activate(int client, char abilityName[255])
{
	Toss_Max[client] = CF_GetArgI(client, GADGETEER, abilityName, "sentry_max");
	float velocity = CF_GetArgF(client, GADGETEER, abilityName, "velocity");
	
	float pos[3], ang[3], vel[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	GetVelocityInDirection(ang, velocity, vel);
	
	int toolbox = CF_FireGenericRocket(client, 0.0, velocity, false);
	if (IsValidEntity(toolbox))
	{
		float gravity = CF_GetArgF(client, GADGETEER, abilityName, "gravity");
		SetEntityMoveType(toolbox, MOVETYPE_FLYGRAVITY);
		SetEntityGravity(toolbox, gravity);
		
		Toss_DMG[toolbox] = CF_GetArgF(client, GADGETEER, abilityName, "damage");
		Toss_KB[toolbox] = CF_GetArgF(client, GADGETEER, abilityName, "knockback");
		float CoolMult = CF_GetArgF(client, GADGETEER, abilityName, "trickshot_mult");
		
		Toss_SentryStats[toolbox].CreateFromArgs(client, abilityName, toolbox);
		
		GetClientEyeAngles(client, Toss_FacingAng[toolbox]);
		Toss_FacingAng[toolbox][0] = 0.0;
		Toss_FacingAng[toolbox][2] = 0.0;
		
		SetEntityModel(toolbox, MODEL_DRG);
		DispatchKeyValue(toolbox, "modelscale", "0.00001");
		
		int phys = AttachPhysModelToEntity(MODEL_TOSS, "", toolbox, false, 999.0, _, TF2_GetClientTeam(client) == TFTeam_Red ? "0" : "1");
		
		Toss_ToolboxOwner[phys] = EntIndexToEntRef(toolbox);
		ScaleHitboxSize(phys, CoolMult);
		SDKHook(phys, SDKHook_OnTakeDamage, Toss_ToolboxDamaged);
		SDKHook(phys, SDKHook_Touch, Toss_ToolboxTouch);
		
		//SetEntProp(phys, Prop_Data, "m_usSolidFlags", 28);
		SetEntProp(phys, Prop_Data, "m_nSolidType", 2);
		
		SetEntityCollisionGroup(phys, 23); //23 is TFCOLLISION_GROUP_COMBATOBJECT, it is solid to everything but players.
		SetEntProp(phys, Prop_Send, "m_iTeamNum", 0);
		
		float randAng[3];
		for (int i = 0; i < 3; i++)
			randAng[i] = GetRandomFloat(0.0, 360.0);
			
		RequestFrame(Toss_Spin, EntIndexToEntRef(toolbox));
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, toolbox, Toss_Explode);
	}
}

public Action Toss_ToolboxTouch(int prop, int other)
{
	int owner = EntRefToEntIndex(Toss_ToolboxOwner[prop]);
	if (!IsValidEntity(owner))
		return Plugin_Continue;
		
	int client = GetEntPropEnt(owner, Prop_Send, "m_hOwnerEntity");
	if (!IsValidClient(client))
		return Plugin_Continue;

	//Check to see if the toolbox collided with an enemy:
	if (IsValidMulti(other, true, true, true, grabEnemyTeam(client)))
	{
		CPrintToChatAll("A toolbox collided with an enemy!");
		//TODO: Bounce off of enemy players
	}
	else if (HasEntProp(other, Prop_Send, "m_hOwnerEntity"))
	{
		//The toolbox did not collide with an enemy, check to see if it collided with one of the owner's projectiles:
		int otherOwner = GetEntPropEnt(other, Prop_Send, "m_hOwnerEntity");
		char classname[255];
		GetEntityClassname(other, classname, sizeof(classname));
		if (StrContains(classname, "tf_projectile_") != -1 && otherOwner == client)
			Toss_SpawnSentry(owner, true);
	}
	
	return Plugin_Continue;
}

public Action Toss_ToolboxDamaged(int prop, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	damage = 0.0;
	
	int owner = EntRefToEntIndex(Toss_ToolboxOwner[prop]);
	if (!IsValidEntity(owner))
		return Plugin_Changed;
		
	int client = GetEntPropEnt(owner, Prop_Send, "m_hOwnerEntity");
	if (!IsValidClient(client))
		return Plugin_Changed;
		
	if (attacker == client)
		Toss_SpawnSentry(owner, true);
	
	return Plugin_Changed;
}

public MRESReturn Toss_Explode(int toolbox)
{
	Toss_SpawnSentry(toolbox, false);
	return MRES_Supercede;
}

public void Toss_SpawnSentry(int toolbox, bool supercharged)
{
	int owner = GetEntPropEnt(toolbox, Prop_Send, "m_hOwnerEntity");
	int team = GetEntProp(toolbox, Prop_Send, "m_iTeamNum");
	
	if (!IsValidClient(owner))
	{
		RemoveEntity(toolbox);
		return;
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
		
		if (Toss_GetDistanceToSurface(prop, 90.0, 0.0, 0.0) < 20.0)
		{
			pos[2] += 20.0;
			TeleportEntity(prop, pos);
		}
		if (Toss_GetDistanceToSurface(prop, 0.0, Toss_FacingAng[toolbox][1], 0.0) < 20.0)
		{
			Toss_FacingAng[toolbox][1] += 180.0;
			TeleportEntity(prop, _, Toss_FacingAng[toolbox]);
		}
		
		Toss_SentryStats[prop].Activate(supercharged);
		
		/*
		TODO: 
		• The following things MUST be done, but cannot be done until we have the custom model:
			○ Visuals indicating different states of damage, as well as a sound which is played to the owner when they are heavily damaged.
			○ When sentries fire, they need a custom firing animation and a team-colored plasma beam indicating where they fired.
			○ Attach payload cart light particles so these sentries are easier to spot and know which team they're on at a glance.
		• The toolbox still has not been modified to collide with enemies and deal damage to them.
		• Shooting your own toolbox with your pistol should supercharge the resulting sentry for a few seconds.
		• The prop_physics needs the following custom sentry logic:
			○ A worldtext entity which is ONLY visible to the sentry's owner, displaying its HP.
			○ Levitation if the sentry spawns on the ground (99% done, just need to figure out why wall sentries don't float properly)
			○ Rescue ranger bolts should be able to collide with these sentries and heal them.
			○ If a sentry gets hit by ANYTHING, it starts spinning out wildly which makes it effectively useless since it isn't able to track its targets. This needs to be fixed so that physics can still apply knockback, but not affect rotation.
		• If a player switches from Gadgeteer to a different character, their sentries do not get destroyed. This is abusable and needs to be fixed.
			○ Add a "CF_OnCharacterSwitched" forward which gets called when a player spawns as a new character.
		*/
	}
	
	RemoveEntity(toolbox);
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
		
		Toss_ToolboxOwner[entity] = -1;
	}
}