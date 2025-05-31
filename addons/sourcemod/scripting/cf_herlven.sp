#pragma semicolon 1
#pragma newdecls required

int BEAM_Laser;
int BEAM_Glow;

int BEAM_Combine_Black;
int BEAM_Combine_Blue;
int BEAM_Combine_Red;

int Glow_Sprite_Red;
int Glow_Sprite_Blue;

#define PARTICLE_SHOTGUN_TRACER_RED		"bullet_scattergun_tracer01_red"
#define PARTICLE_SHOTGUN_TRACER_BLUE		"bullet_scattergun_tracer01_blue"

#define TELE_EXIT_LOOP_SOUND	"mvm/mvm_mothership_loop.wav"
#define TELE_EXIT_TELE_SOUND	"mvm/mvm_robo_stun.wav"
#define NOPE					"replay/record_fail.wav"

float Buckshot_MinMetal = 150.0;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("PNPC_IsNPC");
	MarkNativeAsOptional("PNPC.f_Speed.get");
	MarkNativeAsOptional("PNPC.b_IsABuilding.get");
	return APLRes_Success;
}

/*
	Laser .vmt's that work (but mainly look good):

	"materials/sprites/laser.vmt"
	"materials/sprites/physbeam.vmt"
	"materials/sprites/plasma.vmt"
	"materials/sprites/plasma1.vmt"		//weird one.
	"materials/sprites/fireburst.vmt"	//aacts like the one above in its weirdness
	"materials/sprites/plasmabeam.vmt"	//A PURE BEAM OF SOLID PLAZMA!
	"materials/sprites/purplelaser1.vmt"	//a laser that has a base colour of purple. seems to work best with low width
	"materials/sprites/spotlight.vmt"		//A REALLY FAT BEAM OF LIGHT.
	"materials/sprites/white.vmt"			//a really fat beam of light, like the one above

	"materials/sprites/combineball_trail_black_1.vmt"	//This one has potential for a pure black laser!

	"materials/sprites/lgtning.vmt"
	"materials/sprites/lgtning_noz.vmt"

	//the most unique ones so far
	"materials/sprites/hydragutbeam.vmt"
	"materials/sprites/hydragutbeamcap.vmt"
	"materials/sprites/hydraspinalcord.vmt"

	

	//Beams that are like balls, not a constant beam. basically like balls.
	"sprites/glow02.vmt"
	"materials/sprites/combineball_glow_black_1.vmt"
	"materials/sprites/wxplo1.vmt"
	"materials/sprites/bubble.vmt"
	
	"materials/sprites/laserdot.vmt"
	"materials/sprites/light_glow01.vmt"
	"materials/sprites/light_glow02.vmt"	//seems to have bigger gaps then the 01 version.
	"materials/sprites/light_glow02_noz.vmt"
	"materials/sprites/light_glow03.vmt"	//Even larger gaps.
	
	"materials/sprites/orangecore1.vmt"
	"materials/sprites/orangecore2.vmt"	//smaller then 1
	"materials/sprites/orangeflare1.vmt"

	"materials/sprites/physcannon_bluecore1.vmt"
	"materials/sprites/physcannon_bluecore1b.vmt"
	"materials/sprites/physcannon_bluecore2.vmt"
	"materials/sprites/physcannon_bluecore2b.vmt"

	"materials/sprites/physring1.vmt"	//kinda looks like a diamond.

	"materials/sprites/plasmaember.vmt"

	
	//Halo's
	"materials/sprites/halo01.vmt"	
	"materials/sprites/plasmahalo.vmt"	//note: this works well with just a normal laser, not just as a halo!



	"materials/sprites/obsolete.vmt"	//this one is just fucking funny.
*/
#define Zero(%1)		ResetToZero(%1, sizeof(%1))
#define Zero2(%1)	ResetToZero2(%1, sizeof(%1), sizeof(%1[]))

stock void ResetToZero(any[] array, int length)
{
	for(int i; i<length; i++)
	{
		array[i] = 0;
	}
}
stock void ResetToZero2(any[][] array, int length1, int length2)
{
	for(int a; a<length1; a++)
	{
		for(int b; b<length2; b++)
		{
			array[a][b] = 0;
		}
	}
}

#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define MAXTF2PLAYERS			36
#define MAXENTITIES				2048

//replace with actual grenade models. the iron bomber ones
#define BEACON_BASE_MODEL	"models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl"

#define JUMPPAD_IMPACT1					"Passtime.BallSmack"
#define JUMPPAD_IMPACT2					"TFPlayer.AirBlastImpact"

#define THIS_PLUGIN_NAME		"cf_herlven"

#define ORBITAL_DEATH_RAY		"herlven_orbital_deathray"
#define SUPER_SHOTGUN			"herlven_super_shotgun"
#define CUSTOM_TELEPORTERS		"herlven_teleporters"
#define METAL_PISTOL			"herlven_metal_pistol"

#define DEATHRAY_TOUCHDOWN_SOUND	"weapons/physcannon/energy_sing_explosion2.wav"
#define DEATHRAY_THROW_SOUND		"misc/hologram_start.wav"
#define DEATHRAY_PASSIVE_SOUND		"ambient/energy/weld1.wav"
#define DEATHRAY_END_SOUND			"misc/hologram_stop.wav"

static int Generic_Laser_BEAM_HitDetected[MAXENTITIES];
static int i_beacon_owner[MAXENTITIES];
static float fl_jumppad_falldamge_invlun[MAXTF2PLAYERS];
static bool TPInitiated[MAXTF2PLAYERS];

static const char DeathRayPassiveSounds[][] =
{
	"weapons/physcannon/superphys_small_zap1.wav",
	"weapons/physcannon/superphys_small_zap2.wav",
	"weapons/physcannon/superphys_small_zap3.wav",
	"weapons/physcannon/superphys_small_zap4.wav"
};
static const char WidowCritSound[][] =
{
	"weapons/widow_maker_shot_crit_01.wav",
	"weapons/widow_maker_shot_crit_02.wav",
	"weapons/widow_maker_shot_crit_03.wav"
};

//Precache all of your plugin-specific sounds and models here.
public void OnMapStart()
{
	PrecacheModel(BEACON_BASE_MODEL, true);
	PrecacheSound(TELE_EXIT_LOOP_SOUND, true);
	PrecacheSound(TELE_EXIT_TELE_SOUND, true);
	PrecacheSound(NOPE);

	Zero(TPInitiated);

	for(int i; i < sizeof(DeathRayPassiveSounds); i++)
	{
		PrecacheSound(DeathRayPassiveSounds[i]);
	}
	for(int i; i < sizeof(WidowCritSound); i++)
	{
		PrecacheSound(WidowCritSound[i]);
	}

	BEAM_Laser 			= PrecacheModel("materials/sprites/laser.vmt", true);

	BEAM_Combine_Black 	= PrecacheModel("materials/sprites/combineball_trail_black_1.vmt", true);
	BEAM_Combine_Blue	= PrecacheModel("materials/sprites/combineball_trail_blue_1.vmt", true);
	BEAM_Combine_Red	= PrecacheModel("materials/sprites/combineball_trail_red_1.vmt", true);

	BEAM_Glow 			= PrecacheModel("sprites/glow02.vmt", true);

	Glow_Sprite_Blue = PrecacheModel("sprites/blueglow2.vmt", true);
	Glow_Sprite_Red = PrecacheModel("sprites/redglow2.vmt", true);

	PrecacheScriptSound(JUMPPAD_IMPACT1);
	PrecacheScriptSound(JUMPPAD_IMPACT2);
	Zero(Generic_Laser_BEAM_HitDetected);
	Zero(fl_jumppad_falldamge_invlun);

	PrecacheSound(DEATHRAY_TOUCHDOWN_SOUND, true);
	PrecacheSound(DEATHRAY_THROW_SOUND, true);
	PrecacheSound(DEATHRAY_PASSIVE_SOUND, true);
	PrecacheSound(DEATHRAY_END_SOUND, true);

	PrecacheSound("beams/beamstart5.wav", true);
}

//Hook your events in here.
public void OnPluginStart()
{
	HookEvent("player_builtobject", OnBuildObject);
}

//This forward is called when an ability is activated. It is best used to check if the ability being activated is
//one of our plugin's abilities, so that our plugin can read that ability's variables and act as such.
public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	//The activated ability's plugin is not this plugin, don't do anything.
	if (!StrEqual(pluginName, THIS_PLUGIN_NAME))
		return;
	
	//The activated ability belongs to our plugin, check to see which ability it is.	
	if (StrContains(abilityName, ORBITAL_DEATH_RAY) != -1)
	{
		Orbital_Death_Ray_Activate(client);
	}
	//The activated ability belongs to our plugin, check to see which ability it is.	
	if (StrContains(abilityName, SUPER_SHOTGUN) != -1)
	{
		SuperShotgun_Activate(client, abilityName);
	}
}

//This is a custom ability activation method, used by this plugin. In a real character plugin, this is where you would
//read the ability's variables via the "CF_GetArg" natives and apply its special effects. For example, if our ability
//shoots a rocket with customizable damage, this is where we would read the ability's args from the config to get the
//rocket's damage and then shoot it.
static bool b_DeathRay_Active[MAXTF2PLAYERS];
enum struct DeathRay_Data
{
	float Duration;
	float Timer;

	float Speed;
	float Damage;
	float Radius;

	float Throttle;

	float Location[3];		//the location the beam is at.

	float Anchor_Loc[3];	//the sky location its anchored to.

