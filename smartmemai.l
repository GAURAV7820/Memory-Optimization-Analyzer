%{
#include <stdio.h>
#include <string.h>

#define MAX 100

struct Variable{
    char name[50];
    char type[10];
    int isUsed;
    int isDuplicate;
    int line;
    int scope;
};

struct Variable vars[MAX];
int varCount=0;

char currentType[10];
int declarationMode=0;
int lineNo=1;
int scope=0;

int findVar(char *name){
    for(int i=varCount-1;i>=0;i--){
        if(strcmp(vars[i].name,name)==0 && vars[i].scope==scope)
            return i;
    }
    return -1;
}
%}

%%

\n { lineNo++; }

"{" { scope++; }
"}" { scope--; }

(int|float|char|double|long) {
    strcpy(currentType,yytext);
    declarationMode=1;
}

[a-zA-Z_][a-zA-Z0-9_]*\([ \t]*\) { }

[a-zA-Z_][a-zA-Z0-9_]* {
    if(strcmp(yytext,"main")==0) return 0;

    if(declarationMode){
        int idx=findVar(yytext);

        if(idx==-1){
            strcpy(vars[varCount].name,yytext);
            strcpy(vars[varCount].type,currentType);
            vars[varCount].isUsed=0;
            vars[varCount].isDuplicate=0;
            vars[varCount].line=lineNo;
            vars[varCount].scope=scope;
            varCount++;
        }else{
            vars[idx].isDuplicate=1;
        }
    }else{
        int idx=-1;
        for(int i=varCount-1;i>=0;i--){
            if(strcmp(vars[i].name,yytext)==0){
                idx=i;
                break;
            }
        }

        if(idx!=-1){
            vars[idx].isUsed=1;
        }
    }
}

";" { declarationMode=0; }

[0-9]+ { }
"," { }
"=" { }
[ \t]+ { }
. { }

%%

int getSize(char *type){
    if(strcmp(type,"int")==0) return 4;
    if(strcmp(type,"float")==0) return 4;
    if(strcmp(type,"char")==0) return 1;
    if(strcmp(type,"double")==0) return 8;
    if(strcmp(type,"long")==0) return 8;
    return 0;
}

int main(){
    FILE *fp=fopen("input.c","r");
    FILE *report=fopen("report.txt","w");

    if(!fp||!report) return 1;

    yyin=fp;
    yylex();
    fclose(fp);

    int before=0,after=0;

    fprintf(report,"===== SMARTMEMAI ANALYSIS REPORT =====\n");
    fprintf(report,"\n--- Symbol Table ---\n");

    fprintf(report,"%-8s %-8s %-8s %-6s %-5s\n","Name","Type","Used","Line","Scope");
    fprintf(report,"--------------------------------------------------\n");

    FILE *data=fopen("data.txt","w");
    FILE *names=fopen("names.txt","w");

    for(int i=0;i<varCount;i++){
        fprintf(report,"%-15s %-10s %-10s %-6d %-5d\n",
            vars[i].name,
            vars[i].type,
            vars[i].isUsed ? "Yes" : "No",
            vars[i].line,
            vars[i].scope);

        fprintf(data,"%d %d\n",vars[i].isUsed,vars[i].isDuplicate);
        fprintf(names,"%s\n",vars[i].name);
    }

    fclose(data);
    fclose(names);

    fprintf(report,"\n--- Optimization Report ---\n");

    for(int i=0;i<varCount;i++){
        int size=getSize(vars[i].type);
        before+=size;

        if(vars[i].isUsed)
            after+=size;

        if(!vars[i].isUsed)
            fprintf(report,"Unused variable: %s (line %d)\n",vars[i].name,vars[i].line);

        if(vars[i].isDuplicate)
            fprintf(report,"Duplicate variable: %s (line %d)\n",vars[i].name,vars[i].line);
    }

    fprintf(report,"\n--- Memory Analysis ---\n");
    fprintf(report,"Memory before: %d bytes\n",before);
    fprintf(report,"Memory after: %d bytes\n",after);
    fprintf(report,"Memory saved: %d bytes\n",before-after);

    fclose(report);

    system("python3 ai_model.py");

    report=fopen("report.txt","a");
    fprintf(report,"\n======================================\n");
    fclose(report);

    return 0;
}

int yywrap(){
    return 1;
}