/**
 * READ THIS IF YOU ARE ARTVIN (or just interested in knowing what this plugin does)
 * 
 * This plugin manages all abilities for the Zeina rework.
 * It ALSO manages the rework to the Barrier effect. 
 * Thus, all of the abilities designed for Barrier - granting allies Barrier, granting yourself Barrier, spawning with additional Barrier, etc - are rewritten in here.
 * Sensal has been changed to use these new Barrier abilities as well.
 */

#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <fakeparticles>
#include <worldtext>

#define EF_BONEMERGE			(1 << 0)

#define ZEINA			"cf_zeina_rework"
#define BULLET			"zeina_barrier_bullet"
#define INFO			"zeina_barrier_visor"
#define BARRIER_SPAWN	"zeina_barrier_spawn"
#define BARRIER_GAIN	"zeina_barrier_gain"
#define REPAIR			"zeina_repair_grenade"
#define WINGS			"zeina_subwings_v2"
#define BLASTER			"zeina_barrier_blast"

#define MODEL_DRG				"models/weapons/w_models/w_drg_ball.mdl"
#define MODEL_BARRIER_BUBBLE	"models/effects/resist_shield/resist_shield.mdl"
#define MODEL_REPAIR_GRENADE	"models/Items/battery.mdl"
#define MODEL_WINGS				"models/zombie_riot/weapons/custom_wings_1_3.mdl"

#define SPR_BULLET_TRAIL_1_RED	"materials/effects/repair_claw_trail_red.vmt"
#define SPR_BULLET_TRAIL_1_BLUE	"materials/effects/repair_claw_trail_blue.vmt"
#define SPR_BULLET_TRAIL_2		"materials/effects/electro_beam.vmt"
#define SPR_BULLET_HEAD			"materials/effects/softglow.vmt"

#define PARTICLE_BULLET_GIVE_BARRIER_RED		"repair_claw_heal_red3"
#define PARTICLE_BULLET_GIVE_BARRIER_BLUE		"repair_claw_heal_blue3"
#define PARTICLE_BULLET_IMPACT_RED				"drg_cow_muzzleflash_normal"
#define PARTICLE_BULLET_IMPACT_BLUE				"drg_cow_muzzleflash_normal_blue"
#define PARTICLE_REPAIR_FIZZLE					"sapper_debris"
#define PARTICLE_WINGS_TAKEOFF					"hammer_impact_button_dust"

#define SOUND_BULLET_IMPACT			")weapons/batsaber_hit_world1.wav"
#define SOUND_GIVE_BARRIER			")weapons/rescue_ranger_charge_02.wav"
#define SOUND_BULLET_BEGIN_HOMING	")buttons/button19.wav"
#define SOUND_BARRIER_BLOCKDAMAGE	")physics/metal/metal_box_impact_bullet1.wav"
#define SOUND_BARRIER_BREAK			")physics/metal/metal_box_break2.wav"
#define SOUND_REPAIR_FIZZLE			")physics/concrete/concrete_impact_flare1.wav"
#define SOUND_REPAIR_PULSE			")weapons/rescue_ranger_charge_02.wav"
#define SOUND_CHARGEUP_INSUFFICIENT	")weapons/rocket_pack_boosters_not_ready.wav"
#define SOUND_CHARGEUP_FULLYCHARGED	")items/powerup_pickup_agility.wav"
#define SOUND_WINGS_TAKEOFF_1		")weapons/rocket_jumper_shoot.wav"
#define SOUND_WINGS_TAKEOFF_2		")weapons/sticky_jumper_explode1.wav"
#define SOUND_WINGS_CHARGEUP_BEGIN		")weapons/rocket_pack_boosters_extend.wav"
#define SOUND_WINGS_CHARGEUP_LOOP			")weapons/rocket_pack_boosters_loop.wav"

#define NOPE						"replay/record_fail.wav"

Handle HudSync;

int glowModel, laserModel, i_RepairGrenadeModelIndex, i_WingsModelIndex;

public void OnMapStart()
{
	PrecacheModel(MODEL_DRG);
	PrecacheModel(MODEL_BARRIER_BUBBLE);
	i_WingsModelIndex = PrecacheModel(MODEL_WINGS);
	i_RepairGrenadeModelIndex = PrecacheModel(MODEL_REPAIR_GRENADE);

	PrecacheSound(SOUND_BULLET_IMPACT);
	PrecacheSound(SOUND_GIVE_BARRIER);
	PrecacheSound(SOUND_BULLET_BEGIN_HOMING);
	PrecacheSound(SOUND_BARRIER_BLOCKDAMAGE);
	PrecacheSound(SOUND_BARRIER_BREAK);
	PrecacheSound(SOUND_REPAIR_FIZZLE);
	PrecacheSound(SOUND_REPAIR_PULSE);
	PrecacheSound(SOUND_CHARGEUP_INSUFFICIENT);
	PrecacheSound(SOUND_CHARGEUP_FULLYCHARGED);
	PrecacheSound(SOUND_WINGS_TAKEOFF_1);
	PrecacheSound(SOUND_WINGS_TAKEOFF_2);
	PrecacheSound(SOUND_WINGS_CHARGEUP_BEGIN);
	PrecacheSound(SOUND_WINGS_CHARGEUP_LOOP);
	PrecacheSound(NOPE);

	PrecacheModel(SPR_BULLET_TRAIL_1_RED);
	PrecacheModel(SPR_BULLET_TRAIL_1_BLUE);
	PrecacheModel(SPR_BULLET_TRAIL_2);
	PrecacheModel(SPR_BULLET_HEAD);

	HudSync = CreateHudSynchronizer();

	glowModel = PrecacheModel("materials/sprites/glow02.vmt");
	laserModel = PrecacheModel("materials/sprites/laser.vmt");
}

public void OnPluginStart()
{
	RegAdminCmd("zeina_givebarrier", Barrier_GiveOnCommand, ADMFLAG_SLAY, "Zeina: gives a flat amount of Barrier to the specified client(s). Used mainly for debugging.");
}

int Text_Owner[2048] = { -1, ... };
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

float f_Barrier[MAXPLAYERS + 1] = { 0.0, ... };
float f_NextBarrierTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_BarrierLostRecently[MAXPLAYERS + 1] = { 0.0, ... };

int i_BarrierWorldText[MAXPLAYERS + 1] = { -1, ... };
int i_BarrierBubble[MAXPLAYERS + 1] = { -1, ... };
int i_BarrierWorldTextOwner[2048] = { -1, ... };

bool b_HasBarrierGoggles[MAXPLAYERS + 1] = { false, ... };
bool b_ChargingWings[MAXPLAYERS + 1] = { false, ... };
bool b_ChargingBlaster[MAXPLAYERS + 1] = { false, ... };
bool b_ChargeRefunding[MAXPLAYERS + 1] = { false, ... };

