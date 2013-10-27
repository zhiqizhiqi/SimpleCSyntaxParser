%{
/*
	Used for the syntax analyzer
*/
#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#include "struct.h"
#define YYDEBUG 1
typedef char* string;

Node *head;
Node* Record(char *, ...);

FILE *fout;

extern int yydebug; %}

%union {
	Node *node;
};

%token <node> ASSIGNOP TYPE
%token <node> LC RC
%token <node> STRUCT RETURN 
%token <node> IF ELSE BREAK CONT FOR
%token <node> INT ID SEMI COMMA

%token <node> LP RP LB RB DOT
%token <node> LOGNOT INCR DECR BNOT
%token <node> MOD PRODUCT DIVISION
%token <node> PLUS MINUS
%token <node> SHLEFT SHRIGHT
%token <node> GREATER GREATEREQU LESS LESSEQU
%token <node> EQU NOTEQU
%token <node> BAND
%token <node> BXOR
%token <node> BOR
%token <node> LOGAND
%token <node> LOGOR
%token <node> PLUSAN MINUSAN PRODUCTAN DIVISIONAN BANDAN BXORAN BORAN SHLEFTAN SHRIGHTAN

%type <node> PROGRAM EXTDEFS EXTDEF EXTVARS SPEC STSPEC OPTTAG
%type <node> VAR FUNC PARAS PARA STMTBLOCK STMTS STMT ESTMT
%type <node> DEFS DEF DECS DEC INIT EXP ARRS ARGS
%start PROGRAM

%right PLUSAN MINUSAN PRODUCTAN DIVISIONAN BANDAN BXORAN BORAN SHLEFTAN SHRIGHTAN ASSIGNOP
%left LOGOR
%left LOGAND
%left BOR
%left BXOR
%left BAND
%left EQU NOTEQU
%left GREATER GREATEREQU LESS LESSEQU
%left SHLEFT SHRIGHT
%left PLUS MINUS
%left MOD PRODUCT DIVISION
%right LOGNOT INCR DECR BNOT
%left LP RP LB RB DOT

%%
PROGRAM:
	EXTDEFS					{$$ = Record("PROGRAM", $1, NULL);}
	;

EXTDEFS:
	EXTDEF EXTDEFS			{$$ = Record("EXTDEFS", $1, $2, NULL);}
	| 						{$$ = Record("EXTDEFS", NULL);}
	;

EXTDEF:
	SPEC EXTVARS SEMI		{$$ = Record("EXTDEF", $1, $2, $3, NULL);}
	| SPEC FUNC STMTBLOCK	{$$ = Record("EXTDEF", $1, $2, $3, NULL);}
	;

EXTVARS:
	DEC 					{$$ = Record("EXTVARS", $1, NULL);}
	| DEC COMMA EXTVARS		{$$ = Record("EXTVARS", $1, $2, $3, NULL);}
	| 						{$$ = Record("EXTVARS", NULL);}
	;

SPEC:
	TYPE 					{$$ = Record("SPEC", $1, NULL);}
	| STSPEC				{$$ = Record("SPEC", $1, NULL);}
	;

STSPEC:
	STRUCT OPTTAG LC DEFS RC 	{$$ = Record("STSPEC", $1, $2, $3, $4, $5, NULL);}
	| STRUCT ID 				{$$ = Record("STSPEC", $1, $2, NULL);}
	;

OPTTAG:
	ID 						{$$ = Record("OPTTAG", $1, NULL);}
	| 						{$$ = Record("OPTTAG", NULL);}
	;

VAR:
	ID 						{$$ = Record("VAR", $1, NULL);}
	| VAR LB INT RB			{$$ = Record("VAR", $1, $2, $3, $4, NULL);}
	;

FUNC:
	ID LP PARAS RP			{$$ = Record("FUNC", $1, $2, $3, $4, NULL);}
	;

PARAS:
	PARA COMMA PARAS		{$$ = Record("PARAS", $1, $2, $3, NULL);}
	| PARA 					{$$ = Record("PARAS", $1, NULL);}
	| 						{$$ = Record("PARAS", NULL);}
	;

PARA:
	SPEC VAR 				{$$ = Record("PARA", $1, $2, NULL);}
	;

STMTBLOCK:
	LC DEFS STMTS RC 		{$$ = Record("STMTBLOCK", $1, $2, $3, $4, NULL);}
	;

STMTS:
	STMT STMTS				{$$ = Record("STMTS", $1, $2, NULL);}
	|						{$$ = Record("STMTS", NULL);}
	;

