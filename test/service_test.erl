%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(service_test).    
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(HostName,"c100").
-define(ClusterName,"c1").
-define(PodName,"c1_0").
	 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    ok=setup(),
       
    ok=which_services(),

    io:format("Test OK !!! ~p~n",[?MODULE]),
    cluster_stop_test(),
    timer:sleep(2000),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_services()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    HostClusterNameList=lists:sort(ops:cluster_names()),
    AllServices=[service_lib:which_services(ClusterName)||{_HostName,ClusterName}<-HostClusterNameList],
    
    gl=AllServices,
        
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
    


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
cluster_stop_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    HostClusterNameList=lists:sort(ops:cluster_names()),
    StopAll= [{ops:delete_cluster_node(HostName,ClusterName),HostName,ClusterName}||{HostName,ClusterName}<-HostClusterNameList],
    [{ok,"c100","c1"},
     {ok,"c100","c2"},
     {ok,"c200","c1"},
     {ok,"c201","c1"}]=StopAll,
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


setup()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    cluster_init:start(),
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),

    ok.
