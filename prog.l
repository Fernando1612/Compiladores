%{
#include <string.h>
void crear_token();
void crear_token_iden();
void crear_token_cadena();
void crear_token_num_real();
int val_token();
int cont_ident = 0;
int cont_num_real = 0;
int cont_cadena = 0;

FILE *archSal;
%}

ILEN ([Uu](L|l|LL|ll)?|(L|l|LL|ll)[Uu]?)
pal_res cadena|devuelve|entero|flotante|hacer|mientras|nulo|para|si|sino|vacio
op_arit sum|res|mult|div|mod|pow
op_asig i_i|M_i|m_i|a_i|d_i|p_i|A_i|P_i|B_i
op_rela <M>|<m>|<=>|<M=>|<m=>|<$=>
const_num_real ([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)
const_num_ent_oct ^0[0-7]*{ILEN}?$
const_num_ent_dec ^[1-9][0-9]*{ILEN}?$
const_num_ent_hex ^0[Xx][0-9a-fA-F]+{ILEN}?$
ident ([a-zA-Z_][a-zA-Z_0-9]*|[0-9]+(_|[a-zA-Z])+[0-9]*)
sim_especial [\.:\(\){}]
const_cadenas ^\"(?:[^"\\]|\\.){0,38}\"$

%%
{pal_res} {crear_token(4,yytext);}
{op_arit} {crear_token(6,yytext);}
{op_asig} {crear_token(3,yytext);}
{op_rela} {crear_token(2,yytext);}
{const_num_real} {crear_token_num_real();}
{const_num_ent_oct} {fprintf(archSal,"(Clase 1, Valor %s)\n",yytext);}
{const_num_ent_dec} {fprintf(archSal,"(Clase 1, Valor %s)\n",yytext);}
{const_num_ent_hex} {fprintf(archSal,"(Clase 1, Valor %s)\n",yytext);}
{ident} {crear_token_iden();}
{sim_especial} {fprintf(archSal,"(Clase 5, Valor %s)\n",yytext);}
{const_cadenas} {crear_token_cadena();}
%%

void crear_token(int c,char *s){
    fprintf(archSal,"(Clase %d, Valor %d)\n", c,val_token(s));    
}

void crear_token_iden(){
    fprintf(archSal,"(Clase 0, Valor %d)\n",cont_ident);
    cont_ident = cont_ident + 1;  
}

void crear_token_cadena(){
    fprintf(archSal,"(Clase 7, Valor %d)\n",cont_cadena);
    cont_cadena = cont_cadena + 1;
}

void crear_token_num_real(){
    fprintf(archSal,"(Clase 8, Valor %d)\n",cont_num_real);
    cont_num_real = cont_num_real + 1;
}

int val_token(char *s){
    if(strcmp(s,"cadena") == 0 || strcmp(s,"<M>") == 0 || strcmp(s,"i_i") == 0 || strcmp(s,"sum") == 0){
        return 0;
    }else if(strcmp(s,"devuelve") == 0|| strcmp(s,"<m>") == 0 || strcmp(s,"M_i") == 0 || strcmp(s,"res") == 0){
        return 1;
    }else if(strcmp(s,"entero") == 0 || strcmp(s,"<=>") == 0 || strcmp(s,"m_i") == 0 || strcmp(s,"mult") == 0){
        return 2;
    }else if(strcmp(s,"flotante") == 0 || strcmp(s,"<M=>") == 0 || strcmp(s,"a_i") == 0 || strcmp(s,"div") == 0){
        return 3;
    }else if(strcmp(s,"hacer") == 0 || strcmp(s,"<m=>") == 0 || strcmp(s,"d_i") == 0 || strcmp(s,"mod") == 0){
        return 4;
    }else if(strcmp(s,"mientras") == 0 || strcmp(s,"<$=>") == 0 || strcmp(s,"p_i") == 0 || strcmp(s,"pow") == 0){
        return 5;  
    }else if(strcmp(s,"nulo") == 0 || strcmp(s,"A_i") == 0){
        return 6;  
    }else if(strcmp(s,"para") == 0 || strcmp(s,"P_i") == 0){
        return 7;
    }else if(strcmp(s,"si") == 0 || strcmp(s,"B_i") == 0){
        return 8;
    }else if(strcmp(s,"sino") == 0){
        return 9;
    }else if(strcmp(s,"vacio") == 0){
        return 10;
    }
}

void main(int argc, char *argv[]){
    yyin = fopen(argv[1],"r");
    archSal = fopen("salida.txt","w");
    yylex();
    fclose(archSal);
}

