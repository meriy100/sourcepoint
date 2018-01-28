#include <stdio.h>

long factorial(int n) {
  if(n != 1){
    return (n * factorial(n-1));
  } else {
    return n;
  }
}

int main(void) {
  int i, n;
  long product = 1, result;
  scanf("%d", &n);
  result = factorial(n);
  printf("%d! = %ld\n", n, result);
  return 0;
}

