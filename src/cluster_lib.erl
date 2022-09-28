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
-module(cluster_lib).   
 
-export([

	 is_cluster_present/1,
	 is_node_present/3,
	 start_node/3,
	 stop_node/3
	 
	]).
		 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
is_cluster_present(ClusterName)->
    {error,[not_implemeted,?FUNCTION_NAME,ClusterName]}.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
is_node_present(HostName,ClusterName,ClusterSpec)->
    {ok,Node}=cluster_data:cluster_spec(node,HostName,ClusterName,ClusterSpec),
    {ok,Cookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    case dist_lib:ping(node(),Cookie,Node) of
	pang->
	    false;
	pong->
	    true
    end.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
start_node(HostName,ClusterName,ClusterSpec)->
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
stop_node(HostName,ClusterName,ClusterSpec)->
    {ok,Node}=cluster_data:cluster_spec(node,HostName,ClusterName,ClusterSpec),
    {ok,Cookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    {ok,Dir}=cluster_data:cluster_spec(dir,HostName,ClusterName,ClusterSpec),
    dist_lib:rmdir_r(Node,Cookie,Dir),
 %   io:format("Rm ~p~n",[{R,Dir,?MODULE,?FUNCTION_NAME}]),
    dist_lib:stop_node(HostName,ClusterName,Cookie),
    ok.



%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
