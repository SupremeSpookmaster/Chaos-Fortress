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
	if (StrEqual(Config, ""))	//This check should not be necessary, but line 37 throws errors if it's not here.
		return KeyValType_Null;

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
		//ConfigMap echoSection = section.GetSection("echo");
			
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
			
			/*if (echoSection != null && CanPlay)
			{
				int numEchoes = GetIntFromConfigMap(echoSection, "times", 100);
				float echoDelay = GetFloatFromConfigMap(echoSection, "delay", 0.33);
				int levelReduction = GetIntFromConfigMap(echoSection, "level_reduction", 30);
				float volumeReduction = GetFloatFromConfigMap(echoSection, "volume_reduction", 0.33);
				
				DataPack pack = new DataPack();
				CreateDataTimer(echoDelay, Sound_Echo, pack, TIMER_FLAG_NO_MAPCHANGE);
				WritePackCell(pack, playMode);
				WritePackCell(pack, source);
				WritePackCell(pack, level);
				WritePackFloat(pack, volume);
				WritePackCell(pack, channel);
				WritePackCell(pack, global);
				WritePackCell(pack, numEchoes);
				WritePackFloat(pack, echoDelay);
				WritePackCell(pack, levelReduction);
				WritePackFloat(pack, volumeReduction);
				WritePackCell(pack, minPitch);
				WritePackCell(pack, maxPitch);
				WritePackString(pack, snd);
			}*/
		}
		else
		{
			CanPlay = false;
		}
		
		if (CanPlay && ultType == 0)
			level -= CF_GetDialogueReduction(source);
		
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

public Action Sound_Echo(Handle echo, DataPack pack)
{
	ResetPack(pack);
	
	int playMode = ReadPackCell(pack);
	int source = ReadPackCell(pack);
	int level = ReadPackCell(pack);
	float volume = ReadPackFloat(pack);
	int channel = ReadPackCell(pack);
	bool global = ReadPackCell(pack);
	int numEchoes = ReadPackCell(pack);
	float echoDelay = ReadPackFloat(pack);
	int levelReduction = ReadPackCell(pack);
	float volumeReduction = ReadPackFloat(pack);
	int minPitch = ReadPackCell(pack);
	int maxPitch = ReadPackCell(pack);
	char snd[255];
	ReadPackString(pack, snd, sizeof(snd));
	
	volume -= volumeReduction;
	level -= levelReduction;
	numEchoes--;
	
	TFTeam targTeam = TFTeam_Unassigned;
		
	switch(playMode)
	{
		case 0:	//Everyone
		{
			EmitSoundToAll(snd, global || !IsValidEntity(source) ? SOUND_FROM_PLAYER : source, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
		}
		case 1:	//Self only
		{
			if (IsValidClient(source))
			{
				EmitSoundToClient(source, snd, _, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
			}
		}
		case 2: //Allies only
		{
			if (IsValidClient(source))
			{
				targTeam = TF2_GetClientTeam(source);
			}
		}
		case 3:	//Enemies only
		{
			if (IsValidClient(source))
			{
				targTeam = grabEnemyTeam(source);
			}
		}
	}
		
	if (targTeam != TFTeam_Unassigned)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidMulti(i, false, _, true, targTeam) && i != source)
			{
				EmitSoundToClient(i, snd, global || !IsValidEntity(source) ? SOUND_FROM_PLAYER : source, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
			}
		}
	}
	
	if (numEchoes > 0)
	{
		DataPack pack2 = new DataPack();
		CreateDataTimer(echoDelay, Sound_Echo, pack2, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack2, playMode);
		WritePackCell(pack2, source);
		WritePackCell(pack2, level);
		WritePackFloat(pack2, volume);
		WritePackCell(pack2, channel);
		WritePackCell(pack2, global);
		WritePackCell(pack2, numEchoes);
		WritePackFloat(pack2, echoDelay);
		WritePackCell(pack2, levelReduction);
		WritePackFloat(pack2, volumeReduction);
		WritePackCell(pack2, minPitch);
		WritePackCell(pack2, maxPitch);
		WritePackString(pack2, snd);
	}
	
	return Plugin_Continue;
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
	
	Call_PushStringEx(strSound, sizeof(strSound), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
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