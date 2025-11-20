#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define LAW                           "cf_law"
#define SHIELD                        "law_riot_shield"
#define PROTECT                       "law_protective_custody"
#define CHAIN                         "law_arrest"
#define RIOT                          "law_riot_control"

#define SOUND_SHIELD_TAKEDAMAGE       ")weapons/fx/rics/ric1.wav"
#define SOUND_SHIELD_STAGEBREAK       ")chaos_fortress/law/riotshield_damaged.mp3"
#define SOUND_SHIELD_FULLBREAK        ")chaos_fortress/law/riotshield_break.mp3"
#define SOUND_PROTECT_ADD             ")npc/roller/remote_yes.wav"
#define SOUND_PROTECT_REMOVE          ")npc/roller/code2.wav"
#define SOUND_PROTECT_BLOCKDAMAGE     ")physics/metal/metal_box_impact_bullet1.wav"
#define SOUND_CHAIN_REEL_LOOP         ")physics/metal/metal_chainlink_scrape_rough_loop1.wav"
#define SOUND_CHAIN_THROW             ")doors/door_chainlink_move1.wav"
#define SOUND_CHAIN_YANK              ")doors/door_chainlink_close2.wav"
#define SOUND_CHAIN_BREAK_1           ")doors/heavy_metal_stop1.wav"
#define SOUND_CHAIN_BREAK_2           ")physics/glass/glass_largesheet_break3.wav"
#define SOUND_RIOT_CONTROL_POWER_DOWN ")weapons/physcannon/physcannon_tooheavy.wav"
#define SOUND_SHIELD_KB_1             ")weapons/bumper_car_hit_ball.wav"
#define SOUND_SHIELD_KB_2             ")weapons/metal_gloves_hit_flesh1.wav"

#define MODEL_SHIELD                  "models/chaos_fortress/law/riot_shield_fixed.mdl"
#define MODEL_POLICELINE              "materials/chaos_fortress/law/police_line.vmt"
#define MODEL_CHAIN                   "materials/chaos_fortress/law/chain.vmt"
#define MODEL_DRG                     "models/weapons/w_models/w_drg_ball.mdl"

#define PARTICLE_CHAIN_RED            "spell_teleport_red"
#define PARTICLE_CHAIN_BLUE           "spell_teleport_blue"
#define PARTICLE_SHIELD_SPAWN_RED     "teleportedin_red"
#define PARTICLE_SHIELD_SPAWN_BLUE    "teleportedin_blue"
#define PARTICLE_SHIELD_KB_RED        "vaccinator_red_buff1_burst"
#define PARTICLE_SHIELD_KB_BLUE       "vaccinator_blue_buff1_burst"

int         Flash_BaseMainColor      = 255;
int         Flash_BaseSecondaryColor = 120;
int         Flash_BaseAlpha          = 90;
int         Flash_MaxMainColor       = 255;
int         Flash_MaxSecondaryColor  = 200;
int         Flash_MaxAlpha           = 200;
int         Flash_MainDecay          = 6;
int         Flash_SecondaryDecay     = 4;
int         Flash_AlphaDecay         = 6;

static char g_ChainDamagedSounds[][] = {
    ")physics/metal/metal_chainlink_impact_hard1.wav",
    ")physics/metal/metal_chainlink_impact_hard2.wav",
    ")physics/metal/metal_chainlink_impact_hard3.wav"
};

static char g_ChainAttachSounds[][] = {
    ")physics/metal/sawblade_stick1.wav",
    ")physics/metal/sawblade_stick2.wav",
    ")physics/metal/sawblade_stick3.wav",
}

public void
    OnMapStart()
{
    PrecacheSound(SOUND_SHIELD_TAKEDAMAGE);
    PrecacheSound(SOUND_SHIELD_STAGEBREAK);
    PrecacheSound(SOUND_SHIELD_FULLBREAK);
    PrecacheSound(SOUND_PROTECT_ADD);
    PrecacheSound(SOUND_PROTECT_REMOVE);
    PrecacheSound(SOUND_PROTECT_BLOCKDAMAGE);
    PrecacheSound(SOUND_CHAIN_REEL_LOOP);
    PrecacheSound(SOUND_CHAIN_BREAK_1);
    PrecacheSound(SOUND_CHAIN_BREAK_2);
    PrecacheSound(SOUND_CHAIN_YANK);
    PrecacheSound(SOUND_CHAIN_THROW);
    PrecacheSound(SOUND_RIOT_CONTROL_POWER_DOWN);
    PrecacheSound(SOUND_SHIELD_KB_1);
    PrecacheSound(SOUND_SHIELD_KB_2);

    PrecacheModel(MODEL_SHIELD);
    PrecacheModel(MODEL_DRG);
    PrecacheModel(MODEL_POLICELINE);
    PrecacheModel(MODEL_CHAIN);

    for (int i = 0; i < sizeof(g_ChainDamagedSounds); i++)
    {
        PrecacheSound(g_ChainDamagedSounds[i]);
    }

    for (int i = 0; i < sizeof(g_ChainAttachSounds); i++)
    {
        PrecacheSound(g_ChainAttachSounds[i]);
    }
}

public void OnPluginStart()
{
}

float            f_ShieldMaxHealth[MAXPLAYERS + 1]         = { 0.0, ... };
float            f_ShieldMyMaxHealth[2049]                 = { 0.0, ... };
float            f_ShieldHealth[MAXPLAYERS + 1]            = { 0.0, ... };
float            f_ShieldMyHealth[2049]                    = { 0.0, ... };
float            f_ShieldScale[MAXPLAYERS + 1]             = { 0.0, ... };
float            f_ShieldDistance[MAXPLAYERS + 1]          = { 0.0, ... };
float            f_ShieldHeight[MAXPLAYERS + 1]            = { 0.0, ... };
float            f_ShieldSpeedPenalty[MAXPLAYERS + 1]      = { 0.0, ... };
float            f_ShieldAtkSpeed[MAXPLAYERS + 1]          = { 0.0, ... };
float            f_ShieldRegen[MAXPLAYERS + 1]             = { 0.0, ... };
float            f_ShieldRegenDelay[MAXPLAYERS + 1]        = { 0.0, ... };
float            f_ShieldRegenDelay_Broken[MAXPLAYERS + 1] = { 0.0, ... };
float            f_ShieldDeployTime[MAXPLAYERS + 1]        = { 0.0, ... };
float            f_ShieldOldPercentage[2048]               = { 0.0, ... };
float            f_ShieldHurtAnimEndTime[2048]             = { 0.0, ... };
float            f_ShieldMyScale[2048]                     = { 0.0, ... };
float            f_ShieldMyDeployTime[2048]                = { 0.0, ... };
float            f_RiotShieldDamage[2048]                  = { 0.0, ... };
float            f_RiotShieldKB[2048]                      = { 0.0, ... };
float            f_ShieldDamage[2048]                      = { 0.0, ... };
float            f_ShieldKB[2048]                          = { 0.0, ... };
float            f_NextShieldHit[2048]                     = { 0.0, ... };
float            f_ShieldUltGain[2048]                     = { 0.0, ... };
float            f_ShieldSentryRes[2048]                   = { 0.0, ... };
float            f_ThisShieldSentryRes[2048]               = { 0.0, ... };
float f_ShieldMeleeVuln[2048]               = { 0.0, ... };
float f_ThisShieldMeleeVuln[2048]               = { 0.0, ... };

bool             b_ShieldActive[MAXPLAYERS + 1]            = { false, ... };
bool             b_ShieldHeld[MAXPLAYERS + 1]              = { false, ... };
bool             b_IsShield[2048]                          = { false, ... };
bool             b_ShieldWasDestroyed[MAXPLAYERS + 1]      = { false, ... };
bool             b_CannotWalk[MAXPLAYERS + 1]              = { false, ... };
float f_CannotWalkCheckTime[MAXPLAYERS + 1] = { 0.0, ... };
bool             b_ThisShieldIsHeld[2048]                  = { false, ... };

int              i_Shield[MAXPLAYERS + 1]                  = { -1, ... };
int              i_ShieldOwner[2048]                       = { -1, ... };
int i_GrabWearable[MAXPLAYERS + 1] = { -1, ... };
int              i_ShieldProp[2048]                        = { -1, ... };
int              i_PropShield[2048]                        = { -1, ... };

char             s_RiotShieldLoopSound[2048][255];
char             s_ShieldRegenLoop[2048][255];

CF_SpeedModifier ShieldSpeedModifier[MAXPLAYERS + 1] = { null, ... };

float            RiotShield_Mins[3]                  = { -3.1045, -36.1445, 5.7225 };
float            RiotShield_Maxs[3]                  = { 19.4495, 34.846, 134.134 };

public void Shield_Prepare(int client)
{
    f_ShieldMaxHealth[client]         = CF_GetArgF(client, LAW, SHIELD, "max_health", 600.0);
    f_ShieldHealth[client]            = f_ShieldMaxHealth[client];
    f_ShieldScale[client]             = CF_GetArgF(client, LAW, SHIELD, "scale", 1.0);
    f_ShieldDistance[client]          = CF_GetArgF(client, LAW, SHIELD, "distance", 20.0);
    f_ShieldHeight[client]            = CF_GetArgF(client, LAW, SHIELD, "height", 0.0);
    f_ShieldSpeedPenalty[client]      = CF_GetArgF(client, LAW, SHIELD, "speed_penalty", 160.0);
    f_ShieldAtkSpeed[client]          = CF_GetArgF(client, LAW, SHIELD, "atk_rate", 2.0);
    f_ShieldRegen[client]             = CF_GetArgF(client, LAW, SHIELD, "regen", 4.0);
    f_ShieldRegenDelay[client]        = CF_GetArgF(client, LAW, SHIELD, "regen_delay", 6.0);
    f_ShieldRegenDelay_Broken[client] = CF_GetArgF(client, LAW, SHIELD, "regen_delay_broken", 12.0);
    f_ShieldDeployTime[client]        = CF_GetArgF(client, LAW, SHIELD, "deploy_time", 0.5);
    f_ShieldDamage[client]            = CF_GetArgF(client, LAW, SHIELD, "damage", 0.0);
    f_ShieldKB[client]                = CF_GetArgF(client, LAW, SHIELD, "knockback", 150.0);
    f_ShieldUltGain[client]           = CF_GetArgF(client, LAW, SHIELD, "ult_gain", 0.33);
    f_ShieldSentryRes[client]         = CF_GetArgF(client, LAW, SHIELD, "sentry_res", 0.35);
    f_ShieldMeleeVuln[client] = CF_GetArgF(client, LAW, SHIELD, "melee_vuln", 2.25);
}

