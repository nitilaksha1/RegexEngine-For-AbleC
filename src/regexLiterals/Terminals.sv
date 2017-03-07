grammar edu:umn:cs:melt:exts:ableC:regex:regexLiterals ;

lexer class REGEX_OPER; 
lexer class REGEX_ESC submits to REGEX_OPER;

terminal Plus_t          '+' lexer classes { REGEX_OPER };
terminal Kleene_t        '*' lexer classes { REGEX_OPER };
terminal Optional_t      '?' lexer classes { REGEX_OPER };
terminal Choice_t        '|' lexer classes { REGEX_OPER };
terminal Range_t         '-' lexer classes { REGEX_OPER };
terminal RegexNot_t      '^' lexer classes { REGEX_OPER };
terminal RegexLBrack_t   '[' lexer classes { REGEX_OPER };
terminal RegexRBrack_t   ']' lexer classes { REGEX_OPER };
terminal RegexLParen_t   '(' lexer classes { REGEX_OPER };
terminal RegexRParen_t   ')' lexer classes { REGEX_OPER };
terminal RegexWildcard_t '.' lexer classes { REGEX_OPER };

terminal RegexChar_t     /./ lexer classes { REGEX_ESC }, submits to { cnc:Divide_t };


terminal EscapedChar_t /\\./ submits to { REGEX_ESC };