%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(ops).
 
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
	 start_ops_node/1,
	 stop_ops_node/1
	 
       
	]).


-export([
	 mkdir/2,
	 rmdir/2,
	 cp_file/4,
	 rm_file/3
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
-record(state, {
	       }).


%% ====================================================================
%% External functions
%% ====================================================================
appl_start([])->
    application:start(?MODULE).


start_ops_node(HostName)->
    gen_server:call(?MODULE,{start_ops_node,HostName},infinity).   
stop_ops_node(Node)->
    gen_server:call(?MODULE,{stop_ops_node,Node},infinity).    


% mkdir
% rmdir
% cp_file
% rm_file

mkdir(Host,DirName)->
    gen_server:call(?MODULE,{mkdir,Host,DirName},infinity).
rmdir(Host,DirName)->
    gen_server:call(?MODULE,{rmdir,Host,DirName},infinity).

cp_file(SourceDir,SourcFileName,Host, DestDir)->
    gen_server:call(?MODULE,{cp_file,SourceDir,SourcFileName,Host, DestDir},infinity).
rm_file(Host, Dir,FileName)->
    gen_server:call(?MODULE,{rm_file,Host, Dir,FileName},infinity).
    
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
    application:start(sd),
 %   application:start(nodelog),
    application:start(config),
    %create logdir and file
    

%    rpc:cast(node(),nodelog,log,[notice,?MODULE_STRING,?LINE,
%				 {"OK, started server  ",?MODULE,node()}]), 
    {ok, #state{}}.   
  % {ok, #state{},0}.

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

handle_call({start_ops_node,HostName},_From, State) ->
      % create an agent on Host, check if node is running 
    % Check if dir exists 
    % if note - create a dir 
    Reply=ops_lib:create_agent(HostName),
    {reply, Reply, State};

handle_call({stop_ops_node,Node},_From, State) ->
    % create an agent on Host, check if node is running 
    % Check if dir exists 
    % if note - create a dir 
    Reply=rpc:call(Node,init,stop,[]),
    {reply, Reply, State};


handle_call({mkdir,HostName,DirName},_From, State) ->
    Reply=ops_lib:mkdir(HostName,DirName),
    {reply, Reply, State};

handle_call({rmdir,HostName,DirName},_From, State) ->
    Reply=ops_lib:rmdir(HostName,DirName),
    {reply, Reply, State};

handle_call({cp_file,SourceDir,SourcFileName,HostName, DestDir},_From, State) ->
    % create an agent on Host
    % Check if dir exists 
    % if file copy  
    Reply=ops_lib:cp_file(SourceDir,SourcFileName,HostName, DestDir),
    {reply, Reply, State};

handle_call({rm_file,HostName, Dir,FileName},_From, State) ->
    Reply=ops_lib:rm_file(HostName, Dir,FileName),
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
