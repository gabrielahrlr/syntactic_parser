 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                    Syntactic Parser                   
 %                @autor: Gabriela HERNANDEZ               
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %%%%%%%%%%%%%%%%%%%% DCG Definitions %%%%%%%%%%%%%%%%%%%%%%%
 % Define Clause Grammar (DCG)

% uppercase letters without accent
upper_case(L) --> [L], {65 =< L, L =< 90, !}.
% lowercase letters without accent
lower_case(L) --> [L], {97 =< L, L =< 122, !}.
% accented letters

%DOT
dot(P) --> [P], {P == 46,!}.
blank(B) --> [B], {B =< 32,!}.
% Letter upper case and lower case
letters(L) -->  upper_case(L),!.
letters(L) -->  lower_case(L),!.

%Numbers
numbers(D) --> [D], { 48 =< D, D =< 57, !}.
control_character(P) --> [P], {member(P,[95,45,43,64,47,58,44,39,34,40,41,91,93])}.

%Other symbols
other(S) --> [S], {member(S, [95,45,43,64,47,58,44,39,34,40,41,91,93,46,33,63,59,58,39,147,145,133,-1, 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32])}, !, other(S).
other(S) --> [S],!.


 %%%%%%%%%%%%%%%%%%%%   Read File Section  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicate read_file(F,L)/2, reads a text file F, and returns
% a list L of ASCII codes composing it.

read_file(F, L) :- open(F, read, Channel),read_list(Channel, L), close(Channel).

read_list(Channel, [C | L]) :- get0(Channel, C),C \== -1,!,read_list(Channel, L).
read_list(_, [-1]).
%For testing:
%read_list("filename.txt", L).


%%%%%%%%%%%%%%%%%%%%   Title Parser using DCG Formalism  %%%%%%%%%%%%%%%%%%%%%%%%%%%
% DCG Formalism was used for building this parser. Syntactical Parser
% title(T, Inflow,Outflow),identifies the following titltes ended by a
% dot,where Inflow is the input text, Outflow the output flow and T the
% list of ASCII codes that identify the title. Dictionary of titles:
title(Title) --> "Dr.",{Title="Dr."}.
title(Title) --> "M.",{Title="M."}.
title(Title) --> "Ms.",{Title="Ms."}.
title(Title) --> "Prof.", {Title="Prof."}.
title(Title) --> "Mr.", {Title="Mr."}.
title(Title) --> "Dir.", {Title="Dir."}.
title(Title) --> "Pr.", {Title="Pr."}.

%For  testing, use either:
%?- title(T,"Mr.",[]).
% Expected result: T = [77, 114, 46]
% or
% ?- phrase(title(T),"Dr.").
%T = [68, 114, 46] .

%%%%%%%%%%%%%%%%%%%%   Title Parser using PROLOG rules   %%%%%%%%%%%%%%%%%%%%%%%%
% The same approach than in the former case, but using PROLOG rules, instead of
% DCG formalism.

title_prolog(T, In, []):- member(In,["Dr.","M.","Ms.", "Prof.",
				      "Mr.", "Dir.","Pr."]), T=In,!.
%For testing:
% ?- title_prolog(T,"Prof.",[]).
% Expected result: T = [80, 114, 111, 102, 46].


%%%%%%%%%%%%%%%%%%%%   Acronym Parser   %%%%%%%%%%%%%%%%%%%%%%%%
% Syntactic parse forr acronyms(A, InFlow, OutFlow), identifies an
% acronym (e.g. I.T.), defined by using DCG formalism.

acronym_def([UC,D]) --> upper_case(UC), dot(D).
acronyms(L) --> acronym_def(A), acronyms(R), {append(A,R,L)}.
acronyms(L) --> acronym_def(L).

%For testing use, either:
%?- acronyms(A, "I.T.",[]).
% Expected result: A = [73, 46, 84, 46]
% Or:
%?- phrase(acronyms(A), "U.S.A.").
% Expected result: A = [85, 46, 83, 46, 65, 46]

%Syntactical parser acronyms

%%%%%%%%%%%%%%%%%%%%   Expressions Parser  %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Syntactic parser for expression(E,InFlow,OutFlow) that identifies
% expressions composed of a sequence of letters, numbers or control
% characters — like “:”, “/”, “@” or “#” — and containing a dot,
% e.g. an  email address or an URL.

