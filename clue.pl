/* 
 * CPSC 312 Clue Helper
 * 
 * Keefe Law 43674100 i7w7
 * Olivia (Ningyuan) Zhang 44406106 m4s7
 */
 
% INSTRUCTIONS: Run 'clue' to start the program. Follow prompts from there on.
 
% Our program allows the user to track all game activities between players,
%   and is able to suggest a list of "best" possible moves based on a simple
%   heuristic that less commonly mentioned cards are most worth suggesting over
%   cards that have been previously/recently suggested.
% The program will automatically notify you at the main menu if an accusation is
%   guaranteed (based on the process of elimination/deduction through suggestions
%   and cards that have been shown to the player).
% We are also able to display what other players may be able to infer from their
%   interaction with the rest of the group, namely which cards our player has shown
%   that particular person.

% FEATURES:
% - After running the function, 'clue', easy-to-follow prompts will follow to guide
%     the user in setting up and using the program for the rest of the game.
% - Keep track of all the happenings in the game, including which player made what 
%     suggestions, and which players had shown a card to the person making the suggestion.
%     This includes keeping track of which player knows what about our own user.
%     There is also a list of possible envelope cards that is updated after every action.
% - Offers a list of choices for what suggestions to make next based on a simple
%     heuristic that 'newer is better'. What is meant by this is, cards that have not
%     been mentioned are prioritized over cards that are, simply because we believe
%     touching upon new data first is better than attempting to narrow down cards that
%     have already been suggested/examined.
% - Will prompt the user as soon as the program detects a guaranteed accusation.
% - Close the program with a simple 'quit' input at any point in the program.

% ********************
% User inputs/dynamic database 
% ********************

:- dynamic notes/3. % What the player knows about the game thus far
:- dynamic goal_card/1. % The cards that may be found in the envelope
:- dynamic num_players/1. % How many players are in the game
:- dynamic our_card/1. % Card(s) that you're holding 
:- dynamic our_handsize/1. % How many cards are in the player's hand
:- dynamic player/1. % The players' number
:- dynamic player_name/2. % First param is number, second is string name
:- dynamic our_player/1. % Our player's number
:- dynamic has_card/2. % Player PLAYER_ID has card X if has_card(PLAYER_ID,X) 
:- dynamic seen_card/1. % The cards that has been seen
:- dynamic might_have/2. % Player PLAYER_ID might have card X if might_have(PLAYER_ID, X)
:- dynamic player_handsize/2. % Player PLAYER_ID has X number of cards if player_handsize(PLAYER_ID, X)
:- dynamic player_suggestion/2. % Player PLAYER_ID suggested card X if player_suggestion(PLAYER_ID, X)
:- dynamic we_showed/2. % We showed card X to PLAYER_ID if we_showed(X, PLAYER_ID)
:- dynamic possible_room/1. % The rooms that we can reach



% ********************
% Initialization
% ********************

% The beginning of the program 
clue :- 
    writeln('*******************************'),
    write('Welcome to the Clue assistant! '),
    write('This program is designed to help '),
    write('you dominate the world with dark Clue powers! '), 
    writeln('Just kidding, it\'s to help you make better guesses at this game.'),
    writeln('******* Instructions *******'),
    writeln('To use this program, here are a few rules to remember:'), 
    writeln('- All strings you enter should start with lower case.'),
    writeln('- All character names, rooms, and weapon cards start with lower case.'),
    writeln('- Always add a period after every question you answer.'),
    writeln('- You may select the "see your notes" option to find suggestions.'),
    writeln('- You can enter "quit." at any time to exit the program.'),
    writeln('*******************************'),
    nl,
    writeln('Before we start, let me ask you a few questions.'),
    get_num_players,
    get_players(1),
    writeln('==== Here are the players in the game ===='),
    forall(player_name(ID, NAME),
        (write(ID),
            write(' '),
            writeln(NAME))),
    get_main_player,
    forall(player(ID),
        (get_player_handsize(ID))),
    nl,
    display_all_cards,
    nl,
    get_our_cards(1),
    writeln('Awesome! Now that we have finished setting up, let\'s get started.'),
    nl,
    menu.

