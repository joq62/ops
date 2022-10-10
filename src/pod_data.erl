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
	 all_names/3,
	 info/4,
	 item/2,
	 name_dir_list/3
	]).

-export([

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
all_names(HostName,ClusterName,ClusterSpec)->
    Result=case cluster_data:item(pods_info,HostName,ClusterName,ClusterSpec) of
	       {error,Reason}->
		   {error,Reason};
	       PodsInfoList->
		%io:format("PodsInfoList ~p~n",[{?FUNCTION_NAME,PodsInfoList}]),
		   PodNameList=[item(name,PodInfo)||PodInfo<-PodsInfoList],
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
info(HostName,ClusterName,PodName,ClusterSpec)->
    Result=case cluster_data:item(pods_info,HostName,ClusterName,ClusterSpec) of
	       {error,Reason}->
		   {error,[?MODULE,?FUNCTION_NAME,?LINE,Reason]};
	       PodsInfoList->
		   I=[X||X<-PodsInfoList,
			 PodName=:=item(name,X)],
		   case I of
		       []->
			   {error,[eexists,PodName]};
		       [PodInfo]->
			   PodInfo
		   end
	   end,
    Result.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
item(Key,PodInfo)->
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
name_dir_list(HostName,ClusterName,ClusterSpec)->
    Result=case cluster_data:cluster_spec(pods_info,HostName,ClusterName,ClusterSpec) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,PodsInfoList}->
		   [{item(name,PodInfo),item(dir,PodInfo)}||PodInfo<-PodsInfoList]
	   end,
    Result.
		   



%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
all_pod_nodes(HostName,ClusterName,ClusterSpec)->
    HostClusterPodNameList=all_names(HostName,ClusterName,ClusterSpec),  %{HostName,ClusterName,PodName}
    HostClusterPodNamePodNodeList=[{HostName,ClusterName,PodName,item(node,PodInfo)}||{HostName,ClusterName,PodName}<-HostClusterPodNameList,
										      PodInfo=info(HostName,ClusterName,PodName,ClusterSpec)],
    HostClusterPodNamePodNodeList.
    
    

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
