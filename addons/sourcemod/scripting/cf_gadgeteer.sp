#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <worldtext>
#include <fakeparticles>
#include <pnpc>

#define GADGETEER		"cf_gadgeteer"
#define TOSS			"gadgeteer_sentry_toss"
#define SUPPORTDRONE	"gadgeteer_support_drone"
#define COMMAND			"gadgeteer_command_support_drone"
#define ANNIHILATION	"gadgeteer_annihilation"
#define SCRAP			"gadgeteer_scrap_blaster"
#define BUDDY			"gadgeteer_little_buddy"
#define COMMANDBUDDY	"gadgeteer_command_little_buddy"

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
#define MODEL_ANNIHILATION_TELEPORTER		"models/buildables/teleporter_light.mdl"
#define MODEL_ANNIHILATION_BUILDING			"models/buildables/teleporter.mdl"
#define MODEL_ANNIHILATION_BUSTER			"models/chaos_fortress/gadgeteer/annihilation_buster.mdl"
#define MODEL_TELE_GIB_1		"models/buildables/gibs/teleporter_gib1.mdl"
#define MODEL_TELE_GIB_2		"models/buildables/gibs/teleporter_gib2.mdl"
#define MODEL_TELE_GIB_3		"models/buildables/gibs/teleporter_gib3.mdl"
#define MODEL_TELE_GIB_4		"models/buildables/gibs/teleporter_gib4.mdl"
#define MODEL_BUDDY				"models/bots/engineer/bot_engineer.mdl"
#define MODEL_BUDDY_PISTOL		"models/weapons/c_models/c_pistol/c_pistol.mdl"

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
#define SOUND_SUPPORT_PANIC_BEGIN		")vo/bot_worker/tinybot_crosspaths_06.mp3"
#define SOUND_SUPPORT_COMMANDED			"ui/cyoa_ping_in_progress.wav"
#define NOPE							"replay/record_fail.wav"
#define SOUND_TELE_WAVE					")mvm/mvm_tele_deliver.wav"
#define SOUND_BUSTER_LOOP				")mvm/sentrybuster/mvm_sentrybuster_loop.wav"
#define SOUND_BUSTER_WINDUP				")mvm/sentrybuster/mvm_sentrybuster_spin.wav"
#define SOUND_BUSTER_EXPLODE			")mvm/sentrybuster/mvm_sentrybuster_explode.wav"
#define SOUND_BUSTER_STEP				")mvm/sentrybuster/mvm_sentrybuster_step_01.wav"
#define SOUND_TELE_LOOP					")weapons/teleporter_spin3.wav"
#define SOUND_TELE_SPAWNED				")mvm/giant_common/giant_common_explodes_02.wav"
#define SOUND_TELE_DESTROYED			")weapons/teleporter_explode.wav"
#define SOUND_TELE_SD_WARNING			")weapons/medi_shield_burn_05.wav"
#define SOUND_SUPPORT_GIVE_AMMO			")items/gift_pickup.wav"
#define SOUND_BUDDY_BOOTUP_LOOP			")chaos_fortress/gadgeteer/little_buddy_bootup_loop.wav"
#define SOUND_BUDDY_ACTIVATE			")mvm/mvm_deploy_small.wav"
#define SOUND_BUDDY_FIRE				")weapons/pistol_shoot.wav"
#define SOUND_ANNIHILATION_BUILD_LOOP	")mvm/sentrybuster/mvm_sentrybuster_loop.wav"
#define SOUND_ANNIHILATION_BUILD_LOOP_2	")player/quickfix_invulnerable_on.wav"
#define SOUND_ANNIHILATION_BUILD_END	")player/invuln_off_vaccinator.wav"
#define SOUND_TELE_BUILDING				")mvm/mvm_tank_deploy.wav"

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
#define PARTICLE_SUPPORT_DAMAGED		"dispenserdamage_3"
#define PARTICLE_SCRAP_TRACER_RED		"bullet_scattergun_tracer01_red"
#define PARTICLE_SCRAP_TRACER_BLUE		"bullet_scattergun_tracer01_blue"
#define PARTICLE_SUPPORT_COMMANDED		"ping_circle"
#define PARTICLE_ANNIHILATION_TELE_RED_1	"raygun_projectile_red_crit"
#define PARTICLE_ANNIHILATION_TELE_RED_2	"teleporter_red_charged_level3"
#define PARTICLE_ANNIHILATION_TELE_BLU_1	"raygun_projectile_blue_crit"
#define PARTICLE_ANNIHILATION_TELE_BLU_2	"teleporter_blue_charged_level3"
#define PARTICLE_TELE_SPAWNED_RED			"drg_cow_explosioncore_charged"
#define PARTICLE_TELE_SPAWNED_BLUE			"drg_cow_explosioncore_charged_blue"
#define PARTICLE_TELE_WAVE_1_RED			"powerup_supernova_explode_red"
#define PARTICLE_TELE_WAVE_1_BLUE			"powerup_supernova_explode_blue"
#define PARTICLE_TELE_WAVE_2_RED			"teleportedin_red"
#define PARTICLE_TELE_WAVE_2_BLUE			"teleportedin_blue"
#define PARTICLE_ANNIHILATION_TELE_BOOM		"hightower_explosion"
#define PARTICLE_BUSTER_LIGHT_RED			"raygun_projectile_red"
#define PARTICLE_BUSTER_LIGHT_BLUE			"raygun_projectile_blue"
#define PARTICLE_BUSTER_EXPLODE				"rd_robot_explosion"
#define PARTICLE_BUSTER_GLOW_RED			"player_recent_teleport_red"
#define PARTICLE_BUSTER_GLOW_BLUE			"player_recent_teleport_blue"
#define PARTICLE_BUDDY_BOOTUP_RED			"mvm_emergencylight_glow_red"
#define PARTICLE_BUDDY_BOOTUP_BLUE			"mvm_emergencylight_glow"
#define PARTICLE_BUDDY_ACTIVATED_RED		"utaunt_poweraura_red_start"
#define PARTICLE_BUDDY_ACTIVATED_BLUE		"utaunt_poweraura_blue_start"
#define PARTICLE_BUDDY_TRACER				"bullet_pistol_tracer01_blue"
#define PARTICLE_BUDDY_MUZZLE				"muzzle_pistol_flare"

#define MODEL_TARGETING		"models/fake_particles/plane.mdl"

static char g_LittleBuddyDeathSounds[][] = {
	")vo/mvm/norm/engineer_mvm_paincriticaldeath01.mp3",
	")vo/mvm/norm/engineer_mvm_paincriticaldeath02.mp3",
	")vo/mvm/norm/engineer_mvm_paincriticaldeath03.mp3",
	")vo/mvm/norm/engineer_mvm_paincriticaldeath04.mp3",
	")vo/mvm/norm/engineer_mvm_paincriticaldeath05.mp3",
	")vo/mvm/norm/engineer_mvm_paincriticaldeath06.mp3"
};

static char g_LittleBuddyPainSounds[][] = {
	")vo/mvm/norm/engineer_mvm_painsharp01.mp3",
	")vo/mvm/norm/engineer_mvm_painsharp02.mp3",
	")vo/mvm/norm/engineer_mvm_painsharp03.mp3",
	")vo/mvm/norm/engineer_mvm_painsharp04.mp3",
	")vo/mvm/norm/engineer_mvm_painsharp05.mp3",
	")vo/mvm/norm/engineer_mvm_painsharp06.mp3",
	")vo/mvm/norm/engineer_mvm_painsharp07.mp3",
	")vo/mvm/norm/engineer_mvm_painsharp08.mp3"
};

static char g_LittleBuddyCommandedSounds[][] = {
	")vo/mvm/norm/engineer_mvm_yes01.mp3",
	")vo/mvm/norm/engineer_mvm_yes02.mp3",
	")vo/mvm/norm/engineer_mvm_yes03.mp3"
};

static char g_LittleBuddyActivatedSounds[][] = {
	")vo/mvm/norm/engineer_mvm_sentrypacking02.mp3",
	")vo/mvm/norm/engineer_mvm_battlecry05.mp3"
};

static char g_LittleBuddyThreatSounds[][] = {
	")vo/mvm/norm/engineer_mvm_dominationspy07.mp3",
	")vo/mvm/norm/engineer_mvm_meleedare03.mp3",
	")vo/mvm/norm/engineer_mvm_meleedare02.mp3",
	")vo/mvm/norm/engineer_mvm_meleedare01.mp3"
};

static char g_MetallicImpactSounds[][] = { 
	")weapons/crowbar/crowbar_impact1.wav",
	")weapons/crowbar/crowbar_impact2.wav"
};

static char g_LittleBuddyGibs[][] = { 
	"models/player/gibs/gibs_bolt.mdl",
	"models/player/gibs/gibs_gear1.mdl",
	"models/player/gibs/gibs_gear2.mdl",
	"models/player/gibs/gibs_gear3.mdl",
	"models/player/gibs/gibs_gear4.mdl",
	"models/player/gibs/gibs_gear5.mdl",
};

int Laser_Model = -1;
int Lightning_Model = -1;
int Glow_Model = -1;

bool LateLoad;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	LateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvent("player_builtobject", Gadgeteer_OnBuildingConstructed);
	if (LateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
				OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PreThink, GlowThink);
}

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
	PrecacheModel(MODEL_ANNIHILATION_BUSTER);
	PrecacheModel(MODEL_ANNIHILATION_TELEPORTER);
	PrecacheModel(MODEL_ANNIHILATION_BUILDING);
	PrecacheModel(MODEL_TELE_GIB_1);
	PrecacheModel(MODEL_TELE_GIB_2);
	PrecacheModel(MODEL_TELE_GIB_3);
	PrecacheModel(MODEL_TELE_GIB_4);
	PrecacheModel(MODEL_BUDDY);
	PrecacheModel(MODEL_BUDDY_PISTOL);

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
	PrecacheSound(SOUND_SUPPORT_PANIC_BEGIN);
	PrecacheSound(SOUND_SUPPORT_COMMANDED);
	PrecacheSound(NOPE);
	PrecacheSound(SOUND_TELE_WAVE);
	PrecacheSound(SOUND_BUSTER_EXPLODE);
	PrecacheSound(SOUND_BUSTER_LOOP);
	PrecacheSound(SOUND_BUSTER_STEP);
	PrecacheSound(SOUND_BUSTER_WINDUP);
	PrecacheSound(SOUND_TELE_LOOP);
	PrecacheSound(SOUND_TELE_SPAWNED);
	PrecacheSound(SOUND_TELE_DESTROYED);
	PrecacheSound(SOUND_TELE_SD_WARNING);
	PrecacheSound(SOUND_SUPPORT_GIVE_AMMO);
	PrecacheSound(SOUND_BUDDY_ACTIVATE);
	PrecacheSound(SOUND_BUDDY_BOOTUP_LOOP);
	PrecacheSound(SOUND_BUDDY_FIRE);
	PrecacheSound(SOUND_ANNIHILATION_BUILD_LOOP);
	PrecacheSound(SOUND_ANNIHILATION_BUILD_LOOP_2);
	PrecacheSound(SOUND_ANNIHILATION_BUILD_END);
	PrecacheSound(SOUND_TELE_BUILDING);
	
	for (int i = 0; i < (sizeof(g_LittleBuddyDeathSounds));   i++) { PrecacheSound(g_LittleBuddyDeathSounds[i]);   }
	for (int i = 0; i < (sizeof(g_LittleBuddyPainSounds));   i++) { PrecacheSound(g_LittleBuddyPainSounds[i]);   }
	for (int i = 0; i < (sizeof(g_LittleBuddyCommandedSounds));   i++) { PrecacheSound(g_LittleBuddyCommandedSounds[i]);   }
	for (int i = 0; i < (sizeof(g_LittleBuddyActivatedSounds));   i++) { PrecacheSound(g_LittleBuddyActivatedSounds[i]);   }
	for (int i = 0; i < (sizeof(g_LittleBuddyThreatSounds));   i++) { PrecacheSound(g_LittleBuddyThreatSounds[i]);   }

	for (int i = 0; i < (sizeof(g_MetallicImpactSounds));   i++) { PrecacheSound(g_MetallicImpactSounds[i]);   }

	for (int i = 0; i < (sizeof(g_LittleBuddyGibs));   i++) { PrecacheModel(g_LittleBuddyGibs[i]);   }

	Laser_Model = PrecacheModel("materials/sprites/laserbeam.vmt");
	Lightning_Model = PrecacheModel("materials/sprites/lgtning.vmt");
	Glow_Model = PrecacheModel("sprites/glow02.vmt");
}

float f_NextTargetTime[2049] = { 0.0, ... };

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
int i_Buddy[MAXPLAYERS + 1] = { -1, ... };

float Toss_DMG[2049] = { 0.0, ... };
float Toss_KB[2049] = { 0.0, ... };
float Toss_UpVel[2049] = { 0.0, ... };
float Toss_NextBounce[2049] = { 0.0, ... };
float Toss_AutoDetTime[2049] = { 0.0, ... };
float Toss_MinVel[2049] = { 0.0, ... };
float Toss_MarkTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_NextWrangleBeam[2049] = { 0.0, ... };
float Toss_FacingAng[2049][3];
float f_NextAmmo[2049][MAXPLAYERS + 1];

bool Toss_IsToolbox[2049] = { false, ... };
bool Toss_WasHittingSomething[2049] = { false, ... };
bool Toss_IsSupportDrone[2049] = { false, ... };
bool b_HealingClient[2049][MAXPLAYERS + 1];

