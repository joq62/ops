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
    [{deployment_spec,"cluster_infra","c1",1,["c100","c200","c201"],[{"sd","1.0.0"},{"nodelog","1.0.0"}]},
     {deployment_spec,"test1","c1",2,["c100","c201"],[{"test_add","1.0.0"}]}]=Spec,
      
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
    ["cluster_infra","test1"]=AllNames,
  
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
    Info=deployment_data:info("cluster_infra",Spec),
    {deployment_spec,"cluster_infra",
     "c1",1,["c100","c200","c201"],
     [{"sd","1.0.0"},{"nodelog","1.0.0"}]}=Info, 
    
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
    "c1"=deployment_data:item(cluster_name,"cluster_infra",Spec),
    1=deployment_data:item(num_instances,"cluster_infra",Spec),
    ["c100","c200","c201"]=deployment_data:item(hostnames,"cluster_infra",Spec),
    [{"sd","1.0.0"},{"nodelog","1.0.0"}]=deployment_data:item(services,"cluster_infra",Spec),
    
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


setup()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

 
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),

    ok.
