module type NFA =
  sig

  type nfaStartState = int
  type nfaFinalstates = int list
  type transition = int * char * int

  type nfa = nfaStates * nfaAlphabets * nfaStartState * nfaFinalstates * transition list


  val make_nfa : nfaStartState -> nfaFinalstates -> transition list -> nfa

end

module type DFA =
  sig

  type dfaStartState = int
  type dfaFinalstates = int list
  type transition = int * char * int

  type dfa = dfaStates * dfaAlphabets * dfaStartState * dfaFinalstates * transition list


  val make_dfa : dfaStartState -> dfaFinalstates -> transition list -> dfa

end
