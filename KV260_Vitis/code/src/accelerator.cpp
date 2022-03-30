#include "accelerator.h"

#include "time.h"

#define KG_REG_ADDR 0xA0000000
#define KG_GRAPH_ADDR 0X25000000
#define KG_RESULT_ADDR 0X3F000000

#define REG_SIZE 4096UL
#define REG_MASK (REG_SIZE - 1)
#define KG_SIZE    0x1000000
#define KG_MASK    KG_SIZE - 1


#define SLV_REG0_OFFSET (0*4)
#define SLV_REG1_OFFSET (1*4)
#define SLV_REG2_OFFSET (2*4)
#define SLV_REG3_OFFSET (3*4)

#define KGRAPH_FILE      "kv260_out_end.bin"
#define KGRAPH_SIZE       12800512
#define KGRAPH_RESULT_SIZE 2000

void *reg_vaddr, *kg_graph_vaddr, *kg_result_vaddr, *ptr;
unsigned int KGraph_Result[500];


void KGraph_Open()
{
	reg_vaddr       = (void *)get_vaddr(KG_REG_ADDR, REG_SIZE, REG_MASK);
	kg_graph_vaddr  = (void *)get_vaddr(KG_GRAPH_ADDR, KG_SIZE, KG_MASK);
	kg_result_vaddr = (void *)get_vaddr(KG_RESULT_ADDR, KG_SIZE, KG_MASK);

	printf("------kgraph weight map start--------\n");
    /********************weight map***************************/
	if(kgraph_memcpy(kg_graph_vaddr)==-1){
		printf("------kgraph weight map fail-----\n");
		exit;
		//return -1;
	}
	printf("------kgraph weight map end-----------\n");
}

void KGraph_Close()
{
    // unmap the memory before exiting
    if (munmap(reg_vaddr, REG_SIZE) == -1 || munmap(kg_graph_vaddr, KG_SIZE) == -1 || munmap(kg_result_vaddr, KG_SIZE) == -1) {
        printf("Can't unmap memory from user space.\n");
        exit(0);
    }

	printf("------Accelerator is end------------\n\r");
}

unsigned int * Run_KGraph(uint64_t hash_code)
{
	unsigned int* KGraph_Res = new unsigned int[500];
	//write_reg(SLV_REG1_OFFSET, 0xc7d8d870);
	//write_reg(SLV_REG2_OFFSET, 0x6c110000);

	write_reg(SLV_REG1_OFFSET, (uint32_t)(hash_code >> 32));  //00f937ae2973 train code googlenet
	write_reg(SLV_REG2_OFFSET, (uint32_t)(hash_code));  //7d31015c8ade

	write_reg(SLV_REG3_OFFSET, 0x000000C8);
	printf("------Accelerator start---------------\n");
	write_reg(SLV_REG0_OFFSET, 0x00000002);
	write_reg(SLV_REG0_OFFSET, 0x00000000);
	usleep(10000);
	int j = 0;
	while(1)
	{
		//printf("0x%08x\n", read_reg(SLV_REG0_OFFSET));
		if(read_reg(SLV_REG0_OFFSET) == 0x00000000)
		{
			printf("----acceleartor end------\n");
			break;
		}
	}
   	ptr = memcpy(KGraph_Res,kg_result_vaddr,KGRAPH_RESULT_SIZE);
	printf("result:");
	int i=0;
	for(i=0;i<100;i++) {
		printf("result=%d\n",KGraph_Res[i]);
	}

	return KGraph_Res;
}




