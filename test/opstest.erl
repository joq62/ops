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
-module(opstest).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(ClusterSpec,"cluster.spec").
-define(DeploymentSpec,"deployment.spec").

		 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),
    ok=application:start(ops),

    ok=init_test(),
    io:format("init_test() OK ~n"),

    ok=create_all(),
    io:format(" create_all() OK ~n"),

  

  
    %% Clean up
    
    io:format("opstest() Test suit succeded OK ~n"),
    timer:sleep(1000),
  
    init:stop(),
    ok.





%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create_all()->
    
    ok.
    


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
init_test()->
    pong=config:ping(),

    [{"c1","c201"},
     {"c1","c200"},
     {"c1","c100"},
     {"c2","c100"}]=ops:cluster_spec(),
    ["d1","d2"]=ops:deployment_spec(),
    ok.
      

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

setup()->

    

    ok.
