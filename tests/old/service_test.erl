%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : a
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(service_test).    
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(HostName,"c100").
-define(ClusterName,"test_cluster").
-define(PodName,"test_cluster_6").
	 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    ok=setup(),

    ok=host_candidates(),
    ok=pods_candidates(),
 
       
%    {ok,AllServicesList}=which_services(?ClusterName),
  
    io:format("Test OK !!! ~p~n",[?MODULE]),
    cluster_stop_test(),
    timer:sleep(3000),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
intent()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),    
      

    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
host_candidates()->
     io:format("Start ~p~n",[?FUNCTION_NAME]),    
    Spec=deployment_data:read_spec(),
    AllNames=deployment_data:all_names(Spec),
    [
     [{"this_host_not_same_pod",[{"c100",[{pod_info,"c100",'test_cluster_0@c100',"test_cluster_0","test_cluster.dir/test_cluster_0"},
					  {pod_info,"c100",'test_cluster_1@c100',"test_cluster_1","test_cluster.dir/test_cluster_1"},
					  {pod_info,"c100",'test_cluster_2@c100',"test_cluster_2","test_cluster.dir/test_cluster_2"},
					  {pod_info,"c100",'test_cluster_3@c100',"test_cluster_3","test_cluster.dir/test_cluster_3"},
					  {pod_info,"c100",'test_cluster_4@c100',"test_cluster_4","test_cluster.dir/test_cluster_4"},
					  {pod_info,"c100",'test_cluster_5@c100',"test_cluster_5","test_cluster.dir/test_cluster_5"},
					  {pod_info,"c100",'test_cluster_6@c100',"test_cluster_6","test_cluster.dir/test_cluster_6"}]}]},
      {"any_same_host_same_pod",[{"c100",[{pod_info,"c100",'test_cluster_0@c100',"test_cluster_0","test_cluster.dir/test_cluster_0"},
					  {pod_info,"c100",'test_cluster_1@c100',"test_cluster_1","test_cluster.dir/test_cluster_1"},
					  {pod_info,"c100",'test_cluster_2@c100',"test_cluster_2","test_cluster.dir/test_cluster_2"},
					  {pod_info,"c100",'test_cluster_3@c100',"test_cluster_3","test_cluster.dir/test_cluster_3"},
					  {pod_info,"c100",'test_cluster_4@c100',"test_cluster_4","test_cluster.dir/test_cluster_4"},
					  {pod_info,"c100",'test_cluster_5@c100',"test_cluster_5","test_cluster.dir/test_cluster_5"},
					  {pod_info,"c100",'test_cluster_6@c100',"test_cluster_6","test_cluster.dir/test_cluster_6"}]},
				 {"c200",[{pod_info,"c200",'test_cluster_0@c200',"test_cluster_0","test_cluster.dir/test_cluster_0"},
					  {pod_info,"c200",'test_cluster_1@c200',"test_cluster_1","test_cluster.dir/test_cluster_1"},
					  {pod_info,"c200",'test_cluster_2@c200',"test_cluster_2","test_cluster.dir/test_cluster_2"},
					  {pod_info,"c200",'test_cluster_3@c200',"test_cluster_3","test_cluster.dir/test_cluster_3"},
					  {pod_info,"c200",'test_cluster_4@c200',"test_cluster_4","test_cluster.dir/test_cluster_4"},
					  {pod_info,"c200",'test_cluster_5@c200',"test_cluster_5","test_cluster.dir/test_cluster_5"},
					  {pod_info,"c200",'test_cluster_6@c200',"test_cluster_6","test_cluster.dir/test_cluster_6"}]},
				 {"c201",[{pod_info,"c201",'test_cluster_0@c201',"test_cluster_0","test_cluster.dir/test_cluster_0"},
 					  {pod_info,"c201",'test_cluster_1@c201',"test_cluster_1","test_cluster.dir/test_cluster_1"},
					  {pod_info,"c201",'test_cluster_2@c201',"test_cluster_2","test_cluster.dir/test_cluster_2"},
					  {pod_info,"c201",'test_cluster_3@c201',"test_cluster_3","test_cluster.dir/test_cluster_3"},
					  {pod_info,"c201",'test_cluster_4@c201',"test_cluster_4","test_cluster.dir/test_cluster_4"},
					  {pod_info,"c201",'test_cluster_5@c201',"test_cluster_5","test_cluster.dir/test_cluster_5"},
					  {pod_info,"c201",'test_cluster_6@c201',"test_cluster_6","test_cluster.dir/test_cluster_6"}]}]},
      {"any_same_host_not_same_pod",[{"c100",[{pod_info,"c100",'test_cluster_0@c100',"test_cluster_0","test_cluster.dir/test_cluster_0"},
					      {pod_info,"c100",'test_cluster_1@c100',"test_cluster_1","test_cluster.dir/test_cluster_1"},
					      {pod_info,"c100",'test_cluster_2@c100',"test_cluster_2","test_cluster.dir/test_cluster_2"},
					      {pod_info,"c100",'test_cluster_3@c100',"test_cluster_3","test_cluster.dir/test_cluster_3"},
					      {pod_info,"c100",'test_cluster_4@c100',"test_cluster_4","test_cluster.dir/test_cluster_4"},
					      {pod_info,"c100",'test_cluster_5@c100',"test_cluster_5","test_cluster.dir/test_cluster_5"},
					      {pod_info,"c100",'test_cluster_6@c100',"test_cluster_6","test_cluster.dir/test_cluster_6"}]},
				     {"c200",[{pod_info,"c200",'test_cluster_0@c200',"test_cluster_0","test_cluster.dir/test_cluster_0"},
					      {pod_info,"c200",'test_cluster_1@c200',"test_cluster_1","test_cluster.dir/test_cluster_1"},
					      {pod_info,"c200",'test_cluster_2@c200',"test_cluster_2","test_cluster.dir/test_cluster_2"},
					      {pod_info,"c200",'test_cluster_3@c200',"test_cluster_3","test_cluster.dir/test_cluster_3"},
					      {pod_info,"c200",'test_cluster_4@c200',"test_cluster_4","test_cluster.dir/test_cluster_4"},
					      {pod_info,"c200",'test_cluster_5@c200',"test_cluster_5","test_cluster.dir/test_cluster_5"},
					      {pod_info,"c200",'test_cluster_6@c200',"test_cluster_6","test_cluster.dir/test_cluster_6"}]},
				     {"c201",[{pod_info,"c201",'test_cluster_0@c201',"test_cluster_0","test_cluster.dir/test_cluster_0"},
					      {pod_info,"c201",'test_cluster_1@c201',"test_cluster_1","test_cluster.dir/test_cluster_1"},
					      {pod_info,"c201",'test_cluster_2@c201',"test_cluster_2","test_cluster.dir/test_cluster_2"},
					      {pod_info,"c201",'test_cluster_3@c201',"test_cluster_3","test_cluster.dir/test_cluster_3"},
					      {pod_info,"c201",'test_cluster_4@c201',"test_cluster_4","test_cluster.dir/test_cluster_4"},
					      {pod_info,"c201",'test_cluster_5@c201',"test_cluster_5","test_cluster.dir/test_cluster_5"},
					      {pod_info,"c201",'test_cluster_6@c201',"test_cluster_6","test_cluster.dir/test_cluster_6"}]}]},

      {"any_not_same_hosts_not_same_pods",[[{"c201",[{pod_info,"c201",'test_cluster_0@c201',"test_cluster_0","test_cluster.dir/test_cluster_0"},
						     {pod_info,"c201",'test_cluster_1@c201',"test_cluster_1","test_cluster.dir/test_cluster_1"},
						     {pod_info,"c201",'test_cluster_2@c201',"test_cluster_2","test_cluster.dir/test_cluster_2"},
						     {pod_info,"c201",'test_cluster_3@c201',"test_cluster_3","test_cluster.dir/test_cluster_3"},
						     {pod_info,"c201",'test_cluster_4@c201',"test_cluster_4","test_cluster.dir/test_cluster_4"},
						     {pod_info,"c201",'test_cluster_5@c201',"test_cluster_5","test_cluster.dir/test_cluster_5"},
						     {pod_info,"c201",'test_cluster_6@c201',"test_cluster_6","test_cluster.dir/test_cluster_6"}]},
					    {"c200",[{pod_info,"c200",'test_cluster_0@c200',"test_cluster_0","test_cluster.dir/test_cluster_0"},
						     {pod_info,"c200",'test_cluster_1@c200',"test_cluster_1","test_cluster.dir/test_cluster_1"},
						     {pod_info,"c200",'test_cluster_2@c200',"test_cluster_2","test_cluster.dir/test_cluster_2"},
						     {pod_info,"c200",'test_cluster_3@c200',"test_cluster_3","test_cluster.dir/test_cluster_3"},
						     {pod_info,"c200",'test_cluster_4@c200',"test_cluster_4","test_cluster.dir/test_cluster_4"},
						     {pod_info,"c200",'test_cluster_5@c200',"test_cluster_5","test_cluster.dir/test_cluster_5"},
						     {pod_info,"c200",'test_cluster_6@c200',"test_cluster_6","test_cluster.dir/test_cluster_6"}]}],

					   [{"c201",[{pod_info,"c201",'test_cluster_0@c201',"test_cluster_0","test_cluster.dir/test_cluster_0"},
						     {pod_info,"c201",'test_cluster_1@c201',"test_cluster_1","test_cluster.dir/test_cluster_1"},
						     {pod_info,"c201",'test_cluster_2@c201',"test_cluster_2","test_cluster.dir/test_cluster_2"},
						     {pod_info,"c201",'test_cluster_3@c201',"test_cluster_3","test_cluster.dir/test_cluster_3"},
						     {pod_info,"c201",'test_cluster_4@c201',"test_cluster_4","test_cluster.dir/test_cluster_4"},
						     {pod_info,"c201",'test_cluster_5@c201',"test_cluster_5","test_cluster.dir/test_cluster_5"},
						     {pod_info,"c201",'test_cluster_6@c201',"test_cluster_6","test_cluster.dir/test_cluster_6"}]},
					    {"c100",[{pod_info,"c100",'test_cluster_0@c100',"test_cluster_0","test_cluster.dir/test_cluster_0"},
						     {pod_info,"c100",'test_cluster_1@c100',"test_cluster_1","test_cluster.dir/test_cluster_1"},
						     {pod_info,"c100",'test_cluster_2@c100',"test_cluster_2","test_cluster.dir/test_cluster_2"},
						     {pod_info,"c100",'test_cluster_3@c100',"test_cluster_3","test_cluster.dir/test_cluster_3"},
						     {pod_info,"c100",'test_cluster_4@c100',"test_cluster_4","test_cluster.dir/test_cluster_4"},
						     {pod_info,"c100",'test_cluster_5@c100',"test_cluster_5","test_cluster.dir/test_cluster_5"},
						     {pod_info,"c100",'test_cluster_6@c100',"test_cluster_6","test_cluster.dir/test_cluster_6"}]}],

					   [{"c200",[{pod_info,"c200",'test_cluster_0@c200',"test_cluster_0","test_cluster.dir/test_cluster_0"},
						     {pod_info,"c200",'test_cluster_1@c200',"test_cluster_1","test_cluster.dir/test_cluster_1"},
						     {pod_info,"c200",'test_cluster_2@c200',"test_cluster_2","test_cluster.dir/test_cluster_2"},
						     {pod_info,"c200",'test_cluster_3@c200',"test_cluster_3","test_cluster.dir/test_cluster_3"},
						     {pod_info,"c200",'test_cluster_4@c200',"test_cluster_4","test_cluster.dir/test_cluster_4"},
						     {pod_info,"c200",'test_cluster_5@c200',"test_cluster_5","test_cluster.dir/test_cluster_5"},
						     {pod_info,"c200",'test_cluster_6@c200',"test_cluster_6","test_cluster.dir/test_cluster_6"}]},
					    {"c100",[{pod_info,"c100",'test_cluster_0@c100',"test_cluster_0","test_cluster.dir/test_cluster_0"},
						     {pod_info,"c100",'test_cluster_1@c100',"test_cluster_1","test_cluster.dir/test_cluster_1"},
						     {pod_info,"c100",'test_cluster_2@c100',"test_cluster_2","test_cluster.dir/test_cluster_2"},
						     {pod_info,"c100",'test_cluster_3@c100',"test_cluster_3","test_cluster.dir/test_cluster_3"},
						     {pod_info,"c100",'test_cluster_4@c100',"test_cluster_4","test_cluster.dir/test_cluster_4"},
						     {pod_info,"c100",'test_cluster_5@c100',"test_cluster_5","test_cluster.dir/test_cluster_5"},
						     {pod_info,"c100",'test_cluster_6@c100',"test_cluster_6","test_cluster.dir/test_cluster_6"}]}]]}]
    ]=[{DeplName,candidates:hostnames(DeplName)}||DeplName<-AllNames],
      

    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
