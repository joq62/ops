%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Communicate nodes with different cookies 
%%% This node needs to start as hidden 
%%%   
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(dist_lib).   
 
-export([

	 start_node/4,
	 stop_node/3,

	 cmd/6,
	 mkdir/3,
	 rmdir/3,
	 rmdir_r/3,
	 pwd/2,
	 cp_file/5,
	 rm_file/4
	]).

-export([
	 git_clone/4
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
   
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),
   
    Ip=config:host_local_ip(HostName),
    SshPort=config:host_ssh_port(HostName),
    Uid=config:host_uid(HostName),
    Pwd=config:host_passwd(HostName),
    TimeOut=?SSH_TIMEOUT,
 

    Args="-setcookie "++Cookie++" "++EnvArgs,
    Msg="erl -sname "++NodeName++" "++Args, 
    
    Reply=case rpc:call(node(),my_ssh,ssh_send,[Ip,SshPort,Uid,Pwd,Msg,TimeOut],TimeOut-1000) of
	     % {badrpc,timeout}-> retry X times       
	       {badrpc,Reason}->
		   {error,[{?MODULE,?LINE," ",badrpc,Reason}]};
	       _Return->
%		  io:format("Return ~p~n",[Return]),
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
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),

    Node=list_to_atom(NodeName++"@"++HostName),
    rpc:call(Node,init,stop,[],5000),
    Reply=vm:check_stopped_node(Node),
    
    erlang:set_cookie(node(),CurrentCookie),
    Reply.
    



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
cmd(Node,Cookie,M,F,A,TimeOut)->
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),

    Reply=rpc:call(Node,M,F,A,TimeOut),	
    
    erlang:set_cookie(node(),CurrentCookie),
    Reply.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
git_clone(Node,Cookie,AppId,DirToClone)->
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),

    Reply=case config:application_gitpath(AppId) of
		{error,Reason}->
		    {error,[AppId,Reason]};
		GitPath->
		  appl:git_clone_to_dir(Node,GitPath,DirToClone)
	  end,
    erlang:set_cookie(node(),CurrentCookie),
    Reply.
			  
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
mkdir(Node,Cookie,DirName)->
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),

    Reply=case rpc:call(Node,filelib,is_dir,[DirName],5000) of
	      {badrpc,Reason}->
		  {error,[badrpc,Reason]};
	      true ->
		  {error,[already_exists,DirName]};
	      false ->
		  rpc:call(Node,file,make_dir,[DirName],5000)
	  end,
    erlang:set_cookie(node(),CurrentCookie),
    Reply.
	     
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
pwd(Node,Cookie)->
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),

    Reply=rpc:call(Node,file,get_cwd,[],5000),

    erlang:set_cookie(node(),CurrentCookie),
    Reply.
	     
	    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
rmdir(Node,Cookie,DirName)->
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),

    Reply=case rpc:call(Node,filelib,is_dir,[DirName],5000) of
	      {badrpc,Reason}->
		  {error,[badrpc,Reason]};
	      false ->
		  {error,[eexists,DirName]};
	      true->
		  rm:r(Node,DirName)
	  end,
    erlang:set_cookie(node(),CurrentCookie),
    timer:sleep(1000),
    Reply.
	     
 %% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
rmdir_r(Node,Cookie,DirName)->
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),
    Reply=case  rpc:call(Node,file,get_cwd,[],5000) of
	      {error,Reason}->
		  {error,[Reason]};
	      {badrpc,Reason}->
		  {error,[badrpc,Reason]};
		      {ok,Cwd}->
		  FullDirName=filename:join(Cwd,DirName),
		  rpc:call(Node,os,cmd,["rm -rf "++FullDirName],5000)
	  end,
    erlang:set_cookie(node(),CurrentCookie),
    
    Reply.
	     
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
cp_file(Node,Cookie,SourceDir,SourcFileName, DestDir)->
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),
    
    DestFileName=filename:join(DestDir,SourcFileName),
    SourceFileName=filename:join(SourceDir,SourcFileName),
    Reply=case rpc:call(Node,filelib,is_file,[DestFileName],5000) of
	      {badrpc,Reason}->
		  {error,[badrpc,Reason]};
	      true ->
		  {error,[already_exists,DestFileName]};
	      false ->
		  case file:read_file(SourceFileName) of
		      {error,Reason}->
			  {error,[Reason]};
		      {ok,Bin}->
			  rpc:call(Node,file,write_file,[DestFileName,Bin],5000)
		  end
	  end,
    erlang:set_cookie(node(),CurrentCookie),
    Reply.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
rm_file(Node,Cookie, Dir,FileName)->
    CurrentCookie=erlang:get_cookie(),
    erlang:set_cookie(node(),list_to_atom(Cookie)),
    
    FullFileName=filename:join(Dir,FileName),
    Reply=case rpc:call(Node,filelib,is_file,[FullFileName],5000) of
	      {badrpc,Reason}->
		  {error,[badrpc,Reason]};
	      false ->
		  {error,[eexists,FullFileName]};
	      true ->
		  rpc:call(Node,file,delete,[FullFileName],5000)
	  end,
    erlang:set_cookie(node(),CurrentCookie),
    Reply.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
