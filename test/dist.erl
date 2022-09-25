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
-module(dist).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(OpsNodeName,"ops").
-define(OpsCookie,"ops").

-define(ClId_1,"c1").
-define(ClCookieStr_1,"cookie_c1").
-define(ClNumPods_1,5).
%-define(ClNodeName_1,"c_1").

-define(ClCookie_1,list_to_atom(?ClCookieStr_1)).
-define(ClNodeC100_1,list_to_atom(?ClNodeName_1++"@"++"c100")).
-define(ClNodeC200_1,list_to_atom(?ClNodeName_1++"@"++"c200")).
%-define(ClWorkesNodeName_1,["w_c1_1","w_c1_2","w_c1_3","w_c1_4"]).

-define(HostNames,["c100","c200"]).




%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),

    %% Create a new cluster 
    ClusterId=?ClId_1,
    ClusterNodeName=?ClId_1,
    ClusterDir=?ClId_1++".dir",
    ClusterCookie=?ClCookieStr_1,
    NumPodsPerHost=?ClNumPods_1,
    HostNames=?HostNames,

    ClusterNodes=[ClusterNodeName++"@"++HostName||HostName<-HostNames],
    WorkerNodeNames=[ClusterId++"_"++integer_to_list(N)||N<-lists:seq(0,NumPodsPerHost)],
 %   WorkerNodes=[{WorkerNodeName,WorkerNodeName++"@"++HostName}||WorkerNodeName<-WorkerNodeNames,HostName<-HostNames],
 %   WorkerDirs=[{WorkerNodeName,filename:join(ClusterDir,WorkerNodeName)}||WorkerNodeName<-WorkerNodeNames],
    WorkerInfo=[{WorkerNodeName++"@"++HostName,filename:join(ClusterDir,WorkerNodeName),WorkerNodeName}||WorkerNodeName<-WorkerNodeNames,HostName<-HostNames],
  
     
    ["c1@c100","c1@c200"]=lists:sort(ClusterNodes),

    [{"c1_0@c100","c1.dir/c1_0","c1_0"},{"c1_0@c200","c1.dir/c1_0","c1_0"},{"c1_1@c100","c1.dir/c1_1","c1_1"},
     {"c1_1@c200","c1.dir/c1_1","c1_1"},{"c1_2@c100","c1.dir/c1_2","c1_2"},{"c1_2@c200","c1.dir/c1_2","c1_2"},
     {"c1_3@c100","c1.dir/c1_3","c1_3"},{"c1_3@c200","c1.dir/c1_3","c1_3"},{"c1_4@c100","c1.dir/c1_4","c1_4"},
     {"c1_4@c200","c1.dir/c1_4","c1_4"},{"c1_5@c100","c1.dir/c1_5","c1_5"},{"c1_5@c200","c1.dir/c1_5","c1_5"}]=lists:sort(WorkerInfo),
    
  
    % Start new cluster nodes
    NewClusterStartResult=[L||{ok,L}<-[new_cluster_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)||HostName<-HostNames]],
    [{"c100","c1",'c1@c100',"cookie_c1","c1.dir"},
     {"c200","c1",'c1@c200',"cookie_c1","c1.dir"}]=NewClusterStartResult,
    [{_,_,ConnectNode,_,_}|T]=NewClusterStartResult,
    [dist_lib:cmd(ConnectNode,ClusterCookie,net_adm,ping,[Node],5000)||{_,_,Node,_,_}<-T],
    ['c1@c200']=lists:sort(dist_lib:cmd(ConnectNode,ClusterCookie,erlang,nodes,[],5000)),
    
    %% stop specif worker node

    %% Restart specific worker node 

    %% Start workernodes 



    %% delete specific worker node


    %% Restart specific worker node
    
    %Delete cluster
    
    [true,true]=[delete_cluster_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)||HostName<-HostNames],
    
    
 
    %% Clean up
    
    [true,true]=[dist_lib:stop_node(HostName,?ClId_1,?ClCookieStr_1)||HostName<-?HostNames],

    init:stop(),
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
new_cluster_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)->
    Result=case dist_lib:start_node(HostName,ClusterNodeName,ClusterCookie," -detached  ") of
	       {error,Reason}->
		   {error,[Reason,HostName,ClusterNodeName,ClusterCookie]};
	       true ->
		   ClusterNode=list_to_atom(ClusterNodeName++"@"++HostName),
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

new_cluster_nodes([],_,_,_,Acc)->
    ErrorList=[{error,Reason}||{error,Reason}<-Acc],
    Result=case ErrorList of
	       []->
		   R=[L||{ok,L}<-Acc],
		   {ok,R};
	       ErrorList->
		   {error,ErrorList}
	   end,	       
    Result;

new_cluster_nodes([HostName|T],ClusterNodeName,ClusterCookie,ClusterDir,Acc) ->
    NewAcc=[new_cluster_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)|Acc],
    new_cluster_nodes(T,ClusterNodeName,ClusterCookie,ClusterDir,NewAcc).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

delete_cluster_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)->
    ClusterNode=list_to_atom(ClusterNodeName++"@"++HostName),
    dist_lib:rmdir_r(ClusterNode,ClusterCookie,ClusterDir),
    dist_lib:stop_node(HostName,ClusterNodeName,ClusterCookie).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


setup()->
    ok=application:start(ops),
    [true,true]=[dist_lib:stop_node(HostName,?ClId_1,?ClCookieStr_1)||HostName<-?HostNames],
    ok.