bool busting = false;
bool teleMegaFrag = false;
bool littleBuddyKill = false;
bool littleBuddySentryMode = false;

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
	float f_AmmoInterval;
	float f_AmmoAmt;

	int lastBuildHealth;
	int superchargeType;
	int targetOverride;
	int owner;
	int autoTarget;
	int self;
	int glow;
	int targetGlow;
	
	bool isBuilding;
	bool exists;
	bool isPanicked;
	bool b_StayStill;

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
		this.f_AmmoInterval = CF_GetArgF(client, GADGETEER, abilityName, "ammo_interval");
		this.f_AmmoAmt = CF_GetArgF(client, GADGETEER, abilityName, "ammo_amount");
		
		this.exists = true;
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
		this.f_AmmoInterval = other.f_AmmoInterval;
		this.f_AmmoAmt = other.f_AmmoAmt;

		this.exists = true;
	}

	void Destroy()
	{
		this.exists = false;
		this.isBuilding = false;
		this.isPanicked = false;
		this.superchargeEndTime = 0.0;
		this.findNewTargetTime = 0.0;
		this.healBucket_Others = 0.0;
		this.healBucket_Self = 0.0;
		this.healBucket_Target = 0.0;
		this.buildHealBucket = 0.0;
	}

	int GetTarget()
	{
		int owner = GetClientOfUserId(this.owner);
		int drone = EntRefToEntIndex(this.self);
		
		//Check 1: Have we commanded the Support Drone to target a specific player, and if we have, is that player still valid?
		int target = GetClientOfUserId(this.targetOverride);
		if (IsValidMulti(target, true, true, true, TF2_GetClientTeam(owner)))
			return target;
		else
			this.targetOverride = -1;

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
	float turnRate_Wrangled;
	float fireRate_Wrangled;
	
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
		this.turnRate_Wrangled = CF_GetArgF(client, GADGETEER, abilityName, "rotation_wrangled");
		this.fireRate_Wrangled = CF_GetArgF(client, GADGETEER, abilityName, "rate_wrangled");
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
		this.turnRate_Wrangled = other.turnRate_Wrangled;
		this.fireRate_Wrangled = other.fireRate_Wrangled;
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
				
				char model[255];
				model = Model_Gears[GetRandomInt(0, sizeof(Model_Gears) - 1)];
				int gear = SpawnPhysicsProp(model, 0, "0", 99999.0, true, 1.0, pos, randAng, randVel, 5.0);
				
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
				CF_PlayRandomSound(owner, owner, "sound_toolbox_drone_destroyed");
		}
		
		this.exists = false;
		this.shooting = false;
		this.text = 0;
	}

	bool Wrangled()
	{
		int user = GetClientOfUserId(this.owner);
		if (!IsValidMulti(user))
			return false;

		int weapon = TF2_GetActiveWeapon(user);
		if (!IsValidEntity(weapon))
			return false;

		char classname[255];
		GetEntityClassname(weapon, classname, sizeof(classname));
		return (StrEqual(classname, "tf_weapon_laser_pointer"));
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

	if (StrContains(abilityName, COMMAND) != -1)
		Support_Command(client, abilityName);

	if (StrContains(abilityName, COMMANDBUDDY) != -1)
		Buddy_Command(client, abilityName);

	if (StrContains(abilityName, ANNIHILATION) != -1)
		Annihilation_Activate(client, abilityName);

	if (StrContains(abilityName, SCRAP) != -1)
		Scrap_Activate(client, abilityName);
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

//A trace which returns true as long as the entity is solid, and NOT on the given team.
public bool Toss_OnlyHitSolids(entity, contentsMask, TFTeam team)
{
	return (Brush_Is_Solid(entity) && !CF_IsValidTarget(entity, team));
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
	bool wrangled = Toss_SentryStats[entity].Wrangled();
	float turnSpeed = (wrangled ? Toss_SentryStats[entity].turnRate_Wrangled : Toss_SentryStats[entity].turnRate);
	
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
	
	if (wrangled)
	{
		StopSound(entity, SNDCHAN_AUTO, SOUND_DRONE_SCANNING);
		StopSound(entity, SNDCHAN_AUTO, SOUND_DRONE_SCANNING);

		float userAng[3], userPos[3], targPos[3], targAng[3], dummyAng[3];
		GetClientEyePosition(owner, userPos);
		GetClientEyeAngles(owner, userAng);
		GetPointInDirection(userPos, userAng, 9999.0, targPos);

		TR_TraceRayFilter(userPos, targPos, MASK_SHOT, RayType_EndPoint, Toss_OnlyHitSolids, team);
		TR_GetEndPosition(targPos); 

		GetAngleToPoint(entity, targPos, dummyAng, targAng);
			
		for (int i = 0; i < 3; i++)
		{
			angles[i] = ApproachAngle(targAng[i], angles[i], turnSpeed);
		}
				
		/*if (angles[2] != 0.0)
		{
			angles[2] = ApproachAngle(0.0, angles[2], turnSpeed);
		}*/
				
		TeleportEntity(entity, NULL_VECTOR, angles, vel);

		if (f_NextWrangleBeam[entity] <= gt)
		{
			GetPointInDirection(pos, angles, 9999.0, targPos);
			TR_TraceRayFilter(pos, targPos, MASK_SHOT, RayType_EndPoint, Toss_OnlyHitSolids, team);
			TR_GetEndPosition(targPos);

			float wrangleBeamPos[3], wrangleBeamAng[3];
			GetEntityAttachment(entity, LookupEntityAttachment(entity, "muzzle"), wrangleBeamPos, wrangleBeamAng);

			int r = 255, b = 120;
			if (team == TFTeam_Blue)
			{
				b = 255;
				r = 120;
			}
			SpawnBeam_Vectors(wrangleBeamPos, targPos, 0.1, r, 120, b, 255, Laser_Model, 1.0, 1.0, 1, 0.0, owner);
			for (int targ = 1; targ <= MaxClients; targ++)
			{
				if (IsValidClient(targ) && targ != owner)
					SpawnBeam_Vectors(wrangleBeamPos, targPos, 0.1, r, 120, b, 120, Laser_Model, 1.0, 1.0, 1, 0.0, targ);
			}

			f_NextWrangleBeam[entity] = gt + 0.05;
		}

		if (gt >= Toss_SentryStats[entity].NextShot && GetClientButtons(owner) & IN_ATTACK != 0)
		{
			Toss_SentryFire(entity, gt, pos, angles, team, owner);
		}
	}
	else
	{
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
					Toss_SentryFire(entity, gt, pos, angles, team, owner);
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
	}
	
	Toss_SentryStats[entity].previousPitch = angles[0];
	Toss_SentryStats[entity].previousYaw = angles[1];
	Toss_SentryStats[entity].previousRoll = angles[2];
		
	RequestFrame(Toss_CustomSentryLogic, ref);
}

public void Toss_SentryFire(int entity, float gt, float pos[3], float angles[3], TFTeam team, int owner)
{
	Toss_SentryStats[entity].NextShot = gt + ((Toss_SentryStats[entity].Wrangled() ? Toss_SentryStats[entity].fireRate_Wrangled : Toss_SentryStats[entity].fireRate) / (gt <= Toss_SentryStats[entity].superchargeEndTime ? (Toss_SentryStats[entity].superchargedType == 1 ? Toss_SentryStats[entity].superchargeFire_Hitscan : Toss_SentryStats[entity].superchargeFire) : 1.0));
					
					//CF_FireGenericBullet(owner, angles, Toss_SentryStats[entity].damage, _, _, _, _, 99999.0, 99999.0, _, _, grabEnemyTeam(owner), _, _, _, pos);

	float endPos[3], hitPos[3];
	GetPointInDirection(pos, angles, 99999.0, endPos);

	if (!CF_HasLineOfSight(pos, endPos, _, endPos, entity))
	{
		UTIL_ImpactTrace(owner, pos, DMG_BULLET);
	}

	ArrayList victims = CF_DoBulletTrace(owner, pos, endPos, 0, grabEnemyTeam(owner), _, _, endPos);
	for (int i = 0; i < GetArraySize(victims); i++)
	{
		int vic = GetArrayCell(victims, i);
						
		CF_TraceShot(owner, vic, pos, endPos, _, false, hitPos);
		SDKHooks_TakeDamage(vic, entity, owner, Toss_SentryStats[entity].damage, DMG_BULLET, _, _, hitPos);
	}
	delete victims;

	int muzzle = AttachParticleToEntity(entity, team == TFTeam_Red ? PARTICLE_MUZZLE_RED_2 : PARTICLE_MUZZLE_BLUE_2, "muzzle", 2.0);
	if (IsValidEntity(muzzle))
	{
		GetEntPropVector(muzzle, Prop_Data, "m_vecAbsOrigin", pos);
	}
			
	//This looks really cool, but after a while it just inexplicably wigs out and stops spawning tracers, which makes it really hard to find the drone.
	//SpawnParticle_ControlPoints(pos, endPos, team == TFTeam_Red ? PARTICLE_DRONE_TRACER_RED : PARTICLE_DRONE_TRACER_BLUE, 0.5);

	int r = 255;
	int b = 120;
	if (team == TFTeam_Blue)
	{
		r = 120;
		b = 255;
	}
	SpawnBeam_Vectors(pos, endPos, 0.1, 255, 255, 255, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 1.0, 1.0, _, 0.0);
	SpawnBeam_Vectors(pos, endPos, 0.1, r, 120, b, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 4.0, 4.0, _, 0.0);
	SpawnBeam_Vectors(pos, endPos, 0.1, r, 120, b, 120, PrecacheModel("materials/sprites/glow02.vmt"), 8.0, 8.0, _, 0.0);
	SpawnBeam_Vectors(pos, endPos, 0.15, r, 120, b, 80, PrecacheModel("materials/sprites/glow02.vmt"), 12.0, 12.0, _, 0.0);
	SpawnBeam_Vectors(pos, endPos, 0.2, r, 120, b, 40, PrecacheModel("materials/sprites/glow02.vmt"), 16.0, 16.0, _, 0.0);

	EmitSoundToAll(gt <= Toss_SentryStats[entity].superchargeEndTime ? SOUND_TOSS_SHOOT_SUPERCHARGE : SOUND_TOSS_SHOOT, entity, _, 80, _, _, _, -1);
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

		//We can't use this because it fucks up the Drone's spawn and puts it in the map void.
		/*
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
		*/

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
Handle g_AnnihilationEndTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
//Make sure we destroy all of the client's Drones if they disconnect, change their character, or the round state changes.
public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	if (reason == CF_CRR_DEATH && g_AnnihilationEndTimer[client] != null && g_AnnihilationEndTimer[client] != INVALID_HANDLE)
	{
		Annihilation_GiveRefund(client);
	}

	Annihilation_DeleteTimer(client);

	if (reason == CF_CRR_SWITCHED_CHARACTER || reason == CF_CRR_DISCONNECT || reason == CF_CRR_ROUNDSTATE_CHANGED)
	{
		Toss_DeleteSentries(client);
		Annihilation_DestroyTeleporter(client);
	}
		
	b_ToolboxVM[client] = false;
}

bool noSupportDroneMessage[MAXPLAYERS + 1] = { false, ... };
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
		noSupportDroneMessage[client] = true;
		view_as<PNPC>(support).Gib();
		noSupportDroneMessage[client] = false;
	}

	support = EntRefToEntIndex(i_Buddy[client]);
	if (PNPC_IsNPC(support))
	{
		noSupportDroneMessage[client] = true;
		view_as<PNPC>(support).Gib();
		noSupportDroneMessage[client] = false;
	}
}
bool Annihilation_IsTele[2049] = { false, ... };
bool b_IsBuddy[2049] = { false, ... };
enum struct AA_Tele
{
	int owner;
	int i_WaveCount;

	float f_NextTeleBeam;
	float f_NextBusterWave;
	float f_SDStartTime;
	float f_SDBlastTime;
	float f_NextBlastWarning;
	float f_BuildEndTime;
	
	float f_SDDuration;
	float f_SDRadius;
	float f_SDDMG;
	float f_SDFalloffStart;
	float f_SDFalloffMax;
	float f_WaveInterval;

	float f_BusterHP;
	float f_BusterSpeed;
	float f_BusterDistance;
	float f_BusterRadius;
	float f_BusterSDDuration;
	float f_BusterDMG;
	float f_BusterFalloffStart;
	float f_BusterFalloffMax;
	float f_AutoDetTime;
	float f_BusterAutoDet;

	bool b_AboutToBlowUp;
	bool b_Built;

	void GetBusterStats(AA_Tele other)
	{
		this.f_BusterRadius = other.f_BusterRadius;
		this.f_BusterDistance = other.f_BusterDistance;
		this.f_BusterSDDuration = other.f_BusterSDDuration;
		this.f_BusterDMG = other.f_BusterDMG;
		this.f_BusterFalloffStart = other.f_BusterFalloffStart;
		this.f_BusterFalloffMax = other.f_BusterFalloffMax;
		this.f_BusterAutoDet = other.f_BusterAutoDet;
	}
}

AA_Tele TeleStats[2049];

int currentBuddy;

enum struct LittleBuddy
{
	int owner;
	int target;
	int targetOverride;
	int targetGlow;
	int enemyTarget;
	int i_Pistol;
	int glow;

