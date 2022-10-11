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

    ok=desired_state(),
    
    ok=setup(),
       
  
    {ok,AllServicesList}=which_services(),
    ok=which_service(AllServicesList),

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
desired_state()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    DesiredState=service_lib:desired_state(),
    [{"c100","c1",0,test_add},
     {"c201","c1",0,test_add},
     {"c100","c1",1,test_add},
     {"c201","c1",1,test_add},
     {"c100","c1",2,test_add},
     {"c201","c1",2,test_add},
     {"c100","c1",0,sd},
     {"c100","c1",0,nodelog},
     {"c200","c1",0,sd},
     {"c200","c1",0,nodelog},
     {"c201","c1",0,sd},
     {"c201","c1",0,nodelog},
     {"c100","c1",1,sd},
     {"c100","c1",1,nodelog},
     {"c200","c1",1,sd},
     {"c200","c1",1,nodelog},
     {"c201","c1",1,sd},
     {"c201","c1",1,nodelog}]=DesiredState,
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_service(AllServicesList)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    HostClusterNameList=lists:sort(ops:cluster_names()),
    ClusterNames=remove(HostClusterNameList),
    % Eexists sd
    
    [[],[]]=lists:sort([service_lib:which_service("sd",ClusterName,AllServicesList)||ClusterName<-ClusterNames]),
    
    % exists 
    [[{"c100","c1","c1_0",'c1_0@c100',kernel,"6.5.1"},
      {"c100","c1","c1_1",'c1_1@c100',kernel,"6.5.1"},
      {"c100","c1","c1_2",'c1_2@c100',kernel,"6.5.1"},
      {"c100","c1","c1_3",'c1_3@c100',kernel,"6.5.1"},
      {"c201","c1","c1_0",'c1_0@c201',kernel,"6.5.1"},
      {"c201","c1","c1_1",'c1_1@c201',kernel,"6.5.1"},
      {"c201","c1","c1_2",'c1_2@c201',kernel,"6.5.1"},
      {"c201","c1","c1_3",'c1_3@c201',kernel,"6.5.1"}],
     [{"c100","c2","c2_0",'c2_0@c100',kernel,"6.5.1"},
      {"c100","c2","c2_1",'c2_1@c100',kernel,"6.5.1"},
      {"c100","c2","c2_2",'c2_2@c100',kernel,"6.5.1"}]]=lists:sort([service_lib:which_service("kernel",ClusterName,AllServicesList)||ClusterName<-ClusterNames]),
        
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_services()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    HostClusterNameList=lists:sort(ops:cluster_names()),
    ClusterNames=remove(HostClusterNameList),
    AllServicesList=lists:sort([service_lib:which_services(ClusterName)||ClusterName<-ClusterNames]),
    
    [[{"c100","c1","c1_0",'c1_0@c100',stdlib,"3.11.2"},{"c100","c1","c1_0",'c1_0@c100',kernel,"6.5.1"},
      {"c100","c1","c1_1",'c1_1@c100',stdlib,"3.11.2"},{"c100","c1","c1_1",'c1_1@c100',kernel,"6.5.1"},
      {"c100","c1","c1_2",'c1_2@c100',stdlib,"3.11.2"},{"c100","c1","c1_2",'c1_2@c100',kernel,"6.5.1"},
      {"c100","c1","c1_3",'c1_3@c100',stdlib,"3.11.2"},{"c100","c1","c1_3",'c1_3@c100',kernel,"6.5.1"},
      {"c201","c1","c1_0",'c1_0@c201',stdlib,"3.11.2"},{"c201","c1","c1_0",'c1_0@c201',kernel,"6.5.1"},
      {"c201","c1","c1_1",'c1_1@c201',stdlib,"3.11.2"},{"c201","c1","c1_1",'c1_1@c201',kernel,"6.5.1"},
      {"c201","c1","c1_2",'c1_2@c201',stdlib,"3.11.2"},{"c201","c1","c1_2",'c1_2@c201',kernel,"6.5.1"},
      {"c201","c1","c1_3",'c1_3@c201',stdlib,"3.11.2"},{"c201","c1","c1_3",'c1_3@c201',kernel,"6.5.1"}],
     [{"c100","c2","c2_0",'c2_0@c100',stdlib,"3.11.2"},{"c100","c2","c2_0",'c2_0@c100',kernel,"6.5.1"},
      {"c100","c2","c2_1",'c2_1@c100',stdlib,"3.11.2"},{"c100","c2","c2_1",'c2_1@c100',kernel,"6.5.1"},
      {"c100","c2","c2_2",'c2_2@c100',stdlib,"3.11.2"},{"c100","c2","c2_2",'c2_2@c100',kernel,"6.5.1"}]]=AllServicesList,
        
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    {ok,AllServicesList}.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
remove([])->
    [];
remove(L)->
    lists:reverse(remove(L,[])).

remove([],Acc)->
    Acc;
remove([{_HostName,ClusterName}|T],Acc)->
    NewAcc=case lists:member(ClusterName,Acc) of
	       true->
		   Acc;
	       false->
		   [ClusterName|Acc]
	   end,
    remove(T,NewAcc).
   

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
