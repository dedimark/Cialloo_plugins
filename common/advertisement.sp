#include <sourcemod>
#include <morecolors>

Handle g_timer[MAXPLAYERS];

public Plugin myinfo =
{
    name = "advertisement",
    author = "cialloo",
    description = "send ad to player",
    version = "1.0",
    url = "https://www.cialloo.com"
};

public void OnPluginStart()
{
    for(int i = 0; i < MAXPLAYERS; i++)
        g_timer[i] = INVALID_HANDLE;
}

public void OnClientPutInServer(int client)
{
    if(g_timer[client] == INVALID_HANDLE)
        g_timer[client] = CreateTimer(20.0, Timer_SendAdvertisement, client);
}

public Action Timer_SendAdvertisement(Handle Timer, int client)
{
    if(client 
    && IsClientConnected(client)
    && IsClientInGame(client) 
    && !IsFakeClient(client) 
    && !IsClientSourceTV(client)
    && !IsClientReplay(client))
        CPrintToChat(client, "{green}Visit our website: {blue}https://cialloo.com\n{white}输入!menu可以查看所有服务器信息包括指令.\n{red}默认不提供下载模型资源, 如需预览模型请先至资源下载服!!");

    g_timer[client] = INVALID_HANDLE;
    return Plugin_Handled;
}