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
-module(cl2_test).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(OpsNodeName,"ops").
-define(OpsCookie,"ops").

-define(ClId_1,"c1").
-define(ClCookieStr_1,"cookie_c1").
-define(ClNumPods_1,5).
%-define(ClNodeName_1,"c_1").

-define(ClCookie_1,list_to_atom(?ClCookieStr_1)).
-define(ClNodeC100_1,list_to_atom(?ClNodeName_1++"@"++"c100")).
-define(ClNodeC200_1,list_to_atom(?ClNodeName_1++"@"++"c200")).
%-define(ClWorkesNodeName_1,["w_c1_1","w_c1_2","w_c1_3","w_c1_4"]).

-define(HostNames,["c100","c200","c201"]).


		 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),

    ok=cluster_start_test(),
    ok=pod_start_test(),
    ok=pod_stop_test(),
    ok=cluster_stop_test(),
           
    io:format("Test OK !!! ~p~n",[?MODULE]),

    timer:sleep(3000),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
pod_start_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    AllClusterNames=lists:sort(cluster:cluster_names()),    
    AllPodNames=lists:sort([{HostName,ClusterName,cluster:pod_names(HostName,ClusterName)}||{HostName,ClusterName}<-AllClusterNames]),
     R=[start_pod(HostName,ClusterName,PodNameList)||{HostName,ClusterName,PodNameList}<-AllPodNames],
    Result=lists:sort(lists:append(R)),
    [{ok,{"c100",c1_0@c100}},
     {ok,{"c100",c1_1@c100}},
     {ok,{"c100",c1_2@c100}},
     {ok,{"c100",c1_3@c100}},
     {ok,{"c100",c2_0@c100}},
     {ok,{"c100",c2_1@c100}},
     {ok,{"c100",c2_2@c100}},
     {ok,{"c200",c1_0@c200}},
     {ok,{"c200",c1_1@c200}},
     {ok,{"c200",c1_2@c200}},
     {ok,{"c200",c1_3@c200}},
     {ok,{"c201",c1_0@c201}},
     {ok,{"c201",c1_1@c201}},
     {ok,{"c201",c1_2@c201}},
     {ok,{"c201",c1_3@c201}}]=Result,
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
    
start_pod(HostName,ClusterName,PodNameList)->
    [cluster:start_pod_node(HostName,ClusterName,PodName)||PodName<-PodNameList].

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
pod_stop_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    AllClusterNames=lists:sort(cluster:cluster_names()),    
    AllPodNames=lists:sort([{HostName,ClusterName,cluster:pod_names(HostName,ClusterName)}||{HostName,ClusterName}<-AllClusterNames]),
    R=[stop_pod(HostName,ClusterName,PodNameList)||{HostName,ClusterName,PodNameList}<-AllPodNames],
    Result=lists:sort(lists:append(R)),
    [{true,"c100","c1","c1_0"},{true,"c100","c1","c1_1"},{true,"c100","c1","c1_2"},
     {true,"c100","c1","c1_3"},{true,"c100","c2","c2_0"},{true,"c100","c2","c2_1"},
     {true,"c100","c2","c2_2"},{true,"c200","c1","c1_0"},{true,"c200","c1","c1_1"},
     {true,"c200","c1","c1_2"},{true,"c200","c1","c1_3"},{true,"c201","c1","c1_0"},
     {true,"c201","c1","c1_1"},{true,"c201","c1","c1_2"},{true,"c201","c1","c1_3"}]=Result,
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
stop_pod(HostName,ClusterName,PodNameList)->
    [{cluster:stop_pod_node(HostName,ClusterName,PodName),HostName,ClusterName,PodName}||PodName<-PodNameList].

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
cluster_start_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    AllClusterNames=lists:sort(cluster:cluster_names()),
    [cluster:start_cluster_node(HostName,ClusterName)||{HostName,ClusterName}<-AllClusterNames],
    [true,true,true,true]=[cluster:is_cluster_node_present(HostName,ClusterName)||{HostName,ClusterName}<-AllClusterNames],   
         
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
   

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
cluster_stop_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    AllClusterNames=lists:sort(cluster:cluster_names()),
    StopAll=[{cluster:stop_cluster_node(HostName,ClusterName),HostName,ClusterName}||{HostName,ClusterName}<-AllClusterNames],
    [{ok,"c100","c1"},{ok,"c100","c2"},{ok,"c200","c1"},{ok,"c201","c1"}]=StopAll,
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

setup()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    ok=application:start(ops),
    pong=cluster:ping(),
    AllClusterNames=lists:sort(cluster:cluster_names()),
    [cluster:stop_cluster_node(HostName,ClusterName)||{HostName,ClusterName}<-AllClusterNames],
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),

    ok.
