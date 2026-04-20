#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main() {
    char op[8];
    int a, b;

    while (scanf("%7s %d %d", op, &a, &b) == 3) {
        char libname[32];

        snprintf(libname, sizeof(libname), "./lib%s.so", op);

        // FIX 1: use RTLD_LAZY
        void *handle = dlopen(libname, RTLD_LAZY);
        if (!handle) {
            fprintf(stderr, "Error: %s\n", dlerror());
            continue;
        }

        dlerror(); // clear

        int (*func)(int, int) = (int (*)(int, int)) dlsym(handle, op);

        char *err = dlerror();
        if (err) {
            fprintf(stderr, "Error: %s\n", err);
            dlclose(handle);
            continue;
        }

        int result = func(a, b);
        printf("%d\n", result);

        dlclose(handle); // IMPORTANT: free memory immediately
    }

    return 0;
}
