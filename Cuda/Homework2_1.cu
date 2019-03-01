/*
	Homework 2 Part 1
	Thomas Bennett
*/
#include <iostream>
#include <stdio.h>
#include <stdlib.h>

using namespace std;

__global__ void findOnes(char* matrix, float* count, int N){
	int i = blockDim.x * blockIdx.x + threadIdx.x;
	if(i < N){
		if(matrix[i]=='1'){
			atomicAdd(&count[0], 1.0f);	
		}
	}	
}

int main(int argc, char **argv){
	char * file = argv[1];
	FILE * myfile;
	long lSize;
	char * buffer;
	size_t result; 
	myfile = fopen(file, "rb");
	if(myfile!=NULL){
		fseek(myfile, 0, SEEK_END);
		lSize = ftell(myfile);
		rewind(myfile);
		buffer = (char *) malloc (sizeof(char)*lSize);
		result = fread(buffer,1,lSize,myfile);
		fclose(myfile);
		int n = (int) buffer[0] - 48;
		int m = (int) buffer[2] - 48; 
		char* matrix;
		matrix = (char *) malloc (sizeof(char)*m*n);
		for(int i = 0; i<m*n;i++){
			matrix[i] = buffer[i*2+4];
			//cout << matrix[i] << endl;
		}
		float* count = (float*)malloc(sizeof(float));
		char* gmatrix;
		cudaMalloc(&gmatrix, sizeof(char)*m*n);
		float* gcount;
		cudaMalloc(&gcount, sizeof(float));
		cudaMemcpy(gmatrix, matrix, sizeof(char)*m*n, cudaMemcpyHostToDevice);
		int dimBlock = n;
		int dimGrid = m;
		findOnes<<<dimGrid, dimBlock>>>(gmatrix,gcount,m*n);
		cudaMemcpy(count, gcount, sizeof(float), cudaMemcpyDeviceToHost);
		cout << count[0] << endl;
		cudaFree(gmatrix);
		cudaFree(gcount);
		free(buffer);
		free(count);
		free(matrix);
	}
	else cout << "Unable to open file";
	return 0;
}
