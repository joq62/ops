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
-module(cluster_lib_2).   
 
-export([
	 all_services/1,
	 all_services/2,
	 is_cluster_present/1,
	 is_node_present/3,
	 start_node/3,
	 stop_node/3,
	 intent/2,
	 intent/1
	 
	]).
		 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
intent(ClusterSpec)->
    WantedStateCluster=cluster_data:cluster_all_names(ClusterSpec),
    StatusCluster=[{is_node_present(HostName,ClusterName,ClusterSpec),HostName,ClusterName}||{HostName,ClusterName}<-WantedStateCluster],  
    MissingCluster=[{HostName,ClusterName}||{false,HostName,ClusterName}<-StatusCluster],
  
    Started=[start_node(HostName,ClusterName,ClusterSpec)||{HostName,ClusterName}<-MissingCluster],
    PresentCluster=[{HostName,ClusterName}||{true,HostName,ClusterName}<-StatusCluster],
    Ping=case PresentCluster of
	     []-> % No nodes already started
		 [{Node,NodeStarted,dist_lib:ping(Node,Cookie,NodeStarted)}||{ok,{_,_,NodeStarted,CookieStarted,_}}<-Started,
									     {ok,{_,_,Node,Cookie,_}}<-Started,
									     CookieStarted=:=Cookie,
									     Node/=NodeStarted];
	     _->
		 PresentNodeCookie=[node_cookie(HostName,ClusterName,ClusterSpec)||{HostName,ClusterName}<-PresentCluster],
		 [{Node,NodeStarted,dist_lib:ping(Node,Cookie,NodeStarted)}||{ok,{_,_,NodeStarted,CookieStarted,_}}<-Started,
									     {Node,Cookie}<-PresentNodeCookie,
									     CookieStarted=:=Cookie,
									     Node/=NodeStarted]
	 end,
  %  io:format("Started ~p~n",[{?MODULE,?FUNCTION_NAME,Started}]),
    io:format("Ping ~p~n",[{?MODULE,?FUNCTION_NAME,Ping}]),

    StatusCluster1=[{is_node_present(HostName,ClusterName,ClusterSpec),HostName,ClusterName}||{HostName,ClusterName}<-WantedStateCluster],  
    MissingCluster1=[{HostName,ClusterName}||{false,HostName,ClusterName}<-StatusCluster1],
    PresentCluster1=[{HostName,ClusterName}||{true,HostName,ClusterName}<-StatusCluster1],
    {Started,MissingCluster1,PresentCluster1}.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
intent(WantedClusterName,ClusterSpec)->

    WantedStateCluster=cluster_data:cluster_all_names(ClusterSpec),
    StatusCluster=[{is_node_present(HostName,ClusterName,ClusterSpec),HostName,ClusterName}||{HostName,ClusterName}<-WantedStateCluster,
											     WantedClusterName=:=ClusterName],  
    MissingCluster=[{HostName,ClusterName}||{false,HostName,ClusterName}<-StatusCluster],
    Started=[start_node(HostName,ClusterName,ClusterSpec)||{HostName,ClusterName}<-MissingCluster],
    PresentCluster=[{HostName,ClusterName}||{true,HostName,ClusterName}<-StatusCluster],
    Ping=case PresentCluster of
	     []-> % No nodes already started
		 [{Node,NodeStarted,dist_lib:ping(Node,Cookie,NodeStarted)}||{ok,{_,_,NodeStarted,CookieStarted,_}}<-Started,
									     {ok,{_,_,Node,Cookie,_}}<-Started,
									     CookieStarted=:=Cookie,
									     Node/=NodeStarted];
	     _->
		 PresentNodeCookie=[node_cookie(HostName,ClusterName,ClusterSpec)||{HostName,ClusterName}<-PresentCluster],
		 [{Node,NodeStarted,dist_lib:ping(Node,Cookie,NodeStarted)}||{ok,{_,_,NodeStarted,CookieStarted,_}}<-Started,
									     {Node,Cookie}<-PresentNodeCookie,
									     CookieStarted=:=Cookie,
									     Node/=NodeStarted]
	 end,
  %  io:format("Started ~p~n",[{?MODULE,?FUNCTION_NAME,Started}]),
    io:format("Ping ~p~n",[{?MODULE,?FUNCTION_NAME,Ping}]),

    StatusCluster1=[{is_node_present(HostName,ClusterName,ClusterSpec),HostName,ClusterName}||{HostName,ClusterName}<-WantedStateCluster],  
    MissingCluster1=[{HostName,ClusterName}||{false,HostName,ClusterName}<-StatusCluster1],
    PresentCluster1=[{HostName,ClusterName}||{true,HostName,ClusterName}<-StatusCluster1],
    [{started,Started},{missing,MissingCluster1},{present,PresentCluster1}].

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
is_cluster_present(ClusterName)->
    {error,[not_implemeted,?FUNCTION_NAME,ClusterName]}.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
