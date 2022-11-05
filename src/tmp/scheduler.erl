%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(scheduler).
 
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------

-export([
	
	]).

-export([
	 intent_cluster/1,
	 cluster_status/1,
	 intent_pods/1,
	 pod_status/1,
	 intent_services/1

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
	       cluster_spec
	       }).


%% ====================================================================
%% External functions
%% ====================================================================

appl_start([])->
    application:start(?MODULE).
%% --------------------------------------------------------------------
  
%% --------------------------------------------------------------------


intent_cluster(ClusterName)->
    gen_server:call(?MODULE,{intent_cluster,ClusterName},infinity).
cluster_status(ClusterName)->
    gen_server:call(?MODULE,{cluster_status,ClusterName},infinity).

intent_pods(ClusterName)->
    gen_server:call(?MODULE,{intent_pods,ClusterName},infinity).
pod_status(ClusterName)->
    gen_server:call(?MODULE,{pod_status,ClusterName},infinity).
intent_services(ClusterName)->
    gen_server:call(?MODULE,{intent_services,ClusterName},infinity).


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
    
    
    {ok, #state{
	    cluster_spec=ClusterSpec	    
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

handle_call({intent_cluster,ClusterName},_From, State) ->
    Reply=ops:intent(ClusterName),   
    {reply, Reply, State};

handle_call({cluster_status,ClusterName},_From, State) ->
    Reply=ops:intent(ClusterName),   
    {reply, Reply, State};

handle_call({intent_pods,ClusterName},_From, State) ->
    Reply=ops:intent(ClusterName),   
    {reply, Reply, State};

handle_call({pod_status,ClusterName},_From, State) ->
    Reply=ops:intent(ClusterName),   
    {reply, Reply, State};

handle_call({intent_services,ClusterName},_From, State) ->
    Reply=ops:intent(ClusterName),   
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
