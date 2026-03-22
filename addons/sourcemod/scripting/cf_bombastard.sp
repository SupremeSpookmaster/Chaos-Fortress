#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define BOMBASTARD		"cf_bombastard"
#define TRIP			"bombastard_tripmines"
#define STRIKE			"bombastard_ignition_strike"
#define CLUSTER			"bombastard_cluster"
#define BANG			"bombastard_out_with_a_bang"

#define SOUND_GENERIC_EXPLOSION	")weapons/explode1.wav"
#define SOUND_MINE_ARMED		")weapons/medi_shield_burn_03.wav"
#define SOUND_MINE_TRIPPED		")weapons/neon_sign_hit_world_03.wav"
#define SOUND_STRIKE_SWING		")misc/halloween/strongman_fast_whoosh_01.wav"
#define SOUND_STRIKE_HIT		")weapons/cow_mangler_explode.wav"
#define SOUND_STRIKE_HIT_2		")weapons/halloween_boss/knight_axe_hit.wav"
#define SOUND_CLUSTER_LAUNCHED	")misc/halloween/strongman_fast_whoosh_01.wav"
#define SOUND_CLUSTER_BLAST		")weapons/bumper_car_hit_hard.wav"

#define PARTICLE_GENERIC_EXPLOSION	"ExplosionCore_MidAir"
#define PARTICLE_IG_COMBO_1			"mvm_pow_bam"
#define PARTICLE_IG_COMBO_2			"mvm_pow_crack"
#define PARTICLE_IG_COMBO_3			"mvm_pow_caber"
#define PARTICLE_IG_COMBO_4			"mvm_pow_crit"

#define MODEL_CLUSTER_BOMB		"models/weapons/w_models/w_cannonball.mdl"

int Model_TripBeam, Model_TripHalo;
float f_ClusterUnblockedAt[MAXPLAYERS + 1] = { 0.0, ... };

public void OnMapStart()
{
	PrecacheSound(SOUND_GENERIC_EXPLOSION);
	PrecacheSound(SOUND_MINE_ARMED);
	PrecacheSound(SOUND_MINE_TRIPPED);
	PrecacheSound(SOUND_STRIKE_SWING);
	PrecacheSound(SOUND_STRIKE_HIT);
	PrecacheSound(SOUND_STRIKE_HIT_2);
	PrecacheSound(SOUND_CLUSTER_LAUNCHED);
	PrecacheSound(SOUND_CLUSTER_BLAST);

	PrecacheModel(MODEL_CLUSTER_BOMB);

	Model_TripHalo = PrecacheModel("materials/sprites/glow02.vmt");
	Model_TripBeam = PrecacheModel("materials/sprites/laser.vmt");
}

static char VFX_IG_COMBO[][] = {
	PARTICLE_IG_COMBO_1,
	PARTICLE_IG_COMBO_2,
	PARTICLE_IG_COMBO_3,
	PARTICLE_IG_COMBO_4
};

DynamicHook g_DHookGrenadeExplode;
Handle g_DHookPillCollide;

public void OnPluginStart()
{
	GameData gd = LoadGameConfigFile("chaos_fortress");

	g_DHookGrenadeExplode = DHook_CreateVirtual(gd, "CBaseGrenade::Explode");
	if(!g_DHookGrenadeExplode)
		SetFailState("[Gamedata] Could not find CBaseGrenade::Explode");

	g_DHookPillCollide = CheckedDHookCreateFromConf(gd, "CTFGrenadePipebombProjectile::PipebombTouch");

	delete gd;
}

bool b_TripEnabled[MAXPLAYERS + 1] = { false, ... };

float f_TripRange[MAXPLAYERS + 1] = { 0.0, ... };
float f_TripMinRange[MAXPLAYERS + 1] = { 0.0, ... };
float f_TripArmTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_TripAutoMult_Damage[MAXPLAYERS + 1] = { 0.0, ... };
float f_TripAutoMult_Radius[MAXPLAYERS + 1] = { 0.0, ... };
float f_TripArmedAt[2049] = { 0.0, ... };

ArrayList g_TripMines[MAXPLAYERS + 1] = { null, ... };
Handle g_MineScanTimer[MAXPLAYERS + 1] = { null, ... };

