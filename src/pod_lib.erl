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
-module(pod_lib).    
 
-export([

	 is_node_present/4,
	 start_node/4,
	 stop_node/4,
	 intent/2,
	 intent/1
	 
	]).
		 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
intent(ClusterSpec)->
    WantedStateCluster=cluster_data:all_names(ClusterSpec),
    AllPodNames=lists:append([pod_data:all_names(HostName,ClusterName,ClusterSpec)||{HostName,ClusterName}<-WantedStateCluster]),

    StatusPods=[{is_node_present(HostName,ClusterName,PodName,ClusterSpec),HostName,ClusterName,PodName}||{HostName,ClusterName,PodName}<-AllPodNames],  
  %  io:format("StatusPods ~p~n",[{?FUNCTION_NAME,?LINE,StatusPods}]),
    MissingPods=[{HostName,ClusterName,PodName}||{false,HostName,ClusterName,PodName}<-StatusPods],
    Started=[start_node(HostName,ClusterName,PodName,ClusterSpec)||{HostName,ClusterName,PodName}<-MissingPods],
    
    StatusPods1=[{is_node_present(HostName,ClusterName,PodName,ClusterSpec),HostName,PodName,ClusterName}||{HostName,ClusterName,PodName}<-AllPodNames],   
  %  io:format("StatusPods1 ~p~n",[{?FUNCTION_NAME,?LINE,StatusPods1}]),
    MissingPods1=[{HostName,ClusterName,PodName}||{false,HostName,ClusterName,PodName}<-StatusPods1],
    PresentPods1=[{HostName,ClusterName,PodName}||{true,HostName,ClusterName,PodName}<-StatusPods1],   
      
    {Started,MissingPods1,PresentPods1}.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
intent(WantedClusterName,ClusterSpec)->
    
    WantedStateCluster=cluster_data:all_names(ClusterSpec),
    AllPodNames=lists:append([pod_data:all_names(HostName,ClusterName,ClusterSpec)||{HostName,ClusterName}<-WantedStateCluster,
											    WantedClusterName=:=ClusterName]),

    StatusPods=[{is_node_present(HostName,ClusterName,PodName,ClusterSpec),HostName,ClusterName,PodName}||{HostName,ClusterName,PodName}<-AllPodNames],  
    MissingPods=[{HostName,ClusterName,PodName}||{false,HostName,ClusterName,PodName}<-StatusPods],
    Started=[start_node(HostName,ClusterName,PodName,ClusterSpec)||{HostName,ClusterName,PodName}<-MissingPods],

    StatusPods1=[{is_node_present(HostName,ClusterName,PodName,ClusterSpec),HostName,PodName,ClusterName}||{HostName,ClusterName,PodName}<-AllPodNames],   
    MissingPods1=[{HostName,ClusterName,PodName}||{false,HostName,ClusterName,PodName}<-StatusPods1],
    PresentPods1=[{HostName,ClusterName,PodName}||{true,HostName,ClusterName,PodName}<-StatusPods1],   

    {Started,MissingPods1,PresentPods1}.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
is_node_present(HostName,ClusterName,PodName,ClusterSpec)->
    Result=case pod_data:info(HostName,ClusterName,PodName,ClusterSpec) of
	       {error,Reason}->
		   {error,[?MODULE,?FUNCTION_NAME,?LINE,Reason]};
	       PodInfo->
		   %io:format("PodsInfo ~p~n",[{?FUNCTION_NAME,?LINE,PodsInfo}]),
		   PodNode=pod_data:item(node,PodInfo),
		   Cookie=cluster_data:item(cookie,HostName,ClusterName,ClusterSpec),
		   case dist_lib:ping(node(),Cookie,PodNode) of
		       pang->
			   false;
		       pong->
			   true
		   end
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
start_node(HostName,ClusterName,PodName,ClusterSpec)->
   % io:format(" ~p~n",[{HostName,ClusterName,PodName,?MODULE,?FUNCTION_NAME}]),
    Result=case pod_data:info(HostName,ClusterName,PodName,ClusterSpec) of
	       {error,Reason}->
		   {error,[?MODULE,?FUNCTION_NAME,?LINE,Reason]};
	       PodInfo->
		   ClusterNode=cluster_data:item(node,HostName,ClusterName,ClusterSpec),
		   ClusterCookie=cluster_data:item(cookie,HostName,ClusterName,ClusterSpec),
		   Args=" -setcookie "++ClusterCookie,
		   case pod_data:item(dir,PodInfo) of
		       {error,Reason}->
			   {error,[?MODULE,?FUNCTION_NAME,?LINE,Reason]};
		       PodDir->
			   create(ClusterNode,ClusterCookie,HostName,ClusterName,PodName,PodDir,Args)
		   end
	   end,
  %  io:format("Result ~p~n",[{Result,?MODULE,?FUNCTION_NAME}]),
    Result.

%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
create(ClusterNode,ClusterCookie,HostName,ClusterName,PodNodeName,PodDir,Args)-> 
    dist_lib:rmdir_r(ClusterNode,ClusterCookie,PodDir),
    Result=case dist_lib:mkdir(ClusterNode,ClusterCookie,PodDir) of
	       {error,Reason}->
		   {error,[?MODULE,?FUNCTION_NAME,?LINE,Reason,ClusterNode,PodDir]};
	       ok->
		   case dist_lib:cmd(ClusterNode,ClusterCookie,filelib,is_dir,[PodDir],5000) of
		       false->
			   {error,[?MODULE,?FUNCTION_NAME,?LINE,cluster_dir_eexists,PodDir,ClusterNode]};
		       true->
			   case dist_lib:cmd(ClusterNode,ClusterCookie,slave,start,[HostName,PodNodeName,Args],5000) of
			       {error,[?MODULE,?FUNCTION_NAME,?LINE,Reason]}->
				   dist_lib:rmdir_r(ClusterNode,ClusterCookie,PodDir),
				    {error,Reason};
			        {ok,PodNode}->
				   case dist_lib:cmd(ClusterNode,ClusterCookie,net_adm,ping,[PodNode],3000) of
				       pang->
					   dist_lib:rmdir_r(ClusterNode,ClusterCookie,PodDir),
					   {error,[?MODULE,?FUNCTION_NAME,?LINE,failed_to_connect,PodNode]};
				       pong->
					   {ok,{HostName,ClusterName,ClusterCookie,PodNode,PodDir}}
				   end
			   end
		   end
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
stop_node(HostName,ClusterName,PodName,ClusterSpec)->
    Result=case pod_data:info(HostName,ClusterName,PodName,ClusterSpec) of
	       {error,Reason}->
		   {error,[?MODULE,?FUNCTION_NAME,?LINE,Reason]};
	       PodInfo->
		   case pod_data:item(dir,PodInfo) of
		       {error,Reason}->
			   {error,Reason};
		       PodDir->
			   ClusterNode=cluster_data:item(node,HostName,ClusterName,ClusterSpec),
			   ClusterCookie=cluster_data:item(cookie,HostName,ClusterName,ClusterSpec),
			   dist_lib:rmdir_r(ClusterNode,ClusterCookie,PodDir),
			   dist_lib:stop_node(HostName,PodName,ClusterCookie)
		   end
	   end,
    Result.



%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
