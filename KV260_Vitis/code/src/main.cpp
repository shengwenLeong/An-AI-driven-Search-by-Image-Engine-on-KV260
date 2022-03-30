/*
 * Copyright 2019 Xilinx Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <assert.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <atomic>
#include <sys/stat.h>
#include <unistd.h>
#include <cassert>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <queue>
#include <mutex>
#include <string>
#include <vector>
#include <thread>
#include <mutex>

#include "../include/accelerator.h"
#include "../include/crow_all.h"
#include "../include/dpu.h"

using namespace std::chrono;

const string baseImagePath = "/home/petalinux/cifar10/";
string query_image_path = baseImagePath + "batch1/7331.jpg";
vector<string> cifar10_file_path;

void init()
{
	ifstream infile_database;
	infile_database.open("/home/petalinux/cifar10/train.txt");

	string s;
	while(getline(infile_database, s))
	{
		s = s.substr(0, s.find(" "));
		cifar10_file_path.push_back(s);
	}
}

vector<string> run()
{
	uint64_t hash_code;
	vector<string> result_file_path;

	auto dpu_start = system_clock::now();

    hash_code = DPU_hash(query_image_path);

    auto dpu_end = system_clock::now();
    auto dpu_duration = (duration_cast<microseconds>(dpu_end - dpu_start)).count();
    cout << "[DPU Time]" << dpu_duration << "us" << endl;


    std::cout << "----DPU for hashcode extraction end-----" << std::endl;
    printf("hash_code = %#018"PRIx64"\n", hash_code);
    printf("hash_code = %"PRIx32"\n", (uint32_t)(hash_code>>32));
    printf("hash_code = %"PRIx32"\n", (uint32_t)(hash_code));

    unsigned int *Result_ID;

    auto kgraph_start = system_clock::now();

    Result_ID = Run_KGraph(hash_code);

    auto kgraph_end = system_clock::now();
    auto kgraph_duration = (duration_cast<microseconds>(kgraph_end - kgraph_start)).count();
    cout << "[KGraph Time]" << kgraph_duration << "us" << endl;

	for(int i=0;i<100;i++) {
		result_file_path.push_back(baseImagePath + cifar10_file_path.at(Result_ID[i]));
		printf("result=%d\n",Result_ID[i]);
	}
	delete[] Result_ID;

	return result_file_path;
}

int main(int argc, char **argv)
{
    printf("== START: AXI FPGA test ==\n");
    init();
    KGraph_Open();

    cout << "Hello World!" << endl;

    crow::SimpleApp app;
    crow::mustache::set_base(".");

    CROW_ROUTE(app, "/")
    ([]{
        crow::mustache::context ctx;
        return crow::mustache::load("./Web/a_test.html").render();
    });

    CROW_ROUTE(app, "/test")
    ([](const crow::request& /*req*/, crow::response& res){
        string key= "Access-Control-Allow-Origin";
        string value = "*";
        res.add_header(key,value);
        crow::json::wvalue x;
        vector<string> result;

        result = run();

        vector<string>::iterator it;
        int i=0;
        for(it = result.begin();it != result.end() ; it++)
        {
            string str = (*it).c_str();
            replace(str.begin(),str.end(),'/','+');
            x["img_path"][i] = str;
            i=i+1;
        }
        vector<string>(result).swap(result);
        res.write(crow::json::dump(x));
        res.end();
        //return crow::response(x);
    });
    CROW_ROUTE(app,"/add")
    ([](const crow::request& /*req*/, crow::response& res){
        std::ostringstream os;
        std::ifstream fin("img/thumbs/2-3.jpg",std::ios::binary);
        os << fin.rdbuf();
        res.set_header("Content-Type","image/jpeg");
        res.write(os.str());
        res.end();
    });
    CROW_ROUTE(app,"/img/<string>")
    ([](string a){
        replace(a.begin(),a.end(),'+','/');
        crow::response res;
        std::ostringstream os;
        std::ifstream fi_1(a,std::ios::binary);
        os << fi_1.rdbuf();
        res.set_header("Content-Type","image/jpeg");
        res.write(os.str());
        return res;
    });
    CROW_ROUTE(app,"/herf/<string>")
    ([](string a){
        crow::response res;
        std::ostringstream os;
        //std::ifstream fi_1("img/"+a,std::ios::binary);
        os << a;
        res.set_header("Content-Type","text/html");
        res.write(os.str());
        return res;
    });
    CROW_ROUTE(app,"/css")
    ([](){
        crow::response res;
        std::ostringstream os;
        std::ifstream fi_1("/home/petalinux/Web/css/baguetteBox.css",std::ios::binary);
        os << fi_1.rdbuf();
        res.set_header("Content-Type","text/css");
        res.write(os.str());
        return res;
    });
    CROW_ROUTE(app,"/style")
    ([](){
        crow::response res;
        std::ostringstream os;
        std::ifstream fi_1("/home/petalinux/Web/css/style.css",std::ios::binary);
        os << fi_1.rdbuf();
        res.set_header("Content-Type","text/css");
        res.write(os.str());
        return res;
    });
    CROW_ROUTE(app,"/box")
    ([](){
        crow::response res;
        std::ostringstream os;
        std::ifstream fi_1("/home/petalinux/Web/js/baguetteBox.js",std::ios::binary);
        os << fi_1.rdbuf();
        res.set_header("Content-Type","application/x-javascript");
        res.write(os.str());
        return res;
    });
    CROW_ROUTE(app, "/upload")
        .methods("GET"_method, "POST"_method)
    ([](const crow::request& req)
    {
        string tokens[6] ={"name=\"","\"; filename=\"","\"\r\n","Content-Type: ","\r\n\r\n","\r\n------WebKitFormBoundary"};
        int position[6];
        for(int i=0;i<6;i++)
        {
            position[i] = req.body.find(tokens[i]);
            //CROW_LOG_INFO << "position" <<i<<"="<<position[i];
        }
        string name = req.body.substr(position[0]+tokens[0].length(),position[1]-position[0]-tokens[0].length());
        string filename = req.body.substr(position[1]+tokens[1].length(),position[2]-position[1]-tokens[1].length());
        string ContentType = req.body.substr(position[3]+tokens[3].length(),position[4]-position[3]-tokens[3].length());
        string filecontent = req.body.substr(position[4]+tokens[4].length(),position[5]-position[4]-tokens[4].length());
        string final_string = req.body.substr(position[5]);
        query_image_path = "/home/petalinux/userupload/" + filename;
        /*CROW_LOG_INFO << "name=" <<name;
        CROW_LOG_INFO << "filename=" <<filename;
        CROW_LOG_INFO << "Content-Type=" <<ContentType;
        CROW_LOG_INFO << "final_string=" <<final_string;*/
        std::ofstream file(query_image_path, std::ios::binary);
        file.write(reinterpret_cast<const char*>(filecontent.c_str()),filecontent.length());
        file.close();
        return "aa";
    });
    CROW_ROUTE(app,"/icon")
    ([](){
        crow::response res;
        std::ostringstream os;
        std::ifstream fi_1("/home/petalinux/Web/icon.png",std::ios::binary);
        os << fi_1.rdbuf();
        res.set_header("Content-Type","image/jpeg");
        res.write(os.str());
        return res;
    });
    CROW_ROUTE(app,"/query_image")
    ([](){
        crow::response res;
        std::ostringstream os;
        std::ifstream fi_1("/home/petalinux/Web/Query_Image.png",std::ios::binary);
        os << fi_1.rdbuf();
        res.set_header("Content-Type","image/jpeg");
        res.write(os.str());
        return res;
    });
    app.port(50080)
        .multithreaded()
        .run();

    //DPU_close();
    KGraph_Close();

    printf("== STOP ==\n");

    return 0;
}