% The main menu containing possible actions
menu :-
    nl,
    nl,
    writeln('********************************'),
    writeln('******* CLUE HELPER MENU *******'),
    writeln('********************************'),
    writeln('To select an option from the menu below, enter the option\'s number followed by a period.'),
    writeln('Here are your options:'),
    write_tabbed('1. See your notes.'),
    write_tabbed('2. Record a suggestion that you have made.'),
    write_tabbed('3. Record a suggestion that another player has made.'),
    write_tabbed('4. Record a card shown to you.'),
    write_tabbed('5. See suggestions for next best move.'),
    write_tabbed('6. Confirm a card is in the envolope.'),
    nl,
    writeln('To exit the program at any time, type \'quit\'.'),
    writeln('What would you like to do?'),
    suggest_accusation,

    nl,
    read_int(OPTION),
    perform_action(OPTION).
    
% When user selects option #1 from menu (See your notes)
perform_action(OPTION) :-
    OPTION = 1,
    print_my_notes,
    menu.

% When user selects option #2 from menu (Record a suggestion that you have made)
perform_action(OPTION) :-
    OPTION = 2,
    writeln('You have made a suggestion, is that right? \'yes\' or \'no\''),
    read_string(ANSWER),
    (ANSWER = 'yes',
        our_player(OUR_PLAYER),
        record_suggestion_fixed(OUR_PLAYER, 1),
        menu
        ;
        (ANSWER = 'no',
            menu
            ;
            writeln('I do not understand. Please enter \'yes\' or \'no\''),
            perform_action(OPTION)
        )
    ).
        
% When user selects option #3 from menu (Record a suggestion that another player has made)
perform_action(OPTION) :-
    OPTION = 3,
    writeln('Somebody other than you have made a suggestion, is that right? \'yes\' or \'no\''),
    read_string(ANSWER),
    (ANSWER = 'yes',
        writeln('Which player made the suggestion? Please enter their player number.'),
        display_all_players,
        read_int(PLAYER_ID),
        record_suggestion_fixed(PLAYER_ID, 1),
        menu
    ),
    (ANSWER = 'no',
        menu,
        !
    ),
    (writeln('Not a valid input, please type yes or no'),
        perform_action(OPTION)).

% When user selects option #4 from menu (Record a card shown to you)
perform_action(OPTION) :-
    OPTION = 4,
    seen_card,
    menu.

% When user selects option #5 from menu (See suggestions for next best move)
perform_action(OPTION) :-
    OPTION = 5,
    get_best_room(BEST_ROOM),
    get_next_best_move(BEST_ROOM),
    menu.

% When user selects option #6 from menu (Confirm a card is in the envolope)
perform_action(OPTION) :-
    OPTION = 6,
    confirm_card,
    menu.
    
% When user enters an invalid option from menu
perform_action(OPTION) :-
    OPTION = _,
    writeln('That is not a valid option. Please try again.'),
    menu.

% Return the next suggested move
get_next_best_move(BEST_ROOM) :-  
                            writeln('I suggest you go into the '), 
                            write('*** '), write(BEST_ROOM), writeln(' ***'),
                            writeln('and pick a weapon and a character below: '),
                            nl,
                            write('The following cards are listed based on what'),
                            write(' I believe you should suggest first, where 1 is'),
                            write(' my most preferred next move, and 3 is the least.'),
                            nl,
                            writeln('========== WEAPON CHOICES =========='),
                            get_best_weapon(_),
                            nl,
                            writeln('========== CHARACTER CHOICES =========='),
                            get_best_character(_).

% Gets the prioritized list of weapons
get_best_weapon(WEAPON) :- 
                        forall(weapon(WEAPON),
                            ((goal_card(WEAPON) ->
                                (not(might_have(_,WEAPON)) ->
                                    (not(player_suggestion(_, WEAPON)) ->
                                        write('1 - '), writeln(WEAPON)
                                        ;
                                        write('2 - '), writeln(WEAPON)
                                    )
                                    ;
                                    write('3 - '), writeln(WEAPON)
                                    )             
                                ;
                                write('Already confirmed weapon - '), writeln(WEAPON))
                            )
                        ).

% Gets the prioritized list of characters
get_best_character(CHARACTER) :- 
                        forall(character(CHARACTER),
                            ((goal_card(CHARACTER) ->
                                (not(might_have(_,CHARACTER)) ->
                                    (not(player_suggestion(_, CHARACTER)) ->
                                        write('1 - '), writeln(CHARACTER)
                                        ;
                                        write('2 - '), writeln(CHARACTER)
                                    )
                                    ;
                                    write('3 - '), writeln(CHARACTER)
                                    )             
                                ;
                                write('Already confirmed character - '), writeln(CHARACTER))
                            )
                        ).

