#include <sourcemod>

bool g_allow = false;

public void OnPluginStart()
{
    CreateTimer(10.0, Timer_ChangeLevel);
}

public void OnConfigsExecuted()
{
    if(!g_allow)
        ServerCommand("sv_password iloveu");
}

public Action Timer_ChangeLevel(Handle timer)
{
    g_allow = true;
    char mapname[MAX_NAME_LENGTH];
    GetCurrentMap(mapname, MAX_NAME_LENGTH);
    ForceChangeLevel(mapname, "");
    return Plugin_Stop;
}