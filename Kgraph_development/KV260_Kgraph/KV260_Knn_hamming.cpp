/*************************************************************************
	> File Name: Knn_hamming.cpp
	> Author: 
	> Mail: 
	> Created Time: 2017年11月07日 星期二 19时18分39秒
 ************************************************************************/

#include<iostream>
#include<cassert>
#include<string>
#include<algorithm>
#include<vector>
#include<time.h>
#include<fstream>
#include<functional>
#include<sstream>
#include "kgraph.h"
#include "kgraph-data.h"
using namespace std;
using namespace kgraph;
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
template <class Type>  
Type stringToNum(const string& str)  
{  
    istringstream iss(str);  
    Type num;  
    iss >> num;  
    return num;      
}
int popcount64d(uint64_t x)
{
    int count;
    for (count=0; x; count++)
        x &= x - 1;
    return count;
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
int count_hamm = 0;
int main()
{
    //string query  = "011110011011111001110001111000001101010101100001";
    //string query2 = "111110011011111001110001111000001101010101100000";
    string s;
    
    Matrix<uint64_t> hash_code(50000,1);
    Matrix<uint64_t> query_code(10000,1);
    vector<int> hamming_result;
    vector<std::string> database_label;
    vector<std::string> query_label;
    ifstream infile_database,infile_database_label,infile_query,infile_query_label;
    infile_database.open("kv260_train_hash_code.txt");
    infile_database_label.open("../data/cifar10/train-label.txt");
    infile_query.open("kv260_test_hash_code.txt");
    infile_query_label.open("../data/cifar10/test-label.txt");
    uint64_t me=0;
    int j=0;
    while(getline(infile_database,s))
    {   
        deleteAllMark(s," ");
        uint64_t result = 0LL;
        uint8_t i=0;
        if(j<50000)
        {

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
        }
        else{
            break;
        }
        //cout<<"--"<<result<<endl;
        hash_code[j][0] = result;
        me = me + result;
        j++;
    }
    j=0;
    while(getline(infile_query,s))
    {   
        deleteAllMark(s," ");
        uint64_t result = 0LL;
        uint8_t i=0;
        if(j<10000)
        {

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
        }
        else{
            break;
        }
        //cout<<"--"<<result<<endl;
        query_code[j][0] = result;
        j++;
    }
    //cout<<me<<endl;
    while(getline(infile_database_label,s))
    {
        database_label.push_back(s);
    }
    while(getline(infile_query_label,s))
    {
        query_label.push_back(s);
    }
    hash_code.save_lshkit("kv260_hash_code");
    unsigned dim = hash_code.dim();
    VectorOracle<Matrix<uint64_t>, uint64_t const*> oracle(hash_code,
            [dim](uint64_t const *a, uint64_t const *b)
            {
                count_hamm ++;
                uint64_t r = popcount64d(*a^*b);
                //cout<<"r---"<<r<<endl;
                return r;
            });
    KGraph::SearchParams Sparams;
    Sparams.K = 50 ;
    //Sparams.P = 15;
    Sparams.S = 100;
    KGraph *kgraph = KGraph::create();
    {
        KGraph::IndexParams params;
        params.L = 25;
        //params.reverse = -1;
        kgraph->build(oracle, params, NULL);
        //kgraph->prune(oracle, 1);
        kgraph->save("kv260_hamming_index",1);
        kgraph->load("kv260_hamming_index");
    } 
    //uint64_t a = (uint64_t)133858861307233;
    uint64_t const *query = hash_code[1];
    printf("hash_code=%016lx\n",(*query>>16));
    cout<<"hash_code="<<(*query>>16)<<endl;
    //uint64_t const *quer = query_code[300]; //query_code[200] error rate higher
    //uint64_t const *query = &me;
    Matrix<unsigned> result;
    result.resize(50000,50000);
    cout<<"query_label---"<<database_label.at(0)<<endl;
    KGraph::SearchInfo info;
    Matrix<unsigned> res;
    res.resize(50000,50000);
    //uint64_t a = (uint64_t)133858861307233;
    double accuracy=0;
    for(int j=0;j<100;j++){
        uint64_t const *quer = query_code[j];
        printf("query=%016lx\n",(*quer>>16));
        cout<<"query code="<<(*quer>>16)<<endl;
        //uint64_t const *quer = query_code[300]; //query_code[200] error rate higher
        KGraph::SearchParams Sparams_s;
        Sparams_s.K = 100;
        //Sparams_s.P = 32;
        Sparams_s.S = 100;
        //Sparams_s.init = 99;
    
        kgraph->search(oracle.query(quer),Sparams_s,res[0]);
        //cout<<"++++++++++++++++++++++++++++++++++++++++++++++"<<endl;
        //cout<<"query_label="<<query_label.at(300)<<endl;
        int error_cout = 0;
        for(int i=0;i<Sparams_s.K;i++)
        {
            //cout<<res[0][i]<<"---"<<database_label.at(res[0][i])<<" ";
            if(database_label.at(res[0][i]) != query_label.at(j))
            {
                error_cout++;
            }
        }
        accuracy += (1-(double)(error_cout)/Sparams_s.K);
        cout<<"error rate="<<error_cout<<"="<<(double)(error_cout/Sparams_s.K);
        cout<<"accuracy"<<accuracy<<endl;
     }
    cout<<"final accuracy="<<accuracy/100<<endl;
}
