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
-module(pod).   
 
-export([
	 node/3
	]).

-export([
	 create/6,
	 delete/4,
	 available/3
	]).

-record(pod,{
	     hostname,
	     node,
	     name,
	     dir
	    }).
	     
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
node(Key,Node,PodInfoStatusList)->
    PodInfoList=[PodInfo||{_,PodInfo}<-PodInfoStatusList],
    Info=[I||I<-PodInfoList,
		       I#pod.node=:=node],   
    case Info of
	[]->
	    {error,[node_eexists,Node]};
        [I]->
	    case Key of
		hostname->
		    I#pod.hostname;
		node->
		    I#pod.node;
		name->
		    I#pod.name;
		dir->
		    I#pod.dir;
		Key ->
		    {error,[key_eexists,Key]}
	    end
    end.



%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create(ClusterNode,ClusterCookie,HostName,PodNodeName,PodDir,Args)-> 
    dist_lib:rmdir_r(ClusterNode,ClusterCookie,PodDir),
    Result=case dist_lib:mkdir(ClusterNode,ClusterCookie,PodDir) of
	       {error,Reason}->
		   {error,[Reason,ClusterNode,PodDir]};
	       ok->
		   case dist_lib:cmd(ClusterNode,ClusterCookie,filelib,is_dir,[PodDir],5000) of
		       false->
			   {error,[cluster_dir_eexists,PodDir,ClusterNode]};
		       true->
			   case dist_lib:cmd(ClusterNode,ClusterCookie,slave,start,[HostName,PodNodeName,Args],5000) of
			       {error,Reason}->
				   dist_lib:rmdir_r(ClusterNode,ClusterCookie,PodDir),
				    {error,Reason};
			        {ok,PodNode}->
				   case dist_lib:cmd(ClusterNode,ClusterCookie,net_adm,ping,[PodNode],3000) of
				       pang->
					   dist_lib:rmdir_r(ClusterNode,ClusterCookie,PodDir),
					   {error,[failed_to_connect,PodNode]};
				       pong->
					   {ok,{HostName,PodNode}}
				   end
			   end
		   end
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

delete(ClusterNode,ClusterCookie,PodNode,PodDir)->
    dist_lib:rmdir_r(ClusterNode,ClusterCookie,PodDir),
    dist_lib:cmd(ClusterNode,ClusterCookie,slave,stop,[PodNode],5000).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
available(HostNames,ClusterNodeName,ClusterCookie)->
    ClusterNodes=cluster:availble(HostNames,ClusterNodeName,ClusterCookie),
    [ClusterNode|_]=ClusterNodes,
    AllNodes=dist_lib:cmd(ClusterNode,ClusterCookie,erlang,nodes,[],5000),
    [N||N<-AllNodes,
	false=:=lists:member(N,ClusterNodes)].

