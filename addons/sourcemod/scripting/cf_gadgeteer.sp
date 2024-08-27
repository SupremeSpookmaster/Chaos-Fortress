#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <math>
#include <worldtext>
#include <fakeparticles>
#include <pnpc>

#define GADGETEER		"cf_gadgeteer"
#define TOSS			"gadgeteer_sentry_toss"
#define SUPPORTDRONE	"gadgeteer_support_drone"
#define COMMAND			"gadgeteer_command_support_drone"

#define MODEL_TOSS		"models/weapons/w_models/w_toolbox.mdl"
#define MODEL_HOOK		"models/props_mining/cranehook001.mdl"
#define MODEL_ROPE_RED	"materials/cable/cable_red.vmt"
#define MODEL_ROPE_BLUE	"materials/cable/cable_blue.vmt"
#define MODEL_DRG		"models/weapons/w_models/w_drg_ball.mdl"
#define MODEL_DRONE_PARENT	"models/chaos_fortress/gadgeteer/drone.mdl"
#define MODEL_DRONE_VISUAL	"models/player/items/all_class/pet_robro.mdl"
#define MODEL_TOSS_GIB_1	"models/player/gibs/gibs_gear2.mdl"
#define MODEL_TOSS_GIB_2	"models/player/gibs/gibs_gear3.mdl"
#define MODEL_TOSS_GIB_3	"models/player/gibs/gibs_gear4.mdl"
#define MODEL_TOSS_GIB_4	"models/player/gibs/gibs_spring1.mdl"
#define MODEL_TOSS_GIB_5	"models/player/gibs/gibs_spring2.mdl"
#define MODEL_SUPPORT_DRONE	"models/bots/bot_worker/bot_worker_a.mdl"
#define MODEL_SUPPORT_GIB_1	"models/bots/bot_worker/bot_worker_a_body_gib_l.mdl"
#define MODEL_SUPPORT_GIB_2	"models/bots/bot_worker/bot_worker_a_body_gib_r.mdl"
#define MODEL_SUPPORT_GIB_3	"models/bots/bot_worker/bot_worker_a_head_gib_l.mdl"
#define MODEL_SUPPORT_GIB_4	"models/bots/bot_worker/bot_worker_a_head_gib_r.mdl"
#define MODEL_SUPPORT_GIB_5	"models/bots/bot_worker/bot_worker_arm_gib.mdl"
#define MODEL_SUPPORT_BOX	"models/props_junk/wood_crate001a.mdl"
#define MODEL_SUPPORT_BOX_GIB_1	"models/props_junk/wood_crate001a_chunk04.mdl"
#define MODEL_SUPPORT_BOX_GIB_2	"models/props_junk/wood_crate001a_chunk02.mdl"
#define MODEL_SUPPORT_BOX_GIB_3	"models/props_junk/wood_crate001a_chunk03.mdl"
#define MODEL_SUPPORT_BOX_GIB_4	"models/props_junk/wood_crate001a_chunk07.mdl"
#define MODEL_SUPPORT_BOX_GIB_5	"models/props_junk/wood_crate001a_chunk01.mdl"

#define SOUND_TOSS_BUILD_1	"weapons/neon_sign_hit_01.wav"
#define SOUND_TOSS_BUILD_2	"weapons/neon_sign_hit_02.wav"
#define SOUND_TOSS_BUILD_3	"weapons/neon_sign_hit_03.wav"
#define SOUND_TOSS_BUILD_4	"weapons/neon_sign_hit_04.wav"
#define SOUND_TOSS_BUILD_EXTRA ")ui/itemcrate_smash_rare.wav"
#define SOUND_TOSS_DESTROYED	"weapons/teleporter_explode.wav"
#define SOUND_TOSS_TARGETLOCKED	")weapons/sentry_spot.wav"
#define SOUND_TOSS_TARGETWARNING	"weapons/sentry_spot_client.wav"
#define SOUND_TOSS_TOOLBOX_HIT_PLAYER_1	"weapons/metal_gloves_hit_flesh1.wav"
#define SOUND_TOSS_TOOLBOX_HIT_PLAYER_2	"weapons/bumper_car_hit_ball.wav"
#define SOUND_TOSS_SHOOT			"weapons/shooting_star_shoot.wav"
#define SOUND_TOSS_SHOOT_SUPERCHARGE			"weapons/shooting_star_shoot_crit.wav"
#define SOUND_SUPERCHARGE	"items/powerup_pickup_reflect.wav"
#define SOUND_SUPERCHARGE_HITSCAN			"items/powerup_pickup_agility.wav"
#define SOUND_TOSS_HEAL		"weapons/rescue_ranger_charge_01.wav"
#define SOUND_DRONE_DAMAGED_1	")weapons/sentry_damage1.wav"
#define SOUND_DRONE_DAMAGED_2	")weapons/sentry_damage2.wav"
#define SOUND_DRONE_DAMAGED_3	")weapons/sentry_damage3.wav"
#define SOUND_DRONE_DAMAGED_4	")weapons/sentry_damage4.wav"
#define SOUND_DRONE_DAMAGED_ALERT	"misc/hud_warning.wav"
#define SOUND_DEBUG_HIT_TOOLBOX		"vo/spy_yes01.mp3"
#define SOUND_TOOLBOX_FIZZING		")misc/halloween/hwn_bomb_fuse.wav"
#define SOUND_TOSS_HIT_WORLD		")weapons/metal_gloves_hit.wav"
#define SOUND_DRONE_SCANNING			")weapons/sentry_scan.wav"
#define SOUND_DRONES_TARGETING		"misc/doomsday_lift_warning.wav"
#define SOUND_SUPPORT_DESTROYED		")weapons/dispenser_explode.wav"
#define SOUND_SUPPORT_HEALING_START	"weapons/dispenser_heal.wav"
#define SOUND_SUPPORT_HEALING_STOP	"weapons/medigun_heal_detach.wav"
#define SOUND_SUPPORT_AMBIENT_LOOP	")weapons/dispenser_idle.wav"
#define SOUND_SUPPORT_BUILD_BEGIN	")weapons/sentry_wire_connect.wav"
#define SOUND_SUPPORT_BUILD_FINISHED	")weapons/sentry_finish.wav"
#define SOUND_SUPPORT_BOX_BREAK			")physics/wood/wood_crate_break4.wav"

#define PARTICLE_TOSS_BUILD_1		"bot_impact_heavy"
#define PARTICLE_TOSS_BUILD_2		"duck_pickup_ring"
#define PARTICLE_TOSS_DESTROYED	"rd_robot_explosion"
#define PARTICLE_TOSS_HIT_PLAYER_1	"duck_pickup_ring"
#define PARTICLE_TOSS_HIT_PLAYER_2	"kart_impact_sparks"
#define PARTICLE_TOSS_DRONE_RED		"cart_flashinglight_red"
#define PARTICLE_TOSS_DRONE_BLUE	"cart_flashinglight"
#define PARTICLE_TOSS_SUPERCHARGE_RED	"eyeboss_vortex_red"
#define PARTICLE_TOSS_SUPERCHARGE_HITSCAN_RED		"medic_healradius_red_buffed"
#define PARTICLE_TOSS_SUPERCHARGE_BLUE	"eyeboss_vortex_blue"
#define PARTICLE_TOSS_SUPERCHARGE_HITSCAN_BLUE		"medic_healradius_blue_buffed"
#define PARTICLE_TOSS_HEAL_RED		"healthgained_red"
#define PARTICLE_TOSS_HEAL_BLUE		"healthgained_blu"
#define PARTICLE_DRONE_DAMAGED		"superrare_burning1"
#define PARTICLE_SUPERCHARGE_IMPACT_BLUE	"drg_cow_explosioncore_charged_blue"
#define PARTICLE_SUPERCHARGE_IMPACT_RED		"drg_cow_explosioncore_charged"
#define PARTICLE_TOOLBOX_TRAIL_RED		"flaregun_trail_red"
#define PARTICLE_TOOLBOX_TRAIL_BLUE		"flaregun_trail_blue"
#define PARTICLE_MUZZLE_RED		"muzzle_raygun_red"
#define PARTICLE_MUZZLE_BLUE	"muzzle_raygun_blue"
#define PARTICLE_MUZZLE_RED_2		"muzzle_raygun_red"
#define PARTICLE_MUZZLE_BLUE_2	"muzzle_raygun_blue"
#define PARTICLE_LASER_RED		"bullet_tracer_raygun_red_bits"
#define PARTICLE_LASER_BLUE		"bullet_tracer_raygun_blue_bits"
#define PARTICLE_SUPPORT_HEAL_RED	"dispenser_heal_red"
#define PARTICLE_SUPPORT_HEAL_BLUE	"dispenser_heal_blue"
#define PARTICLE_SUPPORT_BOX_TRAIL_RED 	"healshot_trail_red"
#define PARTICLE_SUPPORT_BOX_TRAIL_BLUE	"healshot_trail_blue"

#define MODEL_TARGETING		"models/fake_particles/plane.mdl"

//int LASER_MODEL = -1;
//int GLOW_MODEL = -1;

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
	PrecacheModel(MODEL_TARGETING);
	PrecacheModel(MODEL_SUPPORT_DRONE);
	PrecacheModel(MODEL_SUPPORT_GIB_1);
	PrecacheModel(MODEL_SUPPORT_GIB_2);
	PrecacheModel(MODEL_SUPPORT_GIB_3);
	PrecacheModel(MODEL_SUPPORT_GIB_4);
	PrecacheModel(MODEL_SUPPORT_GIB_5);
	PrecacheModel(MODEL_SUPPORT_BOX);
	PrecacheModel(MODEL_SUPPORT_BOX_GIB_1);
	PrecacheModel(MODEL_SUPPORT_BOX_GIB_2);
	PrecacheModel(MODEL_SUPPORT_BOX_GIB_3);
	PrecacheModel(MODEL_SUPPORT_BOX_GIB_4);
	PrecacheModel(MODEL_SUPPORT_BOX_GIB_5);

	PrecacheSound(SOUND_TOSS_BUILD_1);
	PrecacheSound(SOUND_TOSS_BUILD_2);
	PrecacheSound(SOUND_TOSS_BUILD_3);
	PrecacheSound(SOUND_TOSS_BUILD_4);
	PrecacheSound(SOUND_TOSS_DESTROYED);
	PrecacheSound(SOUND_TOSS_TARGETLOCKED);
	PrecacheSound(SOUND_TOSS_TARGETWARNING);
	PrecacheSound(SOUND_TOSS_TOOLBOX_HIT_PLAYER_1);
	PrecacheSound(SOUND_TOSS_TOOLBOX_HIT_PLAYER_2);
	PrecacheSound(SOUND_TOSS_SHOOT);
	PrecacheSound(SOUND_TOSS_SHOOT_SUPERCHARGE);
	PrecacheSound(SOUND_SUPERCHARGE_HITSCAN);
	PrecacheSound(SOUND_SUPERCHARGE);
	PrecacheSound(SOUND_TOSS_HEAL);
	PrecacheSound(SOUND_DRONE_DAMAGED_1);
	PrecacheSound(SOUND_DRONE_DAMAGED_2);
	PrecacheSound(SOUND_DRONE_DAMAGED_3);
	PrecacheSound(SOUND_DRONE_DAMAGED_4);
	PrecacheSound(SOUND_DRONE_DAMAGED_ALERT);
	PrecacheSound(SOUND_DEBUG_HIT_TOOLBOX);
	PrecacheSound(SOUND_TOOLBOX_FIZZING);
	PrecacheSound(SOUND_TOSS_BUILD_EXTRA);
	PrecacheSound(SOUND_TOSS_HIT_WORLD);
	PrecacheSound(SOUND_DRONE_SCANNING);
	PrecacheSound(SOUND_DRONES_TARGETING);
	PrecacheSound(SOUND_SUPPORT_DESTROYED);
	PrecacheSound(SOUND_SUPPORT_HEALING_START);
	PrecacheSound(SOUND_SUPPORT_HEALING_STOP);
	PrecacheSound(SOUND_SUPPORT_AMBIENT_LOOP);
	PrecacheSound(SOUND_SUPPORT_BUILD_BEGIN);
	PrecacheSound(SOUND_SUPPORT_BUILD_FINISHED);
	PrecacheSound(SOUND_SUPPORT_BOX_BREAK);

	/*LASER_MODEL = PrecacheModel("materials/sprites/laser.vmt", false);
	GLOW_MODEL = PrecacheModel("sprites/glow02.vmt", true);*/
}

