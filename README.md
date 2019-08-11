# OPT-Tools
These set of tools allows building and hosting of several OPT mods.

## Components

### /settings/

| File | Info |
|------|------|
| setMetaData.bat | Copy/Rename the provided example and adjust your local filepaths and preferences. |
| serverConfig.cfg | Serverconfig for the local ArmA-DevServer. Do not edit the mission-name, because it's changed automatically. |

### /tools/
These scripts can directly be executed by the user or his IDE. Each filename describes the task.
To automatically close the scripts after execution, execute them with a "noPause" parameter or adjust the `WaitAtFinish` setting in `setMetaData.bat`.

| Script | Info |
|--------|------|
| buildAll.bat | Rebuild all mission/mods. If ArmA Client/Server are running, they will be shut down first and restarted afterwards. |
| buildMission.bat | Packs mission from OPT-Mission to PBO-Folder. Mission name is set via `setMetaData.bat`. First start requires administrator rights to create a symlink for EDEN-Editor. |
| buildMod_CLib.bat | Builds both dev- and release-versions of CLib from OPT-Server-Mod. |
| buildMod_OPT-Client.bat | Packs and signs OPT-Client-Mod. If no keys are present in OptKeysDir, a fresh keypair will be generated first. |
| buildMod_OPT-Server.bat | Builds both dev- and release-versions of OPT-Server-Mod. |
| clientStartOffline.bat | Starting ArmA-Client with all built and additional mods. |
| clientStartOnline.bat | Starting ArmA-Client with all built and additional mods and autoconnects to local DevServer. |
| clientStop.bat | Shutdown local ArmA-Client. |
| serverRestart.bat | Restarts local ArmA-DevServer. |
| serverStart.bat | Start local ArmA-DevServer with all built and additional mods. |
| serverStop.bat | Shutdown local ArmA-DevServer. |

### /helpers/
Here resides some internal helping tools or scripts. You don't need them directly. **Just ignore.**

| File | Info |
|------|------|
| armake2.exe | ArmA-Modding Tools by [KoffeinFlummi](https://github.com/KoffeinFlummi/armake2) |
| DirConvert.bat | Converts and cleans any pathname to an absolute pathname and stores it in an environment variable. |
| getPBOName.bat | Extracts PBO-Name from a header file. |
| JREPL.bat | regex text processor by [Dave Benham](https://www.dostips.com/forum/viewtopic.php?t=6044) |
| sleep.bat | Millisecond delays by [Dave Benham](https://stackoverflow.com/questions/29732878/delay-a-batch-file-in-under-a-second/29879492#29879492) |

## Wiki
Our knowledge base is hosted in a neighbor repository:
https://github.com/OperationPandoraTrigger/OPT-Server-Mod/wiki