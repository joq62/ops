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
-module(ops_controller).   
 
-export([
	 create/7,
	 delete/2
	]).
		 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
delete(ControllerNode,Dir)->
    rpc:call(ControllerNode,os,cmd,["rm -rf "++Dir]),
    rpc:call(ControllerNode,init,kill,[],2000),
    ok.
    
    
    
    
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
create(HostName,ConnectNode,NodeName,NodeDir,Cookie,PaArgs,ControllerEnv)->
    rpc:call(ConnectNode,os,cmd,["rm -rf "++NodeDir],2000),
    Result=case vm:create(HostName,NodeDir,NodeName,Cookie,PaArgs,ControllerEnv) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,ControllerNode}-> % Create controller and cluster directory
		   case rpc:call(ControllerNode,file,make_dir,[NodeDir],5000) of
		       {error,Reason}->
			   {error,Reason};
		       ok-> % Copy config specifications
			   SourceNode=node(),
			   SourceDir=".",
			   DestinationNode=ControllerNode,
			   DestinationDir=NodeDir,
			   case copy_spec_files(SourceNode,SourceDir,DestinationNode,DestinationDir) of
			       {error,Reason}->
				   {error,Reason};
			       ok-> % Created Controller App Dir
				   AppId="controller_app",
				   DirToClone=filename:join(NodeDir,AppId),
				   case rpc:call(ControllerNode,file,make_dir,[DirToClone],5000) of
				       {error,Reason}->
					   {error,Reason};
				       ok-> % Git clone controller_app
					   GitPath=config:application_gitpath(AppId),	   
					   case appl:git_clone_to_dir(ControllerNode,GitPath,DirToClone) of
					       {error,Reason}->
						   {error,Reason};
					       {ok,_}->
						   Paths=[filename:join(DirToClone,"ebin")],
						   App=list_to_atom(AppId),
						   case appl:load(ControllerNode,App,Paths) of
						       {error,Reason}->
							   {error,Reason};
						       ok-> % set the controller_app application environment variables
							   case rpc:call(ControllerNode,application,set_env,[ControllerEnv],5000) of
							       {badrpc,Reason}->
								   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
							       {error,Reason}->
								   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
							       ok->
								   case appl:start(ControllerNode,App) of
								       {error,Reason}->
									   {error,Reason};
								       ok->
									   {ok,ControllerNode,NodeDir}
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
copy_spec_files(SourceNode,SourceDir,DestinationNode,DestinationDir)->
    Result=case file:list_dir(SourceDir) of
	       {error,Reason}->
		   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
	       {ok,FileNames}->
		   case spec_file_names(FileNames,[]) of
		       []->
			   {error,[no_specs_files,?MODULE,?FUNCTION_NAME,?LINE]};
		       SpecFileNames->
			   copy_files(SpecFileNames,SourceNode,SourceDir,DestinationNode,DestinationDir,[])
		   end
	   end,
    Result.

copy_files([],_SourceNode,_SourceDir,_DestNode,_DestDir,[])->
    ok;
copy_files([],_SourceNode,_SourceDir,_DestNode,_DestDir,ErrorList)->
    {error,ErrorList};

copy_files([SpecFileName|T],SourceNode,SourceDir,DestNode,DestDir,Acc)->
    NewAcc=case copy:copy_file(SourceNode,SourceDir,SpecFileName,DestNode,DestDir,SpecFileName) of
	       {error,Reason}->
		   [{error,Reason}|Acc];
	       ok ->
		   Acc
	   end,
    copy_files(T,SourceNode,SourceDir,DestNode,DestDir,NewAcc).
			   
spec_file_names([],Acc)->
    Acc;
spec_file_names(["spec.application"|T],Acc)->
    spec_file_names(T,["spec.application"|Acc]);
spec_file_names(["spec.cluster"|T],Acc)->
    spec_file_names(T,["spec.cluster"|Acc]);
spec_file_names(["spec.deployment"|T],Acc)->
    spec_file_names(T,["spec.deployment"|Acc]);
spec_file_names(["spec.host"|T],Acc)->
    spec_file_names(T,["spec.host"|Acc]);
spec_file_names([_|T],Acc)->
    spec_file_names(T,Acc).

    
