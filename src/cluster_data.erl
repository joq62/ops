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
-module(cluster_data).   
 
-export([

	]).

-export([
	 pod_hostname/3,
	 pod_node/3,
	 
	 hostname/3
	]).

-export([
	 read_deployment_spec/0,
	 read_deployment_spec/1,
	 deployment_spec/3,
	 deployment_all_names/1
	]).

-export([
	 read_cluster_spec/0,
	 read_cluster_spec/1,
	 cluster_spec/3,
	 cluster_all_names/1
	]).

-export([
	 applist_all/1,
	 appl_list/3
	]).


-record(cluster_spec,{
		      name,
		      cookie,
		      node,
		      dir,
		      hostname,
		      num_pods,
		      pods_info
		     }).
-record(pod_info,{
		  hostname,
		  node,
		  name,
		  dir
		 }).

-record(deployment_spec,{
			 deploy_name,
			 cluster_name,
			 num_instances,
			 hostnames,
			 appl_list
			}).
-record(appl_list,{
		   appl,
		   app,
		   source_dir
		  }).
		
		   
			 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(ClusterSpecFile,"cluster.spec").
-define(DeploymentSpecFile,"deployment.spec").


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
applist_all(ApplList)->
    [I#appl_list.appl||I<-ApplList].

appl_list(Key,Appl,ApplList)->
    R=[I||I<-ApplList,
	  Appl=:=I#appl_list.appl],
    Result=case R of
	       []->
		   {error,[eexists,Appl]};
	       [X]->
		   case Key of
		       app->
			   X#appl_list.app;
		       source_dir->
			   X#appl_list.source_dir;
		       Eexists->
			   {error,[eexists,Eexists]}
		   end
	   end,
       Result.




%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
deployment_all_names(DeploymentSpec)->
    [I#deployment_spec.deploy_name||I<-DeploymentSpec].

deployment_spec(Key,DeploymentName,DeploymentSpec)->
    R=[I||I<-DeploymentSpec,
	  DeploymentName=:=I#deployment_spec.deploy_name],
    Result=case R of
	       []->
		   {error,[eexists,DeploymentName]};
	       [X]->
		   case Key of
		       cluster_name->
			   X#deployment_spec.cluster_name;
		       num_instances->
			   X#deployment_spec.num_instances;
		       hostnames->
			   X#deployment_spec.hostnames;
		       appl_list->
			   X#deployment_spec.appl_list;
		       Eexists->
			   {error,[eexists,Eexists]}
		   end
	   end,
       Result.



read_deployment_spec()->
    read_deployment_spec(?DeploymentSpecFile).

read_deployment_spec(DeploymentSpecFile)->
    Result=case file:consult(DeploymentSpecFile) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,I}->
		   [create_deployment_info(DeployName,ClusterName,NumInstances,HostNames,Appls)||{{deploy_name,DeployName},
												    {cluster_name,ClusterName},
												    {num_instances,NumInstances},
												    {hostnames,HostNames},
												    {appls,Appls}}<-I]
	   end,
    Result.


create_deployment_info(DeployName,ClusterName,NumInstances,HostNames,Appls)->
    ApplList=[#appl_list{appl=Appl,app=App,source_dir=SourceDir}||{{appl,Appl},{app,App},{source_dir,SourceDir}}<-Appls],
    #deployment_spec{deploy_name=DeployName,cluster_name=ClusterName,
		     num_instances=NumInstances,hostnames=HostNames,
		     appl_list=ApplList}.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
cluster_all_names(ClusterSpec)->
    [{I#cluster_spec.name,I#cluster_spec.hostname}||I<-ClusterSpec].

cluster_spec(Key,NameHost,ClusterSpec)->
    R=[I||I<-ClusterSpec,
	   NameHost=:={I#cluster_spec.name,I#cluster_spec.hostname}],
    Result=case R of
	       []->
		   {error,[eexists,NameHost]};
	       [X]->
		   case Key of
		       name->
			   X#cluster_spec.name;
		       cookie->
			   X#cluster_spec.cookie;
		       node->
			   X#cluster_spec.node;
		       dir->
			   X#cluster_spec.dir;
		       hostname->
			   X#cluster_spec.hostname;
		       num_pods->
			   X#cluster_spec.num_pods;
		       pods_info->
			   X#cluster_spec.pods_info;
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

		       
read_cluster_spec()->
    read_cluster_spec(?ClusterSpecFile).
read_cluster_spec(ClusterSpecFile)->
    Result=case file:consult(ClusterSpecFile) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,I}->
		   X=[create_cluster_spec(HostNames,Name,Cookie,Dir,NumPods)||{{name,Name},{cookie,Cookie},{dir,Dir},
									       {hostnames,HostNames},
									       {num_pods,NumPods}}<-I],
		   lists:append(X)
	   end,
    Result.


create_cluster_spec(HostNames,Name,Cookie,Dir,NumPods)->
    create_cluster_spec(HostNames,Name,Cookie,Dir,NumPods,[]).

create_cluster_spec([],_Name,_Cookie,_Dir,_NumPods,Acc)->
    Acc;
create_cluster_spec([HostName|T],Name,Cookie,Dir,NumPods,Acc) ->
    Node=list_to_atom(Name++"@"++HostName),
    PodNames=[Name++"_"++integer_to_list(N)||N<-lists:seq(0,NumPods)],
    PodsInfo=[#pod_info{hostname=HostName,node=list_to_atom(PodName++"@"++HostName),
		       name=PodName,dir=filename:join(Dir,PodName)}||PodName<-PodNames],
    NewAcc=[#cluster_spec{name=Name,cookie=Cookie,node=Node,dir=Dir,
			 hostname=HostName,num_pods=NumPods,pods_info=PodsInfo}|Acc],    
    create_cluster_spec(T,Name,Cookie,Dir,NumPods,NewAcc).
    


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

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
% {ClusterNodeName,Cookie,ClusterDir,HostName,NumPods,PodsInfo}
hostname(Key,HostName,ClusterInfoList)->
    Info=[I||I<-ClusterInfoList,
		       I#cluster_spec.hostname=:=HostName],   
    case Info of
	[]->
	    {error,[hostname_eexists,HostName]};
        [I]->
	    case Key of
		cookie->
		    I#cluster_spec.cookie;
		dir->
		    I#cluster_spec.dir;
		num_pods->
		    I#cluster_spec.num_pods;
		pods_info->
		    I#cluster_spec.pods_info;
		Key ->
		    {error,[key_eexists,Key]}
	    end
    end.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
