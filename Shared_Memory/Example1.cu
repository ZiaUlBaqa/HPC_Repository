%%writefile freq_from_file.cu
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#define arraysize 10000


//This was actually very slow as it was doing redundzant work by doing global -> shared ->global yaaa bakrrr whaaa????



__global__ void kernel1(int * array)
{
    __shared__ int s_array[arraysize];
    int thread_id = blockIdx.x * blockDim.x + threadIdx.x;

    if(thread_id < arraysize)
    {
        s_array[thread_id] = array[thread_id];
        __syncthreads();

        s_array[thread_id] += 1;

        //copying it back

        array[thread_id] = s_array[thread_id];
    }
}

__global__ void kernel2(int * array)
{

    int thread_id = blockIdx.x * blockDim.x + threadIdx.x;
    if(thread_id < arraysize)
        array[thread_id] +=1;
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