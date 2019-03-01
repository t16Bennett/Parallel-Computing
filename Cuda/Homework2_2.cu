/*
	Homework Assignment 2-2
	Thomas Bennett
*/
#include <iostream>
#include <stdio.h>
#include <stdlib.h>

using namespace std;

__global__ void transpose(char* matrix, char* tMatrix, int m, int n){
	int i = blockDim.x * blockIdx.x + threadIdx.x;
	if(i<(m*n)){
		tMatrix[i] = matrix[(i/m)+(i%m)*n];
	}
}

int main(int argc, char** argv){
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
		}

		char* tMatrix = (char*)malloc(sizeof(char)*m*n);
		char* gmatrix;
		cudaMalloc(&gmatrix,sizeof(char)*m*n);
		char* gtMatrix;
		cudaMalloc(&gtMatrix,sizeof(char)*m*n);
		cudaMemcpy(gmatrix,matrix,sizeof(char)*m*n, cudaMemcpyHostToDevice);
		int dimBlock = n;
		int dimGrid = m;
		transpose<<<dimGrid, dimBlock>>>(gmatrix,gtMatrix,m,n);

		cudaMemcpy(tMatrix, gtMatrix, sizeof(char)*m*n, cudaMemcpyDeviceToHost);
		for(int i = 0; i < n; i++){
			for(int j = 0; j < m; j++){
				cout << tMatrix[i*m+j] << " ";
			}
			cout << endl;
		}
		
		cudaFree(gmatrix);
		cudaFree(gtMatrix);
		free(buffer);
		free(matrix);
		free(tMatrix);
	}
	else cout << "Unable to open file";
	return 0;
}
