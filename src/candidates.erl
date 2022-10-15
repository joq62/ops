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
-module(candidates).   
  
-export([
	 test/0,

	 hostnames/1,
	 hostnames/2,
	 pods/4
	]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

% [any_host,not_same_host]=>[{X,Y}||X<-A,Y<-A,X/=Y,Y>X].
% [any_host,same_host] => Choose from hostlist
% 
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
pods(_NumInstances,HostName,ClusterName,ServiceList)->
    ClusterSpec=cluster_data:read_spec(),
    AllNames=pod_data:all_names(HostName,ClusterName,ClusterSpec),
    io:format("AllNames ~p~n",[{?MODULE,?LINE,AllNames}]),
    AllPodInfo=[pod_data:info(HostName,
			      ClusterName,
			      PodName,
			      ClusterSpec)||{_,_,PodName}<-AllNames],
    io:format("AllPodInfo ~p~n",[{?MODULE,?LINE,AllPodInfo}]),

    AllNodes=[{pod_data:item(node,Info),Info}||Info<-AllPodInfo],
    Cookie=cluster_data:item(cookie,HostName,ClusterName,ClusterSpec),
    ServicesInfo=[{dist_lib:cmd(Node,Cookie,application,which_applications,[],5000),Info}||{Node,Info}<-AllNodes],
    candidate(ServicesInfo,ServiceList).


candidate(ServicesInfo,ServiceList)->
    candidate(ServicesInfo,ServiceList,[]).

candidate([],_ServiceList,Acc)->
    Acc;
candidate([{WhichApplications,Info}|T],ServiceList,Acc)->
    R=[Info||{Service,_,_}<-WhichApplications,
	     lists:keymember(atom_to_list(Service),1,ServiceList)],
    NewAcc=case R of
	       []->
		   [Info|Acc];
	       _ ->
		   Acc
	   end,
    candidate(T,ServiceList,NewAcc).
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
hostnames(DeploymentName)->
    DeploymentSpec=deployment_data:read_spec(),

    NumInstances=deployment_data:item(num_instances,DeploymentName,DeploymentSpec),
    HostNameList=deployment_data:item(hostnames,DeploymentName,DeploymentSpec),
    _ClusterName=deployment_data:item(cluster_name,DeploymentName,DeploymentSpec),
    HostConstraints=lists:sort(deployment_data:item(host_constraints,DeploymentName,DeploymentSpec)),

    Result=case HostConstraints of
	       [any_host,not_same_host] ->
		   hostnames(NumInstances,HostNameList);
	       [any_host,same_host]->
		   HostNameList;
	       [this_host] ->
		   HostNameList
	   end,
    Result.
	      
		   
		   

hostnames(NumInstances,HostNameList)->

  %  io:format("HostNameList ~p~n",[{?MODULE,?FUNCTION_NAME,list_length:start(HostNameList),HostNameList}]),
    list_length:start(HostNameList),

    Result=case NumInstances<list_length:start(HostNameList) of 
	       false->
		   {error,[too_many_instances_vs_hosts,NumInstances-list_length:start(HostNameList)]};
	       true ->
		   case NumInstances of
		       1->
			   [A||A<-HostNameList];
		       2->
			   [[A,B]||A<-HostNameList,B<-HostNameList,A>B];
		       3->
			   [[A,B,C]||A<-HostNameList,B<-HostNameList,C<-HostNameList,A>B,B>C];
		       4->
			   [[A,B,C,D]||A<-HostNameList,B<-HostNameList,C<-HostNameList,D<-HostNameList,A>B,B>C,C>D];
		       5->
			   [[A,B,C,D,E]||A<-HostNameList,B<-HostNameList,C<-HostNameList,D<-HostNameList,E<-HostNameList,A>B,B>C,C>D,D>E];
		       N->
			   {error,[too_many_instances_not_supported,N]}
		   end
	   end,
    Result.
    

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test()->

%%---------------------------------------------------------------------
    A={{deploy_name,"this_host_not_same_pod"},
       {cluster_name,"test_cluster"},
       {num_instances,2},
       {host,{[this_host],["c100"]}},
       {pod,not_same_pod},
       {services,
	[
	 {"test_add","1.0.0"},
	 {"test_divi","1.0.0"},
	 {"test_sub","1.0.0"}]
       }
      },
%%---------------------------------------------------------------------
    B={{deploy_name,"any_same_host_same_pod"},
       {cluster_name,"test_cluster"},
       {num_instances,2},
       {host,{[any_host,same_host],["c100","c200","c201"]}},
       {pod,same_pod},
       {services,
	[
	 {"test_add","1.0.0"},
	 {"test_divi","1.0.0"},
	 {"test_sub","1.0.0"}
	]
       }
      },

%%---------------------------------------------------------------------

    C={{deploy_name,"any_same_host_not_same_pod"},
       {cluster_name,"test_cluster"},
       {num_instances,2},
       {host,{[any_host,same_host],["c100","c200","c201"]}},
       {pod,not_same_pod},
       {services,
	[
	 {"test_add","1.0.0"},
	 {"test_divi","1.0.0"},
	 {"test_sub","1.0.0"}
	]
       }
      },

%%---------------------------------------------------------------------
    D={{deploy_name,"any_not_same_hosts_not_same_pods"},
       {cluster_name,"test_cluster"},
       {num_instances,2},
       {host,{[any_host,not_same_host],["c100","c200","c201"]}},
       {pod,not_same_pod},
       {services,
	[
	 {"test_add","1.0.0"},
	 {"test_divi","1.0.0"},
	 {"test_sub","1.0.0"}
	]
       }
      },
    {A,B,C,D}.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
