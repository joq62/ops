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
	 read_spec/0,
	 read_spec/1,
	 create/5,
	 all_names/1,
	 info/3,
	 item/4
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

	 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(ClusterSpecFile,"cluster.spec").



%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------		       
read_spec()->
    read_spec(?ClusterSpecFile).
read_spec(ClusterSpecFile)->
    Result=case file:consult(ClusterSpecFile) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,I}->
		   X=[create(HostNames,Name,Cookie,Dir,NumPods)||{{name,Name},{cookie,Cookie},{dir,Dir},
									       {hostnames,HostNames},
									       {num_pods,NumPods}}<-I],
		   lists:append(X)
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

create(HostNames,Name,Cookie,Dir,NumPods)->
    create(HostNames,Name,Cookie,Dir,NumPods,[]).

create([],_Name,_Cookie,_Dir,_NumPods,Acc)->
    Acc;
create([HostName|T],Name,Cookie,Dir,NumPods,Acc) ->
    Node=list_to_atom(Name++"@"++HostName),
    PodNames=[Name++"_"++integer_to_list(N)||N<-lists:seq(0,NumPods)],
    PodsInfo=[#pod_info{hostname=HostName,node=list_to_atom(PodName++"@"++HostName),
		       name=PodName,dir=filename:join(Dir,PodName)}||PodName<-PodNames],
    NewAcc=[#cluster_spec{name=Name,cookie=Cookie,node=Node,dir=Dir,
			 hostname=HostName,num_pods=NumPods,pods_info=PodsInfo}|Acc],    
    create(T,Name,Cookie,Dir,NumPods,NewAcc).
   
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
all_names(ClusterSpec)->
    [{I#cluster_spec.hostname,I#cluster_spec.name}||I<-ClusterSpec].

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
info(HostName,ClusterName,ClusterSpec)->
    R=[I||I<-ClusterSpec,
	  {HostName,ClusterName}=:={I#cluster_spec.hostname,I#cluster_spec.name}],
    Result=case R of
	       []->
		   {error,[eexists,{HostName,ClusterName}]};
	       [Info]->
		   Info
	   end,
    Result.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------    

item(Key,HostName,ClusterName,ClusterSpec)->
    R=[I||I<-ClusterSpec,
	  {HostName,ClusterName}=:={I#cluster_spec.hostname,I#cluster_spec.name}],
    Result=case R of
	       []->
		   {error,[eexists,{HostName,ClusterName}]};
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
    Result.

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
