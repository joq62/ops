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
-module(service_test).    
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(HostName,"c100").
-define(ClusterName,"c1").
-define(PodName,"c1_0").
	 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

  %  ok=desired_state(),
  %  ok=desired_state_2(),
    ok=setup(),
  %  ok=intent(),
  
  %  {ok,AllServicesList}=which_services(),
  %  ok=which_service(AllServicesList),

    io:format("Test OK !!! ~p~n",[?MODULE]),
    cluster_stop_test(),
    timer:sleep(2000),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
intent()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),    
    ClusterName="c1",
    Intent=service_lib:intent(ClusterName),
   [
    {"c100","c1",0,nodelog},
    {"c100","c1",0,sd},
    {"c100","c1",0,test_add},
    {"c100","c1",1,nodelog},
    {"c100","c1",1,sd},
    {"c100","c1",1,test_add},
    {"c100","c1",2,test_add},
    {"c200","c1",0,nodelog},
    {"c200","c1",0,sd},
    {"c200","c1",1,nodelog},
    {"c200","c1",1,sd},
    {"c201","c1",0,nodelog},
    {"c201","c1",0,sd},
    {"c201","c1",0,test_add},
    {"c201","c1",1,nodelog},
    {"c201","c1",1,sd},
    {"c201","c1",1,test_add},
    {"c201","c1",2,test_add}
   ]=lists:sort(Intent),

    
    

    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
desired_state_2()->
     io:format("Start ~p~n",[?FUNCTION_NAME]),    
   
    DesiredStateC1=service_lib:desired_state("c1"),
    [
     {"c100","c1",0,nodelog},{"c100","c1",0,sd},{"c100","c1",0,test_add},{"c100","c1",1,nodelog},{"c100","c1",1,sd},
     {"c100","c1",1,test_add},{"c100","c1",2,test_add},{"c200","c1",0,nodelog},{"c200","c1",0,sd},{"c200","c1",1,nodelog},
     {"c200","c1",1,sd},{"c201","c1",0,nodelog},{"c201","c1",0,sd},{"c201","c1",0,test_add},{"c201","c1",1,nodelog},{"c201","c1",1,sd},
     {"c201","c1",1,test_add},{"c201","c1",2,test_add}
    ]=lists:sort(DesiredStateC1),

    DesiredStateC2=service_lib:desired_state("c2"),
    []=lists:sort(DesiredStateC2),

    DesiredStateLgh_1=service_lib:desired_state("lgh_1"),
    [
     {"c201","lgh_1",0,test_add},
     {"c201","lgh_1",1,test_add},
     {"c201","lgh_1",2,test_add}
    ]=lists:sort(DesiredStateLgh_1),

    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
