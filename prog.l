%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
void crear_token();
void crear_token_iden();
void crear_token_cadena();
void crear_token_num_real();
int val_token();
int cont_ident = 0;
int cont_num_real = 0;
int cont_cadena = 0;
int contador_lista = 0;
int posicion_simbolo_repetida = 0;
int pos_atomo = 0;
char sim_entero[10];
char c;
char* atomos = NULL;
char atomoActual();
void insertarNodo(int a,char *s);
int buscarNodo(char *s);
int check_octal(char *s);
void crear_token_num(char *s);
void escribir_atomo(char *s);
void leerCadena();

void tipo();
void L();
void D();
void R();
void S();
void tipoF();
void Fun();
void param();
void otroParam();
void H();
void expreRel();
void E();
void contER();
void opRel();
void T();
void EE();
void F(); 
void TT();
void llama();
void M();
void P();
void I();
void arg();
void otroArg();
void devuelve();
void valor();
void otroValor();
void A();
void opAsig();
void Programa();
void decl();
void masFunciones();
void otraFun();
void check_sintaxis();

FILE *archSalTok;
FILE *archSalTS;
FILE *archSalLC;
FILE *archSalLNR;
FILE *archCadena;
%}


pal_res cadena|devuelve|entero|flotante|hacer|mientras|nulo|para|si|sino|vacio
op_arit sum|res|mult|div|mod|pow
op_asig i_i|M_i|m_i|a_i|d_i|p_i|A_i|P_i|B_i
op_rela <M>|<m>|<=>|<M=>|<m=>|<$=>
const_num_real ([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)
const_num_ent_oct 0[0-7]*
const_num_ent_dec [1-9][0-9]*
const_num_ent_hex 0[Xx][0-9a-fA-F]+
ident ([a-zA-Z_][a-zA-Z_0-9]*|[0-9]+(_|[a-zA-Z])+[0-9]*)
sim_especial [\.:\(\){}]
const_cadenas \"(?:[^"\\]|\\.)*\"

%%
{pal_res} {crear_token(4,yytext);}
{op_arit} {crear_token(6,yytext);}
{op_asig} {crear_token(3,yytext);}
{op_rela} {crear_token(2,yytext);}
{const_num_real} {crear_token_num_real(yytext);}
{const_num_ent_oct} {crear_token_num(yytext);}
{const_num_ent_dec} {crear_token_num(yytext);}
{const_num_ent_hex} {crear_token_num(yytext);}
{ident} {crear_token_iden(yytext);}
{sim_especial} {fprintf(archSalTok," 5     | %s\n",yytext); fprintf(archCadena,"%s",yytext);}
{const_cadenas} {crear_token_cadena(yytext);}
%%
// Objetivo: 
// 
// INTEGRANTES:
// MACEDA PATRICIO FERNANDO
// CALDERON GUEVARA CESAR YAIR
// FECHA DE REALIZACION: 09/MAR/2022 
//Se utilizo la estructura de datos de lista simple enlazada
//Estructura nodo
typedef struct nodo
{
    int dato;               //Tipo de dato de la lista
    char s[100][40+1];
    struct nodo* siguiente; //Apuntador al siguiente nodo o nulo
}nodo;

//Apuntadores para hacer referencias al primero y al ultimo elemento de la lista
nodo* primero = NULL;
nodo* ultimmo = NULL;

//Inserta un nodo en la lista el cual contienen la posicion y el valor de nuestro identificador
void insertarNodo(int a, char*s){
    //Creamos un nodo del temaño dinamico
    nodo* nuevo = (nodo*) malloc(sizeof(nodo));
    nuevo->dato = a;
    strcpy(nuevo->s[contador_lista],s);
    //Revisamos si la lista ha sido creada
    if (primero == NULL)
    {
        primero = nuevo;
        primero->siguiente = NULL;
        ultimmo = nuevo;
    }else{
        ultimmo->siguiente = nuevo;
        nuevo->siguiente = NULL;
        ultimmo = nuevo;
    }
    contador_lista = contador_lista + 1;
}