public const char Toss_BuildSFX[][] =
{
	SOUND_TOSS_BUILD_1,
	SOUND_TOSS_BUILD_2,
	SOUND_TOSS_BUILD_3,
	SOUND_TOSS_BUILD_4
};

public const char Model_Gears[][255] =
{
	MODEL_TOSS_GIB_1,
	MODEL_TOSS_GIB_2,
	MODEL_TOSS_GIB_3,
	MODEL_TOSS_GIB_4,
	MODEL_TOSS_GIB_5
};

public const char Model_BoxGibs[][255] =
{
	MODEL_SUPPORT_BOX_GIB_1,
	MODEL_SUPPORT_BOX_GIB_2,
	MODEL_SUPPORT_BOX_GIB_3,
	MODEL_SUPPORT_BOX_GIB_4,
	MODEL_SUPPORT_BOX_GIB_5
};

public const char Drone_DamageSFX[][255] =
{
	SOUND_DRONE_DAMAGED_1,
	SOUND_DRONE_DAMAGED_2,
	SOUND_DRONE_DAMAGED_3,
	SOUND_DRONE_DAMAGED_4
};

int Toss_Owner[2049] = { -1, ... };
int Toss_Max[MAXPLAYERS + 1] = { 0, ... };
int Toss_ToolboxOwner[2049] = { -1, ... };
int Text_Owner[2049] = { -1, ... };
int Toss_ToolboxParticle[2049] = { -1, ... };
int Toss_Marked[MAXPLAYERS + 1] = { -1, ... };
int Toss_SupportDrone[MAXPLAYERS + 1] = { -1, ... };

float Toss_DMG[2049] = { 0.0, ... };
float Toss_KB[2049] = { 0.0, ... };
float Toss_UpVel[2049] = { 0.0, ... };
float Toss_NextBounce[2049] = { 0.0, ... };
float Toss_AutoDetTime[2049] = { 0.0, ... };
float Toss_MinVel[2049] = { 0.0, ... };
float Toss_MarkTime[MAXPLAYERS + 1] = { 0.0, ... };
float Toss_FacingAng[2049][3];

bool Toss_IsToolbox[2049] = { false, ... };
bool Toss_WasHittingSomething[2049] = { false, ... };
bool Toss_IsSupportDrone[2049] = { false, ... };
bool b_HealingClient[2049][MAXPLAYERS + 1];

Queue Toss_Sentries[MAXPLAYERS + 1] = { null, ... };

CustomSentry Toss_SentryStats[2049];
SupportDroneStats Toss_SupportStats[2049];

float scan_sound_time = 3.1;

enum struct SupportDroneStats
{
	float buildTime;
	float maxHealth;
	float speed;
	float healRadius;
	float healRate_Direct;
	float healRate_Others;
	float healRate_Self;
	float superchargeDuration;
	float superchargeBuildSpeed;
	float superchargeMovementSpeed;
	float superchargeHealRate;
	float superchargeDurationHitscan;
	float superchargeBuildSpeedHitscan;
	float superchargeMovementSpeedHitscan;
	float superchargeHealRateHitscan;
	float buildHealBucket;
	float findNewTargetTime;
	float minHealTime;
	float scanRadius;
	float healBucket_Target;
	float healBucket_Others;
	float healBucket_Self;
	float superchargeEndTime;

	int lastBuildHealth;
	int superchargeType;
	int targetOverride;
	int owner;
	int autoTarget;
	int self;

	bool isBuilding;

	void CreateFromArgs(int client, char abilityName[255])
	{
		this.buildTime = CF_GetArgF(client, GADGETEER, abilityName, "build_time");
		this.maxHealth = CF_GetArgF(client, GADGETEER, abilityName, "max_health");
		this.speed = CF_GetArgF(client, GADGETEER, abilityName, "speed");
		this.healRadius = CF_GetArgF(client, GADGETEER, abilityName, "heal_radius");
		this.healRate_Direct = CF_GetArgF(client, GADGETEER, abilityName, "heal_rate_target");
		this.healRate_Others = CF_GetArgF(client, GADGETEER, abilityName, "heal_rate_other");
		this.healRate_Self = CF_GetArgF(client, GADGETEER, abilityName, "heal_rate_self");
		this.minHealTime = CF_GetArgF(client, GADGETEER, abilityName, "min_heal_time");
		this.scanRadius = CF_GetArgF(client, GADGETEER, abilityName, "scan_radius");

		this.superchargeDuration = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_duration");
		this.superchargeBuildSpeed = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_build");
		this.superchargeMovementSpeed = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_movement");
		this.superchargeHealRate = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_heal");
		this.superchargeDurationHitscan = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_duration_hitscan");
		this.superchargeBuildSpeedHitscan = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_build_hitscan");
		this.superchargeMovementSpeedHitscan = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_movement_hitscan");
		this.superchargeHealRateHitscan = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_heal_hitscan");
	}

	void Copy(SupportDroneStats other)
	{
		this.buildTime = other.buildTime;
		this.maxHealth = other.maxHealth;
		this.speed = other.speed;
		this.healRadius = other.healRadius;
		this.healRate_Direct = other.healRate_Direct;
		this.healRate_Others = other.healRate_Others;
		this.healRate_Self = other.healRate_Self;
		this.minHealTime = other.minHealTime;
		this.scanRadius = other.scanRadius;

		this.superchargeDuration = other.superchargeDuration;
		this.superchargeBuildSpeed = other.superchargeBuildSpeed;
		this.superchargeMovementSpeed = other.superchargeMovementSpeed;
		this.superchargeHealRate = other.superchargeHealRate;
		this.superchargeDurationHitscan = other.superchargeDurationHitscan;
		this.superchargeBuildSpeedHitscan = other.superchargeBuildSpeedHitscan;
		this.superchargeMovementSpeedHitscan = other.superchargeMovementSpeedHitscan;
		this.superchargeHealRateHitscan = other.superchargeHealRateHitscan;
	}

	int GetTarget()
	{
		int owner = GetClientOfUserId(this.owner);
		int drone = EntRefToEntIndex(this.self);
		
		//Check 1: Have we commanded the Support Drone to target a specific player, and if we have, is that player still valid?
		int target = GetClientOfUserId(this.targetOverride);
		if (IsValidMulti(target, true, true, true, TF2_GetClientTeam(owner)))
			return target;

		//Check 2: We have not commanded the Support Drone to target a specific player, check to see if we have a valid target already chosen.
		//If we do, make sure we haven't reached the minimum healing duration yet.
		target = GetClientOfUserId(this.autoTarget);
		if (IsValidMulti(target, true, true, true, TF2_GetClientTeam(owner)) && GetGameTime() < this.findNewTargetTime)
			return target;

		//Check 3: We either do not have a target, or have surpassed the minimum healing duration on our current target.
		//Find the ally with the lowest HP within range (range becomes infinite if there are no allies within range) and target them.
		float selfPos[3];
		GetEntPropVector(drone, Prop_Send, "m_vecOrigin", selfPos);

		ArrayList allies = new ArrayList(255);
		for (int i = 0; i <= MaxClients; i++)
		{
			if (IsValidMulti(i, true, true, true, TF2_GetClientTeam(owner)))
			{
				float otherPos[3];
				GetClientAbsOrigin(i, otherPos);

				if (GetVectorDistance(selfPos, otherPos) <= this.scanRadius)
					PushArrayCell(allies, i);
			}
		}

		//There are no allies in range, make range global so the drone doesn't just stand there and do nothing.
		if (GetArraySize(allies) < 1)
		{
			delete allies;
			allies = new ArrayList(255);
			for (int i = 0; i <= MaxClients; i++)
			{
				if (IsValidMulti(i, true, true, true, TF2_GetClientTeam(owner)))
					PushArrayCell(allies, i);
			}
		}
		
		if (GetArraySize(allies) > 0) //Double-check to make sure we still have living allies to scan through.
		{
			float lowestPercent = -1.0;
			for (int i = 0; i < GetArraySize(allies); i++)
			{
				int ally = GetArrayCell(allies, i);

				//We act based on the lowest percentage of current health instead of just the lowest current health in general, that way light classes/characters don't hog all the support drone priority.
				float hp = float(GetEntProp(ally, Prop_Send, "m_iHealth"));
				float maxHP = float(TF2Util_GetEntityMaxHealth(ally));
				float percent = hp / maxHP;

				if ((percent < lowestPercent || lowestPercent == -1.0) && percent < 1.0)
				{
					lowestPercent = percent;
					target = ally;
				}
			}
		}

		delete allies;

		//Check 4: If we automatically found a valid target, set autoTarget to them and begin targeting them. Otherwise, target the owner by default.
		if (IsValidMulti(target, true, true, true, TF2_GetClientTeam(owner)))
		{
			this.autoTarget = target;
			this.findNewTargetTime = GetGameTime() + this.minHealTime;
		}
		else
		{
			target = owner;
		}

		return target;
	}

	bool IsSupercharged()
	{
		return GetGameTime() <= this.superchargeEndTime;
	}

	float GetMaxSpeed()
	{
		if (this.IsSupercharged())
		{
			if (this.superchargeType == 1)
			{
				return this.superchargeMovementSpeedHitscan;
			}
			else
			{
				return this.superchargeMovementSpeed;
			}
		}

		return this.speed;
	}