	float f_NextTargetTime;
	float f_MaxSpeed;
	float f_NextPainSound;
	float f_BootupEndTime;
	float f_Damage;
	float f_Rate;
	float f_Range;
	float f_IdleDamage;
	float f_IdleRate;
	float f_IdleRange;
	float f_NextShot;
	float f_NextEnemyTime;
	float f_NextScanSound;

	bool b_SentryMode;
	bool b_BootupSequence;
	bool b_HasEnemyTarget;

	PNPC me;

	void FindTarget(float pos[3])
	{
		if (GetGameTime() < this.f_NextTargetTime)
			return;
		
		int targ = this.GetTargetOverride();
		if (!this.IsValidTarget(targ))
			targ = CF_GetClosestTarget(pos, _, _, _, TF2_GetClientTeam(this.GetOwner()));
		
		if (this.IsValidTarget(targ))
			this.SetTarget(targ);
		else
			this.ClearTarget();

		this.f_NextTargetTime = GetGameTime() + 0.2;
	}

	bool IsValidTarget(int targ, bool enemy = false)
	{
		if (enemy)
		{
			currentBuddy = this.me.Index;
			bool result = CF_IsValidTarget(targ, grabEnemyTeam(this.GetOwner()), GADGETEER, Buddy_CheckLOS);

			if (result)
			{
				float pos[3], theirPos[3];
				CF_WorldSpaceCenter(this.me.Index, pos);
				CF_WorldSpaceCenter(targ, theirPos);

				if (GetVectorDistance(pos, theirPos) > (this.b_SentryMode ? this.f_IdleRange : this.f_Range))
					result = false;
			}

			return result;
		}

		return IsValidMulti(targ, _, _, true, TF2_GetClientTeam(this.GetOwner()));
	}

	void SetTarget(int targ)
	{
		this.target = GetClientUserId(targ);
		this.me.i_PathTarget = targ;
		this.me.StartPathing();
	}

	void ClearTarget()
	{
		this.target = -1;
		this.me.i_PathTarget = -1;
		this.me.StopPathing();
	}

	bool FindEnemy(float pos[3])
	{
		if (GetGameTime() < this.f_NextEnemyTime && this.IsValidTarget(this.GetEnemyTarget(), true))
			return true;

		currentBuddy = this.me.Index;
		int targ = this.GetEnemyTarget();
		if (!this.IsValidTarget(targ, true))
			targ = CF_GetClosestTarget(pos, true, _, (this.b_SentryMode ? this.f_IdleRange : this.f_Range), grabEnemyTeam(this.GetOwner()), GADGETEER, Buddy_CheckLOS);

		bool success = this.IsValidTarget(targ, true);
		if (!success)
			this.ClearEnemyTarget();
		else
			this.SetEnemyTarget(targ);

		this.f_NextEnemyTime = GetGameTime() + 0.2;
		return success;
	}

	void SetEnemyTarget(int targ)
	{
		if (targ != this.GetEnemyTarget() || !this.b_HasEnemyTarget)
		{
			int randIndex = GetRandomInt(0, sizeof(g_LittleBuddyThreatSounds) - 1);
			for (int i = 1; i <= MaxClients; i++)
			{
				// I'm assuming that this is probably what was intended here
				if (i != targ && IsClientInGame(i))
				{
					EmitSoundToClient(i, SOUND_TOSS_TARGETLOCKED, this.me.Index, _, 110);
					EmitSoundToClient(i, g_LittleBuddyThreatSounds[randIndex], this.me.Index, _, 110, _, _, 110);
				}
			}
			
			if (IsValidClient(targ))
			{
				EmitSoundToClient(targ, SOUND_TOSS_TARGETWARNING);
				EmitSoundToClient(targ, g_LittleBuddyThreatSounds[GetRandomInt(0, sizeof(g_LittleBuddyThreatSounds) - 1)]);
			}
			
			StopSound(this.me.Index, SNDCHAN_AUTO, SOUND_DRONE_SCANNING);

			this.b_HasEnemyTarget = true;
			if (this.f_NextShot - GetGameTime() < (this.b_SentryMode ? 0.2 : 0.4))
				this.f_NextShot = GetGameTime() + (this.b_SentryMode ? 0.2 : 0.4);
		}

		this.enemyTarget = EntRefToEntIndex(targ);
	}

	void ClearEnemyTarget()
	{
		if (this.b_HasEnemyTarget)
		{
			this.PlayScanSound();
			this.b_HasEnemyTarget = false;
		}

		this.enemyTarget = -1;
	}

	void PlayScanSound()
	{
		EmitSoundToAll(SOUND_DRONE_SCANNING, this.me.Index);
		this.f_NextScanSound = GetGameTime() + scan_sound_time;
	}

	void Shoot()
	{
		int target = this.GetEnemyTarget();
		int pistol = this.GetPistol();
		int client = this.GetOwner();
		float startPos[3], myPos[3], endPos[3], ang[3], targetAng[3];
		GetEntityAttachment(pistol, LookupEntityAttachment(pistol, "muzzle"), startPos, ang);
		
		// Face the target when shooting
		CF_WorldSpaceCenter(target, endPos);
		CF_WorldSpaceCenter(this.me.Index, myPos);
		CF_GetVectorAnglesTwoPoints(myPos, endPos, targetAng);
		targetAng[0] = 0.0;
		targetAng[2] = 0.0;
		// This is apparently supposed to have interpolation, but it clearly doesn't. Oh well
		this.me.SetLocalAngles(targetAng);
		
		littleBuddyKill = true;
		littleBuddySentryMode = this.b_SentryMode;
		SDKHooks_TakeDamage(target, this.me.Index, client, (this.b_SentryMode ? this.f_IdleDamage : this.f_Damage), DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE);
		littleBuddyKill = false;
		littleBuddySentryMode = false;

		SpawnParticle_ControlPoints(startPos, endPos, PARTICLE_BUDDY_TRACER, 0.2);
		SpawnParticle(startPos, PARTICLE_BUDDY_MUZZLE, 0.5);
		EmitSoundToAll(SOUND_BUDDY_FIRE, this.me.Index);
		this.me.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
		
		this.f_NextShot = GetGameTime() + (this.b_SentryMode ? this.f_IdleRate : this.f_Rate);
	}

	int GetTarget() { return GetClientOfUserId(this.target); }
	int GetOwner() { return GetClientOfUserId(this.owner); }
	int GetTargetOverride() { return GetClientOfUserId(this.targetOverride); }
	int GetEnemyTarget() { return EntRefToEntIndex(this.enemyTarget); }
	int GetPistol() { return EntRefToEntIndex(this.i_Pistol); }
}

LittleBuddy buddies[2049];

bool b_IsBuster[2049] = { false, ... };

