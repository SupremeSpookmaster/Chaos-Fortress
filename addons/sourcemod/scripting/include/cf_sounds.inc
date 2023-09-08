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

public void CFS_MakeNatives()
{
	CreateNative("CF_GetRandomSound", Native_CF_GetRandomSound);
	CreateNative("CF_PlayRandomSound", Native_CF_PlayRandomSound);
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
		return KeyValType_Null;
		
	StringMapSnapshot snap = newMap.Snapshot();
	
	int chosen = GetRandomInt(0, snap.Length - 1);
	
	char key[255];
	snap.GetKey(chosen, key, sizeof(key));
	
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

bool PlayRand(int source, char Config[255], char Sound[255], float damage = 0.0)
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
	
	switch(kvType)
	{
		case KeyValType_Value:
		{
			EmitSoundToAll(snd, source, SNDCHAN_VOICE);
			return true;
		}
		case KeyValType_Section:
		{
			char path[255], tempSnd[255];
			
			tempSnd = snd;
			ReplaceString(tempSnd, sizeof(tempSnd), ".", "\\.");
			
			Format(path, sizeof(path), "character.sounds.%s.%s", Sound, tempSnd);
			
			ConfigMap cfgMap = new ConfigMap(ourConf);
			ConfigMap section = cfgMap.GetSection(path);
			
			if (section == null)
				return false;
				
			int level = GetIntFromConfigMap(section, "level", 100);
			bool onlySelf = GetBoolFromConfigMap(section, "source", false);
			float volume = GetFloatFromConfigMap(section, "volume", 1.0);
			int channel = GetIntFromConfigMap(section, "channel", 7);
			bool global = GetBoolFromConfigMap(section, "global", false);
			float chance = GetFloatFromConfigMap(section, "chance", 1.0);
			
			DeleteCfg(cfgMap);
			
			if (GetRandomFloat(0.0, 1.0) <= chance)
			{
				if (global)
				{
					EmitSoundToAll(snd, _, CF_SndChans[channel], level, _, volume);
				}
				else if (onlySelf && IsValidClient(source))
				{
					EmitSoundToClient(source, snd, _, CF_SndChans[channel], level, _, volume);
				}
				else
				{
					EmitSoundToAll(snd, source, CF_SndChans[channel], level, _, volume);
				}
				
				return true;
			}
			else
			{
				return false;
			}
		}
		default:
		{
			return false;
		}
	}
}

public Native_CF_GetRandomSound(Handle plugin, int numParams)
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
	float damage = GetNativeCell(4);
	return PlayRand(source, Config, Sound, damage);
}