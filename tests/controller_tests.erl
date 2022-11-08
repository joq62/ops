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
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
          
    {ok,"c100",PodNodeC100}=ops:create_controller("c100"),
    {ok,"c200",PodNodeC200}=ops:create_controller("c200"),
 
   
    [PodNodeC100,
     PodNodeC200,
     'test_cluster_connect@c100',
     'test_cluster_connect@c200']=lists:sort([PodNodeC100|rpc:call(PodNodeC100,erlang,nodes,[],1000)]),
 
    
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create1_tests()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    AppId="controller_app",
    App=controller_app,
    AllEnvs=application:get_all_env(ops),
%    kuken=AllEnvs

    {cluster_name,ClusterName}=lists:keyfind(cluster_name,1,AllEnvs),
    {application_spec,ApplicationSpec}=lists:keyfind(application_spec,1,AllEnvs),
    {cluster_spec,ClusterSpec}=lists:keyfind(cluster_spec,1,AllEnvs),
    {deployment_spec,DeploymentSpec}=lists:keyfind(deployment_spec,1,AllEnvs),
    {host_spec,HostSpec}=lists:keyfind(host_spec,1,AllEnvs),
    {spec_dir,SpecDir}=lists:keyfind(spec_dir,1,AllEnvs),
    {nodes_to_connect,NodesToConnect}=lists:keyfind(nodes_to_connect,1,AllEnvs),
    
    ControllerEnv=[{App,[{deployment_spec,DeploymentSpec},
				    {cluster_spec,ClusterSpec},
				    {host_spec,HostSpec},
				    {application_spec,ApplicationSpec},
				    {spec_dir,SpecDir},
				    {nodes_to_connect,NodesToConnect}]}],
        
    {ok,"c100",PodNodeC100}=ops:create_pod("c100",AppId,ControllerEnv),
    {ok,"c200",PodNodeC200}=ops:create_pod("c200",AppId,ControllerEnv),
   
    [PodNodeC100,
     PodNodeC200,
     'test_cluster_connect@c100',
     'test_cluster_connect@c200']=lists:sort([PodNodeC100|rpc:call(PodNodeC100,erlang,nodes,[],1000)]),
 
    
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
    {ok,'test_cluster_connect@c100',
     [{pong,'test_cluster_connect@c100'},
      {pang,'test_cluster_connect@c200'}]}=ops:create_connect_node("c100"),
   {ok,'test_cluster_connect@c200',
     [{pong,'test_cluster_connect@c100'},
      {pong,'test_cluster_connect@c200'}]}=ops:create_connect_node("c200"),
  
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok.
