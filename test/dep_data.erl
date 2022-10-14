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
-module(dep_data).    
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),
    
    ok=read_spec(),
    ok=all_names(),
    ok=info(),
    ok=item(),
    
           
    io:format("Test OK !!! ~p~n",[?MODULE]),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
read_spec()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
     Spec=deployment_data:read_spec(),
   [{deployment_spec,"any_not_same_hosts_not_same_pods","test_cluster",2,
     {[any_host,not_same_host],["c100","c200","c201"]},not_same_pod,
     [{"test_add","1.0.0"},{"test_divi","1.0.0"},{"test_sub","1.0.0"}]},
    {deployment_spec,"any_same_host_not_same_pod","test_cluster",2,
     {[any_host,same_host],["c100","c200","c201"]},not_same_pod,
     [{"test_add","1.0.0"},{"test_divi","1.0.0"},{"test_sub","1.0.0"}]},
    {deployment_spec,"any_same_host_same_pod","test_cluster",2,
     {[any_host,same_host],["c100","c200","c201"]},same_pod,
     [{"test_add","1.0.0"},{"test_divi","1.0.0"},{"test_sub","1.0.0"}]},
    {deployment_spec,"any_same_host_same_pod","test_cluster",2,
     {[any_host,same_host],["c100","c200","c201"]},same_pod,
     [{"test_add","1.0.0"},{"test_divi","1.0.0"},{"test_sub","1.0.0"}]},
    {deployment_spec,"this_host_not_same_pod","test_cluster",2,
     {[this_host],["c100"]},not_same_pod,
     [{"test_add","1.0.0"},{"test_divi","1.0.0"},{"test_sub","1.0.0"}]}]=lists:sort(Spec),
      
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.




%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
all_names()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    Spec=deployment_data:read_spec(),
    AllNames=deployment_data:all_names(Spec),
    ["any_not_same_hosts_not_same_pods",
     "any_same_host_not_same_pod",
     "any_same_host_same_pod",
     "any_same_host_same_pod",
     "this_host_not_same_pod"]=lists:sort(AllNames),
  
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),    
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
info()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    Spec=deployment_data:read_spec(),
    Info=deployment_data:info("any_not_same_hosts_not_same_pods",Spec),
    {deployment_spec,"any_not_same_hosts_not_same_pods","test_cluster",2,
     {[any_host,not_same_host],["c100","c200","c201"]},not_same_pod,
     [{"test_add","1.0.0"},{"test_divi","1.0.0"},{"test_sub","1.0.0"}]}=Info, 
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),    
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
item()->

    io:format("Start ~p~n",[?FUNCTION_NAME]),

    Spec=deployment_data:read_spec(),
    "test_cluster"=deployment_data:item(cluster_name,"any_not_same_hosts_not_same_pods",Spec),
    2=deployment_data:item(num_instances,"any_not_same_hosts_not_same_pods",Spec),
    ["c100","c200","c201"]=deployment_data:item(hostnames,"any_not_same_hosts_not_same_pods",Spec),
    [any_host,not_same_host]=deployment_data:item(host_constraints,"any_not_same_hosts_not_same_pods",Spec),
    not_same_pod=deployment_data:item(pod_constraints,"any_not_same_hosts_not_same_pods",Spec),
    [{"test_add","1.0.0"},
     {"test_divi","1.0.0"},
     {"test_sub","1.0.0"}]=deployment_data:item(services,"any_not_same_hosts_not_same_pods",Spec),
   
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),    

    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
cluster_stop_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
-define(SourceDepFile,"./test/specs/deployment_2.spec").
-define(DepFile,"deployment.spec").
	 	 

setup()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    file:delete(?DepFile),
    {ok,Bin}=file:read_file(?SourceDepFile),
    ok=file:write_file(?DepFile,Bin),
    
 
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),

    ok.
