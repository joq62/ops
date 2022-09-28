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
-module(basic).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    application:start(ops),
    HostName="c100",
    
    % start ops node	
    true=ops:stop_ops_node(HostName),
    {ok,OpsNode}=ops:start_ops_node(HostName),
%    ok=create_vms(),
    
   % init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
-define(NodeInfo,[{"n1","n1","c201"},
		  {"n2","n2","c201"},
		  {"n3","n3","c201"}]).


create_vms()->
    
    ok=start_vm(?NodeInfo),
    

    
    ok.
start_vm([])->
    ok;
start_vm([{NodeName,Cookie,HostName}|T])->

    Node=list_to_atom(NodeName++"@"++HostName),
    rpc:call(Node,init,stop,[]),
    timer:sleep(1000),
    io:format(" ~p~n",[Node]),
    true=erlang:set_cookie(node(),list_to_atom(Cookie)),
    ops:cmd(HostName,os,cmd,["erl -sname "++NodeName++" "++" -setcookie "++Cookie++" "++" -detached"],5000),
    timer:sleep(3000),
    pong=net_adm:ping(Node),
    rpc:call(Node,init,stop,[]),
    start_vm(T).
    
    

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
