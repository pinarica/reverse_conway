#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "png_util.h"
#define MAX_N 200 
#define CUDA_CALL(x) {cudaError_t cuda_error__ = (x); if (cuda_error__) printf("CUDA error: " #x " returned \"%s\"\n", cudaGetErrorString(cuda_error__));}

int n;
char* plate[2];
int which=0;

__global__ void cu_iteration(char * d_memblock,int n, int which)
{ 
   int threadn = blockDim.x * blockIdx.x + threadIdx.x;
   int i = threadn / n + 1;
   int j = threadn % n + 1; 
   int index = i * (n+2) + j; 

   if (i > n)
      return;
   if (j > n)
      return;

   char* cu_plate[2];
   cu_plate[0] = &d_memblock[0];
   cu_plate[1] = &d_memblock[(n+2)*(n+2)];

   int num = (cu_plate[which][index - n - 3]
        + cu_plate[which][index - n - 2]
        + cu_plate[which][index - n - 1]
        + cu_plate[which][index - 1]
        + cu_plate[which][index + 1]
        + cu_plate[which][index + n + 1]
        + cu_plate[which][index + n + 2]
        + cu_plate[which][index + n + 3]); 

   if(cu_plate[which][index]==1)
   {	
       cu_plate[!which][index] = (char) (num == 2 || num == 3) ?  1 : 0;
   } else {
       cu_plate[!which][index] = (char) (num == 3);
   }
}

void print_plate(){
    if (n < 60) {
        for(int i = 1; i <= n; i++){
            for(int j = 1; j <= n; j++){
                printf("%d", (int) plate[which][i * (n + 2) + j]);
            }
            printf("\n");
        }
    } else {
	printf("Plate too large to print to screen\n");
    }
    printf("\0");
}

void plate2png(const char filename[]) {
    unsigned char * img = (unsigned char *) malloc(n*n*sizeof(unsigned char));

    printf(filename);
    printf("\n");

    image_size_t sz;
    sz.width = n;
    sz.height = n; 

    for(int i = 1; i <= n; i++){
        for(int j = 1; j <= n; j++){
            int pindex = i * (n + 2) + j;
            int index = (i-1) * (n) + j;
            if (plate[!which][pindex] > 0)
		img[index] = (unsigned char) 255; 
            else 
		img[index] = (unsigned char) 0;
        }
    }
    write_png_file((char *) filename,img,sz);
    free(img);
    
}

int main() { 
    int M;
    struct cudaDeviceProp properties;
    cudaGetDeviceProperties(&properties, 0);
    printf("using %d multiprocessors\n",properties.multiProcessorCount);
    printf("max threads per processor: %d \n\n",properties.maxThreadsPerMultiProcessor);
    printf("max threads per block: %d \n\n",properties.maxThreadsPerBlock);
    n = 0;
    if(scanf("%d %d", &n, &M) == 2){
        int random=0;
        if (n == 0) { 
           n = MAX_N;
           random=1;
        }
        //Allocate memory for plates
        int arrlen = (n+2) * (n+2);
	int nBytes = sizeof(char)*arrlen;
        char *  memblock= (char *) malloc(nBytes*2);
        char *  d_memblock;
        plate[0] = (char *) &memblock[0];          
        plate[1] = (char *) &memblock[arrlen];          

        for(int k=0;k < 2*arrlen;k++)
		memblock[k] = (char) 0;

        char line[n];
        printf("Reading in %dx%d plate and running %d iterations\n",n,n,M);
        if (!random) {
            printf("reading plate in from standard input\n");
            for(int i = 1; i <= n; i++) {
                scanf("%s", &line);
                for(int j = 0; j < n; j++) {
                    plate[which][i * (n+2) + j + 1] = (char) line[j] - '0';
                }
            }
	} else {
            printf("generating random plate\n");
 	    for(int i = 1; i <= n; i++) 
                for(int j = 0; j < n; j++) { 
                   plate[which][i * (n+2) + j + 1] = rand() % 2;
                }
	}
        printf("Reading in %dx%d plate and running %d iterations\n",n,n,M);
	print_plate();

        int num_threads = min(properties.maxThreadsPerBlock,n*n);
        int num_blocks = ceil((double) n*n/ (double) num_threads);
        dim3 numThreads(num_threads,1,1);
        dim3 numBlocks(num_blocks,1,1);

        printf("totalCells=%d nBytes=%d num_threads=%d, num_blocks=%d\n",n*n, nBytes,num_threads,num_blocks);
	
	//CUDA Memory Copy
	CUDA_CALL(cudaMalloc((void **) &d_memblock, nBytes*2));
	
   	printf("Copying to device..\n");
	CUDA_CALL(cudaMemcpy(d_memblock, memblock, nBytes*2, cudaMemcpyHostToDevice));
   	printf("Running Simulation...\n");
        for(int i = 0; i < M; i++){
            //CUDA Kernel Call
  	    printf("Iteration %d of %d\n",i,M);
            cu_iteration<<<numBlocks, numThreads>>>(d_memblock, n, which);
	    cudaError_t errSync  = cudaGetLastError();
	    cudaError_t errAsync = cudaDeviceSynchronize();
            if (errSync != cudaSuccess) 
  		printf("Sync kernel error: %s\n", cudaGetErrorString(errSync));
            if (errAsync != cudaSuccess)
  		printf("Async kernel error: %s\n", cudaGetErrorString(errAsync));
	    which=!which;
        }
	//CUDA Memory Copy
 	printf("Copying results to host..\n");   
	CUDA_CALL(cudaMemcpy(memblock, d_memblock, nBytes*2, cudaMemcpyDeviceToHost));
 
	plate2png("plate.png");
	print_plate();
    } else {
	printf("Input Format error on line 1\n");
    }
    return 0;
}
