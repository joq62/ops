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
	 create/6,
	 delete/1
	]).
		 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
delete(ConnecNode)->
    rpc:call(ConnecNode,init,stop,[],2000).
    
    
    
    
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
create(HostName,NodeName,Cookie,PaArgs,EnvArgs,NodesToConnect)->
    %Create erlang vm
  
    Result=case ssh_vm:create(HostName,NodeName,Cookie,PaArgs,EnvArgs) of
	       {error,Reason}->
		   {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]};
	       {ok,Node}-> % Create controller and cluster directory
		   PingResult=[{rpc:call(Node,net_adm,ping,[NodeX],2000),NodeX}||NodeX<-NodesToConnect],
		   {ok,Node,PingResult}
	   end,
    Result.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------------------------------------------
