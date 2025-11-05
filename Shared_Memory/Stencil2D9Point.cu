%%writefile freq_from_file.cu
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>


#define N 64
#define Radius 1
#define rows 16
#define cols 8 

__global__ void stencil(int * in, int * out)
{
    __shared__ int mem[rows + 2 * Radius][cols + 2 * Radius];

    //global indexes of the thread
    int globalx = blockDim.x * blockIdx.x + threadIdx.x;
    int globaly = blockDim.y * blockIdx.y + threadIdx.y;

    //local indexes of the thread
    int localx = threadIdx.x + Radius;
    int localy = threadIdx.y + Radius;

    //copying the data into relevent indexes
    mem[localy][localx] = in[globaly * N + globalx];

    //loading the halo cells
    if (threadIdx.x == 0 && globalx > 0)
        mem[localy][localx - 1] = in[globaly * N  + (globalx - 1)];

    if (threadIdx.x == blockDim.x - 1 && globalx < N - 1)
        mem[localy][localx + 1] = in[globaly * N + (globalx + 1)];

    if (threadIdx.y == 0 && globaly > 0)
        mem[localy - 1][localx] = in[(globaly - 1) * N + globalx];

    if (threadIdx.y == blockDim.y - 1 && globaly < N - 1)
        mem[localy + 1][localx] = in[(globaly + 1) * N + globalx];

    //loading the corner halo cells


    __syncthreads();

    int value = mem[localy][localx]; // self
    int left = (globalx > 0) ? mem[localy][localx - 1] : value;
    int right = (globalx < N - 1) ? mem[localy][localx + 1] : value;
    int up = (globaly > 0) ? mem[localy - 1][localx] : value;
    int down = (globaly < N - 1) ? mem[localy + 1][localx] : value;
    out[globaly * N + globalx] = (value + left + right + up + down) / 5;

    //the above portion has been done because if we are at the left most block, there is no 
    //more data to be left on left halo
    //if we leave them uninitialized tis will lead to garbage val, which is why we have to use custom values
    //the cells own value for this case


}



int main()
{
    int h_arr[N*N];
    for(int i=0; i< N*N; i++)
    {
        h_arr[i] = i;
    }
    int *d_add_in;
    cudaMalloc(&d_add_in, N*N*sizeof(int));
    cudaMemcpy(d_add_in , h_arr, N*N*sizeof(int), cudaMemcpyHostToDevice);
    int * d_arr_out;
    cudaMalloc(&d_arr_out, N*N*sizeof(int));
    cudaMemset(d_arr_out,0,N*N*sizeof(int));
    dim3 gridDims(4,8);
    dim3 blockDims(8,16);

    stencil<<<gridDims,blockDims>>>(d_add_in,d_arr_out);
    cudaMemcpy(h_arr,d_arr_out, N*N*sizeof(int), cudaMemcpyDeviceToHost);
    

}