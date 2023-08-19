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

/**
 * Gets a random sound from a given boss config.
 *
 * @param Config 				The config to grab the sound from. Must be a direct path such as "configs/chaos_fortress/character.cfg". You can obtain this easily with CF_GetCharacterConfig.
 * @param Sound					The sound section to grab from, such as "sound_kill".
 * @param Output				The output buffer.
 *
 * @return A KeyValType corresponding to the chosen sound. KeyValType_Value for sounds without special settings, KeyValType_Section for sounds with special settings, and KeyValType_Null for invalid sounds.
 */
public KeyValType CF_GetRandomSound(char Config[255], char Sound[255], char Output[255])
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
	
	switch(newMap.GetKeyValType(key))
	{
		case KeyValType_Value: //This works as intended.
		{
			newMap.Get(key, Output, sizeof(Output));
			
			#if defined DEBUG_SOUNDS
			PrintToServer("CF_GetRandomSound retrieved a ConfigMap with KeyValType_Value, the value is %s.", Output);
			#endif
			
			return KeyValType_Value;
		}
		case KeyValType_Section:
		{
			Format(Output, sizeof(Output), "%s", OldKey);
			
			#if defined DEBUG_SOUNDS
			PrintToServer("CF_GetRandomSound retrieved a ConfigMap with KeyValType_Section, the section name is %s.", Output);
			#endif
			
			return KeyValType_Section;
		}
		default:
		{
			#if defined DEBUG_SOUNDS
			PrintToServer("CF_GetRandomSound retrieved a ConfigMap with KeyValType_Null, meaning the section does not exist. This should not be possible.");
			#endif
			
			return KeyValType_Null;
		}
	}
}

/**
 * Plays a random sound from a client's boss config, as specified by the settings below.
 *
 * @param source				The source to play the sound from. If this is a valid client, Config can be left blank to automatically grab their current character config.
 * @param Config				The config to grab the sound from. If source is a valid client and you leave this blank, the config is automatically grabbed from that client's current character.
 * @param Sound					The sound section to grab from, such as "sound_kill".
 * @param damage				The optional damage dealt to trigger this sound, used by sound_bighit.
 *
 * @return		True if the sound was played, false otherwise.
 */
bool CF_PlayRandomSound(int source, char Config[255], char Sound[255], float damage = 0.0)
{
	if (CF_IsPlayerCharacter(source) && StrEqual(Config, ""))
	{
		CF_GetPlayerConfig(source, Config, sizeof(Config));
	}
	
	char snd[255] = ""; char checkFile[255];
	KeyValType kvType = CF_GetRandomSound(Config, Sound, snd);
	Format(checkFile, sizeof(checkFile), "sound/%s", snd);
	
	if (!CheckFile(checkFile))
		return false;
	
	switch(kvType)
	{
		case KeyValType_Value:
		{
			EmitSoundToAll(snd, source, SNDCHAN_VOICE);
			return true;
		}
		case KeyValType_Section:
		{
			char path[255];
			Format(path, sizeof(path), "character.sounds.%s.%s", Sound, snd);
			ReplaceString(path, sizeof(path), ".", "\\.");
			
			ConfigMap cfgMap = new ConfigMap(Config);
			cfgMap = cfgMap.GetSection(path);
			
			if (cfgMap == null)
				return false;
				
			int level = GetIntFromConfigMap(cfgMap, "level", 100);
			bool onlySelf = GetBoolFromConfigMap(cfgMap, "source", false);
			float volume = GetFloatFromConfigMap(cfgMap, "volume", 1.0);
			int channel = GetIntFromConfigMap(cfgMap, "channel", 7);
			bool global = GetBoolFromConfigMap(cfgMap, "global", false);
			float chance = GetFloatFromConfigMap(cfgMap, "chance", 1.0);
			
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