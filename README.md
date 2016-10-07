# Syntactic Parser

---------------------------------------------------------------------------------------------------------------------
                                  Description
---------------------------------------------------------------------------------------------------------------------
This script parse literary texts, returning a list with the sentences it has. In order to achieve this, it was 
aconstructed by defining different parsers using Define Clause Grammar Formalism to deal with cases such as 
acronyms, expressions and/or titles.

---------------------------------------------------------------------------------------------------------------------
                                 Use/Installation
---------------------------------------------------------------------------------------------------------------------
Open the file in Prolog and run it.

---------------------------------------------------------------------------------------------------------------------
                                 Examples
---------------------------------------------------------------------------------------------------------------------
Example for a whole literary text:
?- sentences_from_file(S,"filename.txt").

Note: The literary texts can be extracted from the Gutenberg project (http://www.gutenberg.org/)

Example for Sentences:
?- sentences(S, "Hello Dr. ROCHET, my email is gabriela_28@gmail.com,
please reach me at I.B.T. thanks. The best web-page to buy
books is http://www.amazon.com. ", []).

Example for an Expression:
?- expressions(X, "http://www.amazon.com", []).
%  X=[104,116,116,112,58,47,47,119,119,119,46,97,109,97,122,111,110,46,99,111,109]

Example for an acronym:
%?- phrase(acronyms(A), "U.S.").
% Expected result: A = [85, 46, 83, 46]

Example for a title:
?- title(T,"Mr.",[]).
% Expected result: T = [77, 114, 46]
