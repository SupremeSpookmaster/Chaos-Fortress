#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <worldtext>

#define SKULLFACE		"cf_skullface"
#define DAGGER			"skullface_poison_dagger"
#define MINE			"skullface_mine"
#define SUPPLIES		"skullface_supplies"
#define ULT				"skullface_ult"
#define ULT_FIRE		"skullface_launch_flare"
#define BANNER			"skullface_banner"

#define PARTICLE_POISON_RED				"healthlost_red"
#define PARTICLE_POISON_BLUE			"healthlost_blu"
#define PARTICLE_DAGGER_POISONED		"merasmus_blood"
#define PARTICLE_MINE_ACTIVE_RED		"cart_flashinglight_glow_red"
#define PARTICLE_MINE_ACTIVE_BLUE		"cart_flashinglight_glow"
#define PARTICLE_MINE_DETONATE			"ExplosionCore_MidAir"
#define PARTICLE_MINE_DESTROYED			"sapper_debris"
#define PARTICLE_SUPPLY_CRATE_DESTROYED		"hammer_impact_button_dust"
#define PARTICLE_SUPPLY_CRATE_DESTROYED_2	"hammer_impact_button_dust2"
#define PARTICLE_PICKUP_HEAL_RED			"healthgained_red_large_2"
#define PARTICLE_PICKUP_HEAL_BLUE			"healthgained_blu_large_2"
#define PARTICLE_SPECIAL_PICKUP_RED			"teleporter_red_exit_level3"
#define PARTICLE_SPECIAL_PICKUP_BLUE		"teleporter_blue_exit_level3"
#define PARTICLE_ULT_FLARES_RED				"spell_fireball_small_red"
#define PARTICLE_ULT_FLARES_BLUE			"spell_fireball_small_blue"
#define PARTICLE_ULT_SMOKE					"smoke_train"//"rocketpack_exhaust_smoke"
#define PARTICLE_ULT_PROJECTILE_RED			"flaregun_trail_crit_red"
#define PARTICLE_ULT_PROJECTILE_BLUE		"flaregun_trail_crit_blue"
#define PARTICLE_ULT_TELEPORT_RED			"teleportedin_red"
#define PARTICLE_ULT_TELEPORT_BLUE			"teleportedin_blue"
#define PARTICLE_ULT_OPEN_RED				"drg_cow_explosioncore_charged"
#define PARTICLE_ULT_OPEN_BLUE				"drg_cow_explosioncore_charged_blue"
#define PARTICLE_SPECIAL_PICKUP_ACTIVATED_RED	"spell_batball_impact_red"
#define PARTICLE_SPECIAL_PICKUP_ACTIVATED_BLUE	"spell_batball_impact_blue"
#define PARTICLE_SPECIAL_PICKUP_BUFFED_RED		"powerup_king_red"
#define PARTICLE_SPECIAL_PICKUP_BUFFED_BLUE		"powerup_king_blue"
#define PARTICLE_BANNER_RED						"utaunt_aestheticlogo_teamcolor_red"
#define PARTICLE_BANNER_BLUE					"utaunt_aestheticlogo_teamcolor_blue"
#define PARTICLE_BANNER_SPAWN					"hammer_impact_button_dust2"

#define SOUND_MINE_EXPLODE					")weapons/explode1.wav"
#define SOUND_MINE_TRIGGERED				")weapons/neon_sign_hit_world_03.wav"
#define SOUND_MINE_ARMED					")ui/cyoa_ping_available.wav"
#define SOUND_MINE_DESTROYED				")physics/concrete/concrete_impact_flare1.wav"
#define SOUND_SUPPLY_CRATE_DESTROYED_LOOT	")ui/itemcrate_smash_ultrarare_short.wav"
#define SOUND_PICKUP_HEAL					"items/smallmedkit1.wav"
#define SOUND_PICKUP_AMMO					"items/gift_pickup.wav"
#define SOUND_ULT_FLARE_FIRED				")weapons/flare_detonator_launch.wav"
#define SOUND_ULT_FLARE_LANDED				")weapons/flare_detonator_explode_world.wav"
#define SOUND_ULT_FLARE_FIZZ				")misc/halloween/hwn_bomb_fuse.wav"
#define SOUND_ULT_CRATE_TELEPORT			")misc/halloween/merasmus_spell.wav"
#define SOUND_ULT_CRATE_SPIN_LOOP			")weapons/teleporter_spin3.wav"
#define SOUND_ULT_CRATE_SPIN_WHOOSH			")misc/halloween/strongman_fast_whoosh_01.wav"
#define SOUND_ULT_CRATE_OPEN				")player/taunt_medic_heroic.wav"
#define SOUND_SPECIAL_PICKUP_ACTIVATED		")items/powerup_pickup_crits.wav"
#define SOUND_SPECIAL_PICKUP_LOOP			")weapons/crit_power.wav"
#define SOUND_BANNER_PULSE					")weapons/recon_ping.wav"
#define SOUND_BANNER_PLANTED				")weapons/fx/rics/arrow_impact_concrete4.wav"
#define SOUND_BANNER_LOOP					")weapons/crit_power.wav"

#define MODEL_MINE						"models/chaos_fortress/skullface/razor_mine.mdl"
#define MODEL_SUPPLY_CRATE				"models/props_junk/wood_crate001a.mdl"
#define MODEL_HEALTH_SMALL				"models/items/medkit_small.mdl"
#define MODEL_HEALTH_MEDIUM				"models/items/medkit_medium.mdl"
#define MODEL_HEALTH_LARGE				"models/items/medkit_large.mdl"
#define MODEL_AMMO_SMALL				"models/items/ammopack_small.mdl"
#define MODEL_AMMO_MEDIUM				"models/items/ammopack_medium.mdl"
#define MODEL_AMMO_LARGE				"models/items/ammopack_large.mdl"
#define MODEL_ULT_PICKUP				"models/chaos_fortress/skullface/skullface_booster.mdl"
#define MODEL_SIGNAL_FLARE				"weapons/w_models/w_flaregun_shell.mdl"
#define MODEL_BANNER					"models/chaos_fortress/skullface/skull_banner_v2.mdl"

static char g_SupplyCrateGibs[][] = {
	"models/props_junk/wood_crate001a_chunk04.mdl",
	"models/props_junk/wood_crate001a_chunk02.mdl",
	"models/props_junk/wood_crate001a_chunk03.mdl",
	"models/props_junk/wood_crate001a_chunk07.mdl",
	"models/props_junk/wood_crate001a_chunk01.mdl"
};

static char g_SupplyCrateBreakSounds[][] = {
	")physics/wood/wood_crate_break1.wav",
	")physics/wood/wood_crate_break2.wav",
	")physics/wood/wood_crate_break3.wav",
	")physics/wood/wood_crate_break4.wav",
	")physics/wood/wood_crate_break5.wav"
};

static char g_SupplyCrateDamageSounds[][] = {
	")physics/wood/wood_crate_impact_hard1.wav",
	")physics/wood/wood_crate_impact_hard2.wav",
	")physics/wood/wood_crate_impact_hard3.wav",
	")physics/wood/wood_crate_impact_hard4.wav",
	")physics/wood/wood_crate_impact_hard5.wav"
};

int laserModel;
int glowModel;

