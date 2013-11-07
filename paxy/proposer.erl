-module(proposer).
-export([start/5]).
-define(timeout, 2000).
-define(backoff, 10).
start(Name, Proposal, Acceptors, Seed, PanelId) ->
    spawn(fun() -> init(Name, Proposal, Acceptors, Seed, PanelId) end).
init(Name, Proposal, Acceptors, Seed, PanelId) ->
    random:seed(Seed, Seed, Seed),
    Round = order:null(Name),
    round(Name, ?backoff, Round, Proposal, Acceptors, PanelId).
round(Name, Backoff, Round, Proposal, Acceptors, PanelId) ->
    % Update gui
    io:format("[Proposer ~w] set gui: Round ~w Proposal ~w~n",
    [Name, Round, Proposal]),
    PanelId ! {updateProp, "Round: "
    ++ lists:flatten(io_lib:format("~p", [Round])), "Proposal: "
    ++ lists:flatten(io_lib:format("~p", [Proposal])), Proposal},
    case ballot(Name, ..., ..., ..., PanelId) of
        {ok, Decision} ->
            io:format("[Proposer ~w] ~w decided ~w in round ~w~n",
            [Name, Acceptors, Decision, Round]),
            {ok, Decision};
        abort ->
     timer:sleep(random:uniform(Backoff)),
     Next = order:inc(...),
     round(Name, (2*Backoff), ..., Proposal, Acceptors, PanelId)
end.
ballot(Name, Round, Proposal, Acceptors, PanelId) ->
    prepare(..., ...),
    Quorum = (length(...) div 2) + 1,
    Max = order:null(),
    case collect(..., ..., ..., ...) of
        {accepted, Value} ->
            % update gui
            io:format("[Proposer ~w] set gui: Round ~w Proposal ~w~n",
            [Name, Round, Value]),
            PanelId ! {updateProp, "Round: "
            ++ lists:flatten(io_lib:format("~p", [Round])), "Proposal: "
            ++ lists:flatten(io_lib:format("~p", [Value])), Value},
            accept(..., ..., ...),
            case vote(..., ...) of
                ok ->
                    {ok, ...};
                abort ->
                    abort
            end;
        abort ->
            abort
    end.
collect(0, _, _, Proposal) ->
    {accepted, ...};
collect(N, Round, Max, Proposal) ->
    receive
        {promise, Round, _, na} ->
            collect(..., ..., ..., ...);
        {promise, Round, Voted, Value} ->
            case order:gr(..., ...) of
                true ->
                    collect(..., ..., ..., ...);
                false ->
                    collect(..., ..., ..., ...)
            end;
        {promise, _, _, _} ->
            collect(N, Round, Max, Proposal);
        {sorry, {prepare, Round}} ->
            collect(N, Round, Max, Proposal);
        {sorry, _} ->
            collect(N, Round, Max, Proposal)
    after ?timeout ->
            abort
    end.
vote(0, _) ->
    ok;
vote(N, Round) ->
    receive
        {vote, Round} ->
            vote(..., ...);
        {vote, _} ->
            vote(N, Round);
        {sorry, {accept, Round}} ->
            vote(N, Round);
        {sorry, _} ->
            vote(N, Round)
    after ?timeout ->
            abort
    end.
prepare(Round, Acceptors) ->
    Fun = fun(Acceptor) ->
        send(Acceptor, {prepare, self(), Round})
    end,
    lists:map(Fun, Acceptors).
accept(Round, Proposal, Acceptors) ->
    Fun = fun(Acceptor) ->
        send(Acceptor, {accept, self(), Round, Proposal})
    end,
    lists:map(Fun, Acceptors).
send(Name, Message) ->
    Name ! Message.

