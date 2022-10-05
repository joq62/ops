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
-module(cl1).   
 
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
start()->
   
    ok=setup(),

    ok=cluster_start_test(),
    
    ok=pod_start_test(),
    
    ok=service_test(),

    ok=cluster_stop_test(),
           
    io:format("Test OK !!! ~p~n",[?MODULE]),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
service_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
    HostName="c100",
    ClusterName="c1",
    PodName="c1_0",
    Appl="sd",

    % load
    ok=ops:git_load_service(HostName,ClusterName,PodName,Appl),  
    
    % start
    ok=ops:start_service(HostName,ClusterName,PodName,Appl),  
    true=ops:is_service_running(HostName,ClusterName,PodName,Appl),  
        
    %stop
    ok=ops:stop_service(HostName,ClusterName,PodName,Appl),  
    false=ops:is_service_running(HostName,ClusterName,PodName,Appl),  
  
    % unload
    []=ops:unload_service(HostName,ClusterName,PodName,Appl),  
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
pod_start_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    {
     [{ok,{"c201","c1","c1_cookie",c1_3@c201,"c1.dir/c1_3"}},
      {ok,{"c201","c1","c1_cookie",c1_2@c201,"c1.dir/c1_2"}},
      {ok,{"c201","c1","c1_cookie",c1_1@c201,"c1.dir/c1_1"}},
      {ok,{"c201","c1","c1_cookie",c1_0@c201,"c1.dir/c1_0"}},
      {error,[pod_lib,create,_,[badrpc,nodedown],c1@c200,"c1.dir/c1_3"]},
      {error,[pod_lib,create,_,[badrpc,nodedown],c1@c200,"c1.dir/c1_2"]},
      {error,[pod_lib,create,_,[badrpc,nodedown],c1@c200,"c1.dir/c1_1"]},
      {error,[pod_lib,create,_,[badrpc,nodedown],c1@c200,"c1.dir/c1_0"]},
      {ok,{"c100","c1","c1_cookie",c1_3@c100,"c1.dir/c1_3"}},
      {ok,{"c100","c1","c1_cookie",c1_2@c100,"c1.dir/c1_2"}},
      {ok,{"c100","c1","c1_cookie",c1_1@c100,"c1.dir/c1_1"}},
      {ok,{"c100","c1","c1_cookie",c1_0@c100,"c1.dir/c1_0"}},
      {ok,{"c100","c2","c2_cookie",c2_2@c100,"c2.dir/c2_2"}},
      {ok,{"c100","c2","c2_cookie",c2_1@c100,"c2.dir/c2_1"}},
      {ok,{"c100","c2","c2_cookie",c2_0@c100,"c2.dir/c2_0"}}],
     [{"c200","c1_3","c1"},{"c200","c1_2","c1"}, {"c200","c1_1","c1"},{"c200","c1_0","c1"}],
     [{"c201","c1_3","c1"},{"c201","c1_2","c1"},{"c201","c1_1","c1"},{"c201","c1_0","c1"},
      {"c100","c1_3","c1"},{"c100","c1_2","c1"},{"c100","c1_1","c1"},{"c100","c1_0","c1"},
      {"c100","c2_2","c2"},{"c100","c2_1","c2"},{"c100","c2_0","c2"}]
    }=ops:pod_intent(),
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
 
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
cluster_start_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    HostClusterNameList=lists:sort(ops:cluster_names()),
    StartAll= [ops:create_cluster_node(HostName,ClusterName)||{HostName,ClusterName}<-HostClusterNameList],
   % io:format("HostClusterNameList ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE,HostClusterNameList}]),
    [{ok,{"c100","c1",'c1@c100',"c1_cookie","c1.dir"}},
     {ok,{"c100","c2",'c2@c100',"c2_cookie","c2.dir"}},
     {error,[["c200","c1","c1_cookie",[ehostunreach,my_ssh,ssh_send,26]],"c200","c1","c1_cookie"]},
     {ok,{"c201","c1",'c1@c201',"c1_cookie","c1.dir"}}]=StartAll,
    
   
  %  (cluster_nodes),
   % PodNameDirList=erlang:get(pod_name_dir_list),
       
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
cluster_stop_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    HostClusterNameList=lists:sort(ops:cluster_names()),
    StopAll= [{ops:delete_cluster_node(HostName,ClusterName),HostName,ClusterName}||{HostName,ClusterName}<-HostClusterNameList],
    [{ok,"c100","c1"},
     {ok,"c100","c2"},
     {ok,"c200","c1"},
     {ok,"c201","c1"}]=StopAll,
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


setup()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    ok=application:start(ops),
    ok=cluster_stop_test(),
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),

    ok.