STMT:
	EXP SEMI				{$$ = Record("STMT", $1, $2, NULL);}
	| STMTBLOCK				{$$ = Record("STMT", $1, NULL);}
	| RETURN EXP SEMI 		{$$ = Record("STMT", $1, $2, $3, NULL);}
	| IF LP EXP RP STMT ESTMT	{$$ = Record("STMT", $1, $2, $3, $4, $5, $6, NULL);}
	| FOR LP EXP SEMI EXP SEMI EXP RP STMT 		{$$ = Record("STMT", $1, $2, $3, $4, $5, $6, $7, $8, $9, NULL);}
	| CONT SEMI				{$$ = Record("STMT", $1, $2, NULL);}
	| BREAK SEMI			{$$ = Record("STMT", $1, $2, NULL);}
	;

ESTMT:
	ELSE STMT				{$$ = Record("ESTMT", $1, $2, NULL);}
	| 						{$$ = Record("ESTMT", NULL);}
	;

DEFS:
	DEF DEFS				{$$ = Record("DEFS", $1, $2, NULL);}
	| 						{$$ = Record("DEFS", NULL);}
	;

DEF:
	SPEC DECS SEMI			{$$ = Record("DEF", $1, $2, $3, NULL);}
	;

DECS:
	DEC COMMA DECS			{$$ = Record("DECS", $1, $2, $3, NULL);}
	| DEC 					{$$ = Record("DECS", $1, NULL);}
	;

DEC:
	VAR 					{$$ = Record("DEC", $1, NULL);}
	| VAR ASSIGNOP INIT		{$$ = Record("DEC", $1, $2, $3, NULL);}
	;

INIT:
	EXP						{$$ = Record("INIT", $1, NULL);}
	| LC ARGS RC 			{$$ = Record("INIT", $1, $2, $3, NULL);}
	;
EXP:
	ID 						{$$ = Record("EXP", $1, NULL);}
	| EXP PLUS EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP MINUS EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP PRODUCT EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP DIVISION EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP PLUSAN EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP MINUSAN EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP PRODUCTAN EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP DIVISIONAN EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP MOD EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP SHLEFT EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP SHRIGHT EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP GREATER EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP GREATEREQU EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP LESS EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP LESSEQU EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP EQU EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP NOTEQU EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP BAND EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP BXOR EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP BOR EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP LOGAND EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP LOGOR EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP BANDAN EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP BXORAN EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP BORAN EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP SHLEFTAN EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP SHRIGHTAN EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP DOT EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| EXP ASSIGNOP EXP		{$$ = Record("EXP", $1, $2, $3, NULL);}
	| MINUS EXP			{$$ = Record("EXP", $1, $2, NULL);}
	| INCR EXP			{$$ = Record("EXP", $1, $2, NULL);}
	| DECR EXP			{$$ = Record("EXP", $1, $2, NULL);}
	| BNOT EXP			{$$ = Record("EXP", $1, $2, NULL);}	
	| LOGNOT EXP			{$$ = Record("EXP", $1, $2, NULL);}
	| LP EXP RP				{$$ = Record("EXP", $1, $2, $3, NULL);}
	| ID LP ARGS RP			{$$ = Record("EXP", $1, $2, $3, $4, NULL);}
	| ID ARRS				{$$ = Record("EXP", $1, $2, NULL);}
	| INT 					{$$ = Record("EXP", $1, NULL);}
	|						{$$ = Record("EXP", NULL);}
	;

ARRS:
	LB EXP RB ARRS			{$$ = Record("ARRS", $1, $2, $3, $4, NULL);}
	|						{$$ = Record("ARRS", NULL);}
	;

ARGS:
	EXP COMMA ARGS			{$$ = Record("ARGS", $1, $2, $3, NULL);}
	| EXP					{$$ = Record("ARGS", $1, NULL);}
	;

%%
void walkGraph(Node* n, int layer) {
	fprintf(fout, "%*s", layer*10, n->token);
	if (n->content != NULL) fprintf(fout, "_%s", n->content);

	if (n->child != NULL) {
		fprintf(fout, ":\n");
		walkGraph(n->child, layer+1);
	}
	else fprintf(fout, "\n");
	if (n->next != NULL) walkGraph(n->next, layer);

	return;
}
int main(int argc, char* argv[]){
	//printf ("%s%s\n", argv[0], argv[1]);
	yydebug=0;	//set it to 1, that should be DEBUG mode, to 0, that will disable DEBUG
	freopen(argv[1], "r", stdin);
	fout = fopen(argv[2], "w");
	yyparse();
	printf("\n\n");
	walkGraph(head, 1);
	return 0;
}

int yyerror(char *msg){
	fprintf(fout, "ERROR.", msg);
	exit(0);
	return 0;
}

Node* Record(char* content, ...){
	Node *res = malloc(sizeof(Node));
	res->token = strdup(content);
	res->content = NULL;

	va_list ap;
	va_start(ap, content);

	Node *tmp;
	tmp = va_arg(ap, Node*);

	res->child = tmp;
	res->next = NULL;

	Node *ttmp;
	while(tmp != NULL) {
		ttmp = va_arg(ap, Node*);
		tmp->next = ttmp;
		tmp = ttmp;
	}
	va_end(ap);

	head = res;
	return res;
}
