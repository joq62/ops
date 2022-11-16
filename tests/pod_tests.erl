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
-module(pod_tests).      
 
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
    ok=create_delete_connect_node_tests(),
    ok=create_connect_tests(),
    %% Three connect_nodes running
    {ok,PodNodeC100,PoDirC100}=create_controller_pod("c100"),
    ok=create_controller(),
    


    {ok,PodNodeC200,PoDirC200}=create_controller_pod("c200"),
    {ok,PodNodeC201,PoDirC201}=create_controller_pod("c201"),
    [PodNodeC100,PodNodeC200,PodNodeC201|_]=lists:sort([PodNodeC201|rpc:call(PodNodeC201,erlang,nodes,[])]),
    
    
    
    

    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
 
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create_controller()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
   
    
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create_controller_pod(HostName)->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    PodApp="pod_app",
    {ok,HostName,PodNode}=ops:create_pod(HostName,PodApp,[]),
    
    pong=rpc:call(PodNode,resource_discovery_server,ping,[]),

    [[{host_name,HostName},
      {node,PodNode},
      {dir,PodDir},
      {time,{_,_}}]]=[L||L<-ops:pods(),
			true=:=lists:keymember(HostName,2,L)],
    
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    {ok,PodNode,PodDir}.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create_connect_tests()->
    
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    HostName="c100",

    []=ops:connect_nodes(),
    {ok,C100,[{pong,'test_cluster_connect@c100'},
	      {pang,'test_cluster_connect@c200'},
	      {pang,'test_cluster_connect@c201'}]}=ops:create_connect_node("c100"),
    
    [{"c100",'test_cluster_connect@c100',"test_cluster",
      {_,_}}]=ops:connect_nodes(),

    io:format("c100 created ~p~n",[{?MODULE,?FUNCTION_NAME}]),
   
    {ok,C200,[{pong,'test_cluster_connect@c100'},
	      {pong,'test_cluster_connect@c200'},
	      {pang,'test_cluster_connect@c201'}]}=ops:create_connect_node("c200"),
   
    [{"c200",C200,"test_cluster",{_,_}},
     {"c100",C100,"test_cluster",{_,_}}
    ]=ops:connect_nodes(),

    io:format("c200 created ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    {ok,C201,[{pong,'test_cluster_connect@c100'},
	      {pong,'test_cluster_connect@c200'},
	      {pong,'test_cluster_connect@c201'}]}=ops:create_connect_node("c201"),
   
    [
     {"c201",C201,"test_cluster",{_,_}},
     {"c200",C200,"test_cluster",{_,_}},
     {"c100",C100,"test_cluster",{_,_}}
    ]=ops:connect_nodes(),
    
    io:format("c201 created ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create_delete_connect_node_tests()->
    
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    HostName="c100",

    []=ops:connect_nodes(),
    {ok,ConnectNode,[{pong,'test_cluster_connect@c100'},
		     {pang,'test_cluster_connect@c200'},
		     {pang,'test_cluster_connect@c201'}]}=ops:create_connect_node(HostName),
   
    [{"c100",'test_cluster_connect@c100',"test_cluster",
      {_,_}}]=ops:connect_nodes(),
    
    ok=ops:delete_connect_node(HostName),
    []=ops:connect_nodes(),
    
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
