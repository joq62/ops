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
-module(cluster).   
 
-export([
	 stop/4,

	 create_all_clusters/1,
	 delete_all_clusters/1,

	 create_node/4,
	 delete_node/4,
	 availble/3,
	 not_availble/3,
	 connect/3
	]).
		 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
create_all_clusters(ClusterSpec)->
    StartedClusterNodes=create_clusters(ClusterSpec),
    %StartedPods=create_pods(StartedClusterNodes,ClusterSpec),
    StartedClusterNodes.



create_clusters(ClusterSpec)->
    AllClusterNameHost=cluster_data:clustera_all_names(ClusterSpec),
    [NameHost||{ok,NameHost}<-create_cluster_node(AllClusterNameHost,ClusterSpec,[])].

create_cluster_node([],_,Acc)->
    Acc;
create_cluster_node([NameHost|T],ClusterSpec,Acc)->
    io:format(" Progress  ~p~n",[{?FUNCTION_NAME,NameHost}]),
    
    {ok,HostName}=cluster_data:cluster_spec(hostname,NameHost,ClusterSpec),
    {ok,ClusterNodeName}=cluster_data:cluster_spec(name,NameHost,ClusterSpec),
    {ok,ClusterCookie}=cluster_data:cluster_spec(cookie,NameHost,ClusterSpec),
    {ok,ClusterDir}=cluster_data:cluster_spec(dir,NameHost,ClusterSpec),
    {R,_}=create_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir),
    create_cluster_node(T,ClusterSpec,[{R,NameHost}|Acc]).


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
delete_all_clusters(ClusterSpec)->
    StartedClusterNodes=delete_clusters(ClusterSpec),
    %StartedPods=create_pods(StartedClusterNodes,ClusterSpec),
    StartedClusterNodes.



delete_clusters(ClusterSpec)->
    AllClusterNameHost=cluster_data:clustera_all_names(ClusterSpec),
    [NameHost||{ok,NameHost}<-delete_cluster_node(AllClusterNameHost,ClusterSpec,[])].

delete_cluster_node([],_,Acc)->
    Acc;
delete_cluster_node([NameHost|T],ClusterSpec,Acc)->
    io:format(" Progress  ~p~n",[{?FUNCTION_NAME,NameHost}]),

    {ok,HostName}=cluster_data:cluster_spec(hostname,NameHost,ClusterSpec),
    {ok,ClusterNodeName}=cluster_data:cluster_spec(name,NameHost,ClusterSpec),
    {ok,ClusterCookie}=cluster_data:cluster_spec(cookie,NameHost,ClusterSpec),
    {ok,ClusterDir}=cluster_data:cluster_spec(dir,NameHost,ClusterSpec),
    R=delete_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir),
    delete_cluster_node(T,ClusterSpec,[{R,NameHost}|Acc]).
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

stop(HostNames,ClusterNodeName,ClusterCookie,ClusterDir)->
    [delete_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)||HostName<-HostNames].
	      
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)->
    Result=case dist_lib:start_node(HostName,ClusterNodeName,ClusterCookie," -detached  ") of
	       {error,Reason}->
		   {error,[Reason,HostName,ClusterNodeName,ClusterCookie]};
	       true ->
		   ClusterNode=list_to_atom(ClusterNodeName++"@"++HostName),
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
%% --------------------------------------------------------------------

delete_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)->
    ClusterNode=list_to_atom(ClusterNodeName++"@"++HostName),
    dist_lib:rmdir_r(ClusterNode,ClusterCookie,ClusterDir),
    dist_lib:stop_node(HostName,ClusterNodeName,ClusterCookie).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
availble(HostNames,ClusterNodeName,ClusterCookie)->
    {Available,_}=connect(HostNames,ClusterNodeName,ClusterCookie),
    Available.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
not_availble(HostNames,ClusterNodeName,ClusterCookie)->
    {_,NotAvailable}=connect(HostNames,ClusterNodeName,ClusterCookie),
    NotAvailable.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
connect(HostNames,ClusterNodeName,ClusterCookie)->
    [ClusterNode1|T]=[list_to_atom(ClusterNodeName++"@"++HostName)||HostName<-HostNames],
    R=[{Node,dist_lib:cmd(ClusterNode1,ClusterCookie,net_adm,ping,[Node],5000)}||Node<-T],
    Available=[ClusterNode1|[Node||{Node,pong}<-R]],
    NotAvailable=[Node||{Node,pang}<-R],
    {Available,NotAvailable}.