public void Trip_Enable(int client)
{
	f_TripRange[client] = CF_GetArgF(client, BOMBASTARD, TRIP, "range", 250.0);
	f_TripMinRange[client] = CF_GetArgF(client, BOMBASTARD, TRIP, "min_range", 60.0);
	f_TripArmTime[client] = CF_GetArgF(client, BOMBASTARD, TRIP, "arm_time", 0.8);
	f_TripAutoMult_Damage[client] = CF_GetArgF(client, BOMBASTARD, TRIP, "damage_multiplier", 2.0);
	f_TripAutoMult_Radius[client] = CF_GetArgF(client, BOMBASTARD, TRIP, "radius_multiplier", 1.0);

	b_TripEnabled[client] = true;
}

public void Trip_DeleteHandles(int client)
{
	delete g_TripMines[client];

	if (g_MineScanTimer[client] != null && g_MineScanTimer[client] != INVALID_HANDLE)
	{
		delete g_MineScanTimer[client];
		g_MineScanTimer[client] = null;
	}
}

public Action Trip_ArmMine(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);

	if (IsValidEntity(ent))
	{
		EmitSoundToAll(SOUND_MINE_ARMED, ent, _, _, _, _, GetRandomInt(90, 110));

		float pos[3];
		CF_WorldSpaceCenter(ent, pos);

		int r = 255;
		int b = 0;
		if (GetEntProp(ent, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue))
		{
			b = 255;
			r = 0;
		}

		SpawnRing(pos, 240.0, 0.0, 0.0, 0.0, Model_TripBeam, Model_TripHalo, r, 120, b, 200, 1, 0.33, 16.0, 0.0, 1, 0.1);
	}

	return Plugin_Continue;
}

public Action Trip_ScanForEnemies(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int cell = ReadPackCell(pack);

	if (!IsValidClient(client) || !b_TripEnabled[client] || g_TripMines[client] == null)
	{
		g_MineScanTimer[cell] = null;

		//I deliberately chose to not delete g_TripMines here because in theory, it *should* get deleted elsewhere in this plugin under any circumstances 
		//which would cause the client to fail the above check. If g_TripMines starts leaking memory, we know where to look, but I doubt it will.

		return Plugin_Stop;
	}

	//Don't bother scanning or trying to connect mines if we only have 1.
	if (GetArraySize(g_TripMines[client]) < 2)
		return Plugin_Continue;

	float gt = GetGameTime();
	for (int i = 0; i < GetArraySize(g_TripMines[client]); i++)
	{
		int mine = EntRefToEntIndex(GetArrayCell(g_TripMines[client], i));

		if (!IsValidEntity(mine) || gt < f_TripArmedAt[mine])
			continue;

		Trip_ConnectToOtherMines(client, mine, gt);
	}

	return Plugin_Continue;
}

public bool Trip_ScanTrace(int entity, int contentsmask, int client)
{
	return CF_IsValidTarget(entity, grabEnemyTeam(client));
}

public void Trip_ConnectToOtherMines(int client, int mine, float gt)
{
	float myPos[3];
	CF_WorldSpaceCenter(mine, myPos);

	for (int i = 0; i < GetArraySize(g_TripMines[client]); i++)
	{
		int other = EntRefToEntIndex(GetArrayCell(g_TripMines[client], i));

		if (!IsValidEntity(other) || other == mine || gt < f_TripArmedAt[other])
			continue;

		float theirPos[3];
		CF_WorldSpaceCenter(other, theirPos);

		if (GetVectorDistance(myPos, theirPos) > f_TripRange[client] || GetVectorDistance(myPos, theirPos) < f_TripMinRange[client])
			continue;

		if (!CF_HasLineOfSight(myPos, theirPos))
			continue;

		Handle trace = TR_TraceRayFilterEx(myPos, theirPos, MASK_SHOT_HULL, RayType_EndPoint, Trip_ScanTrace, client);
		bool hit = TR_DidHit(trace);
		int target = TR_GetEntityIndex(trace);
		delete trace;

		if (hit)
		{
			SpawnParticle(myPos, PARTICLE_GENERIC_EXPLOSION, 0.5);
			SpawnParticle(theirPos, PARTICLE_GENERIC_EXPLOSION, 0.5);

			EmitSoundToAll(SOUND_GENERIC_EXPLOSION, mine, _, _, _, _, GetRandomInt(90, 110));
			EmitSoundToAll(SOUND_GENERIC_EXPLOSION, other, _, _, _, _, GetRandomInt(90, 110));

			if (IsValidEntity(target))
				EmitSoundToAll(SOUND_MINE_TRIPPED, target);
			EmitSoundToClient(client, SOUND_MINE_TRIPPED);

			SpawnBeam(myPos, theirPos, 0.25, TF2_GetClientTeam(client) == TFTeam_Red ? 255 : 200, 200, TF2_GetClientTeam(client) == TFTeam_Blue ? 255 : 200, 255, Model_TripBeam, _, _, _, _, 16.0);

			Trip_DetonateMine(client, mine, myPos, gt);
			Trip_DetonateMine(client, other, theirPos, gt);

			return;
		}
		else
		{
			SpawnBeam(myPos, theirPos, 0.11, TF2_GetClientTeam(client) == TFTeam_Red ? 255 : 80, 80, TF2_GetClientTeam(client) == TFTeam_Blue ? 255 : 80, 255, Model_TripBeam, Model_TripHalo);
		}
	}
}

