#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#include <tf2_stocks>
#include <contracts>

#pragma newdecls required


public Plugin myinfo =
{
	name = "ContractsR-TF2",
	author = "Toyguna",
	description = "",
	version = "1.0.0",
	url = "https://github.com/Toyguna/ContractsR-TF2"
};

// ============== [ FORWARDS ] ============== //

public void OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
}

public void Contracts_OnContractCompletion(int client, const char[] contract_id)
{
    PrintToServer("Player '%d' completed contract: %s", client, contract_id);
}

public void Contracts_OnTaskCompletion(int client, const char[] task_id, int goal)
{
    PrintToServer("Player '%d' completed task: %s (goal: %d)", client, task_id, goal);
}

// ============== [ EVENTS ] ============== //

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int victimid = event.GetInt("userid");
    int attackerid = event.GetInt("attacker");
    int custom_kill = event.GetInt("customkill");

    int victim = GetClientOfUserId(victimid);
    int attacker = GetClientOfUserId(attackerid);

    TFClassType victimclass = TF2_GetPlayerClass(victim);
    TFClassType attackerclass = TF2_GetPlayerClass(attacker);

    bool headshot = custom_kill == 
    TF_CUSTOM_HEADSHOT | TF_CUSTOM_HEADSHOT_DECAPITATION | TF_CUSTOM_PENETRATE_HEADSHOT;
    
    bool spell = custom_kill == 
    TF_CUSTOM_SPELL_BATS | TF_CUSTOM_SPELL_BLASTJUMP | TF_CUSTOM_SPELL_FIREBALL | TF_CUSTOM_SPELL_LIGHTNING | TF_CUSTOM_SPELL_METEOR |
    TF_CUSTOM_SPELL_MIRV | TF_CUSTOM_SPELL_MONOCULUS | TF_CUSTOM_SPELL_SKELETON | TF_CUSTOM_SPELL_TELEPORT |
    TF_CUSTOM_SPELL_TINY

    if ( Contracts_ClientHasContract(attacker) )
    { 
        Contracts_Contract attacker_contract;
        Contracts_GetClientContract(attacker, attacker_contract, sizeof(attacker_contract));

        Task_KillPlayer(attacker, attacker_contract, attackerclass, victimclass);
        if (headshot) Task_HeadshotKillPlayer(attacker, attacker_contract, attackerclass, victimclass);
        if (spell) Task_KillBySpell(attacker, attacker_contract, attackerclass, victimclass);
    }
}

// ============== [ FUNCTIONS ] ============== //

void Task_KillPlayer(int client, Contracts_Contract contract, TFClassType attacker, TFClassType victim)
{
    ArrayList matches = GetMatchingTasks(contract, Type_Kill);
    ArrayList tasks = contract.tasks;

    Contracts_Task task;

    for (int i = 0; i < matches.Length; i++)
    {
        int index = matches.Get(i);
        tasks.GetArray(index, task, sizeof(task));

        bool bAs = false;
        bool bTarget = false;

        if (task.detail_as == Detail_Any || ConvertDetailToClass(task.detail_as) == attacker)
        {
            bAs = true;
        }

        if (task.detail_target == Detail_Any || ConvertDetailToClass(task.detail_target) == victim)
        {
            bTarget = true;
        }

        if (bAs && bTarget)
        {
            Contracts_ProgressTask(client, 1, task.index);
        }
    }

    delete matches;
}

void Task_HeadshotKillPlayer(int client, Contracts_Contract contract, TFClassType attacker, TFClassType victim)
{
    ArrayList matches = GetMatchingTasks(contract, Type_HeadshotKill);
    ArrayList tasks = contract.tasks;

    Contracts_Task task;

    for (int i = 0; i < matches.Length; i++)
    {
        int index = matches.Get(i);
        tasks.GetArray(index, task, sizeof(task));

        bool bAs = false;
        bool bTarget = false;

        if (task.detail_as == Detail_Any || ConvertDetailToClass(task.detail_as) == attacker)
        {
            bAs = true;
        }

        if (task.detail_target == Detail_Any || ConvertDetailToClass(task.detail_target) == victim)
        {
            bTarget = true;
        }

        if (bAs && bTarget)
        {
            Contracts_ProgressTask(client, 1, task.index);
        }
    }

    delete matches;
}

void Task_KillBySpell(int client, Contracts_Contract contract, TFClassType attacker, TFClassType victim)
{
    ArrayList matches = GetMatchingTasks(contract, Type_TF2KillBySpell);
    ArrayList tasks = contract.tasks;

    Contracts_Task task;

    for (int i = 0; i < matches.Length; i++)
    {
        int index = matches.Get(i);
        tasks.GetArray(index, task, sizeof(task));

        bool bAs = false;
        bool bTarget = false;

        if (task.detail_as == Detail_Any || ConvertDetailToClass(task.detail_as) == attacker)
        {
            bAs = true;
        }

        if (task.detail_target == Detail_Any || ConvertDetailToClass(task.detail_target) == victim)
        {
            bTarget = true;
        }

        if (bAs && bTarget)
        {
            Contracts_ProgressTask(client, 1, task.index);
        }
    }

    delete matches;
}

// ============== [ UTILITY ] ============== //

ArrayList GetMatchingTasks(Contracts_Contract contract, Contracts_TaskType type)
{
    ArrayList tasks = contract.tasks;

    ArrayList matches = new ArrayList();

    Contracts_Task task;

    for (int i = 0; i < tasks.Length; i++)
    {
        tasks.GetArray(i, task, sizeof(task));

        if (task.IsCompleted()) continue;
        if (task.type != type) continue;

        matches.Push(task.index);
    }

    return matches;
}

TFClassType ConvertDetailToClass(Contracts_TaskDetail detail)
{
    switch (detail)
    {
        case Detail_TF2Scout:
        {
            return TFClass_Scout;
        }
        case Detail_TF2Soldier:
        {
            return TFClass_Soldier;
        }
        case Detail_TF2Pyro:
        {
            return TFClass_Pyro;
        }
        case Detail_TF2Demoman:
        {
            return TFClass_DemoMan;
        }
        case Detail_TF2Heavy:
        {
            return TFClass_Heavy;
        }
        case Detail_TF2Engineer:
        {
            return TFClass_Engineer;
        }
        case Detail_TF2Medic:
        {
            return TFClass_Medic;
        }
        case Detail_TF2Sniper:
        {
            return TFClass_Sniper;
        }
        case Detail_TF2Spy:
        {
            return TFClass_Spy;
        }
        default:
        {
            return TFClass_Unknown;
        }
    }
}