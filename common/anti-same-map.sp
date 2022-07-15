#include <sourcemod>

#define KEY_ROOT "map"
#define KEY_FILE_PATH "addons/sourcemod/data/anti-same-map.kv"

bool g_check = true;
char g_previous_map[MAX_NAME_LENGTH];

public Plugin myinfo =
{
    name = "anti-same-map",
    author = "cialloo",
    description = "avoid same map",
    version = "1.0",
    url = "https://cialloo.com"
};

public void OnPluginStart()
{
    CreateConVar("cialloo_anti_same_map_server_index", "1", "Start From 1, don\'t use 0 as start index.");
    AutoExecConfig(true, "anti-same-map", "cialloo");
}

public void OnConfigsExecuted()
{
    char buffer[8], mapname[MAX_NAME_LENGTH], temp[MAX_NAME_LENGTH];
    GetCurrentMap(mapname, MAX_NAME_LENGTH);

    KeyValues kv = new KeyValues("map");
    kv.ImportFromFile(KEY_FILE_PATH);

    ConVar index = FindConVar("cialloo_anti_same_map_server_index");
    index.GetString(buffer, sizeof(buffer));

    if(g_check)
    {
        kv.Rewind();
        kv.SetString(buffer, mapname);
        kv.Rewind();
        kv.ExportToFile(KEY_FILE_PATH);
        Format(g_previous_map, MAX_NAME_LENGTH, mapname);
        delete kv;
        g_check = false;
        return;
    }

    kv.GotoFirstSubKey(false);
    while(kv.GotoNextKey(false))
    {
        kv.GetString(NULL_STRING, temp, MAX_NAME_LENGTH);
        if(strcmp(mapname, temp) == 0)
        {
            g_check = true;
            break;
        }
    }
    
    if(g_check)
    {
        CreateTimer(5.0, Timer_ChangePreviousMap, _, TIMER_FLAG_NO_MAPCHANGE);
        delete kv;
        return;
    }
    else
    {
        kv.Rewind();
        kv.SetString(buffer, mapname);
        kv.Rewind();
        kv.ExportToFile(KEY_FILE_PATH);
        Format(g_previous_map, MAX_NAME_LENGTH, mapname);
        delete kv;
    }
}

public Action Timer_ChangePreviousMap(Handle timer)
{
    ForceChangeLevel(g_previous_map, "The map playing now is already loaded in other servers.");
    return Plugin_Stop;
}


/* ----------------

below is the addons/sourcemod/data/anti-same-map.kv keyvalues file structure.

"map"
{
    "0"     "default"
	"1"		"surf_ace"
	"2"		"surf_beginner"
	"3"		"surf_not_so_zen"
}
   ---------------- */