	float GetHealRate(int healType)
	{
		float mult = 1.0;
		if (this.IsSupercharged())
		{
			if (this.superchargeType == 1)
			{
				mult = this.superchargeHealRateHitscan;
			}
			else
			{
				mult = this.superchargeHealRate;
			}
		}

		switch(healType)
		{
			case 0:
				return this.healRate_Direct * mult;
			case 1:
				return this.healRate_Others * mult;
			default:
				return this.healRate_Self * mult;
		}
	}

	float GetBuildTime()
	{
		float divAmt = 1.0;
		if (this.IsSupercharged())
		{
			if (this.superchargeType == 1)
			{
				divAmt = this.superchargeBuildSpeedHitscan;
			}
			else
			{
				divAmt = this.superchargeBuildSpeed;
			}
		}

		return this.buildTime / divAmt;
	}

	float CalculateBuildAnimSpeed()
	{
		return 2.33 / this.GetBuildTime();
	}
}

enum struct CustomSentry
{
	int owner;
	int entity;
	int dummy;
	int target;
	int text;
	int superchargedType;
	int damageEffect;
	
	float hoverHeight;
	float scale;
	float radiusDetection;
	float radiusFire;
	float turnRate;
	float fireRate;
	float damage;
	float maxHealth;
	float currentHealth;
	float turnDirection;
	float startingYaw;
	float yawOffset;
	float NextShot;
	float superchargeDuration;
	float superchargeFire;
	float superchargeTurn;
	float superchargeDuration_Hitscan;
	float superchargeFire_Hitscan;
	float superchargeTurn_Hitscan;
	float superchargeEndTime;
	float previousPitch;
	float previousYaw;
	float previousRoll;
	float nextTargetTime;
	float nextScanSound;
	
	bool exists;
	bool shooting;

	//Stores the ability's args in a toolbox to be copied into that toolbox's Drone by CopyFromOther.
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
		this.damage = CF_GetArgF(client, GADGETEER, abilityName, "damage_sentry");
		this.maxHealth = CF_GetArgF(client, GADGETEER, abilityName, "max_health");
		this.superchargeDuration = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_duration");
		this.superchargeFire = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_fire");
		this.superchargeTurn = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_turn");
		this.superchargeDuration_Hitscan = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_duration_hitscan");
		this.superchargeFire_Hitscan = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_fire_hitscan");
		this.superchargeTurn_Hitscan = CF_GetArgF(client, GADGETEER, abilityName, "supercharge_turn_hitscan");
	}
	
	//Copies a toolbox's stats into this Drone.
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
		this.superchargeDuration_Hitscan = other.superchargeDuration_Hitscan;
		this.superchargeFire_Hitscan = other.superchargeFire_Hitscan;
		this.superchargeTurn_Hitscan = other.superchargeTurn_Hitscan;
	}
	
	//Activates the Drone's custom sentry logic and sets its VFX.
	void Activate(bool supercharged, int superchargeType)
	{
		int prop = EntRefToEntIndex(this.entity);
		int owner = GetClientOfUserId(this.owner);
		if (!IsValidEntity(prop) || !IsValidClient(owner))
			return;
			
		float angles[3];
		GetEntPropVector(prop, Prop_Send, "m_angRotation", angles);
		this.previousPitch = angles[0];
		this.previousYaw = angles[1];
		this.previousRoll = angles[2];
		
		//SetEntProp(prop, Prop_Send, "m_fEffects", 32);
		TFTeam team = view_as<TFTeam>(GetEntProp(prop, Prop_Send, "m_iTeamNum"));
		/*int model = AttachModelToEntity(MODEL_DRONE_VISUAL, "", prop, _, team == TFTeam_Red ? "0" : "1");
		if (IsValidEntity(model))
		{
			this.dummy = EntIndexToEntRef(model);
			char scalechar[16];
			Format(scalechar, sizeof(scalechar), "%f", this.scale);
			DispatchKeyValue(model, "modelscale", scalechar);
			SetEntityGravity(model, 0.0);
			TeleportEntity(model, NULL_VECTOR, angles);
		}*/
		
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
			this.superchargedType = superchargeType;
			float duration = (superchargeType == 1 ? this.superchargeDuration_Hitscan : this.superchargeDuration);
			this.superchargeEndTime = GetGameTime() + duration;
			
			char sound[255];
			sound = (superchargeType == 1 ? SOUND_SUPERCHARGE_HITSCAN : SOUND_SUPERCHARGE);
			EmitSoundToClient(owner, sound, _, _, 120, _, _, GetRandomInt(80, 100));
			EmitSoundToClient(owner, sound, _, _, 120, _, _, GetRandomInt(80, 100));
			AttachParticleToEntity(prop, team == TFTeam_Red ? PARTICLE_TOSS_SUPERCHARGE_HITSCAN_RED : PARTICLE_TOSS_SUPERCHARGE_HITSCAN_BLUE, "", duration);
			if (superchargeType == 2)
				AttachParticleToEntity(prop, team == TFTeam_Red ? PARTICLE_TOSS_SUPERCHARGE_RED : PARTICLE_TOSS_SUPERCHARGE_BLUE, "", duration);
		}
		
		AttachParticleToEntity(prop, team == TFTeam_Red ? PARTICLE_TOSS_DRONE_RED : PARTICLE_TOSS_DRONE_BLUE, "");
		
		this.currentHealth = this.maxHealth;
		this.UpdateHP(0.0);
		ScaleHitboxSize(prop, this.scale + 0.33);
		
		SDKHook(prop, SDKHook_OnTakeDamage, Drone_Damaged);
		
		this.exists = true;
		EmitSoundToAll(SOUND_DRONE_SCANNING, prop);
		EmitSoundToAll(SOUND_DRONE_SCANNING, prop);
		this.nextScanSound = GetGameTime() + scan_sound_time;
	}
	
	//Adds "mod" to the Drone's current HP, automatically updating its health display text and damage indication particle if its health is above 0 or destroying it otherwise.
	void UpdateHP(float mod)
	{
		int prop = EntRefToEntIndex(this.entity);
		if (!IsValidEntity(prop))
			return;
			
		this.currentHealth += mod;
		if (this.currentHealth <= 0.0)
		{
			RemoveEntity(prop);
			return;
		}
		else if (this.currentHealth > this.maxHealth)
			this.currentHealth = this.maxHealth;
			
		if (mod < 0.0)
		{
			int chosen = GetRandomInt(0, sizeof(Drone_DamageSFX) - 1);
			int pitch = GetRandomInt(90, 110);
			EmitSoundToAll(Drone_DamageSFX[chosen], prop, _, _, _, _, pitch, -1);
			EmitSoundToAll(Drone_DamageSFX[chosen], prop, _, _, _, _, pitch, -1);
		}
			
		char hpText[255];
		Format(hpText, sizeof(hpText), "HP: %i", RoundToCeil(this.currentHealth));
			
		int textEnt = EntRefToEntIndex(this.text);
		if (!IsValidEntity(textEnt) || this.text == 0)
		{
			textEnt = WorldText_Create(NULL_VECTOR, NULL_VECTOR, hpText, 10.0, _, _, FONT_TF2_BULKY);
			if (IsValidEntity(textEnt))
			{
				WorldText_AttachToEntity(textEnt, prop, "", _, _, 8.0 * this.scale);
				this.text = EntIndexToEntRef(textEnt);
				Text_Owner[textEnt] = this.owner;
				SDKHook(textEnt, SDKHook_SetTransmit, Text_Transmit);
			}
		}

		DispatchKeyValue(textEnt, "message", hpText);
		
		int r = 255, g = 255, b = 255;
		float multiplier = this.currentHealth / this.maxHealth;
		g = RoundFloat(multiplier * 255.0);
		b = RoundFloat(multiplier * 255.0);
		WorldText_SetColor(textEnt, r, g, b);
		
		int client = GetClientOfUserId(this.owner);
		int damageParticle = EntRefToEntIndex(this.damageEffect);
		if (multiplier <= 0.5)
		{
			if (IsValidClient(client))
				EmitSoundToClient(client, SOUND_DRONE_DAMAGED_ALERT);
				
			if (!IsValidEntity(damageParticle) || damageParticle == 0)
			{
				damageParticle = AttachParticleToEntity(prop, PARTICLE_DRONE_DAMAGED, "");
				this.damageEffect = EntIndexToEntRef(damageParticle);
			}
		}
		else if (IsValidEntity(damageParticle) && damageParticle != 0)
		{
			RemoveEntity(damageParticle);
			this.damageEffect = -1;
		}
	}
	
	//Clears all important variables and triggers the Drone destruction VFX/SFX.
	void Destroy()
	{
		int prop = EntRefToEntIndex(this.entity);
		if (IsValidEntity(prop))
		{
			StopSound(prop, SNDCHAN_AUTO, SOUND_DRONE_SCANNING);
			
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
				
				int gear = SpawnPhysicsProp(Model_Gears[GetRandomInt(0, sizeof(Model_Gears) - 1)], 0, "0", 99999.0, true, 1.0, pos, randAng, randVel, 5.0);
				
				if (IsValidEntity(gear))
				{
					SetEntityCollisionGroup(gear, 1);
					SetEntityRenderMode(gear, RENDER_TRANSALPHA);
					RequestFrame(Toss_FadeOutGib, EntIndexToEntRef(gear));
					SetEntityCollisionGroup(gear, 1);
					SetEntProp(gear, Prop_Send, "m_iTeamNum", 0);
				}
			}
			
			int owner = GetClientOfUserId(this.owner);
			if (IsValidMulti(owner))
				CF_PlayRandomSound(owner, "", "sound_toolbox_drone_destroyed");
		}
		
		this.exists = false;
		this.shooting = false;
		this.text = 0;
	}
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, GADGETEER))
		return;
	
	if (StrContains(abilityName, TOSS) != -1)
		Toss_Activate(client, abilityName);

	if (StrContains(abilityName, SUPPORTDRONE) != -1)
		Support_Activate(client, abilityName);
}

//Prevents a point_worldtext entity from being seen by anyone other than its owner.
public Action Text_Transmit(int entity, int client)
{
	SetEdictFlags(entity, GetEdictFlags(entity)&(~FL_EDICT_ALWAYS));
	if (client != GetClientOfUserId(Text_Owner[entity]))
 	{
 		return Plugin_Handled;
	}
 		
	return Plugin_Continue;
}

//Fades the alpha of a given entity and removes it if the alpha falls below 1.
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

//A trace which returns true as long as the entity is not a specified target (Toss_TraceTarget).
public bool Toss_IgnoreAllButTarget(entity, contentsMask)
{
	return entity == Toss_TraceTarget;
}

//A trace which returns true as long as the entity is not a Drone or a client.
public bool Toss_IgnoreDrones(entity, contentsMask, target)
{	
	return !Toss_SentryStats[entity].exists && (entity == 0 || entity > MaxClients) && !PNPC_IsNPC(entity) && Brush_Is_Solid(entity) && entity != target;
}

