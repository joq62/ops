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
-module(deployment_data).   
 

-export([
	 read_spec/0,
	 read_spec/1,
	 create/7,
	 all_names/1,
	 info/2,
	 item/3

	]).



-record(deployment_spec,{
			 deploy_name,
			 cluster_name,
			 num_instances,
			 host,       
			 pod,
			 services
			}).
		
		   
			 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(DeploymentSpecFile,"deployment.spec").


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
read_spec()->
    read_spec(?DeploymentSpecFile).

read_spec(DeploymentSpecFile)->
    Result=case file:consult(DeploymentSpecFile) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,I}->
		   [create(DeployName,
			   ClusterName,
			   NumInstances,
			   HostConstraints,
			   HostNames,
			   PodConstraint,
			   Services)||{{deploy_name,DeployName},
				       {cluster_name,ClusterName},
				       {num_instances,NumInstances},
				       {host,{HostConstraints,HostNames}},
				       {pod,PodConstraint},
				       {services,Services}}<-I]
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create(DeployName,ClusterName,NumInstances,HostConstraints,
       HostNames, PodConstraint,Services)->
    #deployment_spec{deploy_name=DeployName,
		     cluster_name=ClusterName,
		     num_instances=NumInstances,
		     host={HostConstraints,HostNames},
		     pod=PodConstraint,
		     services=Services}.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
all_names(DeploymentSpec)->
    [I#deployment_spec.deploy_name||I<-DeploymentSpec].

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
info(DeploymentName,DeploymentSpec)->
    R=[I||I<-DeploymentSpec,
	  DeploymentName=:=I#deployment_spec.deploy_name],
    Result=case R of
	       []->
		   {error,[eexists,DeploymentName]};
	       [DeploymentInfo]->
		   DeploymentInfo
	   end,
    Result.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
item(Key,DeploymentName,DeploymentSpec)->
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
			   {_,HostNames}=X#deployment_spec.host,
			   HostNames;
		       host_constraints->
			   {HostConstraints,_}=X#deployment_spec.host,
			   HostConstraints;
		       pod_constraints->
			   X#deployment_spec.pod;
		       services->
			   X#deployment_spec.services;
		       Eexists->
			   {error,[eexists,Eexists]}
		   end;
	       Reason ->
		   {error,[case_clause,Reason]}
	   end,
    Result.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
