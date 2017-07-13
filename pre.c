#include <stdio.h>

#define maxStudents 10

typedef struct {
	int english;
	int math;
} data;

void calcAve(data a[], double *eng, double *math, double *total);
int main(void)
{
    data students[maxStudents];
    double mathAve, engAve, totalAve;
    
    int i=0;
    
    while (i<maxStudents) {
        if (scanf("%d %d", &students[i].english, &students[i].math) != 2)
            break;
        i++;
    }
    students[i].english = students[i].math = -1;
    
    calcAve(students,&engAve,&mathAve,&totalAve);
    
    printf ("English average is %6.2f\n", engAve);
    printf ("Math    average is %6.2f\n", mathAve);
    printf ("Total   average is %6.2f\n", totalAve);

    return 0;
}

void calcAve(data a[], double *eng, double *math, double *total)
{
	int i=0;
	*eng=0.0;
	*math=0.0;
	*total=0.0;
	while (a[i].english != -1) {
		*eng+=a[i].english;
		*math+=a[i].math;
		*total+=(a[i].english+a[i].math);
		i++;
	}
	*eng/=i;
	*math/=i;
	*total/=(i*2);
}