/*#include <assert.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <atomic>
#include <sys/stat.h>
#include <unistd.h>
#include <cassert>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <queue>
#include <mutex>
#include <string>
#include <vector>
#include <thread>
#include <mutex>

#include "../include/accelerator.h"
#include "../include/crow_all.h"

int main(int argc, char **argv)
{


    printf("== START: AXI FPGA test ==\n");
    accelerator_init();
    crow::SimpleApp app;

    CROW_ROUTE(app, "/")([](){
        return "Hello world";
    });

    app.port(18080).multithreaded().run();

    printf("== STOP ==\n");

    return 0;
}*/



/*#include <glog/logging.h>

#include <sstream>
#include <vector>
#include <iterator>
#include <algorithm>
#include <cmath>
#include <functional>
#include <iomanip>
#include <iostream>
#include <memory>
#include <numeric>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <vitis/ai/env_config.hpp>
#include <xir/graph/graph.hpp>

#include "vart/dpu/vitis_dpu_runner_factory.hpp"
#include "vart/mm/host_flat_tensor_buffer.hpp"
#include "vart/runner_ext.hpp"
#include "vart/tensor_buffer.hpp"

float mean[3] = {104, 117, 123};

static std::vector<float> convert_fixpoint_to_float(vart::TensorBuffer* tensor,
                                                    float scale);
static void generateHash (vart::TensorBuffer* tensor_buffer, float scale);

static cv::Mat read_image(const std::string& image_file_name) {
  // read image from a file
  auto input_image = cv::imread(image_file_name);
  CHECK(!input_image.empty()) << "cannot load " << image_file_name;
  return input_image;
}

static std::unique_ptr<vart::TensorBuffer> create_cpu_flat_tensor_buffer(
    const xir::Tensor* tensor) {
  return std::make_unique<vart::mm::HostFlatTensorBuffer>(tensor);
}

inline std::vector<const xir::Subgraph*> get_dpu_subgraph(
    const xir::Graph* graph) {
  auto root = graph->get_root_subgraph();
  auto children = root->children_topological_sort();
  auto ret = std::vector<const xir::Subgraph*>();
  for (auto c : children) {
    CHECK(c->has_attr("device"));
    auto device = c->get_attr<std::string>("device");
    if (device == "DPU") {
      ret.emplace_back(c);
    }
  }
  return ret;
}

std::unique_ptr<vart::Runner> InitDPU(string model_name) {
    const auto kernel_name = std::string("subgraph_avg_pool_12/8x8_s1");
    auto graph = xir::Graph::deserialize(model_name);
    auto subgraph = get_dpu_subgraph(graph.get());
    auto runner = vart::dpu::DpuRunnerFactory::create_dpu_runner(model_name, kernel_name);
    return runner;
}

void runDPU(std::unique_ptr<vart::Runner> &runner, std::string image_file_name) {
    auto input_tensors = runner->get_input_tensors();
    auto output_tensors = runner->get_output_tensors();

    // create runner and input/output tensor buffers;
    auto input_scale = vart::get_input_scale(input_tensors);
    auto output_scale = vart::get_output_scale(output_tensors);

    // prepare input tensor buffer
    CHECK_EQ(input_tensors.size(), 1u) << "only support googlenet model";
    auto input_tensor = input_tensors[0];
    auto height = input_tensor->get_shape().at(1);
    auto width = input_tensor->get_shape().at(2);
    auto input_tensor_buffer = create_cpu_flat_tensor_buffer(input_tensor);

    // prepare output tensor buffer
    CHECK_EQ(output_tensors.size(), 1u) << "only support googlenet model";
    auto output_tensor = output_tensors[0];
    auto output_tensor_buffer = create_cpu_flat_tensor_buffer(output_tensor);

    uint64_t data_in = 0u;
    size_t size_in = 0u;
    std::tie(data_in, size_in) = input_tensor_buffer->data(std::vector<int>{0, 0, 0, 0});

    cv::Mat input_image = read_image(image_file_name);
    CHECK(!input_image.empty()) << "cannot load " << image_file_name;
    int8_t* data = (int8_t*)data_in;
    cv::Mat image2 = cv::Mat(height, width, CV_8SC3);
    cv::resize(input_image, image2, cv::Size(height, width), 0, 0, cv::INTER_NEAREST);
    for (int h = 0; h < height; h++) {
      for (int w = 0; w < width; w++) {
        for (int c = 0; c < 3; c++) {
        	float tmp = ((float)image2.at<cv::Vec3b>(h, w)[c]) - mean[c];
          	data[h*width*3+w*3 + c] = (int8_t) ( tmp * input_scale[0]); //in BGR mode
    	    //data_in[h*inWidth*3+w*3 +2-c] = (int8_t) ( tmp * input_scale[0]); //in RGB mode
        }
      }
    }
    auto v = runner->execute_async({input_tensor_buffer.get()}, {output_tensor_buffer.get()});
    auto status = runner->wait((int)v.first, -1);
    CHECK_EQ(status, 0) << "failed to run dpu";
    generateHash(output_tensor_buffer.get(), output_scale[0]);
}

vector<string> images; // Storing the label of Resnet_50
vector<string> hash_code; // Storing the list of images

void ReadImagePath(std::string file)
{
	ifstream infile;
	infile.open(file.data());
	assert(infile.is_open());

	string s;
	while(getline(infile,s))
	{
		cout << s.substr(0,s.find(' ')) <<endl;
		images.emplace_back(s.substr(0,s.find(' ')));
	}

	infile.close();
}

void WriteHashCodeToFile(std::string file)
{
	std::ofstream outfile;
	outfile.open(file.data());
	assert(outfile.is_open());

	std::ostream_iterator<std::string> output_iterator(outfile, "\n");
	copy(hash_code.begin(), hash_code.end(), output_iterator);
	outfile.close();
}

string int_array_to_string(int int_array[], int size_of_array) {
  ostringstream oss("");
  for (int temp = 0; temp < size_of_array; temp++)
  {
	  oss << int_array[temp];
      oss << " ";
  }
  //cout << oss.str() << endl;
  return oss.str();
}

int main(int argc, char* argv[]) {
	std::cout << "enter this liangshengwen 2-------------" << std::endl;
    const auto image_file_name = std::string(argv[1]);  // std::string(argv[2]);
    const auto model_name      = std::string(argv[2]);
    auto runner = InitDPU(model_name);

    const std::string cifar10_path = "../cifar10/";
    ReadImagePath(cifar10_path + "val.txt");
    std::cout << "images.size=" << images.size() << std::endl;
    for(int i = 0; i < images.size(); i++) {
    	std::cout << "path = " << images[i] << std::endl;
    	runDPU(runner, cifar10_path + images[i]);
    }
    WriteHashCodeToFile("test_hash_code.txt");
    // LOG(INFO) << "bye";
    return 0;
}

static void generateHash (vart::TensorBuffer* tensor_buffer, float scale) {
	auto sigmoid_input = convert_fixpoint_to_float(tensor_buffer, scale);
	std::cout << "output size = " << sigmoid_input.size() << std::endl;
	float *sigmoid = new float[48];
	int i = 0;
	for(auto val : sigmoid_input) {
		sigmoid[i] = 1. / (1. + exp(-val));
		i++;
	}
	uint64_t hashcode = 0;
	int *Hash_code = new int[48];
    for (int i=0; i<48; i++)
    {
    	Hash_code[i] = sigmoid[i] > 0.5? 1 : 0;
    	hashcode = sigmoid[i]>0.5? (hashcode | ((uint64_t)1 << (63-i))): ((hashcode & (~((uint64_t)1 << (63-i)))));
    }
    printf("val = %#018"PRIx64"\n", hashcode);
    hash_code.emplace_back(int_array_to_string(Hash_code, 48));

}


static std::vector<float> convert_fixpoint_to_float(
    vart::TensorBuffer* tensor_buffer, float scale) {
  uint64_t data = 0u;
  size_t size = 0u;
  std::tie(data, size) = tensor_buffer->data(std::vector<int>{0, 0});
  signed char* data_c = (signed char*)data;
  auto ret = std::vector<float>(size);
  transform(data_c, data_c + size, ret.begin(),
            [scale](signed char v) { return ((float)v) * scale; });
  return ret;
}*/