//Resets global variables associated with given entities when they are destroyed.
//Also triggers Drone destruction effects if the entity is a Drone.
public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
	{
		StopSound(entity, SNDCHAN_AUTO, SOUND_TELE_LOOP);
		StopSound(entity, SNDCHAN_AUTO, SOUND_BUSTER_LOOP);
		StopSound(entity, SNDCHAN_AUTO, SOUND_BUSTER_WINDUP);
		StopSound(entity, SNDCHAN_AUTO, SOUND_DRONE_SCANNING);

		for (int i = 0; i < 4; i++)
			StopSound(entity, SNDCHAN_AUTO, SOUND_BUDDY_BOOTUP_LOOP);

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

		if (Toss_SupportStats[entity].exists)
		{
			Toss_SupportStats[entity].Destroy();
		}
		
		if (Toss_IsToolbox[entity])
		{
			StopSound(entity, SNDCHAN_AUTO, SOUND_TOOLBOX_FIZZING);
		}
		
		Toss_RemoveParticle(entity);
		
		Toss_ToolboxOwner[entity] = -1;
		Toss_IsToolbox[entity] = false;
		Toss_IsSupportDrone[entity] = false;
		Annihilation_IsTele[entity] = false;
		b_IsBuddy[entity] = false;
		b_IsBuster[entity] = false;
		TeleStats[entity].owner = -1;
		f_NextTargetTime[entity] = 0.0;

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
	else if (busting)
	{
		Format(weapon, sizeof(weapon), "pumpkindeath");
		Format(console, sizeof(console), "Annihilation Buster");
		custom = TF_CUSTOM_CARRIED_BUILDING;
		return Plugin_Changed;
	}
	else if (teleMegaFrag)
	{
		Format(weapon, sizeof(weapon), "purgatory");
		Format(console, sizeof(console), "Teleporter Self-Destruct Sequence");
		critType = 2;
		return Plugin_Changed;
	}
	else if (littleBuddyKill)
	{
		if (littleBuddySentryMode)
		{
			Format(weapon, sizeof(weapon), "obj_minisentry");
			Format(console, sizeof(console), "Little Buddy (Sentry Mode)");
		}
		else
		{
			Format(weapon, sizeof(weapon), "pistol");
			Format(console, sizeof(console), "Little Buddy");
		}
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
		CF_GiveUltCharge(entityOwner, totalHealing, CF_ResourceType_Healing);
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

SupportDroneStats stats;

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
	
	stats.Copy(Toss_SupportStats[toolbox]);
	//Toss_SupportStats[toolbox].Copy(stats);
	float facingAng[3];
	facingAng = Toss_FacingAng[toolbox];

	//I have no fucking idea why, but deleting the toolbox BEFORE spawning the support drone instantly crashes the server.
	//Having the toolbox in the same position as the Drone messes up spawn logic, though, so we need to get rid of it.
	//Therefore: teleport off the map.
	RemoveEntity(toolbox);
	//TeleportEntity(toolbox, OFF_THE_MAP);
	DataPack pack = new DataPack();
	RequestFrame(Toss_SpawnSupportOnDelay, pack);
	WritePackCell(pack, GetClientUserId(owner));
	WritePackFloatArray(pack, pos, sizeof(pos));
	WritePackFloatArray(pack, facingAng, sizeof(facingAng));
	WritePackCell(pack, team);
	WritePackCell(pack, superchargeType);
}

public void Toss_SpawnSupportOnDelay(DataPack pack)
{
	ResetPack(pack);
	int owner = GetClientOfUserId(ReadPackCell(pack));
	float pos[3], facingAng[3];
	ReadPackFloatArray(pack, pos, sizeof(pos));
	ReadPackFloatArray(pack, facingAng, sizeof(facingAng));
	int team = ReadPackCell(pack);
	int superchargeType = ReadPackCell(pack);
	delete pack;

	if (!IsValidClient(owner))
		return;

	if (!TF2Util_IsPointInRespawnRoom(pos))
	{
		char SupportName[255];
		Format(SupportName, sizeof(SupportName), "Support Drone (%N)", owner);

		int oldDrone = EntRefToEntIndex(Toss_SupportDrone[owner]);
		if (IsValidEntity(oldDrone))
		{
			noSupportDroneMessage[owner] = true;
			view_as<PNPC>(oldDrone).Gib();
			noSupportDroneMessage[owner] = false;
			//SDKHooks_TakeDamage(oldDrone, 0, 0, 99999.0, _, _, _, _, false);
		}

		int drone = PNPC(MODEL_SUPPORT_DRONE, view_as<TFTeam>(team), 1, RoundFloat(stats.maxHealth), team - 2, 0.75, stats.speed, Support_Logic, GADGETEER, 0.1, pos, facingAng, _, _, SupportName).Index;
		Toss_SupportStats[drone] = stats;
		for (int i = 0; i <= MaxClients; i++)
			f_NextAmmo[drone][i] = 0.0;

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
		
		view_as<PNPC>(drone).b_GibsForced = true;
		view_as<PNPC>(drone).SetSequence("spawn");
		view_as<PNPC>(drone).SetPlaybackRate(Toss_SupportStats[drone].CalculateBuildAnimSpeed());
		view_as<PNPC>(drone).SetBleedParticle("buildingdamage_sparks2");
		view_as<PNPC>(drone).AddGib(MODEL_SUPPORT_GIB_1, "laser_bone");
		view_as<PNPC>(drone).AddGib(MODEL_SUPPORT_GIB_2, "laser_bone");
		view_as<PNPC>(drone).AddGib(MODEL_SUPPORT_GIB_3, "bip_base");
		view_as<PNPC>(drone).AddGib(MODEL_SUPPORT_GIB_4, "bip_base");
		view_as<PNPC>(drone).AddGib(MODEL_SUPPORT_GIB_5, "laser_bone");
		view_as<PNPC>(drone).f_HealthBarHeight = 60.0;
		view_as<PNPC>(drone).b_IsABuilding = true;
		Toss_SupportStats[drone].isBuilding = true;
		Toss_SupportStats[drone].lastBuildHealth = 1;
		Toss_SupportStats[drone].owner = GetClientUserId(owner);
		Toss_SupportDrone[owner] = EntIndexToEntRef(drone);
		Toss_IsSupportDrone[drone] = true;
		Toss_SupportStats[drone].b_StayStill = false;
		EmitSoundToAll(SOUND_SUPPORT_BUILD_BEGIN, drone);
		
		Toss_SupportStats[drone].glow = EntIndexToEntRef(TF2_CreateGlow(drone, 2));
		SetVariantColor({0, 255, 0, 255});
		AcceptEntityInput(Toss_SupportStats[drone].glow, "SetGlowColor");
		SetEntityTransmitState(Toss_SupportStats[drone].glow, FL_EDICT_FULLCHECK);
		SetEntityOwner(Toss_SupportStats[drone].glow, drone);
		SetEntityOwner(drone, owner);
		SDKHook(Toss_SupportStats[drone].glow, SDKHook_SetTransmit, DroneGlowSetTransmit);
	}
}

public Action DroneGlowSetTransmit(int entity, int client)
{
	// kill the glow if the drone or target don't exist
	int drone = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if (drone == INVALID_ENT_REFERENCE)
	{
		RemoveEntity(entity);
		return Plugin_Handled;
	}
	
	int target = GetEntPropEnt(entity, Prop_Send, "m_hTarget");
	if (!IsValidEntity(target))
	{
		RemoveEntity(entity);
		return Plugin_Handled;
	}
	
	// this is necessary for the glow to be hidden from other clients
	SetEntityTransmitState(entity, FL_EDICT_FULLCHECK);
	
	// force glow target to transmit to ensure that the glow is not cut off by visleaves
	SetEdictFlags(target, GetEdictFlags(target)|FL_EDICT_ALWAYS);
	
	int owner = GetEntPropEnt(drone, Prop_Data, "m_hOwnerEntity");
	if (client != owner)
	{
		// only transmit the outline to the owner
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public void GlowThink(int client)
{
	// we don't really need to check this super often so save the performance
	static float nextCheckTime[MAXPLAYERS+1];
	if (GetTickedTime() < nextCheckTime[client])
		return;
	
	nextCheckTime[client] = GetTickedTime()+0.5;
	int buddy = EntRefToEntIndex(i_Buddy[client]);
	int support = EntRefToEntIndex(Toss_SupportDrone[client]);
	int supportTargetGlow = -1;
	int buddyTargetGlow = -1;
	bool doubleTarget;
	if (IsValidEntity(buddy) && IsValidEntity(support))
	{
		int buddyTarget = GetClientOfUserId(buddies[buddy].targetOverride);
		int supportTarget = GetClientOfUserId(Toss_SupportStats[support].targetOverride);
		buddyTargetGlow = EntRefToEntIndex(buddies[buddy].targetGlow);
		supportTargetGlow = EntRefToEntIndex(Toss_SupportStats[support].targetGlow);
		if (IsValidClient(buddyTarget) && IsValidClient(supportTarget) && buddyTarget == supportTarget)
		{
			if (IsValidEntity(buddyTargetGlow) && IsValidEntity(supportTargetGlow))
			{
				doubleTarget = true;
				static float nextGlowCycleTime[2049];
				static bool glowState[2049];
				if (GetTickedTime() >= nextGlowCycleTime[buddyTarget])
				{
					glowState[buddyTarget] = !glowState[buddyTarget];
					nextGlowCycleTime[buddyTarget] = GetTickedTime()+1.0;
				}
				
				// If both drones are targeting the same player, swap between the glow colors
				if (glowState[buddyTarget])
				{
					AcceptEntityInput(buddyTargetGlow, "Disable");
					AcceptEntityInput(supportTargetGlow, "Enable");
				}
				else
				{
					AcceptEntityInput(buddyTargetGlow, "Enable");
					AcceptEntityInput(supportTargetGlow, "Disable");
				}
			}
		}
	}
	
	// make sure glows are enabled if no double target
	if (!doubleTarget)
	{
		if (IsValidEntity(buddyTargetGlow))
			AcceptEntityInput(buddyTargetGlow, "Enable");
			
		if (IsValidEntity(supportTargetGlow))
			AcceptEntityInput(supportTargetGlow, "Enable");
	}
}

public void Support_Logic(int drone)
{
	PNPC support = view_as<PNPC>(drone);
	
	float selfPos[3];
	PNPC_WorldSpaceCenter(drone, selfPos);
	if (CF_IsEntityInSpawn(drone, (support.i_Team == TFTeam_Red ? TFTeam_Blue : TFTeam_Red)))
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
				Support_CheckPanic(support);
			}
			else
			{
				support.SetPlaybackRate(Toss_SupportStats[drone].CalculateBuildAnimSpeed());
			}
		}
	}
	else
	{
		Support_CheckEndPanic(support);

		int owner = GetClientOfUserId(Toss_SupportStats[drone].owner);
		int target = Toss_SupportStats[drone].GetTarget();

		float targPos[3];
		PNPC_WorldSpaceCenter(drone, selfPos);
		PNPC_WorldSpaceCenter(target, targPos);

		if (!Toss_SupportStats[drone].b_StayStill)
		{
			if (IsValidEntity(target))
				support.i_PathTarget = target;

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
		}
		else
		{
			support.StopPathing();
			support.f_Speed = 0.0;
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
					if (GetGameTime() >= f_NextAmmo[drone][i])
						Support_GiveAmmo(i, drone);

					CF_HealPlayer_WithAttributes(i, owner, (target == i ? targHeals : otherHeals), 1.0);
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
	if (CF_GetArgI(client, GADGETEER, abilityName, "has_toolbox", 0) <= 0)
		return;

	int toolbox = MakeToolbox(client, abilityName, true);
	if (IsValidEntity(toolbox))
	{
		Toss_IsSupportDrone[toolbox] = true;
		Toss_SupportStats[toolbox].CreateFromArgs(client, abilityName);
	}
}

int Command_User = -1;

public void Support_Command(int client, char abilityName[255])
{
	int supportDrone = EntRefToEntIndex(Toss_SupportDrone[client]);
	if (!IsValidEntity(supportDrone))
	{
		PrintCenterText(client, "You don't have an active Support Drone!");
		EmitSoundToClient(client, NOPE);
		return;
	}

	float ang[3];
	GetClientEyeAngles(client, ang);

	if (ang[0] <= -60.0)
	{
		EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
		EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);

		Toss_SupportStats[supportDrone].b_StayStill = false;
		if (Toss_SupportStats[supportDrone].targetOverride != GetClientUserId(client))
		{
			PrintCenterText(client, "Your Support Drone is now following you!");
			Toss_SupportStats[supportDrone].targetOverride = GetClientUserId(client);
		}
		else
		{
			PrintCenterText(client, "Your Support Drone is now using auto-targeting!");
			Toss_SupportStats[supportDrone].targetOverride = -1;
		}
	}
	else
	{
		float startPos[3], endPos[3];
		GetClientEyePosition(client, startPos);
		GetPointInDirection(startPos, ang, 99999.0, endPos);
		CF_HasLineOfSight(startPos, endPos, _, endPos);

		float mins[3];
		mins[0] = -5.0;
		mins[1] = mins[0];
		mins[2] = mins[0];
				
		float maxs[3];
		maxs[0] = -mins[0];
		maxs[1] = -mins[1];
		maxs[2] = -mins[2];
		
		CF_StartLagCompensation(client);
		Command_User = client;
		TR_TraceHullFilter(startPos, endPos, mins, maxs, MASK_SHOT, Command_OnlyPlayers, supportDrone);
		CF_EndLagCompensation(client);

		int target = TR_GetEntityIndex();
		bool wasStill = Toss_SupportStats[supportDrone].b_StayStill;
		Toss_SupportStats[supportDrone].b_StayStill = target == supportDrone && !wasStill;
		if (Toss_SupportStats[supportDrone].b_StayStill)
		{
			PrintCenterText(client, "Your Support Drone is now in Dispenser Mode!");
			float pos[3];
			view_as<PNPC>(supportDrone).GetAbsOrigin(pos);
			view_as<PNPC>(supportDrone).StopPathing();
			view_as<PNPC>(supportDrone).i_PathTarget = -1;
			Toss_SupportStats[supportDrone].targetOverride = -1;
			SpawnParticle(pos, PARTICLE_SUPPORT_COMMANDED, 2.0);
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
		}
		else if (wasStill && target == -1)
		{
			PrintCenterText(client, "Your Support Drone is now using auto-targeting!");
			Toss_SupportStats[supportDrone].targetOverride = -1;
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
		}
		else if (!IsValidMulti(target))
		{
			PrintCenterText(client, "Did not find a valid target!");
			EmitSoundToClient(client, NOPE);
		}
		else
		{
			Toss_SupportStats[supportDrone].targetOverride = GetClientUserId(target);
			int targetGlow = EntRefToEntIndex(Toss_SupportStats[supportDrone].targetGlow);
			if (targetGlow > 0 && IsValidEntity(targetGlow))
			{
				RemoveEntity(targetGlow);
			}
			
			targetGlow = EntIndexToEntRef(TF2_CreateGlow(target, 2));
			SetVariantColor({0, 255, 0, 255});
			AcceptEntityInput(targetGlow, "SetGlowColor");
			SetEntityTransmitState(targetGlow, FL_EDICT_FULLCHECK);
			SetEntityOwner(targetGlow, supportDrone);
			SDKHook(targetGlow, SDKHook_SetTransmit, DroneGlowSetTransmit);
			Toss_SupportStats[supportDrone].targetGlow = targetGlow;
			SetParent(supportDrone, targetGlow); // set parent so the glow dies when the drone does
			
			float pos[3];
			GetClientAbsOrigin(target, pos);
			SpawnParticle(pos, PARTICLE_SUPPORT_COMMANDED, 2.0);
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
			EmitSoundToClient(target, SOUND_SUPPORT_COMMANDED);
			EmitSoundToClient(target, SOUND_SUPPORT_COMMANDED);
			char charName[255];
			CF_GetCharacterName(target, charName, sizeof(charName));
			PrintCenterText(client, "Your Support Drone is now following %s (%N)", charName, target);
			PrintCenterText(target, "%N's Support Drone is now following you!", client);
		}
	}
	
	if (ang[0] <= -60.0 || Toss_SupportStats[supportDrone].b_StayStill 
		|| GetClientOfUserId(Toss_SupportStats[supportDrone].targetOverride) == 0)
	{
		int targetGlow = EntRefToEntIndex(Toss_SupportStats[supportDrone].targetGlow);
		if (targetGlow > 0 && IsValidEntity(targetGlow))
		{
			RemoveEntity(targetGlow);
		}
	}
}

public bool Command_OnlyPlayers(entity, contentsMask, int drone)
{
	return entity != Command_User && (entity == drone || (IsValidClient(entity) && CF_IsValidTarget(entity, TF2_GetClientTeam(Command_User)))); 
}

char s_AnnihilationAbility[MAXPLAYERS + 1][255];
float f_AnnihilationBuildWindow[MAXPLAYERS + 1] = { 0.0, ... };
float f_AnnihilationRefundAmt[MAXPLAYERS + 1] = { 0.0, ... };

void Gadgeteer_OnBuildingConstructed(Event event, const char[] name, bool dontBroadcast)
{
	int entity = event.GetInt("index");
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	TFObjectType type = TF2_GetObjectType(entity);
	if (owner == -1)
		return;

	if (GetGameTime() <= f_AnnihilationBuildWindow[owner])
	{
		Annihilation_Build(owner, s_AnnihilationAbility[owner], entity);
		CF_PlayRandomSound(owner, owner, "sound_annihilation_teleporter_built");
		CF_SilenceCharacter(owner, 0.2);
		Annihilation_DeleteTimer(owner);
		return;
	}

	if(type == TFObject_Dispenser && CF_HasAbility(owner, GADGETEER, SUPPORTDRONE))
	{
		if (CF_GetArgI(owner, GADGETEER, SUPPORTDRONE, "has_toolbox", 0) > 0)
			return;

		float cost = CF_GetArgF(owner, GADGETEER, SUPPORTDRONE, "cost", 400.0);
		if (CF_GetSpecialResource(owner) < cost)
		{
			EmitSoundToClient(owner, NOPE);
			PrintCenterText(owner, "A Support Drone costs %i Metal!", RoundFloat(cost));
			RemoveEntity(entity);
			CF_SilenceCharacter(owner, 0.2);
			return;
		}

		Toss_SupportStats[entity].CreateFromArgs(owner, SUPPORTDRONE);
		Toss_ToolboxOwner[entity] = GetClientUserId(owner);
		Toss_SpawnSupportDrone(entity, false, 0);
		CF_GiveSpecialResource(owner, -cost);
		CF_PlayRandomSound(owner, owner, "sound_support_drone_built");
		CF_SilenceCharacter(owner, 0.2);
	}
	else if (type == TFObject_Sentry && CF_HasAbility(owner, GADGETEER, BUDDY))
	{
		float cost = CF_GetArgF(owner, GADGETEER, BUDDY, "cost", 150.0);
		if (CF_GetSpecialResource(owner) < cost)
		{
			EmitSoundToClient(owner, NOPE);
			PrintCenterText(owner, "Little Buddy costs %i Metal!", RoundFloat(cost));
			RemoveEntity(entity);
			CF_SilenceCharacter(owner, 0.2);
			return;
		}

		Buddy_ReplaceSentry(entity, owner, BUDDY);

		CF_GiveSpecialResource(owner, -cost);
		CF_PlayRandomSound(owner, owner, "sound_little_buddy_built");
		CF_SilenceCharacter(owner, 0.2);
	}
}

public Action PNPC_OnPNPCTakeDamage(PNPC npc, float &damage, int weapon, int inflictor, int attacker, int &damagetype, int &damagecustom)
{
	Action ReturnValue = Plugin_Continue;

	if (Toss_IsSupportDrone[npc.Index] || Annihilation_IsTele[npc.Index] || b_IsBuddy[npc.Index])
	{
		//damagetype |= DMG_ALWAYSGIB;
		float force[3];
		Annihilation_GetUpwardForce(force, 600.0);
		npc.PunchForce(force, true);
		ReturnValue = Plugin_Changed;
		EmitSoundToAll(g_MetallicImpactSounds[GetRandomInt(0, sizeof(g_MetallicImpactSounds) - 1)], npc.Index, _, _, _, _, GetRandomInt(80, 110));
	}

	if (Toss_IsSupportDrone[npc.Index])
	{
		if (!Toss_SupportStats[npc.Index].isBuilding)
			RequestFrame(Support_CheckPanic, npc);

		int chosen = GetRandomInt(0, sizeof(Drone_DamageSFX) - 1);
		int pitch = GetRandomInt(90, 110);
		EmitSoundToAll(Drone_DamageSFX[chosen], npc.Index, _, _, _, _, pitch, -1);
		EmitSoundToAll(Drone_DamageSFX[chosen], npc.Index, _, _, _, _, pitch, -1);
		
		ReturnValue = Plugin_Changed;
	}

	if (b_IsBuddy[npc.Index] && GetGameTime() >= buddies[npc.Index].f_NextPainSound)
	{
		EmitSoundToAll(g_LittleBuddyPainSounds[GetRandomInt(0, sizeof(g_LittleBuddyPainSounds) - 1)], npc.Index, _, _, _, _, GetRandomInt(110, 120));
		buddies[npc.Index].f_NextPainSound = GetGameTime() + 0.2;
	}
	
	return ReturnValue;
}

public void Support_GiveAmmo(int target, int drone)
{
	bool AtLeastOne = false;
	for (int i = 0; i < 2; i++)
	{
		int weapon = GetPlayerWeaponSlot(target, i);
		if (!IsValidEntity(weapon))
			continue;

		//Attribute 421: no ammo from dispensers while active
		if (GetAttributeValue(weapon, 421, 0.0) != 0.0 && weapon == TF2_GetActiveWeapon(target))
			continue;

		int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1);
		int currentAmmo = GetAmmo(target, weapon);
		int maxAmmo = TF2Util_GetPlayerMaxAmmo(target, ammoType);
		if (currentAmmo < maxAmmo)
		{
			currentAmmo += RoundFloat(float(maxAmmo) * Toss_SupportStats[drone].f_AmmoAmt);
			if (currentAmmo > maxAmmo)
				currentAmmo = maxAmmo;

			SetAmmo(target, weapon, currentAmmo);
			AtLeastOne = true;
		}
	}

	if (AtLeastOne)
	{
		EmitSoundToClient(target, SOUND_SUPPORT_GIVE_AMMO);
		f_NextAmmo[drone][target] = GetGameTime() + Toss_SupportStats[drone].f_AmmoInterval;
	}
}