public void Trip_DetonateMine(int client, int mine, float pos[3], float gt)
{
	float damage = GetEntPropFloat(mine, Prop_Send, "m_flDamage") * f_TripAutoMult_Damage[client];
	float radius = GetEntPropFloat(mine, Prop_Send, "m_DmgRadius") * f_TripAutoMult_Radius[client];
	int weapon = GetEntPropEnt(mine, Prop_Send, "m_hOriginalLauncher");

	CF_GenericAOEDamage(client, mine, (IsValidEntity(weapon) ? weapon : -1), damage, DMG_BLAST|DMG_ALWAYSGIB, radius, pos, radius * 0.65, 0.4);

	RemoveEntity(mine);
	f_TripArmedAt[mine] = gt + 0.5;
}

public void Trip_AddToList(int client, int mine)
{
	if (g_TripMines[client] == null)
	{
		g_TripMines[client] = CreateArray(32);

		DataPack pack = new DataPack();
		g_MineScanTimer[client] = CreateDataTimer(0.1, Trip_ScanForEnemies, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, client);
	}

	PushArrayCell(g_TripMines[client], EntIndexToEntRef(mine));
}

public void Trip_RemoveFromList(int client, int mine)
{
	if (g_TripMines[client] == null)
		return;

	for (int i = 0; i < GetArraySize(g_TripMines[client]); i++)
	{
		int ent = EntRefToEntIndex(GetArrayCell(g_TripMines[client], i));
		if (ent == mine)
		{
			RemoveFromArray(g_TripMines[client], mine);
			
			if (GetArraySize(g_TripMines[client]) == 0)
				Trip_DeleteHandles(client);

			return;
		}
	}
}

