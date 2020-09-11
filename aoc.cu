#define block_size = 4
#define raio = 2
#define n = 12

__global__ void foo(int *input, int *output ) {

  /*shared: compartilha com a memoria global*/
  __shared__ int temp[block_size+(raio*2)];
  int ind_global = blockIdx.x * blockDim.x + threadIdx.x;

  //copia o meio para temp
  input[ind_local] = threadIdx.x + raio;
  temp[ind_local] = input[ind_global];

  //copia os dois adjacentes para temp
  if(threadIdx.x < raio){
    if(ind_local - raio >= 0){
      temp[ind_local - raio] = input[ind_global - raio];
    }
    if(ind_local + block_size < n){
      temp[ind_local + block_size] = input[ind_global + block_size];
    }
  }

  __syncthreads();
  //atualizar as entradas
  int soma = 0;
  for(int i = 0; i < ind_local - raio; i++){
    if(ind_local - raio + i >= 0 && ind_local - raio + 1 <= n)
      soma += temp[ind_local - raio + i];
  }
    output[ind_global] = soma;
}

int main (void){
  int num_blocos = 3, num_threads = 4;
  int input[12] = {1,3,2,1,0,2,4,1,5,3,2,4};

  cudaMalloc((void**)&dev_input, n*sizeof(int));
  cudaMalloc((void**)&dev_output, n*sizeof(int));
  cudaMemcpy(dev_input, input, n*sizeof(int));
  cudaMemcpy(dev_output, output, n*sizeof(int), cudaMemcpyHostToDevice);
  foo <<< num_blocos, num_threads >>> (dev_input, dev_output);
  cudaMemcpy(output, dev_output, cudaMemcpyDeviceToHost);

  for (int i = 0; i < n; i++){
    printf("%d\n", output[i]);
  }
}
//usr/local/cuda-8.0/bin/nvcc
