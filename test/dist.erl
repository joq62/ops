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
