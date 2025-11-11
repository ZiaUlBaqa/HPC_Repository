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

    //we have not loaded the corner most halos as they were not being used rxn scn mun wekh apna kallu kaleyaa

    __syncthreads();

    if (globalx > 0 && globalx < N - 1 &&
        globaly > 0 && globaly < N - 1) {
        out[globaly * N + globalx] =
            (mem[localy][localx] +
            mem[localy + 1][localx] +
            mem[localy - 1][localx] +
            mem[localy][localx + 1] +
            mem[localy][localx - 1]) / 5;
    }


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