% Get one of the best rooms to suggest
% A best room is a room that is reachable and have not been mentioned.
% If none exist, then just pick a reachable room.
get_best_room(BEST_ROOM) :- retractall(possible_room(_)),
                            get_possible_rooms, 
                            (possible_room(ROOM), goal_card(ROOM) ->
                              BEST_ROOM = ROOM
                              ;
                              possible_room(ROOM2),
                              BEST_ROOM = ROOM2
                             ).      
    
% Gets the rooms that the player can reach this turn.
get_possible_rooms :- writeln('Which rooms can you travel to this turn? Type \'none\' if there is no more'),
                      read_string(ROOM),
                      (ROOM = 'none' ->
                        !
                        ;
                        (room(ROOM) ->
                            assert(possible_room(ROOM)),
                            get_possible_rooms
                            ;
                            writeln('Invalid room, try again.'),
                            get_possible_rooms
                        )
                      ).


                    

% Sets the number of players in the database
get_num_players :-
    writeln('How many people are playing?'),
    read_int(NUM),
    (NUM >= 3, NUM =< 6 ->
        retractall(num_players(_)),
        assert(num_players(NUM))
        ;
        writeln('This game allows minimum of 3 players and maximum of 6, try again!'),
        get_num_players
    ).

% Defines who is using this assistant program
get_main_player :-
    writeln('What is your player number?'),
    read_int(ID),
    num_players(MAX),
    player_name(ID, NAME),
    (ID >= 1, ID =< MAX ->
        assert(our_player(ID)), nl,
        write('Oh I see! You must be '),
        write(NAME),
        writeln('.'),
        !;
        write('Invalid player number, there are only '),
        write(MAX),
        writeln(' players!'),
        get_main_player
    ).

% Get the number of players involved in this game
get_players(ID) :- num_players(MAX), ID > MAX, !.
get_players(ID) :- 
    writeln('Who is playing this game? Insert their names individually and in order,'),
    writeln(' starting with whoever goes first.'),
    read_string(NAME),
    add_player(ID),
    add_player_name(ID, NAME),
    incr(ID, Y),
    get_players(Y).
    
% Add a player to the database
add_player(ID) :-
    retractall(player(ID)),
    assert(player(ID)).
    
% Add a name to a player
add_player_name(ID, NAME) :-
    retractall(player_name(ID, _)),
    assert(player_name(ID, NAME)).

% Gets how many cards are in the player's hand 
get_player_handsize(PLAYER_ID):-
    (player_name(PLAYER_ID, NAME),
        write('How many cards are in '),
        our_player(OUR_PLAYER),
        (PLAYER_ID = OUR_PLAYER,
            writeln('your hand?'),
            read_int(X),
            assert(our_handsize(X))
            ;
            write(NAME),
            writeln('\'s hand?'),
            read_int(X),
            assert(player_handsize(PLAYER_ID, X)))).
    
% Gets which cards are in our hand
get_our_cards(NUM) :- our_handsize(MAX), NUM > MAX, !. 
get_our_cards(NUM) :-
    writeln('Which cards are you holding? Enter their name one by one.'),
    read_string(CARD),
    (valid_card(CARD), 
        assert(our_card(CARD)),
        our_player(ID),                 % Find our player and add to notes
        assert(notes(ID, ID, CARD)),    % Find our player and add to notes
        retract(goal_card(CARD)),
        incr(NUM, Y),
        get_our_cards(Y), !
        ;
        writeln('This is not a valid card, please enter again. All card names are lower case.'),
        get_our_cards(NUM)).
    
    

% ********************
% Core features 
% ********************

% Confirms that a card is definitely in the envolope, eliminates all other cards from unseen
confirm_card :- writeln('You can be certain that a card is in the envolope, is that right? yes or no.'),
                read_string(ANSWER),
                (ANSWER = 'yes' ->
                    writeln('Which card do you want to confirm?'),
                    display_unseen_all,
                    read_string(CARD),
                    (goal_card(CARD),
                        confirm_helper(CARD)
                        ;
                        writeln('Invalid card, please try again'),
                        confirm_card
                    )
                    ;
                 (ANSWER = 'no' ->
                    menu
                    ;
                    writeln('Invalid input, please answer yes or no.'),
                    confirm_card
                 )
                ).