//A trace which returns true as long as the entity can be shot and is on the opposite of a specified team (Toss_TraceTeam).
public bool Toss_OnlyHitEnemies(entity, contentsMask)
{
	if (!Entity_Can_Be_Shot(entity) || !Brush_Is_Solid(entity))
		return false;
		
	TFTeam otherTeam = view_as<TFTeam>(GetEntProp(entity, Prop_Send, "m_iTeamNum"));
	TFTeam thisTeam = view_as<TFTeam>(Toss_TraceTeam);
	return (otherTeam == TFTeam_Blue && thisTeam == TFTeam_Red) || (otherTeam == TFTeam_Red && thisTeam == TFTeam_Blue);
}

int ToolboxToIgnore;
//A trace which returns true as long as the entity is not a client or a specified toolbox (ToolboxToIgnore).
public bool Toss_IgnoreThisToolbox(entity, contentsMask)
{
	return (entity == 0 || entity > MaxClients) && entity != ToolboxToIgnore;
}

int SentryBeingChecked;

//Controls ALL of the Drone's custom logic. This includes the following:
//	• Finding a target.
//	• Aiming at the target.
//	• Shooting at the target.
//	• Turning left and right as it scans for targets, if it cannot find a target.
//	• Hovering.
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
	if (CF_IsEntityInSpawn(entity, team == TFTeam_Red ? TFTeam_Blue : TFTeam_Red))
	{
		RemoveEntity(entity);
		return;
	}
	
	int owner = GetClientOfUserId(Toss_SentryStats[entity].owner);
	int target = EntRefToEntIndex(Toss_SentryStats[entity].target);
	float turnSpeed = Toss_SentryStats[entity].turnRate;
	
	if (gt <= Toss_SentryStats[entity].superchargeEndTime)
		turnSpeed *= (Toss_SentryStats[entity].superchargedType == 1 ? Toss_SentryStats[entity].superchargeTurn_Hitscan : Toss_SentryStats[entity].superchargeTurn);
	
	float distance;
	float angles[3], pos[3], vel[3];
	//GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	angles[0] = Toss_SentryStats[entity].previousPitch;
	angles[1] = Toss_SentryStats[entity].previousYaw;
	angles[2] = Toss_SentryStats[entity].previousRoll;
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vel);
	
	float groundDist = Toss_GetDistanceToSurface(entity, 90.0, 0.0, 0.0);
	float TARGET_UPVEL = 11.875;	//Due to what is presumably Source engine shenanigans, we can't just lock the velocity to 0.0 and have it hover properly. It needs to be higher or else it will gradually fall to the ground, but not too high or else it will ascend to the heavens. This is VERY annoying.
	if (groundDist < Toss_SentryStats[entity].hoverHeight)
	{
		vel[2] = LerpFloat(0.01, vel[2], 100.0);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);
	}
	else if (vel[2] != TARGET_UPVEL)
	{
		if (vel[2] > TARGET_UPVEL)
			vel[2] = ClampFloat(vel[2] - 4.0, TARGET_UPVEL, 9999.0);
		else
			vel[2] = ClampFloat(vel[2] + 4.0, -9999.0, TARGET_UPVEL);
			
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);
	}
	
	SentryBeingChecked = entity;
	//We do not currently have a target or our target is hiding behind something, find a new target:
	if (!Toss_IsValidTarget(target) && gt >= Toss_SentryStats[entity].nextTargetTime)
	{
		target = Toss_GetClosestTarget(entity, team == TFTeam_Red ? TFTeam_Blue : TFTeam_Red, distance);
		if (IsValidEntity(target))
		{
			if (distance > Toss_SentryStats[entity].radiusDetection)
				target = -1;
			else
			{
				EmitSoundToAll(SOUND_TOSS_TARGETLOCKED, entity, _, _, _, _, _, -1);
				
				if (IsValidClient(target))
					EmitSoundToClient(target, SOUND_TOSS_TARGETWARNING, _, _, 110);
			}
		}
	}
	
	if (Toss_IsValidTarget(target))	//We have a target, rotate to face them and fire if we are able.
	{
		StopSound(entity, SNDCHAN_AUTO, SOUND_DRONE_SCANNING);
		
		int marked = Toss_GetMarkedTarget(entity);
		if (IsValidMulti(marked, _, _, true, grabEnemyTeam(owner)))
			target = marked;
		
		float otherPos[3];
		CF_WorldSpaceCenter(target, otherPos);
		//GetClientAbsOrigin(target, otherPos);
		
		//The target has escaped our firing radius, unlock.
		if (GetVectorDistance(pos, otherPos) > Toss_SentryStats[entity].radiusFire)
		{
			target = -1;
			Toss_SentryStats[entity].target = -1;
			EmitSoundToAll(SOUND_DRONE_SCANNING, entity);
			EmitSoundToAll(SOUND_DRONE_SCANNING, entity);
			Toss_SentryStats[entity].nextScanSound = gt + scan_sound_time;
		}
		else	//The target is still in our firing radius, turn to face them and fire if able.
		{
			//otherPos[2] += 40.0 * (CF_GetCharacterScale(target));
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
			
			TeleportEntity(entity, NULL_VECTOR, angles, vel);
			
			if (gt >= Toss_SentryStats[entity].NextShot && CanShoot)
			{
				Toss_SentryStats[entity].NextShot = gt + (Toss_SentryStats[entity].fireRate / (gt <= Toss_SentryStats[entity].superchargeEndTime ? (Toss_SentryStats[entity].superchargedType == 1 ? Toss_SentryStats[entity].superchargeFire_Hitscan : Toss_SentryStats[entity].superchargeFire) : 1.0));
				
				//Run a traceray to see if our shot will hit the target, or any other target on their team for that matter.
				int victim = target;
				Toss_TraceTeam = GetEntProp(entity, Prop_Send, "m_iTeamNum");
				TR_TraceRayFilter(pos, angles, MASK_SHOT, RayType_Infinite, Toss_OnlyHitEnemies);
				victim = TR_GetEntityIndex();
				
				//This just gets the location where the beam should be fired.
				int r = 255;
				int b = 120;
				if (team == TFTeam_Blue)
				{
					r = 120;
					b = 255;
				}
				
				Toss_TraceTarget = target;
				GetPointFromAngles(pos, angles, 99999.0, otherPos, Toss_IgnoreAllButTarget, MASK_SHOT);
				
				int muzzle = AttachParticleToEntity(entity, team == TFTeam_Red ? PARTICLE_MUZZLE_RED_2 : PARTICLE_MUZZLE_BLUE_2, "muzzle", 2.0);
				if (IsValidEntity(muzzle))
				{
					GetEntPropVector(muzzle, Prop_Data, "m_vecAbsOrigin", pos);
				}
				
				SpawnBeam_Vectors(pos, otherPos, 0.1, 255, 255, 255, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 1.0, 1.0, _, 0.0);
				SpawnBeam_Vectors(pos, otherPos, 0.1, r, 120, b, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 4.0, 4.0, _, 0.0);
				SpawnBeam_Vectors(pos, otherPos, 0.1, r, 120, b, 120, PrecacheModel("materials/sprites/glow02.vmt"), 8.0, 8.0, _, 0.0);
				SpawnBeam_Vectors(pos, otherPos, 0.15, r, 120, b, 80, PrecacheModel("materials/sprites/glow02.vmt"), 12.0, 12.0, _, 0.0);
				SpawnBeam_Vectors(pos, otherPos, 0.2, r, 120, b, 40, PrecacheModel("materials/sprites/glow02.vmt"), 16.0, 16.0, _, 0.0);
				
				//Deal damage if the victim is valid.
				if (IsValidEntity(victim))
					SDKHooks_TakeDamage(victim, entity, owner, Toss_SentryStats[entity].damage, DMG_BULLET, _, _, _, false);
				
				EmitSoundToAll(gt <= Toss_SentryStats[entity].superchargeEndTime ? SOUND_TOSS_SHOOT_SUPERCHARGE : SOUND_TOSS_SHOOT, entity, _, _, _, _, _, -1);
			}
			
			Toss_SentryStats[entity].target = EntIndexToEntRef(target);
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
			
		TeleportEntity(entity, NULL_VECTOR, angles, vel);
		
		if (gt >= Toss_SentryStats[entity].nextScanSound)
		{
			EmitSoundToAll(SOUND_DRONE_SCANNING, entity);
			EmitSoundToAll(SOUND_DRONE_SCANNING, entity);
			Toss_SentryStats[entity].nextScanSound = gt + scan_sound_time;
		}
	}
	
	Toss_SentryStats[entity].previousPitch = angles[0];
	Toss_SentryStats[entity].previousYaw = angles[1];
	Toss_SentryStats[entity].previousRoll = angles[2];
		
	RequestFrame(Toss_CustomSentryLogic, ref);
}

//Gets the closest target for a Drone to shoot at.
public int Toss_GetClosestTarget(int entity, TFTeam targetTeam, float &distance)
{
	SentryBeingChecked = entity;
	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	int closest = Toss_GetMarkedTarget(entity);
	
	if (!IsValidMulti(closest))
		closest = CF_GetClosestTarget(pos, true, distance, Toss_SentryStats[entity].radiusDetection, targetTeam, GADGETEER, Toss_IsValidTarget);
	
	return closest;
}

public int Toss_GetMarkedTarget(int entity)
{
	SentryBeingChecked = entity;
	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	int owner = GetClientOfUserId(Toss_SentryStats[entity].owner);
	if (IsValidClient(owner))
	{
		int target = GetClientOfUserId(Toss_Marked[owner]);
		if (GetGameTime() <= Toss_MarkTime[owner] && IsValidMulti(target, _, _, true, grabEnemyTeam(owner)))
		{
			float vicLoc[3];
			CF_WorldSpaceCenter(target, vicLoc);
			float dist = GetVectorDistance(pos, vicLoc);
			if (Toss_IsValidTarget(target) && dist <= Toss_SentryStats[entity].radiusDetection)
			{
				return target;
			}
		}
	}
	
	return -1;
}

//Used to determine if a given entity is a valid target for a Drone to shoot at.
public bool Toss_IsValidTarget(int entity)
{
	return Toss_HasLineOfSight(SentryBeingChecked, entity) && Entity_Can_Be_Shot(entity) && !IsPlayerInvis(entity);
}

//Gets the distance from a given position to the nearest surface in a direction, using the mods for the angle.
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

//Used to determine if a Drone has line-of-sight to a given target.
public bool Toss_HasLineOfSight(int entity, int target)
{
	if (!IsValidEntity(entity) || !IsValidEntity(target))
		return false;
		
	float pos[3], otherPos[3];
	CF_WorldSpaceCenter(entity, pos);
	CF_WorldSpaceCenter(target, otherPos);
		
	Handle trace = TR_TraceRayFilterEx(pos, otherPos, MASK_SHOT, RayType_EndPoint, Toss_IgnoreDrones, target);
	bool DidHit = TR_DidHit(trace);
	delete trace;
	return !DidHit;
}

