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
-module(controller_tests).      
 
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
    []=ops:controllers(),

    {error,[not_started,"c100"]}=ops:delete_controller("c100"),
    ok=ops:create_controller("c100"),
    [
     [{host_name,"c100"},
      {node,NC100},
      {dir,"test_cluster"},
      {time,{_,_}}]
    ]=ops:controllers(),
    pong=rpc:call(NC100,controller,ping,[],2000),
    {error,[already_started,"c100"]}=ops:create_controller("c100"),


    ok=ops:create_controller("c200"),
   
    [
     [{host_name,"c100"},
      {node,NC100},
      {dir,"test_cluster"},
      {time,{_,_}}],
     [{host_name,"c200"},
      {node,NC200},
      {dir,"test_cluster"},
      {time,{_,_}}]]=lists:sort(ops:controllers()),

    
    pong=rpc:call(NC200,controller,ping,[],2000),
    
    ok=ops:delete_controller("c100"),

    [
     [{host_name,"c200"},
      {node,NC200},
      {dir,"test_cluster"},
      {time,{_,_}}]
    ]=ops:controllers(),
    ok=ops:delete_controller("c200"),
    
    []=ops:controllers(),
   
    
    
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
