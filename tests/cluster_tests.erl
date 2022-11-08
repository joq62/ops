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
-module(cluster_tests).      
 
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
    ok=connect_tests(),
    ok=controller_tests(),

    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
 
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
controller_tests()->

    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),  
    %{ok,"c100",PodNodeC100}=ops:create_controller("c100"),
  
    ControllerStart=[ops:create_controller(HostName)||{HostName,_,_,_}<-ops:connect_nodes()],
    [{ok,"c100",ControllerC100},
     {ok,"c200",ControllerC200},
     {ok,"c201",ControllerC201}
    ]=lists:sort(ControllerStart),
    
    [
     {"c100",ConnectC100,"test_cluster",{_,_}},
     {"c200",ConnectC200,"test_cluster",{_,_}},
     {"c201",ConnectC201,"test_cluster",{_,_}}
    ]=lists:sort(ops:connect_nodes()),

    [ControllerC201,ControllerC200,ControllerC100,
     ConnectC100,ConnectC200,ConnectC201
    ]=lists:sort([ControllerC100|rpc:call(ControllerC100,erlang,nodes,[],2000)]),
    [_,_,_]=rpc:call(ControllerC201,sd,get_node,[controller_app],1000),
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
connect_tests()->

    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),  
    DeleteConnect1=[ops:delete_connect_node(HostName)||HostName<-config:cluster_hostnames(?ClusterName)],
    
    %io:format("DeleteConnect1 ~p~n",[{DeleteConnect1,?MODULE,?FUNCTION_NAME,?LINE}]),
    StartConnect=[ops:create_connect_node(HostName)||HostName<-config:cluster_hostnames(?ClusterName)],
%    io:format("StartConnect ~p~n",[{StartConnect,?MODULE,?FUNCTION_NAME,?LINE}]),
    [
     {"c100",ConnectC100,"test_cluster",{_,_}},
     {"c200",ConnectC200,"test_cluster",{_,_}},
     {"c201",ConnectC201,"test_cluster",{_,_}}
    ]=lists:sort(ops:connect_nodes()),
    [ConnectC100,ConnectC200,ConnectC201]=[ConnectC100|rpc:call(ConnectC100,erlang,nodes,[],2000)],
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
    
    pong=ops:ping(),
    pong=config:ping(),
    []=ops:connect_nodes(),
   
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok.