int accelerator_init()
{
	reg_vaddr       = (void *)get_vaddr(KG_REG_ADDR, REG_SIZE, REG_MASK);
	kg_graph_vaddr  = (void *)get_vaddr(KG_GRAPH_ADDR, KG_SIZE, KG_MASK);
	kg_result_vaddr = (void *)get_vaddr(KG_RESULT_ADDR, KG_SIZE, KG_MASK);

	printf("------kgraph weight map start--------\n");
    /********************weight map***************************/
	if(kgraph_memcpy(kg_graph_vaddr)==-1){
		printf("------kgraph weight map fail-----\n");
		return -1;
	}
	printf("------kgraph weight map end-----------\n");

	printf("------input hash code and User K------\n");

	//write_reg(SLV_REG1_OFFSET, 0xc7d8d870);
	//write_reg(SLV_REG2_OFFSET, 0x6c110000);

	write_reg(SLV_REG1_OFFSET, 0x084eabf7);
	write_reg(SLV_REG2_OFFSET, 0x1d780000);

	write_reg(SLV_REG3_OFFSET, 0x000000C8);
	clock_t start = clock();
	printf("------Accelerator start---------------\n");
	write_reg(SLV_REG0_OFFSET, 0x00000002);
	write_reg(SLV_REG0_OFFSET, 0x00000000);
	int j = 0;
	while(1)
	{
		printf("0x%08x\n", read_reg(SLV_REG0_OFFSET));
		if(read_reg(SLV_REG0_OFFSET) == 0x00000000)
		{
			printf("----acceleartor end------\n");
			break;
		}
	}
	clock_t end = clock();
	printf("execution time=%f\n", (double)(end-start)/CLOCKS_PER_SEC);
	usleep(10000);
	printf("0x%08x\n", read_reg(SLV_REG0_OFFSET));
   	ptr = memcpy(KGraph_Result,kg_result_vaddr,KGRAPH_RESULT_SIZE);
	printf("result:");
	int i=0;
	for(i=0;i<100;i++) {
		printf("result=%d\n",KGraph_Result[i]);
	}
    // unmap the memory before exiting
    if (munmap(reg_vaddr, REG_SIZE) == -1 || munmap(kg_graph_vaddr, KG_SIZE) == -1 || munmap(kg_result_vaddr, KG_SIZE) == -1) {
        printf("Can't unmap memory from user space.\n");
        exit(0);
    }

	printf("------Accelerator is end------------\n\r");
	printf("\n");


}

void * get_vaddr(uint32_t BASE_ADDR, uint32_t SIZE,uint32_t MASK)
{
    printf("== START: AXI FPGA test ==\n");

    int memfd;
    void *mapped_base, *mapped_dev_base;
    off_t dev_base = BASE_ADDR;

    memfd = open("/dev/mem", O_RDWR | O_SYNC);
        if (memfd == -1) {
        printf("Can't open /dev/mem.\n");
        exit(0);
    }

    printf("/dev/mem opened.\n");

    // Map one page of memory into user space such that the device is in that page, but it may not
    // be at the start of the page.
    mapped_base = mmap(0, SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, memfd, dev_base & ~MASK);
        if (mapped_base == (void *) -1) {
        printf("Can't map the memory to user space.\n");
        exit(0);
    }
    printf("Memory mapped at address %p.\n", mapped_base);

    // get the address of the device in user space which will be an offset from the base
    // that was mapped as memory is mapped at the start of a page
    mapped_dev_base = mapped_base + (dev_base & MASK);

    return mapped_dev_base;
}

unsigned int write_reg(int reg_num, unsigned int reg_value){

	*((volatile uint32_t *) (reg_vaddr + reg_num)) = reg_value;

	return 0;
}

unsigned int read_reg(int reg_num){

	return *((volatile uint32_t *) (reg_vaddr + reg_num));
}


int kgraph_memcpy(void *ptr){
	FILE *file_in;
	file_in  = fopen(KGRAPH_FILE,"r");
	if(file_in==NULL){
		printf("open file_in error!\n");
		return -1;
	}
	printf("---------1--------------\n");
	char *w = (char*)malloc(KGRAPH_SIZE);
	if(!w)
	   printf("kgraph error\n");
	printf("---------2--------------\n");
	fread(w,1,KGRAPH_SIZE,file_in);
	printf("---------3--------------\n");
	clock_t start,end;
	start = clock();
	printf("---------4--------------\n");
	ptr = memcpy((ptr),w,KGRAPH_SIZE);
	printf("---------5--------------\n");
	free(w);
	end = clock();
	printf("kgraph weight memcpy success: time=%lf\n",(double)(end-start)/CLOCKS_PER_SEC);
	return 0;
}