//La busqueda se hizo mediante busqueda lineal complejidad O(n)
//Se recorren los elementos de uno por uno.
//Buscamos los identifiacdores que ya estan en nuestra lista,
//Si encontramos un identificador que ya este en la lista se devuelve 1
//Si no se encuentra nada se devuelve 0
int buscarNodo(char* s){
    nodo* actual = (nodo*) malloc(sizeof(nodo));
    actual = primero;
    int encontrado = 0; //Cuando "encontrado" es 0, el nodo no se encontro, cuando "encontrado" es 1 el nodo fue encontrado
    char * nodoBuscado = s;
    //Comprobamos si la lista esta vacia
    if(primero != NULL){
        int i = 0;
        while (actual != NULL && encontrado != 1)
        {
            //Vamos comparando cual de los datos es el buscado
            if(strcmp(actual->s[i],nodoBuscado)==0){
                posicion_simbolo_repetida = actual->dato;
                encontrado = 1;
                return 1;
            }   
            i = i + 1;
            actual = actual->siguiente;
        }
        //Si no encrontramos el nodo
        if(encontrado == 0){
            return 0;
        }
        
    }else{
        //printf("\n La lista esta vacia.");
    }
}


//Escribimos en el archivo de tokens la clase y la posicion de nuestros catalogos ya definidos
void crear_token(int c,char *s){
    fprintf(archSalTok," %d     | %d\n", c,val_token(s));    
    escribir_atomo(s);
}

//Escribimos los tokens de los identificadores y con ayuda de las funciones buscar nodo y crear nodo
//nos aseguramos que no haya identificadores repetidos en la lista
//si no es asi, escribirmos la posicion, valor y tipo en el archivo de la tabla de simbolos
void crear_token_iden(char* s){
    if(buscarNodo(s) != 1){
        fprintf(archSalTok," 0     | %d\n",cont_ident);
        fprintf(archSalTS," %-5d | %-20s | -1\n",cont_ident,s);
        insertarNodo(cont_ident,s);
        cont_ident = cont_ident + 1; 
    }else{
        fprintf(archSalTok," 0     | %d\n",posicion_simbolo_repetida);
    }
    fprintf(archCadena,"a");
     
}

//Escribimos el valor del token de la cadena en el archivo de tokens
//Tambien escribimos la tabla de tokens con posicion y valor 
//Si la cadena tiene mas de 40 elementos contando las comillas regresamos un mensaje de error y no añadimos la cadena
void crear_token_cadena(char *s){
    if(strlen(s) <= 40){
        fprintf(archSalTok," 7     | %d\n",cont_cadena);
        fprintf(archSalLC," %d   | %s\n",cont_cadena,s);
        cont_cadena = cont_cadena + 1;
        fprintf(archCadena,"k");
    }else{
        printf("\nCadena demasiado grande %s\n", s);
    }
    
}

//Escribimos los tokens de los numeros enteros (decimal,octal y hexadecimal)
//con su respectiva clase y valor
void crear_token_num(char *s){
    fprintf(archSalTok," 1     | %s\n",s);
    fprintf(archCadena,"n");
}

//Escribimos los tokens para los numeros reales con su respectiva clase y posicion
//Ademas escribimos la tabla de estos numeros con su posicion y valor
void crear_token_num_real(char* s){
    fprintf(archSalTok," 8     | %d\n",cont_num_real);
    fprintf(archSalLNR," %d   | %s\n", cont_num_real, s);
    cont_num_real = cont_num_real + 1;
    fprintf(archCadena,"r");
}

//Definimos los catalogos acorados en clase y regresamos el valor de su clase dependeindo del simbolo dado
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

