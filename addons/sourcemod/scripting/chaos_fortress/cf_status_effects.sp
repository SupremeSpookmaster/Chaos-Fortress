GlobalForward g_OnStatusEffectApplied_Pre, g_OnStatusEffectApplied_Post, g_OnStatusEffectRemoved, g_OnStatusEffectActiveValueChanged_Pre, g_OnStatusEffectActiveValueChanged_Post;

public void CFSE_MakeForwards()
{
    g_OnStatusEffectApplied_Pre = new GlobalForward("CF_OnStatusEffectApplied_Pre", ET_Event, Param_Cell, Param_String, Param_Cell, Param_CellByRef);
    g_OnStatusEffectApplied_Post = new GlobalForward("CF_OnStatusEffectApplied_Post", ET_Ignore, Param_Cell, Param_String, Param_Cell);

    g_OnStatusEffectRemoved = new GlobalForward("CF_OnStatusEffectRemoved", ET_Ignore, Param_Cell, Param_String, Param_Cell);

    g_OnStatusEffectActiveValueChanged_Pre = new GlobalForward("CF_OnStatusEffectActiveValueChanged_Pre", ET_Event, Param_Cell, Param_String, Param_Cell, Param_Float, Param_FloatByRef, Param_CellByRef);
    g_OnStatusEffectActiveValueChanged_Post = new GlobalForward("CF_OnStatusEffectActiveValueChanged_Post", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Float);
}

public void CFSE_MakeNatives()
{
    CreateNative("CF_HasStatusEffect", Native_CF_HasStatusEffect);
    CreateNative("CF_ApplyStatusEffect", Native_CF_ApplyStatusEffect);
    CreateNative("CF_RemoveStatusEffect", Native_CF_RemoveStatusEffect);
    CreateNative("CF_RemoveAllPositiveEffects", Native_CF_RemoveAllPositiveEffects);
    CreateNative("CF_RemoveAllNegativeEffects", Native_CF_RemoveAllNegativeEffects);
    CreateNative("CF_RemoveAllStatusEffects", Native_CF_RemoveAllStatusEffects);
    CreateNative("CF_GetStatusEffectArgF", Native_CF_GetStatusEffectArgF);
    CreateNative("CF_GetStatusEffectArgI", Native_CF_GetStatusEffectArgI);
    CreateNative("CF_GetStatusEffectArgB", Native_CF_GetStatusEffectArgB);
    CreateNative("CF_GetStatusEffectArgS", Native_CF_GetStatusEffectArgS);
    CreateNative("CF_GetStatusEffectActiveValue", Native_CF_GetStatusEffectActiveValue);
    CreateNative("CF_SetStatusEffectActiveValue", Native_CF_SetStatusEffectActiveValue);
    CreateNative("CF_GetStatusEffectApplicant", Native_CF_GetStatusEffectApplicant);
    CreateNative("CF_SetStatusEffectApplicant", Native_CF_SetStatusEffectApplicant);
    CreateNative("CF_GetStatusEffectEndTime", Native_CF_GetStatusEffectEndTime);
    CreateNative("CF_SetStatusEffectEndTime", Native_CF_SetStatusEffectEndTime);
}

ArrayList g_StatusNames;
ArrayList g_StatusTemplateArgs[2049];
ArrayList g_StatusTemplateValues[2049];

enum struct StatusInfo
{
    bool positive;
    bool allow_entities;

    void Create(bool pos, bool ents) { this.positive = pos; this.allow_entities = ents; }
    void RevertToDefault() { this.positive = false; this.allow_entities = false; }
}

StatusInfo g_StatusTemplates[2049];

ArrayList g_ActiveEffectNames[2049];
ArrayList g_ActiveEffectStats[2049];

//This will break if more than 2048 status effects are active at once. I do not expect this to ever happen in practice, so I'm not going to bother coming up with a more permanent solution.
bool b_ActiveEffectExists[2049] = { false, ... };

int i_ActiveEffectOwner[2049] = { -1, ... };
int i_ActiveEffectApplicant[2049] = { -1, ... };

float f_ActiveEffectActiveValue[2049] = { 0.0, ... };
float f_ActiveEffectEndTime[2049] = { 0.0, ... };

char s_CurrentChange[255];

bool DoNotCallActiveValueForwards = false;