int i_SupportDroneDamagedParticle[2049] = { -1, ... };

public void Support_CheckEndPanic(PNPC npc)
{
	if (!Toss_SupportStats[npc.Index].isPanicked)
		return;

	int halfHP = RoundFloat(npc.i_MaxHealth * 0.5);
	if (npc.i_Health > halfHP)
	{
		npc.SetSequence("panic_end");
		Support_RemovePanicParticle(npc.Index);
		Toss_SupportStats[npc.Index].isPanicked = false;
		Support_SetSequenceAfterDelay(npc, 0.6, "idle", true);
	}
}

void Support_RemovePanicParticle(int ent)
{
	int particle = EntRefToEntIndex(i_SupportDroneDamagedParticle[ent]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
}

public void Support_CheckPanic(PNPC npc)
{
	if (!IsValidEntity(npc.Index) || Toss_SupportStats[npc.Index].isPanicked)
		return;

	int halfHP = RoundFloat(npc.i_MaxHealth * 0.5);
	if (npc.i_Health <= halfHP)
	{
		npc.SetSequence("panic_start_A");
		Toss_SupportStats[npc.Index].isPanicked = true;
		EmitSoundToAll(SOUND_SUPPORT_PANIC_BEGIN, npc.Index);
		Support_SetSequenceAfterDelay(npc, 0.8, "panic", false);
		i_SupportDroneDamagedParticle[npc.Index] = AttachParticleToEntity(npc.Index, PARTICLE_SUPPORT_DAMAGED, "");
	}
}

//TODO: Make this a PNPCS native, replace endPanic with a function parameter
public void Support_SetSequenceAfterDelay(PNPC npc, float delay, char sequence[255], bool endPanic)
{
	DataPack pack = new DataPack();
	RequestFrame(Support_DelayedSequence, pack);
	WritePackCell(pack, EntIndexToEntRef(npc.Index));
	WritePackFloat(pack, GetGameTime() + delay);
	WritePackString(pack, sequence);
	WritePackCell(pack, endPanic);
}

public void Support_DelayedSequence(DataPack pack)
{
	ResetPack(pack);
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	if (!PNPC_IsNPC(ent))
	{
		delete pack;
		return;
	}

	float time = ReadPackFloat(pack);
	char sequence[255];
	ReadPackString(pack, sequence, sizeof(sequence));
	bool endPanic = ReadPackCell(pack);

	if (GetGameTime() >= time)
	{
		PNPC npc = view_as<PNPC>(ent);

		if ((endPanic && !Toss_SupportStats[npc.Index].isPanicked) || (!endPanic && Toss_SupportStats[npc.Index].isPanicked))
			npc.SetSequence(sequence);

		delete pack;
		return;
	}

	RequestFrame(Support_DelayedSequence, pack);
}

public void PNPC_OnPNPCDestroyed(int entity)
{
	if (Toss_IsSupportDrone[entity])
	{
		float pos[3];
		PNPC_WorldSpaceCenter(entity, pos);
		SpawnParticle(pos, PARTICLE_TOSS_DESTROYED);
		EmitSoundToAll(SOUND_SUPPORT_DESTROYED, entity, _, 120);
		Support_RemovePanicParticle(entity);

		int owner = GetClientOfUserId(Toss_SupportStats[entity].owner);
		if (IsValidClient(owner))
		{
			if (noSupportDroneMessage[owner])
				noSupportDroneMessage[owner] = false;
			else
			{
				if (IsPlayerAlive(owner))
					CF_PlayRandomSound(owner, owner, "sound_support_drone_destroyed");

				PrintCenterText(owner, "Your Support Drone was destroyed!");
			}
		}
	}
	else if (Annihilation_IsTele[entity])
	{
		float pos[3];
		PNPC_WorldSpaceCenter(entity, pos);
		SpawnParticle(pos, PARTICLE_TOSS_DESTROYED);
		EmitSoundToAll(SOUND_TELE_DESTROYED, entity, _, 120, _, _, 80);
	}
	else if (b_IsBuddy[entity])
	{
		float pos[3];
		PNPC_WorldSpaceCenter(entity, pos);
		SpawnParticle(pos, PARTICLE_TOSS_DESTROYED);
		EmitSoundToAll(SOUND_SUPPORT_DESTROYED, entity, _, 120);
		EmitSoundToAll(g_LittleBuddyDeathSounds[GetRandomInt(0, sizeof(g_LittleBuddyDeathSounds) - 1)], entity, _, 120, _, _, GetRandomInt(110, 120));

		int owner = GetClientOfUserId(buddies[entity].owner);
		if (IsValidClient(owner))
		{
			if (noSupportDroneMessage[owner])
				noSupportDroneMessage[owner] = false;
			else
			{
				if (IsPlayerAlive(owner))
					CF_PlayRandomSound(owner, owner, "sound_little_buddy_destroyed");

				PrintCenterText(owner, "Your Little Buddy was destroyed!");
			}
		}
	}
}

public void PNPC_OnTouch(PNPC npc, int entity, char[] classname)
{
	if (!npc.b_IsABuilding || StrContains(classname, "tf_projectile") == -1)
		return;

	int launcher = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
	if (!IsValidEntity(launcher))
		return;

	int entityOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

	float healPerScrap = TF2CustAttr_GetFloat(launcher, "toolbox drone heal per scrap", 0.0);
	float healCost = TF2CustAttr_GetFloat(launcher, "toolbox drone heal cost", 0.0);
	float totalHealing = 60.0;
	
	if (healPerScrap > 0.0 && healCost > 0.0)
	{
		float resources = CF_GetSpecialResource(entityOwner);
		if (resources < healCost)
			return;
			
		if (healCost > resources)
			healCost = resources;
			
		float current = float(npc.i_Health); 
		float maxHP = float(npc.i_MaxHealth);
		
		totalHealing = healPerScrap * healCost;
		float afterHeals = current + totalHealing;
		if (afterHeals > maxHP)
		{
			totalHealing -= (afterHeals - maxHP);
		}
		
		npc.i_Health += RoundToFloor(totalHealing);
		
		float finalCost = totalHealing / healPerScrap;
		CF_GiveSpecialResource(entityOwner, -finalCost);
		CF_GiveUltCharge(entityOwner, totalHealing, CF_ResourceType_Healing);
	}
	else
		return;
		
	float pos[3];
	CF_WorldSpaceCenter(entity, pos);
	SpawnParticle(pos, npc.i_Team == TFTeam_Red ? PARTICLE_TOSS_HEAL_RED : PARTICLE_TOSS_HEAL_BLUE, 3.0);
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
}

public void Annihilation_Activate(int client, char abilityName[255])
{
	ForceEquipWeaponSlot(client, 3);
	float duration = CF_GetArgF(client, GADGETEER, abilityName, "build_window");
	f_AnnihilationBuildWindow[client] = GetGameTime() + duration;
	TF2_AddCondition(client, TFCond_FocusBuff, duration);
	TF2_AddCondition(client, TFCond_MegaHeal, duration);
	PrintCenterText(client, "BUILD SOMETHING, QUICK!");
	strcopy(s_AnnihilationAbility[client], 255, abilityName);
	DataPack pack = new DataPack();
	g_AnnihilationEndTimer[client] = CreateDataTimer(duration, Annihilation_MissedChance, pack);
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, client);
	f_AnnihilationRefundAmt[client] = CF_GetArgF(client, GADGETEER, abilityName, "refund_amt");
	EmitSoundToAll(SOUND_ANNIHILATION_BUILD_LOOP, client, _, _, _, _, 60);
	EmitSoundToAll(SOUND_ANNIHILATION_BUILD_LOOP_2, client, _, _, _, _, 90);
}

public Action Annihilation_MissedChance(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int slot = ReadPackCell(pack);
	delete g_AnnihilationEndTimer[slot] = null;

	if (IsValidMulti(client))
	{
		CF_PlayRandomSound(client, client, "sound_annihilation_out_of_time");
		Annihilation_GiveRefund(client);
		StopSound(client, SNDCHAN_AUTO, SOUND_ANNIHILATION_BUILD_LOOP);
		StopSound(client, SNDCHAN_AUTO, SOUND_ANNIHILATION_BUILD_LOOP_2);
		EmitSoundToAll(SOUND_ANNIHILATION_BUILD_END, client);
	}

	return Plugin_Continue;
}

public void Annihilation_DeleteTimer(int client)
{
	if (g_AnnihilationEndTimer[client] != null && g_AnnihilationEndTimer[client] != INVALID_HANDLE)
		delete g_AnnihilationEndTimer[client];
	StopSound(client, SNDCHAN_AUTO, SOUND_ANNIHILATION_BUILD_LOOP);
	StopSound(client, SNDCHAN_AUTO, SOUND_ANNIHILATION_BUILD_LOOP_2);
	EmitSoundToAll(SOUND_ANNIHILATION_BUILD_END, client);
}

public void Annihilation_GiveRefund(int client)
{
	CF_ApplyAbilityCooldown(client, 0.0, CF_AbilityType_Ult, true);
	CF_GiveUltCharge(client, f_AnnihilationRefundAmt[client], _, true);
	PrintCenterText(client, "Ult charge partially refunded.");
}

