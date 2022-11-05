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
-module(cl1).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-define(Id_c1,"c1").


		 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
-define(HostNames,["c100","c300","c200","c201"]).

start()->
   
    ok=setup(),

    
    ok=candidates(1),
    ok=candidates(2),
    ok=candidates(3),
    ok=candidates(4),
    ok=candidates(5),
  %  ok=candidates(6),

    io:format("Test OK !!! ~p~n",[?MODULE]),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
candidates(1)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
    ["c100","c300","c200","c201"]=service_lib:candidates(1,?HostNames),
       
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok;

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
candidates(2)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
   [{"c300","c100"},
    {"c300","c200"},
    {"c300","c201"},
    {"c200","c100"},
    {"c201","c100"},
    {"c201","c200"}]=service_lib:candidates(2,?HostNames),
       
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok;

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
candidates(3)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
    [{"c300","c200","c100"},
     {"c300","c201","c100"},
     {"c300","c201","c200"},
     {"c201","c200","c100"}
    ]=service_lib:candidates(3,?HostNames),
       
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok;

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
candidates(4)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
     {error,[too_many_instances_vs_hosts,0]}=service_lib:candidates(4,?HostNames),
       
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
    ok;
 
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
candidates(5)->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
  
   {error,[too_many_instances_vs_hosts,1]}=service_lib:candidates(5,?HostNames),
       
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),
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


setup()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

 
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),

    ok.