public void CF_OnGenericProjectileTeamChanged(int entity, TFTeam newTeam)
{
	if (Toss_IsToolbox[entity])
	{
		SetEntData(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_nSkin"), view_as<int>(newTeam) - 2, 1, true);
		Toss_RemoveParticle(entity);
		
		if (!Toss_IsSupportDrone[entity])
			Toss_ToolboxParticle[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_TOOLBOX_TRAIL_RED : PARTICLE_TOOLBOX_TRAIL_BLUE, ""));
		else
			Toss_ToolboxParticle[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_SUPPORT_BOX_TRAIL_RED : PARTICLE_SUPPORT_BOX_TRAIL_BLUE, ""));

		Toss_ToolboxOwner[entity] = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	}
}

public void Toss_RemoveParticle(int entity)
{
	int part = EntRefToEntIndex(Toss_ToolboxParticle[entity]);
	if (IsValidEntity(part))
		RemoveEntity(part);
		
	Toss_ToolboxParticle[entity] = -1;
}

bool b_ToolboxVM[MAXPLAYERS + 1] = { false, ... };

//Activates Toolbox Toss by throwing the toolbox.
public void Toss_Activate(int client, char abilityName[255])
{
	Toss_Max[client] = CF_GetArgI(client, GADGETEER, abilityName, "sentry_max");
	
	int toolbox = MakeToolbox(client, abilityName, false);
	if (IsValidEntity(toolbox))
	{
		Toss_SentryStats[toolbox].CreateFromArgs(client, abilityName, toolbox);
	}
}

public void CF_OnForcedVMAnimEnd(int client, char sequence[255])
{
	if (!b_ToolboxVM[client])
		return;
		
	if (IsPlayerHoldingWeapon(client, 0))
		CF_ForceViewmodelAnimation(client, "fj_draw", false, false, false);
	else if (IsPlayerHoldingWeapon(client, 1))
		CF_ForceViewmodelAnimation(client, "pstl_draw", false, false, false);
	else if (IsPlayerHoldingWeapon(client, 2))
		CF_ForceViewmodelAnimation(client, "gun_draw", false, false, false);
			
	b_ToolboxVM[client] = false;
}

int Icon_Target[2049] = { -1, ... };
int Icon_Mark[MAXPLAYERS + 1] = { -1, ... };

public Action CF_OnTakeDamageAlive_Pre(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if (!IsValidClient(attacker))
		return Plugin_Continue;
		
	if (Toss_Sentries[attacker] == null || !IsValidEntity(weapon))
		return Plugin_Continue;
		
	float markTime = TF2CustAttr_GetFloat(weapon, "weapon marks victims for drones", 0.0);
	if (markTime <= 0.0)
		return Plugin_Continue;
		
	bool DontApplyVFX = false;
	int current = EntRefToEntIndex(Icon_Mark[attacker])
	if (IsValidEntity(current))
	{
		ParticleBody currentIcon = view_as<ParticleBody>(current);
		if (GetClientUserId(victim) == Toss_Marked[attacker])
		{
			currentIcon.End_Time = GetGameTime() + markTime;
			DontApplyVFX = true;
		}
		else
		{
			currentIcon.Fading = true;
			currentIcon.Logic = INVALID_FUNCTION;
			currentIcon.Logic_Plugin = null;
		}
	}
	
	if (GetClientUserId(victim) != Toss_Marked[attacker] || GetGameTime() > Toss_MarkTime[attacker])
	{
		EmitSoundToClient(attacker, SOUND_DRONES_TARGETING, _, _, _, _, _, 130);
		EmitSoundToClient(victim, SOUND_DRONES_TARGETING, _, _, _, _, _, 130);
	}
	
	Toss_Marked[attacker] = GetClientUserId(victim);
	Toss_MarkTime[attacker] = GetGameTime() + markTime;
	
	if (!DontApplyVFX)
	{
		int r = 255;
		int b = 120;
		if (TF2_GetClientTeam(attacker) == TFTeam_Blue)
		{
			b = 255;
			r = 120;
		}
		
		float pos[3];
		GetClientAbsOrigin(victim, pos);
		pos[2] += 50.0 * CF_GetCharacterScale(victim);
		
		int fake = FPS_SpawnFakeParticle(pos, NULL_VECTOR, MODEL_TARGETING, 0, "spin", 0.33, 0.0, r, 120, b, 180, 16.0 * CF_GetCharacterScale(victim));
		
		ParticleBody PBody = FPS_CreateParticleBody(pos, NULL_VECTOR, markTime, GADGETEER, Toss_TargetLogic, 6.0);
		PBody.AddEntity(fake);
		
		int color[4];
		color[0] = r;
		color[1] = 120;
		color[2] = b;
		color[3] = 120;
		
		PBody.AddLight(color, 1, 300.0);
		
		Icon_Target[PBody.Index] = GetClientUserId(victim);
		Icon_Mark[attacker] = EntIndexToEntRef(PBody.Index);
		SDKHook(PBody.Index, SDKHook_SetTransmit, Icon_Transmit);
	}
	
	return Plugin_Continue;
}

public Action Icon_Transmit(int entity, int client)
{
 	SetEdictFlags(entity, GetEdictFlags(entity)&(~FL_EDICT_ALWAYS));
 	
 	int targ = GetClientOfUserId(Icon_Target[entity]);
 	if (!IsValidClient(targ))
 		return Plugin_Continue;
 		
 	if (IsPlayerInvis(targ) || (client == targ && (!GetEntProp(client, Prop_Send, "m_nForceTauntCam") && !TF2_IsPlayerInCondition(client, TFCond_Taunting))))
 	{
 		return Plugin_Handled;
 	}
 	
 	return Plugin_Continue;
}

public void Toss_TargetLogic(int entity)
{
	ParticleBody PBody = view_as<ParticleBody>(entity);
	int vic = GetClientOfUserId(Icon_Target[entity]);
	if (!IsValidMulti(vic))
	{
		PBody.Fading = true;
		PBody.Logic = INVALID_FUNCTION;
		PBody.Logic_Plugin = null;
		return;
	}
	
	float pos[3], ang[3];
	GetClientAbsOrigin(vic, pos);
	GetClientAbsAngles(vic, ang);
	pos[2] += 50.0 * CF_GetCharacterScale(vic);
	
	int frame = GetEntProp(entity, Prop_Send, "m_ubInterpolationFrame");
	TeleportEntity(entity, pos, ang);
	SetEntProp(entity, Prop_Send, "m_ubInterpolationFrame", frame);
}

