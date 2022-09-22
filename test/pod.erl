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
-module(pod).   
 
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
    Cookie="cookie1",
    Appl="sd",
    App=list_to_atom(Appl),
    PodDir="pod1.dir",

    ops:rmdir_r(HostName,PodDir),
    ok=ops:mkdir(HostName,PodDir),
    ApplDir=filename:join(PodDir,Appl),
    ok=ops:mkdir(HostName,ApplDir),

    {ok,Node}=create_pod(HostName,NodeName,Cookie,PodDir),
    {ok,CloneDir}=ops:git_clone(HostName,Appl++".spec",ApplDir),
    true=rpc:call(Node,code,add_patha,[filename:join([CloneDir,ApplDir,"ebin"])]),
    ok=rpc:call(Node,application,start,[list_to_atom(Appl)]),
    pang=rpc:call(Node,App,ping,[]),
    
    
    

    rpc:call(Node,init,stop,[]),
    true=vm:check_stopped_node(Node),
    
   
    
    init:stop(),
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
