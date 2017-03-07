grammar edu:umn:cs:melt:exts:ableC:regex:regexLiterals ;

abstract production literalRegex
r::Regex_R ::= s::String
{
  r.regString = regexPurifyString(s);
}

abstract production regex_kleene_of
dr::Regex_UR ::= r::Regex_UR
{
  dr.regString = r.regString ++ "*";
}

abstract production regex_plus_of
dr::Regex_UR ::= r::Regex_UR
{
  dr.regString = r.regString ++ "+";
}

abstract production regex_opt_of
dr::Regex_UR ::= r::Regex_UR
{
  dr.regString = r.regString ++ "?";
}

function regexPurifyString
String ::= s::String
{
  local attribute ch :: String;
  ch = substring(0, 1, s);

  local attribute rest :: String;
  rest = substring(1, length(s), s);

  return if length(s) == 0 
	 then ""
	 else if isAlpha(ch) || isDigit(ch)
	      then ch ++ regexPurifyString(rest)
	      else "[\\" ++ ch ++ "]" ++ regexPurifyString(rest);
}
