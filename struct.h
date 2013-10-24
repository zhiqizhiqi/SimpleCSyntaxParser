typedef struct _node {
	char* content;
	char* token;
	struct _node *next;
	struct _node *child;
} Node;
