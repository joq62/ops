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
	 is_cluster_node_present/3

	]).

-export([
	 cluster_names/1
	]).



%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-define(NODENAME,"ops").
-define(TEMP_DIR,"temp_ops").
-define(SSH_TIMEOUT,5000).
-define(Node(HostName),list_to_atom(?NODENAME++"@"++HostName)).

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
    {ok,ClusterCookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    {ok,ClusterDir}=cluster_data:cluster_spec(dir,HostName,ClusterName,ClusterSpec),
    create_node(HostName,ClusterName,ClusterCookie,ClusterDir).

%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
create_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)->
    Result=case dist_lib:start_node(HostName,ClusterNodeName,ClusterCookie," -detached  ") of
	       {error,Reason}->
		   {error,[Reason,HostName,ClusterNodeName,ClusterCookie]};
	       {ok,ClusterNode} ->
		   dist_lib:rmdir_r(ClusterNode,ClusterCookie,ClusterDir),
		   case dist_lib:mkdir(ClusterNode,ClusterCookie,ClusterDir) of
		       {error,Reason}->
			   {error,[Reason,HostName,ClusterNodeName,ClusterCookie]};
		       ok->
			   case dist_lib:cmd(ClusterNode,ClusterCookie,filelib,is_dir,[ClusterDir],5000) of
			       false->
				   {error,[cluster_dir_eexists,ClusterDir,HostName,ClusterNodeName,ClusterCookie]};
			       true->
				   {ok,{HostName,ClusterNodeName,ClusterNode,ClusterCookie,ClusterDir}}
			   end
		   end
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
delete_cluster_node(HostName,ClusterName,ClusterSpec)->
    {ok,Node}=cluster_data:cluster_spec(node,HostName,ClusterName,ClusterSpec),
    {ok,Cookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    {ok,Dir}=cluster_data:cluster_spec(dir,HostName,ClusterName,ClusterSpec),
    dist_lib:rmdir_r(Node,Cookie,Dir),
 %   io:format("Rm ~p~n",[{R,Dir,?MODULE,?FUNCTION_NAME}]),
    dist_lib:stop_node(HostName,ClusterName,Cookie),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
is_cluster_node_present(HostName,ClusterName,ClusterSpec)->
    {ok,Node}=cluster_data:cluster_spec(node,HostName,ClusterName,ClusterSpec),
    {ok,Cookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    case dist_lib:ping(node(),Cookie,Node) of
	pang->
	    false;
	pong->
	    true
    end.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
