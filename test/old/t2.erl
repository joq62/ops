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
-module(t2).   
 
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
    NodeName="pod1",
    Appl="sd",
    App=list_to_atom(Appl),
    PodDir="pod1.dir",
    SourceDir="/home/joq62/erlang/infra_2/sd/ebin",
    CurrentCookie=erlang:get_cookie(),
    OpsNode=list_to_atom(?OpsNodeName++"@"++HostName),
    
    % start ops node	
    %% To kill the ops node you need to use the latest 
 %   erlang:set_cookie(node(),cookie_c1),
    rpc:call(OpsNode,init,stop,[]),
    timer:sleep(1000),
 
    ops:start_ops_node(HostName),
   
    % Create pod dir and appl dir
    ops:rmdir_r(HostName,PodDir),
    ok=ops:mkdir(HostName,PodDir),

    ApplDir=filename:join(PodDir,Appl),
    ok=ops:mkdir(HostName,ApplDir),

    EbinApplDir=filename:join(ApplDir,"ebin"),   
    ok=ops:mkdir(HostName,EbinApplDir), 
    true=ops:cmd(HostName,filelib,is_dir,[EbinApplDir],5000),

    % copy sd ebin files

    {ok,EbinFiles}=file:list_dir(SourceDir),
    io:format("EbinFiles ~p~n",[EbinFiles]),
    
    %[SourcFileName|_]=EbinFiles,
    DestDir=EbinApplDir,
    [ops:cp_file(SourceDir,SourcFileName,HostName, DestDir)||SourcFileName<-EbinFiles],
    
    % Create a cluster_controller
    ClusterCookie="cookie_c1",
    ClusterNodeName="c1",
    ClusterNode=list_to_atom(ClusterNodeName++"@"++HostName),
    
    true=ops:stop_node(HostName,ClusterNodeName,ClusterCookie),
    
    true=ops:start_node(HostName,ClusterNodeName,ClusterCookie," -detached "),
    pong=net_adm:ping(ClusterNode),

    % Create worker w1
    WorkerNodeName="w1",
    WorkerEnvArgs=" -setcookie "++ClusterCookie,
    {ok,Worker1}=rpc:call(ClusterNode,slave,start,[HostName,WorkerNodeName,WorkerEnvArgs],5000),

    erlang:set_cookie(node(),list_to_atom(ClusterCookie)),
    timer:sleep(500),
    pong=net_adm:ping(Worker1),

    % laod and start sd on worker
    true=rpc:call(Worker1,code,add_patha,[EbinApplDir]),
    ok=rpc:call(Worker1,application,start,[sd]),
    pong=rpc:call(Worker1,sd,ping,[]),

    io:format("1. sd:all ~p~n",[rpc:call(Worker1,sd,all,[])]),
    rpc:call(ClusterNode,init,stop,[]),
    io:format("2. sd:all ~p~n",[rpc:call(Worker1,sd,all,[])]),
    erlang:set_cookie(node(),CurrentCookie),
    io:format("3. sd:all ~p~n",[rpc:call(Worker1,sd,all,[])]),

    pong=net_adm:ping(OpsNode),
			
    rpc:call(OpsNode,init,stop,[]),			   
    timer:sleep(3000),
 %   ops:stop_ops_node(HostName),
     
    
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