//Checks each frame to see if the toolbox is ready to auto-detonate. If it is, it automatically spawns a sentry.
//Otherwise, it performs a manual hull trace every frame to detect when the toolbox collides with an enemy.
//If it does (once per 0.2s), it will damage them, apply knockback, and cause the toolbox to bounce upward.
public void Toss_CheckForCollision(int ref)
{
	int prop = EntRefToEntIndex(ref);
	if (!IsValidEntity(prop))
		return;
		
	int client = GetClientOfUserId(Toss_ToolboxOwner[prop]);
	if (!IsValidClient(client))
		return;
		
	float pos[3], mins[3], maxs[3], vel[3];
	GetEntPropVector(prop, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(prop, Prop_Send, "m_vecMins", mins);
	GetEntPropVector(prop, Prop_Send, "m_vecMaxs", maxs);
	GetEntPropVector(prop, Prop_Data, "m_vecVelocity", vel);
	
	bool CanHit = GetVectorLength(vel) >= Toss_MinVel[prop];
		
	//We go a tiny bit bigger so that we aren't interfering with normal collisions:
	ScaleVector(mins, 1.1);
	ScaleVector(maxs, 1.1);
		
	float gt = GetGameTime();
	if (gt >= Toss_AutoDetTime[prop])
	{
		Toss_SpawnSentry(prop, false, 0);
		return;
	}
	else if (gt >= Toss_NextBounce[prop] && CanHit)
	{	
		Toss_TraceTeam = GetEntProp(prop, Prop_Send, "m_iTeamNum");
		TFTeam targetTeam = view_as<TFTeam>(view_as<TFTeam>(Toss_TraceTeam) == TFTeam_Red ? TFTeam_Blue : TFTeam_Red);
		TR_TraceHullFilter(pos, pos, mins, maxs, MASK_SHOT, Toss_OnlyHitEnemies);
		if (TR_DidHit())
		{
			int other = TR_GetEntityIndex();
			
			if (CF_IsValidTarget(other, targetTeam))
			{
				float ang[3];
				GetEntPropVector(prop, Prop_Send, "m_angRotation", ang);
				ang[0] = -45.0;
				ang[2] = 0.0;
				
				CF_ApplyKnockback(other, Toss_KB[prop], ang);
				
				/*GetVelocityInDirection(ang, Toss_KB[prop], vel);
				vel[2] += Toss_KB[prop];
				TeleportEntity(other, _, _, vel);*/
				vel[0] = 0.0;
				vel[1] = 0.0;
				vel[2] = Toss_UpVel[prop];
				TeleportEntity(prop, _, _, vel);
				
				SDKHooks_TakeDamage(other, prop, client, Toss_DMG[prop], _, _, _, _, false);
				
				SpawnParticle(pos, PARTICLE_TOSS_HIT_PLAYER_1, 3.0);
				SpawnParticle(pos, PARTICLE_TOSS_HIT_PLAYER_2, 3.0);
				
				EmitSoundToAll(SOUND_TOSS_TOOLBOX_HIT_PLAYER_1, prop, _, 110, _, _, GetRandomInt(90, 110), -1);
				EmitSoundToAll(SOUND_TOSS_TOOLBOX_HIT_PLAYER_2, prop, _, _, _, _, GetRandomInt(90, 110), -1);
				
				EmitSoundToClient(client, SOUND_TOSS_TOOLBOX_HIT_PLAYER_1);
				EmitSoundToClient(client, SOUND_TOSS_TOOLBOX_HIT_PLAYER_2);
				
				if (IsValidClient(other))
				{
					EmitSoundToClient(other, SOUND_TOSS_TOOLBOX_HIT_PLAYER_1);
					EmitSoundToClient(other, SOUND_TOSS_TOOLBOX_HIT_PLAYER_2);
				}
				
				Toss_NextBounce[prop] = gt + 0.2;
			}
		}
	}
	
	ScaleVector(mins, 1.15);
	ScaleVector(maxs, 1.15);
	ToolboxToIgnore = prop;
	TR_TraceHullFilter(pos, pos, mins, maxs, MASK_SHOT, Toss_IgnoreThisToolbox);
	if (TR_DidHit())
	{
		if (!Toss_WasHittingSomething[prop])
			EmitSoundToAll(SOUND_TOSS_HIT_WORLD, prop, _, _, _, _, GetRandomInt(80, 110));
		
		Toss_WasHittingSomething[prop] = true;
	}
	else
	{
		Toss_WasHittingSomething[prop] = false;
	}
	
	RequestFrame(Toss_CheckForCollision, ref);
}

//Detects when the toolbox collides with one of the owner's projectiles, and ultra-charges it if it does.
public Action Toss_ToolboxTouch(int prop, int other)
{
	int client = GetClientOfUserId(Toss_ToolboxOwner[prop]);
	if (!IsValidClient(client))
		return Plugin_Continue;
		
	//If the toolbox collided with one of the owner's projectiles, trigger the supercharge using projectile stats.
	if (HasEntProp(other, Prop_Send, "m_hOwnerEntity"))
	{
		int otherOwner = GetEntPropEnt(other, Prop_Send, "m_hOwnerEntity");
		char classname[255];
		GetEntityClassname(other, classname, sizeof(classname));
		if (StrContains(classname, "tf_projectile_") != -1 && otherOwner == client)
		{
			float pos[3];
			GetEntPropVector(other, Prop_Send, "m_vecOrigin", pos);
			SpawnParticle(pos, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_SUPERCHARGE_IMPACT_RED : PARTICLE_SUPERCHARGE_IMPACT_BLUE);
			
			GetEntPropVector(prop, Prop_Send, "m_vecOrigin", pos);
			pos[2] += 20.0 * Toss_SentryStats[prop].scale;
			int text = WorldText_Create(pos, NULL_VECTOR, "ULTRA-CHARGED!", 15.0);
			if (IsValidEntity(text))
			{
				WorldText_MimicHitNumbers(text, 2.0, 3.0, 0.5);
				WorldText_SetRainbow(text, true);
			}

			RemoveEntity(other);
			
			Toss_SpawnSentry(prop, true, 2);
		}
	}
	
	return Plugin_Continue;
}

//Used to detect when a toolbox is shot by hitscan. When this happens: spawn the Drone immediately and supercharge it.
public Action Toss_ToolboxDamaged(int prop, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	damage = 0.0;
		
	int owner = GetClientOfUserId(Toss_ToolboxOwner[prop]);
	if (!IsValidClient(owner))
		return Plugin_Changed;
		
	if (attacker == owner)
	{
		float pos[3];
		GetEntPropVector(prop, Prop_Send, "m_vecOrigin", pos);
		pos[2] += 20.0 * Toss_SentryStats[prop].scale;
		int text = WorldText_Create(pos, NULL_VECTOR, "SUPERCHARGED!", 10.0);
		if (IsValidEntity(text))
			WorldText_MimicHitNumbers(text, 2.0, 3.0, 0.5);
			
		SpawnParticle(pos, TF2_GetClientTeam(owner) == TFTeam_Red ? PARTICLE_SUPERCHARGE_IMPACT_RED : PARTICLE_SUPERCHARGE_IMPACT_BLUE);
		
		Toss_SpawnSentry(prop, true, 1);
	}
	
	return Plugin_Changed;
}

//Updates a Drone's HP when it takes damage, and simulates hitsounds and damage numbers for the attacker.
public Action Drone_Damaged(int prop, int &attacker, int &inflictor, float &damage, int &damagetype)
{	
	float originalDamage = damage;
	damage = 0.0;
	
	if (!Toss_SentryStats[prop].exists || GetEntProp(prop, Prop_Send, "m_iTeamNum") == GetEntProp(attacker, Prop_Send, "m_iTeamNum"))
		return Plugin_Changed;
	
	if (IsValidClient(attacker))
	{
		if (originalDamage >= Toss_SentryStats[prop].currentHealth)
			ClientCommand(attacker, "playgamesound ui/killsound.wav");
		else
			ClientCommand(attacker, "playgamesound ui/hitsound.wav");
			
		float pos[3];
		GetEntPropVector(prop, Prop_Send, "m_vecOrigin", pos);
		pos[2] += 20.0 * Toss_SentryStats[prop].scale;
		
		char damageDealt[16];
		Format(damageDealt, sizeof(damageDealt), "-%i", RoundToCeil(originalDamage));
		int text = WorldText_Create(pos, NULL_VECTOR, damageDealt, 15.0, _, _, _, 255, 120, 120, 255);
		if (IsValidEntity(text))
		{
			Text_Owner[text] = GetClientUserId(attacker);
			SDKHook(text, SDKHook_SetTransmit, Text_Transmit);
			
			WorldText_MimicHitNumbers(text);
		}
	}
	
	Toss_SentryStats[prop].UpdateHP(-originalDamage);
	
	return Plugin_Changed;
}

//Spawns a Drone from a given toolbox. If supercharged is true, superchargeType is used to determine which supercharge stats to use.
//1: Hitscan, 2: Projectile
public void Toss_SpawnSentry(int toolbox, bool supercharged, int superchargeType)
{
	float pos[3];
	GetEntPropVector(toolbox, Prop_Send, "m_vecOrigin", pos);

	if (Toss_IsSupportDrone[toolbox])
	{
		EmitSoundToAll(SOUND_SUPPORT_BOX_BREAK, toolbox, _, _, _, _, GetRandomInt(90, 110));

		for (int i = 0; i < sizeof(Model_BoxGibs); i++)
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
				
			int gib = SpawnPhysicsProp(Model_BoxGibs[i], 0, "0", 99999.0, true, 1.0, pos, randAng, randVel, 5.0);
			
			if (IsValidEntity(gib))
			{
				SetEntityCollisionGroup(gib, 1);
				SetEntityRenderMode(gib, RENDER_TRANSALPHA);
				RequestFrame(Toss_FadeOutGib, EntIndexToEntRef(gib));
				SetEntityCollisionGroup(gib, 1);
				SetEntProp(gib, Prop_Send, "m_iTeamNum", 0);
			}
		}

		Toss_SpawnSupportDrone(toolbox, supercharged, superchargeType);

		return;
	}

	int owner = GetClientOfUserId(Toss_ToolboxOwner[toolbox]);
	int team = GetEntProp(toolbox, Prop_Send, "m_iTeamNum");
	
	if (!IsValidClient(owner))
	{
		RemoveEntity(toolbox);
		return;
	}
	
	int chosen = GetRandomInt(0, sizeof(Toss_BuildSFX) - 1);
	EmitSoundToAll(Toss_BuildSFX[chosen], toolbox, _, _, _, _, GetRandomInt(90, 110), -1);
	EmitSoundToAll(Toss_BuildSFX[chosen], toolbox, _, _, _, _, GetRandomInt(90, 110), -1);
	EmitSoundToAll(SOUND_TOSS_BUILD_EXTRA, toolbox, _, _, _, _, GetRandomInt(90, 110), -1);
	SpawnParticle(pos, PARTICLE_TOSS_BUILD_1, 2.0);
	SpawnParticle(pos, PARTICLE_TOSS_BUILD_2, 2.0);
	
	int prop = CreateEntityByName("prop_physics_multiplayer");
	if (IsValidEntity(prop))
	{
		Toss_SentryStats[prop].CopyFromOther(Toss_SentryStats[toolbox], prop);
		
		DispatchKeyValue(prop, "targetname", "droneparent"); 
		DispatchKeyValue(prop, "model", MODEL_DRONE_PARENT);
		
		DispatchKeyValue(prop, "solid", "6");
		DispatchKeyValue(prop, "spawnflags", "12288");
		SetEntProp(prop, Prop_Send, "m_usSolidFlags", 8);
		SetEntProp(prop, Prop_Data, "m_nSolidType", 2);
		SetEntityCollisionGroup(prop, 23);
		
		DispatchSpawn(prop);
		
		ActivateEntity(prop);
		
		if (IsValidClient(owner))
		{
			SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", owner);
		}
		
		SetEntProp(prop, Prop_Send, "m_iTeamNum", team);
		
		DispatchKeyValue(prop, "skin", view_as<TFTeam>(team) == TFTeam_Red ? "0" : "1");
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
		SetEntProp(prop, Prop_Data, "m_takedamage", 1, 1);
		
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
		
		Toss_SentryStats[prop].Activate(supercharged, superchargeType);
		
		DataPack pack = new DataPack();
		WritePackCell(pack, EntIndexToEntRef(prop));
		WritePackCell(pack, team);
		WritePackCell(pack, IsValidClient(owner) ? GetClientUserId(owner) : -1);
		RequestFrame(Toss_SetSentryTeamOnDelay, pack);
	}

	RemoveEntity(toolbox);
}

public void Toss_SetSentryTeamOnDelay(DataPack pack)
{
	ResetPack(pack);
	int prop = EntRefToEntIndex(ReadPackCell(pack));
	int team = ReadPackCell(pack);
	int owner = GetClientOfUserId(ReadPackCell(pack));
	delete pack;
	
	if (IsValidEntity(prop))
	{
		SetEntProp(prop, Prop_Send, "m_iTeamNum", team);
		if (IsValidClient(owner))
			SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", owner);
	}
}

//Used to change hitscan interaction rules for Drones and toolboxes.
public Action CF_OnPassFilter(int ent1, int ent2, bool &result)
{
	//Check 1: Don't let Drones be shot by allies.
	if (Toss_SentryStats[ent1].exists)
	{
		int owner = GetClientOfUserId(Toss_SentryStats[ent1].owner);
		if (IsValidClient(owner))
		{
			if (IsValidMulti(ent2, false, _, true, TF2_GetClientTeam(owner)))
			{
				result = false;
				return Plugin_Changed;
			}
		}
	}
	
	if (Toss_SentryStats[ent2].exists)
	{
		int owner = GetClientOfUserId(Toss_SentryStats[ent2].owner);
		if (IsValidClient(owner))
		{
			if (IsValidMulti(ent1, false, _, true, TF2_GetClientTeam(owner)))
			{
				result = false;
				return Plugin_Changed;
			}
		}
	}
	
	//Check 2: Only let toolboxes be shot by their owners.
	if (Toss_IsToolbox[ent1] && IsValidClient(ent2))
	{
		int owner = GetClientOfUserId(Toss_ToolboxOwner[ent1]);
		if (owner != ent2)
		{
			result = false;
			return Plugin_Changed;
		}
	}
	
	if (Toss_IsToolbox[ent2] && IsValidClient(ent1))
	{
		int owner = GetClientOfUserId(Toss_ToolboxOwner[ent2]);
		if (owner != ent1)
		{
			result = false;
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

//Adds a newly-created Drone to the owner's collection of Drones, and deletes the oldest Drone if they go above the max.
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

//Removes a Drone from the client's collection and automatically destroys it.
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

public void CF_OnCharacterCreated(int client)
{
	
}

//Make sure we destroy all of the client's Drones if they disconnect, change their character, or the round state changes.
public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	if (reason == CF_CRR_SWITCHED_CHARACTER || reason == CF_CRR_DISCONNECT || reason == CF_CRR_ROUNDSTATE_CHANGED)
		Toss_DeleteSentries(client);
		
	b_ToolboxVM[client] = false;
}

//Destroys all of the client's Drones and deletes their collection.
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

	int support = EntRefToEntIndex(Toss_SupportDrone[client]);
	if (PNPC_IsNPC(support))
	{
		view_as<PNPC>(support).i_Health = 1;
		SDKHooks_TakeDamage(support, 0, 0, 999999.0, _, _, _, _, false);
	}
}

//Resets global variables associated with given entities when they are destroyed.
//Also triggers Drone destruction effects if the entity is a Drone.
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
		
		if (Toss_IsToolbox[entity])
		{
			StopSound(entity, SNDCHAN_AUTO, SOUND_TOOLBOX_FIZZING);
		}
		
		Toss_RemoveParticle(entity);
		
		Toss_ToolboxOwner[entity] = -1;
		Toss_IsToolbox[entity] = false;
		Toss_IsSupportDrone[entity] = false;

		for (int i = 0; i <= MaxClients; i++)
		{
			b_HealingClient[entity][i] = false;
		}
	}
}