desired_state()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    DesiredState=lists:sort(service_lib:desired_state()),
  
    [{"c1",[{"c100","c1",0,sd},{"c100","c1",0,nodelog},{"c200","c1",0,sd},{"c200","c1",0,nodelog},
	    {"c201","c1",0,sd},{"c201","c1",0,nodelog},{"c100","c1",1,sd},{"c100","c1",1,nodelog},
	    {"c200","c1",1,sd},{"c200","c1",1,nodelog},{"c201","c1",1,sd},{"c201","c1",1,nodelog}]},
     {"c1",[{"c100","c1",0,test_add},{"c201","c1",0,test_add},{"c100","c1",1,test_add},
	    {"c201","c1",1,test_add},{"c100","c1",2,test_add},{"c201","c1",2,test_add}]},
     {"lgh_1",[{"c201","lgh_1",0,test_add},{"c201","lgh_1",1,test_add},{"c201","lgh_1",2,test_add}]}]=DesiredState,
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_service(AllServicesList)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    HostClusterNameList=lists:sort(ops:cluster_names()),
    ClusterNames=remove(HostClusterNameList),
    % Eexists sd
    
    [[],[]]=lists:sort([service_lib:which_service("sd",ClusterName,AllServicesList)||ClusterName<-ClusterNames]),
    
    % exists 
    [[{"c100","c1","c1_0",'c1_0@c100',kernel,"6.5.1"},
      {"c100","c1","c1_1",'c1_1@c100',kernel,"6.5.1"},
      {"c100","c1","c1_2",'c1_2@c100',kernel,"6.5.1"},
      {"c100","c1","c1_3",'c1_3@c100',kernel,"6.5.1"},
      {"c201","c1","c1_0",'c1_0@c201',kernel,"6.5.1"},
      {"c201","c1","c1_1",'c1_1@c201',kernel,"6.5.1"},
      {"c201","c1","c1_2",'c1_2@c201',kernel,"6.5.1"},
      {"c201","c1","c1_3",'c1_3@c201',kernel,"6.5.1"}],
     [{"c100","c2","c2_0",'c2_0@c100',kernel,"6.5.1"},
      {"c100","c2","c2_1",'c2_1@c100',kernel,"6.5.1"},
      {"c100","c2","c2_2",'c2_2@c100',kernel,"6.5.1"}]]=lists:sort([service_lib:which_service("kernel",ClusterName,AllServicesList)||ClusterName<-ClusterNames]),
        
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_services()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    HostClusterNameList=lists:sort(ops:cluster_names()),
    ClusterNames=remove(HostClusterNameList),
    AllServicesList=lists:sort([service_lib:which_services(ClusterName)||ClusterName<-ClusterNames]),

    [
     [
      {"c100","c1","c1_0",'c1_0@c100',stdlib,"3.11.2"},{"c100","c1","c1_0",'c1_0@c100',kernel,"6.5.1"},{"c100","c1","c1_1",'c1_1@c100',stdlib,"3.11.2"},
      {"c100","c1","c1_1",'c1_1@c100',kernel,"6.5.1"},{"c100","c1","c1_2",'c1_2@c100',stdlib,"3.11.2"},{"c100","c1","c1_2",'c1_2@c100',kernel,"6.5.1"},
      {"c100","c1","c1_3",'c1_3@c100',stdlib,"3.11.2"},{"c100","c1","c1_3",'c1_3@c100',kernel,"6.5.1"},{"c201","c1","c1_0",'c1_0@c201',stdlib,"3.11.2"},
      {"c201","c1","c1_0",'c1_0@c201',kernel,"6.5.1"},{"c201","c1","c1_1",'c1_1@c201',stdlib,"3.11.2"},{"c201","c1","c1_1",'c1_1@c201',kernel,"6.5.1"},
      {"c201","c1","c1_2",'c1_2@c201',stdlib,"3.11.2"},{"c201","c1","c1_2",'c1_2@c201',kernel,"6.5.1"},{"c201","c1","c1_3",'c1_3@c201',stdlib,"3.11.2"},
      {"c201","c1","c1_3",'c1_3@c201',kernel,"6.5.1"}
     ],
     [
      {"c100","c2","c2_0",'c2_0@c100',stdlib,"3.11.2"},{"c100","c2","c2_0",'c2_0@c100',kernel,"6.5.1"},{"c100","c2","c2_1",'c2_1@c100',stdlib,"3.11.2"},
      {"c100","c2","c2_1",'c2_1@c100',kernel,"6.5.1"},{"c100","c2","c2_2",'c2_2@c100',stdlib,"3.11.2"},{"c100","c2","c2_2",'c2_2@c100',kernel,"6.5.1"}
     ],
     [
      {"c201","lgh_1","lgh_1_0",'lgh_1_0@c201',stdlib,"3.11.2"},{"c201","lgh_1","lgh_1_0",'lgh_1_0@c201',kernel,"6.5.1"},{"c201","lgh_1","lgh_1_1",'lgh_1_1@c201',stdlib,"3.11.2"},
      {"c201","lgh_1","lgh_1_1",'lgh_1_1@c201',kernel,"6.5.1"},{"c201","lgh_1","lgh_1_2",'lgh_1_2@c201',stdlib,"3.11.2"},{"c201","lgh_1","lgh_1_2",'lgh_1_2@c201',kernel,"6.5.1"},
      {"c201","lgh_1","lgh_1_3",'lgh_1_3@c201',stdlib,"3.11.2"},{"c201","lgh_1","lgh_1_3",'lgh_1_3@c201',kernel,"6.5.1"},{"c201","lgh_1","lgh_1_4",'lgh_1_4@c201',stdlib,"3.11.2"},
      {"c201","lgh_1","lgh_1_4",'lgh_1_4@c201',kernel,"6.5.1"},{"c201","lgh_1","lgh_1_5",'lgh_1_5@c201',stdlib,"3.11.2"},{"c201","lgh_1","lgh_1_5",'lgh_1_5@c201',kernel,"6.5.1"},
      {"c201","lgh_1","lgh_1_6",'lgh_1_6@c201',stdlib,"3.11.2"},{"c201","lgh_1","lgh_1_6",'lgh_1_6@c201',kernel,"6.5.1"},{"c201","lgh_1","lgh_1_7",'lgh_1_7@c201',stdlib,"3.11.2"},
      {"c201","lgh_1","lgh_1_7",'lgh_1_7@c201',kernel,"6.5.1"},{"c201","lgh_1","lgh_1_8",'lgh_1_8@c201',stdlib,"3.11.2"},{"c201","lgh_1","lgh_1_8",'lgh_1_8@c201',kernel,"6.5.1"},
      {"c201","lgh_1","lgh_1_9",'lgh_1_9@c201',stdlib,"3.11.2"},{"c201","lgh_1","lgh_1_9",'lgh_1_9@c201',kernel,"6.5.1"},{"c201","lgh_1","lgh_1_10",'lgh_1_10@c201',stdlib,"3.11.2"},
      {"c201","lgh_1","lgh_1_10",'lgh_1_10@c201',kernel,"6.5.1"}
     ]
    ]=AllServicesList,
    
        
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

    
    {[{ok,{"c201","test_1","test_1_cookie",'test_1_6@c201',"test_1.dir/test_1_6"}},
      {ok,{"c201","test_1","test_1_cookie",'test_1_5@c201',"test_1.dir/test_1_5"}},
      {ok,{"c201","test_1","test_1_cookie",'test_1_4@c201',"test_1.dir/test_1_4"}},
      {ok,{"c201","test_1","test_1_cookie",'test_1_3@c201',"test_1.dir/test_1_3"}},
      {ok,{"c201","test_1","test_1_cookie",'test_1_2@c201',"test_1.dir/test_1_2"}},
      {ok,{"c201","test_1","test_1_cookie",'test_1_1@c201',"test_1.dir/test_1_1"}},
      {ok,{"c201","test_1","test_1_cookie",'test_1_0@c201',"test_1.dir/test_1_0"}},
      {ok,{"c200","test_1","test_1_cookie",'test_1_6@c200',"test_1.dir/test_1_6"}},
      {ok,{"c200","test_1","test_1_cookie",'test_1_5@c200',"test_1.dir/test_1_5"}},
      {ok,{"c200","test_1","test_1_cookie",'test_1_4@c200',"test_1.dir/test_1_4"}},
      {ok,{"c200","test_1","test_1_cookie",'test_1_3@c200',"test_1.dir/test_1_3"}},
      {ok,{"c200","test_1","test_1_cookie",'test_1_2@c200',"test_1.dir/test_1_2"}},
      {ok,{"c200","test_1","test_1_cookie",'test_1_1@c200',"test_1.dir/test_1_1"}},
      {ok,{"c200","test_1","test_1_cookie",'test_1_0@c200',"test_1.dir/test_1_0"}},
      {ok,{"c100","test_1","test_1_cookie",'test_1_6@c100',"test_1.dir/test_1_6"}},
      {ok,{"c100","test_1","test_1_cookie",'test_1_5@c100',"test_1.dir/test_1_5"}},
      {ok,{"c100","test_1","test_1_cookie",'test_1_4@c100',"test_1.dir/test_1_4"}},
      {ok,{"c100","test_1","test_1_cookie",'test_1_3@c100',"test_1.dir/test_1_3"}},
      {ok,{"c100","test_1","test_1_cookie",'test_1_2@c100',"test_1.dir/test_1_2"}},
      {ok,{"c100","test_1","test_1_cookie",'test_1_1@c100',"test_1.dir/test_1_1"}},
      {ok,{"c100","test_1","test_1_cookie",'test_1_0@c100',"test_1.dir/test_1_0"}}],
     [],
     [{"c201","test_1_6","test_1"},{"c201","test_1_5","test_1"},{"c201","test_1_4","test_1"},{"c201","test_1_3","test_1"},
      {"c201","test_1_2","test_1"},{"c201","test_1_1","test_1"},{"c201","test_1_0","test_1"},
      {"c200","test_1_6","test_1"},{"c200","test_1_5","test_1"},{"c200","test_1_4","test_1"},
      {"c200","test_1_3","test_1"},{"c200","test_1_2","test_1"},{"c200","test_1_1","test_1"},{"c200","test_1_0","test_1"},
      {"c100","test_1_6","test_1"},{"c100","test_1_5","test_1"},{"c100","test_1_4","test_1"},{"c100","test_1_3","test_1"},
      {"c100","test_1_2","test_1"},{"c100","test_1_1","test_1"},{"c100","test_1_0","test_1"}]}=ops:pod_intent(),
    
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
    [{ok,{"c100","test_1",'test_1@c100',"test_1_cookie","test_1.dir"}},
     {ok,{"c200","test_1",'test_1@c200',"test_1_cookie","test_1.dir"}},
     {ok,{"c201","test_1",'test_1@c201',"test_1_cookie","test_1.dir"}}
    ]=lists:sort(StartAll),
    
   
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
    [{ok,"c100","test_1"},
     {ok,"c200","test_1"},
     {ok,"c201","test_1"}]=lists:sort(StopAll),
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok.