public void Annihilation_Build(int client, char abilityName[255], int building)
{
	float pos[3], ang[3];
	GetEntPropVector(building, Prop_Data, "m_vecAbsOrigin", pos);
	GetEntPropVector(building, Prop_Data, "m_angRotation", ang);
	RemoveEntity(building);
	f_AnnihilationBuildWindow[client] = 0.0;
	TF2_RemoveCondition(client, TFCond_FocusBuff);
	TF2_RemoveCondition(client, TFCond_MegaHeal);
	EmitSoundToAll(SOUND_ANNIHILATION_BUILD_END, client);

	Annihilation_DestroyTeleporter(client);

	char teleName[255];
	Format(teleName, sizeof(teleName), "Annihilation Teleporter (%N)", client);
	int team = view_as<int>(TF2_GetClientTeam(client));

	float maxHP = CF_GetArgF(client, GADGETEER, abilityName, "tele_hp", 3000.0);
	float buildTime = CF_GetArgF(client, GADGETEER, abilityName, "build_duration", 4.0);
	int tele = PNPC(MODEL_ANNIHILATION_BUILDING, view_as<TFTeam>(team), RoundFloat(maxHP), RoundFloat(maxHP), team - 2, 1.33, 0.0, Annihilation_TeleThink, GADGETEER, 0.0, pos, ang, _, _, teleName).Index;
	view_as<PNPC>(tele).SetSequence("build");
	view_as<PNPC>(tele).SetPlaybackRate(10.0 / buildTime);
	view_as<PNPC>(tele).f_Gravity = 9999.0;
	view_as<PNPC>(tele).SetBleedParticle("buildingdamage_sparks2");
	view_as<PNPC>(tele).AddGib(MODEL_TELE_GIB_1, "arm_attach_r");
	view_as<PNPC>(tele).AddGib(MODEL_TELE_GIB_2, "centre_attach");
	view_as<PNPC>(tele).AddGib(MODEL_TELE_GIB_3, "arm_attach_l");
	view_as<PNPC>(tele).AddGib(MODEL_TELE_GIB_4, "centre_attach2");
	view_as<PNPC>(tele).f_HealthBarHeight = 60.0;
	view_as<PNPC>(tele).b_IsABuilding = true;
	view_as<PNPC>(tele).b_GibsForced = true;
	view_as<PNPC>(tele).b_CanBeDisabled = false;
	float mins[3], maxs[3];
	mins[0] = -26.71;
	mins[1] = -26.71;
	mins[2] = -0.25;
	maxs[0] = 39.206;
	maxs[1] = 26.71;
	maxs[2] = 15.271;

	view_as<PNPC>(tele).SetBoundingBox(mins, maxs);

	TeleStats[tele].f_BuildEndTime = GetGameTime() + buildTime;
	TeleStats[tele].b_Built = false;
	TeleStats[tele].owner = GetClientUserId(client);
	TeleStats[tele].f_NextTeleBeam = 0.0;
	TeleStats[tele].f_NextBusterWave = 0.0;
	TeleStats[tele].f_NextBlastWarning = 0.0;
	TeleStats[tele].f_SDStartTime = GetGameTime() + CF_GetArgF(client, GADGETEER, abilityName, "tele_duration", 2.0) + buildTime;
	TeleStats[tele].f_SDDuration = CF_GetArgF(client, GADGETEER, abilityName, "tele_sdtime", 4.0);
	TeleStats[tele].f_SDBlastTime = TeleStats[tele].f_SDStartTime + TeleStats[tele].f_SDDuration;
	TeleStats[tele].f_SDRadius = CF_GetArgF(client, GADGETEER, abilityName, "tele_radius", 4.0);
	TeleStats[tele].f_SDDMG = CF_GetArgF(client, GADGETEER, abilityName, "tele_dmg", 800.0);
	TeleStats[tele].f_SDFalloffStart = CF_GetArgF(client, GADGETEER, abilityName, "tele_falloff_start", 300.0);
	TeleStats[tele].f_SDFalloffMax = CF_GetArgF(client, GADGETEER, abilityName, "tele_falloff_max", 0.5);

	TeleStats[tele].f_BusterHP = CF_GetArgF(client, GADGETEER, abilityName, "buster_hp", 150.0);
	TeleStats[tele].f_BusterSpeed = CF_GetArgF(client, GADGETEER, abilityName, "buster_speed", 380.0);
	TeleStats[tele].f_BusterDistance = CF_GetArgF(client, GADGETEER, abilityName, "buster_distance", 100.0);
	TeleStats[tele].f_BusterRadius = CF_GetArgF(client, GADGETEER, abilityName, "buster_radius", 200.0);
	TeleStats[tele].f_BusterSDDuration = CF_GetArgF(client, GADGETEER, abilityName, "buster_sdtime", 2.0);
	TeleStats[tele].f_BusterDMG = CF_GetArgF(client, GADGETEER, abilityName, "buster_dmg", 200.0);
	TeleStats[tele].f_BusterFalloffStart = CF_GetArgF(client, GADGETEER, abilityName, "buster_falloff_start", 80.0);
	TeleStats[tele].f_BusterFalloffMax = CF_GetArgF(client, GADGETEER, abilityName, "buster_falloff_max", 0.5);
	TeleStats[tele].f_BusterAutoDet = CF_GetArgF(client, GADGETEER, abilityName, "buster_auto_det", 6.0);

	TeleStats[tele].f_WaveInterval = CF_GetArgF(client, GADGETEER, abilityName, "waves_interval", 2.0);
	TeleStats[tele].i_WaveCount = CF_GetArgI(client, GADGETEER, abilityName, "waves_count", 3);

	Annihilation_IsTele[tele] = true;
	EmitSoundToAll(SOUND_TELE_BUILDING, tele, _, 120);
}

public void Annihilation_TeleThink(int tele)
{
	PNPC npc = view_as<PNPC>(tele);
	int client = Annihilation_GetOwner(tele);
	if (!IsValidClient(client) || CF_IsEntityInSpawn(tele, TFTeam_Red) || CF_IsEntityInSpawn(tele, TFTeam_Blue))
	{
		npc.Gib();
		return;
	}

	TFTeam team = TF2_GetClientTeam(client);

	int color[4];
	color[0] = 255;
	color[1] = 60;
	color[2] = 60;
	color[3] = 180;

	if (team == TFTeam_Blue)
	{
		color[0] = 60; color[2] = 255;
	}

	float gt = GetGameTime();
	if (!TeleStats[tele].b_Built)
	{
		if (gt >= TeleStats[tele].f_BuildEndTime)
		{
			npc.SetModel(MODEL_ANNIHILATION_TELEPORTER);
			npc.SetSequence("running");
			npc.SetPlaybackRate(1.0);

			AttachParticleToEntity(tele, (view_as<int>(team) == 2 ? PARTICLE_ANNIHILATION_TELE_RED_1 : PARTICLE_ANNIHILATION_TELE_BLU_1), "arm_attach_L", 0.0);
			AttachParticleToEntity(tele, (view_as<int>(team) == 2 ? PARTICLE_ANNIHILATION_TELE_RED_1 : PARTICLE_ANNIHILATION_TELE_BLU_1), "arm_attach_R", 0.0);
			AttachParticleToEntity(tele, (view_as<int>(team) == 2 ? PARTICLE_ANNIHILATION_TELE_RED_2 : PARTICLE_ANNIHILATION_TELE_BLU_2), "centre_attach2", 0.0, _, _, 3.33);

			EmitSoundToAll(SOUND_TELE_LOOP, tele, _, 110, _, _, 80);
			EmitSoundToAll(SOUND_TELE_SPAWNED, tele, _, 120, _, _, 90);
			StopSound(tele, SNDCHAN_AUTO, SOUND_TELE_BUILDING);

			float pos[3];
			npc.GetAbsOrigin(pos);
			SpawnParticle(pos, (view_as<int>(team) == 2 ? PARTICLE_TELE_SPAWNED_RED : PARTICLE_TELE_SPAWNED_BLUE), 2.0);

			TeleStats[tele].b_Built = true;
		}
		else
			return;
	}

	if (gt >= TeleStats[tele].f_NextTeleBeam)
	{
		float beamPos1[3], beamPos2[3];
		GetEntityAttachment(tele, LookupEntityAttachment(tele, "centre_attach"), beamPos1, beamPos2);
		beamPos2 = beamPos1;
		beamPos2[2] += 9999.0;

		TE_SetupBeamPoints(beamPos1, beamPos2, Laser_Model, Glow_Model, 0, 0, 0.1, 24.0, 24.0, 0, 12.0, color, 45);				
		TE_SendToAll();

		color[3] = 255;
		TE_SetupBeamPoints(beamPos1, beamPos2, Lightning_Model, Glow_Model, 0, 0, 0.1, 8.0, 8.0, 0, 24.0, color, 60);				
		TE_SendToAll();

		TeleStats[tele].f_NextTeleBeam = gt + 0.08;
	}
	
	if (gt >= TeleStats[tele].f_SDStartTime)
	{
		if (gt >= TeleStats[tele].f_SDBlastTime)
		{
			float pos[3];
			CF_WorldSpaceCenter(tele, pos);
			SpawnParticle(pos, PARTICLE_ANNIHILATION_TELE_BOOM, 2.0);
			pos[2] += 40.0;

			teleMegaFrag = true;
			CF_GenericAOEDamage(client, client, client, TeleStats[tele].f_SDDMG, DMG_BLAST|DMG_CLUB|DMG_ALWAYSGIB, TeleStats[tele].f_SDRadius, pos, TeleStats[tele].f_SDFalloffStart, TeleStats[tele].f_BusterFalloffMax, _, false);
			teleMegaFrag = false;
			SpawnShaker(pos, 14, 400, 4, 4, 4);

			float force[3];
			Annihilation_GetUpwardForce(force);
			npc.PunchForce(force, true);
			npc.Gib();
			return;
		}
		else
		{
			float rate = 1.0;
			float timeUntil = TeleStats[tele].f_SDBlastTime - gt;
			float percentageReady = 1.0 - (timeUntil / TeleStats[tele].f_SDDuration);
			rate = 1.5 * percentageReady;
			npc.SetPlaybackRate(rate);

			float pos[3], trash[3];
			GetEntityAttachment(tele, LookupEntityAttachment(tele, "centre_attach"), pos, trash);
			int alpha = 40 + RoundFloat(215.0 * percentageReady);
			spawnRing_Vector(pos, TeleStats[tele].f_SDRadius * 2.0, 0.0, 0.0, 0.0, Laser_Model, color[0], color[1], color[2], alpha, 1, 0.25, 8.0, 0.0, 16);

			if (gt >= TeleStats[tele].f_NextBlastWarning)
			{
				spawnRing_Vector(pos, TeleStats[tele].f_SDRadius * 2.0, 0.0, 0.0, 0.0, Laser_Model, color[0], color[1], color[2], alpha, 1, 0.25, 8.0, 0.0, 16, 1.0);

				int pitch = 60 + RoundFloat(80.0 * percentageReady);
				EmitSoundToAll(SOUND_TELE_SD_WARNING, tele, _, 120, _, _, pitch);

				TeleStats[tele].f_NextBlastWarning = gt + ((0.25 * TeleStats[tele].f_SDDuration) * (1.0 - percentageReady));
			}
		}
	}
	else if (gt >= TeleStats[tele].f_NextBusterWave)
	{
		float pos[3], ang[3];
		GetEntityAttachment(tele, LookupEntityAttachment(tele, "centre_attach"), pos, ang);
		SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_TELE_WAVE_1_RED : PARTICLE_TELE_WAVE_1_BLUE, 1.0);
		SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_TELE_WAVE_2_RED : PARTICLE_TELE_WAVE_2_BLUE, 1.0);

		int closest = CF_GetClosestTarget(pos, true, _, 90.0, grabEnemyTeam(client));
		if (IsValidMulti(closest, _, _, true, grabEnemyTeam(client)))
		{
			SpawnParticle(pos, PARTICLE_BUSTER_EXPLODE, 2.0);
			EmitSoundToAll(SOUND_BUSTER_EXPLODE, tele, _, 110, _, _, GetRandomInt(80, 120));

			pos[2] += 40.0;
			busting = true;
			CF_GenericAOEDamage(client, client, client, TeleStats[tele].f_BusterDMG * 2.0, DMG_BLAST|DMG_CLUB|DMG_ALWAYSGIB, TeleStats[tele].f_BusterRadius, pos, TeleStats[tele].f_BusterFalloffStart, TeleStats[tele].f_BusterFalloffMax, true, false);
			busting = false;
			SpawnShaker(pos, 12, 200, 4, 4, 4);

			pos[2] += 30.0;
			int text = WorldText_Create(pos, NULL_VECTOR, "Telefragged!", 22.5, _, _, _, 120, 255, 120, 255, true);
			if (IsValidEntity(text))	
				WorldText_MimicHitNumbers(text);
		}
		else
		{
			for (int i = 0; i < TeleStats[tele].i_WaveCount; i++)
			{
				float randAng[3], vel[3];
				randAng[1] = GetRandomFloat(0.0, 360.0);
				pos[2] += 20.0;

				char busterName[255];
				Format(busterName, sizeof(busterName), "Annihilation Buster (%N)", client);
				int teamNum = view_as<int>(TF2_GetClientTeam(client));

				int buster = PNPC(MODEL_ANNIHILATION_BUSTER, team, RoundFloat(TeleStats[tele].f_BusterHP), RoundFloat(TeleStats[tele].f_BusterHP), teamNum - 2, 0.66, TeleStats[tele].f_BusterSpeed, Annihilation_BusterThink, GADGETEER, 0.0, pos, randAng, _, _, busterName).Index;
				
				b_IsBuster[buster] = true;
				view_as<PNPC>(buster).b_GibsForced = true;
				view_as<PNPC>(buster).SetSequence("Run_MELEE");
				view_as<PNPC>(buster).SetPlaybackRate(1.0);
				view_as<PNPC>(buster).SetBleedParticle("buildingdamage_sparks2");

				//TODO: Change gibs
				view_as<PNPC>(buster).AddGib(MODEL_TELE_GIB_1, "arm_attach_r");
				view_as<PNPC>(buster).AddGib(MODEL_TELE_GIB_2, "centre_attach");
				view_as<PNPC>(buster).AddGib(MODEL_TELE_GIB_3, "arm_attach_l");
				view_as<PNPC>(buster).AddGib(MODEL_TELE_GIB_4, "centre_attach2");
				view_as<PNPC>(buster).f_HealthBarHeight = 60.0;
				view_as<PNPC>(buster).b_IsABuilding = true;
				view_as<PNPC>(buster).b_CanBeDisabled = false;

				EmitSoundToAll(SOUND_BUSTER_LOOP, buster, _, _, _, _, 110);
				AttachParticleToEntity(buster, team == TFTeam_Red ? PARTICLE_BUSTER_GLOW_RED : PARTICLE_BUSTER_GLOW_BLUE, "root", 4.0);

				TeleStats[buster].GetBusterStats(TeleStats[tele]);
				TeleStats[buster].owner = GetClientUserId(client);
				TeleStats[buster].b_AboutToBlowUp = false;
				TeleStats[buster].f_AutoDetTime = GetGameTime() + TeleStats[buster].f_BusterAutoDet;

				randAng[0] = GetRandomFloat(-70.0, -85.0);
				GetVelocityInDirection(randAng, 250.0, vel);
				view_as<PNPC>(buster).SetVelocity(vel);
			}
		}
			
		EmitSoundToAll(SOUND_TELE_WAVE, tele, _, 120, _, _, GetRandomInt(80, 100));
		TeleStats[tele].f_NextBusterWave = gt + TeleStats[tele].f_WaveInterval;
	}
}

