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
-module(dep1).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(ClusterSpec,"cluster.spec").
-define(DeploymentSpec,"deployment.spec").

		 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),

    ClusterSpec=cluster:read_cluster_spec(?ClusterSpec),
    io:format("ClusterSpec ~p~n",[ClusterSpec]),
    [{"c1","c201"},
     {"c1","c200"},
     {"c1","c100"},
     {"c2","c100"}]=ClusterAllNames=cluster:cluster_all_names(ClusterSpec),
    
    'c1@c100'=cluster:cluster_spec(node,{"c1","c100"},ClusterSpec),
    PodInfo=cluster:cluster_spec(pods_info,{"c1","c200"},ClusterSpec),
    io:format("PodInfo ~p~n",[PodInfo]),

    "c1/c1_0"=cluster:pod_node(dir,'c1_0@c200',PodInfo),
    



    DeploymentSpec=cluster:read_deployment_spec(?DeploymentSpec),
    io:format("DeploymentSpec ~p~n",[DeploymentSpec]),

    [DeploymentName1,"d2"]=DeploymentAllNames=cluster:deployment_all_names(DeploymentSpec),

    ApplList=cluster:deployment_spec(appl_list,DeploymentName1,DeploymentSpec),
    io:format("ApplList ~p~n",[ApplList]),
    App=cluster:appl_list(app,"sd",ApplList),
    sd=App,
    SorceDir=cluster:appl_list(source_dir,"sd",ApplList),
    "/home/joq62/erlang/infra_2/sd/ebin"=SorceDir,
    
    
    
    
  
    %% Clean up
    
  
    init:stop(),
    ok.





%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
t1(HostNames,ClusterNodeName,ClusterCookie,ClusterDir,NumPodsPerHost)->
    Start1=cluster:start(HostNames,ClusterNodeName,ClusterCookie,ClusterDir,NumPodsPerHost),
    io:format("Start1 ~p~n",[Start1]),
    Start1.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
t2(HostNames,ClusterNodeName,ClusterCookie,ClusterDir,NumPodsPerHost)->
    ClusterNodes=[list_to_atom(ClusterNodeName++"@"++HostName)||HostName<-HostNames],
    PodNodeNames=[ClusterNodeName++"_"++integer_to_list(N)||N<-lists:seq(0,NumPodsPerHost)],
  
  
    % Start new cluster nodes
    [cluster:create_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)||HostName<-HostNames],
    cluster:connect(HostNames,ClusterNodeName,ClusterCookie),
    ['c1@c100','c1@c200','c1@c201']=cluster:availble(HostNames,ClusterNodeName,ClusterCookie),
    []=cluster:not_availble(HostNames,ClusterNodeName,ClusterCookie),
   
    
    %% Start workernodes 
    PodArgs=" -setcookie "++ClusterCookie,
    PodInfo=[{list_to_atom(ClusterNodeName++"@"++HostName),ClusterCookie,HostName,PodNodeName,filename:join(ClusterDir,PodNodeName),PodArgs,list_to_atom(PodNodeName++"@"++HostName)}||PodNodeName<-PodNodeNames,HostName<-HostNames],
  
    [pod:create(ClusterNode,ClusterCookie,HostName,PodNodeName,PodDir,PodArgs)||{ClusterNode,ClusterCookie,HostName,PodNodeName,PodDir,PodArgs,_PodNode}<-PodInfo],
    ok.
    
  

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

setup()->
    ok=application:start(ops),
    

    ok.