public void OnMapStart()
{
	PrecacheModel(MODEL_MINE);
	PrecacheModel(MODEL_SUPPLY_CRATE);
	PrecacheModel(MODEL_HEALTH_SMALL);
	PrecacheModel(MODEL_HEALTH_MEDIUM);
	PrecacheModel(MODEL_HEALTH_LARGE);
	PrecacheModel(MODEL_AMMO_SMALL);
	PrecacheModel(MODEL_AMMO_MEDIUM);
	PrecacheModel(MODEL_AMMO_LARGE);
	PrecacheModel(MODEL_ULT_PICKUP);
	PrecacheModel(MODEL_SIGNAL_FLARE);
	PrecacheModel(MODEL_BANNER);
	for (int i = 0; i < sizeof(g_SupplyCrateBreakSounds); i++) { PrecacheSound(g_SupplyCrateBreakSounds[i]); }
	for (int i = 0; i < sizeof(g_SupplyCrateDamageSounds); i++) { PrecacheSound(g_SupplyCrateDamageSounds[i]); }

	PrecacheSound(SOUND_MINE_EXPLODE);
	PrecacheSound(SOUND_MINE_TRIGGERED);
	PrecacheSound(SOUND_MINE_ARMED);
	PrecacheSound(SOUND_MINE_DESTROYED);
	PrecacheSound(SOUND_SUPPLY_CRATE_DESTROYED_LOOT);
	PrecacheSound(SOUND_PICKUP_HEAL);
	PrecacheSound(SOUND_PICKUP_AMMO);
	PrecacheSound(SOUND_ULT_FLARE_FIRED);
	PrecacheSound(SOUND_ULT_FLARE_LANDED);
	PrecacheSound(SOUND_ULT_FLARE_FIZZ);
	PrecacheSound(SOUND_ULT_CRATE_TELEPORT);
	PrecacheSound(SOUND_ULT_CRATE_SPIN_LOOP);
	PrecacheSound(SOUND_ULT_CRATE_SPIN_WHOOSH);
	PrecacheSound(SOUND_ULT_CRATE_OPEN);
	PrecacheSound(SOUND_SPECIAL_PICKUP_ACTIVATED);
	PrecacheSound(SOUND_SPECIAL_PICKUP_LOOP);
	PrecacheSound(SOUND_BANNER_PULSE);
	PrecacheSound(SOUND_BANNER_PLANTED);
	PrecacheSound(SOUND_BANNER_LOOP);
	for (int i = 0; i < sizeof(g_SupplyCrateGibs); i++) { PrecacheModel(g_SupplyCrateGibs[i]); }

	glowModel = PrecacheModel("materials/sprites/glow02.vmt");
	laserModel = PrecacheModel("materials/sprites/laser.vmt");
}

public void OnPluginStart()
{
}

