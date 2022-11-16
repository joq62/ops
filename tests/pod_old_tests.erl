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
-module(pod_old_tests).       
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(ClusterName,"test_cluster").



%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok=setup(),
    ok=create_tests(),

    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
 
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


create_tests()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
 
    []=ops:controllers(),
    {error,[not_started,"c100"]}=ops:get_controller_node("c100"),
    {error,[not_started,"c100"]}=ops:delete_controller("c100"),
    ok=ops:create_controller("c100"),
    {ok,'test_cluster_controller@c100'}=ops:get_controller_node("c100"),

    {ok,"c100",PodNode1}=ops:create_pod("c100","test_app_1",[]),
    42=rpc:call(PodNode1,test_add,add,[20,22]),
    
    [
     [{host_name,"c100"},
      {node,PodNode1},
      {dir,PodNodeDir1},
      {time,{_,_}}
     ]
    ]=ops:pods(),

    ok=ops:create_controller("c200"),
   
    {ok,"c200",PodNode2}=ops:create_pod("c200","test_app_1",[]),
    242=rpc:call(PodNode2,test_add,add,[220,22]),
    
    [
     [{host_name,"c100"},
      {node,PodNode1},
      {dir,PodNodeDir1},
      {time,{_,_}}
     ], 
     [{host_name,"c200"},
      {node,PodNode2},
      {dir,PodNodeDir2},
      {time,{_,_}}
     ]
    ]=lists:sort(ops:pods()),
    
    ok=ops:delete_pod("c100",PodNode1),
    [ 
     [{host_name,"c200"},
      {node,PodNode2},
      {dir,PodNodeDir2},
      {time,{_,_}}
     ]
    ]=lists:sort(ops:pods()),
    
    ok=ops:delete_pod("c200",PodNode2),
    []=lists:sort(ops:pods()),

    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

 

    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok.
