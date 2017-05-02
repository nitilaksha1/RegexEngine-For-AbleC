-- Uncomment to get DFA from regex
-- This has not been integrated with ableC

{-
grammar artifact;

import edu:umn:cs:melt:ableC:concretesyntax as cst;
import edu:umn:cs:melt:ableC:drivers:compile;
import edu:umn:cs:melt:exts:ableC:regex:src:concretesyntax as cn;
import edu:umn:cs:melt:exts:ableC:regex:src:abstractsyntax as an;

parser extendedParser :: cn:Root_c {
  edu:umn:cs:melt:ableC:concretesyntax;
  edu:umn:cs:melt:exts:ableC:regex;
} 

function main
IOVal<Integer> ::= args::[String] io_in::IO
{
  local filename :: String = head(args);
  local fileExists::IOVal<Boolean> = isFile(filename, io_in);
  local text::IOVal<String> = readFile(filename,fileExists.io);
  local result::ParseResult<cn:Root_c> = extendedParser(text.iovalue, filename);

  local attribute r_cst :: cn:Root_c ;
  r_cst = result.parseTree ;

  local attribute r_ast :: an:ROOT ;
  r_ast = r_cst.cn:root;

  local attribute print_success :: IO;
  print_success = 
    print(
           "\n\n" ++
           r_ast.an:pp
           , text.io );

  --return driver(args, io_in, extendedParser);
  return
     if   ! fileExists.iovalue
     then ioval(print("File not found.\n", fileExists.io), 1)
     else
     if   ! result.parseSuccess
     then ioval(print("Parse error:\n" ++ result.parseErrors ++ "\n", text.io), 2)
     else ioval(print_success, 0);
}
-}

-- Integration with ableC start

grammar artifact;

import edu:umn:cs:melt:ableC:concretesyntax as cst;
import edu:umn:cs:melt:ableC:drivers:compile;
import edu:umn:cs:melt:exts:ableC:regex:src:concretesyntax as cn;
import edu:umn:cs:melt:exts:ableC:regex:src:abstractsyntax as an;

parser extendedParser :: cst:Root
{
  edu:umn:cs:melt:ableC:concretesyntax;
  edu:umn:cs:melt:exts:ableC:regex;
} 

function main
IOVal<Integer> ::= args::[String] io_in::IO
{
  return driver(args, io_in, extendedParser);
}

-- Integration with ableC end