% Helper to eliminate all other cards of the same type from goal_card
confirm_helper(CARD) :- unseen_character(CARD),
                        forall(goal_card(X),
                            (not(X = CARD), character(X)->
                                retract(goal_card(X))
                                ;
                                true
                            )
                        ), !.

confirm_helper(CARD) :- unseen_room(CARD),
                        forall(goal_card(X),
                            (not(X = CARD), room(X)->
                                retract(goal_card(X))
                                ;
                                true
                            )
                        ), !.

confirm_helper(CARD) :- unseen_weapon(CARD),
                        forall(goal_card(X),
                            (not(X = CARD), weapon(X)->
                                retract(goal_card(X))
                                ;
                                true
                            )
                        ), !.                  

% Prints out our player's notes
print_my_notes :-
    our_player(ID),
    print_notes(ID).
    
% Prints out a player's notes of all data collected thus far
print_notes(PLAYER) :-
    nl,
    writeln('====== NOTES ======'),
    findall(OTHER, (notes(PLAYER, OTHER, CARD)), PLAYERS),
    sort(PLAYERS, SORTED_PLAYERS),
    foreach((member(NUM, SORTED_PLAYERS), player_name(NUM, NAME)),
        forall(notes(PLAYER, NUM, CARD), 
            (
            player_name(PLAYER, PLAYER_NAME),
            write(PLAYER_NAME),
            write(' knows that '),
            write(NAME),
            write(' has '),
            writeln(CARD)))
    ),
    nl,
    writeln('==== OTHER PLAYERS\' KNOWLEDGE ===='),
    our_player(OUR_PLAYER),
    forall(notes(A, B, C),
            display_others_notes(A,B,C)
        ),
    nl,
    writeln('====== POSSIBILITIES ======'),
    forall(might_have(ID, CARD),
        (player_name(ID, NAME),
        write(NAME), write(' might have '), writeln(CARD))),
    nl,
    writeln('===== UNKNOWNS ====='),
    display_unseen_all,
    nl,
    writeln('===== END OF NOTES =====').

% Makes note of who might have which card
might_have_card :-
    write('Would you like to note that someone might be holding a card?'),
    writeln(' Enter \'yes\' or \'no\'. '),
    read_string(INPUT),
    (INPUT = 'no', 
        !;
        INPUT = 'yes',
        writeln('Please enter their player number: '),
        display_all_players,
        read_int(ID),
        (player(ID)
            ; 
            writeln('The player you entered is not in this game, please enter a player number.'),
            might_have_card),
        writeln('Name the card that they might have: '),
        read_string(CARD),
        (valid_card(CARD)
            ;
            writeln('Invalid card! All card names start with lower case.'),
            might_have_card),
        assert(might_have(ID, CARD)),
        might_have_card).

% Confirms player has seen that another player owns the given card
seen_card :-
    writeln('Has someone shown you a card? Enter \'yes\' or \'no\'.'),
    read_string(RESULT),
    (RESULT = 'no',
        !
        ;
        RESULT = 'yes',
        writeln('Who has the card? Please enter their player number: '),
        display_all_players,
        read_int(ID),
        (player(ID), % if this is a valid player name
            writeln('Which card did they show you?'),
            read_string(CARD),
            (valid_card(CARD),
                assert(has_card(ID, CARD)),
                retractall(might_have(_, CARD)),
                retract(goal_card(CARD)),
                our_player(X),
                assert(notes(X, ID, CARD))
                ;
                writeln('This card you entered is not a valid card! All card names begin with lower case, try again.'),
                seen_card)
            ;
            writeln('This player you entered is not in the game! please try again.'),
            seen_card)
        ;
        writeln('Sorry I didn not understand you, please try again'),
        seen_card
        ).

% Record a player's suggestion
record_suggestion_fixed(PLAYER_ID, NUM) :-
        writeln('Which cards ended up being suggested? Enter them one by one.'),
        read_string(CARD),
        
        (valid_card(CARD) ->
            assert(player_suggestion(PLAYER_ID, CARD))
            ;
            writeln('The card you entered is not a valid card, try again!'),
            record_suggestion_fixed(PLAYER_ID, NUM)
        ),
        (NUM < 3 ->
            incr(NUM, Y),
            record_suggestion_fixed(PLAYER_ID, Y)
            ;
            record_probability(PLAYER_ID),
            !
        ).

