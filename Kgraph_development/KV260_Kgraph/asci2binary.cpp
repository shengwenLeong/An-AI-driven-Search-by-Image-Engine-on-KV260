#include <iostream>
#include <fstream>
#include <stdio.h>

using namespace std;

#define in_name "input.txt"
#define out_name "input.bin"
#define buffersize 65 
#define datasize (buffersize-1)/2

void charArray2intArray(char* charArray,char* intArray);

int main(){
	ifstream in(in_name) ;
	ofstream out (out_name,ios::binary|ios::trunc);
        char buffer[buffersize];
	char data[datasize];
	if(!in.is_open()){
		cout<<"Error opening file"<<endl;
	        return 1;
        }
  	else {
     		while(!in.eof()){
          		in.getline(buffer,buffersize);
			*(buffer+buffersize-1)='\0';
			charArray2intArray(buffer,data);  // char to int /binary
/*			cout<<"char:"<<buffer<<endl;
			cout<<"int :";
			for(int i=0;i<datasize;i++){
				printf("%x",data[i]);
			}
			cout<<endl;
*/	  		out.write(data,datasize);
 	   	}
	}
  	in.close();
	out.close();
	cout<<in_name<<" to "<<out_name<<" success! "<<endl;
	return 0;
}

//char array to 8bit intarray
void charArray2intArray(char* charArray,char* intArray){

	int i=0;char temp=0; int j=0;
	while(*(charArray+i)!='\0'){
		if(*(charArray+i)>='0' && *(charArray+i) <='9'){
			temp=*(charArray+i)-'0';
		}
		else if(*(charArray+i)>='a' && *(charArray+i)<='f'){
			temp=*(charArray+i)-'a'+10;
		}
		else if(*(charArray+i)>='A' && *(charArray+i)<='F'){
			temp=*(charArray+i)-'A'+10;
		}
		if(i%2==0){
			*(intArray+j) =temp<<4;
//			printf("%x ",*(intArray+j));
		}
		else {
			*(intArray+j) |=temp&0x0f;
//			printf("%x ",*(intArray+j));
			j++;
		}
		i++;
		
	}
}