bool b_DaggerPoison = false;
bool b_TroddenOnAMine = false;
public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	if (b_DaggerPoison)
	{
		strcopy(console, sizeof(console), "Poison Dagger");
		strcopy(weapon, sizeof(weapon), "mannpower_plague");
		return Plugin_Changed;
	}

	if (b_TroddenOnAMine)
	{
		strcopy(console, sizeof(console), "Razor Mine");
		strcopy(weapon, sizeof(weapon), "sticky_resistance");
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

bool b_DaggerActive[MAXPLAYERS + 1] = { false, ... };

float f_DaggerDMG[MAXPLAYERS + 1] = { 0.0, ... };
float f_DaggerStabCD[MAXPLAYERS + 1] = { 0.0, ... };
float f_DaggerPoisonDMG[MAXPLAYERS + 1] = { 0.0, ... };
float f_DaggerPoisonInterval[MAXPLAYERS + 1] = { 0.0, ... };
float f_DaggerUlt[MAXPLAYERS + 1] = { 0.0, ... };

int i_DaggerPoisonTicks[MAXPLAYERS + 1] = { 0, ... };

public void Dagger_Prepare(int client)
{
	f_DaggerDMG[client] = CF_GetArgF(client, SKULLFACE, DAGGER, "stab_damage", 100.0);
	f_DaggerStabCD[client] = CF_GetArgF(client, SKULLFACE, DAGGER, "stab_cd", 0.0);
	f_DaggerUlt[client] = CF_GetArgF(client, SKULLFACE, DAGGER, "stab_ult", 250.0);
	f_DaggerPoisonDMG[client] = CF_GetArgF(client, SKULLFACE, DAGGER, "poison_damage", 20.0);
	f_DaggerPoisonInterval[client] = CF_GetArgF(client, SKULLFACE, DAGGER, "poison_interval", 1.0);
	i_DaggerPoisonTicks[client] = CF_GetArgI(client, SKULLFACE, DAGGER, "poison_ticks", 5);
}

public void Dagger_ApplyMeleeCooldown(int client, float delay)
{
	int weapon = GetPlayerWeaponSlot(client, 2);
	if (!IsValidEntity(weapon))
		return;

	float gt = GetGameTime();
	float next = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
	if ((next - gt) > delay)
		return;

	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	int melee = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
				
	if (IsValidEntity(viewmodel))
	{
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", gt + delay);
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", gt + delay);
						
		DataPack pack = new DataPack();
		CreateDataTimer(0.1, Dagger_DoMeleeStunSequence, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, EntIndexToEntRef(viewmodel));
		WritePackCell(pack, melee);
	}
}

public Action Dagger_DoMeleeStunSequence(Handle timely, DataPack pack)
{
	ResetPack(pack);
	int viewmodel = EntRefToEntIndex(ReadPackCell(pack));

	if(viewmodel != INVALID_ENT_REFERENCE)
	{
		int animation = 38;
		switch(ReadPackCell(pack))
		{
			case 225, 356, 423, 461, 574, 649, 1071, 30758:  //Your Eternal Reward, Conniver's Kunai, Saxxy, Wanga Prick, Big Earner, Spy-cicle, Golden Frying Pan, Prinny Machete
				animation=12;

			case 638:  //Sharp Dresser
				animation=32;
		}
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}

	return Plugin_Continue;
}

public Action Dagger_DealPoisonDamage(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int attacker = GetClientOfUserId(ReadPackCell(pack));
	int victim = EntRefToEntIndex(ReadPackCell(pack));
	int times = ReadPackCell(pack);
	float dmg = ReadPackFloat(pack);
	float interval = ReadPackFloat(pack);
	
	if (!IsValidEntity(victim) || (IsValidClient(victim) && !IsPlayerAlive(victim)))
		return Plugin_Continue;

	b_DaggerPoison = true;
	SDKHooks_TakeDamage(victim, _, (IsValidClient(attacker) ? attacker : 0), dmg, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
	b_DaggerPoison = false;

	if (IsValidClient(victim))
	{
		float scale = CF_GetCharacterScale(victim);
		TFTeam team = TF2_GetClientTeam(victim);
		CF_AttachParticle(victim, team == TFTeam_Red ? PARTICLE_POISON_RED : PARTICLE_POISON_BLUE, "root", _, 2.0, _, _, scale * 80.0);
	}
	else
	{
		float pos[3];
		CF_WorldSpaceCenter(victim, pos);
		for (int i = 0; i < 3; i++)
			pos[i] += GetRandomFloat(-10.0, 10.0)

		TFTeam team = view_as<TFTeam>(GetEntProp(victim, Prop_Send, "m_iTeamNum"));
		SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_POISON_RED : PARTICLE_POISON_BLUE, 2.0);
	}

	times--;
	bool cont = times > 0;
	if (cont)
		cont = (IsValidClient(victim) ? IsPlayerAlive(victim) : IsValidEntity(victim));

	if (cont)
	{
		DataPack pack2 = new DataPack();
		CreateDataTimer(interval, Dagger_DealPoisonDamage, pack2, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack2, IsValidClient(attacker) ? GetClientUserId(attacker) : -1);
		WritePackCell(pack2, EntIndexToEntRef(victim));
		WritePackCell(pack2, times);
		WritePackFloat(pack2, dmg);
		WritePackFloat(pack2, interval);
	}

	return Plugin_Continue;
}

int i_MineOwner[2048] = { -1, ... };
int i_MineGlow[2048] = { -1, ... };

float f_MineArmTime[2048] = { 0.0, ... };
float f_MineNextThink[2048] = { 0.0, ... };
float f_MineRadius[2048] = { 0.0, ... };

float f_MineDMG[2048] = { 0.0, ... };
float f_MineBlastRadius[2048] = { 0.0, ... };
float f_MineFalloffStart[2048] = { 0.0, ... };
float f_MineFalloffMax[2048] = { 0.0, ... };
float f_MineBleedRadius[2048] = { 0.0, ... };
float f_MineBleedTime[2048] = { 0.0, ... };

float f_NextMineUse[MAXPLAYERS + 1] = { 0.0, ... };

ArrayList g_Mines[MAXPLAYERS + 1] = { null, ... };

public void Mine_Activate(int client, char abilityName[255])
{
	float radius = CF_GetArgF(client, SKULLFACE, abilityName, "detection_radius", 30.0);
	float pos[3], vel[3];
	CF_WorldSpaceCenter(client, pos);
	vel[2] = 300.0;
	int mine = SpawnPhysProp(client, MODEL_MINE, pos, _, vel, GetClientTeam(client) - 2, 1.0, false, _, 1.0, 1.0, true);
	if (IsValidEntity(mine))
	{
		SetEntProp(mine, Prop_Data, "m_takedamage", 1, 1);
		SDKHook(mine, SDKHook_OnTakeDamage, Mine_Damaged);

		float time = CF_GetArgF(client, SKULLFACE, abilityName, "arm_time", 0.8);
		f_MineArmTime[mine] = GetGameTime() + time;
		f_MineRadius[mine] = radius;
		i_MineOwner[mine] = GetClientUserId(client);

		f_MineDMG[mine] = CF_GetArgF(client, SKULLFACE, abilityName, "damage", 120.0);
		f_MineBlastRadius[mine] = CF_GetArgF(client, SKULLFACE, abilityName, "radius", 90.0);
		f_MineFalloffStart[mine] = CF_GetArgF(client, SKULLFACE, abilityName, "falloff_start", 9999.0);
		f_MineFalloffMax[mine] = CF_GetArgF(client, SKULLFACE, abilityName, "falloff_max", 0.0);
		f_MineBleedRadius[mine] = CF_GetArgF(client, SKULLFACE, abilityName, "bleed_radius", 240.0);
		f_MineBleedTime[mine] = CF_GetArgF(client, SKULLFACE, abilityName, "bleed_duration", 6.0);

		DataPack pack = new DataPack();
		CreateDataTimer(time, Mine_Arm, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, EntIndexToEntRef(mine));
		WritePackCell(pack, TF2_GetClientTeam(client));

		Mine_SetGlow(mine, client, false);
		Mine_AddToList(mine, client, CF_GetArgI(client, SKULLFACE, abilityName, "max_mines", 3));

		RequestFrame(Mine_CheckVictims, EntIndexToEntRef(mine));

		f_NextMineUse[client] = GetGameTime() + CF_GetArgF(client, SKULLFACE, abilityName, "cooldown", 2.0);

		CF_PlayRandomSound(client, mine, "sound_mine_extra");
	}
}

public Action Mine_Damaged(int mine, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	int owner = GetClientOfUserId(i_MineOwner[mine]);
	if (!IsValidClient(owner) || CF_IsValidTarget(attacker, grabEnemyTeam(owner)))
		Mine_Destroy(mine);

	damage = 0.0;
	return Plugin_Changed;
}

public void Mine_AddToList(int mine, int client, int maxMines)
{
	if (g_Mines[client] == null)
		g_Mines[client] = CreateArray(32);

	PushArrayCell(g_Mines[client], EntIndexToEntRef(mine));
	if (maxMines > 1)
	{
		while (GetArraySize(g_Mines[client]) > maxMines)
		{
			mine = EntRefToEntIndex(GetArrayCell(g_Mines[client], 0));
			if (IsValidEntity(mine))
				Mine_Destroy(mine);
			else
				RemoveFromArray(g_Mines[client], 0);
		}

		PrintCenterText(client, "Placed %i/%i Razor Mine(s)", GetArraySize(g_Mines[client]), maxMines);
	}
}

public void Mine_RemoveFromList(int mine, int client)
{
	if (g_Mines[client] == null)
		return;

	for (int i = 0; i < GetArraySize(g_Mines[client]); i++)
	{
		int ref = GetArrayCell(g_Mines[client], i);
		if (ref == EntIndexToEntRef(mine))
		{
			RemoveFromArray(g_Mines[client], i);
			break;
		}
	}

	if (GetArraySize(g_Mines[client]) < 1)
	{
		delete g_Mines[client];
		g_Mines[client] = null;
	}
}

public void Mine_DestroyAll(int client)
{
	if (g_Mines[client] == null)
		return;

	for (int i = 0; i < GetArraySize(g_Mines[client]); i++)
	{
		int mine = EntRefToEntIndex(GetArrayCell(g_Mines[client], i));
		if (IsValidEntity(mine))
			Mine_Destroy(mine, true);
	}

	delete g_Mines[client];
	g_Mines[client] = null;
}

public void Mine_DestroyNextFrame(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
		Mine_Destroy(ent);
}

void Mine_Destroy(int mine, bool nextFrame = false)
{
	if (nextFrame)
	{
		RequestFrame(Mine_DestroyNextFrame, EntIndexToEntRef(mine));
		return;
	}

	float pos[3];
	GetEntPropVector(mine, Prop_Send, "m_vecOrigin", pos);
	SpawnParticle(pos, PARTICLE_MINE_DESTROYED, 0.2);
	EmitSoundToAll(SOUND_MINE_DESTROYED, mine);
	RemoveEntity(mine);
}

public void Mine_SetGlow(int mine, int client, bool armed)
{
	int glow = EntRefToEntIndex(i_MineGlow[mine]);
	if (!IsValidEntity(glow))
	{
		glow = TF2_CreateGlow(mine, GetClientTeam(client) - 2);
		if (!IsValidEntity(glow))
			return;

		SetEntityTransmitState(glow, FL_EDICT_FULLCHECK);
		SetEntityOwner(glow, mine);
		SetEntityOwner(mine, client);
		SDKHook(glow, SDKHook_SetTransmit, Mine_GlowTransmit);
	}

	TFTeam team = TF2_GetClientTeam(client);

	if (armed)
	{
		if (team == TFTeam_Red)
			SetVariantColor({255, 160, 160, 255});
		else
			SetVariantColor({160, 160, 255, 255});
	}
	else
	{
		if (team == TFTeam_Red)
			SetVariantColor({255, 220, 220, 200});
		else
			SetVariantColor({220, 220, 255, 200});
	}

	AcceptEntityInput(glow, "SetGlowColor");

	i_MineGlow[mine] = EntIndexToEntRef(glow);
}

public Action Mine_GlowTransmit(int entity, int client)
{
	// kill the glow if the mine or target don't exist
	int mine = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if (mine == INVALID_ENT_REFERENCE)
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
	
	int owner = GetEntPropEnt(mine, Prop_Data, "m_hOwnerEntity");
	if (client != owner)
	{
		// only transmit the outline to the owner
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Mine_Arm(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int mine = EntRefToEntIndex(ReadPackCell(pack));
	TFTeam team = ReadPackCell(pack);

	if (IsValidEntity(mine))
	{
		AttachParticleToEntity(mine, team == TFTeam_Red ? PARTICLE_MINE_ACTIVE_RED : PARTICLE_MINE_ACTIVE_BLUE, "");
		EmitSoundToAll(SOUND_MINE_ARMED, mine);

		int owner = GetClientOfUserId(i_MineOwner[mine]);
		if (IsValidClient(owner))
		{
			Mine_SetGlow(mine, owner, true);
		}
	}

	return Plugin_Continue;
}

public bool Mine_DoNothing(int mine, int owner, int victim) { return false; }

float f_BleedTime;
public void Mine_InflictBleed(int victim, int &attacker, int &inflictor, int &weapon, float &damage)
{
	if (PNPC_IsNPC(victim))
		view_as<PNPC>(victim).Bleed(f_BleedTime, 4.0, attacker);
	else if (IsValidClient(victim))
		TF2_MakeBleed(victim, attacker, f_BleedTime);
}

public bool Mine_OnlyOrganics(int victim, int &attacker, int &inflictor, int &weapon, float &damage) { return !IsABuilding(victim); }

public bool Mine_CheckVictim(int victim) { return IsValidClient(victim) || IsABuilding(victim) || PNPC_IsNPC(victim); }

public void Mine_CheckVictims(int ref)
{
	int mine = EntRefToEntIndex(ref);
	if (!IsValidEntity(mine))
		return;

	int owner = GetClientOfUserId(i_MineOwner[mine]);
	if (!IsValidClient(owner))
	{
		RemoveEntity(mine);
		return;
	}

	float gt = GetGameTime();
	if (gt >= f_MineNextThink[mine] && gt >= f_MineArmTime[mine])
	{
		float pos[3];
		GetEntPropVector(mine, Prop_Send, "m_vecOrigin", pos);

		float dist;
		int victim = CF_GetClosestTarget(pos, true, dist, f_MineRadius[mine], grabEnemyTeam(owner), SKULLFACE, Mine_CheckVictim, true);

		if (IsValidEntity(victim))
		{
			b_TroddenOnAMine = true;
			CF_GenericAOEDamage(owner, mine, 0, f_MineDMG[mine], DMG_BLAST, f_MineBlastRadius[mine], pos, f_MineFalloffStart[mine], f_MineFalloffMax[mine], _, false);
			b_TroddenOnAMine = false;

			f_BleedTime = f_MineBleedTime[mine];
			CF_GenericAOEDamage(owner, mine, 0, 0.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE, f_MineBleedRadius[mine], pos, 0.0, 0.0, _, false, _, SKULLFACE, Mine_OnlyOrganics, SKULLFACE, Mine_InflictBleed);

			SpawnParticle(pos, PARTICLE_MINE_DETONATE, 0.2);
			EmitSoundToAll(SOUND_MINE_EXPLODE, mine, _, _, _, _, GetRandomInt(80, 120));
			EmitSoundToAll(SOUND_MINE_TRIGGERED, mine);
			EmitSoundToClient(owner, SOUND_MINE_TRIGGERED);

			RemoveEntity(mine);

			return;
		}

		f_MineNextThink[mine] = gt + 0.1;
	}

	RequestFrame(Mine_CheckVictims, ref);
}

int Text_Owner[2048] = { -1, ... };
int i_CrateOwner[2048] = { -1, ... };

float f_CrateHP[2048] = { 0.0, ... };
float f_CrateVel[2048] = { 0.0, ... };
float f_CrateHealAmt[2048] = { 0.0, ... };
float f_CrateOverheal[2048] = { 0.0, ... };
float f_CrateHealthLifespan[2048] = { 0.0, ... };
float f_CrateAmmoAmt[2048] = { 0.0, ... };
float f_CrateAmmoLifespan[2048] = { 0.0, ... };
float f_CrateSpecialLifespan[2048] = { 0.0, ... };

float f_PickupHealAmt[2048] = { 0.0, ... };
float f_PickupOverheal[2048] = { 0.0, ... };
float f_PickupAmmoAmt[2048] = { 0.0, ... };

float f_SpecialBuffEndTime[MAXPLAYERS + 1] = { 0.0, ... };

int i_CrateMinHealth[2048] = { 0, ... };
int i_CrateMaxHealth[2048] = { 0, ... };
int i_CrateMinAmmo[2048] = { 0, ... };
int i_CrateMaxAmmo[2048] = { 0, ... };
int i_CrateMinSpecial[2048] = { 0, ... };
int i_CrateMaxSpecial[2048] = { 0, ... };

char s_CrateSpecialConds[2048][255];
char s_CrateSpecialConds_Owner[2048][255];
char s_PickupSpecialConds[2048][255];
char s_PickupSpecialConds_Owner[2048][255];

public void Supplies_Activate(int client, char abilityName[255])
{
	float pos[3], ang[3], vel[3];
	GetClientEyeAngles(client, ang);
	GetVelocityInDirection(ang, CF_GetArgF(client, SKULLFACE, abilityName, "velocity", 800.0), vel);
	CF_WorldSpaceCenter(client, pos);
	pos[2] += 20.0;
	GetPointInDirection(pos, ang, 20.0, pos);
	float durability = CF_GetArgF(client, SKULLFACE, abilityName, "durability", 200.0);
	float lifespan = CF_GetArgF(client, SKULLFACE, abilityName, "lifespan", 9.0);

	int crate = SpawnPhysProp(-1, MODEL_SUPPLY_CRATE, pos, ang, vel, _, durability, false, _, _, _, true);
	if (IsValidEntity(crate))
	{
		Crate_OutlineEntity(crate, TF2_GetClientTeam(client), true);
		SetEntProp(crate, Prop_Data, "m_takedamage", 1, 1);
		SetEntProp(crate, Prop_Send, "m_iTeamNum",  TF2_GetClientTeam(client) == TFTeam_Red ? view_as<int>(TFTeam_Blue) : view_as<int>(TFTeam_Red));
		SDKHook(crate, SDKHook_OnTakeDamage, Supplies_CrateDamaged);

		if (lifespan > 0.0)
			CreateTimer(lifespan, Crate_Expire, EntIndexToEntRef(crate), TIMER_FLAG_NO_MAPCHANGE);

		f_CrateHP[crate] = durability;

		Crate_ReadArgs(crate, client, abilityName);

		i_CrateOwner[crate] = GetClientUserId(client);

		CF_PlayRandomSound(client, crate, "sound_toss_crate");
		CF_ForceGesture(client);
	}
}

int i_UltCrateParticle[2048] = { -1, ... };
float f_UltCrateDelay[2048] = { 0.0, ... };
float f_UltCrateBurstDelay[2048] = { 0.0, ... };

public void Ult_Launch(int client, char abilityName[255])
{
	float vel = CF_GetArgF(client, SKULLFACE, abilityName, "velocity", 1600.0);
	float gravity = CF_GetArgF(client, SKULLFACE, abilityName, "gravity", 0.33);
	int flare = CF_FireGenericRocket(client, 0.0, vel, _, _, SKULLFACE, Ult_OnCollide);
	if (IsValidEntity(flare))
	{
		SetEntityCollisionGroup(flare, 26);
		SetEntityMoveType(flare, MOVETYPE_FLYGRAVITY);
		SetEntityGravity(flare, gravity);

		i_UltCrateParticle[flare] = EntIndexToEntRef(AttachParticleToEntity(flare, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_ULT_PROJECTILE_RED : PARTICLE_ULT_PROJECTILE_BLUE, ""));

		char readAb[255];
		CF_GetArgS(client, SKULLFACE, abilityName, "read_args", readAb, 255);
		Crate_ReadArgs(flare, client, readAb);
		f_UltCrateDelay[flare] = CF_GetArgF(client, SKULLFACE, readAb, "delay", 3.0);
		f_UltCrateBurstDelay[flare] = CF_GetArgF(client, SKULLFACE, readAb, "delay_burst", 2.0);
		i_CrateOwner[flare] = GetClientUserId(client);

		EmitSoundToAll(SOUND_ULT_FLARE_FIRED, flare);
	}
}

public void Ult_Activate(int client, char abilityName[255])
{
	float pos[3], ang[3], vel[3];
	CF_WorldSpaceCenter(client, pos);
	GetClientEyeAngles(client, ang);
	ang[0] = 0.0;
	vel[2] = 300.0;
	int flare = CF_FireGenericRocket(client, 0.0, 0.0, _, _, SKULLFACE, Ult_OnCollide); //SpawnPhysProp(client, MODEL_SUPPLY_CRATE, pos, ang, vel, _, _, _, 0.1, _, _, true);
	if (IsValidEntity(flare))
	{
		SetEntityModel(flare, MODEL_SIGNAL_FLARE);
		char skinChar[16];
		Format(skinChar, 16, "%i", GetClientTeam(client) - 2);
		DispatchKeyValue(flare, "skin", skinChar);
		SetEntityCollisionGroup(flare, 26);
		SetEntityMoveType(flare, MOVETYPE_FLYGRAVITY);
		TeleportEntity(flare, pos, ang, vel);

		SetEntityRenderMode(flare, RENDER_TRANSALPHA);
		SetEntityRenderColor(flare, _, _, _, 0);
		i_UltCrateParticle[flare] = EntIndexToEntRef(AttachParticleToEntity(flare, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_ULT_PROJECTILE_RED : PARTICLE_ULT_PROJECTILE_BLUE, ""));

		Crate_ReadArgs(flare, client, abilityName);
		f_UltCrateDelay[flare] = CF_GetArgF(client, SKULLFACE, abilityName, "delay", 3.0);
		f_UltCrateBurstDelay[flare] = CF_GetArgF(client, SKULLFACE, abilityName, "delay_burst", 2.0);
		i_CrateOwner[flare] = GetClientUserId(client);

		EmitSoundToAll(SOUND_ULT_FLARE_FIRED, flare);
	}
}

public void Ult_RemoveParticle(int ent)
{
	int targ = EntRefToEntIndex(i_UltCrateParticle[ent]);
	if (IsValidEntity(targ))
		RemoveEntity(targ);
}

public void Ult_OnCollide(int flare, int owner, int teamNum, int other, float pos[3])
{
	float ang[3];
	GetEntPropVector(flare, Prop_Send, "m_angRotation", ang);
	ang[0] = 0.0;
	ang[2] = 0.0;

	float pos2[3];
	pos2 = pos;
	pos2[2] += 40.0;
	int crate = SpawnPhysProp(owner, MODEL_SUPPLY_CRATE, pos2, ang, _, _, _, _, _, _, _, true);
	if (!IsValidEntity(crate))
		return;

	Crate_CopyFromOther(crate, flare);

	SetEntityMoveType(crate, MOVETYPE_NONE);
	SetEntityRenderMode(crate, RENDER_TRANSALPHA);
	SetEntityRenderColor(crate, _, _, _, 0);

	TFTeam team = view_as<TFTeam>(GetEntProp(flare, Prop_Send, "m_iTeamNum"));
	int particle = SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_ULT_FLARES_RED : PARTICLE_ULT_FLARES_BLUE, f_UltCrateDelay[crate]);
	if (IsValidEntity(particle))
		EmitSoundToAll(SOUND_ULT_FLARE_FIZZ, particle);
	SpawnParticle(pos, PARTICLE_ULT_SMOKE, f_UltCrateDelay[crate]);

	CreateTimer(f_UltCrateDelay[crate], Ult_TeleportCrate, EntIndexToEntRef(crate), TIMER_FLAG_NO_MAPCHANGE);

	EmitSoundToAll(SOUND_ULT_FLARE_LANDED, flare);
	RemoveEntity(flare);
}

float f_SpinSpeed[2048];
float f_NextWhoosh[2048];
float f_EndTime[2048];
float f_Tilt[2048];
public Action Ult_TeleportCrate(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
	{
		Ult_RemoveParticle(ent);
		
		EmitSoundToAll(SOUND_ULT_CRATE_TELEPORT, ent);
		EmitSoundToAll(SOUND_ULT_CRATE_SPIN_LOOP, ent);
		SetEntityRenderColor(ent, _, _, _, 255);

		f_SpinSpeed[ent] = 12.0;
		f_NextWhoosh[ent] = GetGameTime() + f_UltCrateBurstDelay[ent] * 0.2;
		f_EndTime[ent] = GetGameTime() + f_UltCrateBurstDelay[ent];
		f_Tilt[ent] = 1.0;
		RequestFrame(Ult_Spin, ref);

		TFTeam team = view_as<TFTeam>(GetEntProp(ent, Prop_Send, "m_iTeamNum"));
		Crate_OutlineEntity(ent, team, true);
		float pos[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_ULT_TELEPORT_RED : PARTICLE_ULT_TELEPORT_BLUE, 0.2);

		CreateTimer(f_UltCrateBurstDelay[ent], Ult_BurstCrate, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);

		//TODO: Deal damage and knockback to enemies who are too close
	}

	return Plugin_Continue;
}

public void Ult_Spin(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return;

	float pos[3], ang[3], targPos[3];
	GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	
	targPos = pos;

	if (CF_HasLineOfSight(pos, targPos, _, _, ent))
		targPos[2] += 0.1;

	ang[1] += f_SpinSpeed[ent];
	if (ang[1] > 360.0)
		ang[1] -= 360.0;

	ang[0] = (ang[0] + (ang[0] * f_Tilt[ent] * 0.1)) + (f_SpinSpeed[ent] * 0.05);
	if (fabs(ang[0]) > 45.0)
		f_Tilt[ent] *= -1.0;

	TeleportEntity(ent, targPos, ang);

	float gt = GetGameTime();
	if (gt >= f_NextWhoosh[ent])
	{
		float diff = f_EndTime[ent] - gt;
		int pitch = 80 + RoundFloat((diff / f_UltCrateBurstDelay[ent]) * 60.0);
		EmitSoundToAll(SOUND_ULT_CRATE_SPIN_WHOOSH, ent, _, _, _, _, pitch);
		f_NextWhoosh[ent] = gt + diff * 0.2;
	}

	f_SpinSpeed[ent] += 0.165;
	RequestFrame(Ult_Spin, ref);
}

public Action Ult_BurstCrate(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
	{
		TFTeam team = view_as<TFTeam>(GetEntProp(ent, Prop_Send, "m_iTeamNum"));

		float pos[3];
		CF_WorldSpaceCenter(ent, pos);
		SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_ULT_OPEN_RED : PARTICLE_ULT_OPEN_BLUE, 0.2);
		EmitSoundToAll(SOUND_ULT_CRATE_OPEN, ent);

		Crate_Destroy(ent, true, team);
	}

	return Plugin_Continue;
}

public void Crate_ReadArgs(int crate, int client, char abilityName[255])
{
	f_CrateVel[crate] = CF_GetArgF(client, SKULLFACE, abilityName, "blast_vel", 600.0);
	f_CrateHealAmt[crate] = CF_GetArgF(client, SKULLFACE, abilityName, "health_amt", 0.25);
	f_CrateOverheal[crate] = CF_GetArgF(client, SKULLFACE, abilityName, "health_overheal", 1.0);
	f_CrateHealthLifespan[crate] = CF_GetArgF(client, SKULLFACE, abilityName, "health_lifespan", 9.0);

	f_CrateAmmoAmt[crate] = CF_GetArgF(client, SKULLFACE, abilityName, "ammo_amt", 0.25);
	f_CrateAmmoLifespan[crate] = CF_GetArgF(client, SKULLFACE, abilityName, "ammo_lifespan", 9.0);

	i_CrateMinHealth[crate] = CF_GetArgI(client, SKULLFACE, abilityName, "health_min", 3);
	i_CrateMaxHealth[crate] = CF_GetArgI(client, SKULLFACE, abilityName, "health_max", 4);
	i_CrateMinAmmo[crate] = CF_GetArgI(client, SKULLFACE, abilityName, "ammo_min", 2);
	i_CrateMaxAmmo[crate] = CF_GetArgI(client, SKULLFACE, abilityName, "ammo_max", 4);
	i_CrateMinSpecial[crate] = CF_GetArgI(client, SKULLFACE, abilityName, "booster_min", 0);
	i_CrateMaxSpecial[crate] = CF_GetArgI(client, SKULLFACE, abilityName, "booster_max", 0);
	f_CrateSpecialLifespan[crate] = CF_GetArgF(client, SKULLFACE, abilityName, "booster_lifespan", 12.0);

	CF_GetArgS(client, SKULLFACE, abilityName, "booster_conds", s_CrateSpecialConds[crate], 255);
	CF_GetArgS(client, SKULLFACE, abilityName, "booster_conds_owner", s_CrateSpecialConds_Owner[crate], 255);
}

public void Crate_CopyFromOther(int crate, int other)
{
	f_CrateVel[crate] = f_CrateVel[other];
	f_CrateHealAmt[crate] = f_CrateHealAmt[other];
	f_CrateOverheal[crate] = f_CrateOverheal[other];
	f_CrateHealthLifespan[crate] = f_CrateHealthLifespan[other];

	f_CrateAmmoAmt[crate] = f_CrateAmmoAmt[other];
	f_CrateAmmoLifespan[crate] = f_CrateAmmoLifespan[other];

	i_CrateMinHealth[crate] = i_CrateMinHealth[other];
	i_CrateMaxHealth[crate] = i_CrateMaxHealth[other];
	i_CrateMinAmmo[crate] = i_CrateMinAmmo[other];
	i_CrateMaxAmmo[crate] = i_CrateMaxAmmo[other];

	f_UltCrateDelay[crate] = f_UltCrateDelay[other];
	f_UltCrateBurstDelay[crate] = f_UltCrateBurstDelay[other];
	f_CrateSpecialLifespan[crate] = f_CrateSpecialLifespan[other];

	strcopy(s_CrateSpecialConds[crate], 255, s_CrateSpecialConds[other]);
	strcopy(s_CrateSpecialConds_Owner[crate], 255, s_CrateSpecialConds_Owner[other]);
	i_CrateMinSpecial[crate] = i_CrateMinSpecial[other];
	i_CrateMaxSpecial[crate] = i_CrateMaxSpecial[other];

	i_CrateOwner[crate] = i_CrateOwner[other];
}

void Crate_OutlineEntity(int ent, TFTeam team, bool outline = false)
{
	if (outline)
	{
		int glow = TF2_CreateGlow(ent, 2);
		if (IsValidEntity(glow))
		{
			if (team == TFTeam_Red)
				SetVariantColor({255, 200, 200, 255});
			else
				SetVariantColor({200, 200, 255, 255});

			AcceptEntityInput(glow, "SetGlowColor");
		}
	}
	else
	{
		int r = 255;
		int b = 120;
		if (team == TFTeam_Blue)
		{
			b = 255;
			r = 120;
		}

		SetEntityRenderColor(ent, r, 120, b, 255);
	}
}

public Action Crate_Expire(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
		Crate_Destroy(ent, false, (view_as<TFTeam>(GetEntProp(ent, Prop_Send, "m_iTeamNum")) == TFTeam_Red ? TFTeam_Blue : TFTeam_Red));

	return Plugin_Continue;
}

public void Crate_DealDamage(int crate, float damage)
{
	f_CrateHP[crate] -= damage;
	if (f_CrateHP[crate] <= 0.0)
		Crate_Destroy(crate, true, (view_as<TFTeam>(GetEntProp(crate, Prop_Send, "m_iTeamNum")) == TFTeam_Red ? TFTeam_Blue : TFTeam_Red));
}

public void Crate_Destroy(int crate, bool spawnDrops, TFTeam team)
{
	float pos[3], ang[3], vel[3];
	CF_WorldSpaceCenter(crate, pos);
	int owner = GetClientOfUserId(i_CrateOwner[crate]);

	for (int i = 0; i < sizeof(g_SupplyCrateGibs); i++)
	{
		ang[0] = GetRandomFloat(-60.0, -90.0);
		ang[1] = GetRandomFloat(0.0, 360.0);
		GetVelocityInDirection(ang, 600.0, vel);

		char mod[255];
		Format(mod, sizeof(mod), "%s", g_SupplyCrateGibs[GetRandomInt(0, sizeof(g_SupplyCrateGibs) - 1)]);
		int gib = SpawnPhysProp(0, mod, pos, ang, vel, _, _, _, _, _, _, true);
		if (IsValidEntity(gib))
			MakeEntityFadeOut(gib, 1);
	}

	EmitSoundToAll(g_SupplyCrateBreakSounds[GetRandomInt(0, sizeof(g_SupplyCrateBreakSounds) - 1)], crate, _, _, _, _, GetRandomInt(80, 120));
	SpawnParticle(pos, PARTICLE_SUPPLY_CRATE_DESTROYED, 0.2);
	SpawnParticle(pos, PARTICLE_SUPPLY_CRATE_DESTROYED_2, 0.2);

	if (spawnDrops)
	{
		Crate_SpawnDrops(owner, Crate_HealthPickup, Crate_MedkitPickupFilter, team, 0, i_CrateMinHealth[crate], i_CrateMaxHealth[crate], pos, f_CrateVel[crate], f_CrateHealthLifespan[crate], f_CrateHealAmt[crate], f_CrateOverheal[crate], 0.0, "", "");
		Crate_SpawnDrops(owner, Crate_AmmoPickup, Crate_AmmoPickupFilter, team, 1, i_CrateMinAmmo[crate], i_CrateMaxAmmo[crate], pos, f_CrateVel[crate], f_CrateAmmoLifespan[crate], 0.0, 0.0, f_CrateAmmoAmt[crate], "", "");
		Crate_SpawnDrops(owner, Crate_SpecialPickup, Crate_SpecialPickupFilter, team, 2, i_CrateMinSpecial[crate], i_CrateMaxSpecial[crate], pos, f_CrateVel[crate], f_CrateSpecialLifespan[crate], 0.0, 0.0, 0.0, s_CrateSpecialConds[crate], s_CrateSpecialConds_Owner[crate]);

		EmitSoundToAll(SOUND_SUPPLY_CRATE_DESTROYED_LOOT, crate);
	}
	else
	{
		int text = WorldText_Create(pos, NULL_VECTOR, "Expired!", 25.0, _, _, _, 255, 120, 120, 255);
		if (IsValidEntity(text))
		{
			WorldText_MimicHitNumbers(text);
		}
	}

	RemoveEntity(crate);
}

//Type: 0 for health, 1 for ammo, anything else for the special thing he gives on ult
public void Crate_SpawnDrops(int owner, Function pickupFunction, Function filterFunction, TFTeam team, int type, int min, int max, float pos[3], float force, float lifespan, float healAmt, float overheal, float ammoAmt, char specialConds[255], char specialConds_Owner[255])
{
	char model[255];
	switch(type)
	{
		case 0:
		{
			if (healAmt >= 1.0)
				strcopy(model, sizeof(model), MODEL_HEALTH_LARGE);
			else if (healAmt >= 0.5)
				strcopy(model, sizeof(model), MODEL_HEALTH_MEDIUM);
			else
				strcopy(model, sizeof(model), MODEL_HEALTH_SMALL);
		}
		case 1:
		{
			if (ammoAmt >= 1.0)
				strcopy(model, sizeof(model), MODEL_AMMO_LARGE);
			else if (ammoAmt >= 0.5)
				strcopy(model, sizeof(model), MODEL_AMMO_MEDIUM);
			else
				strcopy(model, sizeof(model), MODEL_AMMO_SMALL);
		}
		default:
		{
			strcopy(model, sizeof(model), MODEL_ULT_PICKUP);
		}
	}

	for (int i = 0; i < GetRandomInt(min, max); i++)
	{
		float ang[3], vel[3];
		ang[0] = GetRandomFloat(-40.0, -90.0);
		ang[1] = GetRandomFloat(0.0, 360.0);
		GetVelocityInDirection(ang, force, vel);

		int pickup = CF_CreatePickup(owner, 60.0, lifespan, pickupFunction, SKULLFACE, pos, _, vel, _, "", "ref", model, _, filterFunction, SKULLFACE);
		if (IsValidEntity(pickup))
		{
			SetEntProp(pickup, Prop_Send, "m_iTeamNum", view_as<int>(team));
			f_PickupHealAmt[pickup] = healAmt;
			f_PickupOverheal[pickup] = overheal;
			f_PickupAmmoAmt[pickup] = ammoAmt;
			strcopy(s_PickupSpecialConds[pickup], 255, specialConds);
			strcopy(s_PickupSpecialConds_Owner[pickup], 255, specialConds_Owner);

			if (type < 0 || type > 1)
			{
				EmitSoundToAll(SOUND_SPECIAL_PICKUP_LOOP, pickup);
				char skinChar[16];
				Format(skinChar, 16, "%i", view_as<int>(team) - 2);
				DispatchKeyValue(pickup, "skin", skinChar);
				//AttachParticleToEntity(pickup, team == TFTeam_Red ? PARTICLE_SPECIAL_PICKUP_RED : PARTICLE_SPECIAL_PICKUP_BLUE, "");
			}
			else
				Crate_OutlineEntity(pickup, team);
		}
	}
}

public bool Crate_MedkitPickupFilter(int owner, int pickup, int user)
{
	if (!Crate_CanEntityGrabThis(user, pickup))
		return false;

	int max = TF2Util_GetEntityMaxHealth(user);
	int current = GetEntProp(user, Prop_Send, "m_iHealth");
	return (current < max);
}

public bool Crate_AmmoPickupFilter(int owner, int pickup, int user)
{
	if (!Crate_CanEntityGrabThis(user, pickup))
		return false;

	for (int i = 0; i < 2; i++)
	{
		int weapon = GetPlayerWeaponSlot(user, i);
		if (!IsValidEntity(weapon))
			continue;

		int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1);
		int currentAmmo = GetAmmo(user, weapon);
		int maxAmmo = TF2Util_GetPlayerMaxAmmo(user, ammoType);
		if (currentAmmo < maxAmmo)
		{
			return true;
		}
	}

	if (CF_GetSpecialResourceIsMetal(user))
	{
		return (CF_GetSpecialResource(user) < CF_GetMaxSpecialResource(user));
	}
	else
	{
		float maxMetal = 200.0 * GetTotalAttributeValue(user, 80, 1.0) * GetTotalAttributeValue(user, 81, 1.0);
		float currentMetal = float(GetEntProp(user, Prop_Data, "m_iAmmo", _, 3));
		if (currentMetal < maxMetal)
			return true;
	}

	return false;
}

