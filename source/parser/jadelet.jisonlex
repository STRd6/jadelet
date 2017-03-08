id                          [_a-zA-Z][-_a-zA-Z0-9]*
NameStartChar               ":" | [A-Z] | "_" | [a-z] //| [\u00C0-\u00D6] | [\u00D8-\u00F6] | [\u00F8-\u02FF] | [\u0370-\u037D] | [\u037F-\u1FFF] | [\u200C-\u200D] | [\u2070-\u218F] | [\u2C00-\u2FEF] | [\u3001-\uD7FF] | [\uF900-\uFDCF] | [\uFDF0-\uFFFD] | [\u10000-\uEFFFF]
NameChar                    {NameStartChar} | "-" | [0-9] //| \u00B7 | [\u0300-\u036F] | [\u203F-\u2040]
Name                        {NameStartChar}{NameChar}*(?!\-)
Indent                      "  " | "\t"

/* states */
%x parentheses_attributes
%x value
%x filter

%%

<parentheses_attributes>[ \t]+    return 'SEPARATOR';
<parentheses_attributes>")"       this.popState(); return 'RIGHT_PARENTHESIS';
<parentheses_attributes>{id}      return 'ATTRIBUTE';
<parentheses_attributes>"="       this.begin('value'); return 'EQUAL';
<parentheses_attributes>\@{id}    return 'AT_ATTRIBUTE';

<value>\"(\\.|[^\\"])*\"          this.popState(); return 'ATTRIBUTE_VALUE';
<value>\'(\\.|[^\\'])*\'          this.popState(); return 'ATTRIBUTE_VALUE';
<value>[^ \t\)]*                  this.popState(); return 'ATTRIBUTE_VALUE';

<filter>(\n|<<EOF>>)  yy.indent = 0; this.popState(); return 'NEWLINE';
<filter>[^\n]*        return 'FILTER_LINE';

\s*(\n|<<EOF>>)       yy.indent = 0; return 'NEWLINE';
{Indent}              yy.indent += 1; if(yy.indent > yy.filterIndent){this.begin('filter'); }; return 'INDENT';
"("                   this.begin("parentheses_attributes"); return 'LEFT_PARENTHESIS';
"//".*                yytext = yytext.substring(2); return 'COMMENT';
\:{id}                yy.filterIndent = yy.indent; yytext = yytext.substring(1); return 'FILTER';
\#{Name}              yytext = yytext.substring(1); return 'ID';
\.{Name}              yytext = yytext.substring(1); return 'CLASS';
{Name}                return 'TAG';
"=".*                 yytext = yytext.substring(1).trim(); return 'BUFFERED_CODE';
"-".*                 yytext = yytext.substring(1).trim(); return 'UNBUFFERED_CODE';
.*                    yytext = yytext.trim(); return 'TEXT';
