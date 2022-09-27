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
-module(dis_1t).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(OpsNodeName,"ops").
-define(OpsCookie,"ops").

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    ok=application:start(ops),
  
    HostName="c100",
    ClName1="c1",
    ClCookie1Str="c1",
    ClCookie1=c1,
    ClNode1=list_to_atom(ClName1++"@"++HostName),
    ClName2="c2",
    ClCookie2Str="c2",
    ClCookie2=c2,
    ClNode2=list_to_atom(ClName2++"@"++HostName),
    
    % delete nodes to 
    
    true=dist_lib:stop_node(HostName,ClName1,ClCookie1Str),
    true=dist_lib:stop_node(HostName,ClName2,ClCookie2Str),
    
    %Create Nodes

    true=dist_lib:start_node(HostName,ClName1,ClCookie1Str," -detached -hidden "),
    true=dist_lib:start_node(HostName,ClName2,ClCookie2Str," -detached -hidden "),

    D=erlang:date(),
    D=dist_lib:cmd(ClNode1,ClCookie1Str,erlang,date,[],2000),
    D=dist_lib:cmd(ClNode2,ClCookie2Str,erlang,date,[],2000),

    %% create workers
    W1NodeName="w1",
    W1Args=" -setcookie "++ClCookie1Str,
    {ok,W1}=dist_lib:cmd(ClNode1,ClCookie1Str,slave,start,[HostName,W1NodeName,W1Args],5000),
    pong=dist_lib:cmd(ClNode1,ClCookie1Str,net_adm,ping,[W1],2000),


    %% create workers
    W2NodeName="w2",
    W2Args=" -setcookie "++ClCookie2Str,
    {ok,W2}=dist_lib:cmd(ClNode2,ClCookie2Str,slave,start,[HostName,W2NodeName,W2Args],5000),
    pong=dist_lib:cmd(ClNode2,ClCookie2Str,net_adm,ping,[W2],2000),

    
    %% create dirs 
    Appl="sd",
    App=list_to_atom(Appl),
    SourceDir="/home/joq62/erlang/infra_2/sd/ebin",

    %%% Worker 1
    
    C1Dir="c1.dir",
    ApplDir1=filename:join(C1Dir,Appl),
    EbinApplDir1=filename:join(ApplDir1,"ebin"),
    	
    dist_lib:rmdir_r(ClNode1,ClCookie1Str,C1Dir),
    ok=dist_lib:mkdir(ClNode1,ClCookie1Str,C1Dir),
    ok=dist_lib:mkdir(ClNode1,ClCookie1Str,ApplDir1),
    ok=dist_lib:mkdir(ClNode1,ClCookie1Str,EbinApplDir1),
    
    {ok,EbinFiles}=file:list_dir(SourceDir),
    io:format("EbinFiles ~p~n",[EbinFiles]),
    
 
    [dist_lib:cp_file(W1,ClCookie1Str,SourceDir,SourcFileName,EbinApplDir1)||SourcFileName<-EbinFiles],
   % load and start sd on worker
    true=dist_lib:cmd(W1,ClCookie1Str,code,add_patha,[EbinApplDir1],5000),
    ok=dist_lib:cmd(W1,ClCookie1Str,application,start,[sd],5000),
    pong=dist_lib:cmd(W1,ClCookie1Str,sd,ping,[],5000),

    %% Worker 2
    C2Dir="c2.dir",
    ApplDir2=filename:join(C2Dir,Appl),
    EbinApplDir2=filename:join(ApplDir2,"ebin"),
    	
    dist_lib:rmdir_r(ClNode2,ClCookie2Str,C2Dir),
    ok=dist_lib:mkdir(ClNode2,ClCookie2Str,C2Dir),
    ok=dist_lib:mkdir(ClNode2,ClCookie2Str,ApplDir2),
    ok=dist_lib:mkdir(ClNode2,ClCookie2Str,EbinApplDir2),
    
    {ok,EbinFiles}=file:list_dir(SourceDir),
    io:format("EbinFiles ~p~n",[EbinFiles]),
    
    [dist_lib:cp_file(W2,ClCookie2Str,SourceDir,SourcFileName,EbinApplDir2)||SourcFileName<-EbinFiles],
   % load and start sd on worker
    true=dist_lib:cmd(W2,ClCookie2Str,code,add_patha,[EbinApplDir2],5000),
    ok=dist_lib:cmd(W2,ClCookie2Str,application,start,[sd],5000),
    pong=dist_lib:cmd(W2,ClCookie2Str,sd,ping,[],5000),


    %% Clean up
    
    true=dist_lib:stop_node(HostName,ClName1,ClCookie1Str),
    true=dist_lib:stop_node(HostName,ClName2,ClCookie2Str),

    init:stop(),
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

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


setup()->
  
    
    R=ok,
    R.