methodmap CFStatusEffect __nullable__
{
	public CFStatusEffect()
	{
		for (int i = 1; i <= MAXPLAYERS; i++)
		{
			if (!b_ActiveEffectExists[i])
			{
				b_ActiveEffectExists[i] = true;
				return view_as<CFStatusEffect>(i);
			}
		}

		CPrintToChatAll("{red}TOO MANY STATUS EFFECTS ARE ACTIVE AT ONCE! THIS SHOULD NEVER HAPPEN, SEND A SCREENSHOT OF THIS TO A DEV!");
		return view_as<CFStatusEffect>(-1);
	}

    public void Destroy()
    {
        b_ActiveEffectExists[this.index] = false;
        i_ActiveEffectOwner[this.index] = -1;
        i_ActiveEffectApplicant[this.index] = -1;
        f_ActiveEffectActiveValue[this.index] = 0.0;
        f_ActiveEffectEndTime[this.index] = 0.0;
    }

    property int index
	{
		public get() { return view_as<int>(this); }
	}

    property int i_Owner
    {
        public get() { return EntRefToEntIndex(i_ActiveEffectOwner[this.index]); }
        public set(int value) { i_ActiveEffectOwner[this.index] = EntIndexToEntRef(value); }
    }

    property int i_Applicant
    {
        public get() { return EntRefToEntIndex(i_ActiveEffectApplicant[this.index]); }
        public set(int value) { i_ActiveEffectApplicant[this.index] = EntIndexToEntRef(value); }
    }

    property float f_ActiveValue
    {
        public get() { return f_ActiveEffectActiveValue[this.index]; }
        public set(float value)
        {
            if (!DoNotCallActiveValueForwards)
            {
                bool result = true;
                Action event;

                Call_StartForward(g_OnStatusEffectActiveValueChanged_Pre);

                Call_PushCell(this.i_Owner);
                Call_PushString(s_CurrentChange);
                Call_PushCell(this.i_Applicant);
                Call_PushFloat(this.f_ActiveValue);
                Call_PushFloatRef(value);
                Call_PushCellRef(result);

                Call_Finish(event);

                if (!result)
                    return;
            }
            
            f_ActiveEffectActiveValue[this.index] = value;

            if (!DoNotCallActiveValueForwards)
            {
                Call_StartForward(g_OnStatusEffectActiveValueChanged_Post);

                Call_PushCell(this.i_Owner);
                Call_PushString(s_CurrentChange);
                Call_PushCell(this.i_Applicant);
                Call_PushFloat(value);

                Call_Finish();
            }
        }
    }

    property float f_EndTime
    {
        public get() { return f_ActiveEffectEndTime[this.index]; }
        public set(float value) { f_ActiveEffectEndTime[this.index] = value; }
    }
}

public void CFSE_LoadStatusEffectsFromCharacter(ConfigMap Character)
{
    ConfigMap Effects = Character.GetSection("character.status_effects");
    if (Effects == null)
        return;

    StringMapSnapshot snap = Effects.Snapshot();
				
	for (int i = 0; i < snap.Length; i++)
	{
		char effectName[255];
		snap.GetKey(i, effectName, sizeof(effectName));

        //An effect with an identical name already exists, throw a warning and do not add it.
        if (CFSE_GetEffectSlot(effectName) >= 0)
        {
            char charName[128];
            Character.Get("character.name", charName, 128);
            PrintToServer("WARNING: Character ''%s'' attempts to add custom status effect ''%s'', but that status effect's name is already in use! Skipping this status effect.", charName, effectName);
            continue;
        }
					
		ConfigMap subsection = Effects.GetSection(effectName);
        if (subsection != null)
        {
            CFSE_AddStatusEffect(subsection, effectName);
        }
	}
			
	delete snap;
}

