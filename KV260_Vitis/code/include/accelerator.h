#ifndef SRC_ACCELERATOR_H_

#define SRC_ACCELERATOR_H_
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <time.h>
#include "../include/accelerator.h"
#include <unistd.h>

void * get_vaddr(uint32_t BASE_ADDR, uint32_t SIZE,uint32_t MASK);
unsigned int write_reg(int reg_num, unsigned int reg_value);
unsigned int read_reg(int reg_num);
int kgraph_memcpy(void *ptr);

void KGraph_Open();
void KGraph_Close();
unsigned int * Run_KGraph(uint64_t hash_code);
int accelerator_init();

#endif /* SRC_ACCELERATOR_H_ */