public void Riot_Activate(int client, char abilityName[255])
{
    float deployTime = CF_GetArgF(client, LAW, abilityName, "deploy_time", 0.5);
    float distance   = CF_GetArgF(client, LAW, abilityName, "distance", 135.0);
    float scale      = CF_GetArgF(client, LAW, abilityName, "scale", 2.5);
    float maxHealth  = CF_GetArgF(client, LAW, abilityName, "max_health", 1000.0);
    float lifespan   = CF_GetArgF(client, LAW, abilityName, "lifespan", 20.0);
    float damage     = CF_GetArgF(client, LAW, abilityName, "damage", 60.0);
    float knockback  = CF_GetArgF(client, LAW, abilityName, "knockback", 400.0);
    float sentryRes  = CF_GetArgF(client, LAW, abilityName, "sentry_res", 0.35);
    float meleeVuln  = CF_GetArgF(client, LAW, abilityName, "melee_vuln", 2.25);

    float pos[3], eyeLoc[3], ang[3], buffer[3];
    GetClientEyePosition(client, eyeLoc);
    GetClientEyeAngles(client, ang);
    ang[0]       = 0.0;

    Handle trace = TR_TraceRayFilterEx(eyeLoc, ang, MASK_SOLID, RayType_Infinite, Shield_Trace);
    TR_GetEndPosition(pos, trace);
    delete trace;

    pos = ConstrainDistance(eyeLoc, pos, distance);
    float maxs[3], mins[3];
    mins = RiotShield_Mins;
    maxs = RiotShield_Maxs;
    ScaleVector(maxs, scale * 0.2);
    ScaleVector(mins, scale * 0.2);
    ClipToGround(maxs, 134.134 * scale * 0.2, pos, mins);
    // pos[2] -= 73.378 * scale;
    GetAngleVectors(ang, NULL_VECTOR, NULL_VECTOR, buffer);

    Shield_CreateShield(client, pos, ang, false, deployTime, scale, maxHealth, maxHealth, lifespan, damage, knockback, sentryRes, meleeVuln);

    float left[3], right[3];
    GetAngleVectors(ang, NULL_VECTOR, right, NULL_VECTOR);
    left = right;
    ScaleVector(left, -1.0);

    int count = CF_GetArgI(client, LAW, abilityName, "quantity", 9) - 1;
    for (int i = 1; i <= count; i++)
    {
        float currentWave = ((i % 2) ? float(i) + 1.0 : float(i)) / 2.0;

        float dist        = currentWave * 56.9905 * scale;
        float targPos[3];
        targPos = pos;
        targPos[0] += dist * (i % 2 ? right[0] : left[0]);
        targPos[1] += dist * (i % 2 ? right[1] : left[1]);
        targPos[2] += dist * (i % 2 ? right[2] : left[2]);

        ClipToGround(maxs, 134.134 * scale, targPos, mins);

        DataPack pack = new DataPack();
        CreateDataTimer(0.1 * currentWave, Riot_SpawnOnDelay, pack, TIMER_FLAG_NO_MAPCHANGE);
        WritePackCell(pack, GetClientUserId(client));
        WritePackFloatArray(pack, targPos, 3);
        WritePackFloatArray(pack, ang, 3);
        WritePackFloat(pack, deployTime);
        WritePackFloat(pack, scale);
        WritePackFloat(pack, maxHealth);
        WritePackFloat(pack, lifespan);
        WritePackFloat(pack, damage);
        WritePackFloat(pack, knockback);
        WritePackFloat(pack, sentryRes);
        WritePackFloat(pack, meleeVuln);
    }
}

public Action Riot_SpawnOnDelay(Handle timer, DataPack pack)
{
    ResetPack(pack);
    int   client = GetClientOfUserId(ReadPackCell(pack));
    float targPos[3], ang[3];
    ReadPackFloatArray(pack, targPos, 3);
    ReadPackFloatArray(pack, ang, 3);
    float deployTime = ReadPackFloat(pack);
    float scale      = ReadPackFloat(pack);
    float maxHealth  = ReadPackFloat(pack);
    float lifespan   = ReadPackFloat(pack);
    float damage     = ReadPackFloat(pack);
    float knockback  = ReadPackFloat(pack);
    float sentryRes  = ReadPackFloat(pack);
    float meleeVuln = ReadPackFloat(pack);

    if (IsValidClient(client))
        Shield_CreateShield(client, targPos, ang, false, deployTime, scale, maxHealth, maxHealth, lifespan, damage, knockback, sentryRes, meleeVuln);

    return Plugin_Continue;
}

public void Shield_Deploy(int client)
{
    float pos[3], eyeLoc[3], ang[3], buffer[3];
    GetClientEyePosition(client, eyeLoc);
    GetClientEyeAngles(client, ang);
    ang[0]       = ClampFloat(ang[0], -20.0, 0.0);

    Handle trace = TR_TraceRayFilterEx(eyeLoc, ang, MASK_SOLID, RayType_Infinite, Shield_Trace);
    TR_GetEndPosition(pos, trace);
    delete trace;

    pos = ConstrainDistance(eyeLoc, pos, f_ShieldDistance[client]);
    GetAngleVectors(ang, NULL_VECTOR, NULL_VECTOR, buffer);
    pos[0] -= f_ShieldHeight[client] * buffer[0];
    pos[1] -= f_ShieldHeight[client] * buffer[1];
    pos[2] -= f_ShieldHeight[client] * buffer[2];

    Shield_CreateShield(client, pos, ang, true, f_ShieldDeployTime[client], f_ShieldScale[client], f_ShieldMaxHealth[client], f_ShieldHealth[client], 0.0, f_ShieldDamage[client], f_ShieldKB[client], f_ShieldSentryRes[client], f_ShieldMeleeVuln[client]);
}

void Shield_CreateShield(int client, float pos[3], float ang[3], bool held, float deployTime, float scale, float maxHealth, float health, float lifespan, float damage = 0.0, float knockback = 0.0, float sentryRes = 0.0, float meleeVuln = 1.0)
{
    int shield = CF_CreateShieldWall(client, MODEL_SHIELD, "0", 0.0, health, pos, ang);

    if (IsValidEntity(shield))
    {
        DataPack pack = new DataPack();
        WritePackCell(pack, EntIndexToEntRef(shield));
        WritePackFloat(pack, GetGameTime() + deployTime);
        WritePackFloat(pack, scale);
        RequestFrame(Shield_Arm, pack);

        f_ShieldMyMaxHealth[shield]   = maxHealth;
        f_ShieldMyHealth[shield]      = health;
        f_ThisShieldSentryRes[shield] = sentryRes;
        f_ThisShieldMeleeVuln[shield] = meleeVuln;

        i_ShieldOwner[shield]         = GetClientUserId(client);
        f_ShieldOldPercentage[shield] = f_ShieldMyHealth[shield] / f_ShieldMyMaxHealth[shield];

        b_IsShield[shield]            = true;
        b_ThisShieldIsHeld[shield]    = held;
        f_ShieldMyDeployTime[shield]  = deployTime;
        f_ShieldMyScale[shield]       = scale;

        SetEntProp(shield, Prop_Data, "m_takedamage", 0);
        Shield_ApplyProp(shield);
        SetEntityRenderMode(shield, RENDER_TRANSALPHA);
        SetEntityRenderColor(shield, 255, 255, 255, 0);

        if (held)
        {
            Shield_EndRegenLoop(client);

            i_Shield[client]             = EntIndexToEntRef(shield);
            b_ShieldHeld[client]         = true;
            b_ShieldWasDestroyed[client] = false;

            CF_GetRandomSound(client, "sound_riot_shield_loop", s_RiotShieldLoopSound[shield], 255);
            if (!StrEqual(s_RiotShieldLoopSound[shield], ""))
                EmitSoundToAll(s_RiotShieldLoopSound[shield], shield, _, _, _, _, 80);

            SDKUnhook(client, SDKHook_PreThink, Shield_PreThink);
            SDKHook(client, SDKHook_PreThink, Shield_PreThink);

            Shield_SetDamagedState(client);

            ShieldSpeedModifier[client] = CF_ApplyTemporarySpeedChange(client, 3, -f_ShieldSpeedPenalty[client], 0.0, 0, 0.0, false);
            CF_PlayRandomSound(client, shield, "sound_riot_shield_deployed_sfx");
            CF_PlayRandomSound(client, client, "sound_riot_shield_deployed");
            SetEntityCollisionGroup(shield, 26);
        }
        else
        {
            CF_GetRandomSound(client, "sound_riot_control_shield_loop", s_RiotShieldLoopSound[shield], 255);
            if (!StrEqual(s_RiotShieldLoopSound[shield], ""))
                EmitSoundToAll(s_RiotShieldLoopSound[shield], shield, _, _, _, 0.5, 60);
            CF_PlayRandomSound(client, shield, "sound_riot_control_shield_deployed_sfx");

            if (lifespan > 0.0)
                CreateTimer(lifespan, Riot_PowerDown, EntIndexToEntRef(shield), TIMER_FLAG_NO_MAPCHANGE);
        }

        SetEntityMoveType(shield, MOVETYPE_NONE);
        SpawnParticle(pos, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_SHIELD_SPAWN_RED : PARTICLE_SHIELD_SPAWN_BLUE, 0.2);

        f_RiotShieldDamage[shield] = damage;
        f_RiotShieldKB[shield]     = knockback;
        SDKHook(shield, SDKHook_TouchPost, Shield_OnTouch);
    }
}

public Action Shield_OnTouch(int shield, int target)
{
    int owner = GetClientOfUserId(i_ShieldOwner[shield]);
    if (!IsValidClient(owner))
        return Plugin_Handled;

    if (!CF_IsValidTarget(target, grabEnemyTeam(owner)))
        return Plugin_Handled;

    if (IsValidClient(target) && IsInvuln(target))
        return Plugin_Handled;

    if ((f_RiotShieldDamage[shield] > 0.0 || (f_RiotShieldKB[shield] > 0.0 && IsValidClient(target))) && f_NextShieldHit[target] <= GetGameTime())
    {
        f_NextShieldHit[target] = GetGameTime() + 0.2;

        float pos[3];
        CF_WorldSpaceCenter(target, pos);

        SpawnParticle(pos, TF2_GetClientTeam(owner) == TFTeam_Red ? PARTICLE_SHIELD_KB_RED : PARTICLE_SHIELD_KB_BLUE, 0.2);
        EmitSoundToAll(SOUND_SHIELD_KB_1, shield, _, _, _, _, GetRandomInt(80, 110));
        EmitSoundToAll(SOUND_SHIELD_KB_2, shield, _, _, _, _, GetRandomInt(80, 110));

        Shield_Flash(shield);

        if (f_RiotShieldDamage[shield] > 0.0)
            SDKHooks_TakeDamage(target, shield, owner, f_RiotShieldDamage[shield], DMG_CLUB);

        if (f_RiotShieldKB[shield] > 0.0 && IsValidClient(target))
        {
            float ang[3], shieldPos[3];
            CF_WorldSpaceCenter(shield, shieldPos);
            GetAngleBetweenPoints(shieldPos, pos, ang);
            if (ang[0] > -25.0)
                ang[0] = -25.0;

            DataPack pack = new DataPack();
            RequestFrame(Shield_DoKB, pack);
            WritePackCell(pack, GetClientUserId(target));
            WritePackFloatArray(pack, ang, 3);
            WritePackFloat(pack, f_RiotShieldKB[shield]);
        }
    }

    return Plugin_Handled;
}

public void Shield_DoKB(DataPack pack)
{
    ResetPack(pack);

    float ang[3];
    int   target = GetClientOfUserId(ReadPackCell(pack));
    ReadPackFloatArray(pack, ang, 3);
    float kb = ReadPackFloat(pack);

    delete pack;

    if (IsValidClient(target))
        CF_ApplyKnockback(target, kb, ang, true, false, false, true);
}

public Action Riot_PowerDown(Handle timer, int ref)
{
    int shield = EntRefToEntIndex(ref);
    if (!IsValidEntity(shield))
        return Plugin_Continue;

    int prop = EntRefToEntIndex(i_ShieldProp[shield]);
    if (IsValidEntity(prop))
    {
        SetParent(prop, prop);
        MakeEntityGraduallyResize(prop, 0.01, 0.5, true);
        MakeEntityFadeOut(prop, 4);
    }

    EmitSoundToAll(SOUND_RIOT_CONTROL_POWER_DOWN, shield, _, _, _, _, 90);
    RemoveEntity(shield);

    return Plugin_Continue;
}

