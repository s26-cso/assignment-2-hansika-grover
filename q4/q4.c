#include <stdio.h> //for scanf,printf
#include <stdlib.h> // general utilities
#include <string.h> //for snprintf
#include <dlfcn.h> //for dlopen,dlsym,dlclose

int main() {
    char op[8]; // stores op name, extra characters for safety
    int a, b; //operands

    //loop until eof/end of input
    while (scanf("%7s %d %d", op, &a, &b) != EOF) {
        char libname[32]; //buffer to store lib name

        //to construct lib name
        snprintf(libname, sizeof(libname), "lib%s.so", op);

        //dynamically load shared lib at runtime
        void *handle = dlopen(libname, RTLD_NOW);

        //error hndling if loading fails
        if (!handle) {
            fprintf(stderr, "Error: %s\n", dlerror());
            continue;
        }

        dlerror(); // clear old errors

        // gets ptr to fn,cast it to fn ptr
        int (*func)(int, int) = (int (*)(int, int)) dlsym(handle, op);

        //to check if dlysm causer error
        char *err = dlerror();
        if (err != NULL) {
            fprintf(stderr, "Error: %s\n", err);
            dlclose(handle);
            continue;
        }

        //call fn with inputs a and b
        int result = func(a, b);

        //print result
        printf("%d\n", result);

        //close/unload shared lib
        dlclose(handle);
    }

    return 0;
}