public void Annihilation_BusterThink(int buster)
{
	PNPC npc = view_as<PNPC>(buster);
	int client = Annihilation_GetOwner(buster);
	if (!IsValidClient(client) || CF_IsEntityInSpawn(buster, TFTeam_Red) || CF_IsEntityInSpawn(buster, TFTeam_Blue))
	{
		float ang[3], vel[3];
		npc.GetAbsAngles(ang);
		GetVelocityInDirection(ang, npc.f_Speed, vel);
		npc.PunchForce(vel, true);
		npc.Gib();
		return;
	}

	//TFTeam team = TF2_GetClientTeam(client);
	float gt = GetGameTime();

	float pos[3];
	npc.GetAbsOrigin(pos);

	if (TeleStats[buster].b_AboutToBlowUp)
	{
		npc.StopPathing();
		float vel[3];
		npc.SetVelocity(vel);
		if (gt >= TeleStats[buster].f_SDBlastTime)
		{
			SpawnParticle(pos, PARTICLE_BUSTER_EXPLODE, 2.0);
			EmitSoundToAll(SOUND_BUSTER_EXPLODE, buster, _, 110, _, _, GetRandomInt(80, 120));

			pos[2] += 40.0;
			busting = true;
			CF_GenericAOEDamage(client, client, client, TeleStats[buster].f_BusterDMG, DMG_BLAST|DMG_CLUB|DMG_ALWAYSGIB, TeleStats[buster].f_BusterRadius, pos, TeleStats[buster].f_BusterFalloffStart, TeleStats[buster].f_BusterFalloffMax, true, false);
			busting = false;
			SpawnShaker(pos, 12, 200, 4, 4, 4);

			float force[3];
			Annihilation_GetUpwardForce(force);
			npc.PunchForce(force, true);
			npc.Gib();
		}
	}
	else
	{
		if (gt >= f_NextTargetTime[buster])
		{
			npc.i_PathTarget = CF_GetClosestTarget(pos, true, _, _, grabEnemyTeam(client), GADGETEER, Annihilation_NoTargetsInSpawn);
			if (!IsValidEntity(npc.i_PathTarget) || (IsValidClient(npc.i_PathTarget) && !IsPlayerAlive(npc.i_PathTarget)))
			{
				npc.StopPathing();
			}
			else
			{
				float theirPos[3];
				CF_WorldSpaceCenter(npc.i_PathTarget, theirPos);
				if (GetVectorDistance(pos, theirPos) <= TeleStats[buster].f_BusterDistance && GetEntityFlags(buster) & FL_ONGROUND != 0)
				{
					float rate = 2.0 / TeleStats[buster].f_BusterSDDuration;
					npc.SetPlaybackRate(rate);
					npc.SetCycle(0.0);
					npc.SetSequence("sentry_buster_preExplode");
					npc.SetPlaybackRate(rate);
					TeleStats[buster].b_AboutToBlowUp = true;
					TeleStats[buster].f_SDBlastTime = gt + TeleStats[buster].f_BusterSDDuration;
					npc.StopPathing();
					EmitSoundToAll(SOUND_BUSTER_WINDUP, buster, _, 110, _, _, 110);
				}
				else
					npc.StartPathing();
			}

			f_NextTargetTime[buster] = gt + 0.2;
		}
		else if (gt >= TeleStats[buster].f_AutoDetTime)
		{
			float rate = 2.0 / TeleStats[buster].f_BusterSDDuration;
			npc.SetPlaybackRate(rate);
			npc.SetCycle(0.0);
			npc.SetSequence("sentry_buster_preExplode");
			npc.SetPlaybackRate(rate);
			TeleStats[buster].b_AboutToBlowUp = true;
			TeleStats[buster].f_SDBlastTime = gt + TeleStats[buster].f_BusterSDDuration;
			npc.StopPathing();
			EmitSoundToAll(SOUND_BUSTER_WINDUP, buster, _, 110, _, _, 110);
		}
	}
}

public bool Annihilation_NoTargetsInSpawn(int ent)
{
	return !(CF_IsEntityInSpawn(ent, TFTeam_Red) || CF_IsEntityInSpawn(ent, TFTeam_Blue) || IsPayloadCart(ent));
}

void Annihilation_GetUpwardForce(float output[3], float force = 1200.0)
{
	float ang[3];
	ang[0] = GetRandomFloat(-80.0, -90.0);
	ang[1] = GetRandomFloat(0.0, 360.0);
	GetVelocityInDirection(ang, force, output);
}

int Annihilation_GetOwner(int entity) { return GetClientOfUserId(TeleStats[entity].owner); }

public bool Annihilation_HasTeleporter(int client, int &entity)
{
	for (int i = 0; i <= 2048; i++)
	{
		if (Annihilation_GetOwner(i) == client)
		{
			entity = i;
			return true;
		}
	}

	return false;
}

public void Annihilation_DestroyTeleporter(int client)
{
	int tele;
	if (Annihilation_HasTeleporter(client, tele))
	{
		view_as<PNPC>(tele).Gib();
	}
}

public void CF_OnHUDDisplayed(int client, char HUDText[255], int &r, int &g, int &b, int &a)
{
	int supportDrone = EntRefToEntIndex(Toss_SupportDrone[client]);
	if (IsValidEntity(supportDrone))
	{
		PNPC npc = view_as<PNPC>(supportDrone);
		float hp = float(npc.i_Health) / float(npc.i_MaxHealth);
		if (hp > 1.0)
			hp = 1.0;

		int pcnt = RoundToFloor(100.0 * hp);
		Format(HUDText, sizeof(HUDText), "Support Drone: %i[PERCENT] HP\n%s", pcnt, HUDText);
	}

	int buddy = EntRefToEntIndex(i_Buddy[client]);
	if (IsValidEntity(buddy))
	{
		PNPC npc = view_as<PNPC>(buddy);
		float hp = float(npc.i_Health) / float(npc.i_MaxHealth);
		if (hp > 1.0)
			hp = 1.0;

		int pcnt = RoundToFloor(100.0 * hp);

		if (IsValidEntity(supportDrone))
			Format(HUDText, sizeof(HUDText), "Little Buddy: %i[PERCENT] HP | %s", pcnt, HUDText);
		else
			Format(HUDText, sizeof(HUDText), "Little Buddy: %i[PERCENT] HP\n%s", pcnt, HUDText);
	}
}

bool Scrap_HSFalloff;

int Scrap_HSEffect;
int Scrap_User;

float Scrap_HealCost;
float Scrap_HealAmt;

public void Scrap_Activate(int client, char abilityName[255])
{
	float damage = CF_GetArgF(client, GADGETEER, abilityName, "damage");
	int numBullets = CF_GetArgI(client, GADGETEER, abilityName, "bullets");
	float hsMult = CF_GetArgF(client, GADGETEER, abilityName, "hs_mult");
	Scrap_HSEffect = CF_GetArgI(client, GADGETEER, abilityName, "hs_fx");
	Scrap_HSFalloff = CF_GetArgI(client, GADGETEER, abilityName, "hs_falloff") > 0;
	float falloffStart = CF_GetArgF(client, GADGETEER, abilityName, "falloff_start");
	float falloffEnd = CF_GetArgF(client, GADGETEER, abilityName, "falloff_end");
	float falloffMax = CF_GetArgF(client, GADGETEER, abilityName, "falloff_max");
	int pierce = CF_GetArgI(client, GADGETEER, abilityName, "pierce");
	float spread = CF_GetArgF(client, GADGETEER, abilityName, "spread");
	Scrap_HealCost = CF_GetArgF(client, GADGETEER, abilityName, "heal_cost");
	Scrap_HealAmt = CF_GetArgF(client, GADGETEER, abilityName, "heal_amt");

	float ang[3];
	GetClientEyeAngles(client, ang);

	Scrap_User = client;
	for (int i = 0; i < numBullets; i++)
		CF_FireGenericBullet(client, ang, damage, hsMult, spread, GADGETEER, Scrap_Hit, falloffStart, falloffEnd, falloffMax, pierce, TFTeam_Unassigned, GADGETEER, Scrap_CheckTarget, (TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_SCRAP_TRACER_RED : PARTICLE_SCRAP_TRACER_BLUE));
}

public void Scrap_Hit(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit, float hitPos[3])
{
	if (isHeadshot)
	{
		allowFalloff = Scrap_HSFalloff;
	}

	hsEffect = Scrap_HSEffect;

	//Because of our filter, if we hit an ally, that means we hit a building. Therefore: heal the building.
	if (CF_IsValidTarget(victim, TF2_GetClientTeam(attacker)))
	{
		baseDamage = 0.0;
		hsEffect = 0;
		allowFalloff = true;

		float healPerScrap = Scrap_HealAmt;
		float healCost = Scrap_HealCost;
		float totalHealing = 60.0;
		
		if (healPerScrap > 0.0 && healCost > 0.0)
		{
			float resources = CF_GetSpecialResource(attacker);
			if (resources < healCost)
				return;
				
			if (healCost > resources)
				healCost = resources;
				
			float current = float(view_as<PNPC>(victim).i_Health);
			float maxHP = float(view_as<PNPC>(victim).i_MaxHealth);
			bool isNPC = view_as<PNPC>(victim).b_Exists;
			if (!isNPC)
			{
				current = float(GetEntProp(victim, Prop_Data, "m_iHealth"));
				maxHP = float(TF2Util_GetEntityMaxHealth(victim));
			}

			if (current >= maxHP)
				return;
			
			totalHealing = healPerScrap * healCost;
			float afterHeals = current + totalHealing;
			if (afterHeals > maxHP)
			{
				totalHealing -= (afterHeals - maxHP);
			}
			
			if (isNPC)
				view_as<PNPC>(victim).i_Health += RoundToFloor(totalHealing);
			else
				SetEntProp(victim, Prop_Data, "m_iHealth", RoundToFloor(current) + RoundToFloor(totalHealing));

			float finalCost = totalHealing / healPerScrap;
			
			CF_GiveSpecialResource(attacker, -finalCost);

			if (!Toss_IsSupportDrone[victim] || !Toss_SupportStats[victim].isBuilding)
			{
				int owner = GetEntPropEnt(victim, Prop_Send, "m_hOwnerEntity");
				if (owner != attacker && Toss_IsSupportDrone[victim])
					owner = GetClientOfUserId(Toss_SupportStats[victim].owner);
				if (owner != attacker && b_IsBuddy[victim])
					owner = buddies[victim].GetOwner();

				if (owner != attacker)
					CF_GiveUltCharge(attacker, totalHealing, CF_ResourceType_Healing);
			}
		}
		else
			return;
			
		SpawnParticle(hitPos, TF2_GetClientTeam(attacker) == TFTeam_Red ? PARTICLE_TOSS_HEAL_RED : PARTICLE_TOSS_HEAL_BLUE, 3.0);
		EmitSoundToClient(attacker, SOUND_TOSS_HEAL);
			
		char amountHealed[16];
		Format(amountHealed, sizeof(amountHealed), "+%i", RoundToCeil(totalHealing));
		int text = WorldText_Create(hitPos, NULL_VECTOR, amountHealed, 15.0, _, _, _, 120, 255, 120, 255);
		if (IsValidEntity(text))
		{
			Text_Owner[text] = GetClientUserId(attacker);
			SDKHook(text, SDKHook_SetTransmit, Text_Transmit);
				
			WorldText_MimicHitNumbers(text);
		}
	}
}

public bool Scrap_CheckTarget(int target)
{
	return (CF_IsValidTarget(target, grabEnemyTeam(Scrap_User)) || IsABuilding(target));
}

