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
-module(all).      
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),
    ok=controller_tests:start(),
              
    io:format("Test OK !!! ~p~n",[?MODULE]),
    timer:sleep(2000),
    init:stop(),
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
-define(ClusterName,"test_cluster").
-define(Cookie,"test_cluster_cookie").
-define(DepFile,"spec.deployment").
-define(ClusterFile,"spec.cluster").
-define(HostFile,"spec.host").
-define(ApplicationFile,"spec.application").

setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    % setup 
    erlang:set_cookie(node(),list_to_atom(?Cookie)),
    
    AppEnv=[{ops,[{cluster_name,?ClusterName},
		    {deployment_spec,?DepFile},
		    {cluster_spec,?ClusterFile},
		    {host_spec,?HostFile},
		    {application_spec,?ApplicationFile},
		    {spec_dir,"."}]}],
    ok=application:set_env(AppEnv),
    ok=application:start(ops),
    pong=ops:ping(),
    
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok.
