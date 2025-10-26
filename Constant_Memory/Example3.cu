%%writefile freq_from_file.cu
#include <stdio.h>
#include <cuda_runtime.h>

// 100x10 constant array on GPU
__constant__ int d_ConstData[100][10];

__global__ void kernel(int *doubleArr)
{
    int row = blockIdx.x;
    int col = threadIdx.x;
    int idx = row * blockDim.x + col;  // flat index: 0..999

    doubleArr[idx] = d_ConstData[row][col] * 2;
}

int main()
{
    int hostData[100][10];

    // fill hostData
    for (int i = 0; i < 100; i++) {
        for (int j = 0; j < 10; j++) {
            hostData[i][j] = i;
        }
    }

    // Copy to constant memory
    cudaMemcpyToSymbol(d_ConstData, hostData, sizeof(hostData));

    // Allocate output array (flat)
    int *d_Data;
    cudaMalloc(&d_Data, 100 * 10 * sizeof(int));

    // Launch kernel
    kernel<<<100, 10>>>(d_Data);
    cudaDeviceSynchronize();

    // Copy result back
    int hostResult[100][10];
    cudaMemcpy(hostResult, d_Data, sizeof(hostResult), cudaMemcpyDeviceToHost);

    // Print results
    for (int i = 0; i < 100; i++) {
        for (int j = 0; j < 10; j++) {
            printf("%d ", hostResult[i][j]);
        }
        printf("\n");
    }

    cudaFree(d_Data);
    return 0;
}
