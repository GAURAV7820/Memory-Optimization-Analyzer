%{
#include <stdio.h>
#include <string.h>

#define MAX 100

struct Variable{
    char name[50];
    char type[10];
    int isUsed;
    int isDuplicate;
    int isInitialized;
    int isUsedBeforeInit;
    int line;
    int scope;
};

struct Variable vars[MAX];
int varCount=0;

char currentType[10];
int declarationMode=0;
int lineNo=1;
int scope=0;
int lastVarIndex=-1;
int pendingIdentifierUse=0;

int findVar(char *name){
    for(int i=varCount-1;i>=0;i--){
        if(strcmp(vars[i].name,name)==0 && vars[i].scope==scope)
            return i;
    }
    return -1;
}

int findVisibleVar(char *name){
    for(int i=varCount-1;i>=0;i--){
        if(strcmp(vars[i].name,name)==0 && vars[i].scope<=scope)
            return i;
    }
    return -1;
}

void flushPendingIdentifierUse(){
    if(pendingIdentifierUse && lastVarIndex!=-1){
        if(!vars[lastVarIndex].isInitialized)
            vars[lastVarIndex].isUsedBeforeInit=1;

        vars[lastVarIndex].isUsed=1;
    }

    pendingIdentifierUse=0;
}
%}

%%

\n {
    flushPendingIdentifierUse();
    lineNo++;
}

"{" {
    flushPendingIdentifierUse();
    scope++;
}
"}" {
    flushPendingIdentifierUse();
    scope--;
}

(int|float|char|double|long) {
    flushPendingIdentifierUse();
    strcpy(currentType,yytext);
    declarationMode=1;
}

[a-zA-Z_][a-zA-Z0-9_]*/[ \t]*\( {
    flushPendingIdentifierUse();
    lastVarIndex=-1;
    pendingIdentifierUse=0;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    flushPendingIdentifierUse();

    if(strcmp(yytext,"main")==0){
        lastVarIndex=-1;
    }

    else if(declarationMode){
        int idx=findVar(yytext);

        if(idx==-1){
            if(varCount>=MAX){
                fprintf(stderr,"Too many variables. Increase MAX.\n");
                return 0;
            }

            strcpy(vars[varCount].name,yytext);
            strcpy(vars[varCount].type,currentType);
            vars[varCount].isUsed=0;
            vars[varCount].isDuplicate=0;
            vars[varCount].isInitialized=0;
            vars[varCount].isUsedBeforeInit=0;
            vars[varCount].line=lineNo;
            vars[varCount].scope=scope;
            lastVarIndex=varCount;
            varCount++;
        }else{
            vars[idx].isDuplicate=1;
            lastVarIndex=idx;
        }
    }else{
        int idx=findVisibleVar(yytext);

        if(idx!=-1){
            lastVarIndex=idx;
            pendingIdentifierUse=1;
        }else{
            lastVarIndex=-1;
            pendingIdentifierUse=0;
        }
    }
}

";" {
    flushPendingIdentifierUse();
    declarationMode=0;
    lastVarIndex=-1;
}

"=" {
    if(lastVarIndex!=-1)
        vars[lastVarIndex].isInitialized=1;

    declarationMode=0;
    pendingIdentifierUse=0;
}

[0-9]+ {
    flushPendingIdentifierUse();
}
"," {
    flushPendingIdentifierUse();
}
[ \t]+ { }
. {
    flushPendingIdentifierUse();
}

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
    int issueCount=0;
    int totalSavings=0;

    fprintf(report,"===== SMARTMEMAI ANALYSIS REPORT =====\n");
    fprintf(report,"• Code checked using fixed rules\n");
    fprintf(report,"\n--- Symbol Table ---\n");
    fprintf(report,"--------------------------------------------------\n");
    fprintf(report,"Name   Type   Used   Initialized   Line\n");
    fprintf(report,"--------------------------------------------------\n");

    FILE *data=fopen("data.txt","w");
    FILE *names=fopen("names.txt","w");

    for(int i=0;i<varCount;i++){
        fprintf(report,"%-6s %-6s %-6s %-12s %-6d\n",
            vars[i].name,
            vars[i].type,
            vars[i].isUsed ? "Yes" : "No",
            vars[i].isInitialized ? "Yes" : "No",
            vars[i].line);

        fprintf(data,"%d %d\n",vars[i].isUsed,vars[i].isDuplicate);
        fprintf(names,"%s\n",vars[i].name);
    }

    fprintf(report,"--------------------------------------------------\n");

    fclose(data);
    fclose(names);

    fprintf(report,"\n--- Optimization Report ---\n");

    for(int i=0;i<varCount;i++){
        int size=getSize(vars[i].type);
        before+=size;

        if(vars[i].isUsed)
            after+=size;

        if(!vars[i].isUsed)
            fprintf(report,"• Unused variable: %s (line %d)\n",vars[i].name,vars[i].line);

        if(vars[i].isDuplicate)
            fprintf(report,"• Duplicate variable: %s (line %d)\n",vars[i].name,vars[i].line);

        if(vars[i].isUsedBeforeInit)
            fprintf(report,"• Used before initialization: %s (line %d)\n",vars[i].name,vars[i].line);
    }

    fprintf(report,"\n--- Rule-Based Findings ---\n");

    for(int i=0;i<varCount;i++){
        int size=getSize(vars[i].type);

        if(!vars[i].isUsed){
            issueCount++;
            totalSavings+=size;
            fprintf(report,"• Rule R1 [Unused Variable]: %s is declared but never used\n",vars[i].name);
            fprintf(report,"• Suggestion: Remove %s to save approximately %d bytes\n",vars[i].name,size);
        }

        if(vars[i].isDuplicate){
            issueCount++;
            totalSavings += size;
            fprintf(report,"• Rule R2 [Duplicate Declaration]: %s is declared more than once in the same scope\n",vars[i].name);
            fprintf(report,"• Suggestion: Keep one declaration of %s or rename the duplicate variable\n",vars[i].name);
        }

        if(vars[i].isUsedBeforeInit){
            issueCount++;
            fprintf(report,"• Rule R3 [Use Before Initialization]: %s is used before a value is assigned\n",vars[i].name);
            fprintf(report,"• Suggestion: Initialize %s before its first use\n",vars[i].name);
        }
    }

    fprintf(report,"\n--- Memory Analysis ---\n");
    fprintf(report,"• Memory before: %d bytes\n",before);
    fprintf(report,"• Memory after: %d bytes\n",after);
    fprintf(report,"• Memory saved: %d bytes\n",before-after);

    fprintf(report,"\n--- Rule-Based Summary ---\n");
    fprintf(report,"• Total issues found: %d\n",issueCount);
    fprintf(report,"• Estimated removable memory: %d bytes\n",totalSavings);
    if(issueCount==0)
        fprintf(report,"• Final verdict: Code follows the current optimization rules\n");
    else if(issueCount<=2)
        fprintf(report,"• Final verdict: Minor optimization improvements are recommended\n");
    else
        fprintf(report,"• Final verdict: Significant optimization cleanup is recommended\n");

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