public void Buddy_ReplaceSentry(int sentry, int owner, char abilityName[255])
{
	float pos[3], ang[3];
	GetEntPropVector(sentry, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(sentry, Prop_Send, "m_angRotation", ang);

	int chosen = GetRandomInt(0, sizeof(Toss_BuildSFX) - 1);
	EmitSoundToAll(Toss_BuildSFX[chosen], sentry, _, _, _, _, GetRandomInt(90, 110), -1);
	EmitSoundToAll(Toss_BuildSFX[chosen], sentry, _, _, _, _, GetRandomInt(90, 110), -1);
	EmitSoundToAll(SOUND_TOSS_BUILD_EXTRA, sentry, _, _, _, _, GetRandomInt(90, 110), -1);
	SpawnParticle(pos, PARTICLE_TOSS_BUILD_1, 2.0);
	SpawnParticle(pos, PARTICLE_TOSS_BUILD_2, 2.0);

	RemoveEntity(sentry);

	DataPack pack = new DataPack();
	WritePackCell(pack, GetClientUserId(owner));
	WritePackFloatArray(pack, pos, sizeof(pos));
	WritePackFloatArray(pack, ang, sizeof(ang));
	WritePackString(pack, abilityName);
	RequestFrame(Buddy_Spawn, pack);
}

public void Buddy_Spawn(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float pos[3], ang[3];
	ReadPackFloatArray(pack, pos, sizeof(pos));
	ReadPackFloatArray(pack, ang, sizeof(ang));
	char abilityName[255];
	ReadPackString(pack, abilityName, 255);
	delete pack;

	if (!IsValidClient(client))
		return;

	TFTeam team = TF2_GetClientTeam(client);
	
	int hp = CF_GetArgI(client, GADGETEER, abilityName, "health", 150);
	float speed = CF_GetArgF(client, GADGETEER, abilityName, "speed", 400.0);
	float bootTime = CF_GetArgF(client, GADGETEER, abilityName, "bootup_time", 4.0);

	char buddyName[255];
	Format(buddyName, sizeof(buddyName), "Little Buddy (%N)", client);

	PNPC buddy = PNPC(MODEL_BUDDY, team, hp, hp, _, 0.66, speed, Buddy_Think, GADGETEER, 0.1, pos, ang, _, _, buddyName);
	if (!IsValidEntity(buddy.Index))
		return;

	buddy.b_GibsForced = true;
	buddy.SetSequence((bootTime > 0.0 ? "PRIMARY_stun_middle" : "run_SECONDARY"));
	buddy.SetPlaybackRate(1.0);
	buddy.SetBleedParticle("buildingdamage_sparks2");
	
	buddies[buddy.Index].i_Pistol = EntIndexToEntRef(buddy.AttachModel(MODEL_BUDDY_PISTOL, "weapon_bone", _, 0, 0.66, _, true));

	for (int i = 0; i < sizeof(g_LittleBuddyGibs); i++)
		buddy.AddGib(g_LittleBuddyGibs[i]);

	buddy.f_HealthBarHeight = 60.0;
	buddy.b_IsABuilding = true;
	buddy.SetFlinchSequence("ACT_MP_GESTURE_FLINCH_CHEST");

	buddies[buddy.Index].f_NextTargetTime = 0.0;
	buddies[buddy.Index].owner = GetClientUserId(client);
	buddies[buddy.Index].me = buddy;
	buddies[buddy.Index].f_MaxSpeed = speed;
	buddies[buddy.Index].b_SentryMode = false;
	buddies[buddy.Index].b_BootupSequence = bootTime > 0.0;
	buddies[buddy.Index].f_BootupEndTime = GetGameTime() + bootTime;
	buddies[buddy.Index].f_Damage = CF_GetArgF(client, GADGETEER, abilityName, "damage", 10.0);
	buddies[buddy.Index].f_Rate = CF_GetArgF(client, GADGETEER, abilityName, "rate", 0.25);
	buddies[buddy.Index].f_Range = CF_GetArgF(client, GADGETEER, abilityName, "range", 400.0);
	buddies[buddy.Index].f_IdleDamage = CF_GetArgF(client, GADGETEER, abilityName, "damage_idle", 10.0);
	buddies[buddy.Index].f_IdleRate = CF_GetArgF(client, GADGETEER, abilityName, "rate_idle", 0.125);
	buddies[buddy.Index].f_IdleRange = CF_GetArgF(client, GADGETEER, abilityName, "range_idle", 600.0);
	
	buddies[buddy.Index].glow = EntIndexToEntRef(TF2_CreateGlow(buddy.Index, 2));
	SetVariantColor(view_as<int>({255, 255, 0, 255}));
	AcceptEntityInput(buddies[buddy.Index].glow, "SetGlowColor");
	SetEntityTransmitState(buddies[buddy.Index].glow, FL_EDICT_FULLCHECK);
	SetEntityOwner(buddies[buddy.Index].glow, buddy.Index);
	SetEntityOwner(buddy.Index, client);
	SDKHook(buddies[buddy.Index].glow, SDKHook_SetTransmit, DroneGlowSetTransmit);
	
	if (buddies[buddy.Index].b_BootupSequence)
	{
		AttachParticleToEntity(buddy.Index, team == TFTeam_Red ? PARTICLE_BUDDY_BOOTUP_RED : PARTICLE_BUDDY_BOOTUP_BLUE, "head", bootTime);

		for (int i = 0; i < 4; i++)
			EmitSoundToAll(SOUND_BUDDY_BOOTUP_LOOP, buddy.Index);
	}

	int oldDrone = EntRefToEntIndex(i_Buddy[client]);
	if (IsValidEntity(oldDrone))
	{
		noSupportDroneMessage[client] = true;
		view_as<PNPC>(oldDrone).Gib();
		noSupportDroneMessage[client] = false;
	}

	i_Buddy[client] = EntIndexToEntRef(buddy.Index);
	b_IsBuddy[buddy.Index] = true;
}

public void Buddy_Think(int buddy)
{
	PNPC npc = view_as<PNPC>(buddy);

	if (CF_IsEntityInSpawn(buddy, (npc.i_Team == TFTeam_Red ? TFTeam_Blue : TFTeam_Red)))
	{
		float force[3];
		Annihilation_GetUpwardForce(force, 600.0);
		npc.PunchForce(force, true);
		npc.Gib();
		return;
	}

	float pos[3];
	npc.GetAbsOrigin(pos);
	float gt = GetGameTime();

	if (buddies[buddy].b_BootupSequence)
	{
		if (gt >= buddies[buddy].f_BootupEndTime)
		{
			buddies[buddy].b_BootupSequence = false;
			npc.SetSequence("run_SECONDARY");
			npc.AddGesture("ACT_MP_STUN_END");
			EmitSoundToAll(g_LittleBuddyActivatedSounds[GetRandomInt(0, sizeof(g_LittleBuddyActivatedSounds) - 1)], buddy, _, _, _, _, GetRandomInt(110, 120));
			EmitSoundToAll(g_LittleBuddyActivatedSounds[GetRandomInt(0, sizeof(g_LittleBuddyActivatedSounds) - 1)], buddy, _, _, _, _, GetRandomInt(110, 120));

			EmitSoundToAll(SOUND_BUDDY_ACTIVATE, buddy);
			buddies[buddy].PlayScanSound();

			for (int i = 0; i < 4; i++)
				StopSound(buddy, SNDCHAN_AUTO, SOUND_BUDDY_BOOTUP_LOOP);

			SpawnParticle(pos, npc.i_Team == TFTeam_Red ? PARTICLE_BUDDY_ACTIVATED_RED : PARTICLE_BUDDY_ACTIVATED_BLUE, 0.5);
		}

		return;
	}

	if (!buddies[buddy].b_SentryMode)
	{
		buddies[buddy].FindTarget(pos);

		int targ = buddies[buddy].GetTarget();
		if (targ)
		{
			float theirPos[3];
			GetClientAbsOrigin(targ, theirPos);

			if (GetVectorDistance(pos, theirPos) <= 250.0)
			{
				float vel[3];
				GetEntPropVector(targ, Prop_Data, "m_vecAbsVelocity", vel);

				float speed = GetVectorLength(vel);
				if (speed > buddies[buddy].f_MaxSpeed)
					speed = buddies[buddy].f_MaxSpeed;

				if (speed < 150.0)
					speed = 0.0;

				npc.f_Speed = LerpCurve(npc.f_Speed, speed, 70.0, 70.0);
				if (npc.f_Speed <= 0.0)
					npc.f_YawRate = 0.0;
				else
					npc.f_YawRate = 300.0;
			}
			else
				npc.f_Speed = buddies[buddy].f_MaxSpeed;
		}
	}
	else
	{
		npc.StopPathing();
		npc.f_Speed = 0.0;
	}

	if (buddies[buddy].FindEnemy(pos) && gt >= buddies[buddy].f_NextShot)
	{
		buddies[buddy].Shoot();
	}

	if (gt >= buddies[buddy].f_NextScanSound && !buddies[buddy].b_HasEnemyTarget)
		buddies[buddy].PlayScanSound();
}

public void Buddy_Command(int client, char abilityName[255])
{
	int buddy = EntRefToEntIndex(i_Buddy[client]);
	if (!IsValidEntity(buddy))
	{
		PrintCenterText(client, "You don't have an active Little Buddy!");
		EmitSoundToClient(client, NOPE);
		return;
	}

	float ang[3];
	GetClientEyeAngles(client, ang);
	
	if (ang[0] <= -60.0)
	{
		buddies[buddy].b_SentryMode = false;

		EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
		EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
		EmitSoundToAll(g_LittleBuddyCommandedSounds[GetRandomInt(0, sizeof(g_LittleBuddyCommandedSounds) - 1)], buddy, _, _, _, _, GetRandomInt(110, 120));

		if (buddies[buddy].targetOverride != GetClientUserId(client))
		{
			PrintCenterText(client, "Your Little Buddy is now protecting you!");
			buddies[buddy].targetOverride = GetClientUserId(client);
		}
		else
		{
			PrintCenterText(client, "Your Little Buddy is now using auto-targeting!");
			buddies[buddy].targetOverride = -1;
		}
	}
	else
	{
		float startPos[3], endPos[3];
		GetClientEyePosition(client, startPos);
		GetPointInDirection(startPos, ang, 99999.0, endPos);
		CF_HasLineOfSight(startPos, endPos, _, endPos);

		float mins[3];
		mins[0] = -5.0;
		mins[1] = mins[0];
		mins[2] = mins[0];
				
		float maxs[3];
		maxs[0] = -mins[0];
		maxs[1] = -mins[1];
		maxs[2] = -mins[2];

		CF_StartLagCompensation(client);
		Command_User = client;
		TR_TraceHullFilter(startPos, endPos, mins, maxs, MASK_SHOT, Command_OnlyPlayers, buddy);
		CF_EndLagCompensation(client);

		int target = TR_GetEntityIndex();
		bool wasSentry = buddies[buddy].b_SentryMode;
		buddies[buddy].b_SentryMode = target == buddy && !wasSentry;
		if (buddies[buddy].b_SentryMode)
		{
			PrintCenterText(client, "Little Buddy is now in Sentry Mode!");
			float pos[3];
			view_as<PNPC>(buddy).GetAbsOrigin(pos);
			view_as<PNPC>(buddy).StopPathing();
			buddies[buddy].ClearTarget();
			SpawnParticle(pos, PARTICLE_SUPPORT_COMMANDED, 2.0);
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
			EmitSoundToAll(g_LittleBuddyCommandedSounds[GetRandomInt(0, sizeof(g_LittleBuddyCommandedSounds) - 1)], buddy, _, _, _, _, GetRandomInt(110, 120));
		}
		else if (wasSentry && !IsValidMulti(target))
		{
			PrintCenterText(client, "Your Little Buddy is now using auto-targeting!");
			buddies[buddy].targetOverride = -1;
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
			EmitSoundToAll(g_LittleBuddyCommandedSounds[GetRandomInt(0, sizeof(g_LittleBuddyCommandedSounds) - 1)], buddy, _, _, _, _, GetRandomInt(110, 120));
		}
		else if (!IsValidMulti(target))
		{
			PrintCenterText(client, "Did not find a valid target!");
			EmitSoundToClient(client, NOPE);
		}
		else
		{
			buddies[buddy].targetOverride = GetClientUserId(target);
			int targetGlow = EntRefToEntIndex(buddies[buddy].targetGlow);
			if (targetGlow > 0 && IsValidEntity(targetGlow))
			{
				RemoveEntity(targetGlow);
			}
			
			targetGlow = EntIndexToEntRef(TF2_CreateGlow(target, 2));
			SetVariantColor({255, 255, 0, 255});
			AcceptEntityInput(targetGlow, "SetGlowColor");
			SetEntityOwner(targetGlow, buddy);
			SDKHook(targetGlow, SDKHook_SetTransmit, DroneGlowSetTransmit);
			SetEntityTransmitState(targetGlow, FL_EDICT_FULLCHECK);
			buddies[buddy].targetGlow = targetGlow;
			SetParent(buddy, targetGlow); // set parent so the glow dies when the drone does
			
			float pos[3];
			GetClientAbsOrigin(target, pos);
			SpawnParticle(pos, PARTICLE_SUPPORT_COMMANDED, 2.0);
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
			EmitSoundToClient(client, SOUND_SUPPORT_COMMANDED);
			EmitSoundToClient(target, SOUND_SUPPORT_COMMANDED);
			EmitSoundToClient(target, SOUND_SUPPORT_COMMANDED);
			EmitSoundToAll(g_LittleBuddyCommandedSounds[GetRandomInt(0, sizeof(g_LittleBuddyCommandedSounds) - 1)], buddy, _, _, _, _, GetRandomInt(110, 120));
			char charName[255];
			CF_GetCharacterName(target, charName, sizeof(charName));
			PrintCenterText(client, "Your Little Buddy is now protecting %s (%N)", charName, target);
			PrintCenterText(target, "%N's Little Buddy is now protecting you!", client);
		}
	}
	
	if (ang[0] <= -60.0 || buddies[buddy].b_SentryMode || GetClientOfUserId(buddies[buddy].targetOverride) == 0)
	{
		int targetGlow = EntRefToEntIndex(buddies[buddy].targetGlow);
		if (targetGlow > 0 && IsValidEntity(targetGlow))
		{
			RemoveEntity(targetGlow);
		}
	}
}

public bool Buddy_CheckLOS(int ent)
{
	if (IsPlayerInvis(ent))
		return false;

	float pos1[3], pos2[3];
	CF_WorldSpaceCenter(currentBuddy, pos1);
	CF_WorldSpaceCenter(ent, pos2);
	return CF_HasLineOfSight(pos1, pos2, _, _, currentBuddy);
}

public bool PNPC_OnCheckMedigunCanAttach(PNPC npc, int client, int medigun)
{
	if (b_IsBuddy[npc.Index] || Annihilation_IsTele[npc.Index] || Toss_IsSupportDrone[npc.Index] || b_IsBuster[npc.Index])
		return false;

	return true;
}