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
-module(service_lib).   
  
-export([
	 git_load/4,
	 git_load/5,
	 load/5,
	 start/5,
	 stop/5,
	 unload/5,
	 which_services/1,
	 which_service/3,
	 desired_state/0,
	 desired_state/1,
	 intent/1,
	 is_loaded/5
	]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
intent(ClusterName)->
    DesiredState=desired_state(ClusterName),        %[{HostName,CluserName,N,Service}]
    ActiveServicesList=which_services(ClusterName), %[{HostName,ClusterName,PodName,PodNode,Service,Vsn}]
    MissingServices=remove_equal(DesiredState,ActiveServicesList),
    start_service(MissingServices,[]).

start_service([],Acc)->
    Acc;
start_service([{HostName,ClusterName,N,Service}|T],Acc)->
    % Get Free PodName
    FreePodList=pod_lib:get_free_pod(HostName,ClusterName,Service),
    R=case FreePodList of
	  []->
	      {error,[no_pods_available,HostName,ClusterName,Service]};
	  [PodName|_] ->
	      Appl=atom_to_list(Service),
	      ClusterSpec=1/0,
	      git_load(HostName,ClusterName,PodName,Appl,ClusterSpec),
	      case start(HostName,ClusterName,PodName,Appl,ClusterSpec) of
		  ok->
		      {ok,HostName,ClusterName,N,Service};
		  Reason ->
		      {error,[Reason]}
	      end
      end,
    start_service(T,[R|Acc]).

remove_equal(List,[])->
    List;
remove_equal(List,[{HostName1,ClusterName1,_PodName,_PodNode,Service1,_Vsn}|T])->
    NewList=[{HostName,
	      CluserName,
	      N,
	      Service}||{HostName,CluserName,N,Service}<-List,
			{HostName,CluserName,Service}/={HostName1,ClusterName1,Service1}],
    remove_equal(NewList,T).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
desired_state(ClusterName)->
    AllDesiredState=desired_state(), %[{ClusterName,[{HostName,ClusterName,N,Service}]}]]
    List=[DesiredState||
	     {CN,DesiredState}<-AllDesiredState,
	     CN=:=ClusterName],
    lists:append(List).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
desired_state()->
    Spec=deployment_data:read_spec(),
    AllNames=deployment_data:all_names(Spec), %[depname,depname2]
    desired_state(AllNames,Spec,[]).
    
desired_state([],_,Acc)->
    Acc;
desired_state([DepName|T],Spec,Acc)->
    ClusterName=deployment_data:item(cluster_name,DepName,Spec),
    NumInstances=deployment_data:item(num_instances,DepName,Spec),
    HostNameList=deployment_data:item(hostnames,DepName,Spec),
    ServiceIdVsnList=deployment_data:item(services,DepName,Spec),
    Result=desired_state(NumInstances,HostNameList,ClusterName,ServiceIdVsnList,[]),
    NewAcc=[Result|Acc],
    desired_state(T,Spec,NewAcc).
    
    %{"c100","c1","c1_0",'c1_0@c100',kernel,"6.5.1"},
    
desired_state(-1,_,ClusterName,_,Acc)->
    {ClusterName,Acc};
desired_state(N,HostNameList,ClusterName,ServiceIdVsnList,Acc)->
    L=[{HostName,ClusterName,N,list_to_atom(ServiceId)}||HostName<-HostNameList,
						       {ServiceId,_}<-ServiceIdVsnList],
    NewAcc=lists:append(L,Acc),
    desired_state(N-1,HostNameList,ClusterName,ServiceIdVsnList,NewAcc).
    
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------