// Función que escribe el atomo que le corresponde a nuestra cadena de salida dependiendo de la entrada
void escribir_atomo(char *s){
    if(strcmp(s,"cadena") == 0){
        fprintf(archCadena,"s");
    }else if(strcmp(s,"devuelve") == 0){
        fprintf(archCadena,"d");
    }else if(strcmp(s,"entero") == 0){
        fprintf(archCadena,"t");
    }else if(strcmp(s,"flotante") == 0){
        fprintf(archCadena,"f");
    }else if(strcmp(s,"hacer") == 0){
        fprintf(archCadena,"h");
    }else if(strcmp(s,"mientras") == 0){
        fprintf(archCadena,"m");
    }else if(strcmp(s,"nulo") == 0){
        fprintf(archCadena,"u");
    }else if(strcmp(s,"para") == 0){
        fprintf(archCadena,"p");
    }else if(strcmp(s,"si") == 0){
        fprintf(archCadena,"i");
    }else if(strcmp(s,"sino") == 0){
        fprintf(archCadena,"w");
    }else if(strcmp(s,"vacio") == 0){
        fprintf(archCadena,"v");
    }else if(strcmp(s,"<M>") == 0){
        fprintf(archCadena,">");
    }else if(strcmp(s,"<m>") == 0){
        fprintf(archCadena,"<");
    }else if(strcmp(s,"<=>") == 0){
        fprintf(archCadena,"=");
    }else if(strcmp(s,"<M=>") == 0){
        fprintf(archCadena,"g");
    }else if(strcmp(s,"<m=>") == 0){
        fprintf(archCadena,"l");
    }else if(strcmp(s,"<$=>") == 0){
        fprintf(archCadena,"!");
    }else if(strcmp(s,"i_i") == 0){
        fprintf(archCadena,"e");
    }else if(strcmp(s,"M_i") == 0){
        fprintf(archCadena,"b");
    }else if(strcmp(s,"m_i") == 0){
        fprintf(archCadena,"c");
    }else if(strcmp(s,"a_i") == 0){
        fprintf(archCadena,"j");
    }else if(strcmp(s,"d_i") == 0){
        fprintf(archCadena,"o");
    }else if(strcmp(s,"p_i") == 0){
        fprintf(archCadena,"q");
    }else if(strcmp(s,"A_i") == 0){
        fprintf(archCadena,"x");
    }else if(strcmp(s,"P_i") == 0){
        fprintf(archCadena,"y");
    }else if(strcmp(s,"B_i") == 0){
        fprintf(archCadena,"z");
    }else if(strcmp(s,"sum") == 0){
        fprintf(archCadena,"+");
    }else if(strcmp(s,"res") == 0){
        fprintf(archCadena,"-");
    }else if(strcmp(s,"mult") == 0){
        fprintf(archCadena,"*");
    }else if(strcmp(s,"div") == 0){
        fprintf(archCadena,"/");
    }else if(strcmp(s,"mod") == 0){
        fprintf(archCadena,"%%");
    }else if(strcmp(s,"pow") == 0){
        fprintf(archCadena,"^");
    }
    
}
 
// Función que sirve para abrir los archivos que vamos a utilizar y escribir la cabecera
void open_files(){
    archSalTok = fopen("salida_tokens.txt","w");
    fprintf(archSalTok," Clase | valor\n");
    archSalTS = fopen("salida_tabla_simbolos.txt","w");
    fprintf(archSalTS," Pos   | Nombre               | Tipo\n");
    archSalLC = fopen("salida_literales_constantes.txt","w");
    fprintf(archSalLC," Pos | Cadena\n");
    archSalLNR = fopen("salida_literales_numericas_reales.txt","w");
    fprintf(archSalLNR," Pos | Constante\n");
    archCadena = fopen("cadena_salida.txt","w");
}

// Función que sirve para cerrar los archivos
void close_files(){
    fclose(archSalTok);
    fclose(archSalTS);
    fclose(archSalLC);
    fclose(archSalLNR);
    fclose(archCadena);
}

// Sentecias declaraticas
// Declar n variables
void D(){
    tipo();
    c = atomoActual();
    
    if(c = 'a'){
        c = atomoActual();
        L();
        return;
    }else{
        printf("Falta identificador");
        exit(EXIT_FAILURE);
    }
}