is_node_present(HostName,ClusterName,ClusterSpec)->
    {ok,Node}=cluster_data:cluster_spec(node,HostName,ClusterName,ClusterSpec),
    {ok,Cookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    case dist_lib:ping(node(),Cookie,Node) of
	pang->
	    false;
	pong->
	    true
    end.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
start_node(HostName,ClusterName,ClusterSpec)->
    {ok,ClusterCookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    {ok,ClusterDir}=cluster_data:cluster_spec(dir,HostName,ClusterName,ClusterSpec),
    create_node(HostName,ClusterName,ClusterCookie,ClusterDir).

%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
create_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)->
    Result=case dist_lib:start_node(HostName,ClusterNodeName,ClusterCookie," -detached  ") of
	       {error,Reason}->
		   {error,[Reason,HostName,ClusterNodeName,ClusterCookie]};
	       {ok,ClusterNode} ->
		   dist_lib:rmdir_r(ClusterNode,ClusterCookie,ClusterDir),
		   case dist_lib:mkdir(ClusterNode,ClusterCookie,ClusterDir) of
		       {error,Reason}->
			   {error,[Reason,HostName,ClusterNodeName,ClusterCookie]};
		       ok->
			   case dist_lib:cmd(ClusterNode,ClusterCookie,filelib,is_dir,[ClusterDir],5000) of
			       false->
				   {error,[cluster_dir_eexists,ClusterDir,HostName,ClusterNodeName,ClusterCookie]};
			       true->
				   {ok,{HostName,ClusterNodeName,ClusterNode,ClusterCookie,ClusterDir}}
			   end
		   end
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
stop_node(HostName,ClusterName,ClusterSpec)->
    {ok,Node}=cluster_data:cluster_spec(node,HostName,ClusterName,ClusterSpec),
    {ok,Cookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    {ok,Dir}=cluster_data:cluster_spec(dir,HostName,ClusterName,ClusterSpec),
    dist_lib:rmdir_r(Node,Cookie,Dir),
 %   io:format("Rm ~p~n",[{R,Dir,?MODULE,?FUNCTION_NAME}]),
    dist_lib:stop_node(HostName,ClusterName,Cookie),
    ok.



%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
all_services(ClusterSpec)->
    HostNameList=cluster_data:cluster_all_names(ClusterSpec),
    AllServices=[{ClusterName,all_services(ClusterName,ClusterSpec)}||{_,ClusterName}<-HostNameList],
    remove_duplicates(AllServices).

all_services(WantedClusterName,ClusterSpec)->

   % io:format("WantedClusterName ~p~n",[{WantedClusterName,?MODULE,?FUNCTION_NAME}]),

    WantedStateCluster=cluster_data:cluster_all_names(ClusterSpec),

    HostNames=[HostName||{HostName,ClusterName}<-WantedStateCluster,
			 WantedClusterName=:=ClusterName,
			 true=:=is_node_present(HostName,ClusterName,ClusterSpec)],  
    
    Result=case HostNames of
	       []->
		   {error,[?MODULE,?FUNCTION_NAME,?LINE,eexists,WantedClusterName]};
	       _->
		   
		   [{NodeFirst,Cookie}|_]=[node_cookie(HostName,WantedClusterName,ClusterSpec)||HostName<-HostNames],
		   PodNodes=dist_lib:cmd(NodeFirst,Cookie,erlang,nodes,[],5000),
		 %  io:format("PodNodes ~p~n",[{PodNodes,?MODULE,?FUNCTION_NAME}]),
		   
		   AllApps=[{Node,WantedClusterName,Cookie,dist_lib:cmd(Node,Cookie,application,which_applications,[],5000)}||Node<-PodNodes],
		   AllApps
	   end,
    Result.
		  
node_cookie(HostName,ClusterName,ClusterSpec)->
    {ok,Node}=cluster_data:cluster_spec(node,HostName,ClusterName,ClusterSpec),
    {ok,Cookie}=cluster_data:cluster_spec(cookie,HostName,ClusterName,ClusterSpec),
    {Node,Cookie}.


remove_duplicates([])->
    [];
remove_duplicates(L)->
    lists:reverse(remove_duplicates(L,[])).

remove_duplicates([],Acc)->
    Acc;
remove_duplicates([{ClusterName,Info}|T],Acc)->
     NewAcc=case lists:keymember(ClusterName,1,Acc) of
	       true->
		   Acc;
	       false->
		   [{ClusterName,Info}|Acc]
	   end,
    
    remove_duplicates(T,NewAcc).
