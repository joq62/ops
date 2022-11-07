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
-module(connect_tests).      
 
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
    []=ops:connect_nodes(),

    {error,[not_started_on_host,"c100"]}=ops:delete_connect_node("c100"),
    {ok,'test_cluster_connect@c100',
     [{pong,'test_cluster_connect@c100'},
      {pang,'test_cluster_connect@c200'}]}=ops:create_connect_node("c100"),

    [
     {"c100",
      Conn1,
      {_,_}}
    ]=ops:connect_nodes(),
    pong=net_adm:ping(Conn1),
    {error,[already_started_on_host,"c100"]}=ops:create_connect_node("c100"),


    {ok,
     'test_cluster_connect@c200',
     [{pong,'test_cluster_connect@c100'},
      {pong,'test_cluster_connect@c200'}]}=ops:create_connect_node("c200"),
   
    [
     {"c100",
      Conn1,
      {_,_}},
     {"c200",
      Conn2,
      {_,_}}
    ]=lists:sort(ops:connect_nodes()),

    pong=net_adm:ping(Conn2),
    
    ok=ops:delete_connect_node("c100"),

    [
     {"c200",
      Conn2,
      {_,_}}
    ]=lists:sort(ops:connect_nodes()),
    
    ok=ops:delete_connect_node("c200"),
    
    []=lists:sort(ops:connect_nodes()),
   
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