git_load(HostName,ClusterName,PodName,Appl,ClusterSpec)->
    {ok,PodInfo}=pod_data:pod_info_by_name(HostName,ClusterName,PodName,ClusterSpec),
    PodNode=pod_data:pod(node,PodInfo),
    PodDir=pod_data:pod(dir,PodInfo),
    {ok,ClusterCookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    Result=git_load(PodNode,ClusterCookie,Appl,PodDir),
    Result.
	

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

git_load(PodNode,ClusterCookie,Appl,PodDir)->
    GitPath=config:application_gitpath(Appl),
    App=list_to_atom(Appl), 
    {ok,Root}= dist_lib:cmd(PodNode,ClusterCookie,file,get_cwd,[],1000),  
    ApplDir=filename:join([Root,PodDir,Appl]),
    dist_lib:cmd(PodNode,ClusterCookie,os,cmd,["rm -rf "++ApplDir],1000),
    timer:sleep(1000),
    ok=dist_lib:cmd(PodNode,ClusterCookie,file,make_dir,[ApplDir],1000),
    TempDir=filename:join(Root,"temp.dir"),
    dist_lib:cmd(PodNode,ClusterCookie,os,cmd,["rm -rf "++TempDir],1000),
    timer:sleep(1000),
    ok=dist_lib:cmd(PodNode,ClusterCookie,file,make_dir,[TempDir],1000),
    _Clonres= dist_lib:cmd(PodNode,ClusterCookie,os,cmd,["git clone "++GitPath++" "++TempDir],5000),
    timer:sleep(1000),
  %  io:format("Clonres ~p~n",[Clonres]),

    _MvRes= dist_lib:cmd(PodNode,ClusterCookie,os,cmd,["mv  "++TempDir++"/*"++" "++ApplDir],5000),
    %io:format("MvRes ~p~n",[MvRes]),
 %   rpc:cast(node(),nodelog_server,log,[info,?MODULE_STRING,?LINE,
%				     {mv_result,MvRes}]),
    _RmRes= dist_lib:cmd(PodNode,ClusterCookie,os,cmd,["rm -r  "++TempDir],5000),
    timer:sleep(1000),
    %io:format("RmRes ~p~n",[RmRes]),
    %rpc:cast(node(),nodelog_server,log,[info,?MODULE_STRING,?LINE,
%				     {rm_result,RmRes}]),
    Ebin=filename:join(ApplDir,"ebin"),
    Result=case  dist_lib:cmd(PodNode,ClusterCookie,filelib,is_dir,[Ebin],5000) of
	      true->
		  case  dist_lib:cmd(PodNode,ClusterCookie,code,add_patha,[Ebin],5000) of
		      true->
			  dist_lib:cmd(PodNode,ClusterCookie,application,load,[App],5000);
		      {badrpc,Reason} ->
			  {error,[badrpc,?MODULE,?FUNCTION_NAME,?LINE,Reason]};
		      Err ->
			  {error,[?MODULE,?FUNCTION_NAME,?LINE,Err]}
		  end;
	      false ->
		  {error,[ebin_dir_not_created,?MODULE,?FUNCTION_NAME,?LINE,PodNode]};
	      {badrpc,Reason} ->

		  {error,[?MODULE,?FUNCTION_NAME,?LINE,badrpc,Reason]}
	  end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
load(PodNode,ClusterCookie,Appl,SourceDir,ApplDir)->
    App=list_to_atom(Appl),
    Result= case dist_lib:mkdir(PodNode,ClusterCookie,ApplDir) of
		{error,Reason}->
		    {error,Reason};
		ok->
		    EbinApplDir=filename:join(ApplDir,"ebin"),
		    case dist_lib:mkdir(PodNode,ClusterCookie,EbinApplDir) of
			{error,Reason}->
			    {error,Reason};
			ok->
			    case file:list_dir(SourceDir) of
				{error,Reason}->
				    {error,Reason};
				{ok,EbinFiles}->
				    [dist_lib:cp_file(PodNode,ClusterCookie,SourceDir,SourcFileName,EbinApplDir)||SourcFileName<-EbinFiles], 
				    case dist_lib:cmd(PodNode,ClusterCookie,code,add_patha,[EbinApplDir],5000) of
					{error,Reason}->
					    {error,Reason};
					true->
					    dist_lib:cmd(PodNode,ClusterCookie,application,load,[App],5000)
				    end
			    end
		    end
	    end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start(HostName,ClusterName,PodName,Appl,ClusterSpec)->
    {ok,PodInfo}=pod_data:pod_info_by_name(HostName,ClusterName,PodName,ClusterSpec),
    PodNode=pod_data:pod(node,PodInfo),
    {ok,ClusterCookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    Result=start(PodNode,ClusterCookie,Appl),
  %  io:format("Result ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE,Result}]),
    Result.



start(PodNode,ClusterCookie,Appl)->
    App=list_to_atom(Appl),
    dist_lib:cmd(PodNode,ClusterCookie,application,start,[App],5000).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
stop(HostName,ClusterName,PodName,Appl,ClusterSpec)->
    {ok,PodInfo}=pod_data:pod_info_by_name(HostName,ClusterName,PodName,ClusterSpec),
    PodNode=pod_data:pod(node,PodInfo),
    {ok,ClusterCookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    Result=stop(PodNode,ClusterCookie,Appl),
   % io:format("Result ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE,Result}]),
    Result.


stop(PodNode,ClusterCookie,Appl)->
    App=list_to_atom(Appl),
    dist_lib:cmd(PodNode,ClusterCookie,application,stop,[App],5000).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
unload(HostName,ClusterName,PodName,Appl,ClusterSpec)->
    {ok,PodInfo}=pod_data:pod_info_by_name(HostName,ClusterName,PodName,ClusterSpec),
    PodNode=pod_data:pod(node,PodInfo),
    PodDir=pod_data:pod(dir,PodInfo),
    ApplDir=filename:join(PodDir,Appl),
    {ok,ClusterCookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    Result=unload(PodNode,ClusterCookie,ApplDir),
   % io:format("Result ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE,Result}]),
    Result.


unload(PodNode,ClusterCookie,ApplDir)->
    dist_lib:rmdir_r(PodNode,ClusterCookie,ApplDir).


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_service(ServiceId,ClusterName,AllServicesList)->
    which_service(ServiceId,ClusterName,AllServicesList,[]).

which_service(_,_,[],Acc)->
    lists:append(Acc);
which_service(ServiceId,ClusterName,[AllServices|T],Acc)->  % AllServices=[[{HostName,ClusterName,PodName,Node,Service,Vsn}]]
    WantedService=list_to_atom(ServiceId),
    Result=[{HostName,
	      CN,
	      PodName,
	      Node,
	      Service,
	      Vsn}||{HostName,CN,PodName,Node,Service,Vsn}<-AllServices,
		    WantedService=:=Service,
		    CN=:=ClusterName],
    which_service(ServiceId,ClusterName,T,[Result|Acc]).
    




%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

which_services(ClusterName)->
    ClusterSpec=cluster_data:read_spec(),
    HostClusterList=[{HostName,CN}||{HostName,CN}<-cluster_data:all_names(ClusterSpec), % [{HostName,CluserName}]
				    CN=:=ClusterName],
    HostClusterPodNameList=lists:append([pod_data:all_names(HostName,CN,ClusterSpec)
					 ||{HostName,CN}<-HostClusterList]),  %{HostName,ClusterName,PodName}
    
    
    HostClusterPodNamePodNodeList=[{HostName,
				    CN,
				    PodName,
				    pod_data:item(node,pod_data:info(HostName,CN,PodName,ClusterSpec))
				   }||{HostName,CN,PodName}<-HostClusterPodNameList],
    WhichServices=[{
		    HostName,
		    CN,
		    PodName,
		    Node,
		    rpc:call(Node,application,which_applications,[],5000)
		   }||{HostName,CN,PodName,Node}<-HostClusterPodNamePodNodeList],
    
    which_services(WhichServices,[]).
which_services([],Acc)->
    Acc;
which_services([{_,_,_,_,{badrpc,nodedown}}|T],Acc)->
    which_services(T,Acc);    
which_services([{HostName,ClusterName,PodName,Node,ServiceList}|T],Acc)->
  %  io:format("ServiceList ~p~n",[{?MODULE,?LINE,ServiceList}]), 
    L=[{HostName,ClusterName,PodName,Node,Service,Vsn}||{Service,_,Vsn}<-ServiceList], 
    NewAcc=lists:append(L,Acc),
    which_services(T,NewAcc).    


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
is_loaded(_HostName,_ClusterName,_PodName,_Appl,_ClusterSpec)->
    not_implemented.