public void Shield_Arm(DataPack pack)
{
    ResetPack(pack);
    int   shield = EntRefToEntIndex(ReadPackCell(pack));
    float time   = ReadPackFloat(pack);
    float scale  = ReadPackFloat(pack);

    if (!IsValidEntity(shield))
    {
        delete pack;
        return;
    }

    if (GetGameTime() >= time)
    {
        SetEntPropFloat(shield, Prop_Send, "m_flModelScale", scale);
        SetEntProp(shield, Prop_Data, "m_takedamage", 2);
        delete pack;
        return;
    }

    RequestFrame(Shield_Arm, pack);
}

public void Shield_ApplyProp(int shield)
{
    if (!IsValidEntity(shield))
        return;

    int prop = CreateEntityByName("prop_dynamic_override");
    if (IsValidEntity(prop))
    {
        int owner = GetEntPropEnt(shield, Prop_Send, "m_hOwnerEntity");
        int team  = GetEntProp(shield, Prop_Send, "m_iTeamNum");

        SetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity", owner);
        SetEntProp(prop, Prop_Send, "m_iTeamNum", team);

        SetEntityModel(prop, MODEL_SHIELD);

        DispatchSpawn(prop);

        AcceptEntityInput(prop, "Enable");

        float pos[3], ang[3];
        GetEntPropVector(shield, Prop_Send, "m_vecOrigin", pos);
        GetEntPropVector(shield, Prop_Data, "m_angRotation", ang);

        float scale = GetEntPropFloat(shield, Prop_Send, "m_flModelScale");
        SetEntPropFloat(prop, Prop_Send, "m_flModelScale", scale);
        MakeEntityGraduallyResize(prop, f_ShieldMyScale[shield], f_ShieldMyDeployTime[shield], false);

        TeleportEntity(prop, pos, ang, NULL_VECTOR);
        SetEntityRenderMode(prop, RENDER_TRANSALPHA);

        i_ShieldProp[shield] = EntIndexToEntRef(prop);
        i_PropShield[prop]   = EntIndexToEntRef(shield);
        Shield_Flash(shield);
        RequestFrame(Shield_FlashDecay, EntIndexToEntRef(prop));
    }
}

public void Shield_FlashDecay(int ref)
{
    int shield = EntRefToEntIndex(ref);
    if (!IsValidEntity(shield))
        return;

    TFTeam team = view_as<TFTeam>(GetEntProp(shield, Prop_Send, "m_iTeamNum"));

    int    r, g, b, a;
    GetEntityRenderColor(shield, r, g, b, a);

    if (r > (team == TFTeam_Red ? Flash_BaseMainColor : Flash_BaseSecondaryColor))
    {
        r -= (team == TFTeam_Red ? Flash_MainDecay : Flash_SecondaryDecay);
        if (r < (team == TFTeam_Red ? Flash_BaseMainColor : Flash_BaseSecondaryColor))
            r = (team == TFTeam_Red ? Flash_BaseMainColor : Flash_BaseSecondaryColor);
    }

    if (g > Flash_BaseSecondaryColor)
    {
        g -= Flash_SecondaryDecay;
        if (g < Flash_BaseSecondaryColor)
            g = Flash_BaseSecondaryColor;
    }

    if (b > (team == TFTeam_Blue ? Flash_BaseMainColor : Flash_BaseSecondaryColor))
    {
        b -= (team == TFTeam_Blue ? Flash_MainDecay : Flash_SecondaryDecay);
        if (b < (team == TFTeam_Blue ? Flash_BaseMainColor : Flash_BaseSecondaryColor))
            b = (team == TFTeam_Blue ? Flash_BaseMainColor : Flash_BaseSecondaryColor);
    }

    if (a > Flash_BaseAlpha)
    {
        a -= Flash_AlphaDecay;
        if (a < Flash_BaseAlpha)
            a = Flash_BaseAlpha;
    }

    SetEntityRenderColor(shield, r, g, b, a);

    RequestFrame(Shield_FlashDecay, EntIndexToEntRef(shield));
}

public void Shield_Flash(int shield)
{
    shield = EntRefToEntIndex(i_ShieldProp[shield]);
    if (!IsValidEntity(shield))
        return;

    TFTeam team = view_as<TFTeam>(GetEntProp(shield, Prop_Send, "m_iTeamNum"));

    int    r    = (team == TFTeam_Red ? Flash_MaxMainColor : Flash_MaxSecondaryColor);
    int    g    = Flash_MaxSecondaryColor;
    int    b    = (team == TFTeam_Blue ? Flash_MaxMainColor : Flash_MaxSecondaryColor);
    int    a    = Flash_MaxAlpha;

    SetEntityRenderColor(shield, r, g, b, a);
}

public void Shield_SetDamagedState(int client)
{
    int shield = EntRefToEntIndex(i_Shield[client]);
    if (!IsValidEntity(shield))
        return;

    int prop = EntRefToEntIndex(i_ShieldProp[shield]);
    if (!IsValidEntity(prop))
        return;

    Shield_SetDamagedSequence(shield, prop);
}

public void Shield_SetDamagedSequence(int shield, int prop)
{
    char idleSequence[255];
    if (f_ShieldOldPercentage[shield] > 0.75)
        idleSequence = "idle_full";
    else if (f_ShieldOldPercentage[shield] > 0.5)
        idleSequence = "idle_damaged_light";
    else if (f_ShieldOldPercentage[shield] > 0.25)
        idleSequence = "idle_damaged_mid";
    else
        idleSequence = "idle_damaged_heavy";

    SetVariantString(idleSequence);
    AcceptEntityInput(prop, "SetAnimation");
}

public Action Shield_PreThink(int client)
{
    int shield = EntRefToEntIndex(i_Shield[client]);

    if (!IsValidEntity(shield) || !b_ShieldHeld[client])
        return Plugin_Stop;

    float pos[3], eyeLoc[3], eyeAng[3], buffer[3];
    GetClientEyePosition(client, eyeLoc);
    GetClientEyeAngles(client, eyeAng);
    eyeAng[0]    = ClampFloat(eyeAng[0], -20.0, 0.0);

    Handle trace = TR_TraceRayFilterEx(eyeLoc, eyeAng, MASK_SOLID, RayType_Infinite, Shield_Trace);
    TR_GetEndPosition(pos, trace);
    delete trace;

    pos = ConstrainDistance(eyeLoc, pos, f_ShieldDistance[client]);

    GetAngleVectors(eyeAng, NULL_VECTOR, NULL_VECTOR, buffer);
    pos[0] -= f_ShieldHeight[client] * buffer[0];
    pos[1] -= f_ShieldHeight[client] * buffer[1];
    pos[2] -= f_ShieldHeight[client] * buffer[2];

    int frame = GetEntProp(shield, Prop_Send, "m_ubInterpolationFrame");

    TeleportEntity(shield, pos, eyeAng, NULL_VECTOR);

    SetEntProp(shield, Prop_Send, "m_ubInterpolationFrame", frame);

    int prop = EntRefToEntIndex(i_ShieldProp[shield]);
    if (IsValidEntity(prop))
    {
        // eyeAng[1] += 180.0;
        frame = GetEntProp(prop, Prop_Send, "m_ubInterpolationFrame");

        TeleportEntity(prop, pos, eyeAng, NULL_VECTOR);

        SetEntProp(prop, Prop_Send, "m_ubInterpolationFrame", frame);
    }

    return Plugin_Continue;
}

public void Shield_PlayHurtAnimation(int prop, char sequence[255])
{
    SetVariantString(sequence);
    AcceptEntityInput(prop, "SetAnimation");

    f_ShieldHurtAnimEndTime[prop] = GetGameTime() + 0.175;
    RequestFrame(Shield_SetIdleAnim, EntIndexToEntRef(prop));
}

public void Shield_SetIdleAnim(int ref)
{
    int prop = EntRefToEntIndex(ref);
    if (!IsValidEntity(prop))
        return;
    int shield = EntRefToEntIndex(i_PropShield[prop]);
    if (!IsValidEntity(shield))
        return;

    if (GetGameTime() >= f_ShieldHurtAnimEndTime[prop])
    {
        Shield_SetDamagedSequence(shield, prop);
        return;
    }

    RequestFrame(Shield_SetIdleAnim, ref);
}

bool IsNormalCombatEntity(int entity)
{
    return (IsValidClient(entity) || PNPC_IsNPC(entity) || IsABuilding(entity, false));
}

public float GetDistFromPayloadCart(int victim)
{
    if (!IsPayloadMap())
        return 999999999.0;

    int cart = -1;
    for (int i = 1; i < 2049; i++)
    {
        if (!IsValidEntity(i) || !IsPayloadCart(i))
            continue;

        cart = i;
        break;
    }

    if (!IsValidEntity(cart))
        return 999999999.0;

    float myPos[3], cartPos[3];
    CF_WorldSpaceCenter(victim, myPos);
    CF_WorldSpaceCenter(cart, cartPos);

    float dist = GetVectorDistance(myPos, cartPos);
    return dist;
}

public Action CF_OnFakeMediShieldDamaged(int shield, int attacker, int inflictor, float &damage, int &damagetype, int owner)
{
    if (b_IsShield[shield] && damage > 0.0)
    {
        if (IsNormalCombatEntity(attacker) || GetDistFromPayloadCart(shield) >= 250.0)
            Shield_TakeDamage(shield, damage, owner, attacker, inflictor, damagetype);

        damage = 0.0;
        return Plugin_Changed;
    }

    return Plugin_Continue;
}