public bool Crate_SpecialPickupFilter(int owner, int pickup, int user)
{
	if (!Crate_CanEntityGrabThis(user, pickup))
		return false;

	return GetGameTime() > f_SpecialBuffEndTime[user];
}

public void Crate_HealthPickup(int owner, int pickup, int user)
{
	float pos[3];
	GetEntPropVector(pickup, Prop_Send, "m_vecOrigin", pos);
	SpawnParticle(pos, TF2_GetClientTeam(user) == TFTeam_Red ? PARTICLE_PICKUP_HEAL_RED : PARTICLE_PICKUP_HEAL_BLUE);
	EmitSoundToClient(user, SOUND_PICKUP_HEAL);

	int maxHP = TF2Util_GetEntityMaxHealth(user);
	int amt = RoundFloat((float(maxHP)) * f_PickupHealAmt[pickup]);

	CF_HealPlayer(user, owner, amt, f_PickupOverheal[pickup]);
}

public void Crate_AmmoPickup(int owner, int pickup, int user)
{
	for (int i = 0; i < 2; i++)
	{
		int weapon = GetPlayerWeaponSlot(user, i);
		if (!IsValidEntity(weapon))
			continue;

		int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1);
		int currentAmmo = GetAmmo(user, weapon);
		int maxAmmo = TF2Util_GetPlayerMaxAmmo(user, ammoType);
		if (currentAmmo < maxAmmo)
		{
			currentAmmo += RoundFloat(float(maxAmmo) * f_PickupAmmoAmt[pickup]);
			if (currentAmmo > maxAmmo)
				currentAmmo = maxAmmo;

			SetAmmo(user, weapon, currentAmmo);
		}
	}

	if (CF_GetSpecialResourceIsMetal(user))
	{
		CF_GiveSpecialResource(user, f_PickupAmmoAmt[pickup] * CF_GetMaxSpecialResource(user), CF_ResourceType_Generic);
	}
	else
	{
		float maxMetal = 200.0 * GetTotalAttributeValue(user, 80, 1.0) * GetTotalAttributeValue(user, 81, 1.0);
		float currentMetal = float(GetEntProp(user, Prop_Data, "m_iAmmo", _, 3));
		if (currentMetal < maxMetal)
		{
			currentMetal += f_PickupAmmoAmt[pickup] * maxMetal;
			if (currentMetal > maxMetal)
				currentMetal = maxMetal;

			SetEntProp(user, Prop_Data, "m_iAmmo", RoundToFloor(currentMetal), _, 3);
		}
	}

	EmitSoundToClient(user, SOUND_PICKUP_AMMO);
	if (IsValidClient(owner) && owner != user)
		CF_GiveUltCharge(owner, 50.0);	//TODO: Make this CFG customizable
}

