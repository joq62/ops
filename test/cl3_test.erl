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
-module(cl3_test).   
 
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
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    ok=setup(),
    

    io:format("Start Phase 1  ~p~n",[?FUNCTION_NAME]),
    {ok,PresentCluster1,MissingCluster1}=status_intent_cluster_nodes(),
    []=PresentCluster1,
    [{"c100","c1"},{"c100","c2"},
     {"c200","c1"},{"c201","c1"}]=MissingCluster1,

    {ok,PresentPods1,MissingPods1}=status_intent_pod_nodes(),
    []=PresentPods1,
    [{"c100","c1","c1_3"},{"c100","c1","c1_2"},{"c100","c1","c1_1"},{"c100","c1","c1_0"},{"c100","c2","c2_2"},
     {"c100","c2","c2_1"},{"c100","c2","c2_0"},{"c200","c1","c1_3"},{"c200","c1","c1_2"},{"c200","c1","c1_1"},
     {"c200","c1","c1_0"},{"c201","c1","c1_3"},{"c201","c1","c1_2"},{"c201","c1","c1_1"},{"c201","c1","c1_0"}]=MissingPods1,

    io:format("Start Phase 2  ~p~n",[?FUNCTION_NAME]),
    [cluster:start_cluster_node(HostName,ClusterName)||{HostName,ClusterName}<-MissingCluster1],
    {ok,PresentCluster2,MissingCluster2}=status_intent_cluster_nodes(),
    [{"c100","c1"},{"c100","c2"},{"c201","c1"}]=PresentCluster2,
    [{"c200","c1"}]=MissingCluster2,

    MissingPodNames2=lists:append(lists:sort([cluster:pod_names(HostName,ClusterName)||{HostName,ClusterName}<-MissingCluster1])),
    [cluster:start_pod_node(HostName,ClusterName,PodName)||{HostName,ClusterName,PodName}<-MissingPodNames2],
    {ok,PresentPods2,MissingPods2}=status_intent_pod_nodes(),
    [{"c100","c1","c1_3"},{"c100","c1","c1_2"},{"c100","c1","c1_1"},{"c100","c1","c1_0"},
     {"c100","c2","c2_2"},{"c100","c2","c2_1"},{"c100","c2","c2_0"},{"c201","c1","c1_3"},
     {"c201","c1","c1_2"},{"c201","c1","c1_1"},{"c201","c1","c1_0"}]=PresentPods2,
    
     [{"c200","c1","c1_3"},{"c200","c1","c1_2"},
      {"c200","c1","c1_1"},{"c200","c1","c1_0"}]=MissingPods2,
    
  %  ok=pod_start_test(),
  %  ok=pod_stop_test(),
  
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
status_intent_pod_nodes()->
    
    io:format("Start ~p~n",[?FUNCTION_NAME]),
   
    AllClusterNames=lists:sort(cluster:cluster_names()),    
    AllPodNames=lists:append(lists:sort([cluster:pod_names(HostName,ClusterName)||{HostName,ClusterName}<-AllClusterNames])),
    StatusPods=[{cluster:is_pod_node_present(HostName,ClusterName,PodName),HostName,ClusterName,PodName}||{HostName,ClusterName,PodName}<-AllPodNames],
    
    MissingPods=[{HostName,ClusterName,PodName}||{false,HostName,ClusterName,PodName}<-StatusPods],
    PresentPods=[{HostName,ClusterName,PodName}||{true,HostName,ClusterName,PodName}<-StatusPods],

    %io:format("MissingPods  ~p~n",[MissingPods]),  

    {ok,PresentPods,MissingPods}.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
status_intent_cluster_nodes()->
    
    io:format("Start ~p~n",[?FUNCTION_NAME]),
   
    WantedStateCluster=lists:sort(cluster:cluster_names()),
 %   io:format("WantedStateCluster  ~p~n",[WantedStateCluster]),    
    StatusCluster=[{cluster:is_cluster_node_present(HostName,ClusterName),HostName,ClusterName}||{HostName,ClusterName}<-WantedStateCluster],  
 %   io:format("StatusCluster  ~p~n",[StatusCluster]),
    MissingCluster=[{HostName,ClusterName}||{false,HostName,ClusterName}<-StatusCluster],
    PresentCluster=[{HostName,ClusterName}||{true,HostName,ClusterName}<-StatusCluster],
  
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    
    {ok,PresentCluster,MissingCluster}.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
pod_start_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    AllClusterNames=lists:sort(cluster:cluster_names()),    
    AllPodNames=lists:append(lists:sort([cluster:pod_names(HostName,ClusterName)||{HostName,ClusterName}<-AllClusterNames])),
    Result=[cluster:start_pod_node(HostName,ClusterName,PodName)||{HostName,ClusterName,PodName}<-AllPodNames],
   
    [{error,[[badrpc,nodedown],'c1@c200',"c1.dir/c1_0"]},
     {error,[[badrpc,nodedown],'c1@c200',"c1.dir/c1_1"]},
     {error,[[badrpc,nodedown],'c1@c200',"c1.dir/c1_2"]},
     {error,[[badrpc,nodedown],'c1@c200',"c1.dir/c1_3"]},
     {ok,{"c100",'c1_0@c100'}},{ok,{"c100",'c1_1@c100'}},
     {ok,{"c100",'c1_2@c100'}},{ok,{"c100",'c1_3@c100'}},
     {ok,{"c100",'c2_0@c100'}},{ok,{"c100",'c2_1@c100'}},
     {ok,{"c100",'c2_2@c100'}},{ok,{"c201",'c1_0@c201'}},
     {ok,{"c201",'c1_1@c201'}},{ok,{"c201",'c1_2@c201'}},
     {ok,{"c201",'c1_3@c201'}}]=lists:sort(Result),
    
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
   
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
pod_stop_test()->

    io:format("Start ~p~n",[?FUNCTION_NAME]),
        
    AllClusterNames=lists:sort(cluster:cluster_names()),    
    AllPodNames=lists:append(lists:sort([cluster:pod_names(HostName,ClusterName)||{HostName,ClusterName}<-AllClusterNames])),
    Result=[cluster:stop_pod_node(HostName,ClusterName,PodName)||{HostName,ClusterName,PodName}<-AllPodNames],
   
    [true,true,true,true,
     true,true,true,true,
     true,true,true,true,
     true,true,true]=lists:sort(Result),

    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
cluster_start_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    AllClusterNames=lists:sort(cluster:cluster_names()),
    [cluster:start_cluster_node(HostName,ClusterName)||{HostName,ClusterName}<-AllClusterNames],
    [cluster:is_cluster_node_present(HostName,ClusterName)||{HostName,ClusterName}<-AllClusterNames],   
         
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