% Inserts suggestions 
record_probability(PLAYER_ID) :- our_player(PLAYER_ID),
            seen_card.


record_probability(PLAYER_ID) :-
            player_name(PLAYER_ID, NAME),
            write('Did anyone showed '), write(NAME), writeln(' a card? \'yes\' or \'no\''),
            read_string(ANSWER),
            (   ANSWER = 'no', 
                forall(player_suggestion(PLAYER_ID, CARD),
                    add_possibility(PLAYER_ID, CARD)
                    ),
                !
                ;
                (ANSWER = 'yes', 
                has_shown_card(PLAYER_ID)
                ;
                ('Not a valid input, please say yes or no.'),
                record_probability(PLAYER_ID)
                )
            ). 

% Asks who has shown a card to player with the given PLAYER_ID 
has_shown_card(PLAYER_ID) :-
            player_name(PLAYER_ID, NAME),
            write('Who has shown '), write(NAME), writeln(' the card? Please enter their player number.'),
            display_all_players,
            read_int(REVEALER),
            (player(REVEALER), 
                show_card(REVEALER, PLAYER_ID)
                 ;
                 write('The player '), write(REVEALER), writeln(' is not in the game, try again'),
                 has_shown_card(PLAYER_ID)).
                
% If we showed the player a card, take note that they know we have the card
show_card(REVEALER, PLAYER_ID) :- our_player(REVEALER),
                                writeln('You have shown a card, which card did you show?'),
                                read_string(CARD),
                                assert(notes(PLAYER_ID, REVEALER, CARD)),!.
 
% If another player showed a card, take note that they might have the card                 
show_card(REVEALER, PLAYER_ID) :- player(REVEALER),
                                  forall(player_suggestion(PLAYER_ID, CARD), 
                                        add_possibility(REVEALER, CARD)
                                        ), !.   
% not a valid player number, do it again
show_card(REVEALER, PLAYER_ID) :- not(player(REVEALER)),
                                    writeln('The player is not in this game, please try again'),
                                    read_int(NEW_REVEAL),
                                    show_card(NEW_REVEAL, PLAYER_ID), !.                                  

% If we already know the card is ours, do nothing
add_possibility(_, CARD) :- our_card(CARD),!.

% If we cannot know for sure, take note that they might have the card
add_possibility(PLAYER_ID, CARD) :- not(our_card(CARD)),
                                    (goal_card(CARD),
                                        not(might_have(PLAYER_ID, CARD)) ->
                                            assert(might_have(PLAYER_ID, CARD))
                                            ;
                                        !).

% Tell player to go for the accusation
suggest_accusation :-
    aggregate_all(count, goal_card(CARD), COUNT_GOAL),
    (COUNT_GOAL = 3, 
        writeln('=== There appears to be an answer! I suggest you make your accusation ==='),
        forall(goal_card(CARD),
            (writeln(CARD)))
        ;
        !).

% NOT USED==================================
% Take notes on which player might own which card
%take_note(PLAYER_ID) :- 
%        seen_card,
%        might_have_card,
%        player_name(PLAYER_ID, NAME),
%        write('Player '),
%        write(NAME),
%        writeln('\'s turn ends').
% NOT USED==================================

% ********************
% Helpers to display available cards
% ********************

% displays our cards
display_our_cards :- 
    writeln('===== Cards you hold ====='),
    write('['),
    forall(our_card(C),
        (write(C), write(','))),
    writeln(']').

% display all the unseen cards
display_unseen_all :-
    display_unseen_characters,
    nl,
    display_unseen_rooms,
    nl,
    display_unseen_weapons,
    nl.

% display the characters that have not yet been seen
display_unseen_characters :- 
    writeln('===== Unseen Characters ====='),
    write('['),
    forall(unseen_character(X), 
        (write(X), write(','))),
    writeln(']').

% all the rooms that have not been seen
display_unseen_rooms :- 
    writeln('===== Unseen Rooms ====='),
    write('['),
    forall(unseen_room(X), 
        (write(X), write(','))),
    writeln(']').

% all the weapons that have not been seen
display_unseen_weapons :- 
    writeln('===== Unseen Weapons ====='),
    write('['),
    forall(unseen_weapon(X), 
        (write(X), write(','))),
    writeln(']').

% display all valid cards 
display_all_cards :-
    display_all_characters,
    display_all_rooms,
    display_all_weapons.