public void Crate_SpecialPickup(int owner, int pickup, int user)
{
	float pos[3];
	GetEntPropVector(pickup, Prop_Send, "m_vecOrigin", pos);
	SpawnParticle(pos, TF2_GetClientTeam(user) == TFTeam_Red ? PARTICLE_SPECIAL_PICKUP_ACTIVATED_RED : PARTICLE_SPECIAL_PICKUP_ACTIVATED_BLUE, 0.2);
	EmitSoundToAll(SOUND_SPECIAL_PICKUP_ACTIVATED, user);

	char conds[32][32];
	char condStr[255];
	strcopy(condStr, 255, (user == owner ? s_PickupSpecialConds_Owner[pickup] : s_PickupSpecialConds[pickup]));
	int num = ExplodeString(condStr, ";", conds, 32, 32);
	
	float longest = 0.0;
	for(int i = 0; i < num; i += 2)
	{
		TFCond cond = view_as<TFCond>(StringToInt(conds[i]));
		if(cond)
		{
			float duration = StringToFloat(conds[i + 1]);
			CF_AddCondition(user, cond, duration, _, true);
			if (duration > longest)
				longest = duration;
		}
	}

	CF_AttachParticle(user, (TF2_GetClientTeam(user) == TFTeam_Red ? PARTICLE_SPECIAL_PICKUP_BUFFED_RED : PARTICLE_SPECIAL_PICKUP_BUFFED_BLUE), "root", true, longest);
	f_SpecialBuffEndTime[user] = GetGameTime() + longest;
}

