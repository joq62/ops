%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(pod).
 
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------

%% External exports

%% start_ops_node
%% stop_ops_node 

%% Usecases
% mkdir
% rmdir
% cp_file
% rm_file


% Update config file on one host
% Update config file on all hosts

% delete config file on node 
% 
% start new cluster 
% delete cluster 

% load_start appl on cluster node
% stop_unload appl on cluster node

% read nodelog on node

-export([
	 is_node_present/3,
	 start_node/3,
	 stop_node/3,

	 % Admin
	 names/2

	]).


-export([
	 start/0,
	 stop/0,
	 appl_start/1,
	 ping/0
	]).


%% gen_server callbacks



-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%-------------------------------------------------------------------
-record(state,{
	       cluster_spec,
	       deployment_spec
	       }).


%% ====================================================================
%% External functions
%% ====================================================================

appl_start([])->
    application:start(?MODULE).
%% --------------------------------------------------------------------

is_node_present(HostName,ClusterName,PodName)->
    gen_server:call(?MODULE,{is_node_present,HostName,ClusterName,PodName},infinity).  
start_node(HostName,ClusterName,PodName)->
    gen_server:call(?MODULE,{start_node,HostName,ClusterName,PodName},infinity).   
stop_node(HostName,ClusterName,PodName)->
    gen_server:call(?MODULE,{stop_node,HostName,ClusterName,PodName},infinity).   

names(HostName,ClusterName)->
    gen_server:call(?MODULE,{names,HostName,ClusterName},infinity).   


%% --------------------------------------------------------------------

%% call
start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).

ping()->
    gen_server:call(?MODULE,{ping},infinity).

%% cast

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->

    ClusterSpec=cluster_data:read_cluster_spec(),
%    DeploymentSpec=cluster_data:read_deployment_spec(),
    
    {ok, #state{cluster_spec=ClusterSpec,
		deployment_spec=[]}}.   
 

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_call({names,HostName,ClusterName},_From, State) ->
    Reply=cluster_data:pod_all_names(HostName,ClusterName,State#state.cluster_spec),
    {reply, Reply, State};

handle_call({is_node_present,HostName,ClusterName,PodName},_From, State) ->
    Reply=pod_lib:is_node_present(HostName,ClusterName,PodName,State#state.cluster_spec),
    {reply, Reply, State};

handle_call({start_node,HostName,ClusterName,PodName},_From, State) ->
    Reply=pod_lib:start_node(HostName,ClusterName,PodName,State#state.cluster_spec),
    {reply, Reply, State};

handle_call({stop_node,HostName,ClusterName,PodName},_From, State) ->
    Reply=pod_lib:stop_node(HostName,ClusterName,PodName,State#state.cluster_spec),
    {reply, Reply, State};

handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{Msg,?MODULE,?LINE}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({ssh_cm,_,_}, State) ->
   
    {noreply, State};

handle_info(Info, State) ->
    io:format("unmatched match~p~n",[{Info,?MODULE,?LINE}]), 
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
