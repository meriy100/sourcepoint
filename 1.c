#include <stdio.h>
#include <math.h>

int main(void);

int josephus(int n) {
    if (n <= 1) {
        return (1);
    } else if ((n % 2) != 0) {
        return (2 * josephus(n/2) - 1);
    } else {
        return (2 * josephus(n/2) + 1);
    }
}

int main(void) {
    int n;
    
    while (scanf("%d", &n ) != EOF) {
        printf("%d\n", josephus(n));
    }
    return (0);
}
