%%writefile freq_from_file.cu
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
 __constant__ int d_ConstData[100]; //constant mem in GPU
 //constant memory has to be decalred globally

__global__ void kernel(int * doubleArr)
{
    doubleArr[threadIdx.x] = d_ConstData[threadIdx.x] *  2;
}

int main()
{
  //In this example we will be utilizing constant memory of a gpu to perform some task.
  //We will be computing simple doubling of elements in an array

  int  hostData[100];
  for(int i=0; i<100; i++)
  {
    hostData[i] = i;
  }

  int * d_Data;
  cudaMalloc(&d_Data,400);


  cudaMemcpyToSymbol(d_ConstData,hostData,400);

  kernel<<<1,100>>>(d_Data);

  cudaMemcpy(hostData,d_Data,400,cudaMemcpyDeviceToHost);

  for(int i = 0 ; i < 100; i++)
  {
    printf("%d ", hostData[i]);
  }

  return 0;

}