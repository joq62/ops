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
-module(t1).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(NODENAME,"operation").
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
    ClusterCookie="cookie_c1",
    ClusterNodeName="c1",
    
    % start ops node	
    %% To kill the ops node you need to use the latest 

    OpsNode=list_to_atom("ops"++"@"++HostName),
    erlang:set_cookie(node(),list_to_atom(ClusterCookie)),
 %   ops:cmd(HostName,erlang,set_cookie,[OpsNode,list_to_atom(ClusterCookie)],5000),
    rpc:call(OpsNode,init,stop,[]),
    true=ops:stop_ops_node(HostName),
    {ok,OpsNode}=ops:start_ops_node(HostName),

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

    true=ops:cmd(HostName,erlang,set_cookie,[OpsNode,list_to_atom(ClusterCookie)],5000),

    ClusterArgs=" -setcookie "++ClusterCookie,
    {ok,ClusterNode}=ops:cmd(HostName,slave,start,[HostName,ClusterNodeName,ClusterArgs],5000),
    pong=net_adm:ping(ClusterNode),

    % Create wórker w1
    WorkerNodeName="w1",
    {ok,Worker1}=rpc:call(ClusterNode,slave,start,[HostName,WorkerNodeName,ClusterArgs]),
    

    % laod and start sd on worker
    true=rpc:call(Worker1,code,add_patha,[EbinApplDir]),
    ok=rpc:call(Worker1,application,start,[sd]),
    pong=rpc:call(Worker1,sd,ping,[]),
 
    
 %   ops:stop_ops_node(HostName),
     
    
 %   init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create_pod(HostName,NodeName,Cookie,PodDir)->
    Node=list_to_atom(NodeName++"@"++HostName),
    rpc:call(Node,init,stop,[]),
    true=vm:check_stopped_node(Node),
 
    true=erlang:set_cookie(node(),list_to_atom(Cookie)),
    Reply=case ops:cmd(HostName,os,cmd,["erl -sname "++NodeName++" "++" -setcookie "++Cookie++" "++" -detached"],5000) of
	      []->
		  case vm:check_started_node(Node) of
		      true->
			  {ok,Node};
		      false ->
			  {error,[failed_to_start_node,Node]}
		  end;
	      Reason ->
		  {error,[Reason,Node]}
	  end,
    Reply.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
-define(NodeInfo,[{"n1","n1","c100"},
		  {"n2","n2","c100"},
		  {"n3","n3","c100"}]).


create_vms()->
    
    Nodes=start_vm(?NodeInfo,[]),
    io:format(" ~p~n",[Nodes]),
    rpc:multicall(Nodes,init,stop,[]),    
    ok.

start_vm([],Nodes)->
    Nodes;
start_vm([{NodeName,Cookie,HostName}|T],Acc)->
    OpsNode=list_to_atom(?NODENAME++"@"++HostName),
    rpc:call(OpsNode,init,stop,[]),
    true=vm:check_stopped_node(OpsNode),
    Node=list_to_atom(NodeName++"@"++HostName),
    io:format(" ~p~n",[Node]),
    rpc:call(Node,init,stop,[]),
    true=vm:check_stopped_node(Node),
 
    true=erlang:set_cookie(node(),list_to_atom(Cookie)),
    []=ops:cmd(HostName,os,cmd,["erl -sname "++NodeName++" "++" -setcookie "++Cookie++" "++" -detached"],5000),
    true=vm:check_started_node(Node),
    start_vm(T,[Node|Acc]).
    
    

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