public Action Trip_PostSpawn(int pipe)
{
	int client = GetEntPropEnt(pipe, Prop_Send, "m_hOwnerEntity");

	if (!IsValidClient(client) || !b_TripEnabled[client])
		return Plugin_Continue;

	Trip_AddToList(client, pipe);
	f_TripArmedAt[pipe] = GetGameTime() + f_TripArmTime[client];
	CreateTimer(f_TripArmTime[client], Trip_ArmMine, EntIndexToEntRef(pipe), TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

float f_StrikeMeleeMult[MAXPLAYERS + 1] = { 1.0, ... };
float f_StrikeComboMult[MAXPLAYERS + 1] = { 1.0, ... };
float f_StrikeKB[MAXPLAYERS + 1] = { 0.0, ... };
float f_StrikeMarkedMult[2049] = { 1.0, ... };
float f_StrikeSwingTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_StrikeMaxAngle[MAXPLAYERS + 1] = { 0.0, ... };

bool b_StrikeMarked[2049] = { false, ... };

public void Strike_Activate(int client, char ability[255])
{
	f_StrikeMeleeMult[client] = CF_GetArgF(client, BOMBASTARD, ability, "multiplier", 1.272727);
	f_StrikeKB[client] = CF_GetArgF(client, BOMBASTARD, ability, "knockback", 600.0);
	f_StrikeMaxAngle[client] = CF_GetArgF(client, BOMBASTARD, ability, "max_angle", -15.0);
	f_StrikeComboMult[client] = CF_GetArgF(client, BOMBASTARD, ability, "combo_mult", 1.66);

	EmitSoundToAll(SOUND_STRIKE_SWING, client, _, 110);

	SetForceButtonState(client, true, IN_ATTACK);
	SDKHook(client, SDKHook_WeaponCanSwitchTo, Strike_BlockWeaponSwitch);

	f_StrikeSwingTime[client] = GetGameTime() + 0.65;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[]weaponname, bool &result)
{
	f_ClusterUnblockedAt[client] = GetGameTime() + 0.8;

	if (GetGameTime() > f_StrikeSwingTime[client])
		return Plugin_Continue;

	f_StrikeSwingTime[client] = GetGameTime() + 0.6;	//This is 0.6 and the timer is 0.5 on purpose
	CreateTimer(0.5, Strike_UnblockWeaponSwitch, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	SetForceButtonState(client, false, IN_ATTACK);

	return Plugin_Continue;
}

public Action Strike_UnblockWeaponSwitch(Handle timer, int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidMulti(client) && GetGameTime() < f_StrikeSwingTime[client])
	{
		SDKUnhook(client, SDKHook_WeaponCanSwitchTo, Strike_BlockWeaponSwitch);
		f_StrikeSwingTime[client] = 0.0;
	}

	return Plugin_Continue;
}

public Action Strike_BlockWeaponSwitch(int client, int weapon)
{
	if (f_StrikeSwingTime[client] >= GetGameTime())
		return Plugin_Handled;

	return Plugin_Continue;
}

float f_ClusterDMG[2049] = { 0.0, ... };
float f_ClusterRadius[2049] = { 0.0, ... };
float f_ClusterVel[2049] = { 0.0, ... };
float f_ClusterAng[2049] = { 0.0, ... };

int i_ClusterCount[2049] = { 0, ... };

public void Cluster_Activate(int client, char ability[255])
{
	float damage = CF_GetArgF(client, BOMBASTARD, ability, "damage", 200.0);
	float radius = CF_GetArgF(client, BOMBASTARD, ability, "radius", 160.0);
	int bigboy = Core_SpawnGrenade(client, damage, radius, false);
	if (IsValidEntity(bigboy))
	{
		SetEntityModel(bigboy, MODEL_CLUSTER_BOMB);
		DispatchKeyValue(bigboy, "modelscale", "1.5");

		float velocity = CF_GetArgF(client, BOMBASTARD, ability, "throw_velocity", 900.0);
		float upper = CF_GetArgF(client, BOMBASTARD, ability, "throw_uppervel", 200.0);

		float pos[3], ang[3], spawnPos[3], vel[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);
		GetPointInDirection(pos, ang, 20.0, spawnPos);
		CF_HasLineOfSight(pos, spawnPos, _, spawnPos);

		GetVelocityInDirection(ang, velocity, vel);
		vel[2] += upper;

		TeleportEntity(bigboy, pos, ang, vel);

		EmitSoundToAll(SOUND_CLUSTER_LAUNCHED, client);

		g_DHookGrenadeExplode.HookEntity(Hook_Pre, bigboy, Cluster_Explode);

		i_ClusterCount[bigboy] = CF_GetArgI(client, BOMBASTARD, ability, "mini_count", 6);
		f_ClusterDMG[bigboy] = CF_GetArgF(client, BOMBASTARD, ability, "mini_damage", 60.0);
		f_ClusterRadius[bigboy] = CF_GetArgF(client, BOMBASTARD, ability, "mini_radius", 160.0);
		f_ClusterAng[bigboy] = CF_GetArgF(client, BOMBASTARD, ability, "mini_angle", -30.0);
		f_ClusterVel[bigboy] = CF_GetArgF(client, BOMBASTARD, ability, "mini_velocity", 400.0);

		if (CF_GetArgI(client, BOMBASTARD, ability, "use_throw_anim", 1) > 0)
		{
			CF_ForceGesture(client);
			CF_SimulateSpellbookCast(client);
		}
	}
}

public MRESReturn Cluster_Explode(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (!IsValidClient(owner))
		return MRES_Ignored;

	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);

	Core_ShootGrenadeCluster(owner, f_ClusterDMG[entity], f_ClusterRadius[entity], f_ClusterVel[entity], f_ClusterAng[entity], true, i_ClusterCount[entity], MODEL_CLUSTER_BOMB, 0.65, pos);
	EmitSoundToAll(SOUND_CLUSTER_BLAST, entity, _, 120);

	return MRES_Ignored;
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if (!IsValidClient(victim) || !IsValidClient(attacker))
		return Plugin_Continue;

	Action ReturnVal = Plugin_Continue;

	if (GetGameTime() <= f_StrikeSwingTime[attacker] && weapon == GetPlayerWeaponSlot(attacker, 2))
	{
		int pitch = GetRandomInt(90, 110);
		EmitSoundToAll(SOUND_STRIKE_HIT, victim, _, 120, _, 0.8, pitch);
		EmitSoundToAll(SOUND_STRIKE_HIT_2, victim, _, 120, _, _, pitch);
		EmitSoundToAll(SOUND_STRIKE_HIT_2, victim, _, 120, _, _, pitch);

		EmitSoundToClient(attacker, SOUND_STRIKE_HIT, _, _, _, _, 0.8, pitch);
		EmitSoundToClient(attacker, SOUND_STRIKE_HIT_2, _, _, _, _, _, pitch);
		EmitSoundToClient(attacker, SOUND_STRIKE_HIT_2, _, _, _, _, _, pitch);

		CF_PlayRandomSound(attacker, attacker, "sound_ignition_strike_hit");

		SetForceButtonState(attacker, false, IN_ATTACK);
		SDKUnhook(attacker, SDKHook_WeaponCanSwitchTo, Strike_BlockWeaponSwitch);
		f_StrikeSwingTime[attacker] = 0.0;

		float ang[3];
		GetClientEyeAngles(attacker, ang);

		if (ang[0] > f_StrikeMaxAngle[attacker])
			ang[0] = f_StrikeMaxAngle[attacker];

		Core_KnockAndMark(victim, attacker, ang, f_StrikeKB[attacker], f_StrikeComboMult[attacker]);

		damage *= f_StrikeMeleeMult[attacker];
		ReturnVal = Plugin_Changed;
	}

	if (b_StrikeMarked[victim] && weapon != GetPlayerWeaponSlot(attacker, 2))
	{
		damage *= f_StrikeMarkedMult[victim];
		ReturnVal = Plugin_Changed;

		PlayCritVictimSound(victim);
		PlayCritSound(attacker);

		char particle[255];
		strcopy(particle, sizeof(particle), VFX_IG_COMBO[GetRandomInt(0, sizeof(VFX_IG_COMBO) - 1)]);
		SpawnParticle(damagePosition, particle, 2.0);
	}

	return ReturnVal;
}

public void Core_KnockAndMark(int victim, int attacker, float ang[3], float kb, float mult)
{
	CF_ApplyKnockback(victim, kb, ang);

	if (b_StrikeMarked[victim])
	{
		if (mult > f_StrikeMarkedMult[victim])
			f_StrikeMarkedMult[victim] = mult;
	}
	else
	{
		f_StrikeMarkedMult[victim] = mult;
		b_StrikeMarked[victim] = true;
		AttachAura(victim, TF2_GetClientTeam(victim) == TFTeam_Red ? "utaunt_multicurse_teamcolor_red" : "utaunt_multicurse_teamcolor_blue");

		CreateTimer(0.1, Core_CheckGrounded, GetClientUserId(victim), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Core_CheckGrounded(Handle timer, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return Plugin_Stop;

	if (GetEntityFlags(client) & FL_ONGROUND != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
	{
		b_StrikeMarked[client] = false;
		RemoveAura(client, TF2_GetClientTeam(client) == TFTeam_Red ? "utaunt_multicurse_teamcolor_red" : "utaunt_multicurse_teamcolor_blue");
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

int Core_SpawnGrenade(int client, float damage, float radius, bool blockExplosionOnCollide = true)
{
	int grenade = CreateEntityByName("tf_projectile_pipe");
	if (IsValidEntity(grenade))
	{
		int team = GetClientTeam(client);
		SetEntPropEnt(grenade, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(grenade,    Prop_Send, "m_bCritical", 0);
		SetEntProp(grenade,    Prop_Send, "m_iTeamNum",     team, 1);
		SetEntPropFloat(grenade, Prop_Send, "m_flDamage", damage);
		SetEntPropFloat(grenade, Prop_Send, "m_DmgRadius", radius);
		int offs = FindSendPropInfo("CTFGrenadePipebombProjectile", "m_bDefensiveBomb") - 4;
		SetEntDataFloat(grenade, offs, damage);
		SetEntData(grenade, FindSendPropInfo("CTFGrenadePipebombProjectile", "m_nSkin"), (team-2), 1, true);
		
		DispatchSpawn(grenade);

		if (blockExplosionOnCollide)
			DHookEntity(g_DHookPillCollide, false, grenade, _, Core_DoNotExplodeOnCollide);

		return grenade;
	}

	return -1;
}

static MRESReturn Core_DoNotExplodeOnCollide(int self, Handle params) 
{
	return MRES_Supercede;
}

public void Core_ShootGrenadeCluster(int owner, float damage, float radius, float velocity, float shootAng, bool blockExplosionOnCollide, int numToSpawn, char model[255], float scale, float pos[3])
{
	float turnRate = 360.0 / float(numToSpawn);
	float ang[3];
	ang[0] = shootAng;

	char scaleChar[255];
	Format(scaleChar, sizeof(scaleChar), "%f", scale);

	for (int i = 0; i < numToSpawn; i++)
	{
		ang[1] += turnRate;
		int pipe = Core_SpawnGrenade(owner, damage, radius, blockExplosionOnCollide);
		if (IsValidEntity(pipe))
		{
			SetEntityModel(pipe, model);
			DispatchKeyValue(pipe, "modelscale", scaleChar);

			float vel[3];
			GetVelocityInDirection(ang, velocity, vel);
			TeleportEntity(pipe, pos, ang, vel);
		}
	}
}

public void CF_OnCharacterCreated(int client)
{
	if (CF_HasAbility(client, BOMBASTARD, TRIP))
		Trip_Enable(client);
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, BOMBASTARD))
		return;

	if (StrContains(abilityName, STRIKE) != -1)
		Strike_Activate(client, abilityName);

	if (StrContains(abilityName, CLUSTER) != -1)
		Cluster_Activate(client, abilityName);
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if (GetGameTime() < f_StrikeSwingTime[client])
	{
		result = false;
		return Plugin_Changed;
	}

	if (!StrEqual(plugin, BOMBASTARD))
		return Plugin_Continue;

	if (StrContains(ability, CLUSTER) != -1 && GetGameTime() < f_ClusterUnblockedAt[client])
	{
		result = false;
		return Plugin_Changed;
	}

	if (StrContains(ability, STRIKE) != -1)
	{
		int weapon = TF2_GetActiveWeapon(client);
		if (!CanWeaponAttack(client, weapon))
		{
			result = false;
			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

public void My_Ability_Activate(int client, char abilityName[255])
{
}

public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	if (!CF_IsPlayerCharacter(victim) || !CF_HasAbility(victim, BOMBASTARD, BANG))
		return Plugin_Continue;

	int count = CF_GetArgI(victim, BOMBASTARD, BANG, "mini_count", 6);
	float dmg = CF_GetArgF(victim, BOMBASTARD, BANG, "mini_damage", 60.0);
	float rad = CF_GetArgF(victim, BOMBASTARD, BANG, "mini_radius", 160.0);
	float ang = CF_GetArgF(victim, BOMBASTARD, BANG, "mini_angle", -30.0);
	float vel = CF_GetArgF(victim, BOMBASTARD, BANG, "mini_velocity", 400.0);

	float pos[3];
	CF_WorldSpaceCenter(victim, pos);

	Core_ShootGrenadeCluster(victim, dmg, rad, vel, ang, true, count, MODEL_CLUSTER_BOMB, 0.65, pos);

	return Plugin_Continue;
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	//Do not remove tripmines just because we died, otherwise all other reasons for character removal are valid.
	if (reason != CF_CRR_DEATH)
	{
		b_TripEnabled[client] = false;
		Trip_DeleteHandles(client);
	}

	SDKUnhook(client, SDKHook_WeaponCanSwitchTo, Strike_BlockWeaponSwitch);
	SetForceButtonState(client, false, IN_ATTACK);
	f_StrikeSwingTime[client] = 0.0;
	b_StrikeMarked[client] = false;
	RemoveAura(client, TF2_GetClientTeam(client) == TFTeam_Red ? "utaunt_multicurse_teamcolor_red" : "utaunt_multicurse_teamcolor_blue");
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "tf_projectile_pipe_remote"))
	{
		SDKHook(entity, SDKHook_SpawnPost, Trip_PostSpawn);
	}
}

public void OnEntityDestroyed(int entity)
{
	char classname[255];
	GetEntityClassname(entity, classname, 255);

	if (StrEqual(classname, "tf_projectile_pipe_remote"))
	{
		int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (!IsValidClient(client) || !b_TripEnabled[client])
			return;

		Trip_RemoveFromList(client, entity);
	}
}