void L(){
    if(c == '.'){
        c = atomoActual();
        return;
    }else if(c == ':'){
        c = atomoActual();
        if(c == 'a'){
            c = atomoActual();
            L();
        }else{
            printf("Error en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
            exit(EXIT_FAILURE);
        }
    }else{
        printf("Error en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void tipo(){
    if(c == 's' || c == 't' || c == 'f'){
        return;
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void Fun(){
    tipoF();
    c = atomoActual();
    if(c == 'a'){
        c = atomoActual();
        if(c == '('){
            c = atomoActual();
            param();
            if(c == '{'){
                c = atomoActual();
                R();
            }
        }

    }
}

void param(){
    if(c == ')'){
        c = atomoActual();
        return;
    }else{
        tipoF();
        c = atomoActual();
        if(c == 'a'){
            c = atomoActual();
            otroParam();
            return;
        }else{
            exit(EXIT_FAILURE);
        }
    }
}

void otroParam(){
    if(c == ')'){
        c = atomoActual();
        return;
    }else{
        if(c == ':'){
            c = atomoActual();
            tipo();
            c = atomoActual();
            if(c == 'a'){
                c = atomoActual();
                otroParam();
            }
        }
    }
}

void tipoF(){
    if(c == 's' || c == 't' || c == 'f' || c == 'v'){
        return;
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void R(){
    if(c == '}'){
        c = atomoActual();
        return;
    }else if (c != '\0'){
        S();
        R();
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void S(){
    if(c == 's' || c == 't' || c == 'f'){
        D();
    }else if(c == 'a'){
        A();
    }else if(c == 'h'){
        H();
    }else if(c == 'm'){
        M();
    }else if(c == 'p'){
        P();
    }else if(c == 'i'){
        I();
    }else if(c == '{'){
        c = atomoActual();
        llama();
    }else if(c == 'd'){
        devuelve();
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void H(){
    if(c == 'h'){
        c = atomoActual();
        if(c == '{'){
            c = atomoActual();
            S();
            R();
            if(c == 'm'){
                c = atomoActual();
                if(c == '('){
                    c = atomoActual();
                    expreRel();
                    if(c == ')'){
                        c = atomoActual();
                        if(c == '.'){
                            c = atomoActual();
                            return;
                        }else{
                            printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                            exit(EXIT_FAILURE);
                        }
                    }else{
                        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                        exit(EXIT_FAILURE);
                    }
                }else{
                    printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                    exit(EXIT_FAILURE);
                }
            }
        }else{
            printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
            exit(EXIT_FAILURE);
        }
    }
}

void expreRel(){
    E();
    contER();
    return;
}

void E(){
    T();
    EE();
    return;
}

void T(){
    F();
    TT();
    return;
}

void F(){
    if(c == '('){
        c = atomoActual();
        E();
        if(c == ')'){
            c = atomoActual();
            return;
        }
    }else if(c == 'a' || c == 'r' || c == 'n'){
        c = atomoActual();
        return;
    }else if(c == '{'){
        c = atomoActual();
        llama();
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void EE(){
    if(c == '+'){
        c = atomoActual();
        T();
        EE();
        return;
    }else if(c == '-'){
        c = atomoActual();
        T();
        EE();
        return;
    }else{
        return;
    }
}

void TT(){
    if(c == '*'){
        c = atomoActual();
        F();
        TT();
        return;
    }else if(c == '/'){
        c = atomoActual();
        F();
        TT();
        return;
    }else if(c == '%'){
        c = atomoActual();
        F();
        TT();
        return;
    }else if(c == '^'){
        c = atomoActual();
        F();
        TT();
        return;
    }else{
        return;
    }
}

void contER(){
    opRel();
    E();
    return;
}

void opRel(){
    if(c == '>' || c == '<' || c == '=' || c == 'g' || c == 'l' || c == '!'){
        c = atomoActual();
        return;
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void M(){
    if(c == 'm'){
        c = atomoActual();
        if(c == '('){
            c = atomoActual();
            expreRel();
            if(c == ')'){
                c = atomoActual();
                if(c == '{'){
                    c = atomoActual();
                    S();
                    R();
                    if(c == '.'){
                        c = atomoActual();
                        return;
                    }else{
                        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                        exit(EXIT_FAILURE);
                    }
                }else{
                    printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                    exit(EXIT_FAILURE);
                }
            }else{
                printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                exit(EXIT_FAILURE);
            }
        }else{
            printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
            exit(EXIT_FAILURE);
        }
    }
}

void P(){
    if(c == 'p'){
        c = atomoActual();
        if(c == 'n'){
            c = atomoActual();
            if(c == '{'){
                c = atomoActual();
                R();
                if(c == '.'){
                    c = atomoActual();
                    return;
                }else{
                    printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                    exit(EXIT_FAILURE);
                }
            }else{
                printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                exit(EXIT_FAILURE);
            }
        }else{
            printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
            exit(EXIT_FAILURE);
        }
    }
}

void I(){
    if(c == 'i'){
        c = atomoActual();
        if(c == '('){
            c = atomoActual();
            expreRel();
            if(c == ')'){
                c = atomoActual();
                if(c == '{'){
                    c = atomoActual();
                    R();
                    if(c == 'w'){
                        c = atomoActual();
                        if(c == '{'){
                            c = atomoActual();
                            R();
                            if(c == '.'){
                                c = atomoActual();
                                return;
                            }else{
                                printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                                exit(EXIT_FAILURE);
                            }
                        }else{
                            printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                            exit(EXIT_FAILURE);
                        }

                    }else{
                        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                        exit(EXIT_FAILURE);
                    }                                                                                              
                }else{
                    printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                    exit(EXIT_FAILURE);
                }
            }else{
                printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                exit(EXIT_FAILURE);
            }
        }else{
            printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
            exit(EXIT_FAILURE);
        }
    }
}

void llama(){
    if(c == 'a'){
        c = atomoActual();
        if(c == '('){
            c = atomoActual();
            arg();
            if(c == '}'){
                c = atomoActual();
                if(c == '.'){
                    c = atomoActual();
                    return;
                }else{
                    printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                    exit(EXIT_FAILURE);
                }
            }else{
                printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                exit(EXIT_FAILURE);
            }
        }else{
                printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                exit(EXIT_FAILURE);
        }
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void arg(){
    if(c == ')'){
        c = atomoActual();
        return;
    }else if(c == 'a'){
        c = atomoActual();
        otroArg();
        return;
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void otroArg(){
    if (c == ')'){
        c = atomoActual();
        return;
    }else if(c == ':'){
        c = atomoActual();
        if(c == 'a'){
            c = atomoActual();
            otroArg();
        }
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void devuelve(){
    if(c == 'd'){
        c = atomoActual();
        if(c == '('){
            c = atomoActual();
            valor();
            if( c == ')'){
                c = atomoActual();
                if(c == '.'){
                    c = atomoActual();
                    return;
                }else{
                    printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                    exit(EXIT_FAILURE);
                }
            }else{
                printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
                exit(EXIT_FAILURE);
            }
        }else{
            printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
            exit(EXIT_FAILURE);
        }
    }
}

void valor(){
    if(c == 'a' || c == 'n' || c == 'r'){
        c = atomoActual();
        return;
    }else{
        otroValor();
    }
}

void otroValor(){
    if(c == 'u' || c == 'k'){
        c = atomoActual();
        return;
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void A(){
    if(c == 'a'){
        c = atomoActual();
        opAsig();
        E();
        if(c == ':'){
            c = atomoActual();
            return;
        }else{
            printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
            exit(EXIT_FAILURE); 
        }
    }
}

void opAsig(){
    if(c == 'e' || c == 'b' || c == 'c' || c == 'j' || c == 'o' || c == 'q' || c == 'x' || c == 'y' || c == 'z'){
        c = atomoActual();
    }else{
        printf("Error de tipo en el atomo %c posicion %d\n", atomos[pos_atomo-1], pos_atomo-1);
        exit(EXIT_FAILURE);
    }
}

void Programa(){
    decl();
    masFunciones();
    if(c == '\0'){
        printf("\nAnalisis sintactico correcto\n");
        return;
    }else{
        printf("\nError al hacer el analisis sintactico\n");
        exit(EXIT_FAILURE);
    }
}

void decl() {
    if(c == '{'){
        c = atomoActual();
        return;
    }else{
        D();
        decl();
    }
}

void masFunciones(){
    Fun();
    otraFun();
    return;
}

void otraFun(){
    if(c == '}'){
        c = atomoActual();
        return;
    }else{
        Fun();
        otraFun();
    }
}

//Funcion que sirve para crear un arrglo de la cadena de atomos y sea más facil manipularla
void leerCadena(){
    archCadena = fopen("cadena_salida.txt","r");
    int size;
    if(archCadena != NULL){
        size = 1;
        while(getc(archCadena) != EOF){
            size++;
        }
    }
    atomos = (char*) malloc(sizeof(char)*size);
    fseek(archCadena,0,SEEK_SET);
    for(int i = 0; i < size - 1; i++){
        atomos[i] = (char)getc(archCadena);
    }
    atomos[size-1] = '\0';
    fclose(archCadena); 
    c = atomos[0];      
}

char atomoActual(){
    pos_atomo++;
    return atomos[pos_atomo];
}


// Funcion principal que llama a las funciones de abrir archivos, yylex() y cerrar archivos
void main(int argc, char *argv[]){
    yyin = fopen(argv[1],"r");
    open_files();
    yylex();
    close_files();
    leerCadena(); 
    Programa();
}