public void CFSE_AddStatusEffect(ConfigMap effect, char[] name)
{
    if (g_StatusNames == null)
        g_StatusNames = CreateArray(128);

    int slot = GetArraySize(g_StatusNames);
    PushArrayString(g_StatusNames, name);
    g_StatusTemplates[slot].Create(GetBoolFromCFGMap(effect, "positive", false), GetBoolFromCFGMap(effect, "allow_entities", true));

    #if defined DEBUG_STATUS_EFFECTS
    PrintToServer("ADDED STATUS EFFECT: %s", name);
    PrintToServer("     - Positive: %i", g_StatusTemplates[slot].positive);
    PrintToServer("     - Allows Entities: %i", g_StatusTemplates[slot].allow_entities);
    #endif

    ConfigMap custArgs = effect.GetSection("custom_args");
    if (custArgs != null)
    {
        StringMapSnapshot snap = custArgs.Snapshot();

        if (snap.Length > 0)
        {
            g_StatusTemplateArgs[slot] = CreateArray(128);
            g_StatusTemplateValues[slot] = CreateArray(128);
        }
				
        for (int i = 0; i < snap.Length; i++)
        {
            char argName[128], value[128];
            snap.GetKey(i, argName, sizeof(argName));
            custArgs.Get(argName, value, 128);

            PushArrayString(g_StatusTemplateArgs[slot], argName);
            PushArrayString(g_StatusTemplateValues[slot], value);

            #if defined DEBUG_STATUS_EFFECTS
            PrintToServer("     - ''%s''    ''%s''", argName, value);
            #endif
        }
                
        delete snap;
    }
}

public void CFSE_ClearStatusEffects()
{
    if (g_StatusNames == null)
        return;

    for (int i = 0; i < GetArraySize(g_StatusNames); i++)
    {
        g_StatusTemplates[i].RevertToDefault();
        delete g_StatusTemplateArgs[i];
        delete g_StatusTemplateValues[i];
    }

    delete g_StatusNames;

    for (int i = 0; i < 2049; i++)
        CFSE_RemoveAllEffectsFromEntity(i);
}

void CFSE_ApplyStatusToGroup(char[] status, TFTeam team, int applicant, float duration, bool actuallyRemovingItNotApplyingIt = false, float acVal = 0.0)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidMulti(i, true, true, team != TFTeam_Unassigned, team))
        {
            if (actuallyRemovingItNotApplyingIt)
                CF_RemoveStatusEffect(i, status);
            else
                CF_ApplyStatusEffect(i, status, duration, applicant, acVal, true, true);

            CFSE_TellAdmin(i, applicant, actuallyRemovingItNotApplyingIt, status, duration, acVal);
        }
    }
}

void CFSE_TellAdmin(int target, int admin, bool removed, char[] status, float duration, float acVal)
{
    if (removed)
        CPrintToChat(admin, "{indigo}[Chaos Fortress] {default}Removed {vintage}%s{default} from {yellow}%N{default}.", status, target);
    else
        CPrintToChat(admin, "{indigo}[Chaos Fortress] {default}Applied {vintage}%s{default} to {yellow}%N{default} for {orange}%.2f second(s){default}, with an active value of {orange}%.2f{default}.", status, target, duration, acVal);
}

//Pass a valid entity to search for the effect in the given entity's list of active effects, otherwise it searches for the effect in the list of preloaded templates.
int CFSE_GetEffectSlot(char[] effect, int entity = -1)
{
    if (IsValidEntity(entity))
    {
        if (g_ActiveEffectNames[entity] == null)
            return -1;

        for (int i = 0; i < GetArraySize(g_ActiveEffectNames[entity]); i++)
        {
            char name[255];
            GetArrayString(g_ActiveEffectNames[entity], i, name, 255);
            if (StrEqual(name, effect))
                return i;
        }
    }
    else if (g_StatusNames != null)
    {
        for (int i = 0; i < GetArraySize(g_StatusNames); i++)
        {
            char name[255];
            GetArrayString(g_StatusNames, i, name, 255);
            if (StrEqual(name, effect))
                return i;
        }
    }

    return -1;
}

CFStatusEffect CFSE_GetStatusEffect(int entity, char[] effect)
{
    int slot = CFSE_GetEffectSlot(effect, entity);
    if (slot < 0)
        return null;

    return view_as<CFStatusEffect>(GetArrayCell(g_ActiveEffectStats[entity], slot));
}

public int CFSE_GetArgSlot(int effectSlot, char[] arg)
{
    if (effectSlot < 0 || effectSlot > 2048 || g_StatusTemplateArgs[effectSlot] == null)
        return -1;

    for (int i = 0; i < GetArraySize(g_StatusTemplateArgs[effectSlot]); i++)
    {
        char argName[255];
        GetArrayString(g_StatusTemplateArgs[effectSlot], i, argName, 255);

        if (StrEqual(argName, arg))
            return i;
    }

    return -1;
}

public bool CFSE_GetArgValue(char[] effect, char[] arg, char[] output, int size)
{
    int effectSlot = CFSE_GetEffectSlot(effect);
    if (effectSlot < 0)
        return false;

    int argSlot = CFSE_GetArgSlot(effectSlot, arg);
    if (argSlot < 0)
        return false;

    GetArrayString(g_StatusTemplateValues[effectSlot], argSlot, output, size);
    return true;
}

