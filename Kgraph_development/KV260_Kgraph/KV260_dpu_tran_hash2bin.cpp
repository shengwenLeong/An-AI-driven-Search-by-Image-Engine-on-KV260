/*************************************************************************
	> File Name: tran_hash2bin.cpp
	> Author: 
	> Mail: 
	> Created Time: 2018年01月18日 星期四 15时00分54秒
 ************************************************************************/

#include<iostream>
#include<iomanip>
#include<vector>
#include<fstream>
#include<bitset>
#include<string>
#include<sstream>
#include<iterator>
#include<algorithm>
#include<string.h>
#include<random>
#include<boost/algorithm/string.hpp>
using namespace std;
#define buffersize 21 
#define datasize (buffersize-1)/2
#define FORMAT_NO_DIST 1
static char const *KGRAPH_MAGIC = "KNNGRAPH";
static unsigned constexpr KGRAPH_MAGIC_SIZE = 8;
static uint32_t constexpr SIGNATURE_VERSION = 2;


struct uint48_t{
    uint64_t data:48;
} __attribute__((packed));
template <typename RNG>
static void GenRandom (RNG &rng, unsigned *addr, unsigned size, unsigned N) {
    if (N == size) {
        for (unsigned i = 0; i < size; ++i) {
            addr[i] = i;
        }
            return;
    }
    for (unsigned i = 0; i < size; ++i) {
        addr[i] = rng() % (N - size);
    }
    sort(addr, addr + size);
    for (unsigned i = 1; i < size; ++i) {
        if (addr[i] <= addr[i-1]) {
            addr[i] = addr[i-1] + 1;
        }
    }
    unsigned off = rng() % N;
    for (unsigned i = 0; i < size; ++i) {
        addr[i] = (addr[i] + off) % N;
    }
}
void deleteAllMark(string &s, const string &mark)  
{  
    unsigned int nSize = mark.size();  
    while(1)  
    {  
        string::size_type pos = s.find(mark);  
        if(pos == string::npos)  
        {  
            return; 
        }  
        s.erase(pos, nSize);  
    }  
}
uint64_t set_bit(uint64_t bits, uint8_t pos, uint8_t value)
{
   uint64_t mask = 1LL << (63 - pos);
   if (value)
       bits |= mask;
   else
       bits &= ~mask;
   return bits;
}
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
void load_graph(char const *path , uint32_t extract_graph[50002][25])
{
    unsigned seed = 1998;
    mt19937 rng(seed);
    vector<unsigned> random(50);
    vector<uint32_t> init_ids(50);
    GenRandom(rng,&random[0],random.size(),50000);
    unsigned L = 0;
    for(unsigned s: random){
        init_ids[L++] = s;
        cout<<"init_ids="<<s<<endl;

    }
    for(int i=0;i<50;++i)
    {
        int row = i/25;
        int col = i%25;
        extract_graph[row][col] = init_ids[i];
    }
    vector<unsigned> M;
    //vector<vector<Neighbor>> graph;
    bool no_dist;   // Distance & flag information in Neighbor is not valid.
    static_assert(sizeof(unsigned) == sizeof(uint32_t), "unsigned must be 32-bit");
    ifstream is(path, ios::binary);
    char magic[KGRAPH_MAGIC_SIZE];
    uint32_t sig_version;
    uint32_t sig_cap;
    uint32_t N;
    is.read(magic, sizeof(magic));
    is.read(reinterpret_cast<char *>(&sig_version), sizeof(sig_version));
    is.read(reinterpret_cast<char *>(&sig_cap), sizeof(sig_cap));
    if (sig_version != SIGNATURE_VERSION) throw runtime_error("data version not supported.");
    is.read(reinterpret_cast<char *>(&N), sizeof(N));
    if (!is) runtime_error("error reading index file.");
    for (unsigned i = 0; i < KGRAPH_MAGIC_SIZE; ++i) {
        if (KGRAPH_MAGIC[i] != magic[i]) runtime_error("index corrupted.");
    }
    no_dist = sig_cap & FORMAT_NO_DIST;
    //graph.resize(N);
    M.resize(N);
    vector<uint32_t> nids;
    for (unsigned i = 2; i < 50002; ++i) {
        cout << "==========" << i << endl;
        //auto &knn = graph[i];
        unsigned K;
        is.read(reinterpret_cast<char *>(&M[i]), sizeof(M[i]));
        is.read(reinterpret_cast<char *>(&K), sizeof(K));
        if (!is) runtime_error("error reading index file.");
        //knn.resize(K);
        if (no_dist) {
            nids.resize(K);
            is.read(reinterpret_cast<char *>(&nids[0]), K * sizeof(nids[0]));
            for (unsigned k = 0; k < K; ++k) {
                //knn[k].id = nids[k];
                extract_graph[i][k] = nids[k];
                //knn[k].dist = 0;
                //knn[k].flag = false;
                }
            }
            else {
                //is.read(reinterpret_cast<char *>(&knn[0]), K * sizeof(knn[0]));
            }
    }
    for(int i = 0; i<50; ++i)
    {
        for(int j = 0; j<25; ++j)
        {
            cout<<extract_graph[i][j]<<" ";
        }
        cout<<endl;
    }
}