public bool Crate_CanEntityGrabThis(int user, int pickup)
{
	if (!IsValidClient(user))
		return false;
		
	return (GetClientTeam(user) == GetEntProp(pickup, Prop_Send, "m_iTeamNum"));
}

public Action Supplies_CrateDamaged(int prop, int &attacker, int &inflictor, float &damage, int &damagetype)
{	
	float originalDamage = damage;
	damage = 0.0;
	
	if (GetEntProp(prop, Prop_Send, "m_iTeamNum") == GetEntProp(attacker, Prop_Send, "m_iTeamNum"))
		return Plugin_Changed;
	
	if (IsValidClient(attacker))
	{
		if (originalDamage >= f_CrateHP[prop])
			ClientCommand(attacker, "playgamesound ui/killsound.wav");
		else
		{
			EmitSoundToAll(g_SupplyCrateDamageSounds[GetRandomInt(0, sizeof(g_SupplyCrateDamageSounds) - 1)], prop);
			ClientCommand(attacker, "playgamesound ui/hitsound.wav");
		}
			
		float pos[3];
		CF_WorldSpaceCenter(prop, pos);
		pos[2] += 10.0;
		
		#if defined _worldtext_included_
		char damageDealt[16];
		Format(damageDealt, sizeof(damageDealt), "-%i", RoundToCeil(originalDamage));
		int text = WorldText_Create(pos, NULL_VECTOR, damageDealt, 15.0, _, _, _, 255, 120, 120, 255);
		if (IsValidEntity(text))
		{
			Text_Owner[text] = GetClientUserId(attacker);
			SDKHook(text, SDKHook_SetTransmit, Text_Transmit);
			
			WorldText_MimicHitNumbers(text);
		}
		#endif
	}
	
	Crate_DealDamage(prop, originalDamage);
	
	return Plugin_Changed;
}

