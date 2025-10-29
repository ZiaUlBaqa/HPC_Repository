%%writefile freq_from_file.cu
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
//constants
#define arraysize 1000000
#define BlockDim 1024
#define Halo 2


//This is example of stencil in 1D, ehhehehehehhe???



__global__ void kernel1(int * array)
{
    __shared__ int s_array[BlockDim + Halo];
    int thread_id = blockIdx.x * blockDim.x + threadIdx.x;

    if(thread_id < arraysize)
    {
        s_array[threadIdx.x+1] = array[thread_id];

        if(threadIdx.x == 0)
        {
            s_array[threadIdx.x] = s_array[threadIdx.x+1];
        }

        if(threadIdx.x == blockDim.x-1)
        {
            s_array[threadIdx.x+2] = s_array[threadIdx.x+1];
        }
        __syncthreads();

        //copying it back

        array[thread_id] = (s_array[threadIdx.x] + s_array[threadIdx.x+1] + s_array[threadIdx.x+2])/3 ;

    }
}

__global__ void kernel2(int * array)
{   int thread_id = blockIdx.x * blockDim.x + threadIdx.x;
    if(thread_id < arraysize)
    {
        array[thread_id] = (array[thread_id+1]+array[thread_id]+array[thread_id-1])/3;
    }
}

int main()
{
    int arr[arraysize];
    for(int i=0; i<arraysize; i++)
    {
        arr[i] = i;
    }

    int * d_arr;
    cudaMalloc(&d_arr,arraysize*sizeof(int));
    cudaMemcpy(d_arr,arr,arraysize*sizeof(int),cudaMemcpyHostToDevice);

    int * d_arr2;
    cudaMalloc(&d_arr2,arraysize*sizeof(int));
    cudaMemcpy(d_arr2,arr,arraysize*sizeof(int),cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    kernel1<<<977,1024>>>(d_arr);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms = 0;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Time: %.3f ms\n", ms);



    cudaEventRecord(start);
    kernel2<<<977,1024>>>(d_arr2);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    ms = 0;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Time: %.3f ms\n", ms);

    return 0;
}