public void Shield_TakeDamage(int shield, float damage, int owner, int attacker, int inflictor, int damagetype)
{
    int prop = EntRefToEntIndex(i_ShieldProp[shield]);
    if (!IsValidEntity(prop))
        return;

    if (IsValidEntity(inflictor))
    {
        char infClass[255];
        GetEntityClassname(inflictor, infClass, 255);
        if (StrContains(infClass, "obj_sentrygun") != -1)
            damage *= (1.0 - f_ThisShieldSentryRes[shield]);
    }

    if (damagetype & DMG_CLUB != 0)
        damage *= f_ThisShieldMeleeVuln[shield];

    bool soundPlayed = false;
    Shield_Flash(shield);

    if (b_ThisShieldIsHeld[shield])
    {
        f_ShieldHealth[owner] -= damage;
        if (f_ShieldHealth[owner] < 0.0)
            f_ShieldHealth[owner] = 0.0;

        CF_GiveUltCharge(owner, damage * f_ShieldUltGain[owner]);
    }

    f_ShieldMyHealth[shield] -= damage;
    if (f_ShieldMyHealth[shield] < 0.0)
        f_ShieldMyHealth[shield] = 0.0;

    float percentage = (f_ShieldMyHealth[shield] > 0.0 ? f_ShieldMyHealth[shield] / f_ShieldMyMaxHealth[shield] : 0.0);

    if (percentage <= 0.0)
    {
        if (b_ThisShieldIsHeld[shield])
        {
            b_ShieldWasDestroyed[owner] = true;
            Shield_Holster(owner, false);
        }

        Shield_Break(shield, owner, attacker);
    }
    else if (percentage > 0.75)
    {
        Shield_PlayHurtAnimation(prop, "damaged_light_unbroken");
    }
    else if (percentage > 0.5)
    {
        Shield_PlayHurtAnimation(prop, "damaged_light_broken");

        if (f_ShieldOldPercentage[shield] > 0.75)
        {
            EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 120);

            if (IsValidClient(owner))
                EmitSoundToClient(owner, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 120);

            if (IsValidClient(attacker))
                EmitSoundToClient(attacker, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 120);

            soundPlayed = true;
        }
    }
    else if (percentage > 0.25)
    {
        Shield_PlayHurtAnimation(prop, "damaged_mid");

        if (f_ShieldOldPercentage[shield] > 0.5)
        {
            EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 100);

            if (IsValidClient(owner))
                EmitSoundToClient(owner, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 100);

            if (IsValidClient(attacker))
                EmitSoundToClient(attacker, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 100);

            soundPlayed = true;
        }
    }
    else
    {
        Shield_PlayHurtAnimation(prop, "damaged_heavy");

        if (f_ShieldOldPercentage[shield] > 0.25)
        {
            EmitSoundToAll(SOUND_SHIELD_STAGEBREAK, prop, SNDCHAN_STATIC, 120, _, _, 80);

            if (IsValidClient(owner))
                EmitSoundToClient(owner, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 80);

            if (IsValidClient(attacker))
                EmitSoundToClient(attacker, SOUND_SHIELD_STAGEBREAK, _, SNDCHAN_STATIC, 120, _, _, 80);

            soundPlayed = true;
        }
    }

    if (!soundPlayed)
        EmitSoundToAll(SOUND_SHIELD_TAKEDAMAGE, shield, SNDCHAN_STATIC, 80, _, _, GetRandomInt(80, 110));

    f_ShieldOldPercentage[shield] = percentage;
}

public void Shield_Break(int shield, int owner, int attacker)
{
    int prop = EntRefToEntIndex(i_ShieldProp[shield]);
    if (IsValidEntity(prop))
    {
        SetVariantString("break");
        AcceptEntityInput(prop, "SetAnimation");
        MakeEntityFadeOut(prop, 8);
        SetParent(prop, prop);

        EmitSoundToAll(SOUND_SHIELD_FULLBREAK, prop, SNDCHAN_STATIC, 120);

        if (b_ThisShieldIsHeld[shield])
        {
            if (IsValidClient(owner))
                EmitSoundToClient(owner, SOUND_SHIELD_FULLBREAK, _, SNDCHAN_STATIC, 120);

            if (IsValidClient(attacker))
                EmitSoundToClient(attacker, SOUND_SHIELD_FULLBREAK, _, SNDCHAN_STATIC, 120);
        }
    }

    if (b_ThisShieldIsHeld[shield])
    {
        CF_PlayRandomSound(owner, owner, "sound_riot_shield_break");
        CF_SilenceCharacter(owner, 2.0);
    }

    RemoveEntity(shield);
}

void Shield_Holster(int client, bool resupply, bool allowRegen = true)
{
    int shield = EntRefToEntIndex(i_Shield[client]);
    if (IsValidEntity(shield) && b_ShieldHeld[client])
    {
        float delay = f_ShieldRegenDelay_Broken[client];
        if (!b_ShieldWasDestroyed[client])
        {
            delay    = f_ShieldRegenDelay[client];

            int prop = EntRefToEntIndex(i_ShieldProp[shield]);
            if (IsValidEntity(prop))
            {
                SetParent(prop, prop);
                MakeEntityGraduallyResize(prop, 0.01, 0.25, true);
                MakeEntityFadeOut(prop, 4);
            }

            if (!resupply)
                CF_PlayRandomSound(client, shield, "sound_riot_shield_holstered_sfx");
            CF_PlayRandomSound(client, client, "sound_riot_shield_holstered");
        }

        if (ShieldSpeedModifier[client].b_Exists)
            ShieldSpeedModifier[client].Destroy();

        SDKUnhook(client, SDKHook_PreThink, Shield_PreThink);
        b_ShieldHeld[client]         = false;
        b_ShieldWasDestroyed[client] = false;

        if (allowRegen && f_ShieldHealth[client] < f_ShieldMaxHealth[client])
        {
            DataPack pack = new DataPack();
            WritePackCell(pack, GetClientUserId(client));
            WritePackFloat(pack, GetGameTime() + delay);
            RequestFrame(Shield_WaitForRegen, pack);
        }

        CF_ChangeAbilityTitle(client, CF_GetAbilitySlot(client, LAW, SHIELD), "Deploy Riot Shield");

        RemoveEntity(shield);
        i_ShieldOwner[shield] = -1;
    }
}

public void Shield_WaitForRegen(DataPack pack)
{
    ResetPack(pack);
    int   client = GetClientOfUserId(ReadPackCell(pack));
    float time   = ReadPackFloat(pack);
    if (!IsValidMulti(client) || b_ShieldHeld[client] || !b_ShieldActive[client] || f_ShieldHealth[client] >= f_ShieldMaxHealth[client])
    {
        delete pack;
        return;
    }

    if (GetGameTime() >= time)
    {
        delete pack;
        pack = new DataPack();
        WritePackCell(pack, GetClientUserId(client));
        WritePackFloat(pack, GetGameTime() + 0.1);
        RequestFrame(Shield_Regenerate, pack);

        PrintCenterText(client, "RIOT SHIELD: Initiating repair protocol...");
        CF_PlayRandomSound(client, client, "sound_riot_shield_regen_begin");
        CF_GetRandomSound(client, "sound_riot_shield_regen_loop", s_ShieldRegenLoop[client], 255);
        if (!StrEqual(s_ShieldRegenLoop[client], ""))
            EmitSoundToClient(client, s_ShieldRegenLoop[client], _, _, 60, SND_CHANGEVOL, 0.35);

        return;
    }

    RequestFrame(Shield_WaitForRegen, pack);
}

public void Shield_Regenerate(DataPack pack)
{
    ResetPack(pack);
    int   client = GetClientOfUserId(ReadPackCell(pack));
    float time   = ReadPackFloat(pack);
    delete pack;

    if (!IsValidMulti(client) || b_ShieldHeld[client] || !b_ShieldActive[client])
        return;

    if (GetGameTime() >= time)
    {
        f_ShieldHealth[client] += f_ShieldRegen[client];

        if (f_ShieldHealth[client] >= f_ShieldMaxHealth[client])
        {
            f_ShieldHealth[client] = f_ShieldMaxHealth[client];
            PrintCenterText(client, "RIOT SHIELD: Repair protocol complete!");
            CF_PlayRandomSound(client, client, "sound_riot_shield_regen_finish");
            Shield_EndRegenLoop(client);
            return;
        }

        time = GetGameTime() + 0.1;
    }

    pack = new DataPack();
    WritePackCell(pack, GetClientUserId(client));
    WritePackFloat(pack, time);
    RequestFrame(Shield_Regenerate, pack);
}

public void Shield_EndRegenLoop(int client)
{
    if (!StrEqual(s_ShieldRegenLoop[client], ""))
    {
        StopSound(client, SNDCHAN_AUTO, s_ShieldRegenLoop[client]);
        strcopy(s_ShieldRegenLoop[client], 255, "");
    }
}

public bool Shield_Trace(entity, contentsMask)
{
    if (entity <= MaxClients)
        return false;

    if (b_IsShield[entity])
        return false;

    char classname[255];
    GetEntityClassname(entity, classname, sizeof(classname));

    if (StrContains(classname, "tf_projectile") != -1)
        return false;

    return true;
}

float     Protect_Amt[MAXPLAYERS + 1]       = { 0.0, ... };
float     Protect_IgnoreAmt[MAXPLAYERS + 1] = { 0.0, ... };
float     Protect_ShieldAmt[MAXPLAYERS + 1] = { 0.0, ... };
float     Protect_UltGain[MAXPLAYERS + 1]   = { 0.0, ... };
float     Protect_Radius[MAXPLAYERS + 1]    = { 0.0, ... };

bool      Protect_LOS[MAXPLAYERS + 1]       = { false, ... };

// This sometimes gets shifted when clients connect/disconnect. I have no idea why, literally nothing else I have ever written has this issue.
// I'm just going to leave it be for now, and if it ends up being buggy on the live server, we know why.
ArrayList g_Protectors[MAXPLAYERS + 1]      = { null, ... };

int       Protect_StartEnt[MAXPLAYERS + 1][MAXPLAYERS + 1];
int       Protect_EndEnt[MAXPLAYERS + 1][MAXPLAYERS + 1];
int       Protect_Beam[MAXPLAYERS + 1][MAXPLAYERS + 1];

bool      Protect_Active[MAXPLAYERS + 1] = { false, ... };
bool      b_BeamFadingIn[2048]           = { false, ... };
bool      b_BeamActive[2048]             = { false, ... };

char      s_ProtectName[2048][255];

public void Protect_Begin(int client, char abilityName[255])
{
    Protect_Amt[client]       = CF_GetArgF(client, LAW, abilityName, "protection_amount", 0.35);
    Protect_IgnoreAmt[client] = CF_GetArgF(client, LAW, abilityName, "ignore_amount", 0.0);
    Protect_ShieldAmt[client] = CF_GetArgF(client, LAW, abilityName, "shield_amount", 0.5);
    Protect_UltGain[client]   = CF_GetArgF(client, LAW, abilityName, "ult_gain", 0.02);
    Protect_Radius[client]    = CF_GetArgF(client, LAW, abilityName, "radius", 400.0);
    Protect_LOS[client]       = CF_GetArgI(client, LAW, abilityName, "require_los", 1) > 0;

    Protect_Active[client]    = true;
    strcopy(s_ProtectName[client], 255, abilityName);

    CreateTimer(0.1, Protect_Logic, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    CF_PlayRandomSound(client, client, "sound_custody_begin");
}

public Action Protect_Logic(Handle timer, int id)
{
    int client = GetClientOfUserId(id);

    if (!IsValidMulti(client) || !Protect_Active[client])
        return Plugin_Stop;

    float myPos[3];
    CF_WorldSpaceCenter(client, myPos);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || i == client)
            continue;

        float theirPos[3];
        CF_WorldSpaceCenter(i, theirPos);

        if (GetVectorDistance(myPos, theirPos) <= Protect_Radius[client] && (!Protect_LOS[client] || CF_HasLineOfSight(myPos, theirPos, _, _, client)) && IsValidMulti(i, true, true, true, TF2_GetClientTeam(client)) && !Protect_Active[i])
        {
            Protect_AddProtector(i, client);
        }
        else
        {
            Protect_RemoveProtector(i, client, true);
        }
    }

    return Plugin_Continue;
}

public void Protect_AddProtector(int client, int protector)
{
    if (g_Protectors[client] == null)
        g_Protectors[client] = CreateArray(255);

    bool alreadyExists = false;

    if (GetArraySize(g_Protectors[client]) > 0)
    {
        for (int i = 0; i < GetArraySize(g_Protectors[client]); i++)
        {
            int cell = GetClientOfUserId(GetArrayCell(g_Protectors[client], i));
            if (cell == protector)
            {
                alreadyExists = true;
                break;
            }
        }
    }

    if (!alreadyExists)
    {
        Protect_ApplyVFX(client, protector);
        PushArrayCell(g_Protectors[client], GetClientUserId(protector));
        EmitSoundToClient(client, SOUND_PROTECT_ADD, _, _, 120);
        EmitSoundToClient(protector, SOUND_PROTECT_ADD, _, _, 120);

        PrintCenterText(client, "You are now under %N's Protective Custody!", protector);
        char name[255];
        CF_GetCharacterName(client, name, 255);
        PrintCenterText(protector, "%N (%s) is now under your Protective Custody!", client, name);
    }
}

