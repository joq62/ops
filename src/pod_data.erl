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
-module(pod_data).   
 
-export([
	 name_dir_list/3
	]).

-export([
	 pod_all_names/3,
	 pod_info_by_name/4,
	 
	 pod/2,
	 pod_hostname/3,
	 pod_node/3
	]).



-record(pod_info,{
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

pod(Key,PodInfo)->
    Result=case Key of
	       hostname->
		   PodInfo#pod_info.hostname;
	       node->
		   PodInfo#pod_info.node;
	       name->
		   PodInfo#pod_info.name;
	       dir->
		   PodInfo#pod_info.dir;
	       Eexists->
		   {error,[eexists,Eexists]}
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

pod_info_by_name(HostName,ClusterName,PodName,ClusterSpec)->
     Result=case cluster_data:cluster_spec(pods_info,HostName,ClusterName,ClusterSpec) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,PodsInfoList}->
		   I=[X||X<-PodsInfoList,
			 PodName=:=cluster_data:pod(name,X)],
		   case I of
		       []->
			   {error,[eexists,PodName]};
		       [PodInfo]->
			   {ok,PodInfo}
		   end
	    end,
    Result.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
name_dir_list(HostName,ClusterName,ClusterSpec)->
    Result=case cluster_data:cluster_spec(pods_info,HostName,ClusterName,ClusterSpec) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,PodsInfoList}->
		   [{pod(name,PodInfo),pod(dir,PodInfo)}||PodInfo<-PodsInfoList]
	   end,
    Result.
		   
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------    

pod_hostname(Key,HostName,PodInfo)->
    R=[I||I<-PodInfo,
	  HostName=:=I#pod_info.hostname],
    
    Result=case R of
	       []->
		   {error,[eexists,HostName]};
	       _->
		   case Key of
		       name_dir->
			   [{X#pod_info.name,X#pod_info.dir}||X<-R];
		       Eexists->
			   {error,[eexists,Eexists]}
		   end
	   end,
    case Result of
	{error,Reason}->
	    {error,Reason};
	_ ->
	    {ok,Result}
    end.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

pod_node(Key,Node,PodInfo)->
    R=[I||I<-PodInfo,
	  Node=:=I#pod_info.node],
    
    Result=case R of
	       []->
		   {error,[eexists,Node]};
	       [X]->
		   case Key of
		       hostname->
			   X#pod_info.hostname;
		       name->
			   X#pod_info.name;
		       dir->
			   X#pod_info.dir;
		       Eexists->
			   {error,[eexists,Eexists]}
		   end
	   end,
       Result.


			   
pod_all_names(HostName,ClusterName,ClusterSpec)->
    Result=case cluster_data:cluster_spec(pods_info,HostName,ClusterName,ClusterSpec) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,PodsInfoList}->
		   %io:format("PodsInfoList ~p~n",[{?FUNCTION_NAME,PodsInfoList}]),
		   PodNameList=[cluster_data:pod(name,PodInfo)||PodInfo<-PodsInfoList],
		   do_pod_name_list(HostName,ClusterName,PodNameList,[])
	   end,
    Result.


do_pod_name_list(_HostName,_ClusterName,[],Acc)->
    Acc;
do_pod_name_list(HostName,ClusterName,[PodName|T],Acc)->
  %  io:format("PodName ~p~n",[{?FUNCTION_NAME,PodName}]),
    NewAcc=[{HostName,ClusterName,PodName}|Acc],
    do_pod_name_list(HostName,ClusterName,T,NewAcc).


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