int main()
{
    //vector<uint48_t> hash_code;
    struct uint48_t hash_code[50000];
    //vector<bitset<48>> hash_code;
    uint32_t graph[50002][25];
    load_graph("kv260_hamming_index",graph);
    cout<<"---------------------------------"<<endl;
    for(int i = 0; i<50; ++i)
    {
        for(int j = 0; j<25; ++j)
        {
            cout<<graph[i][j]<<" ";
        }
        cout<<endl;
    }
    cout<<"*********************************************************"<<endl;
    string s;
    ifstream infile_database;
    infile_database.open("kv260_train_hash_code.txt");
    int j = 0;
    while(getline(infile_database,s))
    {   
        deleteAllMark(s," ");
        uint64_t result = 0LL;
        uint8_t i=0;
        for(auto iter = s.begin(); iter != s.end();++iter)
        {
            string str;
            str = *iter;
            //cout<<*iter;
           if(str.compare("0")==0)
            {
               result = set_bit(result,(uint8_t)i,(uint8_t)0);
            }
            else if(str.compare("1")==0)
            {
                result = set_bit(result,(uint8_t)i,(uint8_t)1);
            }
            i++;
        }
        result = result >> 16;
        hash_code[j].data = result;
        //if(j<10) cout<<bitset<sizeof(uint64_t)*64>(hash_code[j].data)<<endl;
        //hash_code.push_back(result>>16);
        //if(j<10) cout<<hash_code[j]<<endl;
        j++;
    }
    cout<<"=========================start========================================"<<endl;
    ofstream out("kv260_init_input_data_test.bin",ios::binary|ios::trunc);
    vector<string> string_hash;
    
    for(int i =0; i<50002;++i)
    {
        for(int j=0; j<25; ++j)
        {
            stringstream ss;
            ss<<setfill('0')<<setw(sizeof(uint32_t)*2)<<std::hex<<graph[i][j];
            ss<<setfill('0')<<setw(sizeof(uint32_t)*3)<<std::hex<<hash_code[graph[i][j]].data;
            string sss  = ss.str();
            string push;
            transform(sss.begin(),sss.end(),push.begin(),::toupper);
            push = boost::to_upper_copy<std::string>(sss);
            cout<<"push="<<push<<endl;
            string com("00000000");
            string comp(sss.substr(0,8));
            cout<<comp<<endl;
            if(comp.compare(com) == 0)
            {
                cout<<push.c_str()<<" "<<endl;
            }
            cout<<sss<<" "<<endl;
            cout<<"buffer content="<<push.c_str()<<endl;
            cout<<"====================="<<endl;
            char buffer[buffersize];
            char data[datasize];
            strcpy(buffer,push.c_str());
            cout<<"test liang"<<endl;
            *(buffer+buffersize-1) = '\0';
            charArray2intArray(buffer,data);
            out.write(data,datasize);
            //strcpy(id_buffer,
            //out.write(&graph[i][j],sizeof(uint32_t));
        }
        //cout<<sizeof(uint32_t)<<" "<<sizeof(uint8_t)<<endl;
        //cout<<endl;
    }

    /*for(int i=0; i<50000;i++)
    {
        stringstream ss;
        //cout<<hash_code[i].data<<" ";
        ss<<std::hex << hash_code[i].data;
        string sss = ss.str();
        string push;
        transform(sss.begin(),sss.end(),push.begin(), ::toupper);
        //cout<<"sss = " <<push.c_str()<<endl;
        char buffer[buffersize];
        char data[datasize];
        strcpy(buffer,push.c_str());
        *(buffer+buffersize-1)='\0';
        charArray2intArray(buffer,data);
        out.write(data,datasize);
        string_hash.push_back(push.c_str());
    }*/
    //cout<<"hashcode size="<<hash_code.size()<<endl;
    
    ofstream outfile("kv260_hashcode.txt");
    ofstream out_binary("kv260_hash_code.bin",ofstream::binary);
    if(!outfile || !out_binary)
    {
        cout<<"Create file error"<<endl;
        return 0;
    }
    
    //std::ostream_iterator<std::string> output_iterator(outfile, "\n");
    //std::copy(string_hash.begin(), string_hash.end(), output_iterator);
    

    //out_binary.write((char*)string_hash[0].c_str(),6*sizeof(char));
    //out_binary.close();


    //cout<<"the size of="<<sizeof(hash_code)<<endl;
    //outfile.write((char *)&string_hash[0],50000*sizeof(string_hash));
    outfile.close();
    out.close();
    return 0;

}
