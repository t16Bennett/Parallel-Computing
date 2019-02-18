#include <cilk/cilk.h>
#include <cilk/cilk_api.h>
#include <stdlib.h>
#include <iostream>
#include <time.h>
//#include <chrono>
//#include <pthread.h>

/*
Thomas Bennett
Parallel Array Maximum and Sum
*/
using namespace std;

int find_sum(int* arr, int base, int n, int &max){
	if(n<100000){
		int sum = 0;
		//pthread_mutex_t m;
		for(int i = base; i < base+n; i++){
			if(arr[i]>max){
				//pthread_mutex_lock(&m);
				max = arr[i];
				//pthread_mutex_unlock(&m);
			}
			sum = sum + arr[i];
		}
		return sum;
	}
	else{
		int n1;
		int n2;
		if(n % 2 == 0){
			n1 = cilk_spawn find_sum(arr, base, n/2, max);
			n2 = find_sum(arr, base+n/2, n/2, max);
			cilk_sync;
		}
		else{
			n1 = cilk_spawn find_sum(arr, base, n/2, max);
			n2 = find_sum(arr, base+n/2, (n/2)+1, max);
			cilk_sync;
		}
		return n1+n2;
	}
}

int main(int argc, char **argv){
	srand(time(NULL));
	int size = atoi(argv[1]);
	int* arr = new int[size];
	for(int i = 0; i < size; ++i){
		arr[i] = rand() % 1000 + 1;
	}
	//auto start = chrono::steady_clock::now();
	//auto end = chrono::steady_clock::now();
	//auto diff = start - end;
	//start = chrono::steady_clock::now();
	int max = 0;
	int sum = find_sum(arr, 0, size, max);
	//end = chrono::steady_clock::now();
	//diff = end - start;
	cout << "Maximum: " << max << "; Sum: " << sum << endl;
	//cout << "Time: " << chrono::duration <double,milli> (diff).count() << endl;
	return 0;
}