	float BeamDist;
}
static DeathRay_Data struct_DeathRayData[MAXTF2PLAYERS];
void Orbital_Death_Ray_Activate(int client)
{
	b_DeathRay_Active[client] = true;
	struct_DeathRayData[client].Damage = CF_GetArgF(client, THIS_PLUGIN_NAME, ORBITAL_DEATH_RAY, "Damage");	// 10.0;
	struct_DeathRayData[client].Radius = CF_GetArgF(client, THIS_PLUGIN_NAME, ORBITAL_DEATH_RAY, "Radius");// 25.0;
	struct_DeathRayData[client].Speed =  CF_GetArgF(client, THIS_PLUGIN_NAME, ORBITAL_DEATH_RAY, "Speed");//10.0;
	struct_DeathRayData[client].Duration =CF_GetArgF(client, THIS_PLUGIN_NAME, ORBITAL_DEATH_RAY, "Duration");//10.0;

	float Throw_Velocity = CF_GetArgF(client, THIS_PLUGIN_NAME, ORBITAL_DEATH_RAY, "Throw Velocity");// 1000.0;
	int Ball = Beacon_CreateProp(client, Throw_Velocity);

	i_beacon_owner[Ball] = EntIndexToEntRef(client);
	RequestFrame(Beacon_CheckForCollision, EntIndexToEntRef(Ball));
	//this breaks PDA. me sad :(
	//CF_SimulateSpellbookCast(client, _, CF_Spell_Fireball);

	EmitSoundToAll(DEATHRAY_THROW_SOUND, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);

	CreateTimer(10.0, BeaconFailSafe, EntIndexToEntRef(Ball), TIMER_FLAG_NO_MAPCHANGE);

}
static Action BeaconFailSafe(Handle timer, int ref)
{
	int beacon = EntRefToEntIndex(ref);
	if(!IsValidEntity(beacon))
		return Plugin_Stop;

	int client = EntRefToEntIndex(i_beacon_owner[beacon]);
	
	if(!IsValidClient(client))
		return Plugin_Stop;

	i_beacon_owner[beacon] = INVALID_ENT_REFERENCE;

	float Initiate_In = CF_GetArgF(client, THIS_PLUGIN_NAME, ORBITAL_DEATH_RAY, "WindUp"); //3.0;
	if(Initiate_In<= 0.5)
		Initiate_In = 0.5;

	float pos[3]; GetAbsOrigin_main(beacon, pos);
	float Sky_Loc[3];
	Sky_Loc = GetDeathRayAnchorLocation(client, pos);
	TE_SetupBeamPoints(pos, Sky_Loc, BEAM_Laser, BEAM_Glow, 0, 0, Initiate_In, 15.0, 15.0, 0, 1.0, GetColor(client), 3);				
	TE_SendToAll();

	DataPack pack2 = new DataPack();
	CreateDataTimer(Initiate_In, OffSetDeathRay_Spawn, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, EntIndexToEntRef(client));
	WritePackCell(pack2, EntIndexToEntRef(beacon));

	TeleportEntity(beacon, NULL_VECTOR, NULL_VECTOR, {0.0, 0.0,0.0});
	SetEntityMoveType(beacon, MOVETYPE_NONE);

	return Plugin_Handled;
}
//get a sky location
static float[] GetDeathRayAnchorLocation(int client, float Origin[3])
{
	Generic_Laser_Trace Laser;
	Laser.client = client;
	float Angles[3];
	Angles = {-90.0, 0.0, 0.0};
	Laser.DoForwardTrace_Custom(Angles, Origin);

	for(int i=0 ; i < 5 ; i++)
	{
		float Dist = GetVectorDistance(Laser.End_Point, Laser.Start_Point);
		//absurdly small distance, try again
		if(Dist < 100.0)
		{
			Origin[2] = Laser.End_Point[2] + 50.0;	//try again
			Laser.DoForwardTrace_Custom(Angles, Origin, 2500.0);	//with a range limit just incase.
		}
		else	//we have found a valid position, abort.
			break;
	}

	Laser.End_Point[2]-=25.0;

	return Laser.End_Point;
}
static Action OffSetDeathRay_Spawn(Handle Timer, DataPack pack)
{
	ResetPack(pack);
	int client = EntRefToEntIndex(ReadPackCell(pack));
	int Ball = EntRefToEntIndex(ReadPackCell(pack));

	if(!IsValidClient(client))
	{
		if(IsValidEntity(Ball))
			RemoveEntity(Ball);

		return Plugin_Stop;
	}
	if(CF_GetRoundState() != 1)
	{
		b_DeathRay_Active[client] = false;
		if(IsValidEntity(Ball))
			RemoveEntity(Ball);

		return Plugin_Stop;
	}
	float Spawn_Loc[3];
	if(IsValidEntity(Ball))
	{
		GetEntPropVector(Ball, Prop_Data, "m_vecAbsOrigin", Spawn_Loc);
	}
	else
	{
		GetClientEyePosition(client, Spawn_Loc);
	}
	Invoke_DeathRay(client, Spawn_Loc);
	if(IsValidEntity(Ball))
		RemoveEntity(Ball);

	return Plugin_Handled;
}

