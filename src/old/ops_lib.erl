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
	
	]).

-export([

	]).



%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-define(NODENAME,"ops").
-define(TEMP_DIR,"temp_ops").
-define(SSH_TIMEOUT,5000).
-define(Node(HostName),list_to_atom(?NODENAME++"@"++HostName)).

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
start_node(HostName,NodeName,Cookie,EnvArgs)->

    Ip=config:host_local_ip(HostName),
    SshPort=config:host_ssh_port(HostName),
    Uid=config:host_uid(HostName),
    Pwd=config:host_passwd(HostName),
    TimeOut=?SSH_TIMEOUT,
    CurrentCookie=erlang:get_cookie(),

    Args="-setcookie "++Cookie++" "++EnvArgs,
    Msg="erl -sname "++NodeName++" "++Args, 
    
    Reply=case rpc:call(node(),my_ssh,ssh_send,[Ip,SshPort,Uid,Pwd,Msg,TimeOut],TimeOut-1000) of
	     % {badrpc,timeout}-> retry X times       
	       {badrpc,Reason}->
		   {error,[{?MODULE,?LINE," ",badrpc,Reason}]};
	       Return->
		  io:format("Return ~p~n",[Return]),
		  erlang:set_cookie(node(),list_to_atom(Cookie)),
		  CreatedNode=list_to_atom(NodeName++"@"++HostName),
		  vm:check_started_node(CreatedNode)
	  end,
    erlang:set_cookie(node(),CurrentCookie),
    Reply.
   
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
stop_node(HostName,NodeName,Cookie)->
    Node=list_to_atom(NodeName++"@"++HostName),
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),
    rpc:call(Node,init,stop,[],5000),
    Reply=vm:check_stopped_node(Node),
    erlang:set_cookie(node(),CurrentCookie),
    Reply.
    


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
start_ops_node(HostName)->
    Reply=case net_adm:ping(?Node(HostName)) of
	      pong->
		  {error,[node_already_exists,HostName]};
	      pang->
		  Ip=config:host_local_ip(HostName),
		  SshPort=config:host_ssh_port(HostName),
		  Uid=config:host_uid(HostName),
		  Pwd=config:host_passwd(HostName),
		  NodeName=?NODENAME,
		  Cookie=atom_to_list(erlang:get_cookie()),
		  PaArgs=" ",
		  EnvArgs=" -hidden ",
		  TimeOut=?SSH_TIMEOUT,
		  ssh_vm:create(HostName,NodeName,Cookie,PaArgs,EnvArgs,{Ip,SshPort,Uid,Pwd,TimeOut})
	  end,
    Reply.
   

stop_ops_node(HostName)->
    rpc:call(?Node(HostName),init,stop,[]),
    vm:check_stopped_node(?Node(HostName)).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
cmd(HostName,M,F,A,TimeOut)->
    Reply=case net_adm:ping(?Node(HostName)) of
	      pang->
		  {error,[ops_node_not_started,HostName]};
	      pong->
		  rpc:call(?Node(HostName),M,F,A,TimeOut)		
	  end,
    Reply.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
git_clone(HostName,AppId,DirToClone)->
    Reply=case config:application_gitpath(AppId) of
		{error,Reason}->
		    {error,[AppId,Reason]};
		GitPath->
		  case net_adm:ping(?Node(HostName)) of
		      pang->
			  {error,[ops_node_not_started,HostName]};
		      pong->
			  appl:git_clone_to_dir(?Node(HostName),GitPath,DirToClone)
		  end
	  end,
    Reply.
			  
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
mkdir(HostName,DirName)->
    Reply=case net_adm:ping(?Node(HostName)) of
	      pang->
		  {error,[ops_node_not_started,HostName]};
	      pong->
		  case rpc:call(?Node(HostName),filelib,is_dir,[DirName],5000) of
		      {badrpc,Reason}->
			  {error,[badrpc,Reason]};
		      true ->
			  {error,[already_exists,DirName]};
		      false ->
			  rpc:call(?Node(HostName),file,make_dir,[DirName],5000)
		  end
	  end,
    Reply.
	     
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
pwd(HostName)->
    Reply=case net_adm:ping(?Node(HostName)) of
	      pang->
		  {error,[ops_node_not_started,HostName]};
	      pong->
		  rpc:call(?Node(HostName),file,get_cwd,[],5000)
	  end,
    Reply.
	     
	    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
rmdir(HostName,DirName)->
    Reply=case net_adm:ping(?Node(HostName)) of
	      pang->
		  {error,[ops_node_not_started,HostName]};
	      pong->
		  case rpc:call(?Node(HostName),filelib,is_dir,[DirName],5000) of
		      {badrpc,Reason}->
			  {error,[badrpc,Reason]};
		     false ->
			  {error,[eexists,DirName]};
		      true->
			  rm:r(?Node(HostName),DirName)
		  end
	  end,
    Reply.
	     
 %% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
rmdir_r(HostName,DirName)->
    Reply=case net_adm:ping(?Node(HostName)) of
	      pang->
		  {error,[ops_node_not_started,HostName]};
	      pong->
		  case rpc:call(?Node(HostName),file,get_cwd,[],5000) of
		      {error,Reason}->
			  {error,[Reason]};
		      {badrpc,Reason}->
			  {error,[badrpc,Reason]};
		      {ok,Cwd}->
			  FullDirName=filename:join(Cwd,DirName),
			  rpc:call(?Node(HostName),os,cmd,["rm -rf "++FullDirName],5000)
		  end
	  end,
    Reply.
	     
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
cp_file(SourceDir,SourcFileName,HostName, DestDir)->
    Reply=case net_adm:ping(?Node(HostName)) of
	      pang->
		  {error,[ops_node_not_started,HostName]};
	      pong->
		  DestFileName=filename:join(DestDir,SourcFileName),
		  SourceFileName=filename:join(SourceDir,SourcFileName),
		  case rpc:call(?Node(HostName),filelib,is_file,[DestFileName],5000) of
		      {badrpc,Reason}->
			  {error,[badrpc,Reason]};
		      true ->
			  {error,[already_exists,DestFileName]};
		      false ->
			  case file:read_file(SourceFileName) of
			      {error,Reason}->
				  {error,[Reason]};
			      {ok,Bin}->
				  rpc:call(?Node(HostName),file,write_file,[DestFileName,Bin],5000)
			    end	 
		  end
	  end,
    Reply.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
rm_file(HostName, Dir,FileName)->
    Reply=case net_adm:ping(?Node(HostName)) of
	      pang->
		  {error,[ops_node_not_started,HostName]};
	      pong->
		  FullFileName=filename:join(Dir,FileName),
		  case rpc:call(?Node(HostName),filelib,is_file,[FullFileName],5000) of
		      {badrpc,Reason}->
			  {error,[badrpc,Reason]};
		      false ->
			  {error,[eexists,FullFileName]};
		      true ->
			  rpc:call(?Node(HostName),file,delete,[FullFileName],5000)
		  end
	  end,
    Reply.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