Handle g_BarrierHUDTimer[MAXPLAYERS + 1] = { null, ... };

int numGoggles = 0;

float f_ChargeAmt[MAXPLAYERS + 1] = { 0.0, ... };
float f_ChargeMin[MAXPLAYERS + 1] = { 0.0, ... };
float f_ChargeMax[MAXPLAYERS + 1] = { 0.0, ... };
float f_ChargeRate[MAXPLAYERS + 1] = { 0.0, ... };
float f_ChargeRefundTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_ChargeBarrierMult[MAXPLAYERS + 1] = { 0.0, ... };
float f_ChargeFailCD[MAXPLAYERS + 1] = { 0.0, ... };

CF_SpeedModifier f_ChargeSpeedMod[MAXPLAYERS + 1] = { null, ... };

bool b_AbilityCharging[MAXPLAYERS + 1] = { false, ... };

public void Charge_StartCharging(int client, char abilityName[255])
{
	if (b_AbilityCharging[client])
		return;

	if (f_ChargeSpeedMod[client].b_Exists)
		f_ChargeSpeedMod[client].Destroy();

	f_ChargeMin[client] = CF_GetArgF(client, ZEINA, abilityName, "min_barrier", 25.0);
	f_ChargeMax[client] = CF_GetArgF(client, ZEINA, abilityName, "max_barrier", 100.0);
	f_ChargeRate[client] = CF_GetArgF(client, ZEINA, abilityName, "charge_rate", 2.5);
	f_ChargeRefundTime[client] = CF_GetArgF(client, ZEINA, abilityName, "refund_duration", 1.0);
	f_ChargeFailCD[client] = CF_GetArgF(client, ZEINA, abilityName, "fail_cd", 4.0);
	f_ChargeBarrierMult[client] = CF_GetArgF(client, ZEINA, abilityName, "barrier_mult", 0.5);

	f_ChargeAmt[client] = 0.0;

	float speedPenalty = CF_GetArgF(client, ZEINA, abilityName, "slow_amt", 240.0);
	if (speedPenalty > 0.0)
		f_ChargeSpeedMod[client] = CF_ApplyTemporarySpeedChange(client, 0, -speedPenalty, 0.0, 0, 0.0, false);

	b_AbilityCharging[client] = true;

	CreateTimer(0.1, Charge_ChargeUp, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Charge_ChargeUp(Handle timer, int id)
{
	int client = GetClientOfUserId(id);

	if (!IsValidMulti(client) || !b_AbilityCharging[client])
		return Plugin_Stop;

	float amt = f_ChargeRate[client];
	if (f_Barrier[client] < amt)
		amt = f_Barrier[client];

	float diff = f_ChargeMax[client] - f_ChargeAmt[client];
	if (diff < amt)
		amt = diff;

	f_ChargeAmt[client] += amt;
	Barrier_RemoveBarrier(client, amt);

	if (f_ChargeAmt[client] >= f_ChargeMax[client])
	{
		EmitSoundToClient(client, SOUND_CHARGEUP_FULLYCHARGED, _, _, 120);
		PrintCenterText(client, "FULLY CHARGED!");
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action Charge_RefundBarrier(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float amt = ReadPackFloat(pack);
	int times = ReadPackCell(pack);

	if (!IsValidMulti(client) || b_AbilityCharging[client] || times < 1 || !b_ChargeRefunding[client])
		return Plugin_Continue;

	Barrier_GiveBarrier(client, client, amt, _, _, _, true, true);

	DataPack pack2 = new DataPack();
	CreateDataTimer(0.1, Charge_RefundBarrier, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, GetClientUserId(client));
	WritePackFloat(pack2, amt);
	WritePackCell(pack2, times - 1);

	return Plugin_Continue;
}

float f_WingsMaxVelocity[MAXPLAYERS + 1] = { 0.0, ... };

int i_WingsWearable[MAXPLAYERS + 1] = { -1, ... };

public void Wings_Activate(int client, char abilityName[255])
{
	Charge_StartCharging(client, abilityName);
	f_WingsMaxVelocity[client] = CF_GetArgF(client, ZEINA, abilityName, "max_velocity", 1200.0);
	b_ChargingWings[client] = true;

	EmitSoundToAll(SOUND_WINGS_CHARGEUP_BEGIN, client);
	EmitSoundToAll(SOUND_WINGS_CHARGEUP_LOOP, client);

	int wings = Wings_Attach(client);
	if (IsValidEntity(wings))
	{
		SetEntPropFloat(wings, Prop_Send, "m_flModelScale", 0.1);
		i_WingsWearable[client] = EntIndexToEntRef(wings);
	}

	DataPack pack = new DataPack();
	RequestFrame(Wings_ChargeFX, pack);
	WritePackCell(pack, GetClientUserId(client));
	WritePackFloat(pack, GetGameTime() + 0.2);
}

void Wings_ChargeFX(DataPack pack)
{
	ResetPack(pack);

	int client = GetClientOfUserId(ReadPackCell(pack));
	float nextRing = ReadPackFloat(pack);

	delete pack;

	if (!IsValidMulti(client) || !b_ChargingWings[client])
		return;

	float percentage = f_ChargeAmt[client] / f_ChargeMax[client];

	float gt = GetGameTime();
	if (gt >= nextRing)
	{
		int weakerColor = RoundFloat(percentage * 180.0);
		int r = 255;
		int b = weakerColor;
		if (TF2_GetClientTeam(client) == TFTeam_Blue)
		{
			r = weakerColor;
			b = 255;
		}

		float pos[3];
		GetClientAbsOrigin(client, pos);
		SpawnRing(pos, 120.0 + (percentage * 80.0), 0.0, 0.0, 0.0, laserModel, glowModel, r, weakerColor, b, weakerColor + 75, 1, 0.3, 4.0 + percentage * 4.0, percentage * 4.0, 1, 1.0);
	
		nextRing = gt + 0.2;
	}

	pack = new DataPack();
	RequestFrame(Wings_ChargeFX, pack);
	WritePackCell(pack, GetClientUserId(client));
	WritePackFloat(pack, nextRing);
}

int Wings_Attach(int client)
{
	int entity = CF_AttachWearable(client, 57, "tf_wearable", true, 0, 0);
	if (IsValidEntity(entity))
	{
		//SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_BONEMERGE);
		SetEntProp(entity, Prop_Send, "m_nModelIndex", i_WingsModelIndex);

		int alpha = (TF2_GetClientTeam(client) == TFTeam_Red ? 3 : 8);
		SetEntityRenderColor(entity, _, _, _, alpha);

		SetVariantInt(1);
		AcceptEntityInput(entity, "SetBodyGroup");
	}

	return entity;
}

public Action Wings_BeginGroundCheck(Handle timer, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return Plugin_Continue;

	int wearable = EntRefToEntIndex(i_WingsWearable[client]);
	if (!IsValidEntity(wearable))
		return Plugin_Continue;

	RequestFrame(Wings_CheckGrounded, id);

	return Plugin_Continue;
}

public void Wings_CheckGrounded(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;

	if (GetEntityFlags(client) & FL_ONGROUND != 0 || GetEntityFlags(client) & FL_INWATER != 0)
	{
		int wearable = EntRefToEntIndex(i_WingsWearable[client]);
		if (IsValidEntity(wearable))
		{
			TF2_RemoveWearable(client, wearable);
			RemoveEntity(wearable);
			i_WingsWearable[client] = -1;
		}
		
		return;
	}

	RequestFrame(Wings_CheckGrounded, id);
}

public void Blaster_Activate(int client, char abilityName[255])
{
	Charge_StartCharging(client, abilityName);
	b_ChargingBlaster[client] = true;

	//TODO: Charge logic is finished, we just need to read the args, add custom charge VFX, and fire the laser on held end. Should take 30-45m tops
}

public Action Barrier_GiveOnCommand(int client, int args)
{
	if (args != 2)
	{
		ReplyToCommand(client, "Usage: zeina_givebarrier <target> <amount> | EXAMPLE: zeina_givebarrier john 100 will give John 100 Barrier.");
		return Plugin_Continue;
	}

	char target[32], amtStr[32];
	GetCmdArg(1, target, 32);
	GetCmdArg(2, amtStr, 32);
	float amt = StringToFloat(amtStr);

	int targets[MAXPLAYERS];
	char targName[MAX_TARGET_LENGTH];
	bool tnml;

	int targCount;
	if ((targCount = ProcessTargetString(target, client, targets, MAXPLAYERS, 0, targName, sizeof(targName), tnml)) <= 0)
	{
		ReplyToTargetError(client, targCount);
		return Plugin_Continue;
	}

	for (int i = 0; i < targCount; i++)
	{
		if (amt > 0.0)
			Barrier_GiveBarrier(targets[i], 0, amt, _, _, _, true);
		else
			Barrier_RemoveBarrier(targets[i], -amt);

		char repl[255];
		Format(repl, sizeof(repl), "%s {yellow}%i{default} Barrier %s {%s}%N{default}.", amt > 0.0 ? "Gave" : "Removed", RoundToFloor(amt), amt > 0.0 ? "to" : "from", TF2_GetClientTeam(targets[i]) == TFTeam_Red ? "red" : "blue", targets[i]);
		CPrintToChat(client, repl);
	}

	return Plugin_Handled;
}

void Barrier_DeleteHUDTimer(int client)
{
	if (g_BarrierHUDTimer[client] != null && g_BarrierHUDTimer[client] != INVALID_HANDLE)
	{
		delete g_BarrierHUDTimer[client];
		g_BarrierHUDTimer[client] = null;
	}
}

void Barrier_CheckSpawn(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;

	if (CF_HasAbility(client, ZEINA, BARRIER_SPAWN))
	{
		float amount = CF_GetArgF(client, ZEINA, BARRIER_SPAWN, "amount", 100.0);
		Barrier_RemoveBarrier(client, amount);
		Barrier_GiveBarrier(client, client, amount, _, _, _, true, true);
	}
}

public Action Barrier_CheckGoggles(Handle timer, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return Plugin_Continue;

	bool goggles = CF_HasAbility(client, ZEINA, INFO);
	if (goggles && numGoggles <= 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidMulti(i))
				continue;

			Barrier_AssignWorldText(i);
		}
	}

	b_HasBarrierGoggles[client] = goggles;
	numGoggles += view_as<int>(goggles);

	return Plugin_Continue;
}

int Barrier_GetWorldText(int client) { return EntRefToEntIndex(i_BarrierWorldText[client]); }
int Barrier_GetBubble(int client) { return EntRefToEntIndex(i_BarrierBubble[client]); }

/**
 * Gives the target some Barrier.
 * 
 * @param target		The client to give Barrier to.
 * @param giver			The client who is providing the Barrier. This player will gain ult charge and resources relative to the amount of Barrier provided, using CF_ResourceType_Healing.
 * @param amount		The amount of Barrier to provide.
 * @param percentage	The maximum percentage of the client's health that the Barrier given by this instance can provide (<= 0.0: no percentage-based limit).
 * 						EX: This is 0.5, the client has 100 max HP. This instance will only fill the user's Barrier up to a max of 50.
 * @param max			Barrier hard-cap (<= 0.0: no hard-cap). If this is 50, this instance will only fill the target's Barrier up to 50.
 * 						Between "percentage" and "max", whichever value results in the lower total max Barrier is chosen.
 * 						EX: "percentage" is 0.5, and the target has 100 max HP, but "max" is equal to 25. This instance will only fill up to 25 Barrier.
 * @param attributes	If true: use "health from healers" bonuses/penalties when calculating the amount of Barrier to provide.
 * 
 * @error	Invalid target.
 * @return	The amount of Barrier given.
 */
float Barrier_GiveBarrier(int target, int giver, float amount, float percentage = 0.0, float max = 0.0, bool attributes = false, bool ignoreCooldown = false, bool noSound = false)
{
	if (GetGameTime() < f_NextBarrierTime[target] && !ignoreCooldown)
		return 0.0;

	if (f_Barrier[target] >= max && max > 0.0)
		return 0.0;

	float maxHP = float(TF2Util_GetEntityMaxHealth(target));
	if (f_Barrier[target] >= maxHP * percentage && percentage > 0.0)
		return 0.0;

	if (attributes)
		amount *= GetTotalAttributeValue(target, 854, 1.0) * GetTotalAttributeValue(target, 69, 1.0) * GetTotalAttributeValue(target, 70, 1.0);

	if (b_AbilityCharging[target])
		amount *= f_ChargeBarrierMult[target];

	f_Barrier[target] += amount;
	float amountGiven = amount;

	float cap = max;
	if (percentage > 0.0 && percentage * maxHP < max)
		cap = percentage * maxHP;

	if (f_Barrier[target] > cap && cap > 0.0)
	{
		float diff = f_Barrier[target] - cap;
		amountGiven -= diff;
		f_Barrier[target] = cap;
	}

	if (amountGiven > 0.0)
	{
		int pitch = GetRandomInt(120, 140);

		if (!noSound)
			EmitSoundToAll(SOUND_GIVE_BARRIER, target, _, 80, _, 0.4, pitch);

		Barrier_Update(target, true);
	
		Event event = CreateEvent("player_healonhit", true);
		event.SetInt("entindex", target);
		event.SetInt("amount", RoundFloat(amountGiven));
		event.Fire();

		if (IsValidClient(giver) && giver != target)
		{
			CF_GiveSpecialResource(giver, amountGiven, CF_ResourceType_Healing);
			CF_GiveUltCharge(giver, amountGiven, CF_ResourceType_Healing);
			CF_GiveHealingPoints(giver, amountGiven);
			
			if (!noSound)
				EmitSoundToClient(giver, SOUND_GIVE_BARRIER, target, _, 80, _, 0.6, pitch);

			float pos[3];
			CF_WorldSpaceCenter(target, pos);
			pos[2] += 40.0 * CF_GetCharacterScale(target);
			
			char barrierText[16];
			Format(barrierText, sizeof(barrierText), "+%i", RoundFloat(amountGiven));
			int text = WorldText_Create(pos, NULL_VECTOR, barrierText, 15.0, _, _, _, 200, 200, 200, 255);
			if (IsValidEntity(text))
			{
				Text_Owner[text] = GetClientUserId(giver);
				SDKHook(text, SDKHook_SetTransmit, Text_Transmit);
				
				WorldText_MimicHitNumbers(text);
			}
		}
	}

	return amountGiven;
}

void Barrier_RemoveBarrier(int target, float amount)
{
	f_Barrier[target] -= amount;

	if (f_Barrier[target] <= 0.0)
	{
		f_Barrier[target] = 0.0;
	}

	Barrier_Update(target, false);
}

public Action Barrier_SecondaryHUD(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int slot = ReadPackCell(pack);

	if (!IsValidMulti(client))
	{
		g_BarrierHUDTimer[slot] = null;
		return Plugin_Stop;
	}

	if (f_Barrier[client] <= 0.0)
	{
		g_BarrierHUDTimer[slot] = null;
		return Plugin_Stop;
	}

	Barrier_DisplayExtraHUD(client);

	return Plugin_Continue;
}

void Barrier_DisplayExtraHUD(int client, bool destroyed = false)
{
	char HUDText[255];
	if (!destroyed)
		Format(HUDText, sizeof(HUDText), "Barrier: %i", RoundToFloor(f_Barrier[client]));
	else
		Format(HUDText, sizeof(HUDText), "Barrier: Destroyed!");

	int r = 255, b = 160;
	if (TF2_GetClientTeam(client) == TFTeam_Blue)
	{
		b = 255;
		r = 160;
	}

	SetHudTextParams(-1.0, 0.15, 1.1, r, 160, b, 255);
	ShowSyncHudText(client, HudSync, HUDText);
}

void Barrier_Update(int client, bool gained)
{
	int text = Barrier_GetWorldText(client);
	int bubble = Barrier_GetBubble(client);

	if (gained)
	{
		if (numGoggles > 0 && !IsValidEntity(text))
			Barrier_AssignWorldText(client);

		if (!IsValidEntity(bubble))
		{
			Barrier_AssignBubble(client);
		}
		else
		{
			int trash, a;
			GetEntityRenderColor(bubble, trash, trash, trash, a);
			a += 60;
			if (a > 255)
				a = 255;
			SetEntityRenderColor(bubble, _, _, _, a);
		}

		if (g_BarrierHUDTimer[client] == null)
		{
			DataPack pack = new DataPack();
			g_BarrierHUDTimer[client] = CreateDataTimer(1.0, Barrier_SecondaryHUD, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, GetClientUserId(client));
			WritePackCell(pack, client);
		}
	}
	else if (f_Barrier[client] <= 0.0)
	{
		if (IsValidEntity(text))
		{
			SetParent(text, text);
			WorldText_MimicHitNumbers(text);
			i_BarrierWorldText[client] = -1;
		}

		if (IsValidEntity(bubble))
		{
			TF2_RemoveWearable(client, bubble);
			RemoveEntity(bubble);
			i_BarrierBubble[client] = -1;
		}
	}

	if (IsValidEntity(text))
	{
		char current[255];
		Format(current, sizeof(current), "%i", RoundToFloor(f_Barrier[client]));
		WorldText_SetMessage(text, current);
	}

	if (f_Barrier[client] > 0.0)
		Barrier_DisplayExtraHUD(client);
}

void Barrier_AssignBubble(int client)
{
	int bubble = CF_AttachWearable(client, 57, "tf_wearable", true, 0, 0, _, "");
	if (IsValidEntity(bubble))
	{
		SetEntProp(bubble, Prop_Send, "m_fEffects", GetEntProp(bubble, Prop_Send, "m_fEffects") &~ EF_BONEMERGE);
		SetEntProp(bubble, Prop_Send, "m_nModelIndex", PrecacheModel(MODEL_BARRIER_BUBBLE));
		SetEntPropFloat(bubble, Prop_Send, "m_flModelScale", CF_GetCharacterScale(client));

		SetEntityRenderMode(bubble, RENDER_TRANSCOLOR);
		i_BarrierBubble[client] = EntIndexToEntRef(bubble);
		SDKHook(bubble, SDKHook_SetTransmit, Barrier_BubbleTransmit);
		RequestFrame(Barrier_ManageBubble, GetClientUserId(client));

		int targetOpacity = Barrier_CalculateTargetOpacity(client);
		SetEntityRenderColor(bubble, _, _, _, targetOpacity);
	}
}

int Barrier_CalculateTargetOpacity(int client)
{
	//Reach max opacity at 400 Barrier:
	int targetOpacity = RoundFloat(160.0 * ((ClampFloat(f_Barrier[client], 0.1, 400.0) / 400.0)));

	if (targetOpacity < 10)
		targetOpacity = 10;

	return targetOpacity;
}

void Barrier_ManageBubble(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;

	int bubble = Barrier_GetBubble(client);
	if (!IsValidEntity(bubble))
		return;

	int targetOpacity = Barrier_CalculateTargetOpacity(client);
		
	int junk, a;
	GetEntityRenderColor(bubble, junk, junk, junk, a);

	if (a != targetOpacity)
	{
		a = RoundFloat(LerpCurve(float(a), float(targetOpacity), 8.0, 16.0));
		SetEntityRenderColor(bubble, _, _, _, a);
	}

	RequestFrame(Barrier_ManageBubble, id);
}

void Barrier_AssignWorldText(int client)
{
	if (f_Barrier[client] <= 0.0 || IsValidEntity(Barrier_GetWorldText(client)))
		return;

	char current[255];
	Format(current, sizeof(current), "%i", RoundToFloor(f_Barrier[client]));

	float pos[3], ang[3];
	CF_WorldSpaceCenter(client, pos);
	pos[2] += 50.0 * CF_GetCharacterScale(client);
	GetClientAbsAngles(client, ang);
			
	int text = WorldText_Create(pos, ang, current, 16.0 * CF_GetCharacterScale(client), _, _, FONT_TF2_BULKY, TF2_GetClientTeam(client) == TFTeam_Red ? 255 : 120, 120, TF2_GetClientTeam(client) == TFTeam_Blue ? 255 : 120, 255);
	if (IsValidEntity(text))
	{
		SetParent(client, text);
		i_BarrierWorldText[client] = EntIndexToEntRef(text);
		i_BarrierWorldTextOwner[text] = GetClientUserId(client);
		
		SetEdictFlags(text, GetEdictFlags(text) &~ FL_EDICT_ALWAYS);
		SDKHook(text, SDKHook_SetTransmit, Barrier_TextTransmit);
	}
}

public Action Barrier_BubbleTransmit(int bubble, int client)
{
	int owner = GetEntPropEnt(bubble, Prop_Send, "m_hOwnerEntity");
	if (IsValidClient(owner) && IsPlayerInvis(owner))
		return Plugin_Handled;

	if (bubble == Barrier_GetBubble(client) && !(GetEntProp(client, Prop_Send, "m_nForceTauntCam") || TF2_IsPlayerInCondition(client, TFCond_Taunting)))
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action Barrier_TextTransmit(int text, int client)
{
	//First: block the transmit for anyone who doesn't have the goggles:
	if (!b_HasBarrierGoggles[client])
		return Plugin_Handled;

	int owner = GetClientOfUserId(i_BarrierWorldTextOwner[text]);
	if (!IsValidClient(owner))
	{
		return Plugin_Handled;
	}

	//Second: block the transmit if the target is invisible and the viewer is an enemy:
	if (IsPlayerInvis(owner) && CF_IsValidTarget(owner, TF2_GetClientTeam(client)))
		return Plugin_Handled;

	//Last: block the transmit if the text belongs to this client, and they are not taunting or in third person:
	if (client == owner && !(GetEntProp(client, Prop_Send, "m_nForceTauntCam") || TF2_IsPlayerInCondition(client, TFCond_Taunting)))
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action Barrier_RemoveFromRecent(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float lost = ReadPackFloat(pack);

	if (IsValidMulti(client))
	{
		f_BarrierLostRecently[client] -= lost;
		if (f_BarrierLostRecently[client] < 0.0)
			f_BarrierLostRecently[client] = 0.0;
	}

	return Plugin_Continue;
}

int Bullet_MagOwner = -1;
int Bullet_User = -1;

int i_BulletTrail[2048] = { -1, ... };

float f_BulletDMG[2048] = { 0.0, ... };
float f_BulletBarrier[2048] = { 0.0, ... };
float f_BulletBarrierPercentage[2048] = { 0.0, ... };
float f_BulletBarrierMax[2048] = { 0.0, ... };
float f_BulletSelfBarrier[2048] = { 0.0, ... };
float f_BulletSelfBarrierPercentage[2048] = { 0.0, ... };
float f_BulletSelfBarrierMax[2048] = { 0.0, ... };

public void Bullet_Activate(int client, char abilityName[255])
{
	float velocity = CF_GetArgF(client, ZEINA, abilityName, "velocity", 1200.0);
	
	int bullet = CF_FireGenericRocket(client, 0.0, velocity, false, true, ZEINA, Bullet_OnImpact);
	if (IsValidEntity(bullet))
	{
		TFTeam team = TF2_GetClientTeam(client);

		SetEntityModel(bullet, MODEL_DRG);
		SetEntityRenderMode(bullet, RENDER_TRANSALPHA);
		SetEntityRenderColor(bullet, _, _, _, 1);

		float pos[3];
		CF_WorldSpaceCenter(bullet, pos);
		pos[2] -= 20.0 * CF_GetCharacterScale(client);
		TeleportEntity(bullet, pos);

		ParticleBody bulletTrail = FPS_CreateParticleBody(pos, NULL_VECTOR);
		int color[3];
		color[0] = 255;
		color[1] = 255;
		color[2] = 255;

		if (team == TFTeam_Red)
			bulletTrail.AddTrail(SPR_BULLET_TRAIL_1_RED, 0.5, 10.0, 0.0, color, 255, RENDER_TRANSALPHA, 3);
		else
			bulletTrail.AddTrail(SPR_BULLET_TRAIL_1_BLUE, 0.5, 10.0, 0.0, color, 255, RENDER_TRANSALPHA, 3);

		color[0] = team == TFTeam_Red ? 255 : 120;
		color[1] = 120;
		color[2] = team == TFTeam_Blue ? 255 : 120;
		bulletTrail.AddSprite(SPR_BULLET_HEAD, 0.05, color, 255, RENDER_TRANSALPHA);

		SetParent(bullet, bulletTrail.Index);
		i_BulletTrail[bullet] = EntIndexToEntRef(bulletTrail.Index);

		float startPos[3], endPos[3], ang[3];
		GetClientEyeAngles(client, ang);
		GetClientEyePosition(client, startPos);
		GetPointInDirection(startPos, ang, 99999.0, endPos);
		CF_HasLineOfSight(startPos, endPos, _, endPos);

		float mins[3];
		mins[0] = -8.0;
		mins[1] = mins[0];
		mins[2] = mins[0];
				
		float maxs[3];
		maxs[0] = -mins[0];
		maxs[1] = -mins[1];
		maxs[2] = -mins[2];
		
		CF_StartLagCompensation(client);
		Bullet_User = client;
		TR_TraceHullFilter(startPos, endPos, mins, maxs, MASK_SHOT, Bullet_OnlyAllies);
		CF_EndLagCompensation(client);

		int target = TR_GetEntityIndex();

		if (IsValidMulti(target))
		{
			Bullet_Magnetize(bullet, target);
		}
		else
		{
			float magRad = CF_GetArgF(client, ZEINA, abilityName, "radius", 60.0);
			if (magRad > 0.0)
			{
				DataPack pack = new DataPack();
				RequestFrame(Bullet_CheckMagnetize, pack);
				WritePackCell(pack, EntIndexToEntRef(bullet));
				WritePackFloat(pack, magRad);
			}

			float spread = CF_GetArgF(client, ZEINA, abilityName, "spread", 3.0);

			if (spread > 0.0)
			{
				float vel[3];
				for (int i = 0; i < 3; i++)
					ang[i] += GetRandomFloat(-spread, spread);

				GetVelocityInDirection(ang, velocity, vel);
				TeleportEntity(bullet, _, ang, vel);
			}
		}

		float lifespan = CF_GetArgF(client, ZEINA, abilityName, "lifespan", 0.65);
		if (lifespan > 0.0)
			CreateTimer(lifespan, Timer_RemoveEntity, EntIndexToEntRef(bullet), TIMER_FLAG_NO_MAPCHANGE);

		f_BulletDMG[bullet] = CF_GetArgF(client, ZEINA, abilityName, "damage", 10.0);

		f_BulletBarrier[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier", 10.0);
		f_BulletBarrierPercentage[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier_percentage", 0.5);
		f_BulletBarrierMax[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier_max", 200.0);

		f_BulletSelfBarrier[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier_self", 5.0);
		f_BulletSelfBarrierPercentage[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier_percentage_self", 0.5);
		f_BulletSelfBarrierMax[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier_max_self", 200.0);
	}
}

public void Bullet_OnImpact(int entity, int owner, int team, int other, float pos[3])
{
	if (IsValidMulti(other, true, true, true, TF2_GetClientTeam(owner)))
	{
		Barrier_GiveBarrier(other, owner, f_BulletBarrier[entity], f_BulletBarrierPercentage[entity], f_BulletBarrierMax[entity]);
		Barrier_GiveBarrier(owner, owner, f_BulletSelfBarrier[entity], f_BulletSelfBarrierPercentage[entity], f_BulletSelfBarrierMax[entity]);

		SpawnParticle(pos, team == 2 ? PARTICLE_BULLET_GIVE_BARRIER_RED : PARTICLE_BULLET_GIVE_BARRIER_BLUE, 0.2);
		RemoveEntity(entity);
		return;
	}
	else if (CF_IsValidTarget(other, grabEnemyTeam(owner)))
	{
		SDKHooks_TakeDamage(other, entity, owner, f_BulletDMG[entity], DMG_BULLET);
	}

	SpawnParticle(pos, team == 2 ? PARTICLE_BULLET_IMPACT_RED : PARTICLE_BULLET_IMPACT_BLUE, 0.2);
	int pitch = GetRandomInt(80, 110);
	EmitSoundToAll(SOUND_BULLET_IMPACT, entity, _, _, _, 0.6, pitch);
	EmitSoundToAll(SOUND_BULLET_IMPACT, entity, _, _, _, 0.6, pitch);

	RemoveEntity(entity);
}

public void Bullet_CheckMagnetize(DataPack pack)
{
	ResetPack(pack);
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float rad = ReadPackFloat(pack);

	if (!IsValidEntity(ent))
	{
		delete pack;
		return;
	}

	float pos[3];
	CF_WorldSpaceCenter(ent, pos);

	TFTeam team = view_as<TFTeam>(GetEntProp(ent, Prop_Send, "m_iTeamNum"));

	Bullet_MagOwner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	int closest = CF_GetClosestTarget(pos, false, _, rad, team, ZEINA, Bullet_DontCountOwner);
	if (IsValidMulti(closest, true, true, true, team))
	{
		Bullet_Magnetize(ent, closest);
		delete pack;
		return;
	}

	RequestFrame(Bullet_CheckMagnetize, pack);
}

public void Bullet_Magnetize(int bullet, int target)
{
	CF_InitiateHomingProjectile(bullet, target, 360.0, 360.0);

	int trail = EntRefToEntIndex(i_BulletTrail[bullet]);
	if (IsValidEntity(trail))
	{
		SetParent(trail, trail);

		int color[3];
		color[0] = 255;
		color[1] = 255;
		color[2] = 255;

		view_as<ParticleBody>(trail).AddTrail(SPR_BULLET_TRAIL_2, 0.5, 10.0, 0.0, color, 255, RENDER_TRANSALPHA, 3);

		SetParent(bullet, trail);
	}

	EmitSoundToAll(SOUND_BULLET_BEGIN_HOMING, bullet, _, _, _, _, GetRandomInt(120, 140));
	EmitSoundToAll(SOUND_BULLET_BEGIN_HOMING, bullet, _, _, _, _, GetRandomInt(120, 140));
}

public bool Bullet_DontCountOwner(int ent) { return ent != Bullet_MagOwner; }

public bool Bullet_OnlyAllies(entity, contentsMask)
{
	return entity != Bullet_User && IsValidMulti(entity, true, true, true, TF2_GetClientTeam(Bullet_User)); 
}

bool b_IsRepairGrenade[2048] = { false, ... };

public void Repair_Activate(int client, char abilityName[255])
{
	float delay = CF_GetArgF(client, ZEINA, abilityName, "delay", 1.0);
	float interval = CF_GetArgF(client, ZEINA, abilityName, "interval", 0.65);
	float repair = CF_GetArgF(client, ZEINA, abilityName, "repair_amt", 0.35);
	float extra = CF_GetArgF(client, ZEINA, abilityName, "extra_amt", 10.0);
	float capRatio = CF_GetArgF(client, ZEINA, abilityName, "cap_percentage", 0.5);
	float capFlat = CF_GetArgF(client, ZEINA, abilityName, "cap_flat", 200.0);
	float duration = CF_GetArgF(client, ZEINA, abilityName, "duration", 5.0);
	float velocity = CF_GetArgF(client, ZEINA, abilityName, "velocity", 800.0);
	float radius = CF_GetArgF(client, ZEINA, abilityName, "radius", 400.0);

	float pos[3], ang[3], vel[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	GetPointInDirection(pos, ang, 30.0, pos);
	GetVelocityInDirection(ang, velocity, vel);

	int grenade = CreateEntityByName("tf_projectile_pipe_remote");
	if (IsValidEntity(grenade))
	{
		SetEntPropEnt(grenade, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(grenade, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"), 1);
		SetEntPropFloat(grenade, Prop_Send, "m_flDamage", 0.0); 
		SetEntPropEnt(grenade, Prop_Send, "m_hThrower", client);
		SetEntPropEnt(grenade, Prop_Send, "m_hOriginalLauncher", 0);
		SetEntProp(grenade, Prop_Send, "m_iType", 1);
		SetEntProp(grenade, Prop_Send, "m_bDefensiveBomb", true);

		for(int i; i < 4; i++)
		{
			SetEntProp(grenade, Prop_Send, "m_nModelIndexOverrides", i_RepairGrenadeModelIndex, _, i);
		}

		DispatchSpawn(grenade);

		for (int vec = 0; vec < 3; vec++)
			ang[vec] = GetRandomFloat(0.0, 360.0);
			
		TeleportEntity(grenade, pos, ang, vel);

		b_IsRepairGrenade[grenade] = true;

		DataPack pack = new DataPack();
		RequestFrame(Repair_Logic, pack);
		WritePackCell(pack, EntIndexToEntRef(grenade));
		WritePackFloat(pack, GetGameTime() + delay + duration);
		WritePackFloat(pack, GetGameTime() + delay + interval);
		WritePackFloat(pack, interval);
		WritePackFloat(pack, repair);
		WritePackFloat(pack, extra);
		WritePackFloat(pack, capRatio);
		WritePackFloat(pack, capFlat);
		WritePackFloat(pack, radius);

		CF_ForceGesture(client);
		CF_SimulateSpellbookCast(client);
	}
}

public void Repair_Logic(DataPack pack)
{
	ResetPack(pack);

	int grenade = EntRefToEntIndex(ReadPackCell(pack));
	float endTime = ReadPackFloat(pack);
	float nextWave = ReadPackFloat(pack);
	float interval = ReadPackFloat(pack);
	float repair = ReadPackFloat(pack);
	float extra = ReadPackFloat(pack);
	float capRatio = ReadPackFloat(pack);
	float capFlat = ReadPackFloat(pack);
	float radius = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(grenade))
		return;

	float gt = GetGameTime();
	int owner = GetEntPropEnt(grenade, Prop_Send, "m_hOwnerEntity");

	if (!IsValidClient(owner) || gt >= endTime)
	{
		Repair_Destroy(grenade, true);
		return;
	}

	if (gt >= nextWave)
	{
		int r = 255;
		int b = 90;
		if (TF2_GetClientTeam(owner) == TFTeam_Blue)
		{
			b = 255;
			r = 90;
		}

		float pos[3];
		CF_WorldSpaceCenter(grenade, pos);

		SpawnRing(pos, 0.0, 0.0, 0.0, 0.0, laserModel, glowModel, r, 90, b, 200, 1, 0.33, 9.0, 0.0, 1, radius * 2.0);
		EmitSoundToAll(SOUND_REPAIR_PULSE, grenade, _, 110, _, _, GetRandomInt(90, 110));

		pos[2] += 20.0;

		for (int i = 1; i <= MAXPLAYERS; i++)
		{
			if (!IsValidMulti(i, _, _, true, TF2_GetClientTeam(owner)))
				continue;

			float theirPos[3];
			GetClientAbsOrigin(i, theirPos);
			theirPos[2] += 20.0;

			if (GetVectorDistance(pos, theirPos) <= radius && CF_HasLineOfSight(pos, theirPos, _, _, grenade))
			{
				float repairAmt = f_BarrierLostRecently[i] * repair;
				Barrier_GiveBarrier(i, owner, repairAmt + extra, capRatio, capFlat, _, true);
			}
		}

		nextWave = gt + interval;
	}

	pack = new DataPack();
	RequestFrame(Repair_Logic, pack);
	WritePackCell(pack, EntIndexToEntRef(grenade));
	WritePackFloat(pack, endTime);
	WritePackFloat(pack, nextWave);
	WritePackFloat(pack, interval);
	WritePackFloat(pack, repair);
	WritePackFloat(pack, extra);
	WritePackFloat(pack, capRatio);
	WritePackFloat(pack, capFlat);
	WritePackFloat(pack, radius);
}

void Repair_Destroy(int grenade, bool remove = false)
{
	float pos[3];
	CF_WorldSpaceCenter(grenade, pos);

	SpawnParticle(pos, PARTICLE_REPAIR_FIZZLE, 0.2);
	EmitSoundToAll(SOUND_REPAIR_FIZZLE, grenade, _, 120, _, _, GetRandomInt(90, 110));

	b_IsRepairGrenade[grenade] = false;
	
	if (remove)
		RemoveEntity(grenade);
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, ZEINA))
		return;
	
	if (StrContains(abilityName, BULLET) != -1)
		Bullet_Activate(client, abilityName);

	if (StrContains(abilityName, REPAIR) != -1)
		Repair_Activate(client, abilityName);

	if (StrContains(abilityName, WINGS) != -1)
		Wings_Activate(client, abilityName);

	if (StrContains(abilityName, BLASTER) != -1)
		Blaster_Activate(client, abilityName);

	if (StrContains(abilityName, BARRIER_GAIN) != -1)
	{
		float amount = CF_GetArgF(client, ZEINA, abilityName, "amount", 250.0);
		float max = CF_GetArgF(client, ZEINA, abilityName, "cap", 600.0);
		Barrier_GiveBarrier(client, client, amount, _, max, _, _, true);
	}
}

public void CF_OnHeldEnd_Ability(int client, bool resupply, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, ZEINA))
		return;

	if (b_AbilityCharging[client])
	{
		b_AbilityCharging[client] = false;
		b_ChargingWings[client] = false;
		b_ChargingBlaster[client] = false;

		StopSound(client, SNDCHAN_AUTO, SOUND_WINGS_CHARGEUP_BEGIN);
		StopSound(client, SNDCHAN_AUTO, SOUND_WINGS_CHARGEUP_LOOP);

		if (f_ChargeSpeedMod[client].b_Exists)
			f_ChargeSpeedMod[client].Destroy();

		if (resupply)
			return;

		if (f_ChargeAmt[client] < f_ChargeMin[client])
		{
			EmitSoundToClient(client, SOUND_CHARGEUP_INSUFFICIENT);
			PrintCenterText(client, "Not enough charge! Refunding Barrier...");

			CF_ApplyAbilityCooldown(client, f_ChargeFailCD[client], CF_GetAbilitySlot(client, ZEINA, abilityName), true);

			b_ChargeRefunding[client] = true;
			DataPack pack = new DataPack();
			CreateDataTimer(0.1, Charge_RefundBarrier, pack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, GetClientUserId(client));
			WritePackFloat(pack, (f_ChargeAmt[client] / f_ChargeRefundTime[client]) * 0.1);
			WritePackCell(pack, RoundFloat(10.0 * f_ChargeRefundTime[client]));

			int wearable = EntRefToEntIndex(i_WingsWearable[client]);
			if (IsValidEntity(wearable))
			{
				TF2_RemoveWearable(client, wearable);
				RemoveEntity(wearable);
				i_WingsWearable[client] = -1;
			}
		}
		else if (StrContains(abilityName, WINGS) != -1)
		{
			float velocity = f_WingsMaxVelocity[client] * (f_ChargeAmt[client] / f_ChargeMax[client]);
			float vel[3], ang[3], pos[3];
			GetClientEyeAngles(client, ang);
			GetVelocityInDirection(ang, velocity, vel);

			if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
				vel[2] = fmax(vel[2], 310.0);

			TeleportEntity(client, _, _, vel);

			GetClientAbsOrigin(client, pos);
			SpawnParticle(pos, PARTICLE_WINGS_TAKEOFF, 0.2);
			EmitSoundToAll(SOUND_WINGS_TAKEOFF_1, client, _, _, _, _, GetRandomInt(90, 110));
			EmitSoundToAll(SOUND_WINGS_TAKEOFF_2, client, _, 120, _, _, GetRandomInt(90, 110));
			CF_PlayRandomSound(client, client, "sound_subwings_takeoff");

			CreateTimer(0.2, Wings_BeginGroundCheck, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if (!StrEqual(plugin, ZEINA))
		return Plugin_Continue;
		
	if (StrContains(ability, BARRIER_GAIN) != -1 && CF_GetArgI(client, ZEINA, ability, "block_if_above_cap", 1) > 0)
	{
		float cap = CF_GetArgF(client, ZEINA, ability, "cap", 600.0);
		result = f_Barrier[client] < cap || cap <= 0.0;
		return Plugin_Changed;
	}

	if (StrContains(ability, WINGS) != -1 || StrContains(ability, BLASTER) != -1)
	{
		if (!b_AbilityCharging[client] && f_Barrier[client] < CF_GetArgF(client, ZEINA, ability, "min_barrier", 50.0))
		{
			result = false;
			return Plugin_Changed;
		}

		if (b_ChargingWings[client] && StrContains(ability, BLASTER) != -1)
		{
			result = false;
			return Plugin_Changed;
		}

		if (b_ChargingBlaster[client] && StrContains(ability, WINGS) != -1)
		{
			result = false;
			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

public void CF_OnCharacterCreated(int client)
{
	Barrier_DeleteHUDTimer(client);
	f_NextBarrierTime[client] = 0.0;
	b_AbilityCharging[client] = false;
	b_ChargingWings[client] = false;
	b_ChargingBlaster[client] = false;
	b_ChargeRefunding[client] = false;

	RequestFrame(Barrier_CheckSpawn, GetClientUserId(client));
	CreateTimer(0.1, Barrier_CheckGoggles, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	if (reason == CF_CRR_DEATH || reason == CF_CRR_DISCONNECT || reason == CF_CRR_ROUNDSTATE_CHANGED || reason == CF_CRR_SWITCHED_CHARACTER)
	{
		Barrier_DeleteHUDTimer(client);
		Barrier_RemoveBarrier(client, f_Barrier[client] + 1.0);
		f_NextBarrierTime[client] = 0.0;
		f_BarrierLostRecently[client] = 0.0;
		b_AbilityCharging[client] = false;
		b_ChargingWings[client] = false;
		b_ChargingBlaster[client] = false;
		b_ChargeRefunding[client] = false;
		
		if (b_HasBarrierGoggles[client])
		{
			b_HasBarrierGoggles[client] = false;
			numGoggles--;

			if (numGoggles <= 0)
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					int text = Barrier_GetWorldText(i);
					if (IsValidEntity(text))
					{
						i_BarrierWorldTextOwner[text] = -1;
						RemoveEntity(text);
					}
					
					i_BarrierWorldText[i] = -1;
				}
			}
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if (entity < 0 || entity > 2048)
		return;

	if (i_BulletTrail[entity] != -1)
	{
		int trail = EntRefToEntIndex(i_BulletTrail[entity]);
		if (IsValidEntity(trail))
		{
			SetParent(trail, trail);
			ParticleBody pBod = view_as<ParticleBody>(trail);
			pBod.Fade_Rate = 8.0;
			pBod.Fading = true;
		}

		i_BulletTrail[entity] = -1;
	}

	i_BarrierWorldTextOwner[entity] = -1;

	if (b_IsRepairGrenade[entity])
		Repair_Destroy(entity);
}

public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
    if (!IsValidClient(victim) || f_Barrier[victim] <= 0.0 || damage <= 0.0 || b_AbilityCharging[victim])
		return Plugin_Continue;

	if (damage >= f_Barrier[victim])
	{
		Barrier_DisplayExtraHUD(victim, true);
		EmitSoundToAll(SOUND_BARRIER_BREAK, victim);

		if (IsValidClient(attacker))
    		EmitSoundToClient(attacker, SOUND_BARRIER_BREAK);

		int bubble = Barrier_GetBubble(victim);
		if (IsValidEntity(bubble))
		{
			SetEntityRenderColor(bubble, _, _, _, 255);
			MakeEntityFadeOut(bubble, 16);
			MakeEntityGraduallyResize(bubble, 1.33 * GetEntPropFloat(bubble, Prop_Send, "m_flModelScale"), 0.25, false);
			i_BarrierBubble[victim] = -1;
		}

		//Prevent victims from gaining Barrier for 2s after their Barrier breaks.
		//This allows Barrier to still fully negate overflow damage (I have 1 Barrier, I will still take 0 damage from a 999999 damage attack), 
		//without making the Barrier Gun monstrously OP by allowing it to make people immortal by constantly spamming +2 Barrier.
		f_NextBarrierTime[victim] = GetGameTime() + 2.0;
	}
	else
	{
		int pitch = 160 - RoundFloat(ClampFloat((f_Barrier[victim] / 400.0) * 100.0, 0.0, 100.0));
		EmitSoundToAll(SOUND_BARRIER_BLOCKDAMAGE, victim, _, _, _, _, pitch);

		if (IsValidClient(attacker))
			EmitSoundToClient(attacker, SOUND_BARRIER_BLOCKDAMAGE, _, _, _, _, _, pitch);

		int bubble = Barrier_GetBubble(victim);
		if (IsValidEntity(bubble))
			SetEntityRenderColor(bubble, _, _, _, 255);
	}

	float removed = damage;
	if (removed > f_Barrier[victim])
		removed = f_Barrier[victim];

	Barrier_RemoveBarrier(victim, removed);

	f_BarrierLostRecently[victim] += removed;
	DataPack pack = new DataPack();
	CreateDataTimer(2.0, Barrier_RemoveFromRecent, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(victim));
	WritePackFloat(pack, removed);

	//Subtract half of the ult charge and resources gained when attacking someone who has Barrier:
	if (IsValidClient(attacker) && attacker != victim)
	{
		CF_GiveUltCharge(attacker, -damage * 0.5, CF_ResourceType_DamageDealt);
		CF_GiveSpecialResource(attacker, -damage * 0.5, CF_ResourceType_DamageDealt);
	}

	//Heal the damage instantly instead of setting it to 0, that way knockback still works:
	CF_HealPlayer(victim, victim, RoundFloat(damage), 999.0, false);

	//Display a HUD notif, to create the illusion that the Barrier blocked the damage.
	Event event = CreateEvent("player_healonhit", true);
	event.SetInt("entindex", victim);
	event.SetInt("amount", -RoundFloat(damage));
	event.Fire();

	//damage = 0.0;

	return Plugin_Changed;
}

public void CF_OnHUDDisplayed(int client, char HUDText[255], int &r, int &g, int &b, int &a)
{
	//Ugly ass hack but I really don't care
	if (b_AbilityCharging[client])
	{
		char text[255];
		Format(text, sizeof(text), "[%i[PERCENT] CHARGED] Sub Wings", RoundFloat(100.0 * (f_ChargeAmt[client] / f_ChargeMax[client])));
		ReplaceString(HUDText, 255, "[ACTIVE] Sub Wings", text);

		Format(text, sizeof(text), "[%i[PERCENT] CHARGED] Barrier Blaster", RoundFloat(100.0 * (f_ChargeAmt[client] / f_ChargeMax[client])));
		ReplaceString(HUDText, 255, "[ACTIVE] Barrier Blaster", text);
	}

	/*if (f_Barrier[client] > 0.0)
	{
		Format(HUDText, sizeof(HUDText), "BARRIER: %i\n%s", RoundFloat(f_Barrier[client]), HUDText);
	}*/
}