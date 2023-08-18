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
 * @param Config				The config to grab the sound from. Ignored if source is a valid client.
 * @param Sound					The sound section to grab from, such as "sound_kill".
 * @param OtherCharacter		The optional name of other character involved in the interaction which triggered the sound, used by sound_kill and sound_killed.
 * @param damage				The optional damage dealt to trigger this sound, used by sound_bighit.
 * @param UltLoc				The optional location the Ultimate Ability which triggered this sound was located, used for sound_ultimate_react sounds.
 * @param UltUser				The optional user of the Ultimate Ability which triggered this sound, used for sound_ultimate_react sounds.
 *
 */
void CF_PlayRandomSound(int source, char Config[255], char Sound[255], char OtherCharacter[255] = "", float damage = 0.0, float UltLoc[3] = {0.0, ...}, int UltUser = -1)
{
	//TODO
}