static void Invoke_DeathRay(int client, float Loc[3])
{
	struct_DeathRayData[client].Throttle = 0.0;
	struct_DeathRayData[client].Timer = GetGameTime() + struct_DeathRayData[client].Duration;
	struct_DeathRayData[client].Location = Loc;

	struct_DeathRayData[client].Anchor_Loc = GetDeathRayAnchorLocation(client, Loc);
	
	EmitSoundToAll(DEATHRAY_TOUCHDOWN_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, Loc);

	int color[4]; color = GetColor(client);
	float TE_Duration = struct_DeathRayData[client].Duration;
	float diameter = ClampBeamWidth(struct_DeathRayData[client].Radius*2.0);

	float True_Sky[3]; True_Sky = struct_DeathRayData[client].Anchor_Loc; True_Sky[2]+=2500.0;
									
	TE_SetupBeamPoints(struct_DeathRayData[client].Anchor_Loc, True_Sky, BEAM_Laser, BEAM_Glow, 0, 0, TE_Duration, diameter, diameter, 0, 1.0, color, 3);				
	TE_SendToAll();

	TE_SetupBeamPoints(struct_DeathRayData[client].Anchor_Loc, True_Sky, BEAM_Combine_Black, 0, 0, 0, TE_Duration, 0.7*diameter, 0.7*diameter, 0, 2.5, color, 3);				
	TE_SendToAll();

	int Laser_Core = (TF2_GetClientTeam(client) == TFTeam_Blue ? BEAM_Combine_Blue : BEAM_Combine_Red);
	TE_SetupBeamPoints(struct_DeathRayData[client].Anchor_Loc, True_Sky, Laser_Core, Laser_Core, 0, 0, TE_Duration, diameter, diameter, 0, 1.5, color, 3);				
	TE_SendToAll();
	
	TE_SetupBeamRingPoint(struct_DeathRayData[client].Anchor_Loc, 300.0, 300.1, Laser_Core, BEAM_Glow, 0, 1, TE_Duration, 20.0, 0.1, color, 1, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(struct_DeathRayData[client].Anchor_Loc, 300.0, 0.0, Laser_Core, BEAM_Glow, 0, 1, TE_Duration, 15.0, 0.1, color, 1, 0);
	TE_SendToAll();

	ParticleEffectAt(Loc, GetClientTeam(client) == 2 ? "powerup_supernova_explode_red" : "powerup_supernova_explode_blue", 1.0);
	ParticleEffectAt(struct_DeathRayData[client].Anchor_Loc, GetClientTeam(client) == 2 ? "powerup_supernova_explode_red" : "powerup_supernova_explode_blue", 1.0);

	if (TF2_GetClientTeam(client) == TFTeam_Blue)
	{
		TE_SetupGlowSprite(struct_DeathRayData[client].Anchor_Loc, Glow_Sprite_Blue, TE_Duration, 2.0, 255);
		TE_SendToAll();
	}
	else
	{
		TE_SetupGlowSprite(struct_DeathRayData[client].Anchor_Loc, Glow_Sprite_Red, TE_Duration, 2.0, 255);
		TE_SendToAll();
	}

	//super earth's finest, in action!
	SDKUnhook(client, SDKHook_PreThink, OribtalDeathRay_Tick);
	SDKHook(client, SDKHook_PreThink, OribtalDeathRay_Tick);
}
static int i_DeathRayUser;
static float fl_DeathRayStart[3];
static void OribtalDeathRay_Tick(int client)
{
	float GameTime = GetGameTime();

	if(struct_DeathRayData[client].Timer < GameTime || CF_GetRoundState() != 1)
	{
		b_DeathRay_Active[client] = false;
		EmitSoundToAll(DEATHRAY_END_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, struct_DeathRayData[client].Location);
		SDKUnhook(client, SDKHook_PreThink, OribtalDeathRay_Tick);
		return;
	}
	bool update = true;
	if(struct_DeathRayData[client].Throttle > GameTime)
		update = false;

	float Location[3]; Location = struct_DeathRayData[client].Location;

	float Effect_EndLoc[3], Effect_Anchor_Loc[3];
	Effect_Anchor_Loc = struct_DeathRayData[client].Anchor_Loc;
	float Dist = GetVectorDistance(Location, Effect_Anchor_Loc)*1.1;

	if(struct_DeathRayData[client].BeamDist < Dist)
		struct_DeathRayData[client].BeamDist = Dist;

	Move_Vector_Towards_Target(Effect_Anchor_Loc, Location, Effect_EndLoc, struct_DeathRayData[client].BeamDist);

	float Radius = struct_DeathRayData[client].Radius;
	if(update)
	{
		EmitSoundToAll(DEATHRAY_PASSIVE_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, GetRandomFloat(0.75, 1.0), GetRandomInt(60, 180), -1, Location);

		EmitSoundToAll(DeathRayPassiveSounds[GetURandomInt() % sizeof(DeathRayPassiveSounds)], 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, GetRandomFloat(0.25, 0.5), GetRandomInt(75, 125), -1, Location);

		struct_DeathRayData[client].Throttle = GameTime + 0.1;
		float Travel_Dist = 0.0;
		Location[2]+=25.0;
		i_DeathRayUser = client;
		fl_DeathRayStart = Effect_Anchor_Loc;
		//do the los check from the anchor, but distance from the lasers loc
#if defined _pnpc_included_
		int Target = CF_GetClosestTarget(Location, true, Travel_Dist, 0.0, grabEnemyTeam(client), THIS_PLUGIN_NAME, Can_I_SeeTarget_Deathray);
#else
		int Target = CF_GetClosestTarget(Location, false, Travel_Dist, 0.0, grabEnemyTeam(client), THIS_PLUGIN_NAME, Can_I_SeeTarget_Deathray);
#endif
		Location[2]-=25.0;

		if(CF_IsValidTarget(Target, grabEnemyTeam(client)))
		{
			float Enemy_Loc[3];
			GetAbsOrigin_main(Target, Enemy_Loc);
			Travel_Dist = GetVectorDistance(Enemy_Loc, Location);
			float Speed = 250.0;
#if defined _pnpc_included_
			if(Target <= MaxClients)
			{
				Speed = CF_GetCharacterSpeed(Target);
			}
			else if(!view_as<PNPC>(Target).b_IsABuilding && PNPC_IsNPC(Target))
			{
				Speed = view_as<PNPC>(Target).f_Speed;
			}
#else
			Speed = CF_GetCharacterSpeed(Target);
#endif
			if(Speed <= 0.0)
				Speed = 250.0;

			Speed /=10.0;	//need to reduce speed by 10 since this happens 10 times a second.
			
			Speed *= struct_DeathRayData[client].Speed;
			if(Travel_Dist < Speed)
			{
				Speed*= (Travel_Dist/Speed);
			}

			//CPrintToChatAll("speed: %f",Speed);

			Move_Vector_Towards_Target(Location, Enemy_Loc, struct_DeathRayData[client].Location, Speed);
		}

		Generic_Laser_Trace Laser;

		float Angles[3];
		MakeVectorFromPoints(Effect_Anchor_Loc, Location, Angles);
		GetVectorAngles(Angles, Angles);

		Laser.client = client;
		Laser.DoForwardTrace_Custom(Angles, Effect_Anchor_Loc);
		
		float Trace_Dist = GetVectorDistance(Laser.Start_Point, Laser.End_Point);
		if(Trace_Dist > Dist)
			struct_DeathRayData[client].BeamDist = Trace_Dist;
		else
			struct_DeathRayData[client].BeamDist = Dist;
		
		Laser.Damage = struct_DeathRayData[client].Damage;
		Laser.damagetype = DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE;
		Laser.Radius =  Radius;
		Laser.Start_Point = Effect_Anchor_Loc;
		Laser.End_Point = Effect_EndLoc;
		Laser.Deal_Damage_Basic();

		/*float Land_Pos[3]; Land_Pos = Effect_EndLoc;
		Land_Pos[0]+=GetRandomFloat(-150.0, 150.0);
		Land_Pos[1]+=GetRandomFloat(-150.0, 150.0);
		EmitFancyIonEffect(Effect_EndLoc, Effect_Anchor_Loc);
		*/
	}

	int color[4]; color = GetColor(client);
	float TE_Duration = 0.1;
	float diameter = ClampBeamWidth(Radius*2.0);
									
	TE_SetupBeamPoints(Effect_Anchor_Loc, Effect_EndLoc, BEAM_Laser, BEAM_Glow, 0, 0, TE_Duration, diameter, diameter, 0, 1.0, color, 3);				
	TE_SendToAll();

	TE_SetupBeamPoints(Effect_Anchor_Loc, Effect_EndLoc, BEAM_Combine_Black, 0, 0, 0, TE_Duration, 0.7*diameter, 0.7*diameter, 0, 2.5, color, 3);				
	TE_SendToAll();

	int Laser_Core = (TF2_GetClientTeam(client) == TFTeam_Blue ? BEAM_Combine_Blue : BEAM_Combine_Red);
	TE_SetupBeamPoints(Effect_Anchor_Loc, Effect_EndLoc, Laser_Core, Laser_Core, 0, 0, TE_Duration, diameter, diameter, 0, 1.5, color, 3);				
	TE_SendToAll();
}
public bool Can_I_SeeTarget_Deathray(int enemy)
{
	return (enemy == Check_Line_Of_Sight(i_DeathRayUser, enemy, fl_DeathRayStart) && !IsPlayerInvis(enemy));
}
enum struct SuperShotgunData
{
	float damage_front;
	float damage_behind;
	float damage_multi;

	float falloffstart;
	float falloffmax;
	float maxdist;
	float metalgainonhit;

	float metal_tally;

}
static SuperShotgunData ShotgunData;
/*
	"Damage Bonus Max"			""
	"Damage Bonus Min"			""

	"KnockBack Max"				""
	"KnockBack Min"				""

	"Shotgun Lockout"			"0.75"

	"Base Damage"				""
	"Base Damage Behind"		""

	"FallOffStart"				""
	"FallOffMax"				""
	"MaxFallOffDist"			""
	"Metal Gain Back Ratio"		""

	"Pellets Fired Amt"			""
	"Pellets Pierce Amt"		""
	"Shotgun Spread"			""
*/
static void SuperShotgun_Activate(int client, char abilityName[255])
{
	if (CF_GetSpecialResource(client) < Buckshot_MinMetal)
	{
		PrintCenterText(client, "Must have at least %i Metal!", RoundFloat(Buckshot_MinMetal));
		EmitSoundToClient(client, NOPE);
		return;
	}

	float Dmg_Bonus_Max = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Damage Bonus Max");
	float Dmg_Bonus_Min = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Damage Bonus Min");

	float KB_Max = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "KnockBack Max");
	float KB_Min = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "KnockBack Min");

	int weapon = GetPlayerWeaponSlot(client, 0);

	float Ratio = CF_GetSpecialResource(client) / CF_GetMaxSpecialResource(client);

	float PushForce = -1.0 * (KB_Min + (KB_Max - KB_Min) * Ratio);

	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Shotgun Lockout"));

	SendClientFlying(client, Ratio, PushForce);
	EmitSuperShotgunEffects(client, Ratio);

	CF_SetSpecialResource(client, 0.0);	//nuke all metal!

	ShotgunData.damage_front = 	CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Base Damage");
	ShotgunData.damage_behind = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Base Damage Behind");
	ShotgunData.damage_multi = 	Dmg_Bonus_Min + (Dmg_Bonus_Max - Dmg_Bonus_Min) * Ratio;
	ShotgunData.falloffstart = 	CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "FallOffStart");
	ShotgunData.falloffmax 	=	CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "FallOffMax");//0.9;
	ShotgunData.maxdist 	=	CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "MaxFallOffDist");//0.9;
	ShotgunData.metalgainonhit=	CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Metal Gain Back Ratio");//0.9;
	ShotgunData.metal_tally = 0.0;

	int BulletsFired = 	CF_GetArgI(client, THIS_PLUGIN_NAME, abilityName, "Pellets Fired Amt");

	int PierceAmt = 	CF_GetArgI(client, THIS_PLUGIN_NAME, abilityName, "Pellets Pierce Amt");

	float BulletSpread = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Shotgun Spread");
	float width = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Hitbox Width");

	float ang[3];
	GetClientEyeAngles(client, ang);

	TFTeam Team = TF2_GetClientTeam(client);

	for (int i = 0; i < BulletsFired; i++)
		CF_FireGenericBullet(client, ang, 0.0, 1.0, BulletSpread, THIS_PLUGIN_NAME, SuperShotGunOnHit, 69420.0, 0.0, 0.0, PierceAmt, grabEnemyTeam(client), _, _, (Team == TFTeam_Red ? PARTICLE_SHOTGUN_TRACER_RED : PARTICLE_SHOTGUN_TRACER_BLUE), width);

	float Add_Metal = ShotgunData.metal_tally;

	if(Add_Metal > CF_GetMaxSpecialResource(client))
		Add_Metal = CF_GetMaxSpecialResource(client);

	CF_SetSpecialResource(client, Add_Metal);


}
public void SuperShotGunOnHit(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit, float hitPos[3])
{
	isHeadshot = false;
	hsEffect = false;

	bool behind = IsBehindAndFacingTarget(attacker, victim);

	float StartLoc[3]; GetClientEyePosition(attacker, StartLoc);

	float DistRatio = CalculateFallOff(StartLoc, hitPos, ShotgunData.falloffstart, ShotgunData.falloffmax, ShotgunData.maxdist);

	baseDamage = DistRatio * (behind ? ShotgunData.damage_behind : ShotgunData.damage_front) * ShotgunData.damage_multi;

	ShotgunData.metal_tally += baseDamage*ShotgunData.metalgainonhit;
}
/**
 * Automatically sets up and calls CF_DoBulletTrace and CF_TraceShot, then deals damage to every enemy it hits.
 * This is automatically lag-compensated, and also automatically checks for line-of-sight.
 * 
 * @param client		The client to fire the bullet.
 * @param ang			The angle of the shot.
 * @param damage		Base damage.
 * @param hsMult		Headshot damage multiplier.
 * @param spread		Random spread.
 * @param hitPlugin		Name of the plugin containing the optional function to call on a hit.
 * @param hitFunction	Optional function to call on a hit. Must take an int for the attacker, an int for the victim, a float by reference for damage, a bool by reference for falloff, a bool by reference for headshot, an int by reference for headshot effects, a bool by reference for crits, and a vector for hit position.
 * 						Example: void MyHeadshotCallback(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit, float hitPos[3])
 * 						baseDamage can be changed to modify the damage dealt before falloff is calculated.
 * 						Setting allowFalloff to false will block damage falloff from being calculated.
 * 						isHeadshot can be modified to force or prevent a headshot.
 * 						hsEffect is used for particle/sound effects on headshots. If <= 0, no effects are displayed. If set to 1, mini-crit effects are used. If >= 2, full crit effects are used.
 * 						crit can be set to true to force the attack to crit, or to prevent a crit. Forcing a crit will force hsEffect to 2.
 * @param falloffStart	Range at which damage falloff begins.
 * @param falloffEnd	Range at which damage falloff becomes its strongest.
 * @param falloffMax	Maximum percentage of damage to subtract based on falloff, IE 0.3 = 30% reduced damage.
 * @param pierce		The maximum number of enemies pierced by this attack.
 * @param team			Optional team to check for, using CF_IsValidTarget. Targets who are considered invalid by CF_IsValidTarget are ignored by this native.
 * @param plugin		Plugin name of the optional filter function, using CF_IsValidTarget. Only necessary if "filter" is used.
 * @param filter		Function name of the optional filter function, using CF_IsValidTarget. This function must take one int as a parameter, that being the entity's index, and must return a bool (true to count as valid, false otherwise).
 * @param particle		Bullet tracer particle to use. Must be a multi-point particle.
 */