float f_BannerEndTime[2048] = { 0.0, ... };
float f_BannerNextRing[2048] = { 0.0, ... };
float f_BannerNextPulse[2048] = { 0.0, ... };
float f_BannerRadius[2048] = { 0.0, ... };
float f_BannerDMGBuff[2048] = { 0.0, ... };
float f_BannerResBuff[2048] = { 0.0, ... };
float f_BannerDMGDebuff[2048] = { 0.0, ... };
float f_BannerResDebuff[2048] = { 0.0, ... };

float f_CurrentBuffEndTime[2048] = { 0.0, ... };
float f_CurrentDebuffEndTime[2048] = { 0.0, ... };
float f_CurrentDMGBuff[2048] = { 0.0, ... };
float f_CurrentResBuff[2048] = { 0.0, ... };
float f_CurrentDMGDebuff[2048] = { 0.0, ... };
float f_CurrentResDebuff[2048] = { 0.0, ... };

int i_BannerOwner[2049] = { -1, ... };
int i_BannerParticle[2049] = { -1, ... };

bool b_ValidBannerOwner[MAXPLAYERS + 1] = { false, ... };

public void Banner_Activate(int client, char abilityName[255])
{
	float duration = CF_GetArgF(client, SKULLFACE, abilityName, "lifespan", 12.0);

	float pos[3], ang[3];
	GetClientAbsOrigin(client, pos);
	GetClientAbsAngles(client, ang);
	ang[2] = 0.0;
	ang[0] = 0.0;
	int banner = SpawnPropDynamic(MODEL_BANNER, pos, ang, _, _, "idle");
	if (IsValidEntity(banner))
	{
		b_ValidBannerOwner[client] = true;
		i_BannerOwner[banner] = GetClientUserId(client);
		f_BannerEndTime[banner] = GetGameTime() + duration;
		f_BannerRadius[banner] = CF_GetArgF(client, SKULLFACE, abilityName, "radius", 300.0);
		f_BannerDMGBuff[banner] = CF_GetArgF(client, SKULLFACE, abilityName, "damage_buff_amt", 0.15);
		f_BannerResBuff[banner] = CF_GetArgF(client, SKULLFACE, abilityName, "res_buff_amt", 0.15);
		f_BannerDMGDebuff[banner] = CF_GetArgF(client, SKULLFACE, abilityName, "damage_penalty_amt", 0.15);
		f_BannerResDebuff[banner] = CF_GetArgF(client, SKULLFACE, abilityName, "res_penalty_amt", 0.15);

		TFTeam team = TF2_GetClientTeam(client);
		i_BannerParticle[banner] = EntIndexToEntRef(SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_BANNER_RED : PARTICLE_BANNER_BLUE));
		SpawnParticle(pos, PARTICLE_BANNER_SPAWN, 2.0);

		EmitSoundToAll(SOUND_BANNER_PLANTED, banner);
		EmitSoundToAll(SOUND_BANNER_LOOP, banner, _, _, _, _, 90);

		CreateTimer(0.1, Banner_Logic, EntIndexToEntRef(banner), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Banner_Logic(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Stop;

	float gt = GetGameTime();
	int owner = GetClientOfUserId(i_BannerOwner[ent]);
	if (gt >= f_BannerEndTime[ent] || !IsValidClient(owner) || !b_ValidBannerOwner[owner])
	{
		int particle = EntRefToEntIndex(i_BannerParticle[ent]);
		if (IsValidEntity(particle))
			RemoveEntity(particle);

		StopSound(ent, SNDCHAN_AUTO, SOUND_BANNER_LOOP);
		MakeEntityFadeOut(ent, 4);
		return Plugin_Stop;
	}

	float pos[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);

	int r = 255;
	int b = 90;
	if (TF2_GetClientTeam(owner) == TFTeam_Blue)
	{
		b = 255;
		r = 90;
	}

	if (gt >= f_BannerNextRing[ent])
	{
		SpawnRing(pos, f_BannerRadius[ent] * 2.0, 0.0, 0.0, 0.0, laserModel, glowModel, r, 90, b, 255, 1, 0.33, 12.0, 0.0, 1);
		f_BannerNextRing[ent] = gt + 0.1;
	}

	if (gt >= f_BannerNextPulse[ent])
	{
		SpawnRing(pos, 0.0, 0.0, 0.0, 0.0, laserModel, glowModel, r, 90, b, 200, 1, 0.33, 9.0, 0.0, 1, f_BannerRadius[ent] * 2.0);
		EmitSoundToAll(SOUND_BANNER_PULSE, ent, _, _, _, _, 80);
		f_BannerNextPulse[ent] = gt + 1.0;
	}

	for (int i = 0; i < 2049; i++)
	{
		if ((!IsABuilding(i) && !PNPC_IsNPC(i) && !IsValidMulti(i)) || !HasEntProp(i, Prop_Send, "m_vecOrigin"))
			continue;

		float theirPos[3];
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", theirPos);
		if (GetVectorDistance(pos, theirPos) <= f_BannerRadius[ent])
		{
			if (CF_IsValidTarget(i, TF2_GetClientTeam(owner)))
			{
				if (gt >= f_CurrentBuffEndTime[i])
				{
					f_CurrentDMGBuff[i] = f_BannerDMGBuff[ent];
					f_CurrentResBuff[i] = f_BannerResBuff[ent];
				}
				else
				{
					if (f_CurrentDMGBuff[i] < f_BannerDMGBuff[ent])
						f_CurrentDMGBuff[i] = f_BannerDMGBuff[ent];

					if (f_CurrentResBuff[i] < f_BannerResBuff[ent])
						f_CurrentResBuff[i] = f_BannerResBuff[ent];
				}

				f_CurrentBuffEndTime[i] = gt + 0.2;
			}
			else if (CF_IsValidTarget(i, grabEnemyTeam(owner)))
			{
				if (gt >= f_CurrentDebuffEndTime[i])
				{
					f_CurrentDMGDebuff[i] = f_BannerDMGDebuff[ent];
					f_CurrentResDebuff[i] = f_BannerResDebuff[ent];
				}
				else
				{
					if (f_CurrentDMGDebuff[i] < f_BannerDMGDebuff[ent])
						f_CurrentDMGDebuff[i] = f_BannerDMGDebuff[ent];

					if (f_CurrentResDebuff[i] < f_BannerResBuff[ent])
						f_CurrentResDebuff[i] = f_BannerResDebuff[ent];
				}

				f_CurrentDebuffEndTime[i] = gt + 0.2;
			}
		}
	}

	return Plugin_Continue;
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	Action ReturnValue = Plugin_Continue;

	float gt = GetGameTime();
	if (gt <= f_CurrentBuffEndTime[attacker])
	{
		damage *= 1.0 + f_CurrentDMGBuff[attacker];
		ReturnValue = Plugin_Changed;
	}

	if (gt <= f_CurrentDebuffEndTime[victim])
	{
		damage *= 1.0 + f_CurrentResDebuff[victim];
		ReturnValue = Plugin_Changed;
	}

	return ReturnValue;
}

public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	Action ReturnValue = Plugin_Continue;

	float gt = GetGameTime();
	if (gt <= f_CurrentBuffEndTime[victim])
	{
		damage *= 1.0 - f_CurrentResBuff[victim];
		ReturnValue = Plugin_Changed;
	}

	if (gt <= f_CurrentDebuffEndTime[attacker])
	{
		damage *= 1.0 - f_CurrentDMGDebuff[attacker];
		ReturnValue = Plugin_Changed;
	}

	return ReturnValue;
}

public void CF_OnCharacterCreated(int client)
{
	b_DaggerActive[client] = CF_HasAbility(client, SKULLFACE, DAGGER);
	if (b_DaggerActive[client])
		Dagger_Prepare(client);
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, SKULLFACE))
		return;

	if (StrContains(abilityName, MINE) != -1)
		Mine_Activate(client, abilityName);

	if (StrContains(abilityName, SUPPLIES) != -1)
		Supplies_Activate(client, abilityName);

	if (StrContains(abilityName, ULT) != -1)
		Ult_Activate(client, abilityName);

	if (StrContains(abilityName, ULT_FIRE) != -1)
		Ult_Launch(client, abilityName);

	if (StrContains(abilityName, BANNER) != -1)
		Banner_Activate(client, abilityName);
}

