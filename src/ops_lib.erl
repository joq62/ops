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
-module(ops_lib).   
 
-export([
	 create_agent/1,
	 mkdir/2,
	 rmdir/2

	]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-define(NODENAME,"operation").
-define(SSH_TIMEOUT,5000).

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
mkdir(HostName,DirName)->
    Reply=case ops_lib:create_agent(HostName) of
	      {error,[node_exists_on_host,HostName]}->
		  {error,[node_exists_on_host,HostName]};
	      {ok,Node} ->
		  case rpc:call(Node,filelib,is_dir,[DirName],5000) of
		      {badrpc,Reason}->
			  rpc:call(Node,init,stop,[]),
			  {error,[badrpc,Reason]};
		      true ->
			  rpc:call(Node,init,stop,[]),
			  {error,[dir_already_exists,DirName]};
		      false ->
			  R=rpc:call(Node,file,make_dir,[DirName],5000),
			  rpc:call(Node,init,stop,[]),
			  R
		  end
	  end,
    Reply.
	     
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
rmdir(HostName,DirName)->
    Reply=case ops_lib:create_agent(HostName) of
	      {error,[node_exists_on_host,HostName]}->
		  {error,[node_exists_on_host,HostName]};
	      {ok,Node} ->
		  case rpc:call(Node,filelib,is_dir,[DirName],5000) of
		      {badrpc,Reason}->
			  rpc:call(Node,init,stop,[]),
			  {error,[badrpc,Reason]};
		     false ->
			  rpc:call(Node,init,stop,[]),
			  {error,[dir_eexists,DirName]};
		      true->
			  R=rm:r(Node,DirName),
			  rpc:call(Node,init,stop,[]),
			  R
		  end
	  end,
    Reply.
	     
		    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
create_agent(HostName)->
    Reply=case net_adm:ping(list_to_atom(?NODENAME++"@"++HostName)) of
	      pong->
		  {error,[node_exists_on_host,HostName]};
	      pang->
		  Ip=config:host_local_ip(HostName),
		  SshPort=config:host_ssh_port(HostName),
		  Uid=config:host_uid(HostName),
		  Pwd=config:host_passwd(HostName),
		  NodeName=?NODENAME,
		  Cookie=atom_to_list(erlang:get_cookie()),
		  PaArgs=" ",
		  EnvArgs=" ",
		  TimeOut=?SSH_TIMEOUT,
		  ssh_vm:create(HostName,NodeName,Cookie,PaArgs,EnvArgs,{Ip,SshPort,Uid,Pwd,TimeOut})
	  end,
    Reply.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
