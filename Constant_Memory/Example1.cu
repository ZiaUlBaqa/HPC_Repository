%%writefile freq_from_file.cu
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
 __constant__ int d_ConstData[100]; //constant mem in GPU

__global__ void kernel()
{
    printf("%d ", d_ConstData[threadIdx.x]);
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


  cudaMemcpyToSymbol(d_ConstData,hostData,400);

  kernel<<<1,100>>>();

  cudaDeviceSynchronize();

  return 0;

}