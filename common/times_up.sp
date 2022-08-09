#include <sourcemod>

#define MINIMUM_CLIENT 0    // Max bot players.

public void OnPluginStart()
{
    CreateTimer(25.0 * 60, Timer_ChangeLevel, _, TIMER_REPEAT);
}

public Action Timer_ChangeLevel(Handle timer)
{
    // GetCLientCount() will return both human players and bot players.
    if(GetClientCount() == MINIMUM_CLIENT) ServerCommand("changelevel_next");
    return Plugin_Continue;
}