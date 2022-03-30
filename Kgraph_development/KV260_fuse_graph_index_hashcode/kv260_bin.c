/*************************************************************************
	> File Name: bin.c
	> Author: shengwenLeong 
	> Mail: liangshengwen@ict.ac.cn
	> Created Time: 2018年02月06日 星期二 20时38分22秒
 ************************************************************************/
#include<stdio.h>
#include<stdlib.h>
int main()
{
    FILE *input = fopen("kv260_init_input_data_test.bin","rb");
    FILE *output = fopen("kv260_out_temp.bin","wb");
    FILE *outa   = fopen("kv260_out_end.bin","wb");
    if(input==NULL||output==NULL)
    {
        printf("error \r\n");
    }
    fseek(input,0L,SEEK_END);
    int length = ftell(input);
    char *weight = (char *)malloc(length);
    char *weight_new = (char *)malloc(length+50002*6);
    rewind(input);
    fread(weight,length,1,input);
    printf("length is %d ", length);
    //fread(weight_new,length,1,output);
    int i,j,l;
    j=0;
    for(i=0;i<length;i++)
    {
        if(i%250==0&&(i!=0))
        {
            for(l=0;l<6;l++)
            {
                *(weight_new+j) = 0;
                j++;
            }
            *(weight_new+j) = *(weight+i);
            j++;
        }else
        {
            *(weight_new+j) = *(weight+i);
            j++;

        }
    }
    fwrite(weight_new,(length+50002*6),1,output);
    fclose(output);
    printf("\n---------stage 2------------\n");
    FILE *new_input = fopen("kv260_out_temp.bin","rb");
    fseek(new_input,0L,SEEK_END);
    int new_length = ftell(new_input);
    char *new_weight = (char *)malloc(new_length);
    char *new_weight_new = (char *)malloc(new_length);
    char *new_weight_change = (char *)malloc(new_length);
    rewind(new_input);
    fread(new_weight,new_length,1,new_input);
    for(i=0;i<new_length/4;i++) 
    {
        //printf("%02x ",*(weight+i));
        
        *(new_weight_new+4*i) = *(new_weight+4*i+3);
        *(new_weight_new+4*i+1) = *(new_weight+4*i+2);
        *(new_weight_new+4*i+2) = *(new_weight+4*i+1);
        *(new_weight_new+4*i+3) = *(new_weight+4*i);
    }
    j=0;
    printf("length is %d ",new_length);
    for(i=0;i<new_length/4;i++)
    {
        if(i%16==0&&i!=0)
            j=j+16;
        int one = j*8 + 60 - 4*i;
        int two = j*8 + 61 - 4*i;
        int three = j*8 + 62 - 4*i;
        int four  = j*8 + 63 - 4*i;
        *(new_weight_change+4*i) = new_weight_new[one];
        *(new_weight_change+4*i+1) = new_weight_new[two];
        *(new_weight_change+4*i+2) = new_weight_new[three];
        *(new_weight_change+4*i+3) = new_weight_new[four];
    }
    //fwrite(weight_new,(new_length),1,output);
    fwrite(new_weight_change,new_length,1,outa);
    fclose(input);
    fclose(new_input);
    fclose(outa);
    

}