//Used purely to set kill icons for Drones and Toolbox Toss.
public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	if (!IsValidEntity(inflictor))
		return Plugin_Continue;
		
	if (Toss_SentryStats[inflictor].exists)
	{
		Format(weapon, sizeof(weapon), "obj_minisentry");
		Format(console, sizeof(console), "Drone");
		if (GetGameTime() <= Toss_SentryStats[inflictor].superchargeEndTime)
		{
			int type = Toss_SentryStats[inflictor].superchargedType;
			
			critType = type;
			
			if (type == 2)
				Format(console, sizeof(console), "Drone (Supercharged by Projectile)");
			else
				Format(console, sizeof(console), "Drone (Supercharged by Hitscan)");
		}
			
		return Plugin_Changed;
	}
	else if (Toss_IsToolbox[inflictor])
	{
		Format(weapon, sizeof(weapon), "building_carried_destroyed");
		Format(console, sizeof(console), "Toolbox Toss");
		custom = TF_CUSTOM_CARRIED_BUILDING;
		return Plugin_Changed;
	}
		
	return Plugin_Continue;
}

//Used by Drones to detect when they collide with a friendly non-explosive projectile.
//If the weapon which fired that projectile has our custom Rescue Ranger attribute, we heal the Drone.
public Action CF_OnPhysPropHitByProjectile(int prop, int entity, TFTeam propTeam, TFTeam entityTeam, int propOwner, int entityOwner, char classname[255], int launcher, float damage, float pos[3])
{
	if (propTeam != entityTeam || !IsValidEntity(launcher) || !IsValidClient(entityOwner) || !Toss_SentryStats[prop].exists)
		return Plugin_Continue;
	
	if (Toss_SentryStats[prop].currentHealth >= Toss_SentryStats[prop].maxHealth)
		return Plugin_Continue;

	float healPerScrap = TF2CustAttr_GetFloat(launcher, "toolbox drone heal per scrap", 0.0);
	float healCost = TF2CustAttr_GetFloat(launcher, "toolbox drone heal cost", 0.0);
	float totalHealing = 60.0;
	
	if (healPerScrap > 0.0 && healCost > 0.0)
	{
		float resources = CF_GetSpecialResource(entityOwner);
		if (resources < healCost)
			return Plugin_Continue;
			
		if (healCost > resources)
			healCost = resources;
			
		float current = Toss_SentryStats[prop].currentHealth; 
		float maxHP = Toss_SentryStats[prop].maxHealth;
		
		totalHealing = healPerScrap * healCost;
		float afterHeals = current + totalHealing;
		if (afterHeals > maxHP)
		{
			totalHealing -= (afterHeals - maxHP);
		}
		
		Toss_SentryStats[prop].UpdateHP(totalHealing);
		float finalCost = totalHealing / healPerScrap;
		
		CF_GiveSpecialResource(entityOwner, -finalCost);
	}
	else
		return Plugin_Continue;
		
	SpawnParticle(pos, propTeam == TFTeam_Red ? PARTICLE_TOSS_HEAL_RED : PARTICLE_TOSS_HEAL_BLUE, 3.0);
	EmitSoundToClient(entityOwner, SOUND_TOSS_HEAL);
		
	char amountHealed[16];
	Format(amountHealed, sizeof(amountHealed), "+%i", RoundToCeil(totalHealing));
	int text = WorldText_Create(pos, NULL_VECTOR, amountHealed, 15.0, _, _, _, 120, 255, 120, 255);
	if (IsValidEntity(text))
	{
		Text_Owner[text] = GetClientUserId(entityOwner);
		SDKHook(text, SDKHook_SetTransmit, Text_Transmit);
			
		WorldText_MimicHitNumbers(text);
	}
	
	return Plugin_Continue;
}

public int MakeToolbox(int owner, char abilityName[255], bool support)
{
	float velocity = CF_GetArgF(owner, GADGETEER, abilityName, "velocity");
	
	float pos[3], ang[3], vel[3];
	GetClientEyePosition(owner, pos);
	GetClientEyeAngles(owner, ang);
	GetVelocityInDirection(ang, velocity, vel);
	
	TFTeam team = TF2_GetClientTeam(owner);
	
	float throwOffset = 45.0;
	float fLen = throwOffset * Sine( DegToRad( ang[0] + 90.0 ) );
	pos[0] = pos[0] + fLen * Cosine( DegToRad( ang[1] + 0.0) );
	pos[1] = pos[1] + fLen * Sine( DegToRad( ang[1] + 0.0) );
	pos[2] = pos[2] + throwOffset * Sine( DegToRad( -1 * (ang[0] + 0.0)) );

	int toolbox = CreateEntityByName("prop_physics_override");
	if (IsValidEntity(toolbox))
	{
		float gravity = CF_GetArgF(owner, GADGETEER, abilityName, "gravity");
		SetEntityMoveType(toolbox, MOVETYPE_FLYGRAVITY);
		SetEntityGravity(toolbox, gravity);
		
		Toss_DMG[toolbox] = CF_GetArgF(owner, GADGETEER, abilityName, "damage");
		Toss_KB[toolbox] = CF_GetArgF(owner, GADGETEER, abilityName, "knockback");
		Toss_UpVel[toolbox] = CF_GetArgF(owner, GADGETEER, abilityName, "up_vel");
		float CoolMult = CF_GetArgF(owner, GADGETEER, abilityName, "trickshot_mult");
		float massScale = CF_GetArgF(owner, GADGETEER, abilityName, "mass_scale");
		float intertiaScale = CF_GetArgF(owner, GADGETEER, abilityName, "intertia_scale");
		float autoDet = CF_GetArgF(owner, GADGETEER, abilityName, "auto_deploy");
		Toss_AutoDetTime[toolbox] = GetGameTime() + autoDet;
		Toss_MinVel[toolbox] = CF_GetArgF(owner, GADGETEER, abilityName, "minimum_speed");
		
		GetClientEyeAngles(owner, Toss_FacingAng[toolbox]);
		Toss_FacingAng[toolbox][0] = 0.0;
		Toss_FacingAng[toolbox][2] = 0.0;
		
		//SET MODEL:
		if (!support)
		{
			SetEntityModel(toolbox, MODEL_TOSS);
			DispatchKeyValue(toolbox, "skin", team == TFTeam_Red ? "0" : "1");
		}
		else
		{
			SetEntityModel(toolbox, MODEL_SUPPORT_BOX);
		}
		
		//SET SCALE:
		char scale[255];
		Format(scale, sizeof(scale), "%f", CoolMult);
		DispatchKeyValue(toolbox, "modelscale", scale);
		
		//COLLISION RULES:
		DispatchKeyValue(toolbox, "solid", "6");
		DispatchKeyValue(toolbox, "spawnflags", "12288");
		SetEntProp(toolbox, Prop_Send, "m_usSolidFlags", 8);
		SetEntProp(toolbox, Prop_Data, "m_nSolidType", 2);
		SetEntityCollisionGroup(toolbox, 23);
		
		//ACTIVATION:
		DispatchKeyValueFloat(toolbox, "massScale", massScale);
		DispatchKeyValueFloat(toolbox, "intertiascale", intertiaScale);
		DispatchSpawn(toolbox);
		ActivateEntity(toolbox);
		
		//DAMAGE AND TEAM:
		SetEntProp(toolbox, Prop_Data, "m_takedamage", 1, 1);
		SetEntProp(toolbox, Prop_Send, "m_iTeamNum", view_as<int>(team));
		
		//HOOKS:
		SDKHook(toolbox, SDKHook_OnTakeDamage, Toss_ToolboxDamaged);
		SDKHook(toolbox, SDKHook_Touch, Toss_ToolboxTouch);
		RequestFrame(Toss_CheckForCollision, EntIndexToEntRef(toolbox));

		Toss_IsToolbox[toolbox] = true;
		Toss_ToolboxOwner[toolbox] = GetClientUserId(owner);
	
		TeleportEntity(toolbox, pos, ang, vel);
		
		CF_ForceViewmodelAnimation(owner, "spell_fire");
		b_ToolboxVM[owner] = true;
		
		if (!support)
			Toss_ToolboxParticle[toolbox] = EntIndexToEntRef(AttachParticleToEntity(toolbox, team == TFTeam_Red ? PARTICLE_TOOLBOX_TRAIL_RED : PARTICLE_TOOLBOX_TRAIL_BLUE, "", autoDet));
		else
			Toss_ToolboxParticle[toolbox] = EntIndexToEntRef(AttachParticleToEntity(toolbox, team == TFTeam_Red ? PARTICLE_SUPPORT_BOX_TRAIL_RED : PARTICLE_SUPPORT_BOX_TRAIL_BLUE, "", autoDet));
		
		EmitSoundToAll(SOUND_TOOLBOX_FIZZING, toolbox);

		return toolbox;
	}

	return -1;
}

