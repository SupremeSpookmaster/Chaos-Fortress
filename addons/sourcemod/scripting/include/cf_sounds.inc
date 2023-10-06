int CF_SndChans[10] = {
	SNDCHAN_AUTO,
	SNDCHAN_BODY,
	SNDCHAN_ITEM,
	SNDCHAN_REPLACE,
	SNDCHAN_STATIC,
	SNDCHAN_STREAM,
	SNDCHAN_USER_BASE,
	SNDCHAN_VOICE,
	SNDCHAN_VOICE_BASE,
	SNDCHAN_WEAPON
};

GlobalForward g_SoundHook;

float f_LastSoundHook[MAXPLAYERS + 1] = { 0.0, ... };
float f_Silenced[MAXPLAYERS + 1] = { 0.0, ... };

public void CFS_OnPluginStart()
{
	g_SoundHook = new GlobalForward("CF_SoundHook", ET_Event, Param_String, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	AddNormalSoundHook(view_as<NormalSHook>(NormalSoundHook));
}

public void CFS_MakeNatives()
{
	CreateNative("CF_GetRandomSound", Native_CF_GetRandomSound);
	CreateNative("CF_PlayRandomSound", Native_CF_PlayRandomSound);
	CreateNative("CF_SilenceCharacter", Native_CF_SilenceCharacter);
}

public KeyValType GetRand(char Config[255], char Sound[255], char Output[255])
{
	ConfigMap cfgMap = new ConfigMap(Config);
	
	if (cfgMap == null)
		return KeyValType_Null;
		
	char snd[255];
		
	Format(snd, sizeof(snd), "character.sounds.%s", Sound);
	ConfigMap newMap = cfgMap.GetSection(snd);
	
	if (newMap == null)
	{
		DeleteCfg(cfgMap);
		return KeyValType_Null;
	}
		
	StringMapSnapshot snap = newMap.Snapshot();
	
	int chosen = GetRandomInt(0, snap.Length - 1);
	
	char key[255];
	snap.GetKey(chosen, key, sizeof(key));
	delete snap;
	
	#if defined DEBUG_SOUNDS
	PrintToServer("CF_GetRandomSound retrieved a ConfigMap with the following path: %s.%s", snd, key);
	#endif
	
	char OldKey[255];
	Format(OldKey, sizeof(OldKey), "%s", key);
	
	if (StrContains(key, ".") != -1)
	{
		ReplaceString(key, sizeof(key), ".", "\\.");
		#if defined DEBUG_SOUNDS
		PrintToServer("CF_GetRandomSound retrieved a ConfigMap which contained a '.' in its path. New path: %s.%s", snd, key);
		PrintToServer("The key itself is currently %s", key);
		#endif
	}
	
	KeyValType ReturnValue = KeyValType_Null;
	
	switch(newMap.GetKeyValType(key))
	{
		case KeyValType_Value: //This works as intended.
		{
			newMap.Get(key, Output, sizeof(Output));
			
			#if defined DEBUG_SOUNDS
			PrintToServer("CF_GetRandomSound retrieved a ConfigMap with KeyValType_Value, the value is %s.", Output);
			#endif
			
			ReturnValue = KeyValType_Value;
		}
		case KeyValType_Section:
		{
			Format(Output, sizeof(Output), "%s", OldKey);
			
			#if defined DEBUG_SOUNDS
			PrintToServer("CF_GetRandomSound retrieved a ConfigMap with KeyValType_Section, the section name is %s.", Output);
			#endif
			
			ReturnValue = KeyValType_Section;
		}
		default:
		{
			#if defined DEBUG_SOUNDS
			PrintToServer("CF_GetRandomSound retrieved a ConfigMap with KeyValType_Null, meaning the section does not exist. This should not be possible.");
			#endif
		}
	}
	
	DeleteCfg(cfgMap);
	return ReturnValue;
}

bool PlayRand(int source, char Config[255], char Sound[255])
{
	if (!CF_IsPlayerCharacter(source))
		return false;
		
	char ourConf[255];
	strcopy(ourConf, 255, Config);
	if (CF_IsPlayerCharacter(source) && StrEqual(ourConf, ""))
	{
		CF_GetPlayerConfig(source, ourConf, sizeof(ourConf));
	}
	
	char snd[255] = ""; char checkFile[255];
	KeyValType kvType = CF_GetRandomSound(ourConf, Sound, snd, sizeof(snd));
	Format(checkFile, sizeof(checkFile), "sound/%s", snd);
	
	if (!CheckFile(checkFile))
		return false;
		
	PrecacheSound(snd);
	int playMode = 0;
	
	int ultType = 0;
	if (StrEqual(Sound, "sound_ultimate_activation"))
		ultType = 1;
	if (StrEqual(Sound, "sound_ultimate_activation_friendly")) { ultType = 2; playMode = 2; }
	if (StrEqual(Sound, "sound_ultimate_activation_hostile")) { ultType = 3; playMode = 3; }
	if (StrEqual(Sound, "sound_ultimate_activation_self")) { ultType = 4; playMode = 1; }
	
	int level = 100;
	float volume = 1.0;
	int channel = ultType != 0 ? 4 : 7;
	bool global = ultType != 0;
	int maxPitch = 100;
	int minPitch = 100;
	
	bool CanPlay = true;
	
	if (kvType == KeyValType_Section)
	{
		char path[255], tempSnd[255];
			
		tempSnd = snd;
		ReplaceString(tempSnd, sizeof(tempSnd), ".", "\\.");
			
		Format(path, sizeof(path), "character.sounds.%s.%s", Sound, tempSnd);
			
		ConfigMap cfgMap = new ConfigMap(ourConf);
		ConfigMap section = cfgMap.GetSection(path);
			
		if (section != null)
		{			
			level = GetIntFromConfigMap(section, "level", 100);
			
			if (ultType == 0)
				playMode = GetIntFromConfigMap(section, "source", 0);
				
			volume = GetFloatFromConfigMap(section, "volume", 1.0);
			
			if (ultType == 0)
				channel = GetIntFromConfigMap(section, "channel", 7);
				
			if (ultType == 0)
				global = GetBoolFromConfigMap(section, "global", false);
				
			float chance = GetFloatFromConfigMap(section, "chance", 1.0);
			
			minPitch = GetIntFromConfigMap(section, "pitch_min", 100);
			maxPitch = GetIntFromConfigMap(section, "pitch_max", 100);
				
			CanPlay = GetRandomFloat(0.0, 1.0) <= chance;
		}
		else
		{
			CanPlay = false;
		}
		
		DeleteCfg(cfgMap);
	}
	
	if (CanPlay)
	{
		TFTeam targTeam = TFTeam_Unassigned;
		
		switch(playMode)
		{
			case 0:	//Everyone
			{
				EmitSoundToAll(snd, global ? SOUND_FROM_PLAYER : source, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
			}
			case 1:	//Self only
			{
				EmitSoundToClient(source, snd, _, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
			}
			case 2: //Allies only
			{
				targTeam = TF2_GetClientTeam(source);
			}
			case 3:	//Enemies only
			{
				targTeam = grabEnemyTeam(source);
			}
		}
		
		if (targTeam != TFTeam_Unassigned)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidMulti(i, false, _, true, targTeam) && i != source)
				{
					EmitSoundToClient(i, snd, global ? SOUND_FROM_PLAYER : source, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
				}
			}
		}
	}
	
	return CanPlay;
}

public bool PlaySpecificReplacement(int client, char sound[PLATFORM_MAX_PATH])
{
	if (!CF_IsPlayerCharacter(client))
		return false;
		
	char Sound[255], conf[255];
	Format(Sound, sizeof(Sound), "%s", sound);
	StringToLower(Sound);
	CF_GetPlayerConfig(client, conf, sizeof(conf));
	
	ConfigMap map = new ConfigMap(conf);
	if (map == null)
		return false;
		
	StringMapSnapshot snap = map.GetSection("character.sounds").Snapshot();
	
	bool played = false;
	
	for (int i = 0; i < snap.Length; i++)
	{
		char name[255], tempName[255];
		snap.GetKey(i, name, sizeof(name));
		Format(tempName, sizeof(tempName), "%s", name);
		ReplaceString(tempName, sizeof(tempName), "sound_replace_", "");
		
		if (StrContains(Sound, tempName) != -1)
		{
			played = PlayRand(client, "", name);
			break;
		}
	}
	
	DeleteCfg(map);
	delete snap;
	
	return played;
}

public Action NormalSoundHook(int clients[64],int &numClients,char strSound[PLATFORM_MAX_PATH],int &entity,int &channel,float &volume,int &level,int &pitch,int &flags)
{
	Call_StartForward(g_SoundHook);
	
	Call_PushString(strSound);
	Call_PushCellRef(entity);
	Call_PushCellRef(channel);
	Call_PushFloatRef(volume);
	Call_PushCellRef(level);
	Call_PushCellRef(pitch);
	Call_PushCellRef(flags);
	
	Action result;
	Call_Finish(result);
	
	if (result != Plugin_Stop && result != Plugin_Handled)
	{
		if (CF_IsPlayerCharacter(entity) && StrContains(strSound, "vo/") != -1)
		{
			float gameTime = GetGameTime();
			if (gameTime >= f_LastSoundHook[entity] && gameTime >= f_Silenced[entity])
			{
				char SoundA[255], SoundB[255];
				Format(SoundB, sizeof(SoundB), "%s", strSound);
				StringToLower(SoundB);
				Format(SoundA, sizeof(SoundA), "sound_replace_%s", SoundB);
				ReplaceString(SoundA, sizeof(SoundA), ".mp3", "");
				ReplaceString(SoundA, sizeof(SoundA), ".wav", "");
					
				/*
					
				//Guaranteed to replace scout_cheers03 specifically:
				"sound_replace_vo/scout_cheers03"
				{
					"1"		"mysound.mp3"
				}
					
				//Guaranteed to replace any class dialogue containing the name "scout_cheers", not including scout_cheers03.
				"sound_replace_scout_cheers"
				{
					"1"		"myothersound.mp3"
				}
					
				//Replaces ALL class dialogue, not including any sound which contains "scout_cheers".
				"sound_replace_all"
				{
					"1"		"mythirdsound.mp3"
				}
					
				*/
					
				bool played = false;
					
				if (PlayRand(entity, "", SoundA))
				{
					played = true;
				}
				else
				{
					played = PlaySpecificReplacement(entity, strSound);
				}
					
				if (!played)
				{
					played = PlayRand(entity, "", "sound_replace_all");
				}
				
				f_LastSoundHook[entity] = GetGameTime() + 0.01;
					
				if (played)
				{
					return Plugin_Handled;
				}
			}
			else
			{
				return Plugin_Handled;
			}
		}
		
		return result;
	}
	
	return Plugin_Handled;
}

public any Native_CF_GetRandomSound(Handle plugin, int numParams)
{
	char Config[255], Sound[255], Output[255];
	GetNativeString(1, Config, sizeof(Config));
	GetNativeString(2, Sound, sizeof(Sound));
	KeyValType ReturnVal = GetRand(Config, Sound, Output);
	int len = GetNativeCell(4);
	SetNativeString(3, Output, len, false);
	return ReturnVal;
}

public Native_CF_PlayRandomSound(Handle plugin, int numParams)
{
	int source = GetNativeCell(1);
	char Config[255], Sound[255];
	GetNativeString(2, Config, sizeof(Config));
	GetNativeString(3, Sound, sizeof(Sound));
	return PlayRand(source, Config, Sound);
}

public Native_CF_SilenceCharacter(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float duration = GetNativeCell(2);
	
	if (IsValidClient(client))
		f_Silenced[client] = GetGameTime() + duration;
}