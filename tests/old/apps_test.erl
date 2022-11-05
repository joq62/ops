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
-module(apps_test).   
 
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
    
    gl=all_services(),
    
  
    
    io:format("Test OK !!! ~p~n",[?MODULE]),
 %   ok=cleanup(),
    ok.






%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
all_services()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
      
    AllServices=cluster:all_services(),
    io:format("AllServices ~p~n",[{AllServices,?MODULE,?FUNCTION_NAME}]),
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    
    ok.


remove_duplicates([])->
    [];
remove_duplicates(L)->
    lists:reverse(remove_duplicates(L,[])).

remove_duplicates([],Acc)->
    Acc;
remove_duplicates([{ClusterName,Info}|T],Acc)->
     NewAcc=case lists:keymember(ClusterName,1,Acc) of
	       true->
		   Acc;
	       false->
		   [{ClusterName,Info}|Acc]
	   end,
    
    remove_duplicates(T,NewAcc).
   

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
cluster_stop()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    HostClusterNameList=cluster:cluster_names(),
    [cluster:stop_cluster_node(HostName,ClusterName)||{HostName,ClusterName}<-HostClusterNameList],

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
    ok=cluster_stop(),
    io:format("Start cluster:intent_cluster() ~p~n",[?FUNCTION_NAME]),
    IntentCluster=cluster:intent_cluster(),
    io:format("IntentCluster ~p~n",[{IntentCluster,?FUNCTION_NAME}]),
      
    IntentPods=cluster:intent_pods(),
    io:format("IntentPods ~p~n",[{IntentPods,?FUNCTION_NAME}]),

    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),

    ok.

cleanup()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    ok=cluster_stop(),        
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    timer:sleep(3000),
    init:stop(),
    ok.