public void Toss_SpawnSupportDrone(int toolbox, bool supercharged, int superchargeType)
{
	int owner = GetClientOfUserId(Toss_ToolboxOwner[toolbox]);
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
	EmitSoundToAll(Toss_BuildSFX[chosen], toolbox, _, _, _, _, GetRandomInt(90, 110), -1);
	EmitSoundToAll(SOUND_TOSS_BUILD_EXTRA, toolbox, _, _, _, _, GetRandomInt(90, 110), -1);
	SpawnParticle(pos, PARTICLE_TOSS_BUILD_1, 2.0);
	SpawnParticle(pos, PARTICLE_TOSS_BUILD_2, 2.0);
	
	if (!TF2Util_IsPointInRespawnRoom(pos))
	{
		char SupportName[255];
		Format(SupportName, sizeof(SupportName), "Support Drone (%N)", owner);

		int oldDrone = EntRefToEntIndex(Toss_SupportDrone[owner]);
		if (IsValidEntity(oldDrone))
		{
			view_as<PNPC>(oldDrone).i_Health = 1;
			SDKHooks_TakeDamage(oldDrone, 0, 0, 99999.0, _, _, _, _, false);
		}

		int drone = PNPC(MODEL_SUPPORT_DRONE, view_as<TFTeam>(team), 1, RoundFloat(Toss_SupportStats[toolbox].maxHealth), team - 2, 0.75, Toss_SupportStats[toolbox].speed, Support_Logic, GADGETEER, 0.1, pos, Toss_FacingAng[toolbox], _, _, SupportName).Index;
		Toss_SupportStats[drone].Copy(Toss_SupportStats[toolbox]);

		Toss_SupportStats[drone].superchargeType = superchargeType;
		switch(superchargeType)
		{
			case 1:
			{
				Toss_SupportStats[drone].superchargeEndTime = GetGameTime() + Toss_SupportStats[drone].superchargeDurationHitscan;
				AttachParticleToEntity(drone, TF2_GetClientTeam(owner) == TFTeam_Red ? PARTICLE_TOSS_SUPERCHARGE_HITSCAN_RED : PARTICLE_TOSS_SUPERCHARGE_HITSCAN_BLUE, "root", Toss_SupportStats[drone].superchargeDurationHitscan);
			}
			case 2:
			{
				Toss_SupportStats[drone].superchargeEndTime = GetGameTime() + Toss_SupportStats[drone].superchargeDuration;
				AttachParticleToEntity(drone, TF2_GetClientTeam(owner) == TFTeam_Red ? PARTICLE_TOSS_SUPERCHARGE_RED : PARTICLE_TOSS_SUPERCHARGE_BLUE, "root", Toss_SupportStats[drone].superchargeDuration);
			}
		}
		
		view_as<PNPC>(drone).SetSequence("spawn");
		view_as<PNPC>(drone).SetPlaybackRate(Toss_SupportStats[drone].CalculateBuildAnimSpeed());
		view_as<PNPC>(drone).SetBleedParticle("buildingdamage_sparks2");
		view_as<PNPC>(drone).AddGib(MODEL_SUPPORT_GIB_1, "laser_bone");
		view_as<PNPC>(drone).AddGib(MODEL_SUPPORT_GIB_2, "laser_bone");
		view_as<PNPC>(drone).AddGib(MODEL_SUPPORT_GIB_3, "bip_base");
		view_as<PNPC>(drone).AddGib(MODEL_SUPPORT_GIB_4, "bip_base");
		view_as<PNPC>(drone).AddGib(MODEL_SUPPORT_GIB_5, "laser_bone");
		Toss_SupportStats[drone].isBuilding = true;
		Toss_SupportStats[drone].lastBuildHealth = 1;
		Toss_SupportStats[drone].owner = GetClientUserId(owner);
		Toss_SupportDrone[owner] = EntIndexToEntRef(drone);
		Toss_IsSupportDrone[drone] = true;
		EmitSoundToAll(SOUND_SUPPORT_BUILD_BEGIN, drone);

		//TODO: Finalize panic sequence
		//Also: Fix Drones instantly disappearing if they spawn too close to a wall/player
	}

	RemoveEntity(toolbox);
}

public void Support_Logic(int drone)
{
	PNPC support = view_as<PNPC>(drone);
	
	float selfPos[3];
	PNPC_WorldSpaceCenter(drone, selfPos);
	if (TF2Util_IsPointInRespawnRoom(selfPos))
	{
		support.i_Health = 1;
		SDKHooks_TakeDamage(drone, 0, 0, 99999.0, _, _, _, _, false);
	}

	if (Toss_SupportStats[drone].isBuilding)
	{
		float healsPerSecond = Toss_SupportStats[drone].maxHealth / Toss_SupportStats[drone].GetBuildTime();
		Toss_SupportStats[drone].buildHealBucket += healsPerSecond * 0.1;
		if (Toss_SupportStats[drone].buildHealBucket >= 1.0)
		{
			int heals = RoundToFloor(Toss_SupportStats[drone].buildHealBucket);
			PNPC_HealEntity(drone, heals);
			Toss_SupportStats[drone].lastBuildHealth += heals;
			Toss_SupportStats[drone].buildHealBucket -= float(heals);

			if (Toss_SupportStats[drone].lastBuildHealth >= RoundFloat(Toss_SupportStats[drone].maxHealth))
			{
				support.i_PathTarget = Toss_SupportStats[drone].GetTarget();
				support.StartPathing();
				support.SetSequence("idle");
				support.SetFlinchSequence("ACT_BOT_GESTURE_FLINCH");
				Toss_SupportStats[drone].isBuilding = false;
				support.SetPlaybackRate(1.0);
				EmitSoundToAll(SOUND_SUPPORT_BUILD_FINISHED, drone);
				EmitSoundToAll(SOUND_SUPPORT_AMBIENT_LOOP, drone);
			}
			else
			{
				support.SetPlaybackRate(Toss_SupportStats[drone].CalculateBuildAnimSpeed());
			}
		}
	}
	else
	{
		int owner = GetClientOfUserId(Toss_SupportStats[drone].owner);
		int target = Toss_SupportStats[drone].GetTarget();

		if (IsValidEntity(target))
			support.i_PathTarget = target;

		float targPos[3];
		PNPC_WorldSpaceCenter(drone, selfPos);
		PNPC_WorldSpaceCenter(target, targPos);

		//Slow down to match the target's speed if we are within range of them, that way we don't run into them.
		float dist = GetVectorDistance(selfPos, targPos);
		float speed = Toss_SupportStats[drone].GetMaxSpeed();
		if (dist <= Toss_SupportStats[drone].healRadius)
		{
			float vel[3];
			GetEntPropVector(target, Prop_Data, "m_vecAbsVelocity", vel);
			float targSpeed = GetVectorLength(vel);

			if (targSpeed > speed)
				targSpeed = speed;

			support.f_Speed = targSpeed;
		}
		else if (support.f_Speed < speed)
		{
			support.f_Speed += speed * 0.33;
			if (support.f_Speed > speed)
				support.f_Speed = speed;
		}
		
		int targHeals = RoundFloat(AddToBucket(Toss_SupportStats[drone].healBucket_Target, Toss_SupportStats[drone].GetHealRate(0) * 0.1, 1.0));
		int otherHeals = RoundFloat(AddToBucket(Toss_SupportStats[drone].healBucket_Others, Toss_SupportStats[drone].GetHealRate(1) * 0.1, 1.0));
		int selfHeals = RoundFloat(AddToBucket(Toss_SupportStats[drone].healBucket_Self, Toss_SupportStats[drone].GetHealRate(2) * 0.1, 1.0));

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidMulti(i, true, true, true, support.i_Team))
			{
				PNPC_WorldSpaceCenter(i, targPos);
				if (GetVectorDistance(selfPos, targPos) <= Toss_SupportStats[drone].healRadius && Toss_HasLineOfSight(drone, i))
				{
					CF_HealPlayer(i, owner, (target == i ? targHeals : otherHeals), 1.0);
					if (!b_HealingClient[drone][i])
					{
						int startParticle, endParticle;
						b_HealingClient[drone][i] = true;
						AttachParticle_ControlPoints(i, "", 0.0, 0.0, 40.0, drone, "", 0.0, 0.0, 30.0, support.i_Team == TFTeam_Red ? PARTICLE_SUPPORT_HEAL_RED : PARTICLE_SUPPORT_HEAL_BLUE, startParticle, endParticle);
						
						EmitSoundToClient(i, SOUND_SUPPORT_HEALING_START, _, _, _, _, 0.8, 120);

						DataPack pack = new DataPack();
						CreateDataTimer(0.1, Support_CheckHealBeam, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(pack, EntIndexToEntRef(drone));
						WritePackCell(pack, GetClientUserId(i));
						WritePackCell(pack, EntIndexToEntRef(startParticle));
						WritePackCell(pack, EntIndexToEntRef(endParticle));
					}
				}
				else
					b_HealingClient[drone][i] = false;
			}
		}

		if (selfHeals >= 1 && support.i_Health < support.i_MaxHealth)
			PNPC_HealEntity(drone, selfHeals);
	}
}

public Action Support_CheckHealBeam(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int drone = EntRefToEntIndex(ReadPackCell(pack));
	int client = GetClientOfUserId(ReadPackCell(pack));
	int startPoint = EntRefToEntIndex(ReadPackCell(pack));
	int endPoint = EntRefToEntIndex(ReadPackCell(pack));

	if (!IsValidMulti(client, true, true) || !IsValidEntity(drone))
	{
		Support_TerminateEffects(client, startPoint, endPoint);
		return Plugin_Stop;
	}

	if (!b_HealingClient[drone][client])
	{
		Support_TerminateEffects(client, startPoint, endPoint);
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public void Support_TerminateEffects(int client, int startPoint, int endPoint)
{
	if (IsValidClient(client))
	{
		StopSound(client, SNDCHAN_AUTO, SOUND_SUPPORT_HEALING_START);
		EmitSoundToClient(client, SOUND_SUPPORT_HEALING_STOP, _, _, _, _, 0.9, 120);
	}

	Support_DeleteBeam(startPoint, endPoint);
}

public void Support_DeleteBeam(int startPoint, int endPoint)
{
	if (IsValidEntity(startPoint))
		RemoveEntity(startPoint);

	if (IsValidEntity(endPoint))
		RemoveEntity(endPoint);
}

public void Support_Activate(int client, char abilityName[255])
{
	int toolbox = MakeToolbox(client, abilityName, true);
	if (IsValidEntity(toolbox))
	{
		Toss_IsSupportDrone[toolbox] = true;
		Toss_SupportStats[toolbox].CreateFromArgs(client, abilityName);
	}
}

public Action PNPC_OnPNPCTakeDamage(PNPC npc, float &damage, int weapon, int inflictor, int attacker, int &damagetype, int &damagecustom)
{
	if (Toss_IsSupportDrone[npc.Index])
	{
		damagetype |= DMG_ALWAYSGIB;

		int halfHP = RoundFloat(npc.i_MaxHealth * 0.5);
		if (npc.i_Health > halfHP && npc.i_Health - RoundFloat(damage) <= halfHP)
		{
			npc.SetSequence("panic_start_A");
			//TODO: Force panic sequence after this anim ends, also play a sound here
		}

		int chosen = GetRandomInt(0, sizeof(Drone_DamageSFX) - 1);
		int pitch = GetRandomInt(90, 110);
		EmitSoundToAll(Drone_DamageSFX[chosen], npc.Index, _, _, _, _, pitch, -1);
		EmitSoundToAll(Drone_DamageSFX[chosen], npc.Index, _, _, _, _, pitch, -1);

		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public void PNPC_OnPNPCDestroyed(int entity)
{
	if (Toss_IsSupportDrone[entity])
	{
		float pos[3];
		PNPC_WorldSpaceCenter(entity, pos);
		SpawnParticle(pos, PARTICLE_TOSS_DESTROYED);
		EmitSoundToAll(SOUND_SUPPORT_DESTROYED, entity, _, 120);
	}
}