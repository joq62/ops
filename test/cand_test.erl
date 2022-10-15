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
-module(cand_test).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-define(Id_c1,"c1").


		 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
-define(HostNames,["c100","c300","c200","c201"]).
-define(HostName,"c100").
-define(ClusterName,"test_cluster").
-define(DeplName,"any_not_same_hosts_not_same_pods").

start()->
   
    ok=setup(),

    ok=host_candidates(),
    ok=pod_candidates(),
  
    io:format("Test OK !!! ~p~n",[?MODULE]),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
pod_candidates()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    Spec=deployment_data:read_spec(),

    NumInstances=deployment_data:item(num_instances,"any_not_same_hosts_not_same_pods",Spec),
    ServiceList=deployment_data:item(services,"any_not_same_hosts_not_same_pods",Spec),
    
    gl=candidates:pods(NumInstances,?HostName,?ClusterName,ServiceList),
    
    

    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
host_candidates()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),


    ok=candidates(),
    ok=candidates(1),
    ok=candidates(2),
    ok=candidates(3),
    ok=candidates(4),
    ok=candidates(5),
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
 
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------   
candidates()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    Spec=deployment_data:read_spec(),
    AllNames=deployment_data:all_names(Spec),
    [{"this_host_not_same_pod",["c100"]},
     {"any_same_host_same_pod",["c100","c200","c201"]},
     {"any_same_host_not_same_pod",["c100","c200","c201"]},
     {"any_not_same_hosts_not_same_pods",[
					  ["c200","c100"],
					  ["c201","c100"],
					  ["c201","c200"]]}
    ]=[{DeplName,candidates:hostnames(DeplName)}||DeplName<-AllNames],
    
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
candidates(1)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
    ["c100","c300","c200","c201"]=candidates:hostnames(1,?HostNames),
       
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok;

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
candidates(2)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
   [["c300","c100"],
    ["c300","c200"],
    ["c300","c201"],
    ["c200","c100"],
    ["c201","c100"],
    ["c201","c200"]]=candidates:hostnames(2,?HostNames),
       
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok;

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
candidates(3)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
  [["c300","c200","c100"],
   ["c300","c201","c100"],
   ["c300","c201","c200"],
   ["c201","c200","c100"]
  ]=candidates:hostnames(3,?HostNames),
       
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok;

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
candidates(4)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
     {error,[too_many_instances_vs_hosts,0]}=candidates:hostnames(4,?HostNames),
       
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok;
 
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
candidates(5)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
   {error,[too_many_instances_vs_hosts,1]}=candidates:hostnames(5,?HostNames),
       
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

 
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
-define(SourceDepFile,"./test/specs/deployment_2.spec").
-define(DepFile,"deployment.spec").
-define(SourceClusterFile,"./test/specs/cluster_2.spec").
-define(ClusterFile,"cluster.spec").
	 	 

setup()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    file:delete(?ClusterFile),
    {ok,ClusterBin}=file:read_file(?SourceClusterFile),
    ok=file:write_file(?ClusterFile,ClusterBin),
    
    file:delete(?DepFile),
    {ok,DepBin}=file:read_file(?SourceDepFile),
    ok=file:write_file(?DepFile,DepBin),
 
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),

    ok.
