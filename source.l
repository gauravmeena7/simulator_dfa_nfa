%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stack.h"



int dfa,num_state,num_final,num_input;

int *** nfa_table;					//Transition table for NFA
int** dfa_table;					//Transition table for DFA

int *input_element;					//List of all valid inputs
int *state;						//List of all states
int *final;						//List of all final states

int* kleen_closure;					//To store the e_closure of a given state

int countElement(const char*);				//To count the element in COMA separated input (1,3,2,4)
void e_closure(int);					//To find all the elosure of a state say 1

void reinitialize_current_state();			//To reinitialize current state after reading each input
void update_current_state(char);			//Update the current state in both DFA as well as NFA
void print_specification();				//Print all the specification of the file to check whether we load the correct value or not
void read_specification();				//Load data from specification file into the above variables
void done();						//Check whether the pattern matches or not

int* nfa_current_state;					//Current state of NFA
int dfa_current_state;					//Current state of DFA
int* nfa_next_state;					//Extra memory to help computing some function of NFA 

char current_input;					//Current input variable
_Bool match=0;						//If it is true then the pattern matches else not matches

%}


%%

[$^]	;
[ ]	{}
\n	{done();reinitialize_current_state();}
.	{update_current_state(yytext[0]);}

%%

int main(int argc, char* argv[]){
	if(argc!=5){
		printf("Invalid format of the executable file.\n");
		return 0;
	}

	dfa=atoi(argv[1]);
	num_state=atoi(argv[2]);
	num_final=atoi(argv[3]);
	num_input=atoi(argv[4]);
			//Intializing current state
	if(dfa)
		dfa_current_state = 0;
	else{
		kleen_closure = (int*)malloc(num_state*sizeof(int));
		nfa_current_state = (int*)malloc(num_state*sizeof(int));
		nfa_next_state = (int*)malloc(num_state*sizeof(int));
	}
			//Reading specification.txt file
	read_specification();
			//Printing specification.txt file
//	print_specification();

			//calling pattern matching function
	reinitialize_current_state();
	yylex();

	return 0;
}

			//function to count state in input like    1,5,3,4 
			//then this function return 	:	   4

void reinitialize_current_state(){
	if(dfa)
		dfa_current_state=state[0];
	else{
		e_closure(state[0]);
		for(int i =0;i<num_state;i++)
			nfa_next_state[i]= kleen_closure[i];
	}
}
	
int countElement(const char* s){
	int size = 0;
	for(int i = 0;s[i]!='\0';i++){
		if(s[i] == ',')
			size++;
	}
	return size+1;
}


void print_specification(){
	printf("States : ");
	for(int i = 0;i<num_state;i++)
		printf("%d ", state[i]);
	printf("\nFinal States : ");
	for(int i = 0;i<num_final;i++)
		printf("%d ", final[i]);
	printf("\nInput Symbols : ");
	for(int i = 0;i<num_input;i++)
		printf("%c ", input_element[i]);	
	
	if(dfa){
		printf("\nDFA Transition Table : \n");
		for(int i = 0;i<num_state;i++){
			for(int j = 0;j<num_input;j++)
				printf("%d ", dfa_table[i][j]);
			printf("\n");	
		}
	}else{
		printf("\nNFA Transition Table : \n");
		for(int i = 0;i<num_state;i++){
			for(int j = 0;j<=num_input;j++){
				if(nfa_table[i][j][0] == -1){
					printf("%c\t\t",'^');
					continue;
				}
				for(int k = 0;nfa_table[i][j][k]!=-1;k++){
					printf("%d ",nfa_table[i][j][k]);
				}
				printf("\t\t");
			}
			printf("\n");
		}
	}
}

