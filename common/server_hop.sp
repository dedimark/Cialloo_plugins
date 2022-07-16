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
    PrintToChat(client, "\x03如未弹出询问连接窗口\n玩家可自行复制 connect %s 到控制台手动连接", buffer);
    return Plugin_Handled;
}