//Mode: 1 only removes positive effects, 2 only removes negative effects, all other values remove all effects.
//Applicant: if this is a valid entity, effects will only be removed if they were applied by that entity.
void CFSE_RemoveEffectFromEntity(int entity, char[] effect, int mode = 0, int applicant = -1)
{
    int slot = CFSE_GetEffectSlot(effect, entity);

    if (slot < 0)
        return;

    if (mode > 0 && mode < 3)
    {
        int tempSlot = CFSE_GetEffectSlot(effect);
        if ((g_StatusTemplates[tempSlot].positive && mode == 2) || (!g_StatusTemplates[tempSlot].positive && mode == 1))
            return;
    }

    int cell = GetArrayCell(g_ActiveEffectStats[entity], slot);
    CFStatusEffect info = view_as<CFStatusEffect>(cell);

    if (IsValidEntity(applicant) && info.i_Applicant != applicant)
        return;

    RemoveFromArray(g_ActiveEffectStats[entity], slot);
    if (GetArraySize(g_ActiveEffectStats[entity]) < 1)
        delete g_ActiveEffectStats[entity];

    RemoveFromArray(g_ActiveEffectNames[entity], slot);
    if (GetArraySize(g_ActiveEffectNames[entity]) < 1)
        delete g_ActiveEffectNames[entity];

    Call_StartForward(g_OnStatusEffectRemoved);

    Call_PushCell(entity);
    Call_PushString(effect);
    Call_PushCell(info.i_Applicant);

    Call_Finish();

    #if defined DEBUG_STATUS_EFFECTS
    PrintToServer("REMOVED STATUS EFFECT ''%s'' FROM ENTITY %i, APPLICANT WAS %i", effect, entity, info.i_Applicant);
    #endif

    info.Destroy();
}

//Mode: 1 only removes positive effects, 2 only removes negative effects, all other values remove all effects.
//Applicant: if this is a valid entity, effects will only be removed if they were applied by that entity.
void CFSE_RemoveAllEffectsFromEntity(int entity, int mode = 0, int applicant = -1)
{
    if (g_ActiveEffectNames[entity] == null)
        return;

    for (int i = 0; i < GetArraySize(g_ActiveEffectNames[entity]); i++)
    {
        char name[255];
        GetArrayString(g_ActiveEffectNames[entity], i, name, 255);
        CFSE_RemoveEffectFromEntity(entity, name, mode, applicant);

        if (g_ActiveEffectNames[entity] == null)
            return;
    }
}

public any Native_CF_HasStatusEffect(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    char effect[255];
    GetNativeString(2, effect, 255);

    return (CFSE_GetEffectSlot(effect, entity) != -1);
}

public any Native_CF_ApplyStatusEffect(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);

    if (IsValidClient(entity) && (!IsPlayerAlive(entity) || GetClientTeam(entity) < 2 || GetClientTeam(entity) > 3))
        return false;

    char effect[255];
    GetNativeString(2, effect, 255);

    float duration = GetNativeCell(3);
    int applicant = GetNativeCell(4);
    float activeValue = GetNativeCell(5);
    bool force = GetNativeCell(6);
    bool replace = GetNativeCell(7);

    int efSlot = CFSE_GetEffectSlot(effect);
    if (efSlot < 0)
        return false;

    if (!IsValidClient(entity) && !g_StatusTemplates[efSlot].allow_entities)
        return false;

    if (CF_HasStatusEffect(entity, effect) && !replace)
        return false;

    bool allow = true;
    Action event;
    Call_StartForward(g_OnStatusEffectApplied_Pre);

    Call_PushCell(entity);
    Call_PushString(effect);
    Call_PushCell(applicant);
    Call_PushCellRef(allow);

    Call_Finish(event);

    if (!allow && !force)
        return false;

    if (CF_HasStatusEffect(entity, effect) && replace)
        CF_RemoveStatusEffect(entity, effect);

    if (g_ActiveEffectNames[entity] == null)
        g_ActiveEffectNames[entity] = CreateArray(128);

    PushArrayString(g_ActiveEffectNames[entity], effect);

    if (g_ActiveEffectStats[entity] == null)
        g_ActiveEffectStats[entity] = CreateArray(64);

    CFStatusEffect eff = new CFStatusEffect();
    eff.i_Owner = entity;
    eff.i_Applicant = applicant;
    //DoNotCallActiveValueForwards = true;
    eff.f_ActiveValue = activeValue;
    //DoNotCallActiveValueForwards = false;
    if (duration > 0.0)
        eff.f_EndTime = GetGameTime() + duration;
    
    PushArrayCell(g_ActiveEffectStats[entity], eff.index);

    Call_StartForward(g_OnStatusEffectApplied_Post);

    Call_PushCell(entity);
    Call_PushString(effect);
    Call_PushCell(applicant);

    Call_Finish();

    return true;
}

