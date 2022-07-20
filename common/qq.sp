#include <sourcemod>
#include <qqbot>

public void OnPluginStart()
{
    RegConsoleCmd("sm_qqmsg", Cmd_QQMsg, "Send message to qq group.");
}

public Action Cmd_QQMsg(int client, int args)
{
    char steamid[32], host[MAX_NAME_LENGTH], message[256], qqmsg[512];
    ConVar hostname = FindConVar("hostname");
    hostname.GetString(host, sizeof(host));
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
    GetCmdArgString(message, sizeof(message));
    FormatEx(qqmsg, sizeof(qqmsg), 
    "来自玩家 %N 的消息: %s\n\
    SteamID: %s\n\
    服务器: %s", client, message, steamid, host)
    MessageToQQGroup("285620437", qqmsg);
}