#ifndef STACK_H
#define STACK_H

typedef struct{
	int* arr;
	unsigned max_size;
	int curr;
}Stack;

Stack* create_stack(int);
void delete_stack(Stack*);
void clear(Stack*);
_Bool empty(const Stack const *);
_Bool full(const Stack const *);
void push(Stack *, int);
int pop(Stack*);
int top(const Stack const*);
void print(const Stack const*);

#endif
