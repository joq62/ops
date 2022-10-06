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
-module(scheduler_lib).   
 
-export([
	 intent_cluster/2,
	 cluster_status/2,
	 intent_pod/2,
	 pod_status/2
	 	 
	]).
		 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
intent_cluster(ClusterName,ClusterSpec)->
    R=[{HostName,CN}||{HostName,CN}<-cluster_data:all_names(),
		      CN=:=ClusterName],
    io:format("ClusterName ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE,R}]),
    Status=[{ops:is_cluster_node_present(HostName,ClusterName)}||{HostName,ClusterName}<-R],
    Present=[{HostName,ClusterName}||{true,HostName,ClusterName}<-Status],
    NotPresent=[{HostName,ClusterName}||{false,HostName,ClusterName}<-Status],
    {{present,Present},{not_present,NotPresent}}.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
cluster_status(ClusterName,ClusterSpec)->
    {error,[not_implemeted,?FUNCTION_NAME,ClusterName]}.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
intent_pod(ClusterName,ClusterSpec)->
   
    not_implemted.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
pod_status(ClusterName,ClusterSpec)->
    {error,[not_implemeted,?FUNCTION_NAME,ClusterName]}.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
