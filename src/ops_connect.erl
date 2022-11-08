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
-module(ops_connect).   
 
-export([
	 create/7,
	 delete/3
	]).
		 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
delete(HostName,ConnecNode,NodeDir)->
    ssh_vm:delete_dir(HostName,NodeDir),
    rpc:call(ConnecNode,init,stop,[],2000).
    
    
    
    
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
create(HostName,NodeName,NodeDir,Cookie,PaArgs,EnvArgs,NodesToConnect)->
    %Create erlang vm
    ssh_vm:delete_dir(HostName,NodeDir),
    Result=case ssh_vm:create(HostName,NodeName,Cookie,PaArgs,EnvArgs) of
	       {error,Reason}->
		   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
	       {ok,ConnectNode}-> % Create controller and cluster directory
		   case rpc:call(ConnectNode,file,make_dir,[NodeDir],2000) of
		       {badrpc,Reason}->
			   ssh_vm:delete_dir(HostName,NodeDir),
			   {error,[badrpc,Reason,?MODULE,?FUNCTION_NAME,?LINE]};
		       ok->
			   PingResult=[{rpc:call(ConnectNode,net_adm,ping,[NodeX],2000),NodeX}||NodeX<-NodesToConnect],
			   {ok,ConnectNode,NodeDir,PingResult}
		   end
	   end,
    Result.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