public void Protect_RemoveProtector(int client, int protector, bool notify)
{
    if (g_Protectors[client] == null || GetArraySize(g_Protectors[client]) < 1)
        return;

    for (int i = 0; i < GetArraySize(g_Protectors[client]); i++)
    {
        int cell = GetClientOfUserId(GetArrayCell(g_Protectors[client], i));
        if (cell == protector)
        {
            if (notify)
            {
                EmitSoundToClient(client, SOUND_PROTECT_REMOVE, _, _, 120);
                EmitSoundToClient(protector, SOUND_PROTECT_REMOVE, _, _, 120);

                PrintCenterText(client, "You are no longer under %N's Protective Custody!", protector);

                char name[255];
                CF_GetCharacterName(client, name, 255);
                PrintCenterText(protector, "%N (%s) is no longer under your Protective Custody!", client, name);
            }

            RemoveFromArray(g_Protectors[client], i);

            if (GetArraySize(g_Protectors[client]) < 1)
            {
                delete g_Protectors[client];
                g_Protectors[client] = null;
            }

            Protect_RemoveVFX(client, protector);

            break;
        }
    }
}

// Removes this client from all allies' list of protectors.
public void Protect_ClearClient(int client)
{
    Protect_Active[client] = false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i))
            continue;

        Protect_RemoveProtector(i, client, false);
    }
}

// Removes all protectors from this client.
public void Protect_ClearProtectors(int client)
{
    if (g_Protectors[client] == null)
        return;

    for (int i = 0; i < GetArraySize(g_Protectors[client]); i++)
    {
        int protector = GetClientOfUserId(GetArrayCell(g_Protectors[client], i));
        Protect_RemoveProtector(client, protector, false);

        if (g_Protectors[client] == null)
            break;
    }
}

public void Protect_ApplyVFX(int client, int protector)
{
    int r = 255;
    int b = 120;
    if (TF2_GetClientTeam(protector) == TFTeam_Blue)
    {
        r = 120;
        b = 255;
    }

    int startEnt, endEnt;
    int beam = CreateEnvBeam(protector, client, _, _, "back_lower", "back_lower", startEnt, endEnt, r, 120, b, 0, MODEL_POLICELINE, 12.0, 12.0, 600.0, 0.0, 8.0);
    if (!IsValidEntity(beam))
        return;

    SetEntityRenderColor(beam, r, 120, b, 0);
    b_BeamFadingIn[beam] = true;
    b_BeamActive[beam]   = true;
    RequestFrame(Protect_FadeBeamIn, EntIndexToEntRef(beam));

    DataPack pack = new DataPack();
    RequestFrame(Protect_ManageBeamVFX, pack);
    WritePackCell(pack, EntIndexToEntRef(beam));
    WritePackCell(pack, TF2_GetClientTeam(client));

    Protect_Beam[client][protector] = EntIndexToEntRef(beam);

    if (IsValidEntity(startEnt))
        Protect_StartEnt[client][protector] = EntIndexToEntRef(startEnt);
    if (IsValidEntity(endEnt))
        Protect_EndEnt[client][protector] = EntIndexToEntRef(endEnt);
}

public void Protect_FadeBeamIn(int ref)
{
    int beam = EntRefToEntIndex(ref);
    if (!IsValidEntity(beam) || !b_BeamActive[beam])
        return;

    int r, g, b, a;
    GetEntityRenderColor(beam, r, g, b, a);
    a += 8;
    if (a > 255)
        a = 255;

    SetEntityRenderColor(beam, r, g, b, a);
    if (a >= 255)
    {
        b_BeamFadingIn[beam] = false;
        return;
    }

    RequestFrame(Protect_FadeBeamIn, ref);
}

public void Protect_ManageBeamVFX(DataPack pack)
{
    ResetPack(pack);

    int    beam = EntRefToEntIndex(ReadPackCell(pack));
    TFTeam team = ReadPackCell(pack);

    if (!IsValidEntity(beam) || !b_BeamActive[beam])
    {
        delete pack;
        return;
    }

    int r, g, b, a;
    GetEntityRenderColor(beam, r, g, b, a);

    if (!b_BeamFadingIn[beam])
    {
        // ugly ass code but who cares
        int targetR = 255;
        int targetB = 120;
        if (team == TFTeam_Blue)
        {
            targetR = 120;
            targetB = 255;
        }
        int targetA = 200;

        if (a > targetA)
        {
            a -= 4;
            if (a < targetA)
                a = targetA;
        }

        if (r > targetR)
        {
            r -= 8;
            if (r < targetR)
                r = targetR;
        }

        if (g > 120)
        {
            g -= 8;
            if (g < 120)
                g = 120;
        }

        if (b > targetB)
        {
            b -= 8;
            if (b < targetB)
                b = targetB;
        }

        SetEntityRenderColor(beam, r, g, b, a);
    }

    float amplitude = GetEntPropFloat(beam, Prop_Data, "m_fAmplitude");
    if (amplitude > 0.0)
    {
        amplitude -= 0.05;
        if (amplitude < 0.0)
            amplitude = 0.0;

        SetEntPropFloat(beam, Prop_Data, "m_fAmplitude", amplitude);
    }

    RequestFrame(Protect_ManageBeamVFX, pack);
}

public void Protect_RemoveVFX(int client, int protector)
{
    int beam = EntRefToEntIndex(Protect_Beam[client][protector]);
    if (IsValidEntity(beam))
        b_BeamActive[beam] = false;
    int start = EntRefToEntIndex(Protect_StartEnt[client][protector]);
    int end   = EntRefToEntIndex(Protect_EndEnt[client][protector]);

    Core_RemoveBeamEffect(beam, start, end);

    Protect_Beam[client][protector]     = -1;
    Protect_StartEnt[client][protector] = -1;
    Protect_EndEnt[client][protector]   = -1;
}

float Chain_Duration[2048]     = { 0.0, ... };
float Chain_Radius[2048]       = { 0.0, ... };
float Chain_Damage[2048]       = { 0.0, ... };
float Chain_PullForce[2048]    = { 0.0, ... };
float Chain_HSpeed[2048]       = { 0.0, ... };
float Chain_VDeg[2048]         = { 0.0, ... };
float Chain_Elasticity[2048]   = { 0.0, ... };
float Chain_IgnoreWeight[2048] = { 0.0, ... };
float Chain_Durability[2048]   = { 0.0, ... };
float Chain_Distance[2048]     = { 0.0, ... };
float Chain_LastCheckAt[2048]  = { 0.0, ... };
float Chain_ReelDistance[2048] = { 0.0, ... };

int   i_ChainStartEnt[2048]    = { -1, ... };
int   i_ChainEndEnt[2048]      = { -1, ... };
int   i_ChainBeamEnt[2048]     = { -1, ... };
int   Chain_Owner[2048]        = { -1, ... };
int   Chain_Chain[MAXPLAYERS + 1][MAXPLAYERS + 1];
char  s_ChainAbName[2048][255];

bool  Chain_CanBeYanked[2048][MAXPLAYERS + 1];
bool  b_IsChainProjectile[2048] = { false, ... };

#define HS_MIN_LENGTH                     20.0    // hammer units, minimum length of hookshot relative to eye level
#define HS_CHECK_INTERVAL                 0.05
#define HS_LIMP_MIN_DISTANCE              100.0    // if the player is this many HU closer to the hook than they should be, the rope is limp, and does not affect their motion
#define HS_ROPE_TOP_DISCREPANCY_ALLOWANCE 50.0     // HU of allowed discrepancy in any axis for the end points of the rope (prevents oddities in the ceiling from snapping the rope)
#define HS_DEFAULT_ELASTIC_INTENSITY      900.0
#define HS_ELASTIC_BASE_DISTANCE          100.0
#define HS_HUD_TEXT_LENGTH                (MAX_CENTER_TEXT_LENGTH * 2)
#define HS_FLAG_COOLDOWN_ON_UNHOOK        0x0001
#define HS_FLAG_GLOW_HACK                 0x0002

public void Chain_Activate(int client, char abilityName[255])
{
    float velocity = CF_GetArgF(client, LAW, abilityName, "velocity", 900.0);
    float gravity  = CF_GetArgF(client, LAW, abilityName, "gravity", 1.5);
    float maxAng   = CF_GetArgF(client, LAW, abilityName, "max_angle", -20.0);
    float gravTime = CF_GetArgF(client, LAW, abilityName, "gravity_delay", 0.8);

    float eyeAng[3], vel[3];
    GetClientEyeAngles(client, eyeAng);
    if (eyeAng[0] > maxAng)
        eyeAng[0] = maxAng;

    GetVelocityInDirection(eyeAng, velocity, vel);

    int chain = CF_FireGenericRocket(client, 0.0, velocity, _, _, LAW, Chain_OnHit);
    if (IsValidEntity(chain))
    {
        float pos[3];
        GetEntPropVector(chain, Prop_Send, "m_vecOrigin", pos);

        Chain_Duration[chain]     = CF_GetArgF(client, LAW, abilityName, "duration", 4.0);
        Chain_Radius[chain]       = CF_GetArgF(client, LAW, abilityName, "radius", 250.0);
        Chain_Damage[chain]       = CF_GetArgF(client, LAW, abilityName, "damage", 40.0);
        Chain_IgnoreWeight[chain] = CF_GetArgF(client, LAW, abilityName, "ignore_weight_amt", 0.5);
        Chain_Durability[chain]   = CF_GetArgF(client, LAW, abilityName, "durability", 200.0);
        Chain_PullForce[chain]    = CF_GetArgF(client, LAW, abilityName, "pull_force", 800.0);
        Chain_HSpeed[chain]       = CF_GetArgF(client, LAW, abilityName, "pull_horizontalspeed", 800.0);
        Chain_VDeg[chain]         = CF_GetArgF(client, LAW, abilityName, "pull_verticaldeg", 0.8);
        Chain_Elasticity[chain]   = CF_GetArgF(client, LAW, abilityName, "pull_elasticity", 0.5);
        Chain_Distance[chain]     = CF_GetArgF(client, LAW, abilityName, "distance", 120.0);

        TFTeam team               = TF2_GetClientTeam(client);

        if (gravTime <= 0.0)
        {
            SetEntityMoveType(chain, MOVETYPE_FLYGRAVITY);
            SetEntityGravity(chain, gravity);
        }
        else
        {
            DataPack pack = new DataPack();
            CreateDataTimer(gravTime, Chain_ApplyGravity, pack, TIMER_FLAG_NO_MAPCHANGE);
            WritePackCell(pack, EntIndexToEntRef(chain));
            WritePackFloat(pack, gravTime);
        }

        SetEntityModel(chain, MODEL_DRG);
        AttachParticleToEntity(chain, team == TFTeam_Red ? PARTICLE_CHAIN_RED : PARTICLE_CHAIN_BLUE, "");

        TeleportEntity(chain, _, _, vel);

        int r = 255;
        int b = 120;
        if (team == TFTeam_Blue)
        {
            b = 255;
            r = 120;
        }

        int start, end;
        int beam               = CreateEnvBeam(client, chain, _, pos, "effect_hand_R", _, start, end, r, 120, b, 255, MODEL_CHAIN, 18.0, 18.0, _, 4.0);

        i_ChainStartEnt[chain] = EntIndexToEntRef(start);
        i_ChainEndEnt[chain]   = EntIndexToEntRef(end);
        i_ChainBeamEnt[chain]  = EntIndexToEntRef(beam);

        DataPack pack          = new DataPack();
        RequestFrame(Chain_CheckProjectileLOS, pack);
        WritePackCell(pack, EntIndexToEntRef(chain));
        WritePackCell(pack, EntIndexToEntRef(beam));
        WritePackCell(pack, EntIndexToEntRef(start));
        WritePackCell(pack, EntIndexToEntRef(end));
        WritePackCell(pack, GetClientUserId(client));

        CF_SimulateSpellbookCast(client);
        CF_ForceGesture(client);
        EmitSoundToAll(SOUND_CHAIN_REEL_LOOP, client);
        EmitSoundToAll(SOUND_CHAIN_THROW, client);

        Chain_Owner[chain]         = GetClientUserId(client);
        b_IsChainProjectile[chain] = true;
        strcopy(s_ChainAbName[chain], 255, abilityName);

        CF_PlayRandomSound(client, client, "sound_chain_throw");
    }
}