% displays all characters
display_all_characters :-
    writeln('==== All Characters ===='),
    write('['),
    forall(character(X), 
        (write(X),
            write(','))),
    writeln(']').


% display all rooms 
display_all_rooms :-
    writeln('====== All Rooms ====='),
    write('['),
    forall(room(ROOM), 
        (write(ROOM),
            write(','))),
    writeln(']').

% display all weapons 
display_all_weapons :-
    writeln('====== All Weapons ====='),
    write('['),
    forall(weapon(WEAPON), 
        (write(WEAPON),
            write(','))),
    writeln(']').

% display all players 
display_all_players :-
    writeln('====== All Players ====='),
    write('['),
    forall(player_name(ID, NAME), 
        (write(' '), write(ID), write('.'), write(NAME),
            write(','))),
    writeln(']').

% display all uncertain possiblities 
display_possiblities :-
    forall(player(ID),
        (might_have(ID, CARD),

            write(ID),
            write(' might have '),
            write(CARD)
        )

    ),
    true.

% displays all the suggestions that were made so far
display_suggestions :- 
    forall(player_suggestion(PLAYER_ID, CARD),
     
            (player_name(PLAYER_ID, NAME),
                write(NAME), 
            write(' suggested '), 
            writeln(CARD))   
        
    ).

% Displays other players' notes
display_others_notes(P1, _, _) :- our_player(P1), !.
display_others_notes(P1, P2, CARD) :- player_name(P1, P1NAME),
                                      player_name(P2, P2NAME),
                                      write(P1NAME), 
                                      write(' knows that '), 
                                      write(P2NAME), 
                                      write(' has '), 
                                      writeln(CARD).

% ********************
% Static Database
% ********************

% Valid cards in the game
goal_card('knife').
goal_card('candlestick').
goal_card('revolver').
goal_card('rope').
goal_card('leadpipe').
goal_card('wrench').
goal_card('kitchen').
goal_card('ballroom').
goal_card('conservatory').
goal_card('billiard').
goal_card('library').
goal_card('study').
goal_card('hall').
goal_card('lounge').
goal_card('dining').
goal_card('mustard').
goal_card('scarlet').
goal_card('plum').
goal_card('green').
goal_card('white').
goal_card('peacock').

% All the valid characters in this game
character('mustard').
character('scarlet').
character('plum').
character('green').
character('white').
character('peacock').

% All the valid rooms in the game
room('kitchen').
room('ballroom').
room('conservatory').
room('billiard').
room('library').
room('study').
room('hall').
room('lounge').
room('dining').

% All the valid weapons in the game
weapon('knife').
weapon('candlestick').
weapon('revolver').
weapon('rope').
weapon('leadpipe').
weapon('wrench').

% A card is valid if it is one of either weapon, room or character
valid_card(CARD) :- weapon(CARD), !.
valid_card(CARD) :- room(CARD), !.
valid_card(CARD) :- character(CARD), !.

% cards that have not yet been seen.
unseen_character(X) :- character(X), goal_card(X).
unseen_room(X) :- room(X), goal_card(X).
unseen_weapon(X) :- weapon(X), goal_card(X).


% ********************
% Arithmetic helpers
% ********************

% Decrement by one
decr(X,Y) :- 
    Y is X - 1.
    
% Increment by one
incr(X,Y) :-
    Y is X + 1.
    


% ********************
% I/O helpers
% ********************

% Prints a message to the screen tabbed 4 spaces with a new line
write_tabbed(MSG) :-
    tab(4), write(MSG), nl.

% Reads an integer, if the read fails then return with -1
read_int(INT) :-
    read_input(IN, -1),
    (integer(IN) ->
        INT = IN;
        writeln('Please enter an integer'), 
        read_int(INT)).
    
% Reads a string, if the read fails then return with 'NULL'
read_string(STR) :-
    read_input(IN, 'NULL'),
    (atom(IN) ->
        STR = IN;
        writeln('Please enter a string'),
        read_string(STR)).
        
% Reads input from standard IO, if ctrl+d is pressed the program goes back to run
read_input(IN,FAIL) :-
    write('>> '),
    catch(read(IN), _, IN = FAIL),
    (IN = 'end_of_file' ->
        nl, run;
        true
    ),
    (IN = 'quit' ->
        nl, halt;
        true
    ).