static void SendClientFlying(int client, float Ratio, float PushForce)
{
	float anglesB[3];
	float velocity[3];
	GetClientEyeAngles(client, anglesB);
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = PushForce;
	
	ScaleVector(velocity, knockback);
	if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
		velocity[2] = fmax(velocity[2], 300.0*Ratio);
	else
		velocity[2] += 100.0*Ratio; // a little boost to alleviate arcing issues
		
	float newVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", newVel);

	AddVectors(velocity, newVel, velocity);
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
}
static void EmitSuperShotgunEffects(int client, float Ratio)
{
	float ShakeRatio = Ratio+0.25;
	if(ShakeRatio > 1.3)
		ShakeRatio = 1.3;
	Client_Shake(client, 0, 30.0 * ShakeRatio, 20.0 * ShakeRatio, 0.4 * ShakeRatio);

	EmitSoundToAll("beams/beamstart5.wav", client, SNDCHAN_STATIC, 80, _, (Ratio > 0.8 ? 0.8 : Ratio), 45);

	EmitSoundToClient(client, WidowCritSound[GetURandomInt() % sizeof(WidowCritSound)], _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, GetRandomInt(80, 125));
}

/*	
//OLD VERSION:
{
	float Dmg_Bonus_Max = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Damage Bonus Max");
	float Dmg_Bonus_Min = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Damage Bonus Min");

	float KB_Max = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "KnockBack Max");
	float KB_Min = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "KnockBack Min");

	int weapon = GetPlayerWeaponSlot(client, 0);

	float Ratio = CF_GetSpecialResource(client) / CF_GetMaxSpecialResource(client);

	float PushForce = -1.0 * (KB_Min + (KB_Max - KB_Min) * Ratio);

	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+0.75);

	
	
	float ShakeRatio = Ratio+0.25;
	if(ShakeRatio > 1.3)
		ShakeRatio = 1.3;
	Client_Shake(client, 0, 30.0 * ShakeRatio, 20.0 * ShakeRatio, 0.4 * ShakeRatio);

	EmitSoundToAll("beams/beamstart5.wav", client, SNDCHAN_STATIC, 80, _, (Ratio > 0.8 ? 0.8 : Ratio), 45);

	EmitSoundToClient(client, WidowCritSound[GetURandomInt() % sizeof(WidowCritSound)], _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, GetRandomInt(80, 125));

	float Distance = 	 	CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Distance Max"); //400.0;
	float FallOffStart = 	CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "FallOffStart");	//150.0;
	float FallOffMax = 		CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "FallOffMax");//0.9;
	int Original_Section =  CF_GetArgI(client, THIS_PLUGIN_NAME, abilityName, "Sections");	//4
	int Sections = Original_Section;

	float HeightMax = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Height Max");//75.0;
	float HeightMin = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Height Min");//10.0;

	float WidthMax = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Width Max");//125.0;
	float WidthMin = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Width Min");//25.0;

	bool Penetrate = view_as<bool>(CF_GetArgI(client, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Allow Penetration"));

	Generic_Laser_Trace Laser;
	Laser.client = client;
	Laser.DoForwardTrace_Basic(Distance, Penetrate ? INVALID_FUNCTION : Generic_Laser_BEAM_TraceWallAndEnemies);
	float CheckDistance = GetVectorDistance(Laser.Start_Point, Laser.End_Point);
	if(CheckDistance < Distance-10.0)
	{
		Sections = RoundToFloor(Original_Section*(CheckDistance/Distance));
	}
	//must allways have 1 section! also allows for an edge case to still trace the target.
	if(Sections<Original_Section)
		Sections++;
	
	Laser.Custom_Hull[0]=10.0;
	Laser.CleanEnumerator();

	float Angles[3];
	GetClientEyeAngles(client, Angles);
	float Previous_End[3]; Previous_End = Laser.End_Point;
	for(int i=1 ; i <= Sections ; i++)
	{
		float Section_Ratio = (float(i)/float(Original_Section));
		float Dist_Adjust = Distance*Section_Ratio;
		Get_Fake_Forward_Vec(Dist_Adjust, Angles, Laser.End_Point, Laser.Start_Point);
		Laser.Custom_Hull[1]= WidthMin + (WidthMax - WidthMin) * (1.0-Section_Ratio);
		Laser.Custom_Hull[2]= HeightMin + (HeightMax - HeightMin) * (1.0-Section_Ratio);

		Laser.EnumerateGetEntities();
	}

	float Damage_Attribute = Dmg_Bonus_Min + (Dmg_Bonus_Max - Dmg_Bonus_Min) * Ratio;
	float Damage = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Base Damage");
	float Damage_Behind = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Base Damage Behind");

	float PenFalloff = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Penetration Per Hit FallOff");

	float MetalGainBackRatio = CF_GetArgF(client, THIS_PLUGIN_NAME, abilityName, "Metal Gain Back Ratio");

	float TargetsHit = 1.0;

	float MaxMetal = CF_GetMaxSpecialResource(client);
	float Add_Metal = 0.0;

	//float Weapon_Loc[3];
	//GetEntityAttachment(client, LookupEntityAttachment(client, "effect_hand_r"), Weapon_Loc, NULL_VECTOR);

	for(int i=0 ; i < GetRandomInt(3,6) ; i ++)
	{
		float Offset_LOC[3]; Offset_LOC = Previous_End;
		Offset_LOC[0] += GetRandomFloat(-50.0, 50.0)*(CheckDistance/Distance);
		Offset_LOC[1] += GetRandomFloat(-50.0, 50.0)*(CheckDistance/Distance);
		Offset_LOC[2] += GetRandomFloat(-10.0, 10.0)*(CheckDistance/Distance);
		TE_SetupBeamPoints(Laser.Start_Point, Offset_LOC, BEAM_Laser, BEAM_Glow, 0, 0, 0.5, 5.0, 5.0, 0, 1.0, GetColor(client), 3);				
		TE_SendToAll();
	}
	
	Queue Victims = Laser.GetEnumeratedEntityPop();
	while(!Victims.Empty)
	{
		int victim = Victims.Pop();

		if(victim != Check_Line_Of_Sight(client, victim))
			continue;

		bool behind = IsBehindAndFacingTarget(client, victim);

		float VicLoc[3]; GetAbsOrigin_main(victim, VicLoc);

		float DistRatio = CalculateFallOff(Laser.Start_Point, VicLoc, FallOffStart, FallOffMax, Distance);

		float FinalDamage = DistRatio * (behind ? Damage_Behind : Damage) * Damage_Attribute * TargetsHit;

		Add_Metal +=FinalDamage*MetalGainBackRatio;

		SDKHooks_TakeDamage(victim, weapon, client, FinalDamage, (DMG_BULLET | DMG_ALWAYSGIB), -1, NULL_VECTOR, VicLoc);

		if(victim <=MaxClients)
			EmitSoundToClient(victim, WidowCritSound[GetURandomInt() % sizeof(WidowCritSound)], _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, GetRandomInt(80, 125));

		if(!Penetrate)
		{
			break;
		}
		TargetsHit *=PenFalloff;
	}

	if(Add_Metal > MaxMetal)
		Add_Metal = MaxMetal;
	CF_SetSpecialResource(client, Add_Metal);

	delete Victims;
}
*/

enum struct PadData
{
	int Particle;

