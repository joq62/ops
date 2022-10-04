%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(cluster).
 
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
	
	]).

-export([
	 is_pod_node_present/1,
	 start_pod_node/1,
	 stop_pod_node/1,
	 intent_pods/0,

	 % Admin
	 pod_nodes_status/0

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
	       cluster_nodes,
	       pod_name_dir_list
	       }).


%% ====================================================================
%% External functions
%% ====================================================================

appl_start([])->
    application:start(?MODULE).
%% --------------------------------------------------------------------
  
%% --------------------------------------------------------------------

start_pod_node(PodName)->
    gen_server:call(?MODULE,{start_pod_node,PodName},infinity).   
stop_pod_node(PodName)->
    gen_server:call(?MODULE,{stop_pod_node,PodName},infinity).   

pod_nodes_status()->
    gen_server:call(?MODULE,{pod_nodes_status},infinity).

is_pod_node_present(PodName)->
    gen_server:call(?MODULE,{is_pod_node_present,PodName},infinity).  

intent_pods()->
    gen_server:call(?MODULE,{intent_pods},infinity).

%% --------------------------------------------------------------------

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
    
    {ok,ClusterNodes}=application:get_env(cluster,cluster_nodes),
    {ok,PodNameDirList}=application:get_env(cluster,pod_name_dir_list),
        
    {ok, #state{
	    cluster_nodes=ClusterNodes,
	    pod_name_dir_list=PodNameDirList
	   }}.   
 

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
%% --------------------------------------------------------------------

handle_call({intent_pods},_From, State) ->
    Reply=pod_lib:intent(State#state.pod_name_dir_list),   
    {reply, Reply, State};
handle_call({pod_nodes_status},_From, State) ->
    Reply=pod_lib:status(State#state.pod_name_dir_list),
    {reply, Reply, State};

handle_call({is_pod_node_present,PodName},_From, State) ->
    Reply=pod_lib:is_node_present(PodName),
    {reply, Reply, State};

handle_call({start_pod_node,PodName},_From, State) ->
    Reply=pod_lib:start_node(PodName),
    {reply, Reply, State};

handle_call({stop_pod_node,PodName},_From, State) ->
    Reply=pod_lib:stop_node(PodName),
    {reply, Reply, State};

%% --------------------------------------------------------------------

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
