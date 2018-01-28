#include <stdio.h>

long Fy ( int Ds )   { 
  if ( Ds  !=  1 )  { 
    return  ( Ds  *  Fy ( Ds - 1 )  )  ; 
   }  else  { 
    return Ds ; 
   } 
 } 

int main ( void )   { 
  int DH ,  DF ; 
  long DR  =  1 ,  Dc ; 
  scanf ( "%d" ,   & DF )  ; 
  Dc  =  Fy ( DF )  ; 
  printf ( "%d! = %ld\n" ,  DF ,  Dc )  ; 
  return 0 ; 
 } 