public Native_CF_RemoveStatusEffect(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    char effect[255];
    GetNativeString(2, effect, 255);
    int applicant = GetNativeCell(3);

    CFSE_RemoveEffectFromEntity(entity, effect, _, applicant);

    return 0;
}

public Native_CF_RemoveAllPositiveEffects(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    int applicant = GetNativeCell(2);

    CFSE_RemoveAllEffectsFromEntity(entity, 1, applicant);

    return 0;
}

public Native_CF_RemoveAllNegativeEffects(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    int applicant = GetNativeCell(2);

    CFSE_RemoveAllEffectsFromEntity(entity, 2, applicant);

    return 0;
}

public Native_CF_RemoveAllStatusEffects(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    int applicant = GetNativeCell(2);

    CFSE_RemoveAllEffectsFromEntity(entity, 0, applicant);

    return 0;
}

public any Native_CF_GetStatusEffectArgF(Handle plugin, int numParams)
{
    char effect[255], arg[255];
    GetNativeString(1, effect, 255);
    GetNativeString(2, arg, 255);

    if (CFSE_GetArgValue(effect, arg, arg, 255))
    {
        return StringToFloat(arg);
    }
    
    return GetNativeCell(3);
}

public Native_CF_GetStatusEffectArgI(Handle plugin, int numParams)
{
    char effect[255], arg[255];
    GetNativeString(1, effect, 255);
    GetNativeString(2, arg, 255);

    if (CFSE_GetArgValue(effect, arg, arg, 255))
    {
        return StringToInt(arg);
    }
    
    return GetNativeCell(3);
}

public any Native_CF_GetStatusEffectArgB(Handle plugin, int numParams)
{
    char effect[255], arg[255];
    GetNativeString(1, effect, 255);
    GetNativeString(2, arg, 255);

    if (CFSE_GetArgValue(effect, arg, arg, 255))
    {
        return StringToInt(arg) > 0;
    }
    
    return GetNativeCell(3);
}

public Native_CF_GetStatusEffectArgS(Handle plugin, int numParams)
{
    char effect[255], arg[255];
    GetNativeString(1, effect, 255);
    GetNativeString(2, arg, 255);

    if (CFSE_GetArgValue(effect, arg, arg, 255))
    {
        SetNativeString(3, arg, GetNativeCell(4));
        return 0;
    }
    
    char defaultVal[255];
    GetNativeString(5, defaultVal, 255);
    SetNativeString(3, defaultVal, GetNativeCell(4));

    return 0;
}

public any Native_CF_GetStatusEffectActiveValue(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    char effect[255];
    GetNativeString(2, effect, 255);

    CFStatusEffect eff = CFSE_GetStatusEffect(entity, effect);
    if (eff.index == -1)
        return GetNativeCell(3);

    return eff.f_ActiveValue;
}

public any Native_CF_SetStatusEffectActiveValue(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    char effect[255];
    GetNativeString(2, effect, 255);

    CFStatusEffect eff = CFSE_GetStatusEffect(entity, effect);
    if (eff.index == -1)
        return 0;

    s_CurrentChange = effect;
    eff.f_ActiveValue = GetNativeCell(3);

    return 0;
}

public any Native_CF_GetStatusEffectApplicant(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    char effect[255];
    GetNativeString(2, effect, 255);

    CFStatusEffect eff = CFSE_GetStatusEffect(entity, effect);
    if (eff.index == -1)
        return -1;

    return eff.i_Applicant;
}

public any Native_CF_SetStatusEffectApplicant(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    char effect[255];
    GetNativeString(2, effect, 255);

    CFStatusEffect eff = CFSE_GetStatusEffect(entity, effect);
    if (eff.index == -1)
        return 0;

    eff.i_Applicant = GetNativeCell(3);

    return 0;
}