public Action Chain_ApplyGravity(Handle timer, DataPack pack)
{
    ResetPack(pack);
    int   chain   = EntRefToEntIndex(ReadPackCell(pack));
    float gravity = ReadPackFloat(pack);

    if (IsValidEntity(chain))
    {
        SetEntityMoveType(chain, MOVETYPE_FLYGRAVITY);
        SetEntityGravity(chain, gravity);
    }

    return Plugin_Continue;
}

public void Chain_CheckProjectileLOS(DataPack pack)
{
    ResetPack(pack);
    int chain  = EntRefToEntIndex(ReadPackCell(pack));
    int beam   = EntRefToEntIndex(ReadPackCell(pack));
    int start  = EntRefToEntIndex(ReadPackCell(pack));
    int end    = EntRefToEntIndex(ReadPackCell(pack));
    int client = GetClientOfUserId(ReadPackCell(pack));

    if (!IsValidEntity(chain) || !IsValidMulti(client))
    {
        Chain_Break(beam, start, end, client, -1, false, false);
        delete pack;
        return;
    }

    /*float startPos[3], endPos[3];
    GetClientEyePosition(client, startPos);
    CF_WorldSpaceCenter(end, endPos);
    if (!CF_HasLineOfSight(startPos, endPos) || CF_IsEntityInSpawn(client, TF2_GetClientTeam(client)))
    {
        Chain_Break(beam, start, end, client, -1);
        delete pack;
        RemoveEntity(chain);
        if (CF_IsEntityInSpawn(client, TF2_GetClientTeam(client)))
            PrintCenterText(client, "Your chain broke because you entered spawn!");
        else
            PrintCenterText(client, "Your chain broke because you broke line-of-sight!");

        return;
    }*/

    float amp = GetEntPropFloat(beam, Prop_Data, "m_fAmplitude");
    if (amp > 0.0)
    {
        amp -= 0.2;
        if (amp < 0.0)
            amp = 0.0;
        SetEntPropFloat(beam, Prop_Data, "m_fAmplitude", amp);
    }

    RequestFrame(Chain_CheckProjectileLOS, pack);
}

public void Chain_OnHit(int entity, int owner, int team, int other, float pos[3])
{
    StopSound(owner, SNDCHAN_AUTO, SOUND_CHAIN_REEL_LOOP);

    int beam  = EntRefToEntIndex(i_ChainBeamEnt[entity]);
    int start = EntRefToEntIndex(i_ChainStartEnt[entity]);
    int end   = EntRefToEntIndex(i_ChainEndEnt[entity]);
    if (IsValidEntity(beam))
        RemoveEntity(beam);
    if (IsValidEntity(start))
        RemoveEntity(start);
    if (IsValidEntity(end))
        RemoveEntity(end);

    RemoveEntity(entity);

    if (IsValidMulti(other, true, true, true, grabEnemyTeam(owner)))
    {
        SDKHooks_TakeDamage(other, entity, owner, Chain_Damage[entity], DMG_PREVENT_PHYSICS_FORCE);
        if (!IsPlayerAlive(other))
        {
            CF_ChangeAbilityTitle(owner, CF_GetAbilitySlot(owner, LAW, s_ChainAbName[entity]), "Arrest");
            CF_ApplyAbilityCooldown(owner, CF_GetArgF(owner, LAW, s_ChainAbName[entity], "cooldown", 9.0), CF_GetAbilitySlot(owner, LAW, s_ChainAbName[entity]), true);
            return;
        }

        int r = 255;
        int b = 120;
        if (view_as<TFTeam>(team) == TFTeam_Blue)
        {
            b = 255;
            r = 120;
        }

        beam          = CreateEnvBeam(owner, other, _, _, "effect_hand_R", "effect_hand_L", start, end, r, 120, b, 255, MODEL_CHAIN, 18.0, 18.0);

        DataPack pack = new DataPack();
        RequestFrame(Chain_DragUser, pack);
        WritePackCell(pack, EntIndexToEntRef(beam));
        WritePackCell(pack, EntIndexToEntRef(start));
        WritePackCell(pack, EntIndexToEntRef(end));
        WritePackCell(pack, GetClientUserId(owner));
        WritePackCell(pack, GetClientUserId(other));
        WritePackFloat(pack, GetGameTime() + Chain_Duration[entity]);
        WritePackCell(pack, true);
        WritePackCell(pack, true);

        TF2_AddCondition(other, TFCond_LostFooting, TFCondDuration_Infinite, owner);

        int currentChain = Chain_GetChain(owner, other);
        if (IsValidEntity(currentChain))
            Chain_Break(currentChain, EntRefToEntIndex(i_ChainStartEnt[currentChain]), EntRefToEntIndex(i_ChainEndEnt[currentChain]), owner, other, false);

        Chain_Radius[beam]             = Chain_Radius[entity];
        Chain_Damage[beam]             = Chain_Damage[entity];
        Chain_IgnoreWeight[beam]       = Chain_IgnoreWeight[entity];
        Chain_Durability[beam]         = Chain_Durability[entity];
        Chain_PullForce[beam]          = Chain_PullForce[entity];
        Chain_HSpeed[beam]             = Chain_HSpeed[entity];
        Chain_VDeg[beam]               = Chain_VDeg[entity];
        Chain_Elasticity[beam]         = Chain_Elasticity[entity];
        Chain_Distance[beam]           = Chain_Distance[entity];
        Chain_CanBeYanked[beam][other] = true;
        Chain_Chain[owner][other]      = EntIndexToEntRef(beam);

        Chain_Owner[beam]              = GetClientUserId(owner);

        Chain_LastCheckAt[beam]        = GetEngineTime();

        EmitSoundToClient(owner, SOUND_CHAIN_YANK, _, _, _, _, _, GetRandomInt(80, 120));
        EmitSoundToClient(other, SOUND_CHAIN_YANK, _, _, _, _, _, GetRandomInt(80, 120));
        int slot = GetRandomInt(0, sizeof(g_ChainAttachSounds) - 1);
        EmitSoundToClient(owner, g_ChainAttachSounds[slot], _, _, 120);
        EmitSoundToClient(other, g_ChainAttachSounds[slot], _, _, 120);
        EmitSoundToAll(SOUND_CHAIN_REEL_LOOP, owner, _, _, _, _, 115);
        EmitSoundToAll(SOUND_CHAIN_REEL_LOOP, other, _, _, _, _, 115);

        Shield_Holster(owner, false);

        CF_ChangeAbilityTitle(owner, CF_GetAbilitySlot(owner, LAW, s_ChainAbName[entity]), "Snap Handcuff");
        CF_ApplyAbilityCooldown(owner, 0.5, CF_GetAbilitySlot(owner, LAW, s_ChainAbName[entity]), true);

        strcopy(s_ChainAbName[owner], 255, s_ChainAbName[entity]);
    }
    else
    {
        CF_ChangeAbilityTitle(owner, CF_GetAbilitySlot(owner, LAW, s_ChainAbName[entity]), "Arrest");
        CF_ApplyAbilityCooldown(owner, CF_GetArgF(owner, LAW, s_ChainAbName[entity], "cooldown_miss", 9.0), CF_GetAbilitySlot(owner, LAW, s_ChainAbName[entity]), true);
    }
}

public int Chain_GetChain(int client, int victim)
{
    return (Chain_Chain[client][victim] ? EntRefToEntIndex(Chain_Chain[client][victim]) : -1);
}

void Chain_Break(int beam, int start, int end, int client, int victim, bool sound = true, bool cooldown = true)
{
    if (IsValidEntity(beam))
    {
        Chain_Owner[beam] = -1;
        SetEntityRenderColor(beam, 255, 255, 255, 255);
    }

    Core_RemoveBeamEffect(beam, start, end, true);

    if (sound)
    {
        if (IsValidClient(client))
        {
            StopSound(client, SNDCHAN_AUTO, SOUND_CHAIN_REEL_LOOP);
            EmitSoundToClient(client, SOUND_CHAIN_BREAK_1, _, _, _, _, _, GetRandomInt(90, 110));
            EmitSoundToClient(client, SOUND_CHAIN_BREAK_2, _, _, _, _, _, 80);
        }
        if (IsValidClient(victim))
        {
            StopSound(victim, SNDCHAN_AUTO, SOUND_CHAIN_REEL_LOOP);
            EmitSoundToClient(victim, SOUND_CHAIN_BREAK_1, _, _, _, _, _, GetRandomInt(90, 110));
            EmitSoundToClient(victim, SOUND_CHAIN_BREAK_2, _, _, _, _, _, 80);
        }
    }

    if (IsValidClient(client) && IsValidClient(victim))
        Chain_Chain[client][victim] = -1;

    if (IsValidMulti(client) && cooldown)
    {
        CF_ChangeAbilityTitle(client, CF_GetAbilitySlot(client, LAW, s_ChainAbName[client]), "Arrest");
        CF_ApplyAbilityCooldown(client, CF_GetArgF(client, LAW, s_ChainAbName[client], "cooldown", 9.0), CF_GetAbilitySlot(client, LAW, s_ChainAbName[client]), true);
    }

    if (IsValidMulti(victim))
        TF2_RemoveCondition(victim, TFCond_LostFooting);
}

