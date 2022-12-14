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
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok=setup(),
    ok=pod_tests:start(),
    %ok=cluster_tests:start(),
   
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
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
-define(NodesToConnect,['test_cluster_connect@c100','test_cluster_connect@c200','test_cluster_connect@c201']).

setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    erlang:set_cookie(node(),list_to_atom(?Cookie)),
        
    _R=[rpc:call(N,init,stop,[],2000)||N<-?NodesToConnect],
    timer:sleep(2000),

    AppEnv=[{ops,[{cluster_name,?ClusterName},
		  {deployment_spec,?DepFile},
		  {cluster_spec,?ClusterFile},
		  {host_spec,?HostFile},
		  {application_spec,?ApplicationFile},
		  {spec_dir,"."}]
	    }
	   ],


    ok=application:set_env(AppEnv),
    ok=application:start(ops),
    pong=config:ping(),
   
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok.
