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
-module(ops_pod).   
 
-export([
	 create/7,
	 delete/3
	]).
		 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
delete(ControllerNode,PodeNode,PodDir)->
    rpc:call(ControllerNode,os,cmd,["rm -rf "++PodDir]),
    rpc:call(ControllerNode,slave,stop,[PodeNode],2000),
    ok.
    
    
    
    
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
create(HostName,ControllerNode,PodNodeName,PodDir,Cookie,AppId,AppEnv)->
    Args=" -setcookie "++Cookie,
    Result=case rpc:call(ControllerNode,slave,start,[HostName,PodNodeName,Args],5000) of
	       {badrpc,Reason}->
		   {error,[badrpc,Reason,?MODULE,?FUNCTION_NAME,?LINE]};
	       {error,Reason}->
		   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
	       {ok,PodNode}->
		   case rpc:call(PodNode,file,make_dir,[PodDir],5000) of
		       {error,Reason}->
			   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
		       ok-> % Git clone controller_app
			   case rpc:call(ControllerNode,net_kernel,connect_node,[PodNode],5000) of
			       {badrpc,Reason}->
				   {error,[badrpc,Reason,?MODULE,?FUNCTION_NAME,?LINE]};
			       false->
				   rpc:call(ControllerNode,os,cmd,["rm -rf "++PodDir],5000),
				   {error,[failed_connect,PodNode]};
			       ignored->
				   {error,[ignored,PodNode,?MODULE,?FUNCTION_NAME,?LINE]};
			       true-> % git clone the Application
				   DirToClone=filename:join(PodDir,AppId),
				   case rpc:call(PodNode,file,make_dir,[DirToClone],5000) of
				       {error,Reason}->
					   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
				       ok-> % Git clone controller_app
					   GitPath=config:application_gitpath(AppId),	   
					   case appl:git_clone_to_dir(PodNode,GitPath,DirToClone) of
					       {error,Reason}->
						   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
					       {ok,_}->
						   Paths=[filename:join(DirToClone,"ebin")],
						   App=list_to_atom(AppId),
						   case appl:load(PodNode,App,Paths) of
						       {error,Reason}->
							   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
						       ok-> % set the controller_app application environment variables
							   case rpc:call(PodNode,application,set_env,[AppEnv],5000) of
							       {badrpc,Reason}->
								   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
							       {error,Reason}->
								   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
							       ok->
								   case appl:start(PodNode,App) of
								       {error,Reason}->
									   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
								       ok->
									   {ok,PodNode,PodDir}
								   end
							   end
						   end
					   end
				   end
			   end			   
		   end
	   end,
    Result.
 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