public void Chain_DragUser(DataPack pack)
{
    ResetPack(pack);
    int   beam      = EntRefToEntIndex(ReadPackCell(pack));
    int   start     = EntRefToEntIndex(ReadPackCell(pack));
    int   end       = EntRefToEntIndex(ReadPackCell(pack));
    int   client    = GetClientOfUserId(ReadPackCell(pack));
    int   victim    = GetClientOfUserId(ReadPackCell(pack));
    float endTime   = ReadPackFloat(pack);
    bool  isPulling = ReadPackCell(pack);
    bool forceYank = ReadPackCell(pack);

    float gt        = GetGameTime();

    if (!IsValidMulti(client) || !IsValidMulti(victim) || !IsValidEntity(beam) || gt >= endTime || Chain_Owner[beam] != GetClientUserId(client))
    {
        Chain_Break(beam, start, end, client, victim);
        delete pack;
        return;
    }

    float startPos[3], myPos[3], theirPos[3], ang[3];
    GetClientEyePosition(client, startPos);
    GetClientEyeAngles(client, ang);
    GetPointInDirection(startPos, ang, Chain_Distance[beam], myPos);
    CF_HasLineOfSight(startPos, myPos, _, myPos);

    CF_WorldSpaceCenter(end, theirPos);

    /*if (!CF_HasLineOfSight(myPos, theirPos) || CF_IsEntityInSpawn(client, TF2_GetClientTeam(client)))
    {
        Chain_Break(beam, start, end, client, victim);
        delete pack;

        if (CF_IsEntityInSpawn(client, TF2_GetClientTeam(client)))
            PrintCenterText(client, "Your chain broke because you entered spawn!");
        else
            PrintCenterText(client, "Your chain broke because you broke line-of-sight!");

        return;
    }*/

    Chain_ManageVFX(client, beam, myPos, theirPos);

    bool canPull = CF_HasLineOfSight(myPos, theirPos) && !CF_IsEntityInSpawn(client, TF2_GetClientTeam(client));

    CF_WorldSpaceCenter(victim, theirPos);
    float distance = GetVectorDistance(myPos, theirPos);
    if (canPull)
        canPull = distance >= Chain_Radius[beam];

    if (isPulling)
    {
        if (!canPull)
        {
            StopSound(client, SNDCHAN_AUTO, SOUND_CHAIN_REEL_LOOP);
            StopSound(victim, SNDCHAN_AUTO, SOUND_CHAIN_REEL_LOOP);
            isPulling = false;
        }
        else
        {
            float checkDelta = GetEngineTime() - Chain_LastCheckAt[beam];
            float absOr[3];
            GetClientAbsOrigin(victim, absOr);

            float weightMult         = 1.0 - (CF_GetCharacterWeight(victim) * (1.0 - Chain_IgnoreWeight[beam]));

            Chain_ReelDistance[beam] = fmax(HS_MIN_LENGTH, Chain_ReelDistance[beam] - (checkDelta * Chain_PullForce[beam]));

            float excessDistance     = distance - Chain_ReelDistance[beam];
            float limpDistance       = Chain_ReelDistance[beam] - distance;

            if (checkDelta >= HS_CHECK_INTERVAL && limpDistance < HS_LIMP_MIN_DISTANCE)
            {
                float currentVel[3], targetVel[3];
                GetEntPropVector(victim, Prop_Data, "m_vecVelocity", currentVel);
                targetVel = currentVel;

                if (targetVel[2] < 0 && excessDistance > 0.0)
                    targetVel[2] *= Chain_VDeg[beam];
                {
                    float adjustedPos[3];
                    adjustedPos[0] = absOr[0];
                    adjustedPos[1] = absOr[1];
                    adjustedPos[2] = 0.0;

                    float adjustedTargetPos[3];
                    adjustedTargetPos[0] = myPos[0];
                    adjustedTargetPos[1] = myPos[1];
                    adjustedTargetPos[2] = 0.0;

                    // get our velocity vector and normalize it
                    float elasticVelocity[3];
                    MakeVectorFromPoints(absOr, myPos, elasticVelocity);
                    NormalizeVector(elasticVelocity, elasticVelocity);

                    // the pull in HUPS factors in the length of the rope. if I used a static speed,
                    // the physics would seem screwy with long vs. short ropes
                    for (int axis = 0; axis <= 1; axis++)
                    {
                        elasticVelocity[axis] *= ((Chain_HSpeed[beam] * Chain_ReelDistance[beam]) * checkDelta);

                        // add this to the player's current velocity. no limits.
                        targetVel[axis] += elasticVelocity[axis];
                    }
                }

                if (excessDistance > 0.0)
                {
                    // persuade the boss' position in the direction of the hook
                    // unlike the player motion velocity, there are no limits.
                    float elasticVelocity[3];
                    MakeVectorFromPoints(absOr, myPos, elasticVelocity);
                    NormalizeVector(elasticVelocity, elasticVelocity);

                    // our fun little equation for the velocity modifier
                    for (int axis = 0; axis <= 2; axis++)
                    {
                        elasticVelocity[axis] *= Chain_Elasticity[beam] * ((excessDistance / HS_ELASTIC_BASE_DISTANCE) * checkDelta * HS_DEFAULT_ELASTIC_INTENSITY);

                        // add this to the player's current velocity. no limits.
                        targetVel[axis] += elasticVelocity[axis];
                    }
                }

                // apply the changes to player velocity

                for (int vec = 0; vec < 3; vec++)
                {
                    currentVel[vec] += (targetVel[vec] - currentVel[vec]) * weightMult;
                }

                // If our victim is on the ground: let the user flick up to yank them into the air
                if ((GetEntityFlags(victim) & FL_ONGROUND != 0 && ang[0] <= -40.0) || forceYank)
                {
                    EmitSoundToClient(client, SOUND_CHAIN_YANK, _, _, _, _, _, GetRandomInt(80, 120));
                    EmitSoundToClient(victim, SOUND_CHAIN_YANK, _, _, _, _, _, GetRandomInt(80, 120));
                    int slot = GetRandomInt(0, sizeof(g_ChainAttachSounds) - 1);
                    EmitSoundToClient(client, g_ChainAttachSounds[slot], _, _, 120);
                    EmitSoundToClient(victim, g_ChainAttachSounds[slot], _, _, 120);

                    currentVel[2] = fmax(currentVel[2], 310.0);

                    if (!b_CannotWalk[victim])
                    {
                        TF2_AddCondition(victim, TFCond_GrappledToPlayer, TFCondDuration_Infinite, client);
                        TF2_AddCondition(victim, TFCond_GrappledByPlayer, TFCondDuration_Infinite, client);

                        b_CannotWalk[victim] = true;
                        f_CannotWalkCheckTime[victim] = GetGameTime() + 0.25;
                        RequestFrame(Chain_AllowWalk, GetClientUserId(victim));

                        int wearable = EntRefToEntIndex(i_GrabWearable[victim]);
                        if (IsValidEntity(wearable))
                        {
                            TF2_RemoveWearable(victim, wearable);
                        }

                        i_GrabWearable[victim] = EntIndexToEntRef(CF_AttachWearable(victim, 777, "tf_wearable", false, 0, 0, _, "610 ; -1000.0"));
                    }
                }

                SetEntPropVector(victim, Prop_Data, "m_vecVelocity", currentVel);
                TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, currentVel);

                // finally, schedule the next check
                Chain_LastCheckAt[beam] = GetEngineTime();
            }
        }
    }
    else if (canPull)
    {
        EmitSoundToAll(SOUND_CHAIN_REEL_LOOP, client, _, _, _, _, 115);
        EmitSoundToAll(SOUND_CHAIN_REEL_LOOP, victim, _, _, _, _, 115);
        EmitSoundToClient(client, SOUND_CHAIN_YANK, _, _, _, _, _, GetRandomInt(80, 120));
        EmitSoundToClient(victim, SOUND_CHAIN_YANK, _, _, _, _, _, GetRandomInt(80, 120));

        Chain_LastCheckAt[beam] = GetEngineTime();

        isPulling               = true;
    }

    delete pack;
    pack = new DataPack();
    RequestFrame(Chain_DragUser, pack);
    WritePackCell(pack, EntIndexToEntRef(beam));
    WritePackCell(pack, EntIndexToEntRef(start));
    WritePackCell(pack, EntIndexToEntRef(end));
    WritePackCell(pack, GetClientUserId(client));
    WritePackCell(pack, GetClientUserId(victim));
    WritePackFloat(pack, endTime);
    WritePackCell(pack, isPulling);
    WritePackCell(pack, false);
}

public void Chain_AllowWalk(int id)
{
    int client = GetClientOfUserId(id);
    if (!IsValidMulti(client))
        return;

    if (GetEntityFlags(client) & FL_ONGROUND != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1 && GetGameTime() >= f_CannotWalkCheckTime[client])
    {
        b_CannotWalk[client] = false;
        TF2_RemoveCondition(client, TFCond_GrappledToPlayer);
        TF2_RemoveCondition(client, TFCond_GrappledByPlayer);
        int wearable = EntRefToEntIndex(i_GrabWearable[client]);
        if (IsValidEntity(wearable))
        {
            TF2_RemoveWearable(client, wearable);
        }
        return;
    }

    RequestFrame(Chain_AllowWalk, id);
}

public void Chain_ManageVFX(int client, int beam, float myPos[3], float theirPos[3])
{
    TFTeam team = TF2_GetClientTeam(client);

    int    r, g, b, a;
    GetEntityRenderColor(beam, r, g, b, a);

    // ugly ass code but who cares
    int targetR = 255;
    int targetB = 120;
    if (team == TFTeam_Blue)
    {
        targetR = 120;
        targetB = 255;
    }
    int targetA = 200;

    if (a > targetA)
    {
        a -= 4;
        if (a < targetA)
            a = targetA;
    }

    if (r > targetR)
    {
        r -= 8;
        if (r < targetR)
            r = targetR;
    }

    if (g > 120)
    {
        g -= 8;
        if (g < 120)
            g = 120;
    }

    if (b > targetB)
    {
        b -= 8;
        if (b < targetB)
            b = targetB;
    }

    SetEntityRenderColor(beam, r, g, b, a);

    float amplitude = GetEntPropFloat(beam, Prop_Data, "m_fAmplitude");
    if (amplitude > 0.0)
    {
        amplitude -= 0.15;
        if (amplitude < 0.0)
            amplitude = 0.0;

        SetEntPropFloat(beam, Prop_Data, "m_fAmplitude", amplitude);
    }

    float dist  = GetVectorDistance(myPos, theirPos);
    float width = ClampFloat(24.0 - (18.0 * (dist / Chain_Radius[beam])), 6.0, 18.0);

    SetEntPropFloat(beam, Prop_Data, "m_fWidth", width);
    SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", width);
}

public void Chain_ClearAll(int client)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client || IsValidMulti(i, false, _, true, TF2_GetClientTeam(client)) || !IsValidClient(i))
            continue;

        int chain = Chain_GetChain(client, i);
        if (IsValidEntity(chain))
            Chain_Break(chain, EntRefToEntIndex(i_ChainStartEnt[chain]), EntRefToEntIndex(i_ChainEndEnt[chain]), client, i);

        chain = Chain_GetChain(i, client);
        if (IsValidEntity(chain))
            Chain_Break(chain, EntRefToEntIndex(i_ChainStartEnt[chain]), EntRefToEntIndex(i_ChainEndEnt[chain]), i, client);
    }
}

