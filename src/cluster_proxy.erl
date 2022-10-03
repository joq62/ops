%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(cluster_proxy).
 
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
	 all_services/0,
	 all_services/1,
	 is_cluster_node_present/2,
	 start_cluster_node/2,
	 stop_cluster_node/2,
	 intent_cluster/0,
	 intent_cluster/1,

	 % Admin
	 cluster_names/0

	]).

-export([
	 is_pod_node_present/3,
	 start_pod_node/3,
	 stop_pod_node/3,
	 intent_pods/0,
	 intent_pods/1,

	 % Admin
	 pod_names/2

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
  

all_services()->
    gen_server:call(?MODULE,{all_services},infinity).  

all_services(ClusterName)->
    gen_server:call(?MODULE,{all_services,ClusterName},infinity).  
is_cluster_node_present(HostName,ClusterName)->
    gen_server:call(?MODULE,{is_cluster_node_present,HostName,ClusterName},infinity).  
start_cluster_node(HostName,ClusterName)->
    gen_server:call(?MODULE,{start_cluster_node,HostName,ClusterName},infinity).   
stop_cluster_node(HostName,ClusterName)->
    gen_server:call(?MODULE,{stop_cluster_node,HostName,ClusterName},infinity).   

cluster_names()->
    gen_server:call(?MODULE,{cluster_names},infinity).   

intent_cluster()->
    gen_server:call(?MODULE,{intent_cluster},infinity).  
intent_cluster(ClusterName)->
    gen_server:call(?MODULE,{intent_cluster,ClusterName},infinity).  

%% --------------------------------------------------------------------

is_pod_node_present(HostName,ClusterName,PodName)->
    gen_server:call(?MODULE,{is_pod_node_present,HostName,ClusterName,PodName},infinity).  
start_pod_node(HostName,ClusterName,PodName)->
    gen_server:call(?MODULE,{start_pod_node,HostName,ClusterName,PodName},infinity).   
stop_pod_node(HostName,ClusterName,PodName)->
    gen_server:call(?MODULE,{stop_pod_node,HostName,ClusterName,PodName},infinity).   
pod_names(HostName,ClusterName)->
    gen_server:call(?MODULE,{pod_names,HostName,ClusterName},infinity).  

intent_pods()->
    gen_server:call(?MODULE,{intent_pods},infinity).  
intent_pods(ClusterName)->
    gen_server:call(?MODULE,{intent_pods,ClusterName},infinity).  


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


handle_call({all_services},_From, State) ->
    Reply=cluster_lib:all_services(State#state.cluster_spec),   
    {reply, Reply, State};

handle_call({all_services,ClusterName},_From, State) ->
    Reply=cluster_lib:all_services(ClusterName,State#state.cluster_spec),   
    {reply, Reply, State};

handle_call({intent_cluster,ClusterName},_From, State) ->
    Reply=cluster_lib:intent(ClusterName,State#state.cluster_spec),   
    {reply, Reply, State};

handle_call({intent_cluster},_From, State) ->
    Reply=cluster_lib:intent(State#state.cluster_spec),   
    {reply, Reply, State};

handle_call({cluster_names},_From, State) ->
    Reply=cluster_data:cluster_all_names(State#state.cluster_spec),
    {reply, Reply, State};

handle_call({is_cluster_node_present,HostName,ClusterName},_From, State) ->
    Reply=cluster_lib:is_node_present(HostName,ClusterName,State#state.cluster_spec),
    {reply, Reply, State};

handle_call({start_cluster_node,HostName,ClusterName},_From, State) ->
    Reply=cluster_lib:start_node(HostName,ClusterName,State#state.cluster_spec),
    {reply, Reply, State};

handle_call({stop_cluster_node,HostName,ClusterName},_From, State) ->
    Reply=cluster_lib:stop_node(HostName,ClusterName,State#state.cluster_spec),
    {reply, Reply, State};
%% --------------------------------------------------------------------

handle_call({intent_pods,ClusterName},_From, State) ->
    Reply=pod_lib:intent(ClusterName,State#state.cluster_spec),   
    {reply, Reply, State};

handle_call({intent_pods},_From, State) ->
    Reply=pod_lib:intent(State#state.cluster_spec),   
    {reply, Reply, State};

handle_call({pod_names,HostName,ClusterName},_From, State) ->
    Reply=cluster_data:pod_all_names(HostName,ClusterName,State#state.cluster_spec),
    {reply, Reply, State};

handle_call({is_pod_node_present,HostName,ClusterName,PodName},_From, State) ->
    Reply=pod_lib:is_node_present(HostName,ClusterName,PodName,State#state.cluster_spec),
    {reply, Reply, State};

handle_call({start_pod_node,HostName,ClusterName,PodName},_From, State) ->
    Reply=pod_lib:start_node(HostName,ClusterName,PodName,State#state.cluster_spec),
    {reply, Reply, State};

handle_call({stop_pod_node,HostName,ClusterName,PodName},_From, State) ->
    Reply=pod_lib:stop_node(HostName,ClusterName,PodName,State#state.cluster_spec),
    {reply, Reply, State};

%% --------------------------------------------------------------------

handle_call({cluster_spec},_From, State) ->
    Reply=cluster_data:cluster_all_names(State#state.cluster_spec),
    {reply, Reply, State};

handle_call({deployment_spec},_From, State) ->
    Reply=cluster_data:deployment_all_names(State#state.deployment_spec),
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
