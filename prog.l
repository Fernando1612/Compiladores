pal_res cadena|devuelve|entero|flotante|hacer|mientras|nulo|para|si|sino|vacio
op_arit sum|res|mult|div|mod|pow
op_asig i_i|M_i|m_i|a_i|d_i|p_i|A_i|P_i|B_i
op_rela <M>|<m>|<=>|<M=>|<m=>|<$=>
const_num_real ([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)
const_num_ent 0[0-7]*|0[xX][a-fA-F0-9]+|[1-9][0-9]*
ident ([a-zA-Z_][a-zA-Z0-9_]*|[0-9]+(_|[a-zA-Z])+[0-9]*)
sim_especial [\.:\(\){}]
const_cadenas ^\".{0,38}\"$

%%
{pal_res} {printf("%s es una palabra reservada\n",yytext);}
{op_arit} {printf("%s es un operador aritmetico\n",yytext);}
{op_asig} {printf("%s es un operador de asignacion\n",yytext);}
{op_rela} {printf("%s es un operador relacional\n",yytext);}
{const_num_real} {printf("%s es una constante numerica real\n",yytext);}
{const_num_ent} {printf("%s es una constante numerica entera\n",yytext);}
{ident} {printf("%s es un identificador\n",yytext);}
{sim_especial} {printf("%s es un simbolo especial\n",yytext);}
{const_cadenas} {printf("%s es una constante de cadena\n",yytext);}
%%

void main(){
    yylex();
}