public void CF_OnCheckCanBackstab(int attacker, int victim, bool &forceStab, bool &result)
{
	if (b_DaggerActive[attacker] && !IsABuilding(victim) && CF_IsValidTarget(victim, grabEnemyTeam(attacker)))
		result = true;
}

public void CF_OnBackstab(int attacker, int victim, float &damage)
{
	if (b_DaggerActive[attacker])
	{
		damage = f_DaggerDMG[attacker];
		CF_PlayRandomSound(attacker, attacker, "sound_backstab_poison");
		CF_GiveUltCharge(attacker, f_DaggerUlt[attacker]);

		float current = float((IsValidClient(victim) ? GetEntProp(victim, Prop_Send, "m_iHealth") : GetEntProp(victim, Prop_Data, "m_iHealth")));
		if (PNPC_IsNPC(victim))
			current = float(view_as<PNPC>(victim).i_Health);
		
		if (damage < current)
		{
			if (f_DaggerStabCD[attacker] > 0.0)
				Dagger_ApplyMeleeCooldown(attacker, f_DaggerStabCD[attacker]);

			if (i_DaggerPoisonTicks[attacker] > 0)
			{
				float pos[3];
				CF_WorldSpaceCenter(victim, pos);
				SpawnParticle(pos, PARTICLE_DAGGER_POISONED, 0.2);

				DataPack pack = new DataPack();
				CreateDataTimer(f_DaggerPoisonInterval[attacker], Dagger_DealPoisonDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
				WritePackCell(pack, GetClientUserId(attacker));
				WritePackCell(pack, EntIndexToEntRef(victim));
				WritePackCell(pack, i_DaggerPoisonTicks[attacker]);
				WritePackFloat(pack, f_DaggerPoisonDMG[attacker]);
				WritePackFloat(pack, f_DaggerPoisonInterval[attacker]);
			}
		}
	}
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	if (reason == CF_CRR_SWITCHED_CHARACTER || reason == CF_CRR_DISCONNECT || reason == CF_CRR_ROUNDSTATE_CHANGED)
	{
		Mine_DestroyAll(client);
		b_ValidBannerOwner[client] = false;
	}

	f_NextMineUse[client] = 0.0;
}

public void OnEntityDestroyed(int entity)
{
	if (entity < 0 || entity > 2047)
		return;

	i_MineGlow[entity] = -1;

	if (i_MineOwner[entity] > 0)
	{
		int owner = GetClientOfUserId(i_MineOwner[entity]);
		if (IsValidClient(owner))
			Mine_RemoveFromList(entity, owner);
	}

	i_MineOwner[entity] = -1;

	Text_Owner[entity] = -1;

	StopSound(entity, SNDCHAN_AUTO, SOUND_ULT_CRATE_SPIN_LOOP);
	StopSound(entity, SNDCHAN_AUTO, SOUND_ULT_FLARE_FIZZ);
	StopSound(entity, SNDCHAN_AUTO, SOUND_SPECIAL_PICKUP_LOOP);
	StopSound(entity, SNDCHAN_AUTO, SOUND_BANNER_LOOP);
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if (!StrEqual(plugin, SKULLFACE))
		return Plugin_Continue;

	if (StrContains(ability, MINE) != -1)
	{
		result = GetGameTime() >= f_NextMineUse[client];
		return Plugin_Changed;
	}

	return Plugin_Continue;
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