characters(P) --> letters(P),{!}.
characters(P) --> numbers(P),{!}.
characters(P) --> control_character(P),{!}.
characters(P) --> other(P),{!}.

%Find all the characters before and after
expression_loop(A) --> characters(Ex), expression_loop(Rest), {flatten([Ex,Rest],A)}.
expression_loop(Ex) --> characters(Ex).

%Expression Definition.
expression_def([C,[D],F]) -->  expression_loop(C), dot(D), expression_loop(F).

expressions(A)  --> expression_def([C,[D],F]), expressions(Rest),
	{append([C,[D],F,Rest],A)},{!}.
expressions(A) --> expression_def(Ex), {append(Ex,A)}.

%For testing use, either:
%  ?- expressions(X, "http://www.amazon.com", []).
%  X=[104,116,116,112,58,47,47,119,119,119,46,97,109,97,122,111,110,46,99,111,109]
%  OR ?- phrase(expressions(X), "gabriela_89@gmail.com"), print(X).
%  X=[103,97,98,114,105,101,108,97,95,56,57,64,103,109,97,105,108,46,99,111,109]
%


%%%%%%%%%%%%%%%%%%%%  Sentences Parser  %%%%%%%%%%%%%%%%%%%%%%%%
% syntactic parser for sentence(S, InF low, OutF low) that identifies a
% sequence of characters ended by a strong punctuation, i.e. “.”, “!”,
% “?” or “...”, followed by a white character, a carriage return, a quote
% (single or double) or an end of file.

strong_punctuation(B) --> [B],{member(B,[46,33,63,59,133])}.
end_punctuation(B) --> [B],{B =< 32}.
end_punctuation(X) --> [X], {member(X, [39,147,145,-1,34])}.

end_of_a_sentence([E|Rest]) --> end_punctuation(E), end_of_a_sentence(Rest).
end_of_a_sentence(E) --> end_punctuation(E),!.

%Words Dictionary:
word(T) --> title(T),!.
word(A) --> acronyms(A),!.
word(E) --> expressions(E),!.
word(C) --> characters(C),!.


% Set of words definition:
words(A) --> blank(B), {!}, words(Words),{flatten([[B],Words],A)}.
words(A) --> word(F), words(Words),{flatten([F,Words],A)}.
words(X) --> word(X).


%Sentence Definition
sentence_definition(S) --> words(A), strong_punctuation(B),
	end_of_a_sentence(_), {append(A,[B],S)}.

% Set ofSentences
sentences([[L]|Ls]) --> sentence_definition(S),{name(L,S)},sentences(Ls).
sentences([[A]]) --> sentence_definition(B), {name(A,B)}.

%For testing, use either:
% ?- sentences(S, "Hello Dr. ROCHET, my email is gabriela_28@gmail.com,
% please reach me at I.B.T. at mid-day, thanks. The best web-page to buy
% books is http://www.amazon.com. ", []).

% S = [['Hello Dr. ROCHET, my email is gabriela_28@gmail.com, please
% reach me at I.B.T. at mid-day, thanks.'], ['The best web-page to buy
% books is http://www.amazon.com.']] .
% OR,
% ?- phrase(sentences(S), "Hello Dr. ROCHET, my email is gabriela_28@gmail.com,
% please reach me at I.B.T. at mid-day, thanks. The best web-page to buy
% books is http://www.amazon.com. ").

% S = [['Hello Dr. ROCHET, my email is gabriela_28@gmail.com, please
% reach me at I.B.T. at mid-day, thanks.'], ['The best web-page to buy
% books is http://www.amazon.com.']] .


%%%%%%%%%%%%%%%%%%%%   Syntactical Parser for literay texts %%%%%%%%%%%%%%%%%%%%%%%%
% program sentences_file(S,F), is a program which reads
% a literary text F, and L contains the list of sentences that
% the text contains.
sentences_file(S,F) :- read_file(F,L), sentences(S,L,_),!.

%For testing:
% ?- sentences_from_file(S,"filename.txt").
% The literary texts can be extracted from the Gutenberg project (http://www.gutenberg.org/)

