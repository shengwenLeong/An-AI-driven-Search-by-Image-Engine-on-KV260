#include "dpu.h"

float mean[3] = {104, 117, 123};

static std::vector<float> convert_fixpoint_to_float(vart::TensorBuffer* tensor,
                                                    float scale);
uint64_t runDPU(std::unique_ptr<vart::Runner> &runner, std::string image_file_name);

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

uint64_t runDPU(std::unique_ptr<vart::Runner> &runner, std::string image_file_name) {
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
    return generateHash(output_tensor_buffer.get(), output_scale[0]);
}

uint64_t DPU_hash(std::string ImagePath) {
	if(ImagePath == "") {
		std::cout << "--error!, image is empty--" << std::endl;
	}
	std::cout << "----start execute DPU for hashcode extraction-----" << std::endl;
    auto runner = InitDPU("./model/googlenet.xmodel");
    return runDPU(runner, ImagePath);
}

uint64_t generateHash (vart::TensorBuffer* tensor_buffer, float scale) {
	auto sigmoid_input = convert_fixpoint_to_float(tensor_buffer, scale);
	std::cout << "output size = " << sigmoid_input.size() << std::endl;
	float *sigmoid = new float[48];
	int i = 0;
	for(auto val : sigmoid_input) {
		sigmoid[i] = 1. / (1. + exp(-val));
		i++;
	}
	uint64_t hashcode = 0;
    for (int i=0; i<48; i++)
    {
    	hashcode = sigmoid[i]>0.5? (hashcode | ((uint64_t)1 << (63-i))): ((hashcode & (~((uint64_t)1 << (63-i)))));
    }
    printf("val = %#018"PRIx64"\n", hashcode);
    return hashcode;
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
}