public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
    if (!IsValidClient(attacker))
        return Plugin_Continue;

    if (IsValidEntity(Chain_GetChain(attacker, victim)))
    {
        CF_PlayRandomSound(attacker, attacker, "sound_kill_chain");
        CF_SilenceCharacter(attacker, 1.0);
    }

    return Plugin_Continue;
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
    if (!StrEqual(pluginName, LAW))
        return;

    if (StrEqual(abilityName, SHIELD))
    {
        if (!b_ShieldHeld[client])
        {
            Shield_Deploy(client);
            CF_ChangeAbilityTitle(client, CF_GetAbilitySlot(client, LAW, abilityName), "Holster Riot Shield");
            CF_ApplyAbilityCooldown(client, 0.0, CF_GetAbilitySlot(client, LAW, abilityName), true);
        }
        else
            Shield_Holster(client, false);
    }

    if (StrContains(abilityName, PROTECT) != -1)
    {
        if (!Protect_Active[client])
        {
            Protect_Begin(client, abilityName);
            CF_ChangeAbilityTitle(client, CF_GetAbilitySlot(client, LAW, abilityName), "Exit Protective Custody");
            CF_ApplyAbilityCooldown(client, 0.0, CF_GetAbilitySlot(client, LAW, abilityName), true);
        }
        else
        {
            Protect_ClearClient(client);
            CF_PlayRandomSound(client, client, "sound_custody_end");
            Protect_Active[client] = false;
            CF_ChangeAbilityTitle(client, CF_GetAbilitySlot(client, LAW, abilityName), "Enter Protective Custody");
        }
    }

    if (StrContains(abilityName, CHAIN) != -1)
    {
        bool AtLeastOne = false;
        for (int i = 1; i <= MaxClients; i++)
        {
            int chain = Chain_GetChain(client, i);
            if (IsValidEntity(chain))
            {
                Chain_Break(chain, EntRefToEntIndex(i_ChainStartEnt[chain]), EntRefToEntIndex(i_ChainEndEnt[chain]), client, i);
                AtLeastOne = true;
            }
        }

        if (AtLeastOne)
        {
            CF_ChangeAbilityTitle(client, CF_GetAbilitySlot(client, LAW, abilityName), "Arrest");
            CF_ApplyAbilityCooldown(client, CF_GetArgF(client, LAW, abilityName, "cooldown", 9.0), CF_GetAbilitySlot(client, LAW, abilityName), true);
        }
        else
        {
            Chain_Activate(client, abilityName);
        }
    }

    if (StrContains(abilityName, RIOT) != -1)
        Riot_Activate(client, abilityName);
}

public void CF_OnHeldEnd_Ability(int client, bool resupply, char pluginName[255], char abilityName[255])
{
    if (!StrEqual(pluginName, LAW))
        return;

    if (StrEqual(abilityName, SHIELD))
    {
        Shield_Holster(client, resupply);
        CF_ChangeAbilityTitle(client, CF_GetAbilitySlot(client, LAW, abilityName), "Deploy Riot Shield");
    }

    if (StrContains(abilityName, PROTECT) != -1)
    {
        Protect_ClearClient(client);
        if (Protect_Active[client])
            CF_PlayRandomSound(client, client, "sound_custody_end");
        Protect_Active[client] = false;
        CF_ChangeAbilityTitle(client, CF_GetAbilitySlot(client, LAW, abilityName), "Enter Protective Custody");
    }
}

public void CF_OnCharacterCreated(int client)
{
    b_ShieldActive[client] = CF_HasAbility(client, LAW, SHIELD);
    Shield_EndRegenLoop(client);
    if (b_ShieldActive[client])
        Shield_Prepare(client);
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
    if (reason == CF_CRR_DEATH || reason == CF_CRR_DISCONNECT || reason == CF_CRR_ROUNDSTATE_CHANGED || reason == CF_CRR_SWITCHED_CHARACTER)
    {
        Core_Cleanup(client);
    }

    Shield_EndRegenLoop(client);
}

public void Core_Cleanup(int client)
{
    Shield_Holster(client, true, false);
    Protect_ClearClient(client);
    Protect_ClearProtectors(client);
    Protect_Active[client] = false;
    Chain_ClearAll(client);
    b_CannotWalk[client] = false;
    int wearable = EntRefToEntIndex(i_GrabWearable[client]);
    if (IsValidEntity(wearable))
    {
        TF2_RemoveWearable(client, wearable);
    }
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
    if (!StrEqual(plugin, LAW))
        return Plugin_Continue;

    if (StrContains(ability, SHIELD) != -1)
    {
        result = (b_ShieldActive[client] && f_ShieldHealth[client] > 0.0);
        if (result)
        {
            for (int i = 1; i <= MaxClients; i++)
            {
                int chain = Chain_GetChain(client, i);
                if (IsValidEntity(chain))
                {
                    result = false;
                    break;
                }
            }
        }
        return Plugin_Changed;
    }
    else if (b_ShieldHeld[client] && StrContains(ability, PROTECT) == -1 && StrContains(ability, RIOT) == -1)
    {
        result = false;
        return Plugin_Changed;
    }

    if (StrContains(ability, CHAIN) != -1)
    {
        if (CF_IsEntityInSpawn(client, TF2_GetClientTeam(client)))
        {
            result = false;
            return Plugin_Changed;
        }
        
        for (int i = 1; i < 2048; i++)
        {
            if (!b_IsChainProjectile[i])
                continue;

            int owner = GetClientOfUserId(Chain_Owner[i]);
            if (owner == client)
            {
                result = false;
                return Plugin_Changed;
            }
        }

        return Plugin_Continue;
    }

    return Plugin_Continue;
}

public void CF_OnHUDDisplayed(int client, char HUDText[255], int &r, int &g, int &b, int &a)
{
    if (!b_ShieldActive[client])
        return;

    Format(HUDText, sizeof(HUDText), "Riot Shield HP: %i/%i\n%s", RoundToFloor(f_ShieldHealth[client]), RoundToFloor(f_ShieldMaxHealth[client]), HUDText);
}

public Action CF_OnCalcAttackInterval(int client, int weapon, int slot, char classname[255], float &rate)
{
    if (!b_ShieldHeld[client])
        return Plugin_Continue;

    rate *= f_ShieldAtkSpeed[client];
    return Plugin_Changed;
}

public void OnEntityDestroyed(int entity)
{
    if (entity < 0 || entity >= 2048)
        return;

    if (!StrEqual(s_RiotShieldLoopSound[entity], ""))
    {
        StopSound(entity, SNDCHAN_AUTO, s_RiotShieldLoopSound[entity]);
        strcopy(s_RiotShieldLoopSound[entity], 255, "");
    }

    // This should only happen if the shield is removed by external means, such as the round ending:
    int owner = GetClientOfUserId(i_ShieldOwner[entity]);
    if (IsValidClient(owner) && b_ShieldHeld[owner] && b_ThisShieldIsHeld[entity])
    {
        Shield_Holster(owner, false, true);
    }

    b_BeamFadingIn[entity]      = false;
    b_BeamActive[entity]        = false;
    b_IsChainProjectile[entity] = false;

    if (Chain_Owner[entity] != -1)
    {
        owner = GetClientOfUserId(Chain_Owner[entity]);
        if (IsValidClient(owner))
            StopSound(owner, SNDCHAN_AUTO, SOUND_CHAIN_REEL_LOOP);
    }

    Chain_Owner[entity]        = -1;
    i_ShieldOwner[entity]      = -1;
    SDKUnhook(entity, SDKHook_TouchPost, Shield_OnTouch);
}

public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
    if (!IsValidClient(victim) || g_Protectors[victim] == null || GetArraySize(g_Protectors[victim]) < 1)
        return Plugin_Continue;

    for (int i = 0; i < GetArraySize(g_Protectors[victim]); i++)
    {
        int protector = GetClientOfUserId(GetArrayCell(g_Protectors[victim], i));
        if (!IsValidClient(protector))
            continue;

        int beam = EntRefToEntIndex(Protect_Beam[victim][protector]);
        if (IsValidEntity(beam))
        {
            SetEntityRenderColor(beam, 255, 255, 255, 255);
            SetEntPropFloat(beam, Prop_Data, "m_fAmplitude", ClampFloat(damage / 50.0, 1.0, 6.0));
        }

        float originalDmg = damage;
        damage *= 1.0 - Protect_Amt[protector];

        float amtBlocked   = originalDmg - damage;

        float damageToTake = amtBlocked * (1.0 - Protect_IgnoreAmt[protector]);

        if (b_ShieldHeld[protector])
        {
            originalDmg = damageToTake;
            damageToTake *= 1.0 - Protect_ShieldAmt[protector];

            float shieldDmg = originalDmg - damageToTake;

            Shield_TakeDamage(EntRefToEntIndex(i_Shield[protector]), shieldDmg, protector, attacker, inflictor, damagetype);
        }

        CF_GiveUltCharge(protector, amtBlocked * Protect_UltGain[protector]);

        float protHP = float(GetEntProp(protector, Prop_Send, "m_iHealth"));
        if (damageToTake >= protHP)
            damageToTake = protHP - 1.0;
        SDKHooks_TakeDamage(protector, inflictor, attacker, damageToTake, damagetype, weapon, damageForce, damagePosition);

        EmitSoundToClient(protector, SOUND_PROTECT_BLOCKDAMAGE, _, _, _, _, _, 120 - RoundFloat(ClampFloat((damage / 2.0) - 40.0, 0.0, 40.0)));

        if (g_Protectors[victim] == null)
            break;
    }

    EmitSoundToClient(victim, SOUND_PROTECT_BLOCKDAMAGE, _, _, _, _, _, 120 - RoundFloat(ClampFloat((damage / 2.0) - 40.0, 0.0, 40.0)));
    EmitSoundToClient(attacker, SOUND_PROTECT_BLOCKDAMAGE, _, _, _, _, _, 120 - RoundFloat(ClampFloat((damage / 2.0) - 40.0, 0.0, 40.0)));

    return Plugin_Changed;
}

public Action CF_OnTakeDamageAlive_Post(int victim, int attacker, int inflictor, float damage, int weapon)
{
    if (!IsValidMulti(victim))
        return Plugin_Continue;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == victim || IsValidMulti(i, false, _, true, TF2_GetClientTeam(victim)))
            continue;

        int chain = Chain_GetChain(victim, i);
        if (IsValidEntity(chain))
        {
            Chain_Durability[chain] -= damage;
            if (Chain_Durability[chain] <= 0.0)
                Chain_Break(chain, EntRefToEntIndex(i_ChainStartEnt[chain]), EntRefToEntIndex(i_ChainEndEnt[chain]), victim, i);
            else
            {
                SetEntityRenderColor(chain, 255, 255, 255, 255);
                SetEntPropFloat(chain, Prop_Data, "m_fAmplitude", ClampFloat(damage / 50.0, 1.0, 6.0));

                int slot = GetRandomInt(0, sizeof(g_ChainDamagedSounds) - 1);
                EmitSoundToClient(victim, g_ChainDamagedSounds[slot], _, _, 120, _, _, 120 - RoundFloat(ClampFloat((Chain_Durability[chain] / 200.0) * 60.0, 0.0, 60.0)));
                EmitSoundToClient(i, g_ChainDamagedSounds[slot], _, _, 120, _, _, 120 - RoundFloat(ClampFloat((Chain_Durability[chain] / 200.0) * 60.0, 0.0, 60.0)));
            }
        }
    }

    if (IsValidEntity(weapon))
    {
        float vel = TF2CustAttr_GetFloat(weapon, "law knockback velocity", 0.0);
        if (vel > 0.0)
        {
            float ang[3];
            GetClientEyeAngles(attacker, ang);
            CF_ApplyKnockback(victim, vel, ang, _, _, true);
        }
    }

    return Plugin_Continue;
}

void Core_RemoveBeamEffect(int beam, int startEnt, int endEnt, bool spazOut = false)
{
    if (IsValidEntity(beam))
    {
        MakeEntityFadeOut(beam, 16);
        if (spazOut && GetEntPropFloat(beam, Prop_Data, "m_fAmplitude") < 4.0)
            SetEntPropFloat(beam, Prop_Data, "m_fAmplitude", 4.0);
    }

    if (IsValidEntity(startEnt))
    {
        SetParent(startEnt, startEnt);
        CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(startEnt), TIMER_FLAG_NO_MAPCHANGE);
    }

    if (IsValidEntity(endEnt))
    {
        SetParent(endEnt, endEnt);
        CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(endEnt), TIMER_FLAG_NO_MAPCHANGE);
    }
}