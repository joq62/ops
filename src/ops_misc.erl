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
-module(ops_misc).   
 
-export([
	 create_cluster_node/3,
	 delete_cluster_node/3,
	 is_cluster_node_present/3,
	 cluster_names/1,
	 cluster_intent/1,
	 cluster_intent/2

	]).
-export([
	 create_pod_node/4,
	 delete_pod_node/4,
	 is_pod_node_present/4,
	 pod_name_dir_list/3,
	 pod_intent/1,
	 pod_intent/2


	]).

-export([
	
	]).



%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
pod_intent(ClusterSpec)->
    pod_lib:intent(ClusterSpec).

pod_intent(WantedClusterName,ClusterSpec)->
    pod_lib:intent(WantedClusterName,ClusterSpec).
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
pod_name_dir_list(HostName,ClusterName,ClusterSpec)->
    pod_data:name_dir_list(HostName,ClusterName,ClusterSpec).
    
%%--------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

create_pod_node(HostName,ClusterName,PodName,ClusterSpec)->
    pod_lib:start_node(HostName,ClusterName,PodName,ClusterSpec).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
delete_pod_node(HostName,ClusterName,PodName,ClusterSpec)->
    cluster_lib:stop_node(HostName,ClusterName,PodName,ClusterSpec).

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
is_pod_node_present(HostName,ClusterName,PodName,ClusterSpec)->
    pod_lib:is_node_present(HostName,ClusterName,PodName,ClusterSpec).

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
cluster_intent(ClusterSpec)->
    cluster_lib:intent(ClusterSpec).

cluster_intent(WantedClusterName,ClusterSpec)->
    cluster_lib:intent(WantedClusterName,ClusterSpec).
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
cluster_names(ClusterSpec)->
    HostClusterNameList=cluster_data:cluster_all_names(ClusterSpec),
    HostClusterNameList.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

create_cluster_node(HostName,ClusterName,ClusterSpec)->
    cluster_lib:start_node(HostName,ClusterName,ClusterSpec).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
delete_cluster_node(HostName,ClusterName,ClusterSpec)->
    cluster_lib:stop_node(HostName,ClusterName,ClusterSpec).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
is_cluster_node_present(HostName,ClusterName,ClusterSpec)->
    cluster_lib:is_node_present(HostName,ClusterName,ClusterSpec).
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