public any Native_CF_GetStatusEffectEndTime(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    char effect[255];
    GetNativeString(2, effect, 255);

    CFStatusEffect eff = CFSE_GetStatusEffect(entity, effect);
    if (eff.index == -1)
        return 0.0;

    return eff.f_EndTime;
}

public any Native_CF_SetStatusEffectEndTime(Handle plugin, int numParams)
{
    int entity = GetNativeCell(1);
    char effect[255];
    GetNativeString(2, effect, 255);

    CFStatusEffect eff = CFSE_GetStatusEffect(entity, effect);
    if (eff.index == -1)
        return 0;

    eff.f_EndTime = GetNativeCell(3);

    return 0;
}

void CFSE_ManageEffectDurations()
{
    if (g_StatusNames == null)  //This server doesn't even have any custom status effects, don't bother with the big loop.
        return;

    for (int i = 0; i < 2049; i++)
    {
        if (g_ActiveEffectNames[i] == null)
            continue;

        for (int j = 0; g_ActiveEffectNames[i] != null && j < GetArraySize(g_ActiveEffectNames[i]); j++)
        {
            char name[255];
            GetArrayString(g_ActiveEffectNames[i], j, name, 255);

            CFStatusEffect eff = CFSE_GetStatusEffect(i, name);
            if (eff.f_EndTime > 0.0 && GetGameTime() >= eff.f_EndTime)
            {
                CFSE_RemoveEffectFromEntity(i, name);
            }
        }
    }
}

//EXAMPLE USAGE BELOW (A BETTER EXAMPLE WILL BE PUT ON KHOLDROZ LATER)
//The following example is a simple custom debuff which lights the victim on fire for 5s, dealing 5 damage per tick, plus a random extra amount between 1-10 using the status effect's Active Value.

//In the character's config:
/*

"status_effects"
{
	"Debug Burn"        //The name of our special debuff, "Debug Burn".
	{
		"positive"	"0"             //This is marked as a negative status effect, because being on fire is unpleasant.
		"allow_entities"	"1"     //We allow entities, such as sentries and NPCs, to suffer from this debuff.
			
		"custom_args"
		{
			"damage"		"5.0"   //We deal 5 base damage per tick.
			"duration"		"5.0"   //It lasts for 5s.
		}
	}
}

*/

//And then, the code to make this debuff work:
/*

Handle g_DebugBurnTimer[2049] = { null, ... };

public void MySpecialDebuff(int victim, int attacker)
{
    CF_ApplyStatusEffect(victim, "Debug Burn", CF_GetStatusEffectArgF("Debug Burn", "duration", 3.0), attacker, GetRandomFloat(1.0, 10.0), _, true);
}

public void CF_OnStatusEffectApplied_Post(int entity, char[] effect, int applicant)
{
	AttachAura(entity, "utaunt_multicurse_teamcolor_red");

	DataPack pack = new DataPack();
	g_DebugBurnTimer[entity] = CreateDataTimer(0.5, DebugBurn, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(entity));
	WritePackCell(pack, entity);
}

public Action DebugBurn(Handle debug, DataPack pack)
{
	ResetPack(pack);

	int vic = EntRefToEntIndex(ReadPackCell(pack));
	int cell = ReadPackCell(pack);

	if (!IsValidEntity(vic) || (IsValidClient(vic) && !IsPlayerAlive(vic)))
	{
		g_DebugBurnTimer[cell] = null;
		return Plugin_Stop;
	}

	int attacker = CF_GetStatusEffectApplicant(vic, "Debug Burn");
	float dmg = CF_GetStatusEffectActiveValue(vic, "Debug Burn") + CF_GetStatusEffectArgF("Debug Burn", "damage");
	SDKHooks_TakeDamage(vic, _, attacker, dmg);

	return Plugin_Continue;
}

public void CF_OnStatusEffectRemoved(int entity, char[] effect, int applicant)
{
	RemoveAura(entity, "utaunt_multicurse_teamcolor_red");
	EmitSoundToAll(SOUND_DEBUG_BURN_REMOVED, entity);

    //NOTE: in an actual plugin, you would also want to delete the timer and set it to null if the victim dies/disconnects/is destroyed, as well as when the round changes. For the sake of this quick example, I will not be including that.
	delete g_DebugBurnTimer[entity];
	g_DebugBurnTimer[entity] = null;
}

*/