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
-module(cl_data).    
 
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
  
    Spec=cluster_data:read_spec(),
   [{cluster_spec,"c1","c1_cookie",'c1@c100',"c1.dir","c100",3,[
								{pod_info,"c100",'c1_0@c100',"c1_0","c1.dir/c1_0"},
								{pod_info,"c100",'c1_1@c100',"c1_1","c1.dir/c1_1"},
								{pod_info,"c100",'c1_2@c100',"c1_2","c1.dir/c1_2"},
								{pod_info,"c100",'c1_3@c100',"c1_3","c1.dir/c1_3"}]},
    {cluster_spec,"c1","c1_cookie",'c1@c200',"c1.dir","c200",3,[
								{pod_info,"c200",'c1_0@c200',"c1_0","c1.dir/c1_0"},
								{pod_info,"c200",'c1_1@c200',"c1_1","c1.dir/c1_1"},
								{pod_info,"c200",'c1_2@c200',"c1_2","c1.dir/c1_2"},
								{pod_info,"c200",'c1_3@c200',"c1_3","c1.dir/c1_3"}]},
    {cluster_spec,"c1","c1_cookie",'c1@c201',"c1.dir","c201",3,[
								{pod_info,"c201",'c1_0@c201',"c1_0","c1.dir/c1_0"},
								{pod_info,"c201",'c1_1@c201',"c1_1","c1.dir/c1_1"},
								{pod_info,"c201",'c1_2@c201',"c1_2","c1.dir/c1_2"},
								{pod_info,"c201",'c1_3@c201',"c1_3","c1.dir/c1_3"}]},
    {cluster_spec,"c2","c2_cookie",'c2@c100',"c2.dir","c100",2,[
								{pod_info,"c100",'c2_0@c100',"c2_0","c2.dir/c2_0"},
								{pod_info,"c100",'c2_1@c100',"c2_1","c2.dir/c2_1"},
								{pod_info,"c100",'c2_2@c100',"c2_2","c2.dir/c2_2"}]}]=lists:sort(Spec),
      
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.




%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
all_names()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    Spec=cluster_data:read_spec(),
    AllNames=cluster_data:all_names(Spec),
    [{"c100","c1"},{"c100","c2"},{"c200","c1"},{"c201","c1"}]=lists:sort(AllNames),
  
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),    
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
info()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    Spec=cluster_data:read_spec(),
    Info=cluster_data:info("c100","c1",Spec),
    {cluster_spec,"c1","c1_cookie",'c1@c100',"c1.dir","c100",3,[
								{pod_info,"c100",'c1_0@c100',"c1_0","c1.dir/c1_0"},
								{pod_info,"c100",'c1_1@c100',"c1_1","c1.dir/c1_1"},
								{pod_info,"c100",'c1_2@c100',"c1_2","c1.dir/c1_2"},
								{pod_info,"c100",'c1_3@c100',"c1_3","c1.dir/c1_3"}]}=Info, 
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),    
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
item()->

    io:format("Start ~p~n",[?FUNCTION_NAME]),

    Spec=cluster_data:read_spec(),
    "c1"=cluster_data:item(name,"c100","c1",Spec),
    "c1_cookie"=cluster_data:item(cookie,"c100","c1",Spec),
    'c1@c100'=cluster_data:item(node,"c100","c1",Spec),
    "c1.dir"=cluster_data:item(dir,"c100","c1",Spec),
    "c100"=cluster_data:item(hostname,"c100","c1",Spec),
    3=cluster_data:item(num_pods,"c100","c1",Spec),
    [{pod_info,"c100",'c1_0@c100',"c1_0","c1.dir/c1_0"},
     {pod_info,"c100",'c1_1@c100',"c1_1","c1.dir/c1_1"},
     {pod_info,"c100",'c1_2@c100',"c1_2","c1.dir/c1_2"},
     {pod_info,"c100",'c1_3@c100',"c1_3","c1.dir/c1_3"}]=cluster_data:item(pods_info,"c100","c1",Spec),
   
    
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