pods_candidates()->
     io:format("Start ~p~n",[?FUNCTION_NAME]),    
    Spec=deployment_data:read_spec(),
    AllNames=deployment_data:all_names(Spec),
    [glurk
    ]=[{DeplName,candidates:pods(DeplName)}||DeplName<-AllNames],
      

    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_services(ClusterName)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    AllServicesList=lists:sort(service_lib:which_services(ClusterName)),

    []=AllServicesList,
    
        
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    {ok,AllServicesList}.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
remove([])->
    [];
remove(L)->
    lists:reverse(remove(L,[])).

remove([],Acc)->
    Acc;
remove([{_HostName,ClusterName}|T],Acc)->
    NewAcc=case lists:member(ClusterName,Acc) of
	       true->
		   Acc;
	       false->
		   [ClusterName|Acc]
	   end,
    remove(T,NewAcc).
   


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
    
    ok=application:start(ops),
    ok=cluster_stop_test(),
    ok=cluster_start_test(),
    ok=pod_start_test(),
    
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),

    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
pod_start_test()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    
    {[{ok,{"c201","test_cluster","test_cluster_cookie",'test_cluster_6@c201',"test_cluster.dir/test_cluster_6"}}|_],
     [],
     [{"c201","test_cluster_6","test_cluster"}|_]}=ops:pod_intent(),
    
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
    [{ok,{"c100","test_cluster",'test_cluster@c100',"test_cluster_cookie","test_cluster.dir"}}|_]=lists:sort(StartAll),
    
   
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
    [{ok,"c100","test_cluster"}|_]=lists:sort(StopAll),
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