	float CD;
	float Recharge;
	float Power;
	bool AllowEnemy;
}
static PadData structPadData[MAXENTITIES];
static bool b_IsAExitWithSound[MAXENTITIES];
void OnBuildObject(Event event, const char[] name, bool dontBroadcast)
{
	int entity = event.GetInt("index");
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	if(owner == -1)
	{
		return;
	}

	if(!CF_HasAbility(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS))
	{
		return;
	}

	TFObjectType obj_Type = TF2_GetObjectType(entity);

	if(obj_Type != TFObject_Teleporter)
		return;
	
	TFObjectMode obj_Mode = TF2_GetObjectMode(entity);

	switch(obj_Mode)
	{
		//jump pad.
		case TFObjectMode_Entrance:
		{
			SDKHook(entity, SDKHook_Touch, JumpPad_Touch);

			float Power = CF_GetArgF(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Jump Power");
			float CoolDown = CF_GetArgF(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Jump Cooldown");

			structPadData[entity].CD = CoolDown;
			structPadData[entity].Recharge = 0.0;
			structPadData[entity].AllowEnemy = view_as<bool>(CF_GetArgI(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Jump Pad Allow Enemies"));
			structPadData[entity].Power = Power;

			
			SetEntProp(entity, Prop_Send, "m_iHighestUpgradeLevel", 3);	//Set Pads to level 3 for cosmetic reasons related to recharging
			SetEntProp(entity, Prop_Send, "m_iUpgradeLevel", 3);
			SetEntProp(entity, Prop_Send, "m_bMiniBuilding", true);			//Prevent upgrades and metal from gibs
			SetEntProp(entity, Prop_Send, "m_iMaxHealth", CF_GetArgI(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Jump Pad Health"));			//Max HP reduced to what we want

			SetVariantInt(RoundFloat(CF_GetArgI(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Jump Pad Health") * 0.5));
			AcceptEntityInput(entity, "AddHealth", entity); //Spawns at 50% HP.
			SetEntProp(entity, Prop_Send, "m_iTimesUsed", 0);
			
			//SetEntProp(entity, Prop_Send, "m_nBody", 2);	//Give the arrow to Exits as well.
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.5);
			RequestFrame(ResetSkin, EntIndexToEntRef(entity)); //Setting m_bMiniBuilding tries to set the skin to a 'mini' skin. Since teles don't have one, reset the skin.
			
			SetEntProp(entity, Prop_Send, "m_bDisabled", true);
			CreateTimer(0.1, Timer_BlockTeleEffects, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			CreateTimer(0.1, Timer_HandlePadEffects, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

			DataPack pack = new DataPack();
			CreateDataTimer(1.0, Timer_KeepTeleMaxHealth, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);		//no need to update constantly.
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(CF_GetArgI(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Jump Pad Health"));

		}
		//default exit.
		case TFObjectMode_Exit:
		{
			SetEntProp(entity, Prop_Send, "m_iHighestUpgradeLevel", 3);	
			SetEntProp(entity, Prop_Send, "m_iUpgradeLevel", 3);
			SetEntProp(entity, Prop_Send, "m_bMiniBuilding", true);			//Prevent upgrades and metal from gibs
			SetEntProp(entity, Prop_Send, "m_iMaxHealth", CF_GetArgI(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Teleporter Exit Health"));			//Max HP reduced to what we want

			SetVariantInt(RoundFloat(CF_GetArgI(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Teleporter Exit Health") * 0.5));
			AcceptEntityInput(entity, "AddHealth", entity); //Spawns at 50% HP.
			SetEntProp(entity, Prop_Send, "m_iTimesUsed", 0);
			RequestFrame(ResetSkin, EntIndexToEntRef(entity)); //Setting m_bMiniBuilding tries to set the skin to a 'mini' skin. Since teles don't have one, reset the skin.
			SetEntProp(entity, Prop_Send, "m_bDisabled", true);

			CreateTimer(0.1, Timer_BlockTeleEffects, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

			DataPack pack = new DataPack();
			CreateDataTimer(1.0, Timer_KeepTeleMaxHealth, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);		//no need to update constantly.
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(CF_GetArgI(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Teleporter Exit Health"));

			SDKHook(entity, SDKHook_Touch, ExitTeleOnTouch);

			float Volume = CF_GetArgF(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Teleporter Exit Volume");
			if(Volume > 1.0)
				Volume = 0.25;

			if(Volume > 0.0)
			{
				b_IsAExitWithSound[entity] = true;
				EmitSoundToAll(TELE_EXIT_LOOP_SOUND, entity, SNDCHAN_AUTO, _, _, Volume);
			}
		}
	}
}
public void OnEntityDestroyed(int entity)
{
	if (IsValidEntity(entity) && entity < MAXENTITIES && entity > MaxClients)
	{
		int Particle = EntRefToEntIndex(structPadData[entity].Particle);
		if(IsValidEntity(Particle) && Particle != 0)
			RemoveEntity(Particle);
		structPadData[entity].Particle = INVALID_ENT_REFERENCE;

		if(b_IsAExitWithSound[entity])
		{
			b_IsAExitWithSound[entity] = false;
			StopSound(entity, SNDCHAN_AUTO, TELE_EXIT_LOOP_SOUND);
		}
	}
}
// Taken from Engi Pads but changed.
static void JumpPad_Touch(int entity, int other)
{
	if(!IsValidEntity(entity))
	{
		SDKUnhook(entity, SDKHook_Touch, JumpPad_Touch);
		return;
	}

	//is not a client, abort.
	if(!IsValidClient(other))
		return;
	
	//are we being sapped, got hit by cowmangler m2, are carried, or being built? if so, don't do anything
	if(GetEntProp(entity, Prop_Send, "m_bHasSapper") || GetEntProp(entity, Prop_Send, "m_bPlasmaDisable") || GetEntProp(entity, Prop_Send, "m_bCarried") || GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed")<1.0)
		return;

	float GameTime = GetGameTime();

	if(structPadData[entity].Recharge > GameTime)
		return;

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	if(!IsValidClient(owner))
		return;

	bool Allow_Enemy = structPadData[entity].AllowEnemy;

	if(!Allow_Enemy)
	{
		if(TF2_GetClientTeam(other) != TF2_GetClientTeam(owner))
			return;
	}

	float Power = structPadData[entity].Power;
	float CoolDown = structPadData[entity].CD;

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(other));
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(Power);
	pack.WriteFloat(CoolDown);
	RequestFrame(Teleport_JumpPad, pack);
}
static void Teleport_JumpPad(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());	//who is being pushed into the sky
	int pad = EntRefToEntIndex(pack.ReadCell());	//the pad itself
	float Power = pack.ReadFloat();					//how much velocity up.
	float CoolDown = pack.ReadFloat();				//how long does the pad dissable itself

	// respect any existing velocity, but completely override Z
	float playerVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", playerVelocity);
	playerVelocity[2] = Power;
	SetEntPropVector(client, Prop_Data, "m_vecVelocity", playerVelocity);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, playerVelocity);

	structPadData[pad].Recharge = GetGameTime() + CoolDown;

	fl_jumppad_falldamge_invlun[client] = GetGameTime() + (2.0 * Power/650.0);	//make it scale on power, 650.0 with 2.0 seconds is perfectly aligned.
	TF2_AddCondition(client, TFCond_TeleportedGlow, CoolDown);

	EmitGameSoundToAll(JUMPPAD_IMPACT1, pad);
	EmitGameSoundToAll(JUMPPAD_IMPACT2, pad);
}

static Action Timer_BlockTeleEffects(Handle timer, int Ref)
{
	int entity = EntRefToEntIndex(Ref);
	if(entity != -1)
	{
		SetEntProp(entity, Prop_Send, "m_bDisabled", true);
		return Plugin_Continue;
	}

	return Plugin_Stop;
}
static Action Timer_KeepTeleMaxHealth(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
		if(IsValidClient(owner))
		{
			int maxhealth = pack.ReadCell();
			SetEntProp(entity, Prop_Send, "m_iMaxHealth", maxhealth);
			int current = GetEntProp(entity, Prop_Data, "m_iHealth");
			if(current > maxhealth)
				SetEntProp(entity, Prop_Send, "m_iHealth", maxhealth);
		}
		return Plugin_Continue;
	}

	return Plugin_Stop;
}
static Action Timer_HandlePadEffects(Handle timer, int Ref)
{
	int entity = EntRefToEntIndex(Ref);
	if(entity != -1)
	{
		float GameTime = GetGameTime();

		//are we recharging, being sapped, got hit by cowmangler m2, are carried, or being built? if so, destroy the particle.
		if(structPadData[entity].Recharge > GameTime || GetEntProp(entity, Prop_Send, "m_bHasSapper") || GetEntProp(entity, Prop_Send, "m_bPlasmaDisable") || GetEntProp(entity, Prop_Send, "m_bCarried") || GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed")<1.0)
		{
			int particle = EntRefToEntIndex(structPadData[entity].Particle);

			if(IsValidEntity(particle) && particle != 0)
				RemoveEntity(particle);
		}
		else
		{
			int particle = EntRefToEntIndex(structPadData[entity].Particle);
			if(IsValidEntity(particle))
				return Plugin_Continue;

			float Loc[3]; GetAbsOrigin_main(entity, Loc);
			//Loc[2] += 2.0;
			int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
			if(IsValidClient(owner))
				structPadData[entity].Particle = EntIndexToEntRef(ParticleEffectAt(Loc, (TF2_GetClientTeam(owner) == TFTeam_Red ? "teleporter_red_entrance"	: "teleporter_blue_entrance"), 0.0));
		}
		return Plugin_Continue;
	}

	return Plugin_Stop;
}

///Eureka Effect teleport detection
public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	
	if(!CF_HasAbility(client, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS))
		return;

	int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(!IsValidEntity(activeWeapon))
		return;

	ProcessEurekaEffectCondAdded(client, condition);
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	
	if(!CF_HasAbility(client, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS))
		return;

	int weapon = GetPlayerWeaponSlot(client, 2);

	if(!IsValidEntity(weapon))
		return;

	ProcessEurekaEffectCondRemoved(client, condition);

}

static void ProcessEurekaEffectCondAdded(int client, TFCond condition)
{
	char classname[64];
	GetEntityNetClass(client, classname, sizeof(classname));

	int offset = GetEntData(client, FindSendPropInfo(classname, "m_flKartNextAvailableBoost") + 8, 1);

	if(condition == TFCond_Taunting && offset) // We check for eureka teleport cond here because it doesnt always stay when taunt ends
	{
		TPInitiated[client] = true; // Client is in the process of teleporting, we will check for this when taunt runs out
	}
}
static float fl_allow_exit_touch[MAXTF2PLAYERS];
static void ProcessEurekaEffectCondRemoved(int client, TFCond condition)
{
	if(!TPInitiated[client])
		return;

	if(condition != TFCond_Taunting)
		return;

	// Taunt finished and client was in the process of teleporting?
	TPInitiated[client] = false;

	fl_allow_exit_touch[client] = GetGameTime() + 0.25;
}


static void ExitTeleOnTouch(int entity, int other)
{
	if(!IsValidEntity(entity))
	{
		SDKUnhook(entity, SDKHook_Touch, ExitTeleOnTouch);
		return;
	}

	//is not a client, abort.
	if(!IsValidClient(other))
		return;
	
	////are we being sapped, got hit by cowmangler m2, are carried, or being built? if so, don't do anything
	//if(GetEntProp(entity, Prop_Send, "m_bHasSapper") || GetEntProp(entity, Prop_Send, "m_bPlasmaDisable") || GetEntProp(entity, Prop_Send, "m_bCarried") || GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed")<1.0)
	//	return;


	int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	if(owner != other)
		return;
	//only allow the owner of the tele exit to get in

	if(fl_allow_exit_touch[owner] < GetGameTime())
	{
		return;
	}

	fl_allow_exit_touch[owner] = 0.0;
	//CPrintToChatAll("owner of tele has touched tele after teleporting");

	float Volume = CF_GetArgF(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Teleporter Exit Volume On Teleport");
	if(Volume > 1.0)
		Volume = 0.25;

	if(Volume > 0.0)
	{
		EmitSoundToAll(TELE_EXIT_TELE_SOUND, entity, SNDCHAN_AUTO, _, _, Volume, 254);
	}
	float Loc[3]; GetAbsOrigin_main(entity, Loc);
	Loc[2] += 2.0;
	float ParticleTime = CF_GetArgF(owner, THIS_PLUGIN_NAME, CUSTOM_TELEPORTERS, "Teleporter Exit Particle Life");
	

	TFTeam team = TF2_GetClientTeam(owner);
	char particles[6][255];
	particles[0] = team == TFTeam_Red ? "teleporter_red_entrance"		: "teleporter_blue_entrance";
	particles[1] = team == TFTeam_Red ? "teleporter_red_charged_level2"	: "teleporter_blue_charged_level2";
	particles[2] = team == TFTeam_Red ? "teleporter_red_charged_level3"	: "teleporter_blue_charged_level3";
	particles[3] = team == TFTeam_Red ? "teleporter_red_entrance_level3": "teleporter_blue_entrance_level3";
	particles[4] = team == TFTeam_Red ? "teleporter_red_charged"		: "teleporter_blue_charged";
	particles[5] = team == TFTeam_Red ? "teleporter_red_charged_wisps"	: "teleporter_blue_charged_wisps";

	TF2_AddCondition(owner, TFCond_TeleportedGlow, ParticleTime*1.25);

	if(ParticleTime <= 0.0)
		return;
		
	for(int i=0 ; i < 6 ; i++)
	{
		ParticleEffectAt(Loc, particles[i], ParticleTime);
	}
}



//When a player becomes a character, this forward is called. This forward is best used for passive abilities.
//For example, if our character plugin contains a passive ability that gives the character low gravity, we would
//read the passive ability's variables and apply them in here.
public void CF_OnCharacterCreated(int client)
{
	TPInitiated[client] = false;
}

//When a player's character is removed (typically when they die or leave the match), this forward is called.
//This forward is best for cleaning up variables used by your ability. For example, if our character plugin
//contains a passive ability that attaches a particle to the character, we would remove that particle in here
//to prevent it from following the player's spectator camera while they're dead.
public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	if(reason == CF_CRR_SWITCHED_CHARACTER)
	{
		FakeClientCommand(client, "destroy 0; destroy 1; destroy 2; destroy 3");
	}

	//don't kill deathray on client death.
	if(reason != CF_CRR_DEATH && reason != CF_CRR_RESPAWNED)
	{
		b_DeathRay_Active[client] = false;
		SDKUnhook(client, SDKHook_PreThink, OribtalDeathRay_Tick);
	}
}
//responsible for jumppad falldamage nullification
public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	//is not a client, abort
	if(victim > MaxClients)
		return Plugin_Continue;

	//is the fall damage timer up, and is the damage type fall damage?
	if((damagetype & DMG_FALL) && fl_jumppad_falldamge_invlun[victim] > GetGameTime())
	{
		damage = 0.0;	//remove fall damage
		fl_jumppad_falldamge_invlun[victim] = 0.0;	//and also kill the timer so they can't take multiple falldamage immunities
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public Action CF_OnTakeDamageAlive_Post(int victim, int attacker, int inflictor, float damage, int weapon)
{
	if (CF_HasAbility(attacker, THIS_PLUGIN_NAME, METAL_PISTOL))
	{
		int slot = CF_GetArgI(attacker, THIS_PLUGIN_NAME, METAL_PISTOL, "Weapon Slot");
		if(IsPlayerHoldingWeapon(attacker, slot) && TF2_GetActiveWeapon(attacker) == weapon)
		{
			float amount = float(CF_GetArgI(attacker, THIS_PLUGIN_NAME, METAL_PISTOL, "Metal Gain On Hit"));
			float MaxMetal = CF_GetMaxSpecialResource(attacker);//CF_GetArgI(attacker, THIS_PLUGIN_NAME, METAL_PISTOL, "Max Metal Gain");
			float Current_Metal = CF_GetSpecialResource(attacker); //GetEntProp(attacker, Prop_Data, "m_iAmmo", 4, 3);
			float Add_Metal = Current_Metal + amount;

			if(Add_Metal > MaxMetal)
				Add_Metal = MaxMetal;
			CF_SetSpecialResource(attacker, Add_Metal);
			//SetEntProp(attacker, Prop_Data, "m_iAmmo", Add_Metal, 4, 3);
		}
	}
	return Plugin_Continue;
}

public Action CF_OnUltChargeGiven(int client, float &amt)
{
	if (b_DeathRay_Active[client] && amt > 0.0)
	{
		amt = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if (!StrEqual(plugin, THIS_PLUGIN_NAME))
		return Plugin_Continue;

	if(type == CF_AbilityType_Ult)
	{
		if (StrContains(ability, ORBITAL_DEATH_RAY) != -1 && b_DeathRay_Active[client])
		{
			result = false;
			return Plugin_Changed;
		}
	}
	else if(type == CF_AbilityType_M2)
	{
		if (StrContains(ability, SUPER_SHOTGUN) != -1)
		{
			result = IsPlayerHoldingWeapon(client, 0);

			if(GetEntPropFloat(GetPlayerWeaponSlot(client, 0), Prop_Send, "m_flNextPrimaryAttack") > GetGameTime())
				result = false;
			return Plugin_Changed;
		}
	}

	
	return Plugin_Continue;
}

//Stocks and such.

#define	SHAKE_START					0			// Starts the screen shake for all players within the radius.
#define	SHAKE_STOP					1			// Stops the screen shake for all players within the radius.
#define	SHAKE_AMPLITUDE				2			// Modifies the amplitude of an active screen shake for all players within the radius.
#define	SHAKE_FREQUENCY				3			// Modifies the frequency of an active screen shake for all players within the radius.
#define	SHAKE_START_RUMBLEONLY		4			// Starts a shake effect that only rumbles the controller, no screen effect.
#define	SHAKE_START_NORUMBLE		5			// Starts a shake that does NOT rumble the controller.

stock bool Client_Shake(int client, int command=SHAKE_START, float amplitude=50.0, float frequency=150.0, float duration=3.0)
{
	if (command == SHAKE_STOP) {
		amplitude = 0.0;
	}
	else if (amplitude <= 0.0) {
		return false;
	}

	Handle userMessage = StartMessageOne("Shake", client);

	if (userMessage == INVALID_HANDLE) {
		return false;
	}

	if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available
		&& GetUserMessageType() == UM_Protobuf) {

		PbSetInt(userMessage,   "command",		 command);
		PbSetFloat(userMessage, "local_amplitude", amplitude);
		PbSetFloat(userMessage, "frequency",	   frequency);
		PbSetFloat(userMessage, "duration",		duration);
	}
	else {
		BfWriteByte(userMessage,	command);	// Shake Command
		BfWriteFloat(userMessage,	amplitude);	// shake magnitude/amplitude
		BfWriteFloat(userMessage,	frequency);	// shake noise frequency
		BfWriteFloat(userMessage,	duration);	// shake lasts this long
	}

	EndMessage();

	return true;
}
stock void ResetSkin(int Ref)
{
	int iEnt = EntRefToEntIndex(Ref);
	if (IsValidEntity(iEnt))
	{
		int iTeam = GetEntProp(iEnt, Prop_Data, "m_iTeamNum");
		SetEntProp(iEnt, Prop_Send, "m_nSkin", iTeam - 2);
	}
}
stock int ParticleEffectAt(float position[3], const char[] effectName, float duration)
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		SetEntPropFloat(particle, Prop_Data, "m_flSimulationTime", GetGameTime());
		DispatchKeyValue(particle, "effect_name", effectName);

		DispatchSpawn(particle);
		if(effectName[0])
		{
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
		}

		SetEdictFlags(particle, (GetEdictFlags(particle) & ~FL_EDICT_ALWAYS));

		if (duration > 0.0)
		{
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return particle;
}
stock int[] GetColor(int client) 
{ 
	//the compiler didn't like me doing it one way, so I had to do it this way.
	int color1[4], color2[4]; 
	color1 = {255, 50, 50, 255}; color2 = {50, 50, 255, 255};
	return (TF2_GetClientTeam(client) == TFTeam_Red ? color1 : color2); 
}
/**
 *  @param Origin - Input
 *  @param Target - Input
 *  @param EndLoc - Output
 *  @param Speed - How far it goes, in HU.
 */
stock void Move_Vector_Towards_Target(float Origin[3], float Target[3], float EndLoc[3], float Speed)
{
	float Angles[3];
	MakeVectorFromPoints(Origin, Target, Angles);
	GetVectorAngles(Angles, Angles);

	Get_Fake_Forward_Vec(Speed, Angles, EndLoc, Origin);
}
/**
 *  @param Range - self explanitory.
 *  @param Angles - twoards where should it go
 *  @param Vec_Target - Output Vector.
 *  @param Pos - Input Vector
 */
stock void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}

//Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, cur_vec);
stock void Proper_To_Groud_Clip(float vecHull[3], float StepHeight = 300.0, float vecorigin[3])
{
	float originalPostionTrace[3];
	float startPostionTrace[3];
	float endPostionTrace[3];
	endPostionTrace = vecorigin;
	startPostionTrace = vecorigin;
	originalPostionTrace = vecorigin;
	startPostionTrace[2] += StepHeight;
	endPostionTrace[2] -= 5000.0;

	float vecHullMins[3];
	vecHullMins = vecHull;

	vecHullMins[0] *= -1.0;
	vecHullMins[1] *= -1.0;
	vecHullMins[2] *= -1.0;

	Handle trace;
	trace = TR_TraceHullFilterEx( startPostionTrace, endPostionTrace, vecHullMins, vecHull, MASK_PLAYERSOLID,Generic_Laser_BEAM_TraceWallsOnly, 0);
	if ( TR_GetFraction(trace) < 1.0)
	{
		// This is the point on the actual surface (the hull could have hit space)
		TR_GetEndPosition(vecorigin, trace);	
	}
	vecorigin[0] = originalPostionTrace[0];
	vecorigin[1] = originalPostionTrace[1];

	float VecCalc = (vecorigin[2] - startPostionTrace[2]);
	if(VecCalc > (StepHeight - (vecHull[2] + 2.0)) || VecCalc > (StepHeight - (vecHull[2] + 2.0)) ) //This means it was inside something, in this case, we take the normal non traced position.
	{
		vecorigin[2] = originalPostionTrace[2];
	}

	delete trace;
	//if it doesnt hit anything, then it just does buisness as usual
}

//taken from gadgeteer. modified
static int Beacon_CreateProp(int owner, float Throw_Speed)
{
	float velocity = Throw_Speed;
	
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
		float gravity = 1.0;
		SetEntityMoveType(toolbox, MOVETYPE_FLYGRAVITY);
		SetEntityGravity(toolbox, gravity);
		
		//SET MODEL:

		SetEntityModel(toolbox, BEACON_BASE_MODEL);
		DispatchKeyValue(toolbox, "skin", team == TFTeam_Red ? "0" : "1");

		
		//SET SCALE:
		DispatchKeyValue(toolbox, "modelscale", "1.0");
		
		//COLLISION RULES:
		DispatchKeyValue(toolbox, "solid", "6");
		DispatchKeyValue(toolbox, "spawnflags", "12288");
		SetEntProp(toolbox, Prop_Send, "m_usSolidFlags", 8);
		SetEntProp(toolbox, Prop_Data, "m_nSolidType", 2);
		SetEntityCollisionGroup(toolbox, 23);
		
		//ACTIVATION:
		DispatchKeyValueFloat(toolbox, "massScale", 1.0);
		DispatchKeyValueFloat(toolbox, "intertiascale", 1.0);
		DispatchSpawn(toolbox);
		ActivateEntity(toolbox);
		
		//DAMAGE AND TEAM:
		SetEntProp(toolbox, Prop_Data, "m_takedamage", 1, 1);
		SetEntProp(toolbox, Prop_Send, "m_iTeamNum", view_as<int>(team));

		for(int i= 0 ; i < 3 ; i++)
		{
			ang[i] = GetRandomFloat(0.0, 360.0);
		}
		TeleportEntity(toolbox, pos, ang, vel);

		return toolbox;
	}

	return -1;
}
static void Beacon_CheckForCollision(int ref)
{
	int prop = EntRefToEntIndex(ref);
	if (!IsValidEntity(prop))
		return;
		
	int client = EntRefToEntIndex(i_beacon_owner[prop]);
	if(!IsValidClient(client))
		return;

	float hullMin[3], hullMax[3];
	hullMin[0] = -10.0;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	float pos[3]; GetAbsOrigin_main(prop, pos);
	TR_TraceHullFilter(pos, pos, hullMin, hullMax, MASK_SHOT, Generic_Laser_BEAM_TraceWallsOnly, client);
	if (TR_DidHit())
	{
		float Initiate_In = CF_GetArgF(client, THIS_PLUGIN_NAME, ORBITAL_DEATH_RAY, "WindUp"); //3.0;
		if(Initiate_In<= 0.5)
			Initiate_In = 0.5;

		float Sky_Loc[3];
		Sky_Loc = GetDeathRayAnchorLocation(client, pos);
		TE_SetupBeamPoints(pos, Sky_Loc, BEAM_Laser, BEAM_Glow, 0, 0, Initiate_In, 15.0, 15.0, 0, 1.0, GetColor(client), 3);				
		TE_SendToAll();

		i_beacon_owner[prop] = INVALID_ENT_REFERENCE;

		DataPack pack2 = new DataPack();
		CreateDataTimer(Initiate_In, OffSetDeathRay_Spawn, pack2, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack2, EntIndexToEntRef(client));
		WritePackCell(pack2, EntIndexToEntRef(prop));

		TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, {0.0, 0.0,0.0});
		SetEntityMoveType(prop, MOVETYPE_NONE);
		return;
	}
	
	RequestFrame(Beacon_CheckForCollision, ref);
}
//my beloved stocks that I cannot live without :3
stock void Offset_Vector(float BEAM_BeamOffset[3], float Angles[3], float Result_Vec[3])
{
	float tmp[3];
	float actualBeamOffset[3];

	tmp[0] = BEAM_BeamOffset[0];
	tmp[1] = BEAM_BeamOffset[1];
	tmp[2] = 0.0;
	VectorRotate(BEAM_BeamOffset, Angles, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[2];
	Result_Vec[0] += actualBeamOffset[0];
	Result_Vec[1] += actualBeamOffset[1];
	Result_Vec[2] += actualBeamOffset[2];
}
//the attacker must be valid, same for enemy, otherwise why?
stock int Check_Line_Of_Sight(int attacker, int enemy, float Override_Start[3] = {0.0,0.0,0.0}, float Override_End[3] =  {0.0,0.0,0.0})
{
	char classname[255];
	GetEntityClassname(enemy, classname, sizeof(classname));
	if (StrContains(classname, "prop_physics") != -1)
		return -1;
		
	Generic_Laser_Trace Laser;
	Laser.client = (attacker <= MaxClients ? attacker : -1); //-1 will block lag comp.
	float pos_npc[3];
	if(Override_Start[0] != 0.0 || Override_Start[1] != 0.0 || Override_Start[2] != 0.0)
	{
		pos_npc = Override_Start;
	}
	else
	{
		GetAbsOrigin_main(attacker, pos_npc); pos_npc[2]+=75.0;
	}
	float Enemy_Loc[3], vecAngles[3];
	//get the enemy gamer's location.
	if(Override_End[0] != 0.0 || Override_End[1] != 0.0 || Override_End[2] != 0.0)
	{
		Enemy_Loc = Override_End;
	}
	else
	{
		GetAbsOrigin_main(enemy, Enemy_Loc); Enemy_Loc[2]+=75.0;
	}
	
	//get the angles from the current location of the vector to the enemy gamer
	MakeVectorFromPoints(pos_npc, Enemy_Loc, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	//get the estimated distance to the enemy gamer,
	float Dist = GetVectorDistance(Enemy_Loc, pos_npc);
	//do a trace from the current location of the vector to the enemy gamer.
	Laser.DoForwardTrace_Custom(vecAngles, pos_npc, Dist);	//alongside that, use the estimated distance so that our end location from the trace is where the player is.
	
	
	//debuging stuff
	/*
	float sky[3];
	sky = Laser.End_Point;
	sky[2] +=19999.0;
	TE_SetupBeamPoints(Enemy_Loc, pos_npc, BEAM_Laser, 0, 0, 0, 5.0, 10.0, 5.0, 0, 0.1, {255,0,0,255}, 3);
	TE_SendToAll();

	TE_SetupBeamPoints(Laser.End_Point, pos_npc, BEAM_Laser, 0, 0, 0, 5.0, 10.0, 5.0, 0, 0.1, {0,255,0,255}, 3);
	TE_SendToAll();

	TE_SetupBeamPoints(Laser.End_Point, Enemy_Loc, BEAM_Laser, 0, 0, 0, 5.0, 10.0, 5.0, 0, 0.1, {0,0,255,255}, 3);
	TE_SendToAll();

	TE_SetupBeamPoints(Laser.End_Point, sky, BEAM_Laser, 0, 0, 0, 5.0, 10.0, 5.0, 0, 0.1, {255,255,255,255}, 3);
	TE_SendToAll();
	*/

	//see if the vectors match up, if they do we can safely say the enemy gamer is in sight of the vector.
	if(Similar_Vec(Laser.End_Point, Enemy_Loc))
		return enemy;
	else
		return -1;
}
stock bool Similar_Vec(float Vec1[3], float Vec2[3])
{
	for(int i=0 ; i < 3 ; i ++)
	{
		if(!Similar(Vec1[i], Vec2[i]))
			return false;
	}
	return true;
}
stock bool Similar(float val1, float val2)
{
	return fabs(val1 - val2) < 2.0;
}
stock void GetAbsOrigin_main(int client, float v[3])
{
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", v);
}
stock void RequestFrames(RequestFrameCallback func, int frames, any data=0)
{
	DataPack pack = new DataPack();
	pack.WriteFunction(func);
	pack.WriteCell(data);
	pack.WriteCell(frames);
	RequestFrame(RequestFramesCallback, pack);
}

public void RequestFramesCallback(DataPack pack)
{
	pack.Reset();
	Function func = pack.ReadFunction();
	any data = pack.ReadCell();

	int frames = pack.ReadCell();
	if(frames < 1)
	{
		delete pack;
		
		Call_StartFunction(null, func);
		Call_PushCell(data);
		Call_Finish();
	}
	else
	{
		pack.Position--;
		pack.WriteCell(frames-1, false);
		RequestFrame(RequestFramesCallback, pack);
	}
}

static int i_traced_ents_amt;
enum struct Generic_Laser_Trace
{
	int client;
	float Start_Point[3];
	float End_Point[3];
	float Radius;
	float Damage;
	int damagetype;

	bool player_check;

	bool trace_hit;
	bool trace_hit_enemy;

	float Custom_Hull[3];

	void DoForwardTrace_Basic(float Dist=-1.0, TraceEntityFilter Func_Trace = INVALID_FUNCTION)
	{
		if(Func_Trace==INVALID_FUNCTION)
			Func_Trace = Generic_Laser_BEAM_TraceWallsOnly;

		float Angles[3], startPoint[3], Loc[3];
		GetClientEyeAngles(this.client, Angles);
		GetClientEyePosition(this.client, startPoint);
		CF_StartLagCompensation(this.client);
		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, Func_Trace, this.client);
		CF_EndLagCompensation(this.client);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(Loc, trace);
			delete trace;

			CF_HasLineOfSight(startPoint, Loc, _, Loc, this.client);

			if(Dist !=-1.0)
			{
				ConformLineDistance(Loc, startPoint, Loc, Dist);
			}
			this.Start_Point = startPoint;
			this.End_Point = Loc;
			this.trace_hit=true;
		}
		else
		{
			delete trace;
		}
	}
	void DoForwardTrace_Custom(float Angles[3], float startPoint[3], float Dist=-1.0, TraceEntityFilter Func_Trace = INVALID_FUNCTION)
	{
		if(Func_Trace==INVALID_FUNCTION)
			Func_Trace = Generic_Laser_BEAM_TraceWallsOnly;

		float Loc[3];
		if(this.client !=-1)
			CF_StartLagCompensation(this.client);
		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, Func_Trace, this.client);
		if(this.client !=-1)
			CF_EndLagCompensation(this.client);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(Loc, trace);
			delete trace;


			if(Dist !=-1.0)
			{
				ConformLineDistance(Loc, startPoint, Loc, Dist);
			}
			this.Start_Point = startPoint;
			this.End_Point = Loc;
			this.trace_hit=true;
		}
		else
		{
			delete trace;
		}
	}

	void CleanEnumerator()
	{
		i_traced_ents_amt = 0;
		Zero(Generic_Laser_BEAM_HitDetected);
	}

	void EnumerateGetEntities(TraceEntityFilter Hull_TraceFunc = INVALID_FUNCTION)
	{
		if(Hull_TraceFunc==INVALID_FUNCTION)
			Hull_TraceFunc = Generic_Laser_BEAM_TraceUsers;

		float hullMin[3], hullMax[3];
		this.SetHull(hullMin, hullMax);

		if(this.client !=-1)
			CF_StartLagCompensation(this.client);
		Handle trace = TR_TraceHullFilterEx(this.Start_Point, this.End_Point, hullMin, hullMax, 1073741824, Hull_TraceFunc, this.client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		if(this.client !=-1)
			CF_EndLagCompensation(this.client);
	}
	Queue GetEnumeratedEntityPop()
	{
		Queue Victims = new Queue();

		for (int loop = 0; loop < i_traced_ents_amt; loop++)
		{
			//so we don't have to loop through max ents worth of ents when we only have 1 valid
			int victim = Generic_Laser_BEAM_HitDetected[loop];
			if(victim)
				Victims.Push(victim);
		}

		return Victims;
	}

	void Deal_Damage_Basic(Function Attack_Function = INVALID_FUNCTION)
	{
		this.CleanEnumerator();
		this.EnumerateGetEntities();
		Queue Victims = this.GetEnumeratedEntityPop();
				
		while(!Victims.Empty)
		{
			int victim = Victims.Pop();
			if (victim)
			{
				this.trace_hit_enemy=true;
				if(this.player_check)
				{
					if(Attack_Function && Attack_Function != INVALID_FUNCTION)
					{	
						Call_StartFunction(null, Attack_Function);
						Call_PushCell(this.client);
						Call_PushCell(victim);
						Call_PushCell(this.damagetype);
						Call_PushFloat(this.Damage);
						Call_Finish();	
					}
				}
				else
				{
					float playerPos[3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);

					SDKHooks_TakeDamage(victim, this.client, this.client, this.Damage, this.damagetype, -1, NULL_VECTOR, playerPos);

					if(Attack_Function && Attack_Function != INVALID_FUNCTION)
					{	
						Call_StartFunction(null, Attack_Function);
						Call_PushCell(this.client);
						Call_PushCell(victim);
						Call_PushCell(this.damagetype);
						Call_PushFloat(this.Damage);
						Call_Finish();
					}
				}
			}
		}
		delete Victims;
	}
	void SetHull(float hullMin[3], float hullMax[3])
	{
		if(this.Custom_Hull[0] != 0.0 || this.Custom_Hull[1] != 0.0 || this.Custom_Hull[2] != 0.0)
		{
			hullMin[0] = -this.Custom_Hull[0];
			hullMin[1] = -this.Custom_Hull[1];
			hullMin[2] = -this.Custom_Hull[2];
		}
		else
		{
			hullMin[0] = -this.Radius;
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
		}
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
	}
}
stock float CalculateFallOff(float StartLoc[3], float EndLoc[3], float falloffstart, float falloffmax, float maxDist)
{
	float dist = GetVectorDistance(StartLoc, EndLoc);
	//FF2Dbg("Input damage: %f", Damage);
	if (dist > falloffstart)
	{
		if(dist > maxDist)
			return falloffmax;

		float diff = dist - falloffstart;
		float rad = maxDist - falloffstart;
		
		return (1.0 - ((diff/rad) * falloffmax));
	}
	return 1.0;
}

stock bool Generic_Laser_BEAM_TraceWallsOnly(int entity, int contentsMask, int client)
{
	return !entity;
}
stock bool Generic_Laser_BEAM_TraceWallAndEnemies(int entity, int contentsMask, int client)
{
	if(CF_IsValidTarget(entity, grabEnemyTeam(client)))
		return true;
		

	return !entity;
}

bool Generic_Laser_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		if(client == -1 || CF_IsValidTarget(entity, grabEnemyTeam(client)))
		{
			for(int i=0 ; i < MAXENTITIES ; i++)
			{
				//don't retrace the same entity!
				if(Generic_Laser_BEAM_HitDetected[i] == entity)
					break;
					
				if(!Generic_Laser_BEAM_HitDetected[i])
				{
					i_traced_ents_amt++;	//so we don't have to loop through max ents worth of ents when we only have 1 valid
					Generic_Laser_BEAM_HitDetected[i] = entity;
					break;
				}
			}
		}
	}
	return false;
}
//and the other stocks I need for my stocks to work
stock float ConformAxisValue(float src, float dst, float distCorrectionFactor)
{
	return src - ((src - dst) * distCorrectionFactor);
}
stock float DEG2RAD(float n)
{
	return n * 0.017453;
}

stock float DotProduct(float v1[3], float v2[4])
{
	return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
}

stock void VectorRotate2(float in1[3], float in2[3][4], float out[3])
{
	out[0] = DotProduct(in1, in2[0]);
	out[1] = DotProduct(in1, in2[1]);
	out[2] = DotProduct(in1, in2[2]);
}

stock void AngleMatrix(float angles[3], float matrix[3][4])
{
	float sr = 0.0;
	float sp = 0.0;
	float sy = 0.0;
	float cr = 0.0;
	float cp = 0.0;
	float cy = 0.0;
	sy = Sine(DEG2RAD(angles[1]));
	cy = Cosine(DEG2RAD(angles[1]));
	sp = Sine(DEG2RAD(angles[0]));
	cp = Cosine(DEG2RAD(angles[0]));
	sr = Sine(DEG2RAD(angles[2]));
	cr = Cosine(DEG2RAD(angles[2]));
	matrix[0][0] = cp * cy;
	matrix[1][0] = cp * sy;
	matrix[2][0] = -sp;
	float crcy = cr * cy;
	float crsy = cr * sy;
	float srcy = sr * cy;
	float srsy = sr * sy;
	matrix[0][1] = sp * srcy - crsy;
	matrix[1][1] = sp * srsy + crcy;
	matrix[2][1] = sr * cp;
	matrix[0][2] = sp * crcy + srsy;
	matrix[1][2] = sp * crsy - srcy;
	matrix[2][2] = cr * cp;
	matrix[0][3] = 0.0;
	matrix[1][3] = 0.0;
	matrix[2][3] = 0.0;
}

stock void VectorRotate(float inPoint[3], float angles[3], float outPoint[3])
{
	float matRotate[3][4];
	AngleMatrix(angles, matRotate);
	VectorRotate2(inPoint, matRotate, outPoint);
}

stock float ClampBeamWidth(float w) { return w > 128.0 ? 128.0 : w; }
stock int GetR(int c) { return abs((c>>16)&0xff); }
stock int GetG(int c) { return abs((c>>8 )&0xff); }
stock int GetB(int c) { return abs((c	)&0xff); }
stock int abs(int x) { return x < 0 ? -x : x; }
// if the distance between two points is greater than max distance allowed
// fills result with a new destination point that lines on the line between src and dst
stock void ConformLineDistance(float result[3], const float src[3], const float dst[3], float maxDistance, bool canExtend = false)
{
	float distance = GetVectorDistance(src, dst);
	if (distance <= maxDistance && !canExtend)
	{
		// everything's okay.
		result[0] = dst[0];
		result[1] = dst[1];
		result[2] = dst[2];
	}
	else
	{
		// need to find a point at roughly maxdistance. (FP irregularities aside)
		float distCorrectionFactor = maxDistance / distance;
		result[0] = ConformAxisValue(src[0], dst[0], distCorrectionFactor);
		result[1] = ConformAxisValue(src[1], dst[1], distCorrectionFactor);
		result[2] = ConformAxisValue(src[2], dst[2], distCorrectionFactor);
	}
}