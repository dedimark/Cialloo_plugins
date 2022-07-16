#include <sourcemod>
#include <halflife>

public void OnPluginStart()
{
    RegConsoleCmd("sm_gotoserver", Cmd_GoToServer, "Send a ask connect dialog to client.");
}

public Action Cmd_GoToServer(int client, int args)
{
    char buffer[128];
    GetCmdArgString(buffer, sizeof(buffer));
    DisplayAskConnectBox(client, 10.0, buffer);
    return Plugin_Handled;
}