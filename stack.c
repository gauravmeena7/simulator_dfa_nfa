#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include "stack.h"

#define PRINT_ERROR 0

Stack* create_stack(int size){
	if(size <0 || size > INT_MAX){
		size = INT_MAX;
		if(PRINT_ERROR)printf("Provided size is too big so taking : %u\n",size);
	}

	Stack* new_stack = (Stack*)malloc(sizeof(Stack));
	new_stack->max_size = size;	
	new_stack->arr = (int*)malloc(size*sizeof(int));
	new_stack->curr = 0;
	return new_stack;
}

void delete_stack(Stack* stack){
	free(stack->arr);
	free(stack);
}

void clear(Stack* stack){
	stack->curr = 0;
}

_Bool empty(const Stack const * stack){
	return (stack->curr<1)? 1:0;
}

_Bool full(const Stack const * stack){
	return (stack->curr>=stack->max_size)? 1:0;
}

void push(Stack * stack,int new_element){
	if(full(stack)){
		if(PRINT_ERROR)printf("Stack is Full, can't insert.\n");
		return;
	}
	stack->arr[stack->curr++] = new_element;
	if(PRINT_ERROR)printf("Push : %d\n",new_element);
}

int pop(Stack* stack){
	if(empty(stack)){
		if(PRINT_ERROR)printf("Stack is Empty, can't pop.\n");
		return 0;
	}
	if(PRINT_ERROR)printf("Pop : %d\n",stack->arr[stack->curr-1]);
	return stack->arr[--(stack->curr)];
}

int top(const Stack const* stack){
	return stack->curr? stack->arr[stack->curr-1] : -1;
}

void print(const Stack const* stack){
	printf("%d\n",top(stack));
}
/*
int main(){
	Stack* stack = create_stack(5);
	pop(stack);
	print(stack);
	push(stack,'a');
	print(stack);
	push(stack,'b');
	print(stack);
	pop(stack);
	print(stack);
	push(stack,'b');
	push(stack,'c');
	push(stack,'d');
	push(stack,'e');
	print(stack);
	push(stack,'f');
	pop(stack);
	print(stack);
	push(stack,'g');
	print(stack);
	return 0;
}
*/