void read_specification(){
	char error[100];						//to read the unnecessary letter from the file
	FILE* f = fopen("specification.txt","r");

			//Allocating memory
	state = (int*)malloc(sizeof(int)*num_state);
	final = (int*)malloc(sizeof(int)*num_final);
	input_element = (int*)malloc(sizeof(int)*(num_input));

			//reading state from file
	for(int i = 0;i<num_state;i++){
		fscanf(f,"%d", &state[i]);
	}

			//Reading Final State from file
	for(int i = 0;i<num_final;i++){
		fscanf(f,"%d", &final[i]);
	}
	
			//Reading Input symbol from file
	for(int i = 0;i<num_input;){
		input_element[i] = fgetc(f);
		if(input_element[i] == ' '||input_element[i]=='\n'||input_element[i] == '\t')continue;
		i++;
		
	}

	fgets(error,100,f); //read previous /n
//	fgets(error,100,f);					//this line of specification.txt file is not requred
//	puts(error);

			//IF THE DFA THEN ALLOCATING MEMORY TO DFA TABLE ONLY AND ALSO INITIALIZE THIS TABLE
			//ELSE DO THIS FOR NFA TABLE
	if(dfa){
		dfa_table = (int**)malloc(sizeof(int*)*(num_state));
		for(int i =0;i<num_state;i++){
			dfa_table[i] = (int*)malloc(sizeof(int)*num_input);
		}
		for(int i = 0;i<num_state;i++){
//			int temp2;
//			fscanf(f,"%d",&temp2);					//don't need the first state of each row
			for(int j = 0;j<num_input;j++){
				char temp[100];
				fscanf(f,"%s",temp);
				if(strcmp(temp,"^"))
					dfa_table[i][j] = atoi(temp);
				else
					dfa_table[i][j] = -1;
			}
		}
	}else{
		nfa_table = (int***)malloc((num_state)*sizeof(int**));
		for(int i = 0;i<num_state;i++)
			nfa_table[i] = (int**)malloc(sizeof(int*)*(num_input+1));

		
		for(int i = 0;i<num_state;i++){
//			int temp2;
//			fscanf(f,"%d",&temp2);
			for(int j = 0;j<=num_input;j++){
				int temp_state = 0,index = 0;
				char temp_input[100];
				fscanf(f,"%s",temp_input);
				int temp_element = countElement(temp_input);
				nfa_table[i][j] = (int*)malloc(sizeof(int)*(temp_element+1));			//last element is -1 to check end of the table
				for(int k=0;;k++){
					if(temp_input[k]=='\0'){
						nfa_table[i][j][index++] = temp_state;
						nfa_table[i][j][index++] = -1;
						temp_state = 0;break;
					}else if(temp_input[k] == '^'){
						nfa_table[i][j][index++] = -1;
						nfa_table[i][j][index] = -1;
						break;
					}
					if(temp_input[k]==','){
						nfa_table[i][j][index++] = temp_state;
						temp_state = 0;
					}else if(temp_input[k]<='9' && temp_input[k]>='0'){
						temp_state = temp_state*10 + temp_input[k]-'0';				
					}
				}
			}
		}		
	}
	fclose(f);
}

			//THIS FUNCTION CHECK, IF THE PATTERN MATCHES OR NOT, BY COMPARING CURRENT STATE TO THE LIST OF FINAL STATE
void done(){
	if(dfa){
		for(int i = 0;i<num_final;i++){
			if(final[i] == dfa_current_state){
				printf("MATCHED\n");
				return ;
			}
		}
	}else{
		for(int i = 0;i<num_final;i++){
			if(nfa_next_state[final[i]] == 1){
				printf("MATCHED\n");
				return ;
			}
		}
	}
	printf("ERROR\n");
}


			//THIS FUNCTION UPDATE THE CURRENT STATE USING THE TRANSITION TABLE
void update_current_state(char c){
	if(dfa){
		for(int i =0;i<num_input;i++){
			if(c==input_element[i]){
				dfa_current_state = dfa_table[dfa_current_state][i];
				return ;
			}
		}
	}else{
		for(int i = 0;i<num_state;i++){
			nfa_current_state[i] = nfa_next_state[i];
			nfa_next_state[i] = 0;
		}
		for(int i=0;i<num_input;i++){
			if(c==input_element[i]){
				for(int j = 0;j<num_state;j++){
					if(nfa_current_state[j] == 1){
						for(int k = 0;nfa_table[j][i][k]!=-1;k++){
							e_closure(nfa_table[j][i][k]);
							for(int l=0;l<num_state;l++)
								if(kleen_closure[l] == 1){
									nfa_next_state[l] = 1;
								}
						}
					}
				}		

			}
		}
		return ;
	}
			//User input char which are not listed in the input_element
	printf("\nYour are not supposed to enter input other than given.\n");
	exit(0);
}

void e_closure(int _state){
	for(int i = 0;i<num_state;i++)
		if(i == _state)
			kleen_closure[i] = 1;
		else
			kleen_closure[i] = 0;

	Stack *s1 = create_stack(num_state+2);

	for(int i = 0;nfa_table[_state][num_input][i] != -1;i++){
		if(kleen_closure[nfa_table[_state][num_input][i]]!=1){
			push(s1,nfa_table[_state][num_input][i]);
			kleen_closure[nfa_table[_state][num_input][i]] = 1;
		}
	}
	while(!empty(s1)){
		_state = pop(s1);
		for(int i = 0;nfa_table[_state][num_input][i] != -1;i++){
			if(kleen_closure[nfa_table[_state][num_input][i]]!=1){
				push(s1,nfa_table[_state][num_input][i]);
				kleen_closure[nfa_table[_state][num_input][i]] = 1;
			}
		}
	}
	
}
