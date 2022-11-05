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
-module(cl_test).   
 
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

-define(HostNames,["c100","c200","c201"]).


		 

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
    
    
   %
    ClusterInfoList=cluster:start(HostNames,ClusterNodeName,ClusterCookie,ClusterDir,NumPodsPerHost),
    io:format("ClusterInfoList ~p~n",[ClusterInfoList]),
    ClusterCookie=cluster:hostname(cookie,"c100",ClusterInfoList),
    "c1.dir"=cluster:hostname(dir,"c100",ClusterInfoList),
    5=cluster:hostname(num_pods,"c100",ClusterInfoList),
    [{ok,{pod,"c100",c1_0@c100,"c1_0","c1.dir/c1_0"}}|_]=cluster:hostname(pods_info,"c100",ClusterInfoList),
    
    {error,[key_eexists,glurk]}=cluster:hostname(glurk,"c100",ClusterInfoList),
    {error,[hostname_eexists,"glurk"]}=cluster:hostname(cookie,"glurk",ClusterInfoList),
    Stop1=cluster:stop(HostNames,ClusterNodeName,ClusterCookie,ClusterDir),
    io:format("Stop1 ~p~n",[Stop1]),
    init:stop(),


  %% load start application 
    Appl="sd",
    SourceDir="/home/joq62/erlang/infra_2/sd/ebin",

    PodNode='c1_0@c100',
    PodDir="c1_0",
    ApplDir=filename:join([ClusterDir,PodDir,Appl]),
         
    ok=service:load(PodNode,ClusterCookie,Appl,SourceDir,ApplDir),
    ok=service:start(PodNode,ClusterCookie,Appl),
    pong=dist_lib:cmd(PodNode,ClusterCookie,sd,ping,[],5000),
    timer:sleep(3000),
    ok=service:stop(PodNode,ClusterCookie,Appl),
    {badrpc,_}=dist_lib:cmd(PodNode,ClusterCookie,sd,ping,[],5000),
    service:unload(PodNode,ClusterCookie,ApplDir),
    false=dist_lib:cmd(c1@c100,ClusterCookie,filelib,is_dir,[ApplDir],5000),
    
    

    [true,true,true]=[cluster:delete_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)||HostName<-?HostNames],
    
    
    
 
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
    ClusterNodeName=?ClId_1,
    ClusterDir=?ClId_1++".dir",
    ClusterCookie=?ClCookieStr_1,
    [true,true,true]=[cluster:delete_node(HostName,ClusterNodeName,ClusterCookie,ClusterDir)||HostName<-?HostNames],

    ok.
