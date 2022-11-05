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
-module(pod_test).   
 
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

    %% Check initial
    AllClusterNames=lists:sort(cluster:names()),
    StartAll=[{HostName,ClusterName,cluster:start_node(HostName,ClusterName)}||{HostName,ClusterName}<-AllClusterNames],
    io:format("StartAll ~p~n",[StartAll]),    

io:format("AllClusterNames ~p~n",[AllClusterNames]),
    Presence1=[{HostName,ClusterName,cluster:is_node_present(HostName,ClusterName)}||{HostName,ClusterName}<-AllClusterNames],
    io:format("Presence1 ~p~n",[Presence1]),


    %% Start 

    
    
    %% Kill one

    HostName1="c100",
    ClusterName1="c1",
    ok=cluster:stop_node(HostName1,ClusterName1),
    false=cluster:is_node_present(HostName1,ClusterName1),
    timer:sleep(3000),
    {ok,_}=cluster:start_node(HostName1,ClusterName1),
    true=cluster:is_node_present(HostName1,ClusterName1),
    
    timer:sleep(3000),
    
    StopAll=[{cluster:stop_node(HostName,ClusterName),HostName,ClusterName}||{HostName,ClusterName}<-AllClusterNames],
    io:format("StopAll ~p~n",[StopAll]),
    
    
  
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

setup()->
    ok=application:start(ops),
    pong=cluster:ping(),
    AllClusterNames=lists:sort(cluster:names()),
    StopAll=[{HostName,ClusterName,cluster:stop_node(HostName,ClusterName)}||{HostName,ClusterName}<-AllClusterNames],
    io:format("StopAll ~p~n",[StopAll]),
    
%   ClusterNodeName=?ClId_1,
 %   ClusterDir=?ClId_1++".dir",
 %   ClusterCookie=?ClCookieStr_1,
 %   [true,true,true]=[cluster:delete_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)||HostName<-?HostNames],

    ok.
