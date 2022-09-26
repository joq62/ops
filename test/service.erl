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
-module(service).   
 
-export([
	 load/5,
	 start/3,
	 stop/3,
	 unload/3,
	 running/2,
	 loaded/2
	]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
load(PodNode,ClusterCookie,Appl,SourceDir,ApplDir)->
    App=list_to_atom(Appl),
    Result= case dist_lib:mkdir(PodNode,ClusterCookie,ApplDir) of
		{error,Reason}->
		    {error,Reason};
		ok->
		    EbinApplDir=filename:join(ApplDir,"ebin"),
		    case dist_lib:mkdir(PodNode,ClusterCookie,EbinApplDir) of
			{error,Reason}->
			    {error,Reason};
			ok->
			    case file:list_dir(SourceDir) of
				{error,Reason}->
				    {error,Reason};
				{ok,EbinFiles}->
				    [dist_lib:cp_file(PodNode,ClusterCookie,SourceDir,SourcFileName,EbinApplDir)||SourcFileName<-EbinFiles], 
				    case dist_lib:cmd(PodNode,ClusterCookie,code,add_patha,[EbinApplDir],5000) of
					{error,Reason}->
					    {error,Reason};
					true->
					    dist_lib:cmd(PodNode,ClusterCookie,application,load,[App],5000)
				    end
			    end
		    end
	    end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start(PodNode,ClusterCookie,Appl)->
    App=list_to_atom(Appl),
    dist_lib:cmd(PodNode,ClusterCookie,application,start,[App],5000).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
stop(PodNode,ClusterCookie,Appl)->
    App=list_to_atom(Appl),
    dist_lib:cmd(PodNode,ClusterCookie,application,stop,[App],5000).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
unload(PodNode,ClusterCookie,ApplDir)->
    dist_lib:rmdir_r(PodNode,ClusterCookie,ApplDir).


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
running(PodNode,ClusterCookie)->
    dist_lib:cmd(PodNode,ClusterCookie,application,which_applications,[],5000).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

loaded(PodNode,ClusterCookie)->
    dist_lib:cmd(PodNode,ClusterCookie,application,loaded_applications,[],5000).



